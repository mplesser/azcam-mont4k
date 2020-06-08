"""
Contains the CSS class for the Catalina Sky Survey project.
"""

import azcam


class CSS(object):
    """
    Class definition of CSS project.
    These methods are called remotely thorugh the command server with syntax such as:
    css.expose 1.0 "zero" "/home/obs/a.001.fits" "some image title".
    """

    def __init__(self):
        """
        Creates css object.
        """

        azcam.db.cmd_objects["css"] = self
        azcam.db.css = self

        return

    def initialize(self):
        """
        Initialize AzCam system. 
        """

        reply = azcam.api.reset()

        return reply

    def expose(self, exposuretime, imagetype, filename, title=""):
        """
        Make a complete exposure, returning immediately after start.
        exposuretime is the exposure time in seconds
        imagetype is the type of exposure ('zero', 'object', 'flat', ...)
        filename is remote filename (do not use periods)
        title is the image title.
        """

        azcam.api.set_par("imagetest", 0)
        azcam.api.set_par("imageautoname", 0)
        azcam.api.set_par("imageincludesequencenumber", 0)
        azcam.api.set_par("imageautoincrementsequencenumber", 0)

        azcam.db.exposure.set_filename(filename)

        azcam.api.expose1(exposuretime, imagetype, title)

        return "OK"

    def timeleft(self):
        """
        Return remaining exposure time (in seconds).
        """

        reply = azcam.db.exposure.get_exposuretime_remaining()

        etr = "%.3f" % reply

        return etr

    def camstat(self):
        """
        Return camera status.
        Reply is "STATUS camtemp dewtemp expflag" 
        """

        reply = azcam.db.tempcon.get_temperatures()

        camtemp = "%.3f" % reply[0]
        dewtemp = "%.3f" % reply[1]

        ef = self.exposure.exposure_flag

        return ["OK", camtemp, dewtemp, ef]

    def binning(self, colbin=1, rowbin=1):
        """
        Set binning.
        """

        reply = azcam.db.exposure.set_roi(-1, -1, -1, -1, colbin, rowbin)

        return

    def geterror(self):
        """
        Return current error status.
        """

        reply = azcam.utils.get_error_status()  # get status

        azcam.utils.set_error_status()  # clear error

        return reply

    def flush(self, cycles=1):
        """
        Flush sensor "cycles" times.
        """

        reply = azcam.db.exposure.flush(cycles)

        return
