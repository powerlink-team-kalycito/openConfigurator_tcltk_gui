####################################################################################################
#
#
# NAME:     validation.tcl
#
# PURPOSE:  Contains the validations used in application
#
# AUTHOR:   Kalycito Infotech Pvt Ltd
#
# COPYRIGHT NOTICE:
#
#***************************************************************************************************
# (c) Kalycito Infotech Private Limited
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
# $Log:      $
####################################################################################################

#---------------------------------------------------------------------------------------------------
#  NameSpace Declaration
#
#  namespace : Validation
#---------------------------------------------------------------------------------------------------
namespace eval Validation {
	
}

#---------------------------------------------------------------------------------------------------
#  Validation::IsIp
# 
#  Arguments : str  - string to be validate 
# 	           type - Type for validation 
#
#  Results : 0  or 1
#
#  Description : Validates whether an entry is IP address
#---------------------------------------------------------------------------------------------------
proc Validation::IsIP {str type} {
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
    if { [string equal $type focusout] || [string equal $type forced] } {
	    if [regexp -- $fullExp $str] {
		    Validation::SetPromptFlag
		    return 1
	    } else {
		    return 0
	    }
    } else {
	    if [regexp -- $partialExp $str] {
		    Validation::SetPromptFlag
		    return 1
	    } else {
		    return 0
	    }
	
	
    }
} 

#---------------------------------------------------------------------------------------------------
#  Validation::IsMAC
# 
#  Arguments : str  - string to be validate 
#              type - Type for validation 
#
#  Results : 0  or 1
#
#  Description : Validates whether an entry is MAC address
#---------------------------------------------------------------------------------------------------
proc Validation::IsMAC {str type} {
    set macnum {[0-9a-fA-F]}
    set len [string length $str]

    if { $type == "forced" } {
	    set len 17
    }

    if { $len == 0 } {
	    Validation::SetPromptFlag
	    return 1
    } else {
	    if {$len > 17} {
		    return 0
	    } else {
		    set valExp ""
		    set flag 1
		    for { set chk 0 } {$chk < $len} {incr chk} {
			    if { $flag == 1 } {
				    set valExp $valExp\($macnum)
				    set flag 2
			    } elseif { $flag == 2 } {
				    set valExp $valExp\($macnum)
				    set flag 3
			    } elseif { $flag == 3 } {
				    set valExp $valExp\:
				    set flag 1
			    } else {
			    }
		    }
		    set valExp [subst -nocommands -nobackslashes $valExp]
		    if [regexp -- $valExp $str] {
			    Validation::SetPromptFlag
			    return 1
		    } else {
			    return 0
		    }
	    }
    }
}

#---------------------------------------------------------------------------------------------------
#  Validation::IsInt
# 
#  Arguments : input - string to be validate 
# 	           type  - Type for validation 
#
#  Results : 0 or 1
#
#  Description : Validates whether an entry is integer and length is 3 used to validate CN node entry
#---------------------------------------------------------------------------------------------------
proc Validation::IsInt {input type} {
    if {[expr {[string length $input] <= 3} && {[string is int $input]}]} {
	    return 1 
    } else {
	    return 0
    } 
}

#---------------------------------------------------------------------------------------------------
#  Validation::IsValidStr
# 
#  Arguments : input - string to be validate 
# 	
#  Results : 0 or 1
#
#  Description : Validates whether an entry contains only alphanumeric character and underscore
#---------------------------------------------------------------------------------------------------
proc Validation::IsValidStr {input} {
    if { [string is wordchar $input] == 0 || [string length $input] > 32 } {
	    return 0
    } else {
	    Validation::SetPromptFlag
	    return 1
    }
}

#---------------------------------------------------------------------------------------------------
#  Validation::IsValidName
# 
#  Arguments : input - string (project name)
# 	
#  Results : 0 or 1
#
#  Description : Validates whether the string is valid project name.
#---------------------------------------------------------------------------------------------------
proc Validation::IsValidName { input } {
    if { [string is wordchar $input] == 0 || [string length $input] > 32 } {
	    return 0
    } else {
	    return 1
    }
}

