##############################################################################
#    editor.tcl --
#    Copyright (C) 1999  Andreas Sievers
#    andreas.sievers@t-online.de
#    Parts are based upon Tcl Developer Studio by Alexey Kakunin
#
##############################################################################

namespace eval editorWindows {
    
    namespace export setBindings create selectAll
    namespace export gotoMark gotoProc findNext setCursor replace replaceAll
    namespace export enableHL disableHL onTabSize onFontChange
    
    variable This
    variable TxtWidget ""
    variable Text ""
    variable UndoID
}

proc editorWindows::setBindings {} {
    global tcl_platform
    global EditorData
    variable TxtWidget
    
    set tabSize [expr {$EditorData(options,tabSize)* [font measure $EditorData(options,fonts,editorFont) -displayof $TxtWidget " "]}]
    for {set i 1} {$i < 11} {incr i} {
        set tab [expr {$tabSize * $i}]
        set tabList [lappend tabList $tab]
    }
    $TxtWidget configure -wrap none -font $EditorData(options,fonts,editorFont) -tabs $tabList
    ConfigureTags
    
    # create bindings
    bind $TxtWidget <Tab> "editorWindows::OnTabPress; break"
    if {$tcl_platform(platform) != "windows"} {
        bind $TxtWidget <Control-Insert> "editorWindows::copy; break"
        bind $TxtWidget <Control-Delete> "editorWindows::cut; break"
        bind $TxtWidget <Shift-Insert>   "editorWindows::paste; break"
        bind $TxtWidget <Control-a> "editorWindows::selectAll; break"
    }
    bind $TxtWidget <KeyPress-Return> {[editorWindows::onKeyPressReturn %A ]}
    bind $TxtWidget <KeyRelease-Return> "editorWindows::IndentCurLine ; editorWindows::OnKeyRelease"
    bind $TxtWidget <KeyRelease-space> "editorWindows::OnSpaceRelease;editorWindows::OnKeyRelease"
    # bind $TxtWidget <KeyRelease-braceright> "editorWindows::IndentCurLine;editorWindows::OnKeyRelease"
    # bind $TxtWidget <KeyRelease-braceleft> "editorWindows::OnLeftBraceRelease;editorWindows::OnKeyRelease"
    bind $TxtWidget <KeyRelease-parenleft> "editorWindows::OnLeftParenRelease;editorWindows::OnKeyRelease"
    # bind $TxtWidget <KeyRelease-bracketleft> "editorWindows::OnLeftBracketRelease;editorWindows::OnKeyRelease"
    bind $TxtWidget <KeyRelease-quotedbl> "editorWindows::OnQuoteDblRelease;editorWindows::OnKeyRelease"
    bind $TxtWidget <KeyPress-Delete> {set Editor::current(char) %A; [ editorWindows::delete ] }
    bind $TxtWidget <Control-h> {set Editor::current(char) %A; [ editorWindows::delete bs ] }
    bind $TxtWidget <BackSpace> {set Editor::current(char) %A; [ editorWindows::delete bs ] }
    bind $TxtWidget <KeyRelease> {editorWindows::OnKeyRelease ; break}
    bind $TxtWidget <KeyPress> {[editorWindows::OnKeyPress %A ] }
    bind $TxtWidget <Button-3> {tk_popup $Editor::textMenu %X %Y ; break}
    bind $TxtWidget <ButtonRelease> editorWindows::OnMouseRelease
    bind $TxtWidget <Control-x> "Editor::cut; break"
    bind $TxtWidget <Control-c> "Editor::copy; break"
    bind $TxtWidget <Control-v> "Editor::paste; break"
    bind $TxtWidget <Control-y> "Editor::delLine ; break"
    bind $TxtWidget <KeyRelease-Home> "editorWindows::gotoFirstChar;break"
    bind $TxtWidget <Control-l> "repeat_last_search $TxtWidget"
    return
}

