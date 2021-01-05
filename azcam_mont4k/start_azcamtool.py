# start AzCamTool
import os

import azcam

# use absolute path here
exe = "c:\\azcam\\azcam-tool\\azcam_tool\\builds\\azcamtool.exe"
s = f"start {exe} -s localhost -p {azcam.db.cmdserver.port}"
os.system(s)
