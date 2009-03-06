###############################################################################################
#
#
# NAME:     Wrapper_interactions.tcl
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
#  Description:  Imports an XDC/XDD file
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

##########################FOR TEST########################################################
proc SortNode {nodeType nodeID nodePos choice {indexPos ""} {indexId ""}} {
	global updatetree
	global nodeObj


	set errorString []
	if { $choice == "ind" } {
		set count [new_intp]
		#DllExport ocfmRetCode GetIndexCount(int NodeID, ENodeType NodeType, int* Out_IndexCount);
		set catchErrCode [GetIndexCount $nodeID $nodeType $count]
		set count [intp_value $count]
		set sortRange 4
	} elseif { $choice == "sub" } {
		set count [new_intp]
		#DllExport ocfmRetCode GetSubIndexCount(int NodeID, ENodeType NodeType, char* IndexID, int* Out_SubIndexCount);
		#puts "GetSubIndexCount nodeID->$nodeID nodeType->$nodeType indexId->$indexId count->$count"
		set catchErrCode [GetSubIndexCount $nodeID $nodeType $indexId $count]
		set count [intp_value $count]
		#puts "\nSortNode:subindex count ->$count"
		set sortRange 2
	} else {
		#puts "Invalid choice for SortNode"
		return
	}

#	puts COUNT$count
	#if count is zero no need to proceed		
	set cntLen [string length $count]
	if {$count == 0} {
		if { $choice == "ind" } {
			return [list "" "" ""]
		} elseif { $choice == "sub" } {
		
			return ""
		} else {
			#invalid choice
		}
	}
	set sortList ""
	for { set inc 0 } { $inc < $count } { incr inc } {
		set appZero [expr [string length $count]-[string length $inc]]
		set tmpInc $inc
		for {set incZero 0} {$incZero < $appZero} {incr incZero} {
			#appending zeros
			set tmpInc 0$tmpInc
		}	
		if { $choice == "ind" } {
			set catchErrCode [GetIndexIDbyPositions $nodePos $inc]
			set indexId [lindex $catchErrCode 1]
			#puts "indexId->$indexId"
			lappend sortList $indexId$tmpInc
		} elseif { $choice == "sub" } {
			#puts "GetSubIndexIDbyPositions nodePos->$nodePos indexPos->$indexPos inc->$inc"
			set catchErrCode [GetSubIndexIDbyPositions $nodePos $indexPos $inc]
			set subIndexId [lindex $catchErrCode 1]
			#puts "subIndexId->$subIndexId"
			lappend sortList $subIndexId$tmpInc
		} else {
			#puts "Invalid choice for SortNode"
			return
		}
	
	}
	#puts "b4sortList->$sortList"
	#lsort -increasing $sortList
	set sortList [lsort -ascii $sortList]
	#also chk out dictionary option
	#puts sortList->$sortList

	if { $choice == "ind"} {
		set sortListIdx ""
		set sortListTpdo ""
		set sortListRpdo ""
		for { set inc 0 } { $inc < $count } { incr inc } {
			
			set sortInc [lindex $sortList $inc]
	
			if {[string match "18*" $sortInc] || [string match "1A*" $sortInc]} {
				#it must a TPDO object
				set corrList sortListTpdo
			} elseif {[string match "14*" $sortInc] || [string match "16*" $sortInc]} {
				#it must a RPDO object	
				set corrList sortListRpdo
			} else {
				set corrList sortListIdx
			}
	
			set sortInc [string range $sortInc $sortRange end]
			set sortInc [string trimleft $sortInc 0]
			if {$sortInc == ""} {
				set sortInc 0
			} else {
				#got the exact value
			}
			lappend $corrList $sortInc
		}
		#puts "sortListIdx->$sortListIdx"
		#puts "sortListTpdo->$sortListTpdo"
		#puts "sortListRpdo->$sortListRpdo"
		return [list $sortListIdx $sortListTpdo $sortListRpdo]
	} elseif {$choice == "sub"} {
		set corrList ""
		for { set inc 0 } { $inc < $count } { incr inc } {
		
			set sortInc [lindex $sortList $inc]
			set sortInc [string range $sortInc $sortRange end]
			set sortInc [string trimleft $sortInc 0]
			if {$sortInc == ""} {
				set sortInc 0
			} else {
				#got the exact value
			}
			lappend corrList $sortInc
	
		}
		return $corrList
	} else {
		#check the choice
		#puts "choice Is ------> $choice"
		return
	}


}

