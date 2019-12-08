"""
Contains the RTS2 class.
"""

import typing

import azcam


class RTS2(object):
    """
    Class definition of RTS2.
    These methods are called remotely thorugh the command server with syntax such as:
    rts2.expose 1.0 "zero" "/home/obs/a.001.fits" "some image title".
    """

    def __init__(self):
        """
        Creates rts2 object.
        """

        self.exposure = azcam.db.objects["exposure"]
        self.tempcon = azcam.db.objects["tempcon"]
        self.instrument = azcam.db.objects["instrument"]
        self.controller = azcam.db.objects["controller"]

        return

    def initialize(self):
        """
        Initialize AzCam system. 
        """

        reply = azcam.api.reset()

        return reply

    def setexp(self, et: float = 1.0) -> str:
        """
        Set camera exposure time in seconds.
        """

        self.exposure.set_exposuretime(et)

        return "OK"

    def expose(
        self, exposure_time: float = -1, image_type: str = "", image_title: str = ""
    ) -> typing.Optional[str]:
        """
        Make a complete exposure.
        
        :param exposure_time: the exposure time in seconds
        :param image_type: type of exposure ('zero', 'object', 'flat', ...)
        :param image_title: image title, usually surrounded by double quotes.
        """

        reply = azcam.api.expose1(exposure_time, image_type, image_title)

        return reply

    def timeleft(self) -> float:
        """
        Return remaining exposure time (in seconds).
        """

        reply = self.exposure.get_exposuretime_remaining()

        etr = "%.3f" % reply[1]

        return etr

    def camstat(self) -> typing.List:
        """
        Return camera status(temperatures).
        """

        reply = self.tempcon.get_temperatures()

        camtemp = "%.3f" % reply[0]
        dewtemp = "%.3f" % reply[1]

        return ["OK", camtemp, dewtemp]

    def binning(self, colbin=1, rowbin=1):
        """
        Set binning.
        """

        reply = self.exposure.set_roi(-1, -1, -1, -1, colbin, rowbin)

        return

    def geterror(self):
        """
        Return and clear current error status.
        """

        reply = azcam.utils.get_error_status()  # get status

        azcam.utils.set_error_status()  # clear error

        return reply

    def flush(self, cycles=1):
        """
        Flush sensor "cycles" times.
        """

        self.exposure.flush(cycles)

        return

    def abort(self):
        """
        abort exposure
        """
        try:
            self.exposure.abort()
        except AttributeError as err:
            return

        return

    def readout_abort(self):
        """
        abort readout
        """
        try:
            self.controller.readout_abort()
        except AttributeError as err:
            return

        return

    def pixels_remaining(self):
        """
        Pixels remaing till readout finished 
        """
        reply = self.controller.get_pixels_remaining()

        return reply
