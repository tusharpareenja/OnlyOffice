#!/bin/bash
# Script to verify connection limit change on ARM server

echo "=========================================="
echo "Verifying Connection Limit Change"
echo "=========================================="
echo ""

# Check the constant value in the code
echo "1. Checking LICENSE_CONNECTIONS value in code:"
grep "LICENSE_CONNECTIONS" ~/OnlyOffice/Common/sources/constants.js
echo ""

# Check server info endpoint
echo "2. Checking server info (connection limits):"
curl -s http://localhost:8000/info/info.json | python3 -m json.tool | grep -A 5 -B 5 "connections" || echo "Server not responding"
echo ""

# Check license info specifically
echo "3. Checking license info:"
curl -s http://localhost:8000/info/info.json | python3 -c "
import sys, json
data = json.load(sys.stdin)
if 'licenseInfo' in data:
    lic = data['licenseInfo']
    print(f\"Connections limit: {lic.get('connections', 'N/A')}\")
    print(f\"Connections view limit: {lic.get('connectionsView', 'N/A')}\")
else:
    print('License info not found in response')
"
echo ""

echo "=========================================="
echo "Verification Complete"
echo "=========================================="
echo ""
echo "Expected: connections should be 1000 (not 20)"
echo ""




