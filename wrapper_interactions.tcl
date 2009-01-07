proc Import {cn tmpImpDir} {
	global updatetree
	global cnCount
	load ./Tcl_WrapperMain.so
	Tcl_ImportXML "$tmpImpDir"
	set TclObj [new_CNodeCollection]
	set TclNodeObj [new_CNode]
	set TclNodeObj  [CNodeCollection_getNode $TclObj "1" "1"]
	set TclIndexCollection [new_CIndexCollection]
	set TclIndexCollection  [CNode_getIndexCollection $TclNodeObj]
	set ObjIndex [new_CIndex]
	set count [CIndexCollection_getNumberofIndexes $TclIndexCollection]
	set cnId [split $cn -]
	set cnId [lindex $cnId end]
	for { set i 0 } { $i < $count } { incr i } {
		set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $i]
		set Index [CBaseIndex_getIndex $ObjIndex]
		$updatetree insert 0 $cn Index-1-$cnId-$i -text $Index -open 1 -image [Bitmap::get index]
	}
}


