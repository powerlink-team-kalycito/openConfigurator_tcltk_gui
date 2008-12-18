################################################################################
#									
# Script:	main.tcl						
#									
# Author:	Kalycito Infotech Pvt Ltd		
#									
# Description:	Contains the procedures for TestSuite and forms the backbone for
# TestSuite.
#
# Version:	Version - 1.0.
#
################################################################################

source $RootDir/record.tcl
source $RootDir/xmlread.tcl
source $RootDir/ReadResultXml.tcl

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

################################################################################
#proc delete_id
#called when a editorwindow is closed to delete the correspondend undo_id
################################################################################
proc delete_id {} {
    global undo_id
    delete textUndoer $Editor::current(undo_id)
    return
}

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
    variable caseMenu
    variable textMenu
    variable profileMenu
    variable helpmsgMenu
    variable groupconfic
    variable serverUp 0
}

proc Editor::tick {} {
    global clock_var
    variable mainframe
    variable startTime
    set seconds [expr [clock seconds]  - $startTime]
    set clock_var [clock format $seconds -format %H:%M:%S -gmt 1]
    after 1000 Editor::tick
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
    label $aboutWindow.l_msg -image [Bitmap::get info] -compound left -text "\n   Host Target Interactive TestSuite-2.0\n     (Based On DejaGNU & TCL/Tk)   \n           Designed by       \nKalycito Infotech Private Limited.  \n   For use by Sagem Communications   \n" 
    button $aboutWindow.bt_ok -text Ok -command "destroy $aboutWindow"
    grid config $aboutWindow.l_msg -row 0 -column 0 
    grid config $aboutWindow.bt_ok -row 1 -column 0
    bind $aboutWindow <KeyPress-Return> "destroy $aboutWindow"
    focus $aboutWindow.bt_ok
    centerW .about
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
#called when STB_TSUITE exits
#saves only "EditorData(options,...)"
#but might be easily enhanced with other options
################################################################################
proc Editor::saveOptions {} {
    global EditorData
    global RootDir
    
    Editor::getWindowPositions
    
    set configData "#STB_TSUITE Configuration File\n\n"
    set configFile [file join $RootDir/STB_TSUITE.cfg]
    set optionlist [array names EditorData]
    foreach option $optionlist {
        set optiontext EditorData($option)
        if {![string match "*(options*" $optiontext]} {
            continue
        }
        set value \"[subst \$[subst {$optiontext}]]\"
        append configData "set EditorData($option) $value\n"
        
    }
    set result [Editor::_saveFile $configFile $configData]
}

proc Editor::CreateFonts {} {
    global EditorData
    
    variable configError
    variable Font_var
    variable FontSize_var
    
    # set editor font
    if {$configError} {
        
        set font [list -family Courier -size 10 -weight normal -slant roman -underline 0 -overstrike 0]
        
        set EditorData(options,fonts,editorFont) $font
    }
    eval font create editorFont $EditorData(options,fonts,editorFont)
    # set comment font
    if {$configError} {
        
        set font [list -family Courier -size 10 -weight normal -slant italic -underline 0 -overstrike 0]
        
        set EditorData(options,fonts,commentFont) $font
    }
    eval font create commentFont $EditorData(options,fonts,commentFont)
    
    # set keyword font
    if {$configError} {
        
        set font [list -family Courier -size 10 -weight bold -slant roman -underline 0 -overstrike 0]
        set EditorData(options,fonts,keywordFont) $font
    }
    eval font create keywordFont $EditorData(options,fonts,keywordFont)
    set Font_var [font configure editorFont -family]
    return
}

proc Editor::setDefault {} {
    global tcl_platform
    global EditorData
    global RootDir
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
    set fd [open [file join $RootDir keywords.txt ] r]
    set keyList ""
    while {![eof $fd]} {
        gets $fd word
        lappend keyList $word
    }
    close $fd
    set EditorData(keywords) $keyList
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
        set EditorData(options,showToolbar2) $toolbar2
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
        set toolbar2 $EditorData(options,showToolbar2)
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
    Editor::CreateFonts
    return
}

proc Editor::changeServerPort {} {
    global EditorData
    
    set dialog [toplevel .top ]
    label $dialog.l -text "Enter Port Number"
    set port $EditorData(options,serverPort)
    set portEntry [entry $dialog.e -width 5 -textvar EditorData(options,serverPort)]
    set EditorData(oldPort) $EditorData(options,serverPort)
    set f [frame $dialog.f]
    button $dialog.f.ok -text Ok -width 8 -command {
        destroy .top
    }
    button $dialog.f.c -text Cancel -width 8 -command {
        global EditorData
        destroy .top
        set EditorData(options,serverPort) $EditorData(oldPort)
    }
    pack $dialog.l $portEntry -fill both -expand yes
    pack $dialog.f.ok -side left -fill both -expand yes 
    pack $dialog.f.c -side left -fill both -expand yes
    pack $f
    focus $portEntry
    bind $portEntry <KeyRelease-Return> {
        destroy .top
        break
    }
    wm title $dialog "Enter Port"
    BWidget::place $dialog 0 0 center
}

proc Editor::newFile {{force 0}} {
    variable notebook
    variable current
    global EditorData
	global pageopened_list
    global PjtDir
    if { $PjtDir == "" || $PjtDir == "None" } {
	conPuts "No Project selected" error
	return
    }
    set pages [NoteBook::pages $notebook]
    if {([llength $pages] > 0) && ($force == 0)} {
        if {[info exists current(text)]} {
            set f0 [NoteBook::raise $notebook]
            set text [NoteBook::itemcget $notebook $f0 -text]
            set data [$current(text) get 1.0 end-1c]
            if {($data == "") && ($text == "Untitled")} {return}
        }
    }
    set temp $current(hasChanged)
    set f0 [EditManager::create_text $notebook Untitled]
	# Append Untitiled to the Pageopened List
    set Editor::text_win($Editor::index_counter,undo_id) [new textUndoer [lindex $f0 2]]
    set current(hasChanged) $temp
    NoteBook::raise $notebook [lindex $f0 1]
    set current(hasChanged) 0
    set current(writable) 1
    $Editor::mainframe setmenustate noFile normal
    updateObjects
	lappend pageopened_list Untitled
}


proc Editor::scanLine {} {
    variable current
    
    # is current line a proc-line?
    set result [$current(text) search "proc " "insert linestart" "insert lineend"]
    if {$result == ""} {
        # this is not a proc-line
        # was it a proc-line?
        if {$current(is_procline)} {
            set current(is_procline) 0
            set current(procSelectionChanged) 1
        } else {
            set current(is_procline) 0
            set current(procSelectionChanged) 0
        }
    } else  {
        # is current line really a proc-line?
        set line [$current(text) get "$result linestart" "$result lineend"]
        set temp [string trim $line \ \t\;]
        set proc ""
        set procName ""
        # is it really a proc-line?
        if {[scan $temp %\[proc\]%s proc procName] != 2} {
            set result ""
        } elseif {$proc != "proc"} {
            set result ""
        }
        if {$result != ""} {
            if {$current(procName) != $procName} {
                set current(procName) $procName
                set current(procSelectionChanged) 1
                set current(is_procline) 1
            } else  {
                set current(procSelectionChanged) 0
            }
        } else  {
            if {$current(is_procline)} {
                set current(is_procline) 0
                set current(procSelectionChanged) 1
            } else {
                set current(is_procline) 0
                set current(procSelectionChanged) 0
            }
        }
    }
    return $result
}

proc Editor::updateOnIdle {range} {
    variable current
    # if there?s a pending update only store new range
    if {$current(isUpdate)} {
        if {[$current(text) compare $current(updateStart) > [lindex $range 0]]} {
            set current(updateStart) [$current(text) index [lindex $range 0]]
        }
        if {[$current(text) compare $current(updateEnd) < [lindex $range 1]]} {
            set current(updateEnd) [$current(text) index [lindex $range 1]]
        }
    } else  {
        set current(isUpdate) 1
        set current(updateStart) [$current(text) index [lindex $range 0]]
        set current(updateEnd) [$current(text) index [lindex $range 1]]
        after idle {
            # wait for a longer idle period
            for {set i 0} {$i <= 10000} {incr i} {
                update
                set Editor::current(idleID) [after idle {
                    update
                    after idle {set Editor::current(idleID) ""}
                }]
                vwait Editor::current(idleID)
                if {$i == 100} {
                    set range [editorWindows::deleteMarks $Editor::current(updateStart) $Editor::current(updateEnd) ]
                    Editor::updateObjects $range
                    Editor::selectObject 0
                    set Editor::current(isUpdate) 0
                    break
                }
            }
        }
    }
}


################################################################################
#
#  proc Editor::updateObjects
#
#  reparse the complete file and rebuild object tree
################################################################################

proc Editor::updateObjects {{range {}}} {
    global EditorData
    variable current
    variable treeWindow
    
    if {!$EditorData(options,autoUpdate) || !$EditorData(options,showProcs)} {
        return
    }
    while {[llength $range] == 1} {
        eval set range $range
    }
    
    if {$range == {}} {
        # switch on progressbar
        set Editor::prgindic -1
        set current(checkRootNode) 0
        set start 1.0
        set end "end-1c"
        catch {
            editorWindows::deleteMarks "1.0" "end -1c"
        }
        Editor::tdelNode $current(file)
    } else  {
        set current(checkRootNode) 1
    }
    set code {
        set temp [expr int($nend / $end * 100)]
        if {!$recursion && $temp > $Editor::prgindic && [expr $temp % 10] == 0 } {
            set Editor::prgindic [expr int($nend / $end * 100)]
            set Editor::status "Parsing: $Editor::prgindic % "
            update idletasks
        }
    }
    
    # call parser
    set nodeList [Parser::parseCode $current(file) $current(text) $range $code]  
    # switch off progressbar
    set Editor::prgindic 0
    set Editor::status ""
        foreach node $nodeList {
        catch {Editor::tnewNode $node}
    }
    update
    if {$Editor::options(sortProcs)} {catch {Editor::torder $current(file)}}
}

################################################################################
#
#  proc Editor::selectObject
#
#  selects an object by a given position in the text
#
################################################################################

proc Editor::selectObject {{update 1} {Idx insert}} {
    global EditorData
    variable current
    variable treeWindow
    variable procMarks

    if {!$EditorData(options,showProcs) || !$EditorData(options,showProc)} {
        set current(node) ""
        return ""
    }
    if {$update != 0} {
        set rexp {^(( |\t|\;)*((namespace )|(class )|(proc )|(body )|(configbody )))|((( |\t|\;)*[^\#]*)((method )|(constructor )|(destructor )))}
        if {[regexp $rexp [$current(text) get "$Idx linestart" "$Idx lineend"]]} {
            set start [$current(text) index "$Idx"]
            set end [$current(text) index "$Idx"]
            set range [editorWindows::deleteMarks $start $end]
            updateObjects $range
            set current(isNode) 1
        } else  {
            set current(isNode) 0
        }
    }
    set index [$current(text) index $Idx]
    # marknames equal nodenames
    set node $Idx
    set markList [array names procMarks]
    #get the right mark
    while {[lsearch $markList $node] == -1 || $procMarks($node) == "dummy"} {
        set index [$current(text) index $node]
        set result -1
        foreach { type node idx} [$current(text) dump -mark $index] {
            set result [lsearch $markList $node]
            if {$result != -1} {
                if {$procMarks([lindex $markList $result]) != "dummy"} {
                    break
                } else  {
                    set result -1
                }
            }
        }
        if {$result == -1 && $index != 1.0} {
            set node [$current(text) mark previous $index]
            if {$node == ""} {
                break
            }
        } elseif {$result == -1} {
            set node ""
            break
        }
    }
    if {$node == ""} {
        $treeWindow selection clear
        set current(node) $node
        return $node
    }
    #if it is an end_of_proc mark skip this proc
    if {[string match "*_end_of_proc" $node]} {
        set count -2
        while {$count != 0} {
            set node [$current(text) index $node]
            set node [$current(text) mark previous "$node -1c"]
            if {$node == ""} {
                break
            }
            while {[lsearch $markList $node] == -1 || $procMarks($node) == "dummy"} {
                set index [$current(text) index $node]
                foreach { type node idx} [$current(text) dump -mark $index] {
                    set result [lsearch $markList $node]
                    if {$result != -1} {
                        if {$procMarks($node) != "dummy"} {
                            break
                        } else  {
                            set result -1
                        }
                    }
                }
                if {$result == -1 && $index != 1.0} {
                    set node [$current(text) mark previous $index]
                    if {$node == ""} {
                        break
                    }
                } elseif {$result == -1}  {
                    set node ""
                    break
                }
            }
            if {$node == ""} {
                break
            }
            if {[string match "*_end_of_proc" $node]} {
                incr count -1
            } else {
                incr count
            }
        }
    }
    $treeWindow selection clear
    if {$node != ""} {
        $treeWindow selection set $node
        $treeWindow see $node
    }
    set current(node) $node
    return $node
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
    regsub -all "\\\$" $node "?" node
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
    regsub -all "\\\$" $node "?" node
    # mask instance number
    regsub "\367.+\376$" $node "" node
    
    if {[string index $node [expr [string length $node] -1]] == "#"} {
        append node "{}"
    }
    #check current namespace in normal editing mode
    if {$current(checkRootNode) != 0} {
        # if node doesn't present a qualified name,
        # which presents it's rootnode by itself (e.g. test::test)
        # try to set it?s rootnode
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
    
    # get rid of the ? in the node
    regsub -all \306 $name " " name
    regsub \327 $name ":" name
    regsub -all "?" $name "\$" name
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
    regsub -all "\\\$" $node "?" node
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
    regsub -all "\\\$" $node "?" node
    $treeWindow closetree $node
}
################################################################################
#
#  proc nodetoname
#  convert the name to the node
#  inputs - node
#  return - filename
################################################################################
proc nodetoname {node} {
	global PjtDir
	set tmpsplit [split $node "-"]
	set extsplit [split $node .]
	set exten [lindex $extsplit [expr [llength $extsplit] - 1 ]]
	set nodecount [lindex $tmpsplit [expr [llength $tmpsplit] - 1]]
	set groupcount [lindex $tmpsplit [expr [llength $tmpsplit] - 2]] 
	set selectname [lindex $tmpsplit [expr [llength $tmpsplit] - 3]]
	if { $selectname ==  "path" } {
		set filename [arrTestCase($groupcount)($nodecount) cget -memCasePath]	
		set filename [getAbsolutePath $filename $PjtDir]
		return $filename
	} elseif { $selectname ==  "header" } {
		set filename [arrTestCase($groupcount)($nodecount) cget -memHeaderPath]
		set filename [getAbsolutePath $filename $PjtDir]
		return $filename
	} 
	if { $node ==  "myboard_sshscp.exp" || $node == "makefile"  } {
		set filename $node			
		return "$PjtDir/$filename"
	} elseif { $node ==  "Logfile" } { 
		set filename "logs/DebugInfo"
		if {![file exists "$PjtDir/$filename"]} {
			 tk_messageBox -message "Please run the test to get DebugInfo !" -title Info -icon info		
		}		
		return "PjtDir/$filename"
	} elseif {  $node == "Outputxml" } {
		# Convert the cdata_xml to Testrun.XML file
		set filename "logs/Test_Result.xml"
		if {![file exists "$PjtDir/$filename"]} {
			 tk_messageBox -message "Please run the test to get Test_Result.xml !" -title Info -icon info		
		}				
		return "PjtDir/$filename"
	} elseif { $node == "CSV"} {
		# Convert the cdata_xml to Testrun.XML file
		# convert the Testrun.XML to csv file
		set filename "logs/Test_Result.csv"
		if {![file exists "$PjtDir/$filename"]} {
			 tk_messageBox -message "Please run the test to get Test_Result.csv !" -title Info -icon info
		}				
		return "PjtDir/$filename"
	} elseif { $exten == "c" || $exten == "h" || $exten == "C" || $exten == "H"} {
		return "toolbox"
	} else {
		return "return_fail"
	}
}



################################################################################
#
#  proc Editor::tselectObject
#
#  selects the objects choosen from the tree
################################################################################

################################################################################
proc Editor::tselectObject {node} {
    
   	variable current
   	variable treeWindow
   	variable notebook
   	global PjtDir
	##global updatetree
    	# Call the procedure to get the filename from the node
	set convertfile [nodetoname $node]	
	if { $convertfile != "return_fail" } {
		set filename $convertfile
		if {$convertfile != "toolbox"} {
	 		set result [Editor::openFile $filename]
			puts $filename
		} else {
			set toolDir [getAbsolutePath [instProject cget -memTollbox_path] $PjtDir]
			set result [Editor::openFile "$toolDir/$node"]
		}
		$treeWindow selection clear
		$treeWindow selection set $node
	 	#Switch to the right notebook
        	set node $node
		##puts Nodeselect:$node
		##puts FileName:$filename
		if {$convertfile != "toolbox"} {
	 		set filename "$PjtDir/$filename"
		} else {
			set filename $node
		}
		
		#get rid of the ? (as a substitude for a space) in the filename
		regsub -all \306 $filename " " filename
		set pagelist [array names ::Editor::text_win]
		set found 0
		set pagename ""
		##puts filename2->$filename
		foreach nbPage $pagelist {
        		if {$Editor::text_win($nbPage) == $filename} {		
        			set i [lindex [split $nbPage ,] 0]
        			set pagename $::Editor::text_win($i,pagename)
				set found 1
				##puts pagenamefound_
				break
       			} 
    		}
	##puts notebook->$notebook
	##puts pagename->$pagename
    	catch {$notebook raise $pagename}

    	if {[catch {$current(text) mark set insert $node}]} {
      		return
   	 }
	##puts toFocus...........
    	$current(text) see insert
    	focus $current(text)

    	editorWindows::flashLine
    	Editor::selectObject 0
    	editorWindows::ReadCursor
    	Editor::procList_history_add
    	set current(lastPos) [$current(text) index insert]
    		return
	} else {
		return
	}
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
	if [regexp {TestGroup-(.*)} $node == 1] {
		tk_popup $Editor::groupMenu $x $y	
	} elseif {[regexp {path-(.*)} $node == 1]} { 
		Editor::tselectObject $node
		tk_popup $Editor::caseMenu $x $y		
	} elseif {[regexp {OBD(.*)} $node == 1]} { 
		tk_popup $Editor::projectMenu $x $y		
	}  elseif {[regexp {Config-(.*)} $node == 1]} { 
		tk_popup $Editor::groupconfic $x $y	
	} elseif {[regexp {profile-(.*)} $node == 1]} { 
		tk_popup $Editor::profileMenu $x $y
	} elseif {[regexp {helpMsg-(.*)} $node == 1]} { 
		tk_popup $Editor::helpmsgMenu $x $y
	} else {
		return 
	}   
}
################################################################################
#
#  proc selectobject
#
#  Single Click select the object on the tree
################################################################################
proc selectobject {node} {
    
   	global updatetree
    	
	$updatetree selection clear
	$updatetree selection set $node

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
    regsub -all "\\\$" $node "?" node
    
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
#proc Editor::evalMain
#will be called from within a slave-interpreter to do something within the main-interpreter
################################################################################
proc Editor::evalMain {args} {
    
    uplevel #0 eval $args
}

proc Editor::setTestTermBinding {sock terminal} {
    variable current
    set current(sock) $sock
    bind $terminal <KeyPress-Return> {%W mark set insert "prompt lineend"}
    bind $terminal <KeyRelease-Return> {
        set command [getCommand %W]
        #%W tag configure output -foreground blue
        interp eval $Editor::current(slave) set command [list $command]
        interp eval $Editor::current(slave) {
            eval puts $sock [list $command]
        }
        break
    }
    
}

proc Editor::deleteTestTerminal {pagename} {
    variable con_notebook
    
    $con_notebook delete $pagename
    $con_notebook raise Console
}

################################################################################
#proc Editor::execFile
#runs current editor-data without saving to file,
#or associated or default projectfile with data of the current window
################################################################################
proc Editor::execFile {} {
    global tk_library
    global tcl_library
    global tcl_platform
    global auto_path
    global conWindow
    global code
    global EditorData
    variable current
    
        
    Editor::argument_history_add
    #aleady running ?
    if {[interp exists $current(slave)]} {
        switch -- [tk_messageBox -message "$current(file) is already running!\nRestart ?" -type yesnocancel -icon question -title "Question"] {
            yes {
                Editor::exitSlave $current(slave)
                set tempFile [concat "$current(file)" "~~"]
                if {[Editor::file_copy $tempFile $current(file)] == 0} {
                    file delete $tempFile
                }
                after idle Editor::execFile
                return
            }
            no {}
            cancel {}
        }
        return
    }
    set cursor [. cget -cursor]
    . configure -cursor watch
    
    set hasChanged $current(hasChanged)
    if {$current(file) != "Untitled" && $current(writable)} {
        if {[file_copy $current(file) [concat "$current(file)" "~~"]]} {
            Editor::saveFile
            file_copy $current(file) [concat "$current(file)" "~~"]
        } else  {
            Editor::saveFile
        }
    }
    
    update
    set current(slave) [interp create]
    set Editor::slaves($current(slave)) $Editor::current(pagename)
    interp eval $current(slave) set page $current(pagename)
    $current(slave) alias _exitSlave Editor::exitSlave
    if {"$tcl_platform(platform)" == "windows"} {
        $current(slave) alias consolePuts consolePuts
        interp eval $current(slave) {
            rename puts Puts
            proc puts {args} {
                switch -- [llength $args] {
                    0 {return}
                    1 {eval consolePuts $args}
                    2 {if {[lindex $args 0] == "-nonewline"} {
                            eval consolePuts $args
                        } else  {
                            eval Puts $args
                        }}
                    default {eval Puts $args}
                }
            }
        }
    }
    $current(slave) alias evalMain Editor::evalMain
    if {($current(project) == "none") || ($current(file) == "Untitled" || $current(file) == $current(project))} {
        set current(data) [$current(text) get 1.0 end-1c]
        interp eval $current(slave) set data [list $current(data)]
    } else  {
        if {[file exists $current(project)]} {
            set fd [open $current(project) r]
            interp eval $current(slave) set data [list [read $fd]]
            close $fd
        } else  {
            tk_messageBox -message "ProjectFile <$current(project)> not found !" -title Error -icon error
            after idle Editor::exitSlave $current(slave)
            return
        }
    }
    # ToDo:
    # setup for interpreter environment via dialog
    interp eval $current(slave) set slave $current(slave)
    interp eval $current(slave) set conWindow $conWindow
    interp eval $current(slave) set argv [list $Editor::argument_var]
    interp eval $current(slave) set argc [llength [list $Editor::argument_var]]
    interp eval $current(slave) set argv0 [list $current(file)]
    interp eval $current(slave) set tcl_library [list $tcl_library]
    interp eval $current(slave) set tk_library [list $tk_library]
    interp eval $current(slave) set auto_path [list $auto_path]
    interp eval $current(slave) {
        proc _exitProc {{exitcode 0}} {
            global slave
            catch {_exitSlave $slave}
        }
        load {} Tk
        interp alias {} exit {} _exitProc
        wm protocol . WM_DELETE_WINDOW {_exitProc}
        set code [catch {eval $data} info]
        catch {
            if {$code} {
                tk_messageBox -message $errorInfo -title Error -icon error
                after idle _exitProc
            }
        }
    }
    if {$current(file) != "Untitled"} {
        set tempFile [concat "$current(file)" "~~"]
        if {![Editor::file_copy $tempFile $current(file)]} {
            file delete $tempFile
        }
    }
    set current(hasChanged) $hasChanged
    if {$current(hasChanged)} {
        $Editor::notebook itemconfigure $current(pagename) -image [Bitmap::get redball]
    }
    update idletasks
    . configure -cursor $cursor
    catch {
        interp eval $current(slave) {
            if {[wm title .] != ""} {
                wm title . "STB_TSUITE is running: >>[wm title .]<<"
            } else  {
                if {$current(project) != "none" && $current(project) != $current(file)} {
                    wm title . "STB_TSUITE is running \"$current(project)\" testing >>$current(file)<<"
                } else  {
                    wm title . "STB_TSUITE is running: >>$current(file)<<"
                }
            }
        }
    }
    
}

proc Editor::chooseWish {} {
    global tcl_platform
    global EditorData
    global RootDir
    variable serverUp
    
    if {$serverUp} {
        switch [tk_messageBox \
                -message "Restart Server ?\nThis will shutdown currently running applications!" \
                -icon warning \
                -title "Restart Server ?" \
                -type yesnocancel] {
                    yes {
                        foreach slaveInterp [interp slaves] {
                            # don?t delete console interpreter
                            if {$slaveInterp != "Console"} {
                                Editor::exitSlave $slaveInterp
                            }
                }
                set slave [interp create exitInterp]
                interp eval $slave set RootDir [list $RootDir]
                interp eval $slave {set argv0 "shutdown Server"}
                interp eval $slave {load {} Tk}
                #interp eval $slave source [list [file join $RootDir evalClient.tcl]]
                $slave alias _exitSlave Editor::exitSlave
                interp eval $slave set slave $slave
                interp eval $slave {
                    proc _exitProc {} {
                        global slave
                        after 500 {_exitSlave $slave}
                    }
                    interp alias {} exit {} _exitProc
                    wm protocol . WM_DELETE_WINDOW _exitProc
                }
                interp eval $slave Client::exitExecutionServer $EditorData(options,serverPort)
                interp delete $slave
            }
            default {
                return
            }
        }
    }
    if {$tcl_platform(platform) == "windows"} {
        set filePatternList [list "Executables {*.exe}" "All-Files {*.*}"]
    } else  {
        set filePatternList [list "All-Files {*}"]
    }
    eval set initialFile $EditorData(options,serverWish)
    set initialDir [file dirname [info nameofexecutable]]
    set serverWish [tk_getOpenFile \
            -filetypes $filePatternList \
            -initialdir $initialDir \
            -initialfile $initialFile \
            -title "Choose Server Wish"]
    if {$serverWish != ""} {
        set EditorData(options,serverWish) [list $serverWish]
    }
    return
}

################################################################################
# proc Editor::serverExecFile
# runs current editor-data via the evalServer without saving to file,
# or associated or default projectfile with data of the current window
################################################################################
proc Editor::serverExecFile {} {
    
    global tk_library
    global tcl_library
    global tcl_platform
    global auto_path
    global conWindow
    global RootDir
    global EditorData
    variable current
    variable con_notebook
    
    Editor::argument_history_add
    #aleady running ?
    if {[interp exists $current(slave)]} {
        switch -- [tk_messageBox -message "$current(file) is already running!\nRestart ?" -type yesnocancel -icon question -title "Question"] {
            yes {
                Editor::exitSlave $current(slave)
                set tempFile [concat "$current(file)" "~~"]
                if {![Editor::file_copy $tempFile $current(file)]} {
                    file delete $tempFile
                }
                after idle Editor::serverExecFile
                return
            }
            no {}
            cancel {}
        }
        return
    }
    set cursor [. cget -cursor]
    . configure -cursor watch
    
    set hasChanged $current(hasChanged)
    if {$current(file) != "Untitled" && $current(writable)} {
        # make safety copy to tmp file
        if {[file_copy $current(file) [concat "$current(file)" "~~"]]} {
            Editor::saveFile
            file_copy $current(file) [concat "$current(file)" "~~"]
        } else  {
            Editor::saveFile
        }
    }
    
    update
    set current(slave) [interp create]
    set Editor::slaves($current(slave)) $Editor::current(pagename)
    interp eval $current(slave) set page $current(pagename)
    $current(slave) alias _exitSlave Editor::exitSlave
    $current(slave) alias ConPuts conPuts
    $current(slave) alias EvalMain Editor::evalMain
    $current(slave) alias NoteBookDelete Editor::deleteTestTerminal
    $current(slave) alias SetTestTermBinding Editor::setTestTermBinding
    if {($current(project) == "none") || ($current(file) == "Untitled" || $current(file) == $current(project))} {
        set current(data) [$current(text) get 1.0 end-1c]
        interp eval $current(slave) set data [list $current(data)]
    } else  {
        if {[file exists $current(project)]} {
            set fd [open $current(project) r]
            interp eval $current(slave) set data [list [read $fd]]
            close $fd
        } else  {
            tk_messageBox -message "ProjectFile <$current(project)> not found !" -title Error -icon error
            after idle Editor::exitSlave $current(slave)
            return
        }
    }
    #create testTerminal
    set testTerminal [EditManager::create_testTerminal $con_notebook $current(pagename) [file tail $current(file)]]
    $con_notebook raise $current(pagename)
    
    # ToDo:
    # setup for interpreter environment via dialog
    interp eval $current(slave) set slave $current(slave)
    interp eval $current(slave) set conWindow $conWindow
    interp eval $current(slave) set argv [list $Editor::argument_var]
    interp eval $current(slave) set argc [llength [list $Editor::argument_var]]
    interp eval $current(slave) set argv0 [list $current(file)]
    interp eval $current(slave) set tcl_library [list $tcl_library]
    interp eval $current(slave) set tk_library [list $tk_library]
    interp eval $current(slave) set auto_path [list $auto_path]
    interp eval $current(slave) set RootDir [list $RootDir]
    interp eval $current(slave) set title [file tail $current(file)]
    interp eval $current(slave) set testTerminal $testTerminal
    interp eval $current(slave) set con_notebook $con_notebook
    interp eval $current(slave) set pagename $current(pagename)
    interp eval $current(slave) set port $EditorData(options,serverPort)
    interp eval $current(slave) set serverWish $EditorData(options,serverWish)
    interp eval $current(slave) {
        proc _exitProc {{exitcode 0}} {
            global slave
            global pagename
            NoteBookDelete $pagename
            catch {_exitSlave $slave}
            return
        }
        set newDir [cd [file dirname $argv0]]
        interp alias {} exit {} _exitProc
        load {} Tk
        wm protocol . WM_DELETE_WINDOW {_exitProc}
        wm withdraw .
        #source [file join $RootDir evalClient.tcl]
        
        # new Client handler, overwrites default handler
        proc Client::newSockHandler {testTerminal sock} {
            variable serverResult
            
            if [eof $sock] {
                catch {close $sock}
                ConPuts "Socket closed $sock" error $testTerminal
                exit
                return
            }
            while {[gets $sock serverResult] > -1 } {
                if {$serverResult != ""} {
                    if {[string first "#echo:" $serverResult] == 0} {
                        ConPuts $serverResult prompt $testTerminal
                    } else  {
                        ConPuts $serverResult output $testTerminal
                    }
                }
            }
            return
        }
        
        eval [list set sock [Client::initExecutionClient \
                localhost \
                $port \
                "Client::newSockHandler $testTerminal" \
                [file join $ASEDsRootDir evalServer.tcl] \
                $serverWish \
                ]]
        if {$sock == {}} {
            exit
            return
        }
        #EvalMain {set Editor::serverUp 1}
        SetTestTermBinding $sock $testTerminal
        
        puts $sock [list set argv $argv]
        puts $sock [list set argc $argc]
        puts $sock [list set argv0 $argv0]
        set data [split $data \n]
        foreach line $data {
            puts $sock $line
        }
        puts $sock "wm deiconify ."
        puts $sock [list wm title . "STB_TSUITE Test Server ([file tail $serverWish]): $title"]
        puts $sock "focus ."
        eval [list wm title . "STB_TSUITE Test Terminal: Output of $title"]
    }
    # restore original file from tmp file
    if {$current(file) != "Untitled"} {
        set tempFile [concat "$current(file)" "~~"]
        if {![Editor::file_copy $tempFile $current(file)]} {
            file delete $tempFile
        }
    }
    set current(hasChanged) $hasChanged
    if {$current(hasChanged)} {
        $Editor::notebook itemconfigure $current(pagename) -image [Bitmap::get redball]
    }
    update idletasks
    . configure -cursor $cursor
    return
}



################################################################################
#proc Editor::terminate
#terminates execution of current editor-file or associated projectfile
################################################################################
proc Editor::terminate {} {
    variable current
    Editor::exitSlave $current(slave)
    set tempFile [concat "$current(file)" "~~"]
    if {[file exists $tempFile] && [file mtime $tempFile] > [file mtime $current(file)]} {
        if {![Editor::file_copy $tempFile $current(file)]} {
            file delete $tempFile
        }
    } elseif {[file exists $tempFile]} {
        file delete $tempFile
    }
}

proc Editor::exitSlave {slave} {
    if {[interp exists $slave]} {
        interp eval $slave {
            set taskList [after info]
            foreach id $taskList {
                after cancel $id
            }
        }
        catch {$Editor::notebook raise $Editor::slaves($slave)}
        catch {Editor::deleteTestTerminal $Editor::current(pagename)}
        catch {interp delete $slave}
        update
        catch {$Editor::con_notebook delete $current(pagename)}
    }
    . configure -cursor {}
    return
}


proc Editor::file_copy {in out} {\
    
    if {[file exists $in]} {
        file copy -force $in $out
        return 0
    } else {
        return 1
    }
}
################################################################################
# proc Editor::getFile
# openfile dialog
# returns filename and content of the file
################################################################################
proc Editor::getFile {{filename {}}} {
    global EditorData
    variable treeWindow
    
    # workaround to avoid button1 events to the procWindow while
    # double clicking a file
    bind $treeWindow <Button-1> { }
      if {$filename == {}} {
        if {$EditorData(options,useDefaultExtension)} {
            # set defaultExt .tcl
            set filePatternList [list "C-Files {*.c *.C}" "All {*.* *}"]
        } else  {
            # set defaultExt ""
            set filePatternList [list "All {*.* *}" "C-Files {*.c *.C}" ]
        }
        set defaultExt ""
        set initialFile ""
        set filename [tk_getOpenFile -filetypes $filePatternList -initialdir $EditorData(options,workingDir) -title "Open File"]
    }
    
    if {[file exists $filename]} {
        set cursor [. cget -cursor]
        . configure -cursor watch
        update
        if {[file writable $filename]} {
            set fd [open $filename r+]
        } elseif {[file readable $filename]}  {
            tk_messageBox -message "File is write protected!\nOpen file as read only!"
            set fd [open $filename r]
        } else  {
            tk_messageBox -message "Permission denied!"
            return ""
        }
        set data [read $fd]
        close $fd
        . configure -cursor $cursor
        set EditorData(options,workingDir) [file dirname $filename]
        return [list $filename $data]
    }
}

proc Editor::openNewPage {{file {}}} {\
    global EditorData
    
    #pages opened
    global pageopened_list
    variable notebook
    variable current
    
    set temp [Editor::getFile $file];#returns filename and textdata
    if {$temp == ""} {
        return 1
    }
    set filename [lindex $temp 0]
    if {$filename == ""} {
        return 1
    }
    
    if {$filename == $current(file)} {
        
        tk_messageBox -message "File already opened !" -title Warning -icon warning
        return 1
    }
    
    ##Check the file already opened
    set check [lsearch $pageopened_list $filename]
    if {$check != -1 } {
		##puts openNewPage_Checkfail
                return 1
       }
    lappend pageopened_list $filename    
    set EditorData(options,workingDir) [file dirname $filename]
    set f0 [EditManager::create_text $notebook $filename ]
    set data [lindex $temp 1]
    
    set temp $current(hasChanged)
    set editorWindows::TxtWidget [lindex $f0 2]
    $editorWindows::TxtWidget insert 1.0 $data
    $editorWindows::TxtWidget mark set insert 1.0
    set current(hasChanged) $temp
    editorWindows::colorize; #needs TxtWidget !
    set Editor::text_win($Editor::index_counter,undo_id) [new textUndoer $editorWindows::TxtWidget]
    NoteBook::raise $notebook [lindex $f0 1]
    $Editor::mainframe setmenustate noFile normal
    #Now the new textwindow is the current
    if {[file writable $filename]} {
        set current(writable) 1
    } elseif {[file readable $filename]}  {
        set current(writable) 0
    } else  {
        tk_messageBox -message "Permission denied!"
        return 1
    }
    set current(hasChanged) 0
    set current(lastPos) [$current(text) index insert]
    return 0
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

################################################################################
#proc Editor::associateProject
#if there is a projectfile associated to the current file,
#this file will be started by pressing the test button.
#This overrides the option for the default project file
################################################################################
proc Editor::associateProject {} {
    global EditorData
    variable current
    
    if {$EditorData(options,useDefaultExtension)} {
        # set defaultExt .tcl
        set filePatternList [list "Tcl-Files {*.tcl *.tk *.itcl *.itk}" "All {*.* *}"]
    } else  {
        # set defaultExt ""
        set filePatternList [list "All {*.* *}" "Tcl-Files {*.tcl *.tk *.itcl *.itk}" ]
    }
    set defaultExt ""
    set initialFile ""
    set filename [tk_getOpenFile -filetypes $filePatternList -initialdir $EditorData(options,workingDir) -title "Select Project File"]
    if {$filename != ""} {
        set current(project) $filename
        set prjFile [file rootname $current(file)].prj
        set result [Editor::_saveFile $prjFile $current(project)]
    }
}

proc Editor::unsetProjectAssociation {} {
    global EditorData
    variable current
    
    set prjFile [file rootname $current(file)].prj
    if {[file exists $prjFile]} {
        file delete $prjFile
    }
    set current(project) $EditorData(options,defaultProjectFile)
}

proc Editor::openFile {{file {}}} {    	
	variable notebook
	variable current
	variable index
	variable last
	#pages opened
   	global pageopened_list	
	set deleted 0
	# test if there is a page opened
	set pages [NoteBook::pages $notebook]
	if {[llength $pages] == 0} { \
	        Editor::openNewPage
        	return
	} else {
        	# test if current page is empty
        	if {[info exists current(text)]} {\
        	set f0 $current(pagename)
        	set text [NoteBook::itemcget $notebook $f0 -text]
            
	        set data [$current(text) get 1.0 end-1c]
        	if {($data == "") && ($text == "Untitled")} {\
                	# page is empty
                	delete_id
                	NoteBook::delete $notebook $current(pagename)
               		tdelNode $current(file)
	                set idx $Editor::index($current(text))
        	        foreach entry [array names Editor::text_win $idx,*] {
        	            unset Editor::text_win($entry)
        	}
                unset index($current(text))
                set deleted 1
            }
        }
	set check [lsearch $pageopened_list $file]
	if {$check != -1 } {		
      	  return 1
    	}
       ##open the new page with filename
       set result [Editor::openNewPage $file]
       if {$deleted && $result} {
            set force 1
           Editor::newFile force
      }
    }
}

proc Editor::saveAll {} {
    
    global PjtDir
    if { $PjtDir == "" || $PjtDir == "None" } {
	conPuts "No Project selected" error
	return
    }
    foreach textWin [array names ::Editor::index] {
        set idx $Editor::index($textWin)
        if {$Editor::text_win($idx,writable) == 0} {
            set filename $Editor::text_win($idx,file)
            tk_messageBox -message "File is write protected!\nCan?t save $filename !"
            continue
        }
        set data [$textWin get 1.0 "end -1c"]
        set filename $Editor::text_win($idx,file)
        Editor::file_copy $filename [concat "$filename" "~"]
        Editor::_saveFile $filename $data
        set Editor::text_win($idx,hasChanged) 0
        $Editor::notebook itemconfigure $Editor::text_win($idx,pagename) -image ""
    }
    set Editor::current(hasChanged) 0
}

proc Editor::_saveFile {filename data} {
    variable current
    
    if {$filename == "Untitled"} {
        Editor::_saveFileas $filename $data
        return
    }
    set cursor [. cget -cursor]
    . configure -cursor watch
    update
    if {[catch {set fd [open $filename w+]}]} {
        tk_messageBox -message "$filename is write protected!\nUse SAVE AS.. instead!"
        return
    }
    puts -nonewline $fd $data
    close $fd
    . configure -cursor $cursor
    return
}

proc Editor::saveFile {} {
    variable notebook
    variable current
    variable index
    global PjtDir
    if { $PjtDir == "" || $PjtDir == "None" } {
	conPuts "No Project selected" error
	return
    }
    if {[$notebook pages] == {}} {
        return ;# No open file
    }
    
    set filename $current(file)
    if {$filename == "Untitled"} {
        Editor::saveFileas
        return
    }
    if {[file writable $filename] == 0} {
        tk_messageBox -message "File \"$filename\" is write protected!\nUse SAVE AS .. instead!"
        return
    }
    
    set data [$current(text) get 1.0 end-1c]
    catch {Editor::file_copy $filename [concat "$filename" "~"]}
    set result [Editor::_saveFile $current(file) $data]
    set current(hasChanged) 0
    $Editor::notebook itemconfigure $current(pagename) -image ""
    set idx $index($current(text))
    set Editor::text_win($idx,hasChanged) $current(hasChanged)
    if {$current(project) != "none"} {
        set prjFile [file rootname $current(file)].prj
        set result [Editor::_saveFile $prjFile $current(project)]
    }
}

proc Editor::_saveFileas {filename data} {
    global EditorData
    
    set filePatternList {
        {"All C Files"     {*.c } }
        {"All Header Files"     {*.h } }
	}
    if {$EditorData(options,useDefaultExtension)} {
        # set defaultExt .tcl
        set filePatternList {
        {"All C Files"     {*.c } }
        {"All Header Files"     {*.h } }
	}
    } else  {
        # set defaultExt ""
        set filePatternList {
        {"All C Files"     {*.c } }
        {"All Header Files"     {*.h } }
	}
    }
    set defaultExt ""
    set initialFile $filename
    set file [tk_getSaveFile -filetypes $filePatternList -initialdir $EditorData(options,workingDir) \
            -initialfile $filename -defaultextension $defaultExt -title "Save File"]
    if {$file != ""} {
        if {[file exists $file]} {
            if {[file writable $file]} {
                set cursor [. cget -cursor]
                . configure -cursor watch
                update
                set fd [open $file w+]
                puts -nonewline $fd $data
                close $fd
                . configure -cursor $cursor
            } else  {
                tk_messageBox -message "No write permission!"
                set file ""
            }
        } else  {
            # new filename
            if {[catch {\
                    set cursor [. cget -cursor]
                    . configure -cursor watch
                    update
                    set fd [open $file w+]
                    puts -nonewline $fd $data
                    close $fd
                    . configure -cursor $cursor
                    }]} {
                tk_messageBox -message "Can?t save file $file\nMaybe no write permission!"
                set file ""
            }
        }
    }
	
	global pageopened_list
	# Remove the Untitled and appened the saved file instead.
   	set fileindex [lsearch -exact $pageopened_list Untitled]
	if {$fileindex >= 0} {
        	set pageopened_list [lreplace $pageopened_list $fileindex $fileindex]
        } 
	lappend pageopened_list $file
	set EditorData(options,workingDir) [file dirname $file]
   	return $file
	
}

proc Editor::saveFileas {} {
    variable notebook
    variable current
    
    if {[$notebook pages] == {}} {
        return ;# no open file
    }
 
    set filename $current(file)
    set data [$current(text) get 1.0 end-1c]
    set result [Editor::_saveFileas $current(file) $data]
    if {$result == ""} {
        return 1
    }
    set insertCursor [$current(text) index insert]
    editorWindows::deleteMarks 1.0 "end -1c"
    tdelNode $current(file)
    set current(hasChanged) 0
    $Editor::notebook itemconfigure $current(pagename) -image ""
    
    set current(file) $result
    set current(writable) 1
    set idx $Editor::index($current(text))
    set Editor::text_win($idx,file) $current(file)
    $notebook itemconfigure $current(pagename) -text [file tail $result]
    ##$current(text) mark set insert $insertCursor
    Editor::updateObjects
    Editor::selectObject 0
    
    #if there was already a .prj-File then copy to new name too
    if {[file exists [file rootname $filename].prj]} {
        set prjFile [file rootname $current(file)].prj
        set result [Editor::_saveFile $prjFile $current(project)]
    }
    Editor::file_copy $current(file) [concat "$current(file)" "~"]
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
        Editor::updateObjects
        Editor::selectObject
    } else  {
        grid remove $win
        grid remove $panedWin.sash1
        grid configure $panedWin.f1 -column 0 -columnspan 3
    }
}



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
################################################################################
#proc Editor::close_dialog
#called whenever the user wants to exit STB_TSUITE and there are files
#that have changed and are still not saved yet
################################################################################
proc Editor::close_dialog {} {\
    variable notebook
    variable current
    variable index
    variable text_win
    set result [tk_messageBox -message "File <$current(file)> has changed!\n Save it ?" -type yesnocancel -icon warning -title "Question"]
    switch -- $result {
        yes {
            if {[file writable $current(file)]} {
                Editor::saveFile
                return 0
            } else  {
                return [Editor::saveFileas]
            }
        }
        no  {return 0}
        cancel {return 1}
    }
}
#######################################################################
#proc Editor::deleteNode
# Deletes a testcase update the tree and structure
#######################################################################
proc Editor::deleteNode {{exit 0}} {
	variable notebook
	variable current
	variable index
	variable last
	variable text_win
	global updatetree
	global totaltc
	
	# Find the node position to delete
	set testcaseposition [GetCurrentNodeNum]
	set groupno [GetPreviousNum]

	# Update the Global Data
	# Changes in testgroup
	# Changes in arrTestCase
	
	set currenttotalcase $totaltc($groupno)
	set tmpcount [expr $testcaseposition + 1]
	for {set CaseCount 1 } {$CaseCount <= $currenttotalcase } {incr CaseCount } {
			
			set value [arrTestCase($groupno)($CaseCount) cget -memCasePath] 
			set value [arrTestCase($groupno)($CaseCount) cget -memCaseExecCount] 
			set value [arrTestCase($groupno)($CaseCount) cget -memHeaderPath] 
			
	}	
	# Delete the records in Treeview 
		for {set delRecCount $testcaseposition } {$delRecCount <= $currenttotalcase} {incr delRecCount } {
			set temp -$groupno
			append temp -$delRecCount
			set child [$updatetree delete path$temp]	
		}
	##puts currenttotalcase$currenttotalcase
	# Change the values upto the last testcase in the group
	for { set tcCount $testcaseposition } { $tmpcount <= $currenttotalcase } { incr tcCount} {
		arrTestCase($groupno)($tcCount)  configure -memCasePath [arrTestCase($groupno)($tmpcount) cget -memCasePath]
		arrTestCase($groupno)($tcCount)  configure -memCaseExecCount [arrTestCase($groupno)($tmpcount) cget -memCaseExecCount]
		arrTestCase($groupno)($tcCount)  configure -memCaseRunoptions [arrTestCase($groupno)($tmpcount) cget -memCaseRunoptions]
		arrTestCase($groupno)($tcCount)  configure -memCaseProfile [arrTestCase($groupno)($tmpcount) cget -memCaseProfile]
		arrTestCase($groupno)($tcCount)  configure -memHeaderPath [arrTestCase($groupno)($tmpcount) cget -memHeaderPath]
		incr tmpcount
	}
}

#######################################################################
#proc Editor::deleteNode
# Deletes a testcase update the tree and structure
#######################################################################
proc Editor::deleteNode {{exit 0}} {
	variable notebook
	variable current
	variable index
	variable last
	variable text_win
	global updatetree
	global totaltc
	
	# Find the node position to delete
	set testcaseposition [GetCurrentNodeNum]
	set groupno [GetPreviousNum]

	# Update the Global Data
	# Changes in testgroup
	# Changes in arrTestCase
	
	set currenttotalcase $totaltc($groupno)
	set tmpcount [expr $testcaseposition + 1]
	for {set CaseCount 1 } {$CaseCount <= $currenttotalcase } {incr CaseCount } {
			
			set value [arrTestCase($groupno)($CaseCount) cget -memCasePath] 
			set value [arrTestCase($groupno)($CaseCount) cget -memCaseExecCount] 
			set value [arrTestCase($groupno)($CaseCount) cget -memHeaderPath] 
			
	}	
	# Delete the records in Treeview 
		for {set delRecCount $testcaseposition } {$delRecCount <= $currenttotalcase} {incr delRecCount } {
			set temp -$groupno
			append temp -$delRecCount
			set child [$updatetree delete path$temp]	
		}
	##puts currenttotalcase$currenttotalcase
	# Change the values upto the last testcase in the group
	for { set tcCount $testcaseposition } { $tmpcount <= $currenttotalcase } { incr tcCount} {
		arrTestCase($groupno)($tcCount)  configure -memCasePath [arrTestCase($groupno)($tmpcount) cget -memCasePath]
		arrTestCase($groupno)($tcCount)  configure -memCaseExecCount [arrTestCase($groupno)($tmpcount) cget -memCaseExecCount]
		arrTestCase($groupno)($tcCount)  configure -memCaseRunoptions [arrTestCase($groupno)($tmpcount) cget -memCaseRunoptions]
		arrTestCase($groupno)($tcCount)  configure -memCaseProfile [arrTestCase($groupno)($tmpcount) cget -memCaseProfile]
		arrTestCase($groupno)($tcCount)  configure -memHeaderPath [arrTestCase($groupno)($tmpcount) cget -memHeaderPath]
		incr tmpcount
	}

	# Delete Last Testcase in the TestGroup.
	struct::record delete instance arrTestCase($groupno)($currenttotalcase)

	
	
	# Create the New Testase instance for the deleted position		
	incr currenttotalcase -1
	set totaltc($groupno) $currenttotalcase
	#testgroup($groupno) configure -groupTestCase $currenttotalcase
	set currenttotalcase $totaltc($groupno)
	
	for {set addTcCount $testcaseposition } {$addTcCount <= $currenttotalcase } {incr addTcCount } {
			set tmpname [arrTestCase($groupno)($addTcCount) cget -memCasePath]
			# Spliting Name from whole path
				set tmpsplit [split $tmpname /]
				set tmpname [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
				set tmpheader [arrTestCase($groupno)($addTcCount) cget -memHeaderPath]
				# Spliting header from whole path
				set tmpsplit [split $tmpheader /]
				set tmpheader [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
				set temp -$groupno
				append temp -$addTcCount
				set runoptions [arrTestCase($groupno)($addTcCount) cget -memCaseRunoptions]
				if {$runoptions=="NN"} {
					set child [$updatetree insert $addTcCount TestGroup-$groupno path$temp -text $tmpname  -open 0 -image [Bitmap::get file] -window [Bitmap::get userdefined_unchecked]]
				} elseif {$runoptions=="NB"} {
					set child [$updatetree insert $addTcCount TestGroup-$groupno path$temp -text $tmpname  -open 0 -image [Bitmap::get file_brkpoint] -window [Bitmap::get userdefined_unchecked]]
				} elseif {$runoptions=="CN"} {
					set child [$updatetree insert $addTcCount TestGroup-$groupno path$temp -text $tmpname  -open 0 -image [Bitmap::get file] -window [Bitmap::get userdefined_checked]]
				} elseif {$runoptions=="CB"} {
					set child [$updatetree insert $addTcCount TestGroup-$groupno path$temp -text $tmpname  -open 0 -image [Bitmap::get file_brkpoint] -window [Bitmap::get userdefined_checked]]
				}
			set child [$updatetree insert 1 path$temp  ExecCount$temp -text [arrTestCase($groupno)($addTcCount) cget -memCaseExecCount] -open 0 -image [Bitmap::get palette]]

			set child [$updatetree insert 2 path$temp  header$temp -text $tmpheader  -open 0 -image [Bitmap::get palette]]
	}
	
	# Print the reorderd values (Testing purpose)	
	#Testing

    global pageopened_list
    # Is there an open window
    if {[$notebook pages] == {}} {
        return
    }
    if {$current(hasChanged)} {
        set result [Editor::close_dialog]
        if {$result} {return $result}
    }

    ## KALYCITO
   
    set fileindex [lsearch -exact $pageopened_list $current(file)]
    if {$fileindex >= 0} {
            set pageopened_list [lreplace $pageopened_list $fileindex $fileindex]
        } else {
            return 0
        }
       
    catch {if {[info exists current(undo_id)]} {delete_id}}
    # if current file is running terminate execution
    Editor::terminate
           
    NoteBook::delete $notebook $current(pagename)
    set idx $Editor::index($current(text))
    foreach entry [array names Editor::text_win "$idx,*"] {
        unset Editor::text_win($entry)
    }
    unset index($current(text))          
    #delete node
    tdelNode $current(file)
    set indexList [NoteBook::pages $notebook]
    if {[llength $indexList] != 0} {
        NoteBook::raise $notebook [lindex $indexList end]
    } else {
        if {$exit == 0} {Editor::newFile}
    }   
    return 0

}

#######################################################################
# proc deletegroup
# Deletes a TestGroup and updates the tree and structure
#######################################################################
proc Editor::deletegroup {{exit 0}} {
    	global updatetree
   	global tg_count
	global totaltc

	# Find the Group position to delete
	
	set TestGroupNo [GetCurrentNodeNum]
	set totaltestgroup $tg_count
	# Select all the Nodes in the Group and close them.
	set currenttotalcase $totaltc($TestGroupNo)
	for {set fndCaseCount 1 } {$fndCaseCount <= $currenttotalcase } {incr fndCaseCount } {
		set temp -$TestGroupNo
		append temp -$fndCaseCount
		Editor::tselectObject "path$temp"
		Editor::closeFile
	}

	
	# Update the Global Data
	# Changes in testgroup
	# Changes in testcase
	# Delete the TestGroups in Treeview 
	for {set delTgCount $TestGroupNo } {$delTgCount <= $totaltestgroup} {incr delTgCount } {
			set child [$updatetree delete TestGroup-$delTgCount]	
		}
	
	set newGroupNo $TestGroupNo
	# Reorder All the testgroups
	for {set oldTgCount [expr $TestGroupNo + 1] } {$oldTgCount <= $totaltestgroup} {incr oldTgCount } {
		set oldtotalcase $totaltc($newGroupNo)
		puts oldtestcse->$oldtotalcase
		set currenttotalcase $totaltc($oldTgCount)
		puts current->$currenttotalcase
		# Create necessary Testcase instances
		if { $oldtotalcase < $currenttotalcase } {
			set Total [expr $currenttotalcase - $oldtotalcase]
			set tmpcount [expr $oldtotalcase + 1]
			for {set CaseCount 1 } {$CaseCount <= $Total} {incr CaseCount } {
				# Create the Testase instance
				#Testcase testcase($newGroupNo)($tmpcount)
				#global arrTestCase($newGroupNo)($tmpcount)
				createtestcase arrTestCase $newGroupNo $tmpcount
				incr tmpcount
			}
		}
		# Delete Extra Testcase instances
		if { $oldtotalcase > $currenttotalcase } {
			set Total [expr $oldtotalcase - $currenttotalcase]
			set tmpcount [expr $currenttotalcase + 1]
			for {set CaseCount 1 } {$CaseCount <= $Total} {incr CaseCount } {
				struct::record delete instance arrTestCase($newGroupNo)($tmpcount)
				#set value arrTestCase($newGroupNo)($tmpcount)
				#freegroup $value
				incr tmpcount
			}
		}
		# Copy the TestCase Details
		for {set CaseCount 1 } {$CaseCount <= $currenttotalcase} {incr CaseCount } {
			arrTestCase($newGroupNo)($CaseCount)  configure -memCasePath [arrTestCase($oldTgCount)($CaseCount) cget -memCasePath]
			arrTestCase($newGroupNo)($CaseCount)  configure -memCaseExecCount [arrTestCase($oldTgCount)($CaseCount) cget -memCaseExecCount]
			arrTestCase($newGroupNo)($CaseCount)  configure -memCaseRunoptions [arrTestCase($oldTgCount)($CaseCount) cget -memCaseRunoptions]
			arrTestCase($newGroupNo)($CaseCount)  configure -memCaseProfile [arrTestCase($oldTgCount)($CaseCount) cget -memCaseProfile]
			arrTestCase($newGroupNo)($CaseCount)  configure -memCeaderPath [arrTestCase($oldTgCount)($CaseCount) cget -memCeaderPath]
		}
		# Copy the Group Details
		arrTestGroup($newGroupNo)  configure -memGroupName [arrTestGroup($oldTgCount) cget -memGroupName]
		arrTestGroup($newGroupNo)  configure -memGroupExecMode [arrTestGroup($oldTgCount) cget -memGroupExecMode]
		arrTestGroup($newGroupNo)  configure -memGroupExecCount [arrTestGroup($oldTgCount) cget -memGroupExecCount]
		arrTestGroup($newGroupNo)  configure -memHelpMsg [arrTestGroup($oldTgCount) cget -memHelpMsg]	
		arrTestGroup($newGroupNo)  configure -memChecked [arrTestGroup($oldTgCount) cget -memChecked]
		set totaltc($newGroupNo) $totaltc($oldTgCount)
		#arrTestGroup($newGroupNo) configure -groupTestCase [arrTestGroup($oldTgCount) cget -groupTestCase]
		incr newGroupNo
	}
	# Delete the arrTestGroup 
	set delreturn [struct::record delete instance arrTestGroup($totaltestgroup)]
	#set currenttotalcase [arrTestGroup($totaltestgroup) cget -groupTestCase]
	for {set CaseCount 1 } {$CaseCount <= $currenttotalcase} {incr CaseCount } {
		# Delete Last Testcase in the TestGroup.
		struct::record delete instance arrTestCase($totaltestgroup)($CaseCount)
	}
	# Set the Updated Project Details
	incr totaltestgroup -1
	incr tg_count -1
	#project configure -totalTestGroup $totaltestgroup
	
	# Redraw the tree view
	for {set testGrpCount $TestGroupNo } {$testGrpCount <= $totaltestgroup} {incr testGrpCount } {
		set groupname [arrTestGroup($testGrpCount) cget -memGroupName]
		set groupexecmode [arrTestGroup($testGrpCount) cget -memGroupExecMode]
		set groupexecount [arrTestGroup($testGrpCount) cget -memGroupExecCount]
		set helpMsg [arrTestGroup($testGrpCount) cget -memHelpMsg]
		set checked [arrTestGroup($testGrpCount) cget -memChecked]
		set currenttotalcase $totaltc($testGrpCount)
		set tgname [arrTestGroup($testGrpCount) cget -memGroupName]
		# Insert TestGroup Node 
		# Checking for which image and window to draw
        	if { $checked == "N" && $helpMsg == "" } {
			set child [$updatetree insert $testGrpCount TestSuite TestGroup-$testGrpCount -text "$groupname" -open 1 -image [Bitmap::get openfold] -window [Bitmap::get userdefined_unchecked] ]
		} elseif { $checked == "C" && $helpMsg == ""} {
			set child [$updatetree insert $testGrpCount TestSuite TestGroup-$testGrpCount -text "$groupname" -open 1 -image [Bitmap::get openfold] -window [Bitmap::get userdefined_checked] ]
		} elseif { $checked == "N" && $helpMsg != "" } {
			set child [$updatetree insert $testGrpCount TestSuite TestGroup-$testGrpCount -text "$groupname" -open 1 -image [Bitmap::get openfolder_info] -window [Bitmap::get userdefined_unchecked]]
		} elseif { $checked == "C" && $helpMsg != "" } {
			set child [$updatetree insert $testGrpCount TestSuite TestGroup-$testGrpCount -text "$groupname" -open 1 -image [Bitmap::get openfolder_info] -window [Bitmap::get userdefined_checked]]
		}	
		# Insert Config under the Group
		set child [$updatetree insert 0 TestGroup-$testGrpCount Config-$testGrpCount -text "Config"  -open 0 -image [Bitmap::get right]]
		# Insert groupExecCount, groupTestCase
		set child [$updatetree insert 1 Config-$testGrpCount groupExecMode-$testGrpCount -text $groupexecmode  -open 0 -image [Bitmap::get palette]]
		set child [$updatetree insert 2 Config-$testGrpCount groupExecCount-$testGrpCount -text $groupexecount  -open 0 -image [Bitmap::get palette]]
		if {$helpMsg != ""} {
			set child [$updatetree insert 2 Config-$testGrpCount helpMsg-$testGrpCount -text Message  -open 0 -image [Bitmap::get palette]]
		}
                # Insert TestCase Node
		for {set CaseCount 1 } {$CaseCount <= $currenttotalcase} {incr CaseCount } {
				set casename [arrTestCase($testGrpCount)($CaseCount) cget -memCasePath]
				set execcount [arrTestCase($testGrpCount)($CaseCount) cget -memCaseExecCount]
				set header [arrTestCase($testGrpCount)($CaseCount) cget -memHeaderPath]
				set runoptions [arrTestCase($testGrpCount)($CaseCount) cget -memCaseRunoptions]
				# Spliting Name from whole path
				set tmpsplit [split $casename /]
				set tmpcasename [lindex $tmpsplit [expr [llength $tmpsplit] - 1]]
				# Spliting header from whole path
				set tmpsplit [split $header /]
				set tmpheader [lindex $tmpsplit [expr [llength $tmpsplit] - 1]]
				set temp -$testGrpCount
				append temp -$CaseCount
				if {$runoptions=="NN"} {
					set child [$updatetree insert $CaseCount TestGroup-$testGrpCount path$temp -text $tmpcasename  -open 0 -image [Bitmap::get file] -window [Bitmap::get userdefined_unchecked]]
				} elseif {$runoptions=="NB"} {
					set child [$updatetree insert $CaseCount TestGroup-$testGrpCount path$temp -text $tmpcasename  -open 0 -image [Bitmap::get file_brkpoint] -window [Bitmap::get userdefined_unchecked]]
				} elseif {$runoptions=="CN"} {
					set child [$updatetree insert $CaseCount TestGroup-$testGrpCount path$temp -text $tmpcasename  -open 0 -image [Bitmap::get file] -window [Bitmap::get userdefined_checked]]
				} elseif {$runoptions=="CB"} {
					set child [$updatetree insert $CaseCount TestGroup-$testGrpCount path$temp -text $tmpcasename  -open 0 -image [Bitmap::get file_brkpoint] -window [Bitmap::get userdefined_checked]]
				}
			set child [$updatetree insert 1 path$temp  ExecCount$temp -text $execcount -open 0 -image [Bitmap::get file]]
			set child [$updatetree insert 2 path$temp  header$temp -text $tmpheader -open 0 -image [Bitmap::get file]]
		}

	}
}
proc Editor::closeFile {{exit 0}} {
    
    variable notebook
    variable current
    variable index
    variable last
    variable text_win
    global pageopened_list	
    # Is there an open window
    if {[$notebook pages] == {}} {
        return
    }
    if {$current(hasChanged)} {
        set result [Editor::close_dialog]
        if {$result} {return $result}
    }
    ## Remove the closed file from the list
    set fileindex [lsearch -exact $pageopened_list $current(file)]
    if {$fileindex >= 0} {
            set pageopened_list [lreplace $pageopened_list $fileindex $fileindex]
        } else {
            return 0
        }    
    catch {if {[info exists current(undo_id)]} {delete_id}}
    # if current file is running terminate execution
    Editor::terminate    
    
    NoteBook::delete $notebook $current(pagename)
    set idx $Editor::index($current(text))
    foreach entry [array names Editor::text_win "$idx,*"] {
        unset Editor::text_win($entry)
    }
    unset index($current(text))          
    #delete node
    tdelNode $current(file)
    set indexList [NoteBook::pages $notebook]
    if {[llength $indexList] != 0} {
        NoteBook::raise $notebook [lindex $indexList end]
    } else {
        if {$exit == 0} {Editor::newFile}
    }   
    return 0
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
   		         saveproject
   		     }
   		     no  {conPuts "Project $PjtName not saved" info}
   		     cancel {
				conPuts "Exit Canceled" info
				return}
   		}
    }
    set taskList [after info]
	
    foreach id $taskList {
        after cancel $id
    }
    if {$current(hasChanged)} {\
        if {[catch {set idx $index($current(text))}]} {
            exit
        }
        set text_win($idx,hasChanged) $current(hasChanged)
    }
    set newlist ""
    set index_list [array names index]
    foreach idx $index_list {\
        set newlist [concat $newlist  $index($idx)]
    }
    
    Editor::getWindowPositions
    Editor::saveOptions
    
    #    if no window is open, we can exit at once
    if {[llength $newlist] == ""} {
        exit
    }
    
    foreach idx $newlist {\
        set current(text) $text_win($idx,path)
        set current(page) $text_win($idx,page)
        set current(pagename) $text_win($idx,pagename)
        set current(hasChanged) $text_win($idx,hasChanged)
        set current(undo_id) $text_win($idx,undo_id)
        set current(file) $text_win($idx,file)
        set current(slave) $text_win($idx,slave)
        set current(writable) $text_win($idx,writable)
        set result [Editor::closeFile exit]
        if {$result} {
            NoteBook::raise $notebook $current(pagename)
            return
        }
    }
    if {$serverUp} {
        set slave [interp create]
        interp eval $slave set RootDir [list $RootDir]
        interp eval $slave set argv0 shutdown_Server
        interp eval $slave {load {} Tk}
        interp eval $slave set Client::port $EditorData(options,serverPort)
        interp eval $slave Client::exitExecutionServer
        interp delete $slave
    }

    exit
}

proc Editor::gotoLineDlg {} {
    variable current
    
    set gotoLineDlg [toplevel .dlg]
    set entryLabel [label .dlg.label -text "Please enter line number"]
    set lineEntry [entry .dlg.entry -textvariable lineNo]
    set buttonFrame [frame .dlg.frame]
    set okButton [button $buttonFrame.ok -width 8 -text Ok -command {catch {destroy .dlg};Editor::gotoLine $lineNo}]
    set cancelButton [button $buttonFrame.cancel -width 8 -text Cancel -command {catch {destroy .dlg}}]
    wm title .dlg "Goto Line"
    bind $lineEntry <KeyRelease-Return> {.dlg.frame.ok invoke}
    pack $entryLabel
    pack $lineEntry
    pack $okButton $cancelButton -padx 10 -pady 10 -side left -fill both -expand yes
    pack $buttonFrame
    BWidget::place $gotoLineDlg 0 0 center
    focus $lineEntry
}

proc Editor::gotoLine {lineNo} {
    variable current
    
    switch -- [string index $lineNo 0] {
        "-" -
        "+" {set curLine [lindex [split [$current(text) index insert] "."] 0]
            set lineNo [expr $curLine $lineNo]}
    }
    if {[catch {$current(text) mark set insert $lineNo.0}]} {
        tk_messageBox -message "Line number out of range!" -icon warning -title "Warning"
    }
    $current(text) see insert
    editorWindows::flashLine
    editorWindows::ReadCursor
    selectObject 0
    focus $current(text)
}

proc Editor::cut {} {
    variable current
    
    editorWindows::cut
    set current(lastPos) [$current(text) index insert]
}

proc Editor::copy {} {
    variable current
    editorWindows::copy
}

proc Editor::paste {} {
    
    variable current
    editorWindows::paste
    set current(lastPos) [$current(text) index insert]
}

proc Editor::delete {} {
    variable current
    editorWindows::delete
    set current(lastPos) [$current(text) index insert]
}

proc Editor::delLine {} {
    global EditorData
    variable current
    if {[$current(text) tag range sel] != ""} {
        Editor::delete
    }
    set curPos [$current(text) index insert]
    if {$EditorData(options,autoUpdate)} {
        set range [editorWindows::deleteMarks "$curPos linestart" "$curPos lineend"]
        $current(text) delete "$curPos linestart" "$curPos lineend +1c"
        Editor::updateOnIdle $range
    } else  {
        $current(text) delete "$curPos linestart" "$curPos lineend +1c"
    }
    set current(lastPos) [$current(text) index insert]
}

proc Editor::SelectAll {} {
    variable current
    
    $current(text) tag remove sel 1.0 end
    $current(text) tag add sel 1.0 end
}

proc Editor::insertFile {} {
    variable current
    set filename [lindex $temp 0]
    if {$filename == ""} {return 1}
    if {$filename == $current(file)} {
     #   tk_messageBox -message "File already opened !" -title Warning -icon warning
      #  return 1
    #}
    set EditorData(options,workingDir) [file dirname $filename]
    set data [lindex $temp 1]
    set data "Success"
    
    $current(text) insert insert $data
    
    
    return 0
}

proc Editor::getFirstChar { index } {
    
    set w $Editor::current(text)
    set curLine [lindex [split [$w index $index] "."] 0]
    set pos $curLine.0
    set char [$w get $pos]
    for {set i 0} {$char == " " || $char == "\t"} {incr i} {
        set pos $curLine.$i
        set char [$w get $pos]
    }
    return [list $char $pos]
}

proc Editor::make_comment_block {} {
    variable current
    
    set commentLineString \
            "################################################################################\n"
    
    if {[$current(text) tag ranges sel] == ""} {
        #no selection
        set curPos [$current(text) index insert]
        set curLine [lindex [split [$current(text) index $curPos] "."] 0]
        $current(text) insert $curLine.0 $commentLineString
        editorWindows::ColorizeLine $curLine
    } else {
        set firstLine [lindex [split [$current(text) index sel.first] "."] 0]
        set lastLine [lindex [split [$current(text) index sel.last] "."] 0]
        for {set line $firstLine} {$line <= $lastLine} {incr line} {
            $current(text) insert $line.0 "# "
        }
        $current(text) insert $firstLine.0 $commentLineString
        set lastLine [expr $lastLine+2]
        $current(text) insert $lastLine.0 $commentLineString
        for {set line $firstLine} {$line <= $lastLine} {incr line} {
            editorWindows::ColorizeLine $line
        }
        $current(text) tag remove sel sel.first sel.last
        $current(text) mark set insert "insert+2l linestart"
    }
    selectObject
}

################################################################################
# proc Editor::toggle_comment
# toggles the comment status of the current line or selection
################################################################################
proc Editor::toggle_comment {} {
    variable current
    
    if {[$current(text) tag ranges sel] == ""} {
        #no selection
        set curPos [$current(text) index insert]
        set result [Editor::getFirstChar $curPos]
        if {[lindex $result 0]  == "#"} {
            $current(text) delete [lindex $result 1]
            while {[$current(text) get [lindex $result 1]] == " " \
                        || [$current(text) get [lindex $result 1]] == "\t"} {
                $current(text) delete [lindex $result 1]
            }
            set curLine [lindex [split [$current(text) index $curPos] "."] 0]
            editorWindows::ColorizeLine $curLine
        } else  {
            set curLine [lindex [split [$current(text) index $curPos] "."] 0]
            $current(text) insert [lindex $result 1] "# "
            editorWindows::ColorizeLine $curLine
        }
        updateOnIdle [list $curLine.0 "$curLine.0 lineend"]
    } else {
        set firstLine [lindex [split [$current(text) index sel.first] "."] 0]
        set lastLine [lindex [split [$current(text) index sel.last] "."] 0]
        set result [Editor::getFirstChar $firstLine.0]
        set char [lindex $result 0]
        if {$char == "#"} {
            #if first char of first line is # then uncomment selection complete
            for {set line $firstLine} {$line <= $lastLine} {incr line} {
                set result [Editor::getFirstChar $line.0]
                if {[lindex $result 0] == "#"} {
                    $current(text) delete [lindex $result 1]
                    while {[$current(text) get [lindex $result 1]] == " " \
                                || [$current(text) get [lindex $result 1]] == "\t"} {
                        $current(text) delete [lindex $result 1]
                    }
                    editorWindows::ColorizeLine $line
                }
            }
        } else  {
            #if first char of first line is not # then comment selection complete
            for {set line $firstLine} {$line <= $lastLine} {incr line} {
                set insertPos [lindex [getFirstChar $line.0] 1]
                $current(text) insert $insertPos "# "
                editorWindows::ColorizeLine $line
            }
        }
        set start [$current(text) index sel.first]
        set end [$current(text) index sel.last]
        updateOnIdle [list $start $end]
        $current(text) tag remove sel sel.first sel.last
    }
    selectObject
}

proc Editor::procList_history_get_prev {} {
    variable current
    
    if  {$current(procListHistoryPos) == 0} {
        set index [$Editor::current(text) index insert]
        set Editor::current(lastPos) $index
        Editor::procList_history_add $index
    } elseif {$current(procListHistoryPos) == -1} {
        incr current(procListHistoryPos)
        set index [$Editor::current(text) index insert]
        set Editor::current(lastPos) $index
        Editor::procList_history_add $index
    }
    if {$current(procListHistoryPos) < [expr [llength $current(procListHistory)]-1]} {
        incr current(procListHistoryPos)
    } else  {
        selectObject 0
        return
    }
    
    $current(text) mark set insert [lindex $current(procListHistory) $current(procListHistoryPos)]
    $current(text) see insert
    focus $current(text)
    editorWindows::ReadCursor 0
    editorWindows::flashLine
    selectObject 0
}

proc Editor::procList_history_get_next {} {
    variable current
    
    if {$current(procListHistoryPos) > 0} {
        incr current(procListHistoryPos) -1
    } else  {
        set current(procListHistoryPos) "-1"
        selectObject 0
        return
    }
    catch {$current(text) mark set insert [lindex $current(procListHistory) $current(procListHistoryPos)]}
    if {$current(procListHistoryPos) == 0} {
        set current(procListHistoryPos) "-1"
    }
    
    $current(text) see insert
    focus $current(text)
    editorWindows::ReadCursor 0
    editorWindows::flashLine
    
    selectObject 0
}

proc Editor::procList_history_update {} {
    variable current
    
    if {![info exists current(procListHistory)]} {
        procList_history_add $current(lastPos)
    } elseif {$current(procListHistoryPos) == 0} {
        set index [$current(text) index $current(lastPos)]
        set lineNum [lindex [split $index "."] 0]
        set mark "mark$lineNum"
        lreplace $current(procListHistory) 0 0 $mark
    } else  {
        procList_history_add $current(lastPos)
    }
}

proc Editor::procList_history_add {{pos {}}} {
    variable current
    
    if {$pos == {}} {
        set index [$Editor::current(text) index insert]
        
    } else  {
        set index [$Editor::current(text) index $pos]
    }
    set lineNum [lindex [split $index "."] 0]
    set mark "mark$lineNum"
    
    if {![info exists Editor::current(procListHistory)]} {
        set Editor::current(procListHistory) [list "mark1"]
    } elseif {[lsearch $Editor::current(procListHistory) "$mark"] == 0} {
        $Editor::current(text) mark set $mark $index
        set Editor::current(procListHistoryPos) 0
        return
    }
    
    catch [$Editor::current(text) mark set $mark $index]
    
    set Editor::current(procListHistory) [linsert $Editor::current(procListHistory) 0 $mark]
    if {[llength $Editor::current(procListHistory)] > $Editor::current(procList_hist_maxLength)} {
        $Editor::current(text) mark unset [lindex $Editor::current(procListHistory) end]
        set Editor::current(procListHistory) [lreplace $Editor::current(procListHistory) end end]
    }
    set Editor::current(procListHistoryPos) 0
}

proc Editor::lineNo_history_add {} {\
    variable lineEntryCombo
    variable lineNo
    set newlist [ComboBox::cget $lineEntryCombo -values]
    if {[lsearch -exact $newlist $lineNo] != -1} {return}
    set newlist [linsert $newlist 0 $lineNo]
    ComboBox::configure $lineEntryCombo -values $newlist
}

proc Editor::argument_history_add {} {\
    variable argument_combo
    variable argument_var
    set newlist [ComboBox::cget $argument_combo -values]
    if {[lsearch -exact $newlist $argument_var] != -1} {return}
    set newlist [linsert $newlist 0 $argument_var]
    ComboBox::configure $argument_combo -values $newlist
}

proc Editor::search_history_add {} {\
    variable search_combo
    variable search_var
    set newlist [ComboBox::cget $search_combo -values]
    if {[lsearch -exact $newlist $search_var] != -1} {return}
    set newlist [linsert $newlist 0 $search_var]
    ComboBox::configure $search_combo -values $newlist
}

proc Editor::search_forward {} {\
    global search_option_icase search_option_match search_option_blink
    variable search_combo
    variable current
    Editor::search_history_add
    set search_string $Editor::search_var
    set result [Editor::search $current(text) $search_string search $search_option_icase\
            forwards $search_option_match $search_option_blink]
    focus $current(text)
    selectObject 0
}


proc Editor::search_backward {{searchText {}}} {\
    global search_option_icase search_option_match search_option_blink
    variable search_combo
    variable current
    
    if {$searchText == {}} {
        Editor::search_history_add
        set search_string $Editor::search_var
        set result [Editor::search $current(text) $search_string search $search_option_icase\
                backwards $search_option_match $search_option_blink]
        
    } else  {
        set result [Editor::search $current(text) $searchText search 0\
                backwards $search_option_match 0]
    }
    
    if {$result != ""} {$current(text) mark set insert [lindex $result 0]}
    focus $current(text)
    selectObject 0
}

proc Editor::load_search_defaults {} {\
    search_default_options
}

proc Editor::search {textWindow search_string tagname icase where match blink} {\
    variable current
    set result [search_proc $textWindow $search_string $tagname $icase $where $match $blink]
    editorWindows::ReadCursor 0
    set current(lastPos) [$current(text) index insert]
    return $result
}

proc Editor::search_dialog {} {\
    
    variable current
    
    search_dbox $current(text)
    Editor::search_history_add
    focus $current(text)
}

proc Editor::replace_dialog {} {\
    variable current
    
    replace_dbox $current(text)
    focus $current(text)
}

proc Editor::findInFiles {} {
    global EditorData
    
    set resultList [fif::openFifDialog $EditorData(options,workingDir)]
}

proc Editor::showResults {resultList} {
    variable resultWindow
    variable TxtWidget
    variable con_notebook
    variable searchResults
    
    catch {
        NoteBook::delete $Editor::con_notebook resultWin
        NoteBook::raise $Editor::con_notebook Console
    }
    set resultWindow [EditManager::createResultWindow $con_notebook]
    foreach entry [array names searchResults] {
        unset searchResults($entry)
    }
    foreach entry $resultList {
        set line "File: [lindex $entry 0] --> \"[lindex $entry 3]\""
        set searchResults($line) $entry
        $resultWindow insert 0 $line
    }
    $resultWindow see 0
    $con_notebook raise resultWin
    bind $resultWindow <Button-1> {
        $Editor::resultWindow selection clear 0 end
        $Editor::resultWindow selection set @%x,%y
        set index [$Editor::resultWindow curselection]
        set result [$Editor::resultWindow get $index]
        set result $Editor::searchResults($result)
        Editor::openFile [lindex $result 0]
        set index "[lindex $result 1].[lindex $result 2]"
        $editorWindows::TxtWidget mark set insert $index
        $editorWindows::TxtWidget see insert
        editorWindows::flashLine
        Editor::selectObject 0
    }
}


proc Editor::undo {} {\
    variable notebook
    variable current
    
    set cursor [. cget -cursor]
    . configure -cursor watch
    update
    set range [textUndoer:undo $Editor::current(undo_id)]
    . configure -cursor $cursor
    if {$range != {}} {
        set curPos [lindex $range 1]
        if {[$current(text) compare [lindex $range 0] == [lindex $range 1]]} {
            #delete all marks at insert
            set range [editorWindows::deleteMarks [$current(text) index insert] [$current(text) index insert]]
        } else  {
            set range [editorWindows::deleteMarks [lindex $range 0] [lindex $range 1]]
        }
        set startLine [lindex [split [$current(text) index [lindex $range 0]] "."] 0]
        set endLine [lindex [split [$current(text) index [lindex $range 1]] "."] 0]
        update
        after idle "editorWindows::ColorizeLines $startLine $endLine"
        updateOnIdle $range
        $Editor::current(text) mark set insert $curPos
    }
    
    set current(lastPos) [$current(text) index insert]
    focus $current(text)
}

proc Editor::redo {} {\
    variable notebook
    variable current
    
    set cursor [. cget -cursor]
    . configure -cursor watch
    update
    set range [textRedoer:redo $Editor::current(undo_id)]
    . configure -cursor $cursor
    
    if {$range != {}} {
        set curPos [lindex $range 1]
        if {[$current(text) compare [lindex $range 0] == [lindex $range 1]]} {
            #delete all marks at insert
            set range [editorWindows::deleteMarks [$current(text) index insert] [$current(text) index insert]]
        } else  {
            set range [editorWindows::deleteMarks [lindex $range 0] [lindex $range 1]]
        }
        set startLine [lindex [split [$current(text) index [lindex $range 0]] "."] 0]
        set endLine [lindex [split [$current(text) index [lindex $range 1]] "."] 0]
        updateOnIdle $range
        after idle "editorWindows::ColorizeLines $startLine $endLine"
        $Editor::current(text) mark set insert $curPos
    }
    
    set current(lastPos) [$current(text) index insert]
    focus $current(text)
}


proc Editor::toggleTreeOrder {} {
    global EditorData
    if {$EditorData(options,sortProcs)} {
        set Editor::options(sortProcs) 0
        Editor::torder $Editor::current(file)
    } else  {
        set Editor::options(sortProcs) 1
        Editor::torder $Editor::current(file)
    }
    set EditorData(options,sortProcs) $Editor::options(sortProcs)
    Editor::selectObject 0
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
        {"All Project Files"     {*.pjt } }
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
	# Close all the opened files in the pageopened_list  
	set listLength [llength $pageopened_list]
	##puts listLength::$listLength
	for { set tmpcount 1} { $tmpcount < $listLength } { incr tmpcount} {
		Editor::closeFile		
	}
	# Create the New Pageopened_list 
	set pageopened_list START
	##puts pageopened_list_Newlist::$pageopened_list
	# Delete all the records of previously open project
	struct::record delete record recProjectDetail
	struct::record delete record recTestGroup
	struct::record delete record recTestCase
	struct::record delete record recProfile
	# Delete the Tree
	$updatetree delete end root TestSuite
	
	##################################################################
  	### Reading Datas from XML File (Contain FullPath)
    	##################################################################
	DeclareStructure
	puts "Projectfilename->$projectfilename"
   	readxml $projectfilename
    	##################################################################
	#project configure -memProjectName $PjtName
	#set tg_count 0
	#set tc_count 0
	InsertTree
	# Open the lattest project's Myboard_sshscp.exp
	Editor::tselectObject "myboard_sshscp.exp"

}

#######################################################################
# proc saveProject
# Saves the current project.
########################################################################
proc saveproject { } {
	global PjtName
	global PjtDir
	if {$PjtDir == "" || $PjtDir == "None"} {
		conPuts "No Project Selected" error
		return
	}
	foreach textWin [array names ::Editor::index] {
        	set idx $Editor::index($textWin)
        	if {$Editor::text_win($idx,writable) == 0} {
            		set filename $Editor::text_win($idx,file)
            		tk_messageBox -message "File is write protected!\nCan?t save $filename !"
            		continue
        	}
        set data [$textWin get 1.0 "end -1c"]
        set filename $Editor::text_win($idx,file)
        Editor::file_copy $filename [concat "$filename" "~"]
        Editor::_saveFile $filename $data
        set Editor::text_win($idx,hasChanged) 0
        $Editor::notebook itemconfigure $Editor::text_win($idx,pagename) -image ""
    	}
	set Editor::current(hasChanged) 0
	
	set ret_writexml [initwritexml "$PjtDir/$PjtName"]
	conPuts "Project $PjtName saved" info
	
}
#######################################################################
# proc newprojectwindow
# Creates a new project
########################################################################

proc newprojectWindow {} {
	global PjtDir
	global PjtName	
	global tmpPjtDir
	global status_run
	global tg_count
	global profileName
	global pjtToolBoxPath
	global pjtTimeOut
	global pjtUserInclPath
	if { $status_run == 1 } {
		Editor::RunStatusInfo
		return
	}
	if {$PjtDir != "None"} {
		#Prompt for Saving the Existing Project
		set result [tk_messageBox -message "Save Project $PjtName ?" -type yesnocancel -icon question -title 			"Question"]
			 switch -- $result {
	 		     yes {			 
	   		         saveproject
	   		     }
	   		     no  {conPuts "Project $PjtName not saved" info}
	   		     cancel {
					#set PjtDir None
					conPuts "Create New Project Canceled" info
					return
				}
	   		}
	}
	set winNewProj .newprj
	catch "destroy $winNewProj"
	toplevel $winNewProj
	wm title	 $winNewProj	"New Project"
	wm resizable $winNewProj 0 0
	wm transient $winNewProj .
	wm deiconify $winNewProj
	wm minsize $winNewProj 150 400
	grab $winNewProj
	font create custom3 -weight bold
	label $winNewProj.l_title -text "Add New Project" -font custom3
	label $winNewProj.l_empty -text "               "
	set titf1 [TitleFrame $winNewProj.titf1 -text "New Project"]
	set tiff2 [$titf1 getframe]
	label $tiff2.l_pjname -text "Project Name :" -justify left
	set PjtName ""
	entry $tiff2.en_pjname -textvariable PjtName -background white -relief ridge
	label $tiff2.l_pjpath -text "Project Path :" -justify left
	set tmpPjtDir [pwd]
	entry $tiff2.en_pjpath -textvariable tmpPjtDir -background white -relief ridge -width 35
	button $tiff2.bt_pjpath -text Browse -command {
							set tmpPjtDir [tk_chooseDirectory -title "New Project" -parent .newprj]
							if {$tmpPjtDir == ""} {
								set tmpPjtDir [pwd]			
								focus .newprj
								return
							}
						       }
	label $tiff2.l_empty4 -text "  " 
	label $tiff2.l_empty2 -text "                         "
	label $tiff2.l_pjconfig -text "Config Project:" -justify left -font custom3
	label $tiff2.l_empty3 -text "                         "
	label $tiff2.l_tmout -text "Time Out (Seconds) :"
	set pjtTimeOut 1
	entry $tiff2.en_tmout -textvariable pjtTimeOut -background white -relief ridge -validate key -vcmd {expr {[string len %P] <= 5} && {[string is int %P]}}	
	label $tiff2.l_info -text "Max:10000"
	label $tiff2.l_usrpath -text "User Include Path :" -justify left
	entry $tiff2.en_usrpath -textvariable pjtUserInclPath -background white -relief ridge -width 35
	set pjtUserInclPath [pwd]
	button $tiff2.bt_usrpath -text Browse -command  {
							  set pjtUserInclPath [tk_chooseDirectory -title "Choose User Include Path" -parent .newprj]
							if {$pjtUserInclPath == ""} {
								set pjtUserInclPath [pwd]			
								focus .newprj
								return
							}
							 }
	label $tiff2.l_empty5 -text "  "
	label $tiff2.l_empty7 -text "                         "
	label $tiff2.l_toolpath -text "ToolBox Path :" -justify left
	entry $tiff2.en_toolpath -textvariable pjtToolBoxPath -background white -relief ridge -width 35
	set pjtToolBoxPath [pwd]
	button $tiff2.bt_toolpath -text Browse -command {
							  set pjtToolBoxPath [tk_chooseDirectory -title "Choose ToolBox Directory Path" -parent .newprj]
							if {$pjtToolBoxPath == ""} {
								set pjtToolBoxPath [pwd]			
								focus .newprj
								return
							}
							}
	
	label $tiff2.l_empty6 -text "  "
	label $tiff2.l_prfname -text "Default Profile Name :" -justify left
	set profileName "Default"
	entry $tiff2.en_prfname -textvariable profileName -background white -relief ridge
	label $tiff2.l_empty1 -text "                         "
	button $tiff2.bt_ok -text Ok -command {
						set PjtName [string trim $PjtName]
						if {$PjtName == "" } {
							tk_messageBox -message "Enter Project Name" -title "Set Project Name error" -icon error
							focus .newprj
							return
						}
						if {![file isdirectory $tmpPjtDir]} {
							tk_messageBox -message "Entered path for project is not a Dire directory" -icon error
							focus .newprj
							return
						}
						set pjtTimeOut [string trim $pjtTimeOut]
						if {$pjtTimeOut > 10000} {
							tk_messageBox -message "Enter value less than 10000" -title "Set Execution Count error" -icon error
							focus .newprj
						} elseif {$pjtTimeOut==""} {
							tk_messageBox -message "Enter value for Timeout" -title "Set Execution Count error" -icon error
							focus .newprj
							return
						}
						if {$profileName==""} {
							set profileName "Default"
							tk_messageBox -message "ProfileName Cannot be empty" -title "Profile" -icon error
							focus .newprj
							return
						}
						if {$pjtUserInclPath==""} {
							tk_messageBox -message "Select path for User Include File Directory" -icon error
							focus .newprj
							return
						}
						
						if {![file isdirectory $pjtUserInclPath]} {
							tk_messageBox -message "Entered User include path is not a directory" -icon error
							focus .newprj
							return
						}

						if {$pjtToolBoxPath==""} {
							tk_messageBox -message "Select path for ToolBox File Directory" -icon error
							focus .newprj
							return
						}
						if {![file isdirectory $pjtToolBoxPath]} {
							tk_messageBox -message "Entered Toolbox path is not a directory" -icon error
							focus .newprj
							return
						}
						set PjtDir $tmpPjtDir
						# Proc NewProject is called to create new project and the new datas are drawn in treeview.
						NewProject
						#saveproject
						#puts "Project saved"
						font delete custom3
						destroy .newprj
					}

	button $tiff2.bt_cancel -text Cancel -command { 
							font delete custom3
							destroy .newprj
							set PjtName [instProject  cget -memProjectName]
							
						      }

	grid config $winNewProj.l_title -row 0 -column 0 -columnspan 5 -sticky "news"
	grid config $tiff2.l_pjname -row 0 -column 0 -sticky w
	grid config $tiff2.en_pjname -row 0 -column 1 -sticky w -columnspan 4

	grid config $tiff2.l_pjpath -row 1 -column 0 -sticky w
	grid config $tiff2.en_pjpath -row 1 -column 1 -sticky w -columnspan 4
	grid config $tiff2.l_empty4 -row 1 -column 5
	grid config $tiff2.bt_pjpath -row 1 -column 6

	grid config $tiff2.l_empty2 -row 2 -column 0

	grid config $tiff2.l_pjconfig -row 3 -column 1 -sticky w

	grid config $tiff2.l_empty3 -row 4 -column 0 

	grid config $tiff2.l_tmout -row 5 -column 0 -sticky w
	grid config $tiff2.en_tmout -row 5 -column 1 -sticky w -columnspan 2
	grid config $tiff2.l_info -row 5 -column 3 -sticky w

	grid config $tiff2.l_usrpath -row 6 -column 0 -sticky w
	grid config $tiff2.en_usrpath -row 6 -column 1 -sticky w -columnspan 4
	grid config $tiff2.l_empty5 -row 6 -column 5
	grid config $tiff2.bt_usrpath -row 6 -column 6
	grid config $tiff2.l_empty7 -row 7 -column 0
	grid config $tiff2.l_toolpath -row 8 -column 0 -sticky w
	grid config $tiff2.en_toolpath -row 8 -column 1 -sticky w -columnspan 4
	grid config $tiff2.l_empty6 -row 8 -column 5 
	grid config $tiff2.bt_toolpath -row 8 -column 6

	grid config $tiff2.l_prfname -row 9 -column 0 -sticky w
	grid config $tiff2.en_prfname -row 9 -column 1 -sticky w -columnspan 4

	grid config $tiff2.l_empty1 -row 10 -column 0 -sticky w
	grid config $tiff2.bt_ok -row 11 -column 1 -sticky news -columnspan 1
	grid config $tiff2.bt_cancel -row 11 -column 6 -sticky news
	grid config $titf1 -column 1 -ipadx 100 -row 1
	focus $tiff2.l_pjname
	bind $winNewProj <KeyPress-Return> {set PjtName [string trim $PjtName]
						if {$PjtName == "" } {
							tk_messageBox -message "Enter Project Name" -title "Set Project Name error" -icon error
							focus .newprj
							return
						}
						if {![file isdirectory $pjtUserInclPath]} {
							tk_messageBox -message "Entered User include path is not a directory" -icon error
							focus .newprj
							return
						}
						set pjtTimeOut [string trim $pjtTimeOut]
						if {$pjtTimeOut > 10000} {
							tk_messageBox -message "Enter value less than 10000" -title "Set Execution Count error" -icon error
							focus .newprj
						} elseif {$pjtTimeOut==""} {
							tk_messageBox -message "Enter value for Timeout" -title "Set Execution Count error" -icon error
							focus .newprj
							return
						}
						if {$profileName==""} {
							set profileName "Default"
							tk_messageBox -message "ProfileName Cannot be empty" -title "Profile" -icon error
							focus .newprj
							return
						}
						if {$pjtUserInclPath==""} {
							tk_messageBox -message "Select path for User Include File Directory" -icon error
							focus .newprj
							return
						}
						
						if {![file isdirectory $pjtUserInclPath]} {
							tk_messageBox -message "Entered User include path is not a directory" -icon error
							focus .newprj
							return
						}

						if {$pjtToolBoxPath==""} {
							tk_messageBox -message "Select path for ToolBox File Directory" -icon error
							focus .newprj
							return
						}
						if {![file isdirectory $pjtToolBoxPath]} {
							tk_messageBox -message "Entered Toolbox path is not a directory" -icon error
							focus .newprj
							return
						}
						font delete custom3
						NewProject
						destroy .newprj
					}
	wm protocol .newprj WM_DELETE_WINDOW { 
					 font delete custom3
					 puts "Deleted"
					 destroy .newprj
				       }
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
	Editor::closeFile
	# Delete all the records
	struct::record delete record recProjectDetail
	struct::record delete record recTestGroup
	struct::record delete record recTestCase
	struct::record delete record recProfile
	# Delete the Tree
	$updatetree delete end root TestSuite
	set PjtDir None
		
	##################################################################
  	### Reading Datas from XML File
    	##################################################################
   	#readxml $filename
    	##################################################################
	#InsertTree
	#Editor::tselectObject "TargetConfig"
	}
}

########################################################################
#proAddTestCase
#
#Update the variables and 
#open the file on editor window
########################################################################
proc AddTestCase { } {
	global updatetree
	global totaltc
	global currenttotalcase
	global TestGroupNo
	global filename
	global testcaseexeccount
	global testcaseheader
	global runoptions
	global selectedProfile
	set TestGroupNo [GetCurrentNodeNum]
	set currenttotalcase $totaltc($TestGroupNo)
	
	set ext [file extension $filename]
	    if { $ext != "" } {
	        if {[string compare $ext ".c"]} {
	            conPuts "$ext not supported"
		    return
	        }
	    }
		
	incr currenttotalcase
	incr totaltc($TestGroupNo)	
	########### Update TestGroup Details ###########
	#### Create the Testase instance ###
	createtestcase arrTestCase $TestGroupNo $currenttotalcase
	########### Update TestCase Details ###########
	arrTestCase($TestGroupNo)($currenttotalcase)  configure -memCasePath $filename
	arrTestCase($TestGroupNo)($currenttotalcase)  configure -memCaseExecCount $testcaseexeccount
	arrTestCase($TestGroupNo)($currenttotalcase)  configure -memHeaderPath $testcaseheader
	arrTestCase($TestGroupNo)($currenttotalcase)  configure -memCaseRunoptions 	$runoptions
	arrTestCase($TestGroupNo)($currenttotalcase)  configure -memCaseProfile $selectedProfile
	########################################################################
	# Updates the tree 
	########################################################################
	########### Spliting for Name ################
	set tmpsplit [split $filename /]
	set tmpcasename [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
	if {$testcaseheader!="None"} {
		set tmpsplit [split $testcaseheader /]
		set tmpheader [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
	} else {
		set tmpheader "None"
	}
	set temp -$TestGroupNo
	append temp -$currenttotalcase
	if {$runoptions == "CN" } {
		set child [$updatetree insert $currenttotalcase TestGroup-$TestGroupNo path$temp -text $tmpcasename  -open 0 -image [Bitmap::get file] -window [Bitmap::get userdefined_checked]]
	} elseif {$runoptions =="CB"} {
		set child [$updatetree insert $currenttotalcase TestGroup-$TestGroupNo path$temp -text $tmpcasename  -open 0 -image [Bitmap::get file_brkpoint] -window [Bitmap::get userdefined_checked]]
	}
	set child [$updatetree insert 1 path$temp  ExecCount$temp -text $testcaseexeccount -open 0 -image [Bitmap::get palette]]
	set child [$updatetree insert 2 path$temp  header$temp -text $tmpheader -open 0 -image [Bitmap::get palette]]
	########################################################################
	#select the tree 
	########################################################################
	Editor::tselectObject "path$temp"
	##append pageopened list
}

########################################################################
#proc Configure Test Case
# Pops up a window, get data from user and stores it in Global data
########################################################################
proc ConfigCase {} {
	global PjtDir
	global caseexeccount
	set groupno  [GetPreviousNum]
	set caseno [GetCurrentNodeNum]
 	set caseexeccount [arrTestCase($groupno)($caseno)  cget -memCaseExecCount]
    	set winConfigCase .configCase
    	catch "destroy $winConfigCase"
   	toplevel $winConfigCase
   	wm title	 $winConfigCase	"Configure"
	wm resizable $winConfigCase 0 0
	wm transient $winConfigCase .
	wm deiconify $winConfigCase
	grab $winConfigCase
   	label $winConfigCase.msg -text "Execution Count( Integer ):" -relief groove
   	entry $winConfigCase.entry -width 5 -textvariable caseexeccount -validate key -vcmd {expr {[string len %P] <= 5} && {[string is int %P]}}
   	pack $winConfigCase.msg -fill x
    	pack $winConfigCase.entry -fill x     
    	frame $winConfigCase.butn
    	pack $winConfigCase.butn -side bottom

	button $winConfigCase.butn.ok -text OK -command {
		set caseexeccount [string trim $caseexeccount]	
		if {$caseexeccount==""} {
			tk_messageBox -message "Execution count cannot be empty" -title "Set Execution Count error" -icon error
			focus .configCase
			set caseexeccount 1
			return		
		} elseif {$caseexeccount > 10000} {
			tk_messageBox -message "Enter value less than 10000" -title "Set Execution Count error" -icon error
			focus .configCase
			return	
		}
		#Update the Global data
        	global updatetree
        	
		
		#set name [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
	
		set groupno  [GetPreviousNum]
		set caseno [GetCurrentNodeNum]
		
		if {$caseexeccount == ""} {
			set caseexeccount "None"        	 
        	}
		# Read the Global Data headerPath for that Group
		set headernameread [arrTestCase($groupno)($caseno)  cget -memHeaderPath]

		arrTestCase($groupno)($caseno)  configure -memCaseExecCount $caseexeccount
		# updatetree _draw_tree
		# Delete the Sub Nodes
		set temp -$groupno
		append temp -$caseno
		set child [$updatetree delete 1 ExecCount$temp]
		set child [$updatetree delete 2 header$temp]

		# ReDraw the Sub Nodes
		set child [$updatetree insert 1 path$temp ExecCount$temp -text $caseexeccount -open 0 -image [Bitmap::get palette]]
		# Split the header Name
		if {$headernameread!="None"} {
			set tmpsplit [split $headernameread /]
			set tmpheadernameread [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
		} else {
			set tmpheadernameread "None"
		}
		set child [$updatetree insert 2 path$temp header$temp -text $tmpheadernameread -open 0 -image [Bitmap::get palette]]
       		destroy .configCase
    	}	
	button $winConfigCase.butn.cancel -text Cancel -command "destroy $winConfigCase" 
  	pack  $winConfigCase.butn.ok -side left -expand 1 \
        -padx 10m -pady 2m
	pack  $winConfigCase.butn.cancel -side left -expand 1 \
        -padx 3m -pady 2m	

    	focus $winConfigCase
    	focus $winConfigCase.entry
        centerW $winConfigCase
}
########################################################################
# proc AddHeader
# 
# Adds a header file to the selected test case.
########################################################################
proc AddHeader {} {
	global PjtDir
	global CurrentNode
	set headertypes {
       		{"All Header Files"  { .h } }
       	}
  		set headernameread [tk_getOpenFile -filetypes $headertypes -parent .]
		set ext [file extension $headernameread]
	        if { $ext != "" } {
	        	if {[string compare $ext ".h"]} {
		    		set headernameread None
		    		tk_messageBox -message "Extension $ext not supported" -title "Add Header Error" -icon error
		    		return
	        	}
	    	}
      		if {$headernameread == ""} {
       	        	return
       		}	
		#Set relative path from project folder to the header file
		set headernameread [getRelativePath $headernameread $PjtDir]
		#Update the Global data
        	global updatetree
		set groupno  [GetPreviousNum]
		set caseno [GetCurrentNodeNum]
	
		set caseexeccount [arrTestCase($groupno)($caseno)  cget -memCaseExecCount]		
		if {$headernameread == ""} {
			set headernameread "None"
        	}	
		if {$caseexeccount == ""} {
			set caseexeccount 1 
        	}
		set temp -$groupno
		append temp -$caseno
		arrTestCase($groupno)($caseno)  configure -memCaseExecCount $caseexeccount
		arrTestCase($groupno)($caseno)  configure -memHeaderPath $headernameread
		# updatetree _draw_tree
		# Delete the Sub Nodes
		set child [$updatetree delete 1 ExecCount$temp]
		set child [$updatetree delete 2 header$temp]

		# ReDraw the Sub Nodes
		set child [$updatetree insert 1 path$temp ExecCount$temp -text $caseexeccount -open 0 -image [Bitmap::get palette]]
		# Split the header Name
		set tmpsplit [split $headernameread /]
		set tmpheadernameread [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
		set child [$updatetree insert 2 path$temp header$temp -text $tmpheadernameread -open 0 -image [Bitmap::get palette]]
}

########################################################################
#proc Configure Project
# Pops up a window, get timeout,userincludepath directory,toolbox diretory from user and stores it in Global data
################################################################################

proc ConfigProject {} {
	global PjtDir
	global pjtTimeOut
	global pjtUserInclPath
	global pjtToolBoxPath
	set pjtTimeOut [instProject cget -memTimeout]
	set pjtUserInclPath [instProject cget -memUserInclude_path]
	set pjtToolBoxPath [instProject cget -memTollbox_path]
	set winProConfig .projconfig
	catch "destroy $winProConfig"
	toplevel $winProConfig
    	wm title	 $winProConfig	"Project Configuration"
	wm resizable $winProConfig 0 0
	wm transient $winProConfig .
	wm deiconify $winProConfig
	grab $winProConfig
	#wm minsize $winProConfig 550 400
   	label $winProConfig.l_empty1 -text ""	
	label $winProConfig.l_title -text "Project Configuration" 
	label $winProConfig.l_empty2 -text ""

	grid config $winProConfig.l_empty1 -row 0 -column 0 -sticky "news"
	grid config $winProConfig.l_title  -row 1 -column 0 -sticky "news" -ipadx 125
	grid config $winProConfig.l_empty2 -row 2 -column 0 -sticky "news"

	set titleFrame1 [TitleFrame $winProConfig.titleFrame1 -text "Configure" ]
	grid config $titleFrame1 -row 3 -column 0 -ipadx 20 -sticky "news"
	set titleInnerFrame1 [$titleFrame1 getframe]

   	label $titleInnerFrame1.l_tmout -text "Time Out (Seconds) :"
   	entry $titleInnerFrame1.en_tmout -width 15 -textvariable pjtTimeOut -validate key -vcmd {expr {[string len %P] <= 5} && {[string is int %P]}} -relief ridge -background white
	label $titleInnerFrame1.l_info -text "Max: 10000"
	
   	label $titleInnerFrame1.l_usrincl -text "User Include Path:"
	set pjtUserInclPath [getAbsolutePath $pjtUserInclPath $PjtDir]
   	entry $titleInnerFrame1.en_usrincl -width 35 -textvariable pjtUserInclPath -relief ridge -background white

   	label $titleInnerFrame1.l_tool -text "ToolBox Path:"
	set pjtToolBoxPath [getAbsolutePath $pjtToolBoxPath $PjtDir]
   	entry $titleInnerFrame1.en_tool -width 35 -textvariable pjtToolBoxPath -relief ridge -background white
	
	grid config $titleInnerFrame1.l_tmout -row 0 -column 0 -sticky w
	grid config $titleInnerFrame1.en_tmout -row 0 -column 1 -sticky w -columnspan 1
	#grid config $titleInnerFrame1.l_info -row 0 -column 2 -sticky w
	grid config $titleInnerFrame1.l_usrincl -row 1 -column 0 -sticky w
	grid config $titleInnerFrame1.en_usrincl -row 1 -column 1

	grid config $titleInnerFrame1.l_tool -row 2 -column 0 -sticky w
	grid config $titleInnerFrame1.en_tool -row 2 -column 1
	label $titleInnerFrame1.l_empty5 -text "   "
	grid config $titleInnerFrame1.l_empty5 -row 1 -column 2 -sticky "news"
	label $titleInnerFrame1.l_empty6 -text "   "
	grid config $titleInnerFrame1.l_empty6 -row 2 -column 2 -sticky "news"
   	button $titleInnerFrame1.bt_browinc -text Browse -command {
				set pjtUserInclPath [tk_chooseDirectory -title "Choose User Include Path" -parent .projconfig]
				focus .projconfig
	}
	grid config $titleInnerFrame1.bt_browinc -row 1 -column 3
	button $titleInnerFrame1.bt_browtool -text Browse -command {
				set pjtToolBoxPath [tk_chooseDirectory -title "Choose Toolbox Path" -parent .projconfig]
				focus .projconfig
	}
	grid config $titleInnerFrame1.bt_browtool -row 2 -column 3

	set frame1 [frame $titleInnerFrame1.fram1]
	button $frame1.bt_ok -text OK -command {
				set pjtTimeOut [string trim $pjtTimeOut]
				if {$pjtTimeOut==""} {
					tk_messageBox -message "Timeout cannot be empty" -icon error -parent .projconfig
					focus .projconfig
					return
				}
				puts "Validate->[file isdirectory $pjtToolBoxPath]"
				puts $pjtToolBoxPath
				if {![file isdirectory $pjtToolBoxPath]} {
					tk_messageBox -message "Entered Tool Box path is not a directory" -icon error
					return
					focus .projconfig
				}
				if { $pjtToolBoxPath != "" } {
					Editor::tdelNode ToolBox
					instProject configure -memTollbox_path [getRelativePath $pjtToolBoxPath $PjtDir]
					DrawToolBox $pjtToolBoxPath
				} else {
					tk_messageBox -message "ToolBoxPath cannot be empty" -icon error -parent .projconfig
					focus .projconfig
					return
				}
				if {![file isdirectory $pjtUserInclPath]} {
					tk_messageBox -message "Entered UserIncludePath is not a directory" -icon error
					return
					focus .projconfig
				}
				if { $pjtUserInclPath==""} {
					tk_messageBox -message "UserIncludePath cannot be empty" -icon error -parent .projconfig
					return
					focus .projconfig
				} else {
					instProject configure -memUserInclude_path [getRelativePath $pjtUserInclPath $PjtDir]
				}
				instProject configure -memTimeout $pjtTimeOut
				set modifyto [instProject cget -memTimeout]
        			destroy .projconfig
    	}	
	button $frame1.bt_cancel -text Cancel -command "destroy $winProConfig"   
	label $titleInnerFrame1.l_empty1 -text ""
	grid config $titleInnerFrame1.l_empty1 -row 3 -column 1 -sticky w

	grid $frame1 -row 4 -column 1 -sticky e
	grid config $frame1.bt_ok -row 0 -column 0 -sticky w
	label $frame1.l_empty7 -text "   "
	grid config $frame1.l_empty7 -row 0 -column 1 -sticky w
	grid config $frame1.bt_cancel -row 0 -column 2 -sticky e

	label $winProConfig.l_empty3 -text ""
	grid config $winProConfig.l_empty3 -row 4 -column 0 -sticky "news"	
	label $winProConfig.l_empty4 -text ""
	grid config $winProConfig.l_empty4 -row 5 -column 0 -sticky "news"	  
    focus $winProConfig
    focus $titleInnerFrame1.en_tmout
    centerW $winProConfig
	wm protocol .projconfig WM_DELETE_WINDOW {
							destroy .projconfig
						   }
}
########################################################################
# proc buttontovalue 
# inputs -nil
# output -retstring  
# Description - Convert the Button Status to Exact Mode and return the string retstring
################################################################################
proc buttontovalue { } {
	global mode_interactive
	global mode_continuous
	global mode_sequence

	if { $mode_interactive == on } {
		set char1 I 
	} else {
		set char1 B
	}
	if { $mode_continuous == on } {
		set char2 C 
	} else {
		set char2 D
	}
	if { $mode_sequence == on } {
		set char3 S 
	} else {
		set char3 R
	}
	set retstring [format "%s%s%s" $char1 $char2 $char3]
	return $retstring

}

proc Editor::create { } {
    global tcl_platform
    global clock_var
    global EditorData
    global RootDir
    global STB_TSUITEMacros
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
    variable caseMenu
    variable textMenu
    variable groupMenu
    variable profileMenu
    variable helpmsgMenu
    variable groupconfic
    variable projectMenu
    variable IndexaddMenu
    
    
    set result [catch {source [file join $RootDir/STB_TSUITE.cfg]} info]
    variable configError $result
   
    set prgtext "Please wait while loading ..."
    set prgindic -1
    _create_intro
    update
    
    
    # use default values
    if {[catch {Editor::setDefault}]} {
        set configError 1
        Editor::setDefault
    }
    Editor::load_search_defaults
    Editor::tick
    
    # Menu description
    set descmenu {
        "&File" {} {} 0 {           
            {command "New &Project" {} "New Project" {Ctrl n}  -command newprojectWindow}
	    {command "Open Project" {}  "Open Project" {Ctrl o} -command openproject}
            {command "Save Project" {noFile}  "Save Project" {Ctrl s} -command saveproject}
            {command "Save Project as" {noFile}  "Save Project as" {} -command YetToImplement}
	    {command "Close Project" {}  "Close Project" {} -command YetToImplement}                 
	    {separator}
            {command "E&xit" {}  "Exit openCONFIGURATOR" {Alt x} -command Editor::exit_app}
        }
        "&Edit" {noFile} {} 0 {
            {command "Copy" {} "Copy to Clipboard" {Ctrl c} -command Editor::copy }
            {command "Cut" {} "Cut to Clipboard" {Ctrl x} -command Editor::cut }
            {command "Paste" {} "Paste from Clipboard" {Ctrl v} -command Editor::paste }
            {command "Delete" {} "Delete Selection" {} -command Editor::delete }
            {command "Delete Line" {} "Delete current line" {} -command {Editor::delLine ; break} }
            {separator}
            {command "Select all" {} "Select All" {} -command Editor::SelectAll }
            {separator}
            {command "Insert File ..." {} "Insert file at current cursor position" {} -command Editor::insertFile }
            {separator}
            {command "Goto Line ..." {} "Goto Line" {} -command Editor::gotoLineDlg }
            {separator}
            {command "Search ..." {} "Search dialog" {} -command Editor::search_dialog }
            {command "Search in files ..." {} "Search in files" {} -command Editor::findInFiles}
            {command "Replace ..." {} "Replace dialog" {} -command Editor::replace_dialog }
            {separator}
            {command "Undo" {} "Undo" {CtrlAlt u} -command Editor::undo }
            {command "Redo" {} "Redo" {} -command Editor::redo }
            {separator}
            {command "AutoIndent File" {} "AutoIndent current file" {} -command editorWindows::autoIndent}
        }
        "&Project" {} {} 0 {
            {command "Build Project" {noFile} "Generate CDC and XML" {CtrlAlt F} -command YetToImplement }
            {command "Rebuild Project" {noFile} "Clean and Build" {CtrlAlt R} -command YetToImplement }
	    {command "Clean Project" {noFile} "Clean" {CtrlAlt C} -command YetToImplement }
	    {command "Stop Build" {}  "Reserved" {} -command YetToImplement -state disabled}
            {separator}
            {command "Settings" {}  "Reserved" {} -command YetToImplement -state disabled}
        }
        "&Connection" all options 0 {
            {command "Connect to POWERLINK network" {noFile} "Establish connection with POWERLINK network" {} -command YetToImplement }
            {command "Disconnect from POWERLINK network" {noFile} "Disconnect from POWERLINK network" {} -command YetToImplement }
	    {separator}
            {command "Configure" {}  "Reserved" {} -command YetToImplement -state disabled}
        }
        "&Actions" all options 0 {
            {command "SDO Read/Write" {noFile} "Do SDO Read or Write" {} -command YetToImplement }
            {command "Transfer CDC" {noFile} "Transfer CDC" {} -command YetToImplement }
            {command "Transfer XML" {noFile} "Transfer XML" {} -command YetToImplement }
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
#############################################################################
# Menu for the Test Group
#############################################################################

    set Editor::groupMenu [menu  .groupmenu -tearoff 0]
    set Editor::IndexaddMenu .groupmenu.cascade
    $Editor::groupMenu add command -label "Rename" \
	     -command {set cursor [. cget -cursor]
			DoubleClickNode ""
		      }
    $Editor::groupMenu add cascade -label "Add" -menu $Editor::IndexaddMenu
    menu $Editor::IndexaddMenu -tearoff 0
    $Editor::IndexaddMenu add command -label "Add Index" -command {YetToImplement}
    $Editor::IndexaddMenu add command -label "Add PDO Objects" -command {AddPDOProc}   

#	     -command {set cursor [. cget -cursor]
#			YetToImplement
#		      } 
     $Editor::groupMenu add command -label "Replace XDC" \
            -command {set cursor [. cget -cursor]
			#Call the procedure
			set types {
			        {"All XDC Files"     {.XDC } }
			}
			tk_getOpenFile -title "Add TestCase" -filetypes $types -parent .
            		}
	
    
    $Editor::groupMenu add separator
    $Editor::groupMenu add command -label "Delete" -command { Editor::deletegroup }
############################################################################# 
	# Menu for the Test Group
	set Editor::groupconfic [menu  .groupconfic -tearoff 0]	
	$Editor::groupconfic add command -label "Configure" -command {ConfigTestGroup} 
   
#############################################################################
# Menu for the Project
#############################################################################
    set Editor::projectMenu [menu  .projectmenu -tearoff 0]
#    set Editor::addMenu .projectmenu.cascade
#    $Editor::projectMenu add cascade -label "Add" -menu $Editor::addMenu
     $Editor::projectMenu add command -label "Add MN/CN" -command {AddNewTestGroupWindow} 
#    menu $Editor::addMenu -tearoff 0
#    $Editor::addMenu add command -label "Test Group" -command {AddNewTestGroupWindow}
#    $Editor::addMenu add command -label "Profile" -command {AddProfileWindow}   
#    $Editor::projectMenu add command -label "Configure" -command {ConfigProject} 
#############################################################################    
# Menu for the Profiles
#############################################################################
	set Editor::profileMenu [menu .profilemenu -tearoff 0]
	$Editor::profileMenu add command -label "Delete" -command {DeleteProfile}
#############################################################################    
# Menu for the Help Message
#############################################################################
	set Editor::helpmsgMenu [menu .helpmsgmenu -tearoff 0]
	#$Editor::helpmsgMenu add command -label "Edit" -command {EditMessage} 
	$Editor::helpmsgMenu add command -label "Delete" -command {DeleteMessage}
#############################################################################    
# Menu for the TestCase
#############################################################################
    set Editor::caseMenu [menu .casemenu -tearoff 0]
    $Editor::caseMenu add command -label "Add Headerfile" -command {AddHeader}
    $Editor::caseMenu add command -label "BreakPoint" -command {BreakPoint}
    $Editor::caseMenu add command -label "Compile" -command {ForceCompile}
    $Editor::caseMenu add command -label "Configure" -command {ConfigCase}
    $Editor::caseMenu add command -label "Delete" -command Editor::deleteNode

#############################################################################
# Menu for the Text
#############################################################################
    set Editor::textMenu [menu .textmenu -tearoff 0]
    $Editor::textMenu add command -label "    cut     " -command Editor::cut
    $Editor::textMenu add command -label "    copy     " -command Editor::copy
    $Editor::textMenu add command -label "    paste     " -command Editor::paste
    $Editor::textMenu add separator
    $Editor::textMenu add command -label "undo" -command Editor::undo
    $Editor::textMenu add command -label "redo" -command Editor::redo
    $Editor::textMenu add separator
    $Editor::textMenu add command -label "Auto Indent Selection" -command editorWindows::autoIndent
    $Editor::textMenu add separator
    $Editor::textMenu add separator
    $Editor::textMenu add checkbutton -label "Auto Update" \
            -variable Editor::options(autoUpdate) \
            -command  {
                set EditorData(options,autoUpdate) $Editor::options(autoUpdate)
                set EditorData(options,showProc) $Editor::options(autoUpdate)
                set Editor::options(showProc) $Editor::options(autoUpdate)
                catch {
                    if {$Editor::options(autoUpdate)} {
                        Editor::updateObjects
                    }
        }
    }
    $Editor::textMenu add checkbutton -label "Show Console" \
            -variable Editor::options(showConsole) \
            -command  {
                set EditorData(options,showConsole) $Editor::options(showConsole)
                Editor::showConsole $EditorData(options,showConsole)
                update idletasks
                catch {$Editor::current(text) see insert}
            }
    $Editor::textMenu add checkbutton -label "Show Code Browser" \
            -variable Editor::options(showProcs) \
            -command  {
                set EditorData(options,showProcs) $Editor::options(showProcs)
                Editor::showTreeWin $EditorData(options,showProcs)
                update idletasks
                catch {$Editor::current(text) see insert}
            }
    $Editor::textMenu add checkbutton -label "Solely Console" \
            -variable Editor::options(solelyConsole) \
            -command  {
                set EditorData(options,solelyConsole) $Editor::options(solelyConsole)
                Editor::showSolelyConsole $EditorData(options,solelyConsole)
                update idletasks
            }
    
    set Editor::prgindic -1
    set Editor::status ""
    set mainframe [MainFrame::create .mainframe \
            -menu $descmenu \
            -textvariable Editor::status \
            -progressvar  Editor::prgindic \
            -progressmax 100 \
            -progresstype normal \
            -progressfg blue ]
    $mainframe showstatusbar progression
    
    #incr prgindic 
   # toolbar 1 creation
    set tb1  [MainFrame::addtoolbar $mainframe]
    set bbox [ButtonBox::create $tb1.bbox1 -spacing 0 -padx 1 -pady 1]
    set toolbarButtons(new) [ButtonBox::add $bbox -image [Bitmap::get new] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Create a new file" -command Editor::newFile]
    set toolbarButtons(save) [ButtonBox::add $bbox -image [Bitmap::get save] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Save file" -command Editor::saveFile]
    set toolbarButtons(saveAll) [ButtonBox::add $bbox -image [Bitmap::get saveAll] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Save Project" -command saveproject]    
    set toolbarButtons(openproject) [ButtonBox::add $bbox -image [Bitmap::get openfold] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Open Project" -command openproject]
        
    pack $bbox -side left -anchor w
    #incr prgindic
    set prgindic 0
    set sep0 [Separator::create $tb1.sep0 -orient vertical]
    pack $sep0 -side left -fill y -padx 4 -anchor w
    
    set bbox [ButtonBox::create $tb1.bbox2 -spacing 0 -padx 1 -pady 1]
    set toolbarButtons(cut) [ButtonBox::add $bbox -image [Bitmap::get cut] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Cut selection" -command Editor::cut]
    set toolbarButtons(copy) [ButtonBox::add $bbox -image [Bitmap::get copy] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Copy selection" -command Editor::copy]
    set toolbarButtons(paste) [ButtonBox::add $bbox -image [Bitmap::get paste] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Paste selection" -command Editor::paste]
    
    pack $bbox -side left -anchor w
    set sep2 [Separator::create $tb1.sep2 -orient vertical]
    pack $sep2 -side left -fill y -padx 4 -anchor w
    
    incr prgindic
    set bbox [ButtonBox::create $tb1.bbox2b -spacing 0 -padx 1 -pady 1]
    set toolbarButtons(toglcom) [ButtonBox::add $bbox -image [Bitmap::get toglcom] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Toggle Comment" -command Editor::toggle_comment]
    set toolbarButtons(comblock) [ButtonBox::add $bbox -image [Bitmap::get comblock] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Make Comment Block" -command Editor::make_comment_block]
    set toolbarButtons(unindent) [ButtonBox::add $bbox -image [Bitmap::get unindent] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Unindent Selection" -command editorWindows::unindentSelection]
    set toolbarButtons(indent) [ButtonBox::add $bbox -image [Bitmap::get indent] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Indent Selection" -command editorWindows::indentSelection]
    
    
    set sep1c [Separator::create $tb1.sep1c -orient vertical]
    pack $sep1c -side left -fill y -padx 4 -anchor w
    
    incr prgindic
    set bbox [ButtonBox::create $tb1.bbox3 -spacing 0 -padx 1 -pady 1]
    
    set toolbarButtons(undo) [ButtonBox::add $bbox -image [Bitmap::get undo] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Undo" -command Editor::undo ]
    
    set toolbarButtons(redo) [ButtonBox::add $bbox -image [Bitmap::get redo] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Redo" -command Editor::redo ]
    pack $bbox -side left -anchor w
    #incr prgindic
    set sep3 [Separator::create $tb1.sep3 -orient vertical]
    pack $sep3 -side left -fill y -padx 4 -anchor w
    
    set bbox [ButtonBox::create $tb1.bbox4 -spacing 0 -padx 1 -pady 1]
    
    set toolbarButtons(find) [ButtonBox::add $bbox -image [Bitmap::get find] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Find Dialog" -command Editor::search_dialog ]
    
    set toolbarButtons(replace) [ButtonBox::add $bbox -image [Bitmap::get replace] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Replace Dialog" -command Editor::replace_dialog ]
    
    pack $bbox -side left -anchor w
    
    set search_combo [ComboBox::create $tb1.combo -label "" -labelwidth 0 -labelanchor w \
            -textvariable Editor::search_var\
            -values {""} \
            -helptext "Enter Searchtext" \
            -entrybg white\
            -width 15]
    pack $search_combo -side left
    
    set bbox [ButtonBox::create $tb1.bbox5 -spacing 1 -padx 1 -pady 1]
    
    set down_arrow [ArrowButton::create $bbox.da -dir bottom \
            -height 21\
            -width 21\
            -helptype balloon\
            -helptext "Search forwards"\
            -command Editor::search_forward]
    set up_arrow [ArrowButton::create $bbox.ua -dir top\
            -height 21\
            -width 21\
            -helptype balloon\
            -helptext "Search backwards"\
            -command Editor::search_backward]
    
    pack $down_arrow $up_arrow -side left
    pack $bbox -side left -anchor w
    #incr prgindic
    set sep [Separator::create $tb1.sep -orient vertical]
    pack $sep -side left -fill y -padx 4 -anchor w
    
    set bbox [ButtonBox::create $tb1.bbox1b -spacing 0 -padx 1 -pady 1]
    ButtonBox::add $bbox -image [Bitmap::get stop] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Terminate Execution" -command Editor::terminate
    
    pack $bbox -side left -anchor w -padx 2
    
    set bbox [ButtonBox::create $tb1.bbox1c -spacing 1 -padx 1 -pady 1]
    
    set compile_arrow [ButtonBox::add $bbox -image [Bitmap::get compile]\
            -height 25\
            -width 25\
            -helptype balloon\
            -helptext "Compile"\
	    -command {Compile }\
    ]
    pack $compile_arrow -side left -padx 4
    set right_arrow [ArrowButton::create $bbox.ua -dir right\
            -height 35\
            -width 35\
            -helptype balloon\
            -helptext "Run Test"\
	    -command {RunTest }\
    ]    
    pack $right_arrow -side left -padx 4
    set export_arrow [ButtonBox::add $bbox -image [Bitmap::get compile]\
            -height 25\
            -width 25\
            -helptype balloon\
            -helptext "Export"\
	    -command {ExportGui}\
    ]
    pack $export_arrow -side left -padx 5
   set import_arrow [ButtonBox::add $bbox -image [Bitmap::get compile]\
            -height 25\
            -width 25\
            -helptype balloon\
            -helptext "Import"\
	    -command {ImportProject}\
    ]
    pack $import_arrow -side left -padx 5
    pack $bbox -side left -anchor w
    
    set argument_combo [ComboBox::create $tb1.combo2 -label "" -labelwidth 0 -labelanchor w \
            -textvariable Editor::argument_var\
            -values {""} \
            -helptext "Enter optional argument" \
            -entrybg white\
            -width 15]
    pack $argument_combo -side left
    
    set sep4 [Separator::create $tb1.sep4 -orient vertical]
    pack $sep4 -side left -fill y -padx 4 -anchor w
    
    set bbox [ButtonBox::create $tb1.bbox6 -spacing 1 -padx 1 -pady 1]
    ButtonBox::add $bbox -image [Bitmap::get exitdoor] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Exit STB_TSUITE" -command Editor::exit_app
    
    
    #get Entry path out of Combo Widget
    set childList [winfo children $search_combo]
    foreach w $childList {if {[winfo class $w] == "Entry"} { set entry $w ; break}}
    bind $entry <KeyRelease-Return> {Editor::search_forward ; break}
    set childList [winfo children $argument_combo]
    foreach w $childList {if {[winfo class $w] == "Entry"} { set entry2 $w ; break}}
    bind $entry2 <KeyRelease-Return> {
        set code [catch Editor::execFile cmd]
        if $code {
            tk_messageBox -message $errorInfo -title Error -icon error
        }
        break
    }
    incr prgindic
    # toolbar 2 creation
    set tb2  [MainFrame::addtoolbar $mainframe]
    
    set bbox [ButtonBox::create $tb2.bbox2 -spacing 0 -padx 1 -pady 1]
    
    ButtonBox::add $bbox -image [Bitmap::get incfont] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Increase Fontsize" -command {Editor::increaseFontSize up}
    pack $bbox -side left -anchor w
    
    ButtonBox::add $bbox -image [Bitmap::get decrfont] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Decrease Fontsize" -command {Editor::increaseFontSize down}
    pack $bbox -side left -anchor w
    set sep3 [Separator::create $tb2.sep3 -orient vertical]
    pack $sep3 -side left -fill y -padx 4 -anchor w
    set Editor::Font_var [font configure editorFont -family]
    set Font_combo [ComboBox::create $tb2.combo \
            -label "" \
            -labelwidth 0\
            -labelanchor w \
            -textvariable Editor::Font_var\
            -values [lsort -dictionary [font families]] \
            -helptext "Choose Font" \
            -entrybg white\
            -modifycmd {Editor::changeFont}\
            ]
    pack $Font_combo -side left
    set Editor::FontSize_var [font configure editorFont -size]
    set FontSize_combo [ComboBox::create $tb2.combo2 -width 2 -label "" -labelwidth 0 -labelanchor w \
            -textvariable Editor::FontSize_var\
            -values {8 9 10 11 12 14 16 20 24 30} \
            -helptext "Choose Fontsize" \
            -entrybg white\
            -modifycmd {Editor::changeFont}\
            ]
    pack $FontSize_combo -side left
    
    $Editor::mainframe showtoolbar 0 $Editor::toolbar1
    $Editor::mainframe showtoolbar 1 $Editor::toolbar2
    
    # set statusbar indicator for file-directory clock and Line/Pos
    set temp [MainFrame::addindicator $mainframe -text "Current Startfile: " ]
    set temp [MainFrame::addindicator $mainframe -textvariable Editor::current(project) ]
    set temp [MainFrame::addindicator $mainframe -text " File: " ]
    set temp [MainFrame::addindicator $mainframe -textvariable Editor::current(file) ]
    set temp [MainFrame::addindicator $mainframe -textvariable EditorData(cursorPos)]
    set temp [MainFrame::addindicator $mainframe -textvariable clock_var]
    
    # NoteBook creation
    incr prgindic
    set frame    [$mainframe getframe]
    
    set pw1 [PanedWindow::create $frame.pw -side left]
    set pane [PanedWindow::add $pw1 -minsize 200]
    set pw2 [PanedWindow::create $pane.pw -side top]
# TODO: Improper Way of implementation. Done to get screenshot of the GUI
    set pw3 [PanedWindow::create $pane.pw1 -side top]
    
    set pane1 [PanedWindow::add $pw2 -minsize 100]
    set pane2 [PanedWindow::add $pw3 -minsize 100]
    set pane3 [PanedWindow::add $pw1 -minsize 100]
    set pane4 [PanedWindow::add $pw2 -minsize 100]
    
    set list_notebook [NoteBook::create $pane1.nb]
    set notebook [NoteBook::create $pane2.nb]	
    set con_notebook [NoteBook::create $pane3.nb]
    #set myWin [NoteBook::create $pane4.nb]
    
    set pf1 [EditManager::create_treeWindow $list_notebook]
    set treeWindow $pf1.sw.objTree
    
    	# Binding on tree widget   
     	$treeWindow bindText <ButtonPress-1> selectobject
	#$treeWindow bindText <Double-1> 
	$treeWindow bindText <Double-1> DoubleClickNode
	
    	$treeWindow bindImage <ButtonPress-1> selectobject
	$treeWindow bindImage <Double-1> Editor::tselectObject

	#$treeWindow bindWindow_userdef <ButtonPress-1> CheckObject
	$treeWindow bindImage <ButtonPress-3> {Editor::tselectright %X %Y}
        
	$treeWindow bindText <ButtonPress-3> {Editor::tselectright %X %Y}
    global EditorData
    global PjtDir
    set PjtDir $EditorData(options,History)
    incr prgindic
    set f0 [EditManager::create_text $notebook Untitled]
    set Editor::text_win($Editor::index_counter,undo_id) [new textUndoer [lindex $f0 2]]
    
    NoteBook::compute_size $list_notebook
    pack $list_notebook -side left -fill both -expand yes -padx 2 -pady 4

    # Commented out to remove Editor window    
    #NoteBook::compute_size $notebook
    #pack $notebook -side left -fill both -expand yes -padx 4 -pady 4

	entry $pane4.ent_1 -width 35 -textvariable pjtToolBoxPath -relief ridge -background white
	label $pane4.lab_1 -text "Object" -anchor w
	entry $pane4.ent_2 -width 35 -textvariable pjtToolBoxPath -relief ridge -background white
	label $pane4.lab_2 -text "Parameter Name" -anchor w
	entry $pane4.ent_3 -width 35 -textvariable pjtToolBoxPath -relief ridge -background white
	label $pane4.lab_3 -text "Data Type" -anchor w
	entry $pane4.ent_4 -width 35 -textvariable pjtToolBoxPath -relief ridge -background white
	label $pane4.lab_4 -text "Access Mode" -anchor w
	entry $pane4.ent_5 -width 35 -textvariable pjtToolBoxPath -relief ridge -background white
	label $pane4.lab_5 -text "Default Value" -anchor w
	entry $pane4.ent_6 -width 35 -textvariable pjtToolBoxPath -relief ridge -background white
	label $pane4.lab_6 -text "Parameter Value" -anchor w
	button $pane4.but_1 -width 25 -textvariable "Save changes" -relief ridge -text "Save Changes"
	button $pane4.but_2 -width 25 -textvariable "Save in XDS/XDD" -relief ridge -text "Save Changes in XDC/XDD file"

	label $pane4.disclaimer -width 75 -text "This window will be used for editing the parameters \n and yet to be designed" -relief ridge -background white -foreground red

#
# Create the font TkFixedFont if not yet present
#
	catch {font create TkFixedFont -family Courier -size -12 -weight bold}
#
# Create an image to be displayed in buttons embedded in a tablelist widget
#
	set openImg [image create photo -file [file join . open.gif]]

#
# Create a vertically scrolled tablelist widget with 5
# dynamic-width columns and interactive sort capability
#
set tbl $pane4.tbl
set vsb $pane4.vsb
tablelist::tablelist $pane4.tbl \
    -columns {0 "Label" left
	      0 "Value" center
	      0 "Format" center} \
    -setgrid no -yscrollcommand [list $vsb set] -width 0 \
    -stripebackground gray98 \
    -showseparators 1 -spacing 10

$tbl columnconfigure 0 -background #f9cf7e
$tbl columnconfigure 1 -background #f9cf7e
$tbl columnconfigure 2 -background #f9cf7e

#$tbl columnconfigure 1 -formatcommand emptyStr -sortmode integer
#$tbl columnconfigure 2 -name fileSize -sortmode integer
#$tbl columnconfigure 4 -name seen
scrollbar $vsb -orient vertical -command [list $tbl yview]

proc emptyStr val { return "" }

eval font create BoldFont [font actual [$tbl cget -font]] -weight bold

#
# Populate the tablelist widget for taking screen shots
#
#$tbl insert end [list 1 0010000000202106 2106 02 00 0000 0010]
#$tbl insert end [list 2 0008001000202104 2104 02 00 0001 0008]
#$tbl insert end [list 3 0010000000202106 2106 02 00 0000 0010]
#$tbl insert end [list 4 0008001000202104 2104 02 00 0001 0008]
#$tbl insert end [list 5 0010000000202106 2106 02 00 0000 0010]
#$tbl insert end [list 6 0008001000202104 2104 02 00 0001 0008]
#$tbl insert end [list 7 0010000000202106 2106 02 00 0000 0010]
#$tbl insert end [list 8 0008001000202104 2104 02 00 0001 0008]
#$tbl insert end [list 9 0010000000202106 2106 02 00 0000 0010]
#$tbl insert end [list 10 0008001000202104 2104 02 00 0001 0008]
#$tbl insert end [list 11 0010000000202106 2106 02 00 0000 0010]
#$tbl insert end [list 12 0008001000202104 2104 02 00 0001 0008]
#$tbl insert end [list 13 0010000000202106 2106 02 00 0000 0010]
#$tbl insert end [list 14 0008001000202104 2104 02 00 0001 0008]
#$tbl insert end [list 15 0010000000202106 2106 02 00 0000 0010]
#$tbl insert end [list 16 0008001000202104 2104 02 00 0001 0008]
#$tbl insert end [list 17 0010000000202106 2106 02 00 0000 0010]
#$tbl insert end [list 18 0008001000202104 2104 02 00 0001 0008]
#$tbl insert end [list 19 0010000000202106 2106 02 00 0000 0010]
#$tbl insert end [list 20 0008001000202104 2104 02 00 0001 0008]
#$tbl insert end [list 21 0010000000202106 2106 02 00 0000 0010]
#$tbl insert end [list 22 0008001000202104 2104 02 00 0001 0008]
#$tbl insert end [list 23 0010000000202106 2106 02 00 0000 0010]

$tbl insert 0 [list Index: 1006 ""]
$tbl insert 1 [list Name: NMT_CycleLen_U32 ""]
$tbl cellconfigure 0,1 -editable yes
$tbl insert 2 [list Object\ Type: VAR ""]
$tbl insert 3 [list Data\ Type: Unsigned32 ""]
$tbl insert 4 [list Access\ Type: rw ""]
$tbl insert 5 [list Value: 0007 ""]
$tbl cellconfigure 5,1 -editable yes
$tbl insert 6 [list]
$tbl cellconfigure 6,0 -window createSaveButton -bg gray98
$tbl cellconfigure 6,1 -window createDiscardButton -bg gray98
$tbl cellconfigure 5,2 -window createFormatButton -bg gray98

$tbl cellconfigure 0,0 -editable yes
$tbl cellconfigure 0,1 -editable yes
$tbl cellconfigure 1,0 -editable yes
$tbl cellconfigure 1,1 -editable yes
$tbl cellconfigure 2,0 -editable yes
$tbl cellconfigure 2,1 -editable yes
$tbl cellconfigure 3,0 -editable yes
$tbl cellconfigure 3,1 -editable yes
$tbl cellconfigure 4,0 -editable yes
$tbl cellconfigure 4,1 -editable yes
$tbl cellconfigure 5,0 -editable yes
$tbl cellconfigure 5,1 -editable yes



$tbl columnconfigure 1 -font Courier

# For packing the Tablelist in the right window
pack $pane4.tbl -side left -fill both -expand yes -padx 4 -pady 4
	# Pack the label and entry box 	
	#grid columnconfigure $pane4 0 -minsize 100
	#grid config $pane4.lab_1 -row 0 -column 0 -sticky "n" -padx 10 -pady 10
	#grid config $pane4.ent_1 -row 0 -column 1 -sticky "n" -padx 10 -pady 10
	#grid config $pane4.lab_2 -row 1 -column 0 -sticky "n" -padx 10 -pady 10
	#grid config $pane4.ent_2 -row 1 -column 1 -sticky "n" -padx 10 -pady 10
	#grid config $pane4.lab_3 -row 2 -column 0 -sticky "n" -padx 10 -pady 10
	#grid config $pane4.ent_3 -row 2 -column 1 -sticky "n" -padx 10 -pady 10
	#grid config $pane4.lab_4 -row 3 -column 0 -sticky "n" -padx 10 -pady 10
	#grid config $pane4.ent_4 -row 3 -column 1 -sticky "n" -padx 10 -pady 10
	#grid config $pane4.lab_5 -row 4 -column 0 -sticky "n" -padx 10 -pady 10
	#grid config $pane4.ent_5 -row 4 -column 1 -sticky "n" -padx 10 -pady 10
	#grid config $pane4.lab_6 -row 5 -column 0 -sticky "n" -padx 10 -pady 10
	#grid config $pane4.ent_6 -row 5 -column 1 -sticky "n" -padx 10 -pady 10
	#grid config $pane4.but_1 -row 6 -column 0 -sticky "n" -padx 0 -pady 30
	#grid config $pane4.but_2 -row 6 -column 1 -sticky "n" -padx 0 -pady 30
	
	

	#grid config $pane4.disclaimer -row 6 -column 1 -sticky "n" -padx 0 -pady 30

    
    pack $pw2 -fill both -expand yes
     incr prgindic
    set cf0 [EditManager::create_conWindow $con_notebook]
    NoteBook::compute_size $con_notebook
    pack $con_notebook -side bottom -fill both -expand yes -padx 4 -pady 4
    
    pack $pw1 -fill both -expand yes
    incr prgindic
    $list_notebook raise objtree
    $con_notebook raise Console
    $notebook raise [lindex $f0 1]
    
    pack $mainframe -fill both -expand yes
    
    update idletasks
    destroy .intro
    wm protocol . WM_DELETE_WINDOW Editor::exit_app
      	if {!$configError} {catch Editor::restoreWindowPositions}
}

proc Editor::changeFont {} {
    global EditorData
    global conWindow
    
    variable index
    variable text_win
    variable Font_var
    variable FontSize_var
    
    
    font configure editorFont -family $Font_var \
            -size $FontSize_var
    set EditorData(options,fonts,editorFont) [font configure editorFont]
    
    font configure commentFont -family $Font_var \
            -size $FontSize_var
    set EditorData(options,fonts,commentFont) [font configure commentFont]
    
    font configure keywordFont -family $Font_var \
            -size $FontSize_var
    set EditorData(options,fonts,keywordFont) [font configure keywordFont]
    
    set newlist ""
    set index_list [array names index]
    foreach idx $index_list {\
        set newlist [concat $newlist  $index($idx)]
    }
    
    foreach idx $newlist {\
        editorWindows::onChangeFontSize $text_win($idx,path)
    }
    $conWindow configure -font $EditorData(options,fonts,editorFont)
    
}

proc Editor::increaseFontSize {direction} {
    global EditorData
    global conWindow
    
    variable notebook
    variable current
    variable index
    variable text_win
    variable list_notebook
    variable pw2
    variable con_notebook
    variable pw1
    variable mainframe
    variable FontSize_var
    
    
    set minSize 8
    set maxSize 30
    
    set newlist ""
    set index_list [array names index]
    foreach idx $index_list {\
        set newlist [concat $newlist  $index($idx)]
    }
    
    if {$direction == "up"} {
        if {[font configure editorFont -size] == $maxSize} {
            return
        }
        font configure editorFont -size [expr [font configure editorFont -size]+1]
        set EditorData(options,fonts,editorFont) [font configure editorFont]
        font configure commentFont -size [expr [font configure commentFont -size]+1]
        set EditorData(options,fonts,commentFont) [font configure commentFont]
        font configure keywordFont -size [expr [font configure keywordFont -size]+1]
        set EditorData(options,fonts,keywordFont) [font configure keywordFont]
    } else  {
        if {[font configure editorFont -size] == $minSize} {
            return
        }
        font configure editorFont -size [expr [font configure editorFont -size]-1]
        set EditorData(options,fonts,editorFont) [font configure editorFont]
        font configure commentFont -size [expr [font configure commentFont -size]-1]
        set EditorData(options,fonts,commentFont) [font configure commentFont]
        font configure keywordFont -size [expr [font configure keywordFont -size]-1]
        set EditorData(options,fonts,keywordFont) [font configure keywordFont]
    }
    
    
    foreach idx $newlist {\
        editorWindows::onChangeFontSize $text_win($idx,path)
    }
    set FontSize_var [font configure editorFont -size]
    $conWindow configure -font $EditorData(options,fonts,editorFont)
    
}

proc Editor::update_font { newfont } {
    variable _wfont
    variable notebook
    variable font
    variable font_name
    variable current
    variable con_notebook
    
    . configure -cursor watch
    if { $font != $newfont } {
        SelectFont::configure $_wfont -font $newfont
        set raised [NoteBook::raise $notebook]
        $current(text) configure -font $newfont
        NoteBook::raise $con_notebook
        $con_notebook configure -font $newfont
        set font $newfont
    }
    . configure -cursor ""
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
    set lab1  [label $frame.lab1 -text "Loading Test Suite" -background white -font {times 8}]
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
#######################################################################
# proc xmltocsv
#
# converts the xml file to a csv file.
#######################################################################
proc xmltocsv {} {
global PjtDir
global csvlist
global RootDir

set cmd "$RootDir/xml2csv.sh"
set inputfile "$PjtDir/logs/testrun.xml"
set outputfile "$PjtDir/logs/temptestrun.xml"
set runcmd [list exec $cmd $inputfile $outputfile]

if {[catch $runcmd res]} {	
	return 1
}		

set filename "$PjtDir/logs/testrun.csv"
set fileId [open $filename "w"]
set csvlist START
set result [createcsv]
set csvlistlength [llength $csvlist]

#puts -nonewline $fileId $data
set flagcount 1
set data2 "Testcase Name, Result\n"
for { set tmpcount 1 } { $tmpcount <= $csvlistlength } {incr tmpcount } {	
		
		if { $flagcount == 1 } {
			#puts -nonewline $fileId "$data2"
			set data1 [lindex $csvlist $tmpcount]
			set data1 "$data1\n"
			incr flagcount
		} else {
			set data2 [lindex $csvlist $tmpcount]
			set data2 "$data2,"
			puts -nonewline $fileId "$data2"
			puts -nonewline $fileId "$data1"
			set flagcount 1
		}
}
### Write this to csv file
#set data $newcsvlist
close $fileId
}
################################################################################
#
#  proc DoubleClickNode
#
#  To edit the testgroup name
################################################################################

proc DoubleClickNode {node} {
	global updatetree
	set node [$updatetree selection get]
	set testGroupNo [GetCurrentNodeNum]
	set selected [GetPreviousNum]
	if { $selected == "TestGroup" } {
		set oldName [$updatetree itemcget $node -text]
		set newName [string trim [$updatetree edit $node "$oldName" "" 1 1]]
		if {$newName != ""} {
			$updatetree itemconfigure $node -text $newName
			arrTestGroup($testGroupNo) configure -memGroupName $newName
		} else {
			#tk_messageBox -message "Cannot be empty"
			DoubleClickNode $node
		}
	} else {
		Editor::tselectObject $node
	}		
}

################################################################################
# proc DeleteMessage
# Input: 
# Output: Deletes the help message for a test group.
################################################################################
proc DeleteMessage {} {
	global updatetree
	set testgroupno [GetCurrentNodeNum]
	set node [$updatetree selection get]
	set node [$updatetree parent $node]
	set node [$updatetree parent $node]
	set child [$updatetree delete helpMsg-$testgroupno]
	$updatetree itemconfigure $node -image [Bitmap::get openfold]
	arrTestGroup($testgroupno) configure -memHelpMsg ""
}

#####################################################################
# procedure to draw toolbox
# Input: Selected Directory
# Output: Lists the contents of the selected directory in toolbox
#####################################################################
proc DrawToolBox {toolBoxDir} {
	global updatetree
	set child [$updatetree insert 1 TargetConfig ToolBox -text "Toolbox" -data $toolBoxDir -open 0 -image [Bitmap::get openfold]]
	#exec rm -R *~
	set toolFilesCount 0
	set lentries [glob -nocomplain [file join $toolBoxDir "*"]]
	foreach f $lentries {
        	set tail [file tail $f]
		set extsplit [split $tail .]
		set extention [lindex $extsplit [expr [llength $extsplit] - 1]]
        	if { [file isdirectory $f] } {
        	} else {
			if { $extention == "c" || $extention == "h" || $extention == "C" || $extention == "H"} {
				set child [$updatetree insert $toolFilesCount ToolBox $tail -text $tail -open 0 -image [Bitmap::get file]] 
        	        incr toolFilesCount
			}
        	}
    	    }
}

################################################################################
#
#  proc GetCurrentNodeNum
#
#  This function returns the TestGroup or TestCase number.
################################################################################
proc GetCurrentNodeNum {} {
	global updatetree
	set CurNode [$updatetree selection get]
	set tmpsplit [split $CurNode "-"]
	set nodeNum [lindex $tmpsplit [expr [llength $tmpsplit] -1]]
	return $nodeNum
}

####################################################################################
#
#  proc GetPreviousNum
#
# This function returns the TestGroup number of the TestCase or the TestGroup name.
####################################################################################

proc GetPreviousNum {} {
	global updatetree
	set CurNode [$updatetree selection get]
	set tmpsplit [split $CurNode "-"]
	set nodeNum [lindex $tmpsplit [expr [llength $tmpsplit] -2]]
	return $nodeNum
}
################################################################################
#
#  proc CheckObject
#
#  Single Click to check/uncheck the object on the tree
################################################################################
proc CheckObject {node} {
	global updatetree
	set tmpsplit [split $node "-"]
	set nodeName [lindex $tmpsplit 0]
	if {$nodeName == "TestGroup"} {
		set testGroupNo [lindex $tmpsplit [expr [llength $tmpsplit] -1]]
		set check [arrTestGroup($testGroupNo) cget -memChecked]
		if { $check == "N" } {
			arrTestGroup($testGroupNo) configure -memChecked C
			$updatetree itemconfigure $node -window [Bitmap::get userdefined_checked]
			$updatetree closetree $node
		} elseif { $check == "C" } {
			arrTestGroup($testGroupNo) configure -memChecked N
			$updatetree itemconfigure $node -window [Bitmap::get userdefined_unchecked]
			$updatetree closetree $node
		}
	} elseif {$nodeName == "path"} {
		set testCaseNo [lindex $tmpsplit [expr [llength $tmpsplit] -1]]
		set testGroupNo [lindex $tmpsplit [expr [llength $tmpsplit] -2]]
		set check [arrTestCase($testGroupNo)($testCaseNo) cget -memCaseRunoptions]
		if {$check == "NN" } {
			arrTestCase($testGroupNo)($testCaseNo) configure -memCaseRunoptions "CN"
			$updatetree itemconfigure $node -window [Bitmap::get userdefined_checked]
			$updatetree closetree $node
		} elseif {$check == "NB" } {
			arrTestCase($testGroupNo)($testCaseNo) configure -memCaseRunoptions "CB"
			$updatetree itemconfigure $node -window [Bitmap::get userdefined_checked]
			$updatetree closetree $node
		} elseif {$check == "CN" } {
			arrTestCase($testGroupNo)($testCaseNo) configure -memCaseRunoptions "NN"
			$updatetree itemconfigure $node -window [Bitmap::get userdefined_unchecked]
			$updatetree closetree $node
		} elseif {$check == "CB" } {
			arrTestCase($testGroupNo)($testCaseNo) configure -memCaseRunoptions "NB"
			$updatetree itemconfigure $node -window [Bitmap::get userdefined_unchecked]
			$updatetree closetree $node
		}
	}
}
################################################################################
#
#  proc getRelativePath
#  Input:absolute path,home directory path
#  Output: relative path
#  Returns the relative path of abs_path to the corresponding hom_path
################################################################################
proc getRelativePath {abs_path hom_path} {
	#####one extra space is got when converting to list so using this logic it is removed#####
	set abs_list [lrange [split $abs_path /] 1 end]
	#set hom_path [pwd]
	#puts "The Current path is :\n$hom_path"
	#####one extra space is got when converting to list so using this logic it is removed#####
	set hom_list [lrange [split $hom_path /] 1 end]
	set abs_size [llength $abs_list]
	set hom_size [llength $hom_list]
	#####to detemine whether home or user path is the shortest#####
	if {$hom_size<$abs_size} {
		set small $hom_size
	} else {
		set small $abs_size
	}
	set tempcount 0
	while {(([string compare [lindex $hom_list $tempcount] [lindex $abs_list $tempcount]])==0)&&($tempcount<=$small) } {
		incr tempcount +1
	}
	#####to find out whether the paths are mismatched or the shortest path is completely matched##### 
	if {$small<$tempcount} {
		set count [incr tempcount -1]
	} else {
		set count $tempcount
	}
	set output ./
	#####generating output such that it brings to the directory where till user path and current path matches#####  
	for {set f1 $count} {$f1<$hom_size} {incr f1} {
		append output ../
	}
	#####generating output such that it moves the directory from matched path till complete user given path#####
	for {set f2 $count} {$f2<$abs_size} {incr f2} {
		append output [lindex $abs_list $f2] 
		append output / 
	}
	return $output
}
################################################################################################
# proc AddTestGroup
#
# Output: Creates a testgroup instance and add its in tree window.
################################################################################################
proc AddTestGroup { } {
	global updatetree
	global PjtDir		
	global tg_count
	global totaltc
	global testGroupName
	global execCount
	global helpMsg
	set TotalTestGroup $tg_count
	incr TotalTestGroup
	##################################################################
	# Update the Total TestGroup value 
	##################################################################
	incr tg_count
	##################################################################
	##Format the New TestGroup
	##Create New Instance for TestGroup 
	##################################################################
	# Call the procedure to create the instance for testgroup
	createtestgroup arrTestGroup $TotalTestGroup
	set groupexecmode [buttontovalue]
	set grouptestcase 0
	#set helpMessage $helpMsg
	arrTestGroup($TotalTestGroup)  configure -memGroupName $testGroupName
	arrTestGroup($TotalTestGroup)  configure -memGroupExecMode $groupexecmode
	arrTestGroup($TotalTestGroup)  configure -memGroupExecCount $execCount
	arrTestGroup($TotalTestGroup)  configure -memChecked C
	#arrTestGroup($TotalTestGroup)  configure -memHelpMsg $helpMsg
	set totaltc($TotalTestGroup) $grouptestcase
	#######################################################################
	#Reads the variables and updates the tree 
	########################################################################
	set child [$updatetree insert $TotalTestGroup OBD TestGroup-$TotalTestGroup -text "$testGroupName" -open 1 -image [Bitmap::get openfold] -window [Bitmap::get userdefined_checked]]
	# Insert Config under the Group
	#set child [$updatetree insert 0 TestGroup-$TotalTestGroup Config-$TotalTestGroup -text "Config"  -open 0 -image [Bitmap::get right]]
	# Insert groupExecCount, groupTestCase,Message
#	set child [$updatetree insert 1 Config-$TotalTestGroup groupExecMode-$TotalTestGroup -text $groupexecmode  -open 0 -image [Bitmap::get palette]]
#	set child [$updatetree insert 2 Config-$TotalTestGroup groupExecCount-$TotalTestGroup -text $execCount -open 0 -image [Bitmap::get palette]]
#	if {$helpMsg!=""} {
#		set child [$updatetree insert 3 Config-$TotalTestGroup helpMsg-$TotalTestGroup -text Message  -open 0 -image [Bitmap::get palette]]
#		$updatetree itemconfigure TestGroup-$TotalTestGroup -image [Bitmap::get openfolder_info]
#	}
	destroy .wintestgroupname
}
################################################################################################
# proc AddProfile
# Input : profile name entered by the user
# Output: Creates a profile instance and add its in tree window.
################################################################################################
proc AddProfile {profileName} {
	global updatetree
	global pro_count
	##################################################################
	# Update the Project 
	##################################################################
	incr pro_count
	##Create New Instance for Profile 
	createprofile arrProfile $pro_count
	arrProfile($pro_count)  configure -memProfileName $profileName  
	set child [$updatetree insert $pro_count Profiles profile-$pro_count -text "$profileName"  -open 0 -image [Bitmap::get file]] 
}

#######################################################################
# proc getAbsolutePath
# Convert the Relative path to Exact path from the present working dir
# Input:Relative path 
# Output:Exact path from PWD.
#######################################################################
proc getAbsolutePath {rel_path hom_path} {
	#####To remove extra space#####
	set rel_list [lrange [split $rel_path /] 1 end]
	#####To remove extra space#####
	set hom_list [lrange [split $hom_path /] 1 end]
	set rel_size [llength $rel_list]
	set hom_size [llength $hom_list]
	set count 0
	#####generating output such that it brings to the directory where till user path and current path matches#####  
	for {set f1 0} {$f1<$rel_size} {incr f1 } {
		if { ([string compare [lindex $rel_list $f1] "."])==0} {
		} elseif {([string compare [lindex $rel_list $f1] ".."])==0} {
			incr count
		} else {
			break
		}
	}
	set tempCount [expr $hom_size-$count]
	set output [lrange $hom_list 0 [expr $tempCount-1]]
	#####generating output such that it moves the directory from matched path till complete user given path#####
	incr rel_size -1
	for {set f2 $count} {$f2<$rel_size} {incr f2 } {
		lappend output [lindex $rel_list $f2]
	}
	set strOutput /
	append strOutput [join $output {/}]
	return $strOutput
}
####################################################################################################
# proc NewProject
# Creates a new project, updates the data structure,draws the tree.
#####################################################################################################
proc NewProject {} {
	global PjtDir
	global PjtName	
	global pageopened_list
	global RootDir
	global tg_count
	global tc_count
	global pro_count
	global profileName
	global pjtToolBoxPath
	global pjtTimeOut
	global pjtUserInclPath
	global updatetree
	global totaltc
	#Create instance for project
	createproject tempProject
	# Copy oldproject details before deleting 
	tempProject configure -memProjectName [instProject cget -memProjectName]
	tempProject configure -memTimeout [instProject cget -memTimeout]
	tempProject configure -memExecProfile [instProject cget -memExecProfile]
	tempProject configure -memMode D
	tempProject configure -memTollbox_path [instProject cget -memTollbox_path]
	tempProject configure -memUserInclude_path [instProject cget -memUserInclude_path]
	set oldPro_count $pro_count
	set oldTg_count $tg_count
	for {set profileCount 1} {$profileCount<=$pro_count} {incr profileCount} {
			createprofile tempProfile $profileCount
			tempProfile($profileCount) configure -memProfileName [arrProfile($profileCount) cget -memProfileName]
	}
	for {set testGrpCount 1} {$testGrpCount<=$tg_count} {incr testGrpCount} {
			createtestgroup tempTestGroup $testGrpCount
			tempTestGroup($testGrpCount) configure -memGroupName [arrTestGroup($testGrpCount) cget -memGroupName]
			tempTestGroup($testGrpCount) configure -memGroupExecMode [arrTestGroup($testGrpCount) cget -memGroupExecMode]
			tempTestGroup($testGrpCount) configure -memGroupExecCount [arrTestGroup($testGrpCount) cget -memGroupExecCount]
			tempTestGroup($testGrpCount) configure -memChecked [arrTestGroup($testGrpCount) cget -memChecked]
			tempTestGroup($testGrpCount) configure -memHelpMsg [arrTestGroup($testGrpCount) cget -memHelpMsg]
			set oldTotaltc($testGrpCount) $totaltc($testGrpCount)
			for {set tccount 1} {$tccount<=$totaltc($testGrpCount)} {incr tccount} {
				createtestcase tempTestCase $testGrpCount $tccount
				tempTestCase($testGrpCount)($tccount) configure -memCasePath [arrTestCase($testGrpCount)($tccount) cget memCasePath]
				tempTestCase($testGrpCount)($tccount) configure -memCaseExecCount [arrTestCase($testGrpCount)($tccount) cget memCaseExecCount]
				tempTestCase($testGrpCount)($tccount) configure -memCaseRunoptions [arrTestCase($testGrpCount)($tccount) cget memCaseRunoptions]
				tempTestCase($testGrpCount)($tccount) configure -memCaseProfile [arrTestCase($testGrpCount)($tccount) cget memCaseProfile]
				tempTestCase($testGrpCount)($tccount) configure -memHeaderPath [arrTestCase($testGrpCount)($tccount) cget memHeaderPath]
			}
	}
	#Delete the old project details
	# Delete all the records
	struct::record delete instance instProject
	for {set delProfCount 1} {$delProfCount<=$pro_count} {incr delProfCount} {
		struct::record delete instance arrProfile($delProfCount)
	}
	for {set testGrpCount 1} {$testGrpCount<=$tg_count} {incr testGrpCount} {
		struct::record delete instance arrTestGroup($testGrpCount)
		for {set tccount 1} {$tccount<=$totaltc($testGrpCount)} {incr tccount} {
			struct::record delete instance arrTestCase($testGrpCount)($tccount)
		}
	}
	#DeclareStructure
	createproject instProject
	createprofile arrProfile 1
	set pro_count 1
	arrProfile(1) configure -memProfileName $profileName
	append PjtDir "/$PjtName"
	# Configure new project details
	instProject configure -memProjectName "$PjtName.pjt"
	instProject configure -memTimeout $pjtTimeOut
	instProject configure -memExecProfile $profileName
	instProject configure -memMode D
	instProject configure -memTollbox_path [getRelativePath $pjtToolBoxPath $PjtDir]
	instProject configure -memUserInclude_path [getRelativePath $pjtUserInclPath $PjtDir]
	set tg_count 0
	set tc_count 0
	set pro_count 1
	file mkdir $PjtDir
	set PjtName "$PjtName.pjt"
	set filename "$PjtDir/$PjtName"
	
	#set ret_writ [initwritexml $filename]
	#set ret_writ "xmlCompleted"
	file mkdir $PjtDir/logs
	file mkdir $PjtDir/Elfs
	# Close all the opened files in the pageopened_list  
	set listLength [llength $pageopened_list]
	for { set tmpcount 1} { $tmpcount < $listLength } { incr tmpcount} {
		Editor::closeFile
	}
	# Create the New Pageopened_list 
	set pageopened_list START
	struct::record delete instance tempProject
	for {set profileCount 1} {$profileCount<=$oldPro_count} {incr profileCount} {
		struct::record delete instance tempProfile($profileCount)
		puts Profile->$oldPro_count
	}
	for {set testGrpCount 1} {$testGrpCount<=$oldTg_count} {incr testGrpCount} {
		struct::record delete instance tempTestGroup($testGrpCount)
		for {set tccount 1} {$tccount<=$oldTotaltc($testGrpCount)} {incr tccount} {
			struct::record delete instance tempTestCase($testGrpCount)($tccount)
		}
	}
	# Delete the Tree
	$updatetree delete end root TestSuite
	update idletask

	# Draw tree
	InsertTree 
	##puts PAGEOPENLIST:$pageopened_list
}
#################################################################################################################
# proc AddNewTestGroupWindow
#
# pops up a window and gets all the details for a testgroup and calls AddTestGroup procedure to update in tree window # and in structure
#####################################################################################################################
proc AddNewTestGroupWindow {} {
	global testGroupName
	global execCount
	global mode_interactive
	global mode_continuous
	global mode_sequence
	global titleInnerFrame1
	global helpMsg
	global disptext
	set testGroupName ""
	set execCount 1
	set winAddTestGroup .addTestGroup
	catch "destroy $winAddTestGroup"
	toplevel     $winAddTestGroup
	wm title     $winAddTestGroup "Add New Controlled Node"
	wm resizable $winAddTestGroup 0 0
	wm transient $winAddTestGroup .
	wm deiconify $winAddTestGroup
	grab $winAddTestGroup
	#wm minsize   $winAddTestGroup 300 400
	#wm maxsize   $winAddTestGroup 250 400
	font create custom1 -weight bold
	label $winAddTestGroup.l_empty1 -text ""	
	label $winAddTestGroup.l_title -text "Add New Controlled Node" -font custom1
	label $winAddTestGroup.l_empty2 -text ""
	
	grid config $winAddTestGroup.l_empty1 -row 0 -column 0 -sticky "news"
	grid config $winAddTestGroup.l_title  -row 1 -column 0 -sticky "news" -ipadx 125
	grid config $winAddTestGroup.l_empty2 -row 2 -column 0 -sticky "news"

	set titleFrame1 [TitleFrame $winAddTestGroup.titleFrame1 -text "New Controlled Node" ]
	grid config $titleFrame1 -row 3 -column 0 -ipadx 20 -sticky "news"
	set titleInnerFrame1 [$titleFrame1 getframe]
	
	set titleFrame2 [TitleFrame $titleInnerFrame1.titleFrame2 -text "Configuration"]  
	grid config $titleFrame2 -row 2 -column 0 -ipadx 5  -sticky "news"
	set titleInnerFrame2 [$titleFrame2 getframe]
	
	####frame1 has six radio buttons to select excution mode 
	set frame1 [frame $titleInnerFrame2.fram1]
	#### frame2 has label TestGroupName and the entry box
	set frame2 [frame $titleInnerFrame1.fram2]
	#### frame3 has label Execution count and the entry box
	set frame3 [frame $titleInnerFrame2.fram3]
	#### frame 4 has ok and cancel button
	set frame4 [frame $titleInnerFrame1.fram4]
	set frame5 [frame $titleInnerFrame1.fram5]
	
	label $frame2.l_name -text "CN Name :"
	entry $frame2.en_name -textvariable testGroupName -background white
	grid config $frame2.l_name  -row 0 -column 0 
	grid config $frame2.en_name -row 0 -column 1
	grid config $frame2 -row 0 -column 0

	label $titleInnerFrame1.l_empty3 -text ""
	grid config $titleInnerFrame1.l_empty3  -row 1 -column 0
	
	label $titleInnerFrame2.l_empty4 -text ""
	grid config $titleInnerFrame2.l_empty4  -row 0 -column 0 
	
	label $frame3.l_exe -text "Import XDC :"
	entry $frame3.en_exe -textvariable filename -background white -validate key -vcmd {expr {[string len %P] <= 5} && {[string is int %P]}}
button $frame3.bt_name -text Browse -command {
						set types {
						        {"All XDC Files"     {.XDC } }
							}
						set filename [tk_getOpenFile -title "Add TestCase" -filetypes $types -parent .]
					}
	grid config $frame3.l_exe  -row 0 -column 0 
	grid config $frame3.en_exe -row 0 -column 1
	grid config $frame3.bt_name -row 0 -column 2
	grid config $frame3 -row 1 -column 0
	
	label $titleInnerFrame2.l_empty5 -text ""
	grid config $titleInnerFrame2.l_empty5  -row 2 -column 0
	label $titleInnerFrame2.l_mode -text "Type of CN"
	grid config $titleInnerFrame2.l_mode  -row 3 -column 0 
	
	#variables used for radio buttons
	set mode_interactive on
	set mode_continuous on
	set mode_sequence on
	radiobutton $frame1.ra_inter -text "Software CN"   -variable mode_interactive   -value on 
	radiobutton $frame1.ra_bat   -text "Hardware CN"         -variable mode_interactive   -value off 
	label $frame1.ra_cont  -text ""
	label $frame1.ra_disco -text "" 
	label $frame1.ra_seq   -text "" 
	label $frame1.ra_ran   -text "" 
	grid config $frame1.ra_inter -row 0 -column 0 -sticky "w"
	grid config $frame1.ra_bat   -row 0 -column 1 -sticky "w"
	grid config $frame1.ra_cont  -row 1 -column 0 -sticky "w"
	grid config $frame1.ra_disco -row 1 -column 1 -sticky "w"
	grid config $frame1.ra_seq   -row 2 -column 0 -sticky "w"
	grid config $frame1.ra_ran   -row 2 -column 1 -sticky "w"
	grid config $frame1 -row 5 -column 0
	
#	scrollbar $titleInnerFrame1.h -orient horizontal -command "$titleInnerFrame1.t_help xview"
#	scrollbar $titleInnerFrame1.v -command "$titleInnerFrame1.t_help yview"
#	text $titleInnerFrame1.t_help -width 40 -height 10 -xscroll "$titleInnerFrame1.h set" -yscroll "$titleInnerFrame1.v set" -state disabled
#	grid config $titleInnerFrame1.t_help -row 5 -column 0
#	grid  $titleInnerFrame1.v -row 5 -column 2 -sticky "ns"
#	grid  $titleInnerFrame1.h -row 6 -column 0 -columnspan 2 -sticky "we"
#	set disptext 0
#	label $titleInnerFrame1.l_empty6 -text ""
#	grid config $titleInnerFrame1.l_empty6  -row 3 -column 0
	####when check buton is selected text is enabled if it is unselected text is disabled
#	checkbutton $titleInnerFrame1.ch_help -text "Add Help Messages" -variable disptext -onvalue 1 -offvalue 0 -command {
#		global $titleInnerFrame1
#		if {$disptext==1} {
#			$titleInnerFrame1.t_help config -state normal -background white
#		} else {
#			$titleInnerFrame1.t_help config -state disabled -background lightgrey
#		}
#	}
#	grid config $titleInnerFrame1.ch_help -row 4 -column 0
#	label $titleInnerFrame1.l_empty7 -text ""
#	grid config $titleInnerFrame1.l_empty7  -row 7 -column 0
	button $frame4.b_ok -text "  Ok  " -command { 
							set testGroupName [string trim $testGroupName]
							if {$testGroupName==""} {
								tk_messageBox -message "Enter CN name" -icon error -parent .addTestGroup
								return
							}
							set execCount [string trim $execCount]
							if {$execCount==""} {
								tk_messageBox -message "Enter value for Execution Count" -icon error -parent .addTestGroup
								return
							} elseif {$execCount>10000} {
								tk_messageBox -message "Enter value less than 10000" -icon error -parent .addTestGroup
								return
							}
#							if {$disptext==1} {
#								set helpMsg [string trim [$titleInnerFrame1.t_help get @0,0 end]]
#							} else {
#								set helpMsg ""
#							}
							AddTestGroup
							font delete custom1
							destroy .addTestGroup
						    }
	button $frame4.b_cancel -text "Cancel" -command {
								destroy .addTestGroup
								font delete custom1
							}
	grid config $frame4.b_ok  -row 0 -column 0 
	grid config $frame4.b_cancel -row 0 -column 1
	grid config $frame4 -row 8 -column 0 
	bind $winAddTestGroup <KeyPress-Return> {  
							set testGroupName [string trim $testGroupName]
							if {$testGroupName==""} {
								tk_messageBox -message "Enter TestGroup name" -icon error -parent .addTestGroup
								return
							}
							set execCount [string trim $execCount]
							if {$execCount==""} {
								tk_messageBox -message "Enter value for Execution Count" -icon error -parent .addTestGroup
								return
							} elseif {$execCount>10000} {
								tk_messageBox -message "Enter value less than 10000" -icon error -parent .addTestGroup
								return
							}
#							if {$disptext==1} {
#								set helpMsg [string trim [$titleInnerFrame1.t_help get @0,0 end]]
#							} else {
#								set helpMsg ""
#							}
							AddTestGroup
							font delete custom1
							destroy .addTestGroup
						    }
	label $winAddTestGroup.l_empty8 -text ""
	grid config $winAddTestGroup.l_empty8 -row 4 -column 0 -sticky "news"
	label $winAddTestGroup.l_empty9 -text ""
	grid config $winAddTestGroup.l_empty9 -row 5 -column 0 -sticky "news"
	wm protocol .addTestGroup WM_DELETE_WINDOW {
							font delete custom1
							destroy .addTestGroup
						   }
}

##############################################################################
# proc ConfigTestGroup
# inputs -nil
# outputs -nil
# Pops up a window contain entry and combobox, get the data from user and 
# stores it in Global data
################################################################################
proc ConfigTestGroup {} {
	global disptext
	global helpMsg
	global execCount
	global memGroupExecMode
	global titleInnerFrame1
	global mode_interactive
	global mode_continuous
	global mode_sequence
	set groupno [GetCurrentNodeNum]
	# on startup set options to defaults
	default_ExecModeOptions
	set winConfigGroup .configTestGroup
	catch "destroy $winConfigGroup"
	toplevel     $winConfigGroup
	wm title     $winConfigGroup "Configure Test Group"
	wm resizable $winConfigGroup 0 0
	wm transient $winConfigGroup .
	wm deiconify $winConfigGroup
	grab $winConfigGroup
	#wm minsize   $winAddTestGroup 300 400
	#wm maxsize   $winAddTestGroup 250 400
	font create custom -weight bold
	label $winConfigGroup.l_empty1 -text ""	
	label $winConfigGroup.l_title -text "Configure Test Group" -font custom
	label $winConfigGroup.l_empty2 -text ""
	
	grid config $winConfigGroup.l_empty1 -row 0 -column 0 -sticky "news"
	grid config $winConfigGroup.l_title  -row 1 -column 0 -sticky "news" -ipadx 125
	grid config $winConfigGroup.l_empty2 -row 2 -column 0 -sticky "news"
	set titleFrame1 [TitleFrame $winConfigGroup.titleFrame1 -text "Configure Group" ]
	grid config $titleFrame1 -row 3 -column 0 -ipadx 20 -sticky "news"
	set titleInnerFrame1 [$titleFrame1 getframe]
	
	set titleFrame2 [TitleFrame $titleInnerFrame1.titleFrame2 -text "Configuration"]  
	grid config $titleFrame2 -row 2 -column 0 -ipadx 5  -sticky "news"
	set titleInnerFrame2 [$titleFrame2 getframe]
		
	####frame1 has six radio buttons to select excution mode 
	set frame1 [frame $titleInnerFrame2.fram1]
	
	#### frame3 has label Execution count and the entry box
	set frame3 [frame $titleInnerFrame2.fram3]
	#### frame 4 has ok and cancel button
	set frame4 [frame $titleInnerFrame1.fram4]
	set frame5 [frame $titleInnerFrame1.fram5]
	
	label $titleInnerFrame1.l_empty3 -text ""
	grid config $titleInnerFrame1.l_empty3  -row 1 -column 0
	label $titleInnerFrame2.l_empty4 -text ""
	grid config $titleInnerFrame2.l_empty4  -row 0 -column 0 	
	label $frame3.l_exe -text "Execution Count :"
	set execCount [arrTestGroup($groupno) cget -memGroupExecCount]
	entry $frame3.en_exe -textvariable execCount -background white -validate key -vcmd {expr {[string len %P] <= 5} && {[string is int %P]}}
	grid config $frame3.l_exe  -row 0 -column 0 
	grid config $frame3.en_exe -row 0 -column 1
	grid config $frame3 -row 1 -column 0
	
	label $titleInnerFrame2.l_empty5 -text ""
	grid config $titleInnerFrame2.l_empty5  -row 2 -column 0
	label $titleInnerFrame2.l_mode -text "Execution Mode"
	grid config $titleInnerFrame2.l_mode  -row 3 -column 0 
	
	#variables used for radio buttons
	radiobutton $frame1.ra_inter -text "Interactive"   -variable mode_interactive   -value on 
	radiobutton $frame1.ra_bat   -text "Batch"         -variable mode_interactive   -value off 
	radiobutton $frame1.ra_cont  -text "Continuous"    -variable mode_continuous  -value on 
	radiobutton $frame1.ra_disco -text "Discontinuous" -variable mode_continuous  -value off 
	radiobutton $frame1.ra_seq   -text "Sequence"      -variable mode_sequence     -value on 
	radiobutton $frame1.ra_ran   -text "Random"        -variable mode_sequence     -value off 
	grid config $frame1.ra_inter -row 0 -column 0 -sticky "w"
	grid config $frame1.ra_bat   -row 0 -column 1 -sticky "w"
	grid config $frame1.ra_cont  -row 1 -column 0 -sticky "w"
	grid config $frame1.ra_disco -row 1 -column 1 -sticky "w"
	grid config $frame1.ra_seq   -row 2 -column 0 -sticky "w"
	grid config $frame1.ra_ran   -row 2 -column 1 -sticky "w"
	grid config $frame1 -row 5 -column 0

	scrollbar $titleInnerFrame1.h -orient horizontal -command "$titleInnerFrame1.t_help xview"
	scrollbar $titleInnerFrame1.v -command "$titleInnerFrame1.t_help yview"
	text $titleInnerFrame1.t_help -width 40 -height 10 -xscroll "$titleInnerFrame1.h set" -yscroll "$titleInnerFrame1.v set" 
	set helpMsg [arrTestGroup($groupno) cget -memHelpMsg]
	puts Helpmessage->$helpMsg
	$titleInnerFrame1.t_help insert end $helpMsg	
	grid config $titleInnerFrame1.t_help -row 5 -column 0
	grid  $titleInnerFrame1.v -row 5 -column 2 -sticky "ns"
	grid  $titleInnerFrame1.h -row 6 -column 0 -columnspan 2 -sticky "we"
	if {$helpMsg!=""} {
		set disptext 1
			$titleInnerFrame1.t_help config -state normal -background white
	} else {
		set disptext 0
		$titleInnerFrame1.t_help config -state disable -background lightgrey
	}
	label $titleInnerFrame1.l_empty6 -text ""
	grid config $titleInnerFrame1.l_empty6  -row 3 -column 0
	####when check buton is selected text is enabled if it is unselected text is disabled
	checkbutton $titleInnerFrame1.ch_help -text "Enable/Disable Help Messages" -variable disptext -onvalue 1 -offvalue 0 -command {
 		global $titleInnerFrame1
		if {$disptext==1} {
				$titleInnerFrame1.t_help insert end $helpMsg
			$titleInnerFrame1.t_help config -state normal -background white
		} else {
			$titleInnerFrame1.t_help config -state disabled -background lightgrey
		}
	}
	grid config $titleInnerFrame1.ch_help -row 4 -column 0
	label $titleInnerFrame1.l_empty7 -text ""
	grid config $titleInnerFrame1.l_empty7  -row 7 -column 0
	button $frame4.b_ok -text "  Ok  " -command { 
							global $titleInnerFrame1
							set execCount [string trim $execCount]
							if {$execCount==""} {
								tk_messageBox -message "Enter value for Execution Count" -icon error -parent .configTestGroup
								return
							} elseif {$execCount>10000} {
								tk_messageBox -message "Enter value less than 10000 for Execution Count" -icon error -parent .configTestGroup	
								return
							}
							set groupno [GetCurrentNodeNum]
							set selectvalue [arrTestGroup($groupno) cget -memGroupExecMode]
							# Call the procedure to convert the Button Value to Exact Value
							set groupexecmode [buttontovalue]	
							# Update the TestGroup
							arrTestGroup($groupno)  configure -memGroupExecMode $groupexecmode
							arrTestGroup($groupno)  configure -memGroupExecCount $execCount
							set modifyto [arrTestGroup($groupno) cget -memGroupExecCount]		
							set modifyto [arrTestGroup($groupno) cget -memGroupExecMode]
							set helpMsg [string trim [$titleInnerFrame1.t_help get @0,0 end]]
							# updatetree _draw_tree
							# Delete the Sub Nodes
							set child [$updatetree delete 1 groupExecMode-$groupno]
							set child [$updatetree delete 2 groupExecCount-$groupno]
							if {[arrTestGroup($groupno) cget -memHelpMsg]!=""} {
								set child [$updatetree delete 3 helpMsg-$groupno]
								$updatetree itemconfigure TestGroup-$groupno -image [Bitmap::get openfold]
								arrTestGroup($groupno) configure -memHelpMsg ""
							}
							
							# ReDraw the Sub Nodes groupExecCount, groupTestCase
							set child [$updatetree insert 1 Config-$groupno groupExecMode-$groupno -text $groupexecmode  -open 0 -image [Bitmap::get palette]]
							set child [$updatetree insert 2 Config-$groupno groupExecCount-$groupno -text $groupexeccount  -open 0 -image [Bitmap::get palette]]
							if {$disptext==1 && $helpMsg !=""} {
								set child [$updatetree insert 3 Config-$groupno helpMsg-$groupno -text Message -open 0 -image [Bitmap::get palette]]
								$updatetree itemconfigure TestGroup-$groupno -image [Bitmap::get openfolder_info]
								#arrTestGroup($groupno) configure -memHelpMsg $helpMsg
							} 
							font delete custom
							destroy .configTestGroup
						    }
	button $frame4.b_cancel -text "Cancel" -command {
								destroy .configTestGroup
								font delete custom
							}
	wm protocol .configTestGroup WM_DELETE_WINDOW {
							font delete custom
							destroy .configTestGroup
						   }
	grid config $frame4.b_ok  -row 0 -column 0 
	grid config $frame4.b_cancel -row 0 -column 1
	grid config $frame4 -row 8 -column 0 
	label $winConfigGroup.l_empty8 -text ""
	grid config $winConfigGroup.l_empty8 -row 4 -column 0 -sticky "news"
	label $winConfigGroup.l_empty9 -text ""
	grid config $winConfigGroup.l_empty9 -row 5 -column 0 -sticky "news"
}
#########################################################################################
# proc AddTestCaseWindow
# pops up a window to get all testcase details and then calls AddTestCase procedure
#######################################################################################
proc AddTestCaseWindow {} {
	set winAddTestCase .addTestCase
	global filename
	global testcaseexeccount
	global testcaseheader
	global selectedProfile
	global pro_count
	global addheader
	global breakpt
	catch "destroy $winAddTestCase"
	toplevel     $winAddTestCase
	wm title     $winAddTestCase "Add New Test Case"
	wm resizable $winAddTestCase 0 0
	wm transient $winAddTestCase .
	wm deiconify $winAddTestCase
	grab $winAddTestCase
	#wm minsize   $winAddTestGroup 300 400
	#wm maxsize   $winAddTestGroup 250 400
	font create custom2 -weight bold
	global frame3
	global titleInnerFrame3
	label $winAddTestCase.l_empty1 -text ""	
	label $winAddTestCase.l_title -text "Add New Test Case" -font custom2
	label $winAddTestCase.l_empty2 -text ""
	
	grid config $winAddTestCase.l_empty1 -row 0 -column 0 -sticky "news"
	grid config $winAddTestCase.l_title  -row 1 -column 0 -sticky "news" -ipadx 125
	grid config $winAddTestCase.l_empty2 -row 2 -column 0 -sticky "news"
	
	set titleFrame1 [TitleFrame $winAddTestCase.titleFrame1 -text "New Test Case" ]
	grid config $titleFrame1 -row 3 -column 0 -ipadx 20 -sticky "news"
	set titleInnerFrame1 [$titleFrame1 getframe]

	set titleFrame3 [TitleFrame $titleInnerFrame1.titleFrame3 -text "List of Available Profiles"]
	grid config $titleFrame3 -row 2 -column 0 -ipadx 3 -sticky "news"
	set titleInnerFrame3 [$titleFrame3 getframe]

	set titleFrame2 [TitleFrame $titleInnerFrame1.titleFrame2 -text "Configuration"]  
	grid config $titleFrame2 -row 3 -column 0 -ipadx 5  -sticky "news"
	set titleInnerFrame2 [$titleFrame2 getframe]
	
	for { set chkButtonCount 1} {$chkButtonCount <= $pro_count} {incr chkButtonCount} {
		set state($chkButtonCount) 1
		checkbutton $titleInnerFrame3.cb_profile$chkButtonCount -text [arrProfile($chkButtonCount) cget -memProfileName] -variable state($chkButtonCount)
	}
	$titleInnerFrame3.cb_profile1 select

	set row 0
	for {set profileCount 1 } {$profileCount <= $pro_count} {incr profileCount} {
		grid config $titleInnerFrame3.cb_profile$profileCount -row $row -column 0 -sticky w
		incr row
	}
	#### frame2 has label TestGroupName and the entry box
	set frame2 [frame $titleInnerFrame1.fram2]
	#### frame3 has label Execution count and the entry box
	set frame3 [frame $titleInnerFrame2.fram3]
	#### frame 4 has ok and cancel button
	set frame4 [frame $titleInnerFrame1.fram4]
	set frame5 [frame $titleInnerFrame1.fram5]
	
	label $frame2.l_name -text "Test Case Path :"
	set filename ""
	entry $frame2.en_name -textvariable filename -background white -width 40
	button $frame2.bt_name -text Browse -command {
							set types {
							        {"All C Files"     {.c } }
									{"All Files"     {* } }
							}
							set filename [tk_getOpenFile -title "Add TestCase" -filetypes $types -parent .addTestCase]
							}
	grid config $frame2.l_name  -row 0 -column 0 
	grid config $frame2.en_name -row 0 -column 1 -columnspan 3 
	grid config $frame2.bt_name -row 0 -column 4
	grid config $frame2 -row 0 -column 0
	
	label $frame3.l_empty3 -text ""
	grid config $frame3.l_empty3  -row 1 -column 0
	
	label $titleInnerFrame2.l_empty4 -text ""
	grid config $titleInnerFrame2.l_empty4  -row 0 -column 0 
	
	label $frame3.l_exe -text "Execution Count :"
	set testcaseexeccount 1
	entry $frame3.en_exe -textvariable testcaseexeccount -background white -validate key -vcmd {expr {[string len %P] <= 5} && {[string is int %P]}}
	grid config $frame3.l_exe  -row 0 -column 0 
	grid config $frame3.en_exe -row 0 -column 1 -sticky "w"
	grid config $frame3 -row 1 -column 0
	
	#label $frame3.l_empty11 -text ""
	#grid $frame3.l_empty11 -row 2 -column 3
	label $frame3.l_header -text "Add Header File :" -state disabled
	set testcaseheader ""
	entry $frame3.en_header -textvariable testcaseheader -width 35
	button $frame3.bt_header -text Browse -state disabled -command {
									set types {
       										 {"All Header Files"     {.h } }
       				 					}
									set testcaseheader [tk_getOpenFile -title "Add Header File" -filetypes $types -parent .addTestCase]
									}											
	grid config $frame3.l_header -row 4 -column 0
	grid config $frame3.en_header -row 4 -column 1 -columnspan 3 -sticky "w"
	grid config $frame3.bt_header -row 4 -column 4 
	set addheader 0
	set breakpt 0
	
	####when check buton is selected text is enabled if it is unselected text is disabled
	checkbutton $frame3.ch_addHeader -text "Add Header File" -variable addheader -onvalue 1 -offvalue 0 -command {
		if {$addheader==1} {
			global $frame3
			$frame3.l_header config -state normal
			$frame3.en_header config -state normal -background white
			$frame3.bt_header config -state normal
		} else {
			$frame3.l_header config -state disabled
			$frame3.en_header config -state disabled -background lightgrey
			$frame3.bt_header config -state disabled
		}
	}
	
	grid config $frame3.ch_addHeader -row 3 -column 0
	label $frame3.l_empty10 -text ""
	grid config $frame3.l_empty10 -row 5 -column 0
	checkbutton $frame3.ch_brkpt -text "Set Break Point" -variable breakpt -onvalue 1 -offvalue 0 -command {}
	grid config $frame3.ch_brkpt -row 6 -column 0
	label $frame3.l_empty7 -text ""
	grid config $frame3.l_empty7  -row 7 -column 0
	button $frame4.b_ok -text "  Ok  " -command {
							global $titleInnerFrame3
							set selectedProfile ""
							if {$filename==""} {
								tk_messageBox -message "TestCase not selected" -icon error
								focus .addTestCase
								return
							}
							if {![file isfile $filename]} {
								tk_messageBox -message "Entered test case path is not a file" -icon error -parent .addTestCase
								focus .addTestCase
								return
							}						
							set testcaseexeccount [string trim $testcaseexeccount]
							if {$testcaseexeccount=="" } {
								tk_messageBox -message "Execution Count cannot be empty" -icon error -parent .addTestCase
								set testcaseexeccount 1
								focus .addTestCase
								return
							}
							if {$testcaseexeccount > 10000} {
								tk_messageBox -message "Execution Count should be less than 10000" -icon error -parent .addTestCase
								set testcaseexeccount 1
								focus .addTestCase
								return
							}
							set testcaseheader [string trim $testcaseheader]
							if {$addheader==1} {
								if {![file isfile $testcaseheader]} {
									tk_messageBox -message "Entered header file path is not a file" -icon error -parent .addTestCase
									focus .addTestCase
									return
								}
							}
							if {$addheader==0} {
								set testcaseheader "None"
							}
							if {$breakpt==1} {
								set runoptions "CB"
							} else {
								set runoptions "CN"
							}
							for {set chkButtonCount 1} { $chkButtonCount<=$pro_count } {incr chkButtonCount} {
								global state($chkButtonCount)
								if {$state($chkButtonCount) == 1 } {
									lappend selectedProfile [$titleInnerFrame3.cb_profile$chkButtonCount cget -text]
								}
							}
							if {$selectedProfile==""} {
								tk_messageBox -message "Select atleast one profile" -icon error -parent .addTestCase
								focus .addTestCase
								return
							}
							set filename [getRelativePath $filename $PjtDir]
							if {$testcaseheader!="None"} {
								set testcaseheader [getRelativePath $testcaseheader $PjtDir]
							}
							AddTestCase
							destroy .addTestCase
							font delete custom2
						     }
								
	button $frame4.b_cancel -text "Cancel" -command { 
							destroy .addTestCase
							font delete custom2
					       }
	wm protocol .addTestCase WM_DELETE_WINDOW {
							font delete custom2
							destroy .addTestCase
						   }
	grid config $frame4.b_ok  -row 0 -column 0 
	grid config $frame4.b_cancel -row 0 -column 1
	grid config $frame4 -row 8 -column 0 
	
	label $winAddTestCase.l_empty8 -text ""
	grid config $winAddTestCase.l_empty8 -row 4 -column 0 -sticky "news"
	label $winAddTestCase.l_empty9 -text ""
	grid config $winAddTestCase.l_empty9 -row 5 -column 0 -sticky "news"
}
#################################################################
# proc BreakPoint
#Sets or removes the break point for the current testcase
################################################################
proc BreakPoint {} {
	global updatetree
	global runoptions
	set testCaseNo [GetCurrentNodeNum]
	set testGroupNo [GetPreviousNum]
	set runoptions [arrTestCase($testGroupNo)($testCaseNo) cget -memCaseRunoptions]
	set node [$updatetree selection get]
	if {$runoptions=="CN"} {
		arrTestCase($testGroupNo)($testCaseNo) configure -memCaseRunoptions "CB"
		$updatetree itemconfigure $node -image [Bitmap::get file_brkpoint]
		$updatetree closetree $node
	} elseif {$runoptions=="NN"} {
		arrTestCase($testGroupNo)($testCaseNo) configure -memCaseRunoptions "NB"
		$updatetree itemconfigure $node -image [Bitmap::get file_brkpoint]
		$updatetree closetree $node
	} elseif {$runoptions=="NB"} {
		arrTestCase($testGroupNo)($testCaseNo) configure -memCaseRunoptions "NN"
		$updatetree itemconfigure $node -image [Bitmap::get file]
		$updatetree closetree $node
	} elseif {$runoptions=="CB"} {
		arrTestCase($testGroupNo)($testCaseNo) configure -memCaseRunoptions "CN"
		$updatetree itemconfigure $node -image [Bitmap::get file]
		$updatetree closetree $node
	}
}
###############################################################################
# proc Forcecompile
# Compiles the selected testcase
##############################################################################
proc ForceCompile {} {
	global PjtDir
	global RootDir
	set CaseCount [GetCurrentNodeNum]
	set GroupCount [GetPreviousNum]
	set groupname [arrTestGroup($GroupCount) cget -memGroupName]
	file mkdir $PjtDir/Elfs/$GroupCount-$groupname
	set casename [getAbsolutePath [arrTestCase($GroupCount)($CaseCount) cget -memCasePath] $PjtDir]
	set header [arrTestCase($GroupCount)($CaseCount) cget -memHeaderPath]
	set tmpsplit [split $casename .]
	set output [lindex $tmpsplit [expr [llength $tmpsplit] - 2]]
	set tmpsplit [split $output /]
	set output [lindex $tmpsplit [expr [llength $tmpsplit] - 1]]
	if {$header == "" || $header == "None"} {
		set header "$RootDir/type.h"
		evalCommand . interp0 "make -B -f $PjtDir/makefile --directory=$PjtDir/Elfs/$GroupCount-$groupname/ testcase=$casename header=$header output=$output RootDir=$RootDir"
	} else {
		set header [getAbsolutePath [arrTestCase($GroupCount)($CaseCount) cget -memHeaderPath] $PjtDir]
		evalCommand . interp0 "make -B -f $PjtDir/makefile --directory=$PjtDir/Elfs/$GroupCount-$groupname/ testcase=$casename header=$header output=$output RootDir=$RootDir"
	}	
}
###############################################################################
proc ExportGui {} {	
	global expFldrDirPath
	global tempExpFldrNme
	global .expprj

	set winExpProj .expprj
	catch "destroy $winExpProj"
	toplevel $winExpProj
	wm title	 $winExpProj	"Export"
	wm resizable $winExpProj 0 0
	wm transient $winExpProj .
	wm deiconify $winExpProj
	wm minsize $winExpProj 150 300
	grab $winExpProj
	font create custom3 -weight bold
	label $winExpProj.l_title -text "Export Project" -font custom3
	label $winExpProj.l_empty -text "               "
	set titf1 [TitleFrame $winExpProj.titf1 -text "Export Folder"]
	set tiff2 [$titf1 getframe]
	label $tiff2.l_pjname -text "Export Folder Name :" -justify left
	set PjtName ""
	entry $tiff2.en_pjname -textvariable tempExpFldrNme -background white -relief ridge
	set tempExpFldrNme ""
	label $tiff2.l_pjpath -text "Export Path :" -justify left

	entry $tiff2.en_pjpath -textvariable expFldrDirPath -background white -relief ridge -width 35
	set expFldrDirPath [pwd]
	button $tiff2.bt_pjpath -text Browse -command {
							set expFldrDirPath [tk_chooseDirectory -title "Export Path" -parent .expprj]

							if {$expFldrDirPath == ""} {
								set expFldrDirPath [pwd]			
								focus .expprj
								return
							}
						       }
		label $tiff2.l_empty1 -text "                         "
	button $tiff2.bt_ok -text Ok -command {
						set tempExpFldrNme [string trim $tempExpFldrNme]
						if {$tempExpFldrNme == "" } {
							tk_messageBox -message "Enter Project Name" -title "Set Project Name error" -icon error
							focus .expprj
							return
						}
						if {![file isdirectory $expFldrDirPath]} {
							tk_messageBox -message "Entered path for project is not a Directory" -icon error
							focus .expprj
							return
						}
						if { [string match "*.*" $tempExpFldrNme ] } {
							tk_messageBox -message "Invalid name should not have . " -icon error
							focus .expprj
							return							
			
						}
						if { [string match "*/*" $tempExpFldrNme ] } {
							tk_messageBox -message "Invalid name should not have / " -icon error
							focus .expprj
							return							
			
						}
						if {[file isdirectory $expFldrDirPath/$tempExpFldrNme.tar]==1} {
							set result [tk_messageBox -message "Archive file already exist\nDo you want to overwite it?" -type yesno -icon question -title 			"Question"]
	   						switch -- $result {
	   		     					yes {
									file delete $expFldrDirPath/$tempExpFldrNme.tar
								}
	   		     					no  {
									destroy .expprj
								}
	   		     					cancel {
									conPuts "Open Project Canceled" info
									return
									}
	   						}
						}
							
						ExportProject $expFldrDirPath $tempExpFldrNme
						

						font delete custom3
						destroy .expprj
					}

	button $tiff2.bt_cancel -text Cancel -command { 
							font delete custom3
							destroy .expprj
						      }

	grid config $winExpProj.l_title -row 0 -column 0 -columnspan 5 -sticky "news"
	grid config $tiff2.l_pjname -row 0 -column 0 -sticky w
	grid config $tiff2.en_pjname -row 0 -column 1 -sticky w -columnspan 4
	grid config $tiff2.bt_pjpath -row 1 -column 6
	grid config $tiff2.l_pjpath -row 1 -column 0 -sticky w
	grid config $tiff2.en_pjpath -row 1 -column 1 -sticky w -columnspan 4
	label $tiff2.l_empty2 -text "               "
	grid config $tiff2.l_empty2 -row 2 -column 0
	grid config $tiff2.l_empty1 -row 10 -column 0 -sticky w
	grid config $tiff2.bt_ok -row 11 -column 1 -sticky news -columnspan 1
	grid config $tiff2.bt_cancel -row 11 -column 6 -sticky news
	grid config $titf1 -column 1 -ipadx 10 -row 1
	focus $tiff2.l_pjname

}
###############################################################################
# proc Export
# to export requiired files
##############################################################################
proc ExportProject {expFldrDirPath tempExpFldrNme} {
	global tg_count
	global tc_count
	global totaltc
	global pro_count
	global PjtDir


#set expFldrPth [tk_chooseDirectory -title "Enter location where file is to be exported " -parent .]
set expFldrPth $expFldrDirPath/$tempExpFldrNme
set exportFolderPath /tmp/$tempExpFldrNme
set tarSrcFldr $exportFolderPath
#set tarSrcFldr $exportFolderPath
set folderName [instProject cget -memProjectName]
###to remove extension .pjt so that create folder with same name as project
set folderName [string range $folderName 0 [expr [string length $folderName]-5]]
set tarSrcFile $folderName
#calclated for archiving files used later
#set tarSrcFldr [string range $PjtDir 0 [expr [string length $PjtDir]- [string length $folderName]-1]]
#set tarSrcFile $folderName
######################################
file delete -force $exportFolderPath
file mkdir $exportFolderPath
####copying elfs, logo, make file and myboard_sshscp.exp
set elfsDest $exportFolderPath
append elfsDest /$folderName/Elfs
file mkdir $elfsDest
set elfsSrc $PjtDir
append elfsSrc /Elfs
CpyFolder $elfsSrc $elfsDest

set logoDest $exportFolderPath
append logoDest /$folderName/logs
file mkdir $logoDest
set logoSrc $PjtDir
append logoSrc /logs
CpyFolder $logoSrc $logoDest

set mkfiDest $exportFolderPath
append mkfiDest /$folderName/makefile
set mkfiSrc $PjtDir
append mkfiSrc /makefile
file copy $mkfiSrc $mkfiDest

set boardDest $exportFolderPath
append boardDest /$folderName/myboard_sshscp.exp
set boardSrc $PjtDir
append boardSrc /myboard_sshscp.exp
file copy $boardSrc $boardDest
####storing original structure before editing the contents
	createproject cpyofProject
	cpyofProject configure -memProjectName [instProject cget -memProjectName]
	cpyofProject configure -memTimeout [instProject cget -memTimeout]
	cpyofProject configure -memExecProfile [instProject cget -memExecProfile]
	cpyofProject configure -memMode [instProject cget -memMode]
	cpyofProject configure -memTollbox_path [instProject cget -memTollbox_path]
	cpyofProject configure -memUserInclude_path [instProject cget -memUserInclude_path]
	set oldPro_count $pro_count
	set oldTg_count $tg_count
	for {set count 1} {$count<=$pro_count} {incr count} {
			createprofile cpyofProfile $count
			cpyofProfile($count) configure -memProfileName [arrProfile($count) cget -memProfileName]
	}
	for {set count 1} {$count<=$tg_count} {incr count} {
			createtestgroup cpyofTestGroup $count
			cpyofTestGroup($count) configure -memGroupName [arrTestGroup($count) cget -memGroupName]
			cpyofTestGroup($count) configure -memGroupExecMode [arrTestGroup($count) cget -memGroupExecMode]
			cpyofTestGroup($count) configure -memGroupExecCount [arrTestGroup($count) cget -memGroupExecCount]
			cpyofTestGroup($count) configure -memChecked [arrTestGroup($count) cget -memChecked]
			cpyofTestGroup($count) configure -memHelpMsg [arrTestGroup($count) cget -memHelpMsg]
			set oldTotaltc($count) totaltc($count)
			for {set tccount 1} {$tccount<=$totaltc($count)} {incr tccount} {
				createtestcase cpyofTestCase $count $tccount
				cpyofTestCase($count)($tccount) configure -memCasePath [arrTestCase($count)($tccount) cget -memCasePath]
				cpyofTestCase($count)($tccount) configure -memCaseExecCount [arrTestCase($count)($tccount) cget -memCaseExecCount]
				cpyofTestCase($count)($tccount) configure -memCaseRunoptions [arrTestCase($count)($tccount) cget -memCaseRunoptions]
				cpyofTestCase($count)($tccount) configure -memCaseProfile [arrTestCase($count)($tccount) cget -memCaseProfile]
				cpyofTestCase($count)($tccount) configure -memHeaderPath [arrTestCase($count)($tccount) cget -memHeaderPath]
			}
	}
####altering the structure required to export file and also copying the files into exported files
if {[cpyofProject cget -memTollbox_path]==""} {
	### if tool box path is empty should not change structure and there is no file to copy
	
	
} else {
	set tollboxPathFile $exportFolderPath
	append tollboxPathFile /ToolBox
	file mkdir $tollboxPathFile
	set absTollboxPathSrc [getAbsolutePath [cpyofProject cget -memTollbox_path] $PjtDir]
	CpyFolder $absTollboxPathSrc $tollboxPathFile
	instProject configure -memTollbox_path ./../ToolBox/
}
if {[cpyofProject cget -memUserInclude_path]==""} {
	### user include path is empty should not change structure and there is no file to copy
} else {
	set userincludePathFile $exportFolderPath
	append userincludePathFile /UserIncludeFile
	file mkdir $userincludePathFile
	set absUserincludePathSrc [getAbsolutePath [cpyofProject cget -memUserInclude_path] $PjtDir]
	CpyFolder $absUserincludePathSrc $userincludePathFile
	instProject configure -memUserInclude_path ./../UserIncludeFile/
}

for {set count 1} {$count<=$tg_count} {incr count} {
			set oldTotaltc($count) totaltc($count)
			for {set tccount 1} {$tccount<=$totaltc($count)} {incr tccount} {
				
				set casePathList [split [cpyofTestCase($count)($tccount) cget -memCasePath] /]   
				###need to extract directory in which the test case file resides
				set casePathList [lrange $casePathList [expr [llength $casePathList]-3] end]
				set casePathStr ./../
				append casePathStr [join $casePathList /]
				arrTestCase($count)($tccount) configure -memCasePath $casePathStr
				set caseSrcPath [getAbsolutePath [cpyofTestCase($count)($tccount) cget -memCasePath] $PjtDir]
				set caseDestPath $exportFolderPath
				append caseDestPath /
				append caseDestPath [join $casePathList /]
				CpyTestCase $caseSrcPath $caseDestPath
				if {[cpyofTestCase($count)($tccount) cget -memHeaderPath]=="None"} {
					### if header is empty should not change structure and there is no file to copy
				} else {
					set headPathList [split [cpyofTestCase($count)($tccount) cget -memHeaderPath] /]
					set headPathList [lrange $headPathList [expr [llength $headPathList]-3] end]
					set headPathStr ./../
					append headPathStr [join $headPathList /]
					arrTestCase($count)($tccount) configure -memHeaderPath $headPathStr
					set headSrcPath [getAbsolutePath [cpyofTestCase($count)($tccount) cget -memHeaderPath] $PjtDir]
					set headDestPath $exportFolderPath
					append headDestPath /
					append headDestPath [join $headPathList /]
					CpyTestCase $headSrcPath $headDestPath				
					
				}
			}
}
set projectPath $exportFolderPath
append projectPath /$folderName/$folderName.pjt


set ret_writ [initwritexml $projectPath]


#tempExpFldrNme
exec tar -Pcvzf "$expFldrPth.tar"  -C /tmp $tempExpFldrNme
#exec tar -Pcvzf "$expFldrPth.tar"  -C $tarSrcFldr $tarSrcFile
file delete -force $exportFolderPath 

#changing the structure to old form after exporting the file

	instProject configure -memProjectName [cpyofProject cget -memProjectName]
	instProject configure -memTimeout [cpyofProject cget -memTimeout]
	instProject configure -memExecProfile [cpyofProject cget -memExecProfile]
	instProject configure -memMode [cpyofProject cget -memMode]
	instProject configure -memTollbox_path [cpyofProject cget -memTollbox_path]
	instProject configure -memUserInclude_path [cpyofProject cget -memUserInclude_path]
	set oldPro_count $pro_count
	set oldTg_count $tg_count
	for {set count 1} {$count<=$pro_count} {incr count} {
			arrProfile($count) configure -memProfileName [cpyofProfile($count) cget -memProfileName]
	}
	for {set count 1} {$count<=$tg_count} {incr count} {

			arrTestGroup($count) configure -memGroupName [cpyofTestGroup($count) cget -memGroupName]
			arrTestGroup($count) configure -memGroupExecMode [cpyofTestGroup($count) cget -memGroupExecMode]
			arrTestGroup($count) configure -memGroupExecCount [cpyofTestGroup($count) cget -memGroupExecCount]
			arrTestGroup($count) configure -memChecked [cpyofTestGroup($count) cget -memChecked]
			arrTestGroup($count) configure -memHelpMsg [cpyofTestGroup($count) cget -memHelpMsg]
			set oldTotaltc($count) totaltc($count)
			for {set tccount 1} {$tccount<=$totaltc($count)} {incr tccount} {

				arrTestCase($count)($tccount) configure -memCasePath [cpyofTestCase($count)($tccount) cget -memCasePath]
				arrTestCase($count)($tccount) configure -memCaseExecCount [cpyofTestCase($count)($tccount) cget -memCaseExecCount]
				arrTestCase($count)($tccount) configure -memCaseRunoptions [cpyofTestCase($count)($tccount) cget -memCaseRunoptions]
				arrTestCase($count)($tccount) configure -memCaseProfile [cpyofTestCase($count)($tccount) cget -memCaseProfile]
				arrTestCase($count)($tccount) configure -memHeaderPath [cpyofTestCase($count)($tccount) cget -memHeaderPath]
			}
	}
	#Delete the copied structue
	# Delete all the records
	struct::record delete instance cpyofProject
	for {set count 1} {$count<=$pro_count} {incr count} {
		struct::record delete instance cpyofProfile($count)
	}
	for {set count 1} {$count<=$tg_count} {incr count} {
		struct::record delete instance cpyofTestGroup($count)
		for {set tccount 1} {$tccount<=$totaltc($count)} {incr tccount} {
			struct::record delete instance cpyofTestCase($count)($tccount)
		}
	}
	
}
###########################################################
#proc CpyFolder
#input : path of folder whose input is to be copied
#	 path where the copied content is to be stored
# Output: to copy entire content of folder
###########################################################
proc CpyFolder {cpyPath storePath} {
	set count 0
	set lentries [glob -nocomplain [file join $cpyPath "*"]]
	#puts $lentries
	foreach f $lentries {
        	set tail [file tail $f]
		#puts $tail
		#set extsplit [split $tail .]
		set cpyFile [lindex $lentries $count]
		#puts ||||||||$cpyFile
		set storeFile $storePath
		append $storeFile /
		append $storeFile $tail
		#puts !!!!!!!!!$storeFile
		file copy $cpyFile $storeFile
	        incr count
	}
}
###########################################################
#proc CpyTestCase
#input : path of folder whose input is to be copied
#	 path where the copied content is to be stored
# Output: to copy the 
###########################################################
proc CpyTestCase {sourcePath destPath} {
	set testCaseFldr [split $destPath /]
	set testCaseFldr [lrange $testCaseFldr 0 [expr [llength $testCaseFldr]-3]]
	set testCaseFldr [join $testCaseFldr /]
	append testCaseFldr /
        #puts [file isdirectory $testCaseFldr]
	if {[file isdirectory $testCaseFldr]==1} {
		#folder already exist
		
	} else {
		file mkdir $testCaseFldr
	}
	if {[file isfile $destPath]==1} {
		#file already exist
	} else {
		file copy $sourcePath $destPath
	}
}
#############################################
#proc Import
#
#############################################
proc ImportProject {} {
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
        {"All Project Files"     {*.tar } }
	}
	########### Before Closing Write the Data to the file ##########

	# Validate filename

	set projectfilename [tk_getOpenFile -filetypes $types -parent .]
        if {$projectfilename == ""} {
                return
        }

	
	set tmpsplit [split $projectfilename /]
	set tarDestPath [lrange $tmpsplit 0 [expr [llength $tmpsplit] - 2]]
	set tarDestPath [join $tarDestPath /]
	set tempPjtName [lindex $tmpsplit [expr [llength $tmpsplit] - 1]]
	set tempPjtName [string range $tempPjtName 0 [expr [string length $tempPjtName]-5]]
	puts "Project name->$tempPjtName"
	set ext [file extension $projectfilename]
	    if { $ext != "" } {
	        if {[string compare $ext ".tar"]} {
		    set PjtDir None
		    tk_messageBox -message "Extension $ext not supported" -title "Import Project Error" -icon error
		    return
	        }
	    }
	# to remove .tar from archive file .extracted folder has same name
	set tempPjtDir [string range $projectfilename 0 [expr [string length $projectfilename]-5]]

	exec tar -xvf $projectfilename -C $tarDestPath

	#call procedure here to find .pjt file and should check for it if not it is some other .tar file
	set chk [ FindChkPjt $tempPjtDir ]
	
	if { $chk==0 } {
			tk_messageBox -message "Invalid project file" -type ok -title {Information} -icon info
			return			
	} else { 
	}
	
	# Close all the opened files in the pageopened_list  
	set listLength [llength $pageopened_list]
	##puts listLength::$listLength
	for { set tmpcount 1} { $tmpcount < $listLength } { incr tmpcount} {
		Editor::closeFile		
	}
	# Create the New Pageopened_list 
	set pageopened_list START

	# Delete all the records of previously open project
	struct::record delete record recProjectDetail
	struct::record delete record recTestGroup
	struct::record delete record recTestCase
	struct::record delete record recProfile
	# Delete the Tree
	
	$updatetree delete end root TestSuite
	#exec tar -xvf $projectfilename -C $PjtDir
	
	##################################################################
  	### Reading Datas from XML File (Contain FullPath)
    	##################################################################
	DeclareStructure 
   	readxml $PjtDir/$PjtName
    	##################################################################

	InsertTree
	# Open the lattest project's Myboard_sshscp.exp
	Editor::tselectObject "myboard_sshscp.exp"


}
###################################################
#proc 

#to find directory in which the  project is saved
##################################################
proc FindChkPjt { tempPjtDir } {
	global PjtDir
	global PjtName
	
	set lentries1 [glob -nocomplain [file join $tempPjtDir "*"]]
	foreach f1 $lentries1 {
        	set tail1 [file tail $f1]
		set extsplit1 [split $tail1 .]
		set extention1 [lindex $extsplit1 [expr [llength $extsplit1] - 1]]
		set tempF1 [split $f1 /]
		set tempF1 [lindex $tempF1 [expr [llength $tempF1] - 1]]
        	if { [file isdirectory $f1] } {
			set lentries2 [glob -nocomplain [file join $f1 "*"]]
			foreach f2 $lentries2 {
        			set tail2 [file tail $f2]
				set extsplit2 [split $tail2 .]
				set extention2 [lindex $extsplit2 [expr [llength $extsplit2] - 1]]
				set tempF2 [split $f2 /]
				if { "$tempF1.pjt" == $tail2 } {
					puts { pjt file is found }
					set PjtDir $f1
					set PjtName $tail2
					return 1
				} else {
				}
			}
        	} else {
        	}
    	}
	return 0	
}

proc YetToImplement {} {
tk_messageBox -message "Yet to be Implemented !" -title Info -icon info
}

proc AddPDOProc {} {
	global testGroupName
	global execCount
	global mode_interactive
	global mode_continuous
	global mode_sequence
	global titleInnerFrame1
	global helpMsg
	global disptext
	set testGroupName ""
	set execCount 1
	set winAddPDO .addPDO
	catch "destroy $winAddPDO"
	toplevel     $winAddPDO
	wm title     $winAddPDO "Add PDOs"
	wm resizable $winAddPDO 0 0
	wm transient $winAddPDO .
	wm deiconify $winAddPDO
	grab $winAddPDO

	font create custom1 -weight bold
	label $winAddPDO.l_empty1 -text ""	
	label $winAddPDO.l_title -text "Add Process Data Object(s)" -font custom1
	label $winAddPDO.l_empty2 -text ""
	
	grid config $winAddPDO.l_empty1 -row 0 -column 0 -sticky "news"
	grid config $winAddPDO.l_title  -row 1 -column 0 -sticky "news" -ipadx 125
	grid config $winAddPDO.l_empty2 -row 2 -column 0 -sticky "news"

	set titleFrame1 [TitleFrame $winAddPDO.titleFrame1 -text "PDO" ]
	grid config $titleFrame1 -row 3 -column 0 -ipadx 20 -sticky "news"
	set titleInnerFrame1 [$titleFrame1 getframe]
	
	set titleFrame2 [TitleFrame $titleInnerFrame1.titleFrame2 -text "Configuration"]  
	grid config $titleFrame2 -row 2 -column 0 -ipadx 0  -sticky "news"
	set titleInnerFrame2 [$titleFrame2 getframe]
	
	####frame1 has six radio buttons to select excution mode 
	set frame1 [frame $titleInnerFrame2.fram1]
	#### frame2 has label TestGroupName and the entry box
	set frame2 [frame $titleInnerFrame1.fram2]
	#### frame3 has label Execution count and the entry box
	set frame3 [frame $titleInnerFrame2.fram3]
	#### frame 4 has ok and cancel button
	set frame4 [frame $titleInnerFrame1.fram4]
	set frame5 [frame $titleInnerFrame1.fram5]
	
#	label $frame2.l_name -text "CN Name :"
#	entry $frame2.en_name -textvariable testGroupName -background white
#	grid config $frame2.l_name  -row 0 -column 0 
#	grid config $frame2.en_name -row 0 -column 1
#	grid config $frame2 -row 0 -column 0

#	label $titleInnerFrame1.l_empty3 -text ""
#	grid config $titleInnerFrame1.l_empty3  -row 1 -column 0
	
#	label $titleInnerFrame2.l_empty4 -text ""
#	grid config $titleInnerFrame2.l_empty4  -row 0 -column 0 
	
	label $frame3.l_pdostart -text "PDO Starting number \[1-255\] :"
	entry $frame3.en_pdostart -textvariable pdostartValue -background white -validate key -vcmd {expr {[string len %P] <= 5} && {[string is int %P]}}

	label $frame3.l_MapEnt -text "Mapping Entries \[1-254\] :"
	entry $frame3.en_MapEnt -textvariable MapEntValue -background white -validate key -vcmd {expr {[string len %P] <= 5} && {[string is int %P]}}

	label $frame3.l_NoPDO -text "Number of PDOs \[1-255\] :"
	entry $frame3.en_NoPDO -textvariable NoPDOValue -background white -validate key -vcmd {expr {[string len %P] <= 5} && {[string is int %P]}}

#button $frame3.bt_name -text Browse -command {
#						set types {
#						        {"All XDC Files"     {.XDC } }
#							}
#						set filename [tk_getOpenFile -title "Add TestCase" -filetypes $types -parent .]
#					}
	grid config $frame3.l_pdostart  -row 0 -column 0 
	grid config $frame3.en_pdostart -row 0 -column 1
	grid config $frame3.l_MapEnt  -row 1 -column 0 
	grid config $frame3.en_MapEnt -row 1 -column 1
	grid config $frame3.l_NoPDO  -row 2 -column 0 
	grid config $frame3.en_NoPDO -row 2 -column 1

#	grid config $frame3.bt_name -row 0 -column 2
	grid config $frame3 -row 1 -column 0
	
	label $titleInnerFrame2.l_empty5 -text "Kind of PDO"
	grid config $titleInnerFrame2.l_empty5  -row 2 -column 0
	#label $titleInnerFrame2.l_mode -text "Type of CN"
	#grid config $titleInnerFrame2.l_mode  -row 3 -column 0 
	
	#variables used for radio buttons
	set mode_interactive on
	set mode_continuous on
	set mode_sequence on
	radiobutton $frame1.ra_inter -text "Transmit PDO"   -variable mode_interactive   -value on 
	radiobutton $frame1.ra_bat   -text "Receive PDO"         -variable mode_interactive   -value off 
	label $frame1.ra_cont  -text ""
	label $frame1.ra_disco -text "" 
	label $frame1.ra_seq   -text "" 
	label $frame1.ra_ran   -text "" 
	grid config $frame1.ra_inter -row 0 -column 0 -sticky "w"
	grid config $frame1.ra_bat   -row 0 -column 1 -sticky "w"
	grid config $frame1.ra_cont  -row 1 -column 0 -sticky "w"
	grid config $frame1.ra_disco -row 1 -column 1 -sticky "w"
	grid config $frame1.ra_seq   -row 2 -column 0 -sticky "w"
	grid config $frame1.ra_ran   -row 2 -column 1 -sticky "w"
	grid config $frame1 -row 5 -column 0
	
#	scrollbar $titleInnerFrame1.h -orient horizontal -command "$titleInnerFrame1.t_help xview"
#	scrollbar $titleInnerFrame1.v -command "$titleInnerFrame1.t_help yview"
#	text $titleInnerFrame1.t_help -width 40 -height 10 -xscroll "$titleInnerFrame1.h set" -yscroll "$titleInnerFrame1.v set" -state disabled
#	grid config $titleInnerFrame1.t_help -row 5 -column 0
#	grid  $titleInnerFrame1.v -row 5 -column 2 -sticky "ns"
#	grid  $titleInnerFrame1.h -row 6 -column 0 -columnspan 2 -sticky "we"
#	set disptext 0
#	label $titleInnerFrame1.l_empty6 -text ""
#	grid config $titleInnerFrame1.l_empty6  -row 3 -column 0
	####when check buton is selected text is enabled if it is unselected text is disabled
#	checkbutton $titleInnerFrame1.ch_help -text "Add Help Messages" -variable disptext -onvalue 1 -offvalue 0 -command {
#		global $titleInnerFrame1
#		if {$disptext==1} {
#			$titleInnerFrame1.t_help config -state normal -background white
#		} else {
#			$titleInnerFrame1.t_help config -state disabled -background lightgrey
#		}
#	}
#	grid config $titleInnerFrame1.ch_help -row 4 -column 0
#	label $titleInnerFrame1.l_empty7 -text ""
#	grid config $titleInnerFrame1.l_empty7  -row 7 -column 0
	button $frame4.b_ok -text "  Add  " -command { 
							YetToImplement
							font delete custom1
							destroy .addPDO
						    }
	button $frame4.b_cancel -text "Cancel" -command {
								destroy .addPDO
								font delete custom1
							}
	grid config $frame4.b_ok  -row 0 -column 0 
	grid config $frame4.b_cancel -row 0 -column 1
	grid config $frame4 -row 8 -column 0 
	bind $winAddPDO <KeyPress-Return> {  
							set testGroupName [string trim $testGroupName]
							if {$testGroupName==""} {
								tk_messageBox -message "Enter TestGroup name" -icon error -parent .addTestGroup
								return
							}
							set execCount [string trim $execCount]
							if {$execCount==""} {
								tk_messageBox -message "Enter value for Execution Count" -icon error -parent .addTestGroup
								return
							} elseif {$execCount>10000} {
								tk_messageBox -message "Enter value less than 10000" -icon error -parent .addTestGroup
								return
							}
#							if {$disptext==1} {
#								set helpMsg [string trim [$titleInnerFrame1.t_help get @0,0 end]]
#							} else {
#								set helpMsg ""
#							}
							AddTestGroup
							font delete custom1
							destroy .addTestGroup
						    }
	label $winAddPDO.l_empty8 -text ""
	grid config $winAddPDO.l_empty8 -row 4 -column 0 -sticky "news"
	label $winAddPDO.l_empty9 -text ""
	grid config $winAddPDO.l_empty9 -row 5 -column 0 -sticky "news"
	wm protocol .addPDO WM_DELETE_WINDOW {
							font delete custom1
							destroy .addTestGroup
						   }
}

proc createSaveButton {tbl row col w} {
    set key [$tbl getkeys $row]
#    button $w -image [Bitmap::get openfold] -highlightthickness 0 -takefocus 0 \
#	      -command [list viewFile $tbl $key]
    button $w -text "Save" -command "YetToImplement" -width 10 -height 1
}

proc createDiscardButton {tbl row col w} {
    set key [$tbl getkeys $row]
#    button $w -image [Bitmap::get openfold] -highlightthickness 0 -takefocus 0 \
#	      -command [list viewFile $tbl $key]
    button $w -text "Discard" -command "YetToImplement" -width 10 -height 1
}

proc createFormatButton {tbl row col w} {
    set key [$tbl getkeys $row]
#    button $w -image [Bitmap::get openfold] -highlightthickness 0 -takefocus 0 \
#	      -command [list viewFile $tbl $key]
    button $w -text "Dec" -command "YetToImplement" -width 1 -height 1
}
