@echo off

start/min "azcammonitor" python -m azcam_server.monitor.azcammonitor -- -configfile "/data/mont4k/parameters/parameters_monitor_mont4k.ini"

rem start "azcammonitor" ipython -m azcam_server.monitor.azcammonitor -i -- -configfile "/azcam/azcam-mont4k/support/datafolder/parameters/parameters_monitor_mont4k.ini"

rem ipython -m azcam_server.monitor.azcammonitor -i -- -configfile "/azcam/azcam-mont4k/support/datafolder/parameters/parameters_monitor_mont4k.ini"
