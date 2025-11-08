#!/bin/bash
# Linux run script for ONLYOFFICE Document Server

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Set environment variables
export NODE_ENV=development-linux
export NODE_CONFIG_DIR="$SCRIPT_DIR/Common/config"

echo "Starting ONLYOFFICE Document Server..."
echo "Config directory: $NODE_CONFIG_DIR"
echo ""

# Start DocService in background
echo "Starting DocService..."
cd "$SCRIPT_DIR/DocService"
nohup node sources/server.js > ../logs/docservice.log 2>&1 &
DOCSERVICE_PID=$!
echo "DocService started with PID: $DOCSERVICE_PID"
echo "Logs: $SCRIPT_DIR/logs/docservice.log"

# Wait a bit
sleep 3

# Start FileConverter in background
echo "Starting FileConverter..."
cd "$SCRIPT_DIR/FileConverter"
nohup node sources/convertermaster.js > ../logs/fileconverter.log 2>&1 &
FILECONVERTER_PID=$!
echo "FileConverter started with PID: $FILECONVERTER_PID"
echo "Logs: $SCRIPT_DIR/logs/fileconverter.log"

# Save PIDs to file for easy stopping
echo "$DOCSERVICE_PID" > "$SCRIPT_DIR/logs/docservice.pid"
echo "$FILECONVERTER_PID" > "$SCRIPT_DIR/logs/fileconverter.pid"

echo ""
echo "Services started!"
echo "DocService should be running on http://localhost:8000"
echo ""
echo "To stop the services, run: ./stop.sh"
echo "Or kill the processes: kill $DOCSERVICE_PID $FILECONVERTER_PID"

