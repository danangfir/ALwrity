#!/bin/bash
# ALwrity Ubuntu VPS Setup Script
# Untuk VPS 8GB RAM - Ubuntu 20.04+ / 22.04 LTS
# Usage: sudo bash ubuntu-setup.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Please run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  ALwrity Ubuntu VPS Setup Script${NC}"
echo -e "${BLUE}  For VPS 8GB RAM${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: System Update
echo -e "${YELLOW}📦 Step 1: Updating system packages...${NC}"
apt-get update -qq
apt-get upgrade -y -qq
echo -e "${GREEN}✅ System updated${NC}"
echo ""

# Step 2: Install Basic Dependencies
echo -e "${YELLOW}📦 Step 2: Installing basic dependencies...${NC}"
apt-get install -y -qq \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    net-tools \
    ufw \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release
echo -e "${GREEN}✅ Basic dependencies installed${NC}"
echo ""

# Step 3: Install Docker
echo -e "${YELLOW}🐳 Step 3: Installing Docker...${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker already installed${NC}"
    docker --version
else
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    # Add current user to docker group (if not root)
    if [ -n "$SUDO_USER" ]; then
        usermod -aG docker $SUDO_USER
        echo -e "${GREEN}✓ Added $SUDO_USER to docker group${NC}"
    fi
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    echo -e "${GREEN}✅ Docker installed and started${NC}"
fi
echo ""

# Step 4: Install Docker Compose
echo -e "${YELLOW}🐳 Step 4: Installing Docker Compose...${NC}"
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    echo -e "${GREEN}✓ Docker Compose already installed${NC}"
    docker compose version || docker-compose --version
else
    echo "Installing Docker Compose..."
    apt-get install -y -qq docker-compose-plugin
    echo -e "${GREEN}✅ Docker Compose installed${NC}"
fi
echo ""

# Step 5: Install Python 3.10+ (for scripts)
echo -e "${YELLOW}🐍 Step 5: Installing Python 3.10+...${NC}"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
    echo -e "${GREEN}✓ Python $PYTHON_VERSION already installed${NC}"
else
    apt-get install -y -qq python3 python3-pip python3-venv
    echo -e "${GREEN}✅ Python 3 installed${NC}"
fi

# Install psutil for monitoring scripts
pip3 install --quiet psutil 2>/dev/null || echo -e "${YELLOW}⚠ psutil installation skipped (will install later)${NC}"
echo ""

# Step 6: Configure Firewall
echo -e "${YELLOW}🔥 Step 6: Configuring firewall (UFW)...${NC}"
if ufw status | grep -q "Status: active"; then
    echo -e "${GREEN}✓ UFW already configured${NC}"
else
    # Allow SSH (important!)
    ufw allow 22/tcp comment 'SSH'
    
    # Allow HTTP and HTTPS
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'
    
    # Allow ALwrity backend (if needed externally)
    ufw allow 8000/tcp comment 'ALwrity Backend' || true
    
    # Enable firewall
    ufw --force enable
    echo -e "${GREEN}✅ Firewall configured${NC}"
fi
echo ""

# Step 7: Create ALwrity User (optional but recommended)
echo -e "${YELLOW}👤 Step 7: Creating ALwrity user...${NC}"
read -p "Create dedicated 'alwrity' user? (y/n) [y]: " CREATE_USER
CREATE_USER=${CREATE_USER:-y}

if [ "$CREATE_USER" = "y" ] || [ "$CREATE_USER" = "Y" ]; then
    if id "alwrity" &>/dev/null; then
        echo -e "${GREEN}✓ User 'alwrity' already exists${NC}"
    else
        useradd -m -s /bin/bash alwrity
        usermod -aG docker alwrity
        echo -e "${GREEN}✅ User 'alwrity' created and added to docker group${NC}"
        echo -e "${YELLOW}⚠ Note: Set password with: passwd alwrity${NC}"
    fi
