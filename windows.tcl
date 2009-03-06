###############################################################################################
#
#
# NAME:     windows.tcl
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
#  Description:  Contains the child window displayed in application
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
#proc StartUp
#Input       : -
#Output      : -
#Description : Creates the GUI during startup
###############################################################################################
proc StartUp {} {
	global startVar
	global frame2
	set winStartUp .startUp
	catch "destroy $winStartUp"
	catch "font delete custom2"
        font create custom2 -size 9 -family TkDefaultFont
	toplevel     $winStartUp -takefocus 1
	wm title     $winStartUp "openCONFIGURATOR"
	wm resizable $winStartUp 0 0
	wm transient $winStartUp .
	wm deiconify $winStartUp
	grab $winStartUp	

	set frame1 [frame $winStartUp.fram1]
	set frame2 [frame $frame1.fram2]

	label $frame1.l_empty1 -text ""
	label $frame1.l_empty2 -text ""
	label $frame1.l_empty3 -text ""
	label $frame1.l_desc -text "Description"
	
	text $frame1.t_desc -height 5 -width 40 -state disabled -background white

	radiobutton $frame1.ra_default  -text "Open Sample Project"   -variable startVar -value 1 -font custom2 -command "SampleProjectText $frame1.t_desc" 
	radiobutton $frame1.ra_newProj  -text "Create New Project"    -variable startVar -value 2 -font custom2 -command "NewProjectText $frame1.t_desc" 
	radiobutton $frame1.ra_openProj -text "Open Existing Project" -variable startVar -value 3 -font custom2 -command "OpenProjectText $frame1.t_desc" 
	$frame1.ra_default select
	SampleProjectText $frame1.t_desc
	 
	button $frame2.b_ok -text "  Ok  " -command { 
		if {$startVar == 1} {

			set samplePjt [file join [pwd] Sample Sample.oct]
			#puts "open sample->$samplePjt"

			if {[file exists $samplePjt]} {
				destroy .startUp
				_openproject $samplePjt
			} else {
				errorPuts "Sample project is not present" error	
				focus .startUp
				return
			}
		} elseif {$startVar == 2} {
			destroy .startUp
			NewProjectWindow
		} elseif {$startVar == 3} {
			destroy .startUp
			openproject
		}
		unset startVar
		unset frame2
	}
	button $frame2.b_cancel -text "Cancel" -command {
		unset startVar
		unset frame2
		destroy .startUp
		Editor::exit_app
	}

	grid config $frame1 -row 0 -column 0 -padx 35 -pady 10

	grid config $frame1.ra_default -row 0 -column 0 -sticky w -padx 5 -pady 5
	grid config $frame1.ra_newProj -row 1 -column 0 -sticky w  -padx 5 -pady 5
	grid config $frame1.ra_openProj -row 2 -column 0 -sticky w -padx 5 -pady 5
	grid config $frame1.l_desc -row 3 -column 0 -sticky w -padx 5 -pady 5
	grid config $frame1.t_desc -row 4 -column 0 -sticky w -padx 5 -pady 5
	grid config $frame2 -row 5 -column 0  -padx 5 -pady 5
	grid config $frame2.b_ok -row 0 -column 0
	grid config $frame2.b_cancel -row 0 -column 1

	wm protocol .startUp WM_DELETE_WINDOW "$frame2.b_cancel invoke"
	bind $winStartUp <KeyPress-Return> "$frame2.b_ok invoke"
	bind $winStartUp <KeyPress-Escape> "$frame2.b_cancel invoke"

	$winStartUp configure -takefocus 1
	centerW $winStartUp
}

###############################################################################################
#proc SampleProjectText
#Input       : text widget path
#Output      : -
#Description : Displays text when Sample project is selected in start up
###############################################################################################
proc SampleProjectText {t_desc} {
	$t_desc configure -state normal
	$t_desc delete 1.0 end
	$t_desc insert end "Open the sample Project"
	$t_desc configure -state disabled
}

###############################################################################################
#proc NewProjectText
#Input       : text widget path
#Output      : -
#Description : Displays text when New project is selected in start up
###############################################################################################
proc NewProjectText {t_desc} {
	$t_desc configure -state normal
	$t_desc delete 1.0 end
	$t_desc insert end "Create a new Project"
	$t_desc configure -state disabled
}

###############################################################################################
#proc OpenProjectText
#Input       : text widget path
#Output      : -
#Description : Displays text when Open project is selected in start up
###############################################################################################
proc OpenProjectText {t_desc} {
	$t_desc configure -state normal
	$t_desc delete 1.0 end
	$t_desc insert end "Open Existing Project"
	$t_desc configure -state disabled
}

###############################################################################################
#proc ConnectionSettingWindow
#Input       : -
#Output      : -
#Description : Creates the GUI for connection Settings
###############################################################################################
proc ConnectionSettingWindow {} {
	global connectionIpAddr
	global frame2

	set winConnSett .connSett
	catch "destroy $winConnSett"
	toplevel     $winConnSett
	wm title     $winConnSett "Connection Settings"
	wm resizable $winConnSett 0 0
	wm transient $winConnSett .
	wm deiconify $winConnSett
	grab $winConnSett

	set frame1 [frame $winConnSett.fram1]
	set frame2 [frame $winConnSett.fram2]

	label $winConnSett.l_empty1 -text ""
	label $frame1.l_ip -text "IP Address"
	label $winConnSett.l_empty2 -text ""
	label $winConnSett.l_empty3 -text ""

	set connectionIpAddr ""
	entry $frame1.en_ip -textvariable connectionIpAddr -background white -relief ridge -validate all -vcmd "IsIP %P %V"

	button $frame2.b_ok -text "  Ok  " -command { 
		YetToImplement
		$frame2.b_cancel invoke
	}
	button $frame2.b_cancel -text "Cancel" -command {
		unset connectionIpAddr
		unset frame2
		destroy .connSett
	}

	grid config $winConnSett.l_empty1 -row 0 -column 0
	grid config $frame1 -row 1 -column 0 -padx 10
	grid config $winConnSett.l_empty2 -row 2 -column 0
	grid config $frame2 -row 3 -column 0
	grid config $winConnSett.l_empty3 -row 4 -column 0

	grid config $frame1.l_ip -row 0 -column 0
	grid config $frame1.en_ip -row 0 -column 1

	grid config $frame2.b_ok -row 0 -column 0
	grid config $frame2.b_cancel -row 0 -column 1

	wm protocol .connSett WM_DELETE_WINDOW "$frame2.b_cancel invoke"
	bind $winConnSett <KeyPress-Return> "$frame2.b_ok invoke"
	bind $winConnSett <KeyPress-Escape> "$frame2.b_cancel invoke"

	centerW $winConnSett
}

###############################################################################################
#proc InterCNWindow
#Input       : -
#Output      : -
#Description : Creates the GUI for adding PDO to CN
###############################################################################################
proc InterCNWindow {} {
	global updatetree
	global frame2	

	set node [$updatetree selection get]
	set siblingList ""
	set dispList ""
	foreach sibling [$updatetree nodes [$updatetree parent $node]] {
		if {[string match "OBD*" $sibling] || [string match $node $sibling]} {
			# should not add it to the list
		} else {
			lappend siblingList $sibling
			lappend dispList [$updatetree itemcget $sibling -text]
		}

	}
	if {$siblingList == ""} {
		tk_messageBox -message "only one CN present" -icon info
		return
	}
	

	set winInterCN .interCN
	catch "destroy $winInterCN"
	toplevel     $winInterCN
	wm title     $winInterCN "Inter CN Communication"
	wm resizable $winInterCN 0 0
	wm transient $winInterCN .
	wm deiconify $winInterCN
	grab $winInterCN

	set titleFrame1 [TitleFrame $winInterCN.titleFrame1 -text "PDO Configuration" ]
	set titleInnerFrame1 [$titleFrame1 getframe]
	set frame1 [frame $titleInnerFrame1.fram1 -padx 5 -pady 5]
	set frame2 [frame $titleInnerFrame1.fram2]
	set frame3 [frame $titleInnerFrame1.fram3]

	label $winInterCN.l_empty1 -text ""	
	label $winInterCN.l_empty2 -text ""
	label $frame1.l_cn -text "CN 's :  "
	label $frame1.l_noRpdo -text "Number of RPDO :  "
	label $frame1.l_dispRpdo -text ""
	
	ComboBox $frame1.co_cn -values $dispList -modifycmd "dispRpdo $frame1 [list $siblingList] [list $dispList]" -editable no
 	
	button $frame2.bt_ok -text "  Ok  " -command {
		destroy .interCN
		YetToImplement
	}

	button $frame2.bt_cancel -text "Cancel" -command {
		unset frame2
		destroy .interCN
	}

	grid config $winInterCN.l_empty1 -row 0 -column 0 -sticky "news"
	grid config $titleFrame1 -row 1 -column 0 -padx 5 -sticky "news"
	grid config $winInterCN.l_empty2 -row 2 -column 0 -sticky "news"

	#grid config $titleInnerFrame1 -row 0 -column 0 

	grid config $frame1 -row 0 -column 0 
	grid config $frame1.l_cn  -row 0 -column 0 -sticky e 
	grid config $frame1.co_cn -row 0 -column 1 -sticky w
	grid config $frame1.l_noRpdo  -row 1 -column 0 -sticky e
	grid config $frame1.l_dispRpdo -row 1 -column 1 -sticky w

	grid config $frame2 -row 1 -column 0 
	grid config $frame2.bt_ok  -row 0 -column 0 
	grid config $frame2.bt_cancel -row 0 -column 1

	wm protocol .interCN WM_DELETE_WINDOW "$frame2.bt_cancel invoke"
	bind $winInterCN <KeyPress-Return> "$frame2.bt_ok invoke"
	bind $winInterCN <KeyPress-Escape> "$frame2.bt_cancel invoke"

	centerW $winInterCN

}

