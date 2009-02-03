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
proc SortNode {obj objNode choice {ObjIndex ""}} {
	global updatetree
	global nodeObj


	set errorString []
#	puts "******Sort*****"
#++++++++++++++++++++++++++++++
#	puts "obj->$obj objNode->$objNode choice->$choice ObjIndex->$ObjIndex"
#	puts "**"
	if { $choice == "ind" } {
		set count [CIndexCollection_getNumberofIndexes $obj]
		set sortRange 4
	} elseif { $choice == "tpdoInd"} {
		set obj  [CNode_getPDOIndexCollection $objNode 1]
		set count [CIndexCollection_getNumberofIndexes $obj]
		set sortRange 4
	} elseif { $choice == "rpdoInd" } {
		set obj  [CNode_getPDOIndexCollection $objNode 2]
		set count [CIndexCollection_getNumberofIndexes $obj]
		set sortRange 4
	} elseif { $choice == "sub" } {
		set count [CIndex_getNumberofSubIndexes $ObjIndex]
		set sortRange 2
	} else {
		puts "Invalid choice for SortNode"
		return
	}

#	puts COUNT$count
	set cntLen [string length $count]
	if {$count == 0} {
#		puts "****"
		return
	}
	set sortList ""
	for { set inc 0 } { $inc < $count } { incr inc } {
		set appZero [expr [string length $count]-[string length $inc]]
		set tmpInc $inc
		for {set incZero 0} {$incZero < $appZero} {incr incZero} {
			#appending zeros
			set tmpInc 0$tmpInc
		}	
		if { $choice == "ind" || $choice == "tpdoInd" || $choice == "rpdoInd" } {		
			set tempObjIndex [CIndexCollection_getIndex $obj $inc]
		} elseif { $choice == "sub" } {
			set tempObjIndex [CIndex_getSubIndex $ObjIndex $inc]
		} else {
			puts "Invalid choice for SortNode"
		}
		lappend sortList [CBaseIndex_getIndexValue $tempObjIndex]$tmpInc	
	}
#	puts "b4sortList->$sortList"
	#lsort -increasing $sortList
	set sortList [lsort -ascii $sortList]
	#also chk out dictionary option
#	puts sortList->$sortList

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
		#set ObjIndex [CIndexCollection_getIndex $obj $sortInc]
		#puts [CBaseIndex_getIndexValue $ObjIndex]
	}
#	puts "corrList->$corrList"
#	puts "******Sort end*****"
	return $corrList
}




#########################################################################################


###############################################################################################
#proc Import
#Input       : node, Xdc/Xdd file path, node type, node id 
#Output      : -
#Description : Reads an XDC/XDD file and populates tree
###############################################################################################
proc Import {cn tmpDir NodeType NodeID obj objNode } {
	global updatetree
	global cnCount
	global nodeObj
	ImportProgress start

	global LocvarProgbar
	set LocvarProgbar 0
	set errorString []
	#set NodeType 1
#+++++++++++++++++++++++++++
	#set objNodeCollection [new_CNodeCollection]
	#set objNodeCollection [CNodeCollection_getNodeColObjectPointer]
	#puts "errorString->$errorString...NodeType->$NodeType...NodeID->$NodeID..."
	#CreateNode $NodeID $NodeType
	#ImportXML "$tmpDir" $errorString $NodeType $NodeID
        #set LocvarProgbar 20 
	#set objNode [new_CNode]
	#set obj [new_CIndexCollection]
	#set objNode [CNodeCollection_getNode $objNodeCollection $NodeType $NodeID]
	##old code 
	#set obj [CNode_getIndexCollection $objNode]
	##currntly works only for windows
	##set obj [CNode_getIndexCollectionWithoutPDO $objNode]
	puts "******Import*****"
#++++++++++++++++++++++++++++++
	puts "obj->$obj  objNode->$objNode"
	puts "**"
	set count [CIndexCollection_getNumberofIndexes $obj]
	puts COUNT$count
	if {$count == 0} {
		ImportProgress stop
      		return
	}
	set cnId [split $cn -]
	set xdcId [lrange $cnId 1 end]
	set xdcId [join $xdcId -]
	set cnId [lindex $cnId end]
	puts cnId-->$cnId
	set corrList [SortNode $obj $objNode ind]
	for { set inc 0 } { $inc < $count } { incr inc } {
#		puts "[lindex $corrList $inc]"
		set ObjIndex [CIndexCollection_getIndex $obj [lindex $corrList $inc] ]
		#set ObjIndex [CIndexCollection_getIndex $obj $inc]
		set nodeObj(1-$cnId-$inc) $ObjIndex
		set IndexValue [CBaseIndex_getIndexValue $ObjIndex]
		set IndexName [CBaseIndex_getName $ObjIndex]
		$updatetree insert $inc $cn IndexValue-1-$cnId-$inc -text $IndexName\($IndexValue\) -open 0 -image [Bitmap::get index]
puts "ObjIndex->$ObjIndex"
		set sidxCorrList [SortNode $obj $objNode sub $ObjIndex]
		set SIdxCount [CIndex_getNumberofSubIndexes $ObjIndex]
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
#			puts "in sub index"
			set ObjSIdx [CIndex_getSubIndex $ObjIndex [lindex $sidxCorrList $tmpCount]]
			#set ObjSIdx [CIndex_getSubIndex $ObjIndex $tmpCount]
			set nodeObj(1-$cnId-$inc-$tmpCount) $ObjSIdx
			set SIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
			set SIdxName [CBaseIndex_getName $ObjSIdx]
			$updatetree insert end IndexValue-1-$cnId-$inc SubIndexValue-1-$cnId-$inc-$tmpCount -text $SIdxName\($SIdxValue\) -open 0 -image [Bitmap::get subindex]
		}
		update idletasks
	}
