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
	puts obj->$obj
	puts "**"
	set count [CIndexCollection_getNumberofIndexes $obj]
	puts COUNT$count

	set cnId [split $cn -]
	set xdcId [lrange $cnId 1 end]
	set xdcId [join $xdcId -]
	set cnId [lindex $cnId end]
	puts cnId-->$cnId
	for { set inc 0 } { $inc < $count } { incr inc } {
		set ObjIndex [CIndexCollection_getIndex $obj $inc]
		set nodeObj(1-$cnId-$inc) $ObjIndex
		set IndexValue [CBaseIndex_getIndexValue $ObjIndex]
		set IndexName [CBaseIndex_getName $ObjIndex]
		$updatetree insert $inc $cn IndexValue-1-$cnId-$inc -text $IndexName\($IndexValue\) -open 0 -image [Bitmap::get index]
		set SIdxCount [CIndex_getNumberofSubIndexes $ObjIndex]
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set ObjSIdx [CIndex_getSubIndex $ObjIndex $tmpCount]
			set nodeObj(1-$cnId-$inc-$tmpCount) $ObjSIdx
			set SIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
			set SIdxName [CBaseIndex_getName $ObjIndex]
			$updatetree insert end IndexValue-1-$cnId-$inc SubIndexValue-1-$cnId-$inc-$tmpCount -text $SIdxName\($SIdxValue\) -open 0 -image [Bitmap::get subindex]
		}
		update idletasks
	}
	set LocvarProgbar 40
###########################################for TPDO
	set TclIndexCollection  [CNode_getPDOIndexCollection $objNode 1]
	set ObjIndex [new_CIndex]
	set count [CIndexCollection_getNumberofIndexes $TclIndexCollection]
	puts "count for tpdo->$count"
	$updatetree insert end $cn PDO-1-$cnId -text "PDO" -open 0 -image [Bitmap::get pdo]
	$updatetree insert end PDO-1-$cnId TPDO-1-$cnId -text "TPDO" -open 0 -image [Bitmap::get pdo]
	for { set inc 0 } { $inc < $count } { incr inc } {
		set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $inc]
		set nodeObj(1-TPdo$cnId-$inc) $ObjIndex
		set IndexValue [CBaseIndex_getIndexValue $ObjIndex]
		set IndexName [CBaseIndex_getName $ObjIndex]
		$updatetree insert $inc TPDO-1-$cnId TPdoIndexValue-1-TPdo$cnId-$inc -text $IndexName\($IndexValue\) -open 0 -image [Bitmap::get index]
		set SIdxCount [CIndex_getNumberofSubIndexes $ObjIndex]
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set ObjSIdx [CIndex_getSubIndex $ObjIndex $tmpCount]
			set nodeObj(1-TPdo$cnId-$inc-$tmpCount) $ObjSIdx
			set SIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
			set SIdxName [CBaseIndex_getName $ObjIndex]
			$updatetree insert end TPdoIndexValue-1-TPdo$cnId-$inc TPdoSubIndexValue-1-TPdo$cnId-$inc-$tmpCount -text $SIdxName\($SIdxValue\) -open 0 -image [Bitmap::get subindex]
		}
		update idletasks
	}
	set LocvarProgbar 60	
###########################################for RPDO
	set TclIndexCollection  [CNode_getPDOIndexCollection $objNode 2]
	set ObjIndex [new_CIndex]
	set count [CIndexCollection_getNumberofIndexes $TclIndexCollection]
	puts "count for rpdo->$count"
	$updatetree insert end PDO-1-$cnId RPDO-1-$cnId -text "RPDO" -open 0 -image [Bitmap::get pdo]
	for { set inc 0 } { $inc < $count } { incr inc } {
		set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $inc]
		set nodeObj(1-RPdo$cnId-$inc) $ObjIndex
		set IndexValue [CBaseIndex_getIndexValue $ObjIndex]
		set IndexName [CBaseIndex_getName $ObjIndex]
		$updatetree insert $inc RPDO-1-$cnId RPdoIndexValue-1-RPdo$cnId-$inc -text $IndexName\($IndexValue\) -open 0 -image [Bitmap::get index]
		set SIdxCount [CIndex_getNumberofSubIndexes $ObjIndex]
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set ObjSIdx [CIndex_getSubIndex $ObjIndex $tmpCount]
			set nodeObj(1-RPdo$cnId-$inc-$tmpCount) $ObjSIdx
			set SIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
			set SIdxName [CBaseIndex_getName $ObjIndex]
			$updatetree insert end RPdoIndexValue-1-RPdo$cnId-$inc RPdoSubIndexValue-1-RPdo$cnId-$inc-$tmpCount -text $SIdxName\($SIdxValue\) -open 0 -image [Bitmap::get subindex]
		}
		update idletasks
	}
	puts "errorString->$errorString...NodeType->$NodeType...NodeID->$NodeID..."
	set LocvarProgbar 80
	ImportProgress stop

######followingt lines are hard coded works only for mn#############
#puts "no of coll -> [CNodeCollection_getNumberofNodes]"
#puts "no of coll -> [getNumberofNodes]"
}