#########################################################################################


###############################################################################################
#proc Import
#Input       : node, Xdc/Xdd file path, node type, node id 
#Output      : -
#Description : Reads an XDC/XDD file and populates tree
###############################################################################################
proc Import {parentNode nodeType nodeID } {
#puts "start of import"
	global updatetree
	global cnCount
	#ImportProgress start

#thread::send [tsv::set application importProgress] "StartProgress" ; #
#after 10000

	global LocvarProgbar
	set LocvarProgbar 0
	set errorString []
	#puts "\n\n\t******Import*****"

	set nodePos [new_intp]
	#puts "IfNodeExists nodeID->$nodeID nodeType->$nodeType nodePos->$nodePos"
	#IfNodeExists API is used to get the nodePosition which is needed fro various operation	
	#set catchErrCode [IfNodeExists $nodeID $nodeType $nodePos]




	#TODO waiting for new so then implement it
	set ExistfFlag [new_boolp]
	set catchErrCode [IfNodeExists $nodeID $nodeType $nodePos $ExistfFlag]
	set nodePos [intp_value $nodePos]
	set ExistfFlag [boolp_value $ExistfFlag]
	set ErrCode [ocfmRetCode_code_get $catchErrCode]
	#puts "ErrCode:$ErrCode"
	if { $ErrCode == 0 && $ExistfFlag == 1 } {
		#the node exist continue 
	} else {
		tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon 	warning
		#tk_messageBox -message "ErrCode : $ErrCode\nExistfFlag : $ExistfFlag" -title Warning -icon warning
		#ImportProgress stop
		return
	}




	#puts "catchErrCode->$catchErrCode====nodePos->$nodePos"





	#ocfmRetCode GetIndexCount(int NodeID, ENodeType NodeType, int* Out_IndexCount);
	set count [new_intp]
	set catchErrCode [GetIndexCount $nodeID $nodeType $count]
	set count [intp_value $count]
	#puts COUNT$count
	if {$count == 0} {
		#thread::send -async [tsv::set application importProgress] "StopProgress"
		#ImportProgress stop
      		return
	}

	set parentId [split $parentNode -]
	set parentId [lrange $parentId 1 end]
	set parentId [join $parentId -]
	#puts "parentId---->$parentId"
	set returnList [SortNode $nodeType $nodeID $nodePos ind]
	set corrList [lindex $returnList 0]
	#puts "corrList->$corrList"
	set count [llength $corrList]
	for { set inc 0 } { $inc < $count } { incr inc } {
		set sortedIndexPos [lindex $corrList $inc]
		set IndexValue [GetIndexIDbyPositions $nodePos $sortedIndexPos]
		set IndexValue [lindex $IndexValue 1]
		#puts "IndexValue->$IndexValue"
		#set IndexName [GetIndexAttributes $nodeID $nodeType $IndexValue 0]
		#set IndexName [lindex $IndexName 1]
		#ocfmRetCode GetIndexAttributesbyPositions(int NodePos, int IndexPos, EAttributeType AttributeType, char* Out_AttributeValue);
		set catchErr [GetIndexAttributesbyPositions $nodePos $sortedIndexPos 0 ]
		set IndexName [lindex $catchErr 1]
		$updatetree insert $inc $parentNode IndexValue-$parentId-$inc -text $IndexName\(0x$IndexValue\) -open 0 -image [Bitmap::get index]
		set sidxCorrList [SortNode $nodeType $nodeID $nodePos sub $sortedIndexPos $IndexValue]
		#puts "IndexValue->$IndexValue\nsidxCorrList-->$sidxCorrList\n"

		set SIdxCount [new_intp]
		set catchErrCode [GetSubIndexCount $nodeID $nodeType $IndexValue $SIdxCount]
		set SIdxCount [intp_value $SIdxCount]
		#puts "\t\tSIdxCount->$SIdxCount"
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			#puts "in sub index"
			set sortedSubIndexPos [lindex $sidxCorrList $tmpCount]
			set SIdxValue [GetSubIndexIDbyPositions $nodePos $sortedIndexPos $sortedSubIndexPos ]
			set SIdxValue [lindex $SIdxValue 1]
			#puts "SIdxValue->$SIdxValue"
			#ocfmRetCode GetSubIndexAttributesbyPositions(int NodePos, int IndexPos, int SubIndexPos, EAttributeType AttributeType, char* Out_AttributeValue);
			set catchErr [GetSubIndexAttributesbyPositions $nodePos $sortedIndexPos $sortedSubIndexPos 0 ]
			set SIdxName [lindex $catchErr 1]
			#set SIdxName [GetSubIndexAttributes $nodeID $nodeType $IndexValue $SIdxValue 0]
			#set SIdxName [lindex $SIdxName 1]
		#	#set SIdxName [CBaseIndex_getName $ObjSIdx]
			$updatetree insert end IndexValue-$parentId-$inc SubIndexValue-$parentId-$inc-$tmpCount -text $SIdxName\(0x$SIdxValue\) -open 0 -image [Bitmap::get subindex]
		}
		update idletasks
	}
