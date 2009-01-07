#########################################################################
#									
# Script:	manager.tcl (namespace EditManager)
#									
# Author:	Kalycito Infotech Pvt Ltd		
#									
# Description:	creates the main windows (editor, console, code browser etc.)
#		based on BWidget´s.
#
# Version:	Initially released version.
#
#########################################################################

# Variables in EditManager
namespace eval EditManager {
    variable _progress 0
    variable _afterid  ""
    variable _status "Compute in progress..."
    variable _homogeneous 0
    variable _newPageCounter 0
    variable _newConsoleCounter 0
    variable lastPage ""
}

###########################################################################							
# Proc Name:	focus_text					
# Inputs:	nb, pagename 
# Outputs:	-	
# Description:	Set the focus to the selected file.  
###########################################################################
#proc EditManager::focus_text {nb pagename} {
#    global EditorData
    
#    if {[info exists Editor::current(pagename)] && $Editor::current(pagename) == $pagename} {
#        return
#    } else  {
#        if {[catch Editor::tclose info]} {
            # tk_messageBox -message $info
#        }
#    }
    
#    set text_page [$nb getframe $pagename]
#save values of last active textWindow
#    if {[info exists Editor::current(text)]} {\
#        set f0 $Editor::current(text)
#        set p0 $Editor::current(pagename)
        
#        if {[info exists Editor::index($f0)]} {\
#            
#            set idx $Editor::index($f0)
#            set Editor::text_win($idx,hasChanged) $Editor::current(hasChanged)
#            set Editor::text_win($idx,file) $Editor::current(file)
#            set Editor::text_win($idx,slave) $Editor::current(slave)
#            set Editor::text_win($idx,project) $Editor::current(project)
#            set Editor::text_win($idx,history) $Editor::current(procListHistory)
#            set Editor::text_win($idx,writable) $Editor::current(writable)
#        }
#    }
#    set Editor::current(text) $text_page.sw.textWindow
#    set Editor::current(page) $text_page
#    set idx $Editor::index($Editor::current(text))
#    set Editor::current(undo_id)  $Editor::text_win($idx,undo_id)
#    set Editor::current(hasChanged) $Editor::text_win($idx,hasChanged)
#    set Editor::current(file) $Editor::text_win($idx,file)
#    set Editor::current(pagename) $Editor::text_win($idx,pagename)
#    set Editor::current(slave) $Editor::text_win($idx,slave)
#    set Editor::current(project) $Editor::text_win($idx,project)
#    set Editor::current(procListHistory) $Editor::text_win($idx,history)
#    set Editor::current(writable) $Editor::text_win($idx,writable)
#    #restore Cursor position
#    set Editor::last(index) $idx
#    focus $Editor::current(text)
#    NoteBook::see $nb $pagename
#    set editorWindows::TxtWidget $Editor::current(text)
#    set EditorData(curFile) $Editor::current(file)
#    $Editor::current(text) see insert
#    editorWindows::ReadCursor 0
#    editorWindows::flashLine
#    if {!$Editor::current(initDone)} {
#        Editor::updateObjects
#        Editor::selectObject 0
#        set Editor::current(initDone) 1
#    } else {
#        Editor::topen
#        Editor::selectObject 0
#    }
#    catch {$Editor::con_notebook raise $pagename}
#}


#proc EditManager::create_text {nb file} {
#    global EditorData
#    variable TxtWidget
#    variable _newPageCounter
    
#    incr _newPageCounter
#    set pageName "Page$_newPageCounter"
#    set filename [file tail $file]
#    set prjFile [file join [file dirname $file] [lindex [split $filename .] 0]].prj
#    set frame [$nb insert end $pageName -text $filename \
#        -raisecmd "EditManager::focus_text $nb $pageName" ]
#    set sw [ScrolledWindow::create $frame.sw -auto both]
#    set text [text $sw.textWindow -bg white -wrap none \
#        -font $EditorData(options,fonts,editorFont) -height 20 -width 80]
#    pack $text -fill both -expand yes
#    ScrolledWindow::setwidget $sw $text
#    pack $sw -fill both -expand yes
    
    # init bindings for the text widget
