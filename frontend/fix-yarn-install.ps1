# PowerShell script untuk fix yarn installation issues
# Usage: .\fix-yarn-install.ps1

Write-Host "🔧 Fixing ALwrity Frontend Installation dengan Yarn..." -ForegroundColor Cyan
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
if (Test-Path "yarn.lock") {
    Remove-Item -Force yarn.lock -ErrorAction SilentlyContinue
    Write-Host "   ✓ Removed yarn.lock" -ForegroundColor Green
}
if (Test-Path "package-lock.json") {
    Remove-Item -Force package-lock.json -ErrorAction SilentlyContinue
    Write-Host "   ✓ Removed package-lock.json" -ForegroundColor Green
}

# Step 2: Configure yarn
Write-Host ""
Write-Host "⚙️  Step 2: Configuring yarn..." -ForegroundColor Yellow

# Set network timeout (10 minutes = 600000ms)
yarn config set network-timeout 600000
Write-Host "   ✓ Set network timeout to 10 minutes" -ForegroundColor Green

# Set network concurrency (reduce untuk stability)
yarn config set network-concurrency 1
Write-Host "   ✓ Set network concurrency to 1" -ForegroundColor Green

# Ask user if they want to use mirror (for slow connections)
$useMirror = Read-Host "   Use yarn mirror for faster download? (y/n) [n]"
if ($useMirror -eq "y" -or $useMirror -eq "Y") {
    yarn config set registry https://registry.npmmirror.com
    Write-Host "   ✓ Set registry to npmmirror.com" -ForegroundColor Green
} else {
    # Ensure using default registry
    yarn config set registry https://registry.yarnpkg.com
    Write-Host "   ✓ Using default yarn registry" -ForegroundColor Green
}

# Disable progress untuk mengurangi overhead
yarn config set enableProgress false
Write-Host "   ✓ Disabled progress bar (faster)" -ForegroundColor Green

# Step 3: Install dependencies
Write-Host ""
Write-Host "📥 Step 3: Installing dependencies dengan yarn..." -ForegroundColor Yellow
Write-Host "   This may take several minutes..." -ForegroundColor Gray
Write-Host "   Network timeout: 10 minutes" -ForegroundColor Gray
Write-Host ""

# Install dengan yarn
$installResult = yarn install 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Installation successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Run 'yarn start' to start development server" -ForegroundColor White
    Write-Host "   2. Run 'yarn build' to build for production" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ Installation failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Check your internet connection" -ForegroundColor White
    Write-Host "   2. Try using yarn mirror: yarn config set registry https://registry.npmmirror.com" -ForegroundColor White
    Write-Host "   3. Increase timeout: yarn config set network-timeout 1200000" -ForegroundColor White
    Write-Host "   4. Check firewall/proxy settings" -ForegroundColor White
    Write-Host "   5. See TROUBLESHOOTING_INSTALL.md for more solutions" -ForegroundColor White
    Write-Host ""
    Write-Host "Error output:" -ForegroundColor Red
    Write-Host $installResult -ForegroundColor Gray
    exit 1
}

