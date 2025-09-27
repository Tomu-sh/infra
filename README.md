# LightLLM Infrastructure Demo

This project demonstrates a complete infrastructure setup for deploying LightLLM using Docker, Ansible, and containerized VMs.
## Run only LiteLLM
in the implementation folder, run docker compose up

## Quick Start

1. **Setup environment (OpenRouter API key):**
   ```bash
   make setup-env
   ```

2. **Verify SSH key configuration:**
   ```bash
   make verify-ssh
   ```

3. **Run the complete demo:**
   ```bash
   make demo
   # or manually:
   docker compose -f docker-compose.global.yml up --build
   ```

4. **Test the LightLLM service:**
   ```bash
   # Test OpenRouter integration
   ./test-setup.sh
   
   # Or manually test - check available models
   curl http://localhost:8080/v1/models
   
   # Test chat completion
   curl -X POST http://localhost:8080/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d '{
       "model": "gpt-3.5-turbo",
       "messages": [{"role": "user", "content": "Hello! Please respond with just your name."}],
       "max_tokens": 50
     }'
   
   # Expected response:
   # {
   #   "id": "chatcmpl-...",
   #   "object": "chat.completion",
   #   "choices": [{
   #     "message": {"role": "assistant", "content": "Hello! I am ChatGPT."}
   #   }]
   # }
   ```

## What Happens

1. **Environment Setup**: Configure OpenRouter API key and LLMLite settings
2. **SSH Key Verification**: Ensures SSH keys are properly configured and have correct permissions
3. **VM Creation**: A containerized Ubuntu VM is created with Docker-in-Docker support
4. **SSH Key Setup**: The public key is embedded in the VM during build for passwordless access
5. **Port Forwarding**: LightLLM port 8080 is forwarded to your host machine
6. **Ansible Deployment**: Once the VM is healthy, Ansible connects via SSH and deploys LightLLM with OpenRouter config
7. **Service Ready**: LightLLM becomes accessible at `http://localhost:8080` with OpenRouter models

## SSH Key Configuration

The setup uses SSH key-based authentication:

- **Private Key (`ssh_key`)**: Used by Ansible to connect to the VM
- **Public Key (`ssh_key.pub`)**: Embedded in the VM's `authorized_keys` during build
- **Connection**: Ansible connects as `ansible@lightllm-vm:22` using the private key
- **Security**: No passwords required, keys have proper permissions (600/644)

## OpenRouter Configuration

LLMLite is configured to use OpenRouter as the LLM provider:

- **API Key**: Loaded from `.env` file (`OPENROUTER_API_KEY`)
- **Base URL**: `https://openrouter.ai/api/v1`
- **Available Models**: 
  - `gpt-3.5-turbo` (OpenAI)
  - `gpt-4` (OpenAI)
  - `claude-3-haiku` (Anthropic)
  - `llama-3.1-8b` (Meta)
- **Configuration**: `implementation/llmlite-config.yaml`
- **Environment**: `implementation/.env` (created from `env.example`)

## Using the Implementation

The `implementation/` folder contains reusable Ansible code that can be used to deploy LightLLM to any target hosts:

1. Update the `[target_hosts]` section in `implementation/inventory` with your servers
2. Run: `make deploy` or `cd implementation && ansible-playbook -i inventory playbook.yml --limit target_hosts`

### Inventory Groups

- **`vm`**: Pre-configured for the demo VM (lightllm-vm container)
- **`target_hosts`**: Add your real servers here for production deployments

## Architecture

- **VM Container**: Simulates a remote server with SSH access
- **Ansible**: Handles service deployment and configuration
- **Docker-in-Docker**: Allows running LightLLM containers inside the VM
- **Port Forwarding**: Makes services accessible from the host machine

## Cleanup

```bash
docker compose -f docker-compose.global.yml down -v
docker system prune -f
```
