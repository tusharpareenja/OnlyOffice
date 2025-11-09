#!/bin/bash
set -e

# Function to wait for a service
wait_for_service() {
    local host=$1
    local port=$2
    local service_name=$3
    local max_attempts=60
    local attempt=0
    
    echo "Waiting for $service_name..."
    while [ $attempt -lt $max_attempts ]; do
        if timeout 1 bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null; then
            echo "$service_name is up!"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 1
    done
    
    echo "Warning: $service_name did not become available, continuing anyway..."
    return 0
}

# Wait for services (optional - will continue even if they're not ready)
wait_for_service "${DB_HOST:-postgres}" "${DB_PORT:-5432}" "PostgreSQL" || true
wait_for_service "${RABBITMQ_HOST:-rabbitmq}" "${RABBITMQ_PORT:-5672}" "RabbitMQ" || true
wait_for_service "${REDIS_HOST:-redis}" "${REDIS_PORT:-6379}" "Redis" || true

# Start DocService in background
echo "Starting DocService..."
cd /app/DocService
NODE_ENV=${NODE_ENV:-production-linux} \
NODE_CONFIG_DIR=/app/Common/config \
node sources/server.js &
DOCSERVICE_PID=$!

# Start FileConverter in background
echo "Starting FileConverter..."
cd /app/FileConverter
NODE_ENV=${NODE_ENV:-production-linux} \
NODE_CONFIG_DIR=/app/Common/config \
node sources/convertermaster.js &
FILECONVERTER_PID=$!

# Wait for both processes
wait $DOCSERVICE_PID $FILECONVERTER_PID

