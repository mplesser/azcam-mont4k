"""
Python process start file
"""

import subprocess

OPTIONS = ""
CMD = f"ipython --profile azcamserver -i -m azcam_mont4k.console -- {OPTIONS}"

p = subprocess.Popen(
    CMD,
    creationflags=subprocess.CREATE_NEW_CONSOLE,
)
