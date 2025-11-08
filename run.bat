@echo off
cd /d "%~dp0"

echo Starting ONLYOFFICE Document Server...
echo.

echo Starting DocService...
start "DocService" cmd /k "cd /d "%~dp0DocService" && set "NODE_ENV=development-windows" && set "NODE_CONFIG_DIR=%~dp0Common\config" && node sources/server.js"

timeout /t 3 /nobreak >nul

echo Starting FileConverter...
start "FileConverter" cmd /k "cd /d "%~dp0FileConverter" && set "NODE_ENV=development-windows" && set "NODE_CONFIG_DIR=%~dp0Common\config" && node sources/convertermaster.js"

echo.
echo Services started in separate windows.
echo DocService should be running on http://localhost:8000
echo.
echo Press any key to exit this window (services will continue running)...
pause >nul
