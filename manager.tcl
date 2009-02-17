###############################################################################################
#
#
# NAME:     manager.tcl
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
#  Description:  Creates the main windows (tablelist, console, tabs, tree)
#		based on BWidgets.
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

# Variables in EditManager
namespace eval EditManager {
    variable _newPageCounter 0
    variable _newConsoleCounter 0
}

###############################################################################################
#proc EditManager::create_tab
#Input       : notebook path, title, choice
#Output      : frame, pagename, InnerFrame0, InnerFrame1 
#Description : Creates the GUI for Index and subindex
###############################################################################################
proc EditManager::create_tab {nb filename choice} {
    	global EditorData

    	variable _newPageCounter
    
    	incr _newPageCounter
    	global tmpNam$_newPageCounter
    	global tmpValue$_newPageCounter
    	#global hexDec$_newPageCounter
	global hexDec1
    	set pageName "page$_newPageCounter"
    	#set frame [$nb insert end $pageName -text $filename ]

	set outerFrame [frame $nb.$pageName -relief raised -borderwidth 1 ] ; #newly added
	set frame [frame $outerFrame.frame -relief flat -borderwidth 10  ] ; #newly added
	pack $frame -expand yes -fill both ; #newly added

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

	label $tabInnerf0.l_idx     -text "Index  " 
        label $tabInnerf0.l_empty1 -text "" 
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
	label $tabInnerf1.l_default -text "Default Value" 
	label $tabInnerf1.l_upper   -text "Upper Limit" 
	label $tabInnerf1.l_lower   -text "Lower Limit" 
	label $tabInnerf1.l_pdo   -text "PDO Mapping" 

	entry $tabInnerf0.en_idx1 -state disabled 
	entry $tabInnerf0.en_nam1 -textvariable tmpNam$_newPageCounter -relief ridge -justify center -bg white -width 30 -validate key -vcmd "IsValidStr %P"
	entry $tabInnerf1.en_obj1 -state disabled   
	entry $tabInnerf1.en_data1 -state disabled
	entry $tabInnerf1.en_access1 -state disabled
	entry $tabInnerf1.en_upper1 -state disabled
	entry $tabInnerf1.en_lower1 -state disabled
	entry $tabInnerf1.en_pdo1 -state disabled
	entry $tabInnerf1.en_default1 -state disabled
	entry $tabInnerf1.en_value1 -textvariable tmpValue$_newPageCounter  -relief ridge -justify center -bg white -validate key -vcmd "IsDec %P $tabInnerf1.en_value1"

        set frame1 [frame $tabInnerf1.frame1]
        #set ra_dec [radiobutton $frame1.ra_dec -text "Dec" -variable hexDec$_newPageCounter -value on -command "ConvertDec $tabInnerf1.en_value1"]
        #set ra_hex [radiobutton $frame1.ra_hex -text "Hex" -variable hexDec$_newPageCounter -value off -command "ConvertHex $tabInnerf1.en_value1"]
        set ra_dec [radiobutton $frame1.ra_dec -text "Dec" -variable hexDec1 -value dec -command "ConvertDec $tabInnerf1"]
        set ra_hex [radiobutton $frame1.ra_hex -text "Hex" -variable hexDec1 -value hex -command "ConvertHex $tabInnerf1"]
        $frame1.ra_dec select
	grid config $tabTitlef0 -row 0 -column 0 -sticky ew
	label $uf.l_empty -text ""
	grid config $uf.l_empty -row 1 -column 0
	grid config $tabTitlef1 -row 2 -column 0 -sticky ew

	grid config $tabInnerf0.l_idx -row 0 -column 0 -sticky w
	grid config $tabInnerf0.en_idx1 -row 0 -column 1 -padx 5
	grid config $tabInnerf0.l_empty1 -row 1 -column 0 -columnspan 2
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
	grid config $frame1 -row 4 -column 2 -padx 5 -columnspan 2 -sticky w
	grid config $tabInnerf1.l_default -row 4 -column 4 -sticky w
	grid config $tabInnerf1.en_default1 -row 4 -column 5 -padx 5 
	grid config $tabInnerf1.l_empty6 -row 5 -column 0 -columnspan 2

	grid config $ra_dec -row 0 -column 0 -sticky w
	grid config $ra_hex -row 0 -column 1 -sticky w
   	if {$choice == "ind"} {
		$tabTitlef0 configure -text "Index" 
		$tabTitlef1 configure -text "Properties" 
		grid config $tabInnerf0.l_idx -row 0 -column 0 -sticky w
		grid config $tabInnerf0.en_idx1 -row 0 -column 1 -sticky w -padx 0
		grid config $tabInnerf0.l_nam -row 2 -column 0 -sticky w 
		grid config $tabInnerf0.en_nam1 -row 2 -column 1  -sticky w -columnspan 1
	} elseif {$choice == "sub"} {
		$tabTitlef0 configure -text "Sub Index" 
		$tabTitlef1 configure -text "Properties" 

		label $tabInnerf0.l_sidx -text "Sub Index  "  
		entry $tabInnerf0.en_sidx1 -state disabled

		grid config $tabInnerf0.l_sidx -row 2 -column 0 -sticky w 
		grid config $tabInnerf0.en_sidx1 -row 2 -column 1 -padx 5
		grid config $tabInnerf0.l_nam -row 2 -column 2 -sticky w 
		grid config $tabInnerf0.en_nam1 -row 2 -column 3  -sticky e -columnspan 1
   	}

   	set fram [frame $frame.f1]  
   	label $fram.l_empty -text "  " -height 1 
   	button $fram.b_sav -text " Save " -command "SaveValue $tabInnerf0 $tabInnerf1"
   	label $fram.l_empty1 -text "  "
   	button $fram.b_dis -text "Discard" -command "DiscardValue $tabInnerf0 $tabInnerf1"
   	grid config $fram.l_empty -row 0 -column 0 -columnspan 2
   	grid config $fram.b_sav -row 1 -column 0 -sticky s
   	grid config $fram.l_empty1 -row 1 -column 1 -sticky s
   	grid config $fram.b_dis -row 1 -column 2 -sticky s
   	pack $fram -side bottom

    	#$nb itemconfigure $pageName -state disabled
    	return [list $uf $outerFrame $tabInnerf0 $tabInnerf1 ]
}

