@echo off

start/min "azcammonitor" python -m azcam_monitor.azcammonitor -- -configfile "/data/mont4k/parameters/parameters_monitor_mont4k.ini"

rem start "azcammonitor" ipython -m azcam_monitor.azcammonitor -i -- -configfile "/data/mont4k/parameters/parameters_monitor_mont4k.ini"
