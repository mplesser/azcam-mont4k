rem Create .lod file for gen3 PCI board
rem MPL 01Jan06

rem Directories - change as needed
set ROOT=\azcam\MotorolaDSPTools\
set ROOT3=%ROOT%CLAS563\BIN\
set ROOT0=%ROOT%CLAS56\BIN\

%ROOT3%asm56300 -b -lpci3boot.ls -d DOWNLOAD HOST -d MASTER TIMING pci3boot.asm

%ROOT3%dsplnk -b pci3boot.cld -v pci3boot.cln

del pci3boot.cln

%ROOT3%cldlod pci3boot.cld > pci3.lod

del pci3boot.cld

rem pause