###############################################################################################
#proc EditManager::create_table
#Input       : notebook path, title, choice
#Output      : tablelist
#Description : Creates the GUI for TPDO and RPDO
###############################################################################################
proc EditManager::create_table {nb filename choice} {
    	global EditorData

    	variable _newPageCounter
    
    	incr _newPageCounter
    	set pageName "page$_newPageCounter"
    	#set frame [$nb insert end $pageName -text $filename ]

	set outerFrame [frame $nb.$pageName -relief raised -borderwidth 1 ] ; #newly added
	set frame [frame $outerFrame.frame -relief flat -borderwidth 10  ] ; #newly added
	pack $frame -expand yes -fill both ; #newly added

    	set sw [ScrolledWindow $frame.sw ]
    	pack $sw -fill both -expand true
    	set st $frame.st

    	catch "font delete custom1"
    	font create custom1 -size 9 -family TkDefaultFont

    	if {$choice == "ind"} {
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
    	} elseif {$choice == "pdo"} {


	#tablelist::addBWidgetEntry

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
	    			-showseparators 1 -spacing 10 -font custom1 \
				-editstartcommand StartEdit -editendcommand EndEdit ]


		$st columnconfigure 0 -editable no 
		$st columnconfigure 1 -editable yes -editwindow entry	
		$st columnconfigure 2 -editable yes -editwindow entry
		$st columnconfigure 3 -editable yes -editwindow entry	
		$st columnconfigure 4 -editable yes -editwindow entry
		$st columnconfigure 5 -editable yes -editwindow entry
		$st columnconfigure 6 -editable yes -editwindow entry
   	}

	

    	$sw setwidget $st
    	pack $st -fill both -expand true
    	#$nb itemconfigure $pageName -state disabled
    	$st configure -height 4 -width 40 -stretch all	

   	set fram [frame $frame.f1]  
   	label $fram.l_empty -text "  " -height 1 
   	button $fram.b_sav -text " Save " -command "SaveTable $st"
   	label $fram.l_empty1 -text "  "
   	button $fram.b_dis -text "Discard" -command "DiscardTable $st"
   	grid config $fram.l_empty -row 0 -column 0 -columnspan 2
   	grid config $fram.b_sav -row 1 -column 0 -sticky s
   	grid config $fram.l_empty1 -row 1 -column 1 -sticky s
   	grid config $fram.b_dis -row 1 -column 2 -sticky s
   	pack $fram -side top

    	#$nb itemconfigure $pageName -state disabled

    	return  [list $outerFrame $st]
}

