####################################################################################################
#
#
# NAME:     operations.tcl
#
# PURPOSE:  Contains the major functionality of the tool
#
# AUTHOR:   Kalycito Infotech Pvt Ltd
#
# COPYRIGHT NOTICE:
#
#***************************************************************************************************
# (c) Kalycito Infotech Private Limited
#
#  Project:      openCONFIGURATOR 
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
#***************************************************************************************************
#
#  REVISION HISTORY:
# $Log:      $
####################################################################################################

#---------------------------------------------------------------------------------------------------
#  NameSpace Declaration
#
#  namespace : Validation
#---------------------------------------------------------------------------------------------------
namespace eval Operations {
    variable mnMenu
    variable cnMenu
    variable projMenu    
    variable obdMenu    
    variable idxMenu    
    variable mnCount
    variable cnCount
    variable notebook
    variable tree_notebook
    variable infotabs_notebook
    variable pannedwindow1
    variable pannedwindow2
    variable mainframe
    variable progressmsg
    variable prgressindicator
    variable showtoolbar  1
}

# For including Tablelist Package
set path_to_Tablelist [file join $rootDir tablelist4.10]
lappend auto_path $path_to_Tablelist
package require Tablelist

#Initiating thread for progress bar
package require Thread
tsv::set application main [thread::id]
tsv::set application importProgress [thread::create -joinable {
    package require Tk 8.5
    set rootDir [tsv::get application rootDir]
    set path_to_BWidget [file join $rootDir BWidget-1.2.1]
    lappend auto_path $path_to_BWidget
    package require -exact BWidget 1.2.1
    source [file join $rootDir childWindows.tcl]

    wm withdraw .
    if {"$tcl_platform(platform)" != "windows"} {
        . config -bg #d7d5d3
    }
    wm protocol . WM_DELETE_WINDOW dont_exit
    wm title . "progress"
    BWidget::place . 0 0 center
    update idletasks

    proc StartProgress {} {
	    ImportProgress start
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

#-------------------------
#	Initializing global variables
#-------------------------
global projectDir 
global projectName

set cnCount 0
set mnCount 0
set nodeIdList ""
set savedValueList ""
set nodeSelect ""
set lastXD ""
set lastOpenPjt ""
set LastTableFocus ""
set status_save 0 
Validation::ResetPromptFlag 

#---------------------------------------------------------------------------------------------------
#  Operations::about
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Information about the tool
#---------------------------------------------------------------------------------------------------
proc Operations::about {} {\
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
    Operations::centerW .about
}

#---------------------------------------------------------------------------------------------------
#  Operations::centerW
# 
#  Arguments : windowPath - path of toplevel window
#
#  Results : -
#
#  Description : Place the toplevel window center to application
#---------------------------------------------------------------------------------------------------
proc Operations::centerW windowPath {
    BWidget::place $windowPath 0 0 center
}

#---------------------------------------------------------------------------------------------------
#  Operations::tselectright
# 
#  Arguments : x    - x position
#              y    - y position
#              node - selected node in tree widget
#  Results : -
#
#  Description : Displays right click menu to appropriate node
#---------------------------------------------------------------------------------------------------
proc Operations::tselectright {x y node} {
    variable treeWindow

    $treeWindow selection clear
    $treeWindow selection set $node 
    set CurrentNode $node
    if { [string match "ProjectNode" $node] == 1 } {
	    tk_popup $Operations::projMenu $x $y 
    } elseif { [string match "MN-*" $node] == 1 } {
	    tk_popup $Operations::mnMenu $x $y	
    } elseif { [string match "CN-*" $node] == 1 } { 
	    tk_popup $Operations::cnMenu $x $y 
    } elseif { [string match "OBD-*" $node] == 1 } { 
	    tk_popup $Operations::obdMenu $x $y	
    } elseif { [string match "PDO-*" $node] == 1 } { 
	    tk_popup $Operations::pdoMenu $x $y	
    } elseif {[string match "IndexValue-*" $node] == 1 || [string match "*PdoIndexValue-*" $node] == 1} { 
	    tk_popup $Operations::idxMenu $x $y		
    } elseif {[string match "SubIndexValue-*" $node] == 1 || [string match "*PdoSubIndexValue-*" $node] == 1} { 
	    tk_popup $Operations::sidxMenu $x $y	
    } else {
	    return 
    }   
}

#---------------------------------------------------------------------------------------------------
#  Operations::DisplayConsole
# 
#  Arguments : option - user selected preference
#
#  Results : -
#
#  Description : Displays or hide Console window according to option
#---------------------------------------------------------------------------------------------------
proc Operations::DisplayConsole {option} {
    variable infotabs_notebook

    set window [winfo parent $infotabs_notebook]
    set window [winfo parent $window]
    set pannedWindow [winfo parent $window]
    update idletasks
    if {$option} {
        grid configure $pannedWindow.f0 -rowspan 1
        grid $pannedWindow.sash1
        grid $window
        grid rowconfigure $pannedWindow 2 -minsize 100
    } else  {
        grid remove $window
        grid remove $pannedWindow.sash1
        grid configure $pannedWindow.f0 -rowspan 3
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::DisplayTreeWin
# 
#  Arguments : option - user selected preference
#
#  Results : -
#
#  Description : Displays or hide Tree window according to option
#---------------------------------------------------------------------------------------------------
proc Operations::DisplayTreeWin {option} {
    variable tree_notebook

    set window [winfo parent $tree_notebook]
    set window [winfo parent $window]
    set pannedWindow [winfo parent $window]
    update idletasks
    if {$option} {
        grid configure $pannedWindow.f1 -column 2 -columnspan 1
        grid $pannedWindow.sash1
        grid $window
        grid columnconfigure $pannedWindow 0 -minsize 250
    } else  {
        grid remove $window
        grid remove $pannedWindow.sash1
        grid configure $pannedWindow.f1 -column 0 -columnspan 3
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::exit_app
# 
#  Arguments : -
#
#  Results : -
#
#  Description : prompts to save project when application is exited
#---------------------------------------------------------------------------------------------------
proc Operations::exit_app {} {
    variable notebook
    variable index

    global rootDir
    global projectDir
    global projectName
    global status_save

    if { $projectDir != ""} {
    #check whether project has changed
    if {$status_save} {
	    #Prompt for Saving the Existing Project
	    set result [tk_messageBox -message "Save Project $projectName ?" -type yesnocancel -icon question -title "Question" -parent .]
	    switch -- $result {
	         yes {			 
	                 Operations::Saveproject
		         DisplayInfo "Project $projectName is saved" info
	         }
	         no  {DisplayInfo "Project $projectName not saved" info
	         }
	         cancel {
		         DisplayInfo "Exit Canceled" info
		         return
	         }
	    }
    }
        Operations::CloseProject
    }
    thread::send [tsv::get application importProgress] "exit_thread"
    exit
}

#---------------------------------------------------------------------------------------------------
#  Operations::OpenProjectWindow
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Prompts to save the current project gets an already existing project 
#---------------------------------------------------------------------------------------------------
proc Operations::OpenProjectWindow { } {
    global projectDir
    global projectName
    global treePath
    global nodeIdList
    global mnCount
    global cnCount	
    global status_save
    global lastOpenPjt
    global defaultProjectDir

    if { $projectDir != "" } {
	    #check whether project has changed
	    if {$status_save} {
		    #Prompt for Saving the Existing Project
		    set result [tk_messageBox -message "Save Project $projectName ?" -type yesnocancel -icon question -title "Question" -parent .]
       		switch -- $result {
       		     yes {
				    DisplayInfo "Project $projectName Saved" info
				    Operations::Saveproject
			    }
       		     no  {
				    DisplayInfo "Project $projectName Not Saved" info
			    }
       		     cancel {
				    DisplayInfo "Open Project Canceled" info
				    return
			    }
       		}
	    }
    }


    set types {
	    {"All Project Files"     {*.oct } }
    }


    if { ![file isdirectory $lastOpenPjt] && [file exists $lastOpenPjt] } {
	    set lastOpenFile [file tail $lastOpenPjt]
	    set lastOpenDir [file dirname $lastOpenPjt]
	    set projectfilename [tk_getOpenFile -title "Open Project" -initialdir $lastOpenDir -initialfile $lastOpenFile -filetypes $types -parent .]
    } else {
	    set projectfilename [tk_getOpenFile -title "Open Project" -initialdir $defaultProjectDir -filetypes $types -parent .]
    }

    # Validate filename
        if { $projectfilename == "" } {
                return
        }

    set tempPjtName [file tail $projectfilename]
    set ext [file extension $projectfilename]
        if {[string compare $ext ".oct"]} {
        set projectDir ""
        tk_messageBox -message "Extension $ext not supported" -title "Open Project Error" -icon error -parent .
        return
    }

    #save the path of opened project
    set lastOpenPjt $projectfilename

    Operations::openProject $projectfilename
}

#---------------------------------------------------------------------------------------------------
#  Operations::openProject
# 
#  Arguments : projectfilename - path of project to be opened
#
#  Results : -
#
#  Description : opens the project and populates the gui
#---------------------------------------------------------------------------------------------------
proc Operations::openProject {projectfilename} {
    global projectDir
    global projectName
    global ra_proj
    global ra_auto


    #Operations::CloseProject is called to delete node and insert tree
    Operations::CloseProject

    set tempPjtDir [file dirname $projectfilename]
    set tempPjtName [file tail $projectfilename]
    #puts "\n\nPjtDir->$tempPjtDir projectName->$tempPjtName \n\n"

    thread::send [tsv::get application importProgress] "StartProgress"
    #API for open project
    set catchErrCode [OpenProject $tempPjtDir $tempPjtName]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode != 0 } {
	    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
		    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -parent . -title Warning -icon warning
	    } else {
		    tk_messageBox -message "Unknown Error" -parent . -title Warning -icon warning
            #puts "Unknown Error ->[ocfmRetCode_errorString_get $catchErrCode]"
	    }
	    thread::send -async [tsv::set application importProgress] "StopProgress"
	    return
    } 
    set projectDir $tempPjtDir
    set projectName $tempPjtName

    set result [ Operations::RePopulate $projectDir [string range $projectName 0 end-[string length [file extension $projectName]]] ]
    thread::send [tsv::set application importProgress] "StopProgress"

    # API to get project settings
    set ra_autop [new_EAutoGeneratep]
    set ra_projp [new_EAutoSavep]
    set catchErrCode [GetProjectSettings $ra_autop $ra_projp]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode != 0 } {
	    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
		    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]\nAuto generate is set to \"No\" and project Setting set to \"Discard\" " -title Warning -icon warning
	    } else {
		     tk_messageBox -message "Unknown Error\nAuto generate is set to \"No\" and project Setting set to \"Discard\" " -title Warning -icon warning
		    #puts "Unknown Error ->[ocfmRetCode_errorString_get $catchErrCode]\n"
	    }
	    set ra_auto 0
	    set ra_proj 2
    } else {
	    set ra_auto [EAutoGeneratep_value $ra_autop]
	    set ra_proj [EAutoSavep_value $ra_projp]
    }

    ClearMsgs
    if { $result == 1 } {
	    DisplayInfo "Project $projectName at $projectDir is successfully opened"
    } else {
	    DisplayErrMsg "Error in opening project $projectName at $projectDir"
    }
	
}

#---------------------------------------------------------------------------------------------------
#  Operations::RePopulate
# 
#  Arguments : projectDir  - path of the project
#	           projectName - name of the project
#
#  Results : -
#
#  Description : Rebuilds the the tree with updated values for all nodes
#---------------------------------------------------------------------------------------------------
proc Operations::RePopulate { projectDir projectName } {
    global treePath
    global nodeIdList
    global mnCount
    global cnCount	

    set mnCount 1
    set cnCount 1

    catch {$treePath delete ProjectNode}
    $treePath insert end root ProjectNode -text $projectName -open 1 -image [Bitmap::get network]

    set count [new_intp]
    set catchErrCode [GetNodeCount 240 $count]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode == 0 } {
	    set nodeCount [intp_value $count]
	    for {set inc 0} {$inc < $nodeCount} {incr inc} {
		    #API for getting node attributes based on node position
		    set tmp_nodeId [new_intp]			
		    set catchErrCode [GetNodeAttributesbyNodePos $inc $tmp_nodeId]
		    set ErrCode [ocfmRetCode_code_get [lindex $catchErrCode 0]]
		    if { $ErrCode == 0 } {
			    set nodeId [intp_value $tmp_nodeId]
			    set nodeName [lindex $catchErrCode 1]
			    if {$nodeId == 240} {
				    set nodeType 0
				    $treePath insert end ProjectNode MN-$mnCount -text "openPOWERLINK_MN(240)" -open 1 -image [Bitmap::get mn]
				    $treePath insert end MN-$mnCount OBD-$mnCount-1 -text "OBD" -open 0 -image [Bitmap::get pdo]	
				    set node OBD-$mnCount-1	
			    } else {
				    set nodeType 1
				    set child [$treePath insert end MN-$mnCount CN-$mnCount-$cnCount -text "$nodeName\($nodeId\)" -open 0 -image [Bitmap::get cn]]
				    set node CN-$mnCount-$cnCount
			    }
			    if { [ catch { set result [WrapperInteractions::Import $node $nodeType $nodeId] } ] } {
				    # error has occured
				    Operations::CloseProject
				    return 0
			    }
			    if { $result == "fail" } {
				    return 0
			    }
			    incr cnCount
			    lappend nodeIdList $nodeId 
		    } else {
			    # error has occured
			    Operations::CloseProject
			    return 0
		    }
	    }

	    if { [$Operations::projMenu index 3] != "3" } {
		    $Operations::projMenu insert 3 command -label "Close Project" -command "Operations::InitiateCloseProject"
	    }
	    if { [$Operations::projMenu index 4] != "4" } {
		    $Operations::projMenu insert 4 command -label "Properties" -command "ChildWindows::PropertiesWindow"
	    }
	    #puts nodeIdList->$nodeIdList

    } else {
	    Operations::CloseProject
	    DisplayErrMsg "MN node is not found" error
    }
    return 1
}

#---------------------------------------------------------------------------------------------------
#  Operations::BasicFrames
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Creates the GUI for application when launched
#---------------------------------------------------------------------------------------------------
proc Operations::BasicFrames { } {
    global tcl_platform
    global rootDir
    global f0
    global f1
    global f2
    global LastTableFocus

    variable bb_connect
    variable mainframe
    variable notebook
    variable tree_notebook
    variable infotabs_notebook
    variable pannedwindow2
    variable pannedwindow1
    variable treeWindow
    variable mainframe
    variable progressmsg
    variable prgressindicator
    variable options
    variable Button
    variable cnMenu
    variable mnMenu
    variable IndexaddMenu
    variable obdMenu
    variable pdoMenu
    variable idxMenu
    variable sidxMenu	

    set progressmsg "Please wait while loading ..."
    set prgressindicator -1
    Operations::_tool_intro
    update

    # Menu description
    set descmenu {
	    "&File" {} {} 0 {           
                {command "New &Project" {} "New Project" {Ctrl n}  -command { Operations::InitiateNewProject } }
                {command "Open Project" {}  "Open Project" {Ctrl o} -command { Operations::OpenProjectWindow } }
                {command "Save Project" {noFile}  "Save Project" {Ctrl s} -command Operations::Saveproject}
                {command "Save Project as" {noFile}  "Save Project as" {} -command ChildWindows::SaveProjectAsWindow }
                {command "Close Project" {}  "Close Project" {} -command Operations::InitiateCloseProject }
                {separator}
                {command "E&xit" {}  "Exit openCONFIGURATOR" {Alt x} -command Operations::exit_app}
        	}
        	"&Project" {} {} 0 {
        		{command "Build Project    F7" {noFile} "Generate CDC and XML" {} -command Operations::BuildProject }
        		{command "Clean Project" {noFile} "Clean" {} -command Operations::CleanProject }
        		{separator}
        		{command "Project Settings" {}  "Project Settings" {} -command ChildWindows::ProjectSettingWindow }
        	}
        	"&Actions" all options 0 {
                {command "Transfer CDC and XAP  Ctrl+F5" {noFile} "Transfer CDC and XAP" {} -command "Operations::TransferCDCXAP 1" }
                {separator}
                {command "Start MN" {noFile} "Start the Managing Node" {} -command Operations::StartStack }
                {command "Stop MN" {noFile} "Stop the Managing Node" {} -command Operations::StopStack }
        	}
        	"&View" all options 0 {
                {checkbutton "Show Output Console" {all option} "Show Console Window" {}
                    -variable Operations::options(DisplayConsole)
                    -command  {
                        Operations::DisplayConsole $Operations::options(DisplayConsole)
                        update idletasks
                    }
           		}
                {checkbutton "Show Test Tree Browser" {all option} "Show Code Browser" {}
                    -variable Operations::options(showTree)
                    -command  {
                    Operations::DisplayTreeWin $Operations::options(showTree)
                        update idletasks
                    }
                }
        	}
        	"&Help" {} {} 0 {
                {command "How to" {noFile} "How to Manual" {} -command YetToImplement }
                {separator}
                {command "About" {} "About" {F1} -command Operations::about }
        	}
	    }

    # to select the required check button in View menu
    set Operations::options(showTree) 1
    set Operations::options(DisplayConsole) 1
    #shortcut keys for project
    bind . <Key-F7> "Operations::BuildProject"
     #to prevent BuildProject called
    bind . <Control-Key-F7> "" 
    bind . <Control-Key-F5> "Operations::TransferCDCXAP 1"
    bind . <Control-Key-f> { FindSpace::FindDynWindow }
    bind . <Control-Key-F> { FindSpace::FindDynWindow }
    bind . <KeyPress-Escape> { FindSpace::EscapeTree }

    # Menu for the Controlled Nodes
    set Operations::cnMenu [menu  .cnMenu -tearoff 0]
    set Operations::IndexaddMenu .cnMenu.indexaddMenu
    $Operations::cnMenu add command -label "Add Index" -command "ChildWindows::AddIndexWindow"
    $Operations::cnMenu add command -label "Import XDC/XDD" -command {Operations::ReImport}
    $Operations::cnMenu add separator
    $Operations::cnMenu add command -label "Delete" -command {Operations::DeleteTreeNode}
    $Operations::cnMenu add command -label "Properties" -command {ChildWindows::PropertiesWindow} ; #commented for this delivery 

    # Menu for the Managing Nodes
    set Operations::mnMenu [menu  .mnMenu -tearoff 0]
    $Operations::mnMenu add command -label "Add CN" -command "ChildWindows::AddCNWindow" 
    $Operations::mnMenu add command -label "Import XDC/XDD" -command "Operations::ReImport"
    $Operations::mnMenu add separator
    $Operations::mnMenu add command -label "Auto Generate" -command {Operations::AutoGenerateMNOBD} 
    $Operations::mnMenu add command -label "Delete OBD" -command {Operations::DeleteTreeNode}
    $Operations::mnMenu add separator
    $Operations::mnMenu add command -label "Properties" -command {ChildWindows::PropertiesWindow}; #commented for this delivery

    # Menu for the Project
    set Operations::projMenu [menu  .projMenu -tearoff 0]
    $Operations::projMenu insert 0 command -label "Sample Project" -command {
	    global rootDir
	    set samplePjt [file join $rootDir Sample Sample.oct]
	    if {[file exists $samplePjt]} {
		    Operations::openProject $samplePjt
	    } else {
		    DisplayErrMsg "Sample project is not present" error	
	    }
    } 
    $Operations::projMenu insert 1 command -label "New Project" -command { Operations::InitiateNewProject}
    $Operations::projMenu insert 2 command -label "Open Project" -command {Operations::OpenProjectWindow} 

    # Menu for the object dictionary
    set Operations::obdMenu [menu .obdMenu -tearoff 0]
    $Operations::obdMenu add separator 
    $Operations::obdMenu add command -label "Add Index" -command "ChildWindows::AddIndexWindow"   
    $Operations::obdMenu add separator  

    # Menu for the PDO
    set Operations::pdoMenu [menu .pdoMenu -tearoff 0]
    $Operations::pdoMenu add separator 
    $Operations::pdoMenu add command -label "Add PDO" -command "ChildWindows::AddPDOWindow"   
    $Operations::pdoMenu add separator  

    # Menu for the index
    set Operations::idxMenu [menu .idxMenu -tearoff 0]
    $Operations::idxMenu add command -label "Add SubIndex" -command "ChildWindows::AddSubIndexWindow"   
    $Operations::idxMenu add separator
    $Operations::idxMenu add command -label "Delete Index" -command {Operations::DeleteTreeNode}

    # Menu for the subindex
    set Operations::sidxMenu [menu .sidxMenu -tearoff 0]
    $Operations::sidxMenu add separator
    $Operations::sidxMenu add command -label "Delete SubIndex" -command {Operations::DeleteTreeNode}
    $Operations::sidxMenu add separator

    set Operations::prgressindicator -1
    set mainframe [MainFrame::create .mainframe \
            -menu $descmenu  ]

	    # toolbar  creation
    set toolbar  [MainFrame::addtoolbar $mainframe]
    pack $toolbar -expand yes -fill x
    set bbox [ButtonBox::create $toolbar.bbox1 -spacing 0 -padx 1 -pady 1]
    set Buttons(new) [ButtonBox::add $bbox -image [Bitmap::get page_white] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Create new project" -command { Operations::InitiateNewProject }]
    set Buttons(save) [ButtonBox::add $bbox -image [Bitmap::get disk] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Save Project" -command Operations::Saveproject]
    set Buttons(saveAll) [ButtonBox::add $bbox -image [Bitmap::get disk_multiple] \
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Save Project as" -command ChildWindows::SaveProjectAsWindow]    
	    set toolbarButtons(Operations::OpenProjectWindow) [ButtonBox::add $bbox -image [Bitmap::get openfolder] \
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Open Project" -command Operations::OpenProjectWindow]
        
	    pack $bbox -side left -anchor w
    set prgressindicator 0
    set sep0 [Separator::create $toolbar.sep0 -orient vertical]
    pack $sep0 -side left -fill y -padx 4 -anchor w

    set bbox [ButtonBox::create $toolbar.bbox5 -spacing 1 -padx 1 -pady 1]
    pack $bbox -side left -anchor w
    set bb_build [ButtonBox::add $bbox -image [Bitmap::get build]\
            -height 21\
            -width 21\
            -helptype balloon\
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Build Project"\
	    -command "Operations::BuildProject"]
    pack $bb_build -side left -padx 4
    set bb_clean [ButtonBox::add $bbox -image [Bitmap::get clean]\
        	-height 21\
		    -width 21\
            -helptype balloon\
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "clean Project"\
		    -command "Operations::CleanProject"]
    pack $bb_clean -side left -padx 4

    set sep2 [Separator::create $toolbar.sep2 -orient vertical]
    pack $sep2 -side left -fill y -padx 4 -anchor w

    set bbox [ButtonBox::create $toolbar.bbox4 -spacing 1 -padx 1 -pady 1]
    pack $bbox -side left -anchor w
    set bb_cdc [ButtonBox::add $bbox -image [Bitmap::get transfercdc]\
            	-height 21\
            	-width 21\
            	-helptype balloon\
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Transfer CDC and XAP"\
	        	-command "Operations::TransferCDCXAP 1"]
    pack $bb_cdc -side left -padx 4

    set sep4 [Separator::create $toolbar.sep4 -orient vertical]
    pack $sep4 -side left -fill y -padx 4 -anchor w 

    set bbox [ButtonBox::create $toolbar.bbox2 -spacing 0 -padx 4 -pady 1]
    set bb_start [ButtonBox::add $bbox -image [Bitmap::get start] \
            	-height 21\
            	-width 21\
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Start stack" -command Operations::StartStack]
    pack $bb_start -side left -padx 4
    pack $bbox -side left -anchor w -padx 2

    set bbox [ButtonBox::create $toolbar.bbox3 -spacing 1 -padx 1 -pady 1]
    set bb_stop [ButtonBox::add $bbox -image [Bitmap::get stop]\
            	-height 21\
            	-width 21\
            	-helptype balloon\
            	-highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            	-helptext "Stop stack"\
       	-command Operations::StopStack]
    pack $bb_stop -side left -padx 4
    pack $bbox -side left -anchor w

    set sep1 [Separator::create $toolbar.sep1 -orient vertical]
    pack $sep1 -side left -fill y -padx 4 -anchor w

    set bbox [ButtonBox::create $toolbar.bbox7 -spacing 1 -padx 1 -pady 1]
    pack $bbox -side right
    set bb_kaly [ButtonBox::add $bbox -image [Bitmap::get kalycito_icon]\
            -height 21\
            -width 40\
            -helptype balloon\
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "kalycito" \
            -command Operations::about ]
    pack $bb_kaly -side right  -padx 4

    $Operations::mainframe showtoolbar 0 $Operations::showtoolbar
    set temp [MainFrame::addindicator $mainframe -textvariable Operations::connect_status ]
    $temp configure -relief flat 

    # NoteBook creation
    set framePath [$mainframe getframe]
    set pannedwindow1 [PanedWindow::create $framePath.pannedwindow1 -side left]
    set pane [PanedWindow::add $pannedwindow1 ]
    set pannedwindow2 [PanedWindow::create $pane.pannedwindow2 -side top]
    set pane1 [PanedWindow::add $pannedwindow2 -minsize 250]
    set pane2 [PanedWindow::add $pannedwindow2 -minsize 100]
    set pane3 [PanedWindow::add $pannedwindow1 -minsize 100]

    set tree_notebook [NoteBook::create $pane1.nb]
    set notebook [NoteBook::create $pane2.nb]	
    set infotabs_notebook [NoteBook::create $pane3.nb]

    set pf1 [NoteBookManager::create_treeBrowserWindow $tree_notebook]
    set treeWindow [lindex $pf1 1]
    # Binding on tree widget   
    $treeWindow bindText <ButtonPress-1> Operations::SingleClickNode
    $treeWindow bindText <Double-1> Operations::DoubleClickNode
    $treeWindow bindText <ButtonPress-3> {Operations::tselectright %X %Y}
    if {"$tcl_platform(platform)" == "unix"} {
	    bind $treeWindow <Button-4> {
		    global treePath
		    $treePath yview scroll -5 units
	    }
	    bind $treeWindow <Button-5> {
		    global treePath
		    $treePath yview scroll 5 units
	    }
    }
    bind $treeWindow <Enter> { Operations::BindTree }
    bind $treeWindow <Leave> { Operations::UnbindTree }

    set cf0 [NoteBookManager::create_infoWindow $infotabs_notebook "Info" 1]
    set cf1 [NoteBookManager::create_infoWindow $infotabs_notebook "Error" 2]
    set cf2 [NoteBookManager::create_infoWindow $infotabs_notebook "Warning" 3]

    NoteBook::compute_size $infotabs_notebook
    $infotabs_notebook configure -height 1
    pack $infotabs_notebook -side bottom -fill both -expand yes -padx 4 -pady 4

    pack $pannedwindow1 -fill both -expand yes
    NoteBook::compute_size $tree_notebook
    $tree_notebook configure -width 250
    pack $tree_notebook -side left -fill both -expand yes -padx 2 -pady 4
    catch {font create TkFixedFont -family Courier -size -12 -weight bold}

    set alignFrame [frame $pane2.alignframe -width 750]
    pack $alignFrame -expand yes -fill both

    set f0 [NoteBookManager::create_tab $alignFrame index ]
    set f1 [NoteBookManager::create_tab $alignFrame subindex ]
    set f2 [NoteBookManager::create_table $alignFrame  "pdo"]
    [lindex $f2 1] columnconfigure 0 -background #e0e8f0 -width 6 -sortmode integer
    [lindex $f2 1] columnconfigure 1 -background #e0e8f0 -width 14 
    [lindex $f2 1] columnconfigure 2 -background #e0e8f0 -width 11
    [lindex $f2 1] columnconfigure 3 -background #e0e8f0 -width 11
    [lindex $f2 1] columnconfigure 4 -background #e0e8f0 -width 11
    [lindex $f2 1] columnconfigure 5 -background #e0e8f0 -width 11

    #binding for tablelist widget	
    bind [lindex $f2 1] <Enter> {
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

    pack $pannedwindow2 -fill both -expand yes

    $tree_notebook raise objectTree
    $infotabs_notebook raise Console1
    pack $mainframe -fill both -expand yes
    set prgressindicator 0
    destroy .intro
    wm protocol . WM_DELETE_WINDOW Operations::exit_app
    update idletasks
    FindSpace::EscapeTree
    Operations::ResetGlobalData
    return 1
}

#---------------------------------------------------------------------------------------------------
#  Operations::_tool_intro
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Displays image during launching of application
#---------------------------------------------------------------------------------------------------
proc Operations::_tool_intro { } {
    global tcl_platform
    global rootDir

    set top [toplevel .intro -relief raised -borderwidth 2]

    wm withdraw $top
    wm overrideredirect $top 1

    set image [image create photo -file [file join $rootDir Kalycito.gif]]
    set splashscreen  [label $top.x -image $image]
    set framePath [frame $splashscreen.f -background white]
    set lab1  [label $framePath.la_title1 -text "Loading openCONFIGURATOR" -background white -font {times 8}]
    set lab2  [label $framePath.la_title2 -textvariable Operations::progressmsg -background red -font {times 8} -width 35]
    set prg   [ProgressBar $framePath.prg -width 50 -height 10 -background  black \
	    -variable Operations::prgressindicator -maximum 10]
    pack $lab1 $lab2 $prg
    place $framePath -x 0 -y 0 -anchor nw
    pack $splashscreen
    BWidget::place $top 0 0 center
    wm deiconify $top
}

#---------------------------------------------------------------------------------------------------
#  Operations::BindTree
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Binds various functions to tree widget
#---------------------------------------------------------------------------------------------------
proc Operations::BindTree {} {
    global treePath
    global tcl_platform

    bind . <Delete> Operations::DeleteTreeNode 
    bind . <Up> Operations::ArrowUp 
    bind . <Down> Operations::ArrowDown
    bind . <Left> Operations::ArrowLeft
    bind . <Right> Operations::ArrowRight
    if {"$tcl_platform(platform)" == "windows"} {
	    bind . <MouseWheel> {global treePath; $treePath yview scroll [expr -%D/24] units }
    }
    $treePath configure -selectbackground #678db2
}

#---------------------------------------------------------------------------------------------------
#  Operations::UnbindTree
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Unbinds various functions binded to tree widget
#---------------------------------------------------------------------------------------------------
proc Operations::UnbindTree {} {
    global tcl_platform
    global treePath

    bind . <Delete> "" 
    bind . <Up> ""
    bind . <Down> ""
    bind . <Left> ""
    bind . <Right> ""
    if {"$tcl_platform(platform)" == "windows"} {
	    bind . <MouseWheel> ""
    }
    $treePath configure -selectbackground gray
}

#---------------------------------------------------------------------------------------------------
#  Operations::SingleClickNode
# 
#  Arguments : node - selected node from treewidget
#
#  Results : -
#
#  Description : Displays required properties when corresponding nodes are clicked
#---------------------------------------------------------------------------------------------------
proc Operations::SingleClickNode {node} {
    variable notebook

    global treePath
    global nodeIdList
    global f0
    global f1
    global f2
    global nodeSelect
    global nodeIdList
    global savedValueList
    global lastConv
    global populatedPDOList
    global userPrefList
    global LastTableFocus
    global chkPrompt
    global ra_proj
    global indexSaveBtn
    global subindexSaveBtn
    global tableSaveBtn
	
    if { $nodeSelect == "" || ![$treePath exists $nodeSelect] || [string match "root" $nodeSelect] || [string match "ProjectNode" $nodeSelect] || [string match "MN-*" $nodeSelect] || [string match "OBD-*" $nodeSelect] || [string match "CN-*" $nodeSelect] || [string match "PDO-*" $nodeSelect] } {
	    #should not check for project settings option
    } else {
	    if { $ra_proj == "0"} {
		    if { $chkPrompt == 1 } {
			    if { [string match "TPDO-*" $nodeSelect] || [string match "RPDO-*" $nodeSelect] } {
				    $tableSaveBtn invoke
			    } elseif { [string match "*SubIndex*" $nodeSelect] } {
				    $subindexSaveBtn invoke
			    } elseif { [string match "*Index*" $nodeSelect] } {	
				    $indexSaveBtn invoke
			    } else {
				    #must be root, ProjectNode, MN, OBD or CN
			    }
		    }
		    Validation::ResetPromptFlag
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
						    #must be root, ProjectNode, MN, OBD or CN
					    }
				    }
				    no  {#continue}
			    }
		    }
		    Validation::ResetPromptFlag
	    } elseif { $ra_proj == "2" } {
		
	    } else {
		    #puts "\nInvalid Cond in SingleClickNode ra_proj->$ra_proj !!!\n"
		    return
	    }
    }

    $indexSaveBtn configure -state normal
    $subindexSaveBtn configure -state normal

    $treePath selection set $node
    set nodeSelect $node

    if {[string match "root" $node] || [string match "ProjectNode" $node] || [string match "MN-*" $node] || [string match "OBD-*" $node] || [string match "CN-*" $node] || [string match "PDO-*" $node]} {
	    pack forget [lindex $f0 0]
	    pack forget [lindex $f1 0]
	    pack forget [lindex $f2 0]
	    [lindex $f2 1] cancelediting
	    [lindex $f2 1] configure -state disabled
	    return
    }

    #getting Id and Type of node
    set result [Operations::GetNodeIdType $node]
    if {$result == ""} {
	    #the node is not an index, subindex, TPDO or RPDO do nothing
	    return
    } else {
	    # it is index or subindex
	    set nodeId [lindex $result 0]
	    set nodeType [lindex $result 1]
    }

    set nodePos [new_intp]
    set ExistfFlag [new_boolp]
    set catchErrCode [IfNodeExists $nodeId $nodeType $nodePos $ExistfFlag]
    set nodePos [intp_value $nodePos]
    set ExistfFlag [boolp_value $ExistfFlag]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode == 0 && $ExistfFlag == 1 } {
	    #the node exist continue 
    } else {
	    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
		    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -parent . -title Warning -icon warning
	    } else {
		    tk_messageBox -message "Unknown Error" -parent . -title Warning -icon warning
            #puts "Unknown Error ->[ocfmRetCode_errorString_get $catchErrCode]"
	    }
	    return
    }

    if {[string match "TPDO-*" $node] || [string match "RPDO-*" $node]} {
	    #the LastTableFocus is cleared to avoid potential bugs
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
	    set idx [$treePath nodes $node]
	    foreach tempIdx $idx {
		    set indexId [string range [$treePath itemcget $tempIdx -text] end-4 end-1 ]
		    if {[string match "$commParam*" $indexId]} {
			    lappend commParamList [list $indexId $tempIdx]
		    } elseif {[string match "$mappParam*" $indexId]} {
			    lappend mappParamList [list $indexId $tempIdx]
		    }
	    }
	    set finalMappList ""
	    set populatedPDOList ""
	
	    foreach chk $mappParamList {
		    set paramID [string range [lindex $chk 0] end-1 end]
		    set find [lsearch $commParamList [list $commParam$paramID *]]
		    if { $find != -1 } {
			    lappend finalMappList [lindex [lindex $commParamList $find] 1] [lindex $chk 1] 
			    lappend populatedPDOList [lindex $chk 1] 
		    } else {
			    lappend finalMappList [] [lindex $chk 1] 
			    lappend populatedPDOList [lindex $chk 1] 				
		    }
	    }
	    set popCount 0 
	    [lindex $f2 1] delete 0 end
	
	    set commParamValue ""
	    for {set count 0} { $count <= [expr [llength $finalMappList]-2] } {incr count 2} {
		    set tempIdx [lindex $finalMappList $count]
		    set commParamValue ""
		    if { $tempIdx != "" } {
			    set indexId [string range [$treePath itemcget $tempIdx -text] end-4 end-1 ]
			    set sidx [$treePath nodes $tempIdx]
			    foreach tempSidx $sidx {
				    set subIndexId [string range [$treePath itemcget $tempSidx -text] end-2 end-1 ]
				    if { [string match "01" $subIndexId] == 1 } {
					    set indexPos [new_intp] 
					    set subIndexPos [new_intp] 
					    set catchErrCode [IfSubIndexExists $nodeId $nodeType $indexId $subIndexId $subIndexPos $indexPos] ; #newly added
					    set indexPos [intp_value $indexPos]
					    set subIndexPos [intp_value $subIndexPos] 
					    # 5 is passed to get the actual value
					    set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 5 ]
					    set ErrCode [ocfmRetCode_code_get [lindex $tempIndexProp 0] ]		
					    if {$ErrCode != 0} {
						    #puts "ErrCode in singleclick for TDDO and RPDO : $ErrCode"
						    continue	
					    }
					    set IndexActualValue [lindex $tempIndexProp 1]
					    if {[string match -nocase "0x*" $IndexActualValue] } {
						    #remove appended 0x
						    set IndexActualValue [string range $IndexActualValue 2 end]
					    } else {
						    # no 0x no need to do anything
					    }
					    set commParamValue $IndexActualValue
					    break 
				    }
			    }
		    }
		    set tempIdx [lindex $finalMappList $count+1]
		    set indexId [string range [$treePath itemcget $tempIdx -text] end-4 end-1 ]
		    set sidx [$treePath nodes $tempIdx]
		    foreach tempSidx $sidx { 
			    set subIndexId [string range [$treePath itemcget $tempSidx -text] end-2 end-1 ]
			    if {[string match "00" $subIndexId] == 0 } {
				    set indexPos [new_intp]
				    set subIndexPos [new_intp] 
				    set catchErrCode [IfSubIndexExists $nodeId $nodeType $indexId $subIndexId $subIndexPos $indexPos] 
				    set indexPos [intp_value $indexPos] 
				    set subIndexPos [intp_value $subIndexPos] 
				    # 3 is passed to get the accesstype
				    set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 3 ] 
				    if {$ErrCode != 0} {
					    #puts "ErrCode in singleclick for access type TDDO and RPDO : $ErrCode"
					    [lindex $f2 1] insert $popCount [list "" "" "" "" "" ""]
					    foreach col [list 2 3 4 5 ] {
						    [lindex $f2 1] cellconfigure $popCount,$col -editable no
					    }
					    incr popCount 1 
					    continue	
				    } 
				    set accessType [lindex $tempIndexProp 1]
				    # 5 is passed to get the actual value
				    set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 5 ] 
				    set ErrCode [ocfmRetCode_code_get [lindex $tempIndexProp 0] ]		
				    if {$ErrCode != 0} {
					    #puts "ErrCode in singleclick for actual value TDDO and RPDO : $ErrCode"
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
				    }
				
				    set length [string range $IndexActualValue 0 3]
				    set offset [string range $IndexActualValue 4 7]
				    set reserved [string range $IndexActualValue 8 9]
				    set listSubIndex [string range $IndexActualValue 10 11]
				    set listIndex [string range $IndexActualValue 12 15]
				    [lindex $f2 1] insert $popCount [list $popCount 0x$commParamValue 0x$offset 0x$length 0x$listIndex 0x$listSubIndex ]
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
		    }
	    }
	    pack forget [lindex $f0 0]
	    pack forget [lindex $f1 0]
	    pack [lindex $f2 0] -expand yes -fill both -padx 2 -pady 4
	    return 
    } 

    #checking whether value has changed using save. changing the background accordingly
    if {[lsearch $savedValueList $node] != -1} {
	    set savedBg #fdfdd4
    } else {
	    set savedBg white
    }

    if {[string match "*SubIndex*" $node]} {
	    set tmpInnerf0 [lindex $f1 1]
	    set tmpInnerf1 [lindex $f1 2]
	    set subIndexId [string range [$treePath itemcget $node -text] end-2 end-1]
	    set parent [$treePath parent $node]
	    set indexId [string range [$treePath itemcget $parent -text] end-4 end-1]

	    if { [expr 0x$indexId > 0x1fff] } {
		    set entryState normal
	    } else {
		    set entryState disabled
	    }
	    set indexPos [new_intp] 
	    set subIndexPos [new_intp] 
	    set catchErrCode [IfSubIndexExists $nodeId $nodeType $indexId $subIndexId $subIndexPos $indexPos]
	    if { [ocfmRetCode_code_get $catchErrCode] != 0 } {
		    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .
		    } else {
			    tk_messageBox -message "Unknown Error" -title Warning -icon warning -parent .
		    }
		    return
	    }
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
        #puts "IndexProp->$IndexProp"

	    $tmpInnerf0.en_idx1 configure -state normal
	    $tmpInnerf0.en_idx1 delete 0 end
	    $tmpInnerf0.en_idx1 insert 0 0x$indexId
	    $tmpInnerf0.en_idx1 configure -state disabled

	    $tmpInnerf0.en_sidx1 configure -state normal
	    $tmpInnerf0.en_sidx1 delete 0 end
	    $tmpInnerf0.en_sidx1 insert 0 0x$subIndexId
	    $tmpInnerf0.en_sidx1 configure -state disabled
	    #$tmpInnerf0.en_sidx1 configure -state $entryState

	    pack forget [lindex $f0 0]
	    pack [lindex $f1 0] -expand yes -fill both -padx 2 -pady 4
	    pack forget [lindex $f2 0]
	    [lindex $f2 1] cancelediting
	    [lindex $f2 1] configure -state disabled
    } elseif {[string match "*Index*" $node]} {
	    set tmpInnerf0 [lindex $f0 1]
	    set tmpInnerf1 [lindex $f0 2]

	    set indexId [string range [$treePath itemcget $node -text] end-4 end-1]
	    if { [expr 0x$indexId > 0x1fff] } {
		    set entryState normal
	    } else {
		    set entryState disabled
	    }
	
	    set indexPos [new_intp] 
	    set catchErrCode [IfIndexExists $nodeId $nodeType $indexId $indexPos]
	    if { [ocfmRetCode_code_get $catchErrCode] != 0 } {
		    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .
		    } else {
			    tk_messageBox -message "Unknown Error" -title Warning -icon warning -parent .
		    }
		    return
	    }
	    set indexPos [intp_value $indexPos] 
	    set IndexProp []
	    for {set cnt 0 } {$cnt <= 9} {incr cnt} {
		    set tempIndexProp [GetIndexAttributesbyPositions $nodePos $indexPos $cnt ]
		    set ErrCode [ocfmRetCode_code_get [lindex $tempIndexProp 0]]
		    if {$ErrCode == 0} {
			    lappend IndexProp [lindex $tempIndexProp 1]
		    } else {
			    lappend IndexProp []
		    }

	    }
    #puts "IndexProp->$IndexProp"
	    $tmpInnerf0.en_idx1 configure -state normal
	    $tmpInnerf0.en_idx1 delete 0 end
	    $tmpInnerf0.en_idx1 insert 0 0x$indexId
	    $tmpInnerf0.en_idx1 configure -state disabled
	    #$tmpInnerf0.en_idx1 configure -state $entryState

	    pack [lindex $f0 0] -expand yes -fill both -padx 2 -pady 4
	    pack forget [lindex $f1 0]
	    pack forget [lindex $f2 0]
	    [lindex $f2 1] cancelediting
	    [lindex $f2 1] configure -state disabled
	
	    if { [string match -nocase "A???" $indexId] } {
		    $tmpInnerf0.frame1.ch_gen configure -state disabled
	    } else {
		    $tmpInnerf0.frame1.ch_gen configure -state normal
		    if { [lindex $IndexProp 9] == "1" } {
			    $tmpInnerf0.frame1.ch_gen select
		    } else {
			    $tmpInnerf0.frame1.ch_gen deselect
		    }
	    }

    }

    $tmpInnerf0.en_nam1 configure -validate none
    $tmpInnerf0.en_nam1 delete 0 end
    $tmpInnerf0.en_nam1 insert 0 [lindex $IndexProp 0]
    $tmpInnerf0.en_nam1 configure -bg $savedBg -validate key

    $tmpInnerf1.en_data1 configure -state normal
    $tmpInnerf1.en_data1 delete 0 end
    $tmpInnerf1.en_data1 insert 0 [lindex $IndexProp 2]
    $tmpInnerf1.en_data1 configure -state $entryState -bg white


    $tmpInnerf1.en_default1 configure -state normal
    $tmpInnerf1.en_default1 delete 0 end
    $tmpInnerf1.en_default1 insert 0 [lindex $IndexProp 4]
    $tmpInnerf1.en_default1 configure -state $entryState -bg white

    $tmpInnerf1.en_value1 configure -state normal -validate none -bg $savedBg
    $tmpInnerf1.en_value1 delete 0 end
    $tmpInnerf1.en_value1 insert 0 [lindex $IndexProp 5]

    $tmpInnerf1.en_lower1 configure -state normal -validate none
    $tmpInnerf1.en_lower1 delete 0 end
    $tmpInnerf1.en_lower1 insert 0 [lindex $IndexProp 7]
    $tmpInnerf1.en_lower1 configure -state $entryState -bg white -validate key

    $tmpInnerf1.en_upper1 configure -state normal -validate none
    $tmpInnerf1.en_upper1 delete 0 end
    $tmpInnerf1.en_upper1 insert 0 [lindex $IndexProp 8]
    $tmpInnerf1.en_upper1 configure -state $entryState -bg white -validate key

    if { [expr 0x$indexId < 0x1fff] } {
	    grid remove $tmpInnerf1.co_obj1
	    grid $tmpInnerf1.en_obj1
	    $tmpInnerf1.en_obj1 configure -state normal
	    $tmpInnerf1.en_obj1 delete 0 end
	    $tmpInnerf1.en_obj1 insert 0 [lindex $IndexProp 1]
	    $tmpInnerf1.en_obj1 configure -state disabled

	    grid remove $tmpInnerf1.co_access1
	    grid $tmpInnerf1.en_access1
	    $tmpInnerf1.en_access1 configure -state normal
	    $tmpInnerf1.en_access1 delete 0 end
	    $tmpInnerf1.en_access1 insert 0 [lindex $IndexProp 3]
	    $tmpInnerf1.en_access1 configure -state disabled
	
	    grid remove $tmpInnerf1.co_pdo1
	    grid $tmpInnerf1.en_pdo1
	    $tmpInnerf1.en_pdo1 configure -state normal
	    $tmpInnerf1.en_pdo1 delete 0 end
	    $tmpInnerf1.en_pdo1 insert 0 [lindex $IndexProp 6]
	    $tmpInnerf1.en_pdo1 configure -state disabled
	
	    if { [lindex $IndexProp 2] == "IP_ADDRESS" } {
		    set lastConv ""
		    grid remove $tmpInnerf1.frame1.ra_dec
		    grid remove $tmpInnerf1.frame1.ra_hex
		    $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsIP %P %V" -bg $savedBg
	    } elseif { [lindex $IndexProp 2] == "MAC_ADDRESS" } {
		    set lastConv ""
		    grid remove $tmpInnerf1.frame1.ra_dec
		    grid remove $tmpInnerf1.frame1.ra_hex
		    $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsMAC %P %V" -bg $savedBg
	    } elseif { [lindex $IndexProp 2] == "Visible_String" } {
		    set lastConv ""
		    grid remove $tmpInnerf1.frame1.ra_dec
		    grid remove $tmpInnerf1.frame1.ra_hex
		    $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsValidStr %P" -bg $savedBg
	    } else {
		    grid $tmpInnerf1.frame1.ra_dec
		    grid $tmpInnerf1.frame1.ra_hex
		
		    #puts "\nIN singleclicknode userPrefList->$userPrefList"
		    set schRes [lsearch $userPrefList [list $nodeSelect *]]
		    #puts "schRes->$schRes\n STATE=[$tmpInnerf1.en_value1 cget -state] \t $tmpInnerf1.en_value1\n"
		    if { $schRes != -1 } {
			    if { [lindex [lindex $userPrefList $schRes] 1] == "dec" } {
				    if {[string match -nocase "0x*" [lindex $IndexProp 5]]} {
					    $tmpInnerf1.en_value1 configure -validate none
					    NoteBookManager::InsertDecimal $tmpInnerf1.en_value1
					    $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsDec %P $tmpInnerf1.en_value1 %d %i" -bg $savedBg	
				    } else {
					    # actual value already in decimal 
				    }
			
				    if {[string match -nocase "0x*" [lindex $IndexProp 4]]} {
					    set state [$tmpInnerf1.en_default1 cget -state]
					    $tmpInnerf1.en_default1 configure -state normal
					    NoteBookManager::InsertDecimal $tmpInnerf1.en_default1
					    $tmpInnerf1.en_default1 configure -state $state
				    } else {
					    # default value already in decimal
				    }
				    set lastConv dec
				    $tmpInnerf1.frame1.ra_dec select
			    } elseif { [lindex [lindex $userPrefList $schRes] 1] == "hex" } {
				    if {[string match -nocase "0x*" [lindex $IndexProp 5]]} {
					    # actual already in hexadecimal 
				    } else {
					    $tmpInnerf1.en_value1 configure -validate none
					    NoteBookManager::InsertHex $tmpInnerf1.en_value1
					    $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsHex %P %s $tmpInnerf1.en_value1 %d %i" -bg $savedBg
				    }
			
				    if {[string match -nocase "0x*" [lindex $IndexProp 4]]} {
					    # default is in hexadecimal 
				    } else {
					    set state [$tmpInnerf1.en_default1 cget -state]
					    $tmpInnerf1.en_default1 configure -state normal
					    NoteBookManager::InsertHex $tmpInnerf1.en_default1
					    $tmpInnerf1.en_default1 configure -state $state
				    }
					
				    set lastConv hex
				    $tmpInnerf1.frame1.ra_hex select
			    } else {
				    #puts "\n\nInvalid userpref [lindex $userPrefList 1]\n\n"
				    return 
			    }
		    } else {
			    if {[string match -nocase "0x*" [lindex $IndexProp 5]]} {
				    set lastConv hex
				    if {[string match -nocase "0x*" [lindex $IndexProp 4]]} {
					    #default value is in hexadecimal
				    } else {
					    set state [$tmpInnerf1.en_default1 cget -state]
					    $tmpInnerf1.en_default1 configure -state normal
					    NoteBookManager::InsertHex $tmpInnerf1.en_default1
					    $tmpInnerf1.en_default1 configure -state $state
				    }
				    $tmpInnerf1.frame1.ra_hex select
				    $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsHex %P %s $tmpInnerf1.en_value1 %d %i" -bg $savedBg
			    } else {
				    set lastConv dec
				    if {[string match -nocase "0x*" [lindex $IndexProp 4]]} {
					    #convert default hexadecimal to decimal"
					    set state [$tmpInnerf1.en_default1 cget -state]
					    $tmpInnerf1.en_default1 configure -state normal
					    NoteBookManager::InsertDecimal $tmpInnerf1.en_default1
					    $tmpInnerf1.en_default1 configure -state $state
				    } else {
					    #default value is in decimal
				    }
				    $tmpInnerf1.frame1.ra_dec select
				    $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsDec %P $tmpInnerf1.en_value1 %d %i" -bg $savedBg
			    }
		    }
	    }

	    if { [lindex $IndexProp 3] == "const" || [lindex $IndexProp 3] == "ro" || [lindex $IndexProp 3] == "" } {
		    #the field is non editable
		    $tmpInnerf1.en_value1 configure -state "disabled"
	    } else {
		    $tmpInnerf1.en_value1 configure -state "normal"
	    }
    } else {
	
	    grid remove $tmpInnerf1.frame1.ra_dec
	    grid remove $tmpInnerf1.frame1.ra_hex
	
	    grid remove $tmpInnerf1.en_obj1
	    NoteBookManager::SetComboValue $tmpInnerf1.co_obj1 [lindex $IndexProp 1]
	    grid $tmpInnerf1.co_obj1
	
	    grid remove $tmpInnerf1.en_access1
	    NoteBookManager::SetComboValue $tmpInnerf1.co_access1 [lindex $IndexProp 3]
	    grid $tmpInnerf1.co_access1
	
	    grid remove $tmpInnerf1.en_pdo1
	    NoteBookManager::SetComboValue $tmpInnerf1.co_pdo1 [lindex $IndexProp 6]
	    grid $tmpInnerf1.co_pdo1
	
	    $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsValidStr %P"
	
	    if { [string match -nocase "A???" $indexId] == 1 } {
		    #make the save button disabled
		    $indexSaveBtn configure -state disabled
		    $subindexSaveBtn configure -state disabled
		
		    $tmpInnerf0.en_nam1 configure -state disabled
		    $tmpInnerf1.en_data1 configure -state disabled
		    $tmpInnerf1.en_default1 configure -state disabled
		    $tmpInnerf1.en_value1 configure -state disabled
		    $tmpInnerf1.en_lower1 configure -state disabled
		    $tmpInnerf1.en_upper1 configure -state disabled
		    $tmpInnerf1.co_obj1 configure -state disabled
		    $tmpInnerf1.co_access1 configure -state disabled
		    $tmpInnerf1.co_pdo1 configure -state disabled
	    }
	
    }
    return
}

