#!/bin/bash

echo "n8n Deployment Script"
echo "===================="

# Check if .env exists
if [ ! -f .env ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo "⚠️  Please update .env with your credentials before continuing!"
    echo "   Especially:"
    echo "   - Database passwords"
    echo "   - Encryption keys (use: openssl rand -hex 32)"
    echo "   - Admin email for Let's Encrypt"
    exit 1
fi

# Create necessary directories
echo "Creating directories..."
mkdir -p traefik-data local-files

# Create and set permissions for acme.json
echo "Setting up Let's Encrypt certificate storage..."
touch traefik-data/acme.json
chmod 600 traefik-data/acme.json

# Pull latest images
echo "Pulling Docker images..."
docker-compose pull

# Start services
echo "Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 10

# Check service status
echo ""
echo "Service Status:"
docker-compose ps

echo ""
echo "Deployment complete!"
echo ""
echo "Access your services at:"
echo "  - n8n: https://n8n.intelligencebox.it"
echo "  - Traefik Dashboard: https://traefik.intelligencebox.it (if configured)"
echo ""
echo "View logs with:"
echo "  docker-compose logs -f n8n"
echo "  docker-compose logs -f traefik"