#---------------------------------------------------------------------------------------------------
#  Validation::IsDec
# 
#  Arguments : input     - string (project name)
# 	           entryPath - path of the entry widget
#              mode      - Mode of the entry (insert - 1 / delete - 0) 
#              idx       - Index where the character was inserted or deleted  
#
#  Results : 0 or 1
#
#  Description : Validates whether an entry is an integer and does not exceed specified range.
#---------------------------------------------------------------------------------------------------
proc Validation::IsDec {input entryPath mode idx} {
    set tempInput $input
    #115792089237316195423570985008687907853269984665640564039457584007913129639935 is corresponding value of 64 F's
    if { [string length $tempInput] > 78 || $tempInput > 115792089237316195423570985008687907853269984665640564039457584007913129639935 || [Validation::CheckNumber $tempInput] == 0  } {
	    return 0
    } else {
	    after 1 Validation::SetValue $entryPath $mode $idx $input
	    Validation::SetPromptFlag
	    return 1
    }
}

#---------------------------------------------------------------------------------------------------
#  Validation::CheckNumber
# 
#  Arguments : input - string to be validated
#
#  Results : 0 or 1
#
#  Description : Validates string is containing only numbers 0 to 9
#---------------------------------------------------------------------------------------------------
proc Validation::CheckNumber {input} {
    set exp {[0-9]}
    for {set checkCount 0} {$checkCount < [string length $input]} {incr checkCount} {
        set res [regexp -- $exp [string index $input $checkCount] ]
        if {$res == 1} {
	        #continue with process
        } else {
	        return 0
        }
    }
    return 1
}

#---------------------------------------------------------------------------------------------------
#  Validation::IsHex
# 
#  Arguments : input     - string 
# 	           preinput  - valid previous entry
#              mode      - Mode of the entry (insert - 1 / delete - 0) 
#              idx       - Index where the character was inserted or deleted  
#
#  Results : 0 or 1
#
#  Description : Validates whether an entry is an integer and does not exceed specified range.
#---------------------------------------------------------------------------------------------------
proc Validation::IsHex {input preinput entryPath mode idx} {
    if {[string match -nocase "0x*" $input]} {
	    set tempInput [string range $input 2 end]
    } elseif {[string match -nocase "x*" $input]} {
	    set tempInput [string range $input 1 end]
    } else {
	    if {[string match -nocase "*0x*" $input]} {
		    #entry made before 0x
		    return 0
	    } elseif { $preinput == "0x[string range $input 1 end]" } {
		    #x is being deleted 
		    return 0
	    } else {
		    set tempInput $input
	    }
    }
    if { [string length $tempInput] > 64 || [string is xdigit $tempInput ] == 0 } {
	    return 0
    } else {
	    set tempInput 0x$tempInput
	    after 1 Validation::SetValue $entryPath $mode $idx $tempInput
	
	    Validation::SetPromptFlag
	
	    return 1
    }
}

#---------------------------------------------------------------------------------------------------
#  Validation::SetValue
# 
#  Arguments : entryPath - entry widget path in which value is inserted
#	           mode      - indicaties deletion or insertion of character
#	           idx       - index where cursor is set
#	           str       - string to be inserted
#
#  Results : 0 or 1
#
#  Description : Inserts the string in entry widget and placing the cursor in required place
#---------------------------------------------------------------------------------------------------
proc Validation::SetValue {entryPath mode idx {str no_input}  } {
    set tmpVar [$entryPath cget -textvariable]
    set state [$entryPath cget -state]
    $entryPath configure -state normal -validate none
    $entryPath delete 0 end
    if {$str != "no_input"} {
	    $entryPath insert 0 $str
	    if {$mode == 0} {
		    #value has been deleted
		    $entryPath icursor $idx
	    } else {
		    #value has been inserted
		    $entryPath icursor [expr $idx+1] 
	    }
    } else {
	    #entry box made empty no need to insert value	
    }
    $entryPath configure -state $state -validate key
}

#---------------------------------------------------------------------------------------------------
#  Validation::IsValidIdx
# 
#  Arguments : input       - input to be validated
#	           indexLength - required length
#
#  Results : 0 or 1
#
#  Description : Validates whether an entry is a index and does not exceed specified range
#---------------------------------------------------------------------------------------------------
proc Validation::IsValidIdx {input indexLength} {
    if {[string is xdigit $input] == 0 || [string length $input] > $indexLength } {
	    return 0
    } else {
	    return 1
    }
}

