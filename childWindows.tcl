####################################################################################################
#
#
# NAME:     childWindows.tcl
#
# PURPOSE:  Contains the child window displayed in application
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
#  namespace : ChildWindows
#---------------------------------------------------------------------------------------------------
namespace eval ChildWindows {
	
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::StartUp
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Creates the GUI during startup
#---------------------------------------------------------------------------------------------------
proc ChildWindows::StartUp {} {
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

    label $frame1.la_empty1 -text ""
    label $frame1.la_empty2 -text ""
    label $frame1.la_empty3 -text ""
    label $frame1.la_desc -text "Description"

    text $frame1.t_desc -height 5 -width 40 -state disabled -background white

    radiobutton $frame1.ra_newProj  -text "Create New Project"    -variable startVar -value 1 -font custom2 -command "ChildWindows::StartUpText $frame1.t_desc 1" 
    radiobutton $frame1.ra_openProj -text "Open Existing Project" -variable startVar -value 2 -font custom2 -command "ChildWindows::StartUpText $frame1.t_desc 2" 
    $frame1.ra_newProj select
    ChildWindows::StartUpText $frame1.t_desc 1
	 
    button $frame2.bt_ok -width 8 -text "  Ok  " -command { 
        if {$startVar == 1} {
            destroy .startUp
            ChildWindows::NewProjectWindow
        } elseif {$startVar == 2} {
            destroy .startUp
            Operations::OpenProjectWindow
        }
        catch {
            unset startVar
            unset frame2
        }
    }
    button $frame2.bt_cancel -width 8 -text "Cancel" -command {
        catch {
            unset startVar
            unset frame2
        }
        catch { destroy .startUp }
    }

    grid config $frame1 -row 0 -column 0 -padx 35 -pady 10

    grid config $frame1.ra_newProj -row 1 -column 0 -sticky w  -padx 5 -pady 5
    grid config $frame1.ra_openProj -row 2 -column 0 -sticky w -padx 5 -pady 5
    grid config $frame1.la_desc -row 3 -column 0 -sticky w -padx 5 -pady 5
    grid config $frame1.t_desc -row 4 -column 0 -sticky w -padx 5 -pady 5 
    grid config $frame2 -row 5 -column 0  -padx 5 -pady 5
    grid config $frame2.bt_ok -row 0 -column 0
    grid config $frame2.bt_cancel -row 0 -column 1

    wm protocol .startUp WM_DELETE_WINDOW "$frame2.bt_cancel invoke"
    bind $winStartUp <KeyPress-Return> "$frame2.bt_ok invoke"
    bind $winStartUp <KeyPress-Escape> "$frame2.bt_cancel invoke"

    focus $winStartUp
    $winStartUp configure -takefocus 1
    Operations::centerW $winStartUp
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::StartUpText
# 
#  Arguments : t_desc - path of the text widget
#              choice - based on choice message is displayed
#
#  Results : -
#
#  Description : Displays description message for StartUp window
#---------------------------------------------------------------------------------------------------
proc ChildWindows::StartUpText {t_desc choice} {
    $t_desc configure -state normal
    $t_desc delete 1.0 end
    if { $choice == 1 } {
        $t_desc insert end "Create a new Project"
    } else {
        $t_desc insert end "Open Existing Project"
    }
    $t_desc configure -state disabled
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::ProjectSettingWindow
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Displays description message for StartUp window
#---------------------------------------------------------------------------------------------------
proc ChildWindows::ProjectSettingWindow {} {
    global projectName
    global projectDir
    global ra_proj
    global ra_auto
    global viewChgFlg
    global nodeSelect

    if {$projectDir == "" || $projectName == "" } {
	return
    }
	
    set ra_autop [new_EAutoGeneratep]
    set ra_projp [new_EAutoSavep]
    set videoMode [new_EViewModep]
    set viewChgFlg [new_boolp]

    set catchErrCode [GetProjectSettings $ra_autop $ra_projp $videoMode $viewChgFlg]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode != 0 } {
        if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
            tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]\nAuto generate is set to \"Yes\" and project Setting set to \"Prompt\" " -title Error -icon error
        } else {
            tk_messageBox -message "Unknown Error\nAuto generate is set to \"Yes\" and project Setting set to \"Prompt\" " -title Error -icon error
        }
        set ra_auto 1
        set ra_proj 1
        set videoMode 0
        set viewChgFlg 0
    } else {
        set ra_auto [EAutoGeneratep_value $ra_autop]
        set ra_proj [EAutoSavep_value $ra_projp]
        set videoMode [EViewModep_value $videoMode]
        set viewChgFlg [boolp_value $viewChgFlg]
        # puts "ChildWindows::ProjectSettingWindow videoMode->$videoMode"
    }
	
    set winProjSett .projSett
    catch "destroy $winProjSett"
    toplevel     $winProjSett
    wm title     $winProjSett "Project Settings"
    wm resizable $winProjSett 0 0
    wm transient $winProjSett .
    wm deiconify $winProjSett
    grab $winProjSett

    set framea [frame $winProjSett.framea]
    set frameb [frame $winProjSett.frameb]
    #set framec [frame $winProjSett.framec]
    set frame1 [frame $framea.frame1]
    set frame2 [frame $frameb.frame2]
    set frame3 [frame $winProjSett.frame3]

    #label $winProjSett.la_save -text "Project Settings"
    #label $winProjSett.la_auto -text "Auto Generate"
    label $framea.la_save -text "Project Settings"
    label $frameb.la_auto -text "Auto Generate"
    label $winProjSett.la_empty1 -text ""
    label $winProjSett.la_empty2 -text ""
    label $winProjSett.la_empty3 -text ""
    
     
    text $winProjSett.t_desc -height 4 -width 40 -state disabled -background white	

    radiobutton $frame1.ra_autoSave -variable ra_proj -value 0 -text "Auto Save" -command "ChildWindows::ProjectSettText $winProjSett.t_desc"
    radiobutton $frame1.ra_prompt -variable ra_proj -value 1 -text "Prompt" -command "ChildWindows::ProjectSettText $winProjSett.t_desc"
    radiobutton $frame1.ra_discard -variable ra_proj -value 2 -text "Discard" -command "ChildWindows::ProjectSettText $winProjSett.t_desc"

    radiobutton $frame2.ra_genYes -variable ra_auto -value 1 -text Yes -command "ChildWindows::ProjectSettText $winProjSett.t_desc"
    radiobutton $frame2.ra_genNo -variable ra_auto -value 0 -text No -command "ChildWindows::ProjectSettText $winProjSett.t_desc"

    ChildWindows::ProjectSettText $winProjSett.t_desc

