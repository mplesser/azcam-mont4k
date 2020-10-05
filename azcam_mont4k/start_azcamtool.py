# start AzCamTool
import os

import azcam

# use absolute path here
exe = "c:\\azcam\\azcamtool\\azcamtool\\builds\\azcamtool.exe"
s = f"start {exe} -s localhost -p {azcam.api.cmdserver.port}"
os.system(s)
