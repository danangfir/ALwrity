#!/bin/bash
# Bash script untuk fix installation issues
# Usage: ./fix-install.sh

echo "🔧 Fixing ALwrity Frontend Installation..."
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found!"
    echo "   Please run this script from the frontend directory."
    exit 1
fi

# Step 1: Clean up
echo "📦 Step 1: Cleaning up old files..."
if [ -d "node_modules" ]; then
    rm -rf node_modules
    echo "   ✓ Removed node_modules"
fi
if [ -f "package-lock.json" ]; then
    rm -f package-lock.json
    echo "   ✓ Removed package-lock.json"
fi
if [ -f "yarn.lock" ]; then
    rm -f yarn.lock
    echo "   ✓ Removed yarn.lock"
fi

# Step 2: Configure npm
echo ""
echo "⚙️  Step 2: Configuring npm..."

# Check current registry
CURRENT_REGISTRY=$(npm config get registry)
echo "   Current registry: $CURRENT_REGISTRY"

# Ask user if they want to use mirror
read -p "   Use npm mirror for faster download? (y/n) [n]: " USE_MIRROR
if [ "$USE_MIRROR" = "y" ] || [ "$USE_MIRROR" = "Y" ]; then
    npm config set registry https://registry.npmmirror.com
    echo "   ✓ Set registry to npmmirror.com"
else
    echo "   ✓ Using default registry"
fi

# Set timeout
npm config set fetch-timeout 120000
npm config set fetch-retries 5
echo "   ✓ Set timeout to 120 seconds"

# Step 3: Install dependencies
echo ""
echo "📥 Step 3: Installing dependencies..."
echo "   This may take several minutes..."
echo ""

# Install with extended timeout and retry
if npm install --legacy-peer-deps --timeout=120000 --maxsockets=1; then
    echo ""
    echo "✅ Installation successful!"
    echo ""
    echo "Next steps:"
    echo "   1. Run 'npm start' to start development server"
    echo "   2. Run 'npm run build' to build for production"
else
    echo ""
    echo "❌ Installation failed!"
    echo ""
    echo "Troubleshooting:"
    echo "   1. Check your internet connection"
    echo "   2. Try using npm mirror: npm config set registry https://registry.npmmirror.com"
    echo "   3. Check firewall/proxy settings"
    echo "   4. See TROUBLESHOOTING_INSTALL.md for more solutions"
    exit 1
fi

