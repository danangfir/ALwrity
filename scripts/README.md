# ALwrity Setup Scripts

Koleksi script untuk setup dan deployment ALwrity di Ubuntu VPS.

##  Available Scripts

### 1. `ubuntu-setup.sh` - Full System Setup
**Purpose**: Setup lengkap sistem Ubuntu untuk ALwrity (recommended untuk VPS baru)

**Features**:
-  System update & upgrade
-  Install Docker & Docker Compose
-  Install Python 3.10+ & dependencies
-  Configure firewall (UFW)
-  Create ALwrity user (optional)
-  System optimization untuk 8GB RAM
-  Install monitoring tools

**Usage**:
```bash
sudo bash scripts/ubuntu-setup.sh
```

**Time**: ~5-10 menit

---

### 2. `deploy-alwrity.sh` - Deployment Script
**Purpose**: Deploy ALwrity setelah sistem sudah setup

**Features**:
-  Check system requirements
-  Setup environment variables
-  Build frontend (optional)
-  Deploy dengan Docker Compose
-  Health check

**Usage**:
```bash
bash scripts/deploy-alwrity.sh
```

**Prerequisites**: 
- Docker & Docker Compose sudah terinstall
- Repository sudah di-clone

**Time**: ~5-15 menit (tergantung build frontend)

---

### 3. `ubuntu-quick-setup.sh` - Quick Setup
**Purpose**: Setup minimal cepat (Docker + basic tools)

**Features**:
-  Install Docker & Docker Compose
-  Install basic tools
-  Configure firewall

**Usage**:
```bash
sudo bash scripts/ubuntu-quick-setup.sh
```

**Time**: ~2-3 menit

---

## 🚀 Quick Start Workflow

### Untuk VPS Baru:

```bash
# Step 1: Full system setup
sudo bash scripts/ubuntu-setup.sh

# Step 2: Clone repository (jika belum)
cd /opt/alwrity
git clone https://github.com/AJaySi/ALwrity.git .

# Step 3: Deploy ALwrity
bash scripts/deploy-alwrity.sh
```

### Untuk VPS yang Sudah Ada Docker:

```bash
# Langsung deploy
bash scripts/deploy-alwrity.sh
```

---

## 📁 Script Structure

```
scripts/
├── ubuntu-setup.sh          # Full system setup
├── deploy-alwrity.sh        # Deployment script
├── ubuntu-quick-setup.sh    # Quick setup
└── README.md                # This file
```

---

##  Script Details

### ubuntu-setup.sh

**What it does**:
1. Updates system packages
2. Installs Docker & Docker Compose
3. Installs Python 3.10+ & pip
4. Configures UFW firewall
5. Creates ALwrity user (optional)
6. Optimizes system for 8GB RAM
7. Installs monitoring tools

**Output**: System ready for ALwrity deployment

---

### deploy-alwrity.sh

**What it does**:
1. Checks if Docker is installed
2. Checks system requirements
3. Sets up environment variables
4. Optionally builds frontend
5. Deploys with Docker Compose
6. Runs health checks

**Output**: ALwrity running in Docker containers

---

### ubuntu-quick-setup.sh

**What it does**:
1. Updates system
2. Installs Docker & Docker Compose
3. Installs basic tools
4. Configures firewall

**Output**: Minimal setup complete

---

##  Configuration

### Environment Variables

Scripts akan meminta konfigurasi interaktif untuk:
- Create ALwrity user (y/n)
- Edit .env file (y/n)
- Build frontend (y/n)
- Start containers (y/n)

### Customization

Edit scripts untuk customize:
- Installation paths
- User names
- Port numbers
- Resource limits

---

##  Troubleshooting

### Script Fails

```bash
# Check error messages
# Most scripts use 'set -e' (exit on error)

# Run with verbose output
bash -x scripts/ubuntu-setup.sh
```

### Permission Issues

```bash
# Make sure running with sudo for setup scripts
sudo bash scripts/ubuntu-setup.sh

# Check file permissions
ls -la scripts/
chmod +x scripts/*.sh
```

### Docker Issues

```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check Docker group
groups $USER
```

---

##  Notes

1. **Root Access**: Setup scripts require root (use sudo)
2. **Internet**: Scripts need internet connection
3. **Time**: Full setup takes ~10-15 minutes
4. **Backup**: Backup important data before running scripts
5. **Testing**: Test scripts in non-production first

---

##  Security

Scripts include:
-  Firewall configuration (UFW)
-  User creation (non-root)
-  Docker group permissions
-  System optimization

**Important**: 
- Review scripts before running
- Don't run untrusted scripts
- Keep system updated

---

##  Related Documentation

- [Ubuntu Setup Guide](../UBUNTU_SETUP_GUIDE.md)
- [VPS Deployment Guide](../VPS_DEPLOYMENT_GUIDE.md)
- [Platform Comparison](../PLATFORM_COMPARISON.md)

---

##  Checklist

Before running scripts:
- [ ] VPS dengan Ubuntu 20.04+ / 22.04 LTS
- [ ] Root access atau sudo privileges
- [ ] Internet connection
- [ ] At least 8GB RAM
- [ ] At least 50GB disk space

After running scripts:
- [ ] Docker installed and running
- [ ] Docker Compose available
- [ ] Firewall configured
- [ ] ALwrity containers running
- [ ] Health check passing

---

**Last Updated**: 2025-01-XX

