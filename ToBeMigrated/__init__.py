"""
Namespace package for legacy AI tools that are being migrated into the main
ALwrity backend.

Having this file (and matching __init__.py files in subpackages) ensures that
relative imports like `..ai_web_researcher.firecrawl_web_crawler` resolve
correctly for linters and at runtime.
"""


