#-----------------------------------------------------------------------+
#		=================
#		SEARCH PROCEDURES
#		=================
#-----------------------------------------------------------------------+

# source [file join $rootDir search.tcl]


proc grep {findStr path fileMasks args} {
    
    #parse args
    set subFolders 0
    
    set argLen [llength $args]
    
    for {set i 0} {$i < $argLen} {incr i} {
        set option [lindex $args $i]
        incr i
        
        set value [lindex $args $i]
        
        switch -- "$option" {
            "-subfolders" {
                set subFolders $value
            }
        }
    }
    
    if {[file tail $path] != ""} {
        append path "/"
    }
    
    set pattern ""
    foreach fileMask $fileMasks {
        append pattern $path
        append pattern "$fileMask "
    }
    
    set result {}
    set findStrLen [string length $findStr]
    
    set files [eval "glob -nocomplain -- $pattern"]
    
    foreach file $files {
        switch [file type $file] {
            "file" {
                #process file
                set fileID [open $file "r"]
                set lineNum 1
                
                while {[gets $fileID line] != -1} {
                    set startIndex 0
                    set lineStr $line
                    
                    while {[string first $findStr $line] != -1} {
                        set index [string first $findStr $line]
                        
                        # set string after founded string
                        set line [string range $line [expr {$index + $findStrLen}] end]
                        
                        
                        #append to result
                        lappend result [list $file $lineNum [expr {$startIndex + $index}] $lineStr]
                        
                        # set string after founded string
                        set startIndex [expr {$startIndex + $index + $findStrLen}]
                        set line [string range $line [expr {$index + $findStrLen}] end]
                    }
                    
                    incr lineNum
                }
                
                close $fileID
            }
            
            "directory" {
                if {$subFolders} {
                    #process directory
                    set fileResult [grep $findStr $file $fileMasks $args]
                    #append into the list
                    foreach i $fileResult {
                        lappend result $l
                    }
                }
            }
            
            "link" {
                # nothing to do. Now, we skip links
            }
        }
    }
    
    return $result
}


#-----------------------------------------------------------------------+
#		Search line no...
#-----------------------------------------------------------------------+

proc search_line_proc {w tag line} {
    if {$line == ""} return
    $w mark set insert $line.0
    $w see insert
    
    global search_option_blink
    set blink $search_option_blink
    if {$blink != "off"} {
        textHiliteLineNo $w $line $tag
    }
    
    focus .
    focus $w
    
    if {$blink == "during"} {
        after 2000 blinkoff_search_proc $w $tag
    }
}

#-----------------------------------------------------------------------+
#		Search boxes...
#-----------------------------------------------------------------------+

proc blinkoff_search_proc {w tag} {
    $w tag remove $tag 0.0 end
}

proc search_proc {w string tag icase where match blink} {
    global search_var_string search_option_icase search_option_area search_option_match search_option_blink
    
    $w tag remove $tag 0.0 end
    if {$string == ""} {
        return
    }
    
    set search_var_string $string
    set cur [$w index insert]
    
    if {$where == "global"} {
        set cur 1.0
        set where forwards
    }
    
    if {$where == "forwards"} {
        set stopIndex end
    } elseif {$where == "backwards"} {
        $w mark set insert "insert-1 chars"
        $w mark set insert "insert wordstart"
        set cur [$w index insert]
        set stopIndex 1.0
    }
    
    if {$icase == 1} {
        set icase -nocase
    } else {
        set icase -$match
    }
    set cur [$w search -count search_count $icase -$where -$match -- $string $cur $stopIndex]
    if {$cur == ""} {
        tk_messageBox -message "Searchstring <$string> not found!" -type ok -icon info
        return
    }
    if {$blink != "off"} {
        global search_count
        $w tag add $tag $cur "$cur + $search_count char"
        $w tag configure $tag -background yellow
    }
    
    $w mark set insert "$cur + $search_count char"
    
    $w see insert
    
    focus $w
    
    if {$blink == "during"} {
        after 2000 blinkoff_search_proc $w $tag
        return "$cur $search_count"
    }
}