#	puts "last inc->$inc"
	set LocvarProgbar 50


###########################################for TPDO
	set corrList [lindex $returnList 1]
	#puts "corrList->$corrList"
	set count [llength $corrList]
	#puts "count for tpdo->$count"
	$updatetree insert end $parentNode PDO-$parentId -text "PDO" -open 0 -image [Bitmap::get pdo]
	$updatetree insert end PDO-$parentId TPDO-$parentId -text "TPDO" -open 0 -image [Bitmap::get pdo]
	for { set inc 0 } { $inc < $count } { incr inc } {
		set sortedIndexPos [lindex $corrList $inc]
		set IndexValue [GetIndexIDbyPositions $nodePos $sortedIndexPos]
		set IndexValue [lindex $IndexValue 1]
		#puts "IndexValue->$IndexValue"
		#ocfmRetCode GetIndexAttributesbyPositions(int NodePos, int IndexPos, EAttributeType AttributeType, char* Out_AttributeValue);
		set catchErr [GetIndexAttributesbyPositions $nodePos $sortedIndexPos 0 ]
		set IndexName [lindex $catchErr 1]
		#set IndexName [GetIndexAttributes $nodeID $nodeType $IndexValue 0]
		#set IndexName [lindex $IndexName 1]
		$updatetree insert $inc TPDO-$parentId TPdoIndexValue-$parentId-$inc -text $IndexName\(0x$IndexValue\) -open 0 -image [Bitmap::get index]
		#set sidxCorrList [SortNode $nodeType $nodeID $nodePos $obj $objNode sub "" $sortedIndexPos $IndexValue]
		set sidxCorrList [SortNode $nodeType $nodeID $nodePos sub $sortedIndexPos $IndexValue]
		set SIdxCount [new_intp]
		set catchErrCode [GetSubIndexCount $nodeID $nodeType $IndexValue $SIdxCount]
		set SIdxCount [intp_value $SIdxCount]
		#puts "\t\tSIdxCount->$SIdxCount"
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set sortedSubIndexPos [lindex $sidxCorrList $tmpCount]
			set SIdxValue [GetSubIndexIDbyPositions $nodePos $sortedIndexPos $sortedSubIndexPos]
			set SIdxValue [lindex $SIdxValue 1]
			#puts "SIdxValue->$SIdxValue"
			#ocfmRetCode GetSubIndexAttributesbyPositions(int NodePos, int IndexPos, int SubIndexPos, EAttributeType AttributeType, char* Out_AttributeValue);
			set catchErr [GetSubIndexAttributesbyPositions $nodePos $sortedIndexPos $sortedSubIndexPos 0 ]
			set SIdxName [lindex $catchErr 1]
			#set SIdxName [GetSubIndexAttributes $nodeID $nodeType $IndexValue $SIdxValue 0]
			#set SIdxName [lindex $SIdxName 1]
			$updatetree insert end TPdoIndexValue-$parentId-$inc TPdoSubIndexValue-$parentId-$inc-$tmpCount -text $SIdxName\(0x$SIdxValue\) -open 0 -image [Bitmap::get subindex]
		}
		update idletasks
	}
	set LocvarProgbar 75	
