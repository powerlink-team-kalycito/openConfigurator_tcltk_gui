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

proc EditManager::create_tab {nb filename choice} {
    global EditorData


    variable TxtWidget
    variable _newPageCounter
    
    incr _newPageCounter
    global tmpNam$_newPageCounter
    global tmpValue$_newPageCounter
    global hexDec$_newPageCounter
    set pageName "Page$_newPageCounter"
    set frame [$nb insert end $pageName -text $filename ]

    set sw [ScrolledWindow $frame.sw]
    pack $sw -fill both -expand true

    set sf [ScrollableFrame $sw.sf]
    $sw setwidget $sf

    set uf [$sf getframe]
    $uf configure -height 20 
	set tabTitlef0 [TitleFrame $uf.tabTitlef0 -text "Sub Index" ]
	set tabInnerf0 [$tabTitlef0 getframe]
	set tabTitlef1 [TitleFrame $uf.tabTitlef1 -text "Properties" ]
	set tabInnerf1 [$tabTitlef1 getframe]

#puts "frame in tab :$frame==tabInnerf0:$tabInnerf0"

	label $tabInnerf0.l_idx     -text "Index  " 
        label $tabInnerf0.l_empty1 -text "" 
	#label $tabInnerf0.l_sidx    -text "Sub Index  "  
        label $tabInnerf0.l_empty2 -text "" 
	label $tabInnerf0.l_nam     -text "Name           " 
        label $tabInnerf0.l_empty3 -text ""  
	label $tabInnerf1.l_obj     -text "Object Type" 
        label $tabInnerf1.l_empty4 -text "" 
	label $tabInnerf1.l_data    -text "Data Type"  
        label $tabInnerf1.l_empty5 -text "" 
	label $tabInnerf1.l_access  -text "Access Type"  
        label $tabInnerf1.l_empty6 -text "" 
	label $tabInnerf1.l_value   -text "Value" 
	label $tabInnerf1.l_upper   -text "Upper Limit" 
	label $tabInnerf1.l_lower   -text "Lower Limit" 
	label $tabInnerf1.l_pdo   -text "PDO Mapping" 
	entry $tabInnerf0.en_idx1    
	$tabInnerf0.en_idx1 insert 0 "1006"
	$tabInnerf0.en_idx1 config -state disabled -bg white
	#global tmpNam$_newPageCounter
	entry $tabInnerf0.en_nam1 -textvariable tmpNam$_newPageCounter -relief ridge -justify center -bg white -width 30 -validate key -vcmd "IsValidStr %P"
	$tabInnerf0.en_nam1 insert 0 "NMT_CycleLen_U32"
	#entry $tabInnerf0.en_sidx1   
	#$tabInnerf0.en_sidx1 insert 0 "00"
	#$tabInnerf0.en_sidx1 config -state disabled
	entry $tabInnerf1.en_obj1    
	$tabInnerf1.en_obj1 insert 0 "VAR"
	$tabInnerf1.en_obj1 config -state disabled
	entry $tabInnerf1.en_data1 
	$tabInnerf1.en_data1 insert 0 "Unsigned32"
	$tabInnerf1.en_data1 config -state disabled
	entry $tabInnerf1.en_access1 
	$tabInnerf1.en_access1 insert 0 "rw"
	$tabInnerf1.en_access1 config -state disabled
	entry $tabInnerf1.en_upper1 
	$tabInnerf1.en_upper1 insert 0 "FF"
	$tabInnerf1.en_upper1 config -state disabled
	entry $tabInnerf1.en_lower1 
	$tabInnerf1.en_lower1 insert 0 "00"
	$tabInnerf1.en_lower1 config -state disabled
	entry $tabInnerf1.en_pdo1 
	$tabInnerf1.en_pdo1 insert 0 "no"
	$tabInnerf1.en_pdo1 config -state disabled

	#global tmpValue$_newPageCounter
	#entry $tabInnerf1.en_value1 -textvariable tmpValue$_newPageCounter  -relief ridge -justify center -bg white
	entry $tabInnerf1.en_value1 -textvariable tmpValue$_newPageCounter  -relief ridge -justify center -bg white -validate key -vcmd "IsDec %P"
	$tabInnerf1.en_value1 insert 0 "0007"
        set frame1 [frame $tabInnerf1.frame1]
        set ra_dec [radiobutton $frame1.ra_dec -text "Dec" -variable hexDec$_newPageCounter -value on -command "ConvertDec $tabInnerf1.en_value1"]
        set ra_hex [radiobutton $frame1.ra_hex -text "Hex" -variable hexDec$_newPageCounter -value off -command "ConvertHex $tabInnerf1.en_value1"]
        $frame1.ra_dec select
	grid config $tabTitlef0 -row 0 -column 0 -sticky ew
	label $uf.l_empty -text ""
	grid config $uf.l_empty -row 1 -column 0
	grid config $tabTitlef1 -row 2 -column 0 -sticky ew

	grid config $tabInnerf0.l_idx -row 0 -column 0 -sticky w
	grid config $tabInnerf0.en_idx1 -row 0 -column 1 -padx 5
	grid config $tabInnerf0.l_empty1 -row 1 -column 0 -columnspan 2
	#grid config $tabInnerf0.l_sidx -row 2 -column 0 -sticky w 
	#grid config $tabInnerf0.en_sidx1 -row 2 -column 2 -padx 5
	#grid config $tabInnerf0.l_nam -row 2 -column 3 -sticky w 
	#grid config $tabInnerf0.en_nam1 -row 2 -column 4  -sticky e
	grid config $tabInnerf0.l_empty2 -row 3 -column 0 -columnspan 2
	grid config $tabInnerf1.l_data -row 0 -column 0 -sticky w 
	grid config $tabInnerf1.en_data1 -row 0 -column 1 -padx 5
	grid config $tabInnerf1.l_upper -row 0 -column 2 -sticky w
	grid config $tabInnerf1.en_upper1 -row 0 -column 3 -padx 5
	grid config $tabInnerf1.l_access -row 0 -column 4 -sticky w 
	grid config $tabInnerf1.en_access1 -row 0 -column 5 -padx 5 
	grid config $tabInnerf1.l_empty4 -row 1 -column 0 -columnspan 2
	grid config $tabInnerf1.l_obj -row 2 -column 0 -sticky w 
	grid config $tabInnerf1.en_obj1 -row 2 -column 1 -padx 5
	grid config $tabInnerf1.l_lower -row 2 -column 2 -sticky w
	grid config $tabInnerf1.en_lower1 -row 2 -column 3 -padx 5
	grid config $tabInnerf1.l_pdo -row 2 -column 4 -sticky w
	grid config $tabInnerf1.en_pdo1 -row 2 -column 5 -padx 5
	grid config $tabInnerf1.l_empty5 -row 3 -column 0 -columnspan 2
	grid config $tabInnerf1.l_value -row 4 -column 0 -sticky w
	grid config $tabInnerf1.en_value1 -row 4 -column 1 -padx 5 
	grid config $frame1 -row 4 -column 3 -padx 5 -columnspan 2 -sticky w
	grid config $tabInnerf1.l_empty6 -row 5 -column 0 -columnspan 2

	grid config $ra_dec -row 0 -column 0 -sticky w
	grid config $ra_hex -row 0 -column 1 -sticky w
   if {$choice=="ind"} {
	$tabTitlef0 configure -text "Index" 
	$tabTitlef1 configure -text "Properties" 
	#set tmpValue$_newPageCounter test
	#$tabInnerf1.en_value1 insert 0 test123
	#$tabInnerf1.en_value$_newPageCounter configure -bg green
	grid config $tabInnerf0.l_idx -row 0 -column 0 -sticky w
	grid config $tabInnerf0.en_idx1 -row 0 -column 1 -sticky w -padx 0
	grid config $tabInnerf0.l_nam -row 2 -column 0 -sticky w 
	grid config $tabInnerf0.en_nam1 -row 2 -column 1  -sticky w -columnspan 1

   } elseif {$choice=="sub"} {
	$tabTitlef0 configure -text "Sub Index" 
	$tabTitlef1 configure -text "Properties" 
	label $tabInnerf0.l_sidx    -text "Sub Index  "  
	entry $tabInnerf0.en_sidx1   

        #$tabInnerf1.en_value1 insert 0 "0008"
	#$tabInnerf0.en_nam1 insert 0 "test"
	$tabInnerf0.en_sidx1 insert 0 "00"
	$tabInnerf0.en_sidx1 config -state disabled
	grid config $tabInnerf0.l_sidx -row 2 -column 0 -sticky w 
	grid config $tabInnerf0.en_sidx1 -row 2 -column 1 -padx 5
	grid config $tabInnerf0.l_nam -row 2 -column 2 -sticky w 
	grid config $tabInnerf0.en_nam1 -row 2 -column 3  -sticky e -columnspan 1
   }

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

    $nb itemconfigure $pageName -state disabled
    #$nb raise $pageName
    incr Editor::index_counter
    #return [list $frame $pageName]
    return [list $uf $pageName $tabInnerf0 $tabInnerf1 ]
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

    $sw setwidget $st
    pack $st -fill both -expand true
    $nb itemconfigure $pageName -state disabled
    $st configure -height 4 -width 40 -stretch all	
    incr Editor::index_counter
    return  $st
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
	global updatetree

	variable TxtWidget
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
	
    pack $sw -side top -fill both -expand yes -pady 1
    set treeFrame [frame $frame.f1]  
    #bind $frame <KeyPress-Escape> "puts {escape for tree is pressed}"
    entry $treeFrame.en_find -textvariable FindSpace::txtFindDym -width 10 -background white -validate key -vcmd "FindSpace::Find %P"
    button $treeFrame.b_next -text " Next " -command "FindSpace::Next" -image [Bitmap::get right]
    button $treeFrame.b_prev -text " Prev " -command "FindSpace::Prev" -image [Bitmap::get left]
    grid config $treeFrame.en_find -row 0 -column 0 -sticky ew
    grid config $treeFrame.b_prev -row 0 -column 1 -sticky s -padx 5
    grid config $treeFrame.b_next -row 0 -column 2 -sticky s
    return $frame
}

proc ConvertDec {tmpValue} {
	#puts DectmpValue->$tmpValue
	set tmpVar [$tmpValue cget -textvariable]
	global $tmpVar
	#puts "value in convertdec->[subst $[subst $tmpVar]] "
	set $tmpVar [expr 0x[subst $[subst $tmpVar]] ]
	$tmpValue configure -validate key -vcmd "IsDec %P"
	puts tmpVar->$tmpVar
	#set $tmpVar check
}

proc ConvertHex {tmpValue} {
	puts HextmpValue->$tmpValue
	set tmpVar [$tmpValue cget -textvariable]
	global $tmpVar	
	#puts "value in converthex->[subst $[subst $tmpVar]] "
	set $tmpVar [format %X [subst $[subst $tmpVar]] ]
	$tmpValue configure -validate key -vcmd "IsHex %P $tmpVar"
	puts tmpVar->$tmpVar
	#set $tmpVar test
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

