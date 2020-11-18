# azcamconsole config file for mont4k

import datetime
import os
import sys
import threading

from azcam_ds9.ds9display import Ds9Display
from azcam_focus.focus import Focus
from azcam_observe.observe import Observe

import azcam.shortcuts
from azcam.console import azcam
from azcam.genpars import GenPars

azcam.log("Loading azcam-mont4k environment")

# ****************************************************************
# files and folders
# ****************************************************************
azcam.db.systemname = "mont4k"
azcam.db.systemfolder = f"{os.path.dirname(__file__)}"
azcam.db.datafolder = os.path.join("/data", azcam.db.systemname)
azcam.db.parfile = f"{azcam.db.datafolder}/parameters_{azcam.db.systemname}.ini"

# ****************************************************************
# start logging
# ****************************************************************
tt = datetime.datetime.strftime(datetime.datetime.now(), "%d%b%y_%H%M%S")
azcam.db.logfile = os.path.join(azcam.db.datafolder, "logs", f"console_{tt}.log")
azcam.logging.start_logging(azcam.db.logfile)
azcam.log(f"Configuring console for {azcam.db.systemname}")

# ****************************************************************
# display
# ****************************************************************
display = Ds9Display()
dthread = threading.Thread(target=display.initialize, args=[])
dthread.start()  # thread just for speed

# ****************************************************************
# focus script
# ****************************************************************
focus = Focus()
azcam.db.cli_cmds["focus"] = focus
focus.focus_component = "telescope"
focus.focus_type = "absolute"

# ****************************************************************
# observe script
# ****************************************************************
observe = Observe()
azcam.db.cli_cmds["observe"] = observe

# ****************************************************************
# try to connect to azcamserver
# ****************************************************************
connected = azcam.api.serverconn.connect()
if connected:
    azcam.log("Connected to azcamserver")
else:
    azcam.log("Not connected to azcamserver")

# ****************************************************************
# read par file
# ****************************************************************
genpars = GenPars()
pardict = genpars.parfile_read(azcam.db.parfile)["azcamconsole"]
azcam.utils.update_pars(0, pardict)
wd = genpars.get_par(pardict, "wd", "default")
azcam.utils.curdir(wd)
