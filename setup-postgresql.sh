#!/bin/bash
# PostgreSQL setup script for ONLYOFFICE Document Server

echo "Checking PostgreSQL installation..."

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "PostgreSQL is not installed. Installing..."
    
    # Update package list
    apt-get update
    
    # Install PostgreSQL
    apt-get install -y postgresql postgresql-contrib
    
    # Start PostgreSQL service
    systemctl start postgresql
    systemctl enable postgresql
    
    echo "PostgreSQL installed and started."
else
    echo "PostgreSQL is already installed."
fi

# Check if PostgreSQL service is running
if systemctl is-active --quiet postgresql; then
    echo "PostgreSQL service is running."
else
    echo "Starting PostgreSQL service..."
    systemctl start postgresql
fi

# Find the PostgreSQL user (could be postgres or another user)
PG_USER=""
if id "postgres" &>/dev/null; then
    PG_USER="postgres"
elif id "$(whoami)" &>/dev/null; then
    # Try with current user
    PG_USER="$(whoami)"
else
    echo "Error: Cannot determine PostgreSQL user"
    exit 1
fi

echo "Using PostgreSQL user: $PG_USER"

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create database and user
echo "Setting up database..."

# Try to connect and create database
if [ "$PG_USER" = "postgres" ]; then
    sudo -u postgres psql << EOF
CREATE USER onlyoffice WITH PASSWORD 'onlyoffice';
CREATE DATABASE onlyoffice OWNER onlyoffice;
\q
EOF
else
    # If running as root or another user, try direct psql
    psql -U $PG_USER << EOF
CREATE USER onlyoffice WITH PASSWORD 'onlyoffice';
CREATE DATABASE onlyoffice OWNER onlyoffice;
\q
EOF
fi

# Run the schema
echo "Creating tables..."
if [ "$PG_USER" = "postgres" ]; then
    sudo -u postgres psql -d onlyoffice -f "$SCRIPT_DIR/schema/postgresql/createdb.sql"
else
    psql -U $PG_USER -d onlyoffice -f "$SCRIPT_DIR/schema/postgresql/createdb.sql"
fi

echo "Database setup complete!"
echo ""
echo "To verify, run:"
if [ "$PG_USER" = "postgres" ]; then
    echo "  sudo -u postgres psql -d onlyoffice -c '\\dt'"
else
    echo "  psql -U $PG_USER -d onlyoffice -c '\\dt'"
fi

