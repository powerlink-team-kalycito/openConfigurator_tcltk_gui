proc Import {cn tmpDir NodeType NodeID} {
	global updatetree
	global cnCount
	global xdcFile


	set errorString []
	set NodeID 1
	set NodeType 1
	

	Tcl_CreateNode $NodeID $NodeType
	Tcl_ImportXML "$tmpDir" $errorString $NodeType $NodeID


	set TclObj [new_CNodeCollection]
	set TclNodeObj [new_CNode]
	set TclNodeObj [CNodeCollection_getNode $TclObj $NodeType $NodeID]

	set TclIndexCollection [new_CIndexCollection]
	set TclIndexCollection  [CNode_getIndexCollection $TclNodeObj]

#	set ObjIndex [new_CIndex]
	set count [CIndexCollection_getNumberofIndexes $TclIndexCollection]

	set cnId [split $cn -]
	set xdcId [lrange $cnId 1 end]
	set xdcId [join $xdcId -]
	#puts xdcId-->$xdcId
	#set xdcFile($xdcId) $tmpDir
	set cnId [lindex $cnId end]
	puts cnId-->$cnId
	for { set i 0 } { $i < $count } { incr i } {
		set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $i]
		set xdcFile(1-$cnId-$i) $ObjIndex
		#puts ObjIndex-->$ObjIndex
		set IndexValue [CBaseIndex_getIndexValue $ObjIndex]
		#puts i---->$i
		$updatetree insert $i $cn IndexValue-1-$cnId-$i -text $IndexValue -open 1 -image [Bitmap::get index]
		set SIdxCount [CIndex_getNumberofSubIndexes $ObjIndex]
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set ObjSIdx [CIndex_getSubIndex $ObjIndex $tmpCount]
			#puts ObjSIdx-->$ObjSIdx
			set xdcFile(1-$cnId-$i-$tmpCount) $ObjSIdx
			set SIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
			#puts SIdxValue:$SIdxValue=======tmpCount:$tmpCount

			set SIdxDefaultValue [CBaseIndex_getDefaultValue $ObjSIdx]
			#puts SIdxDefaultValue:$SIdxDefaultValue
			$updatetree insert end IndexValue-1-$cnId-$i SubIndexValue-1-$cnId-$i-$tmpCount -text $SIdxValue -open 1 -image [Bitmap::get subindex]
		}
	}




}

