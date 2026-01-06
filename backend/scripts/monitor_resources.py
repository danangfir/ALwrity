#!/usr/bin/env python3
"""
Resource Monitoring Script for ALwrity
Monitors memory, CPU, and disk usage for VPS deployment.
"""

import psutil
import time
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, Any


class ResourceMonitor:
    """Monitor system resources for ALwrity deployment."""
    
    def __init__(self, alert_threshold_mb: int = 6144):  # 6GB threshold (75% of 8GB)
        self.alert_threshold_mb = alert_threshold_mb
        self.log_file = Path("logs/resource_monitor.log")
        self.log_file.parent.mkdir(exist_ok=True)
    
    def get_memory_info(self) -> Dict[str, Any]:
        """Get current memory usage information."""
        mem = psutil.virtual_memory()
        swap = psutil.swap_memory()
        
        return {
            "total_mb": round(mem.total / (1024 * 1024), 2),
            "available_mb": round(mem.available / (1024 * 1024), 2),
            "used_mb": round(mem.used / (1024 * 1024), 2),
            "percent": mem.percent,
            "swap_total_mb": round(swap.total / (1024 * 1024), 2),
            "swap_used_mb": round(swap.used / (1024 * 1024), 2),
            "swap_percent": swap.percent
        }
    
    def get_cpu_info(self) -> Dict[str, Any]:
        """Get current CPU usage information."""
        cpu_percent = psutil.cpu_percent(interval=1)
        cpu_count = psutil.cpu_count()
        cpu_freq = psutil.cpu_freq()
        
        return {
            "percent": cpu_percent,
            "count": cpu_count,
            "frequency_mhz": round(cpu_freq.current, 2) if cpu_freq else None
        }
    
    def get_disk_info(self) -> Dict[str, Any]:
        """Get current disk usage information."""
        disk = psutil.disk_usage('/')
        
        return {
            "total_gb": round(disk.total / (1024 * 1024 * 1024), 2),
            "used_gb": round(disk.used / (1024 * 1024 * 1024), 2),
            "free_gb": round(disk.free / (1024 * 1024 * 1024), 2),
            "percent": disk.percent
        }
    
    def get_process_info(self) -> Dict[str, Any]:
        """Get information about Python processes (likely ALwrity)."""
        python_processes = []
        total_memory = 0
        
        for proc in psutil.process_iter(['pid', 'name', 'memory_info', 'cpu_percent']):
            try:
                if 'python' in proc.info['name'].lower():
                    mem_mb = proc.info['memory_info'].rss / (1024 * 1024)
                    total_memory += mem_mb
                    python_processes.append({
                        "pid": proc.info['pid'],
                        "name": proc.info['name'],
                        "memory_mb": round(mem_mb, 2),
                        "cpu_percent": proc.info['cpu_percent']
                    })
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
        
        return {
            "count": len(python_processes),
            "total_memory_mb": round(total_memory, 2),
            "processes": python_processes[:10]  # Top 10
        }
    
    def check_alerts(self, memory_info: Dict[str, Any]) -> list:
        """Check for resource alerts."""
        alerts = []
        
        # Memory alert
        if memory_info['used_mb'] > self.alert_threshold_mb:
            alerts.append({
                "type": "memory",
                "severity": "warning",
                "message": f"Memory usage high: {memory_info['used_mb']:.2f}MB / {memory_info['total_mb']:.2f}MB ({memory_info['percent']:.1f}%)"
            })
        
        if memory_info['percent'] > 90:
            alerts.append({
                "type": "memory",
                "severity": "critical",
                "message": f"Critical memory usage: {memory_info['percent']:.1f}%"
            })
        
        return alerts
    
    def get_full_report(self) -> Dict[str, Any]:
        """Get a full resource report."""
        memory = self.get_memory_info()
        cpu = self.get_cpu_info()
        disk = self.get_disk_info()
        processes = self.get_process_info()
        alerts = self.check_alerts(memory)
        
        return {
            "timestamp": datetime.now().isoformat(),
            "memory": memory,
            "cpu": cpu,
            "disk": disk,
            "processes": processes,
            "alerts": alerts,
            "status": "critical" if any(a['severity'] == 'critical' for a in alerts) else 
                     "warning" if alerts else "ok"
        }
    
    def print_report(self, report: Dict[str, Any] = None):
        """Print a formatted resource report."""
        if report is None:
            report = self.get_full_report()
        
        print("\n" + "=" * 60)
        print("📊 ALwrity Resource Monitor")
        print("=" * 60)
        print(f"Timestamp: {report['timestamp']}")
        print(f"Status: {report['status'].upper()}")
        print()
        
        # Memory
        mem = report['memory']
        print("💾 Memory:")
        print(f"   Total:     {mem['total_mb']:.2f} MB")
        print(f"   Used:      {mem['used_mb']:.2f} MB ({mem['percent']:.1f}%)")
        print(f"   Available: {mem['available_mb']:.2f} MB")
        if mem['swap_total_mb'] > 0:
            print(f"   Swap:      {mem['swap_used_mb']:.2f} MB / {mem['swap_total_mb']:.2f} MB ({mem['swap_percent']:.1f}%)")
        print()
        
        # CPU
        cpu = report['cpu']
        print("⚡ CPU:")
        print(f"   Usage:     {cpu['percent']:.1f}%")
        print(f"   Cores:     {cpu['count']}")
        if cpu['frequency_mhz']:
            print(f"   Frequency: {cpu['frequency_mhz']:.2f} MHz")
        print()
        
        # Disk
        disk = report['disk']
        print("💿 Disk:")
        print(f"   Total:     {disk['total_gb']:.2f} GB")
        print(f"   Used:      {disk['used_gb']:.2f} GB ({disk['percent']:.1f}%)")
        print(f"   Free:      {disk['free_gb']:.2f} GB")
        print()
        
        # Processes
        proc = report['processes']
        print(f"🐍 Python Processes: {proc['count']}")
        print(f"   Total Memory: {proc['total_memory_mb']:.2f} MB")
        if proc['processes']:
            print("   Top processes:")
            for p in proc['processes'][:5]:
                print(f"      PID {p['pid']}: {p['memory_mb']:.2f} MB ({p['cpu_percent']:.1f}% CPU)")
        print()
        
        # Alerts
        if report['alerts']:
            print("⚠️  Alerts:")
            for alert in report['alerts']:
                severity_icon = "🔴" if alert['severity'] == 'critical' else "🟡"
                print(f"   {severity_icon} {alert['message']}")
        else:
            print("✅ No alerts")
        
        print("=" * 60)
    
    def log_report(self, report: Dict[str, Any]):
        """Log report to file."""
        try:
            with open(self.log_file, 'a') as f:
                f.write(json.dumps(report) + '\n')
        except Exception as e:
            print(f"Warning: Could not write to log file: {e}")
    
    def monitor_loop(self, interval: int = 60, max_iterations: int = None):
        """Run continuous monitoring loop."""
        print(f"Starting resource monitoring (interval: {interval}s)")
        print(f"Log file: {self.log_file}")
        print("Press Ctrl+C to stop\n")
        
        iteration = 0
        try:
            while True:
                report = self.get_full_report()
                self.print_report(report)
                self.log_report(report)
                
                iteration += 1
                if max_iterations and iteration >= max_iterations:
                    break
                
                time.sleep(interval)
        except KeyboardInterrupt:
            print("\n\nMonitoring stopped by user")


def main():
    """Main function."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Monitor ALwrity resource usage")
    parser.add_argument("--interval", type=int, default=60, help="Monitoring interval in seconds (default: 60)")
    parser.add_argument("--once", action="store_true", help="Run once and exit")
    parser.add_argument("--threshold", type=int, default=6144, help="Memory alert threshold in MB (default: 6144 = 6GB)")
    
    args = parser.parse_args()
    
    monitor = ResourceMonitor(alert_threshold_mb=args.threshold)
    
    if args.once:
        report = monitor.get_full_report()
        monitor.print_report(report)
        monitor.log_report(report)
    else:
        monitor.monitor_loop(interval=args.interval)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nExiting...")
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

