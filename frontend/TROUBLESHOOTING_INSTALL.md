# Troubleshooting: Frontend Installation Issues

## Problem: Network Timeout saat `yarn install`

Error yang terjadi:
```
error Error: https://registry.yarnpkg.com/@mui/icons-material/-/icons-material-5.18.0.tgz: ESOCKETTIMEDOUT
```

Ini adalah masalah **network timeout** saat download package dari npm registry.

## 🔧 Solusi

### Solusi 1: Gunakan npm dengan timeout lebih lama (Recommended)

```bash
# Hapus node_modules dan lock files
rm -rf node_modules package-lock.json yarn.lock

# Install dengan npm (lebih stabil untuk network issues)
npm install --legacy-peer-deps --timeout=60000

# Atau dengan registry yang lebih cepat
npm install --legacy-peer-deps --timeout=60000 --registry=https://registry.npmmirror.com
```

### Solusi 2: Konfigurasi Yarn dengan timeout lebih lama (RECOMMENDED untuk Yarn)

```bash
# Set yarn timeout (10 menit = 600000ms)
yarn config set network-timeout 600000

# Set network concurrency ke 1 (lebih stabil untuk slow connection)
yarn config set network-concurrency 1

# Disable progress bar (lebih cepat)
yarn config set enableProgress false

# Atau gunakan registry mirror yang lebih cepat (opsional)
yarn config set registry https://registry.npmmirror.com

# Lalu install
yarn install
```

**Quick fix script untuk Yarn:**
```bash
# Windows PowerShell
.\fix-yarn-install.ps1

# Linux/Mac
./fix-yarn-install.sh
```

### Solusi 3: Install per package (jika masih timeout)

```bash
# Install core dependencies dulu
npm install react react-dom react-scripts --legacy-peer-deps

# Install MUI packages
npm install @mui/material @mui/icons-material @emotion/react @emotion/styled --legacy-peer-deps

# Install dependencies lainnya
npm install --legacy-peer-deps
```

### Solusi 4: Gunakan npm registry mirror (China/Asia)

```bash
# Set registry ke mirror (lebih cepat untuk Asia)
npm config set registry https://registry.npmmirror.com

# Atau untuk yarn
yarn config set registry https://registry.npmmirror.com

# Install
npm install --legacy-peer-deps
```

### Solusi 5: Install dengan retry otomatis

```bash
# Install dengan retry (menggunakan npm)
npm install --legacy-peer-deps --maxsockets=1 --fetch-retries=5 --fetch-retry-mintimeout=20000
```

## 🌐 Registry Mirrors

Jika koneksi ke registry utama lambat, gunakan mirror:

### npm Registry Mirrors:
- **China**: `https://registry.npmmirror.com`
- **Taobao**: `https://registry.npm.taobao.org` (deprecated, use npmmirror)
- **Europe**: `https://registry.npmjs.eu`
- **Default**: `https://registry.npmjs.org`

### Yarn Registry Mirrors:
```bash
# China mirror
yarn config set registry https://registry.npmmirror.com

# Reset ke default
yarn config set registry https://registry.yarnpkg.com
```

## 🔍 Diagnostik

### Check network connectivity
```bash
# Test koneksi ke npm registry
curl -I https://registry.npmjs.org
ping registry.npmjs.org

# Check DNS
nslookup registry.npmjs.org
```

### Check proxy settings
```bash
# Check npm proxy
npm config get proxy
npm config get https-proxy

# Jika ada proxy, set dengan benar
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080

# Atau disable proxy
npm config delete proxy
npm config delete https-proxy
```

### Check yarn configuration
```bash
# View yarn config
yarn config list

# Check registry
yarn config get registry

# Check timeout
yarn config get network-timeout
```

## ✅ Quick Fix Script

Buat file `fix-install.sh`:

```bash
#!/bin/bash
echo "🔧 Fixing frontend installation..."

# Remove old files
echo "Cleaning up..."
rm -rf node_modules package-lock.json yarn.lock

# Set npm registry (optional - uncomment if needed)
# npm config set registry https://registry.npmmirror.com

# Install with extended timeout
echo "Installing dependencies..."
npm install --legacy-peer-deps --timeout=60000 --maxsockets=1

echo "✅ Done!"
```

Atau untuk Windows (PowerShell), buat `fix-install.ps1`:

```powershell
Write-Host "🔧 Fixing frontend installation..." -ForegroundColor Cyan

# Remove old files
Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue
Remove-Item -Force package-lock.json -ErrorAction SilentlyContinue
Remove-Item -Force yarn.lock -ErrorAction SilentlyContinue

# Install with extended timeout
Write-Host "Installing dependencies..." -ForegroundColor Yellow
npm install --legacy-peer-deps --timeout=60000 --maxsockets=1

Write-Host "✅ Done!" -ForegroundColor Green
```

## 🚀 Recommended Approach untuk VPS

Untuk deployment di VPS, gunakan:

```bash
# 1. Set registry ke mirror yang lebih cepat (opsional)
npm config set registry https://registry.npmmirror.com

# 2. Install dengan timeout lebih lama
npm install --legacy-peer-deps --timeout=120000

# 3. Build production
npm run build
```

## 📝 Notes

1. **Warnings tentang deprecated packages** adalah normal untuk `react-scripts@5.0.1`
   - Ini tidak mempengaruhi functionality
   - Bisa diabaikan untuk sekarang

2. **Network timeout** biasanya disebabkan oleh:
   - Koneksi internet lambat/tidak stabil
   - Firewall/proxy blocking
   - DNS issues
   - npm registry overload

3. **Gunakan `--legacy-peer-deps`** karena beberapa package mungkin memiliki peer dependency conflicts

4. **Untuk production build**, pastikan semua dependencies terinstall dengan benar sebelum build

## 🆘 Jika Masih Gagal

1. **Check internet connection**
   ```bash
   ping google.com
   curl -I https://registry.npmjs.org
   ```

2. **Try different network** (mobile hotspot, different WiFi)

3. **Use VPN** jika ada blocking

4. **Install offline** dengan cara:
   - Download packages di network yang lebih baik
   - Copy `node_modules` dan `package-lock.json`
   - Install di VPS

5. **Contact support** dengan error log lengkap

