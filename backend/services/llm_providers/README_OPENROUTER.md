# OpenRouter Integration

OpenRouter telah terintegrasi ke dalam ALwrity untuk memberikan akses ke berbagai model LLM melalui satu API.

## Konfigurasi

### 1. Dapatkan API Key dari OpenRouter

1. Daftar di [OpenRouter.ai](https://openrouter.ai)
2. Buat API key di dashboard
3. Simpan API key Anda

### 2. Set Environment Variable

Tambahkan ke file `.env`:

```bash
OPENROUTER_API_KEY=sk-or-v1-xxxxx
OPENROUTER_MODEL=openai/gpt-4-turbo  # Optional, default: openai/gpt-4-turbo
OPENROUTER_HTTP_REFERER=https://alwrity.com  # Optional
OPENROUTER_X_TITLE=ALwrity  # Optional
```

Atau simpan melalui API Key Manager di aplikasi.

### 3. Set Provider (Optional)

Untuk menggunakan OpenRouter sebagai provider default:

```bash
GPT_PROVIDER=openrouter
```

## Model yang Tersedia

OpenRouter mendukung berbagai model dari berbagai provider:

- **OpenAI**: `openai/gpt-4-turbo`, `openai/gpt-4`, `openai/gpt-3.5-turbo`
- **Anthropic**: `anthropic/claude-3-opus`, `anthropic/claude-3-sonnet`
- **Mistral**: `mistralai/mistral-large`, `mistralai/mixtral-8x7b`
- **Google**: `google/gemini-pro`, `google/gemini-pro-vision`
- Dan banyak lagi...

Lihat [OpenRouter Models](https://openrouter.ai/models) untuk daftar lengkap.

## Penggunaan

### Melalui Environment Variable

```python
import os
os.environ['GPT_PROVIDER'] = 'openrouter'
os.environ['OPENROUTER_MODEL'] = 'openai/gpt-4-turbo'

from services.llm_providers.main_text_generation import llm_text_gen

response = llm_text_gen(
    prompt="Write a blog post about AI",
    user_id="user_123"
)
```

### Langsung Menggunakan Provider

```python
from services.llm_providers.openrouter_provider import (
    openrouter_text_response,
    openrouter_structured_json_response
)

# Text response
response = openrouter_text_response(
    prompt="Write a blog post about AI",
    model="openai/gpt-4-turbo",
    temperature=0.7,
    max_tokens=2048
)

# Structured JSON response
schema = {
    "type": "object",
    "properties": {
        "title": {"type": "string"},
        "content": {"type": "string"}
    }
}

response = openrouter_structured_json_response(
    prompt="Generate a blog post",
    schema=schema,
    model="anthropic/claude-3-opus",
    temperature=0.2
)
```

## Auto-Detection

Jika tidak ada `GPT_PROVIDER` yang di-set, sistem akan otomatis mendeteksi provider berdasarkan API key yang tersedia dengan prioritas:

1. Google Gemini (jika `GEMINI_API_KEY` tersedia)
2. OpenRouter (jika `OPENROUTER_API_KEY` tersedia)
3. Hugging Face (jika `HF_TOKEN` tersedia)

## Fallback

Jika provider utama gagal, sistem akan otomatis mencoba fallback ke provider lain yang tersedia dengan urutan:

1. Google Gemini
2. OpenRouter
3. Hugging Face

## Tracking & Usage

OpenRouter usage akan ditrack secara terpisah dengan kolom:
- `openrouter_calls`: Jumlah API calls
- `openrouter_tokens`: Total tokens digunakan
- `openrouter_cost`: Total biaya

## Troubleshooting

### Error: "OPENROUTER_API_KEY not found"

Pastikan API key sudah di-set di `.env` atau melalui API Key Manager.

### Error: "Model not found"

Pastikan model identifier benar. Format: `provider/model-name` (contoh: `openai/gpt-4-turbo`)

### Rate Limiting

OpenRouter memiliki rate limits. Jika terjadi rate limit error, sistem akan otomatis retry dengan exponential backoff.

## Referensi

- [OpenRouter Documentation](https://openrouter.ai/docs)
- [OpenRouter Models](https://openrouter.ai/models)
- [OpenRouter Pricing](https://openrouter.ai/docs/pricing)

