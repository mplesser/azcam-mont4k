"""
Contains Mont4k instrument class for the UAO 61" Mont4k instrument.
"""

import socket
import sys
import threading
import time

import azcam
from azcam.instrument import Instrument


class Mont4kInstrument(Instrument):
    """
    The interface to the Mont4k instrument at the Mt. Bigelow 61".
    The InstrumentServer is J. Fookson's Ruby server.
    """

    def __init__(self, obj_id="instrument", name="Mont4k"):

        super().__init__(obj_id, name)

        self.Port = 9875
        self.Host = "10.30.1.1"
        self.ActiveComps = [""]
        self.ActiveFilter = "unknown"
        self.busy = 0

        # instrument server interface
        self.iserver = InstrumentServerInterface(self.Host, self.Port)

        # add keywords
        reply = self.define_keywords()

    def command(self, Command):
        """
        Command interface for Mont4k instrument.  Use instead of instrument server Command().
        """

        # wait until other command have finished
        for i in range(100):
            if self.busy:
                time.sleep(0.1)
            else:
                break
        if i == 99:
            raise azcam.AzcamError("instrument command timeout")

        self.busy = True
        self.iserver.open()
        if self.iserver.Opened:
            reply = self.iserver.recv1()  # read string and ignore for now
            reply = self.iserver.send(Command)
            reply = self.iserver.recv1()
            self.iserver.send("CLIENTDONE")
            reply1 = self.iserver.recv1()  # read string and ignore for now
            time.sleep(0.10)  # !
            self.iserver.close()
        else:
            self.busy = False
            raise azcam.AzcamError("could not open Mont4k instrument")

        # check for error, valid replies starts with 'OK: ' and errors with '?: '
        if reply.startswith("OK: "):
            reply = reply[4:]
            reply = reply.rstrip()
            self.busy = False
            return reply
        else:
            self.busy = False
            raise azcam.AzcamError(reply)

    # *** keywords ***

    def define_keywords(self):
        """
        Defines telescope keywords to telescope, if they are not already defined.
        """

        # add local keywords
        keywords = {"FILTER": ""}
        comments = {"FILTER": "Filter name"}
        types = {"FILTER": str}
        for key in keywords:
            self.set_keyword(key, "", comments[key], types[key])

        return

    def get_keyword(self, keyword):
        """
        Read an instrument keyword value.
        This command will read hardware to obtain the keyword value.
        """

        if keyword == "FILTER":
            reply = self.get_filter(0)
        else:
            raise azcam.AzcamError("keyword not defined")

        # store value in Header
        self.set_keyword(keyword, reply)

        reply, t = self.header.convert_type(reply, self.header.typestrings[keyword])

        return [reply, self.header.comments[keyword], t]

    # *** filters ***

    def get_all_filters(self, id=0):
        """
        Return a list of all available/loaded filters.
        """

        try:
            reply = self.command("SHOWFILTERS")
        except azcam.AzcamError:
            time.sleep(3)
            try:
                reply = self.command("SHOWFILTERS")
            except azcam.AzcamError:
                azcam.log("ERROR reading loaded filters in get_all_filters")
                raise

        # no error, so parse return string into list
        reply1 = reply.lstrip(" ")  # remove leading space
        filterlist = reply1.split(" ")  # make a list
        self.InstalledFilters = filterlist  # save list

        return filterlist

    def get_filter(self, FilterID=0):
        """
        Get the current filter position.
        FilterID is 0 for Mont4k.
        """

        reply = self.wait_filter_busy()

        reply = self.command("SHOWLOADEDFILTER")

        self.ActiveFilter = reply

        return reply

    def set_filter(self, Filter, FilterID=0):
        """
        Set the current filter position.
        FilterID is 0 for Mont4k.
        """

        # assume Filter name starts with #.
        # Filter=Filter[2:]
        reply = self.command("LOADFILTER " + str(Filter))

        reply = self.wait_filter_busy()
        reply = self.wait_filter_busy()  # test for funny business

        # update filter immediately
        reply = self.get_filter()

        return

    def wait_filter_busy(self):
        """
        Waits for filter wheel to stop moving.
        """

        for i in range(50):
            reply = self.command("SHOW FWBUSY")

            if reply.lstrip().startswith("1"):  # busy
                time.sleep(0.1)
                continue
            elif reply.lstrip().startswith("0"):  # not busy
                return
            else:
                time.sleep(0.1)  # other
                continue

        raise azcam.AzcamError("filter wheel BUSY timeout")

    def _filter_busy(self):
        """
        Return True if filter wheel is moving or False if not.
        """

        for i in range(10):
            reply = self.command("SHOW FWBUSY")

            if reply.lstrip().startswith("1"):
                return True
            elif reply.lstrip().startswith("0"):
                return False
            else:
                continue

            time.sleep(0.1)

        raise azcam.AzcamError("filter wheel BUSY timeout")

    def filter_busy(self):
        """
        Returns status and True if filter wheel is moving or False if not.
        """

        moving = self._filter_busy()
        if moving:
            moving = 1
        else:
            moving = 0

        return moving