proc dispRpdo {frame1 siblingList dispList} {
	#puts "frame->$frame1==siblingList->$siblingList==dispList->$dispList"
	#puts [$frame1.co_cn getvalue]

}
###############################################################################################
#proc AddPDOWindow
#Input       : -
#Output      : -
#Description : Creates the GUI for adding PDO to CN
###############################################################################################
#proc AddPDOWindow {} {
#	global pdoStartValue
#	global mapEntValue
#	global noPDOValue
#	global pdoType

#	set winAddPDO .addPDO
#	catch "destroy $winAddPDO"
#	toplevel     $winAddPDO
#	wm title     $winAddPDO "Add PDOs"
#	wm resizable $winAddPDO 0 0
#	wm transient $winAddPDO .
#	wm deiconify $winAddPDO
#	grab $winAddPDO

	
#	set titleFrame1 [TitleFrame $winAddPDO.titleFrame1 -text "PDO Configuration" ]
#	set titleInnerFrame2 [$titleFrame1 getframe]
#	set frame1 [frame $titleInnerFrame2.fram1]
#	set frame2 [frame $titleInnerFrame2.fram2]
#	set frame3 [frame $titleInnerFrame2.fram3]

#	label $winAddPDO.l_empty1 -text ""	
#	label $winAddPDO.l_empty2 -text ""
#	label $frame1.l_pdostart -text "PDO Starting number \[1-255\] :"
#	label $frame1.l_MapEnt -text   "Mapping Entries \[1-254\] :"
#	label $frame1.l_NoPDO -text    "Number of PDOs \[1-255\] :"
#	label $titleInnerFrame2.l_empty5 -text "    "
#	label $titleInnerFrame2.l_type -text "PDO type"
#	label $titleInnerFrame2.l_empty9 -text ""
#	label $winAddPDO.l_empty8 -text ""

#	entry $frame1.en_pdostart -textvariable pdoStartValue -background white -validate key -vcmd "IsInt %P %V"
#	entry $frame1.en_MapEnt -textvariable mapEntValue -background white -validate key -vcmd {expr {[string len %P] <= 3} && {[string is int %P]}}
#	entry $frame1.en_NoPDO -textvariable noPDOValue -background white -validate key -vcmd {expr {[string len %P] <= 3} && {[string is int %P]}}

#	set pdoType off
#	radiobutton $frame2.ra_tran -text "Transmit PDO" -variable pdoType   -value on 
#	radiobutton $frame2.ra_rece   -text "Receive PDO"  -variable pdoType   -value off 
#	$frame2.ra_rece select
#
#	button $frame3.b_ok -text "  Add  " -command { 
#		if {$pdoStartValue < 1 ||$pdoStartValue > 255 } {
#			tk_messageBox -message "PDO Starting number value range is 1 to 255" -parent .addPDO -icon error
#			focus .addPDO
#			return
#		}
#		if {$mapEntValue < 1 ||$mapEntValue > 254 } {
#			tk_messageBox -message "Mapping Entries value range is 1 to 254" -parent .addPDO -icon error
#			focus .addPDO
#			return
#		}
#		if {$noPDOValue < 1 ||$noPDOValue > 255 } {
#			tk_messageBox -message "Number of PDOs value range is 1 to 255" -parent .addPDO -icon error
#			focus .addPDO
#			return
#		}
#		destroy .addPDO
#	}
#	button $frame3.b_cancel -text "Cancel" -command {
#		destroy .addPDO
#	}

#	grid config $winAddPDO.l_empty1 -row 0 -column 0 -sticky "news"
#	grid config $titleFrame1 -row 1 -column 0 -ipadx 20 -padx 20 -sticky "news"
#
#	grid config $frame1 -row 0 -column 0 -sticky "news" -columnspan 1
#	grid config $frame1.l_pdostart  -row 0 -column 0 
#	grid config $frame1.en_pdostart -row 0 -column 1
#	grid config $frame1.l_MapEnt  -row 1 -column 0 
#	grid config $frame1.en_MapEnt -row 1 -column 1
#	grid config $frame1.l_NoPDO  -row 2 -column 0 
#	grid config $frame1.en_NoPDO -row 2 -column 1
#
#	grid config $titleInnerFrame2.l_empty5  -row 3 -column 0
#
#	grid config $titleInnerFrame2.l_type  -row 4 -column 0
#
#	grid config $frame2.ra_tran -row 0 -column 0 -sticky "w"
#	grid config $frame2.ra_rece   -row 0 -column 1 -sticky "w"
#	grid config $frame2 -row 5 -column 0
#
#	grid config $titleInnerFrame2.l_empty9 -row 6 -column 0 -sticky "news"
#
#	grid config $frame3.b_ok  -row 0 -column 0 
#	grid config $frame3.b_cancel -row 0 -column 1
#	grid config $frame3 -row 7 -column 0 
#
#	grid config $winAddPDO.l_empty8 -row 2 -column 0 -sticky "news"
#
#
#	wm protocol .addPDO WM_DELETE_WINDOW "$frame3.b_cancel invoke"
#	bind $winAddPDO <KeyPress-Return> "$frame3.b_ok invoke"
#	bind $winAddPDO <KeyPress-Escape> "$frame3.b_cancel invoke"
#
#	centerW $winAddPDO

#}

