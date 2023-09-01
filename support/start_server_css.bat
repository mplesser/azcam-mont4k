@echo off

ipython.exe --profile azcamserver --TerminalInteractiveShell.term_title_format=azcamserver -i -m azcam_mont4k.server -- -system CSS
