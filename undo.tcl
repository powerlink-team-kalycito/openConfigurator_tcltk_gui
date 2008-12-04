#################################################################
# set zed_dir [file dirname [info script]] 
# here is where the undo stuff begins
global classNewId
global textChanged
if {![info exists classNewId]} {
    # work around object creation between multiple include of this file problem
    set classNewId 0
}


proc new {className args} {
    
    # calls the constructor for the class with optional arguments
    # and returns a unique object identifier independent of the class name
    
    global classNewId
    #sievers
    global textChanged
    set textChanged 0
    
    # use local variable for id for new can be called recursively
    set id [incr classNewId]
    if {[llength [info procs ${className}:$className]]>0} {
        # avoid catch to track errors
        eval ${className}:$className $id $args
    }
    return $id
}

proc delete {className id} {
    # calls the destructor for the class and delete all the object data members
    
    if {[llength [info procs ${className}:~$className]]>0} {
        # avoid catch to track errors
        ${className}:~$className $id
    }
    global $className
    # and delete all this object array members if any (assume that they were stored as $className($id,memberName))
    foreach name [array names $className "$id,*"] {
        unset ${className}($name)
    }
}

proc lifo:lifo {id {size 2147483647}} {
    global lifo
    set lifo($id,maximumSize) $size
    lifo:empty $id
}

proc lifo:push {id data} {
    global lifo
    
    lifo:tidyUp $id
    if {$lifo($id,size)>=$lifo($id,maximumSize)} {
        unset lifo($id,data,$lifo($id,first))
        incr lifo($id,first)
        incr lifo($id,size) -1
    }
    set lifo($id,data,[incr lifo($id,last)]) $data
    incr lifo($id,size)
}

proc lifo:pop {id} {
    global lifo
    lifo:tidyUp $id
    if {$lifo($id,last)<$lifo($id,first)} {
        error "lifo($id) pop error, empty"
    }
    # delay unsetting popped data to improve performance by avoiding a data copy
    set lifo($id,unset) $lifo($id,last)
    incr lifo($id,last) -1
    incr lifo($id,size) -1
    return $lifo($id,data,$lifo($id,unset))
}

proc lifo:tidyUp {id} {
    global lifo
    if {[info exists lifo($id,unset)]} {
        unset lifo($id,data,$lifo($id,unset))
        unset lifo($id,unset)
    }
}

proc lifo:empty {id} {
    global lifo
    lifo:tidyUp $id
    foreach name [array names lifo $id,data,*] {
        unset lifo($name)
    }
    set lifo($id,size) 0
    set lifo($id,first) 0
    set lifo($id,last) -1
}


proc textUndoer:textUndoer {id widget {depth 2147483647}} {
    global textUndoer
    
    if {[string compare [winfo class $widget] Text]!=0} {
        error "textUndoer error: widget $widget is not a text widget"
    }
    set textUndoer($id,widget) $widget
    set textUndoer($id,originalBindingTags) [bindtags $widget]
    bindtags $widget [concat $textUndoer($id,originalBindingTags) UndoBindings($id)]
    
    bind UndoBindings($id) <Control-u> "textUndoer:undo $id"
    
    # self destruct automatically when text widget is gone
    
    bind UndoBindings($id) <Destroy> "delete textUndoer $id"
    
    # rename widget command
    rename $widget [set textUndoer($id,originalCommand) textUndoer:original$widget]
    # and intercept modifying instructions before calling original command
    proc $widget {args} "textUndoer:checkpoint $id \$args;
    global search_count;
    eval $textUndoer($id,originalCommand) \$args"
    
    set textUndoer($id,commandStack) [new lifo $depth]
    set textUndoer($id,cursorStack) [new lifo $depth]
    #lee 
    textRedoer:textRedoer $id $widget $depth
}


proc textUndoer:~textUndoer {id} {
    global textUndoer
    
    bindtags $textUndoer($id,widget) $textUndoer($id,originalBindingTags)
    rename $textUndoer($id,widget) ""
    rename $textUndoer($id,originalCommand) $textUndoer($id,widget)
    delete lifo $textUndoer($id,commandStack)
    delete lifo $textUndoer($id,cursorStack)
    #lee
    textRedoer:~textRedoer $id
}

