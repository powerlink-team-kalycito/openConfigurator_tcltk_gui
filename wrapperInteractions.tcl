####################################################################################################
#
#
# NAME:     wrapperInteractions.tcl
#
# PURPOSE:  populates the object in GUI in sorted order
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
#  namespace : WrapperInteractions
#---------------------------------------------------------------------------------------------------
namespace eval WrapperInteractions {
	
}


#---------------------------------------------------------------------------------------------------
#  WrapperInteractions::SortNode
# 
#  Arguments : nodeType - indicates MN or CN
#              nodeID   - id of the nodes
#              nodePos  - node position in the object created
#              choice   - sorts based on the given choice
#              indexPos - index position in the object created
#              indexId  - id of the index
#  Results : sorted list
#
#  Description : Sorts the index and sub index of the objects
#---------------------------------------------------------------------------------------------------
proc WrapperInteractions::SortNode {nodeType nodeID nodePos choice {indexPos ""} {indexId ""}} {
    global treePath

    set errorString []
    if { $choice == "ind" } {
	    set count [new_intp]
	    set catchErrCode [GetIndexCount $nodeID $nodeType $count]
	    set count [intp_value $count]
	    set sortRange 4
    } elseif { $choice == "sub" } {
	    set count [new_intp]
	    set catchErrCode [GetSubIndexCount $nodeID $nodeType $indexId $count]
	    set count [intp_value $count]
	    set sortRange 2
    } else {
	    return
    }

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
		    lappend sortList $indexId$tmpInc
	    } elseif { $choice == "sub" } {
		    set catchErrCode [GetSubIndexIDbyPositions $nodePos $indexPos $inc]
		    set subIndexId [lindex $catchErrCode 1]
		    lappend sortList $subIndexId$tmpInc
	    } else {
		    return
	    }

    }
    set sortList [lsort -ascii $sortList]

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
	    return
    }
}

