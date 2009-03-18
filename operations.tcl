###############################################################################################
#
#
# NAME:     operations.tcl
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
#  Description:  Contains the procedures for Open Configurator
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
#source $RootDir/windows.tcl
#source $RootDir/validation.tcl

##
# For Tablelist Package
##
set path_to_Tablelist ./tablelist4.10
lappend auto_path $path_to_Tablelist

package require Tablelist
package require Thread

tsv::set application main [thread::id]
#puts ""
tsv::set application importProgress [thread::create -joinable {

	package require Tk 8.5
	#puts "In thread tkpath->$tkpath"
	set RootDir [pwd]
	set path_to_BWidget [file join $RootDir BWidget-1.2.1]
	lappend auto_path $path_to_BWidget
	package require -exact BWidget 1.2.1
	source [file join $RootDir windows.tcl]

	wm withdraw .
	if {"$tcl_platform(platform)" != "windows"} {
		. config -bg #d7d5d3
	}
	wm protocol . WM_DELETE_WINDOW dont_exit
	wm title . "progress"
	BWidget::place . 0 0 center
	update idletasks

	proc StartProgress {} {
		puts "invoked thread start progress"
		ImportProgress start
		after 1
		puts "StartProgress called"
	}
	proc StopProgress {} {
		ImportProgress stop
	}
	proc exit_thread {} {
		wm protocol . WM_DELETE_WINDOW ""
	}
	proc dont_exit {} {
		return
	}
	thread::wait
}]


set dir [file dirname [info script]]
source [file join $dir option.tcl]

global PjtDir 
global PjtName

set status_run 0
set cnCount 0
set mnCount 0
set nodeIdList ""
set savedValueList ""
set nodeSelect ""
set lastXD ""
set lastOpenPjt ""
set status_save 0 ; #if zero no need to save
ResetPromptFlag ; #set chkPrompt 0 ;  #if zero values are not saved prompt message used for PROMPT mode
#set ra_proj 2 ; # TODO TEMPORARY FIX
#set ra_auto 0 ; # TODO TEMPORARY FIX
###############################################################################################

namespace eval Editor {
    	variable initDone 0
    	#variable _wfont
    	variable notebook
    	variable list_notebook
    	variable con_notebook
    	variable pw1
    	variable pw2
    	#variable procWindow
    	#variable markWindow
    	variable mainframe
    	variable status
    	variable prgtext
    	variable prgindic
    	#variable font
    	#variable font_name
    	#variable Font_var
    	#variable FontSize_var
    	variable toolbar1  1
    	variable showConsoleWindow 1
    	variable sortProcs 1
    	variable showProc 1
    	#variable checkNestedProc 1
    	variable showProcWindow 1
    	variable current
    	variable last
    	#variable text_win
    	#variable index_counter 0
    	#variable index
    	#variable slaves
    	#variable startTime [clock seconds]
    	#variable options
    	#variable lineNo
    	#variable lineEntryCombo
    	#variable toolbarButtons
    	#variable searchResults
    	#variable procMarks
    	variable mnMenu
    	variable cnMenu
    	variable projMenu    
    	variable obdMenu    
    	variable idxMenu    
    	variable mnCount
    	variable cnCount

}

################################################################################################
#proc Editor::aboutBox
#Input       : -
#Output      : -
#Description : Creates the GUI displaying about application
################################################################################################
proc Editor::aboutBox {} {\
    	set aboutWindow .about
    	catch "destroy $aboutWindow"
    	toplevel $aboutWindow
    	wm resizable $aboutWindow 0 0
    	wm transient $aboutWindow .
    	wm deiconify $aboutWindow
    	grab $aboutWindow
    	wm title	 $aboutWindow	"About"
    	wm protocol $aboutWindow WM_DELETE_WINDOW "destroy $aboutWindow"
    	label $aboutWindow.l_msg -image [Bitmap::get info] -compound left -text "\n          openCONFIGURATOR Tool\n                    Designed by\n                        Kalycito\nwww.kalycito.com\n"
    	button $aboutWindow.bt_ok -text Ok -width 8 -command "destroy $aboutWindow"
    	grid config $aboutWindow.l_msg -row 0 -column 0 
    	grid config $aboutWindow.bt_ok -row 1 -column 0
    	bind $aboutWindow <KeyPress-Return> "destroy $aboutWindow"
    	focus $aboutWindow.bt_ok
    	centerW .about
}

################################################################################################
#proc centerW
#Input       : windows
#Output      : -
#Description : Places window in center of screen
################################################################################################
proc centerW w {
    	BWidget::place $w 0 0 center
}

################################################################################################
#proc Editor::RunStatusInfo
#Input       : -
#Output      : -
#Description : Displays message when user interrupts a run in pprogress
################################################################################################
proc Editor::RunStatusInfo {} {\

    	option add *Font {helvetica 10 normal}
    	tk_messageBox -message \
    		"A Run is in progress" \
   	 	-type ok \
   	 	-title {Information} \
    	 	-icon info -parent .
}

################################################################################################
#proc Editor::getWindowPositions
#Input       : -
#Output      : -
#Description : Stores the size of various window in application
################################################################################################
proc Editor::getWindowPositions {} {
    	global EditorData
    	variable pw1
    	variable pw2
    	variable notebook
    	variable list_notebook
    	variable con_notebook
    	variable current
    
    	update idletasks
    
    
    	set EditorData(options,notebookWidth) [winfo width $notebook]
    	set EditorData(options,notebookHeight) [winfo height $notebook]
    	set EditorData(options,list_notebookWidth) [winfo width $list_notebook]
    	set EditorData(options,list_notebookHeight) [winfo height $list_notebook]
    	set EditorData(options,con_notebookWidth) [winfo width $con_notebook]
    	set EditorData(options,con_notebookHeight) [winfo height $con_notebook]
   	 #    get position of mainWindow
    	set EditorData(options,mainWinSize) [wm geom .]
}

################################################################################################
#proc Editor::restoreWindowPositions
#Input       : -
#Output      : -
#Description : Restores the size of various window in application
################################################################################################
proc Editor::restoreWindowPositions {} {
    	global EditorData

    	variable pw1
    	variable pw2
    	variable notebook
    	variable list_notebook
    	variable con_notebook
    
    	$notebook configure -width $EditorData(options,notebookWidth)
    	$notebook configure -height $EditorData(options,notebookHeight)
    	$list_notebook configure -width $EditorData(options,list_notebookWidth)
    	$list_notebook configure -height $EditorData(options,list_notebookHeight)
    	$con_notebook configure -width $EditorData(options,con_notebookWidth)
    	$con_notebook configure -height $EditorData(options,con_notebookHeight)
    	showConsole $EditorData(options,showConsole)
    	showTreeWin $EditorData(options,showTree)
}

################################################################################################
#proc Editor::tselect
#Input       : node
#Output      : -
#Description : Selects a node in tree when clicked
################################################################################################
proc Editor::tselect {node} {
   	variable treeWindow
	$treeWindow selection clear
	$treeWindow selection set $node 
}

################################################################################################
#proc Editor::tselectright
#Input       : x position, y position, node
#Output      : -
#Description : Popsup corresponding menu when node in tree is right clicked
################################################################################################
proc Editor::tselectright {x y node} {
   	variable treeWindow
	$treeWindow selection clear
	$treeWindow selection set $node 
	set CurrentNode $node
	if { [string match "PjtName" $node] == 1 } {
		tk_popup $Editor::projMenu $x $y 
	} elseif { [string match "MN-*" $node] == 1 } {
		tk_popup $Editor::mnMenu $x $y	
	} elseif { [string match "CN-*" $node] == 1 } { 
		tk_popup $Editor::cnMenu $x $y 
	} elseif { [string match "OBD-*" $node] == 1 } { 
		tk_popup $Editor::obdMenu $x $y	
	} elseif { [string match "PDO-*" $node] == 1 } { 
		tk_popup $Editor::pdoMenu $x $y	
	} elseif {[string match "IndexValue-*" $node] == 1 || [string match "*PdoIndexValue-*" $node] == 1} { 
		tk_popup $Editor::idxMenu $x $y		
	} elseif {[string match "SubIndexValue-*" $node] == 1 || [string match "*PdoSubIndexValue-*" $node] == 1} { 
		tk_popup $Editor::sidxMenu $x $y	
	} else {
		return 
	}   
}

################################################################################################
#proc Editor::showConsole
#Input       : show
#Output      : -
#Description : Displays or not Console window according to show
################################################################################################
proc Editor::showConsole {show} {
    variable con_notebook
    
    set win [winfo parent $con_notebook]
    set win [winfo parent $win]
    set panedWin [winfo parent $win]
    update idletasks
    if {$show} {
        grid configure $panedWin.f0 -rowspan 1
        grid $panedWin.sash1
        grid $win
        grid rowconfigure $panedWin 2 -minsize 100
    } else  {
        grid remove $win
        grid remove $panedWin.sash1
        grid configure $panedWin.f0 -rowspan 3
    }
}

################################################################################################
#proc Editor::showTreeWin
#Input       : show
#Output      : -
#Description : Displays or not Tree window according to show
################################################################################################
proc Editor::showTreeWin {show} {
    variable list_notebook
    
    set win [winfo parent $list_notebook]
    set win [winfo parent $win]
    set panedWin [winfo parent $win]
    update idletasks
    #puts show->$show
    if {$show} {
        grid configure $panedWin.f1 -column 2 -columnspan 1
        grid $panedWin.sash1
        grid $win
        grid columnconfigure $panedWin 0 -minsize 250
    } else  {
        grid remove $win
        grid remove $panedWin.sash1
        grid configure $panedWin.f1 -column 0 -columnspan 3
    }
}

################################################################################################
#proc Editor::showSolelyConsole
#Input       : show
#Output      : -
#Description : Displays Console window alone or not
################################################################################################
proc Editor::showSolelyConsole {show} {
    variable notebook
    
    set win [winfo parent $notebook]
    set win [winfo parent $win]
    set panedWin [winfo parent $win]
    set frame [winfo parent $panedWin]
    set frame [winfo parent $frame]
    set panedWin [winfo parent $frame]
    update idletasks
    
    if {$show} {
        grid remove $frame
        grid remove $panedWin.sash1
        grid configure $panedWin.f1 -rowspan 3
        grid rowconfigure $panedWin 2 -weight 100
        grid rowconfigure $panedWin 2 -minsize 100
    } else  {
        grid configure $panedWin.f1 -rowspan 1
        grid $panedWin.sash1
        grid $frame
        grid rowconfigure $panedWin 2 -minsize 100
    }
}

################################################################################################
#proc Editor::exit_app
#Input       : -
#Output      : -
#Description : Called when application is exited
################################################################################################
proc Editor::exit_app {} {
    global EditorData
    global RootDir
    variable notebook
    variable current
    variable index
    variable text_win

    global PjtDir
    global PjtName
    global status_run
    global status_save

    set EditorData(options,History) "$PjtDir"
    if { $status_run == 1 } {
	Editor::RunStatusInfo
	return
    }
    if {$PjtDir != ""} {

	#check whether project has changed
	if {$status_save} {
		#Prompt for Saving the Existing Project
		set result [tk_messageBox -message "Save Project $PjtName ?" -type yesnocancel -icon question -title "Question" -parent .]
   		 switch -- $result {
   		     yes {			 
   		             Saveproject
			     conPuts "Project $PjtName is saved" info
   		     }
   		     no  {conPuts "Project $PjtName not saved" info
		     }
   		     cancel {
			     conPuts "Exit Canceled" info
			     return
		     }
   		}
	}
        CloseProject
    }
    thread::send [tsv::get application importProgress] "exit_thread"
    exit
}

################################################################################################
#proc OpenProject
#Input       : -
#Output      : -
#Description : Opens an already existing project prompts to save the current project
################################################################################################
proc openproject { } {
	global PjtDir
	global PjtName
	global updatetree
	global nodeIdList
	global mnCount
	global cnCount	
	global status_run
	global status_save
	global lastOpenPjt
	global defaultPjtDir
	
	if { $status_run == 1 } {
		Editor::RunStatusInfo
		return
	}

	if { $PjtDir != "" } {
		#check whether project has changed
		if {$status_save} {
			#Prompt for Saving the Existing Project
			set result [tk_messageBox -message "Save Project $PjtName ?" -type yesnocancel -icon question -title "Question" -parent .]
	   		switch -- $result {
	   		     yes {
				#conPuts "Project $PjtName Saved" info
				Saveproject
				}
	   		     no  {
				conPuts "Project $PjtName Not Saved" info
				}
	   		     cancel {
				conPuts "Open Project Canceled" info
				return
				}
	   		}
		}
	}

	
	set types {
		{"All Project Files"     {*.oct } }
	}


	#if { ![file isdirectory $lastOpenPjt] && [file exists $lastOpenPjt] } {
	#	set lastOpenFile [file tail $lastOpenPjt]
	#	set lastOpenDir [file dirname $lastOpenPjt]
	#	set projectfilename [tk_getOpenFile -title "Open Project" -initialdir $lastOpenDir -initialfile $lastOpenFile -filetypes $types -parent .]
	#} else {
	#	set projectfilename [tk_getOpenFile -title "Open Project" -initialdir $defaultPjtDir -filetypes $types -parent .]
	#}
	
	# Validate filename
	set projectfilename [tk_getOpenFile -filetypes $types -parent .]
        if {$projectfilename == ""} {
                return
        }
	
	set lastOpenPjt $projectfilename
	
	#set tmpsplit [file split $projectfilename ]
	set tempPjtName [file tail $projectfilename]
	#puts "Project name->$PjtName"
	set ext [file extension $projectfilename]
        if {[string compare $ext ".oct"]} {
	    set PjtDir ""
	    tk_messageBox -message "Extension $ext not supported" -title "Open Project Error" -icon error -parent .
	    return
	}
	
	_openproject $projectfilename
	##CloseProject is called to delete node and insert tree
	#CloseProject
	#
	#set tempPjtDir [file dirname $projectfilename]
	#puts "\n\nPjtDir->$tempPjtDir PjtName->$tempPjtName \n\n"
	#
	#thread::send [tsv::get application importProgress] "StartProgress"
	##API for open project
	##ocfmRetCode OpenProject(char* PjtPath, char* projectXmlFileName);
	#puts "OpenProject $tempPjtDir $tempPjtName "
	#set catchErrCode [OpenProject $tempPjtDir $tempPjtName ]
	#set ErrCode [ocfmRetCode_code_get $catchErrCode]
	##puts "ErrCode:$ErrCode"
	#if { $ErrCode != 0 } {
	#	if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
	#		tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
	#	} else {
	#		tk_messageBox -message "Unknown Error" -title Warning -icon warning
	#		puts "Unknown Error ->[ocfmRetCode_errorString_get $catchErrCode]"
	#	}
	#	thread::send [tsv::set application importProgress] "StopProgress"
	#	return
	#} else {
	#	#conPuts "ReImported $tmpImpDir for Node ID:$nodeId"
	#}
	#set PjtDir $tempPjtDir
	#set PjtName $tempPjtName
	#
	#
	#RePopulate $PjtDir [string range $PjtName 0 end-[string length [file extension $PjtName]]]
	#
	#thread::send [tsv::set application importProgress] "StopProgress"

}

