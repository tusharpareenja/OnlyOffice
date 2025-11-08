# Linux Setup Guide for ONLYOFFICE Document Server

## Prerequisites

1. **Node.js** (v18 or later)
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

2. **PostgreSQL**
   ```bash
   sudo apt-get update
   sudo apt-get install -y postgresql postgresql-contrib
   sudo systemctl start postgresql
   sudo systemctl enable postgresql
   ```

3. **RabbitMQ**
   ```bash
   sudo apt-get install -y rabbitmq-server
   sudo systemctl start rabbitmq-server
   sudo systemctl enable rabbitmq-server
   sudo rabbitmq-plugins enable rabbitmq_management
   ```

4. **Redis**
   ```bash
   sudo apt-get install -y redis-server
   sudo systemctl start redis-server
   sudo systemctl enable redis-server
   ```

## Setup Steps

### 1. Install Dependencies

```bash
# Install root dependencies
npm install

# Install all sub-project dependencies
npm run install:Common
npm run install:DocService
npm run install:FileConverter
npm run install:SpellChecker
```

### 2. Set Up PostgreSQL Database

```bash
# Switch to postgres user
sudo -u postgres psql

# In PostgreSQL prompt, run:
CREATE USER onlyoffice WITH PASSWORD 'onlyoffice';
CREATE DATABASE onlyoffice OWNER onlyoffice;
\c onlyoffice
\i '/root/OnlyOffice/schema/postgresql/createdb.sql'
\q
```

Or from command line:
```bash
sudo -u postgres psql -c "CREATE USER onlyoffice WITH PASSWORD 'onlyoffice';"
sudo -u postgres psql -c "CREATE DATABASE onlyoffice OWNER onlyoffice;"
sudo -u postgres psql -d onlyoffice -f schema/postgresql/createdb.sql
```

### 3. Create Logs Directory

```bash
mkdir -p logs
```

### 4. Make Run Scripts Executable

```bash
chmod +x run.sh
chmod +x stop.sh
```

### 5. Run the Server

```bash
./run.sh
```

Or run manually in separate terminals:

**Terminal 1 - DocService:**
```bash
cd DocService
export NODE_ENV=development-linux
export NODE_CONFIG_DIR=../Common/config
node sources/server.js
```

**Terminal 2 - FileConverter:**
```bash
cd FileConverter
export NODE_ENV=development-linux
export NODE_CONFIG_DIR=../Common/config
node sources/convertermaster.js
```

### 6. Verify Server is Running

```bash
curl http://localhost:8000/healthcheck
# Should return: true

curl http://localhost:8000/info/info.json
# Should return JSON with server info
```

## Configuration

The server uses `development-linux.json` configuration by default when `NODE_ENV=development-linux`.

Key configuration files:
- `Common/config/default.json` - Base configuration
- `Common/config/development-linux.json` - Development settings for Linux
- `Common/config/production-linux.json` - Production settings for Linux

## Troubleshooting

### Database Connection Issues

If you see database errors:
1. Check PostgreSQL is running: `sudo systemctl status postgresql`
2. Verify database exists: `sudo -u postgres psql -l | grep onlyoffice`
3. Check tables exist: `sudo -u postgres psql -d onlyoffice -c "\dt"`

### Port Already in Use

If port 8000 is already in use:
```bash
# Find what's using the port
sudo lsof -i :8000

# Kill the process or change port in config
```

### RabbitMQ Connection Issues

```bash
# Check RabbitMQ status
sudo systemctl status rabbitmq-server

# Check management interface
curl http://localhost:15672
```

### Redis Connection Issues

```bash
# Check Redis status
sudo systemctl status redis-server

# Test Redis connection
redis-cli ping
# Should return: PONG
```

## Running as a Service (Optional)

To run as a systemd service, create `/etc/systemd/system/onlyoffice-docserver.service`:

```ini
[Unit]
Description=ONLYOFFICE Document Server
After=network.target postgresql.service rabbitmq-server.service redis-server.service

[Service]
Type=simple
User=root
WorkingDirectory=/root/OnlyOffice
Environment="NODE_ENV=development-linux"
Environment="NODE_CONFIG_DIR=/root/OnlyOffice/Common/config"
ExecStart=/usr/bin/node /root/OnlyOffice/DocService/sources/server.js
Restart=always

[Install]
WantedBy=multi-user.target
```

Then:
```bash
sudo systemctl daemon-reload
sudo systemctl enable onlyoffice-docserver
sudo systemctl start onlyoffice-docserver
```

## Notes

- **You don't need to run `grunt build`** - that's only for building distribution packages
- The server runs directly from source using Node.js
- Make sure all services (PostgreSQL, RabbitMQ, Redis) are running before starting the Document Server

