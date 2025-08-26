#!/bin/bash

echo "n8n Deployment Script"
echo "===================="

# Check if .env exists
if [ ! -f .env ]; then
    echo "No .env file found. Generating secure credentials..."
    echo ""
    
    # Generate secure random keys
    N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)
    N8N_JWT_SECRET=$(openssl rand -hex 32)
    POSTGRES_PASSWORD=$(openssl rand -base64 24)
    N8N_ADMIN_PASSWORD=$(openssl rand -base64 16)
    
    # Generate Traefik admin password
    TRAEFIK_ADMIN_PASSWORD=$(openssl rand -base64 16)
    # Note: We'll use plain password in env and hash it inline since htpasswd might not be available
    TRAEFIK_USER_PASS="admin:$(echo "$TRAEFIK_ADMIN_PASSWORD" | openssl passwd -apr1 -stdin | sed -e 's/\$/\$\$/g')"
    
    # Create .env file
    cat > .env << EOF
# Timezone
GENERIC_TIMEZONE=Europe/Rome

# PostgreSQL Database
POSTGRES_USER=n8n
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=n8n

# n8n Security Keys
N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
N8N_USER_MANAGEMENT_JWT_SECRET=${N8N_JWT_SECRET}

# n8n Basic Auth (Optional - disable after setting up user management)
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=${N8N_ADMIN_PASSWORD}

# Traefik Dashboard Basic Auth
TRAEFIK_USER_PASS=${TRAEFIK_USER_PASS}

# Email for Let's Encrypt certificate notifications
ACME_EMAIL=admin@intelligencebox.it
EOF
    
    echo "✅ .env file created with secure credentials!"
    echo ""
    echo "==================== SAVE THESE CREDENTIALS ===================="
    echo ""
    echo "📊 PostgreSQL Database:"
    echo "   User: n8n"
    echo "   Password: ${POSTGRES_PASSWORD}"
    echo ""
    echo "🔐 n8n Admin Access:"
    echo "   URL: https://n8n.intelligencebox.it"
    echo "   Username: admin"
    echo "   Password: ${N8N_ADMIN_PASSWORD}"
    echo ""
    echo "🚦 Traefik Dashboard:"
    echo "   URL: https://traefik.intelligencebox.it"
    echo "   Username: admin"
    echo "   Password: ${TRAEFIK_ADMIN_PASSWORD}"
    echo ""
    echo "🔑 Encryption Keys (for backup/recovery):"
    echo "   N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY}"
    echo "   N8N_JWT_SECRET: ${N8N_JWT_SECRET}"
    echo ""
    echo "================================================================="
    echo ""
    echo "⚠️  IMPORTANT: Save these credentials NOW! They won't be shown again!"
    echo ""
    echo "Press ENTER to continue with deployment..."
    read
else
    echo "Using existing .env file"
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
docker compose pull

# Start services
echo "Starting services..."
docker compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 10

# Check service status
echo ""
echo "Service Status:"
docker compose ps

echo ""
echo "Deployment complete!"
echo ""
echo "Access your services at:"
echo "  - n8n: https://n8n.intelligencebox.it"
echo "  - Traefik Dashboard: https://traefik.intelligencebox.it"
echo ""
echo "View logs with:"
echo "  docker compose logs -f n8n"
echo "  docker compose logs -f traefik"