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

    catch "font delete custom1"
    font create custom1 -size 9 -family TkDefaultFont

    if {$choice=="ind"} {
	set st [tablelist::tablelist $st \
	    -columns {0 "Label" left
		      0 "Value" center} \
	    -setgrid no -width 0 -height 1 \
	    -stripebackground gray98  \
	    -labelcommand "" \
	    -resizable 1 -movablecolumns 0 -movablerows 0 \
	    -showseparators 1 -spacing 10 -font custom1]

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
	    -showseparators 1 -spacing 10 -font custom1]
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
    $st configure -height 4 -width 40 -stretch all	
    #puts [$st cget -font]
    #eval font create BoldFont [font actual [$st cget -font]] -weight bold
    #$st columnconfigure 1 -font Courier
    #$st columnconfigure 2 -font Courier
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

#proc EditManager::create_procWindow {nb } {
#    variable TxtWidget
#    
#    set pagename Proclist
#    set frame [$nb insert end $pagename -text "Procs"]
    
#    set sw [ScrolledWindow::create $frame.sw -auto both]
#    set procList [listbox $sw.proc -bg white]
#    $procList configure -exportselection false
#    set item "<none>"
#    $procList insert end $item
#    pack $procList -fill both -expand yes
#    ScrolledWindow::setwidget $sw $procList
#    pack $sw -fill both -expand yes
#    set buttonFrame [frame $frame.buttonFrame -relief sunken -borderwidth 2]
#    set button_prev [Button::create $buttonFrame.bp \
#        -image [Bitmap::get left] \
#        -relief raised\
#        -helptext "Goto previous Position"\
#        -command {Editor::procList_history_get_prev}]
#    set button_next [Button::create $buttonFrame.bn\
#        -image [Bitmap::get right] \
#        -relief raised\
#        -helptext "Goto next Position"\
#    set entryFrame [frame $frame.entryFrame -relief sunken -borderwidth 2]
#    
#    set Editor::lineEntryCombo [ComboBox::create $entryFrame.combo -label "" -labelwidth 0 -labelanchor w \
#        -textvariable Editor::lineNo\
#        -values {""} \
#        -helptext "Enter Linenumber" \
#        -entrybg white\
#        -width 6]
#    set button_go [Button::create $entryFrame.go\
#        -image [Bitmap::get go] \
#        -relief raised\
#        -helptext "Goto Line"\
#        -command {Editor::lineNo_history_add ; Editor::gotoLine $Editor::lineNo}]
#    pack $button_prev -side left -expand yes -padx 2 -pady 5
#    pack $button_next -side left -expand yes -padx 2 -pady 5
#    pack $Editor::lineEntryCombo -side left -fill both -expand yes -pady 0 -ipady 0
#    pack $button_go -side left -expand yes
#    pack $entryFrame -side left -fill both -expand yes -ipadx 2 -padx 1
#    set childList [winfo children $Editor::lineEntryCombo]
#    foreach w $childList {if {[winfo class $w] == "Entry"} { set lineEntry $w ; break}}
#    bind $lineEntry <KeyRelease-Return> {Editor::lineNo_history_add ; Editor::gotoLine $Editor::lineNo}
#    return $frame
#}

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
	$nb itemconfigure $pagename -image [Bitmap::get file]
    } elseif {$choice==2} {    
	set errWindow [errorInit $sw]
	set window $errWindow
	$nb itemconfigure $pagename -image [Bitmap::get error_small]
    } elseif {$choice==3} {    
	set warWindow [warnInit $sw]
	set window $warWindow
	$nb itemconfigure $pagename -image [Bitmap::get warning_small]
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
#proc EditManager::create_testTerminal {nb pagename title} {
#    
#    set frame [$nb insert end $pagename \
#            -text "$title" \
#            -raisecmd "$Editor::notebook raise $pagename" ]
#    
#    set sw [ScrolledWindow::create $frame.sw -auto both]
#    set termWindow [testTermInit $sw]
#    $termWindow configure -wrap word
#    ScrolledWindow::setwidget $sw $termWindow
#    pack $sw -fill both -expand yes
#    
#    return $termWindow
#}

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
	global treeFrame
	variable TxtWidget
	global updatetree
	set pagename objtree
    	set frame [$nb insert end $pagename -text "Tree Browser"]
   	set sw [ScrolledWindow::create $frame.sw -auto both]
   	set objTree [Tree $frame.sw.objTree \
            -width 15\
            -highlightthickness 0\
            -bg white  \
            -deltay 15 \
	    -padx 15 \
	    -dropenabled 0 -dragenabled 0\
	    -opencmd   "Editor::tmoddir 1"  \
            -closecmd  "Editor::tmoddir 0"           
    	]
	$sw setwidget $objTree
	set updatetree $objTree
	#$objTree configure -ipady 15
#puts [$updatetree configure]

	# Call procedure to the read the Project file
	#readxml "output.xml"
	#DeclareStructure
	#readxml $RootDir/NewProject.pjt
	# Call procedure to draw the tree view
	#inserttree
	#set targetconfig myboard_sshscp.exp
	#$objTree insert end root TestSuite -text TestSuite -open 1 -image [Bitmap::get openfold]
    	#set child [$objTree insert end TestSuite TargetConfig -text BoardConfig -open 1 -image [Bitmap::get file]]
	

    
    pack $sw -side top -fill both -expand yes -pady 1
    set treeFrame [frame $frame.f1]  
    #bind $frame <KeyPress-Escape> "puts {escape for tree is pressed}"
    entry $treeFrame.en_find -textvariable FindSpace::txtFindDym -width 10 -background white -validate key -vcmd "FindSpace::Find %P"
    button $treeFrame.b_next -text " Next " -command "FindSpace::Next" -image [Bitmap::get right]
    button $treeFrame.b_prev -text " Prev " -command "FindSpace::Prev" -image [Bitmap::get left]
    grid config $treeFrame.en_find -row 0 -column 0 -sticky ew
    grid config $treeFrame.b_prev -row 0 -column 1 -sticky s -padx 5
    grid config $treeFrame.b_next -row 0 -column 2 -sticky s
    
    #bind $treeFrame.en_find <Configure> "puts {entry key focused}"
        #bind $updatetree <ButtonPress-1> "FindDynWindow"
        #bind . <KeyPress-Escape> "EscapeTree"

    return $frame
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