proc _openproject {projectfilename} {
	global PjtDir
	global PjtName
	global ra_proj
	global ra_auto
	
	
	#CloseProject is called to delete node and insert tree
	CloseProject

	set tempPjtDir [file dirname $projectfilename]
	set tempPjtName [file tail $projectfilename]
	puts "\n\nPjtDir->$tempPjtDir PjtName->$tempPjtName \n\n"

	thread::send [tsv::get application importProgress] "StartProgress"
	#API for open project
	#ocfmRetCode OpenProject(char* PjtPath, char* projectXmlFileName);
	set catchErrCode [OpenProject $tempPjtDir $tempPjtName]
	set ErrCode [ocfmRetCode_code_get $catchErrCode]
	#puts "ErrCode:$ErrCode"
	if { $ErrCode != 0 } {
		if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -parent . -title Warning -icon warning
		} else {
			tk_messageBox -message "Unknown Error" -parent . -title Warning -icon warning
                        puts "Unknown Error ->[ocfmRetCode_errorString_get $catchErrCode]"
		}
		thread::send -async [tsv::set application importProgress] "StopProgress"
		return
	} else {
		#conPuts "ReImported $tmpImpDir for Node ID:$nodeId"
	}
	set PjtDir $tempPjtDir
	set PjtName $tempPjtName
	
	set result [ RePopulate $PjtDir [string range $PjtName 0 end-[string length [file extension $PjtName]]] ]
	thread::send [tsv::set application importProgress] "StopProgress"
	
	 #ocfmRetCode GetProjectSettings(EAutoGenerate autoGen, EAutoSave autoSave)
	set ra_autop [new_EAutoGeneratep]
	set ra_projp [new_EAutoSavep]

	set catchErrCode [GetProjectSettings $ra_autop $ra_projp]
	set ErrCode [ocfmRetCode_code_get $catchErrCode]
	puts "ErrCode:$ErrCode"
	if { $ErrCode != 0 } {
		if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]\nAuto generate is set to \"No\" and project Setting set to \"Discard\" " -title Warning -icon warning
		} else {
			 tk_messageBox -message "Unknown Error\nAuto generate is set to \"No\" and project Setting set to \"Discard\" " -title Warning -icon warning
			puts "Unknown Error ->[ocfmRetCode_errorString_get $catchErrCode]\n"
		}
		set ra_auto 0
		set ra_proj 2
	} else {
		set ra_auto [EAutoGeneratep_value $ra_autop]
		set ra_proj [EAutoSavep_value $ra_projp]
	}
	
	
	
	ClearMsgs
	if { $result == 1 } {
		conPuts "Project [file join $PjtDir $PjtName] is successfully opened"
	} else {
		errorPuts "Error in opening project [file join $PjtDir $PjtName]"
	}
	
}

proc RePopulate { PjtDir PjtName } {
	global updatetree
	global nodeIdList
	global mnCount
	global cnCount	

	set mnCount 1
	set cnCount 1

	catch {$updatetree delete PjtName}
	$updatetree insert end root PjtName -text $PjtName -open 1 -image [Bitmap::get network]
	
	set count [new_intp]
	set catchErrCode [GetNodeCount 240 $count]
	set ErrCode [ocfmRetCode_code_get $catchErrCode]
	#puts "CN count:[intp_value $count]....ErrCode->$ErrCode"
	if { $ErrCode == 0 } {
		set nodeCount [intp_value $count]
		#set nodeType 0
		puts "nodeCount->$nodeCount"
		for {set inc 0} {$inc < $nodeCount} {incr inc} {
			#API
			#ocfmRetCode GetNodeAttributesbyNodePos(int NodePos, ENodeType* NodeType, int* Out_NodeID, char* Out_NodeName);
			set tmp_nodeId [new_intp]			
			#set nodeType [new_intp]
			#set nodeName [new_charp]
			set catchErrCode [GetNodeAttributesbyNodePos $inc $tmp_nodeId]
			#puts "catchErrCode->$catchErrCode"
			set ErrCode [ocfmRetCode_code_get [lindex $catchErrCode 0]]

			#set nodeType 1			
		
			#puts "ErrCode:$ErrCode "
			if { $ErrCode == 0 } {
				set nodeId [intp_value $tmp_nodeId]
				set nodeName [lindex $catchErrCode 1]
				#set nodeName [charp_value $nodeName]
				#puts "nodeId->$nodeId..nodeName->$nodeName.."
				if {$nodeId == 240} {
					set nodeType 0
					$updatetree insert end PjtName MN-$mnCount -text "openPOWERLINK_MN(240)" -open 1 -image [Bitmap::get mn]
					$updatetree insert end MN-$mnCount OBD-$mnCount-1 -text "OBD" -open 0 -image [Bitmap::get pdo]	
					set node OBD-$mnCount-1	
				} else {
					set nodeType 1
					set child [$updatetree insert end MN-$mnCount CN-$mnCount-$cnCount -text "$nodeName\($nodeId\)" -open 0 -image [Bitmap::get cn]]
					set node CN-$mnCount-$cnCount
				}
puts "node->$node"
				if { [ catch { Import $node $nodeType $nodeId } ] } {
					#some error has occured
					CloseProject
					return 0
				}
				incr cnCount
				lappend nodeIdList $nodeId 
			} else {
				#some error has occured
				#continue
				CloseProject
				return 0
			}
		}

		if { [$Editor::projMenu index 3] != "3" } {
			$Editor::projMenu insert 3 command -label "Close Project" -command "_CloseProject"
		}
		if { [$Editor::projMenu index 4] != "4" } {
			$Editor::projMenu insert 4 command -label "Properties" -command "PropertiesWindow"
		}
		puts nodeIdList->$nodeIdList

	} else {
		errorPuts "MN node is not found" error
	}

	return 1
}

