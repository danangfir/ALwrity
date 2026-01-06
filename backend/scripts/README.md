# ALwrity Backend Scripts

Koleksi script utilitas untuk deployment dan maintenance ALwrity.

##  Available Scripts

### 1. `check_system_requirements.py`
**Purpose**: Check jika sistem memenuhi requirements minimum untuk ALwrity.

**Usage**:
```bash
# Run check
python scripts/check_system_requirements.py

# Output akan menunjukkan:
# - Python version
# - RAM availability
# - Disk space
# - CPU cores
# - Dependencies status
# - Directory structure
```

**Exit Codes**:
- `0`: All requirements met
- `1`: Some requirements not met

### 2. `monitor_resources.py`
**Purpose**: Monitor resource usage (memory, CPU, disk) secara real-time.

**Usage**:
```bash
# Run once and exit
python scripts/monitor_resources.py --once

# Continuous monitoring (default: 60s interval)
python scripts/monitor_resources.py --interval 60

# Custom memory threshold (default: 6144MB = 6GB)
python scripts/monitor_resources.py --threshold 6144
```

**Output**:
- Memory usage (total, used, available, swap)
- CPU usage and cores
- Disk usage
- Python processes (ALwrity related)
- Alerts jika resource usage tinggi

**Logs**: Disimpan di `logs/resource_monitor.log`

##  Installation

Scripts ini memerlukan dependency tambahan:
```bash
pip install psutil
```

Atau install semua requirements:
```bash
pip install -r requirements.txt
```

##  Example Usage

### Pre-deployment Check
```bash
# 1. Check system requirements
python scripts/check_system_requirements.py

# 2. If OK, proceed with deployment
# 3. After deployment, monitor resources
python scripts/monitor_resources.py --interval 300  # Every 5 minutes
```

### Troubleshooting
```bash
# Check current resource usage
python scripts/monitor_resources.py --once

# Check system requirements
python scripts/check_system_requirements.py

# Check logs
tail -f logs/resource_monitor.log
```

##  Integration dengan Systemd

Anda bisa membuat systemd service untuk monitoring:

```ini
[Unit]
Description=ALwrity Resource Monitor
After=network.target

[Service]
Type=simple
User=alwrity
WorkingDirectory=/path/to/ALwrity/backend
ExecStart=/usr/bin/python3 scripts/monitor_resources.py --interval 300
Restart=always

[Install]
WantedBy=multi-user.target
```

##  Notes

- Scripts ini dirancang untuk VPS dengan 8GB RAM
- Memory threshold default: 6GB (75% dari 8GB)
- Monitoring interval recommended: 60-300 detik
- Logs dirotasi secara manual (pertimbangkan logrotate)

