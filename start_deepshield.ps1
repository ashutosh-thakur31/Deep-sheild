# DeepShield Launcher (PowerShell)
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "           DEEPSHIELD CYBERSECURITY PLATFORM" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check Python
try {
    $pyVer = & python --version 2>&1
    Write-Host "[OK] Python detected: $pyVer" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Python was not found in PATH." -ForegroundColor Red
    exit 1
}

# Start Backend
Write-Host "Starting Flask Backend on http://localhost:5000 ..." -ForegroundColor Yellow
Start-Process cmd.exe -ArgumentList "/k cd /d `"$baseDir`" && python main.py"

# Start Frontend
Write-Host "Starting React Frontend on http://localhost:5173 ..." -ForegroundColor Yellow
Start-Process cmd.exe -ArgumentList "/k cd /d `"$baseDir\frontend`" && npm.cmd run dev"

Write-Host ""
Write-Host "DeepShield launched successfully!" -ForegroundColor Green
Write-Host "Open http://localhost:5173 in your browser." -ForegroundColor Cyan
Start-Sleep -Seconds 4
Start-Process "http://localhost:5173"

