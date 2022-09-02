import socket
import time
from threading import Lock, RLock

DEBUG = False

AXES = {"RA": 0, "Dec": 1, "ra": 0, "dec": 1, "DEC": 1}
telTalk = RLock()


class telescope:

    # All methods that bind to a tcsng server request
    # will begin with req and all methods that bind to
    # a tcsng server command will begin with com
    # After the first three letters "req" or "com" if
    # the method name is in all caps then it is a letter
    # for letter (underscore = whitespace)copy of the
    # tcsng command or request

    def __init__(self, hostname, telid="TCSNG"):
        try:
            self.ipaddr = socket.gethostbyname(hostname)
            self.hostname = hostname
            self.telid = telid
        except socket.error:
            raise telComError("Cannot Find Telescope Host {0}.".format(hostname))

    def connect(self):
        self.comLock = Lock()
        # Make sure we can talk to this telescope
        if not self.request("EL".encode("utf-8")):
            raise socket.error

        return

    def request(self, reqstr, timeout=0.1, retry=True):

        """This is the main TCSng request method all
        server requests must come through here."""

        with self.comLock:
            HOST = socket.gethostbyname(self.hostname)
            PORT = 5750
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(timeout)
            try:
                s.connect((HOST, PORT))
                output = "{} TCS 1 REQUEST {}".format(self.telid, reqstr.upper())
                s.send(output.encode("utf-8"))
                recvstr = s.recv(4096)
                s.close()
                return recvstr[len(self.telid) + 6 : -1]
            except socket.error:
                msg = "Cannot communicate with telescope {0}".format(self.hostname)
                raise telComError(msg)

    def command(self, reqstr, timeout=0.5):
        """This is the main TCSng command method. All TCS
        server commands must come through here."""

        HOST = socket.gethostbyname(self.hostname)
        PORT = 5750
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST, PORT))
        output = "{} TCS 123 COMMAND {}".format(self.telid, reqstr.upper())
        s.send(output.encode("utf-8"))
        recvstr = s.recv(4096)
        s.settimeout(timeout)
        s.close()
        return recvstr

    def comFOCUS(self, pos):
        """Set the absolute focus position"""
        self.command("FOCUS {}".format(pos))

    def reqFOCUS(self):
        return int(self.request("FOCUS"))

    def test(self):
        print(self.reqFOCUS())


class telComError(Exception):
    def __init__(self, message):
        Exception.__init__(self, message)


# instance
test_big61_focus = telescope("10.30.5.68", "BIG61")
