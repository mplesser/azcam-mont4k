# Install azcam-mont4k
# AzCam packages are not available on PyPi so this gets complicated.

import os
import subprocess

# *****************************************************************************
# check and modify this block
# *****************************************************************************
root = "."
root = os.path.realpath(root)
CLONE = 0
INSTALL = 1

github_lesser = "https://github.com/mplesser/"
github_uaitl = "https://github.com/uaitl/"
repos = {
    "azcam": github_lesser,
    "azcam-ds9": github_lesser,
    "azcam-testers": github_lesser,
    "azcam-arc": github_lesser,
    "azcam-cryocon": github_lesser,
    "azcam-exptool": github_lesser,
    "azcam-monitor": github_lesser,
    "azcam-status": github_lesser,
    "azcam-expstatus": github_lesser,
    "azcam-observe": github_lesser,
    "azcam-webobs": github_lesser,
    "azcam-focus": github_lesser,
    "azcam-mont4k": github_lesser,
}
repos_with_requirements = []

# *****************************************************************************
# clone these repos from github (they are not available from PyPi)
# *****************************************************************************
if CLONE:
    print("Cloning repos...")
    for clone in repos.keys():
        subprocess.call(f"git clone {repos[clone]}{clone}", shell=False, cwd=root)
    print()

# *****************************************************************************
# install packages
# *****************************************************************************
if INSTALL:
    print("Installing repos...")
    for repo in repos:
        print(f"\nInstalling {repo}...")
        if repo in repos_with_requirements:
            cmd = f"pip install -r {root}\\{repo}\\requirements.txt"
        else:
            cmd = f"pip install -e {root}\\{repo}"
        subprocess.call(
            cmd,
            shell=False,
            cwd=f"{root}",
        )

input("\nPress Enter to continue...")
