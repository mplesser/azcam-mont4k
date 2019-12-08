# script to start azcamconsole with IPython

import os

from azcam_mont4k import system_config

# virtual enviroment
if 0:
    venv_script = "/azcam/venv/Scripts/activate.bat"
    ipython = f"call {venv_script} && ipython"
else:
    ipython = "ipython"

# profile and window title
profile = "AzCamConsole"
profiledir = f"{system_config.datafolder_root}/azcam/profiles/{profile}"

# traceback mode
xmode = f"InteractiveShell.xmode={system_config.xmode}"

# execute
cl = (
    f"{ipython} --profile {profile} --profile-dir={profiledir} --{xmode} "
    f"--TerminalInteractiveShell.term_title_format={profile} -i "
    f'-c "{system_config.console_cmd}"'
)
os.system(cl)
