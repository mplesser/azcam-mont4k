# azcamconsole config file for mont4k

import os
import sys
import datetime
import threading

from PySide2.QtWidgets import QApplication

import azcam
import azcam.console
import azcam.logging
from azcam.genpars import GenPars
from azcam.console import api
import azcam.shortcuts_console
from azcam.displays.ds9display import Ds9Display
from azcam import db
from focus import Focus
from observe.observe import Observe

azcam.log("Loading azcam-mont4k environment")

# ****************************************************************
# files and folders
# ****************************************************************
azcam.db.systemname = "mont4k"
azcam.db.systemfolder = f"{os.path.dirname(__file__)}"
azcam.utils.add_searchfolder(azcam.db.systemfolder, 0)  # top level only
azcam.utils.add_searchfolder(os.path.join(azcam.db.systemfolder, "common"), 1)
azcam.db.datafolder = os.path.join("/data", azcam.db.systemname)
azcam.db.parfile = f"{azcam.db.datafolder}/parameters_{azcam.db.systemname}.ini"

# ****************************************************************
# start logging
# ****************************************************************
tt = datetime.datetime.strftime(datetime.datetime.now(), "%d%b%y_%H%M%S")
azcam.db.logfile = os.path.join(db.datafolder, "logs", f"console_{tt}.log")
azcam.logging.start_logging(db.logfile)
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
# create Qt app
# ****************************************************************
app = QApplication(sys.argv)
azcam.db.qtapp = app

# ****************************************************************
# observe script
# ****************************************************************
observe = Observe()
azcam.db.cli_cmds["observe"] = observe

# ****************************************************************
# try to connect to azcam
# ****************************************************************
connected = api.connect()
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

# ****************************************************************
# add scripts to sys.path for Run
# ****************************************************************
azcam.utils.add_searchfolder(os.path.join(azcam.db.systemfolder, "scripts"))

# ****************************************************************
# define names to imported into namespace when using cli
# # ****************************************************************
azcam.db.cli_cmds.update({"azcam": azcam, "db": db, "api": api})

# ****************************************************************
# clean namespace
# # ****************************************************************
del azcam.focalplane, azcam.displays, azcam.shortcuts_console
del azcam.header, azcam.image
