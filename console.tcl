################################################################################
#									
# Script:	console.tcl						
#									
# Author:	Kalycito Infotech Pvt Ltd		
#									
# Description:	Contains the procedures for Console window.
#
#
################################################################################

#Console
global Console
global conWindow
global warWindow
global errWindow

#Acitivated the Console window key press events
proc flashWin {win delay} {
    set color [$win cget -bg]
    $win configure -bg red
    update
    after $delay
    $win configure -bg $color
    update
}

proc reset {} {
    global Console
    interp eval $Console {
        if {[lsearch [package names] Tk] != -1} {
            foreach child [winfo children .] {
                if {[winfo exists $child]} {destroy $child}
            }
            wm withdraw .
        }
    }
}

proc conPuts {var {tag output} {win {}} {flash 0} {see 1}} {
    global prompt
    global conWindow
    
    if {$win == {}} {
        set win $conWindow
    }
    $win mark gravity prompt right
    $win insert end $var $tag
    if {[string index $var [expr [string length $var]-1]] != "\n"} {
        $win insert end "\n"
    }
    set prompt OUTPUT
    $win insert end "$prompt : " prompt
    $win mark gravity prompt left
    if $see {$win see insert}
    update
    if $flash {
        flashWin $win $flash
    }
    return
}

proc consolePuts {args} {
    global prompt
    global conWindow
    global errorInfo
    
    set argcounter [llength $args]
    if {[llength $args] > 3} {
        conPuts [list "invalid arguments" error]
    }
    set newline "\n"
    if {[string match "-nonewline" [lindex $args 0]]} {
        set newline ""
        set args [lreplace $args 0 0]
    }
    if {[llength $args] == 1} {
        set chan stdout
        set string [lindex $args 0]$newline
    } else {
        set chan [lindex $args 0]
        set string [lindex $args 1]$newline
    }
    if [regexp (stdout|stderr) $chan] {
        eval conPuts [list $string]
    } else {
        puts -nonewline $chan $string
    }
}



# proc evalCommand
# executes commands within a seperate interpreter
# runs also windows commands via exec
proc evalCommand {window Interp command} {
    global errorInfo
    global env
    global code
    global result
    global prompt
    global historyIndex
    global tcl_platform
    global buffer
    
    set historyIndex 0
    proc SetValues {_code _result _errorInfo} {
        global code result errorInfo
        set code $_code
        set result $_result
        set errorInfo $_errorInfo
    }
    
    if {$command != {} && $command != "\n"} {
        if {$command == "reset\n"} {
            set buffer ""
            conPuts "current command canceled !" error
            return
        }
        append buffer $command
        if {[info complete $buffer]} {
            set evalCommand $buffer
            set buffer ""
            history add $evalCommand
            interp eval $Interp set evalCommand [list $evalCommand]
            if {[info commands [lindex $evalCommand 0]] == "puts"} {
                eval regsub "puts " $evalCommand "" evalCommand
                eval [list consolePuts $evalCommand]
                return
            }
            interp eval $Interp {
                #set code [catch "eval [list $evalCommand]" result ] ; #The above line also works 
                set code [catch "eval [list $evalCommand]" result errorInfo]
                setValues $code $result $errorInfo
            }
            update idletasks
            if {!$code} {
                if {$result != {}} {
                    eval [list conPuts $result]
                } else  {
                    set prompt OUTPUT
                    $window mark gravity prompt right
                    $window insert end "$prompt % " prompt
                    $window mark gravity prompt left
                    $window see insert
                }
            } else  {
                if {[info commands [lindex $evalCommand 0]] != ""} {
                    eval [list conPuts $errorInfo error]
                } else  {
                    if {$tcl_platform(platform) == "windows"} {
                        set comspec [file split $env(COMSPEC)]
                        set temp ""
                        foreach item $comspec {
                            set temp [file join $temp $item]
                        }
                        set execComspec [concat $temp /c $evalCommand]
                    } else {
                        set execComspec $evalCommand
                    }
                    set code [catch {eval exec $execComspec} result]
		    #Output for the result
                    conPuts "$result"                    
		    conPuts "********************************************************************************" info
                }
            }
        }
    } else  {
        set prompt OUTPUT
        $window mark gravity prompt right
        $window insert end "$prompt % " prompt
        $window mark gravity prompt left
        $window see insert
    }
    set prompt OUTPUT
}


proc getCommand {window} {
    global prompt
    set command [$window get prompt end-1c]
    $window mark set prompt insert
    return $command
}