fi
echo ""

# Step 8: Create Directories
echo -e "${YELLOW}📁 Step 8: Creating directories...${NC}"
mkdir -p /opt/alwrity
mkdir -p /var/log/alwrity
mkdir -p /opt/alwrity/data
mkdir -p /opt/alwrity/logs
echo -e "${GREEN}✅ Directories created${NC}"
echo ""

# Step 9: System Optimization
echo -e "${YELLOW}⚙️  Step 9: Optimizing system for 8GB RAM...${NC}"

# Increase file descriptor limits
cat >> /etc/security/limits.conf << EOF
# ALwrity optimizations
* soft nofile 65535
* hard nofile 65535
EOF

# Optimize swappiness (reduce swap usage)
if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
    echo "vm.swappiness=10" >> /etc/sysctl.conf
    sysctl -w vm.swappiness=10
fi

# Optimize overcommit memory
if ! grep -q "vm.overcommit_memory" /etc/sysctl.conf; then
    echo "vm.overcommit_memory=1" >> /etc/sysctl.conf
    sysctl -w vm.overcommit_memory=1
fi

echo -e "${GREEN}✅ System optimized${NC}"
echo ""

# Step 10: Install Monitoring Tools
echo -e "${YELLOW}📊 Step 10: Installing monitoring tools...${NC}"
apt-get install -y -qq \
    htop \
    iotop \
    nethogs \
    iftop \
    ncdu \
    tree \
    jq \
    curl \
    wget
echo -e "${GREEN}✅ Monitoring tools installed${NC}"
echo ""

# Step 11: Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo ""
echo "1. Clone ALwrity repository:"
echo -e "   ${BLUE}cd /opt/alwrity${NC}"
echo -e "   ${BLUE}git clone https://github.com/AJaySi/ALwrity.git .${NC}"
echo ""
echo "2. Configure environment:"
echo -e "   ${BLUE}cd /opt/alwrity/backend${NC}"
echo -e "   ${BLUE}cp env_template.txt .env${NC}"
echo -e "   ${BLUE}nano .env${NC}"
echo ""
echo "3. Build frontend (if needed):"
echo -e "   ${BLUE}cd /opt/alwrity/frontend${NC}"
echo -e "   ${BLUE}npm install${NC}"
echo -e "   ${BLUE}npm run build${NC}"
echo ""
echo "4. Deploy with Docker:"
echo -e "   ${BLUE}cd /opt/alwrity${NC}"
echo -e "   ${BLUE}docker-compose -f docker-compose.vps.yml up -d${NC}"
echo ""
echo "5. Check system requirements:"
echo -e "   ${BLUE}cd /opt/alwrity/backend${NC}"
echo -e "   ${BLUE}python3 scripts/check_system_requirements.py${NC}"
echo ""
echo "6. Monitor resources:"
echo -e "   ${BLUE}python3 backend/scripts/monitor_resources.py --once${NC}"
echo ""
echo -e "${YELLOW}📚 Documentation:${NC}"
echo "   - VPS_DEPLOYMENT_GUIDE.md"
echo "   - PLATFORM_COMPARISON.md"
echo "   - VPS_8GB_SETUP_SUMMARY.md"
echo ""
echo -e "${YELLOW}🔍 System Information:${NC}"
echo "   OS: $(lsb_release -d | cut -f2)"
echo "   Kernel: $(uname -r)"
echo "   RAM: $(free -h | grep Mem | awk '{print $2}')"
echo "   Disk: $(df -h / | tail -1 | awk '{print $4}') available"
echo ""
if command -v docker &> /dev/null; then
    echo -e "${GREEN}   Docker: $(docker --version)${NC}"
fi
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    echo -e "${GREEN}   Docker Compose: $(docker compose version 2>/dev/null || docker-compose --version)${NC}"
fi
echo ""
echo -e "${GREEN}✅ Ready for ALwrity deployment!${NC}"
echo ""