################################################################################################
#proc Editor::create
#Input       : -
#Output      : -
#Description : Creates the GUI for application when launched
################################################################################################
proc Editor::create { } {
    	global tcl_platform
    	global clock_var
    	global EditorData
    	global RootDir
    	global f0
    	global f1
    	global f2
	global LastTableFocus
	
    	variable bb_connect
   	variable mainframe
    	variable _wfont
    	variable notebook
    	variable list_notebook
    	variable con_notebook
    	variable pw2
    	variable pw1
    	variable procWindow
    	variable treeWindow
    	variable markWindow
    	variable mainframe
    	variable font
    	variable prgtext
    	variable prgindic
    	variable status
    	variable current
    	variable clock_label
    	variable defaultFile
    	variable defaultProjectFile
    	variable Font_var
    	variable FontSize_var
    	variable options
   
    	variable toolbarButtons
    	variable cnMenu
    	variable mnMenu
    	variable IndexaddMenu
    	variable obdMenu
    	variable pdoMenu
    	variable idxMenu
    	variable sidxMenu	
    
    
	set LastTableFocus ""
    
	set result [catch {source [file join $RootDir plk_configtool.cfg]} info]
	variable configError $result
   
	set prgtext "Please wait while loading ..."
	set prgindic -1
	_create_intro
	update
	
	# Menu description
	set descmenu {
		"&File" {} {} 0 {           
       			{command "New &Project" {} "New Project" {Ctrl n}  -command { _NewProject } }
			{command "Open Project" {}  "Open Project" {Ctrl o} -command { openproject } }
	        	{command "Save Project" {noFile}  "Save Project" {Ctrl s} -command Saveproject}
	        	{command "Save Project as" {noFile}  "Save Project as" {} -command SaveProjectAsWindow }
			{command "Close Project" {}  "Close Project" {} -command _CloseProject }
	    		{separator}
            		{command "E&xit" {}  "Exit openCONFIGURATOR" {Alt x} -command Editor::exit_app}
        	}
        	"&Project" {} {} 0 {
            		{command "Build Project    F7" {noFile} "Generate CDC and XML" {} -command BuildProject }
            		{command "Clean Project" {noFile} "Clean" {} -command CleanProject }
            		{separator}
            		{command "Project Settings" {}  "Project Settings" {} -command ProjectSettingWindow }
        	}
        	"&Actions" all options 0 {
            		{command "Transfer CDC   Ctrl+F5" {noFile} "Transfer CDC" {} -command "TransferCDC 1" }
            		{command "Transfer XAP   Ctrl+F6" {noFile} "Transfer XAP" {} -command "TransferXAP 1" }
	    		{separator}
            		{command "Start MN" {noFile} "Start the Managing Node" {} -command StartStack }
            		{command "Stop MN" {noFile} "Stop the Managing Node" {} -command StopStack }
        	}
        	"&View" all options 0 {
            		{checkbutton "Show Output Console" {all option} "Show Console Window" {}
                		-variable Editor::options(showConsole)
                		-command  {set EditorData(options,showConsole) $Editor::options(showConsole)
                    			Editor::showConsole $EditorData(options,showConsole)
                    			update idletasks
                		}
           		}
            		{checkbutton "Show Test Tree Browser" {all option} "Show Code Browser" {}
                		-variable Editor::options(showTree)
                		-command  {set EditorData(options,showTree) $Editor::options(showTree)
                    			Editor::showTreeWin $EditorData(options,showTree)
                    			update idletasks
                		}
            		}
        	}
        	"&Help" {} {} 0 {
	    		{command "How to" {noFile} "How to Manual" {} -command YetToImplement }
	    		{separator}
            		{command "About" {} "About" {F1} -command Editor::aboutBox }
        	}
    	}

	# to select the required check button in View menu
    	set Editor::options(showTree) 1
    	set Editor::options(showConsole) 1
	#shortcut keys for project
	bind . <Key-F7> "BuildProject"
	bind . <Control-Key-F7> "" ; #to prevent BuildProject called
	bind . <Control-Key-F5> "TransferCDC 1"
	bind . <Control-Key-F6> "TransferXAP 1"
	bind . <Control-Key-f> "FindDynWindow"
	bind . <Control-Key-F> "FindDynWindow"
	bind . <KeyPress-Escape> "EscapeTree"
	#bind . <Delete> "puts Delete_key_pressed"
	#############################################################################
	# Menu for the Controlled Nodes
	#############################################################################

	set Editor::cnMenu [menu  .cnMenu -tearoff 0]
	set Editor::IndexaddMenu .cnMenu.indexaddMenu
	#$Editor::cnMenu add command -label "Rename" \
	#	 -command {set cursor [. cget -cursor]
	#		YetToImplement
	#	 }
	
	#$Editor::cnMenu add cascade -label "Add" -menu $Editor::IndexaddMenu
	#menu $Editor::IndexaddMenu -tearoff 0
	#$Editor::IndexaddMenu add command -label "Add Index" -command "AddIndexWindow"
	#$Editor::IndexaddMenu add command -label "Inter CN Communication" -command {InterCNWindow}
	$Editor::cnMenu add command -label "Add Index" -command "AddIndexWindow"
	$Editor::cnMenu add command -label "Import XDC/XDD" -command {ReImport}
	$Editor::cnMenu add separator
	$Editor::cnMenu add command -label "Delete" -command {DeleteTreeNode}
	$Editor::cnMenu add command -label "Properties" -command {PropertiesWindow} ; #commented for this delivery 

	#############################################################################
	# Menu for the Managing Nodes
	#############################################################################
	set Editor::mnMenu [menu  .mnMenu -tearoff 0]
	$Editor::mnMenu add command -label "Add CN" -command "AddCNWindow" 
	$Editor::mnMenu add command -label "Import XDC/XDD" -command "ReImport"
	$Editor::mnMenu add separator
	$Editor::mnMenu add command -label "Auto Generate" -command {AutoGenerateMNOBD} 
	#$Editor::mnMenu add separator
	$Editor::mnMenu add command -label "Delete OBD" -command {DeleteTreeNode}
	$Editor::mnMenu add separator
	$Editor::mnMenu add command -label "Properties" -command {PropertiesWindow}; #commented for this delivery

	#############################################################################
	# Menu for the Project
	#############################################################################

	set Editor::projMenu [menu  .projMenu -tearoff 0]
	#$Editor::projMenu add command -label "Sample Project" -command "YetToImplement" 
	#$Editor::projMenu add command -label "New Project" -command { _NewProject}
	#$Editor::projMenu add command -label "Open Project" -command {openproject}
	$Editor::projMenu insert 0 command -label "Sample Project" -command {
		global RootDir
		set samplePjt [file join $RootDir Sample Sample.oct]
		if {[file exists $samplePjt]} {
			_openproject $samplePjt
		} else {
			errorPuts "Sample project is not present" error	
		}
	} 
	$Editor::projMenu insert 1 command -label "New Project" -command { _NewProject}
	$Editor::projMenu insert 2 command -label "Open Project" -command {openproject} 
	#############################################################################
	# Menu for the object dictionary
	#############################################################################
	set Editor::obdMenu [menu .obdMenu -tearoff 0]
	$Editor::obdMenu add separator 
	$Editor::obdMenu add command -label "Add Index" -command "AddIndexWindow"   
	$Editor::obdMenu add separator  

	#############################################################################
	# Menu for the PDO
	#############################################################################
	set Editor::pdoMenu [menu .pdoMenu -tearoff 0]
	$Editor::pdoMenu add separator 
	$Editor::pdoMenu add command -label "Add PDO" -command "AddPDOWindow"   
	$Editor::pdoMenu add separator  


	#############################################################################
	# Menu for the index
	#############################################################################
	set Editor::idxMenu [menu .idxMenu -tearoff 0]
	$Editor::idxMenu add command -label "Add SubIndex" -command "AddSubIndexWindow"   
	$Editor::idxMenu add separator
	$Editor::idxMenu add command -label "Delete Index" -command {DeleteTreeNode}

	#############################################################################
	# Menu for the subindex
	#############################################################################
	set Editor::sidxMenu [menu .sidxMenu -tearoff 0]
	$Editor::sidxMenu add separator
	$Editor::sidxMenu add command -label "Delete SubIndex" -command {DeleteTreeNode}
	$Editor::sidxMenu add separator

	set Editor::prgindic -1
	set Editor::status ""
	set mainframe [MainFrame::create .mainframe \
	        -menu $descmenu  ]

    	# toolbar 1 creation
	set tb1  [MainFrame::addtoolbar $mainframe]
	pack $tb1 -expand yes -fill x
	set bbox [ButtonBox::create $tb1.bbox1 -spacing 0 -padx 1 -pady 1]
	set toolbarButtons(new) [ButtonBox::add $bbox -image [Bitmap::get page_white] \
	        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	        -helptext "Create new project" -command { _NewProject }]
	set toolbarButtons(save) [ButtonBox::add $bbox -image [Bitmap::get disk] \
	        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	        -helptext "Save Project" -command Saveproject]
	set toolbarButtons(saveAll) [ButtonBox::add $bbox -image [Bitmap::get disk_multiple] \
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Save Project as" -command SaveProjectAsWindow]    
    	set toolbarButtons(openproject) [ButtonBox::add $bbox -image [Bitmap::get openfolder] \
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Open Project" -command openproject]
        
    	pack $bbox -side left -anchor w
	set prgindic 0
	set sep0 [Separator::create $tb1.sep0 -orient vertical]
	pack $sep0 -side left -fill y -padx 4 -anchor w
	

	



	set bbox [ButtonBox::create $tb1.bbox5 -spacing 1 -padx 1 -pady 1]
	pack $bbox -side left -anchor w
	set bb_build [ButtonBox::add $bbox -image [Bitmap::get build]\
	        -height 21\
	        -width 21\
	        -helptype balloon\
	        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	        -helptext "Build Project"\
		-command "BuildProject"]
	pack $bb_build -side left -padx 4
	#set bb_rebuild [ButtonBox::add $bbox -image [Bitmap::get rebuild]\
	#    	-height 21\
	#        -width 21\
	#        -helptype balloon\
	 #       -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	 #       -helptext "Rebuild Project"\
	#	 -command "YetToImplement"]
	#pack $bb_rebuild -side left -padx 4
	set bb_clean [ButtonBox::add $bbox -image [Bitmap::get clean]\
	    	-height 21\
    		-width 21\
	        -helptype balloon\
	        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	        -helptext "clean Project"\
    		-command "CleanProject"]
	pack $bb_clean -side left -padx 4



	set sep2 [Separator::create $tb1.sep2 -orient vertical]
	pack $sep2 -side left -fill y -padx 4 -anchor w

	set bbox [ButtonBox::create $tb1.bbox4 -spacing 1 -padx 1 -pady 1]
	pack $bbox -side left -anchor w
	set bb_cdc [ButtonBox::add $bbox -image [Bitmap::get transfercdc]\
            	-height 21\
            	-width 21\
            	-helptype balloon\
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Transfer CDC"\
    	    	-command "TransferCDC 1"]
	pack $bb_cdc -side left -padx 4
	set bb_xml [ButtonBox::add $bbox -image [Bitmap::get transferxml]\
            	-height 21\
            	-width 21\
            	-helptype balloon\
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Transfer XAP"\
    	    	-command "TransferXAP 1"]
	pack $bb_xml -side left -padx 4
	

	set sep4 [Separator::create $tb1.sep4 -orient vertical]
	pack $sep4 -side left -fill y -padx 4 -anchor w 

		set bbox [ButtonBox::create $tb1.bbox2 -spacing 0 -padx 4 -pady 1]
	set bb_start [ButtonBox::add $bbox -image [Bitmap::get start] \
            	-height 21\
            	-width 21\
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Start stack" -command StartStack]
	pack $bb_start -side left -padx 4
	pack $bbox -side left -anchor w -padx 2
	
	set bbox [ButtonBox::create $tb1.bbox3 -spacing 1 -padx 1 -pady 1]
	
	set bb_stop [ButtonBox::add $bbox -image [Bitmap::get stop]\
            	-height 21\
            	-width 21\
            	-helptype balloon\
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Stop stack"\
	   	-command StopStack]
	pack $bb_stop -side left -padx 4

	#set bb_reconfig [ButtonBox::add $bbox -image [Bitmap::get reconfig]\
        #    	-height 21\
        #   	-width 21\
        #    	-helptype balloon\
        #    	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        #    	-helptext "Reconfigure stack"\
    	#    	-command "YetToImplement"]
	#pack $bb_reconfig -side left -padx 4
	pack $bbox -side left -anchor w

	
	set sep1 [Separator::create $tb1.sep1 -orient vertical]
	pack $sep1 -side left -fill y -padx 4 -anchor w
	



	set bbox [ButtonBox::create $tb1.bbox7 -spacing 1 -padx 1 -pady 1]
	pack $bbox -side right
	set bb_kaly [ButtonBox::add $bbox -image [Bitmap::get kalycito_icon]\
	        -height 21\
	        -width 40\
	        -helptype balloon\
	        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	        -helptext "kalycito" \
	        -command Editor::aboutBox ]
	pack $bb_kaly -side right  -padx 4


   
	$Editor::mainframe showtoolbar 0 $Editor::toolbar1
	set temp [MainFrame::addindicator $mainframe -textvariable Editor::connect_status ]
	$temp configure -relief flat 
	# NoteBook creation
	set frame [$mainframe getframe]
	
	set pw1 [PanedWindow::create $frame.pw1 -side left]
	set pane [PanedWindow::add $pw1 ]
	set pw2 [PanedWindow::create $pane.pw2 -side top]
	#set pw3 [PanedWindow::create $pane.pw3 -side right]	 ; #newly added
	#pack $pw3 -expand yes -fill both ; #newly added

	set pane1 [PanedWindow::add $pw2 -minsize 250]
	set pane2 [PanedWindow::add $pw2 -minsize 100]
	#set pane2 [PanedWindow::add $pw3 -minsize 100] ; #newly added
	set pane3 [PanedWindow::add $pw1 -minsize 100]

#set testframe [frame $pane2.testframe -bg blue] ; #added for test
#pack $testframe -expand yes -fill both ; #added for test

	set list_notebook [NoteBook::create $pane1.nb]
	set notebook [NoteBook::create $pane2.nb]	
	set con_notebook [NoteBook::create $pane3.nb]
	
	set pf1 [EditManager::create_treeWindow $list_notebook]
	set treeWindow $pf1.sw.objTree
	# Binding on tree widget   
	$treeWindow bindText <ButtonPress-1> Editor::SingleClickNode
	$treeWindow bindText <Double-1> Editor::DoubleClickNode
	$treeWindow bindText <ButtonPress-3> {Editor::tselectright %X %Y}
	if {"$tcl_platform(platform)" == "unix"} {
		bind $treeWindow <Button-4> {global updatetree ; $updatetree yview scroll -5 units}
		bind $treeWindow <Button-5> {global updatetree ; $updatetree yview scroll 5 units}
	}


	bind $treeWindow <Enter> { BindTree }
	bind $treeWindow <Leave> { UnbindTree }
	
	#bind . <Configure> {puts "\nCurrent window path ->%W\nFocus window [focus]"}

          
	global EditorData
	global PjtDir
	set PjtDir $EditorData(options,History)



	set cf0 [EditManager::create_conWindow $con_notebook "Console" 1]
	set cf1 [EditManager::create_conWindow $con_notebook "Error" 2]
	set cf2 [EditManager::create_conWindow $con_notebook "Warning" 3]

	NoteBook::compute_size $con_notebook
	pack $con_notebook -side bottom -fill both -expand yes -padx 4 -pady 4

	pack $pw1 -fill both -expand yes
	NoteBook::compute_size $list_notebook
	$list_notebook configure -width 250
	pack $list_notebook -side left -fill both -expand yes -padx 2 -pady 4
	catch {font create TkFixedFont -family Courier -size -12 -weight bold}

	set alignFrame [frame $pane2.alignframe -width 750]
	pack $alignFrame -expand yes -fill both

	set f0 [EditManager::create_tab $alignFrame "Index" ind ]
	set f1 [EditManager::create_tab $alignFrame "Sub index" sub ]
	#set f2 [EditManager::create_table $notebook "PDO mapping" "pdo"]
	set f2 [EditManager::create_table $alignFrame "PDO mapping" "pdo"]
	[lindex $f2 1] columnconfigure 0 -background #e0e8f0 -width 6 -sortmode integer
	[lindex $f2 1] columnconfigure 1 -background #e0e8f0 -width 14 
	[lindex $f2 1] columnconfigure 2 -background #e0e8f0 -width 11
	[lindex $f2 1] columnconfigure 3 -background #e0e8f0 -width 11
	[lindex $f2 1] columnconfigure 4 -background #e0e8f0 -width 11
	[lindex $f2 1] columnconfigure 5 -background #e0e8f0 -width 11
	
	bind [lindex $f2 1] <Enter> {
		#puts "enter tablelist LastTableFocus ->$LastTableFocus"
		global LastTableFocus
		if { [ winfo exists $LastTableFocus ] && [ string match "[lindex $f2 1]*" $LastTableFocus ] } {
			focus $LastTableFocus
		} else {
			focus [lindex $f2 1]
		}
		
		bind . <Motion> {
			global LastTableFocus
			set LastTableFocus [focus]
		}
	}
	
	bind [lindex $f2 1] <Leave> {
		bind . <Motion> {}
		global LastTableFocus
		global treeFrame
		
		if { "$LastTableFocus" == "$treeFrame.en_find" } {
				focus $treeFrame.en_find
		} else {
				focus .
		}
	}
	
	bind [lindex $f2 1] <FocusOut> {
		bind . <Motion> {}
		global LastTableFocus
		set LastTableFocus [focus]
	}
	

	
	#NoteBook::compute_size $notebook
	#$notebook configure -width 750
	#pack $notebook -side left -fill both -expand yes -padx 4 -pady 4


	pack $pw2 -fill both -expand yes

	$list_notebook raise objtree
	$con_notebook raise Console1
	#$notebook raise [lindex $f0 1]

	pack $mainframe -fill both -expand yes
	set prgindic 0
	destroy .intro
	wm protocol . WM_DELETE_WINDOW Editor::exit_app

	if {!$configError} {catch Editor::restoreWindowPositions}
	update idletasks
	return 1
}

################################################################################################
#proc Editor::create_intro
#Input       : -
#Output      : -
#Description : Displays image during launching of application
################################################################################################
proc Editor::_create_intro { } {
	global tcl_platform
	global RootDir
	
	set top [toplevel .intro -relief raised -borderwidth 2]
	
	wm withdraw $top
	wm overrideredirect $top 1
	
	set image [image create photo -file [file join $RootDir Kalycito.gif]]
	set splashscreen  [label $top.x -image $image]
	set frame [frame $splashscreen.f -background white]
	set lab1  [label $frame.lab1 -text "Loading openCONFIGURATOR" -background white -font {times 8}]
	set lab2  [label $frame.lab2 -textvariable Editor::prgtext -background red -font {times 8} -width 35]
	set prg   [ProgressBar $frame.prg -width 50 -height 10 -background  black \
		-variable Editor::prgindic -maximum 10]
	pack $lab1 $lab2 $prg
	place $frame -x 0 -y 0 -anchor nw
	pack $splashscreen
	BWidget::place $top 0 0 center
	wm deiconify $top
}

proc BindTree {} {
	global updatetree
	global tcl_platform
	global f2

	#[lindex $f2 1] configure -takefocus 0

#focus $updatetree ; #temporary fix but not correct

	#set node [$updatetree selection get]
	#puts "BindTree node->$node"
	#if { $node == "" || $node == "root" } {

	#} else {
	#	$updatetree see $node
	#	FindSpace::OpenParent $updatetree $node
	#}
	bind . <Delete> DeleteTreeNode 
	bind . <Up> ArrowUp 
	bind . <Down> ArrowDown
	bind . <Left> ArrowLeft
	bind . <Right> ArrowRight
	if {"$tcl_platform(platform)" == "windows"} {
		bind . <MouseWheel> {global updatetree; $updatetree yview scroll [expr -%D/24] units }
	}

	#$updatetree configure -selectbackground #678db2 -relief sunken 
	$updatetree configure -selectbackground #678db2
}

proc UnbindTree {} {
	global tcl_platform
	global updatetree

	bind . <Delete> "" 
	bind . <Up> ""
	bind . <Down> ""
	bind . <Left> ""
	bind . <Right> ""
	if {"$tcl_platform(platform)" == "windows"} {
		bind . <MouseWheel> ""
	}

	#$updatetree configure -selectbackground gray -relief ridge 
	$updatetree configure -selectbackground gray
}
################################################################################################
#proc Editor::SingleClickNode
#Input       : node
#Output      : -
#Description : Displays required tabs when corresponding nodes are clicked
################################################################################################
proc Editor::SingleClickNode {node} {
	global updatetree
	global nodeIdList
	global f0
	global f1
	global f2
	global nodeObj
	global nodeSelect
	global nodeIdList
	global savedValueList
    	global lastConv
	global populatedPDOList
	global userPrefList
	global LastTableFocus
	global chkPrompt
	variable notebook

	global  ra_proj
	global indexSaveBtn
	global subindexSaveBtn
	global tableSaveBtn

#conPuts "$node"
#puts "ra_proj->$ra_proj"
	
	
	if { $nodeSelect == "" || ![$updatetree exists $nodeSelect] || [string match "root" $nodeSelect] || [string match "PjtName" $nodeSelect] || [string match "MN-*" $nodeSelect] || [string match "OBD-*" $nodeSelect] || [string match "CN-*" $nodeSelect] || [string match "PDO-*" $nodeSelect] } {
		#should not check for project settings option
	} else {
		if { $ra_proj == "0"} {
			if { [string match "TPDO-*" $nodeSelect] || [string match "RPDO-*" $nodeSelect] } {
				$tableSaveBtn invoke
			} elseif { [string match "*SubIndex*" $nodeSelect] } {
				$subindexSaveBtn invoke
			} elseif { [string match "*Index*" $nodeSelect] } {	
				$indexSaveBtn invoke
			} else {
				#must be root, PjtName, MN, OBD or CN
			}
		} elseif { $ra_proj == "1" } {
			if { $chkPrompt == 1 } {
				set result [tk_messageBox -message "Do you want to save ?" -parent . -type yesno -icon question]
				switch -- $result {
					yes {
						#save the value
						if { [string match "TPDO-*" $nodeSelect] || [string match "RPDO-*" $nodeSelect] } {
							$tableSaveBtn invoke
						} elseif { [string match "*SubIndex*" $nodeSelect] } {
							$subindexSaveBtn invoke
						} elseif { [string match "*Index*" $nodeSelect] } {	
							$indexSaveBtn invoke
						} else {
							#must be root, PjtName, MN, OBD or CN
						}
					}
					no  {#continue}
				}
			}
			ResetPromptFlag
			# else it must have been saved or values are not changed
		} elseif { $ra_proj == "2" } {
			
		} else {
			puts "\nInvalid Cond in SingleClickNode ra_proj->$ra_proj !!!\n"
			return
		}
	}

	$updatetree selection set $node
	set nodeSelect $node
	#puts "node====>$node"

	if {[string match "root" $node] || [string match "PjtName" $node] || [string match "MN-*" $node] || [string match "OBD-*" $node] || [string match "CN-*" $node] || [string match "PDO-*" $node]} {
		#$notebook itemconfigure Page1 -state disabled
		#$notebook itemconfigure Page2 -state disabled
		#$notebook itemconfigure Page3 -state disabled
		pack forget [lindex $f0 1]
		pack forget [lindex $f1 1]
		pack forget [lindex $f2 0]
		[lindex $f2 1] cancelediting
		[lindex $f2 1] configure -state disabled
		return
	}

	#getting Id and Type of node
	set result [GetNodeIdType $node]
	if {$result == ""} {
		#the node is not an index, subindex, TPDO or RPDO do nothing
		return
	} else {
		# it is index or subindex
		set nodeId [lindex $result 0]
		set nodeType [lindex $result 1]
	}

	set nodePos [new_intp]
	puts "IfNodeExists nodeId->$nodeId nodeType->$nodeType nodePos->$nodePos"
	#IfNodeExists API is used to get the nodePosition which is needed for various operation	
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
		#tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
		##tk_messageBox -message "ErrCode : $ErrCode\nExistfFlag : $ExistfFlag" -title Warning -icon warning
		if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -parent . -title Warning -icon warning
		} else {
			tk_messageBox -message "Unknown Error" -parent . -title Warning -icon warning
                        puts "Unknown Error ->[ocfmRetCode_errorString_get $catchErrCode]"
		}
		return
	}

	if {[string match "TPDO-*" $node] || [string match "RPDO-*" $node]} {
		
		#the LastTableFocus is cleared just in case of avoiding potential bugs
		set LastTableFocus ""
		
		if {[string match "TPDO-*" $node] } {
			set commParam "18"
			set mappParam "1A"
		} else {
			#must be RPDO
			set commParam "14"
			set mappParam "16"
		}
			set commParamList ""
			set mappParamList ""
		[lindex $f2 1] configure -state normal
		set idx [$updatetree nodes $node]
		foreach tempIdx $idx {
			set indexId [string range [$updatetree itemcget $tempIdx -text] end-4 end-1 ]
			if {[string match "$commParam*" $indexId]} {
				lappend commParamList [list $indexId $tempIdx]
			} elseif {[string match "$mappParam*" $indexId]} {
				lappend mappParamList [list $indexId $tempIdx]
			}
		}
		#puts "commParamList->$commParamList"		
		#puts "mappParamList->$mappParamList"		
		set finalMappList ""
 		set populatedPDOList ""
		
		foreach chk $mappParamList {
			set paramID [string range [lindex $chk 0] end-1 end]
		#puts paramID->$paramID
		#puts "lsearch $commParamList [list $commParam$paramID *]"
			set find [lsearch $commParamList [list $commParam$paramID *]]
			puts "find->$find"
			if { $find != -1 } {
				lappend finalMappList [lindex [lindex $commParamList $find] 1] [lindex $chk 1] 
				lappend populatedPDOList [lindex $chk 1] 
			} else {
				lappend finalMappList [] [lindex $chk 1] 
				lappend populatedPDOList [lindex $chk 1] 				
			}
		}
		#puts "finalMappList->$finalMappList"
		#puts "populatedPDOList->$populatedPDOList"
		set popCount 0 
		[lindex $f2 1] delete 0 end
		
		set commParamValue ""
		for {set count 0} { $count <= [expr [llength $finalMappList]-2] } {incr count 2} {
			set tempIdx [lindex $finalMappList $count]
			puts "tempIdx->$tempIdx"
			#set commParamValue ""
			if { $tempIdx != "" } {
				set indexId [string range [$updatetree itemcget $tempIdx -text] end-4 end-1 ]
				set sidx [$updatetree nodes $tempIdx]
				set commParamValue ""
				lappend commParamValue [] []
				foreach tempSidx $sidx {
					set subIndexId [string range [$updatetree itemcget $tempSidx -text] end-2 end-1 ]
					#puts "commParamValue->$commParamValue subIndexId->$subIndexId"
					if {[string match "01" $subIndexId] == 1 || [string match "02" $subIndexId] == 1} {
						set indexPos [new_intp] ; #newly added
						set subIndexPos [new_intp] ; #newly added
						set catchErrCode [IfSubIndexExists $nodeId $nodeType $indexId $subIndexId $subIndexPos $indexPos] ; #newly added
						set indexPos [intp_value $indexPos] ; #newly added
						set subIndexPos [intp_value $subIndexPos] ; #newly added
						#set tempIndexProp [GetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId 4]
						set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 5 ] ; # 5 is passed to get the actual value
						#puts "tempIndexPropi PDO ->$tempIndexProp"
						set ErrCode [ocfmRetCode_code_get [lindex $tempIndexProp 0] ]		
						if {$ErrCode != 0} {
							puts "ErrCode in singleclick for TDDO and RPDO : $ErrCode"
							#[lindex $f2 1] insert $popCount [list "" "" "" "" "" "" ""]
							#incr popCount 1
							#lappend commParamValue []
							continue	
						}
						set IndexActualValue [lindex $tempIndexProp 1]
						#puts "IndexActualValue->$IndexActualValue"
						if {[string match -nocase "0x*" $IndexActualValue] } {
							#remove appende 0x
							set IndexActualValue [string range $IndexActualValue 2 end]
						} else {
							# no 0x no need to do anything
							#TODO CHECK WHETHER NEED TO CONVERT TO HEX
						}
						if {[string match "01" $subIndexId] == 1} {
							set commParamValue [lreplace $commParamValue 0 0 $IndexActualValue]
							puts "\n in subindexId 01 commParamValue->$commParamValue\n"
						} elseif {[string match "02" $subIndexId] == 1} {
							set commParamValue [lreplace $commParamValue 1 1 $IndexActualValue]
						} else {
							puts "SingleClickNode should not occur subIndexId->$subIndexId"
						}
						#puts "IndexActualValue->$IndexActualValue"
						#set DataSize [string range $IndexActualValue 0 3]
						#set Offset [string range $IndexActualValue 4 7]
						#set Reserved [string range $IndexActualValue 8 9]
						#set listSubIndex [string range $IndexActualValue 10 11]
						#set listIndex [string range $IndexActualValue 12 15]
						#[lindex $f2 1] insert $popCount [list $popCount $IndexActualValue $listIndex $listSubIndex $Reserved $Offset $DataSize]
						#incr popCount 1 
					}
				}
			} else {
				#set commParamValue [list "" "" ]
			}
############################################################################################################
			#puts "commParamValue->$commParamValue"
			set tempIdx [lindex $finalMappList $count+1]
			#puts "tempIdx->$tempIdx"
			set indexId [string range [$updatetree itemcget $tempIdx -text] end-4 end-1 ]
			set sidx [$updatetree nodes $tempIdx]
			foreach tempSidx $sidx { 
				set subIndexId [string range [$updatetree itemcget $tempSidx -text] end-2 end-1 ]
				if {[string match "00" $subIndexId] == 0 } {
					set indexPos [new_intp] ; #newly added
					set subIndexPos [new_intp] ; #newly added
					set catchErrCode [IfSubIndexExists $nodeId $nodeType $indexId $subIndexId $subIndexPos $indexPos] ; #newly added
					set indexPos [intp_value $indexPos] ; #newly added
					set subIndexPos [intp_value $subIndexPos] ; #newly added

					set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 3 ] ; # 3 is passed to get the accesstype
					if {$ErrCode != 0} {
						puts "ErrCode in singleclick for access type TDDO and RPDO : $ErrCode"
						[lindex $f2 1] insert $popCount [list "" "" "" "" "" ""]
						foreach col [list 2 3 4 5 ] {
							[lindex $f2 1] cellconfigure $popCount,$col -editable no
						}
						incr popCount 1 
						continue	
					} 
					set accessType [lindex $tempIndexProp 1]
					
					
					#set tempIndexProp [GetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId 4]
					set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 5 ] ; # 5 is passed to get the actual value
					#puts "tempIndexPropi PDO ->$tempIndexProp"

					set ErrCode [ocfmRetCode_code_get [lindex $tempIndexProp 0] ]		
					if {$ErrCode != 0} {
						puts "ErrCode in singleclick for actual value TDDO and RPDO : $ErrCode"
						[lindex $f2 1] insert $popCount [list "" "" "" "" "" ""]
						foreach col [list 2 3 4 5 ] {
							[lindex $f2 1] cellconfigure $popCount,$col -editable no
						}
						incr popCount 1 
						continue	
					}

					set IndexActualValue [lindex $tempIndexProp 1]
					if {[string match -nocase "0x*" $IndexActualValue] } {
						#remove appende 0x
						set IndexActualValue [string range $IndexActualValue 2 end]
					} else {
						# no 0x no need to do anything
						#TODO CHECK WHETHER NEED TO CONVERT TO HEX
					}
					#puts "IndexActualValue->$IndexActualValue"
					

					
					set length [string range $IndexActualValue 0 3]
					set offset [string range $IndexActualValue 4 7]
					set reserved [string range $IndexActualValue 8 9]
					set listSubIndex [string range $IndexActualValue 10 11]
					set listIndex [string range $IndexActualValue 12 15]
					#[lindex $f2 1] insert $popCount [list $popCount 0x[lindex $commParamValue 0] 0x[lindex $commParamValue 1] 0x$IndexActualValue 0x$listIndex 0x$listSubIndex 0x$reserved 0x$offset 0x$length]
					[lindex $f2 1] insert $popCount [list $popCount 0x[lindex $commParamValue 0] 0x$offset 0x$length 0x$listIndex 0x$listSubIndex ]
					if { $accessType == "ro" || $accessType == "const" } {
						foreach col [list 2 3 4 5 ] {
							[lindex $f2 1] cellconfigure $popCount,$col -editable no
						}							
					} else {
						foreach col [list 2 3 4 5 ] {
							[lindex $f2 1] cellconfigure $popCount,$col -editable yes
						}	
					}
					incr popCount 1 
				}
############################################################################################################
			}
		}
		pack forget [lindex $f0 1]
		pack forget [lindex $f1 1]
		pack [lindex $f2 0] -expand yes -fill both -padx 2 -pady 4
		
		#set chkPrompt 0
		return 
	} else {
	}

	#checking whether value has changed using save. If yes, keep the background
	#of value and name as yellow. If no, white 
	if {[lsearch $savedValueList $node] != -1} {
		set savedBg #fdfdd4
	} else {
		set savedBg white
	}

	if {[string match "*SubIndex*" $node]} {
		set tmpInnerf0 [lindex $f1 2]
		set tmpInnerf1 [lindex $f1 3]
		
		# ocfmRetCode GetSubIndexAttributes(int NodeID, ENodeType NodeType, char* IndexID, char* SubIndexID, EAttributeType AttributeType, char* AttributeValue) ; # dont pass arguments for Attribute value


		set subIndexId [string range [$updatetree itemcget $node -text] end-2 end-1]
		set parent [$updatetree parent $node]
		set indexId [string range [$updatetree itemcget $parent -text] end-4 end-1]

		if { [expr 0x$indexId > 0x1fff] } {
			set entryState normal
			puts "0x$indexId is greater than 0x1fff state->$entryState"
		} else {
			set entryState disabled
			puts "0x$indexId is lesser than 0x1fff state->$entryState"
		}

		#DllExport ocfmRetCode IfSubIndexExists(int NodeID, ENodeType NodeType, char* IndexID, char* SubIndexID, int* SubIndexPos, int* IndexPos);
		set indexPos [new_intp] 
		set subIndexPos [new_intp] 
		set catchErrCode [IfSubIndexExists $nodeId $nodeType $indexId $subIndexId $subIndexPos $indexPos]
		set indexPos [intp_value $indexPos] 
		set subIndexPos [intp_value $subIndexPos] 

		set IndexProp []
		for {set cnt 0 } {$cnt <= 8} {incr cnt} {

			set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos $cnt ]
			set ErrCode [ocfmRetCode_code_get [lindex $tempIndexProp 0]]
			if {$ErrCode == 0} {	
				lappend IndexProp [lindex $tempIndexProp 1]
			} else {
				lappend IndexProp []
			}

	}

		$tmpInnerf0.en_idx1 configure -state normal
		$tmpInnerf0.en_idx1 delete 0 end
		$tmpInnerf0.en_idx1 insert 0 0x$indexId
		$tmpInnerf0.en_idx1 configure -state disabled
		#$tmpInnerf0.en_idx1 configure -state $entryState

		$tmpInnerf0.en_sidx1 configure -state normal
		$tmpInnerf0.en_sidx1 delete 0 end
		$tmpInnerf0.en_sidx1 insert 0 0x$subIndexId
		$tmpInnerf0.en_sidx1 configure -state disabled
		#$tmpInnerf0.en_sidx1 configure -state $entryState

		pack forget [lindex $f0 1]
		pack [lindex $f1 1] -expand yes -fill both -padx 2 -pady 4
		pack forget [lindex $f2 0]
		[lindex $f2 1] cancelediting
		[lindex $f2 1] configure -state disabled
	} elseif {[string match "*Index*" $node]} {
		set tmpInnerf0 [lindex $f0 2]
		set tmpInnerf1 [lindex $f0 3]

		#DllExport ocfmRetCode GetIndexAttributes(int NodeID, ENodeType NodeType, char* IndexID, EAttributeType AttributeType,char* AttributeValue) ; # dont pass arguments for Attribute value
		set indexId [string range [$updatetree itemcget $node -text] end-4 end-1]
		
		if { [expr 0x$indexId > 0x1fff] } {
			set entryState normal
			puts "0x$indexId is greater than 0x1fff state->$entryState"
		} else {
			set entryState disabled
			puts "0x$indexId is lesser than 0x1fff state->$entryState"
		}
		
		set indexPos [new_intp] 
		#DllExport ocfmRetCode IfIndexExists(int NodeID, ENodeType NodeType, char* IndexID, int* IndexPos)
		set catchErrCode [IfIndexExists $nodeId $nodeType $indexId $indexPos] 
		set indexPos [intp_value $indexPos] 
		set IndexProp []
		for {set cnt 0 } {$cnt <= 9} {incr cnt} {
			#puts "\nGetIndexAttributes nodeId->$nodeId nodeType->$nodeType indexId->$indexId $cnt\n"
			#set tempIndexProp [GetIndexAttributes $nodeId $nodeType $indexId $cnt]
			set tempIndexProp [GetIndexAttributesbyPositions $nodePos $indexPos $cnt ]
			set ErrCode [ocfmRetCode_code_get [lindex $tempIndexProp 0]]
			#puts "ErrCode:$ErrCode"
			if {$ErrCode == 0} {
				lappend IndexProp [lindex $tempIndexProp 1]
			} else {
				puts "Error occured for property no :$cnt ErrCode:$ErrCode ErrStr:[ocfmRetCode_errorString_get [lindex $tempIndexProp 0]]]"
				lappend IndexProp []
			}

		}

		$tmpInnerf0.en_idx1 configure -state normal
		$tmpInnerf0.en_idx1 delete 0 end
		$tmpInnerf0.en_idx1 insert 0 0x$indexId
		$tmpInnerf0.en_idx1 configure -state disabled
		#$tmpInnerf0.en_idx1 configure -state $entryState

		pack [lindex $f0 1] -expand yes -fill both -padx 2 -pady 4
		pack forget [lindex $f1 1]
		pack forget [lindex $f2 0]
		[lindex $f2 1] cancelediting
		[lindex $f2 1] configure -state disabled
		
		puts "***include index ? [lindex $IndexProp 9]***"
		if { [lindex $IndexProp 9] == "1" } {
			$tmpInnerf0.frame1.ch_gen select
		} else {
			$tmpInnerf0.frame1.ch_gen deselect
		}

	}
	
	#if not configured to validate none forcing the validating condition thus setting the chkPrompt value
	$tmpInnerf0.en_nam1 configure -validate none
	$tmpInnerf0.en_nam1 delete 0 end
	$tmpInnerf0.en_nam1 insert 0 [lindex $IndexProp 0]
	$tmpInnerf0.en_nam1 configure -bg $savedBg -validate key

	$tmpInnerf1.en_data1 configure -state normal
	$tmpInnerf1.en_data1 delete 0 end
	$tmpInnerf1.en_data1 insert 0 [lindex $IndexProp 2]
	#$tmpInnerf1.en_data1 configure -state disabled
	$tmpInnerf1.en_data1 configure -state $entryState -bg white

	
	$tmpInnerf1.en_default1 configure -state normal
	$tmpInnerf1.en_default1 delete 0 end
	$tmpInnerf1.en_default1 insert 0 [lindex $IndexProp 4]
	#$tmpInnerf1.en_default1 configure -state disabled
	$tmpInnerf1.en_default1 configure -state $entryState -bg white

	#puts "#en_value1 is configured to state normal to prevent potential bugs $tmpInnerf1.en_value1"
	$tmpInnerf1.en_value1 configure -state normal -validate none -bg $savedBg
	$tmpInnerf1.en_value1 delete 0 end
	$tmpInnerf1.en_value1 insert 0 [lindex $IndexProp 5]

	$tmpInnerf1.en_lower1 configure -state normal
	$tmpInnerf1.en_lower1 delete 0 end
	$tmpInnerf1.en_lower1 insert 0 [lindex $IndexProp 7]
	#$tmpInnerf1.en_lower1 configure -state disabled
	$tmpInnerf1.en_lower1 configure -state $entryState -bg white

	$tmpInnerf1.en_upper1 configure -state normal
	$tmpInnerf1.en_upper1 delete 0 end
	$tmpInnerf1.en_upper1 insert 0 [lindex $IndexProp 8]
	#$tmpInnerf1.en_upper1 configure -state disabled
	$tmpInnerf1.en_upper1 configure -state $entryState -bg white

	if { $entryState == "disabled" } {
		grid remove $tmpInnerf1.co_obj1
		grid $tmpInnerf1.en_obj1
		$tmpInnerf1.en_obj1 configure -state normal
		$tmpInnerf1.en_obj1 delete 0 end
		$tmpInnerf1.en_obj1 insert 0 [lindex $IndexProp 1]
		$tmpInnerf1.en_obj1 configure -state disabled
		#$tmpInnerf1.en_obj1 configure -state $entryState
	
		#grid remove $tmpInnerf1.co_data1
		##grid $tmpInnerf1.en_data1	
		#$tmpInnerf1.en_data1 configure -state normal
		#$tmpInnerf1.en_data1 delete 0 end
		#$tmpInnerf1.en_data1 insert 0 [lindex $IndexProp 2]
		#$tmpInnerf1.en_data1 configure -state disabled
		#$tmpInnerf1.en_data1 configure -state $entryState

		grid remove $tmpInnerf1.co_access1
		grid $tmpInnerf1.en_access1
		$tmpInnerf1.en_access1 configure -state normal
		$tmpInnerf1.en_access1 delete 0 end
		$tmpInnerf1.en_access1 insert 0 [lindex $IndexProp 3]
		$tmpInnerf1.en_access1 configure -state disabled
		#$tmpInnerf1.en_access1 configure -state $entryState
		
		grid remove $tmpInnerf1.co_pdo1
		grid $tmpInnerf1.en_pdo1
		$tmpInnerf1.en_pdo1 configure -state normal
		$tmpInnerf1.en_pdo1 delete 0 end
		$tmpInnerf1.en_pdo1 insert 0 [lindex $IndexProp 6]
		$tmpInnerf1.en_pdo1 configure -state disabled
		#$tmpInnerf1.en_pdo1 configure -state $entryState
		
		
		
		
		
		
		
		if { [lindex $IndexProp 2] == "IP_ADDRESS" } {
			set lastConv ""
			grid remove $tmpInnerf1.frame1.ra_dec
			grid remove $tmpInnerf1.frame1.ra_hex
			$tmpInnerf1.en_value1 configure -validate key -vcmd "IsIP %P %V" -bg $savedBg
		} elseif { [lindex $IndexProp 2] == "MAC_ADDRESS" } {
			set lastConv ""
			grid remove $tmpInnerf1.frame1.ra_dec
			grid remove $tmpInnerf1.frame1.ra_hex
			$tmpInnerf1.en_value1 configure -validate key -vcmd "IsMAC %P %V" -bg $savedBg
		} else {

			#grid remove $tmpInnerf1.frame1.ra_ip
			#grid remove $tmpInnerf1.frame1.ra_mac
			grid $tmpInnerf1.frame1.ra_dec
			grid $tmpInnerf1.frame1.ra_hex
			
			puts "\nIN singleclicknode userPrefList->$userPrefList"
			set schRes [lsearch $userPrefList [list $nodeSelect *]]
			puts "schRes->$schRes\n STATE=[$tmpInnerf1.en_value1 cget -state] \t $tmpInnerf1.en_value1\n"
			if { $schRes != -1 } {
				if { [lindex [lindex $userPrefList $schRes] 1] == "dec" } {
					if {[string match -nocase "0x*" [lindex $IndexProp 5]]} {
						$tmpInnerf1.en_value1 configure -validate none
						InsertDec $tmpInnerf1.en_value1
						$tmpInnerf1.en_value1 configure -validate key -vcmd "IsDec %P $tmpInnerf1 %d %i" -bg $savedBg	
					} else {
						puts "# ACTUALVALUE already in decimal no need to do anything"
					}
				
					if {[string match -nocase "0x*" [lindex $IndexProp 4]]} {
						set state [$tmpInnerf1.en_default1 cget -state]
						$tmpInnerf1.en_default1 configure -state normal
						InsertDec $tmpInnerf1.en_default1
						$tmpInnerf1.en_default1 configure -state $state
					} else {
						puts "# DEFAULTVALUE already in decimal no need to do anything"
					}
					set lastConv dec
					$tmpInnerf1.frame1.ra_dec select
				} elseif { [lindex [lindex $userPrefList $schRes] 1] == "hex" } {
					if {[string match -nocase "0x*" [lindex $IndexProp 5]]} {
						puts "# ACTUALVALUE already in hexadecimal no need to do anything"
					} else {
						$tmpInnerf1.en_value1 configure -validate none
						InsertHex $tmpInnerf1.en_value1
						$tmpInnerf1.en_value1 configure -validate key -vcmd "IsHex %P %s $tmpInnerf1 %d %i" -bg $savedBg
					}
				
					if {[string match -nocase "0x*" [lindex $IndexProp 4]]} {
						puts "# DEFAULTVALUE already in hexadecimal no need to do anything"
					} else {
						set state [$tmpInnerf1.en_default1 cget -state]
						$tmpInnerf1.en_default1 configure -state normal
						InsertHex $tmpInnerf1.en_default1
						$tmpInnerf1.en_default1 configure -state $state
					}
						
					set lastConv hex
					$tmpInnerf1.frame1.ra_hex select
				} else {
					puts "\n\nInvalid userpref [lindex $userPrefList 1]\n\n"
					return 
				}
			} else {
				if {[string match -nocase "0x*" [lindex $IndexProp 5]]} {
					set lastConv hex
					if {[string match -nocase "0x*" [lindex $IndexProp 4]]} {
						puts "#default value is already in hexadecimal no need to convert"
					} else {
						set state [$tmpInnerf1.en_default1 cget -state]
						$tmpInnerf1.en_default1 configure -state normal
					#	set tmpVal [lindex $IndexProp 4]
					#        #set tmpVal [string trimleft $tmpVal 0] ; #trimming zero leads to error
					#	if { $tmpVal != "" } {
					#	        if { [ catch {set tmpVal [_ConvertHex $tmpVal] } ] } {
					#			#error raised should not convert
					#	        } else {
					#			$tmpInnerf1.en_default1 delete 0 end
					#			$tmpInnerf1.en_default1 insert 0 0x$tmpVal
					#	        }
					#	} else {
					#		#value is empty insert 0x
					#		$tmpInnerf1.en_default1 insert 0 0x
					#	}
				
						InsertHex $tmpInnerf1.en_default1
						$tmpInnerf1.en_default1 configure -state $state
					}
					$tmpInnerf1.frame1.ra_hex select
					$tmpInnerf1.en_value1 configure -validate key -vcmd "IsHex %P %s $tmpInnerf1 %d %i" -bg $savedBg
				} else {
					set lastConv dec
					#puts "singleclicknode inside decimal default [lindex $IndexProp 4]"
					if {[string match -nocase "0x*" [lindex $IndexProp 4]]} {
						puts "#CONVERT DEFAULT HEXADECIMAL VALUE TO decimal"
						set state [$tmpInnerf1.en_default1 cget -state]
						$tmpInnerf1.en_default1 configure -state normal
						#set tmpVal [lindex $IndexProp 4]
						#if { $tmpVal != "" } {
						#	set tmpVal [string range $tmpVal 2 end]
						#	if { [ catch { set tmpVal [expr 0x$tmpVal] } ] } {
						#		puts "#raised an error dont convert"
						#	} else {
						#	        $tmpInnerf1.en_default1 delete 0 end
						#		$tmpInnerf1.en_default1 insert 0 $tmpVal
						#	}
						#} else {
						#	set tmpVal []
						#	$tmpInnerf1.en_default1 insert 0 $tmpVal
						#}
					
						InsertDec $tmpInnerf1.en_default1
						
						$tmpInnerf1.en_default1 configure -state $state
					} else {
						puts "#default value is already in decimal no need to convert"
					}
					$tmpInnerf1.frame1.ra_dec select
					$tmpInnerf1.en_value1 configure -validate key -vcmd "IsDec %P $tmpInnerf1 %d %i" -bg $savedBg
				}
			}
		}
	
		if { [lindex $IndexProp 3] == "const" || [lindex $IndexProp 3] == "ro" || [lindex $IndexProp 3] == "" } {
			puts "#the field is non editable"
			$tmpInnerf1.en_value1 configure -state "disabled"
		} else {
			$tmpInnerf1.en_value1 configure -state "normal"
		}
	
		
		
	} else {
		
		grid remove $tmpInnerf1.frame1.ra_dec
		grid remove $tmpInnerf1.frame1.ra_hex
		
		grid $tmpInnerf1.co_obj1
		grid remove $tmpInnerf1.en_obj1
		
		#grid $tmpInnerf1.co_data1
		#grid remove $tmpInnerf1.en_data1	
		
		grid $tmpInnerf1.co_access1
		grid remove $tmpInnerf1.en_access1
		
		grid $tmpInnerf1.co_pdo1
		grid remove $tmpInnerf1.en_pdo1
	}
	
	
	
	#if { [lindex $IndexProp 2] == "IP_ADDRESS" } {
	#	set lastConv ""
	#	grid remove $tmpInnerf1.frame1.ra_dec
	#	grid remove $tmpInnerf1.frame1.ra_hex
	#	$tmpInnerf1.en_value1 configure -validate key -vcmd "IsIP %P %V" -bg $savedBg
	#} elseif { [lindex $IndexProp 2] == "MAC_ADDRESS" } {
	#	set lastConv ""
	#	grid remove $tmpInnerf1.frame1.ra_dec
	#	grid remove $tmpInnerf1.frame1.ra_hex
	#	$tmpInnerf1.en_value1 configure -validate key -vcmd "IsMAC %P %V" -bg $savedBg
	#} else {
	#
	#	#grid remove $tmpInnerf1.frame1.ra_ip
	#	#grid remove $tmpInnerf1.frame1.ra_mac
	#	grid $tmpInnerf1.frame1.ra_dec
	#	grid $tmpInnerf1.frame1.ra_hex
	#	
	#	puts "\nIN singleclicknode userPrefList->$userPrefList"
	#	set schRes [lsearch $userPrefList [list $nodeSelect *]]
	#	puts "schRes->$schRes\n STATE=[$tmpInnerf1.en_value1 cget -state] \t $tmpInnerf1.en_value1\n"
	#	if { $schRes != -1 } {
	#		if { [lindex [lindex $userPrefList $schRes] 1] == "dec" } {
	#			if {[string match -nocase "0x*" [lindex $IndexProp 5]]} {
	#				$tmpInnerf1.en_value1 configure -validate none
	#				InsertDec $tmpInnerf1.en_value1
	#				$tmpInnerf1.en_value1 configure -validate key -vcmd "IsDec %P $tmpInnerf1 %d %i" -bg $savedBg	
	#			} else {
	#				puts "# ACTUALVALUE already in decimal no need to do anything"
	#			}
	#			
	#			if {[string match -nocase "0x*" [lindex $IndexProp 4]]} {
	#				set state [$tmpInnerf1.en_default1 cget -state]
	#				$tmpInnerf1.en_default1 configure -state normal
	#				InsertDec $tmpInnerf1.en_default1
	#				$tmpInnerf1.en_default1 configure -state $state
	#			} else {
	#				puts "# DEFAULTVALUE already in decimal no need to do anything"
	#			}
	#			set lastConv dec
	#			$tmpInnerf1.frame1.ra_dec select
	#		} elseif { [lindex [lindex $userPrefList $schRes] 1] == "hex" } {
	#			if {[string match -nocase "0x*" [lindex $IndexProp 5]]} {
	#				puts "# ACTUALVALUE already in hexadecimal no need to do anything"
	#			} else {
	#				$tmpInnerf1.en_value1 configure -validate none
	#				InsertHex $tmpInnerf1.en_value1
	#				$tmpInnerf1.en_value1 configure -validate key -vcmd "IsHex %P %s $tmpInnerf1 %d %i" -bg $savedBg
	#			}
	#			
	#			if {[string match -nocase "0x*" [lindex $IndexProp 4]]} {
	#				puts "# DEFAULTVALUE already in hexadecimal no need to do anything"
	#			} else {
	#				set state [$tmpInnerf1.en_default1 cget -state]
	#				$tmpInnerf1.en_default1 configure -state normal
	#				InsertHex $tmpInnerf1.en_default1
	#				$tmpInnerf1.en_default1 configure -state $state
	#			}
	#				
	#			set lastConv hex
	#			$tmpInnerf1.frame1.ra_hex select
	#		} else {
	#			puts "\n\nInvalid userpref [lindex $userPrefList 1]\n\n"
	#			return 
	#		}
	#	} else {
	#		if {[string match -nocase "0x*" [lindex $IndexProp 5]]} {
	#			set lastConv hex
	#			if {[string match -nocase "0x*" [lindex $IndexProp 4]]} {
	#				puts "#default value is already in hexadecimal no need to convert"
	#			} else {
	#				set state [$tmpInnerf1.en_default1 cget -state]
	#				$tmpInnerf1.en_default1 configure -state normal
	#			#	set tmpVal [lindex $IndexProp 4]
	#			#        #set tmpVal [string trimleft $tmpVal 0] ; #trimming zero leads to error
	#			#	if { $tmpVal != "" } {
	#			#	        if { [ catch {set tmpVal [_ConvertHex $tmpVal] } ] } {
	#			#			#error raised should not convert
	#			#	        } else {
	#			#			$tmpInnerf1.en_default1 delete 0 end
	#			#			$tmpInnerf1.en_default1 insert 0 0x$tmpVal
	#			#	        }
	#			#	} else {
	#			#		#value is empty insert 0x
	#			#		$tmpInnerf1.en_default1 insert 0 0x
	#			#	}
	#			
	#				InsertHex $tmpInnerf1.en_default1
	#				$tmpInnerf1.en_default1 configure -state $state
	#			}
	#			$tmpInnerf1.frame1.ra_hex select
	#			$tmpInnerf1.en_value1 configure -validate key -vcmd "IsHex %P %s $tmpInnerf1 %d %i" -bg $savedBg
	#		} else {
	#			set lastConv dec
	#			#puts "singleclicknode inside decimal default [lindex $IndexProp 4]"
	#			if {[string match -nocase "0x*" [lindex $IndexProp 4]]} {
	#				puts "#CONVERT DEFAULT HEXADECIMAL VALUE TO decimal"
	#				set state [$tmpInnerf1.en_default1 cget -state]
	#				$tmpInnerf1.en_default1 configure -state normal
	#				#set tmpVal [lindex $IndexProp 4]
	#				#if { $tmpVal != "" } {
	#				#	set tmpVal [string range $tmpVal 2 end]
	#				#	if { [ catch { set tmpVal [expr 0x$tmpVal] } ] } {
	#				#		puts "#raised an error dont convert"
	#				#	} else {
	#				#	        $tmpInnerf1.en_default1 delete 0 end
	#				#		$tmpInnerf1.en_default1 insert 0 $tmpVal
	#				#	}
	#				#} else {
	#				#	set tmpVal []
	#				#	$tmpInnerf1.en_default1 insert 0 $tmpVal
	#				#}
	#				
	#				InsertDec $tmpInnerf1.en_default1
	#				
	#				$tmpInnerf1.en_default1 configure -state $state
	#			} else {
	#				puts "#default value is already in decimal no need to convert"
	#			}
	#			$tmpInnerf1.frame1.ra_dec select
	#			$tmpInnerf1.en_value1 configure -validate key -vcmd "IsDec %P $tmpInnerf1 %d %i" -bg $savedBg
	#		}
	#	}
	#}
	#
	#if { $entryState == "disabled" } {
	#	#the index is less than 1fff
	#	if { [lindex $IndexProp 3] == "const" || [lindex $IndexProp 3] == "ro" || [lindex $IndexProp 3] == "" } {
	#		puts "#the field is non editable"
	#		$tmpInnerf1.en_value1 configure -state "disabled"
	#	} else {
	#		$tmpInnerf1.en_value1 configure -state "normal"
	#	}
	#} else {
	#	#the index is more than 2000 should always be editable
	#	$tmpInnerf1.en_value1 configure -state "normal"
	#}
	
	#set chkPrompt 0

	return
}

################################################################################################
#proc Editor::DoubleClickNode
#Input       : node
#Output      : -
#Description : Displays required tabs when corresponding nodes are clicked
################################################################################################
proc Editor::DoubleClickNode {node} {
	global updatetree

	if {[$updatetree nodes $node] != "" } {
		if {[$updatetree itemcget $node -open]} {
			#it is already expanded so collapse it
			$updatetree itemconfigure $node -open 0
		} else {
			#it is collapsed so expand it
			$updatetree itemconfigure $node -open 1
		}
	} else {
		# it has no child no need to expand
	}
	Editor::SingleClickNode $node
} 

################################################################################################
#proc SaveProject
#Input       : -
#Output      : -
#Description : -
################################################################################################
proc Saveproject {} {
	global tcl_platform
	global PjtName
	global PjtDir
	global status_save

	if {$PjtDir == "" || $PjtName == "" } {
		#there is no project directory or project name no need to save
		return
	} else {
		set savePjtName [string range $PjtName 0 end-[ string length [file extension $PjtName] ]]
		set savePjtDir [string range $PjtDir 0 end-[string length $savePjtName] ]
		puts "\n\nSaveProject $savePjtDir $savePjtName\n\n"
		set catchErrCode [SaveProject $savePjtDir $savePjtName]
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		if { $ErrCode != 0 } {
			#tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
			if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
				tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -parent . -title Warning -icon warning
			} else {
				tk_messageBox -message "Unknown Error" -parent . -title Warning -icon warning
				puts "Unknown Error ->[ocfmRetCode_errorString_get $catchErrCode]\n"
			}
			return 
		}
		
		
	}
	#project is saved so change status to zero
	set status_save 0
	
	conPuts "Project [file join $PjtDir $PjtName] is saved"
}

