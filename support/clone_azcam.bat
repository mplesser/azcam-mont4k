@echo off
echo Clone azcam repos to local folder
echo.

:: packages
git clone https://github.com/mplesser/azcam.git
git clone https://github.com/mplesser/focus.git
git clone https://github.com/mplesser/genpars.git
git clone https://github.com/mplesser/observe.git
git clone https://github.com/mplesser/obstool.git
git clone https://github.com/mplesser/azcamtool.git
git clone https://github.com/mplesser/ds9support.git
git clone https://github.com/mplesser/azcammonitor.git

:: environments
::git clone https://github.com/uaitl/azcam-itl.git
git clone https://github.com/mplesser/azcam-mont4k.git

:: options
git clone https://github.com/uaitl/motoroladsptools.git
git clone https://github.com/mplesser/expstatus.git
git clone https://github.com/mplesser/engtool.git
