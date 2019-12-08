# azcamserver config file for mont4k

import os
import sys

import azcam
import azcam.azcamserver
from azcam.displays.ds9display import Ds9Display
from azcam.systemheader import SystemHeader
from azcam.cameras.arc.controller_arc import ControllerArc
from azcam.tempcons.tempcon_arc import TempConArc
from azcam.cameras.arc.exposure_arc import ExposureArc
from azcam.cmdserver import CommandServer

from azcam_mont4k.common import commands
from azcam_mont4k import system_config


def config(systemname: str = "menu"):

    # ****************************************************************
    # configuration menu
    # ****************************************************************
    menu_options = {
        "mont4k standard mode": "mont4k normal",
        "mont4k for RTS2": "mont4k RTS2",
        "mont4k for CSS": "mont4k CSS",
    }
    if systemname == "config":
        systemname = system_config.systemname
    if systemname == "menu":
        options = azcam.utils.show_menu(menu_options)
    else:
        options = menu_options[systemname]

    # ****************************************************************
    # files and folders
    # ****************************************************************
    systemname = system_config.systemname
    azcam.db.systemname = systemname

    systemfolder = azcam.utils.fix_path(os.path.dirname(__file__))
    azcam.db.systemfolder = systemfolder
    azcam.utils.add_searchfolder(systemfolder, 0)
    azcam.utils.add_searchfolder(os.path.join(systemfolder, "common"), 1)

    datafolder = system_config.datafolder_root
    azcam.db.datafolder = datafolder

    CSS = 0
    RTS2 = 0
    if "normal" in options:
        template = f"{azcam.db.datafolder}/templates/FitsTemplate_mont4k_master.txt"
        parfile = f"{azcam.db.datafolder}/azcam/parameters_mont4k.ini"
    elif "RTS2" in options:
        template = f"{azcam.db.datafolder}/templates/FitsTemplate_mont4k_rts2.txt"
        parfile = f"{azcam.db.datafolder}/azcam/parameters_mont4k_rts2.ini"
        RTS2 = 1
    elif "CSS" in options:
        template = f"{azcam.db.datafolder}/templates/FitsTemplate_mont4k_css.txt"
        parfile = f"{azcam.db.datafolder}/azcam/parameters_mont4k_css.ini"
        CSS = 1
    else:
        azcam.AzCamError("invalid menu item")
    azcam.db.parfile = parfile

    # ****************************************************************
    # start logging
    # ****************************************************************
    logfile = os.path.join(datafolder, "azcam/logs", "azcamserver.log")
    logfile = azcam.utils.fix_path(logfile)
    azcam.utils.start_logging(logfile)
    azcam.log(f"Configuring azcamserver for {options}")

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
    controller.utility_file = f"{azcam.db.systemfolder}/dspcode/dsputility/util3.lod"
    controller.pci_file = f"{azcam.db.systemfolder}/dspcode/dsppci/pci3.lod"
    controller.timing_file = f"{azcam.db.systemfolder}/dspcode/dsptiming/mont4k_config0.lod"
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
    exposure.aztime.sntp.servers = ["128.196.208.118", "time.nist.gov"]
    exposure.set_remote_server(remote_imageserver_host, remote_imageserver_port)
    # exposure.set_remote_server()

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
    from azcam_mont4k.instrument_mont4k import Mont4kInstrument

    instrument = Mont4kInstrument()

    # ****************************************************************
    # telescope
    # ****************************************************************
    from azcam_mont4k.telescope_big61 import telescope

    # ****************************************************************
    # system header template
    # ****************************************************************
    system = SystemHeader("mont4k", template)

    # ****************************************************************
    # focus script - server-side
    # ****************************************************************
    from azcam_mont4k.common.focus import Focus

    focus = Focus()
    azcam.db.focus = focus
    azcam.db.objects["focus"] = focus
    focus.focus_component = "telescope"
    focus.focus_type = "absolute"

    # ****************************************************************
    # display
    # ****************************************************************
    display = Ds9Display()

    # ****************************************************************
    # ipython config
    # ****************************************************************
    commands.config_ipython()

    # ****************************************************************
    # command server
    # ****************************************************************
    cmdserver = CommandServer()
    cmdserver.port = 2402
    azcam.db.cmdserver = cmdserver
    azcam.log(f"Starting command server listening on port {cmdserver.port}")
    cmdserver.start()
    azcam.db.logcommands = 0

    if CSS:
        from azcam_mont4k.css import CSS

        css = CSS()
        azcam.db.css = css
        azcam.db.objects["css"] = css
    elif RTS2:
        from azcam_mont4k.rts2 import RTS2

        rts2 = RTS2()
        azcam.db.rts2 = rts2
        azcam.db.objects["rts2"] = rts2
        rts2.focus = focus  # call as rts2.focus.xxx not focus.xxx

    # ****************************************************************
    # read parameters file
    # ****************************************************************
    azcam.api.parfile_read(parfile)

    # overwrite come pars
    if CSS:
        instrument.enabled = 0
        telescope.enabled = 0
        exposure.flush_array = 0

    # ****************************************************************
    # apps
    # ****************************************************************
    if system_config.start_azcamtool:
        import azcam_mont4k.start_azcamtool

    if system_config.restart_cameraserver:
        import azcam_mont4k.restart_cameraserver

    # ****************************************************************
    # finish
    # ****************************************************************
    initialized = 1
    azcam.log("Configuration complete")

    # for debugger only
    if 0:
        pass

    return


if __name__ == "__main__":
    args = sys.argv[1:]
    config(*args)
