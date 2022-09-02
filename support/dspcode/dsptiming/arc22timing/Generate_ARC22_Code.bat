@echo off
rem Creates .lod files for ARC22 timing board
rem MPL 21May12

rem arguments are NAME CONFIG
rem NAME is root name of the output file and the input waveform filename
rem CONFIG is config0 through config3
rem the 'current' folder here is the calling dir from the Make file

rem Directory paths - change as needed
set ROOT=\azcam\motoroladsptools\motoroladsptools\
set ROOT3=%ROOT%CLAS563\BIN\
set CODEDIR=%CD%\arc22timing\

rem Set waveform include file based on NAME
set WAVEFILE=%1.asm

@echo on

rem Set defaults
set CONFIG=config0
set CONFIGFLAG=-d CONFIG0 1 -d CONFIG1 0 -d CONFIG2 0 -d CONFIG3 0

rem *** set CONFIG flag -> default is config0 ***

if /i %2 EQU config0 (
set CONFIGFLAG=-d CONFIG0 1 -d CONFIG1 0 -d CONFIG2 0 -d CONFIG3 0
set CONFIG=config0
)
if /i %2 EQU config1 (
set CONFIGFLAG=-d CONFIG0 0 -d CONFIG1 1 -d CONFIG2 0 -d CONFIG3 0
set CONFIG=config1
)
if /i %2 EQU config2 (
set CONFIGFLAG=-d CONFIG0 0 -d CONFIG1 0 -d CONFIG2 1 -d CONFIG3 0
set CONFIG=config2
)
if /i %2 EQU config3 (
set CONFIGFLAG=-d CONFIG0 0 -d CONFIG1 0 -d CONFIG2 0 -d CONFIG3 1
set CONFIG=config3
)

%ROOT3%asm56300 -l%1_%CONFIG%.ls -b -i %CODEDIR% -d DOWNLOAD HOST %CONFIGFLAG% -d WAVEFILE %WAVEFILE% %CODEDIR%TIM3.asm

%ROOT3%dsplnk -b TIM3.cld -v TIM3.cln 
del TIM3.cln

%ROOT3%cldlod TIM3.cld > %1_%CONFIG%.lod
del TIM3.cld