proc search_default_options {} {
    
    global search_var_string
    set search_var_string ""
    
    global search_option_icase
    set search_option_icase 1
    
    global search_option_prompt
    set search_option_prompt 1
    
    global search_option_area
    set search_option_area forwards
    
    global search_option_match
    set search_option_match "exact"
    
    global search_option_blink
    set search_option_blink during
    
}

# on startup set options to defaults
search_default_options

#---------------------------------------------------------------------
#	search options subroutine
#---------------------------------------------------------------------

proc search_options_sub {w {replace 1}} {
    
  # shared common proc for drawing search options
  # used by both search & replace dialogs
    
	#---------------------------------------------------------------------
	#	search options
	#---------------------------------------------------------------------
    
    frame $w.option -relief raised -bd 4
    pack $w.option -fill both -expand yes
    
    frame $w.option.header -relief groove -bd 2
    pack  $w.option.header -side top -fill both -expand yes
    
    label $w.option.header.l -text "Options" -relief groove -bd 2
    pack $w.option.header.l -side left -fill both -expand yes
    
    button $w.option.header.default -text "Default options" \
        -command search_default_options
    pack $w.option.header.default -side left
    
    
	#---------------------------------------------------------------------
	#	search options:mix
	#---------------------------------------------------------------------
    frame $w.option.mix -relief groove -bd 2
    pack $w.option.mix -fill both -side left -expand yes
    
	#frame $w.option.mix -relief groove -bd 2
	#pack $w.option.mix -side left -anchor nw
    
		#---------------------------------------------------------------------
		#	search options: ignore case
		#---------------------------------------------------------------------
    checkbutton $w.option.mix.case -variable search_option_icase -text "ignore case"
    pack $w.option.mix.case -anchor w
    
		#---------------------------------------------------------------------
		#	search options: prompt/pause before replace
		#---------------------------------------------------------------------
    if {$replace} {
        checkbutton $w.option.mix.prompt -variable search_option_prompt \
            -text "prompt before replace"
        pack $w.option.mix.prompt -anchor w
    }
	#---------------------------------------------------------------------
	#	search options: area
	#---------------------------------------------------------------------
    frame $w.option.direction -relief groove -bd 2
    pack $w.option.direction -fill both -side left -expand yes
    
    label $w.option.direction.label -text " Area : "
    pack $w.option.direction.label -anchor w
    
    radiobutton $w.option.direction.forward -variable search_option_area \
        -text "Forward" -value forwards
    pack $w.option.direction.forward -anchor w
    
    radiobutton $w.option.direction.backward -variable search_option_area \
        -text "Backward" -value backwards
    pack $w.option.direction.backward -anchor w
    
    radiobutton $w.option.direction.global -variable search_option_area \
        -text "Global" -value global
    pack $w.option.direction.global -anchor w
    
	#---------------------------------------------------------------------
	#	search options: match
	#---------------------------------------------------------------------
    frame $w.option.match -relief groove -bd 2
    pack $w.option.match -fill both -side left -anchor nw -expand yes
    
    label $w.option.match.label -text " Match : "
    pack $w.option.match.label -anchor w
    
    radiobutton $w.option.match.exact -variable search_option_match \
        -text "exact" -value exact
    pack $w.option.match.exact -anchor w
    
    radiobutton $w.option.match.regexp -variable search_option_match \
        -text "regexp" -value regexp
    pack $w.option.match.regexp -anchor w
    
	#---------------------------------------------------------------------
	#	search options: blink
	#---------------------------------------------------------------------
    frame $w.option.blink -relief groove -bd 2
    pack $w.option.blink -fill both -side left -anchor nw -expand yes
    
    label $w.option.blink.label -text " Blink : "
    pack $w.option.blink.label -anchor w
    
    radiobutton $w.option.blink.during -variable search_option_blink \
        -text "during search" -value during
    pack $w.option.blink.during -anchor w
    
    radiobutton $w.option.blink.off -variable search_option_blink \
        -text "off" -value off
    pack $w.option.blink.off -anchor w
    
    radiobutton $w.option.blink.always -variable search_option_blink \
        -text "always" -value always
    pack $w.option.blink.always -anchor w
    
}

