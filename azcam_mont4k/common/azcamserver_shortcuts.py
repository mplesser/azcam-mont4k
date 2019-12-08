"""
Shortcuts for command line.

Defines: sav, bf, p, sroi, sf, gf
"""

import azcam


def sav():
    """Shortcut to parfile_write() to save current folder in database."""
    azcam.utils.curdir()  # update wd
    azcam.api.parfile_write()

    return None


def bf():
    """Shortcut for file_browser() and azcam.utils.curdir()."""

    folder = azcam.utils.file_browser("", "folder", "Select folder")
    if isinstance(folder, list):
        folder = folder[0]
    azcam.utils.curdir(folder)
    azcam.api.parfile_write()  # save working folder
    return


def p():
    """Shortcut to toggle cmdserver printing."""

    old = azcam.db.logcommands
    new = not old
    azcam.db.logcommands = new
    print("cmdserver logcommands is %s" % ("ON" if new else "OFF"))

    return


def sroi():
    """Alias for set_image_roi()."""
    azcam.utils.set_image_roi()
    return


def sf():
    """Shortcut to Set image folder"""

    try:
        folder = azcam.utils.curdir()
        folder = folder.replace("/", "\\\\")
        azcam.set_local("imagefolder", folder)
    except Exception:
        pass

    return


def gf():
    """
    Shortcut to Go to image folder.
    Also issues sav() command to save folder location.
    """

    folder = azcam.api.get_par("imagefolder")
    azcam.utils.curdir(folder)
    azcam.db.wd = folder
    sav()

    return
