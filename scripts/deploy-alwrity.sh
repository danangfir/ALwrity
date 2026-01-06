#!/bin/bash
# ALwrity Deployment Script for Ubuntu
# Deploys ALwrity after initial setup
# Usage: bash deploy-alwrity.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  ALwrity Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please run ubuntu-setup.sh first.${NC}"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo -e "${RED}❌ Docker Compose not found. Please run ubuntu-setup.sh first.${NC}"
    exit 1
fi

# Get project directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo -e "${YELLOW}📁 Project directory: $PROJECT_DIR${NC}"
echo ""

# Step 1: Check if repository is cloned
if [ ! -f "backend/app.py" ]; then
    echo -e "${YELLOW}📥 Repository not found. Cloning...${NC}"
    read -p "Enter repository URL [https://github.com/AJaySi/ALwrity.git]: " REPO_URL
    REPO_URL=${REPO_URL:-https://github.com/AJaySi/ALwrity.git}
    
    if [ -d ".git" ]; then
        echo -e "${GREEN}✓ Already a git repository${NC}"
    else
        git clone "$REPO_URL" .
    fi
    echo ""
fi

# Step 2: Check system requirements
echo -e "${YELLOW}🔍 Step 1: Checking system requirements...${NC}"
if [ -f "backend/scripts/check_system_requirements.py" ]; then
    cd backend
    python3 scripts/check_system_requirements.py || echo -e "${YELLOW}⚠ Some requirements not met, continuing...${NC}"
    cd ..
else
    echo -e "${YELLOW}⚠ System check script not found, skipping...${NC}"
fi
echo ""

# Step 3: Setup environment variables
echo -e "${YELLOW}⚙️  Step 2: Setting up environment variables...${NC}"
if [ ! -f "backend/.env" ]; then
    if [ -f "backend/env_template.txt" ]; then
        cp backend/env_template.txt backend/.env
        echo -e "${GREEN}✓ Created backend/.env from template${NC}"
        echo -e "${YELLOW}⚠ Please edit backend/.env and add your API keys${NC}"
        read -p "Edit .env now? (y/n) [n]: " EDIT_ENV
        if [ "$EDIT_ENV" = "y" ] || [ "$EDIT_ENV" = "Y" ]; then
            ${EDITOR:-nano} backend/.env
        fi
    else
        echo -e "${YELLOW}⚠ env_template.txt not found, creating empty .env${NC}"
        touch backend/.env
    fi
else
    echo -e "${GREEN}✓ backend/.env already exists${NC}"
fi
echo ""

# Step 4: Build frontend (optional)
echo -e "${YELLOW}🏗️  Step 3: Building frontend...${NC}"
read -p "Build frontend now? (y/n) [n]: " BUILD_FRONTEND
if [ "$BUILD_FRONTEND" = "y" ] || [ "$BUILD_FRONTEND" = "Y" ]; then
    if [ -f "frontend/package.json" ]; then
        cd frontend
        
        # Check if node_modules exists
        if [ ! -d "node_modules" ]; then
            echo "Installing frontend dependencies..."
            if command -v yarn &> /dev/null; then
                yarn install
            else
                npm install
            fi
        fi
        
        echo "Building frontend..."
        if command -v yarn &> /dev/null; then
            yarn build
        else
            npm run build
        fi
        
        cd ..
        echo -e "${GREEN}✅ Frontend built${NC}"
    else
        echo -e "${YELLOW}⚠ frontend/package.json not found, skipping...${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Skipping frontend build${NC}"
fi
echo ""

# Step 5: Check Docker Compose file
echo -e "${YELLOW}🐳 Step 4: Checking Docker configuration...${NC}"
if [ ! -f "docker-compose.vps.yml" ]; then
    echo -e "${RED}❌ docker-compose.vps.yml not found!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose file found${NC}"
echo ""

# Step 6: Pull Docker images
echo -e "${YELLOW}📥 Step 5: Pulling Docker images...${NC}"
docker compose -f docker-compose.vps.yml pull || docker-compose -f docker-compose.vps.yml pull
echo ""

# Step 7: Deploy
echo -e "${YELLOW}🚀 Step 6: Deploying ALwrity...${NC}"
read -p "Start containers now? (y/n) [y]: " START_CONTAINERS
START_CONTAINERS=${START_CONTAINERS:-y}

if [ "$START_CONTAINERS" = "y" ] || [ "$START_CONTAINERS" = "Y" ]; then
    echo "Starting containers..."
    docker compose -f docker-compose.vps.yml up -d || docker-compose -f docker-compose.vps.yml up -d
    
    echo ""
    echo -e "${GREEN}✅ Containers started${NC}"
    echo ""
    
    # Wait a bit for services to start
    echo "Waiting for services to start..."
    sleep 5
    
    # Check status
    echo ""
    echo -e "${YELLOW}📊 Container Status:${NC}"
    docker compose -f docker-compose.vps.yml ps || docker-compose -f docker-compose.vps.yml ps
    echo ""
    
    # Check health
    echo -e "${YELLOW}🏥 Health Check:${NC}"
    sleep 3
    if curl -f http://localhost:8000/health &> /dev/null; then
        echo -e "${GREEN}✅ Backend is healthy${NC}"
    else
        echo -e "${YELLOW}⚠ Backend health check failed (may still be starting)${NC}"
    fi
    echo ""
else
    echo -e "${YELLOW}⚠ Skipping container start${NC}"
fi

# Step 8: Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}📋 Useful Commands:${NC}"
echo ""
echo "View logs:"
echo -e "   ${BLUE}docker compose -f docker-compose.vps.yml logs -f backend${NC}"
echo ""
echo "Check status:"
echo -e "   ${BLUE}docker compose -f docker-compose.vps.yml ps${NC}"
echo ""
echo "Stop containers:"
echo -e "   ${BLUE}docker compose -f docker-compose.vps.yml down${NC}"
echo ""
echo "Restart containers:"
echo -e "   ${BLUE}docker compose -f docker-compose.vps.yml restart${NC}"
echo ""
echo "Monitor resources:"
echo -e "   ${BLUE}python3 backend/scripts/monitor_resources.py --once${NC}"
echo ""
echo "View container stats:"
echo -e "   ${BLUE}docker stats${NC}"
echo ""
echo -e "${YELLOW}🌐 Access URLs:${NC}"
echo "   Backend API: http://localhost:8000"
echo "   API Docs: http://localhost:8000/api/docs"
echo "   Health: http://localhost:8000/health"
echo ""
if [ -d "frontend/build" ]; then
    echo "   Frontend: http://localhost (via Nginx)"
fi
echo ""
echo -e "${GREEN}✅ ALwrity is ready!${NC}"
echo ""

