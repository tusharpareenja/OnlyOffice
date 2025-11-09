#!/bin/bash
# Script to push Docker image to Docker Hub

set -e

echo "=========================================="
echo "Pushing to Docker Hub"
echo "=========================================="
echo ""

# Get image name and tag from user or use defaults
IMAGE_NAME=${1:-"onlyoffice-documentserver"}
TAG=${2:-"arm64-latest"}
DOCKER_USERNAME=${3:-""}

if [ -z "$DOCKER_USERNAME" ]; then
    echo "Usage: ./push-to-dockerhub.sh [image-name] [tag] [docker-username]"
    echo "Example: ./push-to-dockerhub.sh onlyoffice-documentserver arm64-v1.0 yourusername"
    echo ""
    read -p "Enter your Docker Hub username: " DOCKER_USERNAME
fi

FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}"

echo "Image will be tagged as: ${FULL_IMAGE_NAME}"
echo ""

# Tag the image
echo "Tagging image..."
docker tag onlyoffice_documentserver:latest ${FULL_IMAGE_NAME}

# Login to Docker Hub
echo "Logging in to Docker Hub..."
docker login

# Push the image
echo "Pushing image to Docker Hub..."
docker push ${FULL_IMAGE_NAME}

echo ""
echo "=========================================="
echo "Image pushed successfully!"
echo "=========================================="
echo ""
echo "Image URL: https://hub.docker.com/r/${DOCKER_USERNAME}/${IMAGE_NAME}"
echo ""
echo "Client can pull with:"
echo "  docker pull ${FULL_IMAGE_NAME}"
echo ""

