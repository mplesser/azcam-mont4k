# azcamconsole config file for mont4k

import os
import sys
import threading

import azcam
import azcam_console
import azcam_console.shortcuts
from azcam.tools.ds9display import Ds9Display
from azcam_console.tools.focus import Focus
from azcam_server.tools.observe import Observe

try:
    i = sys.argv.index("-datafolder")
    datafolder = sys.argv[i + 1]
except ValueError:
    datafolder = None
try:
    i = sys.argv.index("-lab")
    lab = 1
except ValueError:
    lab = 0

# ****************************************************************
# files and folders
# ****************************************************************
azcam.db.systemname = "mont4k"

azcam.db.systemfolder = f"{os.path.dirname(__file__)}"

if datafolder is None:
    droot = os.environ.get("AZCAM_DATAROOT")
    if droot is None:
        droot = "/data"
    azcam.db.datafolder = os.path.join(droot, azcam.db.systemname)
else:
    azcam.db.datafolder = datafolder
azcam.db.datafolder = azcam.utils.fix_path(azcam.db.datafolder)

parfile = os.path.join(
    azcam.db.datafolder, "parameters", f"parameters_console_{azcam.db.systemname}.ini"
)

# ****************************************************************
# start logging
# ****************************************************************
logfile = os.path.join(azcam.db.datafolder, "logs", "console.log")
azcam.db.logger.start_logging(logfile=logfile)
azcam.log(f"Configuring console for {azcam.db.systemname}")

# ****************************************************************
# display
# ****************************************************************
display = Ds9Display()
dthread = threading.Thread(target=display.initialize, args=[])
dthread.start()  # thread just for speed

# ****************************************************************
# console tools
# ****************************************************************
from azcam_console.tools import create_console_tools

create_console_tools()

# ****************************************************************
# focus tool
# ****************************************************************
focus = Focus()
focus.focus_component = "telescope"
focus.focus_type = "absolute"

# ****************************************************************
# observe
# ****************************************************************
observe = Observe()

# ****************************************************************
# try to connect to azcamserver
# ****************************************************************
server = azcam.db.tools["server"]
connected = server.connect()
if connected:
    azcam.log("Connected to azcamserver")
else:
    azcam.log("Not connected to azcamserver")

# ****************************************************************
# read par file
# ****************************************************************
azcam.db.parameters.read_parfile(parfile)
azcam.db.parameters.update_pars(0, "azcamconsole")