#---------------------------------------------------------------------------------------------------
#  WrapperInteractions::Import
# 
#  Arguments : parentNode - parent node in tree window
#              nodeType   - indicates the type as MN or CN
#              nodeID     - id of the node
#
#  Results : pass or fail
#
#  Description : Populates the node on to the tree window
#---------------------------------------------------------------------------------------------------
proc WrapperInteractions::Import {parentNode nodeType nodeID } {
    global treePath
    global cnCount

    global LocvarProgbar
    set LocvarProgbar 0
    set errorString []

    #check for view if simple exit else advanced continue
    if { [string match "SIMPLE" $Operations::viewType ] == 1 } {
        return pass
    }
    set nodePos [new_intp]

    #TODO waiting for new so then implement it
    set ExistfFlag [new_boolp]
    set catchErrCode [IfNodeExists $nodeID $nodeType $nodePos $ExistfFlag]
    set nodePos [intp_value $nodePos]
    set ExistfFlag [boolp_value $ExistfFlag]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode == 0 && $ExistfFlag == 1 } {
        #the node exist continue 
    } else {
        if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
	        tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error
        } else {
	        tk_messageBox -message "Unknown Error" -title Error -icon error
        }
        Operations::CloseProject
        return fail
    }
    
    set parentId [split $parentNode -]
    set parentId [lrange $parentId 1 end]
    set parentId [join $parentId -]
    
    $treePath insert end $parentNode PDO-$parentId -text "PDO" -open 0 -image [Bitmap::get pdo]
    $treePath insert end PDO-$parentId TPDO-$parentId -text "TPDO" -open 0 -image [Bitmap::get pdo]
    $treePath insert end PDO-$parentId RPDO-$parentId -text "RPDO" -open 0 -image [Bitmap::get pdo]

    #ocfmRetCode GetIndexCount(int NodeID, ENodeType NodeType, int* Out_IndexCount);
    set count [new_intp]
    set catchErrCode [GetIndexCount $nodeID $nodeType $count]
    set count [intp_value $count]
    if {$count == 0} {
      		return 
    }


    set returnList [WrapperInteractions::SortNode $nodeType $nodeID $nodePos ind]
    set corrList [lindex $returnList 0]
    set count [llength $corrList]
    for { set inc 0 } { $inc < $count } { incr inc } {
        set sortedIndexPos [lindex $corrList $inc]
        set IndexValue [GetIndexIDbyPositions $nodePos $sortedIndexPos]
        if { [ocfmRetCode_code_get [lindex $IndexValue 0]] != 0 } {
	        if { [ string is ascii [ocfmRetCode_errorString_get [lindex $IndexValue 0]] ] } {
		        tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $IndexValue 0]]\nClosing the project" -title Error -icon error -parent .
	        } else {
		        tk_messageBox -message "Unknown Error\nClosing the project" -title Error -icon error -parent .
	        }
	        Operations::CloseProject
	        return fail
        }
        set IndexValue [lindex $IndexValue 1]
        set catchErr [GetIndexAttributesbyPositions $nodePos $sortedIndexPos 0 ]
        set IndexName [lindex $catchErr 1]
        if { [ocfmRetCode_code_get [lindex $catchErr 0]] != 0 } {
	        if { [ string is ascii [ocfmRetCode_errorString_get [lindex $catchErr 0]] ] } {
		        tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $catchErr 0]]\nClosing the project" -title Error -icon error -parent .
	        } else {
		        tk_messageBox -message "Unknown Error\nClosing the project" -title Error -icon error -parent .
	        }
	        Operations::CloseProject
	        return fail
        }

        $treePath insert $inc $parentNode IndexValue-$parentId-$inc -text $IndexName\(0x$IndexValue\) -open 0 -image [Bitmap::get index]
        set sidxCorrList [WrapperInteractions::SortNode $nodeType $nodeID $nodePos sub $sortedIndexPos $IndexValue]

        set SIdxCount [new_intp]
        set catchErrCode [GetSubIndexCount $nodeID $nodeType $IndexValue $SIdxCount]
        set SIdxCount [intp_value $SIdxCount]
        for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
	        set sortedSubIndexPos [lindex $sidxCorrList $tmpCount]
	        set SIdxValue [GetSubIndexIDbyPositions $nodePos $sortedIndexPos $sortedSubIndexPos]
	        if { [ocfmRetCode_code_get [lindex $SIdxValue 0]] != 0 } {
		        if { [ string is ascii [ocfmRetCode_errorString_get [lindex $SIdxValue 0]] ] } {
			        tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $SIdxValue 0] ]\nClosing the project" -title Error -icon error -parent .
		        } else {
			        tk_messageBox -message "Unknown Error\nClosing the project" -title Error -icon error -parent .
		        }
		        Operations::CloseProject
		        return fail
	        }
	        set SIdxValue [lindex $SIdxValue 1]
	        set catchErr [GetSubIndexAttributesbyPositions $nodePos $sortedIndexPos $sortedSubIndexPos 0 ]
	        set SIdxName [lindex $catchErr 1]
	        if { [ocfmRetCode_code_get [lindex $catchErr 0]] != 0 } {
		        if { [ string is ascii [ocfmRetCode_errorString_get [lindex $catchErr 0]] ] } {
			        tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $catchErr 0]]\nClosing the project" -title Error -icon error -parent .
		        } else {
			        tk_messageBox -message "Unknown Error\nClosing the project" -title Error -icon error -parent .
		        }
		        Operations::CloseProject
		        return fail
	        }
	        $treePath insert end IndexValue-$parentId-$inc SubIndexValue-$parentId-$inc-$tmpCount -text $SIdxName\(0x$SIdxValue\) -open 0 -image [Bitmap::get subindex]
        }
        update idletasks
    }
    #for TPDO
    set corrList [lindex $returnList 1]
    set count [llength $corrList]

    for { set inc 0 } { $inc < $count } { incr inc } {
        set sortedIndexPos [lindex $corrList $inc]
        set IndexValue [GetIndexIDbyPositions $nodePos $sortedIndexPos]
        if { [ocfmRetCode_code_get [lindex $IndexValue 0]] != 0 } {
	        if { [ string is ascii [ocfmRetCode_errorString_get [lindex $IndexValue 0]] ] } {
		        tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $IndexValue 0]]\nClosing the project" -title Error -icon error -parent .
	        } else {
		        tk_messageBox -message "Unknown Error\nClosing the project" -title Error -icon error -parent .
	        }
	        Operations::CloseProject
	        return fail
        }
        set IndexValue [lindex $IndexValue 1]
        set catchErr [GetIndexAttributesbyPositions $nodePos $sortedIndexPos 0 ]
        set IndexName [lindex $catchErr 1]
        if { [ocfmRetCode_code_get [lindex $catchErr 0]] != 0 } {
	        if { [ string is ascii [ocfmRetCode_errorString_get [lindex $catchErr 0]] ] } {
		        tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $catchErr 0]]\nClosing the project" -title Error -icon error -parent .
	        } else {
		        tk_messageBox -message "Unknown Error\nClosing the project" -title Error -icon error -parent .
	        }
	        Operations::CloseProject
	        return fail
        }
        $treePath insert $inc TPDO-$parentId TPdoIndexValue-$parentId-$inc -text $IndexName\(0x$IndexValue\) -open 0 -image [Bitmap::get index]
        set sidxCorrList [WrapperInteractions::SortNode $nodeType $nodeID $nodePos sub $sortedIndexPos $IndexValue]
        set SIdxCount [new_intp]
        set catchErrCode [GetSubIndexCount $nodeID $nodeType $IndexValue $SIdxCount]
        set SIdxCount [intp_value $SIdxCount]
        for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
	        set sortedSubIndexPos [lindex $sidxCorrList $tmpCount]
	        set SIdxValue [GetSubIndexIDbyPositions $nodePos $sortedIndexPos $sortedSubIndexPos]
	        if { [ocfmRetCode_code_get [lindex $SIdxValue 0]] != 0 } {
		        if { [ string is ascii [ocfmRetCode_errorString_get [lindex $SIdxValue 0]] ] } {
			        tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $SIdxValue 0] ]\nClosing the project" -title Error -icon error -parent .
		        } else {
			        tk_messageBox -message "Unknown Error\nClosing the project" -title Error -icon error -parent .
		        }
		        Operations::CloseProject
		        return fail
	        }
	        set SIdxValue [lindex $SIdxValue 1]
	        set catchErr [GetSubIndexAttributesbyPositions $nodePos $sortedIndexPos $sortedSubIndexPos 0 ]
	        set SIdxName [lindex $catchErr 1]
	        if { [ocfmRetCode_code_get [lindex $catchErr 0]] != 0 } {
		        if { [ string is ascii [ocfmRetCode_errorString_get [lindex $catchErr 0]] ] } {
			        tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $catchErr 0]]\nClosing the project" -title Error -icon error -parent .
		        } else {
			        tk_messageBox -message "Unknown Error\nClosing the project" -title Error -icon error -parent .
		        }
		        Operations::CloseProject
		        return fail
	        }
	        $treePath insert end TPdoIndexValue-$parentId-$inc TPdoSubIndexValue-$parentId-$inc-$tmpCount -text $SIdxName\(0x$SIdxValue\) -open 0 -image [Bitmap::get subindex]
        }
        update idletasks
    }
    #for RPDO
    set corrList [lindex $returnList 2]
    set count [llength $corrList]
    
    for { set inc 0 } { $inc < $count } { incr inc } {
        set sortedIndexPos [lindex $corrList $inc]
        set IndexValue [GetIndexIDbyPositions $nodePos $sortedIndexPos]
        if { [ocfmRetCode_code_get [lindex $IndexValue 0]] != 0 } {
	        if { [ string is ascii [ocfmRetCode_errorString_get [lindex $IndexValue 0]] ] } {
		        tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $IndexValue 0]]\nClosing the project" -title Error -icon error -parent .
	        } else {
		        tk_messageBox -message "Unknown Error\nClosing the project" -title Error -icon error -parent .
	        }
	        Operations::CloseProject
	        return fail
        }
        set IndexValue [lindex $IndexValue 1]
        set catchErr [GetIndexAttributesbyPositions $nodePos $sortedIndexPos 0 ]
        set IndexName [lindex $catchErr 1]
        if { [ocfmRetCode_code_get [lindex $catchErr 0]] != 0 } {
	        if { [ string is ascii [ocfmRetCode_errorString_get [lindex $catchErr 0]] ] } {
		        tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $catchErr 0]]\nClosing the project" -title Error -icon error -parent .
	        } else {
		        tk_messageBox -message "Unknown Error\nClosing the project" -title Error -icon error -parent .
	        }
	        Operations::CloseProject
	        return fail
        }
        $treePath insert $inc RPDO-$parentId RPdoIndexValue-$parentId-$inc -text $IndexName\(0x$IndexValue\) -open 0 -image [Bitmap::get index]
        set sidxCorrList [WrapperInteractions::SortNode $nodeType $nodeID $nodePos sub $sortedIndexPos $IndexValue]
        set SIdxCount [new_intp]
        set catchErrCode [GetSubIndexCount $nodeID $nodeType $IndexValue $SIdxCount]
        set SIdxCount [intp_value $SIdxCount]
        for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
	        set sortedSubIndexPos [lindex $sidxCorrList $tmpCount]
	        set SIdxValue [GetSubIndexIDbyPositions $nodePos $sortedIndexPos $sortedSubIndexPos]
	        if { [ocfmRetCode_code_get [lindex $SIdxValue 0]] != 0 } {
		        if { [ string is ascii [ocfmRetCode_errorString_get [lindex $SIdxValue 0]] ] } {
			        tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $SIdxValue 0] ]\nClosing the project" -title Error -icon error -parent .
		        } else {
			        tk_messageBox -message "Unknown Error\nClosing the project" -title Error -icon error -parent .
		        }
		        Operations::CloseProject
		        return fail
	        }
	        set SIdxValue [lindex $SIdxValue 1]
	        set catchErr [GetSubIndexAttributesbyPositions $nodePos $sortedIndexPos $sortedSubIndexPos 0 ]
	        if { [ocfmRetCode_code_get [lindex $catchErr 0]] != 0 } {
		        if { [ string is ascii [ocfmRetCode_errorString_get [lindex $catchErr 0]] ] } {
			        tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $catchErr 0]]\nClosing the project" -title Error -icon error -parent .
		        } else {
			        tk_messageBox -message "Unknown Error\nClosing the project" -title Error -icon error -parent .
		        }
		        Operations::CloseProject
		        return fail
	        }
	        set SIdxName [lindex $catchErr 1]
	        $treePath insert end RPdoIndexValue-$parentId-$inc RPdoSubIndexValue-$parentId-$inc-$tmpCount -text $SIdxName\(0x$SIdxValue\) -open 0 -image [Bitmap::get subindex]
        }
        update idletasks
    }
    return pass
}

