:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: (c) Kalycito Infotech Private Limited
::
::  Project:		openCONFIGURATOR - written by Kalycito 
::
::	File name:		TransferCDC.bat
::
::  Description:  
::	Copies the file set to "Src' variable to the folder set to "Dest" variable
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

:: Set the Source file
set Src= ..\cdc_xap\mnobd.cdc
::echo The variable is "%Src%"

:: Set the Destination folder file
set Dest=Dump
::echo The variable is "%Dest%"

if "%Src%" == "" goto error1
if "%Dest%" == "" goto error2

:: xcopy "%1" "%2" /S /E /H

xcopy "%Src%" "%Dest%"
goto endofprogram
:error1
echo You must provide source
echo Syntax:
echo %0 source destination
goto endofprogram
:error2
echo You must provide destination
echo Syntax:
echo %0 source destination
goto endofprogram
:endofprogram
PAUSE