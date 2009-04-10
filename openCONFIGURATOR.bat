@echo off
regedit /e %TEMP%.\reg1.txt HKEY_LOCAL_MACHINE\SOFTWARE\ActiveState\ActiveTcl
type %TEMP%.\reg1.txt | find "CurrentVersion" > %TEMP%.\reg2.txt
if %errorlevel%==0 (
@echo on
@echo Active Tcl found
@echo off 
) else (
@echo on
@echo Error! ActiveTcl not installed
@echo ActiveTcl can be downloaded at http://www.activestate.com/activetcl
@echo off
)
@echo off
type %TEMP%.\reg2.txt | find "CurrentVersion"
if %errorlevel%==0 (
@echo on
tclsh85 openCONFIGURATOR
@echo off
) else (
@echo on
@echo Error! No Active Tcl version matches found
@echo Please install ActiveTcl
PAUSE 
@echo off
)
@echo off
del %TEMP%.\reg1.txt
del %TEMP%.\reg2.txt