###########################################for RPDO
	set corrList [lindex $returnList 2]
	#puts "corrList->$corrList"
	set count [llength $corrList]
	#puts "count for rpdo->$count"
	$updatetree insert end PDO-$parentId RPDO-$parentId -text "RPDO" -open 0 -image [Bitmap::get pdo]
	for { set inc 0 } { $inc < $count } { incr inc } {
		set sortedIndexPos [lindex $corrList $inc]
		set IndexValue [GetIndexIDbyPositions $nodePos $sortedIndexPos]
		set IndexValue [lindex $IndexValue 1]
		#puts "IndexValue->$IndexValue"
		#ocfmRetCode GetIndexAttributesbyPositions(int NodePos, int IndexPos, EAttributeType AttributeType, char* Out_AttributeValue);
		set catchErr [GetIndexAttributesbyPositions $nodePos $sortedIndexPos 0 ]
		set IndexName [lindex $catchErr 1]
		#set IndexName [GetIndexAttributes $nodeID $nodeType $IndexValue 0]
		#set IndexName [lindex $IndexName 1]
		$updatetree insert $inc RPDO-$parentId RPdoIndexValue-$parentId-$inc -text $IndexName\(0x$IndexValue\) -open 0 -image [Bitmap::get index]
		#set sidxCorrList [SortNode $nodeType $nodeID $nodePos $obj $objNode sub "" $sortedIndexPos $IndexValue]
		set sidxCorrList [SortNode $nodeType $nodeID $nodePos sub $sortedIndexPos $IndexValue]
		set SIdxCount [new_intp]
		set catchErrCode [GetSubIndexCount $nodeID $nodeType $IndexValue $SIdxCount]
		set SIdxCount [intp_value $SIdxCount]
		#puts "\t\tSIdxCount->$SIdxCount"
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set sortedSubIndexPos [lindex $sidxCorrList $tmpCount]
			set SIdxValue [GetSubIndexIDbyPositions $nodePos $sortedIndexPos $sortedSubIndexPos]
			set SIdxValue [lindex $SIdxValue 1]
			#puts "SIdxValue->$SIdxValue"
			#set SIdxName [GetSubIndexAttributes $nodeID $nodeType $IndexValue $SIdxValue 0]
			#set SIdxName [lindex $SIdxName 1]
			#ocfmRetCode GetSubIndexAttributesbyPositions(int NodePos, int IndexPos, int SubIndexPos, EAttributeType AttributeType, char* Out_AttributeValue);
			set catchErr [GetSubIndexAttributesbyPositions $nodePos $sortedIndexPos $sortedSubIndexPos 0 ]
			set SIdxName [lindex $catchErr 1]
			$updatetree insert end RPdoIndexValue-$parentId-$inc RPdoSubIndexValue-$parentId-$inc-$tmpCount -text $SIdxName\(0x$SIdxValue\) -open 0 -image [Bitmap::get subindex]
		}
		update idletasks
	}
	#puts "errorString->$errorString...nodeType->$nodeType...nodeID->$nodeID..."
	set LocvarProgbar 100
	#ImportProgress stop
#tk_messageBox -message "clicing ok destroys progress window"
}