proc _NewProject {} {
	set result [SaveProjectWindow] 
	puts "\n _NewProject result->$result \n"
	if { $result != "cancel"} {
		NewProjectWindow
	}
}

proc _CloseProject {} {
	global status_save
	global PjtName

	#before close should prompt to close
	if {$status_save} {
		set result [tk_messageBox -message "Save Project $PjtName Before closing?" -parent . -type yesnocancel -icon question -title "Question"]
		switch -- $result {
			yes {			 
				Saveproject
				conPuts "Project $PjtName is saved" info
			}
			no {
				conPuts "Project $PjtName not saved" info
			}
			cancel {
				return
			}
		}
		CloseProject
		puts "\n _CloseProject SaveProjectWindow result->$result \n"

	} else {
		set result [CloseProjectWindow]
		puts "\n _CloseProject CloseProjectWindow result->$result \n"
	}

}

################################################################################################
#proc CloseProject
#Input       : -
#Output      : -
#Description : -
################################################################################################
proc CloseProject {} {
	global updatetree

	DeleteAllNode
	
	ResetGlobalData
	
	catch {$updatetree delete PjtName}
	
	#delete in reverse order to get coorect output
	if { [$Editor::projMenu index 4] == "4" } {
		catch {$Editor::projMenu delete 4}
	}
	if { [$Editor::projMenu index 3] == "3" } {
		catch {$Editor::projMenu delete 3}
	}

	

	
	InsertTree
		
}

