# start AzCamTool
import os

# use absolute path here
exe = "c:\\azcam\\azcam-tool\\azcamtool\\builds\\azcamtool.exe"
s = "start %s -s localhost -p 2402" % exe
os.system(s)