###############################################################################################
#proc EditManager::create_conWindow
#Input       : notebook path, title, choice
#Output      : frame
#Description : Creates the console for displaying messages
###############################################################################################
proc EditManager::create_conWindow {nb text choice} {
    	global conWindow
    	global warWindow
    	global errWindow
    	variable _newConsoleCounter
    
    	incr _newConsoleCounter

    	set pagename Console$_newConsoleCounter
    	set frame [$nb insert end $pagename -text $text]
    
    	set sw [ScrolledWindow::create $frame.sw -auto both]
    	if {$choice == 1} {
		set conWindow [consoleInit $sw]
		set window $conWindow
		$nb itemconfigure $pagename -image [Bitmap::get file]
    	} elseif {$choice == 2} {    
		set errWindow [errorInit $sw]
		set window $errWindow
		$nb itemconfigure $pagename -image [Bitmap::get error_small]
    	} elseif {$choice == 3} {    
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
    	return $frame
}

###############################################################################################
#proc EditManager::create_treeWindow
#Input       : notebook path
#Output      : frame
#Description : Creates tree window for the object tree
###############################################################################################
proc EditManager::create_treeWindow {nb } {
    	global RootDir
	global treeFrame
	global updatetree

	set pagename objtree
    	set frame [$nb insert end $pagename -text "Tree Browser"]
   
   	set sw [ScrolledWindow::create $frame.sw -auto both]
    	#set sf [ScrollableFrame $sw.sf]      ;#newly added
    	#$sw setwidget $sf		     ;#newly added
    	#set uf [$sf getframe]		     ;#newly added
	#$uf configure -bg white
   	#set objTree [Tree $uf.objTree \
        #    	-width 15\
        #    	-highlightthickness 0\
        #    	-bg white  \
        #    	-deltay 15 \
	#    	-padx 15 \
	#    	-dropenabled 0 -dragenabled 0 \
	#	-relief flat
    	#]
	#$sw setwidget $objTree
   	set objTree [Tree $frame.sw.objTree \
            	-width 15\
            	-highlightthickness 0\
            	-bg white  \
           	-deltay 15 \
	   	-padx 15 \
	    	-dropenabled 0 -dragenabled 0 -relief ridge 
    	]
	$sw setwidget $objTree
	set updatetree $objTree
	
    	pack $sw -side top -fill both -expand yes -pady 1
	#pack $updatetree -fill both -expand yes	;#newly added
    	set treeFrame [frame $frame.f1]  
    	entry $treeFrame.en_find -textvariable FindSpace::txtFindDym -width 10 -background white -validate key -vcmd "FindSpace::Find %P"
    	button $treeFrame.b_next -text " Next " -command "FindSpace::Next" -image [Bitmap::get right] -relief flat
    	button $treeFrame.b_prev -text " Prev " -command "FindSpace::Prev" -image [Bitmap::get left] -relief flat
   	grid config $treeFrame.en_find -row 0 -column 0 -sticky ew
    	grid config $treeFrame.b_prev -row 0 -column 1 -sticky s -padx 5
    	grid config $treeFrame.b_next -row 0 -column 2 -sticky s
    	return $frame
}

###############################################################################################
#proc ConvertDec
#Input       : Entrybox path
#Output      : -
#Description : Converts to decimal value and changes validation for entry
###############################################################################################
proc ConvertDec {tmpValue} {
	#set selVar [$tmpValue.frame1.ra_dec cget -variable]
	#global $selVar
	#set selVar [subst $[subst $selVar]]
	#puts "selVar->$selVar"
	
	#puts "ConvertDec"
	set tmpVar [$tmpValue.en_value1 cget -textvariable]
	global $tmpVar
	set tmpVal [subst $[subst $tmpVar]]
	#puts "b4 trim ConvertDec->[subst $[subst $tmpVar]]--------tmpVal->$tmpVal"
	if {[string match -nocase "0x*" $tmpVal ] == 1 } {
		set tmpVal [string range $tmpVal 2 end]
		#puts "b4 trim 0x remov ConvertDec->$tmpVal"
		set tmpVal [string trimleft $tmpVal 0]
		#puts "ConvertDec->$tmpVal"
		$tmpValue.en_value1 configure -validate none
		$tmpValue.en_value1 delete 0 end
		catch {set tmpVal [expr 0x$tmpVal]}
		$tmpValue.en_value1 insert 0 $tmpVal
		#set $tmpVar " "
		#puts  "fina1 ConvertDec->$tmpVal"
		$tmpValue.en_value1 configure -validate key -vcmd "IsDec %P $tmpValue.en_value1"
	} else {
		#puts "ConvertDec already selected"
		#already dec is selected
	}
	
}

###############################################################################################
#proc ConvertHex
#Input       : Entrybox path
#Output      : -
#Description : Converts to Hexadecimal value and changes validation for entry
###############################################################################################
proc ConvertHex {tmpValue} {
	#set selVar [$tmpValue.frame1.ra_dec cget -variable]
	#global $selVar
	#set selVar [subst $[subst $selVar]]
	##puts "selVar->$selVar...."
	#puts "ConvertHex"

	set tmpVar [$tmpValue.en_value1 cget -textvariable]
	global $tmpVar	
	set tmpVal [subst $[subst $tmpVar]]
	#puts "b4 trim ConvertHex->[subst $[subst $tmpVar]]--------tmpVal->$tmpVal"
	if {[string match -nocase "0x*" $tmpVal ] == 0 } {
		
		set tmpVal [string trimleft $tmpVal 0]
		#puts "ConvertHex->$tmpVal"
		$tmpValue.en_value1 configure -validate none
		$tmpValue.en_value1 delete 0 end
		catch {set tmpVal [format %X $tmpVal]}
		set tmpVal 0x$tmpVal
		$tmpValue.en_value1 insert 0 $tmpVal
		#puts  "final ConvertHex->$tmpVal"
		$tmpValue.en_value1 configure -validate key -vcmd "IsHex %P $tmpValue.en_value1"
	} else {
		#puts "ConvertHex already selected"
		#already hex is selected
	}
}

###############################################################################################
#proc SaveValue
#Input       : -
#Output      : -
#Description : Saves the user given data
###############################################################################################
proc SaveValue {frame0 frame1} {
	global nodeSelect
	#global nodeObj
	global nodeIdList
	global updatetree
	global savedValueList ; #this list contains Nodes whose value are changed using save option

	#puts "\n\n   SaveValue \n"

	set oldName [$updatetree itemcget $nodeSelect -text]
	if {[string match "*SubIndexValue*" $nodeSelect]} {
		set subIndexId [string range $oldName end-2 end-1]
		set subIndexId [string toupper $subIndexId]
		set parent [$updatetree parent $nodeSelect]
		set indexId [string range [$updatetree itemcget $parent -text ] end-4 end-1]
		set indexId [string toupper $indexId]
		set oldName [string range $oldName end-3 end ]
	} else {
		set indexId [string range $oldName end-4 end-1 ]
		set indexId [string toupper $indexId]
		set oldName [string range $oldName end-5 end ]
	}

	#gets the nodeId and Type of selected node
	set result [GetNodeIdType $nodeSelect]
	if {$result != "" } {
		set nodeId [lindex $result 0]
		set nodeType [lindex $result 1]
	} else {
		#must be some other node this condition should never reach
		#puts "\n\nSaveValue->SHOULD NEVER HAPPEN 1!!\n\n"
		return
	}


	set tmpVar0 [$frame0.en_nam1 cget -textvariable]
	global $tmpVar0	
	set newName [subst $[subst $tmpVar0]]
	#puts "newName->[subst $[subst $tmpVar0]]"

	set tmpVar1 [$frame1.en_value1 cget -textvariable]
	global $tmpVar1	
	set value [string toupper [subst $[subst $tmpVar1]] ]
	#puts "value->$value"
	#puts "value->[subst $[subst $tmpVar1]]"

	set radioSel [$frame1.frame1.ra_dec cget -variable]
	global $radioSel
	#puts "radioSel->$radioSel"
	set radioSel [subst $[subst $radioSel]]
	#puts "radioSel after sub ->$radioSel"

	if {$value != ""} {
		if {$radioSel == "hex"} {
			##it is hex value trim leading 0x
			#set value [string range $value 2 end]
			#do nothing values will be passed correctly
		} elseif {$radioSel == "dec"} {  
			#is is dec value convert to hex
			set value [string trimleft $value 0]
#puts "value after trim for dec :$value"
			if {$value != ""} {
				set value [format %X $value]
				#0x is appended to represent it as hex
				set value 0x$value
#puts "value after conv for dec :$value"
			} else {
				#the value must be zero
				set value 0x0
			}
		} else {
			#puts "\n\n\nSaveValue->Should Never Happen 1!!!\n\n\n"
		}
	} else {
		#no value has been inputed by user
	}

	set value [string toupper $value]
	if {[string match "*SubIndexValue*" $nodeSelect]} {
		#DllExport ocfmRetCode SetSubIndexAttributes(int NodeID, ENodeType NodeType, char* IndexID, char* SubIndexID, char* IndexValue, char* IndexName);
		#puts "SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $newName"
		set catchErrCode [SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $newName]
		#puts "catchErrCode->$catchErrCode"
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		#puts "ErrCode:$ErrCode"
		if { $ErrCode != 0 } {
			#tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
			return
		}
	} elseif {[string match "*IndexValue*" $nodeSelect]} {
		#DllExport ocfmRetCode SetIndexAttributes(int NodeID, ENodeType NodeType, char* IndexID, char* IndexValue, char* IndexName);
		#puts "SetIndexAttributes $nodeId $nodeType $indexId $value $newName"
		set catchErrCode [SetIndexAttributes $nodeId $nodeType $indexId $value $newName]
		#puts "catchErrCode->$catchErrCode"
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		#puts "ErrCode:$ErrCode"
		if { $ErrCode != 0 } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
			#tk_messageBox -message "ErrCode : $ErrCode" -title Warning -icon warning
			return
		}
	} else {
		#puts "\n\n\nSaveValue->Should Never Happen 2!!!\n\n\n"
	}
	set newName [append newName $oldName]
	#puts "newName->$newName"
	$updatetree itemconfigure $nodeSelect -text $newName
	lappend savedValueList $nodeSelect
	$frame0.en_nam1 configure -bg #fdfdd4
	$frame1.en_value1 configure -bg #fdfdd4
	#$frame1.en_value1 configure -validate none 
	#$frame1.en_value1 delete 0 end
	#$frame1.en_value1 insert 0 $value
	#$frame1.en_value1 configure -validate key	


	#$frame1.frame1.ra_hex select
	#always hex value is passed so it should be selected
	#puts "savedValueList->$savedValueList"
}