    button $frame3.bt_ok -width 8 -text "Ok" -command {
        if { $Operations::viewType == "EXPERT" } {
            set viewType 1
        } else {
            set viewType 0
        }
        set catchErrCode [SetProjectSettings $ra_auto $ra_proj $viewType $viewChgFlg]
        set ErrCode [ocfmRetCode_code_get $catchErrCode]
        if { $ErrCode != 0 } {
            if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
                tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .projSett
            } else {
	            tk_messageBox -message "Unknown Error" -title Error -icon error -parent .projSett
            }
	}
        destroy .projSett
	Operations::SingleClickNode $nodeSelect
    }
	
    button $frame3.bt_cancel -width 8 -text "Cancel" -command {
        #if cancel is called project settings for existing project is called
        global ra_proj
        global ra_auto
        global viewChgFlg
        set ra_autop [new_EAutoGeneratep]
        set ra_projp [new_EAutoSavep]
        set videoMode [new_EViewModep]
        set viewChgFlg [new_boolp]
        set catchErrCode [GetProjectSettings $ra_autop $ra_projp $videoMode $viewChgFlg]
        set ErrCode [ocfmRetCode_code_get $catchErrCode]
        if { $ErrCode != 0 } {
            set ra_auto 1
            set ra_proj 1
            set videoMode 0
            set viewChgFlg 0
        } else {
            set ra_auto [EAutoGeneratep_value $ra_autop]
            set ra_proj [EAutoSavep_value $ra_projp]
            set videoMode [EViewModep_value $videoMode]
            set viewChgFlg [boolp_value $viewChgFlg]
        }
        #puts "ChildWindows::ProjectSettingWindow videoMode->$videoMode"
    	destroy .projSett
    }
	
    #grid config $winProjSett.la_empty1 -row 0 -column 0

    #grid config $winProjSett.la_save -row 1 -column 0 -sticky w
    
    grid config $framea -row 0 -column 0 -sticky w -padx 10 -pady 10
    grid config $framea.la_save -row 0 -column 0 -sticky w
    #grid config $frame1 -row 2 -column 0 -padx 10 -sticky w
    #grid config $frame1.ra_autoSave -row 0 -column 0
    #grid config $frame1.ra_prompt -row 0 -column 1 -padx 5
    #grid config $frame1.ra_discard -row 0 -column 2
    grid config $frame1 -row 1 -column 0 -padx 10 -sticky w
    grid config $frame1.ra_autoSave -row 0 -column 0
    grid config $frame1.ra_prompt -row 0 -column 1 -padx 5
    grid config $frame1.ra_discard -row 0 -column 2

    #grid config $winProjSett.la_empty2 -row 3 -column 0

    #grid config $winProjSett.la_auto -row 4 -column 0 -sticky w
    grid config $frameb -row 1 -column 0 -sticky w -padx 10 -pady 10
    grid config $frameb.la_auto -row 0 -column 0 -sticky w
    #grid config $frame2 -row 5 -column 0 -padx 10 -sticky w
    #grid config $frame2.ra_genYes -row 0 -column 0 -padx 2
    #grid config $frame2.ra_genNo -row 0 -column 1 -padx 2
    grid config $frame2 -row 1 -column 0 -padx 10 -sticky w
    grid config $frame2.ra_genYes -row 0 -column 0 -padx 2
    grid config $frame2.ra_genNo -row 0 -column 1 -padx 2

    #grid config $winProjSett.la_empty3 -row 6 -column 0 
    #grid config $winProjSett.t_desc -row 7 -column 0 -padx 10 -pady 10 -sticky news
    grid config $winProjSett.t_desc -row 2 -column 0 -padx 10 -pady 10 -sticky news    
    #grid config $frame3 -row 8 -column 0 -pady 10 
    #grid config $frame3.bt_ok -row 0 -column 0
    #grid config $frame3.bt_cancel -row 0 -column 1
    grid config $frame3 -row 8 -column 0 -pady 10 
    grid config $frame3.bt_ok -row 0 -column 0
    grid config $frame3.bt_cancel -row 0 -column 1
    
    wm protocol .projSett WM_DELETE_WINDOW "$frame3.bt_cancel invoke"
    bind $winProjSett <KeyPress-Return> "$frame3.bt_ok invoke"
    bind $winProjSett <KeyPress-Escape> "$frame3.bt_cancel invoke"
    Operations::centerW $winProjSett

}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::ProjectSettText
# 
#  Arguments : t_desc - path of the text widget
#
#  Results : -
#
#  Description : Displays description message for project settings
#---------------------------------------------------------------------------------------------------
proc ChildWindows::ProjectSettText {t_desc} {
    global ra_proj
    global ra_auto

    switch -- $ra_proj {
	0 {
	    set msg1 "Edited data are saved automatically"
	}
	1 {
	    set msg1 "Prompts the user for saving the edited data"
	}
	2 {
	    set msg1 "Edited data is discarded unless user saves it"
	}
    }

    if { $ra_auto == 1 } {
	    set msg2 "Autogenerates MN object dictionary during build"
    } else {
	    set msg2 "User imported xdd or xdc file will be build"
    }

    $t_desc configure -state normal
    $t_desc delete 1.0 end
    $t_desc insert 1.0 "$msg1\n\n$msg2"
    $t_desc configure -state disabled
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::AddCNWindow
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Creates the child window for creating CN 
#---------------------------------------------------------------------------------------------------
proc ChildWindows::AddCNWindow {} {
	global cnName
	global nodeId
	global tmpImpCnDir
	global lastXD
	global frame1
	global frame3
	
	set winAddCN .addCN
	catch "destroy $winAddCN"
	toplevel     $winAddCN
	wm title     $winAddCN "Add New Node"
	wm resizable $winAddCN 0 0
	wm transient $winAddCN .
	wm deiconify $winAddCN
	grab $winAddCN

	label $winAddCN.la_empty -text ""	

	set frame1 [frame $winAddCN.frame1]
	set frame2 [frame $frame1.frame2]
	set frame3 [frame $winAddCN.frame3]

	label $frame2.la_name -text "Name :   " -justify left
	label $frame2.la_node -text "Node ID :" -justify left
	label $frame1.la_cn -text "CN Configuration"
	
	radiobutton $frame1.ra_def -text "Default" -variable confCn -value on  -command {
		$frame1.en_imppath config -state disabled 
		$frame1.bt_imppath config -state disabled 
	}		
	radiobutton $frame1.ra_imp -text "Import XDC/XDD" -variable confCn -value off -command {
		$frame1.en_imppath config -state normal 
		$frame1.bt_imppath config -state normal 
	}
	$frame1.ra_def select
	
	set autoGen [ChildWindows::GenerateCNname]

	entry $frame2.en_name -textvariable cnName -background white -relief ridge -validate key -vcmd "Validation::IsValidName %P"
	set cnName [lindex $autoGen 0]	
	$frame2.en_name selection range 0 end
	$frame2.en_name icursor end
	entry $frame2.en_node -textvariable nodeId -background white -relief ridge -validate key -vcmd "Validation::IsInt %P %V"
	set nodeId [lindex $autoGen 1]
	entry $frame1.en_imppath -textvariable tmpImpCnDir -background white -relief ridge -width 25
	if {![file isdirectory $lastXD] && [file exists $lastXD] } {	
		set tmpImpCnDir $lastXD	
	} else {
		set tmpImpCnDir ""
	}
	$frame1.en_imppath config -state disabled

	button $frame1.bt_imppath -width 8 -text Browse -command {
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
	}
	$frame1.bt_imppath config -state disabled 
	button $frame3.bt_ok -width 8 -text "  Ok  " -command {
		set cnName [string trim $cnName]
		if {$cnName == "" } {
			tk_messageBox -message "Enter CN name (free form text without space)" -parent .addCN -icon error
			focus .addCN
			return
		}
		if {$nodeId == "" } {
			tk_messageBox -message "Enter Node id (1 to 239)" -parent .addCN -icon error
			focus .addCN
			return
		}
		if {$nodeId < 1 || $nodeId > 239 } {
			tk_messageBox -message "Node id should be between 1 to 239" -parent .addCN -icon error
			focus .addCN
			return
		}
		if {$confCn=="off"} {
			if {![file isfile $tmpImpCnDir]} {
				tk_messageBox -message "Entered path to Import XDC/XDD file does not exist" -icon error -parent .addCN
				focus .addCN
				return
			}
			set ext [file extension $tmpImpCnDir]
			if { $ext == ".xdc" || $ext == ".xdd" } {
				#file is of correct type
			} else {
				tk_messageBox -message "Import files only of type XDC/XDD" -icon error -parent .addCN
				focus .addCN
				return
			}
			set lastXD $tmpImpCnDir
		}

		if {$confCn == "off"} {
		        catch { destroy .addCN }
			#import the user selected xdc/xdd file for cn
			set chk [Operations::AddCN $cnName $tmpImpCnDir $nodeId]
		} else {
			#import the default cn xdd file
			global rootDir
			set tmpImpCnDir [file join $rootDir openPOWERLINK_CN.xdd]
			if {[file exists $tmpImpCnDir]} {
			        catch { destroy .addCN }
				set chk [Operations::AddCN $cnName $tmpImpCnDir $nodeId]
			} else {
				#there is no default xdd file in required path
				tk_messageBox -message "Default xdd file for CN not found" -icon error -parent .addCN
				focus .addCN
				return
			}
		}
		catch { $frame3.bt_cancel invoke }
	}

	button $frame3.bt_cancel -width 8 -text Cancel -command { 
		catch {
			unset cnName
			unset nodeId
			unset tmpImpCnDir
			unset frame1
			unset frame3
		}
		catch { destroy .addCN }
	}
	
	grid config $frame1 -row 0 -column 0 -padx 15 -pady 15
	
	grid config $frame2 -row 0 -column 0 -columnspan 2 -sticky w 
	grid config $frame2.la_name -row 0 -column 0 -sticky w 
	grid config $frame2.en_name -row 0 -column 1 -sticky w -pady 5
	grid config $frame2.la_node -row 1 -column 0 -sticky w 
	grid config $frame2.en_node -row 1 -column 1 -sticky w -pady 5
	
	grid config $frame1.la_cn -row 1 -column 0 -sticky w -pady 5
	grid config $frame1.ra_def -row 2 -column 0 -sticky w -pady 5
	grid config $frame1.ra_imp -row 3 -column 0 -sticky w 
	grid config $frame1.en_imppath -row 3 -column 1 -padx 5 -pady 5 -sticky w 
	grid config $frame1.bt_imppath -row 3 -column 2 -sticky w 
	
	grid config $frame3 -row 4 -column 0 -columnspan 3 -pady 5
	grid config $frame3.bt_ok -row 0 -column 0 -padx 3 
	grid config $frame3.bt_cancel -row 0 -column 1 -padx 3
	
	wm protocol .addCN WM_DELETE_WINDOW "$frame3.bt_cancel invoke"
	bind $winAddCN <KeyPress-Return> "$frame3.bt_ok invoke"
	bind $winAddCN <KeyPress-Escape> "$frame3.bt_cancel invoke"

	focus $frame2.en_name
	Operations::centerW $winAddCN
}


#---------------------------------------------------------------------------------------------------
#  ChildWindows::GenerateCNname
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Generates unique  name and node id for CN
#---------------------------------------------------------------------------------------------------
proc ChildWindows::GenerateCNname {} {
    global nodeIdList
    global treePath

    for {set inc 1} {$inc < 240} {incr inc} {
	    if {[lsearch -exact $nodeIdList $inc] == -1 } {
		    break;
	    }
    }
    if {$inc == 240} { 
	    #239 cn are created 
    } else {
	    return [list CN_$inc $inc]
    }
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::SaveProjectWindow
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Creates the child window for save project
#---------------------------------------------------------------------------------------------------
proc ChildWindows::SaveProjectWindow {} {
    global projectDir
    global projectName
    global treePath
    global status_save	

    if {$projectDir == "" || $projectName == "" } {
	    Console::DisplayInfo "No project present to save" info
	    return
    } else {	
	    #check whether project has changed from last saved
	    if {$status_save} {
		    set result [tk_messageBox -message "Save Project $projectName?" -type yesnocancel -icon question -title "Question" -parent .]
		    switch -- $result {
			    yes {			 
				    Operations::Saveproject
				    Console::DisplayInfo "Project $projectName at location $projectDir is saved" info
				    return yes
			    }
			    no {
				    Console::DisplayInfo "Project $projectName not saved" info
				    if { ![file exists [file join $projectDir $projectName].oct ] } {
				        catch { file delete -force -- $projectDir }
				    }
				    return no
			    }
			    cancel {
				    return cancel
			    }
		    }
	    }		
    }
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::SaveProjectAsWindow
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Creates the child window for save as project
#---------------------------------------------------------------------------------------------------
proc ChildWindows::SaveProjectAsWindow {} {

    global projectName
    global projectDir

	set tempPreviousProjectName $projectName
	
    if {$projectDir == "" || $projectName == "" } {
	    Console::DisplayInfo "No Project present to save" info
	    return
    } else {
	    set saveProjectAs [tk_getSaveFile -parent . -title "Save Project As" -initialdir $projectDir -initialfile $projectName] 
	    if { $saveProjectAs == "" } {
		    return
	    }
	    set tempProjectDir [file dirname $saveProjectAs]
	    set tempProjectName [file tail $saveProjectAs]
		set tempProjectNameNoExtn [string range $tempProjectName 0 end-[string length [file extension $tempProjectName]]]
	    catch {file mkdir $saveProjectAs}
	    catch {file mkdir [file join $saveProjectAs cdc_xap]}
	    catch {file mkdir [file join $saveProjectAs octx]}
	    catch {file mkdir [file join $saveProjectAs scripts]}
	    
	    ChildWindows::CopyScript $saveProjectAs
	    
	    thread::send [tsv::set application importProgress] "StartProgress"
	    set catchErrCode [SaveProject $tempProjectDir $tempProjectNameNoExtn]

	    set ErrCode [ocfmRetCode_code_get $catchErrCode]
	    if { $ErrCode != 0 } {
			thread::send [tsv::set application importProgress] "StopProgress"
		    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .
		    } else {
			    tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
		    }
		    Console::DisplayErrMsg "Error in saving project $saveProjectAs"
		    return
	    } else {
			#since the .oct file will be saved with same name as folder variable 'tempProjectNameNoExtn' is used twice
			set openResult [Operations::openProject [file join $tempProjectDir $tempProjectNameNoExtn $tempProjectNameNoExtn].oct]
			if {$openResult == 1} {
				Console::ClearMsgs
				Console::DisplayInfo "project $tempPreviousProjectName is saved as $saveProjectAs and opened"
			}
			thread::send  [tsv::set application importProgress] "StopProgress"
		}
	    
    }
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::NewProjectWindow
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Creates the child window for new project creation
#---------------------------------------------------------------------------------------------------
proc ChildWindows::NewProjectWindow {} {
    global tmpPjtName
    global tmpPjtDir
    global tmpImpDir
    global winNewProj
    global ra_proj
    global ra_auto
    global newProjectFrame2
    global frame1_1
    global frame1_4
    global frame2_1
    global frame2_2
    global frame2_3

    global treePath
    global nodeIdList
    global projectName
    global projectDir
    global defaultProjectDir
    global status_save
    global lastXD
    global tcl_platform

    set winNewProj .newprj
    catch "destroy $winNewProj"
    toplevel $winNewProj
    wm title     $winNewProj	"Project Wizard"
    wm resizable $winNewProj 0 0
    wm transient $winNewProj .
    wm deiconify $winNewProj
    wm minsize   $winNewProj 50 200
    grab $winNewProj


    set newProjectFrame2 [frame $winNewProj.frame2 -width 650 -height 470 ]
    grid configure $newProjectFrame2 -row 0 -column 0 -sticky news -sticky news -padx 15 -pady 15
	

    set frame2_1 [frame $newProjectFrame2.frame2_1]
    set frame2_2 [frame $newProjectFrame2.frame2_2]
    set frame2_3 [frame $frame2_1.frame2_3]

    label $frame2_1.la_mn -text "MN Configuration"
    label $frame2_1.la_generate -text "Auto Generate"
    label $frame2_1.la_desc -text "Description"

    entry $frame2_1.en_imppath -textvariable tmpImpDir -background white -relief ridge -width 28 -state disabled	
    if {![file isdirectory $lastXD] && [file exists $lastXD] } {	
	    set tmpImpDir $lastXD	
    } else {
	    set tmpImpDir ""
    }

    if {"$tcl_platform(platform)" == "windows"} {
		    set text_width 45
		    set text_padx 37
    } else {
		    set text_width 55
		    set text_padx 27
    }

    text $frame2_1.t_desc -height 5 -width 40 -state disabled -background white	

    radiobutton $frame2_1.ra_def -text "Default" -variable conf -value on -command {
	    ChildWindows::NewProjectMNText $frame2_1.t_desc 
	    $frame2_1.en_imppath config -state disabled 
	    $frame2_1.bt_imppath config -state disabled 
    }
    radiobutton $frame2_1.ra_imp -text "Import XDC/XDD" -variable conf -value off -command {
	    ChildWindows::NewProjectMNText $frame2_1.t_desc 
	    $frame2_1.en_imppath config -state normal 
	    $frame2_1.bt_imppath config -state normal 
    } 
    $frame2_1.ra_def select	
    
    set ra_auto 1
    radiobutton $frame2_1.ra_yes -text "Yes" -variable ra_auto -value 1 -command "ChildWindows::NewProjectMNText  $frame2_1.t_desc"
    radiobutton $frame2_1.ra_no -text "No" -variable ra_auto -value 0 -command "ChildWindows::NewProjectMNText  $frame2_1.t_desc"
    $frame2_1.ra_yes select
    ChildWindows::NewProjectMNText $frame2_1.t_desc 

    button $frame2_1.bt_imppath -state disabled -width 8 -text Browse -command {
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
	    if {$tmpImpDir == ""} {
		    focus .newprj
		    return
	    }
       }

    button $frame2_2.bt_back -width 8 -text " Back " -command {
	    grid remove $winNewProj.frame2
	    grid $winNewProj.frame1
	    bind $winNewProj <KeyPress-Return> "$frame1_4.bt_next invoke"
    }

    button $frame2_2.bt_next -width 8 -text "  Ok  " -command {
	    if {$conf=="off" } {
		    if {![file isfile $tmpImpDir]} {
			    tk_messageBox -message "Entered path to Import XDC/XDD file does not exist" -icon warning -parent .newprj
			    focus .newprj
			    return
		    }
		    set ext [file extension $tmpImpDir]
		    if { $ext == ".xdc" || $ext == ".xdd" } {
			    #correct type continue
		    } else {
			    tk_messageBox -message "Import files only of type XDC/XDD" -icon warning -parent .newprj
			    focus .newprj
			    return
		    }
		    set lastXD $tmpImpDir
	    } else {
		    global rootDir
		    set tmpImpDir [file join $rootDir openPOWERLINK_MN.xdd]
		    if {![file isfile $tmpImpDir]} {
			    tk_messageBox -message "Default xdd file for MN is not found" -icon warning -parent .newprj
			    focus .newprj
			    return
		    }
	    }

	    catch { destroy .newprj }
        #all new projects have "SIMPLE" type
        set Operations::viewType "SIMPLE"
	    ChildWindows::NewProjectCreate $tmpPjtDir $tmpPjtName $tmpImpDir $conf $ra_proj $ra_auto
	    catch {
		    unset tmpPjtName
		    unset tmpPjtDir
		    unset tmpImpDir
		    unset newProjectFrame2
		    unset frame1_1
		    unset frame1_4
		    unset frame2_1
		    unset frame2_2
		    unset frame2_3
		    unset winNewProj
	    }
    }

    button $frame2_2.bt_cancel -width 8 -text "Cancel" -command {
	    catch { $frame1_4.bt_cancel invoke }
    }

    grid config $frame2_1 -row 0 -column 0 -sticky w 
    grid config $frame2_1.la_mn -row 0 -column 0 -sticky w
    grid config $frame2_1.ra_def -row 1 -column 0 -sticky w 
    grid config $frame2_1.ra_imp -row 2 -column 0 -sticky w
    grid config $frame2_1.en_imppath -row 2 -column 1 -sticky w -padx 5 -pady 10
    grid config $frame2_1.bt_imppath -row 2 -column 2 -sticky w 
    grid config $frame2_1.la_generate -row 3 -column 0 -columnspan 2 -sticky w
    grid config $frame2_1.ra_yes -row 4 -column 0 -sticky w -pady 2 -padx 5
    grid config $frame2_1.ra_no -row 5 -column 0 -sticky w -pady 3 -padx 5
    grid config $frame2_1.la_desc -row 6 -column 0 -sticky w
    grid config $frame2_1.t_desc -row 7 -column 0 -columnspan 3 -pady 10 -sticky news
    grid config $frame2_2 -row 8 -column 0
    grid config $frame2_2.bt_back -row 0 -column 0
    grid config $frame2_2.bt_next -row 0 -column 1
    grid config $frame2_2.bt_cancel -row 0 -column 2	

    grid remove $winNewProj.frame2

    set newProjectFrame1 [frame $winNewProj.frame1 -width 650 -height 470 ]
    grid configure $newProjectFrame1 -row 0 -column 0 -sticky news -padx 15 -pady 15


    set frame1_1 [frame $newProjectFrame1.frame1_1]
    set frame1_4 [frame $newProjectFrame1.frame1_4]


    label $winNewProj.la_empty -text "               "	
    label $winNewProj.la_empty1 -text "               "
    label $frame1_1.la_pjname -text "Project Name" -justify left
    label $frame1_1.la_pjpath -text "Choose Path" -justify left
    label $frame1_1.la_saveoption -text "Choose Save Option" -justify left
    label $frame1_1.la_desc -text "Description"
    label $frame1_1.la_empty1 -text ""
    label $frame1_1.la_empty2 -text ""
    label $frame1_1.la_empty3 -text ""
    label $frame1_1.la_empty4 -text ""

    entry $frame1_1.en_pjname -textvariable tmpPjtName -background white -relief ridge -validate key -vcmd "Validation::IsValidName %P" -width 35	
    set tmpPjtName  [Operations::GenerateAutoName $defaultProjectDir Project ""]

    $frame1_1.en_pjname selection range 0 end
    $frame1_1.en_pjname icursor end

    entry $frame1_1.en_pjpath -textvariable tmpPjtDir -background white -relief ridge -width 35	
    set tmpPjtDir $defaultProjectDir

    text $frame1_1.t_desc -height 5 -width 40 -state disabled -background white	

    radiobutton $frame1_1.ra_save -text "Auto Save" -variable ra_proj -value 0 -command "ChildWindows::NewProjectText $frame1_1.t_desc 0"
    radiobutton $frame1_1.ra_prompt -text "Prompt" -variable ra_proj -value 1 -command "ChildWindows::NewProjectText $frame1_1.t_desc 1"
    radiobutton $frame1_1.ra_discard -text "Discard" -variable ra_proj -value 2 -command "ChildWindows::NewProjectText $frame1_1.t_desc 2"
    $frame1_1.ra_prompt select
    ChildWindows::NewProjectText $frame1_1.t_desc 1	

    button $frame1_1.bt_pjpath -width 8 -text Browse -command {
	    set tmpPjtDir [tk_chooseDirectory -title "Project Location" -initialdir $defaultProjectDir -parent .newprj]
	    if {$tmpPjtDir == ""} {
		    focus .newprj
		    return
	    }
    }

    button $frame1_4.bt_back -state disabled -width 8 -text "Back"
    button $frame1_4.bt_next -width 8 -text " Next " -command {   
	    set tmpPjtName [string trim $tmpPjtName]
	    if {$tmpPjtName == "" } {
		    tk_messageBox -message "Enter Project Name" -icon warning -parent .newprj
		    focus .newprj
		    return
	    }
	    if {![file isdirectory $tmpPjtDir]} {
		    tk_messageBox -message "Entered path for Project is not a directory" -icon warning -parent .newprj
		    focus .newprj
		    return
	    }
	    if {![file writable $tmpPjtDir]} {
		    tk_messageBox -message "Entered path for Project is write protected\nChoose another path" -icon info -parent .newprj
		    focus .newprj
		    return
	    }
	    if {[file exists [file join $tmpPjtDir $tmpPjtName]]} {
		    set result [tk_messageBox -message "Folder $tmpPjtName already exists.\nDo you want to overwrite it?" -type yesno -icon question -parent .newprj]
		     switch -- $result {
		     	yes {
		     		#continue with process
		     	}			 
	         		no  {
				    focus $frame1_1.en_pjname
		       		return
		     	}
		     }
	    }
	    grid remove $winNewProj.frame1
	    grid $winNewProj.frame2
	    bind $winNewProj <KeyPress-Return> "$frame2_2.bt_next invoke"
    }

    button $frame1_4.bt_cancel -width 8 -text Cancel -command {
	    global projectName
	    global projectDir
	    global ra_proj
	    global ra_auto
        global viewChgFlg
	    catch {
		if { $projectDir != "" && $projectName != "" } {
		    set ra_autop [new_EAutoGeneratep]
		    set ra_projp [new_EAutoSavep]
            set videoMode [new_EViewModep]
            set viewChgFlg [new_boolp]
		    set catchErrCode [GetProjectSettings $ra_autop $ra_projp $videoMode $viewChgFlg]
		    set ErrCode [ocfmRetCode_code_get $catchErrCode]
		    if { $ErrCode == 0 } {
		        set ra_auto [EAutoGeneratep_value $ra_autop]
		        set ra_proj [EAutoSavep_value $ra_projp]
                Operations::SetVideoType [EViewModep_value $videoMode]
                set viewChgFlg [boolp_value $viewChgFlg]
		    } else {
		        set ra_auto 1
		        set ra_proj 1
                Operations::SetVideoType 0
                set viewChgFlg 0
            }
		}
            #puts "ChildWindows::NewProjectWindow videoMode->$videoMode"
	    }

	    catch {
		    unset tmpPjtName
		    unset tmpPjtDir
		    unset tmpImpDir
		    unset newProjectFrame2
		    unset frame1_1
		    unset frame1_4
		    unset frame2_1
		    unset frame2_2
		    unset frame2_3
		    unset winNewProj
	    }
	    catch { destroy .newprj }
	    return
    }

    grid config $frame1_1 -row 0 -column 0 -sticky w 
    grid config $frame1_1.la_pjname -row 0 -column 0 -sticky w
    grid config $frame1_1.en_pjname -row 0 -column 1 -sticky w -padx 5
    grid config $frame1_1.la_pjpath -row 2 -column 0 -sticky w
    grid config $frame1_1.en_pjpath -row 2 -column 1 -sticky w -padx 5 -pady 10
    grid config $frame1_1.bt_pjpath -row 2 -column 2 -sticky w 
    grid config $frame1_1.la_saveoption -row 4 -column 0 -columnspan 2 -sticky w
    grid config $frame1_1.ra_save -row 5 -column 1 -sticky w -pady 2
    grid config $frame1_1.ra_prompt -row 6 -column 1 -sticky w
    grid config $frame1_1.ra_discard -row 7 -column 1 -sticky w -pady 2
    grid config $frame1_1.la_desc -row 8 -column 0 -sticky w
    grid config $frame1_1.t_desc -row 9 -column 0 -columnspan 3 -pady 10 -sticky news
    grid config $frame1_4 -row 11 -column 0
    grid config $frame1_4.bt_back -row 0 -column 0
    grid config $frame1_4.bt_next -row 0 -column 1
    grid config $frame1_4.bt_cancel -row 0 -column 2

    wm protocol .newprj WM_DELETE_WINDOW "$frame1_4.bt_cancel invoke"
    bind $winNewProj <KeyPress-Return> "$frame1_4.bt_next invoke"
    bind $winNewProj <KeyPress-Escape> "$frame1_4.bt_cancel invoke"

    focus $frame1_1.en_pjname	
    Operations::centerW $winNewProj
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::NewProjectText
# 
#  Arguments : t_desc - path of the text widget
#              choice - message displayed based on choice
#
#  Results : -
#
#  Description : Displays description message for project settings
#---------------------------------------------------------------------------------------------------
proc ChildWindows::NewProjectText {t_desc choice} {
    $t_desc configure -state normal
    switch -- $choice {
	    0 {
		    $t_desc delete 1.0 end
		    $t_desc insert end "Edited data are saved automatically"
	    }
	    1 {
		    $t_desc delete 1.0 end
		    $t_desc insert end "Prompts the user for saving the edited data"
	    }
	    2 {
		    $t_desc delete 1.0 end
		    $t_desc insert end "Edited data is discarded unless user saves it"
	    }
    }
    $t_desc configure -state disabled
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::NewProjectMNText
# 
#  Arguments : t_desc - path of the text widget
#
#  Results : -
#
#  Description : Displays description message for imported file for mn and autogenerate
#---------------------------------------------------------------------------------------------------
proc ChildWindows::NewProjectMNText {t_desc} {
    global conf
    global ra_auto

    if { $conf == "on" } {
	    set msg1 "Imports default xdd file designed by Kalycito for openPOWERLINK MN"
    } else {
	    set msg1 "Imports user selected xdd or xdc file for openPOWERLINK MN"
    }

    if { $ra_auto == 1 } {
	    set msg2 "Autogenerates MN object dictionary during build"
    } else {
	    set msg2 "User imported xdd or xdc file will be build"
    }

    $t_desc configure -state normal
    $t_desc delete 1.0 end
    $t_desc insert 1.0 "$msg1\n\n$msg2"
    $t_desc configure -state disabled
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::NewProjectCreate
# 
#  Arguments : tmpPjtDir   - project location
#              tmpPjtName  - project name
#              tmpImpDir   - file to be imported
#              conf        - choice based on which file is imported
#              tempRa_proj - project settings 
#              tempRa_auto - auto generate 
#
#  Results : -
#
#  Description : creates the new project 
#---------------------------------------------------------------------------------------------------
proc ChildWindows::NewProjectCreate {tmpPjtDir tmpPjtName tmpImpDir conf tempRa_proj tempRa_auto} {
    global tcl_platform
    global rootDir
    global ra_proj
    global ra_auto
    global treePath
    global mnCount
    global projectName
    global projectDir
    global nodeIdList
    global status_save
    global viewChgFlg

    #CloseProject is called to delete node and insert tree
    Operations::CloseProject

    set projectName $tmpPjtName
    set pjtName [string range $projectName 0 end-[string length [file extension $projectName]] ] 
    set projectDir [file join $tmpPjtDir  $pjtName]

    $treePath itemconfigure ProjectNode -text $tmpPjtName

#    set catchErrCode [Operations::NodeCreate 240 0 openPOWERLINK_MN]
#    set ErrCode [ocfmRetCode_code_get $catchErrCode]
#    if { $ErrCode != 0 } {
#	    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
#		    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .
#	    } else {
#		    tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
#	    }
#	    return
#    }


    #New project is created need to save
    set status_save 1

    $treePath insert end ProjectNode MN-$mnCount -text "openPOWERLINK_MN(240)" -open 1 -image [Bitmap::get mn]
    lappend nodeIdList 240 

    if {$conf == "off" || $conf == "on" } {
	    thread::send [tsv::get application importProgress] "StartProgress" 
	    #set catchErrCode [ImportXML "$tmpImpDir" 240 0]
	    set catchErrCode [NewProjectNode 240 0 openPOWERLINK_MN "$tmpImpDir"]
	    set ErrCode [ocfmRetCode_code_get $catchErrCode]
	    if { $ErrCode != 0 } {
		    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .
		    } else {
			    tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
		    }
		    thread::send  [tsv::set application importProgress] "StopProgress"
		    return
	    }
        #All the nw project has view type SIMPLE do not insert OBD icon
        #$treePath insert end MN-$mnCount OBD-$mnCount-1 -text "OBD" -open 0 -image [Bitmap::get pdo]

	    set result [WrapperInteractions::Import OBD-$mnCount-1 0 240]
	    thread::send  [tsv::set application importProgress] "StopProgress"
	    if { $result == "fail" } {
		    return
	    }
	    Console::DisplayInfo "Imported file $tmpImpDir for MN"

	    file mkdir [file join $projectDir ]
	    file mkdir [file join $projectDir cdc_xap]
	    file mkdir [file join $projectDir octx]
	    file mkdir [file join $projectDir scripts]

	    ChildWindows::CopyScript $projectDir

	    if { [$Operations::projMenu index 2] != "2" } {
		    $Operations::projMenu insert 2 command -label "Close Project" -command "Operations::InitiateCloseProject"
	    }
	    if { [$Operations::projMenu index 3] != "3" } {
		    $Operations::projMenu insert 3 command -label "Properties..." -command "ChildWindows::PropertiesWindow"
	    }
    }
    #set the view type as simple for all new project
    set Operations::viewType "SIMPLE"
    set viewType 0
    global lastVideoModeSel
    set lastVideoModeSel 0
    set viewChgFlg 0
    #if { $Operations::viewType == "EXPERT" } {
    #    set viewType 1
    #} else {
    #    set viewType 0
    #}
    set catchErrCode [SetProjectSettings $tempRa_auto $tempRa_proj $viewType $viewChgFlg]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode != 0 } {
	    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
		    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .
	    } else {
		    tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
	    }
    }
    set ra_proj $tempRa_proj
    set ra_auto $tempRa_auto
    Console::ClearMsgs
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::CloseProjectWindow
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Creates the child window to close project
#---------------------------------------------------------------------------------------------------
proc ChildWindows::CloseProjectWindow {} {
    global projectDir
    global projectName
    global treePath
    global status_save	

    if {$projectDir == "" || $projectName == "" } {
	    Console::DisplayInfo "No Project present to close" info
	    Operations::CloseProject
	    return
    } else {	
	    set result [tk_messageBox -message "Close Project $projectName?" -type okcancel -icon question -title "Question" -parent .]
	     switch -- $result {
		    ok {
			    Operations::CloseProject
			    return ok
		    }
		    cancel {
			    return cancel 
		    }
	    }
    }		
}

#---------------------------------------------------------------------------------------------------
#  ImportProgress
# 
#  Arguments : stat - change the status of progressbar
#
#  Results : -
#
#  Description : Creates the child window displaying progress bar
#---------------------------------------------------------------------------------------------------
proc ImportProgress {stat} {
    if {$stat == "start"} {
	    wm deiconify .
	    raise .
	    focus .
	    set winImpoProg .
	    wm title     $winImpoProg	"In Progress"
	    wm resizable $winImpoProg 0 0
	    wm deiconify $winImpoProg
	    grab $winImpoProg

	    if {![winfo exists .prog]} {
		    set prog [ttk::progressbar .prog -mode indeterminate -orient horizontal -length 200 ]
		    grid config $prog -row 0 -column 0 -padx 10 -pady 10
	    }
	    catch { .prog start 10 }
	    catch { BWidget::place $winImpoProg 0 0 center }
	    update idletasks
	    return  
    } elseif {$stat == "stop" } { 
	    catch {	.prog stop }
	    wm withdraw .
    } else {
	
    }

}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::AddIndexWindow
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Creates the child window and adds the index to the node
#---------------------------------------------------------------------------------------------------
proc ChildWindows::AddIndexWindow {} {
    global treePath
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
    set frame3 [frame $frame1.fram3]

    label $winAddIdx.la_empty1 -text "               "	
    label $frame1.la_index -text "Enter the Index :"
    label $winAddIdx.la_empty2 -text "               "	
    label $winAddIdx.la_empty3 -text "               "
    label $frame3.la_hex -text "0x"

    entry $frame3.en_index -textvariable indexVar -background white -relief ridge -validate key -vcmd "Validation::IsValidIdx %P 4"
    set indexVar ""

    button $frame2.bt_ok -width 8 -text "  Ok  " -command {
	    if {[string length $indexVar] != 4} {
		    set res [tk_messageBox -message "Invalid Index should be 4 characters long" -type ok -parent .addIdx]
		    focus .addIdx
		    return
	    }
	    set indexVar [string toupper $indexVar]
	    set node [$treePath selection get]

	    #gets the nodeId and Type of selected node
	    set result [Operations::GetNodeIdType $node]
	    if {$result != "" } {
		    set nodeId [lindex $result 0]
		    set nodeType [lindex $result 1]
	    } else {
		    return
	    }
	    set nodePosition [split $node -]
	    set nodePosition [lrange $nodePosition 1 end]
	    set nodePosition [join $nodePosition -]

	    if {[string match "18*" $indexVar] || [string match "1A*" $indexVar]} {
		    #is a TPDO object
		    set child [$treePath nodes TPDO-$nodePosition]
	    } elseif {[string match "14*" $indexVar] || [string match "16*" $indexVar]} {
		    #is a RPDO object	
		    set child [$treePath nodes RPDO-$nodePosition]
	    } else {
		    set child [$treePath nodes $node]
	    }	

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
			    if {[ expr 0x$indexVar > 0x[string range [$treePath itemcget $tempChild -text] end-4 end-1] ]} {
				    #since the tree is populated after sorting 
				    incr indexPosition
			    } else {
			    }
		    }
	    }


	    set sortChild [lsort -integer $sortChild]
	    if {$sortChild == ""} {
		    set count 0
	    } else {
		    set count [expr [lindex $sortChild end]+1 ]
	    }
	    set catchErrCode [AddIndex $nodeId $nodeType $indexVar]
	    set ErrCode [ocfmRetCode_code_get $catchErrCode]
	    if { $ErrCode != 0 } {
		    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .addIdx
		    } else {
			    tk_messageBox -message "Unknown Error" -title Error -icon error -parent .addIdx
		    }
		    catch { $frame2.bt_cancel invoke }
		    return
	    }

	    #Index is added need to save
	    set status_save 1
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
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .addIdx
		    } else {
			    tk_messageBox -message "Unknown Error" -title Error -icon error -parent .addIdx
		    }
		    catch { $frame2.bt_cancel invoke }
		    return
	    }
	    set indexPos [new_intp]
	    set catchErrCode [IfIndexExists $nodeId $nodeType $indexVar $indexPos]
	    set indexPos [intp_value $indexPos]

	    set indexName [GetIndexAttributesbyPositions $nodePos $indexPos 0 ]
	    if {[string match "18*" $indexVar] || [string match "1A*" $indexVar]} {
		    #is a TPDO object
		    set parentNode TPDO-$nodePosition
		    set indexNode TPdoIndexValue-$nodePosition-$count
		    set subIndexNode TPdoSubIndexValue-$nodePosition-$count
	    } elseif {[string match "14*" $indexVar] || [string match "16*" $indexVar]} {
		    #is a RPDO object	
		    set parentNode RPDO-$nodePosition
		    set indexNode RPdoIndexValue-$nodePosition-$count
		    set subIndexNode RPdoSubIndexValue-$nodePosition-$count
	    } else {
		    set parentNode $node
		    set indexNode IndexValue-$nodePosition-$count
		    set subIndexNode SubIndexValue-$nodePosition-$count
	    }

	    $treePath insert $indexPosition $parentNode $indexNode -text [lindex $indexName 1]\(0x$indexVar\) -open 0 -image [Bitmap::get index]
	    set sidxCorrList [WrapperInteractions::SortNode $nodeType $nodeId $nodePos sub $indexPos $indexVar]
	    set sidxCount [llength $sidxCorrList]
	    for {set tempSidxCount 0} { $tempSidxCount < $sidxCount } {incr tempSidxCount} {
		    set sortedSubIndexPos [lindex $sidxCorrList $tempSidxCount]
		    set subIndexName [GetSubIndexAttributesbyPositions $nodePos $indexPos $sortedSubIndexPos  0 ]
		    set subIndexId [GetSubIndexIDbyPositions $nodePos $indexPos $sortedSubIndexPos ]
		    set subIndexId [lindex $subIndexId 1]
		    $treePath insert $tempSidxCount $indexNode $subIndexNode-$tempSidxCount -text [lindex $subIndexName 1]\(0x$subIndexId\) -open 0 -image [Bitmap::get subindex]
		    $treePath itemconfigure $subIndexNode-$tempSidxCount -open 0
	    }
	    catch { $frame2.bt_cancel invoke }
    }
    button $frame2.bt_cancel -width 8 -text Cancel -command { 
	    catch {
		    unset indexVar
		    unset frame2
	    }
	    catch { destroy .addIdx	 }
	    return
    }
    grid config $winAddIdx.la_empty1 -row 0 -column 0 
    grid config $frame1 -row 1 -column 0 
    grid config $winAddIdx.la_empty2 -row 2 -column 0 
    grid config $frame2 -row 3 -column 0  
    grid config $winAddIdx.la_empty3 -row 4 -column 0 

    grid config $frame1.la_index -row 0 -column 0 -padx 5
    grid config $frame3 -row 0 -column 1 -padx 5
    grid config $frame3.la_hex -row 0 -column 0
    grid config $frame3.en_index -row 0 -column 1


    grid config $frame2.bt_ok -row 0 -column 0 -padx 5
    grid config $frame2.bt_cancel -row 0 -column 1 -padx 5

    wm protocol .addIdx WM_DELETE_WINDOW "$frame2.bt_cancel invoke"
    bind $winAddIdx <KeyPress-Return> "$frame2.bt_ok invoke"
    bind $winAddIdx <KeyPress-Escape> "$frame2.bt_cancel invoke"

    focus $frame3.en_index
    Operations::centerW $winAddIdx
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::AddSubIndexWindow
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Creates the child window and adds the subindex to the index
#---------------------------------------------------------------------------------------------------
proc ChildWindows::AddSubIndexWindow {} {
    global treePath
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
    set frame3 [frame $frame1.fram3]

    label $winAddSidx.la_empty1 -text "               "	
    label $frame1.la_subindex -text "Enter the SubIndex :"
    label $winAddSidx.la_empty2 -text "               "	
    label $winAddSidx.la_empty3 -text "               "
    label $frame3.la_hex -text "0x"

    entry $frame3.en_subindex -textvariable subIndexVar -background white -relief ridge -validate key -vcmd "Validation::IsValidIdx %P 2"
    set subIndexVar ""

    button $frame2.bt_ok -width 8 -text "  Ok  " -command {
	    if {[string length $subIndexVar] == 1} {
		    set subIndexVar 0$subIndexVar
	    } elseif { [string length $subIndexVar] != 2 } {
		    set res [tk_messageBox -message "Invalid SubIndex should be 2 characters long" -type ok -parent .addSidx]
		    focus .addSidx
		    return
	    }		
	    set subIndexVar [string toupper $subIndexVar]
	    set node [$treePath selection get]
	    set indexVar [string range [$treePath itemcget $node -text] end-4 end-1 ]
	    set indexVar [string toupper $indexVar]
	    #gets the nodeId and Type of selected node
	    set result [Operations::GetNodeIdType $node]
	    if {$result != "" } {
		    set nodeId [lindex $result 0]
		    set nodeType [lindex $result 1]
	    } else {
		    return
	    }

	    set child [$treePath nodes $node]
	    set subIndexPos 0
	    set sortChild ""
	    foreach tempChild $child {
		    set tail [split $tempChild -]
		    set tail [lindex $tail end]
		    lappend sortChild $tail
		    #find the position where the added index is to be inserted in sorted order in TreeView 
		    #0x is appended so that the input will be considered as hexadecimal number and numerical operation proceeds
		    if {[ expr 0x$subIndexVar > 0x[string range [$treePath itemcget $tempChild -text] end-2 end-1] ]} {
			    #since the tree is populated after sorting get the count where it is just greater such that it can be inserted properly
			    incr subIndexPos
		    } else {
		    }
	    }

	    set sortChild [lsort -integer $sortChild]
	    if {$sortChild == ""} {
		    set count 0
	    } else {
		    set count [expr [lindex $sortChild end]+1 ]
	    }
	    set nodePos [split $node -]
	    set nodePos [lrange $nodePos 1 end]
	    set nodePos [join $nodePos -]
	    set catchErrCode [AddSubIndex $nodeId $nodeType $indexVar $subIndexVar]
	    set ErrCode [ocfmRetCode_code_get $catchErrCode]
	    if { $ErrCode != 0 } {
		    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .addSidx
		    } else {
			    tk_messageBox -message "Unknown Error" -title Error -icon error -parent .addSidx
		    }
		    catch { $frame2.bt_cancel invoke }
		    return
	    }

	    #SubIndex is added need to save
	    set status_save 1

	    set subIndexName []
	    set subIndexName [GetSubIndexAttributes $nodeId $nodeType $indexVar $subIndexVar 0]

	    if {[string match "TPdo*" $node]} {
		    $treePath insert $subIndexPos $node TPdoSubIndexValue-$nodePos-$count -text [lindex $subIndexName 1]\(0x$subIndexVar\) -open 0 -image [Bitmap::get subindex]
	    } elseif {[string match "RPdo*" $node]} {
		    $treePath insert $subIndexPos $node RPdoSubIndexValue-$nodePos-$count -text [lindex $subIndexName 1]\(0x$subIndexVar\) -open 0 -image [Bitmap::get subindex]
	    } else {
		    $treePath insert $subIndexPos $node SubIndexValue-$nodePos-$count -text [lindex $subIndexName 1]\(0x$subIndexVar\) -open 0 -image [Bitmap::get subindex]
	    }
	    catch { $frame2.bt_cancel invoke }
	    return

    }
    button $frame2.bt_cancel -width 8 -text Cancel -command { 
	    catch {
		    unset subIndexVar
		    unset frame2
	    }
	    catch { destroy .addSidx }
	    return
    }
    grid config $winAddSidx.la_empty1 -row 0 -column 0 
    grid config $frame1 -row 1 -column 0
    grid config $winAddSidx.la_empty2 -row 2 -column 0 
    grid config $frame2 -row 3 -column 0  
    grid config $winAddSidx.la_empty3 -row 4 -column 0 

    grid config $frame1.la_subindex -row 0 -column 0 -padx 5
    grid config $frame3 -row 0 -column 1 -padx 5
    grid config $frame3.la_hex -row 0 -column 0
    grid config $frame3.en_subindex -row 0 -column 1

    grid config $frame2.bt_ok -row 0 -column 0 -padx 5
    grid config $frame2.bt_cancel -row 0 -column 1 -padx 5

    wm protocol .addSidx WM_DELETE_WINDOW "$frame2.bt_cancel invoke"
    bind $winAddSidx <KeyPress-Return> "$frame2.bt_ok invoke"
    bind $winAddSidx <KeyPress-Escape> "$frame2.bt_cancel invoke"

    focus $frame3.en_subindex
    Operations::centerW $winAddSidx
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::AddPDOWindow
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Creates the child window and adds the pdo index
#---------------------------------------------------------------------------------------------------
proc ChildWindows::AddPDOWindow {} {
    global treePath
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
    set frame3 [frame $frame1.fram3]

    label $winAddPdo.la_empty1 -text "               "	
    label $frame1.la_index -text "Enter the PDO Index :"
    label $winAddPdo.la_empty2 -text "               "	
    label $winAddPdo.la_empty3 -text "               "
    label $frame3.la_hex -text "0x"

    entry $frame3.en_index -textvariable pdoVar -background white -relief ridge -validate key -vcmd "Validation::IsValidIdx %P 4"
    set pdoVar ""

    button $frame2.bt_ok -width 8 -text "  Ok  " -command {
	    if {[string length $pdoVar] != 4} {
		    set res [tk_messageBox -message "Invalid PDO Index should be 4 characters long" -type ok -parent .addPdo]
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
		    set res [tk_messageBox -message "Invalid PDO Index \nfirst two characters should be 14, 16, 18 or 1A" -type ok -parent .addPdo]
		    focus .addPdo
		    return
	    }


	    set node [$treePath selection get]
	    #gets the nodeId and Type of selected node
	    set result [Operations::GetNodeIdType $node]
	    if {$result != "" } {
		    set nodeId [lindex $result 0]
		    set nodeType [lindex $result 1]
	    } else {
		    return
	    }


	    set nodePosition [split $node -]
	    set nodePosition [lrange $nodePosition 1 end]
	    set nodePosition [join $nodePosition -]

	    if {[string match "18*" $pdoVar] || [string match "1A*" $pdoVar]} {
		    #is a TPDO object
		    set child [$treePath nodes TPDO-$nodePosition]
	    } elseif {[string match "14*" $pdoVar] || [string match "16*" $pdoVar]} {
		    #is a RPDO object	
		    set child [$treePath nodes RPDO-$nodePosition]
	    } else {
		    #should not occur
	    }	


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
			    if {[ expr 0x$pdoVar > 0x[string range [$treePath itemcget $tempChild -text] end-4 end-1] ]} {
				    #since the tree is populated after sorting 
				    incr indexPosition
			    } else {
			    }
		    }
	    }

	    set sortChild [lsort -integer $sortChild]
	    if {$sortChild == ""} {
		    set count 0
	    } else {
		    set count [expr [lindex $sortChild end]+1 ]
	    }
	    set catchErrCode [AddIndex $nodeId $nodeType $pdoVar]
	    set ErrCode [ocfmRetCode_code_get $catchErrCode]
	    if { $ErrCode != 0 } {
		    if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .addPdo
		    } else {
			    tk_messageBox -message "Unknown Error" -title Error -icon error -parent .addPdo
		    }
		    catch { $frame2.bt_cancel invoke }
		    return
	    }

	    #Index is added to PDO need to save
	    set status_save 1
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
			    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .addPdo
		    } else {
			    tk_messageBox -message "Unknown Error" -title Error -icon error -parent .addPdo
		    }
		    catch { $frame2.bt_cancel invoke }
		    return
	    }
	    set indexPos [new_intp]
	    set catchErrCode [IfIndexExists $nodeId $nodeType $pdoVar $indexPos]
	    set indexPos [intp_value $indexPos]

	    set indexName [GetIndexAttributesbyPositions $nodePos $indexPos 0 ]
	    if {[string match "18*" $pdoVar] || [string match "1A*" $pdoVar]} {
		    #is a TPDO object
		    set parentNode TPDO-$nodePosition
		    set indexNode TPdoIndexValue-$nodePosition-$count
		    set subIndexNode TPdoSubIndexValue-$nodePosition-$count
	    } elseif {[string match "14*" $pdoVar] || [string match "16*" $pdoVar]} {
		    #is a RPDO object	
		    set parentNode RPDO-$nodePosition
		    set indexNode RPdoIndexValue-$nodePosition-$count
		    set subIndexNode RPdoSubIndexValue-$nodePosition-$count
	    } else {
		    #should not occur
		    return
	    }
	    $treePath insert $indexPosition $parentNode $indexNode -text [lindex $indexName 1]\(0x$pdoVar\) -open 0 -image [Bitmap::get index]

	    set sidxCorrList [WrapperInteractions::SortNode $nodeType $nodeId $nodePos sub $indexPos $pdoVar]
	    set sidxCount [llength $sidxCorrList]
	    for {set tempSidxCount 0} { $tempSidxCount < $sidxCount } {incr tempSidxCount} {
		    set sortedSubIndexPos [lindex $sidxCorrList $tempSidxCount]
		    set subIndexName [GetSubIndexAttributesbyPositions $nodePos $indexPos $sortedSubIndexPos  0 ]
		    set subIndexId [GetSubIndexIDbyPositions $nodePos $indexPos $sortedSubIndexPos ]
		    set subIndexId [lindex $subIndexId 1]
		    $treePath insert $tempSidxCount $indexNode $subIndexNode-$tempSidxCount -text [lindex $subIndexName 1]\(0x$subIndexId\) -open 0 -image [Bitmap::get subindex]
		    $treePath itemconfigure $subIndexNode-$tempSidxCount -open 0
	    }
	    catch { $frame2.bt_cancel invoke }
	    return
	
    }
    button $frame2.bt_cancel -width 8 -text Cancel -command { 
	    catch {
		    unset pdoVar
		    unset frame2
	    }
	    catch { destroy .addPdo	}
	    return
    }
    grid config $winAddPdo.la_empty1 -row 0 -column 0 
    grid config $frame1 -row 1 -column 0 
    grid config $winAddPdo.la_empty2 -row 2 -column 0 
    grid config $frame2 -row 3 -column 0  
    grid config $winAddPdo.la_empty3 -row 4 -column 0 

    grid config $frame1.la_index -row 0 -column 0 -padx 5
    grid config $frame3 -row 0 -column 1 -padx 5
    grid config $frame3.la_hex -row 0 -column 0
    grid config $frame3.en_index -row 0 -column 1

    grid config $frame2.bt_ok -row 0 -column 0 -padx 5
    grid config $frame2.bt_cancel -row 0 -column 1 -padx 5

    wm protocol .addPdo WM_DELETE_WINDOW "$frame2.bt_cancel invoke"
    bind $winAddPdo <KeyPress-Return> "$frame2.bt_ok invoke"
    bind $winAddPdo <KeyPress-Escape> "$frame2.bt_cancel invoke"

    focus $frame3.en_index
    Operations::centerW $winAddPdo
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::PropertiesWindow
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Creates the child window and adds the pdo index
#---------------------------------------------------------------------------------------------------
proc ChildWindows::PropertiesWindow {} {
    global treePath
    global projectDir

    set node [$treePath selection get]

    set winProp .prop
    catch "destroy $winProp"
    toplevel $winProp
    wm resizable $winProp 0 0
    wm transient $winProp .
    wm deiconify $winProp
    wm minsize   $winProp 200 100
    grab $winProp

    set frame1 [frame $winProp.frame -padx 5 -pady 5 ]

    if {$node == "ProjectNode"} {
	    wm title $winProp "Project Properties"
	    set title "Project Properties"
	    set title1 "Name"
	    set display1 [$treePath itemcget $node -text]
	    set title2 "Location"	
	    set display2 $projectDir
	    set message "$title1$display1\n$title2$display2"
    } elseif { [string match "MN-*" $node] || [string match "CN-*" $node] } {
	    if { [string match "MN-*" $node] } {
		    wm title $winProp "MN Properties"
		    set title "MN Properties"
		    set nodeId 240
		    set nodeType 0
		    set title1 "Managing Node"
		    set display1 "openPOWERLINK_MN"
		    set title3 "Number of CN"	
		    set count [new_intp]
		    set catchErrCode [GetNodeCount 240 $count]
		    set ErrCode [ocfmRetCode_code_get $catchErrCode]
		    if { $ErrCode == 0 } {
			    set display3 [expr [intp_value $count]-1]
		    } else {
			    set display3 ""
		    }
		    label $frame1.la_title3 -text $title3
		    label $frame1.la_sep3 -text ":"
		    label $frame1.la_display3 -text $display3	
	    } else {
		    wm title $winProp "CN Properties"
		    set title "CN Properties"
		    set result [Operations::GetNodeIdType $node]
		    if {$result != "" } {
			    set nodeId [lindex $result 0]
			    set nodeType [lindex $result 1]
		    } else {
			    #must be some other node this condition should never reach
			    return
		    }
		    set title1 "Name"
		    set display1 [string range [$treePath itemcget $node -text] 0 end-[expr [string length $nodeId]+2]]
	
	    }
	    set title2 "NodeId"	
	    set display2 $nodeId

	    set title4 "Number of Indexes"
	    set count [new_intp]
	    set catchErrCode [GetIndexCount $nodeId $nodeType $count]
	    set ErrCode [ocfmRetCode_code_get $catchErrCode]
	    if { $ErrCode == 0 } {
		    set display4 [intp_value $count]
	    } else {
		    set display4 ""
	    }
	    label $frame1.la_title4 -text $title4
	    label $frame1.la_sep4 -text ":"
	    label $frame1.la_display4 -text $display4
    } else {
	    return
    }


    label $frame1.la_title1 -text $title1 
    label $frame1.la_sep1 -text ":"
    label $frame1.la_display1 -text $display1
    label $frame1.la_title2 -text $title2
    label $frame1.la_sep2 -text ":"
    label $frame1.la_display2 -text $display2
    label $frame1.la_empty1 -text ""
    label $frame1.la_empty2 -text ""

    button $winProp.bt_ok -text "  Ok  " -width 8 -command {
	    destroy .prop
    }

    pack configure $frame1 
    grid config $frame1.la_empty1 -row 0 -column 0 -columnspan 2

    grid config $frame1.la_title1 -row 1 -column 0 -sticky w
    grid config $frame1.la_sep1 -row 1 -column 1
    grid config $frame1.la_display1 -row 1 -column 2 -sticky w
    grid config $frame1.la_title2 -row 2 -column 0  -sticky w
    grid config $frame1.la_sep2 -row 2 -column 1
    grid config $frame1.la_display2 -row 2 -column 2 -sticky w
    if { $node == "ProjectNode" } {
	    grid config $frame1.la_empty2 -row 3 -column 0 -columnspan 1
	    pack configure $winProp.bt_ok -pady 10
    } elseif { [string match "MN-*" $node] } {
	    grid config $frame1.la_title3 -row 3 -column 0 -sticky w	
	    grid config $frame1.la_sep3 -row 3 -column 1	
	    grid config $frame1.la_display3 -row 3 -column 2 -sticky w
	    grid config $frame1.la_title4 -row 4 -column 0 -sticky w
	    grid config $frame1.la_sep4 -row 4 -column 1	
	    grid config $frame1.la_display4 -row 4 -column 2 -sticky w
	    grid config $frame1.la_empty2 -row 5 -column 0 -columnspan 1
	    pack configure $winProp.bt_ok -pady 10
    } elseif { [string match "CN-*" $node] } {
	    grid config $frame1.la_title4 -row 3 -column 0 -sticky w
	    grid config $frame1.la_sep4 -row 3 -column 1
	    grid config $frame1.la_display4 -row 3 -column 2 -sticky w
	    grid config $frame1.la_empty2 -row 4 -column 0 -columnspan 1
	    pack configure $winProp.bt_ok -pady 10
    } else {
	    #should not occur
    }

    wm protocol .prop WM_DELETE_WINDOW "$winProp.bt_ok invoke"
    bind $winProp <KeyPress-Return> "$winProp.bt_ok invoke"
    bind $winProp <KeyPress-Escape> "$winProp.bt_ok invoke"
    Operations::centerW $winProp
    focus $winProp
}

#---------------------------------------------------------------------------------------------------
#  ChildWindows::CopyScript
# 
#  Arguments : -
#
#  Results : -
#
#  Description : Copies the transfer script file
#---------------------------------------------------------------------------------------------------
proc ChildWindows::CopyScript { pjtFldr } {
    global tcl_platform
    global rootDir
    
    if {"$tcl_platform(platform)" == "windows"} {
	set sptFile Transfer.bat
    } elseif {"$tcl_platform(platform)" == "unix"} {
	set sptFile Transfer.sh
    }
    set scriptFile [file join $rootDir $sptFile]
    if { [file exists $scriptFile] && [file isfile $scriptFile] } {
	#file exists
	catch {file copy -force $scriptFile [file join $pjtFldr scripts]}
	return pass
    } else {
	tk_messageBox -parent . -icon info -message "file $sptFile at location $rootDir is missing\nTransfer feature will not work"
	return fail
    }
}
