"""
Python process start file
"""

import subprocess

CMD = "ipython --profile azcamserver -i -m azcam_mont4k.server -- -system CSS"

p = subprocess.Popen(
    CMD,
    creationflags=subprocess.CREATE_NEW_CONSOLE,
)
