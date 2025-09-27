#!/bin/bash

DOMAIN="api.tomu.sh"
EMAIL="admin@tomu.sh"

echo "🔒 Setting up SSL certificates for $DOMAIN..."

# Create required directories
mkdir -p nginx/ssl
mkdir -p certbot/www

# Start temporary nginx for ACME challenge
docker run -d --name nginx-temp -p 80:80 -v $(pwd)/certbot/www:/var/www/certbot nginx:alpine sh -c "
echo 'server { 
    listen 80; 
    server_name $DOMAIN; 
    location /.well-known/acme-challenge/ { 
        root /var/www/certbot; 
    } 
    location / { 
        return 200 \"ACME challenge server\"; 
    } 
}' > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"

sleep 2

# Get SSL certificate
docker run --rm -v $(pwd)/nginx/ssl:/etc/letsencrypt -v $(pwd)/certbot/www:/var/www/certbot certbot/certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d $DOMAIN

# Stop temporary nginx
docker stop nginx-temp
docker rm nginx-temp

echo "✅ SSL certificate obtained!"
echo "🚀 Starting production services..."

# Start all services
docker compose up -d

echo "🎉 Setup complete! Your API should be available at:"
echo "   https://$DOMAIN/litellm/v1/models"
echo "   https://$DOMAIN/health"