#    set editorWindows::TxtWidget $text
#    editorWindows::setBindings
    
#    incr Editor::index_counter
#    set Editor::index($text) $Editor::index_counter
#    set Editor::text_win($Editor::index_counter,page) $frame
#    set Editor::text_win($Editor::index_counter,path) $text
#    set Editor::text_win($Editor::index_counter,hasChanged) 0
#    set Editor::text_win($Editor::index_counter,file) $file
#    set Editor::text_win($Editor::index_counter,writable) 1
#    set Editor::text_win($Editor::index_counter,pagename) $pageName
#    set Editor::text_win($Editor::index_counter,slave) "none"
#    set Editor::text_win($Editor::index_counter,history) [list "mark1"]
#    if {[file exists $prjFile]} {
#        set fd [open $prjFile r]
#        set Editor::text_win($Editor::index_counter,project) [read $fd]
#        close $fd
#    } else  {
#        set Editor::text_win($Editor::index_counter,project) $EditorData(options,defaultProjectFile)
#    }
#    set Editor::current(initDone) 0
#    return [list $frame $pageName $text]
#}

#to create the tabs
proc EditManager::create_tab {nb filename} {
    global EditorData
    variable TxtWidget
    variable _newPageCounter
    
    incr _newPageCounter
    set pageName "Page$_newPageCounter"
    set frame [$nb insert end $pageName -text $filename ]

    set sw [ScrolledWindow $frame.sw]

    pack $sw -fill both -expand true


    set sf [ScrollableFrame $sw.sf]
    #$sf configure -bg white
    $sw setwidget $sf

    #pack $sf -fill both -expand true

    set uf [$sf getframe]
    $uf configure -height 20 
    #pack $uf -fill both -expand true
    #$uf config -bg blue

    incr Editor::index_counter
    #return [list $frame $pageName]
    return [list $uf $pageName]
    #return [list $sf $pageName]
}



proc EditManager::create_table {nb filename choice} {
    global EditorData
    variable TxtWidget
    variable _newPageCounter
    
    incr _newPageCounter
    set pageName "Page$_newPageCounter"
    set frame [$nb insert end $pageName -text $filename ]

    set sw [ScrolledWindow $frame.sw]
    pack $sw -fill both -expand true
    set st $frame.st
    #set vsb $frame.vsb
    #set hsb $frame.hsb

    if {$choice=="ind"} {
	set st [tablelist::tablelist $st \
	    -columns {0 "Label" left
		      0 "Value" center} \
	    -setgrid no -width 0 -height 1 \
	    -stripebackground gray98  \
	    -labelcommand "" \
	    -resizable 1 -movablecolumns 0 -movablerows 0 \
	    -showseparators 1 -spacing 10 ]
            ##-xscrollcommand [list $hsb set] -yscrollcommand [list $vsb set]

	set fram [frame $frame.f1]  
	label $fram.l_empty -text "  " -height 1 
	button $fram.b_sav -text " Save " -command "YetToImplement"
	label $fram.l_empty1 -text "  "
	button $fram.b_dis -text "Discard" -command "YetToImplement"
	grid config $fram.l_empty -row 0 -column 0 -columnspan 2
	grid config $fram.b_sav -row 1 -column 0 -sticky s
	grid config $fram.l_empty1 -row 1 -column 1 -sticky s
	grid config $fram.b_dis -row 1 -column 2 -sticky s
	pack $fram -side bottom
    } elseif {$choice=="pdo"} {
	set st [tablelist::tablelist $st \
	    -columns {0 "No" left
		      0 "Mapping Entries" center
		      0 "Index" center
		      0 "Sub Index"
		      0 "Reserved"
		      0 "Offset"
		      0 "Length"} \
	    -setgrid 0 -width 0 \
	    -stripebackground gray98 \
	    -resizable 1 -movablecolumns 0 -movablerows 0 \
	    -showseparators 1 -spacing 10 ]
            ##-xscrollcommand [list $hsb set] -yscrollcommand [list $vsb set]
   }
        ##scrollbar $vsb -orient vertical   -command [list $st yview]
        ##scrollbar $hsb -orient horizontal -command [list $st xview]
   #$st columnconfigure 0 -background #e0e8f0 -width 47
   #$st columnconfigure 1 -background #e0e8f0 -width 47

   #$st insert 0 [list Index: 1006 ""]
   #$st insert 1 [list Name: NMT_CycleLen_U32 ""]
   #$st insert 2 [list Object\ Type: VAR ""]
   #$st insert 3 [list Data\ Type: Unsigned32 ""]
   #$st insert 4 [list Access\ Type: rw ""]
   #$st insert 5 [list Value: 0007 ""]

    $sw setwidget $st
    pack $st -fill both -expand true
    ##pack $vsb -side right 
    ##pack $hsb 
    $nb itemconfigure $pageName -state disabled

    #set sf [ScrollableFrame $sw.sf]
    #$sf configure -bg white


    #pack $sf -fill both -expand true

    #set uf [$sf getframe]
    #$uf configure -height 20 

    #$uf config -bg blue

    #set frame6 [frame $st.f]
    #set frame5 [frame $frame.f]
    #pack $frame5 -side bottom -ipady 4

    #pack $frame6 -side bottom -ipady 4
    incr Editor::index_counter
    #return [list $frame $pageName]
    #return [list $uf $pageName]
    return  $st
}

