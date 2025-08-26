#!/bin/bash

echo "Generating secure .env file for n8n deployment..."
echo "================================================="

# Generate secure random keys
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)
N8N_JWT_SECRET=$(openssl rand -hex 32)
POSTGRES_PASSWORD=$(openssl rand -base64 24)
N8N_ADMIN_PASSWORD=$(openssl rand -base64 16)

# Generate Traefik admin password hash (username: admin)
TRAEFIK_ADMIN_PASSWORD=$(openssl rand -base64 16)
TRAEFIK_USER_PASS="admin:$(htpasswd -nbB admin "$TRAEFIK_ADMIN_PASSWORD" | sed -e 's/\$/\$\$/g' | cut -d: -f2)"

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

echo "✅ .env file created successfully!"
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
echo "   URL: https://traefik.intelligencebox.it (if configured)"
echo "   Username: admin"
echo "   Password: ${TRAEFIK_ADMIN_PASSWORD}"
echo ""
echo "🔑 Encryption Keys (for backup/recovery):"
echo "   N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY}"
echo "   N8N_JWT_SECRET: ${N8N_JWT_SECRET}"
echo ""
echo "================================================================="
echo ""
echo "⚠️  IMPORTANT: Save these credentials in a secure password manager!"
echo "They won't be shown again!"
echo ""
echo "Next step: Run ./deploy.sh to start the services"