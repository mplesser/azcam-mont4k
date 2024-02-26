@echo off

ipython.exe --profile azcamserver -i -m azcam_mont4k.server -- %1 %2 %3 %4 %5
