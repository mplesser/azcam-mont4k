# start AzCamTool
import os

import azcam

exe = os.environ.get("AZCAMTOOL")
cmdserver = azcam.db.get("cmdserver")

if cmdserver is None:
    cmdport = 2402
else:
    cmdport = cmdserver.port

if exe is None:
    exe = "c:\\azcam\\azcam-tool\\azcam_tool\\builds\\azcamtool.exe"
s = f"start {exe} -s localhost -p {cmdport}"
os.system(s)
