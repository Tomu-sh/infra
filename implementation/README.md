# LiteLLM Implementation

This folder contains the Ansible implementation for deploying LiteLLM with OpenRouter integration.

## Configuration

### Environment Setup
1. Copy `env.example` to `.env` and update with your OpenRouter API key:
   ```bash
   cp env.example .env
   # Edit .env and set OPENROUTER_API_KEY=sk-or-v1-your-actual-key-here
   ```

### Available Models
- `gpt-3.5-turbo` (OpenAI via OpenRouter)
- `gpt-4` (OpenAI via OpenRouter)
- `claude-3-haiku` (Anthropic via OpenRouter)
- `llama-3.1-8b` (Meta via OpenRouter)

## API Usage

### Authentication
Use your OpenRouter API key in the Authorization header:
```
Authorization: Bearer sk-or-v1-<your-api-key>
```

### Chat Completions
```bash
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-or-v1-<your-api-key>" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello! Please respond with just your name."}],
    "max_tokens": 50
  }'
```

### List Available Models
```bash
curl -X GET http://localhost:8080/v1/models \
  -H "Authorization: Bearer sk-or-v1-<your-api-key>"
```

### Health Check
```bash
curl http://localhost:8080/health
```

