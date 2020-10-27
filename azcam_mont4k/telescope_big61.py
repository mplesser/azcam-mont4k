# Contains the interface class to the big61 Telescope Control System for Next Generation TCS.

import os
import socket
import sys
import time

import azcam
from azcam.header import Header
from azcam.telescopes.telescope import Telescope


class Big61TCSng(Telescope):
    """
    The interface to the Steward Observatory TCSng telescope server.
    """

    def __init__(self, obj_id="telescope", obj_name="Big61 telescope"):

        super().__init__(obj_id, obj_name)

        self.Host = ""
        self.TELID = ""
        self.Port = -1

        # the value Keywords is the string used by TCS
        self.keywords = {
            "RA": "ra",
            "DEC": "dec",
            "AIRMASS": "secz",
            "HA": "ha",
            "LST-OBS": "lst",
            "EQUINOX": "epoch",
            "JULIAN": "jd",
            "ELEVAT": "alt",
            "AZIMUTH": "az",
            "ROTANGLE": "iis",
            "ST": "lst",
            "EPOCH": "epoch",
            "MOTION": "motion",
            "FOCUS": "focus",
        }
        self.comments = {
            "RA": "right ascension",
            "DEC": "declination",
            "AIRMASS": "airmass",
            "HA": "hour angle",
            "LST-OBS": "local siderial time",
            "EQUINOX": "equinox of RA and DEC",
            "JULIAN": "julian date",
            "ELEVAT": "elevation",
            "AZIMUTH": "azimuth",
            "MOTION": "telescope motion flag",
            "ROTANGLE": "IIS rotation angle",
            "ST": "local siderial time",
            "EPOCH": "equinox of RA and DEC",
            "MOTION": "motion flag",
            "FOCUS": "telescope focus position",
        }
        self.typestrings = {
            "RA": str,
            "DEC": str,
            "AIRMASS": float,
            "HA": str,
            "LST-OBS": str,
            "EQUINOX": float,
            "JULIAN": float,
            "ELEVAT": float,
            "AZIMUTH": float,
            "MOTION": int,
            "BEAM": int,
            "ROTANGLE": float,
            "ST": str,
            "EPOCH": float,
            "FOCUS": float,
        }

        # add keywords
        reply = self.define_keywords()

        return

    def initialize(self):
        """
        Initializes the telescope interface.
        """

        if self.initialized:
            return

        if not self.enabled:
            azcam.AzcamWarning(f"{self.name} is not enabled")
            return

        # set host and port for telescopes
        if self.name == "big61":
            self.Host = "10.30.5.69"
            self.TELID = "BIG61"
            self.Port = 5750
        elif self.name == "test":
            pass
        else:
            azcam.log("ERROR - only BIG61 currently supported")

        # create Telescope object
        if self.name != "test":
            self.Telescope = TelescopeNG(self.Host, self.TELID, self.Port)

        self.initialized = 1

        return

    # **************************************************************************************************
    # exposure
    # **************************************************************************************************
    def exposure_start(self):
        """
        Setup before exposure starts.
        """

        return

    def exposure_finish(self):
        """
        Setup before exposure starts.
        """

        return

    # **************************************************************************************************
    # Keywords
    # **************************************************************************************************
    def update_header(self):
        """
        Update headers, reading current data.
        Override this method to read actual data.
        """

        # delete all keywords if not enabled
        if not self.enabled:
            self.header.delete_all_keywords()
            return

        if not self.initialized:
            self.initialize()

        # update header
        self.define_keywords()
        reply = self.read_header()

        return

    def define_keywords(self):
        """
        Defines telescope keywords to telescope, if they are not already defined.
        """

        # add keywords to header
        for key in list(self.keywords.keys()):
            try:
                self.header.keywords[key] = self.keywords[key]
                self.header.comments[key] = self.comments[key]
                self.header.typestrings[key] = self.typestrings[key]
            except Exception as message:
                azcam.log(key, "TCS keyword error", message)
                self.header.keywords[key] = key
                self.header.comments[key] = "unknown"
                self.header.typestrings[key] = "str"

        return

    def get_keyword(self, Keyword):
        """
        Reads an telescope keyword value.
        Keyword is the name of the keyword to be read.
        This command will read hardware to obtain the keyword value.
        """

        if not self.enabled:
            azcam.AzcamWarning("telescope not enabled")
            return

        data = self.Telescope.azcam_all()

        keyword = Keyword.lower()
        reply = data[keyword]

        # parse RA and DEC specially
        if Keyword == "RA":
            reply = "%s:%s:%s" % (reply[0:2], reply[2:4], reply[4:])
        elif Keyword == "DEC":
            reply = "%s:%s:%s" % (reply[0:3], reply[3:5], reply[5:])
        else:
            pass

        # store value in Header
        self.header.set_keyword(Keyword, reply)

        # convert type
        if self.typestrings[Keyword] == int:
            reply = int(reply)
        elif self.typestrings[Keyword] == float:
            reply = float(reply)

        t = self.header.get_type_string(self.typestrings[Keyword])

        return [reply, self.comments[Keyword], t]

    def read_header(self):
        """
        Returns telescope header info.
        returns [Header[]]: Each element Header[i] contains the sublist (keyword, value, comment, and type).
        Example: Header[2][1] is the value of keyword 2 and Header[2][3] is its type.
        Type is one of str, int, or float.
        """

        if not self.enabled:
            azcam.AzcamWarning("telescope not enabled")
            return

        header = []

        data = self.Telescope.azcam_all()
        keywords = list(data.keys())
        keywords.sort()
        list1 = []

        for key in list(self.keywords.keys()):
            try:
                t = self.header.get_type_string(self.typestrings[key])
                list1 = [key, data[self.keywords[key]], self.comments[key], t]
                header.append(list1)
            except Exception as message:
                azcam.log("ERROR", key, message)
                continue

            # store value in Header
            self.header.set_keyword(list1[0], list1[1], list1[2], list1[3])

        return header

    # **************************************************************************************************
    # Focus
    # **************************************************************************************************

    def set_focus(self, FocusPosition, FocusID=0, focus_type="absolute"):
        """
        Move the telescope focus to the specified position.
        FocusPosition is the focus position to set.
        FocusID is the focus mechanism ID.
        """

        # azcam.utils.prompt('Move to focus %s and press Enter...' % FocusPosition)

        self.Telescope.comFOCUS(int(float(FocusPosition)))

        return

    def get_focus(self, FocusID=0):
        """
        Return the current telescope focus position.
        Current just prompts user for current focus value.
        FocusID is the focus mechanism ID.
        """

        # focpos=azcam.utils.prompt('Enter current focus position:')

        focpos = self.Telescope.reqFOCUS()  # returns an integer

        try:
            self.FocusPosition = float(focpos)
        except:
            self.FocusPosition = focpos

        return self.FocusPosition

    # **************************************************************************************************
    # Move
    # **************************************************************************************************

    def offset(self, RA, Dec):
        """
        Offsets telescope in arcsecs.
        """

        if not self.enabled:
            azcam.AzcamWarning("telescope not enabled")
            return

        reply = self.Telescope.comSTEPRA(RA)
        reply = self.Telescope.comSTEPDEC(Dec)

        # wait for motion to stop
        reply = self.wait_for_move()

        return

    def wait_for_move(self):
        """
        Wait for telescope to stop moving.
        """

        if not self.enabled:
            azcam.AzcamWarning("telescope not enabled")
            return

        # loop for up to ~20 seconds
        for i in range(200):
            reply = self.get_keyword("MOTION")
            try:
                motion = int(reply[0])
            except:
                raise azcam.AzcamError("bad MOTION status keyword: %s" % reply[1])

            if not motion:
                return

            time.sleep(0.1)

        # stop the telescope
        command = "CANCEL"
        reply = self.Telescope.command(command)

        raise azcam.AzcamError("stopped motion flag not detected")


