"""
AzCamMonitor process start file
"""

import subprocess

OPTIONS = "parameters_monitor_mont4k.ini"

# CMD = f"python -m azcam.monitor -- -configfile {OPTIONS}"
CMD = f"azcammonitor -configfile {OPTIONS}"

p = subprocess.Popen(
    CMD,
    creationflags=subprocess.CREATE_NEW_CONSOLE,
)
