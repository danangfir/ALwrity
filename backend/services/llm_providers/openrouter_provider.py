"""
OpenRouter Provider Module for ALwrity

This module provides functions for interacting with OpenRouter API, which provides
access to multiple LLM models through a unified interface.

Key Features:
- Text response generation with retry logic
- Structured JSON response generation with schema validation
- Comprehensive error handling and logging
- Automatic API key management
- Support for various models via OpenRouter (OpenAI, Anthropic, Mistral, etc.)

Best Practices:
1. Use structured output for complex, multi-field responses
2. Keep schemas simple and flat to avoid truncation
3. Set appropriate token limits (8192 for complex outputs)
4. Use low temperature (0.1-0.3) for consistent structured output
5. Implement proper error handling in calling functions
6. Specify model explicitly for predictable results

Usage Examples:
    # Text response
    result = openrouter_text_response(
        prompt, 
        model="openai/gpt-4-turbo",
        temperature=0.7, 
        max_tokens=2048
    )
    
    # Structured JSON response
    schema = {
        "type": "object",
        "properties": {
            "tasks": {
                "type": "array",
                "items": {"type": "object", "properties": {...}}
            }
        }
    }
    result = openrouter_structured_json_response(
        prompt, 
        schema, 
        model="openai/gpt-4-turbo",
        temperature=0.2, 
        max_tokens=8192
    )

Dependencies:
- openai (for OpenRouter API compatibility)
- tenacity (for retry logic)
- logging (for debugging)
- json (for fallback parsing)

Author: ALwrity Team
Version: 1.0
Last Updated: January 2025
"""

import os
import sys
from pathlib import Path
from typing import Optional, Dict, Any
import json
import re

from dotenv import load_dotenv
from loguru import logger
from tenacity import (
    retry,
    stop_after_attempt,
    wait_random_exponential,
)

# Fix the environment loading path - load from backend directory
current_dir = Path(__file__).parent.parent  # services directory
backend_dir = current_dir.parent  # backend directory
env_path = backend_dir / '.env'

if env_path.exists():
    load_dotenv(env_path)
else:
    load_dotenv()

try:
    import openai
except ImportError:
    logger.error("openai package not installed. Install with: pip install openai")
    raise

from ..onboarding.api_key_manager import APIKeyManager


def get_openrouter_api_key() -> str:
    """Get OpenRouter API key with proper error handling."""
    api_key_manager = APIKeyManager()
    api_key = api_key_manager.get_api_key("openrouter")
    
    if not api_key:
        # Fallback to environment variable
        api_key = os.getenv('OPENROUTER_API_KEY')
    
    if not api_key:
        error_msg = "OPENROUTER_API_KEY not found. Please set it in your .env file or via API key manager."
        logger.error(error_msg)
        raise ValueError(error_msg)
    
    return api_key


def get_openrouter_client():
    """Get OpenRouter client configured with API key."""
    api_key = get_openrouter_api_key()
    
    # OpenRouter uses OpenAI-compatible API
    client = openai.OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key=api_key,
        default_headers={
            "HTTP-Referer": os.getenv("OPENROUTER_HTTP_REFERER", "https://alwrity.com"),
            "X-Title": os.getenv("OPENROUTER_X_TITLE", "ALwrity"),
        }
    )
    
    return client


@retry(wait=wait_random_exponential(min=1, max=60), stop=stop_after_attempt(6))
def openrouter_text_response(
    prompt: str,
    model: str = "openai/gpt-4-turbo",
    temperature: float = 0.7,
    max_tokens: int = 2048,
    top_p: float = 1.0,
    system_prompt: Optional[str] = None
) -> str:
    """
    Generate text response using OpenRouter API.
    
    Args:
        prompt (str): The input prompt for the AI model
        model (str): Model identifier (e.g., "openai/gpt-4-turbo", "anthropic/claude-3-opus")
        temperature (float): Controls randomness (0.0-2.0). Higher = more creative
        max_tokens (int): Maximum tokens in response
        top_p (float): Nucleus sampling parameter (0.0-1.0)
        system_prompt (str, optional): System instruction for the model
    
    Returns:
        str: Generated text response
        
    Raises:
        Exception: If API key is missing or API call fails
        
    Example:
        result = openrouter_text_response(
            "Write a blog post about AI", 
            model="openai/gpt-4-turbo",
            temperature=0.8, 
            max_tokens=1024
        )
    """
    try:
        client = get_openrouter_client()
        
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": prompt})
        
        logger.debug(f"[openrouter_text_response] Calling model: {model}, prompt length: {len(prompt)}")
        
        response = client.chat.completions.create(
            model=model,
            messages=messages,
            temperature=temperature,
            max_tokens=max_tokens,
            top_p=top_p,
        )
        
        if not response or not response.choices:
            raise ValueError("Empty response from OpenRouter API")
        
        result_text = response.choices[0].message.content
        
        if not result_text:
            raise ValueError("No content in response from OpenRouter API")
        
        logger.debug(f"[openrouter_text_response] Successfully generated {len(result_text)} characters")
        return result_text.strip()
        
    except Exception as e:
        logger.error(f"[openrouter_text_response] Error: {str(e)}")
        raise


