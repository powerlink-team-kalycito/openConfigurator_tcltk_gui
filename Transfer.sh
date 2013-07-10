####################################################################################################
#
#
#  NAME:     Transfer.sh
#
#  PURPOSE:  To copy file from source to destination
#
#  AUTHOR:   Kalycito Powerlink Team
#
#  Copyright :(c) Kalycito Infotech Private Limited
#
#***************************************************************************************************
#  COPYRIGHT NOTICE: 
#
#  Project:      openCONFIGURATOR 
#
#  License:
#
#    Redistribution and use in source and binary forms, with or without
#    modification, are permitted provided that the following conditions
#    are met:
#
#    1. Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
#    3. Neither the name of Kalycito Infotech Private Limited nor the names of 
#       its contributors may be used to endorse or promote products derived
#       from this software without prior written permission. For written
#       permission, please contact info@kalycito.com.
#
#    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#    POSSIBILITY OF SUCH DAMAGE.
#
#    Severability Clause:
#
#        If a provision of this License is or becomes illegal, invalid or
#        unenforceable in any jurisdiction, that shall not affect:
#        1. the validity or enforceability in that jurisdiction of any other
#           provision of this License; or
#        2. the validity or enforceability in other jurisdictions of that or
#           any other provision of this License.
#
#***************************************************************************************************
#
#  REVISION HISTORY:
#  
####################################################################################################

####################################################################################################
#Syntax:
# cp [options]... Source Dest
#
#Example:
# CdcSrc="/home/UserName/Documents/openCONFIGURATOR_Projects/Project1/cdc_xap/mnobd.cdc"
# CdcDest="/home/UserName/Desktop/openPOWERLINK/mnobd.cdc"
# 
# XapSrc="/home/UserName/Documents/openCONFIGURATOR_Projects/Project1/cdc_xap/xap.h"
# XapDest="/home/UserName/Desktop/openPOWERLINK/xap.h"
#
# Consult the user manual for Trouble shooting and for more explanation
#
####################################################################################################
#!/bin/sh
CdcSrc=""
CdcDest=""
#echo The cdc Source is $CdcSrc
#echo The cdc Destination is $CdcDest

XapSrc=""
XapDest=""
#echo The xap Source is $XapSrc
#echo The xap Destination is $XapDest

cp -rvf $CdcSrc $CdcDest
cp -rvf $XapSrc $XapDest
