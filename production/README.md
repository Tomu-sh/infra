# Production LiteLLM with Nginx & SSL

Simple production setup for LiteLLM API with:
- Nginx reverse proxy with `/litellm` path prefix
- SSL/TLS using Let's Encrypt
- CORS enabled for localhost debugging
- Docker Compose + Ansible deployment automation

## Quick Deployment with Docker + Ansible

No need to install Ansible locally - everything runs in containers!

### 1. Configure your server
Edit the `inventory` file:
```ini
[production]
api-server ansible_host=YOUR_SERVER_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key.pem
```

### 2. Set up your environment
```bash
# Copy environment template
cp env.example .env

# Edit .env and add your OpenRouter API key
vim .env
# Set: OPENROUTER_API_KEY=sk-or-v1-your-actual-key-here
```

### 3. Deploy to your server
```bash
make deploy
```

That's it! The Docker container will run Ansible and:
- Install Docker and required packages on your server
- Copy all configuration files
- Get SSL certificates from Let's Encrypt
- Start all services
- Test the deployment

## Alternative: Run deployment in background
```bash
make deploy-detached  # Run in background
make deploy-logs      # View deployment logs
make deploy-stop      # Stop deployment container
```

## Manual Setup (Alternative)

If you prefer to set up manually on the server:

```bash
# Copy files to your server
scp -r production/* user@your-server:/opt/litellm-production/

# SSH to your server and run
ssh user@your-server
cd /opt/litellm-production
make setup
```

## API Usage

Your API will be available at `https://api.tomu.sh/litellm/`

### Example requests:

**Chat completion:**
```bash
curl -X POST https://api.tomu.sh/litellm/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-or-v1-your-api-key" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 50
  }'
```

**List models:**
```bash
curl https://api.tomu.sh/litellm/v1/models \
  -H "Authorization: Bearer sk-or-v1-your-api-key"
```

**Health check:**
```bash
curl https://api.tomu.sh/health
```

## Management Commands

```bash
make deploy           # Deploy to production server

```

## CORS Support

CORS is enabled for all origins (`*`), so you can test from localhost:

```javascript
// From your frontend running on localhost
fetch('https://api.tomu.sh/litellm/v1/models', {
  headers: {
    'Authorization': 'Bearer sk-or-v1-your-api-key'
  }
})
```

## File Structure

```
production/
├── docker-compose.global.yml         # Docker + Ansible deployment
├── deploy.yml                        # Ansible playbook
├── inventory                         # Server configuration
├── ansible.cfg                       # Ansible settings
├── docker-compose.yml                # Main services
├── nginx/conf.d/api.tomu.sh.conf     # Nginx config
├── setup-ssl.sh                      # SSL setup script
├── Makefile                          # Management commands
├── .env                              # Your API keys
├── litellm-config.yaml               # LiteLLM configuration
└── README.md                         # This file
```

## Prerequisites

- Docker and Docker Compose installed on your local machine
- A server with Ubuntu 20.04+ and SSH access
- Domain name (api.tomu.sh) pointing to your server
- Ports 80 and 443 open on your server
- SSH key access to your server

## Troubleshooting

**Deployment fails:**
- Check your inventory file has correct server details
- Ensure SSH key works: `ssh -i ~/.ssh/your-key.pem user@server`
- Make sure domain points to your server
- View deployment logs: `make deploy-logs`

**SSL certificate issues:**
- Verify api.tomu.sh resolves to your server IP
- Ensure ports 80 and 443 are open
- Check DNS propagation: `dig api.tomu.sh`

**API not responding:**
- Check logs: `make logs`
- Check containers: `docker ps`
- Test health: `curl https://api.tomu.sh/health`

## Useful Commands
```bash
# SSH to your server
ssh -i ~/.ssh/id_ed25519 ubuntu@81.15.150.170

# Check deployment status
make deploy-logs

# Test API once deployed
curl https://api.tomu.sh/health
```