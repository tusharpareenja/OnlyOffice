#!/bin/bash
# Build script for ARM64 Docker image

set -e

echo "=========================================="
echo "Building ONLYOFFICE Document Server"
echo "Architecture: ARM64"
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
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    echo "Warning: Not building on ARM64. Use buildx for cross-platform builds."
fi

# Build the image
echo ""
echo "Building Docker image..."
docker build \
    -f Dockerfile.arm64 \
    -t onlyoffice-documentserver:arm64-latest \
    -t onlyoffice-documentserver:arm64-$(date +%Y%m%d) \
    .

echo ""
echo "=========================================="
echo "Build Complete!"
echo "=========================================="
echo ""
echo "Image tags:"
docker images | grep onlyoffice-documentserver | grep arm64
echo ""
echo "To run the container:"
echo "  docker-compose -f docker-compose.arm64.yml up -d"
echo ""
echo "Or manually:"
echo "  docker run -d -p 8000:8000 --name documentserver-arm onlyoffice-documentserver:arm64-latest"
echo ""
echo "To save the image:"
echo "  docker save onlyoffice-documentserver:arm64-latest | gzip > onlyoffice-documentserver-arm64.tar.gz"
echo ""