#---------------------------------------------------------------------------------------------------
#  Validation::IsTableHex
# 
#  Arguments : input       - input to be validated
#	           preinput    - previous validated input
#	           mode        - indicaties deletion or insertion of character
#              idx         - index where cursor is set
#	           reqLen      - required length
#	           tablePath   - tablelist widget path
#	           rowIndex    - row of the edited cell
#	           columnIndex - column of the edited cell
#	           entryPath   - embedded entry in tablelist
#
#  Results : -
#
#  Description : Validates whether an entry is a hexadecimal value and does not exceed specified range
#---------------------------------------------------------------------------------------------------
proc Validation::IsTableHex {input preinput mode idx reqLen tablePath rowIndex columnIndex entryPath} {
    if {[string match -nocase "0x*" $input]} {
	    set input [string range $input 2 end]
    } elseif {[string match -nocase "x*" $input]} {
	    set input [string range $input 1 end]
    } else {
	    if {[string match -nocase "*0x*" $input]} {
		    return 0
	    } elseif { $preinput == "0x[string range $input 1 end]" } {
		    #x is being deleted 
		    return 0
	    } else {
		    set input $input
	    }
    }

    if {[string is xdigit $input] == 0 || [string length $input] > $reqLen } {
	    return 0
    } else {
	    after 1 Validation::SetTableValue $entryPath $mode $idx 0x$input
	
	    Validation::SetPromptFlag
	
	    return 1
    }
}

#---------------------------------------------------------------------------------------------------
#  Validation::SetTableValue
# 
#  Arguments : entryPath - embedded entry in tablelist
#	           mode      - indicaties deletion or insertion of character
#	           idx       - index where cursor is set
#	           input     - input to be validated
#
#  Results : -
#
#  Description : Validates whether an entry is a hexadecimal value and does not exceed specified range
#---------------------------------------------------------------------------------------------------
proc Validation::SetTableValue { entryPath mode idx input } {
    $entryPath configure -validate none
    $entryPath delete 0 end
    $entryPath insert 0 $input
    if {$mode == 0} {
	    #value has been deleted
	    $entryPath icursor $idx
    } else {
	    #value has been inserted
	    $entryPath icursor [expr $idx+1] 
    }
    $entryPath configure -validate key
}

#---------------------------------------------------------------------------------------------------
# Validation::InputToHex
# 
#  Arguments : input - input to be validated
#	      
#  Results : converted value
#
#  Description : converts the input decinmal value into hexadecimal value
#---------------------------------------------------------------------------------------------------
proc Validation::InputToHex {input} {
    if { $input == 0 } {
	    #if value is zero return as it is
	    return 0x$input
    } elseif { $input == "" || [Validation::CheckNumber $input] == 0 } {
	    #if value empty or not an int return back same value
	    return $input
    }
     #counting the leading zero if they are present
    set zeroCount [NoteBookManager::CountLeadZero $input] 
    set input [string trimleft $input 0]
    if { $input > 4294967295 } {
	    set calcVal $input
	    set finalVal ""
	    while { $calcVal > 4294967295 } {
		    set quo [expr $calcVal / 4294967296 ]
		    set rem [expr $calcVal - ( $quo * 4294967296) ]
		    if { $quo  > 4294967295 } {
			    set finalVal [NoteBookManager::AppendZero [format %X $rem] 8]$finalVal		
		    } else {
			    set finalVal [NoteBookManager::AppendZero [format %X $rem] 8]$finalVal	
			    set finalVal [format %X $quo]$finalVal
		    }
		    set calcVal $quo
	    }
	    set input $finalVal
	    #appending trimmed leading zero if any
	    set input [ NoteBookManager::AppendZero $input [expr $zeroCount+[string length $input] ] ] 
	    set input 0x$input
    } else {
	    if { [catch {set input [format %X $input]}] } {
		    #raised an error in conversion
	    } else {
		    #appending trimmed leading zero if any
		    set input [ NoteBookManager::AppendZero $input [expr $zeroCount+[string length $input] ] ] 
		    set input 0x$input
	    }
    }
    return $input
}

#---------------------------------------------------------------------------------------------------
# Validation::SetPromptFlag
# 
#  Arguments :-
#	      
#  Results : -
#
#  Description : set the flag checked during prompt 
#---------------------------------------------------------------------------------------------------
proc Validation::SetPromptFlag {} {
    global chkPrompt
    set chkPrompt 1
}

#---------------------------------------------------------------------------------------------------
# Validation::ResetPromptFlag
# 
#  Arguments :-
#	      
#  Results : -
#
#  Description : reset the flag checked during prompt 
#---------------------------------------------------------------------------------------------------
proc Validation::ResetPromptFlag {} {
    global chkPrompt
    set chkPrompt 0
}