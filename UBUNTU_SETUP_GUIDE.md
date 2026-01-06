# Ubuntu Setup Guide untuk ALwrity

Panduan lengkap setup ALwrity di Ubuntu VPS 8GB RAM.

##  Quick Start (One Command)

```bash
# Download dan jalankan setup script
curl -fsSL https://raw.githubusercontent.com/AJaySi/ALwrity/main/scripts/ubuntu-setup.sh | sudo bash

# Atau clone repository dulu
git clone https://github.com/AJaySi/ALwrity.git
cd ALwrity
sudo bash scripts/ubuntu-setup.sh
```

##  Manual Setup (Step by Step)

### Step 1: Update System

```bash
sudo apt update
sudo apt upgrade -y
```

### Step 2: Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (optional)
sudo usermod -aG docker $USER
# Logout dan login lagi untuk apply
```

### Step 3: Install Docker Compose

```bash
sudo apt install -y docker-compose-plugin
```

### Step 4: Install Python & Tools

```bash
sudo apt install -y \
    python3 \
    python3-pip \
    git \
    curl \
    wget \
    htop \
    vim \
    nano
```

### Step 5: Configure Firewall

```bash
# Allow SSH (important!)
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
```

### Step 6: Clone ALwrity

```bash
# Create directory
sudo mkdir -p /opt/alwrity
cd /opt/alwrity

# Clone repository
sudo git clone https://github.com/AJaySi/ALwrity.git .

# Set permissions
sudo chown -R $USER:$USER /opt/alwrity
```

### Step 7: Configure Environment

```bash
cd /opt/alwrity/backend
cp env_template.txt .env
nano .env  # Edit dan tambahkan API keys
```

### Step 8: Build Frontend (Optional)

```bash
cd /opt/alwrity/frontend
npm install  # atau yarn install
npm run build  # atau yarn build
```

### Step 9: Deploy

```bash
cd /opt/alwrity
docker-compose -f docker-compose.vps.yml up -d
```

### Step 10: Verify

```bash
# Check containers
docker-compose -f docker-compose.vps.yml ps

# Check logs
docker-compose -f docker-compose.vps.yml logs -f backend

# Health check
curl http://localhost:8000/health
```

## Setup Scripts

### 1. Full Setup Script

```bash
sudo bash scripts/ubuntu-setup.sh
```

**Fitur:**
- System update
- Install Docker & Docker Compose
- Install Python & dependencies
- Configure firewall
- Create ALwrity user
- System optimization
- Install monitoring tools

### 2. Deployment Script

```bash
bash scripts/deploy-alwrity.sh
```

**Fitur:**
- Check system requirements
- Setup environment variables
- Build frontend (optional)
- Deploy with Docker
- Health check

### 3. Quick Setup

```bash
sudo bash scripts/ubuntu-quick-setup.sh
```

**Fitur:**
- Minimal setup (Docker + basic tools)
- Fast installation

##  System Requirements Check

```bash
cd /opt/alwrity/backend
python3 scripts/check_system_requirements.py
```

##  Monitoring

### Resource Monitoring

```bash
# Run once
python3 backend/scripts/monitor_resources.py --once

# Continuous monitoring
python3 backend/scripts/monitor_resources.py --interval 60
```

### Docker Stats

```bash
docker stats
```

### System Monitoring

```bash
# CPU & Memory
htop

# Disk usage
df -h
du -sh /opt/alwrity/*

# Network
iftop
nethogs
```

##  Security Best Practices

### 1. Firewall Configuration

```bash
# Check status
sudo ufw status

# Allow specific IP for SSH (recommended)
sudo ufw delete allow 22/tcp
sudo ufw allow from YOUR_IP to any port 22
```

### 2. SSH Hardening

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Recommended settings:
# PermitRootLogin no
# PasswordAuthentication no  # Use keys only
# Port 2222  # Change default port

# Restart SSH
sudo systemctl restart sshd
```

### 3. Regular Updates

```bash
# Setup automatic updates
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 4. SSL/TLS Setup

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Generate certificate
sudo certbot --nginx -d yourdomain.com
```

##  Troubleshooting

### Docker Issues

```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check Docker logs
sudo journalctl -u docker
```

### Container Issues

```bash
# View logs
docker-compose -f docker-compose.vps.yml logs backend

# Restart container
docker-compose -f docker-compose.vps.yml restart backend

# Rebuild containers
docker-compose -f docker-compose.vps.yml up -d --build
```

### Memory Issues

```bash
# Check memory usage
free -h
docker stats

# If out of memory, reduce limits in docker-compose.vps.yml
```

### Network Issues

```bash
# Check ports
sudo netstat -tulpn | grep LISTEN

# Check firewall
sudo ufw status

# Test connectivity
curl -I http://localhost:8000/health
```

##  Maintenance

### Daily

```bash
# Check container status
docker-compose -f docker-compose.vps.yml ps

# Check logs
docker-compose -f docker-compose.vps.yml logs --tail=50 backend
```

### Weekly

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Clean Docker
docker system prune -f

# Check disk space
df -h
du -sh /opt/alwrity/*
```

### Monthly

```bash
# Update ALwrity
cd /opt/alwrity
git pull
docker-compose -f docker-compose.vps.yml up -d --build

# Review logs
docker-compose -f docker-compose.vps.yml logs --since 30d > monthly-logs.txt
```

##  Next Steps

1.  Setup SSL/TLS dengan Let's Encrypt
2.  Configure domain name
3.  Setup monitoring (Prometheus, Grafana)
4.  Setup backups
5.  Configure log rotation

##  Additional Resources

- [VPS Deployment Guide](VPS_DEPLOYMENT_GUIDE.md)
- [Platform Comparison](PLATFORM_COMPARISON.md)
- [VPS 8GB Setup Summary](VPS_8GB_SETUP_SUMMARY.md)

---

**Last Updated**: 2025-01-XX  
**Tested on**: Ubuntu 22.04 LTS, 8GB RAM VPS

