@echo off
echo Install azcam repos
echo.

pip install -e azcam
pip install -e focus
pip install -e genpars
pip install -e observe
pip install -e obstool

pip install -r azcam-mont4k\requirements.txt

:: pause
