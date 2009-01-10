proc Import {cn tmpDir NodeType NodeID} {
	global updatetree
	global cnCount
	global xdcFile


	set errorString []
	set NodeID 1
	set NodeType 1
	
set objNodeCollection [new_CNodeCollection]
set objNodeCollection [CNodeCollection_getNodeColObjectPointer]

	Tcl_CreateNode $NodeID $NodeType
	Tcl_ImportXML "$tmpDir" $errorString $NodeType $NodeID



set objNode [new_CNode]

set obj [new_CIndexCollection]
set objNode [CNodeCollection_getNode $objNodeCollection $NodeType $NodeID]
set obj [CNode_getIndexCollection $objNode]
puts "**"

set count [CIndexCollection_getNumberofIndexes $obj]
puts COUNT$count


#	set TclObj [new_CNodeCollection]
#	set TclNodeObj [new_CNode]
#	set TclNodeObj [CNodeCollection_getNode $TclObj $NodeType $NodeID]

#	set TclIndexCollection [new_CIndexCollection]
#	set TclIndexCollection  [CNode_getIndexCollection $TclNodeObj]

#	set ObjIndex [new_CIndex]
#	set count [CIndexCollection_getNumberofIndexes $TclIndexCollection]

	set cnId [split $cn -]
	set xdcId [lrange $cnId 1 end]
	set xdcId [join $xdcId -]
	#puts xdcId-->$xdcId
	#set xdcFile($xdcId) $tmpDir
	set cnId [lindex $cnId end]
	puts cnId-->$cnId
	
	
	for { set i 0 } { $i < $count } { incr i } {
	
	set ObjIndex [new_CIndex]
	
		#set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $i]
		set ObjIndex [CIndexCollection_getIndex $obj $i]
		set xdcFile(1-$cnId-$i) $ObjIndex
		#puts ObjIndex-->$ObjIndex
		set IndexValue [CBaseIndex_getIndexValue $ObjIndex]
		set IndexName [CBaseIndex_getName $ObjIndex]
		#puts i---->$i
		$updatetree insert $i $cn IndexValue-1-$cnId-$i -text $IndexName\($IndexValue\) -open 1 -image [Bitmap::get index]
		set SIdxCount [CIndex_getNumberofSubIndexes $ObjIndex]
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set ObjSIdx [CIndex_getSubIndex $ObjIndex $tmpCount]
			#puts ObjSIdx-->$ObjSIdx
			set xdcFile(1-$cnId-$i-$tmpCount) $ObjSIdx
			set SIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
			#puts SIdxValue:$SIdxValue=======tmpCount:$tmpCount
			set SIdxName [CBaseIndex_getName $ObjIndex]
			set SIdxDefaultValue [CBaseIndex_getDefaultValue $ObjSIdx]
			#puts SIdxDefaultValue:$SIdxDefaultValue
			$updatetree insert end IndexValue-1-$cnId-$i SubIndexValue-1-$cnId-$i-$tmpCount -text $SIdxName\($SIdxValue\) -open 1 -image [Bitmap::get subindex]
			
		}
	}




}

