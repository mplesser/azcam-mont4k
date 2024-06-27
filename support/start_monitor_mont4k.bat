@echo off

start/min "azcammonitor" python -m azcam.monitor -- -configfile "../parameters_monitor_mont4k.ini"

rem start "azcammonitor" ipython -m azcam.monitor -i -- -configfile "../parameters/parameters_monitor_mont4k.ini"

rem ipython -m azcam.monitor -i -- -configfile "../parameters/parameters_monitor_mont4k.ini"
