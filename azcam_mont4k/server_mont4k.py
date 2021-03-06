# azcamserver config file for mont4k

import datetime
import os
import sys

import azcam
import azcam.server
import azcam.shortcuts_server
from azcam.cmdserver import CommandServer
from azcam.system import System
from azcam_webserver.web_server import WebServer
from azcam_monitor.monitorinterface import AzCamMonitorInterface
from azcam_arc.controller_arc import ControllerArc
from azcam_arc.exposure_arc import ExposureArc
from azcam_arc.tempcon_arc import TempConArc
from azcam_ds9.ds9display import Ds9Display
from azcam_focus.focus import Focus
import azcam_exptool
import azcam_status
import azcam_observe.webobs


# ****************************************************************
# parse command line arguments
# ****************************************************************
try:
    i = sys.argv.index("-system")
    option = sys.argv[i + 1]
except ValueError:
    option = "menu"

# ****************************************************************
# configuration menu
# ****************************************************************
menu_options = {
    "mont4k standard mode": "mont4k",
    "mont4k for RTS2": "RTS2",
    "mont4k for CSS": "CSS",
}
if option == "menu":
    option = azcam.utils.show_menu(menu_options)

# ****************************************************************
# define folders for system
# ****************************************************************
azcam.db.systemname = "mont4k"
azcam.db.systemfolder = os.path.dirname(__file__)
azcam.db.systemfolder = azcam.utils.fix_path(azcam.db.systemfolder)
azcam.db.datafolder = os.path.join("/data", azcam.db.systemname)
azcam.db.datafolder = azcam.utils.fix_path(azcam.db.datafolder)
parfile = os.path.join(azcam.db.datafolder, f"parameters_{azcam.db.systemname}.ini")

# ****************************************************************
# add folders to search path
# ****************************************************************
azcam.utils.add_searchfolder(azcam.db.systemfolder, 0)

# ****************************************************************
# enable logging
# ****************************************************************
tt = datetime.datetime.strftime(datetime.datetime.now(), "%d%b%y_%H%M%S")
azcam.db.logger.logfile = os.path.join(azcam.db.datafolder, "logs", f"server_{tt}.log")
azcam.db.logger.start_logging()

azcam.log(f"Configuring for {option}")

# ****************************************************************
# configure system options
# ****************************************************************
CSS = 0
RTS2 = 0
NORMAL = 0
if "mont4k" in option:
    template = os.path.join(
        azcam.db.datafolder, "templates", "FitsTemplate_mont4k_master.txt"
    )
    parfile = os.path.join(azcam.db.datafolder, "parameters_mont4k.ini")
    NORMAL = 1
    cmdport = 2402
    azcam.db.servermode = "mont4k"
    default_object = None
elif "RTS2" in option:
    template = os.path.join(
        azcam.db.datafolder, "templates", "FitsTemplate_mont4k_rts2.txt"
    )
    parfile = os.path.join(azcam.db.datafolder, "parameters_mont4k_rts2.ini")
    RTS2 = 1
    cmdport = 2412
    azcam.db.servermode = "RTS2"
    default_object = "rts2"
elif "CSS" in option:
    template = os.path.join(
        azcam.db.datafolder, "templates", "FitsTemplate_mont4k_css.txt"
    )
    parfile = os.path.join(azcam.db.datafolder, "parameters_mont4k_css.ini")
    CSS = 1
    cmdport = 2422
    azcam.db.servermode = "CSS"
    default_object = None
else:
    azcam.AzcamError("invalid menu item")
parfile = parfile

# ****************************************************************
# define and start command server
# ****************************************************************
cmdserver = CommandServer()
cmdserver.port = cmdport
azcam.log(f"Starting cmdserver - listening on port {cmdserver.port}")
# cmdserver.welcome_message = "Welcome - azcam-itl server"
cmdserver.start()
cmdserver.default_object = default_object

# ****************************************************************
# controller
# ****************************************************************
controller = ControllerArc()
controller.timing_board = "arc22"
controller.clock_boards = ["gen3"]
controller.video_boards = ["gen2"]
controller.utility_board = "gen3"
controller.set_boards()
controller.camserver.set_server("localhost", 2405)
controller.utility_file = os.path.join(
    azcam.db.systemfolder, "dspcode", "dsputility/util3.lod"
)
controller.pci_file = os.path.join(
    azcam.db.systemfolder, "dspcode", "dsppci", "pci3.lod"
)
controller.timing_file = os.path.join(
    azcam.db.systemfolder, "dspcode", "dsptiming", "mont4k_config0.lod"
)
controller.video_gain = 2
controller.video_speed = 2