###############################################################################################
#proc DiscardValue
#Input       : -
#Output      : -
#Description : discards the user given data and restores old data
###############################################################################################
proc DiscardValue {frame0 frame1} {
	global nodeSelect
	#global nodeObj
	global nodeIdList
	global updatetree

	#puts "\n\n  DiscardValue \n"

	#set tmpSplit [split $nodeSelect -]
	#set tmpNodeSelect [lrange $tmpSplit 1 end]
	#set tmpNodeSelect [join $tmpNodeSelect -]
	set oldName [$updatetree itemcget $nodeSelect -text]
	if {[string match "*SubIndexValue*" $nodeSelect]} {
		#set sIdxValue [CBaseIndex_getIndexValue $nodeObj($tmpNodeSelect)]
		set subIndexId [string range $oldName end-2 end-1]
		set parent [$updatetree parent $nodeSelect]
		set indexId [string range [$updatetree itemcget $parent -text] end-4 end-1]
		set parent [$updatetree parent $parent]

	} else {
		set indexId [string range $oldName end-4 end-1 ]
		set parent [$updatetree parent $nodeSelect]
	}


	
	#gets the nodeId and Type of selected node
	set result [GetNodeIdType $nodeSelect]
	if {$result != "" } {
		set nodeId [lindex $result 0]
		set nodeType [lindex $result 1]
	} else {
		#must be some other node this condition should never reach
		#puts "\n\DiscardValue->SHOULD NEVER HAPPEN 1!!\n\n"
		return
	}
	#set nodeList [GetNodeList]
	#set schCnt [lsearch -exact $nodeList $parent ]
	##puts  "schCnt->$schCnt=======nodeList->$nodeList"
	#set nodeId [lindex $nodeIdList $schCnt]
	#if {[string match "OBD*" $parent]} {
	#	#it must be a mn
	#	set nodeType 0
	#} else {
	#	#it must be cn
	#	set nodeType 1
	#}


	if {[string match "*SubIndexValue*" $nodeSelect]} {
		#puts "GetSubIndexAttributes nodeId->$nodeId nodeType->$nodeType indexId->$indexId subIndexId->$subIndexId 0"
		set tempIndexProp [GetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId 0]
		set IndexName [lindex $tempIndexProp 1]
		set tempIndexProp [GetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId 5]
		set IndexActualValue [lindex $tempIndexProp 1]		
		#set IndexActualValue []
	} else {
		#puts "GetIndexAttributes nodeId->$nodeId nodeType->$nodeType indexId->$indexId 0"
		set tempIndexProp [GetIndexAttributes $nodeId $nodeType $indexId 0]
		set IndexName [lindex $tempIndexProp 1]
		set tempIndexProp [GetIndexAttributes $nodeId $nodeType $indexId 5]
		set IndexActualValue [lindex $tempIndexProp 1]	
		#set IndexActualValue []
	}

	$frame0.en_nam1 delete 0 end
	$frame0.en_nam1 insert 0 $IndexName

	$frame1.en_value1 configure -validate none 
	$frame1.en_value1 delete 0 end
	$frame1.en_value1 insert 0 $IndexActualValue
	$frame1.en_value1 configure -validate key
	#puts "IndexName->$IndexName"
	#puts "IndexActualValue->$IndexActualValue"
	#after inserting value select appropriate radio button
	if {[string match -nocase "0x*" $IndexActualValue]} {
		$frame1.frame1.ra_hex select 
	} else {
		$frame1.frame1.ra_dec select	
	}

}