proc textUndoer:checkpoint {id arguments} {
    global textUndoer
    #lee
    global textRedoer
    #sievers
    global textChanged
    
    set textChanged 0
    # do nothing if non modifying command
    if {[string compare [lindex $arguments 0] insert]==0} {
        textUndoer:processInsertion $id [lrange $arguments 1 end]
        if {$textRedoer($id,redo) == 0} {
            textRedoer:reset $id
        }
        #sievers
        set textChanged 1
        
    }
    if {[string compare [lindex $arguments 0] delete]==0} {
        textUndoer:processDeletion $id [lrange $arguments 1 end]
        if {$textRedoer($id,redo) == 0} {
            textRedoer:reset $id
        }
        #sievers
        set textChanged 1
        
        
    }
    if {$textChanged} {
        if {! $Editor::current(hasChanged)} {
            set Editor::current(hasChanged) 1
            $Editor::notebook itemconfigure $Editor::current(pagename) -image [Bitmap::get redball]
        }
    }
}

proc textUndoer:processInsertion {id arguments} {
    global textUndoer
    
    set number [llength $arguments]
    set length 0
    # calculate total insertion length while skipping tags in arguments
    for {set index 1} {$index<$number} {incr index 2} {
        incr length [string length [lindex $arguments $index]]
    }
    if {$length>0} {
        set index [$textUndoer($id,originalCommand) index [lindex $arguments 0]]
        lifo:push $textUndoer($id,commandStack) "delete $index $index+${length}c"
        lifo:push $textUndoer($id,cursorStack) [$textUndoer($id,originalCommand) index insert]
    }
}

proc textUndoer:processDeletion {id arguments} {
    global textUndoer
    
    set command $textUndoer($id,originalCommand)
    lifo:push $textUndoer($id,cursorStack) [$command index insert]
    
    set start [$command index [lindex $arguments 0]]
    if {[llength $arguments]>1} {
        lifo:push $textUndoer($id,commandStack) "insert $start [list [$command get $start [lindex $arguments 1]]]"
    #I changed line above : instead "{ [$command ...] }" -> " [list [$command ...] ]"
    #See explanation in file undo.txt
    } else {
        lifo:push $textUndoer($id,commandStack) "insert $start [list [$command get $start]]"
    #I changed line above : instead "{ [$command ...] }" -> " [list [$command ...] ]"
    #See explanation in file undo.txt
    }
}

proc textUndoer:undo {id} {
    global textUndoer
    #sievers
    global textChanged
    
    if {[catch {set cursor [lifo:pop $textUndoer($id,cursorStack)]}]} {
        return
    }
    
    set popArgs [lifo:pop $textUndoer($id,commandStack)]
    textRedoer:checkpoint $id $popArgs
    
    eval $textUndoer($id,originalCommand) $popArgs
#    eval $textUndoer($id,originalCommand) [list [lifo:pop $textUndoer($id,commandStack)] ]
    # now restore cursor position
    $textUndoer($id,originalCommand) mark set insert $cursor
    # make sure insertion point can be seen
    $textUndoer($id,originalCommand) see insert
    if {[lindex $popArgs 0] == "insert"} {
        return [list [lindex $popArgs 1] "[lindex $popArgs 1]+[string length [lindex $popArgs 2]]c"]
    } else  {
#        return [list $cursor $cursor]
        return [list [lindex $popArgs 1] [lindex $popArgs 1]]
    }
    
}

proc textUndoer:reset {id} {
    global textUndoer
    
    lifo:empty $textUndoer($id,commandStack)
    lifo:empty $textUndoer($id,cursorStack)
}

proc textRedoer:textRedoer {id widget {depth 2147483647}} {
    global textRedoer
    
    #bp {creation redoer}
    if {[string compare [winfo class $widget] Text]!=0} {
        error "textRedoer error: widget $widget is not a text widget"
    }
    set textRedoer($id,commandStack) [new lifo $depth]
    set textRedoer($id,cursorStack) [new lifo $depth]
    set textRedoer($id,redo) 0
}

