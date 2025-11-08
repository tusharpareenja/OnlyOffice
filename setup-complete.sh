#!/bin/bash
# Complete setup script for ONLYOFFICE Document Server on Linux

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "ONLYOFFICE Document Server Setup"
echo "=========================================="
echo ""

# Check if dependencies are installed
echo "Step 1: Installing dependencies..."
if [ ! -d "node_modules" ] || [ ! -d "Common/node_modules" ] || [ ! -d "DocService/node_modules" ]; then
    echo "Installing root dependencies..."
    npm install
    
    echo "Installing Common dependencies..."
    npm run install:Common
    
    echo "Installing DocService dependencies..."
    npm run install:DocService
    
    echo "Installing FileConverter dependencies..."
    npm run install:FileConverter
    
    echo "✓ Dependencies installed"
else
    echo "✓ Dependencies already installed"
fi

echo ""
echo "Step 2: Creating logs directory..."
mkdir -p logs
echo "✓ Logs directory created"

echo ""
echo "Step 3: Making scripts executable..."
chmod +x run.sh stop.sh 2>/dev/null || true
echo "✓ Scripts ready"

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Make sure PostgreSQL, RabbitMQ, and Redis are running:"
echo "   sudo systemctl status postgresql"
echo "   sudo systemctl status rabbitmq-server"
echo "   sudo systemctl status redis-server"
echo ""
echo "2. Start the Document Server:"
echo "   ./run.sh"
echo ""
echo "   Or manually:"
echo "   Terminal 1: cd DocService && NODE_ENV=development-linux NODE_CONFIG_DIR=../Common/config node sources/server.js"
echo "   Terminal 2: cd FileConverter && NODE_ENV=development-linux NODE_CONFIG_DIR=../Common/config node sources/convertermaster.js"
echo ""
echo "3. Verify it's working:"
echo "   curl http://localhost:8000/healthcheck"
echo ""

