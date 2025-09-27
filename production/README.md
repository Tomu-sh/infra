# Production LiteLLM with Nginx & SSL

Simple production setup for LiteLLM API with Nginx proxy and SSL certificates.

## Quick Setup

1. Configure your server in `inventory`
2. Set your OpenRouter API key in `.env`
3. Deploy: `make deploy`

## API Commands(For Frontend)

### Test if service is running:
```bash
curl https://api.tomu.sh/health
```

### List available models:
```bash
curl https://api.tomu.sh/litellm/v1/models \
  -H "Authorization: Bearer sk-or-v1-YOUR_OPENROUTER_KEY"
```

### Send a chat request:
```bash
curl -X POST https://api.tomu.sh/litellm/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-or-v1-YOUR_OPENROUTER_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello! Please respond with just your name."}],
    "max_tokens": 50
  }'
```

### Test with Claude:
```bash
curl -X POST https://api.tomu.sh/litellm/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-or-v1-YOUR_OPENROUTER_KEY" \
  -d '{
    "model": "claude-3-haiku",
    "messages": [{"role": "user", "content": "What is 2+2?"}],
    "max_tokens": 50
  }'
```

### Test with Llama:
```bash
curl -X POST https://api.tomu.sh/litellm/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-or-v1-YOUR_OPENROUTER_KEY" \
  -d '{
    "model": "llama-3.1-8b",
    "messages": [{"role": "user", "content": "Write a haiku about coding"}],
    "max_tokens": 100
  }'
```

## Available Models
- `gpt-3.5-turbo` - OpenAI GPT-3.5 Turbo
- `gpt-4` - OpenAI GPT-4  
- `claude-3-haiku` - Anthropic Claude 3 Haiku
- `llama-3.1-8b` - Meta Llama 3.1 8B

## Management Commands

```bash
make deploy        # Full deployment
make update-docker # Update services
make update-nginx  # Update nginx config
make status        # Check server status
make test-ssh      # Test SSH connection
```

## CORS Enabled

You can call the API from localhost/browser:
```javascript
fetch('https://api.tomu.sh/litellm/v1/models', {
  headers: {
    'Authorization': 'Bearer sk-or-v1-YOUR_OPENROUTER_KEY'
  }
})
```

## Prerequisites

- Ubuntu server with SSH access
- Domain `api.tomu.sh` pointing to your server IP
- OpenRouter API key
- Ports 80/443 open

## Troubleshooting

- **Health check fails**: `make status`
- **Nginx issues**: `make update-nginx`
- **Service issues**: `make update-docker`