proc editorWindows::OnKeyPress {key} {
    variable TxtWidget
    global EditorData
    
    set Editor::current(char) $key
    switch -regexp -- $key {
        
        {.} {
            #printable chars and Return
            if {[$TxtWidget tag ranges sel] != "" && $EditorData(options,autoUpdate)} {
                set start [$TxtWidget index sel.first]
                set end [$TxtWidget index sel.last]
                set range [editorWindows::deleteMarks $start $end]
                $TxtWidget mark set delStart [lindex $range 0]
                $TxtWidget mark gravity delStart left
                $TxtWidget mark set delEnd [lindex $range 1]
                $TxtWidget delete sel.first sel.last
                $TxtWidget insert insert $key
                if {[$TxtWidget compare insert > delEnd]} {
                    $TxtWidget mark set delEnd insert
                }
                Editor::updateOnIdle [list [$TxtWidget index delStart] [$TxtWidget index delEnd]]
                $TxtWidget mark unset delStart
                $TxtWidget mark unset delEnd
                return break
            } else  {
                set rexp {^(( |\t|\;)*((namespace )|(class )|(proc )|(body )|(configbody )))|((( |\t|\;)*[^\#]*)((method )|(constructor )|(destructor )))}
                if {[regexp $rexp [$TxtWidget get "insert linestart" "insert lineend"]]} {
                    set Editor::current(isNode) 1
                } else  {
                    set Editor::current(isNode) 0
                }
            }
        }
        
        default  {
            #non printable chars
            return list
        }
    }
    return list
}

proc editorWindows::gotoFirstChar {} {
    variable TxtWidget
    
    set curPos [$Editor::current(text) index insert]
    set result [Editor::getFirstChar $curPos]
    $TxtWidget mark set insert [lindex $result 1]
    
}

# edit-copy
proc editorWindows::copy {} {
    variable TxtWidget
    
    if {[catch {$TxtWidget index sel.first}]} {
        return
    }
    
    set lineStart [lindex [split [$TxtWidget index sel.first] "."] 0]
    set lineEnd [lindex [split [$TxtWidget index sel.last] "."] 0]
    
    tk_textCopy $TxtWidget
    
    ReadCursor
    ColorizeLines $lineStart $lineEnd
    
    return
}

# edit-cut
proc editorWindows::cut {} {
    variable TxtWidget
    global EditorData
    
    if {$TxtWidget == ""} {
        return
    }
    if {[$TxtWidget tag ranges sel] != "" && $EditorData(options,autoUpdate)} {
        set start [$TxtWidget index sel.first]
        set end [$TxtWidget index sel.last]
        set rexp {(^( |\t|\;)*namespace )|(^( |\t|\;)*class )|(^( |\t|\;)*proc )|(method )|(^( |\t|\;)*body )|(constructor )|(destructor )}
        if {[regexp $rexp [$TxtWidget get $start $end]]} {
            set range [editorWindows::deleteMarks $start $end]
            $TxtWidget mark set delStart [lindex $range 0]
            $TxtWidget mark gravity delStart left
            $TxtWidget mark set delEnd [lindex $range 1]
            tk_textCut $TxtWidget
            Editor::updateOnIdle [list [$editorWindows::TxtWidget index delStart] [$TxtWidget index delEnd]]
            $TxtWidget mark unset delStart
            $TxtWidget mark unset delEnd
        } else  {
            tk_textCut $TxtWidget
            update
        }
    } else  {
        tk_textCut $TxtWidget
        update
    }
    ReadCursor
    
    set lineNum [lindex [split [$TxtWidget index insert] "."] 0]
    
    ColorizeLines $lineNum $lineNum
    
    return
}

# edit-paste
proc editorWindows::paste {} {
    global tcl_platform
    global EditorData
    variable TxtWidget
    
    if {$TxtWidget == "" || [focus] != $TxtWidget} {
        return
    }
    if {$EditorData(options,autoUpdate)} {
        if {[$TxtWidget tag ranges sel] == "" } {
            #get prev NodeIndex boundaries
            set range [getUpdateBoundaries insert]
            set start [lindex $range 0]
            set end [lindex $range 1]
            tk_textPaste $TxtWidget
            
            $TxtWidget see insert
            if {[$TxtWidget compare insert > $end]} {
                set end [$TxtWidget index insert]
            }
            Editor::updateOnIdle [list $start $end]
        } else  {
            set lineStart [lindex [split [$TxtWidget index sel.first] "."] 0]
            set start [$TxtWidget index sel.first]
            set end [$TxtWidget index sel.last]
            set range [editorWindows::deleteMarks $start $end]
            $TxtWidget mark set delStart [lindex $range 0]
            $TxtWidget mark gravity delStart left
            $TxtWidget mark set delEnd [lindex $range 1]
            if {"$tcl_platform(platform)" == "unix"} {
                catch { $TxtWidget delete sel.first sel.last }
            }
            tk_textPaste $TxtWidget
            $TxtWidget see insert
            if {[$TxtWidget compare insert > $end]} {
                set end [$TxtWidget index insert]
            }
            Editor::updateOnIdle [list $start $end]
            $TxtWidget mark unset delStart
            $TxtWidget mark unset delEnd
        }
    }
    update idletasks
    ReadCursor
    set lineStart [lindex [split [$TxtWidget index $start] "."] 0]
    set lineEnd [lindex [split [$TxtWidget index $end] "."] 0]
    ColorizeLines $lineStart $lineEnd
    autoIndent $lineStart.0 "$lineEnd.0 lineend"
    return
}

proc editorWindows::getMarkNames {start end} {
    variable TxtWidget
    
    if {[$TxtWidget index end] == $end} {
        set end "end -1c"
    }
    set markList [array names Editor::procMarks]
    set resultList ""
    set markIndex [$TxtWidget index $start]
    while {[$TxtWidget compare $markIndex <= $end]} {
        #get the right mark
        foreach { type markName index} [$TxtWidget dump -mark $markIndex] {
            set result [lsearch $markList $markName]
            if {$result != -1} {
                lappend resultList $markName
            }
        }
        set markName [$TxtWidget mark next "$markIndex +1c"]
        if {$markName == ""} {
            break
        } else  {
            set markIndex [$TxtWidget index $markName]
        }
    }
    return $resultList
}

proc editorWindows::getUpdateBoundaries {start {end insert}} {
    variable TxtWidget
    set start [$TxtWidget index "$start linestart"]
    set end [$TxtWidget index "$end lineend"]
    set markList [editorWindows::getMarkNames $start $end]
    if {$markList == ""} {
        return [list $start $end]
    }
    # set boundaries to start or end of a node array
    foreach markName $markList {
        #get counterMark
        set counterMark ""
        if {[regexp "(_end_of_proc)$" $markName]} {
            #this is an end mark
            regsub "(_end_of_proc)$" $markName "" counterMark
            if {[$TxtWidget compare $counterMark < $start]} {
                set start $counterMark
            }
        } else  {
            #this is a start mark
            append counterMark $markName "_end_of_proc"
            if {[$TxtWidget compare $counterMark > $end]} {
                set end $counterMark
            }
        }
    } ;#end of foreach
    #now we should have the correct boundaries
    set start [$TxtWidget index $start]
    set end [$TxtWidget index $end]
    return [list $start $end]
}

proc editorWindows::deleteMarks {start end} {
    global EditorData
    variable TxtWidget
    
    set range [getUpdateBoundaries $start $end]
    set start [lindex $range 0]
    set end [lindex $range 1]
    set markList [editorWindows::getMarkNames $start $end]
    if {$markList != ""} {
        foreach markName $markList {
            #do not delete duplicates or namespaces or classes with children
            if {[$TxtWidget compare $markName > $end] || [$TxtWidget compare $markName < $start]} {
                continue
            }
            set tempName $markName
            regsub {_end_of_proc} $markName "" tempName
            if {[$Editor::treeWindow exists $tempName]} {
                set type [lindex [$Editor::treeWindow itemcget $tempName -data] 0]
            } else  {
                set type normal
            }
            switch -- $type {
                "class" -
                "namespace" {
                    # if there are remaining nodes, don´t delete namespace/class
                    if {[$Editor::treeWindow nodes $tempName] != ""} {
                        $TxtWidget mark set $markName 1.0
                    } else  {
                        if {$markName == $tempName} {
                            Editor::tdelNode $tempName
                        }
                        #get counterMark
                        set counterMark ""
                        if {[regexp "(_end_of_proc)$" $markName]} {
                            #this is an end mark
                            regsub "(_end_of_proc)$" $markName "" counterMark
                        } else  {
                            #this is a start mark
                            append counterMark $markName "_end_of_proc"
                        }
                        catch {$TxtWidget mark unset $markName}
                        catch {unset Editor::procMarks($markName)}
                    }
                }
                "file" -
                "code" {
                    #skip
                }
                default {
                    if {$markName == $tempName} {
                        Editor::tdelNode $markName
                    }
                    catch {$TxtWidget mark unset $markName}
                    catch {unset Editor::procMarks($markName)}
                }
            }
        }
    }
    return [list $start $end]
}

# edit-delete
proc editorWindows::delete {{backspace ""}} {
    global tcl_platform
    global EditorData
    variable TxtWidget
    
    if {$TxtWidget == "" || !$EditorData(options,autoUpdate)} {
        return list
    }
    set rexp {(^( |\t|\;)*namespace )|(^( |\t|\;)*class )|(^( |\t|\;)*proc )|(method )|(^( |\t|\;)*body )|(constructor )|(destructor )}
    if {[$TxtWidget tag ranges sel] != ""} {
        set start [$TxtWidget index "sel.first linestart"]
        set end [$TxtWidget index "sel.last lineend"]
        ColorizeLine [lindex [split [$TxtWidget index insert] "."] 0]
        if {![regexp $rexp [$TxtWidget get $start $end]]} {
            return list
        }
        $TxtWidget delete sel.first sel.last
        ColorizeLine [lindex [split [$TxtWidget index insert] "."] 0]
        Editor::updateOnIdle [list $start $end]
        return break
    }
    set start [$TxtWidget index "insert linestart"]
    set end [$TxtWidget index "insert lineend"]
    if {![regexp $rexp [$TxtWidget get $start $end]]} {
        ColorizeLine [lindex [split [$TxtWidget index insert] "."] 0]
        return list
    } else  {
        if {$backspace == {}} {
            $TxtWidget delete insert
        } else  {
            $TxtWidget delete "insert -1c" 
        }
        Editor::updateOnIdle [list $start $end]
        ColorizeLine [lindex [split [$TxtWidget index insert] "."] 0]
        return break
    }
    ColorizeLine [lindex [split [$TxtWidget index insert] "."] 0]
    return list
}

proc editorWindows::selectAll {} {
    variable TxtWidget
    
    if {$TxtWidget == ""} {
        return
    }
    
    $TxtWidget tag add sel 0.0 end
    
}

# set cursor to the function
proc editorWindows::gotoMark { markName } {
    global EditorData
    variable TxtWidget
    
    $TxtWidget mark set insert $markName
    $TxtWidget see insert
    focus $TxtWidget
    ReadCursor 0
    flashLine
}

proc editorWindows::gotoProc {procName} {
    global EditorData
    variable TxtWidget
    
    
    
    set expression "^( |\t|\;)*proc( |\t)+($procName)+( |\t)"
    set result [$TxtWidget search -regexp -- $expression insert]
    
    if {$result != ""} {
        $TxtWidget mark set insert $result
        $TxtWidget see insert
        focus $TxtWidget
        ReadCursor 0
        flashLine
    }
    return
}

proc editorWindows::gotoObject {name} {
    #Reasemnle the node name
    set node [file join [split [lrange $name 1 end] ::]]
}

proc editorWindows::flashLine {} {
    variable TxtWidget
    $TxtWidget tag add procSearch "insert linestart" "insert lineend"
    $TxtWidget tag configure procSearch -background yellow
    after 2000 {catch {$editorWindows::TxtWidget tag delete procSearch} }
    return
}

proc editorWindows::flashRegion {start end} {
    variable TxtWidget
    $TxtWidget tag add regionSearch $start $end
    $TxtWidget tag configure regionSearch -background yellow
    after 2000 {catch {$editorWindows::TxtWidget tag delete regionSearch} }
    return
}



# parse file and create proc file
proc editorWindows::ReadMarks { fileName } {
    global EditorData
    variable TxtWidget
    
    # clear all marks in this file
    foreach name [array names EditorData files,$EditorData(curFile),marks,] {
        unset EditorData($name)
    }
    
    set EditorData(files,$fileName,marks) {}
    
    set result [$TxtWidget search -forwards "proc " 1.0 end]
    
    while {$result != ""} {
        set lineNum [lindex [split $result "."] 0]
        set line [$TxtWidget get $lineNum.0 "$lineNum.0 lineend"]
        set temp [string trim $line \ \t\;]
        if {[scan $temp %\[proc\]%s proc name] == 2} {
            if {$proc == "proc"} {
                set markName $name
                lappend EditorData(files,$fileName,marks) $markName
                set EditorData(files,$fileName,marks,$markName,name) $name
            }
        }
        set result [$TxtWidget search -forwards "proc" "$result lineend" end ]
    }
    return
}


proc editorWindows::IndentCurLine {} {
    variable TxtWidget
    
    IndentLine [lindex [split [$TxtWidget index insert] "."] 0]
}

proc editorWindows::IndentLine {lineNum} {
    variable TxtWidget
    global EditorData
    
    if {$EditorData(options,useSintaxIndent)} {
        set end [$TxtWidget index "$lineNum.0 lineend"]
        incr lineNum -1
        set start [$TxtWidget index "$lineNum.0"]
        autoIndent $start $end
    } elseif {$EditorData(options,useIndent)} {
        if {$lineNum > 1} {
            # get previous line text
            incr lineNum -1
            set prevText [$TxtWidget get "$lineNum.0" "$lineNum.0 lineend"]
            regexp "^(\ |\t)*" $prevText spaces
            set braces [CountBraces $prevText]
            if {$braces > 0} {
                #indent
                incr lineNum
                $TxtWidget insert $lineNum.0 $spaces
                return
            }
        }
    } else  {
        return
    }
}

proc editorWindows::indentSelection {} {
    variable TxtWidget
    global tclDevData
    
    #check for selection & get start and end lines
    if {[$TxtWidget tag ranges sel] == ""} {
        set startLine [lindex [split [$TxtWidget index insert] "."] 0]
        set endLine [lindex [split [$TxtWidget index insert] "."] 0]
        set oldpos [$TxtWidget index insert]
    } else  {
        set startLine [lindex [split [$TxtWidget index sel.first] "."] 0]
        set endLine [lindex [split [$TxtWidget index sel.last] "."] 0]
        set selFirst [$TxtWidget index sel.first]
        set selLast [$TxtWidget index sel.last]
        set anchor [$TxtWidget index anchor]
    }
    
    
    if {$endLine == [lindex [split [$TxtWidget index end] "."] 0]} {
        #skip last line in widget
        incr endLine -1
    }
    
    for {set lineNum $startLine} {$lineNum <= $endLine} {incr lineNum} {
        set text " "
        append text [$TxtWidget get "$lineNum.0" "$lineNum.0 lineend"]
        
        $TxtWidget delete "$lineNum.0" "$lineNum.0 lineend"
        $TxtWidget insert "$lineNum.0" $text
    }
    # highlight
    ColorizeLines $startLine $endLine
    
    # set selection
    if {[$TxtWidget tag ranges sel] != ""} {
        set selFirst $selFirst+1c
        set selLast $selLast+1c
        $TxtWidget tag add sel $selFirst $selLast
        $TxtWidget mark set anchor $anchor
        $TxtWidget mark set insert $selLast
    } else  {
        $TxtWidget mark set insert $oldpos+1c
    }
    return
}

proc editorWindows::unindentSelection {} {
    variable TxtWidget
    global tclDevData
    
    #check for selection & get start and end lines
    if {[$TxtWidget tag ranges sel] == ""} {
        set startLine [lindex [split [$TxtWidget index insert] "."] 0]
        set endLine [lindex [split [$TxtWidget index insert] "."] 0]
        set oldpos [$TxtWidget index insert]
    } else  {
        set startLine [lindex [split [$TxtWidget index sel.first] "."] 0]
        set endLine [lindex [split [$TxtWidget index sel.last] "."] 0]
        set selFirst [$TxtWidget index sel.first]
        set selLast [$TxtWidget index sel.last]
        set anchor [$TxtWidget index anchor]
    }
    
    if {$endLine == [lindex [split [$TxtWidget index end] "."] 0]} {
        #skip last line in widget
        incr endLine -1
    }
    
    for {set lineNum $startLine} {$lineNum <= $endLine} {incr lineNum} {
        if {[$TxtWidget get "$lineNum.0" "$lineNum.0 +1 char"] == " "} {
            $TxtWidget delete "$lineNum.0" "$lineNum.0 +1 char"
        }
    }
    # highlight
    ColorizeLines $startLine $endLine
    
    # set selection
    if {[$TxtWidget tag ranges sel] != ""} {
        if {[lindex [split $selFirst "."] 1] != 0} {
            set selFirst $selFirst-1c
        }
        if {[lindex [split $selLast "."] 1] != 0} {
            set selLast $selLast-1c
        }
        $TxtWidget tag add sel $selFirst $selLast
        $TxtWidget mark set anchor $anchor
        $TxtWidget mark set insert $selLast
    } else  {
        $TxtWidget mark set insert $oldpos-1c
    }
    return
}

proc editorWindows::autoIndent {{start ""} {end ""}} {
    global EditorData
    variable TxtWidget
    
    set cursor [. cget -cursor]
    set textCursor [$TxtWidget cget -cursor]
    . configure -cursor watch
    $TxtWidget configure -cursor watch
    set selection 0
    set update 0
    if {$start == "" || $end == ""} {
        if {[$TxtWidget tag ranges sel] == ""} {
            #no selection: auto indent the whole file
            set start "1.0"
            set end "end -1c"
            set Editor::prgindic 0
            set Editor::status ""
            set update 1
        } else  {
            # only indent selection
            set selection 1
            set start [$TxtWidget index sel.first]
            set end [$TxtWidget index sel.last]
        }
    }
    # check for line continuation
    while {[$TxtWidget search -regexp {[\\]$} $start "$start lineend"] != "" && $start != "1.0"} {
        set start [$TxtWidget index "$start -1l linestart"]
    }
    set level 0
    set levelCorrection 0
    set comment 0
    set lineExpand 0
    set firstLine [$TxtWidget get "$start linestart" "$start lineend"]
    set curLine [$TxtWidget get "insert linestart" "insert lineend"]
    set cursorPos [lindex [split [$TxtWidget index insert] "."] 1]
    set cursorLine [lindex [split [$TxtWidget index insert] "."] 0]
    regexp {^[ \t]*} $curLine temp
    set cursorPos [expr $cursorPos - [string length $temp]]
    regexp {^[ \t]*} $firstLine temp
    regsub -all {\t} $temp $EditorData(indentString) offset
    while {[expr [string length $offset] % [string length $EditorData(indentString)]]} {
        append offset " "
    }
    set spaces $offset
    set currentSpaces $spaces
    set level [expr [string length $offset] / [string length $EditorData(indentString)]]
    set lineNum [lindex [split [$TxtWidget index $start] "."] 0]
    set startLine $lineNum
    set endLine [lindex [split [$TxtWidget index $end] "."] 0]
    while {$lineNum <= $endLine} {
        if {$Editor::prgindic != -1} {
            set Editor::prgindic [expr int($lineNum.0 / $endLine * 100)]
            set Editor::status "Indention progress: $Editor::prgindic % "
            update idletasks
        }
        set oldLine [$TxtWidget get $lineNum.0 "$lineNum.0 lineend"]
        set line [string trim $oldLine " \t"]
        set firstChar [string index $line 0]
        switch -- $firstChar {
            "\#" {
                #skip
                set comment 1
            }
            "\}" {
                #unindent line
                set spaces ""
                set comment 0
                if {$lineNum != $startLine} {
                    #skip the first line, otherwise it will be unindented
                    incr level -1
                }
                if {$level >= 0} {
                    for  {set i 0} {$i < $level} {incr i} {
                        append spaces "$EditorData(indentString)"
                    }
                    incr level
                } else  {
                    set level 0
                }
            }
            default {
                set comment 0
            }
        }
        set newLine "$spaces$line"
        if {$comment} {
            if {$oldLine != $newLine} {
                $TxtWidget delete "$lineNum.0" "$lineNum.0 lineend"
                $TxtWidget insert "$lineNum.0" $newLine
            }
            incr lineNum
            set currentSpaces $spaces
            continue
        }
        set count [CountBraces $line]
        incr level $count
        if {$level < 0} {
            set level 0
        }
        set lastChar [string index $line [expr [string length $line] -1]]
        switch -- $lastChar {
            "\\" {
                #is there a leading openbrace?
                if [regexp {\{[ \t]*\\$} $line] {
                    #ignore backslash
                } else  {
                    # line continues with next line
                    if {$lineExpand} {
                        #skip
                    } else  {
                        #this is the first line of line concatenation
                        set lineExpand 1
                        incr level 2
                        incr levelCorrection -2
                    }
                }
            }
            
            default {
                #is this the end of line concatenation
                if {$lineExpand} {
                    set lineExpand 0
                    if {$count <= 0} {
                        # do correction
                        if {$level > 0} {
                            incr level $levelCorrection
                            set levelCorrection 0
                        }
                    } else {
                        #if there´s an open command do the indent correction later
                    }
                } elseif {$count < 0} {
                    #now the open command within a line concatenation should be completed
                    #so we add the correction value
                    incr level $levelCorrection
                    set levelCorrection 0
                }
            }
        }; #end of switch
        #store current Spaces for restoring cursor position
        set currentSpaces $spaces
        # now setting the offset (spaces) for the next line
        set spaces ""
        for  {set i 0} {$i < $level} {incr i} {
            append spaces "$EditorData(indentString)"
        }
        if {$oldLine == $newLine} {
            incr lineNum
            continue
        }
        $TxtWidget delete "$lineNum.0" "$lineNum.0 lineend"
        $TxtWidget insert "$lineNum.0" $newLine
        incr lineNum
    } ; #end of while
    set startLine [lindex [split [$TxtWidget index $start] "."] 0]
    set endLine [lindex [split [$TxtWidget index $end] "."] 0]
    ColorizeLines $startLine $endLine
    . configure -cursor $cursor
    $TxtWidget configure -cursor $textCursor
    update
    
    #restore cursor position
    incr lineNum -1
    set cursorPos [expr $cursorPos + [string length $currentSpaces]]
    $TxtWidget mark set insert $cursorLine.$cursorPos
    if {$selection} {
        $TxtWidget tag remove sel $start insert
    }
    $TxtWidget see insert
    set Editor::prgindic -1
    set Editor::status ""
}

# change tab to spaces
proc editorWindows::OnTabPress {} {
    variable TxtWidget
    global EditorData
    
    if {$EditorData(options,changeTabs)} {
        set spaces ""
        
        for {set i 0} {$i < $EditorData(options,tabSize)} {incr i} {
            append spaces " "
        }
        
        #insert spaces
        $TxtWidget insert insert $spaces
    } else {
        #insert tab
        $TxtWidget insert insert "\t"
    }
    Editor::selectObject 0
}

proc editorWindows::onKeyPressReturn {key} {
    global EditorData
    variable TxtWidget
    
    set Editor::current(char) "\n"
    if {!$EditorData(options,autoUpdate)} {
        return list
    }
    if {[$TxtWidget tag ranges sel] != "" && $EditorData(options,autoUpdate)} {
        set start [$TxtWidget index sel.first]
        set end [$TxtWidget index sel.last]
        set range [editorWindows::deleteMarks $start $end]
        $TxtWidget mark set delStart [lindex $range 0]
        $TxtWidget mark gravity delStart left
        $TxtWidget mark set delEnd [lindex $range 1]
        $TxtWidget delete sel.first sel.last
        $TxtWidget insert insert $key
        if {[$TxtWidget compare insert > delEnd]} {
            $TxtWidget mark set delEnd insert
        }
        Editor::updateOnIdle [list [$TxtWidget index delStart] [$TxtWidget index delEnd]]
        $TxtWidget mark unset delStart
        $TxtWidget mark unset delEnd
        return break
    } else {
        return list
    }
}

# reaction on key releasing
proc editorWindows::OnKeyRelease {} {
    global EditorData
    variable TxtWidget
    
    catch {
        switch -regexp -- $Editor::current(char) {
            "\n" {
                # Return
                set lineNum [lindex [split [$TxtWidget index insert] "."] 0]
                set Editor::current(lastPos) [$Editor::current(text) index insert]
                ReadCursor
                ColorizeLine $lineNum
                set Editor::current(procListHistoryPos) 0
            }
            {.} {
                #printable chars
                switch -- $Editor::current(char) {
                    "\{" {editorWindows::OnLeftBraceRelease}
                    "\}" {editorWindows::IndentCurLine}
                    "\[" {editorWindows::OnLeftBracketRelease}
                }
                if {$Editor::current(isNode) && $EditorData(options,autoUpdate)} {
                    #if there´s a pending update only store new range
                    Editor::updateOnIdle [list [$TxtWidget index insert] [$TxtWidget index insert]]
                } elseif {$EditorData(options,autoUpdate)}  {
                    Editor::selectObject 1
                } else  {
                    Editor::selectObject 0
                }
                set lineNum [lindex [split [$TxtWidget index insert] "."] 0]
                set Editor::current(lastPos) [$Editor::current(text) index insert]
                ReadCursor
                ColorizeLine $lineNum
                set Editor::current(procListHistoryPos) 0
            }
            default  {
                #non printable chars
                Editor::selectObject 0
                set Editor::current(lastPos) [$Editor::current(text) index insert]
                ReadCursor
            }
        }
    }
    set Editor::current(char) ""
}

#reaction on space release
proc editorWindows::OnSpaceRelease {} {
    global EditorData
    variable TxtWidget
    
    if {!$EditorData(options,useTemplates) || !$EditorData(options,useTemplatesForKeywords)} {
        return
    }
    set templateKeyword [GetTemplateKeyword [$TxtWidget get "insert linestart" "insert lineend"]]
    set curPos [$TxtWidget index insert]
    set lineNum [lindex [split $curPos "."] 0]
    
    switch -- $templateKeyword {
        "if" {
            $TxtWidget insert insert " \{\n\}"
            incr lineNum
            IndentLine $lineNum
            $TxtWidget mark set insert $curPos
        }
        
        "for" {
            $TxtWidget insert insert " \{\} \{\} \{\} \{\n\}"
            incr lineNum
            IndentLine $lineNum
            $TxtWidget mark set insert "$curPos +1ch"
        }
        
        "foreach" {
            $TxtWidget insert insert " \{\n\}"
            incr lineNum
            IndentLine $lineNum
            $TxtWidget mark set insert $curPos
        }
        
        "while" {
            $TxtWidget insert insert " \{\n\}"
            incr lineNum
            IndentLine $lineNum
            $TxtWidget mark set insert $curPos
        }
        
        "switch" {
            $TxtWidget insert insert " \{\n\}"
            incr lineNum
            IndentLine $lineNum
            $TxtWidget mark set insert $curPos
        }
        
        "proc" {
            $TxtWidget insert insert " \{\} \{\n\}"
            incr lineNum
            IndentLine $lineNum
            $TxtWidget mark set insert $curPos
        }
        
        "else" {
            $TxtWidget insert insert " \{\n\n\}"
            ColorizeLine $lineNum
            incr lineNum
            IndentLine $lineNum
            incr lineNum
            IndentLine $lineNum
            incr lineNum -1
            $TxtWidget mark set insert "$lineNum.0 lineend"
        }
        
        "elseif" {
            $TxtWidget insert insert " \{\n\}"
            ColorizeLine $lineNum
            incr lineNum
            IndentLine $lineNum
            $TxtWidget mark set insert $curPos
        }
    }
    return 0
}

proc editorWindows::OnLeftBraceRelease {} {
    variable TxtWidget
    global EditorData
    
    if {!$EditorData(options,useTemplates) || !$EditorData(options,useTemplatesForBrace)} {
        return
    }
    set curPos [$TxtWidget index insert]
    $TxtWidget insert insert "\}"
    $TxtWidget mark set insert $curPos
    return
}

proc editorWindows::OnLeftParenRelease {} {
    variable TxtWidget
    global EditorData
    
    if {!$EditorData(options,useTemplates) || !$EditorData(options,useTemplatesForParen)} {
        return
    }
    set curPos [$TxtWidget index insert]
    $TxtWidget insert insert "\)"
    $TxtWidget mark set insert $curPos
    Editor::selectObject 0
    return
}

proc editorWindows::OnLeftBracketRelease {} {
    variable TxtWidget
    global EditorData
    
    if {!$EditorData(options,useTemplates) || !$EditorData(options,useTemplatesForBracket)} {
        return
    }
    
    set curPos [$TxtWidget index insert]
    $TxtWidget insert insert "\]"
    $TxtWidget mark set insert $curPos
    return
}

proc editorWindows::OnQuoteDblRelease {} {
    variable TxtWidget
    global EditorData
    
    if {!$EditorData(options,useTemplates) || !$EditorData(options,useTemplatesForQuoteDbl)} {
        return
    }
    set curPos [$TxtWidget index insert]
    $TxtWidget insert insert "\""
    $TxtWidget mark set insert $curPos
    Editor::selectObject 0
    return
}

# reaction on mouse button release

proc editorWindows::OnMouseRelease {} {
    variable TxtWidget
    
    ReadCursor
    ColorizePair
    set oldNode $Editor::current(node)
    set curNode [Editor::selectObject 0]
    if {$oldNode != $curNode} {
        Editor::procList_history_add $Editor::current(lastPos)
    } else  {
        Editor::procList_history_update
    }
    set Editor::current(lastPos) [$TxtWidget index insert]
}

# read information about cursor and set it to the global variables
proc editorWindows::ReadCursor {{selectProc 1}} {
    variable TxtWidget
    global EditorData
    
    set insertPos [split [$TxtWidget index insert] "."]
    set EditorData(cursor,line) [lindex $insertPos 0]
    set EditorData(cursor,pos) [expr {[lindex $insertPos 1] }]
    set EditorData(cursorPos) "Line: $EditorData(cursor,line)   Pos: $EditorData(cursor,pos)"
    set Editor::lineNo $EditorData(cursor,line)
    return
}


proc editorWindows::enableHL {} {
    variable TxtWidget
    
    if {$TxtWidget != ""} {
        colorize
    }
    
    return
}

proc editorWindows::disableHL {} {
    variable TxtWidget
    
    if {$TxtWidget != ""} {
        # delete all tags
        $TxtWidget tag delete comment
        $TxtWidget tag delete keyword
        
        ConfigureTags
    }
    
    return
}

proc editorWindows::colorize {} {
    variable TxtWidget
    variable EditorData
    
    # get number of lines
    set lineEnd [lindex [split [$TxtWidget index end] "."] 0]
    
    ColorizeLines 1 $lineEnd
}

proc editorWindows::ColorizeLines {StartLine EndLine} {
    variable TxtWidget
    
    # delete all tags
    $TxtWidget tag remove comment "$StartLine.0" "$EndLine.0 lineend"
    $TxtWidget tag remove keyword "$StartLine.0" "$EndLine.0 lineend"
    
    for {set lineNum $StartLine} {$lineNum <= $EndLine} {incr lineNum} {
        ColorizeLine $lineNum
    }
    
    return
}

proc editorWindows::ColorizeLine {lineNum} {
    variable TxtWidget
    global EditorData
    
    if {!$EditorData(options,useHL)} {
        return
    }
    
    #   get line
    set line [$TxtWidget get $lineNum.0 "$lineNum.0 lineend"]
    
    set range [IsComment $line $lineNum]
    if {$range != {}} {
        # this is comment
        # set comment font
        eval $TxtWidget tag remove keyword $range
        eval $TxtWidget tag add comment $range
    } else {
        $TxtWidget tag remove comment $lineNum.0 "$lineNum.0 lineend"
        set range [GetKeywordCoord $line $lineNum]
        if {$range != {} } {
            eval $TxtWidget tag add keyword $range
        } else {
            $TxtWidget tag remove keyword $lineNum.0 "$lineNum.0 lineend"
        }
    }
    return
}

proc editorWindows::ConfigureTags {} {
    variable TxtWidget
    global EditorData
    
    # blue is specially for Lapshin
    $TxtWidget tag configure comment -font $EditorData(options,fonts,commentFont) -foreground blue
    $TxtWidget tag configure keyword -font $EditorData(options,fonts,keywordFont)
    $TxtWidget tag configure pair -background red
    
    return
}

proc editorWindows::IsComment {line lineNum} {
    variable TxtWidget
    
    set a ""
    regexp "^( |\t)*\#" $line a
    
    if {$a != ""} {
        return [list $lineNum.[expr [string length $a]-1] $lineNum.[string length $line]]
    } else {
        regexp "^(.*\;( |\t)*)\#" $line a
        if {$a != ""} {
            $TxtWidget tag remove comment $lineNum.0 "$lineNum.0 lineend"
            set range [GetKeywordCoord $line $lineNum]
            if {$range != {} } {
                eval $TxtWidget tag add keyword $range
            } else {
                $TxtWidget tag remove keyword $lineNum.0 "$lineNum.0 lineend"
            }
            return [list $lineNum.[expr [string length $a]-1] $lineNum.[string length $line]]
        } else  {
            return {}
        }
    }
}

proc editorWindows::GetKeywordCoord {line lineNum} {
    global EditorData
    
    set name ""
    
    set temp [string trim $line \ \t\;\{\[\]\}]
    if {![scan $temp %s name]} {
        return {}
    }
    
    set nameStart [string first $name $line]
    set nameEnd [string wordend $line $nameStart]
    
    # is it keyword?
    if {[lsearch $EditorData(keywords) $name] != -1 || $name == "else" || $name == "elseif"} {
        return [list $lineNum.$nameStart $lineNum.$nameEnd]
    } else  {
        return {}
    }
}


proc editorWindows::GetTemplateKeyword { line } {
    global EditorData
    
    set a ""
    regexp "^( |\t|\;)*\[a-z\]+ $" $line a
    
    if {$a != ""} {
        # gets name
        set b ""
        regexp "^( |\t)*" $line b
        set nameStart [string length $b]
        set nameEnd [string length $a]
        set name [string range $a [string length $b] end]
        
        #return name without last space
        return [string range $name 0 [expr {[string length $name] - 2}]]
    } else {
        # check for else
        set a ""
        regexp "^( |\t)*\}( |\t)*else $" $line a
        
        if {$a != ""} {
            return "else"
        }
        
        # check for elseif
        set a ""
        regexp "^( |\t)*\}( |\t)*elseif $" $line a
        
        if {$a != ""} {
            return "elseif"
        }
    }
    
    return ""
}

proc editorWindows::setCursor {lineNum pos} {
    variable TxtWidget
    
    $TxtWidget mark set insert $lineNum.$pos
    $TxtWidget see insert
    focus $TxtWidget
    ReadCursor
    
    return
}

#reaction on changing tab size
proc editorWindows::onTabSize {} {
    variable TxtWidget
    global EditorData
    
    if {$TxtWidget != ""} {
        set size [expr {$EditorData(options,tabSize)*
            [font measure $EditorData(options,fonts,editorFont) -displayof $TxtWidget " "]}]
        $TxtWidget configure -tabs [list $size]
    }
    
    return
}

# reaction on change font
proc editorWindows::onFontChange {} {
    variable TxtWidget
    global EditorData
    
    if {$TxtWidget != ""} {
        $TxtWidget configure -font $EditorData(options,fonts,editorFont)
        ConfigureTags
    }
    
    return
}

proc editorWindows::onChangeFontSize {editWin} {
    global EditorData
    
    if {$editWin != ""} {
        $editWin configure -font editorFont
        $editWin tag configure comment -font commentFont -foreground blue
        $editWin tag configure keyword -font keywordFont
        $editWin tag configure pair -background red
        update
    }
    return
}

proc editorWindows::GetOpenPair {symbol {index ""}} {
    variable TxtWidget
    
    if {$index == ""} {
        set index "insert"
    } else  {
        set index "$index"
    }
    
    set count -1
    
    switch $symbol {
        "\}" {set rexp {(^[ \t\;]*#)|(\{)|(\\)|(\})}}
        "\]" {set rexp {(^[ \t\;]*#)|(\[)|(\\)|(\])}}
        "\)" {set rexp {(^[ \t\;]*#)|(\()|(\\)|(\))}}
    }
    while {$count != 0} {
        set index [$TxtWidget search -backwards -regexp $rexp "$index" "1.0"]
        
        if {$index == ""} {
            break
        }
        #check for quoting
        if {[$TxtWidget get "$index -1c"] != "\\"} {
            switch [$TxtWidget get $index] {
                "\{" {incr count}
                "\[" {incr count}
                "\(" {incr count}
                "\}" {incr count -1}
                "\]" {incr count -1}
                "\)" {incr count -1}
            }
        }
    }
    
    if {$count == 0} {
        return $index
    } else  {
        return ""
    }
}



proc editorWindows::GetClosePair {symbol {index ""}} {
    variable TxtWidget
    
    if {$index == ""} {
        set index "insert"
    }
    
    set count 1
    
    switch $symbol {
        "\{" {set rexp {(^[ \t\;]*#)|(\})|(\{)|(\\)}}
        "\[" {set rexp {(^[ \t\;]*#)|(\[)|(\\)|(\])}}
        "\(" {set rexp {(^[ \t\;]*#)|(\()|(\\)|(\))}}
    }
    while {$count != 0} {
        set index [$TxtWidget search -regexp $rexp "$index +1c" end ]
        if {$index == ""} {
            break
        }
        switch -- [$TxtWidget get $index] {
            "\{" {incr count}
            "\[" {incr count}
            "\(" {incr count}
            "\}" {incr count -1}
            "\]" {incr count -1}
            "\)" {incr count -1}
            "\\" {set index "$index +1ch"}
            default {
                #this is a comment line
                set index [$TxtWidget index "$index lineend"]
            }
        }
        if {[$TxtWidget compare $index >= "end-1c"]} {
            break
        }
    }
    if {$count == 0} {
        return [$TxtWidget index $index]
    } else  {
        return ""
    }
}

#process line for openSymbol
proc editorWindows::ProcessLineForOpenSymbol {line symbol countName} {
    upvar $countName count
    
    switch -- $symbol {
        "\}" {
            set openSymbol "\{"
        }
        "\]" {
            set openSymbol "\["
        }
        "\)" {
            set openSymbol "\("
        }
    }
    
    #process line
    for {set i [expr {[string length $line] - 1}]} {$i >= 0} {incr i -1} {
        set curChar [string index $line $i]
        
        if {$curChar == $openSymbol} {
            # increment count
            if {[string index $line [expr {$i - 1}]] == "\\"} {
                #skip it
                incr i -1
            } else  {
                incr count
                if {$count > 0} {
                    return $i
                }
            }
        } elseif {$curChar == $symbol } {
            # decrement count
            if {[string index $line [expr {$i - 1}]] == "\\"} {
                #skip it
                incr i -1
            } else  {
                incr count -1
            }
        }
    }
    
    return ""
}


#process line for closeSymbol
proc editorWindows::ProcessLineForCloseSymbol {line symbol countName} {
    upvar $countName count
    
    switch -- $symbol {
        "\{" {
            set closeSymbol "\}"
        }
        "\[" {
            set closeSymbol "\]"
        }
        "\(" {
            set closeSymbol "\)"
        }
    }
    
    #process line
    set len [string length $line]
    for {set i 0} {$i < $len} {incr i } {
        set curChar [string index $line $i]
        
        if {$curChar == $closeSymbol} {
            # increment count
            incr count
            if {$count > 0} {
                return $i
            }
        } elseif {$curChar == $symbol } {
            # decrement count
            incr count -1
        } elseif {$curChar == "\\"} {
            #skip next symbol
            incr i
        }
    }
    
    return ""
}

# count braces in text
proc editorWindows::CountBraces {text {count 0}} {
    set rexp_open {\{}
    set rexp_close {\}}
    #ignore comment lines
    regsub -all {^[ \t\;]#[^\n]*} $text "" dummy
    #ignore quoted braces
    regsub -all {(\\\\)} $dummy "" dummy
    regsub -all {(\\\{|\\\})} $dummy "" text
    set openBraces [regsub -all $rexp_open $text "*" dummy]
    set closeBraces [regsub -all $rexp_close $text "*" dummy]
    return [expr $openBraces - $closeBraces]
}

# colorize pair
proc editorWindows::ColorizePair {} {
    variable TxtWidget
    
    $TxtWidget tag remove pair 0.0 end
    
    #get current char
    set curChar [$TxtWidget get insert]
    
    switch -- $curChar {
        "\}" {
            set result [GetOpenPair "\}"]
            if {$result != ""} {
                $TxtWidget tag add pair $result "$result +1ch"
            }
        }
        "\]" {
            set result [GetOpenPair "\]"]
            if {$result != ""} {
                $TxtWidget tag add pair $result "$result +1ch"
            }
        }
        "\)" {
            set result [GetOpenPair "\)"]
            if {$result != ""} {
                $TxtWidget tag add pair $result "$result +1ch"
            }
        }
        "\{" {
            set result [GetClosePair "\{"]
            if {$result != ""} {
                $TxtWidget tag add pair $result "$result +1ch"
            }
        }
        "\[" {
            set result [GetClosePair "\["]
            if {$result != ""} {
                $TxtWidget tag add pair $result "$result +1ch"
            }
        }
        "\(" {
            set result [GetClosePair "\("]
            if {$result != ""} {
                $TxtWidget tag add pair $result "$result +1ch"
            }
        }
        default {return}
    }
}
