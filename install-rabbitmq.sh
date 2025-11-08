#!/bin/bash
# Install RabbitMQ for ONLYOFFICE Document Server

set -e

echo "=========================================="
echo "Installing RabbitMQ"
echo "=========================================="

# Add RabbitMQ repository
echo "Adding RabbitMQ repository..."
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key | sudo apt-key add -
echo "deb https://ppa1.novemberain.com/rabbitmq/rabbitmq-erlang/ubuntu jammy main" | sudo tee /etc/apt/sources.list.d/rabbitmq.list
echo "deb https://ppa1.novemberain.com/rabbitmq/rabbitmq-server/ubuntu jammy main" | sudo tee -a /etc/apt/sources.list.d/rabbitmq.list

# Update package list
echo "Updating package list..."
apt-get update

# Install Erlang (required for RabbitMQ)
echo "Installing Erlang..."
apt-get install -y erlang-base erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
    erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key erlang-runtime-tools \
    erlang-snmp erlang-ssl erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

# Install RabbitMQ
echo "Installing RabbitMQ..."
apt-get install -y rabbitmq-server

# Start RabbitMQ service
echo "Starting RabbitMQ service..."
systemctl start rabbitmq-server
systemctl enable rabbitmq-server

# Wait a moment
sleep 3

# Enable management plugin
echo "Enabling RabbitMQ management plugin..."
rabbitmq-plugins enable rabbitmq_management

# Check status
if systemctl is-active --quiet rabbitmq-server; then
    echo "✓ RabbitMQ service is running"
    echo ""
    echo "RabbitMQ Management UI: http://localhost:15672"
    echo "Default credentials: guest / guest"
else
    echo "✗ Error: RabbitMQ service failed to start"
    exit 1
fi

echo ""
echo "=========================================="
echo "RabbitMQ installation complete!"
echo "=========================================="

