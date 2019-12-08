@echo on
rem *** Make DSP timing code files for ARC22 timing board ***

set CCD=mont4k

set DIR=.\arc22timing\

call %DIR%Generate_ARC22_Code.bat %CCD% config0

pause