:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: (c) Kalycito Infotech Private Limited
::
::  Project:        openCONFIGURATOR - written by Kalycito 
::
::  File name:      TransferCDC.bat
::
::  Description:  
::  Copies the file set to "Src' variable to the folder set to "Dest" variable
::  For help on editing this file for the purpose of openCONFIGURATOR, please refer
::  to the User Manual document of openCONFIGURATOR
::
::  License:
::
::   Redistribution and use in source and binary forms, with or without
::   modification, are permitted provided that the following conditions
::   are met:
::
::   1. Redistributions of source code must retain the above copyright
::      notice, this list of conditions and the following disclaimer.
::
::   2. Redistributions in binary form must reproduce the above copyright
::      notice, this list of conditions and the following disclaimer in the
::      documentation and/or other materials provided with the distribution.
::
::   3. Neither the name of Kalycito Infotech Private Limited nor the names of 
::      its contributors may be used to endorse or promote products derived
::      from this software without prior written permission. For written
::      permission, please contact info@kalycito.com.
::
::   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
::   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
::   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
::   FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
::   COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
::   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
::   BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
::   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
::   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
::   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
::   ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
::   POSSIBILITY OF SUCH DAMAGE.
::
::   Severability Clause:
::
::       If a provision of this License is or becomes illegal, invalid or
::       unenforceable in any jurisdiction, that shall not affect:
::       1. the validity or enforceability in that jurisdiction of any other
::          provision of this License; or
::       2. the validity or enforceability in other jurisdictions of that or
::          any other provision of this License.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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