################################################################################################
#proc ResetGlobalData
#Input       : -
#Output      : -
#Description : -
################################################################################################
proc ResetGlobalData {} {
	#puts "ResetGlobalData called"
	global PjtDir
	global PjtName
	global nodeIdList
	global savedValueList
	global populatedPDOList
	global userPrefList
	global nodeSelect	
	global updatetree
	global mnCount
	global cnCount
	global status_save
	global status_run
	global f0
	global f1
	global f2
	global lastConv
	global LastTableFocus
	global chkPrompt
	global ra_proj
	global ra_auto

	#reset all the globaly maintained values 
	set nodeIdList ""
	set savedValueList ""
	set populatedPDOList ""
	set userPrefList ""
	set nodeSelect ""
	set mnCount 0
	set cnCount 0
	set status_save 0 ; # if zero no need to save
	set status_run 0 ; #if zero no other operation is running
	set PjtDir ""
	set PjtName ""
	set lastConv ""
	set LastTableFocus ""
	#set chkPrompt 0 ; ResetPromptFlag
	set ra_proj 2 ; #TODO TEMPORARY FIX
	set ra_auto 0 ; # TODO TEMPORARY FIX
	#no need to reset lastOpenPjt, lastXD, tableSaveBtn, indexSaveBtn and subindexSaveBtn
	
	#no index subindex or pdo table should be displayed
	pack forget [lindex $f0 1]
	pack forget [lindex $f1 1]
	pack forget [lindex $f2 0]
	[lindex $f2 1] cancelediting
	[lindex $f2 1] configure -state disabled
	
	update
}