proc StartEdit {tbl row col text} {
	#puts "tbl->$tbl==row->$row===col->$col"
	set w [$tbl editwinpath]
  	switch $col {
		1 {
            		$w configure -invalidcommand bell -validate key  -validatecommand "IsTableHex %P 16 $tbl $row $col"
        	}

        	2 {
			$w configure -invalidcommand bell -validate key  -validatecommand "IsTableHex %P 4 $tbl $row $col"
        	}

	        3 {
			$w configure -invalidcommand bell -validate key  -validatecommand "IsTableHex %P 2 $tbl $row $col"
        	}
        	4 {
			$w configure -invalidcommand bell -validate key  -validatecommand "IsTableHex %P 2 $tbl $row $col"
        	}
        	5 {
            		$w configure -invalidcommand bell -validate key  -validatecommand "IsTableHex %P 4 $tbl $row $col"
        	}
       	 	6 {
            		$w configure -invalidcommand bell -validate key  -validatecommand "IsTableHex %P 4 $tbl $row $col"
        	}
    	}

	return $text
}

proc EndEdit {tbl row col text} {
  	switch $col {
		1 {
			if {[string length $text] != 16} {
				bell
				$tbl rejectinput
				#return ""
			} else {
			}
        	}

        	2 {
			if {[string length $text] != 4} {
				bell
				$tbl rejectinput
				#return ""
			} else {
			}
        	}

	        3 {
			if {[string length $text] != 2} {
				bell
				$tbl rejectinput
				#return ""
			} else {
			}
        	}
        	4 {
			if {[string length $text] != 2} {
				bell
				$tbl rejectinput
				#return ""
			} else {
			}
        	}
        	5 {
			if {[string length $text] != 4} {
				bell
				$tbl rejectinput
				#return ""
			} else {
			}
        	}
       	 	6 {
 			if {[string length $text] != 4} {
				bell
				$tbl rejectinput
				#return ""
			} else {
			}
        	}
    	}
	 return $text
}