###########################################################################							
# Proc Name:	create_procWindow					
# Inputs:	nb
# Outputs:	frame.
# Description:	Create the procedure window for the procedures in
#		the selected file.  
###########################################################################

proc EditManager::create_procWindow {nb } {
    variable TxtWidget
    
    set pagename Proclist
    set frame [$nb insert end $pagename -text "Procs"]
    
    set sw [ScrolledWindow::create $frame.sw -auto both]
    set procList [listbox $sw.proc -bg white]
    $procList configure -exportselection false
    set item "<none>"
    $procList insert end $item
    pack $procList -fill both -expand yes
    ScrolledWindow::setwidget $sw $procList
    pack $sw -fill both -expand yes
    set buttonFrame [frame $frame.buttonFrame -relief sunken -borderwidth 2]
    set button_prev [Button::create $buttonFrame.bp \
        -image [Bitmap::get left] \
        -relief raised\
        -helptext "Goto previous Position"\
        -command {Editor::procList_history_get_prev}]
    set button_next [Button::create $buttonFrame.bn\
        -image [Bitmap::get right] \
        -relief raised\
        -helptext "Goto next Position"\
        -command {Editor::procList_history_get_next}]
    set entryFrame [frame $frame.entryFrame -relief sunken -borderwidth 2]
    
    set Editor::lineEntryCombo [ComboBox::create $entryFrame.combo -label "" -labelwidth 0 -labelanchor w \
        -textvariable Editor::lineNo\
        -values {""} \
        -helptext "Enter Linenumber" \
        -entrybg white\
        -width 6]
    set button_go [Button::create $entryFrame.go\
        -image [Bitmap::get go] \
        -relief raised\
        -helptext "Goto Line"\
        -command {Editor::lineNo_history_add ; Editor::gotoLine $Editor::lineNo}]
    pack $button_prev -side left -expand yes -padx 2 -pady 5
    pack $button_next -side left -expand yes -padx 2 -pady 5
    pack $Editor::lineEntryCombo -side left -fill both -expand yes -pady 0 -ipady 0
    pack $button_go -side left -expand yes
    pack $entryFrame -side left -fill both -expand yes -ipadx 2 -padx 1
    set childList [winfo children $Editor::lineEntryCombo]
    foreach w $childList {if {[winfo class $w] == "Entry"} { set lineEntry $w ; break}}
    bind $lineEntry <KeyRelease-Return> {Editor::lineNo_history_add ; Editor::gotoLine $Editor::lineNo}
    return $frame
}

