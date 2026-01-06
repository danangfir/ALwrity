#!/usr/bin/env python3
"""
System Requirements Checker for ALwrity
Checks if the system meets minimum requirements for deployment.
"""

import sys
import platform
import subprocess
from pathlib import Path
from typing import Dict, List, Tuple


class SystemRequirementsChecker:
    """Check system requirements for ALwrity."""
    
    def __init__(self):
        self.requirements = {
            "python": {"min_version": (3, 10), "recommended": (3, 11)},
            "ram_mb": {"min": 4096, "recommended": 8192},
            "disk_gb": {"min": 20, "recommended": 50},
            "cpu_cores": {"min": 2, "recommended": 4}
        }
        self.issues = []
        self.warnings = []
    
    def check_python_version(self) -> Tuple[bool, str]:
        """Check Python version."""
        version = sys.version_info[:2]
        min_version = self.requirements["python"]["min_version"]
        recommended = self.requirements["python"]["recommended"]
        
        if version < min_version:
            return False, f"Python {version[0]}.{version[1]} is below minimum {min_version[0]}.{min_version[1]}"
        elif version < recommended:
            self.warnings.append(f"Python {version[0]}.{version[1]} is below recommended {recommended[0]}.{recommended[1]}")
            return True, f"Python {version[0]}.{version[1]} (recommended: {recommended[0]}.{recommended[1]}+)"
        else:
            return True, f"Python {version[0]}.{version[1]} ✓"
    
    def check_ram(self) -> Tuple[bool, str]:
        """Check available RAM."""
        try:
            import psutil
            mem = psutil.virtual_memory()
            total_mb = mem.total / (1024 * 1024)
            min_ram = self.requirements["ram_mb"]["min"]
            recommended_ram = self.requirements["ram_mb"]["recommended"]
            
            if total_mb < min_ram:
                return False, f"RAM {total_mb:.0f}MB is below minimum {min_ram}MB"
            elif total_mb < recommended_ram:
                self.warnings.append(f"RAM {total_mb:.0f}MB is below recommended {recommended_ram}MB")
                return True, f"RAM {total_mb:.0f}MB (recommended: {recommended_ram}MB+)"
            else:
                return True, f"RAM {total_mb:.0f}MB ✓"
        except ImportError:
            return None, "psutil not available - cannot check RAM"
    
    def check_disk(self) -> Tuple[bool, str]:
        """Check available disk space."""
        try:
            import psutil
            disk = psutil.disk_usage('/')
            free_gb = disk.free / (1024 * 1024 * 1024)
            min_disk = self.requirements["disk_gb"]["min"]
            recommended_disk = self.requirements["disk_gb"]["recommended"]
            
            if free_gb < min_disk:
                return False, f"Disk space {free_gb:.1f}GB is below minimum {min_disk}GB"
            elif free_gb < recommended_disk:
                self.warnings.append(f"Disk space {free_gb:.1f}GB is below recommended {recommended_disk}GB")
                return True, f"Disk space {free_gb:.1f}GB free (recommended: {recommended_disk}GB+)"
            else:
                return True, f"Disk space {free_gb:.1f}GB free ✓"
        except ImportError:
            return None, "psutil not available - cannot check disk"
    
    def check_cpu(self) -> Tuple[bool, str]:
        """Check CPU cores."""
        try:
            import psutil
            cores = psutil.cpu_count()
            min_cores = self.requirements["cpu_cores"]["min"]
            recommended_cores = self.requirements["cpu_cores"]["recommended"]
            
            if cores < min_cores:
                return False, f"CPU cores {cores} is below minimum {min_cores}"
            elif cores < recommended_cores:
                self.warnings.append(f"CPU cores {cores} is below recommended {recommended_cores}")
                return True, f"CPU cores {cores} (recommended: {recommended_cores}+)"
            else:
                return True, f"CPU cores {cores} ✓"
        except ImportError:
            return None, "psutil not available - cannot check CPU"
    
    def check_dependencies(self) -> List[Tuple[str, bool, str]]:
        """Check critical Python dependencies."""
        critical_deps = [
            "fastapi",
            "uvicorn",
            "sqlalchemy",
            "pydantic",
            "python-dotenv"
        ]
        
        results = []
        for dep in critical_deps:
            try:
                __import__(dep.replace("-", "_"))
                results.append((dep, True, "installed"))
            except ImportError:
                results.append((dep, False, "missing"))
        
        return results
    
    def check_directories(self) -> List[Tuple[str, bool, str]]:
        """Check required directories."""
        required_dirs = [
            ("backend", Path("backend").exists()),
            ("backend/api", Path("backend/api").exists()),
            ("backend/services", Path("backend/services").exists()),
        ]
        
        results = []
        for name, exists in required_dirs:
            if exists:
                results.append((name, True, "exists"))
            else:
                results.append((name, False, "missing"))
        
        return results
    
    def run_all_checks(self) -> Dict:
        """Run all system checks."""
        print("🔍 Checking System Requirements for ALwrity...")
        print("=" * 60)
        
        results = {
            "python": self.check_python_version(),
            "ram": self.check_ram(),
            "disk": self.check_disk(),
            "cpu": self.check_cpu(),
            "dependencies": self.check_dependencies(),
            "directories": self.check_directories(),
            "platform": platform.system(),
            "platform_version": platform.version()
        }
        
        # Print results
        print("\n📋 System Information:")
        print(f"   Platform: {results['platform']} {results['platform_version']}")
        print()
        
        print("✅ Requirements Check:")
        print(f"   Python:  {results['python'][1]}")
        if results['ram'][0] is not None:
            print(f"   RAM:     {results['ram'][1]}")
        if results['disk'][0] is not None:
            print(f"   Disk:    {results['disk'][1]}")
        if results['cpu'][0] is not None:
            print(f"   CPU:     {results['cpu'][1]}")
        print()
        
        print("📦 Dependencies:")
        for dep, ok, status in results['dependencies']:
            icon = "✅" if ok else "❌"
            print(f"   {icon} {dep}: {status}")
        print()
        
        print("📁 Directories:")
        for name, ok, status in results['directories']:
            icon = "✅" if ok else "❌"
            print(f"   {icon} {name}: {status}")
        print()
        
        # Check for issues
        all_ok = True
        for key, (ok, msg) in results.items():
            if key in ['python', 'ram', 'disk', 'cpu'] and ok is False:
                self.issues.append(f"{key.upper()}: {msg}")
                all_ok = False
        
        for dep, ok, _ in results['dependencies']:
            if not ok:
                self.issues.append(f"Missing dependency: {dep}")
                all_ok = False
        
        # Print summary
        print("=" * 60)
        if self.issues:
            print("❌ Issues Found:")
            for issue in self.issues:
                print(f"   • {issue}")
            print()
        
        if self.warnings:
            print("⚠️  Warnings:")
            for warning in self.warnings:
                print(f"   • {warning}")
            print()
        
        if all_ok and not self.warnings:
            print("✅ All requirements met! System is ready for ALwrity deployment.")
        elif all_ok:
            print("✅ Minimum requirements met, but some recommendations not met.")
        else:
            print("❌ Some requirements are not met. Please address the issues above.")
        
        print("=" * 60)
        
        return results


def main():
    """Main function."""
    checker = SystemRequirementsChecker()
    results = checker.run_all_checks()
    
    # Exit with error code if issues found
    if checker.issues:
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()

