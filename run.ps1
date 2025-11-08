# PowerShell script to start ONLYOFFICE Document Server
$ErrorActionPreference = "Stop"

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$configDir = Join-Path $scriptPath "Common\config"

Write-Host "Starting ONLYOFFICE Document Server..." -ForegroundColor Green
Write-Host ""

# Start DocService
Write-Host "Starting DocService..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$scriptPath\DocService'; `$env:NODE_ENV='development-windows'; `$env:NODE_CONFIG_DIR='$configDir'; node sources/server.js"

Start-Sleep -Seconds 3

# Start FileConverter
Write-Host "Starting FileConverter..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$scriptPath\FileConverter'; `$env:NODE_ENV='development-windows'; `$env:NODE_CONFIG_DIR='$configDir'; node sources/convertermaster.js"

Write-Host ""
Write-Host "Services started in separate windows." -ForegroundColor Green
Write-Host "DocService should be running on http://localhost:8000" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")