proc searchHistory {direction} {
    global historyIndex
    switch $direction {
        backwards {
            if {$historyIndex > -20} {
                set command [history event $historyIndex]
                incr historyIndex -1
                return $command
            } else  {
                return {}
            }
        }
        forwards {
            if {$historyIndex < -1} {
                incr historyIndex
                set command [history event [expr $historyIndex+1]]
                return $command
            } else  {
                return {}
            }
        }
        default {tk_messageBox -message "Internal Error" -type ok; return}
    }
    
}

proc onKeyPressed {win} {
    if {[$win compare insert < prompt]} {
        $win mark set insert prompt
        $win see insert
    }
}

proc onButtonPressed {win} {
}

proc onKeyHome {win} {
    $win mark set insert prompt
}

proc onKeyUp {win} {
    if {[$win compare insert >= prompt]} {
        $win mark set insert prompt
        $win delete prompt end
        set command [searchHistory backwards]
        $win insert prompt $command
        $win see insert
    } else  {
        $win mark set insert "insert - 1line"
    }
}

proc onKeyDown {win} {
    if {[$win compare insert >= prompt]} {
        $win mark set insert prompt
        $win delete prompt end
        set command [searchHistory forwards]
        $win insert prompt $command
        $win see insert
    } else  {
        $win mark set insert "insert + 1line"
    }
}

proc onKeyLeft {win} {
    if {[$win compare insert >= prompt]} {
        set curPos [lindex [split [$win index insert] "."] 1]
        set promptPos [lindex [split [$win index prompt] "."] 1]
        if {$curPos <= $promptPos} {
            return {}
        } else  {
            $win mark set insert insert-1c
        }
    } else  {
        $win mark set insert "insert -1c"
    }
}

proc onKeyRight {win} {
    $win mark set insert "insert +1c"
}

proc onKeyBackSpace {win} {
    
    if {[$win compare insert <= prompt]} {
        return {}
    }  else  {
        $win delete insert-1c
    }
}




proc onKeyHome {win} {
    $win mark set insert prompt
}

proc errorInit {win {width 60} {height 5}} {
    global Console
    global prompt
    global window
    #global historyIndex
    global EditorData
    
    #set historyIndex 0
    set window $win
    set prompt ERROR
    
    if {$window == "."} {
        set window ""
    }
    set Console [interp create]
    
    
    $Console alias setValues SetValues
    $Console alias exit reset
    $Console alias puts errorPuts
    text $window.t -width $width -height $height -bg white
    catch {$window.t configure -font $EditorData(options,fonts,editorFont)}
    
    $window.t tag configure output -foreground blue
    $window.t tag configure prompt -foreground grey40
    $window.t tag configure error -foreground red
    $window.t insert end "$prompt % " prompt
    $window.t mark set prompt insert
    $window.t mark gravity prompt left
    #bind $window.t <KeyPress-Return> {%W mark set insert "prompt lineend"}
    #bind $window.t <KeyRelease-Return> {evalCommand %W $Console [getCommand %W];break}
    #bind $window.t <Key-Up> {onKeyUp %W ; break}
    #bind $window.t <Key-Down> {onKeyDown %W ; break}
    #bind $window.t <Key-Return> {errorPuts ""}
    bind $window.t <Key-Left> {onKeyLeft %W ; break}
    bind $window.t <Key-Right> {onKeyRight %W ; break}
    bind $window.t <Key-BackSpace> {onKeyBackSpace %W;break}
    bind $window.t <Key-Home> {onKeyHome %W ;break}
    bind $window.t <Control-c> {set dummy nothing}
    #bind $window.t <KeyPress> {onKeyPressed %W}
    pack $window.t -fill both -expand yes
    return $window.t
}

proc errorPuts {var {tag output} {win {}} {flash 0} {see 1}} {
    global prompt
    global errWindow
    
    if {$win == {}} {
        set win $errWindow
    }
    $win mark gravity prompt right
    $win insert end $var $tag
    if {[string index $var [expr [string length $var]-1]] != "\n"} {
        $win insert end "\n"
    }
    set prompt ERROR
    $win insert end "$prompt : " prompt
    $win mark gravity prompt left
    if $see {$win see insert}
    update
    if $flash {
        flashWin $win $flash
    }
    return
}