#---------------------------------------------------------------------------------------------------
#  WrapperInteractions::RebuildNode
# 
#  Arguments : Node - node in tree window
#
#  Results : pass or fail
#
#  Description : rebuilds the node on to the tree window
#---------------------------------------------------------------------------------------------------
proc WrapperInteractions::RebuildNode {{Node ""}} {
	global treePath
	global nodeSelect
	if {$Node == ""} {
		set Node $nodeSelect
	}
	if {[$treePath exists $Node] == 1} 	{
		#node exists continue the function
	} else {
		return
	}
	
	#gets the nodeId and Type of selected node
	set result [Operations::GetNodeIdType $Node]
	if {$result != "" } {
		set nodeID [lindex $result 0]
		set nodeType [lindex $result 1]
	} else {
		return
	}
	set nodePosition [split $Node -]
	set nodePosition [lrange $nodePosition 1 end]
	set nodePosition [join $nodePosition -]
	
	set nodePos [new_intp]
    set ExistfFlag [new_boolp]
    set catchErrCode [IfNodeExists $nodeID $nodeType $nodePos $ExistfFlag]
    set nodePos [intp_value $nodePos]
    set ExistfFlag [boolp_value $ExistfFlag]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode == 0 && $ExistfFlag == 1 } {
	    #the node exist continue 
    } else {
	    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
		    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -parent . -title Error -icon error
	    } else {
		    tk_messageBox -message "Unknown Error" -parent . -title Error -icon error
	    }
	    return
    }
	
	set IndexValue [string range [$treePath itemcget $Node -text] end-4 end-1]
	
	set indexPos [new_intp] 
	set catchErrCode [IfIndexExists $nodeID $nodeType $IndexValue $indexPos]
	if { [ocfmRetCode_code_get $catchErrCode] != 0 } {
		if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .
		} else {
			tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
		}
		return
	}
	set indexPos [intp_value $indexPos] 
	
	set childNodeList [$treePath nodes $Node]
	if {[llength $childNodeList] > 0} {
		$treePath itemconfigure $Node -open 0
	}
	foreach childNode $childNodeList {
		$treePath delete $childNode
	}
	
	set sidxCorrList [WrapperInteractions::SortNode $nodeType $nodeID $nodePos sub $indexPos $IndexValue]

	set SIdxCount [new_intp]
	set catchErrCode [GetSubIndexCount $nodeID $nodeType $IndexValue $SIdxCount]
	set SIdxCount [intp_value $SIdxCount]
	for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
		set sortedSubIndexPos [lindex $sidxCorrList $tmpCount]
		set SIdxValue [GetSubIndexIDbyPositions $nodePos $indexPos $sortedSubIndexPos]
		if { [ocfmRetCode_code_get [lindex $SIdxValue 0]] != 0 } {
			if { [ string is ascii [ocfmRetCode_errorString_get [lindex $SIdxValue 0]] ] } {
				tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $SIdxValue 0] ]\nClosing the project" -title Error -icon error -parent .
			} else {
				tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
			}
			return fail
		}
		set SIdxValue [lindex $SIdxValue 1]
		set catchErr [GetSubIndexAttributesbyPositions $nodePos $indexPos $sortedSubIndexPos 0 ]
		set SIdxName [lindex $catchErr 1]
		if { [ocfmRetCode_code_get [lindex $catchErr 0]] != 0 } {
			if { [ string is ascii [ocfmRetCode_errorString_get [lindex $catchErr 0]] ] } {
				tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $catchErr 0]]\nClosing the project" -title Error -icon error -parent .
			} else {
				tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
			}
			return fail
		}
		$treePath insert end $Node SubIndexValue-$nodePosition-$tmpCount -text $SIdxName\(0x$SIdxValue\) -open 0 -image [Bitmap::get subindex]
	}
	update idletasks
}
