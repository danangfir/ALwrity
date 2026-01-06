# PowerShell script untuk fix installation issues
# Usage: .\fix-install.ps1

Write-Host "🔧 Fixing ALwrity Frontend Installation..." -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "package.json")) {
    Write-Host "❌ Error: package.json not found!" -ForegroundColor Red
    Write-Host "   Please run this script from the frontend directory." -ForegroundColor Yellow
    exit 1
}

# Step 1: Clean up
Write-Host "📦 Step 1: Cleaning up old files..." -ForegroundColor Yellow
if (Test-Path "node_modules") {
    Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue
    Write-Host "   ✓ Removed node_modules" -ForegroundColor Green
}
if (Test-Path "package-lock.json") {
    Remove-Item -Force package-lock.json -ErrorAction SilentlyContinue
    Write-Host "   ✓ Removed package-lock.json" -ForegroundColor Green
}
if (Test-Path "yarn.lock") {
    Remove-Item -Force yarn.lock -ErrorAction SilentlyContinue
    Write-Host "   ✓ Removed yarn.lock" -ForegroundColor Green
}

# Step 2: Configure npm (optional - uncomment if needed)
Write-Host ""
Write-Host "⚙️  Step 2: Configuring npm..." -ForegroundColor Yellow

# Check current registry
$currentRegistry = npm config get registry
Write-Host "   Current registry: $currentRegistry" -ForegroundColor Gray

# Ask user if they want to use mirror (for slow connections)
$useMirror = Read-Host "   Use npm mirror for faster download? (y/n) [n]"
if ($useMirror -eq "y" -or $useMirror -eq "Y") {
    npm config set registry https://registry.npmmirror.com
    Write-Host "   ✓ Set registry to npmmirror.com" -ForegroundColor Green
} else {
    Write-Host "   ✓ Using default registry" -ForegroundColor Green
}

# Set timeout
npm config set fetch-timeout 120000
npm config set fetch-retries 5
Write-Host "   ✓ Set timeout to 120 seconds" -ForegroundColor Green

# Step 3: Install dependencies
Write-Host ""
Write-Host "📥 Step 3: Installing dependencies..." -ForegroundColor Yellow
Write-Host "   This may take several minutes..." -ForegroundColor Gray
Write-Host ""

# Install with extended timeout and retry
$installResult = npm install --legacy-peer-deps --timeout=120000 --maxsockets=1 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Installation successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Run 'npm start' to start development server" -ForegroundColor White
    Write-Host "   2. Run 'npm run build' to build for production" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ Installation failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Check your internet connection" -ForegroundColor White
    Write-Host "   2. Try using npm mirror: npm config set registry https://registry.npmmirror.com" -ForegroundColor White
    Write-Host "   3. Check firewall/proxy settings" -ForegroundColor White
    Write-Host "   4. See TROUBLESHOOTING_INSTALL.md for more solutions" -ForegroundColor White
    Write-Host ""
    Write-Host "Error output:" -ForegroundColor Red
    Write-Host $installResult -ForegroundColor Gray
    exit 1
}