################################################################################################
#proc DeleteAllNode
#Input       : -
#Output      : -
#Description : -
################################################################################################
proc DeleteAllNode {} {
	global nodeIdList
	
	puts "DeleteAllNode nodeIdList->$nodeIdList...length->[llength $nodeIdList]"
	if {[llength $nodeIdList] != 0} {
		foreach nodeId $nodeIdList {
			if {$nodeId == 240} {
				# nodeId is 240 for mn
				set nodeType 0
			} else {
				set nodeType 1
			}	
			puts "DeleteNode nodeId->$nodeId nodeType->$nodeType"
			DeleteNode $nodeId $nodeType
		}
	} else {
		#there was no node created so continue with process
	}
	
}

################################################################################################
#proc AddCN
#Input       : cn name, file to be imported, node id
#Output      : -
#Description : Add CN to MN and import xdc/xdd file if required
################################################################################################
proc AddCN {cnName tmpImpDir nodeId} {
	global updatetree
	global cnCount
	global mnCount
	global nodeIdList
	global status_save
	global status_run 	

	incr cnCount
	set catchErrCode [NodeCreate $nodeId 1 $cnName]
	#puts "\n\nAdd CN catchErrCode->$catchErrCode"
	#set catchErrCode [lindex $obj 0]
	set ErrCode [ocfmRetCode_code_get $catchErrCode]
	if { $ErrCode != 0 } {
		#tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
		if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]"  -title Warning -icon warning
		} else {
			tk_messageBox -message "Unknown Error" -title Warning -icon warning
                        puts "Unknown Error in AddCN ->[ocfmRetCode_errorString_get $catchErrCode]\n"
		}
		return 
	}

	#New CN is created need to save
	set status_save 1

	set node [$updatetree selection get]
	#puts "node->$node"
	set parentId [split $node -]
	set parentId [lrange $parentId 1 end]
	set parentId [join $parentId -]

	if {$tmpImpDir != ""} {
		#API
		#DllExport ocfmRetCode ImportXML(char* fileName, int NodeID, ENodeType NodeType);
		set catchErrCode [ImportXML "$tmpImpDir" $nodeId 1]
		#puts "catchErrCode->$catchErrCode"
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		#puts "ErrCode:$ErrCode"
		if { $ErrCode != 0 } {
			#tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
			if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
				tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
			} else {
				tk_messageBox -message "Unknown Error" -title Warning -icon warning
	                        puts "Unknown Error ->[ocfmRetCode_errorString_get $catchErrCode]\n"
			}
			return 
		} else {
			conPuts "Imported $tmpImpDir for Node ID: $nodeId"
		}
		
		#lappend nodeIdList CN-1-$cnCount
		lappend nodeIdList $nodeId 
	
	puts "nodeIdList->$nodeIdList"
		#creating the GUI for CN
		set child [$updatetree insert end $node CN-$parentId-$cnCount -text "$cnName\($nodeId\)" -open 0 -image [Bitmap::get cn]]
		
                thread::send -async [tsv::set application importProgress] "StartProgress"
		#creating the GUI for imported objects
		#Import parentNode nodeType nodeID 
		Import CN-$parentId-$cnCount 1 $nodeId 
		thread::send -async [tsv::set application importProgress] "StopProgress"
		
	} else {
		#lappend nodeIdList CN-1-$cnCount
		lappend nodeIdList $nodeId 

		#should not import should create GUI default are not it will come here
		set child [$updatetree insert end $node CN-$parentId-$cnCount -text "$cnName\($nodeId\)" -open 0 -image [Bitmap::get cn]]
	}
	return 
}

################################################################################################
#proc YetToImplement
#Input       : -
#Output      : -
#Description : Displays message for non implemented function 
################################################################################################
proc YetToImplement {} {
	tk_messageBox -message "Yet to be Implemented !" -title Info -icon info
}

################################################################################################
#proc InsertTree
#Input       : -
#Output      : -
#Description : Creates tree during startup 
################################################################################################
proc InsertTree { } {
	global updatetree
	global cnCount
	global mnCount
	incr cnCount
	incr mnCount
	$updatetree insert end root PjtName -text "POWERLINK Network" -open 1 -image [Bitmap::get network]
}

################################################################################################

namespace eval FindSpace {
	variable findList
	variable searchString
	variable searchCount
	variable txtFindDym
}

################################################################################################
#proc FindDynWindow
#Input       : -
#Output      : -
#Description : Displays GUI for Find and add binding for Next
################################################################################################
proc FindDynWindow {} {
	catch {
		global treeFrame
		pack $treeFrame -side bottom -pady 5
		focus $treeFrame.en_find
		bind $treeFrame.en_find <KeyPress-Return> "FindSpace::Next"
		set FindSpace::txtFindDym ""
	}
}

################################################################################################
#proc EscapeTree
#Input       : -
#Output      : -
#Description : Hides GUI for Find and remove binding for Next
################################################################################################
proc EscapeTree {} {
	catch {
		global treeFrame
		pack forget $treeFrame
		bind $treeFrame.en_find <KeyPress-Return> ""
	}

}

################################################################################################
#proc FindSpace::Find
#Input       : search string
#Output      : nodes containing search string
#Description : Finds nodes containing search string
################################################################################################
proc FindSpace::Find { searchStr {node ""} {mode 0} } {
	global updatetree

#puts "mode->$mode"
	set FindSpace::searchString $searchStr
	set flag 0
	set chk 0
	set prev ""
	set next ""
	if {$searchStr== ""} {
		$updatetree selection clear
		return 1
	}
	set mnNode [$updatetree nodes PjtName]
	foreach tempMn $mnNode {
		if {$tempMn == $node && $mode != 0} {
			if {$mode == "prev"} {
				return $prev
			} else {
				set flag 1
			}
		}
		set childMn [$updatetree nodes $tempMn]
		foreach tempChildMn $childMn {
			if {$tempChildMn == $node && $mode != 0} {
				if {$mode == "prev"} {
					return $prev
				} else {
					set flag 1
				}
			}
			set idx [$updatetree nodes $tempChildMn]
			foreach tempIdx $idx {
				if {$tempIdx == $node && $mode != 0} {
					if {$mode == "prev"} {
						return $prev
					} else {
						set flag 1
						set chk 1
					}
				
#puts "flag 1 in idx ->$tempIdx"	
				}
				if {[string match -nocase "PDO*" $tempIdx]} {
#puts "calling pdo"
				#set result [FindSpace::FindPdo $tempIdx $searchStr $mode $node $flag $prev $next $chk]
				#if {$result == "no_match"} {
				#	continue
				#} else {
				#	return $result
				#}
					set childPdo [$updatetree nodes $tempIdx]
					foreach tempPdo $childPdo {
						if {$tempPdo == $node && $mode != 0} {
							if {$mode == "prev"} {
								return $prev
							} else {
								set flag 1
							}
						}
						set pdoIdx [$updatetree nodes $tempPdo]
						foreach tempPdoIdx $pdoIdx { 
							if {$tempPdoIdx == $node && $mode != 0} {
								if {$mode == "prev"} {
									return $prev
								} else {
									set flag 1
									set chk 1
								}
						
#puts "flag 1 in pdo idx ->$tempPdoIdx"	
							}
							if {[string match -nocase "*$searchStr*" [$updatetree itemcget $tempPdoIdx -text]] && $chk == 0} {
								#lappend FindSpace::findList $tempIdx
								#puts -nonewline "......MATCH idx......"
								if { $mode == 0 } {
									FindSpace::OpenParent $updatetree $tempPdoIdx
									return 1
								} elseif {$mode == "prev" } {
									set prev $tempPdoIdx
#puts "prev in pdo idx ->$prev"
								} elseif {$mode == "next" } {
									if {$flag == 0} {
										#do nothing
									} elseif {$flag == 1} {
										set next $tempPdoIdx
#puts "next in pdo sidx ->$next"
										return $next
									}
								}
							} elseif {$chk == 1} {
								set chk 0
							}
							set pdoSidx [$updatetree nodes $tempPdoIdx]
							foreach tempPdoSidx $pdoSidx { 
								if {$tempPdoSidx == $node && $mode != 0} {
									if {$mode == "prev"} {
										return $prev
									} else {
										set flag 1
										set chk 1
									}
						
#puts "flag 1 in idx ->$tempIdx"	
								}
								if {[string match -nocase "*$searchStr*" [$updatetree itemcget $tempPdoSidx -text]] && $chk == 0} {
									#lappend FindSpace::findList $tempSidx
									#puts -nonewline "......MATCH sidx......"
									if { $mode == 0 } {
										FindSpace::OpenParent $updatetree $tempPdoSidx
										return 1
									} elseif {$mode == "prev" } {
										set prev $tempPdoSidx
#puts "prev in pdo sidx ->$prev"
									} elseif {$mode == "next" } {
										if {$flag == 0} {
											#do nothing
										} elseif {$flag == 1} {
											set next $tempPdoSidx
#puts "next in pdo sidx ->$next"
											return $next
										}
		
									}
								} elseif {$chk == 1} {
									set chk 0
								}
							}
						}	
					}
				}
				if {[string match -nocase "*$searchStr*" [$updatetree itemcget $tempIdx -text]] && $chk == 0} {
#puts "idx matched -> $tempIdx"
					#lappend FindSpace::findList $tempIdx
					if { $mode == 0 } { 
						FindSpace::OpenParent $updatetree $tempIdx
						return 1
					} elseif {$mode == "prev" } {
						set prev $tempIdx
#puts "prev in idx ->$prev"
					} elseif {$mode == "next" } {
						if {$flag == 0} {
							#do nothing
						} elseif {$flag == 1} {
							set next $tempIdx
#puts "next in idx ->$next"
							return $next
						}
					}
				} elseif {$chk == 1} {
					set chk 0
				}
					
				set sidx [$updatetree nodes $tempIdx]
				foreach tempSidx $sidx { 
					if {$tempSidx == $node && $mode != 0} {
						if {$mode == "prev"} {
							return $prev
						} else {
							set flag 1
							set chk 1
						}
#puts "flag 1 in sidx ->$tempSidx"
					}
					if {[string match -nocase "*$searchStr*" [$updatetree itemcget $tempSidx -text]] && $chk == 0} {
#puts "sidx matched -> $tempSidx"
						#lappend FindSpace::findList $tempSidx

						if { $mode == 0 } { 
							FindSpace::OpenParent $updatetree $tempSidx
							return 1
						} elseif {$mode == "prev" } {
							set prev $tempSidx
#puts "prev in sidx ->$prev"
						} elseif {$mode == "next" } {
							if {$flag == 0} {
								#do nothing
							} elseif {$flag == 1} {
								set next $tempSidx
#puts "next in sidx ->$next"
								return $next
							}
	
						}
					} elseif {$chk == 1} {
						set chk 0
				}
						
			}
		}
			}
	}
	#$updatetree selection clear
	##puts FindSpace::findList->$FindSpace::findList
	#if {[llength $FindSpace::findList]!=0} {
	#	catch { set parent [$updatetree parent [lindex $FindSpace::findList 0] ]
	#		$updatetree itemconfigure [$updatetree parent [lindex $FindSpace::findList 0] ] -open 1
	#		$updatetree selection set [lindex $FindSpace::findList 0] 
	#		$updatetree see [lindex $FindSpace::findList 0]}
	#}
	if {$mode == 0} {
		$updatetree selection clear
		return 1
	} else {
		$updatetree selection clear
		return ""
	} 
}

################################################################################################
#proc FindSpace::OpenParent
#Input       : pdo node, search string
#Output      : nodes containing search string
#Description : Finds nodes containing search string in PDO
################################################################################################
proc FindSpace::OpenParent { updatetree node } {
	$updatetree selection clear
	set tempNode $node
	while {[$updatetree parent $tempNode] != "PjtName"} {
		#puts "open parent tempNode->$tempNode"
		set tempNode [$updatetree parent $tempNode]
		$updatetree itemconfigure $tempNode -open 1
	}
	$updatetree selection set $node 
	$updatetree see $node

}

################################################################################################
#proc FindSpace::Prev
#Input       : -
#Output      : -
#Description : Displays previous node containing search string
################################################################################################
proc FindSpace::Prev {} {
	global updatetree
	set node [$updatetree selection get]
	if {![info exists FindSpace::searchString]} {
		return
	} 
	if {$node == ""} {
		# if no node is selected find first match
		FindSpace::Find $FindSpace::searchString
	} else {
		set prev [FindSpace::Find $FindSpace::searchString $node prev]
		#puts out->$out
		#set prev [lindex $out 0]
		#puts prev->$prev
		if { $prev == "" } {
			#puts "prev no match"
		} else {
			FindSpace::OpenParent $updatetree $prev
			#$updatetree selection set $prev 
			#$updatetree see $prev
		}
		return
	}
}

################################################################################################
#proc FindSpace::Next
#Input       : -
#Output      : -
#Description : Displays next node containing search string
################################################################################################
proc FindSpace::Next {} {
	global updatetree
	set node [$updatetree selection get]
	if {![info exists FindSpace::searchString]} {
		return
	} 
	if {$node == ""} {
		# if no node is selected find first match
		FindSpace::Find $FindSpace::searchString
	} else {	
		set next [FindSpace::Find $FindSpace::searchString $node next]
		#puts next->$next
		if { $next == "" } {
			#puts "next no match"
		} else {
			FindSpace::OpenParent $updatetree $next
		}
		return
	}
}

proc StartStack {} {
	
}

proc StopStack {} {
	
}

################################################################################################
#proc TransferCDC
#Input       : -
#Output      : -
#Description : Gets location where CDC is to be stored
################################################################################################
proc TransferCDC {choice} {
	global PjtDir
	global PjtName 

	if {$PjtDir == "" || $PjtName == "" } {
		errorPuts "No project to generate CDC"
		return	
	}

	#if {$choice} {
	#	set result [tk_messageBox -message "Do you want to Generate CDC ?" -type yesno -icon question -title "Question"]
	#	switch -- $result {
	#		yes {
	#			#continue
	#		}
	#		no { 
	#			return
	#		}
	#	}
	#}

	#if {![file isfile [file join [pwd] config_data.cdc]]} {}
	#if {![file isfile [file join $PjtDir config_data.cdc]]} {
	#	tk_messageBox -message "CDC does not exist\nBuild the Project to Generate CDC" -icon info -title "Information"
	#	return
	#}

	set types {
        {"CDC files"     {*.cdc } }
	}
	set fileLocation_from_CDC [tk_getOpenFile -initialdir [file join $PjtDir CDC_XAP] -filetypes $types -parent . -title "Select CDC file to transfer"]
        if {$fileLocation_from_CDC == ""} {
                return
        }
	########### Before Closing Write the Data to the file ##########

	#set file [tk_getSaveFile -filetypes $filePatternList -initialdir $EditorData(opti	ons,workingDir) \
        #     -initialfile $filename -defaultextension $defaultExt -title "Save File"]


	# Validate filename
	set fileLocation_to_CDC [tk_getSaveFile -filetypes $types -initialdir [file join $PjtDir CDC_XAP] -initialfile [generateAutoName [file join $PjtDir CDC_XAP] CDC .cdc ] -title "Transfer CDC at"]
        if {$fileLocation_to_CDC == ""} {
                return
        }

	#set fileLocation_CDC [file join .. .. openPOWERLINK_CFM_V1.3.0-3 config_dat.cdc]
	puts "fileLocation_to_CDC->$fileLocation_to_CDC   fileLocation_from_CDC->$fileLocation_from_CDC"
	#catch { file copy -force [file join [pwd] config_data.cdc] $fileLocation_CDC }
	file copy -force $fileLocation_from_CDC $fileLocation_to_CDC
	conPuts "CDC transfer complete"
	#puts fileLocation_CDC:$fileLocation_CDC
	#set catchErrCode [GenerateCDC $fileLocation_CDC]
	#set ErrCode [ocfmRetCode_code_get $catchErrCode]
	##puts "ErrCode:$ErrCode"
	#if { $ErrCode != 0 } {
	#	errorPuts "[ocfmRetCode_errorString_get $catchErrCode]"
	#	tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
	#	#tk_messageBox -message "ErrCode:$ErrCode" -title Warning -icon warning
	#} else {
	#	conPuts "CDC generated" info
	#}
	#return $ErrCode
}