###############################################################################################
#proc AddCNWindow
#Input       : -
#Output      : -
#Description : Creates the GUI for adding CN to MN
###############################################################################################
proc AddCNWindow {} {
	global cnName
	global nodeId
	global tmpImpCnDir
	global frame1
	global lastXD

	set winAddCN .addCN
	catch "destroy $winAddCN"
	toplevel     $winAddCN
	wm title     $winAddCN "Add New Node"
	wm resizable $winAddCN 0 0
	wm transient $winAddCN .
	wm deiconify $winAddCN
	grab $winAddCN

	label $winAddCN.l_empty -text ""	

	set titleFrame1 [TitleFrame $winAddCN.titleFrame1 -text "Add CN" ]
	set titleInnerFrame1 [$titleFrame1 getframe]
	set frame1 [frame $titleInnerFrame1.fram1]
	set frame2 [frame $titleInnerFrame1.fram2]
	set titleFrame2 [TitleFrame $titleInnerFrame1.titleFrame2 -text "Select Node" ]
	set titleInnerFrame2 [$titleFrame2 getframe]
	set titleFrame3 [TitleFrame $titleInnerFrame1.titleFrame3 -text "CN Configuration" ]
	set titleInnerFrame3 [$titleFrame3 getframe]

	label $titleInnerFrame1.l_empty1 -text "               "
	label $titleInnerFrame1.l_empty2 -text "               "
	label $frame2.l_name -text "Name :   " -justify left
	label $frame2.l_node -text "Node ID :" -justify left
	label $titleInnerFrame1.l_empty3 -text "               "
	label $titleInnerFrame1.l_empty4 -text "              "
	label $winAddCN.l_empty5 -text " "

	radiobutton $titleInnerFrame2.ra_mn -text "Managing Node" -variable mncn -value on  
	radiobutton $titleInnerFrame2.ra_cn -text "Controlled Node" -variable mncn -value off 
	$titleInnerFrame2.ra_mn select
	radiobutton $titleInnerFrame3.ra_def -text "Default" -variable confCn -value on  -command {
		.addCN.titleFrame1.f.titleFrame3.f.en_imppath config -state disabled 
		.addCN.titleFrame1.f.titleFrame3.f.bt_imppath config -state disabled 
	}		

	
	radiobutton $titleInnerFrame3.ra_imp -text "Import XDC/XDD" -variable confCn -value off -command {
		.addCN.titleFrame1.f.titleFrame3.f.en_imppath config -state normal 
		.addCN.titleFrame1.f.titleFrame3.f.bt_imppath config -state normal 
	}
	$titleInnerFrame3.ra_def select

	set autoGen [GenCNname]

	entry $frame2.en_name -textvariable cnName -background white -relief ridge -validate key -vcmd "IsValidStr %P"
	set cnName [lindex $autoGen 0]	
	$frame2.en_name selection range 0 end
	$frame2.en_name icursor end

	entry $frame2.en_node -textvariable nodeId -background white -relief ridge -validate key -vcmd "IsInt %P %V"
	set nodeId [lindex $autoGen 1]
	entry $titleInnerFrame3.en_imppath -textvariable tmpImpCnDir -background white -relief ridge -width 35
	if {![file isdirectory $lastXD] && [file exists $lastXD] } {	
		set tmpImpCnDir $lastXD	
	} else {
		set tmpImpCnDir ""
	}
	$titleInnerFrame3.en_imppath config -state disabled

	button $titleInnerFrame3.bt_imppath -text Browse -command {
		set types {
		        {{XDC/XDD Files} {.xd*} }
		        {{XDD Files}     {.xdd} }
			{{XDC Files}     {.xdc} }
		}
		if {![file isdirectory $lastXD] && [file exists $lastXD] } {
			set tmpImpCnDir [tk_getOpenFile -title "Import XDC/XDD" -initialfile $lastXD -filetypes $types -parent .addCN]
		} else {
			set tmpImpCnDir [tk_getOpenFile -title "Import XDC/XDD" -filetypes $types -parent .addCN]
		}
		#set tmpImpCnDir [tk_getOpenFile -title "Import XDC/XDD" -filetypes $types -parent .addCN] ; #workingold

	}
 	$titleInnerFrame3.bt_imppath config -state disabled 

	button $frame1.bt_ok -text "  Ok  " -command {
		set cnName [string trim $cnName]
		if {$cnName == "" } {
			tk_messageBox -message "Enter CN Name" -title "Set Node Name error" -parent .addCN -icon error
			focus .addCN
			return
		}
		if {$nodeId == "" } {
			tk_messageBox -message "Enter Node id" -parent .addCN -icon error
			focus .addCN
			return
		}
		if {$nodeId < 1 || $nodeId > 239 } {
			tk_messageBox -message "Node id value range is 1 to 239" -parent .addCN -icon error
			focus .addCN
			return
		}
		
		if {$confCn=="off"} {
			if {![file isfile $tmpImpCnDir]} {
				tk_messageBox -message "Entered path for Import XDC/XDD not exist " -icon error -parent .addCN
				focus .addCN
				return
			}
			set ext [file extension $tmpImpCnDir]
#puts "addcn ext->$ext"
			if { $ext == ".xdc" || $ext == ".xdd" } {
				#continue file is correct type
			} else {
				tk_messageBox -message "Import files only of type XDC/XDD" -icon error -parent .addCN
				focus .addCN
				return
			}
		
			set lastXD $tmpImpCnDir
		
		}

		if {$confCn == "off"} {
			#import the user selected xdc/xdd file for cn
			set chk [AddCN $cnName $tmpImpCnDir $nodeId]
		} else {
			#import the default cn xdd file
			set tmpImpCnDir [file join [pwd] cn.xdd]
			if {[file exists $tmpImpCnDir]} {
				set chk [AddCN $cnName $tmpImpCnDir $nodeId]
			} else {
			#	#there is no default cn.xdd file in required path
				tk_messageBox -message "Default cn.xdd is not found" -icon error -parent .addCN
				focus .addCN
				return
			}
			#set chk [AddCN $cnName "" $nodeId]			
		}
		$frame1.bt_cancel invoke
	}

	button $frame1.bt_cancel -text Cancel -command { 
		unset cnName
		unset nodeId
		unset tmpImpCnDir
		unset frame1
		destroy .addCN
	}





	grid config $winAddCN.l_empty -row 0 -column 0  
	
	grid config $titleFrame1 -row 1 -column 0 -sticky "news" 

	grid config $titleInnerFrame1.l_empty1 -row 0 -column 0  

	grid config $frame2 -row 2 -column 0 
	grid config $frame2.l_name -row 0 -column 0 
	grid config $frame2.en_name -row 0 -column 1 
	grid config $frame2.l_node -row 1 -column 0 
	grid config $frame2.en_node -row 1 -column 1 

	grid config $titleInnerFrame1.l_empty3 -row 3 -column 0  

	grid config $titleFrame3 -row 4 -column 0 -sticky "news"
	grid config $titleInnerFrame3.ra_def -row 0 -column 0 -sticky "w"
	grid config $titleInnerFrame3.ra_imp -row 1 -column 0
	grid config $titleInnerFrame3.en_imppath -row 1 -column 1
	grid config $titleInnerFrame3.bt_imppath -row 1 -column 2
 
	grid config $titleInnerFrame1.l_empty4 -row 5 -column 0  
	
	grid config $frame1 -row 6 -column 0 
	grid config $frame1.bt_ok -row 0 -column 0  
	grid config $frame1.bt_cancel -row 0 -column 1
	
	grid config $winAddCN.l_empty5 -row 7 -column 0  

	wm protocol .addCN WM_DELETE_WINDOW "$frame1.bt_cancel invoke"
	bind $winAddCN <KeyPress-Return> "$frame1.bt_ok invoke"
	bind $winAddCN <KeyPress-Escape> "$frame1.bt_cancel invoke"

	focus $frame2.en_name
	centerW $winAddCN
}

proc GenCNname {} {
	global nodeIdList
	global updatetree
puts "in GenCNname nodeIdList->$nodeIdList"
	for {set inc 1} {$inc < 240} {incr inc} {
		puts "lsearch -exact $nodeIdList $inc->[lsearch -exact $nodeIdList $inc]"
		if {[lsearch -exact $nodeIdList $inc] == -1 } {
			break;
		}
	}

	if {$inc == 240} { 
		#239 cn are created no more cn can be created
		#return $Name$inc
	} else {
		return [list CN_$inc $inc]
	}
}
###############################################################################################
#proc SaveProjectAsWindow
#Input       : -
#Output      : -
#Description : Creates the GUI when Project is to be saved at different location and name
###############################################################################################
proc SaveProjectAsWindow {} {
	global PjtName
	global PjtDir

	if {$PjtDir == "" || $PjtDir == "None" || $PjtName == "" } {
		conPuts "No Project Selected" info
		return
	} else {
		set saveProjectAs [tk_getSaveFile -parent . -title "Save Project As"]
		#set fileLocation_CDC [tk_getSaveFile -filetypes $types -initialdir $PjtDir -initialfile [generateAutoName $PjtDir CDC .cdc ] -title "Transfer CDC"]
		set projectDir [file dirname $saveProjectAs]
		set projectName [file tail $saveProjectAs]

		set catchErrCode [SaveProject $projectDir [string range $projectName 0 end-[string length [file extension $projectName]]]]
		puts "In save project as SaveProject $projectDir [string range $projectName 0 end-[string length [file extension $projectName]]]"

		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		if { $ErrCode != 0 } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
			return 
		}
	}

		#puts "saveProject->$saveProject"
		#global tmpPjtName
		#global tmpPjtDir

		#set winSavProjAs .savProjAs
		#catch "destroy $winSavProjAs"
		#toplevel $winSavProjAs
		#wm title     $winSavProjAs	"Project Wizard"
		#wm resizable $winSavProjAs 0 0
		#wm transient $winSavProjAs .
		#wm deiconify $winSavProjAs
		#wm minsize   $winSavProjAs 50 200
		#grab $winSavProjAs

		#set titleFrame1 [TitleFrame $winSavProjAs.titleFrame1 -text "Save Project as" ]
		#set titleInnerFrame1 [$titleFrame1 getframe]
		#set frame1 [frame $titleInnerFrame1.fram1]

		#label $winSavProjAs.l_empty -text "               "	
		#label $winSavProjAs.l_empty1 -text "               "
		#label $titleInnerFrame1.l_empty2 -text "               "
		#label $titleInnerFrame1.l_pjname -text "Project Name :" -justify left
		#label $titleInnerFrame1.l_pjpath -text "Project Path :" -justify left
		#label $titleInnerFrame1.l_empty3 -text "               "
	#label $winSavProjAs.l_empty4 -text "               "

	#set tmpPjtName ""
	#entry $titleInnerFrame1.en_pjname -textvariable tmpPjtName -background white -relief ridge
	#set tmpPjtDir ""
	#entry $titleInnerFrame1.en_pjpath -textvariable tmpPjtDir -background white -relief ridge -width 35

	#button $titleInnerFrame1.bt_pjpath -text Browse -command {
	#	set tmpPjtDir [tk_chooseDirectory -title "Save Project at" -parent .savProjAs]
	#	if {$tmpPjtDir == ""} {
	#		focus .savProjAs
	#		return
	#	}
	#}
	#button $frame1.bt_ok -text "  Ok  " -command {
	#	set tmpPjtName [string trim $tmpPjtName]
	#	if {$tmpPjtName == "" } {
	#		tk_messageBox -message "Enter Project Name" -title "Set Project Name error" -parent .savProjAs -icon error
	#		focus .savProjAs
	#		return
	#	}
	#	if {![file isdirectory $tmpPjtDir]} {
	#		tk_messageBox -message "Entered path for project is not a Directory" -parent .savProjAs -icon error
	#		focus .savProjAs
	#		return
	#	}
	#	destroy .savProjAs
	#}
	#button $frame1.bt_cancel -text Cancel -command { 
	#	destroy .savProjAs
	#}


	#grid config $winSavProjAs.l_empty -row 0 -column 0 
	
	#grid config $titleFrame1 -row 1 -column 0 -sticky "news" -ipadx 10 -padx 10 -ipady 10
	#grid config $titleInnerFrame1.l_pjname -row 1 -column 0 
	#grid config $titleInnerFrame1.en_pjname -row 1 -column 1 -sticky "w"
	#grid config $titleInnerFrame1.l_pjpath -row 2 -column 0 
	#grid config $titleInnerFrame1.en_pjpath -row 2 -column 1 -sticky "w"
	#grid config $titleInnerFrame1.bt_pjpath -row 2 -column 2 
	
	#grid config $titleInnerFrame1.l_empty3 -row 3 -column 0 
	#grid config $frame1 -row 6 -column 1 
	#grid config $frame1.bt_ok -row 0 -column 0 
	#grid config $frame1.bt_cancel -row 0 -column 1 

	#grid config $winSavProjAs.l_empty4 -row 2 -column 0 

	#wm protocol .savProjAs WM_DELETE_WINDOW "$frame1.bt_cancel invoke"
	#bind $winSavProjAs <KeyPress-Return> "$frame1.bt_ok invoke"
	#bind $winSavProjAs <KeyPress-Escape> "$frame1.bt_cancel invoke"

	#centerW $winSavProjAs
}

