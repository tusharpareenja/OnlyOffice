#!/bin/bash
# Build script for Intel/x86_64 Docker image

set -e

echo "=========================================="
echo "Building ONLYOFFICE Document Server"
echo "Architecture: Intel/x86_64 (AMD64)"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

# Check architecture
ARCH=$(uname -m)
echo "Current architecture: $ARCH"
if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "amd64" ]; then
    echo "Warning: Not building on x86_64. Use buildx for cross-platform builds."
fi

# Build the image
echo ""
echo "Building Docker image..."
docker build \
    -f Dockerfile.amd64 \
    -t onlyoffice-documentserver:intel-latest \
    -t onlyoffice-documentserver:amd64-latest \
    -t onlyoffice-documentserver:intel-$(date +%Y%m%d) \
    .

echo ""
echo "=========================================="
echo "Build Complete!"
echo "=========================================="
echo ""
echo "Image tags:"
docker images | grep onlyoffice-documentserver | grep -E "intel|amd64"
echo ""
echo "To run the container:"
echo "  docker-compose -f docker-compose.amd64.yml up -d"
echo ""
echo "Or manually:"
echo "  docker run -d -p 8000:8000 --name documentserver-intel onlyoffice-documentserver:intel-latest"
echo ""
echo "To push to Docker Hub:"
echo "  docker tag onlyoffice-documentserver:intel-latest yajbirmalik/onlyoffice-documentserver:intel-latest"
echo "  docker push yajbirmalik/onlyoffice-documentserver:intel-latest"
echo ""

