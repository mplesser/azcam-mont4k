# azcamconsole config file

import os
import sys

import azcam
import azcam.azcamconsole

from azcam_mont4k import system_config
from azcam_mont4k.common import commands

def config():

    # ****************************************************************
    # files and folders
    # ****************************************************************
    systemname = system_config.systemname
    azcam.db.systemname = systemname

    systemfolder = f"{os.path.dirname(__file__)}"
    azcam.db.systemfolder = systemfolder
    azcam.utils.add_searchfolder(systemfolder, 0)  # top level only
    azcam.utils.add_searchfolder(os.path.join(systemfolder, "common"), 1)

    datafolder = system_config.datafolder_root
    azcam.db.datafolder = datafolder

    parfile = f"{datafolder}/azcam/parameters_{systemname}.ini"
    azcam.db.parfile = parfile

    # ****************************************************************
    # start logging
    # ****************************************************************
    logfile = os.path.join(datafolder, "azcam/logs", "azcamconsole.log")
    logfile = azcam.utils.fix_path(logfile)
    azcam.utils.start_logging(logfile)
    azcam.log(f"Configuring azcamconsole for Mont4k")

    # ****************************************************************
    # config ipython if in use
    # ****************************************************************
    commands.config_ipython()

    # ****************************************************************
    # display
    # ****************************************************************
    from azcam.displays.ds9display import Ds9Display

    display = Ds9Display()

    # ****************************************************************
    # focus script
    # ****************************************************************
    from azcam_mont4k.common.focus import Focus

    focus = Focus()
    azcam.db.focus = focus
    azcam.db.objects["focus"] = focus
    focus.focus_component="telescope"
    focus.focus_type = "absolute"

    # ****************************************************************
    # observe script
    # ****************************************************************
    from azcam_mont4k.common.observe.observe import Observe

    if getattr(azcam.db, "qtapp", None) is None:
        import PyQt4.QtGui as QtGui

        qtapp = QtGui.QApplication([])
        azcam.db.qtapp = qtapp
    observe = Observe()
    azcam.db.objects["observe"] = observe

    # ****************************************************************
    # try to connect to azcamserver
    # ****************************************************************
    connected = azcam.api.connect()
    if connected:
        azcam.log("Connected to azcamserver")
    else:
        azcam.log("Not connected to azcamserver")

    # ****************************************************************
    # read par file
    # ****************************************************************
    azcam.api.parfile_read(parfile)

    # ****************************************************************
    # finish
    # ****************************************************************
    azcam.log("Configuration complete")

    # for debugger only
    if 0:
        pass

    return

if __name__ == "__main__":
    args = sys.argv[1:]
    config(*args)