proc search_dbox {t} {
    set w .search
    catch "destroy $w"
    toplevel $w
	# wm geometry	 $w	+300+300
    wm title	 $w	"Search "
    wm iconname	 $w	"Search "
    
    label $w.msg -text " Enter search string: " -relief groove
    pack $w.msg -fill x
    
    entry $w.entry -textvariable search_var_string
    pack $w.entry -fill x
    
	#---------------------------------------------------------------------
	#	call search options built-in frame
	#---------------------------------------------------------------------
    search_options_sub $w 0
	#---------------------------------------------------------------------
    
    frame $w.butn
    pack $w.butn -fill x
    
    button $w.butn.ok -text OK -command "
    set s \[$w.entry get\]
		# puts stdout \$s
    search_proc $t \$s search \$search_option_icase \$search_option_area \$search_option_match \$search_option_blink
    destroy $w
    " \
        -width 12 -under 0 -pady 0 -default active
    pack  $w.butn.ok -side left -expand 1 \
        -padx 3m -pady 2m
    button $w.butn.cancel -text Cancel -command "destroy $w" \
        -width 12 -under 0 -pady 0
    
    pack  $w.butn.cancel -side left -expand 1 \
        -padx 3m -pady 2m
    
        
    bind $w.entry <Key-Return> "$w.butn.ok  invoke"
    bind $w.entry <Key-Escape> "$w.butn.cancel  invoke"
    
    focus $w
    focus $w.entry
    
    centerW $w
    
    bind $t <Control-L> "repeat_last_search $t"
    bind $t <Control-l> "repeat_last_search $t"
}

proc search_files_dbox {} {
    set w .search
    catch "destroy $w"
    toplevel $w
	# wm geometry	 $w	+300+300
    wm title	 $w	"Search "
    wm iconname	 $w	"Search "
    
    label $w.msg -text " Enter search string: " -relief groove
    pack $w.msg -fill x
    
    entry $w.entry -textvariable search_var_string
    pack $w.entry -fill x
    
    frame $w.butn
    pack $w.butn -fill x
    
    button $w.butn.ok -text OK -command {
        set s [.search.entry get]
        set result [grep $s [pwd] *.tcl ]
        destroy .search
        if {$result != {}} {
            Editor::showResults $result
        } else  {
            tk_messageBox -message "\"$s\" not found!" -title "ASED Information" -icon info
        }
        
    } \
        -width 12 -under 0 -pady 0 -default active
    pack  $w.butn.ok -side left -expand 1 \
        -padx 3m -pady 2m
    button $w.butn.cancel -text Cancel -command "destroy $w" \
        -width 12 -under 0 -pady 0
    
    pack  $w.butn.cancel -side left -expand 1 \
        -padx 3m -pady 2m
    
    
	#button $w.butn.default -text "Default options" -command search_default_options
	#pack  $w.butn.default -side left -expand 1
    
    bind $w.entry <Key-Return> "$w.butn.ok  invoke"
    bind $w.entry <Key-Escape> "$w.butn.cancel  invoke"
    
    focus $w
    focus $w.entry
    
    centerW $w
}

proc centerW w {
    BWidget::place $w 0 0 center
}

# bind .t <Control-L> repeat_last_search
# bind .t <Control-l> repeat_last_search

proc repeat_last_search { t} {
    global search_var_string search_option_icase search_option_area search_option_match search_option_blink
    
    search_proc $t $search_var_string search $search_option_icase $search_option_area $search_option_match $search_option_blink
}