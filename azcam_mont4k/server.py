"""
Setup method for mont4k azcamserver.
Usage example:
  python -i -m azcam_mont4k.server -- -system mont4k
"""

import os
import sys

import azcam
import azcam.utils
import azcam.exceptions
from azcam.header import System
import azcam.server
import azcam.shortcuts
from azcam.logger import check_for_remote_logger
from azcam.cmdserver import CommandServer
from azcam.tools.arc.controller_arc import ControllerArc
from azcam.tools.arc.exposure_arc import ExposureArc
from azcam.tools.arc.tempcon_arc import TempConArc
from azcam.tools.ds9display import Ds9Display
from azcam.tools.focus import Focus
from azcam.web.webserver_main import WebServer

from azcam_mont4k.instrument_mont4k import Mont4kInstrument
from azcam_mont4k.telescope_big61 import Big61TCSng


def setup():

    # parse command line args
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

    # configuration menu
    menu_options = {
        "mont4k standard mode": "mont4k",
        "mont4k for RTS2": "RTS2",
        "mont4k for CSS": "CSS",
    }
    if option == "menu":
        option = azcam.utils.show_menu(menu_options)

    # define folders for system
    azcam.db.systemname = "mont4k"

    azcam.db.systemfolder = os.path.dirname(__file__)
    azcam.db.systemfolder = azcam.utils.fix_path(azcam.db.systemfolder)
    azcam.db.datafolder = azcam.utils.get_datafolder(datafolder)

    parfile = os.path.join(
        azcam.db.datafolder,
        "parameters",
        f"parameters_{azcam.db.systemname}.ini",
    )

    # logging
    logfile = os.path.join(azcam.db.datafolder, "logs", "server.log")
    if check_for_remote_logger():
        azcam.db.logger.start_logging(logtype="23", logfile=logfile)
    else:
        azcam.db.logger.start_logging(logtype="13", logfile=logfile)

    azcam.log(f"Configuring for {option}")

    # system options
    CSS = 0
    RTS2 = 0
    NORMAL = 0
    if "mont4k" in option:
        template = os.path.join(
            azcam.db.datafolder, "templates", "fits_template_mont4k_master.txt"
        )
        parfile = os.path.join(
            azcam.db.datafolder, "parameters", "parameters_server_mont4k.ini"
        )
        NORMAL = 1
        cmdport = 2402
        azcam.db.servermode = "mont4k-normal"

        default_tool = "api"
    elif "RTS2" in option:
        template = os.path.join(
            azcam.db.datafolder, "templates", "fits_template_mont4k_rts2.txt"
        )
        parfile = os.path.join(
            azcam.db.datafolder, "parameters", "parameters_server_mont4k_rts2.ini"
        )
        azcam.db.servermode = "mont4k-rts2"
        RTS2 = 1
        cmdport = 2412
        default_tool = "rts2"
    elif "CSS" in option:
        template = os.path.join(
            azcam.db.datafolder, "templates", "fits_template_mont4k_css.txt"
        )
        parfile = os.path.join(
            azcam.db.datafolder, "parameters", "parameters_server_mont4k_css.ini"
        )
        azcam.db.servermode = "mont4k-css"
        CSS = 1
        cmdport = 2422
        default_tool = "css"
    else:
        azcam.exceptions.AzcamError("invalid menu item")
    parfile = parfile

    # controller
    controller = ControllerArc()
    controller.timing_board = "arc22"
    controller.clock_boards = ["gen3"]
    controller.video_boards = ["gen2"]
    controller.utility_board = "gen3"
    controller.set_boards()
    controller.utility_file = os.path.join(
        azcam.db.datafolder, "dspcode", "dsputility/util3.lod"
    )
    controller.pci_file = os.path.join(
        azcam.db.datafolder, "dspcode", "dsppci", "pci3.lod"
    )
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

    # temperature controller
    tempcon = TempConArc()
    tempcon.control_temperature = -135.0
    tempcon.set_calibrations([0, 0, 3])

    # exposure
    exposure = ExposureArc()
    remote_imageserver_port = 6543
    exposure.send_image = 1
    if CSS:
        remote_imageserver_host = "10.30.7.82"
        imagefolder = "/home/css"
        exposure.sendimage.set_remote_imageserver(
            remote_imageserver_host, remote_imageserver_port, "azcam"
        )
    elif RTS2:
        remote_imageserver_host = "10.30.1.24"
        imagefolder = "/home/rts2obs"
        exposure.sendimage.set_remote_imageserver(
            remote_imageserver_host, remote_imageserver_port, "dataserver"
        )
    else:
        remote_imageserver_host = "10.30.1.1"
        imagefolder = "/home/bigobs"
        exposure.sendimage.set_remote_imageserver(
            remote_imageserver_host, remote_imageserver_port, "dataserver"
        )
    exposure.filetype = exposure.filetypes["MEF"]
    exposure.image.filetype = exposure.filetypes["MEF"]
    exposure.display_image = 0
    exposure.folder = imagefolder
    if lab:
        exposure.send_image = 0

    # detector
    detector_mont4k = {
        "name": "mont4k",
        "description": "4096x4096 CCD",
        "ref_pixel": [2048, 2048],
        "format": [4096, 20, 0, 20, 4096, 0, 0, 0, 0],
        "focalplane": [1, 1, 2, 1, [0, 1]],
        "roi": [1, 4096, 1, 4096, 3, 3],
        "ext_position": [[1, 1], [2, 1]],
        "jpg_order": [1, 2],
    }
    exposure.set_detpars(detector_mont4k)
    sc = 0.000_039_722
    exposure.image.focalplane.wcs.scale1 = [sc, sc]
    exposure.image.focalplane.wcs.scale2 = [sc, sc]

    # instrument
    instrument = Mont4kInstrument()
    instrument.is_enabled = 1

    # telescope
    telescope = Big61TCSng()

    # system header template
    system = System("mont4k", template)
    system.set_keyword("DEWAR", "Mont4kDewar", "Dewar name")

    # focus
    focus = Focus()
    focus.focus_component = "telescope"
    focus.focus_type = "absolute"
    focus.initialize()

    # display
    display = Ds9Display()
    display.initialize()

    # system-specific
    start_azcamtool = 0
    if CSS:
        from azcam_mont4k.css import CSS

        css = CSS()
    elif RTS2:
        from azcam_mont4k.rts2 import RTS2

        rts2 = RTS2()
        rts2.focus = focus  # call as rts2.focus.xxx not focus.xxx
        start_azcamtool = 0

    # par file
    azcam.db.parameters.read_parfile(parfile)
    azcam.db.parameters.update_pars()

    # overwrite some pars
    if CSS:
        instrument.is_enabled = 0
        telescope.is_enabled = 0
        exposure.flush_array = 0

    # define and start command server
    cmdserver = CommandServer()
    cmdserver.port = cmdport
    azcam.log(f"Starting cmdserver - listening on port {cmdserver.port}")
    if default_tool is not None:
        azcam.db.default_tool = default_tool
    azcam.db.tools["api"].initialize_api()
    cmdserver.start()

    # web server
    webserver = WebServer()
    webserver.port = cmdport + 1
    webserver.start()

    # azcammonitor
    azcam.db.monitor.register()

    # controller server
    import azcam_mont4k.restart_cameraserver

    # GUIs
    if start_azcamtool:
        import azcam_mont4k.start_azcamtool

    # finish
    azcam.log("Configuration complete")


# start
setup()
from azcam.cli import *  # bring CLI commands to namespace
