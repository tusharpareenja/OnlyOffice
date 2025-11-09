#!/bin/bash
# Setup script for ONLYOFFICE Document Server on Intel/x86_64

set -e

echo "=========================================="
echo "ONLYOFFICE Document Server Setup (Intel)"
echo "=========================================="
echo ""

# Check architecture
echo "1. Checking system architecture:"
uname -m
echo ""

# Check what's in OnlyOffice directory
echo "2. Checking OnlyOffice directory:"
cd ~/OnlyOffice
ls -la
echo ""

# Check if Node.js is installed
echo "3. Checking Node.js:"
node --version 2>/dev/null || echo "Node.js not installed"
npm --version 2>/dev/null || echo "npm not installed"
echo ""

# Check required services
echo "4. Checking required services:"
systemctl is-active postgresql 2>/dev/null && echo "✓ PostgreSQL running" || echo "✗ PostgreSQL not running"
systemctl is-active rabbitmq-server 2>/dev/null && echo "✓ RabbitMQ running" || echo "✗ RabbitMQ not running"
systemctl is-active redis-server 2>/dev/null && echo "✓ Redis running" || echo "✗ Redis not running"
echo ""

echo "=========================================="
echo "Setup Check Complete"
echo "=========================================="


