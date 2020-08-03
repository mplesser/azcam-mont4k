import os

# relative path
folder = os.path.normpath((os.path.dirname(__file__)))

exe = f"{folder}\\builds\\azcamtool.exe"
s = "start %s -s localhost -p 2402" % exe
os.system(s)
