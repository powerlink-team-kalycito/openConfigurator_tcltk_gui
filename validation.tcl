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
proc Validation::IsDec {input entryPath mode idx {dataType ""}} {
    global UPPER_LIMIT
    global LOWER_LIMIT
    set tempInput $input
    
    set stdDataType [ string toupper $dataType ]
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
    

    if { [string match -nocase "INTEGER*" $stdDataType] && [string match -nocase "-?*" $tempInput] } {
	set reqLengt [expr $reqLengt+1]
    }
    if { $tempInput == "" || ([Validation::CheckDecimalNumber $tempInput] == 1 &&  $tempInput <= $maxLimit && $tempInput >= $minLimit && [string length $tempInput] <= $reqLengt ) || ($tempInput == "-" && [string match -nocase "INTEGER*" $stdDataType]) } {
        ##if { $tempInput != ""} {
        #if { [string match "*.en_value1" $entryPath] } {
        #    set limitResult [CheckAgainstLimits $entryPath $tempInput $dataType]
        #    if { [lindex $limitResult 0] == 0 } {
        #        return 0
        #    }
        #}
        ##}
    	if {[string match "*.en_lower1" $entryPath] && $tempInput != "-"} {
            set LOWER_LIMIT $tempInput
        } elseif {[string match "*.en_upper1" $entryPath] && $tempInput != "-"} {
            set UPPER_LIMIT $tempInput
        }
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
#  Validation::HextoBin
#   
# Arguments:  hexNo - number in hexadecimal format
#  
# Results: binary number
#  
#---------------------------------------------------------------------------------------------------
proc Validation::HextoBin {hexNo} {
    set t [list 0 0000 1 0001 2 0010 3 0011 4 0100 \
	    5 0101 6 0110 7 0111 8 1000 9 1001 \
	    a 1010 b 1011 c 1100 d 1101 e 1110 f 1111 \
	    A 1010 B 1011 C 1100 D 1101 E 1110 F 1111]
    regsub {^0[xX]} $hexNo {} hexNo
    return [string map -nocase $t $hexNo]
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
proc Validation::IsHex {input preinput entryPath mode idx {dataType ""}} {
    global LOWER_LIMIT
    global UPPER_LIMIT
    
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
		    set idx [expr $idx+2]
	    }
    }
    
    if { $tempInput == "" || ([string is xdigit $tempInput ] == 1 && [expr 0x$tempInput <= $maxLimit] && [expr 0x$tempInput >= $minLimit] && [string length $tempInput] <= $reqLengt )} {
        ##if { $tempInput != "" } {
        #if { [string match "*.en_value1" $entryPath] } {
        #    set limitResult [CheckAgainstLimits $entryPath 0x$tempInput $dataType]
        #    if { [lindex $limitResult 0] == 0 } {
        #        return 0
        #    }
        #}
        ##}
	set tempInput 0x$tempInput
	if {[string match "*.en_lower1" $entryPath] && $tempInput != "0x"} {
            set LOWER_LIMIT $tempInput
        } elseif {[string match "*.en_upper1" $entryPath] && $tempInput != "0x"} {
            set UPPER_LIMIT $tempInput
        }
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
    
    #puts "IsTableHex::: entryPath:$entryPath, mode:$mode, idx:$idx, input:$input preinput:$preinput"
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
		    set idx [expr $idx+2]
	    }
    }

    if {[string is xdigit $input] == 0 || [string length $input] > $reqLen } {
	    return 0
    } else {
		if { $columnIndex == 1} {
			#for editing node id
			after 1 Validation::SetTableValueNodeid $tablePath $rowIndex $columnIndex $entryPath $mode $idx 0x$input
		} else {
			after 1 Validation::SetTableValue $entryPath $mode $idx 0x$input
		}
	
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
    
    #puts "SetTableValue::: entryPath:$entryPath, mode:$mode, idx:$idx, input:$input "
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

proc Validation::SetTableComboValue { input tablePath rowIndex columnIndex entryPath} {
    global populatedCommParamList
	switch -- $columnIndex {
		0 {
			# Do nothing for Sno
		}
		1 {
			#set enty [Widget::subcget $tablePath .e]
			#$entryPath configure -editable no
			if { [string length $input] < 3 || [string length $input] > 4 } {
				return 0
			}

			foreach tempList $populatedCommParamList {
				set rowlist [lindex $tempList 2]
				# puts "rowlist: $rowlist"
				set chkRslt [lsearch $rowlist $rowIndex]
				if { $chkRslt != -1} {

					foreach indRow $rowlist {
						if { $indRow == $rowIndex } {
							continue;
						}
						$tablePath cellconfigure $indRow,$columnIndex -text "$input"
					}
					return 0;
				} else {
				}
			}
		}
		2 {
			# sidx and length should be set empty after index is edited or modified
			$tablePath cellconfigure $rowIndex,3 -text "0x"
			$tablePath cellconfigure $rowIndex,4 -text "0x"
		}
		3 {
			# length should be set empty after sidx is modified or edited
			$tablePath cellconfigure $rowIndex,4 -text "0x"
		}
		4 {
			#puts "tablePath: $tablePath,"
			#puts "rowIndex: $rowIndex, columnIndex: $columnIndex, input: $input"
			if {[string length $input] != 6} {
				return 0;
			}
			foreach tempList $populatedCommParamList {
				set rowlist [lindex $tempList 2]
				#puts "rowlist: $rowlist"
				set chkRslt [lsearch $rowlist $rowIndex]
				if { $chkRslt != -1} {
					set maxRow [llength $rowlist]
					#puts "maxRow: $maxRow"
					set counter 1
					foreach indRow $rowlist {
						# while 1a00 has one index
						if { $counter == 1 } {
							#puts "counter == 1"
							# 1st subindex in an channel for which offset is 0x0000
							$tablePath cellconfigure $indRow,5 -text "0x0000"
							set offsetVal [$tablePath cellcget $indRow,5 -text]
							if { $indRow == $rowIndex } {
								set lengthVal $input
							} else {
								set lengthVal [$tablePath cellcget $indRow,4 -text]    
							}
							#puts "offsetVal: $offsetVal, lengthVal: $lengthVal"
						} elseif { $counter == $maxRow } {
							#puts "counter == maxRow"
							#no need to manipulate and set offset value to next row if it is a last row
							set totalOffset [expr $offsetVal+$lengthVal]
							#puts "totalOffset: $totalOffset"
							set totalOffsethex 0x[NoteBookManager::AppendZero [string toupper [format %x $totalOffset]] 4]
							#puts "totalOffsethex: $totalOffsethex"
							$tablePath cellconfigure $indRow,5 -text "$totalOffsethex"
						} elseif { $indRow == $rowIndex } {
							#puts "indRow == rowIndex"
							set totalOffset [expr $offsetVal+$lengthVal]
							#puts "totalOffset: $totalOffset"
							set totalOffsethex 0x[NoteBookManager::AppendZero [string toupper [format %x $totalOffset]] 4]
							$tablePath cellconfigure $indRow,5 -text "$totalOffsethex"
							set offsetVal [$tablePath cellcget $indRow,5 -text]
							#puts "offsetVal: $offsetVal"
							set lengthVal $input
							#puts "inputlengthval: $lengthVal"
						} else {
							#puts "Else"
							set totalOffset [expr $offsetVal+$lengthVal]
							#puts "totalOffset: $totalOffset"
							set totalOffsethex 0x[NoteBookManager::AppendZero [string toupper [format %x $totalOffset]] 4]
							#puts "totalOffsethex: $totalOffsethex"
							$tablePath cellconfigure $indRow,5 -text "$totalOffsethex"
							set offsetVal [$tablePath cellcget $indRow,5 -text]
							set lengthVal [$tablePath cellcget $indRow,4 -text]
							#puts "offsetVal: $offsetVal, lengthVal: $lengthVal"
						}
						incr counter
					}
				} else {

				}
			}
		}
		5 {
		    # do nothing for offset
		}
	}
    return 0
}

proc Validation::SetTableValueNodeid {tablePath rowIndex columnIndex entryPath mode idx input} {
	global populatedCommParamList

	Validation::SetTableValue $entryPath $mode $idx $input
	
	foreach tempList $populatedCommParamList {
		set rowlist [lindex $tempList 2]
		#puts "rowlist: $rowlist"
		set chkRslt [lsearch $rowlist $rowIndex]
		if { $chkRslt != -1} {
		
			foreach indRow $rowlist {
				if { $indRow == $rowIndex } {
					continue;
				}
				$tablePath cellconfigure $indRow,$columnIndex -text "$input"
			}
			return;
		} else {
			
		}
	}
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
    } elseif { $input == "-" } {
	    return [list "" pass]
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
			#negative number should be an integer
	        return [list $input fail]
	    }
	}
	#removing negative sign
	set input [string range $input 1 end]
	 #counting the leading zero if they are present
	set zeroCount [NoteBookManager::CountLeadZero $input] 
	set input [string trimleft $input 0]
	set input [expr $maxLimit-$input]
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


#---------------------------------------------------------------------------------------------------
# Validation::CheckDatatypeValue
# 
#  Arguments : dataType - datatype against which value to be checked
#              radioSel - radiobutton selection
#              value    - vlaue to be checked
#	      
#  Results : fail and error message or pass with value
#
#  Description : reset the flag checked during prompt 
#---------------------------------------------------------------------------------------------------
proc Validation::CheckDatatypeValue {entryPath dataType radioSel value} {
    if { [string match -nocase "INTEGER*" $dataType] || [string match -nocase "UNSIGNED*" $dataType] || [string match -nocase "BOOLEAN" $dataType ] } {
        #need to convert
         if {$value != ""} {
            if { $radioSel == "hex" } {
                #it is hex value trim leading 0x
                if {[string match -nocase "0x*" $value]} {
                    set value [string range $value 2 end]
                }
                set value [string toupper $value]
                if { $value == "" } {
                    set value ""
                } else {
                    set value 0x$value
                }
            } elseif { $radioSel == "dec" } {
                #is is dec value convert to hex
                set value [lindex [Validation::InputToHex $value $dataType] 0]
                if { $value == "" } {
                    set value ""
                } else {
                    #0x is appended to represent it as hex
                    set value [string range $value 2 end]
                    set value [string toupper $value]
                    set value 0x$value
                }
            } else {
                #invalid condition
            }
        }
    } elseif { [string match -nocase "BIT" $dataType] } {
        if {$value != ""} {
            #convert value to hex and save
            set value 0x[Validation::BintoHex $value]
        }
        #continue
    } elseif { [string match -nocase "REAL*" $dataType] } {
        if { [string match -nocase "0x" $value] } {
            set value ""
        } else {
            #continue    
        }
    } elseif { $dataType == "IP_ADDRESS" } {
        set result [$entryPath validate]
        if {$result == 0} {
            #tk_messageBox -message "IP address not complete\nValues not saved" -title Warning -icon warning -parent .
            Validation::ResetPromptFlag
            return [list fail "IP address not complete\nValues not saved"]
        }
    } elseif { $dataType == "MAC_ADDRESS" } {
        set result [$entryPath validate]
        if {$result == 0} {
            #tk_messageBox -message "MAC address not complete\nValues not saved" -title Warning -icon warning -parent .
            Validation::ResetPromptFlag
            return [list fail "MAC address not complete\nValues not saved"]
        }
    } elseif { $dataType ==  "Visible_String" } {
        #continue
    }	elseif { $dataType ==  "Octet_String" } {
        #continue
    }
    return [list pass $value]
}

#---------------------------------------------------------------------------------------------------
#  Validation::CheckCnNodeNumber
# 
#  Arguments : input - string to be validated
#
#  Results : 0 or 1
#
#  Description : Validates string is containing only numbers 1 to 239
#---------------------------------------------------------------------------------------------------
proc Validation::CheckCnNodeNumber {input} {
    
    #
    #if { (([string is int $input] == 1) && ($input >= 1) && ($input <= 254) && ($input != 240)) || ($input == "") } { }
    #
    if { ( ([string is int $input] == 1) && ($input >= 1) && ($input <= 239) ) || ($input == "") } {
        if { $input != "" } {
            Validation::SetPromptFlag
        }
        return 1    
    } else {
        bell
        return 0
    }
}

#---------------------------------------------------------------------------------------------------
#  Validation::CheckForceCycleNumber
# 
#  Arguments : input - string to be validated
#              prescalerLimit - the vale of multiplex prescaler value
#
#  Results : 0 or 1
#
#  Description : Validates string is containing only numbers 1 to prescalerLimit
#---------------------------------------------------------------------------------------------------
proc Validation::CheckForceCycleNumber {input prescalerLimit} {
    if { ( ([string is int $input] == 1) && ($input >= 1) && ($input <= $prescalerLimit) ) || ($input == "") } {
        if { $input != "" } {
            Validation::SetPromptFlag
        }
        return 1    
    } else {
        return 0
    }
}

#---------------------------------------------------------------------------------------------------
#  Validation::ValidatePollRespTimeoutMinimum
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
proc Validation::ValidatePollRespTimeoutMinimum {input entryPath mode idx validationType presponseActualCycleTimeValue presponseLimitMinimumCycleTimeValue {dataType ""} InterchangeParameterFlag} {

	if { $InterchangeParameterFlag == "1" } {
		set presponseCycleTimeValue  $presponseActualCycleTimeValue 
	} else {
			set presponseCycleTimeValue  $presponseLimitMinimumCycleTimeValue
	} 

    if { ($input == "" ) || ([Validation::IsDec $input $entryPath $mode $idx $dataType] == 1) } {
        if { ($validationType == "focusout" || $validationType == "forced") } {
            if { ($input != "") && ($input >= $presponseCycleTimeValue) } {
                #for the poll response time out the user should only enter values
                #which is higher than the minimum value plus 25micro seconds
				if { $InterchangeParameterFlag == "1" } {
					$entryPath configure -validate key -vcmd "Validation::ValidatePollRespTimeoutMinimum \   %P $entryPath %d %i %V $presponseActualCycleTimeValue $presponseLimitMinimumCycleTimeValue $dataType 0"
					return 1
					}
				$entryPath configure -validate key -vcmd "Validation::ValidatePollRespTimeoutMinimum \   %P $entryPath %d %i %V $presponseActualCycleTimeValue $presponseLimitMinimumCycleTimeValue $dataType 1"

            } else {
					if { $InterchangeParameterFlag == "1" } {
						$entryPath configure -validate key -vcmd "Validation::ValidatePollRespTimeoutMinimum \   %P $entryPath %d %i %V $presponseActualCycleTimeValue $presponseLimitMinimumCycleTimeValue $dataType 0"
					}
                return 0
            }
        }
        after 1 Validation::SetValue $entryPath $mode $idx $input
        return 1
    } else {
        return 0
    }
}

#---------------------------------------------------------------------------------------------------
#  Validation::CheckAgainstLimits
# 
#  Arguments : input     - input string 
# 	       entryPath - path of the entry widget(Actual alue text box)
#              dataType  - datatype of the input
#              idx       - Index where the character was inserted or deleted  
#
#  Results : 0 with error message or 1
#
#  Description : Validates the input value is within the limit range
#---------------------------------------------------------------------------------------------------
proc Validation::CheckAgainstLimits {entryPath input {dataType ""} } {
    global LOWER_LIMIT
    global UPPER_LIMIT

    if {$input == "-"} {
        return 1
    }
    if {$input == "" || [string match -nocase "0x" $input]} {
        if {[string match "*.en_lower1" $entryPath]} {
            set LOWER_LIMIT ""
        } elseif {[string match "*.en_upper1" $entryPath]} {
            set UPPER_LIMIT ""
        }
        return 1
    }
    
    if { [string match "*.en_value1" $entryPath] } {
        if { !($LOWER_LIMIT == "" || [string match -nocase "0x" $LOWER_LIMIT])} {
            if { [ catch { set lowerlimitResult [expr $input >= $LOWER_LIMIT] } ] } {
                return [list 0 "Error in comparing ($input) and lower limit($LOWER_LIMIT)"]
            }
            if { $lowerlimitResult == 0 } {
                return [list 0 "The input value ($input) is less than lowerlimit($LOWER_LIMIT)"]
            }
        }
        if { !($UPPER_LIMIT == "" || [string match -nocase "0x" $UPPER_LIMIT])} {
            if { [ catch { set uppperlimitResult [expr $input <= $UPPER_LIMIT] } ] } {
                return [list 0 "Error in comparing ($input) and lowerlimit($LOWER_LIMIT)"]
            }
            if { $uppperlimitResult == 0 } {
                return [list 0 "The input value ($input) is greater than upperlimit($UPPER_LIMIT)"]
            }
        }
    } elseif {[string match "*.en_lower1" $entryPath]} {
        if { !($UPPER_LIMIT == "" || [string match -nocase "0x" $UPPER_LIMIT]) } {
            if { [ catch { set uppperlimitResult [expr $input <= $UPPER_LIMIT] } ] } {
                return [list 0 "Error in comparing lowerlimit($input) and upperlimit($UPPER_LIMIT)"]
            }
            if { $uppperlimitResult == 0 } {
                return [list 0 "The lowerlimit ($input) is greater than upperlimit($UPPER_LIMIT)"]
            }
        }
        set LOWER_LIMIT $input
    } elseif {[string match "*.en_upper1" $entryPath]} {
        if { !($LOWER_LIMIT == "" || [string match -nocase "0x" $LOWER_LIMIT]) } {
            if { [ catch { set lowerlimitResult [expr $input >= $LOWER_LIMIT] } ] } {
                return [list 0 "Error in comparing upperlimit($input) and lowerlimit($UPPER_LIMIT)"]
            }
            if { $lowerlimitResult == 0 } {
                return [list 0 "The upperlimit($UPPER_LIMIT) is lesser than lowerlimit ($input)"]
            }
        }
        set UPPER_LIMIT $input
    }
    return 1
}

proc Validation::CheckValueIsInRange {input valueFormat {dataType ""}} {
    set stdDataType [ string toupper $dataType ]
    switch -- $stdDataType {
        BOOLEAN {
            set minDecLimit 0
            set maxDecLimit 1
	    set reqDecLengt 1
                    set minLimit 0x0
            set maxLimit 0x1
	    set reqLengt 1
        }
        INTEGER8 {
            set minDecLimit -128
            set maxDecLimit 127
            set reqDecLengt 3
            set minHexLimit 0x0
            set maxHexLimit 0xFF
            set reqHexLengt 2
        }
        UNSIGNED8 {
            set minDecLimit 0
            set maxDecLimit 255
            set reqDecLengt 3
            set minHexLimit 0x0
            set maxHexLimit 0xFF
            set reqHexLengt 2
        }
        INTEGER16 {
            set minDecLimit -32768
            set maxDecLimit 32767
            set reqDecLengt 5
    	    set minHexLimit 0x0
            set maxHexLimit 0xFFFF
            set reqHexLengt 4
        }
        UNSIGNED16 {
            set minDecLimit 0
            set maxDecLimit 65535
            set reqDecLengt 5
            set minHexLimit 0x0
            set maxHexLimit 0xFFFF
            set reqHexLengt 4
        }
        INTEGER24 {
            set minDecLimit -8388608
            set maxDecLimit 8388607
            set reqDecLengt 7
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFF
            set reqHexLengt 6
        }
        UNSIGNED24 {
            set minDecLimit 0
            set maxDecLimit 16777215
            set reqDecLengt 8
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFF
    	    set reqHexLengt 6
        }
        INTEGER32 {
            set minDecLimit -2147483648
            set maxDecLimit 2147483647
            set reqDecLengt 10
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFFFF
            set reqHexLengt 8
        }
        UNSIGNED32 {
            set minDecLimit 0
            set maxDecLimit 4294967295
            set reqDecLengt 10
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFFFF
            set reqHexLengt 8
        }
        INTEGER40 {
            set minDecLimit -549755813888
            set maxDecLimit 549755813887
            set reqDecLengt 12
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFFFFFF
            set reqHexLengt 10
        }
        UNSIGNED40 {
            set minDecLimit 0
            set maxDecLimit 1099511627775
            set reqDecLengt 13
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFFFFFF
            set reqHexLengt 10
        }
        INTEGER48 {
            set minDecLimit -140737488355328
            set maxDecLimit 140737488355327
            set reqDecLengt 15
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFFFFFFFF
            set reqHexLengt 12
        }
        UNSIGNED48 {
            set minDecLimit 0
            set maxDecLimit 281474976710655
            set reqDecLengt 15
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFFFFFFFF
            set reqHexLengt 12
        }
        INTEGER56 {
            set minDecLimit -36028797018963968
            set maxDecLimit 36028797018963967
            set reqDecLengt 17
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFFFFFFFFFF
            set reqHexLengt 14
        }
        UNSIGNED56 {
            set minDecLimit 0
            set maxDecLimit 72057594037927935
            set reqDecLengt 17
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFFFFFFFFFF
            set reqHexLengt 14
        }
        INTEGER64 {
            set minDecLimit -9223372036854775808
            set maxDecLimit 9223372036854775807
            set reqDecLengt 19
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFFFFFFFFFFFF
            set reqHexLengt 16
        }
        UNSIGNED64 {
            set minDecLimit 0
            set maxDecLimit 18446744073709551615
            set reqDecLengt 20
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFFFFFFFFFFFF
            set reqHexLengt 16
        }
        REAL32 {
            set minHexLimit 0x0
            set maxHexLimit 0xFFFFFFFF
            set reqHexLengt 8
        }
        REAL64 {
            set minLimit 0x0
            set maxHexLimit 0xFFFFFFFFFFFFFFFF
            set reqHexLengt 16
        }
        default  {
            return 0
        }
    }
}

#---------------------------------------------------------------------------------------------------
#  Validation::validateValueandLimit
# 
#  Arguments : input       - value input
# 	       lowerlimit  - lower limit value
#              upperlimit  - uppper limit value
#
#  Results : 0 with error message or 1
#
#  Description : Validates the limits against each other and the value is in range
#---------------------------------------------------------------------------------------------------
proc Validation::validateValueandLimit {input lowerlimit upperlimit} {
    global LOWER_LIMIT
    global UPPER_LIMIT
    
    foreach tempValue [list \
	[list $input "Input Value"] \
	[list $lowerlimit "Lower limit"] \
	[list $upperlimit "Upper limit"] \
	] {
	if { [lindex $tempValue 0] == "-"} {
	    return [0 "\"-\" cannot be saved for [lindex $tempValue 1]"]
	}
    }
    foreach tempValue [list \
	input lowerlimit upperlimit] {
	if {[string match -nocase "0X" [subst $[subst $tempValue]] ]} {
	    set $tempValue ""
	}
    }

    if { $lowerlimit != "" && $upperlimit != "" } {
	if { [ catch { set limitResult [expr $lowerlimit <= $upperlimit] } ] } {
	    return [list 0 "Error in comparing lowerlimit($lowerlimit) and upperlimit($upperlimit)"]
	}
	if { $limitResult == 0 } {
	    return [list 0 "The lowerlimit($lowerlimit) is greater than upperlimit($upperlimit)"]
	}
    }
    set LOWER_LIMIT $lowerlimit
    set UPPER_LIMIT $upperlimit
    
    if { $lowerlimit != "" && $input != "" } {
	if { [ catch { set lowerlimitResult [expr $input >= $LOWER_LIMIT] } ] } {
	    return [list 0 "Error in comparing input value($input) and lower limit($LOWER_LIMIT)"]
	}
	if { $lowerlimitResult == 0 } {
	    return [list 0 "The input value($input) is lesser than lowerlimit($LOWER_LIMIT)"]
	}
    }
	
        
    if { $upperlimit != "" && $input != "" } {
	if { [ catch { set uppperlimitResult [expr $input <= $UPPER_LIMIT] } ] } {
	    return [list 0 "Error in comparing lowerlimit($input) and upperlimit($UPPER_LIMIT)"]
	}
	if { $uppperlimitResult == 0 } {
	    return [list 0 "The input value($input) is greater than upperlimit($UPPER_LIMIT)"]
	}
    }
    return 1   
}