###############################################################################################
#proc NewProjectWindow
#Input       : -
#Output      : -
#Description : Creates the GUI when New Project is to be created
###############################################################################################
proc NewProjectWindow {} {
	global tmpPjtName
	global tmpPjtDir
	global tmpImpDir
	global frame1
	global titleInnerFrame1
	global titleInnerFrame2
	global winNewProj

	global updatetree
	global nodeIdList
	global PjtName
	global PjtDir
	global DefaultPjtDir
	global HOME
	global status_save
	global lastXD

puts "DefaultPjtDir->$DefaultPjtDir"

	set winNewProj .newprj
	catch "destroy $winNewProj"
	toplevel $winNewProj
	wm title     $winNewProj	"Project Wizard"
	wm resizable $winNewProj 0 0
	wm transient $winNewProj .
	wm deiconify $winNewProj
	wm minsize   $winNewProj 50 200
	grab $winNewProj

	set titleFrame1 [TitleFrame $winNewProj.titleFrame1 -text "Create New Project" ]
	set titleInnerFrame1 [$titleFrame1 getframe]
	set frame1 [frame $titleInnerFrame1.fram1]
	set titleFrame2 [TitleFrame $titleInnerFrame1.titleFrame2 -text "MN Configuration" ]
	set titleInnerFrame2 [$titleFrame2 getframe]

	label $winNewProj.l_empty -text "               "	
	label $winNewProj.l_empty1 -text "               "
	label $titleInnerFrame1.l_empty2 -text "               "
	label $titleInnerFrame1.l_pjname -text "Project Name :" -justify left
	label $titleInnerFrame1.l_pjpath -text "Project Path   :" -justify left
	label $titleInnerFrame1.l_empty3 -text "               "
	label $titleInnerFrame1.l_empty4 -text "               "

	entry $titleInnerFrame1.en_pjname -textvariable tmpPjtName -background white -relief ridge -validate key -vcmd "IsValidStr %P"
	#for {set inc 1} {1} {incr inc} {
	#	if {![file exists [file join $DefaultPjtDir Project$inc]]} {
	#		break;
	#	}
	#}
	#set tmpPjtName Project$inc
	set tmpPjtName  [generateAutoName $DefaultPjtDir Project ""]
#puts "tmpPjtName->$tmpPjtName....."
	$titleInnerFrame1.en_pjname selection range 0 end
	$titleInnerFrame1.en_pjname icursor end

	entry $titleInnerFrame1.en_pjpath -textvariable tmpPjtDir -background white -relief ridge -width 35
	set tmpPjtDir $DefaultPjtDir

	entry $titleInnerFrame2.en_imppath -textvariable tmpImpDir -background white -relief ridge -width 35
	if {![file isdirectory $lastXD] && [file exists $lastXD] } {	
		set tmpImpDir $lastXD	
	} else {
		set tmpImpDir ""
	}

	$titleInnerFrame2.en_imppath config -state disabled 

	radiobutton $titleInnerFrame2.ra_def -text "Default" -variable conf -value on -command {
		.newprj.titleFrame1.f.titleFrame2.f.en_imppath config -state disabled 
		.newprj.titleFrame1.f.titleFrame2.f.bt_imppath config -state disabled 
		#wm minsize   $winNewProj 50 200
		#grid remove $titleInnerFrame2.en_imppath
		#grid remove $titleInnerFrame2.bt_imppath
	}
	radiobutton $titleInnerFrame2.ra_imp -text "Import XDC/XDD" -variable conf -value off -command {
		.newprj.titleFrame1.f.titleFrame2.f.en_imppath config -state normal 
		.newprj.titleFrame1.f.titleFrame2.f.bt_imppath config -state normal 
		#wm minsize   $winNewProj 550 200
		#grid config $titleInnerFrame2.en_imppath -row 1 -column 1
		#grid config $titleInnerFrame2.bt_imppath -row 1 -column 2

	} 
	$titleInnerFrame2.ra_def select

	button $titleInnerFrame1.bt_pjpath -text Browse -command {
		set tmpPjtDir [tk_chooseDirectory -title "Project Location" -initialdir $DefaultPjtDir -parent .newprj]
		if {$tmpPjtDir == ""} {
			focus .newprj
			return
		}
	}
	button $titleInnerFrame2.bt_imppath -text Browse -command {
#set typeList [list *.xdc *.xdd]
		set types {
		        {{XDC/XDD Files} {.xd*} }
		        {{XDD Files}     {.xdd} }
			{{XDC Files}     {.xdc} }
		}
		if {![file isdirectory $lastXD] && [file exists $lastXD] } {
			set tmpImpDir [tk_getOpenFile -title "Import XDC/XDD" -initialfile $lastXD -filetypes $types -parent .newprj]
		} else {
			set tmpImpDir [tk_getOpenFile -title "Import XDC/XDD" -filetypes $types -parent .newprj]
		}
		#set tmpImpDir [tk_getOpenFile -title "Import XDC/XDD" -filetypes $types -parent .newprj];#workingold
		if {$tmpImpDir == ""} {
			focus .newprj
			return
		}
       }
	$titleInnerFrame2.bt_imppath config -state disabled 
	button $frame1.bt_ok -text "  Ok  " -command {
		set tmpPjtName [string trim $tmpPjtName]
		if {$tmpPjtName == "" } {
			tk_messageBox -message "Enter Project Name" -title "Set Project Name error" -icon warning
			focus .newprj
			return
		}
		if {![file isdirectory $tmpPjtDir]} {
			tk_messageBox -message "Entered path for Project is not a directory" -icon warning -parent .newprj
			focus .newprj
			return
		}
		if {![file writable $tmpPjtDir]} {
			tk_messageBox -message "Entered path for Project is write protected" -icon info -parent .newprj
			focus .newprj
			return
		}
		if {[file exists [file join $tmpPjtDir $tmpPjtName]]} {
			set result [tk_messageBox -message "Folder $tmpPjtName already exists.\nDo you want to overwrite it?" -type yesno -icon question -parent .newprj]
   			 switch -- $result {
   			 	yes {
			 		#continue with process
					#TODO does the existing project need to be deleted
			 	}			 
   		     		no  {
					focus $titleInnerFrame1.en_pjname
			   		return
			 	}
   			 }
		}
		if {$conf=="off" } {
			if {![file isfile $tmpImpDir]} {
				tk_messageBox -message "Entered path for Import XDC/XDD not exist " -icon warning -parent .newprj
				focus .newprj
				return
			}
			set ext [file extension $tmpImpDir]
#puts "newproj ext->$ext"
			if { $ext == ".xdc" || $ext == ".xdd" } {
				#correct type continue
			} else {
				tk_messageBox -message "Import files only of type XDC/XDD" -icon warning -parent .newprj
				focus .newprj
				return
			}
			set lastXD $tmpImpDir
		} else {
			set tmpImpDir [file join [pwd] mn.xdd]
			if {![file isfile $tmpImpDir]} {
				##TODO: discuss what to do
				tk_messageBox -message "Default cn.xdd is not found" -icon warning -parent .newprj
				focus .newprj
				return
			}
		}


		#CloseProject is called to delete node and insert tree
		CloseProject

		set PjtName $tmpPjtName
		set pjtName [string range $PjtName 0 end-[string length [file extension $PjtName]] ] 
		set PjtDir [file join $tmpPjtDir  $pjtName]

		catch {$Editor::projMenu delete 3} ; # to delete the close project if already present 
		$Editor::projMenu add command -label "Close Project" -command "_CloseProject" 
		catch {$Editor::projMenu delete 4} ; # to delete the Properties if already present
		$Editor::projMenu add command -label "Properties" -command "PropertiesWindow" ; #not implemnted in this delivery so commented out


		$updatetree itemconfigure PjtName -text $tmpPjtName

		set catchErrCode [NodeCreate 240 0 openPOWERLINK_MN]
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		#puts "ErrCode:$ErrCode"
		if { $ErrCode != 0 } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Info -parent .newprj -icon info
			$frame1.bt_cancel invoke
		}


		#New project is created need to save
		set status_save 1

		$updatetree insert end PjtName MN-$mnCount -text "openPOWERLINK_MN(240)" -open 1 -image [Bitmap::get mn]
		lappend nodeIdList 240 ; #removed obj and obj node
puts "nodeIdList->$nodeIdList"

		#if later if dont want to import anything for default option change the if condition
		if {$conf == "off" || $conf == "on" } {
thread::send [tsv::get application importProgress] "StartProgress" ; #
#puts "before calling thread"
#after 1
#puts "after calling thread"
#thread::join [tsv::get application importProgress]
#vwait tsv::get application flag
#tsv::set application flag 0
#puts "waiting for variable to be set"

			#DllExport ocfmRetCode ImportXML(char* fileName, int NodeID, ENodeType NodeType);
			set catchErrCode [ImportXML "$tmpImpDir" 240 0]
			#puts "catchErrCode for import in new project->$catchErrCode"
			set ErrCode [ocfmRetCode_code_get $catchErrCode]
			#puts "ErrCode:$ErrCode"
			if { $ErrCode != 0 } {
				tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning	
				$frame1.bt_cancel invoke
			}
		$updatetree insert end MN-$mnCount OBD-$mnCount-1 -text "OBD" -open 0 -image [Bitmap::get pdo]
		#Import parentNode nodeType nodeID 
		Import OBD-$mnCount-1 0 240
thread::send -async [tsv::set application importProgress] "StopProgress"


#folder for project is created only when there is no error
#puts "file mkdir $PjtDir"

			file mkdir [file join $PjtDir ]
			file mkdir [file join $PjtDir CDC_XAP]
			file mkdir [file join $PjtDir XDC]
		} else {
#puts "file mkdir $PjtDir"	
			#file mkdir [file join $PjtDir $PjtName]
			#file mkdir [file join $PjtDir $PjtName CDC_XAP]
			#file mkdir [file join $PjtDir $PjtName XDC]
		}

		$frame1.bt_cancel invoke
	}
	button $frame1.bt_cancel -text Cancel -command { 
		unset tmpPjtName
		unset tmpPjtDir
		unset tmpImpDir
		unset frame1
		unset titleInnerFrame1
		unset titleInnerFrame2
		unset winNewProj
		destroy .newprj
		return
	}

	grid config $winNewProj.l_empty -row 0 -column 0 
	
	grid config $titleFrame1 -row 1 -column 0 -sticky "news" -ipadx 10 -padx 10 -ipady 10

	grid config $titleInnerFrame1.l_pjname -row 1 -column 0 -sticky "w"
	grid config $titleInnerFrame1.en_pjname -row 1 -column 1 -sticky "w"
	grid config $titleInnerFrame1.l_pjpath -row 2 -column 0 -sticky "w"
	grid config $titleInnerFrame1.en_pjpath -row 2 -column 1 -sticky "w"
	grid config $titleInnerFrame1.bt_pjpath -row 2 -column 2 
	
	grid config $titleInnerFrame1.l_empty3 -row 3 -column 0 

	grid config $titleFrame2 -row 4 -column 0 -columnspan 3 -sticky "news"
	grid config $titleInnerFrame2.ra_def -row 0 -column 0 -sticky "w"
	grid config $titleInnerFrame2.ra_imp -row 1 -column 0
	grid config $titleInnerFrame2.en_imppath -row 1 -column 1
	grid config $titleInnerFrame2.bt_imppath -row 1 -column 2 

	grid config $titleInnerFrame1.l_empty4 -row 5 -column 0 
	
	grid config $frame1 -row 6 -column 1 
	grid config $frame1.bt_ok -row 0 -column 0 
	grid config $frame1.bt_cancel -row 0 -column 1 
	
	grid config $winNewProj.l_empty1 -row 7 -column 0 
	wm protocol .newprj WM_DELETE_WINDOW "$frame1.bt_cancel invoke"
	bind $winNewProj <KeyPress-Return> "$frame1.bt_ok invoke"
	bind $winNewProj <KeyPress-Escape> "$frame1.bt_cancel invoke"

	focus $titleInnerFrame1.en_pjname
	centerW $winNewProj
}

