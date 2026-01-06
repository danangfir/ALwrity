#!/bin/bash
# ALwrity Quick Setup Script for Ubuntu
# One-command setup untuk VPS baru
# Usage: sudo bash ubuntu-quick-setup.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  ALwrity Quick Setup (Ubuntu)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SETUP_SCRIPT="$SCRIPT_DIR/ubuntu-setup.sh"

if [ -f "$SETUP_SCRIPT" ]; then
    echo -e "${YELLOW}Running full setup script...${NC}"
    bash "$SETUP_SCRIPT"
else
    echo -e "${YELLOW}Running minimal setup...${NC}"
    
    # Update
    apt-get update -qq
    apt-get upgrade -y -qq
    
    # Install Docker
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
        systemctl start docker
        systemctl enable docker
    fi
    
    # Install Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        apt-get install -y -qq docker-compose-plugin
    fi
    
    # Install basic tools
    apt-get install -y -qq curl wget git htop python3 python3-pip
    
    # Configure firewall
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    
    echo -e "${GREEN}✅ Quick setup complete!${NC}"
fi

echo ""
echo -e "${YELLOW}Next: Run deploy-alwrity.sh to deploy ALwrity${NC}"
echo ""

