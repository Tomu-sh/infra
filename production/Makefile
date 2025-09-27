.PHONY: deploy update-docker update-nginx logs status clean test-ssh help

# Deploy to production server using Docker Compose + Ansible
deploy:
	@if [ ! -f .env ]; then echo "❌ Please create .env file first (copy from env.example)"; exit 1; fi
	docker compose -f docker-compose.global.yml up --build

# Update Docker services on production server
update-docker:
	@if [ ! -f .env ]; then echo "❌ Please create .env file first (copy from env.example)"; exit 1; fi
	@echo "🔄 Updating Docker services on production server..."
	@echo "⏰ Started at: $$(date)"
	ssh -o IdentityAgent=none -o IdentitiesOnly=yes -i  "\
		cd /opt/litellm-production && \
		echo '🛑 Stopping existing services...' && \
		sudo docker compose down || true && \
		echo '🧹 Cleaning up old containers and images...' && \
		sudo docker system prune -f && \
		sudo docker image prune -a -f && \
		echo '📥 Pulling latest images...' && \
		sudo docker compose pull && \
		echo '🚀 Starting updated services...' && \
		sudo docker compose up -d && \
		echo '📊 Checking service status...' && \
		sudo docker compose ps && \
		echo '✅ Update complete!'"
	@echo "🎉 Docker services updated successfully!"
	@echo "📋 Check status with: make status"

# Update nginx configuration only
update-nginx:
	@echo "🔄 Updating nginx configuration..."
	@echo "📁 Copying nginx config to server..."
	scp -o IdentityAgent=none -o IdentitiesOnly=yes -i nginx/conf.d/api.tomu.sh.conf :/tmp/api.tomu.sh.conf
	ssh -o IdentityAgent=none -o IdentitiesOnly=yes -i  "\
		cd /opt/litellm-production && \
		echo '📝 Installing new nginx config...' && \
		sudo cp /tmp/api.tomu.sh.conf nginx/conf.d/api.tomu.sh.conf && \
		echo '🔄 Restarting nginx container...' && \
		sudo docker compose restart nginx && \
		echo '📊 Checking nginx status...' && \
		sudo docker compose logs nginx --tail 10"
	@echo "✅ Nginx configuration updated!"

# View deployment logs
logs:
	docker compose -f docker-compose.global.yml logs -f

# Check production server status
status:
	@echo "📊 Production Server Status:"
	ssh -o IdentityAgent=none -o IdentitiesOnly=yes -i ~/.ssh/id_ed25519 ubuntu@81.15.150.170 "\
		cd /opt/litellm-production && \
		echo '🐳 Docker Services:' && \
		sudo docker compose ps && \
		echo '' && \
		echo '📋 Recent Logs:' && \
		sudo docker compose logs --tail 20"

# Clean up deployment containers (local)
clean:
	docker compose -f docker-compose.global.yml down
	docker system prune -f

# Test SSH connection
test-ssh:
	@echo "Testing SSH connection to production server..."
	ssh -o IdentityAgent=none -o IdentitiesOnly=yes -o ConnectTimeout=30 -i ~/.ssh/id_ed25519 ubuntu@81.15.150.170 "echo 'SSH connection successful'"

help:
	@echo "Commands:"
	@echo "  deploy        - Deploy to production server (full deployment)"
	@echo "  update-docker - Update Docker services on production server"
	@echo "  update-nginx  - Update nginx configuration only"
	@echo "  logs          - View deployment logs"
	@echo "  status        - Check production server status"
	@echo "  clean         - Clean up local deployment containers"
	@echo "  test-ssh      - Test SSH connection to server"
	@echo "  help          - Show this help"