# ****************************************************************
# temperature controller
# ****************************************************************
tempcon = TempConArc()
tempcon.control_temperature = -135.0
tempcon.set_calibrations([0, 0, 3])

# ****************************************************************
# exposure
# ****************************************************************
exposure = ExposureArc()
remote_imageserver_port = 6543
if CSS:
    exposure.image.server_type = "azcam"
    remote_imageserver_host = "10.30.7.82"
    imagefolder = "/home/css"
    azcam.db.servermode = "mont4k-css"
elif RTS2:
    exposure.image.server_type = "dataserver"
    remote_imageserver_host = "10.30.1.1"
    # imagefolder = "/home/bigobs"
    imagefolder = "/home/rts2obs"
    azcam.db.servermode = "mont4k-rts2"
else:
    exposure.image.server_type = "dataserver"
    remote_imageserver_host = "10.30.1.1"
    imagefolder = "/home/bigobs"
    azcam.db.servermode = "mont4k-normal"
exposure.filetype = exposure.filetypes["MEF"]
exposure.image.filetype = exposure.filetypes["MEF"]
exposure.display_image = 0
exposure.folder = imagefolder
exposure.set_remote_imageserver(remote_imageserver_host, remote_imageserver_port)
# exposure.set_remote_imageserver()

# ****************************************************************
# detector
# ****************************************************************
detector_mont4k = {
    "name": "mont4k",
    "description": "4096x4096 CCD",
    "ref_pixel": [2048, 2048],
    "format": [4096, 20, 0, 20, 4096, 0, 0, 0, 0],
    "focalplane": [1, 1, 2, 1, "01"],
    "roi": [1, 4096, 1, 4096, 3, 3],
    "ext_position": [[1, 1], [2, 1]],
    "jpg_order": [1, 2],
}
exposure.set_detpars(detector_mont4k)
sc = 0.000_039_722
exposure.image.focalplane.wcs.scale1 = [sc, sc]
exposure.image.focalplane.wcs.scale2 = [sc, sc]

# ****************************************************************
# instrument
# ****************************************************************
from instrument_mont4k import Mont4kInstrument

instrument = Mont4kInstrument()
instrument.enabled = 1

# ****************************************************************
# telescope
# ****************************************************************
from telescope_big61 import telescope

telescope = telescope

# ****************************************************************
# system header template
# ****************************************************************
system = System("mont4k", template)
system.set_keyword("DEWAR", "Mont4kDewar", "Dewar name")

# ****************************************************************
# focus
# ****************************************************************
focus = Focus()
azcam.db.cli_cmds["focus"] = focus
focus.focus_component = "telescope"
focus.focus_type = "absolute"

# ****************************************************************
# display
# ****************************************************************
display = Ds9Display()

# ****************************************************************
# system-specific
# ****************************************************************
if CSS:
    from css import CSS

    css = CSS()
    azcam.db.cli_cmds["css"] = css
    process_path = "c:/azcam/azcam-mont4k/bin/start_server_css.bat"
elif RTS2:
    from rts2 import RTS2

    rts2 = RTS2()
    rts2.focus = focus  # call as rts2.focus.xxx not focus.xxx
    process_path = "c:/azcam/azcam-mont4k/bin/start_server_rts2.bat"
else:
    process_path = "c:/azcam/azcam-mont4k/bin/start_server_mont4k.bat"

# ****************************************************************
# read par file
# ****************************************************************
pardict = azcam.api.config.read_parfile(parfile)
azcam.api.config.update_pars(0, "azcamserver")

# overwrite come pars
if CSS:
    instrument.enabled = 0
    telescope.enabled = 0
    exposure.flush_array = 0

# ****************************************************************
# web server
# ****************************************************************
webserver = WebServer()
webserver.templates_folder = azcam.db.systemfolder
webserver.port = 2403  # common port for all configurations
webserver.index = f"index_Mont4k.html"
webserver.start()
azcam_exptool.load()
azcam_status.load()
azcam_observe.webobs.load()

# ****************************************************************
# camera server
# ****************************************************************
import restart_cameraserver

# ****************************************************************
# GUIs
# ****************************************************************
if 1:
    import start_azcamtool

# ****************************************************************
# finish
# ****************************************************************
azcam.log("Configuration complete")
