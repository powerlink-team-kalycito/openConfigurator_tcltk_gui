################################################################################
#
# tclparser.tcl
#
# this file contains procedures needed for a parser
# with syntaxhighlighting etc.
#
# It's a separate file so I could source it later on
# while working on it.
#
# Changes by A.Sievers, dated 03/15/00
# - now this file only parses the textfile and returns a nodelist
#   each entry including name, type, startindex and endindex
#
# zerbst@tu-harburg.de
#
#################################################################################


namespace eval Parser {
}

################################################################################
#
#  proc Parser::parseCode
#
# wannabe replacement of the current code parsing. Should do everything:
#
# syntax highlighting, inclusive [incr tcl] support
# tree with objects (namespace, class, procs etc.) [more or less done]
# perhaps one day inheritance
#
# Changes: 28.01.2000 Changed Top and Bottom to <Top> and <Bottom> to avoid
#                     mixing it up with a proc
#
#                     Changed names of treenodes. The new syntax starts with the
#                     filename, then a # separated list of objetc,type names
#                     1. It's easy to get the filename now
#                     2. It's possible to have a namespace and proc of the same name e.g.
#
# zerbst@tu-harburg.d
#
# Changes: 15.03.00 by Andreas Sievers (andreas.sievers@t-online.de)
#     parseCode works now independent from a specific application
#     and returns a list of "nodes", each including
#     - name
#     - type
#     - startIndex
#     - endIndex
#
# args:
#     - rootnode: rootnode, e.g. filename
#     - textWidget: the text widget, whose text has to be parsed
#     - range: an optional range in the form "[list start end]"
#              if range is empty {} the whole text will be parsed
#     - code: an optional code will be executed while parsing
#             e.g. code for a progressbar
#
################################################################################
proc Parser::parseCode {rootnode textWidget {range {}} {code {}} } {
    variable TxtWidget
    
    set TxtWidget $textWidget
    if {$range != {} && [$TxtWidget compare [lindex $range 0 ] == [lindex $range 1 ]]} {
        return {}
    }
    set rexp {^(( |\t|\;)*((namespace )|(class )|(proc )|(body )|(configbody )))|((( |\t|\;)*[^\#]*)((method )|(constructor )|(destructor )))}
    if {$range == {}} {
        set start 1.0
        set end "end -1c"
        set NodeList [parse $start $end $rootnode $rexp 0 $code]
        set NodeList [linsert $NodeList 0 [list $rootnode#<Bottom> code "end -1lines" "end -1lines lineend" ]]
        set NodeList [linsert $NodeList 0 [list $rootnode#<Top> code 1.0 "1.0 lineend"]]
        set NodeList [linsert $NodeList 0 [list $rootnode file "1.0" "end -1c"]]
    } else  {
        set start [lindex $range 0]
        set end [lindex $range 1]
        set NodeList [parse $start $end $rootnode $rexp 0 $code]
    }
    return $NodeList
}

proc Parser::GetClosePair {symbol {index ""}} {
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

################################################################################
#
#  proc Parser::parse
#
#  parses code between $start and $end. Found objects likes namespaces,
#  classes and procs are reported to Editor::tnewNode to be inserted in the
#  tree. The type and start and end is saved in the tree as data
#
#  No syntax highlighting yet, no inheritance yet
#
#  Changes: 28.01.2000 Changed name of treenodes, see parseCode
#           01.02.2000 Handle itcl forward declaration correct
#                      Handle itcl inheritance correct and save inheritance to tree
#
#  zerbst@tu-harburg.d
################################################################################

proc Parser::parse {start end node rexp {recursion 0} {code {}} } {
    variable TxtWidget
    
    set nodeList {}
    
    if {$start == ""} {
        return
    }
    set end [$TxtWidget index $end]
    set nend $start
    
    # look for the first char which isn´t a whitespace
    # and test if it is an openbrace
    set brace_rexp {[^ \t\n(\\\n)]}
    
    set result [$TxtWidget search -forwards -regexp $rexp  $start $end]
    set ancestors {}
    
    while {$result != ""} {
        set line [$TxtWidget get $result "$result lineend"]
        
        set temp [string trim $line \ \t\;]
        set nend $result
        #perhaps look at rights later
        regsub {(^private )|(^protected )|(^public )} $temp "" temp
        regsub -all "\[ \t\;\]+" $temp { } temp
        scan $temp %s%s%s token arg1 arg2
        if {![info exists arg1]} {
            set nend "$nend +1lines"
            if {[$TxtWidget compare $nend >= "end -1c"]} {
                break
            }
            set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
            continue
        }
        #get the first token and decide furtheron
        switch $token {
            
            "namespace" {
                #Really a new namespace ?
                if {![string match eval $arg1] || [catch {set name $arg2}]} {
                    set nend "$nend +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                #Get the name
                set name $arg2
                regsub {^::} $name "" name
                regsub -all {::} $name \# name
                #Get the start end end of the namespace
                set nstart [$TxtWidget search -forward \{ $result "$result lineend"]
                if {$nstart == ""} {
                    set nend "$nend +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                set nend [GetClosePair "\{" "$nstart"]
                if {$nend == ""} {
                    set nend "$start +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                #Create a node
                set nname "$node\#$name"
                lappend nodeList [list $nname namespace "$result linestart"  "$nend +1c"]
                if {[$TxtWidget compare $nend > $end]} {
                    editorWindows::deleteMarks $end $nend
                }
                foreach NamespaceNode [parse $nstart $nend $nname $rexp 1] {
                    lappend nodeList $NamespaceNode
                }
            }
            
            "class" {
                
                #setting newline sensivity
                #allowing whitespaces at linestart followed by one of the alternative keywords
                #or allowing any char but no hash (with possible leading white spaces)
                #at linestart followed by one of the alternative keywords
                set rexp {^(( |\t|\;)*((namespace )|(class )|(proc )|(body )|(configbody )))|((( |\t|\;)*[^\#]*)((method )|(constructor )|(destructor )))}
                #Get the name
                set name $arg1
                ##puts stderr "\tname $name"
                regsub {^::} $name "" name
                regsub -all {::} $name \# name
                
                
                #Get the start end end of the class
                set nstart [$TxtWidget search -forward \{ $result "$result lineend"]
                if {$nstart == ""} {
                    set nend "$nend +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                set nend [GetClosePair "\{" "$nstart"]
                if {$nend == ""} {
                    set nend "$start +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                #Create a node
                set nname "$node\#$name"
                lappend nodeList [list $nname class "$result linestart"  "$nend +1c"]
                foreach ClassNode [parse $nstart $nend $nname $rexp 1] {
                    lappend nodeList $ClassNode
                }
            }
            
            "proc"  {
                set proc_rexp {^[ \t\;]*(proc )}
                #Get the name
                set name $arg1
                regsub {^::} $name "" name
                regsub -all {::} $name \# name
                
                #Skip the arguments
                set nstart [$TxtWidget search -forward \{ $result "$result lineend"]
                if {$nstart == ""} {
                    set nend "$nend +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                
                set nend [GetClosePair "\{" "$nstart"]
                if {$nend == ""} {
                    set nend "$nstart +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                
                #Get the start end end of the proc
                
                set nstart [$TxtWidget search -regexp $brace_rexp "$nend+1c" end]
                if {[$TxtWidget get $nstart] != "\{"} {
                    set nend "$nend +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                set nend [GetClosePair "\{" "$nstart"]
                if {$nend == ""} {
                    set nend "$nstart +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                #Create a node
                set nname "$node\#$name"
                lappend nodeList [list $nname proc "$result linestart"  "$nend +1c"]
                foreach ProcNode [parse $nstart $nend $nname $proc_rexp 1] {
                    lappend nodeList $ProcNode
                }
            }
            
            "method" {
                #Get the name
                set name $arg1
                #Skip the arguments
                set nstart [$TxtWidget search -forward \{ $result "$result lineend"]
                if {$nstart == ""} {
                    set nend "$nend +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                set nend [GetClosePair "\{" "$nstart"]
                if {$nend == ""} {
                    set nend "$nstart +1lines linestart"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                #Get the start end end of the method
                
                set nstart [$TxtWidget search -regexp $brace_rexp "$nend+1c" end]
                if {[$TxtWidget get $nstart] != "\{"} {
                    #this is a forward declaration!
                    #Create a node
                    set nname "$node\#$name"
                    if {![$Editor::treeWindow exists $nname]} {
                        lappend nodeList [list $nname method "$result linestart"  "$nend +1c"]
                    }
                    set nname "$node\#$name\#declaration"
                    lappend nodeList [list $nname forward "$result linestart"  "$nend +1c"]
                } else  {
                    set nend [GetClosePair "\{" "$nstart"]
                    if {$nend == ""} {
                        set nend "$nstart +1lines"
                        if {[$TxtWidget compare $nend >= "end -1c"]} {
                            break
                        }
                        set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                        continue
                    }
                    #Create a node
                    set nname "$node\#$name"
                    lappend nodeList [list $nname method "$result linestart"  "$nend +1c"]
                }
            }
            
            "body" {
                #Get the name
                set name $arg1
                regsub {^::} $name "" name
                regsub -all {::} $name \# name
                
                #Skip the arguments
                set nstart [$TxtWidget search -forward \{ $result "$result lineend"]
                if {$nstart == ""} {
                    set nend "$nend +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                set nend [GetClosePair "\{" "$nstart"]
                if {$nend == ""} {
                    set nend "$nstart +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                #Get the start end end of the body
                set nstart [$TxtWidget search -regexp $brace_rexp "$nend+1c" end]
                if {[$TxtWidget get $nstart] != "\{"} {
                    set nend "$nend +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                set nend [GetClosePair "\{" "$nstart"]
                if {$nend == ""} {
                    set nend "$nstart +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                
                #Create a node
                switch -- $name {
                    "constructor" {set nname "$node\#constructor\#body"}
                    "destructor" {set nname "$node\#destructor\#body"}
                    default {set nname "$node\#$name\#body"}
                }
                lappend nodeList [list $nname body "$result linestart"  "$nend +1c"]
            }
            
            "configbody" {
                #Get the name
                set name $arg1
                regsub {^::} $name "" name
                regsub -all {::} $name \# name
                #Get the start end end of the configbody
                set nstart [$TxtWidget search -regexp $brace_rexp "$nend+1c" end]
                if {[$TxtWidget get $nstart] != "\{"} {
                    set nend "$nend +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                set nend [GetClosePair "\{" "$nstart"]
                if {$nend == ""} {
                    set nend "$nstart +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                
                #Create a node
                set nname "$node\#$name"
                lappend nodeList [list $nname configbody "$result linestart"  "$nend +1c"]
            }
            
            "constructor" {
                
                #Skip the arguments
                set nstart [$TxtWidget search -forward \{ $result "$result lineend"]
                if {$nstart == ""} {
                    set nend "$nend +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                set nend [GetClosePair "\{" "$nstart"]
                if {$nend == ""} {
                    set nend "$nstart +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                
                #Get the start end end of the next environmet
                set nstart [$TxtWidget search -regexp $brace_rexp "$nend+1c" end]
                if {[$TxtWidget get $nstart] != "\{"} {
                    set nend "$nend +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                set nend [GetClosePair "\{" "$nstart"]
                if {$nend == ""} {
                    set nend "$nstart +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                
                #If there is some inheritance defined, go on to the body
                set rexp1 "[lindex $ancestors 0]::constructor"
                set inhet [$TxtWidget search -forwards -regexp $rexp1 $nstart $nend]
                
                if {$inhet != "" && [expr  (floor($inhet) >= floor($nstart) ) && ( floor($inhet) <= floor($nend) )]} {
                    #Get the start end end of the next environmet
                    set nstart [$TxtWidget search -regexp $brace_rexp "$nend+1c" end]
                    if {[$TxtWidget get $nstart] != "\{"} {
                        set nend "$nend +1lines"
                        if {[$TxtWidget compare $nend >= "end -1c"]} {
                            break
                        }
                        set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                        continue
                    }
                    set nend [GetClosePair "\{" "$nstart"]
                    if {$nend == ""} {
                        set nend "$nstart +1lines"
                        if {[$TxtWidget compare $nend >= "end -1c"]} {
                            break
                        }
                        set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                        continue
                    }
                }
                
                
                
                #Create a node
                set nname "$node\#constructor"
                lappend nodeList [list $nname constructor "$result linestart"  "$nend +1c"]
            }
            
            "destructor" {
                #Get the start end end of the body
                set nstart [$TxtWidget search -regexp $brace_rexp "$nend+1c" end]
                if {[$TxtWidget get $nstart] != "\{"} {
                    set nend "$nend +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                set nend [GetClosePair "\{" "$nstart"]
                
                if {$nend == ""} {
                    set nend "$nstart +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                }
                #Create a node
                set nname "$node\#destructor"
                lappend nodeList [list $nname destructor "$result linestart"  "$nend +1c"]
            }
            
            default {
                #skip line
                if {$nend == ""} {
                    set nend "$nstart +1lines"
                    if {[$TxtWidget compare $nend >= "end -1c"]} {
                        break
                    }
                    set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
                    continue
                } else  {
                    set nend "$nend +1lines"
                }
            }
        } ;# end of switch
        
        set result [$TxtWidget search -forwards -regexp $rexp $nend $end ]
        
        set nend [$TxtWidget index $nend]
        if {$code != {}} {
            eval $code
        }
    } ;#end of while
    return $nodeList
}