class TelescopeNG:

    # All methods that bind to a tcsng server request
    # will begin with req and all methods that bind to
    # a tcsng server command will begin with com
    # After the first three letters "req" or "com" if
    # the method name is in all caps then it is a letter
    # for letter (underscore = whitespace)copy of the
    # tcsng command or request

    def __init__(self, hostname, telid, port):
        try:
            self.ipaddr = socket.gethostbyname(hostname)
            self.hostname = hostname
            self.telid = telid
        except socket.error:
            raise ValueError("Cannot Find Telescope Host {0}.".format(hostname))

        # Make sure we can talk to this telescope
        if not self.request("EL"):
            raise socket.error

    def request(self, reqstr, timeout=1.0, retry=True):

        """This is the main TCSng request method all
        server requests must come through here."""

        HOST = socket.gethostbyname(self.hostname)
        PORT = 5750
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(timeout)
        try:
            s.connect((HOST, PORT))
            s.send(str.encode("%s TCS 1 REQUEST %s" % (self.telid, reqstr.upper())))
            recvstr = s.recv(4096).decode()
            s.close()
            return recvstr[len(self.telid) + 6 : -1]
        except socket.error:
            msg = "Cannot communicate with telescope {0}".format(self.hostname)
            raise ValueError(msg)

    def command(self, reqstr, timeout=0.5):
        """This is the main TCSng command method. All TCS
        server commands must come through here."""

        HOST = socket.gethostbyname(self.hostname)
        PORT = 5750
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST, PORT))
        s.send(str.encode("%s TCS 123 COMMAND %s" % (self.telid, reqstr.upper())))
        recvstr = s.recv(4096).decode()
        s.settimeout(timeout)
        s.close()
        return recvstr

    def reqALL(self):
        """returns dictions of "ALL" request i.e.
        [MOT] [RA] [DEC] [HA] [LST] [ALT] [AZ] [SECZ] [Epoch]"""
        allDict = {}
        names = ["motion", "ra", "dec", "ha", "lst", "alt", "az", "secz", "epoch"]
        rawStr = self.request("ALL")
        rawList = [ii for ii in rawStr.split(" ") if ii != ""]
        for num in range(len(rawList)):
            allDict[names[num]] = rawList[num]

        return allDict

    def reqXALL(self):
        """returns dictions of "XALL" request i.e.
        [FOC] [DOME] [IIS] [PA] [UTD] [JD]"""
        xallDict = {}
        names = ["focus", "dome", "iis", "pa", "utd", "jd"]
        rawStr = self.request("XALL")
        rawList = [ii for ii in rawStr.split(" ") if ii != ""]

        for num in range(len(rawList)):
            xallDict[names[num]] = rawList[num]

        return xallDict

    def reqTIME(self):
        timeStr = self.request("TIME")
        return timeStr

    def azcam_all(self):
        """Grab all the data necessary to populate the fits headers for SO cameras."""
        azcamall = {}

        vals = [
            "ha",
            "iis",
            "utd",
            "ut",
            "focus",
            "epoch",
            "motion",
            "lst",
            "pa",
            "ra",
            "jd",
            "alt",
            "az",
            "dec",
            "dome",
            "secz",
        ]
        azcamall.update(self.reqALL())
        azcamall.update(self.reqXALL())
        azcamall["ut"] = self.reqTIME()
        return azcamall

    def comSTEPRA(self, dist_in_asecs):
        """Bump ra drive"""
        return self.command("STEPRA {0}".format(dist_in_asecs))

    def comSTEPDEC(self, dist_in_asecs):
        """Bump dec drive"""
        return self.command("STEPDEC {0}".format(dist_in_asecs))

    def radecguide(self, ra, dec):
        """Send a telcom style guide command"""
        raresp = self.STEPRA(ra)
        decresp = self.STEPDEC(dec)
        return [raresp, decresp]

    def comFOCUS(self, pos):
        """Set the absolute focus position"""
        self.command("FOCUS {}".format(pos))

    def reqFOCUS(self):
        return int(self.request("FOCUS"))


# create instance
telescope = Big61TCSng()

# tel = TelescopeNG("10.30.5.69", "BIG61", 5750)
# print(tel.azcam_all())
