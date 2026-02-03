#
# 🚀 ONE-CLICK BROWSER CHALLENGE SOLVER (Windows)
#
# This script automatically:
# 1. Installs Node.js (if missing)
# 2. Installs npm dependencies
# 3. Installs Playwright Chromium browser
# 4. Runs the challenge solver
# 5. Completes all 30 steps in ~30 seconds
#
# Usage: .\solve.ps1
#

$ErrorActionPreference = "Stop"

# Get script directory
$ROOT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ROOT_DIR

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🚀 ONE-CLICK BROWSER CHALLENGE SOLVER                      ║" -ForegroundColor Cyan
Write-Host "║     Completes 30 steps in under 5 minutes                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check/Install Node.js
Write-Host "[1/5] Checking Node.js..." -ForegroundColor Blue

$nodeExists = $false
try {
    $nodeVersion = & node --version 2>$null
    if ($nodeVersion) {
        $nodeExists = $true
        Write-Host "      ✓ Node.js found: $nodeVersion" -ForegroundColor Green
    }
} catch {}

if (-not $nodeExists) {
    Write-Host "      ⚠ Node.js not found. Installing..." -ForegroundColor Yellow

    # Try winget first
    $wingetExists = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetExists) {
        Write-Host "      ⬇ Installing Node.js via winget..." -ForegroundColor Cyan
        winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements 2>$null

        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        # Download Node.js directly
        Write-Host "      ⬇ Downloading Node.js installer..." -ForegroundColor Cyan
        $nodeUrl = "https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi"
        $installerPath = "$env:TEMP\node_installer.msi"

        Invoke-WebRequest -Uri $nodeUrl -OutFile $installerPath -UseBasicParsing
        Write-Host "      📦 Installing Node.js..." -ForegroundColor Cyan
        Start-Process msiexec.exe -Wait -ArgumentList "/i `"$installerPath`" /quiet /norestart"
        Remove-Item $installerPath -Force

        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }

    # Verify installation
    try {
        $nodeVersion = & node --version 2>$null
        if ($nodeVersion) {
            Write-Host "      ✓ Node.js installed: $nodeVersion" -ForegroundColor Green
        } else {
            throw "Node.js not found after installation"
        }
    } catch {
        Write-Host "      ❌ Failed to install Node.js. Please install manually from https://nodejs.org" -ForegroundColor Red
        exit 1
    }
}

# Step 2: Install npm dependencies
Write-Host "[2/5] Checking npm dependencies..." -ForegroundColor Blue

if (Test-Path "$ROOT_DIR\node_modules\playwright") {
    Write-Host "      ✓ Dependencies already installed" -ForegroundColor Green
} else {
    Write-Host "      ⬇ Installing npm packages..." -ForegroundColor Cyan
    & npm install --silent 2>$null
    if (-not $?) { & npm install }
    Write-Host "      ✓ Dependencies installed" -ForegroundColor Green
}

# Step 3: Install Playwright Chromium
Write-Host "[3/5] Checking Playwright browser..." -ForegroundColor Blue

$playwrightCache = "$env:LOCALAPPDATA\ms-playwright"
$chromiumInstalled = $false

if (Test-Path $playwrightCache) {
    $chromiumDirs = Get-ChildItem -Path $playwrightCache -Directory -Filter "chromium-*" -ErrorAction SilentlyContinue
    if ($chromiumDirs) {
        $chromiumInstalled = $true
    }
}

if ($chromiumInstalled) {
    Write-Host "      ✓ Chromium browser ready" -ForegroundColor Green
} else {
    # Check for offline cache
    if (Test-Path "$ROOT_DIR\offline\ms-playwright") {
        Write-Host "      📦 Using offline Chromium bundle..." -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $playwrightCache -Force | Out-Null
        Copy-Item -Path "$ROOT_DIR\offline\ms-playwright\*" -Destination $playwrightCache -Recurse -Force
        Write-Host "      ✓ Chromium installed from offline cache" -ForegroundColor Green
    } else {
        Write-Host "      ⬇ Downloading Chromium browser (~170MB)..." -ForegroundColor Cyan
        & npx playwright install chromium 2>$null
        if (-not $?) { & npx playwright install chromium }
        Write-Host "      ✓ Chromium browser installed" -ForegroundColor Green
    }
}

# Step 4: Create output directory
Write-Host "[4/5] Preparing output directory..." -ForegroundColor Blue
New-Item -ItemType Directory -Path "$ROOT_DIR\output" -Force | Out-Null
Write-Host "      ✓ Output directory ready" -ForegroundColor Green

# Step 5: Run the solver
Write-Host ""
Write-Host "[5/5] 🎯 STARTING CHALLENGE SOLVER" -ForegroundColor Green
Write-Host "      Target: https://serene-frangipane-7fd25b.netlify.app/"
Write-Host ""
Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor Cyan

# Run the solver
$startTime = Get-Date
& node "$ROOT_DIR\solver.js"
$exitCode = $LASTEXITCODE
$endTime = Get-Date
$duration = [math]::Round(($endTime - $startTime).TotalSeconds)

Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host ""

# Show results
if ($exitCode -eq 0) {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  🏆 CHALLENGE COMPLETE!                                    ║" -ForegroundColor Green
    Write-Host "║     Total time: $duration seconds                                  ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green

    # Show screenshot location
    $screenshotPath = "$ROOT_DIR\output\final_screenshot.png"
    if (Test-Path $screenshotPath) {
        Write-Host ""
        Write-Host "📸 Screenshot: output\final_screenshot.png" -ForegroundColor Cyan
        Write-Host "📊 Statistics: output\run_stats.json" -ForegroundColor Cyan

        # Try to open the screenshot
        Start-Process $screenshotPath -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║  ❌ Solver exited with error code: $exitCode                       ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    exit $exitCode
}

Write-Host ""
