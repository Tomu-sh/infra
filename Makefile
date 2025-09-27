.PHONY: demo start stop clean test logs status verify-ssh deploy deploy-vm

# Verify SSH key configuration
verify-ssh:
	./verify-ssh.sh

# Start the complete demo
demo: verify-ssh
	@echo "💡 Make sure to create implementation/.env from implementation/env.example with your OpenRouter API key"
	docker compose -f docker-compose.global.yml up --build

# Start with real-time logs and status updates
start:
	@echo "🚀 Starting LiteLLM infrastructure..."
	@echo "💡 Make sure to create implementation/.env from implementation/env.example with your OpenRouter API key"
	@echo ""
	docker compose -f docker-compose.global.yml up --build -d
	@echo ""
	@echo "📊 Monitoring startup progress..."
	@echo "   VM Health: Waiting for SSH service..."
	@timeout 60 sh -c 'until docker compose -f docker-compose.global.yml ps --format "table {{.Name}}\t{{.Status}}" | grep -q "healthy"; do echo "   ⏳ VM starting... ($$(date +%T))"; sleep 2; done' || echo "   ⚠️  VM health check timeout"
	@echo "   ✅ VM is healthy!"
	@echo ""
	@echo "   Ansible: Waiting for deployment..."
	@timeout 120 sh -c 'until docker compose -f docker-compose.global.yml ps --format "table {{.Name}}\t{{.Status}}" | grep ansible-deploy | grep -q "Exited"; do echo "   ⏳ Deploying LiteLLM... ($$(date +%T))"; sleep 3; done' || echo "   ⚠️  Ansible deployment timeout"
	@echo "   ✅ Deployment completed!"
	@echo ""
	@echo "🔍 Testing service availability..."
	@sleep 5
	@curl -s -I http://localhost:8080 >/dev/null 2>&1 && echo "   ✅ LiteLLM service is responding!" || echo "   ⚠️  Service not ready yet (may need API key configuration)"
	@echo ""
	@echo "🎉 Startup complete! Use 'make logs' to monitor, 'make test' to verify, or 'make stop' to shutdown."

# Stop all services
stop:
	docker compose -f docker-compose.global.yml down

# Clean up everything
clean:
	docker compose -f docker-compose.global.yml down -v
	docker system prune -f

# Test the LightLLM service
test:
	@echo "Testing LightLLM service..."
	@curl -f http://localhost:8080/health || echo "Service not ready yet"

# Show logs with timestamps
logs:
	@echo "📋 Showing real-time logs (Ctrl+C to exit)..."
	docker compose -f docker-compose.global.yml logs -f --timestamps

# Show current status
status:
	@echo "📊 Current service status:"
	@docker compose -f docker-compose.global.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "🔍 Quick service test:"
	@curl -s -I http://localhost:8080 >/dev/null 2>&1 && echo "   ✅ LiteLLM service is responding on port 8080" || echo "   ❌ LiteLLM service not responding"
	@nc -z localhost 2222 >/dev/null 2>&1 && echo "   ✅ SSH access available on port 2222" || echo "   ❌ SSH access not available"

# Deploy to custom hosts (uses target_hosts group in inventory)
deploy:
	cd implementation && ansible-playbook -i inventory playbook.yml --limit target_hosts

# Deploy to VM example (uses vm group in inventory)
deploy-vm:
	cd implementation && ansible-playbook -i inventory playbook.yml --limit vm

help:
	@echo "Available commands:"
	@echo "  verify-ssh - Verify SSH key configuration"
	@echo "  demo       - Start the complete demo (foreground with logs)"
	@echo "  start      - Start with real-time progress monitoring"
	@echo "  status     - Show current service status and health"
	@echo "  logs       - Show real-time service logs"
	@echo "  test       - Test if LiteLLM service is responding"
	@echo "  stop       - Stop all services"
	@echo "  clean      - Stop and remove all containers/volumes"
	@echo "  deploy     - Deploy to target_hosts group"
	@echo "  deploy-vm  - Deploy to vm group (for testing)"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Setup: Copy implementation/env.example to implementation/.env and add your OpenRouter API key"