class InstrumentServerInterface(object):
    """
    Defines the InstrumentServerInterface class.
    Communicates with an instrument server using an ethernet socket.
    """

    def __init__(self, Host, Port):

        self.Host = Host
        self.Port = Port
        self.Opened = 0

        self.OK = "OK"
        self.ERROR = "ERROR"

    def command(self, Command):
        """
        Communicate with the remote instrument server.
        Opens and closes the socket each time.
        Returns the exact reply from the server.
        """

        self.open()
        if self.Opened:
            self.send(Command)
            reply = self.recv()
            self.close()
        else:
            reply = ""

        return reply

    def open(self, Host="", Port=-1):
        """
        Open a socket connection to an instrument.
        Creates the socket and makes a connection.
        """

        if Host != "":
            self.Host = Host
        if Port != -1:
            self.Port = Port

        self.Socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            self.Socket.connect((self.Host, self.Port))
            self.Opened = 1
            return [self.OK]
        except Exception:
            self.Opened = 0
            return [self.ERROR, "instrument not opened"]

    def close(self):
        """
        Close an open socket connection to an instrument.
        """

        try:
            self.Socket.close()
        except Exception:
            pass
        self.Opened = 0
        return [self.OK]

    def send(self, Command):
        """
        Send a command string to a socket instrument.
        Appends CR LF to Command.
        """

        try:
            self.Socket.send(
                str.encode(Command + "\r\n")
            )  # send command with terminator
        except Exception:
            return [self.ERROR, "could not send command to instrument"]
        return [self.OK]

    def send1(self, Command):
        """
        Send a command string to a socket instrument.
        Do not append CR LF to Command.
        """

        try:
            self.Socket.send(str.encode(Command))  # send command with terminator
        except Exception:
            return [self.ERROR, "could not send command to instrument"]
        return [self.OK]

    def recv(self):
        """
        Receives a reply from a socket instrument.
        Terminates read when newline CR  LF is found.
        """

        # receive Reply from remote server
        msg = chunk = ""
        while chunk != "\n":  # server returns CR LF, which is '\n' translated
            try:
                chunk = self.Socket.recv(1).decode()
            except Exception:
                msg = chunk = ""
                self.status = -1
                return "ERROR in instrument communication"  # get out
            msg = msg + chunk
        Reply = msg[:-2]  # remove CR/LF
        self.status = 0
        if Reply is None:
            Reply = ""
        return Reply

    def recv1(self, Length=1024):
        """
        Receives a reply from a socket instrument.
        Reads up to Length characters.
        """

        try:
            msg = self.Socket.recv(Length).decode()
        except Exception as message:
            msg = ""

        return msg