###############################################################################################
#proc SaveProjectWindow
#Input       : -
#Output      : -
#Description : Creates the GUI when existing Project is to be closed
###############################################################################################
proc SaveProjectWindow {} {
	global PjtDir
	global PjtName
	global updatetree
	global status_save	

	if {$PjtDir == "" || $PjtDir == "None" || $PjtName == "" } {
		conPuts "No Project Selected" info
		return
	} else {	
		#check whether project has changed from last saved
		if {$status_save} {
			set result [tk_messageBox -message "Save Project $PjtName ?" -type yesno -icon question -title "Question"]
			switch -- $result {
				yes {			 
					Saveproject
					conPuts "Project $PjtName is saved" info
					return yes
				}
				no {
					conPuts "Project $PjtName not saved" info
					return no
				}
			}
		}		
	}
}

###############################################################################################
#proc CloseProjectWindow
#Input       : -
#Output      : -
#Description : Creates the GUI when existing Project is to be closed
###############################################################################################
proc CloseProjectWindow {} {
	global PjtDir
	global PjtName
	global updatetree
	global status_save	

	if {$PjtDir == "" || $PjtDir == "None" || $PjtName == "" } {
		conPuts "No Project Selected" info
		CloseProject
		return
	} else {	
		#TODO only for testing remove for delivery
		set result [tk_messageBox -message "Close Project $PjtName ?" -type okcancel -icon question -title "Question"]
   		 switch -- $result {
			ok {
				CloseProject
				return ok
			}
			cancel {
				return cancel 
			}
		}
	}		
}


################################################################################################
#proc ImportProgress
#Input       : choice
#Output      : progressbar path
#Description : Creates the GUI displaying progress when XDC/XDD is imported
#	       This function is called by thread 
################################################################################################
proc ImportProgress {stat} {
	#global LocvarProgbar
	#global prog

	if {$stat == "start"} {


	#package require Tk 8.5
	#puts "In thread tkpath->$tkpath"
	#set RootDir [pwd]
	#set path_to_BWidget [file join $RootDir BWidget-1.2.1]
	#lappend auto_path $path_to_BWidget
	#package require -exact BWidget 1.2.1

	#wm withdraw .
	#wm title . "progress"
	#BWidget::place . 0 0 
			wm deiconify .
			raise .
			focus .




		#set winImpoProg .impoProg
		#catch "destroy $winImpoProg"
		set winImpoProg .
		#toplevel $winImpoProg
		wm title     $winImpoProg	"Project Wizard"
		wm resizable $winImpoProg 0 0
		#wm transient $winImpoProg .
		wm deiconify $winImpoProg
		grab $winImpoProg
		set LocvarProgbar 0
		#set prog [ProgressBar $winImpoProg.prog -orient horizontal -width 200 -maximum 100 -height 10 -variable LocvarProgbar -type incremental -bg white -fg blue]
		#set prog [ttk::progressbar $winImpoProg.prog -mode indeterminate]
		if {![winfo exists .prog]} {
			set prog [ttk::progressbar .prog -mode indeterminate -orient horizontal -length 200 ]
			grid config $prog -row 0 -column 0 -padx 10 -pady 10
			#ttk::progressbar::start $winImpoProg.prog 10 ; #added for indeterminate mode
		} else {
			
		}
		catch { .prog start 10 }
		BWidget::place $winImpoProg 0 0 center

		update idletasks
		#puts "progress bar created"
		return  $winImpoProg.prog
	} elseif {$stat == "stop" } { 
		#set LocvarProgbar 100
		#ttk::progressbar::stop .impoProg.prog ; #added for indeterminate mode
		#.impoProg.prog stop

		#if {[winfo exists .prog]} {
		#	catch {	.prog stop }
		#}

		catch {	.prog stop }
		#destroy .impoProg
		wm withdraw .
	} elseif {$stat == "incr"} {
		incr LocvarProgbar
	}

}

