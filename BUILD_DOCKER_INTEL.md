# Building Docker Image for Intel/x86_64 Architecture

## Prerequisites

1. Docker installed on Intel server
2. All dependencies (PostgreSQL, RabbitMQ, Redis) running

## Step 1: On Intel Server - Prepare

```bash
# SSH into Intel server
ssh administrator@144.76.8.27

# Navigate to project
cd ~/OnlyOffice

# Ensure connection limit is set to 1000
grep "LICENSE_CONNECTIONS" Common/sources/constants.js
# Should show: exports.LICENSE_CONNECTIONS = 1000;
```

## Step 2: Copy Docker Files

Copy these files to Intel server:
- `Dockerfile.amd64`
- `docker-entrypoint.sh` (same as ARM)
- `docker-compose.amd64.yml`
- `Common/config/docker.json`
- `build-docker-intel.sh`

Or create them directly on the server.

## Step 3: Create Files on Intel Server

### Create Dockerfile.amd64

```bash
cat > Dockerfile.amd64 << 'EOF'
# Dockerfile for ONLYOFFICE Document Server - Intel/x86_64
FROM node:18-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY npm-shrinkwrap.json ./
COPY Common/package*.json ./Common/
COPY Common/npm-shrinkwrap.json ./Common/
COPY DocService/package*.json ./DocService/
COPY DocService/npm-shrinkwrap.json ./DocService/
COPY FileConverter/package*.json ./FileConverter/
COPY FileConverter/npm-shrinkwrap.json ./FileConverter/

# Install dependencies
RUN npm ci
RUN npm run install:Common && \
    npm run install:DocService && \
    npm run install:FileConverter

# Copy application code
COPY . .

# Create directories
RUN mkdir -p logs App_Data/data

# Environment variables
ENV NODE_ENV=development-linux
ENV NODE_CONFIG_DIR=/app/Common/config

# Copy docker config
COPY Common/config/docker.json /app/Common/config/docker.json
RUN mkdir -p /app/Common/config/log4js
COPY Common/config/log4js/ /app/Common/config/log4js/

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/healthcheck || exit 1

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
EOF
```

### Create docker-compose.amd64.yml

```bash
cat > docker-compose.amd64.yml << 'EOF'
version: '3.8'

services:
  documentserver:
    build:
      context: .
      dockerfile: Dockerfile.amd64
    container_name: onlyoffice-documentserver-intel
    network_mode: host
    environment:
      NODE_ENV: development-linux
      NODE_CONFIG_DIR: /app/Common/config
      DB_HOST: localhost
      DB_PORT: 5432
      DB_NAME: onlyoffice
      DB_USER: onlyoffice
      DB_PASS: onlyoffice
      RABBITMQ_HOST: localhost
      RABBITMQ_PORT: 5672
      REDIS_HOST: localhost
      REDIS_PORT: 6379
    volumes:
      - ./App_Data:/app/App_Data
      - ./logs:/app/logs
    restart: unless-stopped
EOF
```

## Step 4: Build the Image

```bash
# Make scripts executable
chmod +x docker-entrypoint.sh

# Build the image
docker build -f Dockerfile.amd64 -t onlyoffice-documentserver:intel-latest .

# Or use docker-compose
docker-compose -f docker-compose.amd64.yml build
```

## Step 5: Test the Image

```bash
# Stop current running server (if needed)
pkill -f "node sources" || true

# Start with docker-compose
docker-compose -f docker-compose.amd64.yml up -d

# Check logs
docker-compose -f docker-compose.amd64.yml logs -f documentserver

# Test
curl http://localhost:8000/healthcheck
```

## Step 6: Verify Connection Limit

```bash
curl -s http://localhost:8000/info/info.json | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f\"Connections: {data['licenseInfo'].get('connections', 'N/A')}\")
"
# Should show: Connections: 1000
```

## Step 7: Push to Docker Hub

```bash
# Login
docker login

# Tag the image
docker tag onlyoffice-documentserver:intel-latest yajbirmalik/onlyoffice-documentserver:intel-latest

# Push
docker push yajbirmalik/onlyoffice-documentserver:intel-latest
```

## Summary

After pushing both images, your client can use:
- ARM64: `docker pull yajbirmalik/onlyoffice-documentserver:arm64-latest`
- Intel: `docker pull yajbirmalik/onlyoffice-documentserver:intel-latest`