proc warnInit {win {width 60} {height 5}} {
    global Console
    global prompt
    global window
    #global historyIndex
    global EditorData
    
    #set historyIndex 0
    set window $win
    set prompt WARN
    
    if {$window == "."} {
        set window ""
    }
    set Console [interp create]
    
    
    $Console alias setValues SetValues
    $Console alias exit reset
    $Console alias puts warnPuts
    text $window.t -width $width -height $height -bg white
    catch {$window.t configure -font $EditorData(options,fonts,editorFont)}
    
    $window.t tag configure output -foreground blue
    $window.t tag configure prompt -foreground grey40
    $window.t tag configure error -foreground red
    $window.t insert end "$prompt % " prompt
    $window.t mark set prompt insert
    $window.t mark gravity prompt left
    #bind $window.t <KeyPress-Return> {%W mark set insert "prompt lineend"}
    #bind $window.t <KeyRelease-Return> {evalCommand %W $Console [getCommand %W];break}
    #bind $window.t <Key-Up> {onKeyUp %W ; break}
    #bind $window.t <Key-Down> {onKeyDown %W ; break}
    bind $window.t <Key-Left> {onKeyLeft %W ; break}
    bind $window.t <Key-Right> {onKeyRight %W ; break}
    bind $window.t <Key-BackSpace> {onKeyBackSpace %W;break}
    bind $window.t <Key-Home> {onKeyHome %W ;break}
    bind $window.t <Control-c> {set dummy nothing}
    #bind $window.t <KeyPress> {onKeyPressed %W}
    pack $window.t -fill both -expand yes
    return $window.t
}

proc warnPuts {var {tag output} {win {}} {flash 0} {see 1}} {
    global prompt
    global warWindow
    
    if {$win == {}} {
        set win $warWindow
    }
    $win mark gravity prompt right
    $win insert end $var $tag
    if {[string index $var [expr [string length $var]-1]] != "\n"} {
        $win insert end "\n"
    }
    set prompt WARN
    $win insert end "$prompt : " prompt
    $win mark gravity prompt left
    if $see {$win see insert}
    update
    if $flash {
        flashWin $win $flash
    }
    return
}



proc consoleInit {win {width 60} {height 5}} {
    global Console
    global prompt
    global window
    global historyIndex
    global EditorData
    
    set historyIndex 0
    set window $win
    set prompt OUTPUT
    
    if {$window == "."} {
        set window ""
    }
    set Console [interp create]
    
    
    $Console alias setValues SetValues
    $Console alias exit reset
    $Console alias puts consolePuts
    text $window.t -width $width -height $height -bg white
    catch {$window.t configure -font $EditorData(options,fonts,editorFont)}
    
    $window.t tag configure output -foreground blue
    $window.t tag configure prompt -foreground grey40
    $window.t tag configure error -foreground red
    $window.t insert end "$prompt % " prompt
    $window.t mark set prompt insert
    $window.t mark gravity prompt left
    bind $window.t <KeyPress-Return> {%W mark set insert "prompt lineend"}
    bind $window.t <KeyRelease-Return> {evalCommand %W $Console [getCommand %W];break}
    bind $window.t <Key-Up> {onKeyUp %W ; break}
    bind $window.t <Key-Down> {onKeyDown %W ; break}
    bind $window.t <Key-Left> {onKeyLeft %W ; break}
    bind $window.t <Key-Right> {onKeyRight %W ; break}
    bind $window.t <Key-BackSpace> {onKeyBackSpace %W;break}
    bind $window.t <Key-Home> {onKeyHome %W ;break}
    bind $window.t <Control-c> {set dummy nothing}
    bind $window.t <KeyPress> {onKeyPressed %W}
    pack $window.t -fill both -expand yes
    return $window.t
}
proc testTermInit {win {interp {}} {width 60} {height 5}} {
    global prompt
    global historyIndex
    global EditorData
    
    set historyIndex 0
    set prompt OUTPUT
    
    set termWin [text $win.t -width $width -height $height -bg white]
    catch {$termWin configure -font $EditorData(options,fonts,editorFont)}
    #$termWin tag configure output -foreground blue
    #$termWin tag configure prompt -foreground grey40
    $termWin tag configure error -foreground red
    $termWin insert end "$prompt : " prompt
    $termWin mark set prompt insert
    $termWin mark gravity prompt left
    bind $termWin <KeyPress-Return> {%W mark set insert "prompt lineend"}
    bind $termWin <KeyRelease-Return> {evalCommand %W $interp [getCommand %W];break}
    bind $termWin <Key-Up> {onKeyUp %W ; break}
    bind $termWin <Key-Down> {onKeyDown %W ; break}
    bind $termWin <Key-Left> {onKeyLeft %W ; break}
    bind $termWin <Key-Right> {onKeyRight %W ; break}
    bind $termWin <Key-BackSpace> {onKeyBackSpace %W;break}
    bind $termWin <Key-Home> {onKeyHome %W ;break}
    bind $termWin <Control-c> {set dummy nothing}
    bind $termWin <KeyPress> {onKeyPressed %W}
    pack $termWin -fill both -expand yes
    return $termWin
}

# this won´t be executed if con.tcl is sourced by another app
if {[string compare [info script] $argv0] == 0} {
    consoleInit .
}
