# n8n with Traefik and HTTPS

This setup provides n8n workflow automation with Traefik reverse proxy and automatic HTTPS certificates via Let's Encrypt.

## Prerequisites

- Docker and Docker Compose installed
- Domain pointed to your server (n8n.intelligencebox.it)
- Cloudflare account with API access (for DNS challenge)

## Setup Instructions

### 1. Configure Environment Variables

Copy `.env.example` to `.env` and update:

```bash
cp .env.example .env
```

Edit `.env` and set:
- Strong passwords for PostgreSQL and n8n
- Generate encryption keys:
  ```bash
  openssl rand -hex 32  # For N8N_ENCRYPTION_KEY
  openssl rand -hex 32  # For N8N_USER_MANAGEMENT_JWT_SECRET
  ```
- Cloudflare API credentials for Let's Encrypt DNS challenge
- Generate Traefik dashboard password:
  ```bash
  htpasswd -nB admin | sed -e s/\\$/\\$\\$/g
  ```

### 2. Prepare Directories

```bash
mkdir -p traefik-data local-files
touch traefik-data/acme.json
chmod 600 traefik-data/acme.json
```

### 3. Start Services

```bash
docker-compose up -d
```

### 4. Access Services

- n8n: https://n8n.intelligencebox.it
- Traefik Dashboard: https://traefik.intelligencebox.it (if configured)

## Services Included

- **n8n**: Workflow automation platform
- **Traefik**: Reverse proxy with automatic HTTPS
- **PostgreSQL**: Database for n8n
- **Redis**: Queue management for n8n

## Security Notes

1. **Change all default passwords** in `.env`
2. **Generate new encryption keys** for production
3. **Secure your Cloudflare API key**
4. **Enable n8n built-in user management** after first login
5. **Configure firewall** to only allow ports 80 and 443

## Backup

Important directories to backup:
- `n8n-data/`: n8n workflows and credentials
- `postgres-data/`: Database
- `.env`: Environment configuration

## Maintenance

### Update n8n
```bash
docker-compose pull n8n
docker-compose up -d n8n
```

### View Logs
```bash
docker-compose logs -f n8n
docker-compose logs -f traefik
```

### Stop Services
```bash
docker-compose down
```

### Complete Reset (Warning: Data Loss!)
```bash
docker-compose down -v
```

## Troubleshooting

### Certificate Issues
- Check Cloudflare API credentials in `.env`
- Verify DNS records point to your server
- Check Traefik logs: `docker-compose logs traefik`

### n8n Connection Issues
- Ensure PostgreSQL is healthy: `docker-compose ps`
- Check n8n logs: `docker-compose logs n8n`
- Verify environment variables in `.env`

### Performance Tuning
- Adjust PostgreSQL settings if needed
- Configure Redis persistence
- Monitor with `docker stats`