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

source $RootDir/windows.tcl
source $RootDir/validation.tcl

##
# For Tablelist Package
##
set path_to_Tablelist ./tablelist4.10
lappend auto_path $path_to_Tablelist

package require Tablelist

set dir [file dirname [info script]]
source [file join $dir option.tcl]

global PjtDir 
global PjtName

variable status_run
set status_run 0
set cnCount 0
set mnCount 0
set nodeIdList ""

###############################################################################################

namespace eval Editor {
    	variable initDone 0
    	variable _wfont
    	variable notebook
    	variable list_notebook
    	variable con_notebook
    	variable pw1
    	variable pw2
    	variable procWindow
    	variable markWindow
    	variable mainframe
    	variable status
    	variable prgtext
    	variable prgindic
    	variable font
    	variable font_name
    	variable Font_var
    	variable FontSize_var
    	variable toolbar1  1
    	variable toolbar2  0
    	variable showConsoleWindow 1
    	variable sortProcs 1
    	variable showProc 1
    	variable checkNestedProc 1
    	variable showProcWindow 1
    	variable current
    	variable last
    	variable text_win
    	variable index_counter 0
    	variable index
    	variable slaves
    	variable startTime [clock seconds]
    	variable options
    	variable lineNo
    	variable lineEntryCombo
    	variable toolbarButtons
    	variable searchResults
    	variable procMarks
    	variable mnMenu
    	variable cnMenu
    	variable projMenu    
    	variable obdMenu    
    	variable idxMenu    
    	variable mnCount
    	variable cnCount
    	variable serverUp 0
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
    	label $aboutWindow.l_msg -image [Bitmap::get info] -compound left -text "\n      openCONFIGURATOR Tool           \n       Designed by       \nKalycito Infotech Private Limited.  \n"
    	button $aboutWindow.bt_ok -text Ok -command "destroy $aboutWindow"
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
    	 	-icon info
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
    	showProcWin $EditorData(options,showProcs)
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
	if [regexp {PjtName(.*)} $node == 1] {
		tk_popup $Editor::projMenu $x $y 
	} elseif [regexp {CN-(.*)} $node == 1] {
		tk_popup $Editor::cnMenu $x $y 
	} elseif {[regexp {MN-(.*)} $node == 1]} { 
		tk_popup $Editor::mnMenu $x $y	
	} elseif {[regexp {OBD-(.*)} $node == 1]} { 
		tk_popup $Editor::obdMenu $x $y	
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
    puts show->$show
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
    variable serverUp
    global TotalTestCase
    global PjtDir
    global PjtName
    global status_run
    set EditorData(options,History) "$PjtDir"
    if { $status_run == 1 } {
	Editor::RunStatusInfo
	return
    }
    if {$PjtDir != "None"} {
	#Prompt for Saving the Existing Project
		set result [tk_messageBox -message "Save Project $PjtName ?" -type yesnocancel -icon question -title 			"Question"]
   		 switch -- $result {
   		     yes {			 
   		         #saveproject
   		     }
   		     no  {conPuts "Project $PjtName not saved" info}
   		     cancel {
				conPuts "Exit Canceled" info
				return}
   		}
    }

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
	global pageopened_list
	global status_run
	if { $status_run == 1 } {
		Editor::RunStatusInfo
		return
	}

	if {$PjtDir != "None"} {
		#Prompt for Saving the Existing Project
			set result [tk_messageBox -message "Save Project $PjtName ?" -type yesnocancel -icon question -title 			"Question"]
	   		switch -- $result {
	   		     yes {
				#conPuts "Project $PjtName Saved" info
				#saveproject
				}
	   		     no  {
				#conPuts "Project $PjtName Not Saved" info
				}
	   		     cancel {
				#conPuts "Open Project Canceled" info
				return
				}
	   		}
	}
	set types {
        {"All Project Files"     {*.oct } }
	}
	########### Before Closing Write the Data to the file ##########

	# Validate filename
	set projectfilename [tk_getOpenFile -filetypes $types -parent .]
        if {$projectfilename == ""} {
                return
        }
	set tmpsplit [split $projectfilename /]
	set PjtName [lindex $tmpsplit [expr [llength $tmpsplit] - 1]]
	puts "Project name->$PjtName"
	set ext [file extension $projectfilename]
	    if { $ext != "" } {
	        if {[string compare $ext ".pjt"]} {
		    set PjtDir None
		    tk_messageBox -message "Extension $ext not supported" -title "Open Project Error" -icon error
		    return
	        }
	    }
	set PjtDir [file dirname $projectfilename]
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
    	variable idxMenu
    	variable sidxMenu	
    
    
    
	set result [catch {source [file join $RootDir/plk_configtool.cfg]} info]
	variable configError $result
   
	set prgtext "Please wait while loading ..."
	set prgindic -1
	_create_intro
	update
	
	# Menu description
	set descmenu {
		"&File" {} {} 0 {           
       			{command "New &Project" {} "New Project" {Ctrl n}  -command NewProjectWindow}
			{command "Open Project" {}  "Open Project" {Ctrl o} -command openproject}
	        	{command "Save Project" {noFile}  "Save Project" {Ctrl s} -command YetToImplement}
	        	{command "Save Project as" {noFile}  "Save Project as" {} -command SaveProjectAsWindow}
			{command "Close Project" {}  "Close Project" {} -command CloseProject}                 
	    		{separator}
            		{command "E&xit" {}  "Exit openCONFIGURATOR" {Alt x} -command Editor::exit_app}
        	}
        	"&Project" {} {} 0 {
            		{command "Build Project    F7" {noFile} "Generate CDC and XML" {} -command BuildProject }
            		{command "Rebuild Project  Ctrl+F7" {noFile} "Clean and Build" {} -command YetToImplement }
	    		{command "Clean Project" {noFile} "Clean" {} -command YetToImplement }
	    		{command "Stop Build" {}  "Reserved" {} -command YetToImplement -state disabled}
            		{separator}
            		{command "Project Settings" {}  "Project Settings" {} -command YetToImplement }
        	}
        	"&Connection" all options 0 {
            		{command "Connect to POWERLINK network" {connect} "Establish connection with POWERLINK network" {} -command Editor::Connect }
            		{command "Disconnect from POWERLINK network" {disconnect} "Disconnect from POWERLINK network" {} -command Editor::Disconnect -state disabled }
	    		{separator}
            		{command "Connection Settings" {}  "Connection Settings" {} -command ConnectionSettingWindow -state normal}
        	}
        	"&Actions" all options 0 {
        		{command "SDO Read/Write" {noFile} "Do SDO Read or Write" {} -command YetToImplement -state disabled}
            		{command "Transfer CDC   Ctrl+F5" {noFile} "Transfer CDC" {} -command TransferCDC }
            		{command "Transfer XML   Ctrl+F6" {noFile} "Transfer XML" {} -command YetToImplement }
	    		{separator}
            		{command "Start MN" {noFile} "Start the Managing Node" {} -command YetToImplement }
            		{command "Stop MN" {noFile} "Transfer CDC" {} -command YetToImplement }
            		{command "Reconfigure MN" {noFile} "Transfer XML" {} -command YetToImplement }
	    		{separator}
            		{command "Configure SDO connection" {}  "Reserved" {} -command YetToImplement -state disabled}
            		{command "Configure CDC Transfer" {}  "Reserved" {} -command YetToImplement -state disabled}
            		{command "Configure XML Transfer" {}  "Reserved" {} -command YetToImplement -state disabled}
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
                		-variable Editor::options(showProcs)
                		-command  {set EditorData(options,showProcs) $Editor::options(showProcs)
                    			Editor::showTreeWin $EditorData(options,showProcs)
                    			update idletasks
                		}
            		}
            		{checkbutton "Solely Console" {all option} "Only Console Window" {}
                		-variable Editor::options(solelyConsole)
                		-command  {set EditorData(options,solelyConsole) $Editor::options(solelyConsole)
                    			Editor::showSolelyConsole $EditorData(options,solelyConsole)
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
    	set Editor::options(showProcs) 1
    	set Editor::options(showConsole) 1
	#shortcut keys for project
	bind . <Key-F7> "BuildProject"
	bind . <Control-Key-F7> "YetToImplement"
	bind . <Control-Key-F5> "YetToImplement"
	bind . <Control-Key-F6> "YetToImplement"
	bind . <Control-Key-f> "FindDynWindow"
	bind . <Control-Key-F> "FindDynWindow"
	bind . <KeyPress-Escape> "EscapeTree"
	#bind . <Delete> "puts Delete_key_pressed"
	#############################################################################
	# Menu for the Controlled Nodes
	#############################################################################

	set Editor::cnMenu [menu  .cnMenu -tearoff 0]
	set Editor::IndexaddMenu .cnMenu.indexaddMenu
	$Editor::cnMenu add command -label "Rename" \
		 -command {set cursor [. cget -cursor]
			YetToImplement
			#DoubleClickNode ""
		 }
	$Editor::cnMenu add cascade -label "Add" -menu $Editor::IndexaddMenu
	menu $Editor::IndexaddMenu -tearoff 0
	$Editor::IndexaddMenu add command -label "Add Index" -command "AddIndexWindow"
	$Editor::IndexaddMenu add command -label "Add PDO Objects" -command {AddPDOWindow}   
	$Editor::cnMenu add command -label "Import XDC/XDD" -command {ReImport}
	$Editor::cnMenu add separator
	$Editor::cnMenu add command -label "Delete" -command {DeleteTreeNode}

	#############################################################################
	# Menu for the Managing Nodes
	#############################################################################
	set Editor::mnMenu [menu  .mnMenu -tearoff 0]
	$Editor::mnMenu add command -label "Add CN" -command "AddCNWindow" 
	$Editor::mnMenu add command -label "Import XDC/XDD" -command "ReImport"
	$Editor::mnMenu add separator
	$Editor::mnMenu add command -label "Auto Generate" -command {YetToImplement} 

	#############################################################################
	# Menu for the Project
	#############################################################################

	set Editor::projMenu [menu  .projMenu -tearoff 0]
	$Editor::projMenu add command -label "Sample Project" -command "YetToImplement" 
	$Editor::projMenu add command -label "New Project" -command "NewProjectWindow" 
	$Editor::projMenu add command -label "Open Project" -command "YetToImplement" 

	#############################################################################
	# Menu for the object dictionary
	#############################################################################
	set Editor::obdMenu [menu .obdMenu -tearoff 0]
	$Editor::obdMenu add separator 
	$Editor::obdMenu add command -label "Add Index" -command "AddIndexWindow"   
	$Editor::obdMenu add separator  

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
	        -menu $descmenu  \
        	-textvariable Editor::status ]
	$mainframe showstatusbar status

    	# toolbar 1 creation
	set tb1  [MainFrame::addtoolbar $mainframe]
	pack $tb1 -expand yes -fill x
	set bbox [ButtonBox::create $tb1.bbox1 -spacing 0 -padx 1 -pady 1]
	set toolbarButtons(new) [ButtonBox::add $bbox -image [Bitmap::get page_white] \
	        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	        -helptext "Create new project" -command NewProjectWindow]
	set toolbarButtons(save) [ButtonBox::add $bbox -image [Bitmap::get disk] \
	        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	        -helptext "Save Project" -command YetToImplement]
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
	
	set bbox [ButtonBox::create $tb1.bbox2 -spacing 0 -padx 4 -pady 1]
	set bb_start [ButtonBox::add $bbox -image [Bitmap::get start] \
            	-height 21\
            	-width 21\
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Start stack" -command {YetToImplement}]
	pack $bb_start -side left -padx 4
	pack $bbox -side left -anchor w -padx 2
	
	set bbox [ButtonBox::create $tb1.bbox3 -spacing 1 -padx 1 -pady 1]
	
	set bb_stop [ButtonBox::add $bbox -image [Bitmap::get stop]\
            	-height 21\
            	-width 21\
            	-helptype balloon\
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Stop stack"\
	   	 -command "YetToImplement"]
	pack $bb_stop -side left -padx 4

	set bb_reconfig [ButtonBox::add $bbox -image [Bitmap::get reconfig]\
            	-height 21\
           	-width 21\
            	-helptype balloon\
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Reconfigure stack"\
    	    	-command "YetToImplement"]
	pack $bb_reconfig -side left -padx 4
	pack $bbox -side left -anchor w
	
	set sep1 [Separator::create $tb1.sep1 -orient vertical]
	pack $sep1 -side left -fill y -padx 4 -anchor w
	
	set bbox [ButtonBox::create $tb1.bbox4 -spacing 1 -padx 1 -pady 1]
	pack $bbox -side left -anchor w
	set bb_cdc [ButtonBox::add $bbox -image [Bitmap::get transfercdc]\
            	-height 21\
            	-width 21\
            	-helptype balloon\
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Transfer CDC"\
    	    	-command TransferCDC]
	pack $bb_cdc -side left -padx 4
	set bb_xml [ButtonBox::add $bbox -image [Bitmap::get transferxml]\
            	-height 21\
            	-width 21\
            	-helptype balloon\
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Transfer XML"\
    	    	-command "YetToImplement"]
	pack $bb_xml -side left -padx 4
	
	set sep2 [Separator::create $tb1.sep2 -orient vertical]
	pack $sep2 -side left -fill y -padx 4 -anchor w

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
	set bb_rebuild [ButtonBox::add $bbox -image [Bitmap::get rebuild]\
	    	-height 21\
	        -width 21\
	        -helptype balloon\
	        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	        -helptext "Rebuild Project"\
		-command "YetToImplement"]
	pack $bb_rebuild -side left -padx 4
	set bb_clean [ButtonBox::add $bbox -image [Bitmap::get clean]\
	    	-height 21\
    		-width 21\
	        -helptype balloon\
	        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	        -helptext "clean Project"\
    		-command "YetToImplement"]
	pack $bb_clean -side left -padx 4
	
	set sep3 [Separator::create $tb1.sep3 -orient vertical]
	pack $sep3 -side left -fill y -padx 4 -anchor w
	
	set bbox [ButtonBox::create $tb1.bbox6 -spacing 1 -padx 1 -pady 1]
	pack $bbox -side left -anchor w
	set bb_connect [ButtonBox::add $bbox -image [Bitmap::get connect]\
	    	-height 21\
    		-width 21\
	        -helptype balloon\
	        -helptext "connection"\
	    	-command Editor::TogConnect ]
	pack $bb_connect -side left -padx 4  

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

	set sep4 [Separator::create $tb1.sep4 -orient vertical]
	pack $sep4 -side left -fill y -padx 4 -anchor w 
   
	$Editor::mainframe showtoolbar 0 $Editor::toolbar1
	set temp [MainFrame::addindicator $mainframe -textvariable Editor::connect_status ]
	set Editor::connect_status "Disconnected from IP :0.0.0.0"
	$temp configure -relief flat 
	# NoteBook creation
	set frame	[$mainframe getframe]
	
	set pw1 [PanedWindow::create $frame.pw1 -side left]
	set pane [PanedWindow::add $pw1 ]
	set pw2 [PanedWindow::create $pane.pw2 -side top]
	
	set pane1 [PanedWindow::add $pw2 -minsize 250 ]
	set pane2 [PanedWindow::add $pw2 -minsize 100]
	set pane3 [PanedWindow::add $pw1 -minsize 100]

	set list_notebook [NoteBook::create $pane1.nb]
	set notebook [NoteBook::create $pane2.nb]	
	set con_notebook [NoteBook::create $pane3.nb]
	
	set pf1 [EditManager::create_treeWindow $list_notebook]
	set treeWindow $pf1.sw.objTree
	# Binding on tree widget   
	$treeWindow bindText <ButtonPress-1> Editor::DoubleClickNode
	#$treeWindow bindText <Delete> DeleteTreeNode
	$treeWindow bindText <ButtonPress-3> {Editor::tselectright %X %Y}
	#bind .mainframe.frame.pw1.f0.frame.pw2.f0.frame.nb.fobjtree.sw.objTree <Delete> "puts Delete_key_pressed"
	bind $treeWindow <Button-4> {.mainframe.frame.pw1.f0.frame.pw2.f0.frame.nb.fobjtree.sw.objTree yview scroll -5 units}
	bind $treeWindow <Button-5> {.mainframe.frame.pw1.f0.frame.pw2.f0.frame.nb.fobjtree.sw.objTree yview scroll 5 units}
	bind $treeWindow <Enter> { bind . <Delete> DeleteTreeNode ; .mainframe.frame.pw1.f0.frame.pw2.f0.frame.nb.fobjtree.sw.objTree configure -relief sunken }
	bind $treeWindow <Leave> { bind . <Delete> "" ; .mainframe.frame.pw1.f0.frame.pw2.f0.frame.nb.fobjtree.sw.objTree configure -relief ridge }

          
	global EditorData
	global PjtDir
	set PjtDir $EditorData(options,History)

	NoteBook::compute_size $list_notebook
	$list_notebook configure -width 250
	pack $list_notebook -side left -fill both -expand yes -padx 2 -pady 4

	set cf0 [EditManager::create_conWindow $con_notebook "Console" 1]
	set cf1 [EditManager::create_conWindow $con_notebook "Error" 2]
	set cf2 [EditManager::create_conWindow $con_notebook "Warning" 3]

	NoteBook::compute_size $con_notebook
	pack $con_notebook -side bottom -fill both -expand yes -padx 4 -pady 4

	pack $pw1 -fill both -expand yes
	catch {font create TkFixedFont -family Courier -size -12 -weight bold}
	set f0 [EditManager::create_tab $notebook "Index" ind ]
	set f1 [EditManager::create_tab $notebook "Sub index" sub ]
	set f2 [EditManager::create_table $notebook "PDO mapping" "pdo"]
	$f2 columnconfigure 0 -background #e0e8f0 -width 6 -sortmode integer
	$f2 columnconfigure 1 -background #e0e8f0 -width 23
	$f2 columnconfigure 2 -background #e0e8f0 -width 11
	$f2 columnconfigure 3 -background #e0e8f0 -width 11
	$f2 columnconfigure 4 -background #e0e8f0 -width 11
	$f2 columnconfigure 5 -background #e0e8f0 -width 11
	$f2 columnconfigure 6 -background #e0e8f0 -width 11

	NoteBook::compute_size $notebook
	$notebook configure -width 750
	pack $notebook -side left -fill both -expand yes -padx 4 -pady 4
	pack $pw2 -fill both -expand yes

	$list_notebook raise objtree
	$con_notebook raise Console1
	$notebook raise [lindex $f0 1]

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

################################################################################################
#proc Editor::DoubleClickNode
#Input       : node
#Output      : -
#Description : Displays required tabs when corresponding nodes are clicked
################################################################################################
proc Editor::DoubleClickNode {node} {
	global updatetree
	global f0
	global f1
	global f2
	global nodeObj
	global nodeSelect

	variable notebook


	$updatetree selection set $node
	set nodeSelect $node
puts "node====>$node"
	if {[string match "TPDO-*" $node] || [string match "RPDO-*" $node]} {
		set idx [$updatetree nodes $node]
		set popCount 0 
		$f2 delete 0 end
		foreach tempIdx $idx {
			set sidx [$updatetree nodes $tempIdx]
			foreach tempSidx $sidx { 
				puts tempSidx->$tempSidx						
				set tmpnode $tempSidx
				set tmpSplit [split $tmpnode -]
				set xdcId [lrange $tmpSplit 1 end]
				set xdcId [join $xdcId -]
				set xdcIcxId [lrange $tmpSplit 1 [expr [llength $tmpSplit] - 2]]
				set xdcIcxId [join $xdcIcxId -]
				set errorString []
				set NodeID 1
				set NodeType 1
				set indx [lindex $tmpSplit [expr [llength $tmpSplit] - 2]]
				set subId [lindex $tmpSplit end]
				set indexValue [CBaseIndex_getIndexValue $nodeObj($xdcIcxId)]
				set sIdxValue [CBaseIndex_getIndexValue $nodeObj($xdcId)]
				set IndexName [CBaseIndex_getName $nodeObj($xdcId)]
				set IndexObjType [CBaseIndex_getObjectType $nodeObj($xdcId)]
				set IndexDataType [CBaseIndex_getDataType $nodeObj($xdcId)]
				set IndexAccessType [CBaseIndex_getAccessType $nodeObj($xdcId)]
				set IndexDefaultValue [CBaseIndex_getDefaultValue $nodeObj($xdcId)]
				if {[string match "00" $sIdxValue]==0 } {
					set DataSize [string range $IndexDefaultValue 2 5]
					set Offset [string range $IndexDefaultValue 6 9]
					set Reserved [string range $IndexDefaultValue 10 11]
					set listSubIndex [string range $IndexDefaultValue 12 13]
					set listIndex [string range $IndexDefaultValue 14 17]
					$f2 insert $popCount [list $popCount $IndexDefaultValue $listIndex $listSubIndex $Reserved $Offset $DataSize]
					incr popCount 1 
				}
			}
		}
		if {[string match "TPDO-*" $node]} {
			$notebook itemconfigure Page3 -state normal -text "TPDO mapping"
		} else {
			$notebook itemconfigure Page3 -state normal -text "RPDO mapping"
		}
		$notebook raise Page3
		$notebook itemconfigure Page1 -state disabled
		$notebook itemconfigure Page2 -state disabled
		return 
	} else {
	}
	if {[string match "*SubIndex*" $node]} {
		set tmpInnerf0 [lindex $f1 2]
		set tmpInnerf1 [lindex $f1 3]
		set tmpSplit [split $node -]
		set xdcId [lrange $tmpSplit 1 end]
		set xdcId [join $xdcId -]
		set xdcIcxId [lrange $tmpSplit 1 [expr [llength $tmpSplit] - 2]]
		set xdcIcxId [join $xdcIcxId -]
puts "xdcId->$xdcId...xdcIcxId->$xdcIcxId"
		set errorString []
		set NodeID 1
		set NodeType 1
		set indx [lindex $tmpSplit [expr [llength $tmpSplit] - 2]]
		set subId [lindex $tmpSplit end]
		set indexValue [CBaseIndex_getIndexValue $nodeObj($xdcIcxId)]
		set sIdxValue [CBaseIndex_getIndexValue $nodeObj($xdcId)]
		set IndexName [CBaseIndex_getName $nodeObj($xdcId)]
		set IndexObjType [CBaseIndex_getObjectType $nodeObj($xdcId)]
		#set objIndexDataType [CBaseIndex_getDataType $nodeObj($xdcId)]
		#set IndexDataType [DataType_getName $objIndexDataType]
		set IndexDataType "CHECK!!!!!!"
		set IndexAccessType [CBaseIndex_getAccessType $nodeObj($xdcId)]
		#Check for hex data. If not hex, make it null.
		set IndexAccessType [string trimleft $IndexAccessType 0x]
		set IndexAccessType [string trimleft $IndexAccessType 0X]
		if {![string is ascii $IndexAccessType]} {
			puts ErrorStr:$IndexAccessType
			set IndexAccessType []
		}
		set IndexDefaultValue [CBaseIndex_getDefaultValue $nodeObj($xdcId)]
		#Check for hex data. If not hex, make it null.
		set IndexDefaultValue [string trimleft $IndexDefaultValue 0x]
		set IndexDefaultValue [string trimleft $IndexDefaultValue 0X]
		if {![string is xdigit $IndexDefaultValue]} {
			puts ErrorStr:$IndexDefaultValue
			set IndexDefaultValue []
		}
		set IndexActualValue [CBaseIndex_getActualValue $nodeObj($xdcId)]
		set IndexHighLimit [CBaseIndex_getHighLimit $nodeObj($xdcId)]
		set IndexLowLimit [CBaseIndex_getLowLimit $nodeObj($xdcId)]	
		set IndexPdoMap [CBaseIndex_getPDOMapping $nodeObj($xdcId)]
		#set pdoMapList [list NO DEFAULT OPTIONAL RPDO TPDO ]
		#if {$IndexPdoMap >= 0 && IndexPdoMap <= 4} {
		#	set IndexPdoMap [lindex $pdoMapList $IndexPdoMap ]
		#} else {
		#	#returned value out of range
		#}
		$tmpInnerf0.en_idx1 configure -state normal
		$tmpInnerf0.en_idx1 delete 0 end
		$tmpInnerf0.en_idx1 insert 0 $indexValue
		$tmpInnerf0.en_idx1 configure -state disabled

		$tmpInnerf0.en_sidx1 configure -state normal
		$tmpInnerf0.en_sidx1 delete 0 end
		$tmpInnerf0.en_sidx1 insert 0 $sIdxValue
		$tmpInnerf0.en_sidx1 configure -state disabled

		$tmpInnerf0.en_nam1 delete 0 end
		$tmpInnerf0.en_nam1 insert 0 $IndexName

		$tmpInnerf1.en_obj1 configure -state normal
		$tmpInnerf1.en_obj1 delete 0 end
		$tmpInnerf1.en_obj1 insert 0 $IndexObjType
		$tmpInnerf1.en_obj1 configure -state disabled

		$tmpInnerf1.en_data1 configure -state normal
		$tmpInnerf1.en_data1 delete 0 end
		$tmpInnerf1.en_data1 insert 0 $IndexDataType
		$tmpInnerf1.en_data1 configure -state disabled

		$tmpInnerf1.en_access1 configure -state normal
		$tmpInnerf1.en_access1 delete 0 end
		$tmpInnerf1.en_access1 insert 0 $IndexAccessType
		$tmpInnerf1.en_access1 configure -state disabled

		$tmpInnerf1.en_default1 configure -state normal
		$tmpInnerf1.en_default1 delete 0 end
		$tmpInnerf1.en_default1 insert 0 $IndexDefaultValue
		$tmpInnerf1.en_default1 configure -state disabled

		$tmpInnerf1.en_value1 configure -validate none 
		$tmpInnerf1.en_value1 delete 0 end
		$tmpInnerf1.en_value1 insert 0 $IndexActualValue
		$tmpInnerf1.en_value1 configure -validate key -vcmd "IsDec %P $tmpInnerf1.en_value1"

		$tmpInnerf1.en_lower1 configure -state normal
		$tmpInnerf1.en_lower1 delete 0 end
		$tmpInnerf1.en_lower1 insert 0 $IndexLowLimit
		$tmpInnerf1.en_lower1 configure -state disabled

		$tmpInnerf1.en_upper1 configure -state normal
		$tmpInnerf1.en_upper1 delete 0 end
		$tmpInnerf1.en_upper1 insert 0 $IndexHighLimit
		$tmpInnerf1.en_upper1 configure -state disabled

		$tmpInnerf1.en_pdo1 configure -state normal
		$tmpInnerf1.en_pdo1 delete 0 end
		$tmpInnerf1.en_pdo1 insert 0 $IndexPdoMap
		$tmpInnerf1.en_pdo1 configure -state disabled

		$tmpInnerf1.frame1.ra_dec select
		#set hexDec1 dec

		$notebook itemconfigure Page2 -state normal
		$notebook raise Page2
		$notebook itemconfigure Page1 -state disabled
		$notebook itemconfigure Page3 -state disabled
	} elseif {[string match "*Index*" $node]} {
		set tmpInnerf0 [lindex $f0 2]
		set tmpInnerf1 [lindex $f0 3]
		set tmpSplit [split $node -]
		set xdcId [lrange $tmpSplit 1 end]
		set xdcId [join $xdcId -]
puts "xdcId->$xdcId"
		set errorString []
		set NodeID 1
		set NodeType 1
		set indx [lindex $tmpSplit end]
		set indexValue [CBaseIndex_getIndexValue $nodeObj($xdcId)]
		set IndexName [CBaseIndex_getName $nodeObj($xdcId)]
		set IndexObjType [CBaseIndex_getObjectType $nodeObj($xdcId)]
		#set objIndexDataType [CBaseIndex_getDataType $nodeObj($xdcId)]
		#set IndexDataType [DataType_getName $objIndexDataType]
		set IndexDataType "CHECK!!!!!!"
		set IndexAccessType [CBaseIndex_getAccessType $nodeObj($xdcId)]
		#Check for hex data. If not hex, make it null.
		set IndexAccessType [string trimleft $IndexAccessType 0x]
		set IndexAccessType [string trimleft $IndexAccessType 0X]
		if {![string is ascii $IndexAccessType]} {
			puts ErrorStr:$IndexAccessType
			set IndexAccessType []
		}
		set IndexDefaultValue [CBaseIndex_getDefaultValue $nodeObj($xdcId)]
		#Check for hex data. If not hex, make it null.
		set IndexDefaultValue [string trimleft $IndexDefaultValue 0x]
		set IndexDefaultValue [string trimleft $IndexDefaultValue 0X]
		if {![string is xdigit $IndexDefaultValue]} {
			puts ErrorStr:$IndexDefaultValue
			set IndexDefaultValue []
		}
		set IndexActualValue [CBaseIndex_getActualValue $nodeObj($xdcId)]
		set IndexHighLimit [CBaseIndex_getHighLimit $nodeObj($xdcId)]
		set IndexLowLimit [CBaseIndex_getLowLimit $nodeObj($xdcId)]	
		set IndexPdoMap [CBaseIndex_getPDOMapping $nodeObj($xdcId)]
		#set pdoMapList [list NO DEFAULT OPTIONAL RPDO TPDO ]
		#if {$IndexPdoMap >= 0 && IndexPdoMap <= 4} {
		#	set IndexPdoMap [lindex $pdoMapList $IndexPdoMap ]
		#} else {
		#	#returned value out of range
		#}
		$tmpInnerf0.en_idx1 configure -state normal
		$tmpInnerf0.en_idx1 delete 0 end
		$tmpInnerf0.en_idx1 insert 0 $indexValue
		$tmpInnerf0.en_idx1 configure -state disabled

		$tmpInnerf0.en_nam1 delete 0 end
		$tmpInnerf0.en_nam1 insert 0 $IndexName

		$tmpInnerf1.en_obj1 configure -state normal
		$tmpInnerf1.en_obj1 delete 0 end
		$tmpInnerf1.en_obj1 insert 0 $IndexObjType
		$tmpInnerf1.en_obj1 configure -state disabled

		$tmpInnerf1.en_data1 configure -state normal
		$tmpInnerf1.en_data1 delete 0 end
		$tmpInnerf1.en_data1 insert 0 $IndexDataType
		$tmpInnerf1.en_data1 configure -state disabled

		$tmpInnerf1.en_access1 configure -state normal
		$tmpInnerf1.en_access1 delete 0 end
		$tmpInnerf1.en_access1 insert 0 $IndexAccessType
		$tmpInnerf1.en_access1 configure -state disabled

		$tmpInnerf1.en_default1 configure -state normal
		$tmpInnerf1.en_default1 delete 0 end
		$tmpInnerf1.en_default1 insert 0 $IndexDefaultValue
		$tmpInnerf1.en_default1 configure -state disabled

		$tmpInnerf1.en_value1 configure -validate none 
		$tmpInnerf1.en_value1 delete 0 end
		$tmpInnerf1.en_value1 insert 0 $IndexActualValue
		$tmpInnerf1.en_value1 configure -validate key -vcmd "IsDec %P $tmpInnerf1.en_value1"

		$tmpInnerf1.en_lower1 configure -state normal
		$tmpInnerf1.en_lower1 delete 0 end
		$tmpInnerf1.en_lower1 insert 0 $IndexLowLimit
		$tmpInnerf1.en_lower1 configure -state disabled

		$tmpInnerf1.en_upper1 configure -state normal
		$tmpInnerf1.en_upper1 delete 0 end
		$tmpInnerf1.en_upper1 insert 0 $IndexHighLimit
		$tmpInnerf1.en_upper1 configure -state disabled

		$tmpInnerf1.en_pdo1 configure -state normal
		$tmpInnerf1.en_pdo1 delete 0 end
		$tmpInnerf1.en_pdo1 insert 0 $IndexPdoMap
		$tmpInnerf1.en_pdo1 configure -state disabled

		$tmpInnerf1.frame1.ra_dec select

		$notebook itemconfigure Page1 -state normal
		$notebook raise Page1
		$notebook itemconfigure Page2 -state disabled
		$notebook itemconfigure Page3 -state disabled
	} else {
		$notebook itemconfigure Page1 -state disabled
		$notebook itemconfigure Page2 -state disabled
		$notebook itemconfigure Page3 -state disabled
	}
	return
}

################################################################################################
#proc CloseProject
#Input       : -
#Output      : -
#Description : -
################################################################################################
proc CloseProject {} {

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
	incr cnCount
	set child [$updatetree insert end MN-1 CN-1-$cnCount -text "$cnName" -open 0 -image [Bitmap::get cn]]
	set obj [NodeCreate $nodeId 1]
	#lappend nodeIdList CN-1-$cnCount
	lappend nodeIdList $nodeId [lindex $obj 0] [lindex $obj 1]
	if {$tmpImpDir!=0} {
		#API
	set errorString []
	set catchErrCode [ImportXML "$tmpImpDir" 1 $nodeId]
	if { $catchErrCode != 0 } {
		tk_messageBox -message "ENUM:$catchErrCode!" -title Info -icon info
		return
	}
		
		#puts $tmpImpDir
		Import CN-1-$cnCount $tmpImpDir 1 $nodeId [lindex $obj 0] [lindex $obj 1]
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
#proc Editor::TogConnect
#Input       : -
#Output      : -
#Description : Toggles image and calls appropriate procedures for connect and disconect  
################################################################################################
proc Editor::TogConnect {} {
	variable bb_connect
	set tog [$bb_connect cget -image]
	#puts $tog
	#to toggle image the value varies according to images added 
	if {$tog == "image15"} {
		Editor::Connect	       
	} else {
		Editor::Disconnect
	}
}

################################################################################################
#proc Editor::Connect
#Input       : -
#Output      : -
#Description : Enables the menu for connect
################################################################################################
proc Editor::Connect {} {
	variable bb_connect
        variable mainframe
	$bb_connect configure -image [Bitmap::get disconnect]
	$mainframe setmenustate connect disabled
	$mainframe setmenustate disconnect normal
	set Editor::connect_status "Connected to IP :0.0.0.0"
	YetToImplement
}

################################################################################################
#proc Editor::Disconnect
#Input       : -
#Output      : -
#Description : Enables the menu for disconnect
################################################################################################
proc Editor::Disconnect {} {
	variable bb_connect
        variable mainframe
	$bb_connect configure -image [Bitmap::get connect]
	$mainframe setmenustate disconnect disabled
	$mainframe setmenustate connect normal
	set Editor::connect_status "Disconnected from IP :0.0.0.0"
	YetToImplement
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
#Description : Displays GUI for Find
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
#Description : Hides GUI for Find
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

puts "mode->$mode"
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
				
puts "flag 1 in idx ->$tempIdx"	
				}
				if {[string match -nocase "PDO*" $tempIdx]} {
puts "calling pdo"
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
						
puts "flag 1 in pdo idx ->$tempPdoIdx"	
							}
							if {[string match -nocase "*$searchStr*" [$updatetree itemcget $tempPdoIdx -text]] && $chk == 0} {
								#lappend FindSpace::findList $tempIdx
								puts -nonewline "......MATCH idx......"
								if { $mode == 0 } {
									FindSpace::OpenParent $updatetree $tempPdoIdx
									return 1
								} elseif {$mode == "prev" } {
									set prev $tempPdoIdx
puts "prev in pdo idx ->$prev"
								} elseif {$mode == "next" } {
									if {$flag == 0} {
										#do nothing
									} elseif {$flag == 1} {
										set next $tempPdoIdx
puts "next in pdo sidx ->$next"
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
						
puts "flag 1 in idx ->$tempIdx"	
								}
								if {[string match -nocase "*$searchStr*" [$updatetree itemcget $tempPdoSidx -text]] && $chk == 0} {
									#lappend FindSpace::findList $tempSidx
									puts -nonewline "......MATCH sidx......"
									if { $mode == 0 } {
										FindSpace::OpenParent $updatetree $tempPdoSidx
										return 1
									} elseif {$mode == "prev" } {
										set prev $tempPdoSidx
puts "prev in pdo sidx ->$prev"
									} elseif {$mode == "next" } {
										if {$flag == 0} {
											#do nothing
										} elseif {$flag == 1} {
											set next $tempPdoSidx
puts "next in pdo sidx ->$next"
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
puts "idx matched -> $tempIdx"
					#lappend FindSpace::findList $tempIdx
					if { $mode == 0 } { 
						FindSpace::OpenParent $updatetree $tempIdx
						return 1
					} elseif {$mode == "prev" } {
						set prev $tempIdx
puts "prev in idx ->$prev"
					} elseif {$mode == "next" } {
						if {$flag == 0} {
							#do nothing
						} elseif {$flag == 1} {
							set next $tempIdx
puts "next in idx ->$next"
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
puts "flag 1 in sidx ->$tempSidx"
					}
					if {[string match -nocase "*$searchStr*" [$updatetree itemcget $tempSidx -text]] && $chk == 0} {
puts "sidx matched -> $tempSidx"
						#lappend FindSpace::findList $tempSidx

						if { $mode == 0 } { 
							FindSpace::OpenParent $updatetree $tempSidx
							return 1
						} elseif {$mode == "prev" } {
							set prev $tempSidx
puts "prev in sidx ->$prev"
						} elseif {$mode == "next" } {
							if {$flag == 0} {
								#do nothing
							} elseif {$flag == 1} {
								set next $tempSidx
puts "next in sidx ->$next"
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
	#puts FindSpace::findList->$FindSpace::findList
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
#proc FindSpace::FindPdo
#Input       : pdo node, search string
#Output      : nodes containing search string
#Description : Finds nodes containing search string in PDO
################################################################################################
proc FindSpace::FindPdo {pdoNode searchStr mode node flag prev next chk } {
	global updatetree

puts "mode->$mode"
puts "node->$node"
puts "flag->$flag"
puts "prev->$prev"
puts "next->$next"
puts "chk->$chk"
		
	set childPdo [$updatetree nodes $pdoNode]
	foreach tempPdo $childPdo {
		if {$tempPdo == $node && $mode != 0} {
			if {$mode == "prev"} {
				return $prev
			} else {
				set flag 1
			}
		}
		set idx [$updatetree nodes $tempPdo]
		foreach tempIdx $idx { 
			if {$tempIdx == $node && $mode != 0} {
				if {$mode == "prev"} {
					return $prev
				} else {
					set flag 1
					set chk 1
				}
						
puts "flag 1 in idx ->$tempIdx"	
			}
			if {[string match -nocase "*$searchStr*" [$updatetree itemcget $tempIdx -text]] && $chk == 0} {
				#lappend FindSpace::findList $tempIdx
				puts -nonewline "......MATCH idx......"
				if { $mode == 0 } {
					FindSpace::OpenParent $updatetree $tempIdx
					return 1
				} elseif {$mode == "prev" } {
					set prev $tempIdx
puts "prev in pdo idx ->$prev"
				} elseif {$mode == "next" } {
					if {$flag == 0} {
						#do nothing
					} elseif {$flag == 1} {
						set next $tempIdx
puts "next in pdo sidx ->$next"
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
						
puts "flag 1 in idx ->$tempIdx"	
				}
				if {[string match -nocase "*$searchStr*" [$updatetree itemcget $tempSidx -text]] && $chk == 0} {
					#lappend FindSpace::findList $tempSidx
					puts -nonewline "......MATCH sidx......"
					if {$tempSidx == $node && $mode == 1 && $flag ==0 } {
						set flag 1
					}
					if { $mode == 0 } {
						FindSpace::OpenParent $updatetree $tempSidx
						return 1
					} elseif {$mode == "prev" } {
						set prev $tempSidx
puts "prev in pdo sidx ->$prev"
					} elseif {$mode == "next" } {
						if {$flag == 0} {
							#do nothing
						} elseif {$flag == 1} {
							set next $tempSidx
puts "next in pdo sidx ->$next"
							return $next
						}
		
					}
				} elseif {$chk == 1} {
					set chk 0
				}
			}
		}	
	}
	return "no_match"
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
		puts prev->$prev
		if { $prev == "" } {
			puts "prev no match"
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
		puts next->$next
		if { $next == "" } {
			puts "next no match"
		} else {
			FindSpace::OpenParent $updatetree $next
		}
		return
	}
}

################################################################################################
#proc TransferCDC
#Input       : -
#Output      : -
#Description : Gets location where CDC is to be stored
################################################################################################
proc TransferCDC {} {

	set types {
        {"All Project Files"     {*.cdc } }
	}
	########### Before Closing Write the Data to the file ##########

	#set file [tk_getSaveFile -filetypes $filePatternList -initialdir $EditorData(opti	ons,workingDir) \
        #     -initialfile $filename -defaultextension $defaultExt -title "Save File"]


	# Validate filename
	set fileLocation_CDC [tk_getSaveFile -filetypes $types -title "Transfer CDC"]
        if {$fileLocation_CDC == ""} {
                return
        }
	puts fileLocation_CDC:$fileLocation_CDC
	Tcl_TransferCDC $fileLocation_CDC
}

################################################################################################
#proc BuildProject
#Input       : -
#Output      : -
#Description : Build the project 
################################################################################################
proc BuildProject {} {
	conPuts "generating CDC"
	conPuts "generating XML"
	#Tcl_GenerateCDC
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

puts "Reimport nodeIdList->$nodeIdList"

	set node [$updatetree selection get]
	if {[string match "MN*" $node]} {
		set child [$updatetree nodes $node]
		set tmpNode [string range $node 2 end]
		set node OBD$tmpNode
		set res [lsearch $child "*OBD$tmpNode*"]
		set obj [lindex $nodeIdList 1]
		set objNode [lindex $nodeIdList 2]
		set nodeId 240
		set nodeType 0
		#if { $res == -1} {
		#	$updatetree insert 0 MN$tmpNode OBD$tmpNode -text "OBD" -open 0 -image [Bitmap::get pdo]
		#}
	} else {
		set nodeList ""
		
		#foreach mnNode [$updatetree nodes PjtName] {
		#	set chk 1
		#	foreach cnNode [$updatetree nodes $mnNode] {
		#		if {$chk == 1} {
		#			if {[string match "OBD*" $cnNode]} {
		#				lappend nodeList $cnNode " " " "
		#			} else {
		#				lappend nodeList " " " " " " $cnNode " " " "
		#			}
		#			set chk 0
		#		} else {
		#			lappend nodeList $cnNode " " " "
		#		}
		#	}
		#}
		set nodeList [GetNodeList]
		set schCnt [lsearch -exact $nodeList $node]
puts  "schCnt->$schCnt=======nodeList->$nodeList"
		set nodeId [lindex $nodeIdList $schCnt]
		set obj [lindex $nodeIdList [expr $schCnt+1]]
		set objNode [lindex $nodeIdList [expr $schCnt+2]]
		set nodeType 1
	}	
	set cursor [. cget -cursor]
	set types {
	        {"XDC Files"     {.xdc } }
	        {"XDD Files"     {.xdd } }
	}
puts  "REimport obj->$obj=====objNode->$objNode"
	set tmpImpDir [tk_getOpenFile -title "Import XDC" -filetypes $types -parent .]
	if {$tmpImpDir != ""} {
		catch {
			if { $res == -1} {
				$updatetree insert 0 MN$tmpNode OBD$tmpNode -text "OBD" -open 0 -image [Bitmap::get pdo]
			}
		}
		catch {FreeNodeMemory $node}
		catch {$updatetree delete [$updatetree nodes $node]}
		# pass node Id  and node type instead of 1 and cn
		$updatetree itemconfigure $node -open 0
	#parseFile(char* filename, int NodeID, ENodeType  NodeType); 
		 #ReImportXML(char* fileName, char* errorString, int NodeID, ENodeType NodeType);
		set errorString []
		#API 
		set catchErrCode [ReImportXML $tmpImpDir $nodeId $nodeType]
		if { $catchErrCode != 0 } {
			tk_messageBox -message "ENUM:$catchErrCode!" -title Info -icon info
			return
		}		
		Import $node $tmpImpDir $nodeId $nodeType $obj $objNode 
	}
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
	puts nodeIdList->$nodeIdList
	set nodeList ""
	set node [$updatetree selection get]
	if { [string match "PjtName" $node] || [string match "MN*" $node] || [string match "PDO*" $node]|| [string match "?PDO*" $node] } {
		#should not delete when pjt, mn, pdo, tpdo or rpdo is selected 
		return
	}
	#procedure GetNodeList does following fun
	#foreach mnNode [$updatetree nodes PjtName] {
	#	set chk 1
	#	foreach cnNode [$updatetree nodes $mnNode] {
	#		if {$chk == 1} {
	#			if {[string match "OBD*" $cnNode]} {
	#				lappend nodeList $cnNode " " " "
	#			} else {
	#				lappend nodeList " " " " " " $cnNode " " " "
	#			}
	#			set chk 0
	#		} else {
	#			lappend nodeList $cnNode " " " "
	#		}
	#	}
	#}
	set nodeList [GetNodeList]
	puts nodeList->$nodeList...
	if {[lsearch -exact $nodeList $node ]!=-1} {
		set result [tk_messageBox -message "Do you want to delete node?" -type yesno -icon question -title "Question"]
   		 switch -- $result {
   		     yes {			 
   		         #continue with process
   			}
   		     no {
   			     return
			}
   		}	
		puts "is a node"
		set schCnt [lsearch -exact $nodeList $node]
		set nodeId [lindex $nodeIdList $schCnt]
		#set incNodPos [expr $nodePos+1]
		puts "nodeId->$nodeId..."
		#set nodeList [DeleteList $nodeList $node]
		
		#set nodeList [lrange $nodeList $incNodPos end]
		#set nodeIdList [lrange $nodeIdList $incNodPos end]



		#freeing memory
		FreeNodeMemory $node
		#this proc does following
	 	#foreach childIdx [$updatetree nodes $node] {
		#	if {[string match "*PDO*" $childIdx]} {
		#		foreach childPdo [$updatetree nodes $childIdx] {
		#			foreach childIdx [$updatetree nodes $childPdo] {
		#				set tmpSplit [split $childIdx -]
		#				set xdcId [join $xdcId -]
		#				unset nodeObj($xdcId)
		#				foreach childSidx [$updatetree nodes $childIdx] {
		#					set tmpSplit [split $childSidx -]
		#					set xdcId [lrange $tmpSplit 1 end]
		#					set xdcId [join $xdcId -]
		#					unset nodeObj($xdcId)
		#				}
		#			}
		#		}
		#		continue
		#	}
		#	set tmpSplit [split $childIdx -]
		#	set xdcId [lrange $tmpSplit 1 end]
		#	set xdcId [join $xdcId -]
		#	unset nodeObj($xdcId)
		#	foreach childSidx [$updatetree nodes $childIdx] {
		#		set tmpSplit [split $childSidx -]
		#		set xdcId [lrange $tmpSplit 1 end]
		#		set xdcId [join $xdcId -]
		#		unset nodeObj($xdcId)
		#	}
		#}		
		set nodeType 1
		#set nodeId 4
		set errorString []
		#set tmp_NodePos [SharedLib_IfNodeExists $nodeId 1 $errorString]
		#if {[expr {$tmp_NodePos < 0}]}  {
		#	puts tmp_NodePos->$tmp_NodePos
		#	puts "Fail. Node not found"
		#	puts errorString:$errorString
		#	return
		#} else {
		#	puts tmp_NodePos:$tmp_NodePos
		#	SharedLib_DeleteNode $tmp_NodePos
		#}
		if {[string match "OBD*" $node]} {
			#should not delete nodeId, obj, objNode from list since it is mn
		} else {
			set nodeIdList [DeleteList $nodeIdList $nodeId]		
			puts "after deletion nodeIdList->$nodeIdList "		
		}
		
		#SharedLib delete cn node
	} else {
		set idxNode [$updatetree selection get]
		if {[string match "*SubIndexValue*" $node]} {
			set end [string length [$updatetree itemcget $node -text] ]
			set sidx [string range [$updatetree itemcget $node -text] [expr $end-3] [expr $end-2] ]
			puts sidx->$sidx
			set idxNode [$updatetree parent $node]
		} elseif {[string match "*IndexValue*" $node]} {
			#freeing the memory
	 		foreach childIdx [$updatetree nodes $node] {	
				set tmpSplit [split $childIdx -]
				set xdcId [lrange $tmpSplit 1 end]
				set xdcId [join $xdcId -]
				#puts -nonewline "$xdcId  "
				unset nodeObj($xdcId)
			}
		}
		set end [string length [$updatetree itemcget $idxNode -text] ]
		set idx [string range [$updatetree itemcget $idxNode -text] [expr $end-5] [expr $end-2] ]
		puts idx->$idx
 		set child $idxNode
		if {[string match "*Pdo*" $node]} {	
			set temppdo [$updatetree parent $idxNode]
			set child [$updatetree parent $temppdo]	
		}
		puts child->$child
		set paren [$updatetree parent $child]
		puts paren->$paren
		if {[string match "OBD*" $paren]} {	
			#since it is a mn
			set nodeId 240
			set nodeType 0
			puts "it is a MN"
		} else {
			#it is a cn
			set nodeId [lsearch -exact $nodeList $paren]
			set nodeId [lindex $nodeIdList $nodeId]
			puts nodeId->$nodeId
			set nodeType 1
		}		
		if {[string match "*SubIndexValue*" $node]} {
		puts "SharedLib delete sub index"
			puts "DeleteSubIndex $nodeId $nodeType $idx $sidx"
			set errorString []
				set errStruct [IfNodeExists $nodeId 1 $errorString]
				puts TEST::[ocfmRetValError_getRetValue $errStruct] 
			set res [DeleteSubIndex $nodeId $nodeType $idx $sidx $errorString]
			if {$res == -1} {
				return
			}
		} elseif {[string match "*IndexValue*" $node]} {
		puts "SharedLib delete index"
			puts "DeleteIndex $nodeId $nodeType $idx"
			set errorString []		
			set res [DeleteIndex $nodeId $nodeType $idx $errorString]
			if {$res == -1} {
				return
			}			
		}
		
	set tmpSplit [split $node -]
	set xdcId [lrange $tmpSplit 1 end]
	set xdcId [join $xdcId -]
	unset nodeObj($xdcId)
	}
	set parent [$updatetree parent $node]
	set nxtSelList [$updatetree nodes $parent]

	if {[llength $nxtSelList] == 1} {
		#it is the only node so select parent
		$updatetree selection set $parent
	} else {
		set nxtSelCnt [expr [lsearch $nxtSelList $node]+1]
		if {$nxtSelCnt >= [llength $nxtSelList]} {
			#it is the last node select previous node
			set nxtSelCnt [expr $nxtSelCnt-2]
		} elseif { $nxtSelCnt > 0 } {
			#select next node since nxtSelCnt already incremented do nothing
		} else {
			puts "DeleteTreeNode->this cond should not occur"
		}
			catch {set nxtSel [lindex $nxtSelList $nxtSelCnt] }
			catch {$updatetree selection set $nxtSel}
	}
	$updatetree delete $node
	#puts "*************$xdcId"
}

################################################################################################
#proc DeleteList
#Input       : -
#Output      : -
#Description : searches a variable in list if present delete it
################################################################################################
proc DeleteList {tempList deleteVar} {
	set res [lsearch $tempList $deleteVar] 
	if {$res != -1} {
		if {$res == 0} {
			set resList [lrange $tempList 3 end]
			return $resList
		} else {
			set resList [lrange $tempList 0 [expr $res-1] ]
			#in nodeIdList delete nodeId obj and objNode
			foreach tempVar [lrange $tempList [expr $res+3] end ] {
				lappend resList $tempVar
			}
			return $resList
		}
	}
	puts "no match to delete from list"
	return $tempList
}

################################################################################################
#proc NodeCreate
#Input       : -
#Output      : pointer to object
#Description : creates an object for node
################################################################################################
proc NodeCreate {NodeID NodeType} {
	set objNode [new_CNode]
	set objNodeCollection [new_CNodeCollection]
	set objNodeCollection [CNodeCollection_getNodeColObjectPointer]
	#puts "errorString->$errorString...NodeType->$NodeType...NodeID->$NodeID..."
	set catchErrCode [CreateNode $NodeID $NodeType]
	if { $catchErrCode != 0 } {
		tk_messageBox -message "ENUM:$catchErrCode!" -title Info -icon info
		return
	}
	set objNode [new_CNode]
	set obj [new_CIndexCollection]
	set objNode [CNodeCollection_getNode $objNodeCollection $NodeType $NodeID]
	#old code 
	set obj [CNode_getIndexCollection $objNode]
	#currntly works only for windows
	#set obj [CNode_getIndexCollectionWithoutPDO $objNode]
	puts "NodeCreate :::  obj->$obj====objNode->$objNode"
	return [list $obj $objNode]
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
		set chk 1
		foreach cnNode [$updatetree nodes $mnNode] {
			if {$chk == 1} {
				if {[string match "OBD*" $cnNode]} {
					lappend nodeList $cnNode " " " "
				} else {
					lappend nodeList " " " " " " $cnNode " " " "
				}
				set chk 0
			} else {
				lappend nodeList $cnNode " " " "
			}
		}
	}

	return $nodeList
}

################################################################################################
#proc FreeNodeMemory
#Input       : -
#Output      : pointer to object
#Description : creates an object for node
################################################################################################
proc FreeNodeMemory {node} {
	global updatetree
	global nodeObj
 	foreach childIdx [$updatetree nodes $node] {
		if {[string match "*PDO*" $childIdx]} {
			foreach childPdo [$updatetree nodes $childIdx] {
				foreach childIdx [$updatetree nodes $childPdo] {
					set tmpSplit [split $childIdx -]
					set xdcId [lrange $tmpSplit 1 end]
					set xdcId [join $xdcId -]
					unset nodeObj($xdcId)
					foreach childSidx [$updatetree nodes $childIdx] {
						set tmpSplit [split $childSidx -]
						set xdcId [lrange $tmpSplit 1 end]
						set xdcId [join $xdcId -]
						unset nodeObj($xdcId)
					}
				}
			}
			continue
		}
		set tmpSplit [split $childIdx -]
		set xdcId [lrange $tmpSplit 1 end]
		set xdcId [join $xdcId -]
		unset nodeObj($xdcId)
		foreach childSidx [$updatetree nodes $childIdx] {
			set tmpSplit [split $childSidx -]
			set xdcId [lrange $tmpSplit 1 end]
			set xdcId [join $xdcId -]
			unset nodeObj($xdcId)
		}
	}
}