proc SaveTable {tableWid} {
	global nodeSelect
	global updatetree

	#puts "nodeSelect->$nodeSelect"
	set result [$tableWid finishediting]
	if {$result == 0} {
		# value entered doesnt pass the -editendcommand of tablelist widget do not save value
		return 
	} else {
		#continue doing
	}
	#puts "\n\n\tSaveTable->tablelist is having valid value entered\n\n"
	# should save entered values to corresponding subindex
	set result [GetNodeIdType $nodeSelect]
	set nodeId [lindex $result 0]
	set nodeType [lindex $result 1]
	set rowCount 0
	foreach childIndex [$updatetree nodes $nodeSelect] {
	 	set indexId [string range [$updatetree itemcget $childIndex -text] end-4 end-1]
		foreach childSubIndex [$updatetree nodes $childIndex] {
			set subIndexId [string range [$updatetree itemcget $childSubIndex -text] end-2 end-1]
			if {[string match "00" $subIndexId]} {
			} else {
				set name [string range [$updatetree itemcget $childSubIndex -text] 0 end-4]
				set value [$tableWid cellcget $rowCount,1 -text]
				#puts "tableWid cellcget $rowCount,1 -text ====>$value"
				#0x is appended when saving value to indicate it is a hexa decimal number
				#puts "SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId 0x$value $name"
				SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId 0x$value $name
				incr rowCount
			}
		}
	}
#	set size [$tableWid size] ; # SIZE GIVES NO OF ROWS
#	#puts size->$size
#	#puts "total_row->[expr $size/[$tableWid columncount] ]"
}

proc DiscardTable {tableWid} {
	global nodeSelect

	Editor::SingleClickNode $nodeSelect
	#$tableWid finishediting
}
