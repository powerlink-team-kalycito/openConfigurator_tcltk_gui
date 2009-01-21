################################################################################
#									
# Script:	operations.tcl						
#									
# Author:	Kalycito Infotech Pvt Ltd		
#									
# Description:	Contains the procedures for Open Configurator 
# 
#
# Version:	Version - 1.0.
#
################################################################################

source $RootDir/record.tcl
#source $RootDir/xmlread.tcl
#source $RootDir/ReadResultXml.tcl
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
##
#
##
global PjtDir 
global PjtName
##variable helpMessage
variable status_run
##variable profileName
##variable testGroupName
##variable selectedProfile
set status_run 0
set cnCount 0
set mnCount 0
################################################################################

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
    variable search_var
    variable search_combo
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
    #variable f0
}


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
    label $aboutWindow.l_msg -image [Bitmap::get info] -compound left -text "\n      openMANAGER Tool           \n       Designed by       \nKalycito Infotech Private Limited.  \n"
    button $aboutWindow.bt_ok -text Ok -command "destroy $aboutWindow"
    grid config $aboutWindow.l_msg -row 0 -column 0 
    grid config $aboutWindow.bt_ok -row 1 -column 0
    bind $aboutWindow <KeyPress-Return> "destroy $aboutWindow"
    focus $aboutWindow.bt_ok
    centerW .about
}

proc centerW w {
    BWidget::place $w 0 0 center
}

proc Editor::RunStatusInfo {} {\

    option add *Font {helvetica 10 normal}
    tk_messageBox -message \
    "A Run is in progress" \
    -type ok \
    -title {Information} \
    -icon info
}

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


################################################################################
#proc Editor::saveOptions
#called when open configurator exits
#saves only "EditorData(options,...)"
#but might be easily enhanced with other options
################################################################################


proc Editor::setDefault {} {
    global tcl_platform
    global EditorData
    global RootDir
    global f0
    global f1
    variable current
    variable configError
    variable toolbar1
    variable toolbar2
    variable showConsoleWindow
    variable showProcWindow
    variable sortProcs
    variable showProc
    variable checkNestedProc
    variable options
    variable lineNo
    
    
    set current(is_procline) 0; #is needed for checkProcs
    set current(procLine) 0
    set current(autoUpdate) 1
    set current(procSelectionChanged) 0
    set current(procListHistoryPos) 0
    set current(procListHistory) [list "mark1"]
    set current(procList_hist_maxLength) 20
    set current(lastPos) "1.0"
    set current(isNode) 0
    set current(checkRootNode) 0
    set current(isUpdate) 0
    
    
    # set keywords
    #set fd [open [file join $RootDir keywords.txt ] r]
    #set keyList ""
    #while {![eof $fd]} {
    #    gets $fd word
    #    lappend keyList $word
    #}
    #close $fd
    #set EditorData(keywords) $keyList
    set EditorData(files) {}
    set EditorData(curFile) ""
    set EditorData(find) {}
    set EditorData(find,lastOptions) ""
    set EditorData(replace) {}
    set EditorData(projectFile) ""
    set EditorData(cursor,line) 1
    set EditorData(cursor,pos) 0
    set EditorData(cursorPos) "Line: 1   Pos: 0"
    set Editor::lineNo $EditorData(cursor,line)
    
    if $configError {
        if {$tcl_platform(platform) == "windows"} {
            set EditorData(options,fontSize) 15
            set EditorData(options,fontEncoding) ""
        } else {
            set EditorData(options,fontSize) 12
            set EditorData(options,fontEncoding) "koi8-r"
        }
        
        
        font create nbFrameFont -size 8
        
        #set EditorData(options,useEvalServer) 0
        #set options(useEvalServer) 0
        #set EditorData(options,serverPort) 9001
        #set options(serverPort) 9001
        #set EditorData(options,serverWish) [list [info nameofexecutable]]
        #set options(serverPort) [info nameofexecutable]
        set EditorData(options,useIndent) 1
        set options(useIndent) 1
        set EditorData(options,useSintaxIndent) 1
        set options(useSI) 1
        set EditorData(options,indentSize) 4
        set EditorData(options,changeTabs) 1
        set options(changeTabs) 1
        set EditorData(options,tabSize) 4
        set EditorData(options,useHL) 1
        set options(useHL) 1
        set EditorData(options,useTemplates) 1
        set options(useTemplates) 1
        set EditorData(options,useTemplatesForKeywords) 1
        set options(useKeywordTemplates) 1
        set EditorData(options,useTemplatesForBrace) 1
        set options(useBracesTemplates) 1
        set EditorData(options,useTemplatesForParen) 1
        set options(useParenTemplates) 1
        set EditorData(options,useTemplatesForBracket) 1
        set options(useBracketTemplates) 1
        set EditorData(options,useTemplatesForQuoteDbl) 1
        set options(useQuotesTemplates) 1
        set EditorData(options,showToolbar1) $toolbar1
        #set EditorData(options,showToolbar2) $toolbar2
        set options(showConsole) 1
        set EditorData(options,showConsole) $showConsoleWindow
        set options(showProcs) 1
        set EditorData(options,showProcs) $showProcWindow
        set options(sortProcs) 1
        set EditorData(options,sortProcs) $sortProcs
        set options(autoUpdate) 1
        set EditorData(options,autoUpdate) 1
        set options(showProc) 1
        set EditorData(options,showProc) $showProc
        set options(defaultProjectFile) "none"
        set EditorData(options,defaultProjectFile) "none"
        set current(project) "none"
        set options(workingDir) "~"
        set EditorData(options,workingDir) "~"
        set options(showSolelyConsole) 0
        set EditorData(options,showSolelyConsole) 0
        set options(useDefaultExtension) 1
        set EditorData(options,useDefaultExtension) 1
    } else  {
        set toolbar1 $EditorData(options,showToolbar1)
        #set toolbar2 $EditorData(options,showToolbar2)
        #set options(useEvalServer) $EditorData(options,useEvalServer)
        #set options(serverPort) $EditorData(options,serverPort)
        set options(useIndent) $EditorData(options,useIndent)
        set options(useSI) $EditorData(options,useSintaxIndent)
        set options(useHL) $EditorData(options,useHL)
        set options(useTemplates) $EditorData(options,useTemplates)
        set options(useKeywordTemplates) $EditorData(options,useTemplatesForKeywords)
        set options(useBracesTemplates) $EditorData(options,useTemplatesForBrace)
        set options(useParenTemplates) $EditorData(options,useTemplatesForParen)
        set options(useBracketTemplates) $EditorData(options,useTemplatesForBracket)
        set options(useQuotesTemplates) $EditorData(options,useTemplatesForQuoteDbl)
        set options(changeTabs) $EditorData(options,changeTabs)
        set options(showConsole) $EditorData(options,showConsole)
        set options(showProcs) $EditorData(options,showProcs)
        set options(showProc) $EditorData(options,showProc)
        set options(autoUpdate) $EditorData(options,autoUpdate)
        set options(sortProcs) $EditorData(options,sortProcs)
        set options(defaultProjectFile) $EditorData(options,defaultProjectFile)
        set current(project) $EditorData(options,defaultProjectFile)
        set options(workingDir) $EditorData(options,workingDir)
        set options(showSolelyConsole) $EditorData(options,showSolelyConsole)
        set options(serverWish) $EditorData(options,serverWish)
        set options(useDefaultExtension) $EditorData(options,useDefaultExtension)
    }
    set EditorData(indentString) "    "
    return
}






