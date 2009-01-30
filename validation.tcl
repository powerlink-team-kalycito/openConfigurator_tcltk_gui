###############################################################################################
#
#
# NAME:     validation.tcl
#
# PURPOSE:  purpose description
#
# AUTHOR:   Kalycito Infotech Pvt Ltd
#
# COPYRIGHT NOTICE:
#
#********************************************************************************
# (c) Kalycito Infotech Private Limited
#
#  Project:      openCONFIGURATOR 
#
#  Description:  Contains the validations used in appliaction
#
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
#********************************************************************************
#
#  REVISION HISTORY:
# $Log:      $
###############################################################################################

###############################################################################################
#proc IsIp
#Input       : input, type
#Output      : 0 or 1
#Description : Validates whether an entry is IP address
###############################################################################################
proc IsIP {str type} {
   # modify these if you want to check specific ranges for
   # each portion - now it look for 0 - 255 in each
   set ipnum1 {\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]}
   set ipnum2 {\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]}
   set ipnum3 {\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]}
   set ipnum4 {\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]}
   set fullExp {^($ipnum1)\.($ipnum2)\.($ipnum3)\.($ipnum4)$}
   set partialExp {^(($ipnum1)(\.(($ipnum2)(\.(($ipnum3)(\.(($ipnum4)?)?)?)?)?)?)?)?$}
   set fullExp [subst -nocommands -nobackslashes $fullExp]
   set partialExp [subst -nocommands -nobackslashes $partialExp]
   if [string equal $type focusout] {
      if [regexp -- $fullExp $str] {
         return 1
      } else {
         #tk_messageBox -message "IP is NOT complete!" -title "IP Address" -parent .projconfig
         return 0
      }
   } elseif [string equal $type dstry] {
      if [regexp -- $fullExp $str] {
         return 1
      } else {
         #tk_messageBox -message "IP is NOT complete!" -title "IP Address" -parent .projconfig
         return 0
      }
   } else {
      return [regexp -- $partialExp $str]
   }
} 

###############################################################################################
#proc IsInt
#Input       : input, type
#Output      : 0 or 1
#Description : Validates whether an entry is an Integer
###############################################################################################
proc IsInt {input type} {
	if {[expr {[string len $input] <= 3} && {[string is int $input]}]} {
		return 1 
	} else {
		return 0
	} 
}

###############################################################################################
#proc IsValidStr
#Input       : input, type
#Output      : 0 or 1
#Description : Validates whether an entry is a valid string
###############################################################################################
proc IsValidStr {input} {
	if { [string is wordchar $input] == 0 || [string length $input] > 32 } {
		return 0
	} else {
		return 1
	}
}

###############################################################################################
#proc IsDec
#Input       : input
#Output      : 0 or 1
#Description : Validates whether an entry is a integer and does not exceed specified range
###############################################################################################
proc IsDec {input tmpValue} {
	puts "IsDec test"
	set tempInput [string trimleft $input 0]		
	

	if { [string is int $tempInput] == 0 } {
		return 0
	} else {
		after 1 SetValue $tmpValue $input
		return 1
	}
}

###############################################################################################
#proc IsHex
#Input       : input
#Output      : 0 or 1
#Description : Validates whether an entry is a hexa decimal and does not exceed specified range
###############################################################################################
proc IsHex {input tmpValue} {
	puts "IsHex test"
	puts "input->$input"
	#set tmpVar [$tmpValue cget -textvariable]
	if {[string match -nocase "0x*" $input]} {
		set tempInput [string range $input 2 end]
	} elseif {[string match -nocase "x*" $input]} {
		set tempInput [string range $input 1 end]
	} else {
		set tempInput $input
	}


	if { [string is xdigit $tempInput ] == 0 } {
		return 0
	} else {
		set tempInput 0x$tempInput
		after 1 SetValue $tmpValue $tempInput
		#puts "SetValue called"
		return 1
	}
}

############for test ########
proc SetValue {tmpValue str } {
	#puts "SetValue invoked"
	set tmpVar [$tmpValue cget -textvariable]
	$tmpValue configure -validate none
	puts "SetValue->[$tmpValue cget -vcmd]"
	$tmpValue delete 0 end
	$tmpValue insert 0 $str
	$tmpValue configure -validate key
}

