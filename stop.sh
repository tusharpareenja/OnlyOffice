#!/bin/bash
# Stop script for ONLYOFFICE Document Server

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f "$SCRIPT_DIR/logs/docservice.pid" ]; then
    PID=$(cat "$SCRIPT_DIR/logs/docservice.pid")
    if ps -p $PID > /dev/null 2>&1; then
        echo "Stopping DocService (PID: $PID)..."
        kill $PID
    else
        echo "DocService process not found"
    fi
    rm "$SCRIPT_DIR/logs/docservice.pid"
fi

if [ -f "$SCRIPT_DIR/logs/fileconverter.pid" ]; then
    PID=$(cat "$SCRIPT_DIR/logs/fileconverter.pid")
    if ps -p $PID > /dev/null 2>&1; then
        echo "Stopping FileConverter (PID: $PID)..."
        kill $PID
    else
        echo "FileConverter process not found"
    fi
    rm "$SCRIPT_DIR/logs/fileconverter.pid"
fi

echo "Services stopped."

