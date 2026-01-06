# ALwrity VPS Deployment Guide (8GB RAM)

Panduan lengkap untuk deploy ALwrity di VPS dengan 8GB RAM.

##  Prerequisites

### System Requirements
- **RAM**: 8GB (minimum 4GB, recommended 8GB)
- **CPU**: 2+ cores (4+ recommended)
- **Storage**: 50GB+ SSD
- **OS**: Ubuntu 20.04+ / Debian 11+ / CentOS 8+

### Software Requirements
- Docker 20.10+ & Docker Compose 2.0+
- Python 3.10+ (jika tidak menggunakan Docker)
- Node.js 18+ (untuk frontend build)
- Git

##  Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/AJaySi/ALwrity.git
cd ALwrity
```

### 2. Check System Requirements
```bash
cd backend
python scripts/check_system_requirements.py
```

### 3. Setup Environment Variables
```bash
# Backend
cp backend/env_template.txt backend/.env
nano backend/.env

# Frontend (jika build sendiri)
cp frontend/env_template.txt frontend/.env
nano frontend/.env
```

### 4. Build Frontend (Production)
```bash
cd frontend
npm install
npm run build
cd ..
```

### 5. Deploy dengan Docker Compose
```bash
# Gunakan konfigurasi VPS yang sudah dioptimasi
docker-compose -f docker-compose.vps.yml up -d

# Check logs
docker-compose -f docker-compose.vps.yml logs -f backend
```

##  Optimasi untuk 8GB RAM

### Resource Limits (Sudah dikonfigurasi di docker-compose.vps.yml)

**Backend:**
- Memory limit: 4GB
- CPU limit: 2 cores
- Memory reservation: 2GB

**Redis:**
- Memory limit: 256MB
- CPU limit: 0.25 cores

**Nginx:**
- Memory limit: 128MB
- CPU limit: 0.25 cores

**Total: ~4.4GB reserved, ~3.6GB untuk OS dan buffer**

### Konfigurasi Production

1. **Single Worker** (sudah dioptimasi)
   - Backend menggunakan 1 worker untuk menghemat memory
   - Konfigurasi ada di `production_optimizer.py`

2. **Disable Heavy Features** (opsional)
   ```bash
   # Di backend/.env
   SKIP_LINGUISTIC_SETUP=false  # Keep enabled (required for persona)
   DISABLE_VIDEO_PROCESSING=false  # Set true jika tidak perlu video
   ```

3. **Database Optimization**
   - Gunakan SQLite untuk development/testing
   - Gunakan PostgreSQL eksternal (managed) untuk production
   - Atau gunakan PostgreSQL container dengan limit memory

4. **Redis Caching**
   - Redis sudah dikonfigurasi dengan maxmemory 256MB
   - LRU eviction policy untuk menghemat memory

##  Monitoring

### 1. Resource Monitoring Script
```bash
# Install psutil jika belum
pip install psutil

# Run monitoring (once)
python backend/scripts/monitor_resources.py --once

# Run continuous monitoring (setiap 60 detik)
python backend/scripts/monitor_resources.py --interval 60
```

### 2. Docker Stats
```bash
# Monitor resource usage container
docker stats

# Monitor specific container
docker stats alwrity-backend
```

### 3. System Monitoring
```bash
# Check memory usage
free -h

# Check disk usage
df -h

# Check CPU usage
top
# atau
htop
```

##  Troubleshooting

### Memory Issues

**Problem: Out of Memory (OOM)**
```bash
# Check memory usage
free -h
docker stats

# Solution:
# 1. Kurangi resource limits di docker-compose.vps.yml
# 2. Disable fitur yang tidak digunakan
# 3. Gunakan external database/Redis
```

**Problem: High Memory Usage**
```bash
# Check processes
ps aux --sort=-%mem | head -10

# Check Python processes
ps aux | grep python

# Solution:
# 1. Restart backend container
docker-compose -f docker-compose.vps.yml restart backend
# 2. Check for memory leaks
python backend/scripts/monitor_resources.py --once
```

### Performance Issues

**Problem: Slow Response**
```bash
# Check CPU usage
top

# Check database connections
docker-compose -f docker-compose.vps.yml exec backend python -c "from services.database import get_db; print('DB OK')"

# Solution:
# 1. Enable Redis caching
# 2. Optimize database queries
# 3. Use connection pooling
```

### Disk Space Issues

**Problem: Disk Full**
```bash
# Check disk usage
df -h
du -sh /var/lib/docker/volumes/*

# Clean up Docker
docker system prune -a
docker volume prune

# Clean logs
find backend/logs -name "*.log" -mtime +7 -delete
```

##  Security Best Practices

1. **Firewall Configuration**
   ```bash
   # Allow only necessary ports
   ufw allow 22/tcp    # SSH
   ufw allow 80/tcp    # HTTP
   ufw allow 443/tcp   # HTTPS
   ufw enable
   ```

2. **SSL/TLS Setup**
   ```bash
   # Install Certbot
   sudo apt install certbot python3-certbot-nginx

   # Generate certificate
   sudo certbot --nginx -d yourdomain.com
   ```

3. **Environment Variables**
   - Jangan commit `.env` files
   - Gunakan secrets management
   - Rotate API keys regularly

##  Scaling Tips

### Untuk Traffic Tinggi

1. **Use External Services**
   - Managed PostgreSQL (AWS RDS, DigitalOcean, dll)
   - Managed Redis (AWS ElastiCache, dll)
   - CDN untuk static files (Cloudflare, dll)

2. **Load Balancing**
   - Deploy multiple backend instances
   - Use Nginx load balancer
   - Consider horizontal scaling

3. **Caching Strategy**
   - Enable Redis caching
   - Cache API responses
   - Use CDN for static assets

### Untuk Memory Optimization

1. **Disable Unused Features**
   ```bash
   # Di backend/.env
   DISABLE_VIDEO_PROCESSING=true  # Jika tidak perlu
   DISABLE_IMAGE_GENERATION=false  # Keep jika perlu
   ```

2. **Optimize Dependencies**
   - Remove unused Python packages
   - Use lighter alternatives jika memungkinkan

3. **Database Optimization**
   - Use connection pooling
   - Optimize queries
   - Regular VACUUM (PostgreSQL)

##  Maintenance

### Daily
- Monitor resource usage
- Check logs for errors
- Verify health endpoints

### Weekly
- Review resource usage trends
- Clean up old logs
- Check disk space

### Monthly
- Update dependencies
- Review security patches
- Optimize database

##  Support

Jika mengalami masalah:

1. Check logs: `docker-compose -f docker-compose.vps.yml logs backend`
2. Run diagnostics: `python backend/scripts/check_system_requirements.py`
3. Monitor resources: `python backend/scripts/monitor_resources.py --once`
4. Check GitHub Issues: https://github.com/AJaySi/ALwrity/issues

##  Additional Resources

- [Installation Guide](docs-site/docs/getting-started/installation.md)
- [Self-Host Setup](docs-site/docs/user-journeys/developers/self-host-setup.md)
- [Performance Optimization](docs-site/docs/user-journeys/developers/performance-optimization.md)

---

**Last Updated**: 2025-01-XX
**Tested on**: Ubuntu 22.04, 8GB RAM VPS

