@echo off

SET CFILE="../support/parameters_monitor_mont4k.ini"

rem start/min "azcammonitor" python -m azcam.monitor -- -configfile %CFILE%

rem start "azcammonitor" ipython -m azcam.monitor -i -- -configfile %CFILE%

ipython -m azcam.monitor -i -- -configfile %CFILE%
