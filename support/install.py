# install script for azcam-mont4k

import os

PACKAGE = "azcam-mont4k"

print(f"Installing {PACKAGE} in a virtual environment")

# get root for azcam (change to CLI)
if os.name == "posix":
    AZCAM_ROOT = os.path.join(os.environ["HOME"],"azcam")
    PYTHON = "python3"
else:
    AZCAM_ROOT = "/azcam"
    PYTHON = "python"

# check for and create VE if necessary
ve = os.path.join(AZCAM_ROOT,"venvs","azcam")
if not os.path.exists(ve):
    print(f"Creating azcam virtual environment {ve}")
    os.makedirs(ve)
    os.system(f'{PYTHON} -m venv {ve}')

    # update pip
    print("updating pip")
    cmd = f"{os.path.join(ve,'scripts','python.exe')} -m pip install --upgrade pip"
    os.system(cmd)

# install 
if os.name == "posix":
    commands = [
        'sudo apt-get install python3-tk',
        f'. {AZCAM_ROOT}/venvs/azcam/bin/activate ; pip install -e {AZCAM_ROOT}/{PACKAGE}',
    ]

    for command in commands:
        os.system(command)

else:
    commands = [
        f'{AZCAM_ROOT}/venvs/azcam/scripts/activate.bat ',
        f'& pip install -e {AZCAM_ROOT}/{PACKAGE} ',
    ]

    command = ''
    for cmd in commands:
        command = command + cmd
    os.system(command)

# finish
print("Finished")
