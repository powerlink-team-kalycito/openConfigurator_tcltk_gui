################################################################################
#									
# Script:	operations.tcl						
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
    variable mnMenu
    variable cnMenu
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
    label $aboutWindow.l_msg -image [Bitmap::get info] -compound left -text "\n   PowerLink Configurator Tool       \n       Designed by       \nKalycito Infotech Private Limited.  \n"
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
    # if there�s a pending update only store new range
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
		
		#get rid of the � (as a substitude for a space) in the filename
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
		tk_popup $Editor::cnMenu $x $y	
	} elseif {[regexp {OBD(.*)} $node == 1]} { 
		tk_popup $Editor::mnMenu $x $y		
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
                            # don�t delete console interpreter
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
            tk_messageBox -message "File is write protected!\nCan�t save $filename !"
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
                tk_messageBox -message "Can�t save file $file\nMaybe no write permission!"
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

    exit
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
            		tk_messageBox -message "File is write protected!\nCan�t save $filename !"
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
    variable cnMenu
    variable mnMenu
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

    Editor::tick
    
    # Menu description
    set descmenu {
        "&File" {} {} 0 {           
            {command "New &Project" {} "New Project" {Ctrl n}  -command newprojectWindow}
	    {command "Open Project" {}  "Open Project" {Ctrl o} -command openproject}
            {command "Save Project" {noFile}  "Save Project" {Ctrl s} -command YetToImplement}
            {command "Save Project as" {noFile}  "Save Project as" {} -command saveProjectAsWindow}
	    {command "Close Project" {}  "Close Project" {} -command YetToImplement}                 
	    {separator}
            {command "E&xit" {}  "Exit openCONFIGURATOR" {Alt x} -command Editor::exit_app}
        }
        "&Project" {} {} 0 {
            {command "Build Project    F7" {noFile} "Generate CDC and XML" {} -command YetToImplement }
            {command "Rebuild Project  Ctrl+F7" {noFile} "Clean and Build" {} -command YetToImplement }
	    {command "Clean Project" {noFile} "Clean" {} -command YetToImplement }
	    {command "Stop Build" {}  "Reserved" {} -command YetToImplement -state disabled}
            {separator}
            {command "Project Settings" {}  "Project Settings" {} -command YetToImplement }
        }
        "&Connection" all options 0 {
            {command "Connect to POWERLINK network" {connect} "Establish connection with POWERLINK network" {} -command Connect }
            {command "Disconnect from POWERLINK network" {disconnect} "Disconnect from POWERLINK network" {} -command Disconnect }
	    {separator}
            {command "Connection Settings" {}  "Connection Settings" {} -command ConnectionSettingWindow -state normal}
        }
        "&Actions" all options 0 {
            {command "SDO Read/Write" {noFile} "Do SDO Read or Write" {} -command YetToImplement -state disabled}
            {command "Transfer CDC   Ctrl+F5" {noFile} "Transfer CDC" {} -command YetToImplement }
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
    bind . <Key-F7> "puts {build project short cut}"
    bind . <Control-Key-F7> "puts {Rebuild project short cut}"

    bind . <Control-Key-F5> "puts {Transfer CDC short cut}"
    bind . <Control-Key-F6> "puts {Transfer XML short cut}"
#############################################################################
# Menu for the Controlled Nodes
#############################################################################

    set Editor::cnMenu [menu  .cnMenu -tearoff 0]
    set Editor::IndexaddMenu .cnMenu.cascade
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
     $Editor::cnMenu add command -label "Import XDC" \
            -command {set cursor [. cget -cursor]
			#Call the procedure
			set types {
			        {"All XDC Files"     {.XDC } }
			}
			tk_getOpenFile -title "Import XDC" -filetypes $types -parent .
            		}
	
    
    $Editor::cnMenu add separator
    $Editor::cnMenu add command -label "Delete" -command { YetToImplement }

   
#############################################################################
# Menu for the Managing Nodes
#############################################################################
    set Editor::mnMenu [menu  .mnMenu -tearoff 0]

     $Editor::mnMenu add command -label "Add CN" -command "AddCNWindow" 
     $Editor::mnMenu add separator
     $Editor::mnMenu add command -label "Auto Generate" -command {YetToImplement} 


    
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
    set toolbarButtons(new) [ButtonBox::add $bbox -image [Bitmap::get page_white] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Create new project" -command newprojectWindow]
    set toolbarButtons(save) [ButtonBox::add $bbox -image [Bitmap::get disk] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Save Project" -command YetToImplement]
    set toolbarButtons(saveAll) [ButtonBox::add $bbox -image [Bitmap::get disk_multiple] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Save Project as" -command saveProjectAsWindow]    
    set toolbarButtons(openproject) [ButtonBox::add $bbox -image [Bitmap::get openfolder] \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Open Project" -command openproject]
        
    pack $bbox -side left -anchor w
    #incr prgindic
    set prgindic 0
    set sep0 [Separator::create $tb1.sep0 -orient vertical]
    pack $sep0 -side left -fill y -padx 4 -anchor w
    


    

    
    set bbox [ButtonBox::create $tb1.bbox1b -spacing 0 -padx 4 -pady 1]
    set bb_start [ButtonBox::add $bbox -image [Bitmap::get start] \
            -height 21\
            -width 21\
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Start" -command {YetToImplement}]
    pack $bb_start -side left -padx 4
    pack $bbox -side left -anchor w -padx 2
    
    set bbox [ButtonBox::create $tb1.bbox1c -spacing 1 -padx 1 -pady 1]
    
    set bb_stop [ButtonBox::add $bbox -image [Bitmap::get stop]\
            -height 21\
            -width 21\
            -helptype balloon\
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Stop"\
	    -command "YetToImplement"]
    #puts [$tb1.bbox itemcget -image]
    pack $bb_stop -side left -padx 4

    set bb_reconfig [ButtonBox::add $bbox -image [Bitmap::get reconfig]\
            -height 21\
            -width 21\
            -helptype balloon\
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Reconfigure"\
    	    -command "YetToImplement"]
    pack $bb_reconfig -side left -padx 4
 
    pack $bbox -side left -anchor w
    
 
    
    set sep4 [Separator::create $tb1.sep4 -orient vertical]
    pack $sep4 -side left -fill y -padx 4 -anchor w
    
    set bbox [ButtonBox::create $tb1.bbox6 -spacing 1 -padx 1 -pady 1]
    pack $bbox -side left -anchor w
    set bb_cdc [ButtonBox::add $bbox -image [Bitmap::get transfercdc]\
            -height 21\
            -width 21\
            -helptype balloon\
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Transfer CDC"\
    	    -command "YetToImplement"]
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
    set sep6 [Separator::create $tb1.sep6 -orient vertical]
    pack $sep6 -side left -fill y -padx 4 -anchor w

    set bbox [ButtonBox::create $tb1.bbox7 -spacing 1 -padx 1 -pady 1]
    pack $bbox -side left -anchor w
    set bb_build [ButtonBox::add $bbox -image [Bitmap::get build]\
            -height 21\
            -width 21\
            -helptype balloon\
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Build Project"\
    	    -command "YetToImplement"]
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
    set sep7 [Separator::create $tb1.sep7 -orient vertical]
    pack $sep7 -side left -fill y -padx 4 -anchor w
    
    set bbox [ButtonBox::create $tb1.bbox8 -spacing 1 -padx 1 -pady 1]
    pack $bbox -side left -anchor w
    set bb_connect [ButtonBox::add $bbox -image [Bitmap::get disconnect]\
            -height 21\
            -width 21\
            -helptype balloon\
            -helptext "connection"\
            -command connectio ]
    pack $bb_connect -side left -padx 4  

    set sep8 [Separator::create $tb1.sep8 -orient vertical]
    pack $sep8 -side left -fill y -padx 4 -anchor w 

    set f_tb1 [frame $tb1.f]
    label $f_tb1.l_empty -text ""
    radiobutton $f_tb1.ra_dec -text "Dec" -variable hexDec -value on
    radiobutton $f_tb1.ra_hex -text "Hex" -variable hexDec -value off
    pack $f_tb1 -side right -anchor e -expand 1 -padx 100
    grid config $f_tb1.ra_dec -row 0 -column 1 -sticky "w" -padx 5
    grid config $f_tb1.ra_hex -row 0 -column 2 -sticky "w" -padx 5
    $f_tb1.ra_dec select

    incr prgindic
      
    $Editor::mainframe showtoolbar 0 $Editor::toolbar1

    set temp [MainFrame::addindicator $mainframe -text "Current Startfile: " ]
    set temp [MainFrame::addindicator $mainframe -textvariable Editor::current(project) ]
    set temp [MainFrame::addindicator $mainframe -text " File: " ]
    set temp [MainFrame::addindicator $mainframe -textvariable Editor::current(file) ]
    set temp [MainFrame::addindicator $mainframe -textvariable EditorData(cursorPos)]
    set temp [MainFrame::addindicator $mainframe -textvariable clock_var]
    
    # NoteBook creation
    #incr prgindic
    set frame    [$mainframe getframe]
    
    set pw1 [PanedWindow::create $frame.pw -side left]
    set pane [PanedWindow::add $pw1 -minsize 200]
#$pane configure -width 200	
#$pw1 configure -width 200	
    set pw2 [PanedWindow::create $pane.pw -side top]
    
# TODO: Improper Way of implementation. Done to get screenshot of the GUI
    set pw3 [PanedWindow::create $pane.pw1 -side top]
	

    set pane1 [PanedWindow::add $pw2 -minsize 250]

#PanedWindow::configure $pane1 "-width 250"
#PanedWindow $pane1 configure -width 250
$pane1 configure -width 250
$pw2 configure -width 250  
    set pane2 [PanedWindow::add $pw2 -minsize 100]
    set pane3 [PanedWindow::add $pw1 -minsize 100]


    set list_notebook [NoteBook::create $pane1.nb]
    set notebook [NoteBook::create $pane2.nb]	
    set con_notebook [NoteBook::create $pane3.nb]
    
    #set myWin [NoteBook::create $pane4.nb]
    
    set pf1 [EditManager::create_treeWindow $list_notebook]
    set treeWindow $pf1.sw.objTree
   # Editor::openNewPage
    	# Binding on tree widget   
     	$treeWindow bindText <ButtonPress-1> selectobject
	#$treeWindow bindText <Double-1> 
	$treeWindow bindText <Double-1> DoubleClickNode
	
    	$treeWindow bindImage <ButtonPress-1> selectobject
	$treeWindow bindImage <Double-1> Editor::tselectObject

	#$treeWindow bindWindow_userdef <ButtonPress-1> CheckObject
	$treeWindow bindImage <ButtonPress-3> {Editor::tselectright %X %Y}
        
	$treeWindow bindText <ButtonPress-3> {Editor::tselectright %X %Y}
	$treeWindow configure -width 10
    global EditorData
    global PjtDir
    set PjtDir $EditorData(options,History)
    incr prgindic

#    set f0 [EditManager::create_tab $notebook "Index"]

    #set Editor::text_win($Editor::index_counter,undo_id) [new textUndoer [lindex $f0 2]]

$list_notebook configure -width 10    
    NoteBook::compute_size $list_notebook
#pack $pane -side left -expand yes
    #pack $list_notebook -side left -padx 2 -pady 4
    pack $list_notebook -side left -fill both -expand yes -padx 2 -pady 4
 

    # Commented out to remove Editor window    
#    NoteBook::compute_size $notebook

    set cf0 [EditManager::create_conWindow $con_notebook "Console" 1]


#TODO hard coded to bring image
#code for adding image in console

    $con_notebook itemconfigure Console1 -image [Bitmap::get file]
    set cf1 [EditManager::create_conWindow $con_notebook "Error" 2]
   $con_notebook itemconfigure Console2 -image [Bitmap::get error_small]
    set cf2 [EditManager::create_conWindow $con_notebook "Warning" 3]
   $con_notebook itemconfigure Console3 -image [Bitmap::get warning_small]



    NoteBook::compute_size $con_notebook
    #pack $con_notebook -side bottom -padx 4 -pady 4
    pack $con_notebook -side bottom -fill both -expand yes -padx 4 -pady 4
    
#pack $con_notebook1 -side bottom -fill both -expand yes -padx 4 -pady 4

    pack $pw1 -fill both -expand yes


#    pack $notebook -side left -fill both -expand yes -padx 4 -pady 4
    
    #alternate way of creating tab in right note book


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

    set f0 [EditManager::create_tab $notebook "Index"]
    NoteBook::compute_size $notebook
    pack $notebook -side left -fill both -expand yes -padx 4 -pady 4
     set pane4 [lindex $f0 0]
set tbl $pane4.tbl

tablelist::tablelist $pane4.tbl \
    -columns {0 "Label" left
	      0 "Value" center} \
    -setgrid no -width 0 -height 6 \
    -stripebackground gray98  \
    -labelcommand "" \
    -resizable 0 -movablecolumns 0 -movablerows 0 \
    -showseparators 1 -spacing 10 

#label command is to disable sorting 
#resizable doesnt allow the user to change table width 

#$tbl columnconfigure 0 -background #e6e6d3 -width 47
#$tbl columnconfigure 1 -background #e1e1e1 -width 47

$tbl columnconfigure 0 -background #e0e8f0 -width 47
$tbl columnconfigure 1 -background #e0e8f0 -width 47

#$tbl columnconfigure 1 -formatcommand emptyStr -sortmode integer
#$tbl columnconfigure 2 -name fileSize -sortmode integer
#$tbl columnconfigure 4 -name seen


proc emptyStr val { return "" }

eval font create BoldFont [font actual [$tbl cget -font]] -weight bold

#
# Populate the tablelist widget for taking screen shots
#

$tbl insert 0 [list Index: 1006 ""]
$tbl insert 1 [list Name: NMT_CycleLen_U32 ""]
$tbl insert 2 [list Object\ Type: VAR ""]
$tbl insert 3 [list Data\ Type: Unsigned32 ""]
$tbl insert 4 [list Access\ Type: rw ""]
$tbl insert 5 [list Value: 0007 ""]

$tbl cellconfigure 1,1 -editable yes
$tbl cellconfigure 5,1 -editable yes

$tbl columnconfigure 1 -font Courier

# For packing the Tablelist in the right window

#pack $pane4.tbl -fill both -expand yes -padx 4 -pady 4
pack $pane4.tbl  -padx 4 -pady 4
#puts [$pane4.tbl cget -height]
#grid config $pane4.tbl -row 0 -column 0

set frame4 [frame $pane4.f] 
button $frame4.b_sav -text " Save " -command "YetToImplement"
button $frame4.b_dis -text "Discard" -command "YetToImplement"
pack $frame4
grid config $frame4.b_sav -row 0 -column 0
grid config $frame4.b_dis -row 0 -column 1

#forcing the frist tab Tab to be disabled
#Widget::configure $pane4 "-state disabled"


set f1 [EditManager::create_tab $notebook "Sub Index"]
 set pane6 [lindex $f1 0]
set tbl2 $pane6.tbl2

tablelist::tablelist $pane6.tbl2 \
    -columns {0 "Label" left
	      0 "Value" center} \
    -setgrid no -width 0 -height 7 \
    -stripebackground gray98 \
    -labelcommand "" \
    -resizable 0 -movablecolumns 0 -movablerows 0 \
    -showseparators 1 -borderwidth 1 -spacing 10


#$tbl2 columnconfigure 0 -background #dbdbc9 -width 47
#$tbl2 columnconfigure 1 -background #f9cf7e -width 47

$tbl2 columnconfigure 0 -background #e0e8f0 -width 47 
$tbl2 columnconfigure 1 -background #e0e8f0 -width 47

$tbl2 insert 0 [list Index: 1006]
$tbl2 insert 1 [list Sub\ Index: 00]
$tbl2 insert 2 [list Name: NMT_CycleLen_U32]
$tbl2 insert 3 [list Object\ Type: VAR]
$tbl2 insert 4 [list Data\ Type: Unsigned32]
$tbl2 insert 5 [list Access\ Type: rw]
$tbl2 insert 6 [list Value: 0007]


$tbl2 cellconfigure 2,1 -editable yes
$tbl2 cellconfigure 6,1 -editable yes

pack $pane6.tbl2 -fill both -expand yes -padx 4 -pady 4
set frame6 [frame $pane6.f] 
button $frame6.b_sav -text " Save " -command "YetToImplement"
button $frame6.b_dis -text "Discard" -command "YetToImplement"
pack $frame6
grid config $frame6.b_sav -row 0 -column 0
grid config $frame6.b_dis -row 0 -column 1

set f2 [EditManager::create_tab $notebook "PDO mapping"]

     set pane5 [lindex $f2 0]
set tbl1 $pane5.tbl1

tablelist::tablelist $pane5.tbl1 \
    -columns {0 "No" left
	      0 "Mapping Entries" center
	      0 "Index" center
	      0 "Sub Index"
	      0 "Reserved"
	      0 "Offset"
	      0 "Length"} \
    -setgrid 0 -width 0 \
    -stripebackground gray98 \
    -resizable 0 -movablecolumns 0 -movablerows 0 \
    -showseparators 1 -spacing 10


# the column No has onlly integer values som sorting based on integer
$tbl1 columnconfigure 0 -background #e0e8f0 -width 6 -sortmode integer
$tbl1 columnconfigure 1 -background #e0e8f0 -width 23
$tbl1 columnconfigure 2 -background #e0e8f0 -width 11
$tbl1 columnconfigure 3 -background #e0e8f0 -width 11
$tbl1 columnconfigure 4 -background #e0e8f0 -width 11
$tbl1 columnconfigure 5 -background #e0e8f0 -width 11
$tbl1 columnconfigure 6 -background #e0e8f0 -width 11

#$tbl1 columnconfigure 0 -background #f9cf7e -sortmode integer
#$tbl1 columnconfigure 1 -background #f9cf7e
#$tbl1 columnconfigure 2 -background #f9cf7e 
#$tbl1 columnconfigure 3 -background #f9cf7e 
#$tbl1 columnconfigure 4 -background #f9cf7e 
#$tbl1 columnconfigure 5 -background #f9cf7e
#$tbl1 columnconfigure 6 -background #f9cf7e 

$tbl1 insert end [list 65536 0010000000202106 2106 02 00 0000 0010]
$tbl1 insert end [list 2 0008001000202104 2104 02 00 0001 0008]
$tbl1 insert end [list 3 0010000000202106 2106 02 00 0000 0010]
$tbl1 insert end [list 4 0008001000202104 2104 02 00 0001 0008]
$tbl1 insert end [list 5 0010000000202106 2106 02 00 0000 0010]
$tbl1 insert end [list 6 0008001000202104 2104 02 00 0001 0008]
$tbl1 insert end [list 7 0010000000202106 2106 02 00 0000 0010]
$tbl1 insert end [list 8 0008001000202104 2104 02 00 0001 0008]
$tbl1 insert end [list 9 0010000000202106 2106 02 00 0000 0010]
$tbl1 insert end [list 10 0008001000202104 2104 02 00 0001 0008]
$tbl1 insert end [list 11 0010000000202106 2106 02 00 0000 0010]
$tbl1 insert end [list 12 0008001000202104 2104 02 00 0001 0008]
$tbl1 insert end [list 13 0010000000202106 2106 02 00 0000 0010]
$tbl1 insert end [list 14 0008001000202104 2104 02 00 0001 0008]
$tbl1 insert end [list 15 0010000000202106 2106 02 00 0000 0010]
$tbl1 insert end [list 16 0008001000202104 2104 02 00 0001 0008]
$tbl1 insert end [list 17 0010000000202106 2106 02 00 0000 0010]
$tbl1 insert end [list 18 0008001000202104 2104 02 00 0001 0008]
$tbl1 insert end [list 19 0010000000202106 2106 02 00 0000 0010]
$tbl1 insert end [list 20 0008001000202104 2104 02 00 0001 0008]
$tbl1 insert end [list 21 0010000000202106 2106 02 00 0000 0010]
$tbl1 insert end [list 22 0008001000202104 2104 02 00 0001 0008]
$tbl1 insert end [list 23 0010000000202106 2106 02 00 0000 0010]

pack $pane5.tbl1 -fill both -expand yes -padx 4 -pady 4


    
    pack $pw2 -fill both -expand yes

     #incr prgindic



    #incr prgindic
    $list_notebook raise objtree
    $con_notebook raise Console1
    #$con_notebook _select Console1
    $notebook raise [lindex $f0 1]
    #$notebook _select [lindex $f0 1]


    pack $mainframe -fill both -expand yes

#set prgindic -1
set prgindic 0

    update idletasks
    destroy .intro
    wm protocol . WM_DELETE_WINDOW Editor::exit_app
      	if {!$configError} {catch Editor::restoreWindowPositions}


    errorPuts "testing Error.."
    warnPuts "testing Warn.."
    conPuts "testing console"

EditManager::create_table $notebook "Index"

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
#puts "node in doubleclick------------->$node"

	if {$node=="Index_2"} {
		pack .mainframe.topf.tb0.f.ra_dec -side left -padx 5
		pack .mainframe.topf.tb0.f.ra_hex -side left -padx 5
		pack forget .mainframe.topf.tb0.f.ra_dec
		pack forget .mainframe.topf.tb0.f.ra_hex
	} else {
		pack .mainframe.topf.tb0.f.ra_dec -side left -padx 5
		pack .mainframe.topf.tb0.f.ra_hex -side left -padx 5
	}

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




proc AddCN {Name} {
	global updatetree
	global testGroupName
	global tg_count
	set TotalTestGroup $tg_count
	incr TotalTestGroup
	incr tg_count
	set child [$updatetree insert $TotalTestGroup OBD TestGroup-$TotalTestGroup -text "$Name" -open 1 -image [Bitmap::get openfold]]

	return
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


proc YetToImplement {} {
tk_messageBox -message "Yet to be Implemented !" -title Info -icon info
}


#########################################################################3



proc connectio {} {
	set tog [.mainframe.topf.tb0.bbox8.b0 cget -image]
	#puts $tog
	#to toggle image the value varies according to images added 
	if {$tog=="image15"} {
	        .mainframe.topf.tb0.bbox8.b0 configure -image [Bitmap::get connect]
	} else {
	        .mainframe.topf.tb0.bbox8.b0 configure -image [Bitmap::get disconnect]
	}
}
proc Connect {} {
	.mainframe.topf.tb0.bbox8.b0 configure -image [Bitmap::get disconnect]
	.mainframe setmenustate connect disabled
	.mainframe setmenustate disconnect normal
}

proc Disconnect {} {
	.mainframe.topf.tb0.bbox8.b0 configure -image [Bitmap::get connect]
	.mainframe setmenustate disconnect disabled
	.mainframe setmenustate connect normal
}