################################################################################################
#proc AddIndexWindow
#Input       : -
#Output      : -
#Description : -
################################################################################################
proc AddIndexWindow {} {
	global updatetree
	global indexVar
	global frame2
	global status_save

	set winAddIdx .addIdx
	catch "destroy $winAddIdx"
	toplevel $winAddIdx
	wm title     $winAddIdx	"Add Index"
	wm resizable $winAddIdx 0 0
	wm transient $winAddIdx .
	wm deiconify $winAddIdx
	wm minsize   $winAddIdx 50 50
	grab $winAddIdx

	set frame1 [frame $winAddIdx.fram1]
	set frame2 [frame $winAddIdx.fram2]

	label $winAddIdx.l_empty1 -text "               "	
	label $frame1.l_index -text "Enter the Index"
	label $winAddIdx.l_empty2 -text "               "	
	label $winAddIdx.l_empty3 -text "               "

	entry $frame1.en_index -textvariable indexVar -background white -relief ridge -validate key -vcmd "IsValidIdx %P 4"
	set indexVar ""

	button $frame2.bt_ok -text "  Ok  " -command {
		if {[string length $indexVar] != 4} {
			set res [tk_messageBox -message "Invalid Index" -type ok -parent .addIdx]
			focus .addIdx
			return
		}
		set indexVar [string toupper $indexVar]
		set node [$updatetree selection get]
		#puts node----->$node

		#gets the nodeId and Type of selected node
		set result [GetNodeIdType $node]
		if {$result != "" } {
			set nodeId [lindex $result 0]
			set nodeType [lindex $result 1]
		} else {
			#must be some other node this condition should never reach
			#puts "\n\nAddIndexWindow->SHOULD NEVER HAPPEN 1!!\n\n"
			return
		}


		set nodePosition [split $node -]
		set nodePosition [lrange $nodePosition 1 end]
		set nodePosition [join $nodePosition -]

		if {[string match "18*" $indexVar] || [string match "1A*" $indexVar]} {
			#it must a TPDO object
			set child [$updatetree nodes TPDO-$nodePosition]
		} elseif {[string match "14*" $indexVar] || [string match "16*" $indexVar]} {
			#it must a RPDO object	
			set child [$updatetree nodes RPDO-$nodePosition]
		} else {
			set child [$updatetree nodes $node]
		}	


		#puts child->$child
		set sortChild ""
		set indexPosition 0
		foreach tempChild $child {
			if {[string match "PDO*" $tempChild]} {
				#dont need to add it to list
			} else {
				set tail [split $tempChild -]
				set tail [lindex $tail end]
				lappend sortChild $tail
				#find the position where the added index is to be inserted in sorted order in TreeView 
				#0x is appended so that the input will be considered as hexadecimal number and numerical operation proceeds
				if {[ expr 0x$indexVar > 0x[string range [$updatetree itemcget $tempChild -text] end-4 end-1] ]} {
					#since the tree is populated after sorting 
					incr indexPosition
				} else {
					#
				}
			}
		}


		set sortChild [lsort -integer $sortChild]
		if {$sortChild == ""} {
			set count 0
		} else {
			set count [expr [lindex $sortChild end]+1 ]
		}
		#puts "AddIndex nodeId->$nodeId nodeType->$nodeType indexVar->$indexVar"
		set catchErrCode [AddIndex $nodeId $nodeType $indexVar]
		#puts "catchErrCode->$catchErrCode"
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		#puts "ErrCode:$ErrCode"
		if { $ErrCode != 0 } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .addIdx
			#tk_messageBox -message "ErrCode : $ErrCode" -title Warning -icon warning
			$frame2.bt_cancel invoke
		}

		#Index is added need to save
		set status_save 1

		#puts "inc->[llength $sortChild]"

		#set indexName []
		#set indexName [GetIndexAttributes $nodeId $nodeType $indexVar 0]
		#puts "indexName->$indexName"




		set nodePos [new_intp]
		#puts "IfNodeExists nodeId->$nodeId nodeType->$nodeType nodePos->$nodePos"
		#IfNodeExists API is used to get the nodePosition which is needed fro various operation	
		#set catchErrCode [IfNodeExists $nodeId $nodeType $nodePos]


		#TODO waiting for new so then implement it
		set ExistfFlag [new_boolp]
		set catchErrCode [IfNodeExists $nodeId $nodeType $nodePos $ExistfFlag]
		set nodePos [intp_value $nodePos]
		set ExistfFlag [boolp_value $ExistfFlag]
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		#puts "ErrCode:$ErrCode"
		if { $ErrCode == 0 && $ExistfFlag == 1 } {
			#the node exist continue 
		} else {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon 	warning -parent .addIdx
			#tk_messageBox -message "ErrCode : $ErrCode\nExistfFlag : $ExistfFlag" -title Warning -icon warning -parent .addIdx
			$frame2.bt_cancel invoke
		}






		set indexPos [new_intp]
		#DllExport ocfmRetCode IfIndexExists(int NodeID, ENodeType NodeType, char* IndexID, int* IndexPos)
		set catchErrCode [IfIndexExists $nodeId $nodeType $indexVar $indexPos]
		set indexPos [intp_value $indexPos]

		set indexName [GetIndexAttributesbyPositions $nodePos $indexPos 0 ]
		#puts "indexName->$indexName"


		if {[string match "18*" $indexVar] || [string match "1A*" $indexVar]} {
			#it must a TPDO object
			set parentNode TPDO-$nodePosition
			set indexNode TPdoIndexValue-$nodePosition-$count
			set subIndexNode TPdoSubIndexValue-$nodePosition-$count
		} elseif {[string match "14*" $indexVar] || [string match "16*" $indexVar]} {
			#it must a RPDO object	
			set parentNode RPDO-$nodePosition
			set indexNode RPdoIndexValue-$nodePosition-$count
			set subIndexNode RPdoSubIndexValue-$nodePosition-$count
		} else {
			set parentNode $node
			set indexNode IndexValue-$nodePosition-$count
			set subIndexNode SubIndexValue-$nodePosition-$count
		}

#puts "child for parentNode===>[$updatetree nodes $parentNode] "

		$updatetree insert $indexPosition $parentNode $indexNode -text [lindex $indexName 1]\(0x$indexVar\) -open 0 -image [Bitmap::get index]


		#SortNode {nodeType nodeID nodePos choice {indexPos ""} {indexId ""}}
		set sidxCorrList [SortNode $nodeType $nodeId $nodePos sub $indexPos $indexVar]
		set sidxCount [llength $sidxCorrList]
		for {set tempSidxCount 0} { $tempSidxCount < $sidxCount } {incr tempSidxCount} {
			set sortedSubIndexPos [lindex $sidxCorrList $tempSidxCount]
			set subIndexName [GetSubIndexAttributesbyPositions $nodePos $indexPos $sortedSubIndexPos  0 ]
			set subIndexId [GetSubIndexIDbyPositions $nodePos $indexPos $sortedSubIndexPos ]
			set subIndexId [lindex $subIndexId 1]
			$updatetree insert $tempSidxCount $indexNode $subIndexNode-$tempSidxCount -text [lindex $subIndexName 1]\(0x$subIndexId\) -open 0 -image [Bitmap::get subindex]

#puts "$updatetree insert $tempSidxCount $indexNode $subIndexNode-$tempSidxCount -text [lindex $subIndexName 1]\($subIndexId\) -open 0 -image [Bitmap::get subindex]"

$updatetree itemconfigure $subIndexNode-$tempSidxCount -open 0
		}

		#puts "child for parentNode after adding index ->[$updatetree nodes $parentNode]"

		$frame2.bt_cancel invoke
	}
	button $frame2.bt_cancel -text Cancel -command { 
		unset indexVar
		unset frame2
		destroy .addIdx	
		return
	}
	grid config $winAddIdx.l_empty1 -row 0 -column 0 
	grid config $frame1 -row 1 -column 0 
	grid config $winAddIdx.l_empty2 -row 2 -column 0 
	grid config $frame2 -row 3 -column 0  
	grid config $winAddIdx.l_empty3 -row 4 -column 0 

	grid config $frame1.l_index -row 0 -column 0 -padx 5
	grid config $frame1.en_index -row 0 -column 1 -padx 5

	grid config $frame2.bt_ok -row 0 -column 0 -padx 5
	grid config $frame2.bt_cancel -row 0 -column 1 -padx 5

	wm protocol .addIdx WM_DELETE_WINDOW "$frame2.bt_cancel invoke"
	bind $winAddIdx <KeyPress-Return> "$frame2.bt_ok invoke"
	bind $winAddIdx <KeyPress-Escape> "$frame2.bt_cancel invoke"

	focus $frame1.en_index
	centerW $winAddIdx
}

