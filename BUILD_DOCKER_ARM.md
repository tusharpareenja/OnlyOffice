# Building Docker Image for ARM64 Architecture

## Prerequisites

1. Docker installed on ARM server
2. Docker Buildx (for multi-platform builds)

## Step 1: Install Docker Buildx (if not installed)

```bash
# Check if buildx is available
docker buildx version

# If not installed, it's usually included with Docker 19.03+
# Create a new builder instance
docker buildx create --name multiarch --use
docker buildx inspect --bootstrap
```

## Step 2: Build ARM64 Image

### Option A: Build on ARM server directly (Recommended)

```bash
# On your ARM server
cd ~/OnlyOffice

# Build the image
docker build -f Dockerfile.arm64 -t onlyoffice-documentserver:arm64-latest .

# Tag it
docker tag onlyoffice-documentserver:arm64-latest onlyoffice-documentserver:arm64-v1.0
```

### Option B: Build using buildx (for cross-platform)

```bash
# Build for ARM64
docker buildx build \
  --platform linux/arm64 \
  -f Dockerfile.arm64 \
  -t onlyoffice-documentserver:arm64-latest \
  --load \
  .
```

## Step 3: Verify the Image

```bash
# Check image details
docker image inspect onlyoffice-documentserver:arm64-latest | grep Architecture

# List images
docker images | grep onlyoffice
```

## Step 4: Test the Image

### Using Docker Compose (Recommended)

```bash
# Start all services
docker-compose -f docker-compose.arm64.yml up -d

# Check logs
docker-compose -f docker-compose.arm64.yml logs -f documentserver

# Test health check
curl http://localhost:8000/healthcheck
```

### Using Docker Run (Manual)

```bash
# First, start dependencies
docker run -d --name postgres-arm \
  -e POSTGRES_USER=onlyoffice \
  -e POSTGRES_PASSWORD=onlyoffice \
  -e POSTGRES_DB=onlyoffice \
  postgres:15

docker run -d --name rabbitmq-arm \
  -p 5672:5672 -p 15672:15672 \
  rabbitmq:3-management

docker run -d --name redis-arm \
  -p 6379:6379 \
  redis:7-alpine

# Wait for services to be ready
sleep 10

# Run the Document Server
docker run -d --name documentserver-arm \
  --link postgres-arm:postgres \
  --link rabbitmq-arm:rabbitmq \
  --link redis-arm:redis \
  -p 8000:8000 \
  -e DB_HOST=postgres \
  -e RABBITMQ_HOST=rabbitmq \
  -e REDIS_HOST=redis \
  onlyoffice-documentserver:arm64-latest

# Check logs
docker logs -f documentserver-arm

# Test
curl http://localhost:8000/healthcheck
```

## Step 5: Save the Image

```bash
# Save image to file
docker save onlyoffice-documentserver:arm64-latest | gzip > onlyoffice-documentserver-arm64.tar.gz

# Or push to registry
docker tag onlyoffice-documentserver:arm64-latest your-registry/onlyoffice-documentserver:arm64-latest
docker push your-registry/onlyoffice-documentserver:arm64-latest
```

## Step 6: Load Image on Another Machine

```bash
# Load from file
docker load < onlyoffice-documentserver-arm64.tar.gz

# Or pull from registry
docker pull your-registry/onlyoffice-documentserver:arm64-latest
```

## Troubleshooting

### Build fails with architecture errors
```bash
# Make sure you're building on ARM or using buildx
docker buildx ls
docker buildx use multiarch
```

### Native modules fail to compile
```bash
# Rebuild native modules
docker exec -it documentserver-arm bash
cd /app/DocService
npm rebuild
```

### Connection issues
```bash
# Check if services are linked properly
docker network ls
docker network inspect bridge
```

## Notes

- The image includes the connection limit change (1000 connections)
- Make sure PostgreSQL, RabbitMQ, and Redis are accessible
- The image uses `production-linux` configuration
- Health check endpoint: `/healthcheck`

