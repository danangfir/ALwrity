#!/bin/bash
# Bash script untuk fix yarn installation issues
# Usage: ./fix-yarn-install.sh

echo "🔧 Fixing ALwrity Frontend Installation dengan Yarn..."
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
if [ -f "yarn.lock" ]; then
    rm -f yarn.lock
    echo "   ✓ Removed yarn.lock"
fi
if [ -f "package-lock.json" ]; then
    rm -f package-lock.json
    echo "   ✓ Removed package-lock.json"
fi

# Step 2: Configure yarn
echo ""
echo "⚙️  Step 2: Configuring yarn..."

# Set network timeout (10 minutes = 600000ms)
yarn config set network-timeout 600000
echo "   ✓ Set network timeout to 10 minutes"

# Set network concurrency (reduce untuk stability)
yarn config set network-concurrency 1
echo "   ✓ Set network concurrency to 1"

# Ask user if they want to use mirror
read -p "   Use yarn mirror for faster download? (y/n) [n]: " USE_MIRROR
if [ "$USE_MIRROR" = "y" ] || [ "$USE_MIRROR" = "Y" ]; then
    yarn config set registry https://registry.npmmirror.com
    echo "   ✓ Set registry to npmmirror.com"
else
    yarn config set registry https://registry.yarnpkg.com
    echo "   ✓ Using default yarn registry"
fi

# Disable progress untuk mengurangi overhead
yarn config set enableProgress false
echo "   ✓ Disabled progress bar (faster)"

# Step 3: Install dependencies
echo ""
echo "📥 Step 3: Installing dependencies dengan yarn..."
echo "   This may take several minutes..."
echo "   Network timeout: 10 minutes"
echo ""

# Install dengan yarn
if yarn install; then
    echo ""
    echo "✅ Installation successful!"
    echo ""
    echo "Next steps:"
    echo "   1. Run 'yarn start' to start development server"
    echo "   2. Run 'yarn build' to build for production"
else
    echo ""
    echo "❌ Installation failed!"
    echo ""
    echo "Troubleshooting:"
    echo "   1. Check your internet connection"
    echo "   2. Try using yarn mirror: yarn config set registry https://registry.npmmirror.com"
    echo "   3. Increase timeout: yarn config set network-timeout 1200000"
    echo "   4. Check firewall/proxy settings"
    echo "   5. See TROUBLESHOOTING_INSTALL.md for more solutions"
    exit 1
fi