###########################################################################							
# Proc Name:	create_conWindow					
# Inputs:	nb.
# Outputs:	frame.
# Description:	Create the Output Console for the OutPut display and 
#		User Interactions.
###########################################################################
proc EditManager::create_conWindow {nb text choice} {
    global conWindow
    global warWindow
    global errWindow
    variable _newConsoleCounter
    
    incr _newConsoleCounter

    set pagename Console$_newConsoleCounter
    set frame [$nb insert end $pagename -text $text]
    
    set sw [ScrolledWindow::create $frame.sw -auto both]
    if {$choice==1} {
	set conWindow [consoleInit $sw]
	set window $conWindow
    } elseif {$choice==2} {    
	set errWindow [errorInit $sw]
	set window $errWindow
    } elseif {$choice==3} {    
	set warWindow [warnInit $sw]
	set window $warWindow
    } else {
	#invalid selection
	return
    }
    $window configure -wrap word
    ScrolledWindow::setwidget $sw $window
    pack $sw -fill both -expand yes

    #raised the window after creating it 
    $nb raise $pagename
    #return [$frame $pagename]
	return $frame
}
###########################################################################							
# Proc Name:	create_testTerminal					
# Inputs:	nb, pagename, title
# Outputs:	terminal window.
# Description:	
###########################################################################
proc EditManager::create_testTerminal {nb pagename title} {
    
    set frame [$nb insert end $pagename \
            -text "$title" \
            -raisecmd "$Editor::notebook raise $pagename" ]
    
    set sw [ScrolledWindow::create $frame.sw -auto both]
    set termWindow [testTermInit $sw]
    $termWindow configure -wrap word
    ScrolledWindow::setwidget $sw $termWindow
    pack $sw -fill both -expand yes
    
    return $termWindow
}

################################################################################
# 
# Proc Name:	create_treeWindow
# Inputs:	nb
# Outputs :	frame
# Description:	create a tree window for the object tree, using BWidgets treewidget
#
################################################################################

proc EditManager::create_treeWindow {nb } {
    	global RootDir
	variable TxtWidget
	global updatetree
	set pagename objtree
    	set frame [$nb insert end $pagename -text "Tree Browser"]
   
   	set sw [ScrolledWindow::create $frame.sw -auto both]
   	set objTree [Tree $frame.sw.objTree \
            -width 15\
            -highlightthickness 0\
            -bg white  \
            -deltay 18 \
	    -dropenabled 0 -dragenabled 0\
	    -dragevent 1 \
	    -droptypes {
		TREE_NODE {copy {}}
	     }\
	    -dropcmd {} \
	    -dragendcmd {}\
	    -opencmd   "Editor::tmoddir 1"  \
            -closecmd  "Editor::tmoddir 0"           
    	]
	$sw setwidget $objTree
	set updatetree $objTree

	# Call procedure to the read the Project file
	#readxml "output.xml"
	#DeclareStructure
	#readxml $RootDir/NewProject.pjt
	# Call procedure to draw the tree view
	#inserttree
	#set targetconfig myboard_sshscp.exp
	#$objTree insert end root TestSuite -text TestSuite -open 1 -image [Bitmap::get openfold]
    	#set child [$objTree insert end TestSuite TargetConfig -text BoardConfig -open 1 -image [Bitmap::get file]]
	
    #navigator frame
    set naviframe [frame $frame.naviFrame -height 20 -width 150]
    #History Buttons
    set buttonFrame [frame $naviframe.buttonFrame -relief sunken -borderwidth 2 ]
    set button_prev [Button::create $buttonFrame.bp \
        -image [Bitmap::get left] \
        -relief raised\
        -helptext "Goto previous Position"\
        -command {Editor::procList_history_get_prev}]
    set button_next [Button::create $buttonFrame.bn\
        -image [Bitmap::get right] \
        -relief raised\
        -helptext "Goto next Position"\
        -command {Editor::procList_history_get_next}]
    # Line number etc.
    
    set entryFrame [frame $naviframe.entryFrame -relief sunken -borderwidth 2]
    set Editor::lineEntryCombo [ComboBox::create $entryFrame.combo -label "" -labelwidth 0 -labelanchor w \
        -textvariable Editor::lineNo\
        -values {""} \
        -helptext "Enter Linenumber" \
        -entrybg white\
        -width 6]
    
    set button_go [Button::create $entryFrame.go\
        -image [Bitmap::get go] \
        -relief raised\
        -helptext "Goto Line"\
        -command {Editor::lineNo_history_focadd ; Editor::gotoLine $Editor::lineNo}]
    
    pack $naviframe -side bottom -fill x
    pack $sw -side top -fill both -expand yes -pady 1
    set childList [winfo children $Editor::lineEntryCombo]
    foreach w $childList {if {[winfo class $w] == "Entry"} { set lineEntry $w ; break}}
    bind $lineEntry <KeyRelease-Return> {Editor::lineNo_history_add ; Editor::gotoLine $Editor::lineNo}
    return $frame
}

