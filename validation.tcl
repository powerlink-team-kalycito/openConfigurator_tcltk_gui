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
#  Validation::IsValidEntryData
# 
#  Arguments : input - string to be validate 
# 	
#  Results : 0 or 1
#
#  Description : Validates whether an entry contains only alphanumeric character and underscore
#---------------------------------------------------------------------------------------------------
proc Validation::IsValidEntryData {input} {
    if { ([string is wordchar $input] == 1 || [string match "*.*" $input] || [string match "*:*" $input]) && [string length $input] <= 32 } {
	    Validation::SetPromptFlag
	    return 1
    } else {
	    return 0
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
proc Validation::IsDec {input entryPath mode idx dataType} {
    set tempInput $input
    
    set stdDataType [ string toupper $dataType ]
    puts "Validation::IsDec dataType->$dataType stdDataType->$stdDataType"
    switch -- $stdDataType {
        BOOLEAN {
            set minLimit 0
            set maxLimit 1
	    set reqLengt 1
        }
        INTEGER8 {
            set minLimit -128
            set maxLimit 127
	    set reqLengt 3
        }
        UNSIGNED8 {
            set minLimit 0
            set maxLimit 255
	    set reqLengt 3
        }
        INTEGER16 {
            set minLimit -32768
            set maxLimit 32767
	    set reqLengt 5
        }
        UNSIGNED16 {
	    set minLimit 0
	    set maxLimit 65535
	    set reqLengt 5
        }
        INTEGER24 {
            set minLimit -8388608
            set maxLimit 8388607
	    set reqLengt 7
        }
        UNSIGNED24 {
            set minLimit 0
            set maxLimit 16777215
	    set reqLengt 8
        }
        INTEGER32 {
            set minLimit -2147483648
            set maxLimit 2147483647
	    set reqLengt 10
        }
        UNSIGNED32 {
            set minLimit 0
            set maxLimit 4294967295
	    set reqLengt 10
        }
        INTEGER40 {
            set minLimit -549755813888
            set maxLimit 549755813887
	    set reqLengt 12
        }
        UNSIGNED40 {
            set minLimit 0
            set maxLimit 1099511627775
	    set reqLengt 13
        }
        INTEGER48 {
            set minLimit -140737488355328
            set maxLimit 140737488355327
	    set reqLengt 15
        }
        UNSIGNED48 {
	    set minLimit 0
            set maxLimit 281474976710655
	    set reqLengt 15
        }
        INTEGER56 {
	    set minLimit -36028797018963968
            set maxLimit 36028797018963967
	    set reqLengt 17
        }
        UNSIGNED56 {
            set minLimit 0
            set maxLimit 72057594037927935
	    set reqLengt 17
        }
        INTEGER64 {
            set minLimit -9223372036854775808
            set maxLimit 9223372036854775807
	    set reqLengt 19
        }
        UNSIGNED64 {
            set minLimit 0
            set maxLimit 18446744073709551615
	    set reqLengt 20
        }
	default  {
		return 0
	}
    }
    
#    if { [string length $tempInput] > 20 || $tempInput > 18446744073709551615 || [Validation::CheckDecimalNumber $tempInput] == 0  } {
#	    return 0
#    } else {
#	    after 1 Validation::SetValue $entryPath $mode $idx $input
#	    Validation::SetPromptFlag
#	    return 1
#    }
    if { [string match -nocase "INTEGER*" $stdDataType] && [string match -nocase "-?*" $tempInput] } {
	set reqLengt [expr $reqLengt+1]
    }
    if { $tempInput == "" || ([Validation::CheckDecimalNumber $tempInput] == 1 &&  $tempInput <= $maxLimit && $tempInput >= $minLimit && [string length $tempInput] <= $reqLengt ) || ($tempInput == "-" && [string match -nocase "INTEGER*" $stdDataType]) } {
	    after 1 Validation::SetValue $entryPath $mode $idx $input
	    Validation::SetPromptFlag
	    return 1
    } else {
	    return 0
    }
}

#---------------------------------------------------------------------------------------------------
#  Validation::CheckDecimalNumber
# 
#  Arguments : input - string to be validated
#
#  Results : 0 or 1
#
#  Description : Validates string is containing only numbers 0 to 9
#---------------------------------------------------------------------------------------------------
proc Validation::CheckDecimalNumber {input} {
    set firstExp {-|[0-9]}
    set exp {[0-9]}
    for {set checkCount 0} {$checkCount < [string length $input]} {incr checkCount} {
	if { $checkCount == 0 } {
	    set res [regexp -- $firstExp [string index $input $checkCount] ]
	} else {
	    set res [regexp -- $exp [string index $input $checkCount] ]
	}
        if {$res == 1} {
	        #continue with process
        } else {
	        return 0
        }
    }
    return 1
}

#---------------------------------------------------------------------------------------------------
#  Validation::CheckHexaNumber
# 
#  Arguments : input - string to be validated
#
#  Results : 0 or 1
#
#  Description : Validates string is containing only numbers 0 to 9 and characters a to f
#---------------------------------------------------------------------------------------------------
proc Validation::CheckHexaNumber {input} {
    set exp {[0-9]|[a-f]|[A-F]}
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
#  Validation::CheckBitNumber
# 
#  Arguments : input - string to be validated
#
#  Results : 0 or 1
#
#  Description : Validates string is containing only 0 and 1
#---------------------------------------------------------------------------------------------------
proc Validation::CheckBitNumber {input} {
    if { [string length $input] > 8 } {
	return 0
    }
    set exp {0|1}
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
#  Validation::BintoHex
#   
# Arguments:  bin - number in binary format
#  
# Results: hexadecimal number
#  
#---------------------------------------------------------------------------------------------------
proc Validation::BintoHex {binNo} {
    ## No sanity checking is done
    array set template {
	0000 0 0001 1 0010 2 0011 3 0100 4
	0101 5 0110 6 0111 7 1000 8 1001 9
	1010 a 1011 b 1100 c 1101 d 1110 e 1111 f
    }
    set diff [expr {4-[string length $binNo]%4}]
    if {$diff != 4} {
        set binNo [format %0${diff}d$binNo 0]
    }
    regsub -all .... $binNo {$template(&)} hex
    return [subst $hex]
}

#---------------------------------------------------------------------------------------------------
#  Validation::IsHex
# 
#  Arguments : input     - string 
#              preinput  - valid previous entry
#              mode      - Mode of the entry (insert - 1 / delete - 0) 
#              idx       - Index where the character was inserted or deleted  
#
#  Results : 0 or 1
#
#  Description : Validates whether an entry is an integer and does not exceed specified range.
#---------------------------------------------------------------------------------------------------
proc Validation::IsHex {input preinput entryPath mode idx dataType} {

    set stdDataType [ string toupper $dataType ]
    switch -- $stdDataType {
        BOOLEAN {
            set minLimit 0x0
            set maxLimit 0x1
	    set reqLengt 1
        }
        INTEGER8 {
            set minLimit 0x0
            set maxLimit 0xFF
	    set reqLengt 2
        }
        UNSIGNED8 {
            set minLimit 0x0
            set maxLimit 0xFF
	    set reqLengt 2
        }
        INTEGER16 {
	    set minLimit 0x0
            set maxLimit 0xFFFF
	    set reqLengt 4
        }
        UNSIGNED16 {
            set minLimit 0x0
            set maxLimit 0xFFFF
	    set reqLengt 4
        }
        INTEGER24 {
            set minLimit 0x0
            set maxLimit 0xFFFFFF
	    set reqLengt 6
        }
        UNSIGNED24 {
            set minLimit 0x0
            set maxLimit 0xFFFFFF
	    set reqLengt 6
        }
        INTEGER32 {
            set minLimit 0x0
            set maxLimit 0xFFFFFFFF
	    set reqLengt 8
        }
        UNSIGNED32 {
            set minLimit 0x0
            set maxLimit 0xFFFFFFFF
	    set reqLengt 8
        }
        INTEGER40 {
            set minLimit 0x0
            set maxLimit 0xFFFFFFFFFF
	    set reqLengt 10
        }
        UNSIGNED40 {
            set minLimit 0x0
	    set maxLimit 0xFFFFFFFFFF
	    set reqLengt 10
        }
        INTEGER48 {
            set minLimit 0x0
            set maxLimit 0xFFFFFFFFFFFF
	    set reqLengt 12
        }
        UNSIGNED48 {
            set minLimit 0x0
            set maxLimit 0xFFFFFFFFFFFF
	    set reqLengt 12
        }
        INTEGER56 {
            set minLimit 0x0
            set maxLimit 0xFFFFFFFFFFFFFF
	    set reqLengt 14
        }
        UNSIGNED56 {
            set minLimit 0x0
            set maxLimit 0xFFFFFFFFFFFFFF
	    set reqLengt 14
        }
        INTEGER64 {
            set minLimit 0x0
	    set maxLimit 0xFFFFFFFFFFFFFFFF
	    set reqLengt 16
        }
        UNSIGNED64 {
            set minLimit 0x0
            set maxLimit 0xFFFFFFFFFFFFFFFF
	    set reqLengt 16
        }
        REAL32 {
            set minLimit 0x0
            set maxLimit 0xFFFFFFFF
	    set reqLengt 8
        }
        REAL64 {
            set minLimit 0x0
            set maxLimit 0xFFFFFFFFFFFFFFFF
	    set reqLengt 16
        }
	default  {
		return 0
	}
    }

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
    
    if { $tempInput == "" || ([string is xdigit $tempInput ] == 1 && [expr 0x$tempInput <= $maxLimit] && [expr 0x$tempInput >= $minLimit] && [string length $tempInput] <= $reqLengt )} {
	set tempInput 0x$tempInput
	after 1 Validation::SetValue $entryPath $mode $idx $tempInput
	Validation::SetPromptFlag
	return 1
    } else { 
	    return 0
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
#              mode      - indicaties deletion or insertion of character
#              idx       - index where cursor is set
#              input     - input to be validated
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
#  Arguments : input    - input to be validated
#              dataType - data type of the input
#	      
#  Results : converted value
#
#  Description : converts the input decimal value into hexadecimal value
#---------------------------------------------------------------------------------------------------
proc Validation::InputToHex {input dataType} {
    set stdDataType [ string toupper $dataType ]
    if { $input == 0 } {
	    #if value is zero return as it is
	    return [list 0x$input pass]
    } elseif { $input == "" || [Validation::CheckDecimalNumber $input ] == 0 } {
	    #if value empty or not an int return back same value
	    return [list $input fail]
    }
    
        
    if { $input < 0 } {
	switch -- $stdDataType {
	    INTEGER8 {
	        set maxLimit 256
	    }
	    INTEGER16 {
	        set maxLimit 65536
	    }
	    INTEGER24 {
	        set maxLimit 16777216
	    }
	    INTEGER32 {
	        set maxLimit 4294967296
	    }
	    INTEGER40 {
	        set maxLimit 1099511627776
	    }
	    INTEGER48 {
	        set maxLimit 281474976710656
	    }
	    INTEGER56 {
	        set maxLimit 72057594037927936
	    }
	    INTEGER64 {
	        set maxLimit 18446744073709551616
	    }
	    default  {
	        return [list $input fail]
	    }
	}
	#removing negative sign
	set input [string range $input 1 end]
	 #counting the leading zero if they are present
	set zeroCount [NoteBookManager::CountLeadZero $input] 
	set input [string trimleft $input 0]
	set input [expr $maxLimit-$input]
	puts "conv neg input->$input"
    } else {
	 #counting the leading zero if they are present
	set zeroCount [NoteBookManager::CountLeadZero $input] 
	set input [string trimleft $input 0]
    }
    
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
		    return [list $input fail]
	    } else {
		    #appending trimmed leading zero if any
		    set input [ NoteBookManager::AppendZero $input [expr $zeroCount+[string length $input] ] ] 
		    set input 0x$input
	    }
    }
    return [list $input pass]
}

#---------------------------------------------------------------------------------------------------
# Validation::InputToDec
# 
#  Arguments : input    - input to be validated
#              dataType - data type of the input
#	      
#  Results : converted value
#
#  Description : converts the input hexadecimal value into decimal value
#---------------------------------------------------------------------------------------------------
proc Validation::InputToDec {input dataType} {
    set stdDataType [string toupper $dataType]
    set signFlag 0
    puts "Validation::InputToDec dataType->$dataType stdDataType->$stdDataType"
    if { $input == 0 } {
        # value is zero 
	return [list $input pass]
    } elseif { $input != "" } {
        #counting the leading zero if they are present
        set zeroCount [NoteBookManager::CountLeadZero $input]
        if { [ catch {set input [expr 0x$input]} ] } {
            #error raised should not convert
	    return [list $input fail]
        } else {
	    #convert value according to datatype
	    if {[string match -nocase "INTEGER*" $stdDataType]} {
		switch -- $stdDataType {
		    INTEGER8 {
			set posLimit 127
		        set maxLimit 256
		    }
		    INTEGER16 {
			set posLimit 32767
		        set maxLimit 65536
		    }
		    INTEGER24 {
			set posLimit 8388607
		        set maxLimit 16777216
		    }
	            INTEGER32 {
			set posLimit 2147483647
	                set maxLimit 4294967296
	            }
	            INTEGER40 {
			set posLimit 549755813887
	                set maxLimit 1099511627776
	            }
		    INTEGER48 {
			set posLimit 140737488355327
	                set maxLimit 281474976710656
	            }
	            INTEGER56 {
			set posLimit 36028797018963967
	                set maxLimit 72057594037927936
	            }
	            INTEGER64 {
			set posLimit 9223372036854775807
	                set maxLimit 18446744073709551616
	            }
		}
		if { $input > $posLimit } {
		    set input [expr $maxLimit-$input]
		    set signFlag 1
		}
	    }
            #appending trimmed leading zero if any
            set input [ NoteBookManager::AppendZero $input [expr $zeroCount+[string length $input] ] ]
	    if { $signFlag == 1} {
		#since it is a negative number append minus sign
		set input -$input
	    }
	    return [list $input pass]
        }
    } else {
	return [list "" pass]
    }
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