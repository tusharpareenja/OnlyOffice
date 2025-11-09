#!/bin/bash
# Install Docker on Ubuntu/Debian

set -e

echo "=========================================="
echo "Installing Docker"
echo "=========================================="

# Remove old versions
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group (optional)
sudo usermod -aG docker $USER || true

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
echo ""
echo "=========================================="
echo "Docker Installation Complete"
echo "=========================================="
echo ""
docker --version
docker compose version
echo ""
echo "Note: You may need to log out and back in for group changes to take effect"
echo "Or run: newgrp docker"