proc textRedoer:~textRedoer {id} {
    global textRedoer
    
    #bp {destroy redoer}
    delete lifo $textRedoer($id,commandStack)
    delete lifo $textRedoer($id,cursorStack)
}


proc textRedoer:checkpoint {id arguments} {
    global textUndoer
    global textRedoer
    #sievers
    global textChanged
    
    
    # bp {redo-check point}
    # do nothing if non modifying command
    if {[string compare [lindex $arguments 0] insert]==0} {
        textRedoer:processInsertion $id [lrange $arguments 1 end]
                #sievers
        
        set textChanged 1
        
    }
    if {[string compare [lindex $arguments 0] delete]==0} {
        textRedoer:processDeletion $id [lrange $arguments 1 end]
        #sievers
        set textChanged 1
        
    }
    if {$textChanged} {
        if {! $Editor::current(hasChanged)} {
            set Editor::current(hasChanged) 1
            $Editor::notebook itemconfigure $Editor::current(pagename) -image [Bitmap::get redball]
        }
#        catch Editor::checkProcs
    }
}

proc textRedoer:processInsertion {id arguments} {
    global textUndoer
    global textRedoer
    
    
    #bp {redo-insert}
    set number [llength $arguments]
    set length 0
    # calculate total insertion length while skipping tags in arguments
    for {set index 1} {$index<$number} {incr index 2} {
        incr length [string length [lindex $arguments $index]]
    }
    if {$length>0} {
        set index [$textUndoer($id,originalCommand) index [lindex $arguments 0]]
        lifo:push $textRedoer($id,commandStack) "delete $index $index+${length}c"
        lifo:push $textRedoer($id,cursorStack) [$textUndoer($id,originalCommand) index insert]
        
    }
}

proc textRedoer:processDeletion {id arguments} {
    global textUndoer
    global textRedoer
        #bp {redo-del}
    set command $textUndoer($id,originalCommand)
    lifo:push $textRedoer($id,cursorStack) [$command index insert]
    
    set start [$command index [lindex $arguments 0]]
    if {[llength $arguments]>1} {
        lifo:push $textRedoer($id,commandStack) "insert $start [list [$command get $start [lindex $arguments 1]]]"
    #I changed line above : instead "{ [$command ...] }" -> " [list [$command ...] ]"
    #See explanation in file undo.txt
        
    } else {
        lifo:push $textRedoer($id,commandStack) "insert $start [list [$command get $start]]"
    #I changed line above : instead "{ [$command ...] }" -> " [list [$command ...] ]"
    #See explanation in file undo.txt
    }
    
}
proc textRedoer:redo {id} {
    global textUndoer
    global textRedoer
    #sievers
    global textChanged
    
    #bp {redo-redo}
    if {[catch {set cursor [lifo:pop $textRedoer($id,cursorStack)]}]} {
        return
    }
    
#    textRedoer:checkpoint $id  [lifo:pop $textUndoer($id,commandStack)] 
    
    set textRedoer($id,redo) 1
    set popArgs [lifo:pop $textRedoer($id,commandStack)]
    textUndoer:checkpoint $id $popArgs
    eval $textUndoer($id,originalCommand) $popArgs
    set textRedoer($id,redo) 0
    # now restore cursor position
    $textUndoer($id,originalCommand) mark set insert $cursor
    # make sure insertion point can be seen
    $textUndoer($id,originalCommand) see insert
    if {[lindex $popArgs 0] == "insert"} {
        return [list [lindex $popArgs 1] "[lindex $popArgs 1]+[string length [lindex $popArgs 2]]c"]
    } else  {
        return [list $cursor $cursor]
    }
    
}


proc textRedoer:reset {id} {
    global textRedoer
    
#    bp {redo-reset}
    lifo:empty $textRedoer($id,commandStack)
    lifo:empty $textRedoer($id,cursorStack)
}