#---------------------------------------------------------------------------------------------------
#  Operations::DoubleClickNode
# 
#  Arguments : node - selected node from treewidget
#
#  Results : -
#
#  Description : Displays required properties and expands tree when corresponding nodes are clicked 
#---------------------------------------------------------------------------------------------------
proc Operations::DoubleClickNode {node} {
    global treePath

    if {[$treePath nodes $node] != "" } {
	    if {[$treePath itemcget $node -open]} {
		    #it is already expanded so collapse it
		    $treePath itemconfigure $node -open 0
	    } else {
			    #it is collapsed so expand it
			    $treePath itemconfigure $node -open 1
	    }
    } else {
	    # it has no child no need to expand
    }
    Operations::SingleClickNode $node
} 

#---------------------------------------------------------------------------------------------------
#  Operations::Saveproject
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Calls the API to save projext
#---------------------------------------------------------------------------------------------------
proc Operations::Saveproject {} {
    global tcl_platform
    global projectName
    global projectDir
    global status_save

    if {$projectDir == "" || $projectName == "" } {
	    #there is no project directory or project name no need to save
	    return
    } else {
	    set savePjtName [string range $projectName 0 end-[ string length [file extension $projectName] ]]
	    set savePjtDir [string range $projectDir 0 end-[string length $savePjtName] ]
                thread::send -async [tsv::set application importProgress] "StartProgress"
	    set catchErrCode [SaveProject $savePjtDir $savePjtName]
	    thread::send -async [tsv::set application importProgress] "StopProgress"
	    set ErrCode [ocfmRetCode_code_get $catchErrCode]
	    if { $ErrCode != 0 } {
		    #tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
		    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -parent . -title Warning -icon warning
		    } else {
			    tk_messageBox -message "Unknown Error" -parent . -title Warning -icon warning
		    }
		    DisplayErrMsg "Project $projectName at location $projectDir  is saved" error
		    return 
	    }
	
	
    }
    #project is saved so change status to zero
    set status_save 0

    DisplayInfo "Project $projectName at location $projectDir  is saved"
}

