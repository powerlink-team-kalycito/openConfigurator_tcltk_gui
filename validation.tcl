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
	puts "IsIP type->$type"
	#set
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
	if {[string equal $type focusout] || [string equal $type dstry] || [string equal $type forced]} {
		if [regexp -- $fullExp $str] {
			SetPromptFlag
			return 1
		} else {
			return 0
		}
	} else {
		if [regexp -- $partialExp $str] {
			SetPromptFlag
			return 1
		} else {
			return 0
		}
		
		
	}
} 

proc IsMAC {str type} {
	#puts "str->$str type->$type"
	set macnum {[0-9a-fA-F]}
	set len [string length $str]
	#puts "len->$len"

	if { $type == "forced" } {
		set len 17
	}

	if { $len == 0 } {
		SetPromptFlag
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
					puts "\nthis condition never reach in IsMAC flag->$flag\n"
				}
			}
			#puts "valExp->$valExp\n"
			set valExp [subst -nocommands -nobackslashes $valExp]
			#puts "valExp->$valExp\n"
			if [regexp -- $valExp $str] {
				SetPromptFlag
				return 1
			} else {
				return 0
			}
		}
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
		SetPromptFlag
		return 1
	}
}

proc IsValidProjectName { input } {
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
proc IsDec {input tmpValue mode idx} {

	#set tempInput [string trimleft $input 0] ; #trimming zero leads to error	
	set tempInput $input
	#puts "IsDec test input->$input tempInput->$tempInput isint->[string is int $tempInput]"
	#340282366920938463463374607431768211455 is the corresponding value of 32 F's
	#115792089237316195423570985008687907853269984665640564039457584007913129639935 is corresponding value of 64 F's
	if { [string length $tempInput] > 78 || $tempInput > 115792089237316195423570985008687907853269984665640564039457584007913129639935 || [Int $tempInput] == 0  } {
		return 0
	} else {
		after 1 SetValue $tmpValue.en_value1 $mode $idx $input
		
		SetPromptFlag
		
		return 1
	}
}

proc Int {input} {
	set exp {[0-9]}
	#puts "\n\n********"
	for {set cnt 0} {$cnt < [string length $input]} {incr cnt} {
		#puts "string index $input $cnt ->[string index $input $cnt]"
		set res [regexp -- $exp [string index $input $cnt] ]
		if {$res == 1} {
			#continue with process
		} else {
			#res is zero 
			return 0
		}
	}
	#puts "*********\n\n"
	#tk_messageBox -message "Issue"
	
	SetPromptFlag
	
	return 1
}

###############################################################################################
#proc IsHex
#Input       : input
#Output      : 0 or 1
#Description : Validates whether an entry is a hexa decimal and does not exceed specified range
###############################################################################################
proc IsHex {input preinput tmpValue mode idx} {
	#puts "IsHex test"
	#puts "IsHex preinput->$preinput 0x[string range $input 1 end]"
	#set tmpVar [$tmpValue cget -textvariable]
	if {[string match -nocase "0x*" $input]} {
		set tempInput [string range $input 2 end]
	} elseif {[string match -nocase "x*" $input]} {
		set tempInput [string range $input 1 end]
	} else {
		if {[string match -nocase "*0x*" $input]} {
			return 0
		} elseif { $preinput == "0x[string range $input 1 end]" } {
			#x is being deleted 
			return 0
		} else {
			set tempInput $input
		}
	}
#puts "string length $tempInput ->[string length $tempInput]"

	if { [string length $tempInput] > 64 || [string is xdigit $tempInput ] == 0 } {
		return 0
	} else {
		set tempInput 0x$tempInput
		after 1 SetValue $tmpValue.en_value1 $mode $idx $tempInput
		#puts "SetValue called"
		
		SetPromptFlag
		
		return 1
	}
}

###############################################################################################
#proc SetValue
#Input       : input
#Output      : 0 or 1
#Description : #used to insert data into entry widget mainly for entry displaying actualValue
###############################################################################################
proc SetValue {tmpValue mode idx {str no_input}  } {
	puts "SetValue invoked mode->$mode idx->$idx str->$str"
	set tmpVar [$tmpValue cget -textvariable]
	set state [$tmpValue cget -state]
	$tmpValue configure -state normal -validate none
	#puts SetValue->[$tmpValue cget -vcmd]
	$tmpValue delete 0 end
	if {$str != "no_input"} {
		$tmpValue insert 0 $str
		if {$mode == 0} {
			#value has been deleted
			$tmpValue icursor $idx
		} else {
			#value has been inserted
			$tmpValue icursor [expr $idx+1] 
		}
	} else {
		#entry box made empty no need to insert value	
	}
	$tmpValue configure -state $state -validate key
}

###############################################################################################
#proc IsValidIdx
#Input       : input
#Output      : 0 or 1
#Description : Validates whether an entry is a index and does not exceed specified range
###############################################################################################
proc IsValidIdx {input len} {
	if {[string is xdigit $input] == 0 || [string length $input] > $len } {
		return 0
	} else {
		SetPromptFlag
		return 1
	}
}

###############################################################################################
#proc IsTableHex
#Input       : input
#Output      : 0 or 1
#Description : Validates whether an entry is a index and does not exceed specified range
###############################################################################################
proc IsTableHex {input preinput mode idx len tbl row col win} {
	#puts "tbl->$tbl==row->$row===col->$col"
	
	if {[string match -nocase "0x*" $input]} {
		set input [string range $input 2 end]
	} elseif {[string match -nocase "x*" $input]} {
		#puts "starting with hex"
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

	if {[string is xdigit $input] == 0 || [string length $input] > $len } {
		return 0
	} else {
		#puts "IsTableHex input->$input"
#		set no [string range [$tbl cellcget $row,0 -text] 2 end]
#		set mappEntr [string range [$tbl cellcget $row,3 -text] 2 end]
#		set index [string range [$tbl cellcget $row,4 -text] 2 end]
#		set subIndex [string range [$tbl cellcget $row,5 -text] 2 end]
#		set reserved [string range [$tbl cellcget $row,6 -text] 2 end]
#		set offset [string range [$tbl cellcget $row,7 -text] 2 end]
#		set length [string range [$tbl cellcget $row,8 -text] 2 end]
#  		switch -- $col {
#			3 {
#				set length [string range $input 0 3]
#				set offset [string range $input 4 7]
#				set reserved [string range $input 8 9]
#				set subIndex [string range $input 10 11]
#				set index [string range $input 12 15]
#				$tbl cellconfigure $row,4 -text 0x$index
#				$tbl cellconfigure $row,5 -text 0x$subIndex
#				$tbl cellconfigure $row,6 -text 0x$reserved
#				$tbl cellconfigure $row,7 -text 0x$offset
#				$tbl cellconfigure $row,8 -text 0x$length
#				after 1 SetTableValue $win $mode $idx 0x$input
#            			return 1
#        		}
#
#        		4 {
#				set mappEntr $length$offset$reserved$subIndex$input
#        		}
#
#	        	5 {
#				set mappEntr $length$offset$reserved$input$index	
#        		}
#        		6 {
#				set mappEntr $length$offset$input$subIndex$index	
#        		}
#        		7 {
#				set mappEntr $length$input$reserved$subIndex$index
#        		}
#       	 		8 {
#				set mappEntr $input$offset$reserved$subIndex$index
# 			}
#    		}
#		$tbl cellconfigure $row,3 -text 0x$mappEntr
		after 1 SetTableValue $win $mode $idx 0x$input
		
		SetPromptFlag
		
		return 1
	}
}

proc SetTableValue { win mode idx input } {
	$win configure -validate none
	$win delete 0 end
	$win insert 0 $input
	if {$mode == 0} {
		#value has been deleted
		$win icursor $idx
	} else {
		#value has been inserted
		$win icursor [expr $idx+1] 
	}
	$win configure -validate key
}

proc _ConvertHex {tmpVal} {
	
	puts "\n\n_ConvertHex invoked tmpVal->$tmpVal"
	
	if { $tmpVal == 0 } {
		#puts "tmpVal equal to zero\n"
		#do not trim any zero pass as it is
		return $tmpVal
	}
	
	set cnt [CntLeadZero $tmpVal] ; #counting the leading zero if they are present
	puts "after counting zero tmpVal->$tmpVal"
	set tmpVal [string trimleft $tmpVal 0]
	puts "tmpVal->$tmpVal cnt->$cnt"
	
	if { $tmpVal > 4294967295 } {
		set calcVal $tmpVal
		set finalVal ""
		while { $calcVal > 4294967295 } {
			set quo [expr $calcVal / 4294967296 ]
			puts "quo->$quo"
			set rem [expr $calcVal - ( $quo * 4294967296) ]
			puts "rem->$rem"
			if { $quo  > 4294967295 } {
				#set rem [AppendZero [format %X $rem] 8]	
				set finalVal [AppendZero [format %X $rem] 8]$finalVal		
				puts "rem->$rem...finalVal->$finalVal"
			} else {
				#set quo [AppendZero [format %X $quo] 8]
				set finalVal [AppendZero [format %X $rem] 8]$finalVal	
				puts "final val after appending	$finalVal"
				set finalVal [format %X $quo]$finalVal
				puts "quo->$quo...finalVal->$finalVal"
			}
			set calcVal $quo
			puts "calcVal->$calcVal"
		}
		set tmpVal $finalVal
		puts " AppendZero $tmpVal [expr $cnt+[string length $tmpVal] ] -> [ AppendZero $tmpVal [expr $cnt+[string length $tmpVal] ] ]"
		set tmpVal [ AppendZero $tmpVal [expr $cnt+[string length $tmpVal] ] ] ; #appending trimmed leading zero if any
		
	} else {
		#set cnt [CntLeadZero $tmpVal] ; #counting the leading zero if they are present
		#puts "cnt->$cnt"
		#set tempVal [string trimleft $tmpVal 0] ; #zero is trimmed otherwise considered as octal
		if { [catch {set tmpVal [format %X $tmpVal]}] } {
			puts "raised an error return the sent value itself tempVal->$tempVal"
			#set tmpVal [format %X $tmpVal] ; # TODO just to check what the error is REMOVE LATER
		} else {
			#set tmpVal $tempVal
			puts " AppendZero $tmpVal [expr $cnt+[string length $tmpVal] ] -> [ AppendZero $tmpVal [expr $cnt+[string length $tmpVal] ] ]"
			set tmpVal [ AppendZero $tmpVal [expr $cnt+[string length $tmpVal] ] ] ; #appending trimmed leading zero if any
			
		}
	}
	puts "**************\n\n"
	return $tmpVal
}

proc SetPromptFlag {} {
	global chkPrompt
	set chkPrompt 1
	puts "\tchkprompt SET\t"
	#set
}

proc ResetPromptFlag {} {
	global chkPrompt
	set chkPrompt 0
	puts "\tchkprompt RESET\t"
}