################################################################################################
#proc TransferXAP
#Input       : -
#Output      : -
#Description : Gets location where XAP is to be stored
################################################################################################
proc TransferXAP {choice} {
	global PjtDir
	global PjtName 

	if {$PjtDir == "" || $PjtName == "" } {
		errorPuts "No project to generate XAP"
		return	
	}
	#if {$choice} {
	#	set result [tk_messageBox -message "Do you want to Generate XAP ?" -type yesno -icon question -title "Question"]
	#	switch -- $result {
	#		yes {
	#			#continue
	#		}
	#		no { 
	#			return
	#		}
	#	}
	#}

	#if {![file isfile [file join [pwd] XAP.xap]]} {}
	#if {![file isfile [file join [pwd] XAP.xap]]} {
	#	tk_messageBox -message "XAP does not exist\nBuild the Project to Generate XAP" -icon info -title "Information"
	#	return
	#}

	set types {
        {"XAP Files"     {*.xap } }
	}
	set fileLocation_from_XAP [tk_getOpenFile -initialdir [file join $PjtDir CDC_XAP] -filetypes $types -parent . -title "Select XAP file to transfer"]
        if {$fileLocation_from_XAP == ""} {
                return
        }
	########### Before Closing Write the Data to the file ##########

	#set file [tk_getSaveFile -filetypes $filePatternList -initialdir $EditorData(options,workingDir) \
        #     -initialfile $filename -defaultextension $defaultExt -title "Save File"]


	# Validate filename
	set fileLocation_to_XAP [tk_getSaveFile -filetypes $types -initialdir [file join $PjtDir CDC_XAP] -initialfile [generateAutoName [file join $PjtDir CDC_XAP] XAP .xap ] -title "Transfer XAP file at"]
        if {$fileLocation_to_XAP == ""} {
                return
        }
	
	puts "fileLocation_from_XAP->$fileLocation_from_XAP  fileLocation_to_XAP->$fileLocation_to_XAP"
	
	if { ![file isfile $fileLocation_from_XAP.h] } {
		conPuts "XAP.h not found. XAP not transferred"
		return
	}
	
	file copy -force $fileLocation_from_XAP $fileLocation_to_XAP
	file copy -force $fileLocation_from_XAP.h $fileLocation_to_XAP.h
	conPuts "XAP transfer complete"
	conPuts "XAP.h also transferred"

}

################################################################################################
#proc BuildProject
#Input       : -
#Output      : -
#Description : Build the project 
################################################################################################
proc BuildProject {} {
	global PjtDir
	global PjtName
	global ra_proj
	global nodeIdList
	global savedValueList
	global populatedPDOList
	global userPrefList
	global nodeSelect	
	global updatetree
	global mnCount
	global cnCount
	global f0
	global f1
	global f2


	if {$PjtDir == "" || $PjtName == "" } {
		errorPuts "No project to Build"
		return	
	}

	set result [tk_messageBox -message "Do you want to Build Project ?" -type yesno -icon question -title "Question" -parent .]
	switch -- $result {
		yes {
			#continue
		}
		no { 
			return
		}
	}
	
	set types {
        {"CDC files"     {*.cdc } }
	}
	
	#set fileLocation_CDC [tk_getSaveFile -filetypes $types -initialdir $PjtDir -initialfile [generateAutoName $PjtDir CDC .cdc ] -title "Transfer CDC"]
        #if {$fileLocation_CDC == ""} {
        #        return
        #}
	set fileLocation_CDC [generateAutoName [file join $PjtDir CDC_XAP] CDC .cdc ]

	thread::send [tsv::get application importProgress] "StartProgress"	
	puts "GenerateCDC [file join $PjtDir CDC_XAP ] fileLocation_CDC->$fileLocation_CDC"
	#set catchErrCode [GenerateCDC [file join $PjtDir CDC_XAP $fileLocation_CDC.cdc] ]
	set catchErrCode [GenerateCDC [file join $PjtDir CDC_XAP] ]
	#puts "catchErrCode->$catchErrCode"
	set ErrCode [ocfmRetCode_code_get $catchErrCode]
	#puts "ErrCode:$ErrCode"


	if { $ErrCode != 0 } {
		#error in generating CDC dont generate XAP
		errorPuts "Error in generating CDC. XAP not generated" error
		thread::send [tsv::get application importProgress] "StopProgress"
		return
	} else {
		set tempPjtDir $PjtDir
		set tempPjtName $PjtName
		set tempRa_proj $ra_proj
		ResetGlobalData
		set PjtDir $tempPjtDir
		set PjtName $tempPjtName
		set ra_proj $tempRa_proj
		#catch {$updatetree delete PjtName}
		#$updatetree insert end root PjtName -text [string range $PjtName 0 end-[string length [file extension $PjtName] ] ] -open 1 -image [Bitmap::get network]

		RePopulate  $PjtDir [string range $PjtName 0 end-[string length [file extension $PjtName] ] ]
		set fileLocation_XAP [generateAutoName [file join $PjtDir CDC_XAP] XAP .xap ]

		puts "GenerateXAP [file join $PjtDir CDC_XAP $fileLocation_XAP.xap] fileLocation_XAP->$fileLocation_XAP"
		#set catchErrCode [GenerateCDC [file join $PjtDir CDC_XAP $fileLocation_CDC] ]
		#set catchErrCode [GenerateXAP XAP]
		#set catchErrCode [GenerateXAP [file join $PjtDir CDC_XAP $fileLocation_XAP.xap] ]
		set catchErrCode [GenerateXAP [file join $PjtDir CDC_XAP XAP] ]
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		##puts "ErrCode:$ErrCode"
		if { $ErrCode != 0 } {
			errorPuts "XAP is not generated"
			thread::send -async [tsv::set application importProgress] "StopProgress"			
			return
		} else {
			conPuts "CDC and XAP are successfully generated"
			#catch { file copy -force [file join [file join $PjtDir $PjtName] $PjtName.xap]  [file join [pwd] $PjtName.xap]}
			#catch { file rename -force [file join [pwd] $PjtName.xap] [file join [pwd] XAP.xap] }
			#catch { file copy -force [file join [file join $PjtDir $PjtName] $PjtName.xap.h]  [file join [pwd] $PjtName.xap.h]}
			#catch { file rename -force [file join [pwd] $PjtName.xap.h] [file join [pwd] XAPH.xap.h] }
			thread::send -async [tsv::set application importProgress] "StopProgress"
		}

	}
}

proc CleanProject {} {
	global PjtDir
	global PjtName 
	
	#TODO finalise the files to be cleaned
	foreach tempFile [list mnobd.txt mnobd.cdc XAP XAP.h] {
		set CleanFile [file join $PjtDir CDC_XAP $tempFile]
		puts "CleanFile->$CleanFile"
		catch {file delete -force $CleanFile}
	}
}

################################################################################################
#proc ReImport
#Input       : -
#Output      : -
#Description : Imports XDC/XDD file for MN or CN called when right clicked 
################################################################################################
proc ReImport {} {
	global updatetree
	global nodeIdList
	global status_save
	global status_run
	global lastXD

#puts " \n\nReimport" 
#puts "nodeIdList->$nodeIdList"

	set node [$updatetree selection get]
	if {[string match "MN*" $node]} {
		set child [$updatetree nodes $node]
		set tmpNode [string range $node 2 end]
		# since a MN has only one so -1 is appended
		set node OBD$tmpNode-1

		# check whether import is first time or not 
		#so as to add OBD icon in GUI
		set res [lsearch $child "OBD$tmpNode-1*"]
		#puts "in reimport res -> $res"
		#puts "child->$child"

		set nodeId 240
		set nodeType 0
	
	} else {
		#gets the nodeId and Type of selected node
		set result [GetNodeIdType $node]
		if {$result != "" } {
			set nodeId [lindex $result 0]
			set nodeType [lindex $result 1]
		} else {
			#must be some other node this condition should never reach
			#puts "\n\nDeleteTreeNode->SHOULD NEVER HAPPEN\n\n"
			return
		}

	}	
	set cursor [. cget -cursor]
	set types {
	        {{XDC/XDD Files} {.xd*} }
	        {{XDD Files}     {.xdd} }
		{{XDC Files}     {.xdc} }
	}
	#puts  "\n\nREimport"
	if {![file isdirectory $lastXD] && [file exists $lastXD] } {
		set tmpImpDir [tk_getOpenFile -title "Import XDC/XDD" -initialfile $lastXD -filetypes $types -parent .]
	} else {
		set tmpImpDir [tk_getOpenFile -title "Import XDC/XDD" -filetypes $types -parent .]
	}
	if {$tmpImpDir != ""} {
		set lastXD $tmpImpDir
		#API 
		#ReImportXML(char* fileName, char* errorString, int NodeID, ENodeType NodeType);
		set result [tk_messageBox -message "Do you want to Import $tmpImpDir ?" -type yesno -icon question -title "Question" -parent .]
   		 switch -- $result {
   		     yes {
			   conPuts "Importing file $tmpImpDir for Node ID : $nodeId"
			 }			 
   		     no  {
			   conPuts "Importing $tmpImpDir is cancelled for Node ID : $nodeId"
			   return
			 }
   		}
		set catchErrCode [ReImportXML $tmpImpDir $nodeId $nodeType]
		#puts "catchErrCode in reimport ->$catchErrCode"
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		#puts "ErrCode:$ErrCode"
		if { $ErrCode != 0 } {
			#tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
			if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
				tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .
			} else {
				tk_messageBox -message "Unknown Error" -title Warning -icon warning -parent .
			        puts "Unknown Error in ReImport ->[ocfmRetCode_errorString_get $catchErrCode]\n"
			}
			return
		} else {
			#conPuts "ReImported $tmpImpDir for Node ID:$nodeId"
		}

		#xdc/xdd is reimported need to save
		set status_save 1

		catch {
			if { $res == -1} {
				#there can be one OBD in MN so -1 is hardcoded
				$updatetree insert 0 MN$tmpNode OBD$tmpNode-1 -text "OBD" -open 0 -image [Bitmap::get pdo]
			}
		}
		#catch {FreeNodeMemory $node} ; # no need to free memory
		CleanList $node 0
		CleanList $node 1
		catch {$updatetree delete [$updatetree nodes $node]}
		$updatetree itemconfigure $node -open 0
		
		thread::send -async [tsv::set application importProgress] "StartProgress"
		#Import parentNode nodeType nodeID 
		Import $node $nodeType $nodeId
		thread::send -async [tsv::set application importProgress] "StopProgress"
		
	}
	#puts "**********\n"

} 

################################################################################################
#proc DeleteTreeNode
#Input       : -
#Output      : -
#Description : to delete a node in the tree
################################################################################################
proc DeleteTreeNode {} {
	
	global updatetree
	global nodeIdList
	global nodeObj	
	global savedValueList
	global userPrefList
	global status_save
	#puts nodeIdList->$nodeIdList


	set node [$updatetree selection get]
	
	if { [string match "PjtName" $node] || [string match "PDO*" $node]|| [string match "?PDO*" $node] } {
		#should not delete when pjt, mn, pdo, tpdo or rpdo is selected 
		return
	}
	if {[string match "MN*" $node]} {
		set nodePos [split $node -]
		set nodePos [lrange $nodePos 1 end]
		set nodePos [join $nodePos -]

		# always OBD node ends with -1
		set node OBD-$nodePos-1
		#puts "DeleteTreeNode:::::node->$node"

		set exist [$updatetree exists $node]	
		if {$exist} { 
			#has OBD node continue processing
		} else {
			#does not have any OBD exit from procedure		
			return
		}
	}
	#gets the nodeId and Type of selected node
	set result [GetNodeIdType $node]
	if {$result != "" } {
		set nodeId [lindex $result 0]
		set nodeType [lindex $result 1]
	} else {
		#must be some other node this condition should never reach
		#puts "\n\nDeleteTreeNode->SHOULD NEVER HAPPEN\n\n"
		return
	}
	
	set nodeList ""
	set nodeList [GetNodeList]
	#puts nodeList->$nodeList...
	if {[lsearch -exact $nodeList $node ]!=-1} {
		set result [tk_messageBox -message "Do you want to delete node?" -type yesno -icon question -title "Question" -parent .]
   		 switch -- $result {
   		     yes {			 
   		         #continue with process
   			}
   		     no {
   			     return
			}
   		}	

		if {$nodeType == 0} {
			#it is a MN so clear up the memory
		#	#ocfmRetCode DeleteMNObjDict(int NodeID);
		#	puts "DeleteMNObjDict nodeId->$nodeId"
		#	#set catchErrCode [DeleteMNObjDict $nodeId]
		#	set catchErrCode [DeleteNodeObjDict $nodeId $nodeType] ; #THIS WORK FOR BOTH IMPLEMENT IT AFTER CODE COMMIT
			set catchErrCode [DeleteNodeObjDict $nodeId $nodeType]
		} elseif {$nodeType == 1} {
			#it is a CN so delete the node entirely
		#	puts "DeleteNode nodeId->$nodeId nodeType->$nodeType"
			set catchErrCode [DeleteNode $nodeId $nodeType]
		} else {
		#	puts "\n\n\tDeleteTreeNode:invalid nodeType->$nodeType"
			return
		}



		#node is deleted need to save
		set status_save 1


		#freeing memory
		if {[string match "OBD*" $node]} {
			#should not delete nodeId, obj, objNode from list since it is mn
		} else {
			set nodeIdList [DeleteList $nodeIdList $nodeId 0]		
			#puts "after deletion nodeIdList->$nodeIdList "		
		}

		#to clear the list from child of the node from saved value list
		CleanList $node 0
		CleanList $node 1

	} else {
	
		set res []
		set idxNode [$updatetree selection get]
		if {[string match "*SubIndexValue*" $node]} {
			#gets SubIndexId of selected node
			set sidx [string range [$updatetree itemcget $node -text] end-2 end-1 ]
			#puts sidx->$sidx
			if { $sidx == "00" } {
				#should not allow to delete 00 subindex
				tk_messageBox -message "Do not delete SubIndex 00" -parent .
				return
			}

			#gets the IndexId of selected SubIndex
			set idxNode [$updatetree parent $node]
			set idx [string range [$updatetree itemcget $idxNode -text] end-4 end-1 ]

			#puts "\n    DeleteSubIndex $nodeId $nodeType $idx $sidx\n"
			set catchErrCode [DeleteSubIndex $nodeId $nodeType $idx $sidx]
		} elseif {[string match "*IndexValue*" $node]} {
			#gets the IndexId of selected Index			
			set idx [string range [$updatetree itemcget $idxNode -text] end-4 end-1 ]
			#puts "\n      DeleteIndex $nodeId $nodeType $idx\n"
			set catchErrCode [DeleteIndex $nodeId $nodeType $idx]
		} else {
			#puts "\n\n       DeleteTreeNode->Invalid cond 2!!!\n\n"
			return
		}
		#clear the savedValueList of the deleted node
		set savedValueList [DeleteList $savedValueList $node 0]
		
		puts "\nbefore delete userPrefList->$userPrefList\n"
		set userPrefList [DeleteList $userPrefList $node 1]
		puts "\nafter delete userPrefList->$userPrefList\n"
		
	}

	#puts "catchErrCode->$catchErrCode"
	set ErrCode [ocfmRetCode_code_get $catchErrCode]
	#puts "ErrCode:$ErrCode"
	if { $ErrCode != 0 } {
		#tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
		if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .
		} else {
			tk_messageBox -message "Unknown Error" -title Warning -icon warning -parent .
                        puts "Unknown Error in DeleteTreeNode->[ocfmRetCode_errorString_get $catchErrCode]\n"
		}
		return
	}

	#index or subindex is deleted need to save
	set status_save 1

	set parent [$updatetree parent $node]
	set nxtSelList [$updatetree nodes $parent]

	# to highlight the next logical node after the deleted node
	if {[llength $nxtSelList] == 1} {
		#it is the only node so select parent
		$updatetree selection set $parent
		#if TPDO or RPDO is selected Gui should be deleted before calling procedure Editor::SingleClickNode
		catch {$updatetree delete $node}
		ResetPromptFlag
		Editor::SingleClickNode $parent
		return
	} else {
		set nxtSelCnt [expr [lsearch $nxtSelList $node]+1]
		if {$nxtSelCnt >= [llength $nxtSelList]} {
			#it is the last node select previous node
			set nxtSelCnt [expr $nxtSelCnt-2]
		} elseif { $nxtSelCnt > 0 } {
			#select next node since nxtSelCnt already incremented do nothing
		} else {
			#puts "DeleteTreeNode->Invalid cond 2"
		}
			catch {set nxtSel [lindex $nxtSelList $nxtSelCnt] }
			catch {$updatetree selection set $nxtSel}
			catch {$updatetree delete $node}
			#should display logical next node after deleting currently highlighted node
			ResetPromptFlag
			Editor::SingleClickNode $nxtSel
			return
	}
	catch {$updatetree delete $node}
	#puts "*************$xdcId"
}