@retry(wait=wait_random_exponential(min=1, max=60), stop=stop_after_attempt(6))
def openrouter_structured_json_response(
    prompt: str,
    schema: Dict[str, Any],
    model: str = "openai/gpt-4-turbo",
    temperature: float = 0.2,
    max_tokens: int = 8192,
    system_prompt: Optional[str] = None
) -> Dict[str, Any]:
    """
    Generate structured JSON response using OpenRouter API with schema validation.
    
    Args:
        prompt (str): The input prompt for the AI model
        schema (dict): JSON schema defining the expected output structure
        model (str): Model identifier (e.g., "openai/gpt-4-turbo")
        temperature (float): Controls randomness (0.0-2.0). Lower = more consistent
        max_tokens (int): Maximum tokens in response
        system_prompt (str, optional): System instruction for the model
    
    Returns:
        dict: Parsed JSON response matching the schema
        
    Raises:
        Exception: If API key is missing, API call fails, or JSON parsing fails
        
    Example:
        schema = {
            "type": "object",
            "properties": {
                "title": {"type": "string"},
                "content": {"type": "string"}
            }
        }
        result = openrouter_structured_json_response(
            "Generate a blog post",
            schema,
            model="openai/gpt-4-turbo"
        )
    """
    try:
        client = get_openrouter_client()
        
        # Enhance prompt with schema instructions
        schema_str = json.dumps(schema, indent=2)
        enhanced_prompt = f"""{prompt}

IMPORTANT: You must respond with valid JSON that matches this exact schema:
{schema_str}

Return ONLY the JSON object, no additional text or markdown formatting."""
        
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": enhanced_prompt})
        
        logger.debug(f"[openrouter_structured_json_response] Calling model: {model}, schema: {schema.get('type', 'unknown')}")
        
        # Use response_format for models that support it (OpenAI models)
        response_kwargs = {
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
        }
        
        # Add response_format for OpenAI models
        if model.startswith("openai/"):
            try:
                response_kwargs["response_format"] = {"type": "json_object"}
            except Exception:
                pass  # Some models may not support this
        
        response = client.chat.completions.create(**response_kwargs)
        
        if not response or not response.choices:
            raise ValueError("Empty response from OpenRouter API")
        
        result_text = response.choices[0].message.content
        
        if not result_text:
            raise ValueError("No content in response from OpenRouter API")
        
        # Clean and parse JSON
        result_text = result_text.strip()
        
        # Remove markdown code blocks if present
        if result_text.startswith("```"):
            result_text = re.sub(r'^```(?:json)?\s*\n', '', result_text)
            result_text = re.sub(r'\n```\s*$', '', result_text)
        
        try:
            parsed_json = json.loads(result_text)
            logger.debug(f"[openrouter_structured_json_response] Successfully parsed JSON response")
            return parsed_json
        except json.JSONDecodeError as e:
            logger.error(f"[openrouter_structured_json_response] JSON parsing failed: {e}")
            logger.error(f"[openrouter_structured_json_response] Response text: {result_text[:500]}")
            raise ValueError(f"Failed to parse JSON response: {str(e)}")
        
    except Exception as e:
        logger.error(f"[openrouter_structured_json_response] Error: {str(e)}")
        raise


def list_available_models() -> list:
    """
    List available models from OpenRouter.
    
    Returns:
        list: List of available model identifiers
    """
    try:
        client = get_openrouter_client()
        models = client.models.list()
        return [model.id for model in models.data]
    except Exception as e:
        logger.error(f"[list_available_models] Error: {str(e)}")
        return []


def get_model_info(model: str) -> Dict[str, Any]:
    """
    Get information about a specific model.
    
    Args:
        model (str): Model identifier
        
    Returns:
        dict: Model information
    """
    try:
        client = get_openrouter_client()
        models = client.models.list()
        for m in models.data:
            if m.id == model:
                return {
                    "id": m.id,
                    "name": getattr(m, "name", model),
                    "context_length": getattr(m, "context_length", None),
                    "pricing": getattr(m, "pricing", {}),
                }
        return {}
    except Exception as e:
        logger.error(f"[get_model_info] Error: {str(e)}")
        return {}

