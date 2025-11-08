#!/bin/bash
# Install and setup PostgreSQL for ONLYOFFICE Document Server

set -e

echo "=========================================="
echo "Installing PostgreSQL"
echo "=========================================="

# Update package list
echo "Updating package list..."
apt-get update

# Install PostgreSQL server and client
echo "Installing PostgreSQL..."
apt-get install -y postgresql postgresql-contrib

# Start PostgreSQL service
echo "Starting PostgreSQL service..."
systemctl start postgresql
systemctl enable postgresql

# Wait a moment for service to start
sleep 2

# Check if service is running
if systemctl is-active --quiet postgresql; then
    echo "✓ PostgreSQL service is running"
else
    echo "✗ Error: PostgreSQL service failed to start"
    exit 1
fi

echo ""
echo "=========================================="
echo "Setting up database"
echo "=========================================="

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create database and user
echo "Creating database and user..."
sudo -u postgres psql << 'EOF'
-- Create user if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'onlyoffice') THEN
    CREATE USER onlyoffice WITH PASSWORD 'onlyoffice';
  END IF;
END
$$;

-- Create database if it doesn't exist
SELECT 'CREATE DATABASE onlyoffice OWNER onlyoffice'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'onlyoffice')\gexec
EOF

echo "✓ Database and user created"

# Run the schema
echo "Creating tables..."
if [ -f "$SCRIPT_DIR/schema/postgresql/createdb.sql" ]; then
    sudo -u postgres psql -d onlyoffice -f "$SCRIPT_DIR/schema/postgresql/createdb.sql"
    echo "✓ Tables created"
else
    echo "✗ Error: Schema file not found at $SCRIPT_DIR/schema/postgresql/createdb.sql"
    exit 1
fi

# Verify tables
echo ""
echo "Verifying tables..."
TABLE_COUNT=$(sudo -u postgres psql -d onlyoffice -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('doc_changes', 'task_result');")

if [ "$TABLE_COUNT" -eq 2 ]; then
    echo "✓ All tables created successfully"
    echo ""
    echo "Tables:"
    sudo -u postgres psql -d onlyoffice -c "\dt"
else
    echo "⚠ Warning: Expected 2 tables, found $TABLE_COUNT"
fi

echo ""
echo "=========================================="
echo "PostgreSQL setup complete!"
echo "=========================================="
echo ""
echo "Database: onlyoffice"
echo "User: onlyoffice"
echo "Password: onlyoffice"
echo ""
echo "To test connection:"
echo "  sudo -u postgres psql -d onlyoffice -c '\\dt'"