################################################################################################
#proc DeleteList
#Input       : -
#Output      : -
#Description : searches a variable in list if present delete it 
#	       used for deleting nodeId from nodeIdlist
################################################################################################
proc DeleteList {tempList deleteVar choice} {
	if { $choice == 0 } {
		set res [lsearch $tempList $deleteVar]
	} elseif { $choice == 1 } {
		set res [lsearch $tempList [list $deleteVar *]]
	} else {
		
	}
	if {$res != -1} {
		if {$res == 0} {
			set resList [lrange $tempList 1 end]
			return $resList
		} else {
			set resList [lrange $tempList 0 [expr $res-1] ]
			foreach tempVar [lrange $tempList [expr $res+1] end ] {
				lappend resList $tempVar
			}
			return $resList
		}
	}
	#puts "no match to delete from list"
	return $tempList
}

################################################################################################
#proc CleanList
#Input       : node
#Output      : -
#Description : searches the savedValueList and deletes the node under it if they are present
#	       
################################################################################################
proc CleanList {node choice} {
	global savedValueList
	global userPrefList

	if { $choice == 0 } {
		#called for cleaning savedValueList
		set tempList $savedValueList
	} elseif { $choice == 1 } {
		set tempList $userPrefList
		puts "\nb4 delete userPrefList->$userPrefList\n"
	} else {
		#invalid choice
		return 
	}
#puts "bef clean savedValueList->$savedValueList"

	set tempFinalList ""
	set matchNode [split $node -]
	set matchNode [lrange $matchNode 1 end]
	set matchNode [join $matchNode -]
	#puts "matchNode->$matchNode"
	foreach tempValue $tempList {
		if { $choice == 0 } {
			set testValue $tempValue
		} else {
			set testValue [lindex $tempValue 0]
			puts "testValue->$testValue"
		}
			
		if {[string match "*SubIndexValue*" $testValue]} {
			set tempMatchNode *-$matchNode-*-*
		} elseif {[string match "*IndexValue*" $testValue]} {
			set tempMatchNode *-$matchNode-*
		} else {
			#other than IndexValue and SubIndexValue no node should occur
		}
#puts "tempMatchNode->$tempMatchNode tempValue->$tempValue match->[string match $tempMatchNode $tempValue]"
		if {[string match $tempMatchNode $testValue]} {
			#matched so dont copy it
		} else {
			lappend tempFinalList $tempValue
		}
	}
	

	if { $choice == 0 } {
		set savedValueList $tempFinalList

	} else {
		set userPrefList $tempFinalList
		puts "\nafter delete userPrefList->$userPrefList\n"
	}

#puts "aft clean savedValueList->$savedValueList"

#tk_messageBox
}

################################################################################################
#proc NodeCreate
#Input       : -
#Output      : pointer to object
#Description : creates an object for node
################################################################################################
proc NodeCreate {NodeID NodeType NodeName} {

#puts "\n\n      NodeCreate"




	set objNode [new_CNode]
	set objNodeCollection [new_CNodeCollection]
	set objNodeCollection [CNodeCollection_getNodeColObjectPointer]
	#puts "errorString->$errorString...NodeType->$NodeType...NodeID->$NodeID..."
	#puts $NodeType
	set catchErrCode [new_ocfmRetCode]
	#puts "CreateNode NodeID->$NodeID NodeType->$NodeType"
	set catchErrCode [CreateNode $NodeID $NodeType $NodeName]
	#puts "catchErrCode->$catchErrCode"
	set ErrCode [ocfmRetCode_code_get $catchErrCode]
	#puts "ErrCode:$ErrCode"
	if { $ErrCode != 0 } {
		#puts "ErrStr:[ocfmRetCode_errorString_get $catchErrCode]"
		#tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
		#NO NEED TO DISPLAY HERE CALLING FUNCTION WILL DISPLAY THEM
		#tk_messageBox -message "ErrCode : $ErrCode" -title Warning -icon warning
		return $catchErrCode 
	}
	return $catchErrCode 
}

################################################################################################
#proc GetNodeList
#Input       : -
#Output      : pointer to object
#Description : creates an object for node
################################################################################################
proc GetNodeList {} {
	global updatetree

	foreach mnNode [$updatetree nodes PjtName] {
		
		#puts "mnNode->$mnNode"
		set chk 1
		foreach cnNode [$updatetree nodes $mnNode] {
			if {$chk == 1} {
				if {[string match "OBD*" $cnNode]} {
					lappend nodeList $cnNode
				} else {
					lappend nodeList " " $cnNode
				}
				set chk 0
			} else {
				lappend nodeList $cnNode
			}
		}
	}

	#puts "\n\t in GetNodeList nodeList->$nodeList"
	return $nodeList
}
################################################################################################
#proc GetNodeIdType
#Input       : node
#Output      : node Id and nodeType
#Description : 
################################################################################################
proc GetNodeIdType {node} {
	global updatetree
	global nodeIdList

	puts node->$node
	if {[string match "*SubIndex*" $node]} {
		set parent [$updatetree parent [$updatetree parent $node]]
		if {[string match "?Pdo*" $node]} {
			#it must be subindex in TPDO orRPDO
			set parent [$updatetree parent [$updatetree parent $parent]]
		} else {
			#must be subindex which is not a TPDO or RPDO
		}
	} elseif {[string match "*Index*" $node]} {
		set parent [$updatetree parent $node]
		if {[string match "?Pdo*" $node]} {
			#it must be index in TPDO or RPDO
			set parent [$updatetree parent [$updatetree parent $parent]]
		} else {
			#must be index which is not a TPDO or RPDO
		}
	} elseif {[string match "TPDO-*" $node] || [string match "RPDO-*" $node]} {
		#it must be either TPDO or RPDO
		set parent [$updatetree parent $node]
		set parent [$updatetree parent $parent]
	} elseif {[string match "PDO-*" $node]} {
		set parent [$updatetree parent $node]	
	} elseif {[string match "OBD-*" $node] || [string match "CN-*" $node]} {
		set parent $node
	} else {
		puts "\n\nmust be root, PjtName or PDO\n\n"
		#puts "\n\n  GetNodeIdType->must be root, PjtNmae or PDO passed node->$node\n\n"  
		return
	}

	#puts "parent->$parent"
	set nodeList []
	set nodeList [GetNodeList]
	set searchCount [lsearch -exact $nodeList $parent ]
	set nodeId [lindex $nodeIdList $searchCount]
#puts  "searchCount->$searchCount=======nodeList->$nodeList======nodeIdList->$nodeIdList=====nodeId->$nodeId"
	if {[string match "OBD*" $parent]} {
		#it must be a mn
		set nodeType 0
	} else {
		#it must be cn
		set nodeType 1
	}
	#puts "GetNodeIdType->nodeId$nodeId===nodeType->$nodeType"
	return [list $nodeId $nodeType]

}


################################################################################################
#proc ArrowUp
#Input       : -
#Output      : -
#Description : Traversal for tree window
################################################################################################

proc ArrowUp {} {
	global updatetree
	set node [$updatetree selection get]
	#puts "AU node->$node"
	if { $node == "" || $node == "root" || $node == "PjtName" } {
		$updatetree selection set "PjtName"
		$updatetree see "PjtName"
		return
	}
	set parent [$updatetree parent $node]
	set siblingList [$updatetree nodes $parent]
	set cnt [lsearch -exact $siblingList $node]
#puts "AU parent->$parent \t siblingList_>$siblingList \t cnt->$cnt"
	if { $cnt == 0} {
		#there is no node before it so select parent
		$updatetree selection set $parent
		$updatetree see $parent
	} else {
		set sibling  [lindex $siblingList [expr $cnt-1] ]
#puts "AU sibling->$sibling \t open->[$updatetree itemcget $sibling -open]"
		if {[$updatetree itemcget $sibling -open] == 0 || ( [$updatetree itemcget $sibling -open] == 1 && [$updatetree nodes $sibling] == "" )} {
			$updatetree selection set $sibling
			$updatetree see $sibling
			return
		} else {
#puts "AU siblingList->$siblingList"
			set siblingList [$updatetree nodes $sibling]
			if {[$updatetree itemcget [lindex $siblingList end] -open] == 1 && [$updatetree nodes [lindex $siblingList end] ] != "" } {
				_ArrowUp [lindex $siblingList end]
			} else {			
				$updatetree selection set [lindex $siblingList end]
				$updatetree see [lindex $siblingList end]
				return
			}	
		}
	}
}

proc _ArrowUp {node} {
	global updatetree

#puts "-AU node->$node \t open->$[$updatetree itemcget $node -open]"
	if {[$updatetree itemcget $node -open] == 0 || ( [$updatetree itemcget $node -open] == 1 && [$updatetree nodes $node] == "" )} {
		$updatetree selection set $node
		$updatetree see $node
		return
	} else {
		
		set siblingList [$updatetree nodes $node]
#puts "-AU siblingList->$siblingList open->[$updatetree itemcget [lindex $siblingList end] -open]"
		if {[$updatetree itemcget [lindex $siblingList end] -open] == 1 && [$updatetree nodes [lindex $siblingList end] ] != "" } {
			_ArrowUp [lindex $siblingList end]
		} else {			
			$updatetree selection set [lindex $siblingList end]
			$updatetree see [lindex $siblingList end]
			return
		}	
	}
}
################################################################################################
#proc ArrowDown
#Input       : -
#Output      : -
#Description : Traversal for tree window
################################################################################################

proc ArrowDown {} {
	global updatetree
	set node [$updatetree selection get]
	#puts "AD node->$node"
	if { $node == "" || $node == "root" } {
		return
	}
	#if {$node == "root" } {
	#	return
	#}
#puts "AD open->[$updatetree itemcget $node -open]"
	if {[$updatetree itemcget $node -open] == 0 || ( [$updatetree itemcget $node -open] == 1 && [$updatetree nodes $node] == "" )} {
		set parent [$updatetree parent $node]
		set siblingList [$updatetree nodes $parent]
		set cnt [lsearch -exact $siblingList $node]
#puts "AD parent->$parent \t siblingList->$siblingList \t cnt->$cnt"
		if { $cnt == [expr [llength $siblingList]-1 ]} {
			_ArrowDown $parent $node
		} else {
			$updatetree selection set [lindex $siblingList [expr $cnt+1] ]
			$updatetree see [lindex $siblingList [expr $cnt+1] ]
			return
		}
	} else {
		set siblingList [$updatetree nodes $node]
#puts "AD siblingList->$siblingList"
		$updatetree selection set [lindex $siblingList 0]
		$updatetree see [lindex $siblingList 0]
		return
	}


}



proc _ArrowDown {node origNode} {
	global updatetree
	#puts "-arrowDown node->$node origNode->$origNode"
	if { $node == "root" } {
		$updatetree selection set $origNode
		$updatetree see $origNode
		return
	}
	set parent [$updatetree parent $node]

	set siblingList [$updatetree nodes $parent]
	set cnt [lsearch -exact $siblingList $node]
#puts "-AD parent->$parent \t siblingList->$siblingList \t cnt->$cnt \t length of siblingList->[llength $siblingList]"
	if { $cnt == [expr [llength $siblingList]-1 ]} {
		_ArrowDown $parent $origNode
	} else {
		$updatetree selection set [lindex $siblingList [expr $cnt+1] ]
		$updatetree see [lindex $siblingList [expr $cnt+1] ]
		return
	}

}

################################################################################################
#proc ArrowLeft
#Input       : -
#Output      : -
#Description : Traversal for tree window
################################################################################################
proc ArrowLeft {} {
	global updatetree
	set node [$updatetree selection get]
	if {[$updatetree nodes $node] != "" } {
		$updatetree itemconfigure $node -open 0		
	} else {
		# it has no child no need to collapse
	}
}

################################################################################################
#proc ArrowRight
#Input       : -
#Output      : -
#Description : Traversal for tree window
################################################################################################
proc ArrowRight {} {
	global updatetree
	set node [$updatetree selection get]
	if {[$updatetree nodes $node] != "" } {	
		$updatetree itemconfigure $node -open 1		
	} else {
		# it has no child no need to expand
	}

}

################################################################################################
#proc AutoGenerateMNOBD
#Input       : -
#Output      : -
#Description : AutoGenerates the MN OBD and populates the tree.
################################################################################################

proc AutoGenerateMNOBD {} {
	global updatetree
	global nodeIdList
	global status_save

	set node [$updatetree selection get]
	if {[string match "MN*" $node]} {
		set child [$updatetree nodes $node]
		set tmpNode [string range $node 2 end]
		# since a MN has only one OBD so -1 is appended
		set node OBD$tmpNode-1

		# check whether import is first time or not 
		#so as to add OBD icon in GUI
		set res [lsearch $child "OBD$tmpNode-1*"]
		#puts "in reimport res -> $res"
		#puts "child->$child"

		set nodeId 240
		set nodeType 0
		#if { $res == -1} {
		#	$updatetree insert 0 MN$tmpNode OBD$tmpNode -text "OBD" -open 0 -image [Bitmap::get pdo]
		#}
	} else {
		set result [GetNodeIdType $node]
		if {$result != "" } {
			set nodeId [lindex $result 0]
			set nodeType [lindex $result 1]
		} else {
			#must be some other node this condition should never reach
			#puts "\n\nDeleteTreeNode->SHOULD NEVER HAPPEN\n\n"
			return
		}

	}	
	set tmpImpDir .
	if {$tmpImpDir != ""} {
		set result [tk_messageBox -message "Do you want to Auto Generate object dictionary for MN ?" -type yesno -icon question -title "Question" -parent .]
   		 switch -- $result {
   		     yes {
			   conPuts "Auto Generating object dictionary for MN"
			 }			 
   		     no  {
			   conPuts "Auto Generate is cancelled for MN"
			   return
			 }
   		}
		set catchErrCode [GenerateMNOBD]		
		
		#puts "catchErrCode in reimport ->$catchErrCode"
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		#puts "ErrCode:$ErrCode"
		if { $ErrCode != 0 } {
			#tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
			if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
				tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .
			} else {
				tk_messageBox -message "Unknown Error" -title Warning -icon warning -parent .
			        puts "Unknown Error ->[ocfmRetCode_errorString_get $catchErrCode]\n"
			}
			return
		} else {
			#conPuts "ReImported $tmpImpDir for Node ID:$nodeId"
		}

		#OBD for MN is auto generated need to save
		set status_save 1

		catch {
			if { $res == -1} {
				#there can be one OBD in MN so -1 is hardcoded
				$updatetree insert 0 MN$tmpNode OBD$tmpNode-1 -text "OBD" -open 0 -image [Bitmap::get pdo]
			}
		}
		#catch {FreeNodeMemory $node} ; # no need to free memory
		catch {$updatetree delete [$updatetree nodes $node]}
		$updatetree itemconfigure $node -open 0
		
		thread::send -async [tsv::set application importProgress] "StartProgress"
		#Import parentNode nodeType nodeID 
		Import $node $nodeType $nodeId
		thread::send -async [tsv::set application importProgress] "StopProgress"
		
		#to clear the list from child of the node from savedvaluelist and userpreflist
		CleanList $node 0
		CleanList $node 1
		
	}
	#puts "**********\n"
}

proc generateAutoName {Dir Name ext} {
	#should check for extension but should send back unique name without extension
	for {set inc 1} {1} {incr inc} {
		set autoName $Name$inc$ext
		if {![file exists [file join $Dir $autoName]]} {
			break;
		}
	}
	return $Name$inc
}
