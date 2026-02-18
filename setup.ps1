$ErrorActionPreference = "Stop"

Write-Host "Starting Laravel Windows Companion Setup..." -ForegroundColor Cyan

# 1. Detect Container Engine (Podman/Docker)
$engine = "docker"
if (Get-Command "podman" -ErrorAction SilentlyContinue) {
    if (Get-Command "docker" -ErrorAction SilentlyContinue) {
        # Both exist, prefer podman if docker is not running or if user prefers
        $engine = "podman" 
        Write-Host "Detected Podman and Docker. Using Podman." -ForegroundColor Green
    } else {
        $engine = "podman"
        Write-Host "Detected Podman." -ForegroundColor Green
    }
} elseif (Get-Command "docker" -ErrorAction SilentlyContinue) {
    Write-Host "Detected Docker." -ForegroundColor Green
} else {
    Write-Error "No Container Engine found! Please install Docker Desktop or Podman Desktop."
    exit 1
}

# 2. Setup Environment File
if (-not (Test-Path ".env")) {
    Write-Host "Copying .env.docker to .env..." -ForegroundColor Yellow
    Copy-Item ".env.docker" ".env"
} else {
    Write-Host ".env file already exists. Skipping copy." -ForegroundColor Gray
}

# 3. Increase Timeout for Slow Connections
$env:COMPOSE_HTTP_TIMEOUT = "300" # 5 Minutes
Write-Host "Increased Compose Timeout to 300s for slow connections." -ForegroundColor Gray

# 4. Explicit Pull (Fixes 'Stuck' perception)
Write-Host "`nPulling Images (This may take a while for MySQL/MariaDB)..." -ForegroundColor Cyan
& $engine compose pull
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to pull images. Check your internet connection."
    exit 1
}

# 5. Build Custom Images
Write-Host "`nBuilding Custom Configs..." -ForegroundColor Cyan
& $engine compose build
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to build images."
    exit 1
}

# 6. Start Services
Write-Host "`nStarting Services..." -ForegroundColor Cyan
& $engine compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to start services."
    exit 1
}

Write-Host "`nAll Services are Running!" -ForegroundColor Green
& $engine compose ps
Write-Host "`nSetup Complete! You can now use the services." -ForegroundColor Cyan
