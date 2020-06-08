# azcamserver config file for mont4k

import os
import sys
import datetime

from PySide2.QtWidgets import QApplication
from genpars import GenPars

import azcam
import azcam.server
from azcam.displays.ds9display import Ds9Display
from azcam.systemheader import SystemHeader
from azcam.controllers.controller_arc import ControllerArc
from azcam.tempcons.tempcon_arc import TempConArc
from azcam.exposures.exposure_arc import ExposureArc
from azcam.cmdserver import CommandServer
from azcam.webserver.web_server import WebServer

from azcam_obstool.obstool import MainWindow

from azcam_mont4k.instrument_mont4k import Mont4kInstrument
from azcam_mont4k.telescope_big61 import telescope

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
    "mont4k standard mode": "normal",
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
azcam.db.parfile = os.path.join(
    azcam.db.datafolder, f"parameters_{azcam.db.systemname}.ini"
)

# ****************************************************************
# enable logging
# ****************************************************************
tt = datetime.datetime.strftime(datetime.datetime.now(), "%d%b%y_%H%M%S")
azcam.db.logfile = os.path.join(azcam.db.datafolder, "logs", f"server_{tt}.log")
azcam.utils.start_logging(azcam.db.logfile, "123")

azcam.log(f"Configuring for {option}")

# ****************************************************************
# define and start command server
# ****************************************************************
cmdserver = CommandServer()
cmdserver.port = 2402
azcam.log(f"Starting command server listening on port {cmdserver.port}")
# cmdserver.welcome_message = "Welcome - azcam-itl server"
cmdserver.start()

# ****************************************************************
# create Qt app
# ****************************************************************
app = QApplication(sys.argv)
azcam.db.qtapp = app

# ****************************************************************
# configure system options
# ****************************************************************
CSS = 0
RTS2 = 0
if "normal" in option:
    template = os.path.join(
        azcam.db.datafolder, "templates", "FitsTemplate_mont4k_master.txt"
    )
    parfile = os.path.join(azcam.db.datafolder, "parameters_mont4k.ini")
elif "RTS2" in option:
    template = os.path.join(
        azcam.db.datafolder, "templates", "FitsTemplate_mont4k_rts2.txt"
    )
    parfile = os.path.join(azcam.db.datafolder, "parameters_mont4k_rts2.ini")
    RTS2 = 1
elif "CSS" in option:
    template = os.path.join(
        azcam.db.datafolder, "templates", "FitsTemplate_mont4k_css.txt"
    )
    parfile = os.path.join(azcam.db.datafolder, "parameters_mont4k_css.ini")
    CSS = 1
else:
    azcam.AzcamError("invalid menu item")
azcam.db.parfile = parfile

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
# dewar
# ****************************************************************
controller.header.set_keyword("DEWAR", "Mont4kDewar", "Dewar name")

# ****************************************************************
# exposure
# ****************************************************************
exposure = ExposureArc()
if CSS:
    exposure.image.server_type = "azcam"
    remote_imageserver_host = "10.30.7.82"
    remote_imageserver_port = 6543
    imagefolder = "/home/css"
elif RTS2:
    exposure.image.server_type = "dataserver"
    remote_imageserver_host = "10.30.1.1"
    remote_imageserver_port = 6543
    imagefolder = "/home/bigobs"
else:
    exposure.image.server_type = "dataserver"
    remote_imageserver_host = "10.30.1.1"
    remote_imageserver_port = 6543
    imagefolder = "/home/bigobs"
exposure.filetype = azcam.db.filetypes["MEF"]
exposure.image.filetype = azcam.db.filetypes["MEF"]
exposure.display_image = 0
exposure.filename.folder = imagefolder
# exposure.set_remote_server(remote_imageserver_host, remote_imageserver_port)
exposure.set_remote_server()

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
    "extension_position": [[1, 1], [2, 1]],
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

# ****************************************************************
# telescope
# ****************************************************************
telescope = telescope

# ****************************************************************
# system header template
# ****************************************************************
system = SystemHeader("mont4k", template)

# ****************************************************************
# focus script - server-side
# ****************************************************************
from azcam_focus import FocusServer

focus = FocusServer()
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
    from azcam_mont4k.css import CSS

    css = CSS()
    azcam.db.cli_cmds["css"] = css
elif RTS2:
    from azcam_mont4k.rts2 import RTS2

    rts2 = RTS2()
    rts2.focus = focus  # call as rts2.focus.xxx not focus.xxx

# ****************************************************************
# read par file
# ****************************************************************
azcam.db.genpars = GenPars()
pardict = azcam.db.genpars.parfile_read(parfile)["azcamserver"]
azcam.utils.update_pars(0, pardict)
wd = azcam.db.genpars.get_par(pardict, "wd", "default")
azcam.utils.curdir(wd)

# overwrite come pars
if CSS:
    instrument.enabled = 0
    telescope.enabled = 0
    exposure.flush_array = 0

# ****************************************************************
# web server
# ****************************************************************
webserver = WebServer()
webserver.start()

# ****************************************************************
# apps
# ****************************************************************
import azcam_mont4k.restart_cameraserver
obstool = MainWindow()
obstool.start()

# ****************************************************************
# define names to imported into namespace
# ****************************************************************
azcam.db.cli_cmds.update({"azcam": azcam, "db": azcam.db, "obstool": obstool})

# ****************************************************************
# finish
# ****************************************************************
azcam.log("Configuration complete")
