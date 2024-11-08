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
        Creates rts2 tool.
        """

        azcam.db.rts2 = self
        azcam.db.tools["rts2"] = self

        return

    def initialize(self):
        """
        Initialize AzCam system.
        """

        azcam.db.tools["exposure"].reset()

        return

    def reset(self):
        """
        Reset exposure.
        """

        azcam.db.tools["exposure"].reset()

        return

    def set_par(self, parameter, value):
        """
        Set parameter.
        """

        if parameter == "remote_imageserver_host":
            azcam.db.tools["exposure"].sendimage.remote_imageserver_host = value
        elif parameter == "remote_imageserver_port":
            azcam.db.tools["exposure"].sendimage.remote_imageserver_port = int(value)
        else:
            azcam.db.parameters.set_par(parameter, value)

        return

    def set_roi(
        self,
        first_col=-1,
        last_col=-1,
        first_row=-1,
        last_row=-1,
        col_bin=-1,
        row_bin=-1,
        roi_num=0,
    ):

        azcam.db.tools["exposure"].set_roi(
            first_col, last_col, first_row, last_row, col_bin, row_bin
        )

        return

    def setexp(self, et: float = 1.0) -> str:
        """
        Set camera exposure time in seconds.
        """

        azcam.db.tools["exposure"].set_exposuretime(et)

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

        reply = azcam.db.tools["exposure"].expose1(
            exposure_time, image_type, image_title
        )

        return reply

    def timeleft(self) -> float:
        """
        Return remaining exposure time (in seconds).
        """

        reply = azcam.db.tools["exposure"].get_exposuretime_remaining()

        etr = "%.3f" % reply

        return etr

    def camstat(self) -> list:
        """
        Return camera status(temperatures).
        """

        reply = azcam.db.tools["tempcon"].get_temperatures()

        camtemp = "%.3f" % reply[0]
        dewtemp = "%.3f" % reply[1]

        return ["OK", camtemp, dewtemp]

    def binning(self, colbin=1, rowbin=1):
        """
        Set binning.
        """

        azcam.db.tools["exposure"].set_roi(-1, -1, -1, -1, colbin, rowbin)

        return

    def geterror(self):
        """
        Return and clear current error status.
        """

        return ["OK", ""]

    def flush(self, cycles=1):
        """
        Flush sensor "cycles" times.
        """

        azcam.db.tools["exposure"].flush(cycles)

        return

    def abort(self):
        """
        abort exposure
        """

        try:
            azcam.db.tools["exposure"].abort()
        except AttributeError:
            return

        return

    def readout_abort(self):
        """
        abort readout
        """

        try:
            azcam.db.tools["controller"].readout_abort()
        except AttributeError:
            return

        return

    def pixels_remaining(self):
        """
        Pixels remaing till readout finished.
        """

        reply = azcam.db.tools["controller"].get_pixels_remaining()

        return reply