################################################################################
#
# Gui components of the treewidget
#
#
#
################################################################################

################################################################################
#
#  proc Editor::tdelNode
#
#  deletes a node and its children from the tree
#
################################################################################
proc Editor::tdelNode {node} {
    variable treeWindow
    
    regsub -all " " $node \306 node
    regsub ":$" $node \327 node
    regsub -all "\\\$" $node "�" node
    $treeWindow delete $node
}


################################################################################
#
#  proc Editor::tnewNode
#
#  inserts a new node into the tree. Gets a string representation of
#  the namspace/class/method/proc name and the type of object
#
#
################################################################################
proc Editor::tnewNode {nodedata} {
    variable current
    variable treeWindow
    set pagename objtree
    set instanceNo 0
    
    set node [lindex $nodedata 0]
    set type [lindex $nodedata 1]
    set startIndex [lindex $nodedata 2]
    set endIndex [lindex $nodedata 3]
    
    # mask spaces in the node name
    regsub -all " " $node \306 node
    # mask ending single : in node name
    regsub ":$" $node \327 node
    # mask "$" in nodename
    regsub -all "\\\$" $node "�" node
    # mask instance number
    regsub "\367.+\376$" $node "" node
    
    if {[string index $node [expr [string length $node] -1]] == "#"} {
        append node "{}"
    }
    #check current namespace in normal editing mode
    if {$current(checkRootNode) != 0} {
        # if node doesn't present a qualified name,
        # which presents it's rootnode by itself (e.g. test::test)
        # try to set it�s rootnode
        # use regsub to count qualifiers (# in nodes instead of ::)
        if {[regsub -all -- {#} $node "" dummy] > 1} {
            # do nothing
        } else  {
            set rootNode [selectObject 0 "insert linestart -1c"]
            if {$rootNode != ""} {
                set name [string range $node [expr [string last \# $node]+1] end]
                if {$name == ""} {
                    set name $node
                }
                set node "$rootNode\#$name"
            }
        }
    }
    
    set rootnode [string range $node 0 [expr [string last \# $node] -1]]
    set name [string range $node [expr [string last \# $node]+1] end]
    
    # get rid of the � in the node
    regsub -all \306 $name " " name
    regsub \327 $name ":" name
    regsub -all "�" $name "\$" name
    if {$name == ""} {
        set name $node
    }
    
    #Does the rootnode exist ? Otherwise call tnewNode recursively
    if {![string match $type file]} {
        if {![$treeWindow exists $rootnode]} {
            tnewNode [list [list $rootnode] dummy $startIndex $endIndex]
        }
    }
    # Does node exist ? Then append an instance counter
    while {[$treeWindow exists $node]} {
        regsub "\367.+\367$" $node "" node
        # append instance number"
        incr instanceNo
        append node \367$instanceNo\367
    }
    switch $type {
        "file" {
		#$treeWindow insert end root $node -text "TestProject" \
                    -open 1 -data $type -image [Bitmap::get openfold] 
		#set child [$treeWindow insert end $node Config:1 -text "Site.exp" -open 0 -image [Bitmap::get file]]	
		$treeWindow insert end child-$nodecount $node - image [Bitmap::get file] -drawcross auto \
               		-text Configure-$nodecount 
        "code" {
            $treeWindow insert end $rootnode $node -text $name \
                    -open 1 -data $type  -image [Bitmap::get oplink]
            if {$name == "<Top>"} {
                $treeWindow itemconfigure $node -image [Bitmap::get top]
            } elseif {$name == "<Bottom>"}  {
                $treeWindow itemconfigure $node -image [Bitmap::get bottom]
            } else  {
                $treeWindow itemconfigure $node -image [Bitmap::get qmark]
            }
        }
        
        "namespace" -
        "class" {
            $treeWindow insert end  $rootnode $node  -text "$type: $name" \
                    -open 1 -data $type -image [Bitmap::get openfold] -drawcross allways
        }
        "dummy" {
            $treeWindow insert end  $rootnode $node  -text "namespace: $name" \
                    -open 1 -data $type -image [Bitmap::get openfold]
        }
        "proc" {
            $treeWindow insert end  $rootnode $node  -text "$type: $name" \
                    -open 1 -data $type -image [Bitmap::get file]
        }
        "method" {
            $treeWindow insert end  $rootnode $node  -text "$type: $name" \
                    -open 1 -data $type -image [Bitmap::get new]
        }
        "forward" {
            $treeWindow insert end  $rootnode $node  -text "$name" \
                    -open 1 -data $type -image [Bitmap::get oplink]
        }
        "body" {
            $treeWindow insert end  $rootnode $node  -text "$name" \
                    -open 1 -data $type -image [Bitmap::get file]
        }
        "configbody" {
            $treeWindow insert end  $rootnode $node  -text "$type: $name" \
                    -open 1 -data $type -image [Bitmap::get file]
        }
        
        "constructor" -
        "destructor" {
            $treeWindow insert end  $rootnode $node  -text "$type" \
                    -open 1 -data $type -image  [Bitmap::get new]
        }
        
        
        default {puts "Oops $nodedata"}
    }
    switch -- $name {
        "<Top>" -
        "<Bottom>" {
            set end_of_proc_name $node
            append end_of_proc_name "_end_of_proc"
            $Editor::current(text) mark set $node $startIndex
            if {$name == "<Top>"} {
                $Editor::current(text) mark gravity $node left
                $Editor::current(text) mark gravity $end_of_proc_name left
            }
            $Editor::current(text) mark set $end_of_proc_name $endIndex
            return $node
        }
        "file" {return ""}
        
        default {
            set Editor::procMarks($node) $type
            set end_of_proc_name $node
            append end_of_proc_name "_end_of_proc"
            set Editor::procMarks($end_of_proc_name) $type
            $Editor::current(text) mark set $node $startIndex
            $Editor::current(text) mark set $end_of_proc_name $endIndex
            $Editor::current(text) mark gravity $end_of_proc_name left
	  }
	}
    }
}

################################################################################
#
#  proc Editor::tgetData
#
#  gets the data for a given node
#
################################################################################
proc Editor::tgetData {node} {
    variable treeWindow
    
    
    if {[catch {$treeWindow itemcget $node -data} data]} {
        set data ""
    }
    return $data
}


################################################################################
#
#  proc Editor::tmoddir
#
#  needed to open / close a node in the tree. Gets open/close in $idx and
#  the name of the node in $node
#
################################################################################

proc Editor::tmoddir { idx node } {
    variable treeWindow
    
    if $idx {
        #Opening
        set data [$treeWindow itemcget $node -data]
        set type [lindex $data 0]
        switch $type {
            "namespace" -
            "class" {
                if { [llength [$treeWindow nodes $node]] } {
                    set img openfold
                } else  {
                    set img folder
                }
            }
            "code" {
                set name [lindex $data 1]
                if {$name == "<Top>"} {
                    set img top
                } elseif {$name == "<Bottom>"} {
                    set img bottom
                } else  {
                    set img qmark
                }
            }
            "forward" {set img oplink}
            "proc" -
            "method" { set img file}
            "configbody" -
            "body" {set img file}
            "constructor" -
            "destructor" {set img new}
            default {set img openfold}
        }
    } else  {
        #Closing
    }
    
    # $treeWindow itemconfigure $node -image [Bitmap::get $img]
    
}


################################################################################
#
#  proc Editor::topen
#
#  opens the complete tree
#
################################################################################
proc Editor::topen {path} {
    variable treeWindow
    variable current
    regsub -all " " $current(file) \306 node
    regsub ":$" $node \327 node
    regsub -all "\\\$" $node "�" node
#    $treeWindow opentree $node
	## commented for avoid opening all nodes and subnodes.
	#$treeWindow opentree $path
}

################################################################################
#
#  proc Editor::tclose
#
#  closes the complete tree
################################################################################
proc Editor::tclose {} {
    variable treeWindow
    variable current
    
    set node $current(file)
    regsub -all " " $node \306 node
    regsub ":$" $node \327 node
    regsub -all "\\\$" $node "�" node
    $treeWindow closetree $node
}


################################################################################
#
#  proc Editor::tselectright
#
#  selects the objects choosen from the tree
################################################################################

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
	} elseif {[string match "IndexValue-*" $node] == 1} { 
		tk_popup $Editor::idxMenu $x $y		
	} else {
		return 
	}   
}

################################################################################
#
#  proc Editor::tsee
#
#  show the now
#
################################################################################
proc Editor::tsee {node} {
    variable treeWindow
    
    $treeWindow see $node
}


################################################################################
#
#  proc Editor::torder
#
#  order the tree by types and alphabet
#
################################################################################
proc Editor::torder {node} {
    variable treeWindow
    variable current
    
    regsub -all " " $node \306 node
    regsub ":$" $node \327 node
    regsub -all "\\\$" $node "�" node
    
    proc sortTree {node} {
        variable treeWindow
        set children [$treeWindow nodes $node]
        if {[llength $children] == 0} {
            return
        }
        set tempList ""
        foreach child $children {
            sortTree $child
            set childText [$treeWindow itemcget $child -text]
            if {$childText == "<Top>" || $childText == "<Bottom>"} {
                continue
            }
            lappend tempList "$childText\#$child"
        }
        set sortedList ""
        set tempList [lsort -dictionary $tempList]
        
        foreach childNode $tempList {
            set nodeName [string range $childNode [expr [string first \# $childNode]+1] end]
            lappend sortedList $nodeName
        }
        $treeWindow reorder $node $sortedList
        return
    }
    
    proc realorderTree {node} {
        variable treeWindow
        variable current
        
        set children [$treeWindow nodes $node]
        if {[llength $children] == 0} {
            return
        }
        set indexList {}
        foreach child $children {
            set childText [$treeWindow itemcget $child -text]
            if {$childText == "<Top>" || $childText == "<Bottom>"} {
                continue
            }
            realorderTree $child
            set index [$current(text) index $child]
            set newItem $index
            lappend newItem $child
            lappend indexList $newItem
        }
        #now we have a list of children with "index name"
        set itemList [lsort -dictionary $indexList]
        set realorderList {}
        foreach item $itemList {
            lappend realorderList [lindex $item 1]
        }
        #now we have a realorderList for child
        $treeWindow reorder $node $realorderList
        return
    }
    
    if {$Editor::options(sortProcs)} {
        sortTree $node
    } else {
        realorderTree $node
    }
}



################################################################################
#proc Editor::setDefaultProject
#if default project file is set then this will be run from any window by
#pressing the Test button instead of the current file, except for the current
#file is associated to another projectfile
################################################################################
proc Editor::setDefaultProject {{filename {}}} {
    global EditorData
    variable current
    
    if {$filename == "none"} {
        switch -- [tk_messageBox -message "Do you want to unset current default project ?" \
                -type yesnocancel -icon question -title Question] {
                    yes {
                        set EditorData(options,defaultProjectFile) "none"
                        set current(project) "none"
                    }
            default {}
        }
        return
    }
    
    if {$filename == {}} {
        if {$EditorData(options,useDefaultExtension)} {
            # set defaultExt .tcl
            set filePatternList [list "Tcl-Files {*.tcl *.tk *.itcl *.itk}" "All {*.* *}"]
        } else  {
            # set defaultExt ""
            set filePatternList [list "All {*.* *}" "Tcl-Files {*.tcl *.tk *.itcl *.itk}" ]
        }
        set defaultExt ""
        set initialFile ""
        set filename [tk_getOpenFile -filetypes $filePatternList -initialdir $EditorData(options,workingDir) -title "Select Default Project File"]
    }
    if {$filename != ""} {
        set oldfile $EditorData(options,defaultProjectFile)
        set EditorData(options,defaultProjectFile) $filename
        # only set current(project) if it is not set by projectassociaion
        if {$current(project) == "$oldfile"} {
            set current(project) $filename
        }
    }
}



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

################################################################
# proc Editor::showTreeWin
#displays or not tree window
################################################################
proc Editor::showTreeWin {show} {
    variable list_notebook
    
    set win [winfo parent $list_notebook]
    set win [winfo parent $win]
    set panedWin [winfo parent $win]
    update idletasks
    
    if {$show} {
        grid configure $panedWin.f1 -column 2 -columnspan 1
        grid $panedWin.sash1
        grid $win
        grid columnconfigure $panedWin 0 -minsize 200
    } else  {
        grid remove $win
        grid remove $panedWin.sash1
        grid configure $panedWin.f1 -column 0 -columnspan 3
    }
}

################################################################
# proc Editor::showSolelyConsole
#displays console window alone or not
################################################################

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





#######################################################################
#proc OpenProject
#
#Opens an already existing project prompts to save the current project
########################################################################
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
				conPuts "Project $PjtName Saved" info
				saveproject
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
	puts "Project Dir->$PjtDir"
	puts "Projectfilename->$projectfilename"

}


###############################################################################
# proc Editor::create
#creates the GUI when application is started
###############################################################################
proc Editor::create { } {
    global tcl_platform
    global clock_var
    global EditorData
    global RootDir
    global f0
    global f1
    global f2
    global tf0
    global tf1
    #global ra_dec
    #global ra_hex

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
    variable search_combo
    variable argument_combo
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
    
    
    set result [catch {source [file join $RootDir/plk_configtool.cfg]} info]
    variable configError $result
   
    set prgtext "Please wait while loading ..."
    set prgindic -1
    _create_intro
    update
    
    
    # use default values
    #if {[catch {Editor::setDefault}]} {
    #    set configError 1
        #Editor::setDefault
    #}

    
    # Menu description
    set descmenu {
        "&File" {} {} 0 {           
            {command "New &Project" {} "New Project" {Ctrl n}  -command NewProjectWindow}
	    {command "Open Project" {}  "Open Project" {Ctrl o} -command openproject}
            {command "Save Project" {noFile}  "Save Project" {Ctrl s} -command YetToImplement}
            {command "Save Project as" {noFile}  "Save Project as" {} -command SaveProjectAsWindow}
	    {command "Close Project" {}  "Close Project" {} -command closeproject}                 
	    {separator}
            {command "E&xit" {}  "Exit openMANAGER" {Alt x} -command Editor::exit_app}
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
                    catch {$Editor::current(text) see insert}
                }
            }
            {checkbutton "Show Test Tree Browser" {all option} "Show Code Browser" {}
                -variable Editor::options(showProcs)
                -command  {set EditorData(options,showProcs) $Editor::options(showProcs)
                    Editor::showTreeWin $EditorData(options,showProcs)
                    update idletasks
                    catch {$Editor::current(text) see insert}
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

#shortcut keys for project
    bind . <Key-F7> "BuildProject"
    bind . <Control-Key-F7> "YetToImplement"
    bind . <Control-Key-F5> "YetToImplement"
    bind . <Control-Key-F6> "YetToImplement"
    bind . <Control-Key-f> "FindDynWindow"
    bind . <KeyPress-Escape> "EscapeTree"
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
    $Editor::IndexaddMenu add command -label "Add Index" -command {YetToImplement}
    $Editor::IndexaddMenu add command -label "Add PDO Objects" -command {AddPDOWindow}   

#	     -command {set cursor [. cget -cursor]
#			YetToImplement
#		      } 
     $Editor::cnMenu add command -label "Import XDC/XDD" \
        -command {YetToImplement
		#set cursor [. cget -cursor]
		#Call the procedure
		#set types {
		#        {"XDC Files"     {.xdc } }
		#        {"XDD Files"     {.xdd } }
		#}
		#set tmpImpDir [tk_getOpenFile -title "Import XDC" -filetypes $types -parent .]
		#set node [$updatetree selection get]
		#if {$tmpImpDir!=""} {
			# pass node Id  and node type instead of 1 and cn
		#	Import $node $tmpImpDir cn 1
		#}
            }
	
    
    $Editor::cnMenu add separator
    $Editor::cnMenu add command -label "Delete" -command { YetToImplement }

   
#############################################################################
# Menu for the Managing Nodes
#############################################################################
    set Editor::mnMenu [menu  .mnMenu -tearoff 0]

     $Editor::mnMenu add command -label "Add CN" -command "AddCNWindow" 
     $Editor::mnMenu add command -label "Import XDC/XDD" \
        -command {YetToImplement
		#set cursor [. cget -cursor]
		#Call the procedure
		#set types {
		#        {"XDC Files"     {.xdc } }
		#        {"XDD Files"     {.xdd } }
		#}
		#set tmpImpDir [tk_getOpenFile -title "Import XDC" -filetypes $types -parent .]
		#set node [$updatetree selection get]
		#if {$tmpImpDir!=""} {
			# pass node Id  and node type instead of 1 and cn
		#	Import $node $tmpImpDir mn 1
		#}
            }
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
     $Editor::obdMenu add command -label "Add Index" -command "YetToImplement"   
     $Editor::obdMenu add separator  

#############################################################################
# Menu for the index
#############################################################################
    set Editor::idxMenu [menu .idxMenu -tearoff 0]
     $Editor::idxMenu add separator
     $Editor::idxMenu add command -label "Add SubIndex" -command "YetToImplement"   
     $Editor::idxMenu add separator

    set Editor::prgindic -1
    set Editor::status ""
    set mainframe [MainFrame::create .mainframe \
            -menu $descmenu  \
            -textvariable Editor::status ]
            #-progressvar  Editor::prgindic \
            #-progressmax 100 \
            #-progresstype normal \
            #-progressfg blue ]
    $mainframe showstatusbar status


    #incr prgindic 
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
    #incr prgindic
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
    #puts [$tb1.bbox itemcget -image]
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
    #incr prgindic
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
    #incr prgindic
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

    #set f_tb1 [frame $tb1.f]
    #label $f_tb1.l_empty -text ""
    #set ra_dec [radiobutton $f_tb1.ra_dec -text "Dec" -variable hexDec -value on]
    #set ra_hex [radiobutton $f_tb1.ra_hex -text "Hex" -variable hexDec -value off]
    #pack $f_tb1 -side left -anchor w -expand 1 -padx 100
    #grid config $f_tb1.ra_dec -row 0 -column 1 -sticky "w" -padx 5
    #grid config $f_tb1.ra_hex -row 0 -column 2 -sticky "w" -padx 5
    #$f_tb1.ra_dec select

    incr prgindic
      
    $Editor::mainframe showtoolbar 0 $Editor::toolbar1

    #set temp [MainFrame::addindicator $mainframe -text "Current Startfile: " ]
    #set temp [MainFrame::addindicator $mainframe -textvariable Editor::current(project) ]
    #set temp [MainFrame::addindicator $mainframe -text " File: " ]
    #set temp [MainFrame::addindicator $mainframe -textvariable Editor::current(file) ]
    #set temp [MainFrame::addindicator $mainframe -textvariable EditorData(cursorPos)]
    #set temp [MainFrame::addindicator $mainframe -textvariable clock_var]
    set temp [MainFrame::addindicator $mainframe -textvariable Editor::connect_status ]
    $temp configure -relief flat 
    # NoteBook creation
    #incr prgindic
    set frame    [$mainframe getframe]
    
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
    $treeWindow bindText <Double-1> Editor::DoubleClickNode
    $treeWindow bindText <ButtonPress-3> {Editor::tselectright %X %Y}
    #$treeWindow:cmd bind "win" <KeyPress-Escape> "puts {Escape entered }"

    global EditorData
    global PjtDir
    set PjtDir $EditorData(options,History)

    NoteBook::compute_size $list_notebook
    $list_notebook configure -width 250
    #pack $pane -side left -expand yes
    #pack $list_notebook -side left -padx 2 -pady 4
    pack $list_notebook -side left -fill both -expand yes -padx 2 -pady 4

    # Commented out to remove Editor window    
    #    NoteBook::compute_size $notebook

    set cf0 [EditManager::create_conWindow $con_notebook "Console" 1]
    set cf1 [EditManager::create_conWindow $con_notebook "Error" 2]
    set cf2 [EditManager::create_conWindow $con_notebook "Warning" 3]

    NoteBook::compute_size $con_notebook
    pack $con_notebook -side bottom -fill both -expand yes -padx 4 -pady 4

 

    pack $pw1 -fill both -expand yes
    catch {font create TkFixedFont -family Courier -size -12 -weight bold}
    #
    # Create an image to be displayed in buttons embedded in a tablelist widget
    #
    set openImg [image create photo -file [file join ./images/open.gif]]

    #
    # Create a vertically scrolled tablelist widget with 5
    # dynamic-width columns and interactive sort capability
    #

    #set f0 [EditManager::create_table $notebook "Index" "ind"]

    #$f0 configure -height 4 -width 40 -stretch all

    #$f0 columnconfigure 0 -background #e0e8f0 
    #$f0 columnconfigure 1 -background #e0e8f0 


    #
    # Populate the tablelist widget for taking screen shots
    #

    #$f0 insert 0 [list Index: 1006 ""]
    #$f0 insert 1 [list Name: NMT_CycleLen_U32 ""]
    #$f0 insert 2 [list Object\ Type: VAR ""]
    #$f0 insert 3 [list Data\ Type: Unsigned32 ""]
    #$f0 insert 4 [list Access\ Type: rw ""]
    #$f0 insert 5 [list Value: 0007 ""]

    #$f0 cellconfigure 1,1 -editable yes -image [Bitmap::get pencil] 
    #$f0 cellconfigure 5,1 -editable yes -image [Bitmap::get pencil]


    #forcing the frist tab Tab to be disabled
    #Widget::configure $pane4 "-state disabled"

    #set f1 [EditManager::create_table $notebook "Sub Index" "ind"]


    #$f1 configure -height 4 -width 40 -stretch all
    #$f1 columnconfigure 0 -background #e0e8f0
    #$f1 columnconfigure 1 -background #e0e8f0
    
    #$f1 insert 0 [list Index: 1006]
    #$f1 insert 1 [list Sub\ Index: 00]
    #$f1 insert 2 [list Name: NMT_CycleLen_U32]
    #$f1 insert 3 [list Object\ Type: VAR]
    #$f1 insert 4 [list Data\ Type: Unsigned32]
    #$f1 insert 5 [list Access\ Type: rw]
    #$f1 insert 6 [list Value: 0007]

    #$f1 cellconfigure 2,1 -editable yes -image [Bitmap::get pencil]
    #$f1 cellconfigure 6,1 -editable yes -image [Bitmap::get pencil]

    set f0 [EditManager::create_tab $notebook "Index Test" ind ]
    set f1 [EditManager::create_tab $notebook "Sub index Test" sub ]

    set f2 [EditManager::create_table $notebook "PDO mapping" "pdo"]
    #$f2 configure -height 4 -width 40 -stretch all
    # the column No has onlly integer values som sorting based on integer
    $f2 columnconfigure 0 -background #e0e8f0 -width 6 -sortmode integer
    $f2 columnconfigure 1 -background #e0e8f0 -width 23
    $f2 columnconfigure 2 -background #e0e8f0 -width 11
    $f2 columnconfigure 3 -background #e0e8f0 -width 11
    $f2 columnconfigure 4 -background #e0e8f0 -width 11
    $f2 columnconfigure 5 -background #e0e8f0 -width 11
    $f2 columnconfigure 6 -background #e0e8f0 -width 11
	

#testing


#.mainframe.frame.pw1.f0.frame.pw2.f1.frame.nb.fPage4.sf.frame.tabTitlef1.f.en_value1 delete 0 10


####################

    NoteBook::compute_size $notebook
    $notebook configure -width 750
    pack $notebook -side left -fill both -expand yes -padx 4 -pady 4
    pack $pw2 -fill both -expand yes

    $list_notebook raise objtree
    $con_notebook raise Console1
    #$con_notebook _select Console1
    $notebook raise [lindex $f0 1]
    #$notebook _select [lindex $f0 1]


    pack $mainframe -fill both -expand yes

    #set prgindic -1
    set prgindic 0


    destroy .intro
    wm protocol . WM_DELETE_WINDOW Editor::exit_app
      	if {!$configError} {catch Editor::restoreWindowPositions}


    #errorPuts "testing Error.."
    #warnPuts "testing Warn.."
    #conPuts "testing console"
    update idletasks
    return 1
}



proc Editor::_create_intro { } {
    global tcl_platform
    global RootDir
    
    set top [toplevel .intro -relief raised -borderwidth 2]
    
    wm withdraw $top
    wm overrideredirect $top 1
    
    set image [image create photo -file [file join $RootDir Kalycito.gif]]
    set splashscreen  [label $top.x -image $image]
    set frame [frame $splashscreen.f -background white]
    set lab1  [label $frame.lab1 -text "Loading openMANAGER" -background white -font {times 8}]
    set lab2  [label $frame.lab2 -textvariable Editor::prgtext -background red -font {times 8} -width 35]
    set prg   [ProgressBar $frame.prg -width 50 -height 10 -background  black \
                   -variable Editor::prgindic -maximum 10]
    pack $lab1 $lab2 $prg
    place $frame -x 0 -y 0 -anchor nw
    pack $splashscreen
    BWidget::place $top 0 0 center
    wm deiconify $top
}
##################
# Many of the below Procs may not be needed.
##################

################################################################################
#
#  proc DoubleClickNode
#
#  To edit the testgroup name
################################################################################

proc Editor::DoubleClickNode {node} {
	global updatetree
	global f0
	global f1
	global f2
	#global tf0
	#global tf1
	global ra_dec
	global ra_hex
	global xdcFile
	variable notebook





	if {[string match "TPDO-*" $node] || [string match "RPDO-*" $node]} {
		#pack $ra_dec -side left -padx 5
		#pack $ra_hex -side left -padx 5
		set idx [$updatetree nodes $node]
		set popCount 0 
		foreach tempIdx $idx {
					#puts idx-->[$updatetree itemcget $tempIdx -text]
			set sidx [$updatetree nodes $tempIdx]
					#puts sidx-->$sidx

			foreach tempSidx $sidx { 
				puts tempSidx->$tempSidx						
				set tmpnode $tempSidx
				set tmpSplit [split $tmpnode -]
				set xdcId [lrange $tmpSplit 1 end]
				set xdcId [join $xdcId -]
				#puts xdcId-->$xdcId
				#puts xdcFile------------->$xdcFile($xdcId)
				set xdcIcxId [lrange $tmpSplit 1 [expr [llength $tmpSplit] - 2]]
				set xdcIcxId [join $xdcIcxId -]
		#puts xdcIcxId-->$xdcIcxId
		#puts xdcIndexFile------------->$xdcFile($xdcIcxId)
				set errorString []
				set NodeID 1
				set NodeType 1
		#Tcl_ImportXML "$xdcFile($xdcId)" $errorString $NodeType $NodeID
		#set TclObj [new_CNodeCollection]
		#set TclNodeObj [new_CNode]
		#set TclNodeObj [CNodeCollection_getNode $TclObj $NodeType $NodeID]
		#set TclIndexCollection [new_CIndexCollection]
		#set TclIndexCollection  [CNode_getIndexCollection $TclNodeObj]
				set indx [lindex $tmpSplit [expr [llength $tmpSplit] - 2]]
				set subId [lindex $tmpSplit end]
		#set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $indx]
				set indexValue [CBaseIndex_getIndexValue $xdcFile($xdcIcxId)]
		#set ObjSIdx [CIndex_getSubIndex $ObjIndex $subId]
		#set sIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
				set sIdxValue [CBaseIndex_getIndexValue $xdcFile($xdcId)]
				set IndexName [CBaseIndex_getName $xdcFile($xdcId)]
				set IndexObjType [CBaseIndex_getObjectType $xdcFile($xdcId)]
				set IndexDataType [CBaseIndex_getDataType $xdcFile($xdcId)]
				set IndexAccessType [CBaseIndex_getAccessType $xdcFile($xdcId)]
				set IndexDefaultValue [CBaseIndex_getDefaultValue $xdcFile($xdcId)]
				#puts indx-->$indx===subId-->$subId===popCount-->$popCount===IndexDefaultValue-->$IndexDefaultValue
				if {[string match "00" $sIdxValue]==0 } {
					catch {$f2 delete $popCount }
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
		puts node-->$node
		set tmpSplit [split $node -]
		set xdcId [lrange $tmpSplit 1 end]
		set xdcId [join $xdcId -]
		#puts xdcId-->$xdcId
		#puts xdcFile------------->$xdcFile($xdcId)
		set xdcIcxId [lrange $tmpSplit 1 [expr [llength $tmpSplit] - 2]]
		set xdcIcxId [join $xdcIcxId -]
		#puts xdcIcxId-->$xdcIcxId
		#puts xdcIndexFile------------->$xdcFile($xdcIcxId)
		set errorString []
		set NodeID 1
		set NodeType 1
		#Tcl_ImportXML "$xdcFile($xdcId)" $errorString $NodeType $NodeID
		#set TclObj [new_CNodeCollection]
		#set TclNodeObj [new_CNode]
		#set TclNodeObj [CNodeCollection_getNode $TclObj $NodeType $NodeID]
		#set TclIndexCollection [new_CIndexCollection]
		#set TclIndexCollection  [CNode_getIndexCollection $TclNodeObj]
		set indx [lindex $tmpSplit [expr [llength $tmpSplit] - 2]]
		set subId [lindex $tmpSplit end]
		#puts indx-->$indx===subId-->$subId
		#set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $indx]
		set indexValue [CBaseIndex_getIndexValue $xdcFile($xdcIcxId)]
		#set ObjSIdx [CIndex_getSubIndex $ObjIndex $subId]
		#set sIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
		set sIdxValue [CBaseIndex_getIndexValue $xdcFile($xdcId)]
		set IndexName [CBaseIndex_getName $xdcFile($xdcId)]
		set IndexObjType [CBaseIndex_getObjectType $xdcFile($xdcId)]
		#set IndexDataType [CBaseIndex_getDataType $xdcFile($xdcId)]
		#Monica code starts			
		set objIndexDataType [CBaseIndex_getDataType $xdcFile($xdcId)]
		set IndexDataType [DataType_getName $objIndexDataType]
		#Monice code ends
		set IndexAccessType [CBaseIndex_getAccessType $xdcFile($xdcId)]
		set IndexDefaultValue [CBaseIndex_getDefaultValue $xdcFile($xdcId)]
		#$f1 delete 0
		#$f1 insert 0 [list Index: $indexValue]
		$tmpInnerf0.en_idx1 configure -state normal
		$tmpInnerf0.en_idx1 delete 0 end
		$tmpInnerf0.en_idx1 insert 0 $indexValue
		$tmpInnerf0.en_idx1 configure -state disabled
		#$f1 delete 1
		#$f1 insert 1 [list Sub\ Index: $sIdxValue]
		$tmpInnerf0.en_sidx1 configure -state normal
		$tmpInnerf0.en_sidx1 delete 0 end
		$tmpInnerf0.en_sidx1 insert 0 $sIdxValue
		$tmpInnerf0.en_sidx1 configure -state disabled
		#$f1 delete 2
		#$f1 insert 2 [list Name: $IndexName]
		$tmpInnerf0.en_nam1 delete 0 end
		$tmpInnerf0.en_nam1 insert 0 $IndexName
		#$f1 delete 3
		#$f1 insert 3 [list Object\ Type: $IndexObjType]
		$tmpInnerf1.en_obj1 configure -state normal
		$tmpInnerf1.en_obj1 delete 0 end
		$tmpInnerf1.en_obj1 insert 0 $IndexObjType
		$tmpInnerf1.en_obj1 configure -state disabled
		#$f1 delete 4
		#$f1 insert 4 [list Data\ Type: $IndexDataType]
		$tmpInnerf1.en_data1 configure -state normal
		$tmpInnerf1.en_data1 delete 0 end
		$tmpInnerf1.en_data1 insert 0 $IndexDataType
		$tmpInnerf1.en_data1 configure -state disabled
		#$f1 delete 5
		#$f1 insert 5 [list Access\ Type: $IndexAccessType]
		$tmpInnerf1.en_access1 configure -state normal
		$tmpInnerf1.en_access1 delete 0 end
		$tmpInnerf1.en_access1 insert 0 $IndexAccessType
		$tmpInnerf1.en_access1 configure -state disabled
		#$f1 delete 6
		#$f1 insert 6 [list Value: $IndexDefaultValue]
		$tmpInnerf1.en_value1 delete 0 end
		$tmpInnerf1.en_value1 insert 0 $IndexDefaultValue
		#$f1 cellconfigure 2,1 -editable yes -image [Bitmap::get pencil]
		#$f1 cellconfigure 6,1 -editable yes -image [Bitmap::get pencil]
		$notebook itemconfigure Page2 -state normal
		$notebook raise Page2
		$notebook itemconfigure Page1 -state disabled
		$notebook itemconfigure Page3 -state disabled
	} elseif {[string match "*Index*" $node]} {
		set tmpInnerf0 [lindex $f0 2]
		set tmpInnerf1 [lindex $f0 3]
		#set tmpVar [$tmpf0Innerf0.en_nam1 cget -textvariable]
		#global $tmpVar
		#puts node-->$node
		set tmpSplit [split $node -]
		set xdcId [lrange $tmpSplit 1 end]
		set xdcId [join $xdcId -]
		#puts xdcId-->$xdcId
		#puts xdcFile------------->$xdcFile($xdcId)
		set errorString []
		set NodeID 1
		set NodeType 1
		#Tcl_ImportXML "$xdcFile($xdcId)" $errorString $NodeType $NodeID
		#set TclObj [new_CNodeCollection]
		#set TclNodeObj [new_CNode]
		#set TclNodeObj [CNodeCollection_getNode $TclObj $NodeType $NodeID]
		#set TclIndexCollection [new_CIndexCollection]
		#set TclIndexCollection  [CNode_getIndexCollection $TclNodeObj]
		#set tmpName [$updatetree itemcget $node -text]
		set indx [lindex $tmpSplit end]
		#puts indx----->$indx
		#set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $indx]
		#set indexValue [CBaseIndex_getIndexValue $ObjIndex]
		set indexValue [CBaseIndex_getIndexValue $xdcFile($xdcId)]
		#puts indexValue:$indexValue
		#puts [CBaseIndex_getIndexValue $ObjIndex]
		set IndexName [CBaseIndex_getName $xdcFile($xdcId)]
		#puts IndexName:$IndexName
		set IndexObjType [CBaseIndex_getObjectType $xdcFile($xdcId)]
		#puts IndexObjType:$IndexObjType
		#set IndexDataType [CBaseIndex_getDataType $xdcFile($xdcId)]
		#Monica code starts			
		set objIndexDataType [CBaseIndex_getDataType $xdcFile($xdcId)]
		#puts objIndexDataType:$objIndexDataType
		set IndexDataType [DataType_getName $objIndexDataType]
		#Monice code ends
		
		set IndexAccessType [CBaseIndex_getAccessType $xdcFile($xdcId)]
		#Check for hex data. If not hex, make it null.
		set IndexAccessType [string trimleft $IndexAccessType 0x]
		set IndexAccessType [string trimleft $IndexAccessType 0X]
		#puts IndexAccessType:$IndexAccessType
		if {![string is ascii $IndexAccessType]} {
		
			puts ErrorStr:$IndexAccessType
			set IndexAccessType []
		
		}

	
		set IndexDefaultValue [CBaseIndex_getDefaultValue $xdcFile($xdcId)]
		#Check for hex data. If not hex, make it null.
		set IndexDefaultValue [string trimleft $IndexDefaultValue 0x]
		set IndexDefaultValue [string trimleft $IndexDefaultValue 0X]
		if {![string is xdigit $IndexDefaultValue]} {
		
			puts ErrorStr:$IndexDefaultValue
			set IndexDefaultValue []
		
		}
		
		#$f0 delete 0
		#$f0 insert 0 [list Index: $indexValue]
		$tmpInnerf0.en_idx1 configure -state normal
		$tmpInnerf0.en_idx1 delete 0 end
		$tmpInnerf0.en_idx1 insert 0 $indexValue
		$tmpInnerf0.en_idx1 configure -state disabled
		#$f0 delete 1
		#$f0 insert 1 [list Name: $IndexName]
		#puts $tmpVar
		$tmpInnerf0.en_nam1 delete 0 end
		$tmpInnerf0.en_nam1 insert 0 $IndexName
		#set $tmpVar $IndexName
		#$f0 delete 2
		#$f0 insert 2 [list Object\ Type: $IndexObjType]
		$tmpInnerf1.en_obj1 configure -state normal
		$tmpInnerf1.en_obj1 delete 0 end
		$tmpInnerf1.en_obj1 insert 0 $IndexObjType
		$tmpInnerf1.en_obj1 configure -state disabled
		#$f0 delete 3
		#$f0 insert 3 [list Data\ Type: $IndexDataType]
		$tmpInnerf1.en_data1 configure -state normal
		$tmpInnerf1.en_data1 delete 0 end
		$tmpInnerf1.en_data1 insert 0 $IndexDataType
		$tmpInnerf1.en_data1 configure -state disabled
		#$f0 delete 4
		#$f0 insert 4 [list Access\ Type: $IndexAccessType]
		$tmpInnerf1.en_access1 configure -state normal
		$tmpInnerf1.en_access1 delete 0 end
		$tmpInnerf1.en_access1 insert 0 $IndexAccessType
		$tmpInnerf1.en_access1 configure -state disabled
		#$f0 delete 5
		#$f0 insert 5 [list Value: $IndexDefaultValue]
		$tmpInnerf1.en_value1 delete 0 end
		$tmpInnerf1.en_value1 insert 0 $IndexDefaultValue

		#$f0 cellconfigure 1,1 -editable yes -image [Bitmap::get pencil]
		#$f0 cellconfigure 5,1 -editable yes -image [Bitmap::get pencil]
		$notebook itemconfigure Page1 -state normal
		$notebook raise Page1
		$notebook itemconfigure Page2 -state disabled
		$notebook itemconfigure Page3 -state disabled
		#$f0 insert 0,1 $tmpName
	} else {
		#pack forget $ra_dec
		#pack forget $ra_hex
		$notebook itemconfigure Page1 -state disabled
		$notebook itemconfigure Page2 -state disabled
		$notebook itemconfigure Page3 -state disabled
	}
	return
}



proc AddCN {cnName tmpImpDir nodeId} {
	global updatetree
	global cnCount
	global mnCount
	incr cnCount
	#puts "node value CN-1-$cnCount $nodeId"
	#set child [$updatetree insert $cnCount MN-1 CN-1-$cnCount -text "$cnName" -open 1 -image [Bitmap::get cn]]
	set child [$updatetree insert end MN-1 CN-1-$cnCount -text "$cnName" -open 1 -image [Bitmap::get cn]]
	if {$tmpImpDir!=0} {
		puts $tmpImpDir
		#set NodeID 1
		#set NodeType 1
		#Tcl_CreateNode $NodeID $NodeType
		Import CN-1-$cnCount $tmpImpDir cn $nodeId
	}
	return
}


###############################################################################


proc YetToImplement {} {
	tk_messageBox -message "Yet to be Implemented !" -title Info -icon info
}


#########################################################################3



proc Editor::TogConnect {} {
	variable bb_connect
	set tog [$bb_connect cget -image]
	#puts $tog
	#to toggle image the value varies according to images added 
	if {$tog=="image15"} {
		Editor::Connect	       
		# .mainframe.topf.tb0.bbox8.b0 configure -image [Bitmap::get connect]
	} else {
		Editor::Disconnect
	        #.mainframe.topf.tb0.bbox8.b0 configure -image [Bitmap::get disconnect]
	}
}
proc Editor::Connect {} {
	variable bb_connect
        variable mainframe
        #variable 
	#puts $mainframe
	$bb_connect configure -image [Bitmap::get disconnect]
	$mainframe setmenustate connect disabled
	$mainframe setmenustate disconnect normal
	set Editor::connect_status "Connected to IP :"
	YetToImplement
}

proc Editor::Disconnect {} {
	variable bb_connect
        variable mainframe
	#puts $mainframe
	$bb_connect configure -image [Bitmap::get connect]
	$mainframe setmenustate disconnect disabled
	$mainframe setmenustate connect normal
	set Editor::connect_status "Disconnected from IP :"
	YetToImplement
}

###########################################################################							
# Proc Name:	InsertTree						
# Inputs:	 
# Outputs:	
# Description:	Based on the Global Data draw the treeview. 
#
###########################################################################
proc InsertTree { } {
	global updatetree
	global cnCount
	global mnCount
	incr cnCount
	incr mnCount
	$updatetree insert end root PjtName -text "POWERLINK Network" -open 1 -image [Bitmap::get network]
}
#############################################################
namespace eval FindSpace {
	variable findList
	variable searchCount
	variable txtFindDym
}

proc FindDynWindow {} {
	#puts "FindDynWindow invoked"
	catch {
		global treeFrame
		#global updatetree
		pack $treeFrame -side bottom -pady 5
		set FindSpace::txtFindDym ""
		#$updatetree selection clear
		#$treeFrame.en_find configure -text ""
	}
	#$treeFrame.en_find configure -background gray
}

proc EscapeTree {} {
	catch {
		global treeFrame
		pack forget $treeFrame
	}
}


proc FindSpace::Find { searchStr } {
	global updatetree
	#set searchStr 1006
	#puts searchStr-->$searchStr
	set FindSpace::findList ""
	set FindSpace::searchCount 0
	if {$searchStr==""} {
		$updatetree selection clear
		return 1
	}
	set mnNode [$updatetree nodes PjtName]
	foreach tempMn $mnNode {
		set childMn [$updatetree nodes $tempMn]
		#puts $childMn
			foreach tempChildMn $childMn {
				set idx [$updatetree nodes $tempChildMn]
				foreach tempIdx $idx {
					#puts idx-->[$updatetree itemcget $tempIdx -text]
					if {[string match "*$searchStr*" [$updatetree itemcget $tempIdx -text]]} {
						#puts tempMn->$tempMn:tempChildMn->$tempChildMn:tempIdx->$tempIdx
						#puts [$updatetree itemcget $tempIdx -text]
						lappend FindSpace::findList $tempIdx
					}
					set sidx [$updatetree nodes $tempIdx]
					#puts sidx-->$sidx
					#puts [string length $sidx]
					foreach tempSidx $sidx { 
						#puts "subindex entered"
						if {[string match "*$searchStr*" [$updatetree itemcget $tempSidx -text]]} {
							#puts [$updatetree itemcget $tempSidx -text]
							#puts $tempSidx
							lappend findList $tempSidx
						}
					}
				}
			}
	}
	#puts FindSpace::findList->$FindSpace::findList
	#return $FindSpace::findList
	$updatetree selection clear
	if {[llength $FindSpace::findList]!=0} {
		catch { $updatetree selection set [lindex $FindSpace::findList 0] 
			$updatetree see [lindex $FindSpace::findList 0]}
	}
	return 1
 
}

proc FindSpace::Prev {} {
	global updatetree
	if {[llength $FindSpace::findList]==0} {
		#tk_messageBox -message "search string $searchEntry not found" -icon info -parent .find
		return
	} else {
		if {$FindSpace::searchCount <= [expr [llength $FindSpace::findList] - 1] && $FindSpace::searchCount > 0} {
			incr FindSpace::searchCount -1
			$updatetree selection set [lindex $FindSpace::findList $FindSpace::searchCount]
			$updatetree see [lindex $FindSpace::findList $FindSpace::searchCount]
		} else {
			#tk_messageBox -message "$searchEntry not found" -icon info -parent .find		
		}
	}
	return
}

proc FindSpace::Next {} {
	global updatetree
	if {[llength $FindSpace::findList]==0} {
		#tk_messageBox -message "search string $searchEntry not found" -icon info -parent .find
		return
	} else {
		if {$FindSpace::searchCount < [expr [llength $FindSpace::findList] - 1] } {
			incr FindSpace::searchCount 1
			$updatetree selection set [lindex $FindSpace::findList $FindSpace::searchCount]
			$updatetree see [lindex $FindSpace::findList $FindSpace::searchCount]
		} else {
			#tk_messageBox -message "$searchEntry not found" -icon info -parent .find		
		}
	}
	return
}

##################################################################

proc TransferCDC {} {

	set types {
        {"All Project Files"     {*.cdc } }
	}
	########### Before Closing Write the Data to the file ##########

	#set file [tk_getSaveFile -filetypes $filePatternList -initialdir $EditorData(opti	ons,workingDir) \
    #        -initialfile $filename -defaultextension $defaultExt -title "Save File"]


	# Validate filename
	set fileLocation_CDC [tk_getSaveFile -filetypes $types -title "Transfer CDC"]
        if {$fileLocation_CDC == ""} {
                return
        }
	puts fileLocation_CDC:$fileLocation_CDC
	Tcl_TransferCDC $fileLocation_CDC
}

proc BuildProject {} {
	conPuts "generating CDC"
	conPuts "generating XML"
	#Tcl_GenerateCDC
}

