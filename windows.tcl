################################################################################
#									
# Script:	windows.tcl						
#									
# Author:	Kalycito Infotech Pvt Ltd		
#									
# Description:	Contains the windows displayed in application.
#
#
################################################################################

################################################################################
#proc StartUpWindow
#Input   : -
#Output  : -
#Description : Gui during start up
################################################################################
proc StartUp {} {
	global startVar
	set winStartUp .startUp
	catch "destroy $winStartUp"
	catch "font delete custom2"
        font create custom2 -size 9 -family TkDefaultFont
	toplevel     $winStartUp -takefocus 1
	wm title     $winStartUp "openCONGFIGURATOR"
	wm resizable $winStartUp 0 0
	wm transient $winStartUp .
	wm deiconify $winStartUp
	#wm minsize   $winStartUp 100 100
	#wm topmost  $winStartUp 
	grab $winStartUp	

	#set titleFrame1 [TitleFrame $winStartUp.titleFrame1 -text "Select Project" ]
	#set frame1 [$titleFrame1 getframe]
	set frame1 [frame $winStartUp.fram1]
	set frame2 [frame $frame1.fram2]

	label $frame1.l_empty1 -text ""
	label $frame1.l_empty2 -text ""
	label $frame1.l_empty3 -text ""
	label $frame1.l_desc -text "Description"
	
	text $frame1.t_desc -height 5 -width 40 -state disabled -background white

	radiobutton $frame1.ra_default  -text "Open Sample Project"   -variable startVar -value 1 -font custom2 -command "SampleText $frame1.t_desc" -state disabled
	radiobutton $frame1.ra_newProj  -text "Create New Project"    -variable startVar -value 2 -font custom2 -command "NewText $frame1.t_desc" 
	radiobutton $frame1.ra_openProj -text "Open Existing Project" -variable startVar -value 3 -font custom2 -command "OpenText $frame1.t_desc" -state disabled
	$frame1.ra_newProj select
	NewText $frame1.t_desc
	 
	button $frame2.b_ok -text "  Ok  " -command { 
		if {$startVar==1} {
			YetToImplement;
		} elseif {$startVar==2} {
			NewProjectWindow
		} elseif {$startVar==3} {
			YetToImplement;
		}
		destroy .startUp
	}
	button $frame2.b_cancel -text "Cancel" -command {
		destroy .startUp
		Editor::exit_app
	}
	#grid config $titleFrame1 -row 0 -column 0 -padx 35 -pady 10
	#grid config $frame1 -row 0 -column 0 

	grid config $frame1 -row 0 -column 0 -padx 35 -pady 10

	#grid config $frame1.ra_default -row 0 -column 0 -sticky w 
	#grid config $frame1.l_empty1 -row 1 -column 0 -sticky w 	
	#grid config $frame1.ra_newProj -row 2 -column 0 -sticky w 
	#grid config $frame1.l_empty2 -row 3 -column 0 -sticky w 
	#grid config $frame1.ra_openProj -row 4 -column 0 -sticky w 
	#grid config $frame1.l_empty3 -row 5 -column 0 -sticky w 
	#grid config $frame2 -row 6 -column 0  -padx 5 -pady 5

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


proc SampleText {t_desc} {
	$t_desc configure -state normal
	$t_desc delete 1.0 end
	$t_desc insert end "Open the sample Project"
	$t_desc configure -state disabled
}

proc NewText {t_desc} {
	$t_desc configure -state normal
	$t_desc delete 1.0 end
	$t_desc insert end "Create a new Project"
	$t_desc configure -state disabled
}

proc OpenText {t_desc} {
	$t_desc configure -state normal
	$t_desc delete 1.0 end
	$t_desc insert end "Open Existing Project"
	$t_desc configure -state disabled
}

################################################################################
#proc ConnectionSettingWindow
#Input   : -
#Output  : -
#Description : Gui for connection Settings
################################################################################
proc ConnectionSettingWindow {} {
	global connectionIpAddr
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
	entry $frame1.en_ip -textvariable connectionIpAddr -background white -relief ridge -validate all -vcmd "isIP %P %V"

	button $frame2.b_ok -text "  Ok  " -command { 
		YetToImplement
		destroy .connSett
	}
	button $frame2.b_cancel -text "Cancel" -command {
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

	#wm protocol .connSett WM_DELETE_WINDOW {
	#	destroy .connSett
	#}
	wm protocol .connSett WM_DELETE_WINDOW "$frame2.b_cancel invoke"
	bind $winConnSett <KeyPress-Return> "$frame2.b_ok invoke"
	bind $winConnSett <KeyPress-Escape> "$frame2.b_cancel invoke"
	
	centerW $winConnSett

}

################################################################################
#proc AddPDOWindow
#Input   : -
#Output  : -
#Description : Gui for adding PDO to CN
################################################################################
proc AddPDOWindow {} {

	global pdoStartValue
	global mapEntValue
	global noPDOValue
	global pdoType

	set winAddPDO .addPDO
	catch "destroy $winAddPDO"
	toplevel     $winAddPDO
	wm title     $winAddPDO "Add PDOs"
	wm resizable $winAddPDO 0 0
	wm transient $winAddPDO .
	wm deiconify $winAddPDO
	grab $winAddPDO

	
	set titleFrame1 [TitleFrame $winAddPDO.titleFrame1 -text "PDO Configuration" ]
	set titleInnerFrame2 [$titleFrame1 getframe]
	set frame1 [frame $titleInnerFrame2.fram1]
	set frame2 [frame $titleInnerFrame2.fram2]
	set frame3 [frame $titleInnerFrame2.fram3]

	label $winAddPDO.l_empty1 -text ""	
	label $winAddPDO.l_empty2 -text ""
	label $frame1.l_pdostart -text "PDO Starting number \[1-255\] :"
	label $frame1.l_MapEnt -text   "Mapping Entries \[1-254\] :"
	label $frame1.l_NoPDO -text    "Number of PDOs \[1-255\] :"
	label $titleInnerFrame2.l_empty5 -text "    "
	label $titleInnerFrame2.l_type -text "PDO type"
	label $titleInnerFrame2.l_empty9 -text ""
	label $winAddPDO.l_empty8 -text ""

	entry $frame1.en_pdostart -textvariable pdoStartValue -background white -validate key -vcmd "IsInt %P %V"
	entry $frame1.en_MapEnt -textvariable mapEntValue -background white -validate key -vcmd {expr {[string len %P] <= 3} && {[string is int %P]}}
	entry $frame1.en_NoPDO -textvariable noPDOValue -background white -validate key -vcmd {expr {[string len %P] <= 3} && {[string is int %P]}}

	set pdoType off
	radiobutton $frame2.ra_tran -text "Transmit PDO" -variable pdoType   -value on 
	radiobutton $frame2.ra_rece   -text "Receive PDO"  -variable pdoType   -value off 
	$frame2.ra_rece select

	button $frame3.b_ok -text "  Add  " -command { 
		if {$pdoStartValue < 1 ||$pdoStartValue > 255 } {
			tk_messageBox -message "PDO Starting number value range is 1 to 255" -parent .addPDO -icon error
			focus .addPDO
			return
		}
		if {$mapEntValue < 1 ||$mapEntValue > 254 } {
			tk_messageBox -message "Mapping Entries value range is 1 to 254" -parent .addPDO -icon error
			focus .addPDO
			return
		}
		if {$noPDOValue < 1 ||$noPDOValue > 255 } {
			tk_messageBox -message "Number of PDOs value range is 1 to 255" -parent .addPDO -icon error
			focus .addPDO
			return
		}
		destroy .addPDO
	}
	button $frame3.b_cancel -text "Cancel" -command {
		destroy .addPDO
	}

	grid config $winAddPDO.l_empty1 -row 0 -column 0 -sticky "news"
	grid config $titleFrame1 -row 1 -column 0 -ipadx 20 -padx 20 -sticky "news"

	grid config $frame1 -row 0 -column 0 -sticky "news" -columnspan 1
	grid config $frame1.l_pdostart  -row 0 -column 0 
	grid config $frame1.en_pdostart -row 0 -column 1
	grid config $frame1.l_MapEnt  -row 1 -column 0 
	grid config $frame1.en_MapEnt -row 1 -column 1
	grid config $frame1.l_NoPDO  -row 2 -column 0 
	grid config $frame1.en_NoPDO -row 2 -column 1

	grid config $titleInnerFrame2.l_empty5  -row 3 -column 0

	grid config $titleInnerFrame2.l_type  -row 4 -column 0

	grid config $frame2.ra_tran -row 0 -column 0 -sticky "w"
	grid config $frame2.ra_rece   -row 0 -column 1 -sticky "w"
	grid config $frame2 -row 5 -column 0

	grid config $titleInnerFrame2.l_empty9 -row 6 -column 0 -sticky "news"

	grid config $frame3.b_ok  -row 0 -column 0 
	grid config $frame3.b_cancel -row 0 -column 1
	grid config $frame3 -row 7 -column 0 

	grid config $winAddPDO.l_empty8 -row 2 -column 0 -sticky "news"


	wm protocol .addPDO WM_DELETE_WINDOW "$frame3.b_cancel invoke"
	bind $winAddPDO <KeyPress-Return> "$frame3.b_ok invoke"
	bind $winAddPDO <KeyPress-Escape> "$frame3.b_cancel invoke"

	centerW $winAddPDO
}

#################################################################################################################
# proc AddCNWindow
#
# pops up a window and gets all the details for a testgroup and calls AddTestGroup procedure to update in tree window # and in structure
#####################################################################################################################
proc AddCNWindow {} {
	global cnName
	global nodeId
	global tmpImpCnDir

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
	set titleFrame3 [TitleFrame $titleInnerFrame1.titleFrame3 -text "CN Config" ]
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


	entry $frame2.en_name -textvariable cnName -background white -relief ridge
	set cnName ""	
	entry $frame2.en_node -textvariable nodeId -background white -relief ridge -validate key -vcmd "IsInt %P %V"
	set nodeId ""
	entry $titleInnerFrame3.en_imppath -textvariable tmpImpCnDir -background white -relief ridge -width 35
	set tmpImpCnDir ""
	$titleInnerFrame3.en_imppath config -state disabled

	button $titleInnerFrame3.bt_imppath -text Browse -command {
		set types {
		        {"XDC Files"     {.xdc } }
		        {"XDD Files"     {.xdd } }
		}
		set tmpImpCnDir [tk_getOpenFile -title "Import XDC/XDD" -filetypes $types -parent .addCN]

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
		if {$nodeId < 1 ||$nodeId > 239 } {
			tk_messageBox -message "Node id value range is 1 to 239" -parent .addCN -icon error
			focus .addCN
			return
		}
		
		if {$confCn=="off" && ![file isfile $tmpImpCnDir]} {
			tk_messageBox -message "Entered path for Import XDC/XDD not exist " -icon error -parent .addCN
			focus .addCN
			return
		}


		if {$confCn=="off"} {
			set chk [AddCN $cnName $tmpImpCnDir $nodeId]
		} else {
			set chk [AddCN $cnName 0 $nodeId]
		}
		destroy .addCN
	}

	button $frame1.bt_cancel -text Cancel -command { 
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

	centerW $winAddCN
}


#######################################################################
# proc saveProjectAsWindow
#
########################################################################
proc SaveProjectAsWindow {} {
	global tmpPjtName
	global tmpPjtDir

	set winSavProjAs .savProjAs
	catch "destroy $winSavProjAs"
	toplevel $winSavProjAs
	wm title     $winSavProjAs	"Project Wizard"
	wm resizable $winSavProjAs 0 0
	wm transient $winSavProjAs .
	wm deiconify $winSavProjAs
	wm minsize   $winSavProjAs 50 200
	grab $winSavProjAs

	set titleFrame1 [TitleFrame $winSavProjAs.titleFrame1 -text "Save Project as" ]
	set titleInnerFrame1 [$titleFrame1 getframe]
	set frame1 [frame $titleInnerFrame1.fram1]

	label $winSavProjAs.l_empty -text "               "	
	label $winSavProjAs.l_empty1 -text "               "
	label $titleInnerFrame1.l_empty2 -text "               "
	label $titleInnerFrame1.l_pjname -text "Project Name :" -justify left
	label $titleInnerFrame1.l_pjpath -text "Project Path :" -justify left
	label $titleInnerFrame1.l_empty3 -text "               "
	label $winSavProjAs.l_empty4 -text "               "

	set tmpPjtName ""
	entry $titleInnerFrame1.en_pjname -textvariable tmpPjtName -background white -relief ridge
	set tmpPjtDir ""
	entry $titleInnerFrame1.en_pjpath -textvariable tmpPjtDir -background white -relief ridge -width 35

	button $titleInnerFrame1.bt_pjpath -text Browse -command {
		set tmpPjtDir [tk_chooseDirectory -title "Save Project at" -parent .savProjAs]
		if {$tmpPjtDir == ""} {
			focus .savProjAs
			return
		}
	}
	button $frame1.bt_ok -text "  Ok  " -command {
		set tmpPjtName [string trim $tmpPjtName]
		if {$tmpPjtName == "" } {
			tk_messageBox -message "Enter Project Name" -title "Set Project Name error" -parent .savProjAs -icon error
			focus .savProjAs
			return
		}
		if {![file isdirectory $tmpPjtDir]} {
			tk_messageBox -message "Entered path for project is not a Directory" -parent .savProjAs -icon error
			focus .savProjAs
			return
		}
		destroy .savProjAs
	}
	button $frame1.bt_cancel -text Cancel -command { 
		destroy .savProjAs
	}


	grid config $winSavProjAs.l_empty -row 0 -column 0 
	
	grid config $titleFrame1 -row 1 -column 0 -sticky "news" -ipadx 10 -padx 10 -ipady 10
	#grid config $winNewProj.l_empty1 -row 2 -column 0 
	#grid config $titleInnerFrame1.l_empty2 -row 0 -column 0 
	grid config $titleInnerFrame1.l_pjname -row 1 -column 0 
	grid config $titleInnerFrame1.en_pjname -row 1 -column 1 -sticky "w"
	grid config $titleInnerFrame1.l_pjpath -row 2 -column 0 
	grid config $titleInnerFrame1.en_pjpath -row 2 -column 1 -sticky "w"
	grid config $titleInnerFrame1.bt_pjpath -row 2 -column 2 
	
	grid config $titleInnerFrame1.l_empty3 -row 3 -column 0 
	grid config $frame1 -row 6 -column 1 
	grid config $frame1.bt_ok -row 0 -column 0 
	grid config $frame1.bt_cancel -row 0 -column 1 

	grid config $winSavProjAs.l_empty4 -row 2 -column 0 

	#wm protocol .savProjAs WM_DELETE_WINDOW { 
	#	 destroy .savProjAs
        #}
	wm protocol .savProjAs WM_DELETE_WINDOW "$frame1.bt_cancel invoke"
	bind $winSavProjAs <KeyPress-Return> "$frame1.bt_ok invoke"
	bind $winSavProjAs <KeyPress-Escape> "$frame1.bt_cancel invoke"

	centerW $winSavProjAs
}
#######################################################################
# proc newprojectwindow
# Creates a new project
########################################################################

proc NewProjectWindow {} {
	#global PjtDir
	#global PjtName	
	#global tmpPjtDir
	#global status_run
	#global tg_count
	#global profileName
	#global pjtToolBoxPath
	#global pjtTimeOut
	#global pjtUserInclPath
	#if { $status_run == 1 } {
	#	Editor::RunStatusInfo
	#}
	#if {$PjtDir != "None"} {
		#Prompt for Saving the Existing Project
		#set result [tk_messageBox -message "Save Project $PjtName ?" -type yesnocancel -icon question -title 			#"Question"]
			 #switch -- $result {
	 		   #  yes {			 
	   		   #      saveproject
	   		    # }
	   		    # no  {conPuts "Project $PjtName not saved" info}
	   		    # cancel {
					#set PjtDir None
				#	conPuts "Create New Project Canceled" info
				#	return
				#}
	   		#}
	#}
	global tmpPjtName
	global tmpPjtDir
	global tmpImpDir
	#global mn
	global updatetree

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
	set titleFrame2 [TitleFrame $titleInnerFrame1.titleFrame2 -text "MN Config" ]
	set titleInnerFrame2 [$titleFrame2 getframe]

	label $winNewProj.l_empty -text "               "	
	label $winNewProj.l_empty1 -text "               "
	label $titleInnerFrame1.l_empty2 -text "               "
	label $titleInnerFrame1.l_pjname -text "Project Name :" -justify left
	label $titleInnerFrame1.l_pjpath -text "Project Path :" -justify left
	label $titleInnerFrame1.l_empty3 -text "               "
	label $titleInnerFrame1.l_empty4 -text "               "

	set tmpPjtName ""
	entry $titleInnerFrame1.en_pjname -textvariable tmpPjtName -background white -relief ridge
	set tmpPjtDir ""
	entry $titleInnerFrame1.en_pjpath -textvariable tmpPjtDir -background white -relief ridge -width 35
	set tmpImpDir ""
	entry $titleInnerFrame2.en_imppath -textvariable tmpImpDir -background white -relief ridge -width 35
	$titleInnerFrame2.en_imppath config -state disabled 

	radiobutton $titleInnerFrame2.ra_def -text "Default" -variable conf -value on -command {
			.newprj.titleFrame1.f.titleFrame2.f.en_imppath config -state disabled 
			.newprj.titleFrame1.f.titleFrame2.f.bt_imppath config -state disabled 
	}
	radiobutton $titleInnerFrame2.ra_imp -text "Import XDC/XDD" -variable conf -value off -command {
			.newprj.titleFrame1.f.titleFrame2.f.en_imppath config -state normal 
			.newprj.titleFrame1.f.titleFrame2.f.bt_imppath config -state normal 
	} 
	$titleInnerFrame2.ra_def select

	button $titleInnerFrame1.bt_pjpath -text Browse -command {
		set tmpPjtDir [tk_chooseDirectory -title "Project Location" -parent .newprj]
		if {$tmpPjtDir == ""} {
			focus .newprj
			return
		}
	}
	button $titleInnerFrame2.bt_imppath -text Browse -command {
		set types {
		        {"XDC Files"     {.xdc } }
		        {"XDD Files"     {.xdd } }
		}
		set tmpImpDir [tk_getOpenFile -title "Import XDC/XDD" -filetypes $types -parent .newprj]
		if {$tmpImpDir == ""} {
			focus .newprj
			return
		}
       }
	$titleInnerFrame2.bt_imppath config -state disabled 
	button $frame1.bt_ok -text "  Ok  " -command {
		set tmpPjtName [string trim $tmpPjtName]
		if {$tmpPjtName == "" } {
			tk_messageBox -message "Enter Project Name" -title "Set Project Name error" -icon error
			focus .newprj
			return
		}
		if {![file isdirectory $tmpPjtDir]} {
			tk_messageBox -message "Entered path for Project is not a directory" -icon error -parent .newprj
			focus .newprj
			return
		
		}
		if {$conf=="off" && ![file isfile $tmpImpDir]} {
			tk_messageBox -message "Entered path for Import XDC/XDD not exist " -icon error -parent .newprj
			focus .newprj
			return
		}

		#if {![file isdirectory $tmpPjtDir]} {
		#	tk_messageBox -message "Entered path for project is not a Directory" -icon error
		#	focus .newprj
		#	return
		#}
		$Editor::projMenu add command -label "Close Project" -command "closeproject" 
		$updatetree itemconfigure PjtName -text $tmpPjtName
		catch {$updatetree delete MN-$mnCount}
		$updatetree insert end PjtName MN-$mnCount -text "openPOWERLINK MN" -open 1 -image [Bitmap::get mn]
		if {$conf=="off"} {
			$updatetree insert end MN-$mnCount OBD-$mnCount -text "OBD" -open 1 -image [Bitmap::get pdo]
			Import OBD-$mnCount $tmpImpDir mn 1
		}
		destroy .newprj
	}
	button $frame1.bt_cancel -text Cancel -command { 
		destroy .newprj
	}

	grid config $winNewProj.l_empty -row 0 -column 0 
	
	grid config $titleFrame1 -row 1 -column 0 -sticky "news" -ipadx 10 -padx 10 -ipady 10
	#grid config $winNewProj.l_empty1 -row 2 -column 0 
	#grid config $titleInnerFrame1.l_empty2 -row 0 -column 0 
	grid config $titleInnerFrame1.l_pjname -row 1 -column 0 
	grid config $titleInnerFrame1.en_pjname -row 1 -column 1 -sticky "w"
	grid config $titleInnerFrame1.l_pjpath -row 2 -column 0 
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

	centerW $winNewProj
}

#######################################################################
# proc closeproject
# Saves the project if user selects the clears the structure
########################################################################

proc closeproject {} {
	global PjtDir
	global PjtName
	if {$PjtDir == "" || $PjtDir == "None"} {
		conPuts "No Project Selected" error
		return
	} else {	
	set result [tk_messageBox -message "Save Project $PjtName ?" -type yesnocancel -icon question -title 			"Question"]
   		 switch -- $result {
   		     yes {			 
   		         saveproject
   		     }
   		     no  {conPuts "Project $PjtName not saved" info}
   		     cancel {
				conPuts "Exit Canceled" info
				return}
   		}	
	global updatetree
	#Editor::tselectObject "TargetConfig"
	#Editor::closeFile
	# Delete all the records
	#struct::record delete record recProjectDetail
	#struct::record delete record recTestGroup
	#struct::record delete record recTestCase
	#struct::record delete record recProfile
	# Delete the Tree
	$updatetree delete PjtName
	$updatetree insert end root PjtName -text "POWERLINK Network" -open 1 -image [Bitmap::get network]
	#$updatetree itemconfigure PjtName -text "POWERLINK Network"
	#catch {$updatetree delete MN-$mnCount}

	#set PjtDir None
		
	##################################################################
  	### Reading Datas from XML File
    	##################################################################
   	#readxml $filename
    	##################################################################
	#InsertTree
	#Editor::tselectObject "TargetConfig"
	}
}
#######################################################################
# proc saveProjectAsWindow
#
########################################################################
proc ImportProgress {stat} {

global impPro

	if {$stat=="start"} {
		set winImpoProg .impoProg
		catch "destroy $winImpoProg"
		toplevel $winImpoProg
		wm title     $winImpoProg	"Project Wizard"
		wm resizable $winImpoProg 0 0
		wm transient $winImpoProg .
		wm deiconify $winImpoProg
		#wm minsize   $winImpoProg 50 200
		grab $winImpoProg
		ProgressBar $winImpoProg.prog -orient horizontal -width 200 -maximum 100 -height 10 -variable impPro -type infinite -bg white -fg blue
		grid config $winImpoProg.prog -row 0 -column 0 -padx 10 -pady 10
		#$winImpoProg.prog start
	} elseif {$stat=="stop" } { 
		#$winImpoProg.prog stop		
		destroy .impoProg
	} elseif {$stat=="incr"} {
		incr impPro
		after 1000
		ImportProgress incr
	}


}