#	puts "last inc->$inc"
	set LocvarProgbar 50
###########################################for TPDO
	set TclIndexCollection  [CNode_getPDOIndexCollection $objNode 1]
	#set ObjIndex [new_CIndex]
	set count [CIndexCollection_getNumberofIndexes $TclIndexCollection]
	puts "count for tpdo->$count"
	set corrList [SortNode $obj $objNode tpdoInd]
	$updatetree insert end $cn PDO-1-$cnId -text "PDO" -open 0 -image [Bitmap::get pdo]
	$updatetree insert end PDO-1-$cnId TPDO-1-$cnId -text "TPDO" -open 0 -image [Bitmap::get pdo]
	for { set inc 0 } { $inc < $count } { incr inc } {
		set ObjIndex [CIndexCollection_getIndex $TclIndexCollection [lindex $corrList $inc]]
		#set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $inc]
		set nodeObj(1-TPdo$cnId-$inc) $ObjIndex
puts "tpdo ObjIndex->$ObjIndex"
		set IndexValue [CBaseIndex_getIndexValue $ObjIndex]
		set IndexName [CBaseIndex_getName $ObjIndex]
		$updatetree insert $inc TPDO-1-$cnId TPdoIndexValue-1-TPdo$cnId-$inc -text $IndexName\($IndexValue\) -open 0 -image [Bitmap::get index]
		set sidxCorrList [SortNode $obj $objNode sub $ObjIndex]
		set SIdxCount [CIndex_getNumberofSubIndexes $ObjIndex]
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set ObjSIdx [CIndex_getSubIndex $ObjIndex [lindex $sidxCorrList $tmpCount]]
			#set ObjSIdx [CIndex_getSubIndex $ObjIndex $tmpCount]
			set nodeObj(1-TPdo$cnId-$inc-$tmpCount) $ObjSIdx
#			puts "nodeObj(1-TPdo$cnId-$inc-$tmpCount)--->$ObjSIdx"
			set SIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
			set SIdxName [CBaseIndex_getName $ObjSIdx]
			$updatetree insert end TPdoIndexValue-1-TPdo$cnId-$inc TPdoSubIndexValue-1-TPdo$cnId-$inc-$tmpCount -text $SIdxName\($SIdxValue\) -open 0 -image [Bitmap::get subindex]
		}
		update idletasks
	}
	set LocvarProgbar 75	
###########################################for RPDO
	set TclIndexCollection  [CNode_getPDOIndexCollection $objNode 2]
	#set ObjIndex [new_CIndex]
	set count [CIndexCollection_getNumberofIndexes $TclIndexCollection]
	puts "count for rpdo->$count"
	$updatetree insert end PDO-1-$cnId RPDO-1-$cnId -text "RPDO" -open 0 -image [Bitmap::get pdo]
	set corrList [SortNode $obj $objNode rpdoInd]
	for { set inc 0 } { $inc < $count } { incr inc } {
		set ObjIndex [CIndexCollection_getIndex $TclIndexCollection [lindex $corrList $inc]]
		#set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $inc]
		set nodeObj(1-RPdo$cnId-$inc) $ObjIndex
puts "rpdoObjIndex->$ObjIndex"
		set IndexValue [CBaseIndex_getIndexValue $ObjIndex]
		set IndexName [CBaseIndex_getName $ObjIndex]
		$updatetree insert $inc RPDO-1-$cnId RPdoIndexValue-1-RPdo$cnId-$inc -text $IndexName\($IndexValue\) -open 0 -image [Bitmap::get index]
		set sidxCorrList [SortNode $obj $objNode sub $ObjIndex]
		set SIdxCount [CIndex_getNumberofSubIndexes $ObjIndex]
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set ObjSIdx [CIndex_getSubIndex $ObjIndex [lindex $sidxCorrList $tmpCount]]
			#set ObjSIdx [CIndex_getSubIndex $ObjIndex $tmpCount]
			set nodeObj(1-RPdo$cnId-$inc-$tmpCount) $ObjSIdx
			set SIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
			set SIdxName [CBaseIndex_getName $ObjSIdx]
			$updatetree insert end RPdoIndexValue-1-RPdo$cnId-$inc RPdoSubIndexValue-1-RPdo$cnId-$inc-$tmpCount -text $SIdxName\($SIdxValue\) -open 0 -image [Bitmap::get subindex]
		}
		update idletasks
	}
	puts "errorString->$errorString...NodeType->$NodeType...NodeID->$NodeID..."
	set LocvarProgbar 100
	ImportProgress stop

}

