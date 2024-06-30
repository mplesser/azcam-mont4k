"""
ExposureStaus start file
"""

import subprocess

OPTIONS = "-port 2402"
CMD = f"pythonw -m azcam_expstatus.expstatus -- {OPTIONS}"

p = subprocess.Popen(
    CMD,
    creationflags=subprocess.CREATE_NEW_CONSOLE,
)

# PowerShell -WindowStyle Hidden "python -m azcam_expstatus.expstatus - -port 2402"
