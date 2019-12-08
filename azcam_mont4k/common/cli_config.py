import azcam

# imports for azcamconsole command line
if azcam.db.is_azcamconsole:

    from azcam_itl.azcamconsole_shortcuts import *

    from astropy.io import fits as pyfits
    from matplotlib import pylab

    from azcam.testers import *
    from azcam_itl import itldatabase

# imports for azcamserver command line
elif azcam.db.is_azcamserver:

    from azcam_itl.azcamserver_shortcuts import *

# common configuration for server and console
from azcam import api

# put the db["objects"] items in the current name space for CLI use
for obj in azcam.db.objects:
    globals()[obj] = azcam.db.objects[obj]