#---------------------------------------------------------------------------------------------------
#  Operations::InitiateNewProject
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Save the current project and creates new project
#---------------------------------------------------------------------------------------------------
proc Operations::InitiateNewProject {} {
    set result [ChildWindows::SaveProjectWindow] 
    if { $result != "cancel"} {
	    ChildWindows::NewProjectWindow
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::InitiateCloseProject
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Save the current project and close th project
#---------------------------------------------------------------------------------------------------
proc Operations::InitiateCloseProject {} {
    global status_save
    global projectName

    #before close should prompt to close
    if {$status_save} {
	    set result [tk_messageBox -message "Save Project $projectName Before closing?" -parent . -type yesnocancel -icon question -title "Question"]
	    switch -- $result {
		    yes {			 
			    Operations::Saveproject
			    DisplayInfo "Project $projectName is saved" info
		    }
		    no {
			    DisplayInfo "Project $projectName not saved" info
		    }
		    cancel {
			    return
		    }
	    }
	    Operations::CloseProject
    } else {
	    set result [ChildWindows::CloseProjectWindow]
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::CloseProject
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Deletes the tree widget, deletes all the node in current project
#                and resets global data
#---------------------------------------------------------------------------------------------------
proc Operations::CloseProject {} {
    global treePath

    Operations::DeleteAllNode

    Operations::ResetGlobalData

    catch {$treePath delete ProjectNode}

    if { [$Operations::projMenu index 4] == "4" } {
	    catch {$Operations::projMenu delete 4}
    }
    if { [$Operations::projMenu index 3] == "3" } {
	    catch {$Operations::projMenu delete 3}
    }

    Operations::InsertTree
	
}

#---------------------------------------------------------------------------------------------------
#  Operations::ResetGlobalData
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Resets all the globally maintained data
#---------------------------------------------------------------------------------------------------
proc Operations::ResetGlobalData {} {
    global projectDir
    global projectName
    global nodeIdList
    global savedValueList
    global populatedPDOList
    global userPrefList
    global nodeSelect	
    global treePath
    global mnCount
    global cnCount
    global status_save
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
    set status_save 0 
    set projectDir ""
    set projectName ""
    set lastConv ""
    set LastTableFocus ""
    Validation::ResetPromptFlag
    set ra_proj 2 
    set ra_auto 0 
    #no need to reset lastOpenPjt, lastXD, tableSaveBtn, indexSaveBtn and subindexSaveBtn

    #no index subindex or pdo table should be displayed
    pack forget [lindex $f0 0]
    pack forget [lindex $f1 0]
    pack forget [lindex $f2 0]
    [lindex $f2 1] cancelediting
    [lindex $f2 1] configure -state disabled

    update
}

#---------------------------------------------------------------------------------------------------
#  Operations::DeleteAllNode
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Deletes all the node in current project
#---------------------------------------------------------------------------------------------------
proc Operations::DeleteAllNode {} {
    global nodeIdList

    if {[llength $nodeIdList] != 0} {
	    foreach nodeId $nodeIdList {
		    if {$nodeId == 240} {
			    # nodeId is 240 for mn
			    set nodeType 0
		    } else {
			    set nodeType 1
		    }	
		    DeleteNode $nodeId $nodeType
	    }
    } else {
	    #there was no node created
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::AddCN
# 
#  Arguments : cnName    - name of CN
#              tmpImpDir - file to be imported
#              nodeId    - Id for CN
#
#  Results : -
#
#  Description : Creates the CN node
#---------------------------------------------------------------------------------------------------
proc Operations::AddCN {cnName tmpImpDir nodeId} {
    global treePath
    global cnCount
    global mnCount
    global nodeIdList
    global status_save

    incr cnCount
    set catchErrCode [Operations::NodeCreate $nodeId 1 $cnName]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode != 0 } {
	    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
		    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]"  -title Warning -icon warning
	    } else {
		    tk_messageBox -message "Unknown Error" -title Warning -icon warning
	    }
	    return 
    }

    #New CN is created need to save
    set status_save 1

    set node [$treePath selection get]
    set parentId [split $node -]
    set parentId [lrange $parentId 1 end]
    set parentId [join $parentId -]

    lappend nodeIdList $nodeId 
    #creating the GUI for CN
    set child [$treePath insert end $node CN-$parentId-$cnCount -text "$cnName\($nodeId\)" -open 0 -image [Bitmap::get cn]]

    if {$tmpImpDir != ""} {
	    #API
	    #DllExport ocfmRetCode ImportXML(char* fileName, int NodeID, ENodeType NodeType);
	    set catchErrCode [ImportXML "$tmpImpDir" $nodeId 1]
	    set ErrCode [ocfmRetCode_code_get $catchErrCode]
	    if { $ErrCode != 0 } {
		    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
		    } else {
			    tk_messageBox -message "Unknown Error" -title Warning -icon warning
		    }
		    return 
	    } else {
		    DisplayInfo "Imported $tmpImpDir for Node ID: $nodeId"
	    }
                thread::send -async [tsv::set application importProgress] "StartProgress"
	    set result [WrapperInteractions::Import CN-$parentId-$cnCount 1 $nodeId]
	    thread::send -async [tsv::set application importProgress] "StopProgress"
	    if { $result == "fail" } {
		    return
	    }
	
    } else {
	    lappend nodeIdList $nodeId 
    }
    return 
}

#---------------------------------------------------------------------------------------------------
#  YetToImplement
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Displays message for non implemented function 
#---------------------------------------------------------------------------------------------------
proc YetToImplement {} {
    tk_messageBox -message "Yet to be Implemented !" -title Info -icon info
}

#---------------------------------------------------------------------------------------------------
#  Operations::InsertTree
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Inserts the initial node in tree widget
#---------------------------------------------------------------------------------------------------
proc Operations::InsertTree { } {
    global treePath
    global cnCount
    global mnCount
    incr cnCount
    incr mnCount
    $treePath insert end root ProjectNode -text "POWERLINK Network" -open 1 -image [Bitmap::get network]
}

#---------------------------------------------------------------------------------------------------
#  NameSpace Declaration
#
#  namespace : FindSpace
#---------------------------------------------------------------------------------------------------
namespace eval FindSpace {
    variable findList
    variable searchString
    variable searchCount
    variable txtFindDym
}

#---------------------------------------------------------------------------------------------------
#  FindSpace::FindDynWindow
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Displays GUI for Find and add binding for Next button
#---------------------------------------------------------------------------------------------------
proc FindSpace::FindDynWindow {} {
    catch {
	    global treeFrame
	    pack $treeFrame -side bottom -pady 5
	    focus $treeFrame.en_find
	    bind $treeFrame.en_find <KeyPress-Return> "FindSpace::Next"
	    set FindSpace::txtFindDym ""
    }
}

#---------------------------------------------------------------------------------------------------
#  FindSpace::EscapeTree
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Hides GUI for Find and remove binding for Next button
#---------------------------------------------------------------------------------------------------
proc FindSpace::EscapeTree {} {
    catch {
	    global treeFrame
	    pack forget $treeFrame
	    bind $treeFrame.en_find <KeyPress-Return> ""
    }
}

#---------------------------------------------------------------------------------------------------
#  FindSpace::Find
# 
#  Arguments : searchStr - search string
#              node      - node to be refered while searching
#              mode      - indicate mode of searching
#
#  Results : nodes containing search string
#
#  Description : Finds nodes containing search string
#---------------------------------------------------------------------------------------------------
proc FindSpace::Find { searchStr {node ""} {mode 0} } {
    global treePath

    set FindSpace::searchString $searchStr
    set flag 0
    set chk 0
    set prev ""
    set next ""
    if {$searchStr== ""} {
	    $treePath selection clear
	    return 1
    }
    set mnNode [$treePath nodes ProjectNode]
    foreach tempMn $mnNode {
	    if {$tempMn == $node && $mode != 0} {
		    if {$mode == "prev"} {
			    return $prev
		    } else {
			    set flag 1
		    }
	    }
	    set childMn [$treePath nodes $tempMn]
	    foreach tempChildMn $childMn {
		    if {$tempChildMn == $node && $mode != 0} {
			    if {$mode == "prev"} {
				    return $prev
			    } else {
				    set flag 1
			    }
		    }
		    set idx [$treePath nodes $tempChildMn]
		    foreach tempIdx $idx {
			    if {$tempIdx == $node && $mode != 0} {
				    if {$mode == "prev"} {
					    return $prev
				    } else {
					    set flag 1
					    set chk 1
				    }
			    }
			    if {[string match -nocase "PDO*" $tempIdx]} {
				    set childPdo [$treePath nodes $tempIdx]
				    foreach tempPdo $childPdo {
					    if {$tempPdo == $node && $mode != 0} {
						    if {$mode == "prev"} {
							    return $prev
						    } else {
							    set flag 1
						    }
					    }
					    set pdoIdx [$treePath nodes $tempPdo]
					    foreach tempPdoIdx $pdoIdx { 
						    if {$tempPdoIdx == $node && $mode != 0} {
							    if {$mode == "prev"} {
								    return $prev
							    } else {
								    set flag 1
								    set chk 1
							    }
						    }
						    if {[string match -nocase "*$searchStr*" [$treePath itemcget $tempPdoIdx -text]] && $chk == 0} {
							    if { $mode == 0 } {
								    FindSpace::OpenParent $treePath $tempPdoIdx
								    return 1
							    } elseif {$mode == "prev" } {
								    set prev $tempPdoIdx
							    } elseif {$mode == "next" } {
								    if {$flag == 0} {
									    #do nothing
								    } elseif {$flag == 1} {
									    set next $tempPdoIdx
									    return $next
								    }
							    }
						    } elseif {$chk == 1} {
							    set chk 0
						    }
						    set pdoSidx [$treePath nodes $tempPdoIdx]
						    foreach tempPdoSidx $pdoSidx { 
							    if {$tempPdoSidx == $node && $mode != 0} {
								    if {$mode == "prev"} {
									    return $prev
								    } else {
									    set flag 1
									    set chk 1
								    }
							    }
							    if {[string match -nocase "*$searchStr*" [$treePath itemcget $tempPdoSidx -text]] && $chk == 0} {
								    if { $mode == 0 } {
									    FindSpace::OpenParent $treePath $tempPdoSidx
									    return 1
								    } elseif {$mode == "prev" } {
									    set prev $tempPdoSidx
								    } elseif {$mode == "next" } {
									    if {$flag == 0} {
										    #do nothing
									    } elseif {$flag == 1} {
										    set next $tempPdoSidx
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
			    if {[string match -nocase "*$searchStr*" [$treePath itemcget $tempIdx -text]] && $chk == 0} {
				    if { $mode == 0 } { 
					    FindSpace::OpenParent $treePath $tempIdx
					    return 1
				    } elseif {$mode == "prev" } {
					    set prev $tempIdx
				    } elseif {$mode == "next" } {
					    if {$flag == 0} {
						    #do nothing
					    } elseif {$flag == 1} {
						    set next $tempIdx
						    return $next
					    }
				    }
			    } elseif {$chk == 1} {
				    set chk 0
			    }
				
			    set sidx [$treePath nodes $tempIdx]
			    foreach tempSidx $sidx { 
				    if {$tempSidx == $node && $mode != 0} {
					    if {$mode == "prev"} {
						    return $prev
					    } else {
						    set flag 1
						    set chk 1
					    }
				    }
				    if {[string match -nocase "*$searchStr*" [$treePath itemcget $tempSidx -text]] && $chk == 0} {
					    if { $mode == 0 } { 
						    FindSpace::OpenParent $treePath $tempSidx
						    return 1
					    } elseif {$mode == "prev" } {
						    set prev $tempSidx
					    } elseif {$mode == "next" } {
						    if {$flag == 0} {
							    #do nothing
						    } elseif {$flag == 1} {
							    set next $tempSidx
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
    if {$mode == 0} {
	    $treePath selection clear
	    return 1
    } else {
	    $treePath selection clear
	    return ""
    } 
}

#---------------------------------------------------------------------------------------------------
#  FindSpace::OpenParent
# 
#  Arguments : treePath - path to the tree widget
#              node     - node containing search string
#
#  Results : -
#
#  Description : Node is made visible 
#---------------------------------------------------------------------------------------------------
proc FindSpace::OpenParent { treePath node } {
    $treePath selection clear
    set tempNode $node
    while {[$treePath parent $tempNode] != "ProjectNode"} {
	    #puts "open parent tempNode->$tempNode"
	    set tempNode [$treePath parent $tempNode]
	    $treePath itemconfigure $tempNode -open 1
    }
    $treePath selection set $node 
    $treePath see $node
}

#---------------------------------------------------------------------------------------------------
#  FindSpace::Prev
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Displays previous node containing search string
#---------------------------------------------------------------------------------------------------
proc FindSpace::Prev {} {
    global treePath
    set node [$treePath selection get]
    if {![info exists FindSpace::searchString]} {
	    return
    } 
    if {$node == ""} {
	    # if no node is selected find first match
	    FindSpace::Find $FindSpace::searchString
    } else {
	    set prev [FindSpace::Find $FindSpace::searchString $node prev]
	    if { $prev != "" } {
		    FindSpace::OpenParent $treePath $prev
	    }
	    return
    }
}

#---------------------------------------------------------------------------------------------------
#  FindSpace::Next
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Displays next node containing search string
#---------------------------------------------------------------------------------------------------
proc FindSpace::Next {} {
    global treePath
    set node [$treePath selection get]
    if {![info exists FindSpace::searchString]} {
        return
    } 
    if {$node == ""} {
        # if no node is selected find first match
        FindSpace::Find $FindSpace::searchString
    } else {	
        set next [FindSpace::Find $FindSpace::searchString $node next]
        if { $next != "" } {
	        FindSpace::OpenParent $treePath $next
        }
        return
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::StartStack
# 
#  Arguments : -
#
#  Results : -
#
#  Description : 
#---------------------------------------------------------------------------------------------------
proc Operations::StartStack {} {
	global projectDir
	global tcl_platform
	
	if { "$tcl_platform(platform)" == "unix" } {
		
		set startFile [file join $projectDir scripts start.sh]
	} elseif { "$tcl_platform(platform)" == "windows" } {
		set startFile [file join $projectDir scripts start.bat]
	}
	if { [file exists $startFile] } {
		catch { exec $startFile }
	}
}

#---------------------------------------------------------------------------------------------------
#  Operations::StopStack
# 
#  Arguments : -
#
#  Results : -
#
#  Description : 
#---------------------------------------------------------------------------------------------------
proc Operations::StopStack {} {
	global projectDir
	global tcl_platform
	
	if { "$tcl_platform(platform)" == "unix" } {
		set stopFile [file join $projectDir scripts stop.sh]
	} elseif { "$tcl_platform(platform)" == "windows" } {
		set stopFile [file join $projectDir scripts stop.bat]
	}
	if { [file exists $stopFile] } {
		catch { exec $stopFile }
	}
}

#---------------------------------------------------------------------------------------------------
#  Operations::TransferCDCXAP
# 
#  Arguments : -
#
#  Results : -
#
#  Description : 
#---------------------------------------------------------------------------------------------------
proc Operations::TransferCDCXAP {choice} {
	global projectDir
	global tcl_platform
	
	if { "$tcl_platform(platform)" == "unix" } {
		set transferFile [file join $projectDir scripts transfer.sh]
	} elseif { "$tcl_platform(platform)" == "windows" } {
		set transferFile [file join $projectDir scripts transfer.bat]
	}
	
	if { [file exists $transferFile] } {
		catch { exec $transferFile }
	}
}

#---------------------------------------------------------------------------------------------------
#  Operations::BuildProject
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Builds the project and generate cdc and xap files
#---------------------------------------------------------------------------------------------------
proc Operations::BuildProject {} {
    global projectDir
    global projectName
    global ra_proj
    global ra_auto
    global nodeIdList
    global savedValueList
    global populatedPDOList
    global userPrefList
    global nodeSelect	
    global treePath
    global mnCount
    global cnCount
    global f0
    global f1
    global f2
    global status_save

    if {$projectDir == "" || $projectName == "" } {
	    DisplayErrMsg "No project to Build"
	    return	
    }

    if { $ra_auto == 1 } {
	    set result [tk_messageBox -message "MN saved values will be lost\nDo you want to Build Project?" -type yesno -icon question -title "Question" -parent .]
	    switch -- $result {
		    yes {
			    #continue
		    }
		    no { 
			    return
		    }
	    }
    }

    thread::send [tsv::get application importProgress] "StartProgress"	
    set catchErrCode [GenerateCDC [file join $projectDir cdc_xap] ]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]

    if { $ErrCode != 0 } {
	    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
		    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .
	    } else {
		    tk_messageBox -message "Unknown Error" -title Warning -icon warning -parent .
	    }
	    #error in generating CDC dont generate XAP
	    DisplayErrMsg "Error in generating cdc. xap was not generated" error
	    thread::send [tsv::get application importProgress] "StopProgress"
	    return
    } else {
	    set tempPjtDir $projectDir
	    set tempPjtName $projectName
	    set tempRa_proj $ra_proj
	    set tempRa_auto $ra_auto
	    Operations::ResetGlobalData
	    set projectDir $tempPjtDir
	    set projectName $tempPjtName
	    set ra_proj $tempRa_proj
	    set ra_auto $tempRa_auto

	    Operations::RePopulate  $projectDir [string range $projectName 0 end-[string length [file extension $projectName] ] ]
	    set catchErrCode [GenerateXAP [file join $projectDir cdc_xap xap] ]
	    set ErrCode [ocfmRetCode_code_get $catchErrCode]
	    if { $ErrCode != 0 } {
		    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .
		    } else {
			    tk_messageBox -message "Unknown Error" -title Warning -icon warning -parent .
		    }
		    DisplayErrMsg "xap is not generated"
		    thread::send -async [tsv::set application importProgress] "StopProgress"			
		    return
	    } else {
		    DisplayInfo "CDC and XAP are successfully generated"
		    DisplayInfo "files mnobd.txt mnobd.cdc xap.xml xap.h are generated in location [file join $projectDir cdc_xap]"
		    thread::send -async [tsv::set application importProgress] "StopProgress"
	    }
	    #project is built need to save
	    set status_save 1
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::CleanProject
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Deletes cdc and xap related files in project
#---------------------------------------------------------------------------------------------------
proc Operations::CleanProject {} {
    global projectDir
    global projectName 

    foreach tempFile [list mnobd.txt mnobd.cdc xap.xml xap.h] {
	    set CleanFile [file join $projectDir cdc_xap $tempFile]
	    catch {file delete -force $CleanFile}
    }
    DisplayInfo "files mnobd.txt mnobd.cdc xap.xml xap.h in [file join $projectDir cdc_xap] are deleted "
}

#---------------------------------------------------------------------------------------------------
#  Operations::ReImport
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Imports XDC/XDD file for MN or CN 
#---------------------------------------------------------------------------------------------------
proc Operations::ReImport {} {
    global treePath
    global nodeIdList
    global status_save
    global lastXD
    global f0
    global f1
    global f2

    set node [$treePath selection get]
    if {[string match "MN*" $node]} {
	    set child [$treePath nodes $node]
	    set tmpNode [string range $node 2 end]
	    # since a MN has only one so -1 is appended
	    set node OBD$tmpNode-1
	    set res [lsearch $child "OBD$tmpNode-1*"]
	    set nodeId 240
	    set nodeType 0

    } else {
	    #gets the nodeId and Type of selected node
	    set result [Operations::GetNodeIdType $node]
	    if {$result != "" } {
		    set nodeId [lindex $result 0]
		    set nodeType [lindex $result 1]
	    } else {
		    return
	    }

    }	
    set cursor [. cget -cursor]
    set types {
            {{XDC/XDD Files} {.xd*} }
            {{XDD Files}     {.xdd} }
	    {{XDC Files}     {.xdc} }
    }
    if {![file isdirectory $lastXD] && [file exists $lastXD] } {
	    set tmpImpDir [tk_getOpenFile -title "Import XDC/XDD" -initialfile $lastXD -filetypes $types -parent .]
    } else {
	    set tmpImpDir [tk_getOpenFile -title "Import XDC/XDD" -filetypes $types -parent .]
    }
    if {$tmpImpDir != ""} {
	    set lastXD $tmpImpDir

	    set result [tk_messageBox -message "Do you want to Import $tmpImpDir ?" -type yesno -icon question -title "Question" -parent .]
	     switch -- $result {
	         yes {
		       DisplayInfo "Importing file $tmpImpDir for Node ID : $nodeId"
		     }			 
	         no  {
		       DisplayInfo "Importing $tmpImpDir is cancelled for Node ID : $nodeId"
		       return
		     }
	    }
	    set catchErrCode [ReImportXML $tmpImpDir $nodeId $nodeType]
	    set ErrCode [ocfmRetCode_code_get $catchErrCode]
	    if { $ErrCode != 0 } {
		    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .
		    } else {
			    tk_messageBox -message "Unknown Error" -title Warning -icon warning -parent .
		    }
		    return
	    } else {
		    DisplayInfo "ReImported $tmpImpDir for Node ID:$nodeId"
	    }

	    pack forget [lindex $f0 0]
	    pack forget [lindex $f1 0]
	    pack forget [lindex $f2 0]
	    [lindex $f2 1] cancelediting
	    [lindex $f2 1] configure -state disabled

	    #xdc/xdd is reimported need to save
	    set status_save 1

	    catch {
		    if { $res == -1} {
			    #there can be one OBD in MN so -1 is hardcoded
			    $treePath insert 0 MN$tmpNode OBD$tmpNode-1 -text "OBD" -open 0 -image [Bitmap::get pdo]
		    }
	    }
	    pack forget [lindex $f0 0]
	    pack forget [lindex $f1 0]
	    pack forget [lindex $f2 0]
	    [lindex $f2 1] cancelediting
	    [lindex $f2 1] configure -state disabled

	    Operations::CleanList $node 0
	    Operations::CleanList $node 1
	    catch {$treePath delete [$treePath nodes $node]}
	    $treePath itemconfigure $node -open 0
	
	    thread::send -async [tsv::set application importProgress] "StartProgress"
	    set result [WrapperInteractions::Import $node $nodeType $nodeId]
	    thread::send -async [tsv::set application importProgress] "StopProgress"
	
    }
} 

#---------------------------------------------------------------------------------------------------
#  Operations::DeleteTreeNode
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Deletes a node in the tree
#---------------------------------------------------------------------------------------------------
proc Operations::DeleteTreeNode {} {
    global treePath
    global nodeIdList
    global savedValueList
    global userPrefList
    global status_save

    set node [$treePath selection get]

    if { [string match "ProjectNode" $node] || [string match "PDO*" $node]|| [string match "?PDO*" $node] } {
	    #should not delete when pjt, mn, pdo, tpdo or rpdo is selected 
	    return
    }
    if {[string match "MN*" $node]} {
	    set nodePos [split $node -]
	    set nodePos [lrange $nodePos 1 end]
	    set nodePos [join $nodePos -]

	    # always OBD node ends with -1
	    set node OBD-$nodePos-1
	    set exist [$treePath exists $node]	
	    if {$exist} { 
		    #has OBD node continue processing
	    } else {
		    #does not have any OBD exit from procedure		
		    return
	    }
    }
    #gets the nodeId and Type of selected node
    set result [Operations::GetNodeIdType $node]
    if {$result != "" } {
	    set nodeId [lindex $result 0]
	    set nodeType [lindex $result 1]
    } else {
	    return
    }

    set nodeList ""
    set nodeList [Operations::GetNodeList]
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
		    set catchErrCode [DeleteNodeObjDict $nodeId $nodeType]
	    } elseif {$nodeType == 1} {
		    #it is a CN so delete the node entirely
		    set catchErrCode [DeleteNode $nodeId $nodeType]
	    } else {
		    return
	    }


	    #node is deleted need to save
	    set status_save 1


	    if {[string match "OBD*" $node]} {
		    #should not delete nodeId from list since it is mn
	    } else {
		    set nodeIdList [Operations::DeleteList $nodeIdList $nodeId 0]		
	    }

	    #to clear the list from child of the node from saved value list
	    Operations::CleanList $node 0
	    Operations::CleanList $node 1

    } else {

	    set res []
	    set idxNode [$treePath selection get]
	    if {[string match "*SubIndexValue*" $node]} {
		    #gets SubIndexId of selected node
		    set sidx [string range [$treePath itemcget $node -text] end-2 end-1 ]
		    if { $sidx == "00" } {
			    tk_messageBox -message "SubIndex 00 cannot be deleted" -parent .
			    return
		    }

		    #gets the IndexId of selected SubIndex
		    set idxNode [$treePath parent $node]
		    set idx [string range [$treePath itemcget $idxNode -text] end-4 end-1 ]
		    set catchErrCode [DeleteSubIndex $nodeId $nodeType $idx $sidx]
	    } elseif {[string match "*IndexValue*" $node]} {
		    set idx [string range [$treePath itemcget $idxNode -text] end-4 end-1 ]
		    set compareIdx [ string toupper $idx]
		    set safeObjectList [list 1006 1020 1300 1C02 1C09 1F26 1F27 1F84 1F89 1F8A 1F8B 1F8D 1F92]
		    if { [lsearch -exact $safeObjectList $compareIdx] != -1 } {
			    set result [tk_messageBox -type yesno -message "$idx is a special Index\nDeleting lead to unexpected cdc generation\nDo you want to delete?" ]
			    switch -- $result {
				    yes {#continue with process}
				    no {return}
			    }
		    }
		    set catchErrCode [DeleteIndex $nodeId $nodeType $idx]
	    } else {
		    return
	    }
	    #clear the savedValueList of the deleted node
	    set savedValueList [Operations::DeleteList $savedValueList $node 0]
	    set userPrefList [Operations::DeleteList $userPrefList $node 1]
	
    }

    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode != 0 } {
	    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
		    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .
	    } else {
		    tk_messageBox -message "Unknown Error" -title Warning -icon warning -parent .
	    }
	    return
    }

    #index or subindex is deleted need to save
    set status_save 1

    set parent [$treePath parent $node]
    set nxtSelList [$treePath nodes $parent]

    # to highlight the next logical node after the deleted node
    if {[llength $nxtSelList] == 1} {
	    #it is the only node so select parent
	    $treePath selection set $parent
	    catch {$treePath delete $node}
	    Validation::ResetPromptFlag
	    Operations::SingleClickNode $parent
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
		    catch {$treePath selection set $nxtSel}
		    catch {$treePath delete $node}
		    #should display logical next node after deleting currently highlighted node
		    Validation::ResetPromptFlag
		    Operations::SingleClickNode $nxtSel
		    return
    }
    catch {$treePath delete $node}
}

#---------------------------------------------------------------------------------------------------
#  Operations::DeleteList
# 
#  Arguments : tempList  - list in which value to be deleted
#              deleteVar - value to be deleted
#              choice    - to indicate sent list
#
#  Results : list with deleted value
#
#  Description : Deletes variable if present in list
#---------------------------------------------------------------------------------------------------
proc Operations::DeleteList {tempList deleteVar choice} {
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
    return $tempList
}

#---------------------------------------------------------------------------------------------------
#  Operations::CleanList
# 
#  Arguments : node   - node to be deleted
#              choice - to indicate sent list
#
#  Results : -
#
#  Description : Deletes node in savedValueList and userPrefList according to choice
#---------------------------------------------------------------------------------------------------
proc Operations::CleanList {node choice} {
    global savedValueList
    global userPrefList

    if { $choice == 0 } {
	    set tempList $savedValueList
    } elseif { $choice == 1 } {
	    set tempList $userPrefList
    } else {
	    #invalid choice
	    return 
    }
    set tempFinalList ""
    set matchNode [split $node -]
    set matchNode [lrange $matchNode 1 end]
    set matchNode [join $matchNode -]
    foreach tempValue $tempList {
	    if { $choice == 0 } {
		    set testValue $tempValue
	    } else {
		    set testValue [lindex $tempValue 0]
	    }
		
	    if {[string match "*SubIndexValue*" $testValue]} {
		    set tempMatchNode *-$matchNode-*-*
	    } elseif {[string match "*IndexValue*" $testValue]} {
		    set tempMatchNode *-$matchNode-*
	    } else {
		    #other than IndexValue and SubIndexValue no node should occur
	    }
    "
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
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::NodeCreate
# 
#  Arguments : NodeID   - node id 
#              NodeType - indicate MN or CN
#              NodeName - node name
#
#  Results : -
#
#  Description : Creates a node with given data
#---------------------------------------------------------------------------------------------------
proc Operations::NodeCreate {NodeID NodeType NodeName} {
    set objNode [new_CNode]
    set objNodeCollection [new_CNodeCollection]
    set objNodeCollection [CNodeCollection_getNodeColObjectPointer]
    set catchErrCode [new_ocfmRetCode]
    set catchErrCode [CreateNode $NodeID $NodeType $NodeName]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode != 0 } {
	    return $catchErrCode 
    }
    return $catchErrCode 
}

#---------------------------------------------------------------------------------------------------
#  Operations::GetNodeList
# 
#  Arguments : -
#
#  Results : list containing nodes of MN and CN from tree widget
#
#  Description : Creates a node with given data
#---------------------------------------------------------------------------------------------------
proc Operations::GetNodeList {} {
    global treePath

    foreach mnNode [$treePath nodes ProjectNode] {
	    set chk 1
	    foreach cnNode [$treePath nodes $mnNode] {
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
    return $nodeList
}

#---------------------------------------------------------------------------------------------------
#  Operations::GetNodeIdType
# 
#  Arguments : node - node of tree widget for which id and type is to be found
#
#  Results : node id and node type
#
#  Description : Returns the node id and node type for the node from tree widget
#---------------------------------------------------------------------------------------------------
proc Operations::GetNodeIdType {node} {
    global treePath
    global nodeIdList

    if {[string match "*SubIndex*" $node]} {
	    set parent [$treePath parent [$treePath parent $node]]
	    if {[string match "?Pdo*" $node]} {
		    # subindex in TPDO orRPDO
		    set parent [$treePath parent [$treePath parent $parent]]
	    } else {
	    }
    } elseif {[string match "*Index*" $node]} {
	    set parent [$treePath parent $node]
	    if {[string match "?Pdo*" $node]} {
		    #it must be index in TPDO or RPDO
		    set parent [$treePath parent [$treePath parent $parent]]
	    } else {
	    }
    } elseif {[string match "TPDO-*" $node] || [string match "RPDO-*" $node]} {
	    #it must be either TPDO or RPDO
	    set parent [$treePath parent $node]
	    set parent [$treePath parent $parent]
    } elseif {[string match "PDO-*" $node]} {
	    set parent [$treePath parent $node]	
    } elseif {[string match "OBD-*" $node] || [string match "CN-*" $node]} {
	    set parent $node
    } else {
	    #it is root or ProjectNode
	    return
    }

    set nodeList []
    set nodeList [Operations::GetNodeList]
    set searchCount [lsearch -exact $nodeList $parent ]
    set nodeId [lindex $nodeIdList $searchCount]
    if {[string match "OBD*" $parent]} {
	    #it is a mn
	    set nodeType 0
    } else {
	    #it is a cn
	    set nodeType 1
    }
    return [list $nodeId $nodeType]
}

#---------------------------------------------------------------------------------------------------
#  Operations::ArrowUp
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Traverse the tree widget for up arrow key
#---------------------------------------------------------------------------------------------------
proc Operations::ArrowUp {} {
    global treePath
    set node [$treePath selection get]
    if { $node == "" || $node == "root" || $node == "ProjectNode" } {
	    $treePath selection set "ProjectNode"
	    $treePath see "ProjectNode"
	    return
    }
    set parent [$treePath parent $node]
    set siblingList [$treePath nodes $parent]
    set cnt [lsearch -exact $siblingList $node]
    if { $cnt == 0} {
	    #there is no node before it so select parent
	    $treePath selection set $parent
	    $treePath see $parent
    } else {
	    set sibling  [lindex $siblingList [expr $cnt-1] ]
	    if {[$treePath itemcget $sibling -open] == 0 || ( [$treePath itemcget $sibling -open] == 1 && [$treePath nodes $sibling] == "" )} {
		    $treePath selection set $sibling
		    $treePath see $sibling
		    return
	    } else {
		    set siblingList [$treePath nodes $sibling]
		    if {[$treePath itemcget [lindex $siblingList end] -open] == 1 && [$treePath nodes [lindex $siblingList end] ] != "" } {
			    Operations::_ArrowUp [lindex $siblingList end]
		    } else {			
			    $treePath selection set [lindex $siblingList end]
			    $treePath see [lindex $siblingList end]
			    return
		    }	
	    }
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::_ArrowUp
# 
#  Arguments : node - parent node of node to be highlighted
#
#  Results : -
#
#  Description : Highlights the node for up arrow key
#---------------------------------------------------------------------------------------------------
proc Operations::_ArrowUp {node} {
    global treePath

    if {[$treePath itemcget $node -open] == 0 || ( [$treePath itemcget $node -open] == 1 && [$treePath nodes $node] == "" )} {
	    $treePath selection set $node
	    $treePath see $node
	    return
    } else {
	    set siblingList [$treePath nodes $node]
	    if {[$treePath itemcget [lindex $siblingList end] -open] == 1 && [$treePath nodes [lindex $siblingList end] ] != "" } {
		    Operations::_ArrowUp [lindex $siblingList end]
	    } else {			
		    $treePath selection set [lindex $siblingList end]
		    $treePath see [lindex $siblingList end]
		    return
	    }	
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::ArrowDown
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Traverse the tree widget for down arrow key
#---------------------------------------------------------------------------------------------------
proc Operations::ArrowDown {} {
    global treePath

    set node [$treePath selection get]
    if { $node == "" || $node == "root" } {
	    return
    }
    if {[$treePath itemcget $node -open] == 0 || ( [$treePath itemcget $node -open] == 1 && [$treePath nodes $node] == "" )} {
	    set parent [$treePath parent $node]
	    set siblingList [$treePath nodes $parent]
	    set cnt [lsearch -exact $siblingList $node]
	    if { $cnt == [expr [llength $siblingList]-1 ]} {
		    Operations::_ArrowDown $parent $node
	    } else {
		    $treePath selection set [lindex $siblingList [expr $cnt+1] ]
		    $treePath see [lindex $siblingList [expr $cnt+1] ]
		    return
	    }
    } else {
	    set siblingList [$treePath nodes $node]
	    $treePath selection set [lindex $siblingList 0]
	    $treePath see [lindex $siblingList 0]
	    return
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::_ArrowDown
# 
#  Arguments : node     - parent node of node to be highlighted
#              origNode - selected node
#  Results : -
#
#  Description : Highlights the node for down arrow key
#---------------------------------------------------------------------------------------------------
proc Operations::_ArrowDown {node origNode} {
    global treePath
    if { $node == "root" } {
	    $treePath selection set $origNode
	    $treePath see $origNode
	    return
    }
    set parent [$treePath parent $node]

    set siblingList [$treePath nodes $parent]
    set cnt [lsearch -exact $siblingList $node]
    if { $cnt == [expr [llength $siblingList]-1 ]} {
	    Operations::_ArrowDown $parent $origNode
    } else {
	    $treePath selection set [lindex $siblingList [expr $cnt+1] ]
	    $treePath see [lindex $siblingList [expr $cnt+1] ]
	    return
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::ArrowLeft
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Collapse the highlighted node 
#---------------------------------------------------------------------------------------------------
proc Operations::ArrowLeft {} {
    global treePath
    set node [$treePath selection get]
    if {[$treePath nodes $node] != "" } {
	    $treePath itemconfigure $node -open 0		
    } else {
	    # it has no child no need to collapse
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::ArrowRight
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Expands the highlighted node 
#---------------------------------------------------------------------------------------------------
proc Operations::ArrowRight {} {
    global treePath
    set node [$treePath selection get]
    if {[$treePath nodes $node] != "" } {	
	    $treePath itemconfigure $node -open 1		
    } else {
	    # it has no child no need to expand
    }
}

#---------------------------------------------------------------------------------------------------
#  Operations::AutoGenerateMNOBD
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Auto generates object dictionary for MN and populates the tree.
#---------------------------------------------------------------------------------------------------
proc Operations::AutoGenerateMNOBD {} {
	global treePath
	global nodeIdList
	global status_save
	global f0
	global f1
	global f2
	set node [$treePath selection get]
	if {[string match "MN*" $node]} {
		set child [$treePath nodes $node]
		set tmpNode [string range $node 2 end]
		set node OBD$tmpNode-1
		set res [lsearch $child "OBD$tmpNode-1*"]
		set nodeId 240
		set nodeType 0
		set result [Operations::GetNodeIdType $node]
		if {$result != "" } {
			set nodeId [lindex $result 0]
			set nodeType [lindex $result 1]
		} else {
			return
		}

		set result [tk_messageBox -message "Do you want to Auto Generate object dictionary for MN ?" -type yesno -icon question -title "Question" -parent .]
   		 switch -- $result {
   		     yes {
			   DisplayInfo "Auto Generating object dictionary for MN"
			 }			 
   		     no  {
			   DisplayInfo "Auto Generate is cancelled for MN"
			   return
			 }
		 }
		set catchErrCode [GenerateMNOBD]		
		set ErrCode [ocfmRetCode_code_get $catchErrCode]
		if { $ErrCode != 0 } {
			if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
				tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .
			} else {
				tk_messageBox -message "Unknown Error" -title Warning -icon warning -parent .
			}
			return
		} 

		#OBD for MN is auto generated need to save
		set status_save 1

		catch {
			if { $res == -1} {
				#there can be one OBD in MN so -1 is hardcoded
				$treePath insert 0 MN$tmpNode OBD$tmpNode-1 -text "OBD" -open 0 -image [Bitmap::get pdo]
			}
		}
		catch {$treePath delete [$treePath nodes OBD$tmpNode-1]}
		$treePath itemconfigure $node -open 0
		
		thread::send -async [tsv::set application importProgress] "StartProgress"
		set result [WrapperInteractions::Import $node $nodeType $nodeId]
		thread::send -async [tsv::set application importProgress] "StopProgress"
		if { $result == "fail" } {
			return
		}
		#to clear the list from child of the node from savedvaluelist and userpreflist
		Operations::CleanList $node 0
		Operations::CleanList $node 1
		
	}
}

#---------------------------------------------------------------------------------------------------
#  Operations::GenerateAutoName
# 
#  Arguments : dir  - directory in which name of file is auto generated
#              name - default file name for which unique file name is generated
#              ext  - extension of the file
#
#  Results : auto generated file name
#
#  Description : Generates unique file name in the path
#---------------------------------------------------------------------------------------------------
proc Operations::GenerateAutoName {dir name ext} {
    #should check for extension but should send back unique name without extension
    for {set loopCount 1} {1} {incr loopCount} {
	    set autoName $name$loopCount$ext
	    if {![file exists [file join $dir $autoName]]} {
		    break;
	    }
    }
    return $name$loopCount
}
