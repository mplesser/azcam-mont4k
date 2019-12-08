# script to start azcamserver with IPython

import os
import sys

from azcam_mont4k import system_config


def start(flags=[]):

    # virtual enviroment
    if 0:
        venv_script = "/azcam/venv/Scripts/activate.bat"
        ipython = f"call {venv_script} && ipython"
    else:
        ipython = "ipython"

    # profile and window title
    profile = profile = "AzCamServer"
    profiledir = f"{system_config.datafolder_root}/azcam/profiles/{profile}"

    # server mode
    if system_config.servermode == "interactive":
        interactive = "-i"
    elif system_config.servermode == "prompt":
        ans = input("Enter i for interactive mode: ")
        if ans == "i":
            interactive = "-i"
        else:
            interactive = ""
    elif system_config.servermode == "server":
        interactive = ""
    else:
        interactive = ""

    # override with CL argument
    if "server" in flags:
        interactive = ""

    # traceback mode
    xmode = f"InteractiveShell.xmode={system_config.xmode}"

    # execute
    cl = (
        f"{ipython} --profile {profile} --profile-dir={profiledir} --{xmode} "
        f"--TerminalInteractiveShell.term_title_format={profile} {interactive} "
        f'-c "{system_config.server_cmd}"'
    )
    os.system(cl)

    return


if __name__ == "__main__":
    args = sys.argv[1:]
    start(*args)
