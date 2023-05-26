# azcamserver config file for mont4k

import os
import sys

import azcam
import azcam_server.server
import azcam_server.shortcuts
from azcam_server.cmdserver import CommandServer
from azcam.header import System
from azcam_monitor.monitorinterface import AzCamMonitorInterface
from azcam_server.tools.arc.controller_arc import ControllerArc
from azcam_server.tools.arc.exposure_arc import ExposureArc
from azcam_server.tools.arc.tempcon_arc import TempConArc
from azcam.tools.ds9display import Ds9Display
from azcam.tools.sendimage import SendImage
from azcam_server.tools.focus import Focus
from azcam_server.tools.webserver.fastapi_server import WebServer
from azcam_server.tools.webtools.status.status import Status

from azcam_mont4k.instrument_mont4k import Mont4kInstrument
from azcam_mont4k.telescope_big61 import Big61TCSng

# ****************************************************************
# parse command line arguments
# ****************************************************************
try:
    i = sys.argv.index("-system")
    option = sys.argv[i + 1]
except ValueError:
    option = "menu"
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

if datafolder is None:
    droot = os.environ.get("AZCAM_DATAROOT")
    if droot is None:
        droot = "/data"
    azcam.db.datafolder = os.path.join(droot, azcam.db.systemname)
else:
    azcam.db.datafolder = datafolder
azcam.db.datafolder = azcam.utils.fix_path(azcam.db.datafolder)

parfile = os.path.join(
    azcam.db.datafolder, "parameters", f"parameters_server_{azcam.db.systemname}.ini"
)

# ****************************************************************
# enable logging
# ****************************************************************
logfile = os.path.join(azcam.db.datafolder, "logs", "server.log")
azcam.db.logger.start_logging(logfile=logfile)
azcam.log(f"Configuring for {option}")

# ****************************************************************
# configure system options
# ****************************************************************
CSS = 0
RTS2 = 0
NORMAL = 0
if "mont4k" in option:
    template = os.path.join(azcam.db.datafolder, "templates", "fits_template_mont4k_master.txt")
    parfile = os.path.join(azcam.db.datafolder, "parameters", "parameters_server_mont4k.ini")
    NORMAL = 1
    cmdport = 2402
    azcam.db.servermode = "mont4k"
    default_tool = None
elif "RTS2" in option:
    template = os.path.join(azcam.db.datafolder, "templates", "fits_template_mont4k_rts2.txt")
    parfile = os.path.join(azcam.db.datafolder, "parameters", "parameters_server_mont4k_rts2.ini")
    RTS2 = 1
    cmdport = 2412
    azcam.db.servermode = "RTS2"
    default_tool = "rts2"
elif "CSS" in option:
    template = os.path.join(azcam.db.datafolder, "templates", "fits_template_mont4k_css.txt")
    parfile = os.path.join(azcam.db.datafolder, "parameters", "parameters_server_mont4k_css.ini")
    CSS = 1
    cmdport = 2422
    azcam.db.servermode = "CSS"
    default_tool = "css"
else:
    azcam.AzcamError("invalid menu item")
parfile = parfile

# ****************************************************************
# controller
# ****************************************************************
controller = ControllerArc()
controller.timing_board = "arc22"
controller.clock_boards = ["gen3"]
controller.video_boards = ["gen2"]
controller.utility_board = "gen3"
controller.set_boards()
controller.utility_file = os.path.join(azcam.db.datafolder, "dspcode", "dsputility/util3.lod")
controller.pci_file = os.path.join(azcam.db.datafolder, "dspcode", "dsppci", "pci3.lod")
controller.timing_file = os.path.join(
    azcam.db.datafolder, "dspcode", "dsptiming", "mont4k_config0.lod"
)
controller.video_gain = 2
controller.video_speed = 2
if lab:
    # controller.camserver.set_server("conserver5", 2405)
    controller.camserver.set_server("localhost", 2405)
else:
    controller.camserver.set_server("localhost", 2405)

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
sendimage = SendImage()
exposure.send_image = 1
if CSS:
    remote_imageserver_host = "10.30.7.82"
    imagefolder = "/home/css"
    azcam.db.servermode = "mont4k-css"
    sendimage.set_remote_imageserver(remote_imageserver_host, remote_imageserver_port, "azcam")
elif RTS2:
    remote_imageserver_host = "10.30.1.24"
    imagefolder = "/home/rts2obs"
    azcam.db.servermode = "mont4k-rts2"
    sendimage.set_remote_imageserver(remote_imageserver_host, remote_imageserver_port, "dataserver")
else:
    remote_imageserver_host = "10.30.1.1"
    imagefolder = "/home/bigobs"
    azcam.db.servermode = "mont4k-normal"
    sendimage.set_remote_imageserver(remote_imageserver_host, remote_imageserver_port, "dataserver")
exposure.filetype = exposure.filetypes["MEF"]
exposure.image.filetype = exposure.filetypes["MEF"]
exposure.display_image = 0
exposure.folder = imagefolder
if lab:
    exposure.send_image = 0

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
instrument = Mont4kInstrument()
instrument.enabled = 1

# ****************************************************************
# telescope
# ****************************************************************
telescope = Big61TCSng()

# ****************************************************************
# system header template
# ****************************************************************
system = System("mont4k", template)
system.set_keyword("DEWAR", "Mont4kDewar", "Dewar name")

# ****************************************************************
# focus
# ****************************************************************
focus = Focus()
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
    from azcam_mont4k.css import CSS

    css = CSS()
    process_path = "c:/azcam/azcam-mont4k/bin/start_server_css.bat"
elif RTS2:
    from azcam_mont4k.rts2 import RTS2

    rts2 = RTS2()
    rts2.focus = focus  # call as rts2.focus.xxx not focus.xxx
    process_path = "c:/azcam/azcam-mont4k/bin/start_server_rts2.bat"
else:
    process_path = "c:/azcam/azcam-mont4k/bin/start_server_mont4k.bat"

# ****************************************************************
# read par file
# ****************************************************************
azcam.db.parameters.read_parfile(parfile)
azcam.db.parameters.update_pars(0, "azcamserver")

# overwrite come pars
if CSS:
    instrument.enabled = 0
    telescope.enabled = 0
    exposure.flush_array = 0

# ****************************************************************
# define and start command server
# ****************************************************************
cmdserver = CommandServer()
cmdserver.port = cmdport
azcam.log(f"Starting cmdserver - listening on port {cmdserver.port}")
# cmdserver.welcome_message = "Welcome - azcam-itl server"
cmdserver.start()
if default_tool is not None:
    azcam.db.default_tool = default_tool

# ****************************************************************
# web server
# ****************************************************************
webserver = WebServer()
webserver.port = 2403  # common port for all configurations
webserver.index = os.path.join(azcam.db.systemfolder, "index_mont4k.html")
webserver.start()
webstatus = Status()
webstatus.initialize()

# ****************************************************************
# controller server
# ****************************************************************
import azcam_mont4k.restart_cameraserver

# ****************************************************************
# GUIs
# ****************************************************************
if 1:
    import azcam_mont4k.start_azcamtool

# ****************************************************************
# finish
# ****************************************************************
azcam.log("Configuration complete")