################################################################################################
#proc AddSubIndexWindow
#Input       : -
#Output      : -
#Description : -
################################################################################################
proc AddSubIndexWindow {} {
	global updatetree
	global subIndexVar
	global frame2
	global status_save

	set winAddSidx .addSidx
	catch "destroy $winAddSidx"
	toplevel $winAddSidx
	wm title     $winAddSidx "Add SubIndex"
	wm resizable $winAddSidx 0 0
	wm transient $winAddSidx .
	wm deiconify $winAddSidx
	wm minsize   $winAddSidx 50 50
	grab $winAddSidx

	set frame1 [frame $winAddSidx.fram1]
	set frame2 [frame $winAddSidx.fram2]

	label $winAddSidx.l_empty1 -text "               "	
	label $frame1.l_subindex -text "Enter the SubIndex"
	label $winAddSidx.l_empty2 -text "               "	
	label $winAddSidx.l_empty3 -text "               "

	entry $frame1.en_subindex -textvariable subIndexVar -background white -relief ridge -validate key -vcmd "IsValidIdx %P 2"
	set subIndexVar ""

	button $frame2.bt_ok -text "  Ok  " -command {
		if {[string length $subIndexVar] != 2} {
			set res [tk_messageBox -message "Invalid SubIndex" -type ok -parent .addSidx]
			focus .addSidx
			return
		}		
		set subIndexVar [string toupper $subIndexVar]
		set node [$updatetree selection get]
		#puts node----->$node
		set indexVar [string range [$updatetree itemcget $node -text] end-4 end-1 ]
		set indexVar [string toupper $indexVar]


		#gets the nodeId and Type of selected node
		set result [GetNodeIdType $node]
		if {$result != "" } {
			set nodeId [lindex $result 0]
			set nodeType [lindex $result 1]
		} else {
			#must be some other node this condition should never reach
			#puts "\n\nAddSubIndexWindow->SHOULD NEVER HAPPEN 1!!\n\n"
			return
		}
	
		set child [$updatetree nodes $node]
		#puts child->$child
		set subIndexPos 0
		set sortChild ""
		foreach tempChild $child {
			set tail [split $tempChild -]
			set tail [lindex $tail end]
			lappend sortChild $tail
			#find the position where the added index is to be inserted in sorted order in TreeView 
			#0x is appended so that the input will be considered as hexadecimal number and numerical operation proceeds
			if {[ expr 0x$subIndexVar > 0x[string range [$updatetree itemcget $tempChild -text] end-2 end-1] ]} {
				#since the tree is populated after sorting get the count where it is just greater such that it can be inserted properly
				incr subIndexPos
			} else {
				#
			}
		}

		set sortChild [lsort -integer $sortChild]
		if {$sortChild == ""} {
			set count 0
		} else {
			set count [expr [lindex $sortChild end]+1 ]
		}
		#puts "count->$count===subIndexPos->$subIndexPos"
		
		#puts node->$node
		set nodePos [split $node -]
		set nodePos [lrange $nodePos 1 end]
		set nodePos [join $nodePos -]
		##puts "nodePos---->$nodePos=====nodeType---->$nodeType======nodeId--->$nodeId"
		#puts "AddSubIndex nodeId->$nodeId nodeType->$nodeType indexVar->$indexVar subIndexVar->$subIndexVar"
		set catchErrCode [AddSubIndex $nodeId $nodeType $indexVar $subIndexVar]
		#puts "catchErrCode->$catchErrCode"
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		#puts "ErrCode:$ErrCode"
		if { $ErrCode != 0 } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
			#tk_messageBox -message "ErrCode : $ErrCode" -title Warning -icon warning
			$frame2.bt_cancel invoke
		}

		#SubIndex is added need to save
		set status_save 1

		set subIndexName []
		set subIndexName [GetSubIndexAttributes $nodeId $nodeType $indexVar $subIndexVar 0]
		#puts "subIndexName->$subIndexName"

		if {[string match "TPdo*" $node]} {
			$updatetree insert $subIndexPos $node TPdoSubIndexValue-$nodePos-$count -text [lindex $subIndexName 1]\(0x$subIndexVar\) -open 0 -image [Bitmap::get subindex]
		} elseif {[string match "RPdo*" $node]} {
			$updatetree insert $subIndexPos $node RPdoSubIndexValue-$nodePos-$count -text [lindex $subIndexName 1]\(0x$subIndexVar\) -open 0 -image [Bitmap::get subindex]
		} else {
			$updatetree insert $subIndexPos $node SubIndexValue-$nodePos-$count -text [lindex $subIndexName 1]\(0x$subIndexVar\) -open 0 -image [Bitmap::get subindex]
		}

		$frame2.bt_cancel invoke

	}
	button $frame2.bt_cancel -text Cancel -command { 
		unset subIndexVar
		unset frame2
		destroy .addSidx
		return
	}
	grid config $winAddSidx.l_empty1 -row 0 -column 0 
	grid config $frame1 -row 1 -column 0 
	grid config $winAddSidx.l_empty2 -row 2 -column 0 
	grid config $frame2 -row 3 -column 0  
	grid config $winAddSidx.l_empty3 -row 4 -column 0 

	grid config $frame1.l_subindex -row 0 -column 0 -padx 5
	grid config $frame1.en_subindex -row 0 -column 1 -padx 5

	grid config $frame2.bt_ok -row 0 -column 0 -padx 5
	grid config $frame2.bt_cancel -row 0 -column 1 -padx 5

	wm protocol .addSidx WM_DELETE_WINDOW "$frame2.bt_cancel invoke"
	bind $winAddSidx <KeyPress-Return> "$frame2.bt_ok invoke"
	bind $winAddSidx <KeyPress-Escape> "$frame2.bt_cancel invoke"

	focus $frame1.en_subindex
	centerW $winAddSidx
}

################################################################################################
#proc AddPDOWindow
#Input       : -
#Output      : -
#Description : -
################################################################################################
proc AddPDOWindow {} {
	global updatetree
	global pdoVar
	global frame2
	global status_save

	set winAddPdo .addPdo
	catch "destroy $winAddPdo"
	toplevel $winAddPdo
	wm title     $winAddPdo	"Add PDO"
	wm resizable $winAddPdo 0 0
	wm transient $winAddPdo .
	wm deiconify $winAddPdo
	wm minsize   $winAddPdo 50 50
	grab $winAddPdo

	set frame1 [frame $winAddPdo.fram1]
	set frame2 [frame $winAddPdo.fram2]

	label $winAddPdo.l_empty1 -text "               "	
	label $frame1.l_index -text "Enter the PDO Index"
	label $winAddPdo.l_empty2 -text "               "	
	label $winAddPdo.l_empty3 -text "               "

	entry $frame1.en_index -textvariable pdoVar -background white -relief ridge -validate key -vcmd "IsValidIdx %P 4"
	set pdoVar ""

	button $frame2.bt_ok -text "  Ok  " -command {
		if {[string length $pdoVar] != 4} {
			set res [tk_messageBox -message "Invalid PDO Index" -type ok -parent .addPdo]
			focus .addPdo
			return
		}
		set pdoVar [string toupper $pdoVar]

		set flag 0
		foreach check [list 14?? 16?? 18?? 1A??] {
			if {[string match "$check" $pdoVar]} {
				#it is a match exit the loop
				set flag 0
				break
			} else {
				set flag 1
			}
		}
		if {$flag == 1} {
			#it did not match any thing
			set res [tk_messageBox -message "Invalid PDO Index" -type ok -parent .addPdo]
			focus .addPdo
			return
 		}


		set node [$updatetree selection get]
		#puts node----->$node

		#gets the nodeId and Type of selected node
		set result [GetNodeIdType $node]
		if {$result != "" } {
			set nodeId [lindex $result 0]
			set nodeType [lindex $result 1]
		} else {
			#must be some other node this condition should never reach
			#puts "\n\nAddIndexWindow->SHOULD NEVER HAPPEN 1!!\n\n"
			return
		}


		set nodePosition [split $node -]
		set nodePosition [lrange $nodePosition 1 end]
		set nodePosition [join $nodePosition -]

		if {[string match "18*" $pdoVar] || [string match "1A*" $pdoVar]} {
			#it must a TPDO object
			set child [$updatetree nodes TPDO-$nodePosition]
		} elseif {[string match "14*" $pdoVar] || [string match "16*" $pdoVar]} {
			#it must a RPDO object	
			set child [$updatetree nodes RPDO-$nodePosition]
		} else {
			#should not occur
		}	


		puts child->$child
		set sortChild ""
		set indexPosition 0
		foreach tempChild $child {
			if {[string match "PDO*" $tempChild]} {
				#dont need to add it to list
			} else {
				set tail [split $tempChild -]
				set tail [lindex $tail end]
				lappend sortChild $tail
				#find the position where the added index is to be inserted in sorted order in TreeView 
				#0x is appended so that the input will be considered as hexadecimal number and numerical operation proceeds
				if {[ expr 0x$pdoVar > 0x[string range [$updatetree itemcget $tempChild -text] end-4 end-1] ]} {
					#since the tree is populated after sorting 
					incr indexPosition
				} else {
					#
				}
			}
		}


		set sortChild [lsort -integer $sortChild]
		if {$sortChild == ""} {
			set count 0
		} else {
			set count [expr [lindex $sortChild end]+1 ]
		}
		#puts "AddIndex nodeId->$nodeId nodeType->$nodeType indexVar->$pdoVar"
		set catchErrCode [AddIndex $nodeId $nodeType $pdoVar]
		#puts "catchErrCode->$catchErrCode"
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		#puts "ErrCode:$ErrCode"
		if { $ErrCode != 0 } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .addPdo
			#tk_messageBox -message "ErrCode : $ErrCode" -title Warning -icon warning
			$frame2.bt_cancel invoke
		}

		#puts "inc->[llength $sortChild]"

		#set indexName []
		#set indexName [GetIndexAttributes $nodeId $nodeType $indexVar 0]
		#puts "indexName->$indexName"

		#Index is added to PDO need to save
		set status_save 1


		set nodePos [new_intp]
		#puts "IfNodeExists nodeId->$nodeId nodeType->$nodeType nodePos->$nodePos"
		#IfNodeExists API is used to get the nodePosition which is needed fro various operation	
		#set catchErrCode [IfNodeExists $nodeId $nodeType $nodePos]


		#TODO waiting for new so then implement it
		set ExistfFlag [new_boolp]
		set catchErrCode [IfNodeExists $nodeId $nodeType $nodePos $ExistfFlag]
		set nodePos [intp_value $nodePos]
		set ExistfFlag [boolp_value $ExistfFlag]
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		#puts "ErrCode:$ErrCode"
		if { $ErrCode == 0 && $ExistfFlag == 1 } {
			#the node exist continue 
		} else {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon 	warning -parent .addPdo
			#tk_messageBox -message "ErrCode : $ErrCode\nExistfFlag : $ExistfFlag" -title Warning -icon warning -parent .addPdo
			$frame2.bt_cancel invoke
		}






		set indexPos [new_intp]
		#DllExport ocfmRetCode IfIndexExists(int NodeID, ENodeType NodeType, char* IndexID, int* IndexPos)
		set catchErrCode [IfIndexExists $nodeId $nodeType $pdoVar $indexPos]
		set indexPos [intp_value $indexPos]

		set indexName [GetIndexAttributesbyPositions $nodePos $indexPos 0 ]
		#puts "indexName->$indexName"


		if {[string match "18*" $pdoVar] || [string match "1A*" $pdoVar]} {
			#it must a TPDO object
			set parentNode TPDO-$nodePosition
			set indexNode TPdoIndexValue-$nodePosition-$count
			set subIndexNode TPdoSubIndexValue-$nodePosition-$count
		} elseif {[string match "14*" $pdoVar] || [string match "16*" $pdoVar]} {
			#it must a RPDO object	
			set parentNode RPDO-$nodePosition
			set indexNode RPdoIndexValue-$nodePosition-$count
			set subIndexNode RPdoSubIndexValue-$nodePosition-$count
		} else {
			#should not occur
		}

#puts "child for parentNode===>[$updatetree nodes $parentNode] "

		$updatetree insert $indexPosition $parentNode $indexNode -text [lindex $indexName 1]\(0x$pdoVar\) -open 0 -image [Bitmap::get index]


		#SortNode {nodeType nodeID nodePos choice {indexPos ""} {indexId ""}}
		set sidxCorrList [SortNode $nodeType $nodeId $nodePos sub $indexPos $pdoVar]
		set sidxCount [llength $sidxCorrList]
		for {set tempSidxCount 0} { $tempSidxCount < $sidxCount } {incr tempSidxCount} {
			set sortedSubIndexPos [lindex $sidxCorrList $tempSidxCount]
			set subIndexName [GetSubIndexAttributesbyPositions $nodePos $indexPos $sortedSubIndexPos  0 ]
			set subIndexId [GetSubIndexIDbyPositions $nodePos $indexPos $sortedSubIndexPos ]
			set subIndexId [lindex $subIndexId 1]
			$updatetree insert $tempSidxCount $indexNode $subIndexNode-$tempSidxCount -text [lindex $subIndexName 1]\(0x$subIndexId\) -open 0 -image [Bitmap::get subindex]

#puts "$updatetree insert $tempSidxCount $indexNode $subIndexNode-$tempSidxCount -text [lindex $subIndexName 1]\($subIndexId\) -open 0 -image [Bitmap::get subindex]"

$updatetree itemconfigure $subIndexNode-$tempSidxCount -open 0
		}

		#puts "child for parentNode after adding index ->[$updatetree nodes $parentNode]"
		$frame2.bt_cancel invoke
		
	}
	button $frame2.bt_cancel -text Cancel -command { 
		unset pdoVar
		unset frame2
		destroy .addPdo	
		return
	}
	grid config $winAddPdo.l_empty1 -row 0 -column 0 
	grid config $frame1 -row 1 -column 0 
	grid config $winAddPdo.l_empty2 -row 2 -column 0 
	grid config $frame2 -row 3 -column 0  
	grid config $winAddPdo.l_empty3 -row 4 -column 0 

	grid config $frame1.l_index -row 0 -column 0 -padx 5
	grid config $frame1.en_index -row 0 -column 1 -padx 5

	grid config $frame2.bt_ok -row 0 -column 0 -padx 5
	grid config $frame2.bt_cancel -row 0 -column 1 -padx 5

	wm protocol .addPdo WM_DELETE_WINDOW "$frame2.bt_cancel invoke"
	bind $winAddPdo <KeyPress-Return> "$frame2.bt_ok invoke"
	bind $winAddPdo <KeyPress-Escape> "$frame2.bt_cancel invoke"

	focus $frame1.en_index
	centerW $winAddPdo
}