###########################################################################
# Proc Name:	dropfunction					
# Inputs:	treewidget,drag_source,lDrop,op,dataType, data.
# Outputs:	-
# Description:	Based on the Drop Position the Tree order and the data 
#	  	are reordered.
#
# Version : Older
###########################################################################
proc dropfunction {treewidget drag_source lDrop op dataType data} {

        global totaltc
        global updatetree
	
	variable loop

	# If the Drop Position is anywhere in the window No modification
 	if {$lDrop == "widget"} { 
		return 1;
	}	
	# To (Destination) Data
	set node_pos [lindex $lDrop [expr [llength $lDrop] - 2]]
 	if {$node_pos == "node"} { return 1; }	
	puts "whats this=$node_pos"
	set tmpsplit [split $node_pos "-"]
			set totestgroupposition [lindex $tmpsplit [expr [llength $tmpsplit] - 1]]
			puts totestgroupposition->$totestgroupposition
			set totestcaseposition [lindex $lDrop [expr [llength $lDrop] - 1]]
			puts totestcaseposition->$totestcaseposition
	
	##puts totestgroupposition->$totestgroupposition
	##puts totestcaseposition->$totestcaseposition
	
	# From (source) Data 
	set data_pos [lindex $data [expr [llength $data] - 1]]
 	puts Frtdata->$data_pos
	set tmpsplit [split $data_pos "-"]
			set frtestcaseposition [lindex $tmpsplit [expr [llength $tmpsplit] - 1]]
			set frtestgroupposition [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
	
	puts frtestgroupposition->$frtestgroupposition
	puts frtestcaseposition->$frtestcaseposition
	# Different Group
	if { $totestgroupposition != $frtestgroupposition } { 		
		return 1;
	 }
	set currenttotalcase $totaltc($totestgroupposition)
	puts currenttotalcase$currenttotalcase
	# Get Drag Values.
	set dragName [arrTestCase($frtestgroupposition)($frtestcaseposition) cget -memCasePath]
	set dragExecCount [arrTestCase($frtestgroupposition)($frtestcaseposition) cget -memCaseExecCount]
	set dragRunoptions [arrTestCase($frtestgroupposition)($frtestcaseposition) cget -memCaseRunoptions]
	set dragCaseprofile [arrTestCase($frtestgroupposition)($frtestcaseposition) cget -memCaseProfile]
	set dragHeader [arrTestCase($frtestgroupposition)($frtestcaseposition) cget -memHeaderPath]
	# Rearranging the Data in the Group
	if { $totestcaseposition == $frtestcaseposition } {
		 puts equal...Terminated
		return 1
	} elseif {$frtestcaseposition < $totestcaseposition} {
		puts ToptoDown
		if { $totestcaseposition == [expr {$frtestcaseposition + 1}] } {
			return 1
		} 
		incr totestcaseposition -1
		# Move datas one position up upto toposition
		set tmpcount [expr {$frtestcaseposition + 1} ]
		for { set count $frtestcaseposition } { $count <= $totestcaseposition && $tmpcount <= $totestcaseposition } { incr count} {
			arrTestCase($frtestgroupposition)($count)  configure -memCasePath [arrTestCase($frtestgroupposition)($tmpcount) cget -memCasePath]
			arrTestCase($frtestgroupposition)($count)  configure -memCaseExecCount [arrTestCase($frtestgroupposition)($tmpcount) cget -memCaseExecCount]
			arrTestCase($frtestgroupposition)($count)  configure -memCaseRunoptions [arrTestCase($frtestgroupposition)($tmpcount) cget -memCaseRunoptions]
			arrTestCase($frtestgroupposition)($count)  configure -memCaseProfile [arrTestCase($frtestgroupposition)($tmpcount) cget -memCaseProfile]
			arrTestCase($frtestgroupposition)($count)  configure -memHeaderPath [arrTestCase($frtestgroupposition)($tmpcount) cget -memHeaderPath]
		incr tmpcount
		}
		# Put the Drag value to drop position
		arrTestCase($frtestgroupposition)($totestcaseposition)  configure -memCasePath $dragName
		arrTestCase($frtestgroupposition)($totestcaseposition)  configure -memCaseExecCount $dragExecCount
		arrTestCase($frtestgroupposition)($totestcaseposition)  configure -memCaseRunoptions $dragRunoptions
		arrTestCase($frtestgroupposition)($totestcaseposition)  configure -memCaseProfile $dragCaseprofile
		arrTestCase($frtestgroupposition)($totestcaseposition)  configure -memHeaderPath $dragHeader

		# Delete the records in Treeview 
		for {set count $frtestcaseposition } {$count <= $currenttotalcase} {incr count } {
			set temp -$frtestgroupposition
			append temp -$count
			set child [$updatetree delete path$temp]	
		}
		# ReDraw the Nodes 
		for {set count $frtestcaseposition } {$count <= $currenttotalcase } {incr count } {
			set tmpname [arrTestCase($frtestgroupposition)($count) cget -memCasePath]
			# Spliting Name from whole path
			set tmpsplit [split $tmpname /]
			set tmpname [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
			set tmpheader [arrTestCase($frtestgroupposition)($count) cget -memHeaderPath]
			# Spliting header from whole path
			if {$tmpheader!="None"} {
				set tmpsplit [split $tmpheader /]
				set tmpheader [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
			} else {
				set tmpheader "None"
			}
			set temp -$frtestgroupposition
			append temp -$count
			set runoptions [arrTestCase($frtestgroupposition)($count) cget -memCaseRunoptions]
			if {$runoptions=="NN"} {
				set child [$updatetree insert $count TestGroup-$frtestgroupposition path$temp -text $tmpname  -open 0 -image [Bitmap::get file] -window [Bitmap::get userdefined_unchecked]]
			} elseif {$runoptions=="NB"} {
				set child [$updatetree insert $count TestGroup-$frtestgroupposition path$temp -text $tmpname  -open 0 -image [Bitmap::get file_brkpoint] -window [Bitmap::get userdefined_unchecked]]
			} elseif {$runoptions=="CN"} {
				set child [$updatetree insert $count TestGroup-$frtestgroupposition path$temp -text $tmpname  -open 0 -image [Bitmap::get file] -window [Bitmap::get userdefined_checked]]
			} elseif {$runoptions=="CB"} {
				set child [$updatetree insert $count TestGroup-$frtestgroupposition path$temp -text $tmpname  -open 0 -image [Bitmap::get file_brkpoint] -window [Bitmap::get userdefined_checked]]
			}
			set child [$updatetree insert 1 path$temp  ExecCount$temp -text [arrTestCase($frtestgroupposition)($count) cget -memCaseExecCount] -open 0 -image [Bitmap::get palette]]

			set child [$updatetree insert 2 path$temp  header$temp -text $tmpheader  -open 0 -image [Bitmap::get palette]]
		}
		# Print the reorderd values (Testing purpose)
		##Testing 
			
	} else {
		puts DowntoTop
		#if { $totestcaseposition == [expr {$frtestcaseposition - 1}] } {
		#	return 1
		#} else { 
			
			#set zeroposition 0
			if { $totestcaseposition == 0 } {
				set totestcaseposition 1
				# Flag for toposition-> zero
				#set zeroposition 1
			}
			set tmpcount [expr {$frtestcaseposition - 1} ]
			for { set count $frtestcaseposition } { $tmpcount >= $totestcaseposition } { incr count -1} {
				arrTestCase($frtestgroupposition)($count)  configure -memCasePath [arrTestCase($frtestgroupposition)($tmpcount) cget -memCasePath]
				arrTestCase($frtestgroupposition)($count)  configure -memCaseExecCount [arrTestCase($frtestgroupposition)($tmpcount) cget -memCaseExecCount]
				arrTestCase($frtestgroupposition)($count)  configure -memCaseRunoptions [arrTestCase($frtestgroupposition)($tmpcount) cget -memCaseRunoptions]
				arrTestCase($frtestgroupposition)($count)  configure -memCaseProfile [arrTestCase($frtestgroupposition)($tmpcount) cget -memCaseProfile]
				arrTestCase($frtestgroupposition)($count)  configure -memHeaderPath [arrTestCase($frtestgroupposition)($tmpcount) cget -memHeaderPath]
				incr tmpcount -1
			}
			#if { $zeroposition != 1 } {
			#	incr totestcaseposition
			#}
			 
			# Put the Drag value to drop position
			arrTestCase($totestgroupposition)($totestcaseposition)  configure -memCasePath $dragName
			arrTestCase($totestgroupposition)($totestcaseposition)  configure -memCaseExecCount $dragExecCount
			arrTestCase($totestgroupposition)($totestcaseposition)  configure -memCaseRunoptions $dragRunoptions
			arrTestCase($totestgroupposition)($totestcaseposition)  configure -memCaseProfile $dragCaseprofile
			arrTestCase($totestgroupposition)($totestcaseposition)  configure -memHeaderPath $dragHeader

			# Delete the records in Treeview 
			for {set count $totestcaseposition } {$count <= $currenttotalcase} {incr count } {
				set temp -$frtestgroupposition
				append temp -$count
				set child [$updatetree delete path$temp]	
			}
			
			# ReDraw the Nodes 
			for {set count $totestcaseposition } {$count <= $currenttotalcase } {incr count } {
				set tmpname [arrTestCase($totestgroupposition)($count) cget -memCasePath]
				# Spliting Name from whole path
				set tmpsplit [split $tmpname /]
				set tmpname [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
				set tmpheader [arrTestCase($totestgroupposition)($count) cget -memHeaderPath]
				# Spliting header from whole path
				if {$tmpheader!="None"} {
					set tmpsplit [split $tmpheader /]
					set tmpheader [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
				} else {
					set tmpheader "None"
				}
				set temp -$frtestgroupposition
				append temp -$count
				set runoptions [arrTestCase($totestgroupposition)($count) cget -memCaseRunoptions]
				if {$runoptions=="NN"} {
					set child [$updatetree insert $count TestGroup-$totestgroupposition path$temp -text $tmpname  -open 0 -image [Bitmap::get file] -window [Bitmap::get userdefined_unchecked]]
				} elseif {$runoptions=="NB"} {
					set child [$updatetree insert $count TestGroup-$totestgroupposition path$temp -text $tmpname  -open 0 -image [Bitmap::get file_brkpoint] -window [Bitmap::get userdefined_unchecked]]
				} elseif {$runoptions=="CN"} {
					set child [$updatetree insert $count TestGroup-$totestgroupposition path$temp -text $tmpname  -open 0 -image [Bitmap::get file] -window [Bitmap::get userdefined_checked]]
				} elseif {$runoptions=="CB"} {
					set child [$updatetree insert $count TestGroup-$totestgroupposition path$temp -text $tmpname  -open 0 -image [Bitmap::get file_brkpoint] -window [Bitmap::get userdefined_checked]]
				}
				set child [$updatetree insert 1 path$temp  ExecCount$temp -text [arrTestCase($frtestgroupposition)($count) cget -memCaseExecCount] -open 0 -image [Bitmap::get palette]]
				set child [$updatetree insert 2 path$temp  header$temp -text $tmpheader  -open 0 -image [Bitmap::get palette]]
			}
			# Print the reorderd values (Testing purpose)
			##Testing 
		#} 		
		
	}
}
############################For Testing############################

proc Testing { } {
	global tg_count
	global totaltc
	set totaltestgroup $tg_count
	for {set GroupCount 1 } {$GroupCount <= $totaltestgroup} {incr GroupCount } {
		set currenttotalcase $totaltc($GroupCount) 
		for {set CaseCount 1 } {$CaseCount <= $currenttotalcase } {incr CaseCount } {
			
			set value [arrTestCase($GroupCount)($CaseCount) cget -memCasePath] 
		}		
	}	


}

