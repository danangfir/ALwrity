# Instruksi Fix Yarn Install - Network Timeout

## 🔧 Solusi Cepat (Manual)

Jalankan perintah berikut di terminal (dari folder `frontend`):

### Step 1: Konfigurasi Yarn

```bash
# Set network timeout ke 10 menit (600000ms)
yarn config set network-timeout 600000

# Set network concurrency ke 1 (lebih stabil untuk slow connection)
yarn config set network-concurrency 1

# Disable progress bar (lebih cepat)
yarn config set enableProgress false
```

### Step 2: Opsional - Gunakan Mirror (jika koneksi lambat)

```bash
# Gunakan npm mirror (lebih cepat untuk Asia)
yarn config set registry https://registry.npmmirror.com

# Atau tetap pakai default
yarn config set registry https://registry.yarnpkg.com
```

### Step 3: Clean dan Install

```bash
# Hapus node_modules dan lock files
rm -rf node_modules yarn.lock package-lock.json

# Install dengan yarn
yarn install
```

## 🚀 Quick Fix (Gunakan Script)

### Windows (PowerShell):
```powershell
cd frontend
.\fix-yarn-install.ps1
```

### Linux/Mac:
```bash
cd frontend
chmod +x fix-yarn-install.sh
./fix-yarn-install.sh
```

## 📋 Perintah Lengkap (Copy-Paste)

### Untuk Windows (Git Bash / PowerShell):

```bash
cd ALwrity/frontend

# Konfigurasi yarn
yarn config set network-timeout 600000
yarn config set network-concurrency 1
yarn config set enableProgress false

# Clean
rm -rf node_modules yarn.lock package-lock.json

# Install
yarn install
```

### Jika Masih Timeout, Gunakan Mirror:

```bash
cd ALwrity/frontend

# Set mirror
yarn config set registry https://registry.npmmirror.com
yarn config set network-timeout 1200000  # 20 menit

# Clean
rm -rf node_modules yarn.lock package-lock.json

# Install
yarn install
```

## ⚙️ Konfigurasi Yarn yang Disarankan

Setelah install berhasil, simpan konfigurasi ini:

```bash
# Timeout lebih lama
yarn config set network-timeout 600000

# Concurrency rendah (stabil untuk slow connection)
yarn config set network-concurrency 1

# Disable progress (lebih cepat)
yarn config set enableProgress false

# Check konfigurasi
yarn config list
```

## 🔍 Troubleshooting

### Jika masih timeout:

1. **Tingkatkan timeout lebih lama:**
   ```bash
   yarn config set network-timeout 1200000  # 20 menit
   ```

2. **Gunakan mirror:**
   ```bash
   yarn config set registry https://registry.npmmirror.com
   ```

3. **Install per package (jika masih gagal):**
   ```bash
   # Install core dulu
   yarn add react react-dom react-scripts
   
   # Install MUI
   yarn add @mui/material @mui/icons-material @emotion/react @emotion/styled
   
   # Install sisanya
   yarn install
   ```

4. **Check koneksi:**
   ```bash
   # Test koneksi ke registry
   curl -I https://registry.yarnpkg.com
   ping registry.yarnpkg.com
   ```

## ✅ Verifikasi

Setelah install berhasil:

```bash
# Check yarn version
yarn --version

# Check installed packages
yarn list --depth=0

# Test build
yarn build
```

## 📝 Catatan

- **Warnings tentang deprecated packages** adalah normal dan bisa diabaikan
- **Network timeout** biasanya karena koneksi lambat atau tidak stabil
- **Gunakan mirror** jika koneksi ke registry utama lambat
- **Timeout 10 menit** biasanya cukup untuk install semua dependencies