################################################################################################
#proc PropertiesWindow
#Input       : -
#Output      : -
#Description : -
################################################################################################
proc PropertiesWindow {} {
	global updatetree
	global PjtDir

	set node [$updatetree selection get]

	set winProp .prop
	catch "destroy $winProp"
	toplevel $winProp
	wm resizable $winProp 0 0
	wm transient $winProp .
	wm deiconify $winProp
	wm minsize   $winProp 200 100
	grab $winProp

	set frame1 [frame $winProp.frame -padx 5 -pady 5 ]

	if {$node == "PjtName"} {
		wm title $winProp "Project Properties"
		set title1 "Name"
		set display1 [$updatetree itemcget $node -text]
		set title2 "Location"	
		set display2 $PjtDir
	} elseif { [string match "MN-*" $node] || [string match "CN-*" $node] } {
		if { [string match "MN-*" $node] } {
			wm title $winProp "MN Properties"
			set nodeId 240
			set nodeType 0
			set title1 "Managing Node"
			set display1 "openPOWERLINK_MN"
			#ocfmRetCode GetNodeCount(int MNID, int* Out_NodeCount)
			set title3 "Number of CN"	
			set count [new_intp]
			set catchErrCode [GetNodeCount 240 $count]
			set ErrCode [ocfmRetCode_code_get $catchErrCode]
#puts "CN count:[intp_value $count]....ErrCode->$ErrCode"
			if { $ErrCode == 0 } {
				set display3 [expr [intp_value $count]-1]
			} else {
				set display3 ""
			}
			label $frame1.l_title3 -text $title3
			label $frame1.l_sep3 -text ":"
			label $frame1.l_display3 -text $display3	
		} else {
			wm title $winProp "CN Properties"
			set result [GetNodeIdType $node]
			if {$result != "" } {
				set nodeId [lindex $result 0]
				set nodeType [lindex $result 1]
			} else {
				#must be some other node this condition should never reach
				return
			}
			set title1 "Name"
			set display1 [string range [$updatetree itemcget $node -text] 0 end-[expr [string length $nodeId]+2]]
		
		}

		set title2 "NodeId "	
		set display2 $nodeId

		set title4 "Number of Indexes"
		set count [new_intp]
#puts "GetIndexCount $nodeId $nodeType $count"	
		set catchErrCode [GetIndexCount $nodeId $nodeType $count]
#puts "catchErrCode->$catchErrCode"
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
#puts "Errcode->$ErrCode"
		if { $ErrCode == 0 } {
			set display4 [intp_value $count]
		} else {
			set display4 ""
		}
		label $frame1.l_title4 -text $title4
		label $frame1.l_sep4 -text ":"
		label $frame1.l_display4 -text $display4
	} else {
		#should not occur
		return
	}


	label $frame1.l_title1 -text $title1 
	label $frame1.l_sep1 -text ":"
	label $frame1.l_display1 -text $display1
	label $frame1.l_title2 -text $title2
	label $frame1.l_sep2 -text ":"
	label $frame1.l_display2 -text $display2
	label $frame1.l_empty1 -text ""
	label $frame1.l_empty2 -text ""

	button $winProp.bt_ok -text "  Ok  " -command {
		destroy .prop
	}

	#grid config $frame1 -row 0 -column 0 
	pack configure $frame1 

	grid config $frame1.l_empty1 -row 0 -column 0 -columnspan 2

	grid config $frame1.l_title1 -row 1 -column 0 -sticky w
	grid config $frame1.l_sep1 -row 1 -column 1
	grid config $frame1.l_display1 -row 1 -column 2 -sticky w
	grid config $frame1.l_title2 -row 2 -column 0  -sticky w
	grid config $frame1.l_sep2 -row 2 -column 1
	grid config $frame1.l_display2 -row 2 -column 2 -sticky w
	if { $node == "PjtName" } {
		grid config $frame1.l_empty2 -row 3 -column 0 -columnspan 1

		#grid config $winProp.bt_ok -row 1 -column 0
		pack configure $winProp.bt_ok
	} elseif { [string match "MN-*" $node] } {
		grid config $frame1.l_title3 -row 3 -column 0 -sticky w	
		grid config $frame1.l_sep3 -row 3 -column 1	
		grid config $frame1.l_display3 -row 3 -column 2 -sticky w
		grid config $frame1.l_title4 -row 4 -column 0 -sticky w
		grid config $frame1.l_sep4 -row 4 -column 1	
		grid config $frame1.l_display4 -row 4 -column 2 -sticky w
		grid config $frame1.l_empty2 -row 5 -column 0 -columnspan 1

		#grid config $winProp.bt_ok -row 1 -column 0
		pack configure $winProp.bt_ok
	} elseif { [string match "CN-*" $node] } {
		grid config $frame1.l_title4 -row 3 -column 0 -sticky w
		grid config $frame1.l_sep4 -row 3 -column 1
		grid config $frame1.l_display4 -row 3 -column 2 -sticky w
		grid config $frame1.l_empty2 -row 4 -column 0 -columnspan 1

		#grid config $winProp.bt_ok -row 1 -column 0
		pack configure $winProp.bt_ok
	} else {
		#should not occur
	}
	
}
