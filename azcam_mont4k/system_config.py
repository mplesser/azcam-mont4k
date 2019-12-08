# configuration parameters

server_cmd = "import azcamserver_mont4k; azcamserver_mont4k.config(); from azcam_mont4k.common.cli_config import *"
console_cmd = "import azcamconsole_mont4k; azcamconsole_mont4k.config(); from azcam_mont4k.common.cli_config import *"

datafolder_root = "c:/data/mont4k"
systemname = "mont4k"
xmode = "Context"  # Minimal, Context, Verbose

# custom options
servermode = "interactive"  # prompt, interactive, server
start_azcamtool = 1
restart_cameraserver = 1
