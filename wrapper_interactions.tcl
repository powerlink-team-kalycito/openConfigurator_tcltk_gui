proc Import {cn tmpImpDir} {
	global updatetree
	global cnCount

	set errorString []
	set NodeID 1
	set NodeType 1
	
	load ./Tcl_WrapperMain.so
	Tcl_CreateNode $NodeID $NodeType
	Tcl_ImportXML "$tmpImpDir" $errorString $NodeType $NodeID

	set TclObj [new_CNodeCollection]
	set TclNodeObj [new_CNode]
	set TclNodeObj [CNodeCollection_getNode $TclObj $NodeType $NodeID]

	set TclIndexCollection [new_CIndexCollection]
	set TclIndexCollection  [CNode_getIndexCollection $TclNodeObj]

#	set ObjIndex [new_CIndex]
	set count [CIndexCollection_getNumberofIndexes $TclIndexCollection]

	set cnId [split $cn -]
	set cnId [lindex $cnId end]
	for { set i 0 } { $i < $count } { incr i } {
		set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $i]
		set IndexValue [CBaseIndex_getIndexValue $ObjIndex]
		
		$updatetree insert end $cn IndexValue-1-$cnId-$i -text $IndexValue -open 1 -image [Bitmap::get index]
		set SIdxCount [CIndex_getNumberofSubIndexes $ObjIndex]
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set ObjSIdx [CIndex_getSubIndex $ObjIndex $tmpCount]

			set SIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
			puts SIdxValue:$SIdxValue

			set SIdxDefaultValue [CBaseIndex_getDefaultValue $ObjSIdx]
			puts SIdxDefaultValue:$SIdxDefaultValue
			$updatetree insert end IndexValue-1-$cnId-$i SIdxValue-1-$cnId-$i-$tmpCount -text $SIdxValue -open 1 -image [Bitmap::get subindex]
		}
	}




}

