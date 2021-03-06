###############################################################################
#  This software is copyrighted by Ramon Rib� (RAMSAN) ramsan@cimne.upc.es.
#  (http://gid.cimne.upc.es/ramsan) The following terms apply to all files
#  associated with the software unless explicitly disclaimed in individual files.
#
#  The authors hereby grant permission to use, copy, modify, distribute,
#  and license this software and its documentation for any purpose, provided
#  that existing copyright notices are retained in all copies and that this
#  notice is included verbatim in any distributions. No written agreement,
#  license, or royalty fee is required for any of the authorized uses.
#  Modifications to this software may be copyrighted by their authors
#  and need not follow the licensing terms described here, provided that
#  the new terms are clearly indicated on the first page of each file where
#  they apply.
#
#  IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
#  FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
#  ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
#  DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#
#  THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
#  IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
#  NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
#  MODIFICATIONS.
################################################################################


#!/bin/sh
#\
exec wish8.5 "$0" ${1+"$@"}

global masterRootDir
global auto_path

set libDir [file join $masterRootDir lib]
set auto_path [linsert $auto_path 0 $libDir]

namespace eval HelpViewer {
    
    variable HelpBaseDir
    variable LastFileList
    variable images
	variable displayArrangeList
	variable workingFolderArrangeList
}
	global helpFile
    set helpFile "Project Wizard.html"
	set HelpViewer::HelpBaseDir [file join $masterRootDir help]
	set HelpViewer::displayArrangeList [list \
		"Project Wizard.html" \
		"Simple and Advanced view.html" \
		"Adding a CN(Controlled Node).html" \
		"Adding Index and Subindex.html" \
		"Editing OBD Entries.html" \
		"Editing MN & CN Properties.html" \
		"Deleting the nodes.html" \
		"Building the project.html" \
		"Project options.html" \
		"Known bugs and troubleshooting.html" \
	]

#package provide helpviewer 1.0
# requiring exactly 2.1 to avoid getting the one from Activestate
catch { package require -exact Tkhtml 2.1 }

package require BWidget 1.6
package require supergrid
package require dialogwin
package require fileutil
package require htmlparse

if {"$tcl_platform(platform)" != "windows"} {
	    # Background color based on OS
	    option add *background #d7d5d3 userDefault
}


proc filenormalize { file } {
    
    if { $file == "New file" } { return $file }
    if { $file == "" } { return "" }
    
    set pwd [pwd]
    catch {
        cd [file dirname $file]
        set file [file join [pwd] [file tail $file]]
    }
    cd $pwd
    
    if { $::tcl_platform(platform) == "windows" } {
        catch { set file [file attributes $file -longname] }
    }
    
    return $file
}

if { [info command tkTabToWindow] == "" } {
    proc tkTabToWindow {w} {
        focus $w
        after 100 {
            set w [focus]
            if {[string equal [winfo class $w] Entry]} {
                $w selection range 0 end
                $w icursor end
            }
        }
    }
}

set comms [list tkButtonInvoke tkTextSelectTo tkEntryInsert tkEntryBackspace \
        tk_textCut tk_textCopy tk_textPaste tk_focusNext tk_focusPrev tkTextClosestGap \
        tkTextAutoScan tkCancelRepeat]

foreach i $comms {
    auto_load $i
    if {![llength [info commands $i]]} {
        tk::unsupported::ExposePrivateCommand $i
    }
}

namespace eval History {
    variable list ""
    variable pos
    variable menu
    
    proc Add { name } {
        variable list
        variable pos
        variable menu
        
        lappend list $name
        set pos [expr [llength $list]-1]
        if { $pos == 0 } {
            if { [info exists menu] && [winfo exists $menu] } {
                $menu entryconf Backward -state disabled
            }
        } else {
            if { [info exists menu] && [winfo exists $menu] } {
                $menu entryconf Backward -state normal
            }
        }
        if { [info exists menu] && [winfo exists $menu] } {
            $menu entryconf Forward -state disabled
        }
    }
    proc GoHome { w } {
        variable list
        variable pos
        variable menu
        global helpFile
        set pos 0
        if { [info exists menu] && [winfo exists $menu] } {
            $menu entryconf Backward -state disabled
        }
        if { [info exists menu] && [winfo exists $menu] } {
            $menu entryconf Forward -state normal
        }
        # HelpViewer::LoadRef $w [lindex $list $pos] 0
        HelpViewer::LoadRef $w [file join $HelpViewer::HelpBaseDir $helpFile] 0
    }
    proc GoBackward { w } {
        variable list
        variable pos
        variable menu
        
        incr pos -1
        if { $pos == 0 } {
            if { [info exists menu] && [winfo exists $menu] } {
                $menu entryconf Backward -state disabled
            }
        }
        if { [info exists menu] && [winfo exists $menu] } {
            $menu entryconf Forward -state normal
        }
        HelpViewer::LoadRef $w [lindex $list $pos] 0
    }
    proc GoForward { w } {
        variable list
        variable pos
        variable menu
        
        incr pos 1
        if { $pos == [expr [llength $list]-1] } {
            if { [info exists menu] && [winfo exists $menu] } {
                $menu entryconf Forward -state disabled
            }
        }
        if { [info exists menu] && [winfo exists $menu] } {
            $menu entryconf Backward -state normal
        }
        HelpViewer::LoadRef $w [lindex $list $pos] 0
    }
}

namespace eval HelpPrefs {
    variable tttrick 0
    variable RunningAlone 0
}



proc HelpViewer::GiveLastFile { w } {
    variable LastFileList
    set retval ""
    catch {
        set w [winfo toplevel $w]
        set retval $LastFileList($w)
    }
    return $retval
}
proc HelpViewer::EnterLastFile { w file } {
    variable LastFileList
    set w [winfo toplevel $w]
    set LastFileList($w) $file
}

#A font chooser routine.
#
#  $base.h.h config -fontcommand pickFont
proc HelpViewer::pickFont {size attrs} {
    global tcl_platform
    
    if { [lsearch [font names] HelpFont] != -1 } {
        set family [font conf HelpFont -family]
        set fsize [font conf HelpFont -size]
    } else {
        set family Helvetica
        switch $::tcl_platform(platform) {
            windows { set fsize 11 }
            default { set fsize 15 }
        }
    }
    
    if { $HelpPrefs::tttrick } {
        set a [expr {-1<[lsearch $attrs fixed]?{Symbol}:"$family"}]
    } else {
        set a [expr {-1<[lsearch $attrs fixed]?{Courier}:"$family"}]
    }
    set b [expr {-1<[lsearch $attrs italic]?{italic}:{roman}}]
    set c [expr {-1<[lsearch $attrs bold]?{bold}:{normal}}]
    set d [expr int($fsize*pow(1.2,$size-4))]
    #     if { $tcl_platform(platform) != "windows"} {
    #         set d [expr {3+int(12*pow(1.2,$size-4))}]
    #     } else {
    #         set d [expr {3+int(12*pow(1.2,$size-6))}]
    #     }
    
    list $a $d $b $c
}

proc HelpViewer::CreateFrame { frame { hscroll 1 } {vscroll 1 }  } {
    frame $frame
    frame $frame.f1
    frame $frame.f2
    if { $hscroll } {
        set hscrollcommand "$frame.f2hsb set"
    } else { set xscrollcommand "" }
    if { $vscroll } {
        set yscrollcommand "$frame.f1vsb set"
    } else { set yscrollcommand "" }
    html $frame.f1.h \
            -xscrollcommand $hscrollcommand \
            -yscrollcommand $yscrollcommand \
            -padx 5 \
            -pady 9 \
            -formcommand FormCmd \
            -imagecommand ImageCmd \
            -scriptcommand ScriptCmd \
            -appletcommand AppletCmd \
            -underlinehyperlinks 0 \
            -bg white -tablerelief raised \
            -resolvercommand ResolveUri \
            -exportselection 1 \
            -takefocus 1
    
    bind $frame.f1.h.x <1> "HelpViewer::HrefBinding $frame.h %x %y"
    if { $hscroll } {
        frame $frame.f2.sp -width [winfo reqwidth $base.h.vsb] -bd 2 -relief raised
        scrollbar $frame.f2.hsb -orient horizontal -command "$frame.f1.h xview"
        pack $base.f2.sp -side right -fill y
        pack $frame.f2.hsb -side left -fill x -expand 1
    }
    if { $vscroll } {
        scrollbar $frame.f1.vsb -orient vertical -command "$frame.f1.h yview"
        pack $frame.f1.vsb -side right -fill y -expand 1
    }
    pack $frame.f1.h -side left -fill both -expand 1
    pack $frame.f1 -side top -fill both -expand 1
    pack $frame.f2 -side bottom -fill x -expand 1
}

proc HelpViewer::FrameCmd { base type arglist } {
    global HelpPriv
    switch $type {
        frameset {
            set HelpPriv(frameset) $arglist
            foreach i [array names frame*] {
                uset HelpPriv($i)
            }
        }
        frame {
            set i 0
            while { [info exists HelpPriv(frame$i)] } { incr i }
            set HelpPriv(frame$i) $arglist
        }
        /frameset {
            foreach "name args" "$HelpPriv(frameset)" {
                switch $name {
                    rows {
                    }
                }
            }
            set i 0
            while { [info exists HelpPriv(frame$i)] } {
                foreach "name args" "$HelpPriv(frame$i)" {
                    
                    
                }
                incr i
            }
        }
    }
    tk_messageBox -icon error -message $type----$arglist-- -type ok
}

# This routine is called for each form element
#
proc HelpViewer::FormCmd {n cmd args} {
    switch $cmd {
        select -
        textarea -
        input {
            set w [lindex $args 0]
            label $w -image nogifsm
        }
    }
}

proc HelpViewer::ImageCmd {args} {
    global OldImages Images showImages
    if {!$showImages} {
        return smgray
    }
    set fn [lindex $args 0]
    
    set list [file split $fn]
    if { [lindex $list 0] == "." } {
        set list [lrange $list 1 end]
    }
    set fn [eval [concat "file join $list"]]
    
    if { [file dirname $fn] == "." } {
        set fn [file tail $fn]
    }
    if {[info exists OldImages($fn)]} {
        set Images($fn) $OldImages($fn)
        unset OldImages($fn)
        return $Images($fn)
    }
    if {[catch {image create photo -file $fn} img]} {
        return smgray
    }
    if {[image width $img]*[image height $img]>20000} {
        global BigImages
        set b [image create photo -width [image width $img] \
                -height [image height $img]]
        set BigImages($b) $img
        set img $b
        after idle "HelpViewer::MoveBigImage $b"
    }
    set Images($fn) $img
    return $img
}

proc HelpViewer::MoveBigImage b {
    global BigImages
    if {![info exists BigImages($b)]} return
    $b copy $BigImages($b)
    image delete $BigImages($b)
    unset BigImages($b)
    update
}


# This routine is called for every <SCRIPT> markup
#
proc HelpViewer::ScriptCmd {args} {
    # puts "ScriptCmd: $args"
}

# This routine is called for every <APPLET> markup
#
proc HelpViewer::AppletCmd {w arglist} {
    label $w -text "The Applet $w" -bd 2 -relief raised
}

# This procedure is called when the user clicks on a hyperlink.
# See the "bind $base.h.h.x" below for the binding that invokes this
# procedure
#
proc HelpViewer::HrefBinding {w x y} {
    
    set new [$w href $x $y]
    catch {
        if { [llength $new] == 1 } {
            set new [lindex $new 0]
            if { [llength $new] == 1 } {
                set new [lindex $new 0]
            }
        }
    }
    LoadRef $w $new
}

proc HelpViewer::LoadRef { w new { enterinhistory 1 } } {
    global tcl_platform
    
    
    if { [regexp {http:/localhost/cgi-bin/man/man2html\?(\w+)\+(\w+)} $new {} sec word] } {
        SearchManHelpFor $w $word $sec
        return
    } elseif { $new != "" && [regexp {[a-zA-Z]+[a-zA-Z]:.*} $new] } {
        regexp {http:/.*} $new url
        if { [regexp {:/[^/]} $url] } {
            regsub {:/} $url {://} url
        }
        if { $tcl_platform(platform) != "windows"} {
            set comm [auto_execok konqueror]
            if { $comm == "" } {
                set comm [auto_execok netscape]
            }
            if { $comm == "" } {
                tk_messageBox -icon warning -message \
                        "Check url: $url in your web browser." -type ok
            } else {
                exec $comm $url &
            }
        } else {
            global env
            if {[file exists [file join $env(ProgramFiles) "internet explorer" iexplore.exe]]} {
                exec [file join $env(ProgramFiles) "internet explorer" iexplore.exe] $url &
            } else  {
                tk_messageBox -icon warning -message \
                        "Check url: $url in your web browser." -type ok
            }
            # set comm [freewrap::shell_getCmd_imp .html open]
            # if { $comm == "" } {
                # tk_messageBox -icon warning -message \
                        # "Check url: $url in your web browser." -type ok
            # } else {
                # regsub -all {\\} $comm {\\\\} comm
                # exec "$comm" $url &
            # }
        }
        return
    }
    
    if {$new!=""} {
        set LastFile [GiveLastFile $w]
        if { [string match \#* [file tail $new]] } {
            set new $LastFile[file tail $new]
        }
        set pattern $LastFile#
        set len [string length $pattern]
        incr len -1
        if {[string range $new 0 $len]==$pattern} {
            incr len
            $w yview [string range $new $len end]
            if { $enterinhistory } {
                History::Add $new
            }
        } elseif { [regexp {(.*)\#(.*)} $new {} file tag] } {
            LoadFile $w $file $enterinhistory $tag
        } else {
            LoadFile $w $new $enterinhistory
        }
    }
}

proc HelpViewer::Load { w } {
    set filetypes {
        {{Html Files} {.html .htm}}
        {{All Files} *}
    }
    global lastDir htmltext
    set f [tk_getOpenFile -initialdir $lastDir -filetypes $filetypes]
    
    if {$f!=""} {
        LoadFile $w $f
        set lastDir [file dirname $f]
    }
}

# Clear the screen.
#
# Clear the screen.
#
proc HelpViewer::Clear { w } {
    global Images OldImages hotkey
    $w clear
    catch {unset hotkey}
}

proc HelpViewer::ClearOldImages {} {
    global OldImages
    #          foreach fn [array names OldImages] {
    #              image delete $OldImages($fn)
    #          }
    #          catch {unset OldImages}
}
proc HelpViewer::ClearBigImages {} {
    global BigImages
    #          foreach b [array names BigImages] {
    #              image delete $BigImages($b)
    #          }
    #          catch {unset BigImages}
}

# Read a file
#
proc HelpViewer::ReadFile {name} {
    if { [file dirname $name] == "." } {
        set name [file tail $name]
    }
    if {[catch {open $name r} fp]} {
        tk_messageBox -icon error -message $fp -type ok
        return {}
    } else {
        fconfigure $fp -translation binary
        set r [read $fp [file size $name]]
        close $fp
        if { [regexp {(?i)<meta\s+[^>]*charset=utf-8[^>]*>} $r] } {
            set fp [open $name r]
            fconfigure $fp -encoding utf-8
            set r [read $fp]
            close $fp
        }
        return $r
    }
}

# Load a file into the HTML widget
#
proc HelpViewer::LoadFile {w name { enterinhistory 1 } { tag "" } } {
    global HelpPriv
    if { $name == "" } { return }
    
    if { [file isdir $name] } {
        set files [glob -dir $name *]
        set ipos [lsearch -regexp $files {(?i)(index|contents|_toc)\.(htm|html)}]
        if { $ipos != -1 } {
            set name [lindex $files $ipos]
        } else { return }
    }
    
    
    set html [ReadFile $name]
    if {$html==""} return
    Clear $w
    EnterLastFile $w $name
    
    $w config -base $name
    if { $enterinhistory } {
        if { $tag == "" } {
            History::Add $name
        } else {
            History::Add $name#$tag
        }
    }
    $w sel clear
    $w parse $html
    ClearOldImages
    if { $tag != "" } {
        update idletasks
        $w yview $tag
    }
    TryToSelect $name
    variable SearchPos
    set SearchPos ""
}

proc HelpViewer::GiveManHelpNames { word } {
    
    if { [auto_execok man2html] == "" } { return "" }
    
    set err [catch { exec man -aw $word } file]
    if { $err } { return "" }
    
    set words ""
    foreach i [split $file \n] {
        set ext [string trimleft [file ext $i] .]
        if { $ext == "gz" } { set ext [string trimleft [file ext [file root $i]] .] }
        if { [lsearch $words "$word (man $ext)"] == -1 } {
            lappend words "$word (man $ext)"
        }
    }
    return $words
}

proc HelpViewer::SearchManHelpFor { w word { mansection "" } } {
    
    if { $mansection == "" } {
        regexp {(\S*)\s+\(man\s+(.*)\)} $word {} word mansection
    }
    
    set err [catch { exec man -aw $word } file]
    if { $err } { return }
    
    set files [split $file \n]
    
    if { [llength $files] > 1 } {
        set found 0
        foreach i $files {
            set ext [string trimleft [file ext $i] .]
            if { $ext == "gz" } { set ext [string trimleft [file ext [file root $i]] .] }
            if { $mansection == $ext } {
                set found 1
                set file $i
                break
            }
        }
        if { !$found } { set file [lindex $files 0] }
    } else { set file [lindex $files 0] }
    
    if { [file ext $file] == ".gz" } {
        set comm [list exec gunzip -c $file | man2html]
    } else { set comm [list exec man2html $file] }
    
    set err [catch { eval $comm } html]
    #if { $err } { return }
    
    Clear $w
    
    $w sel clear
    $w parse $html
    ClearOldImages
    variable SearchPos
    set SearchPos ""
}

# Refresh the current file.
#
proc HelpViewer::Refresh {w args} {
    set LastFile [GiveLastFile $w]
    if {![info exists LastFile] || ![winfo exists $w] } return
    LoadFile $w $LastFile 0
}

proc HelpViewer::ResolveUri { args } {
    return [file join [file dirname [lindex $args 0]] [lindex $args 1]]
}

proc HelpViewer::ManageSel { htmlw w x y type } {
    global HelpPriv tcl_platform
    if { ![winfo exists  $w] } { return }
    if { [winfo parent $w] != $htmlw } { return }
    if { [info exists HelpPriv(lastafter)] } {
        after cancel $HelpPriv(lastafter)
    }
    switch -glob $type {
        press {
            update idletasks
            $htmlw sel clear
            set idx [$htmlw index @$x,$y]
            if { $idx == "" } { return }
            $htmlw insert $idx
            $htmlw sel set $idx $idx
        }
        motion* {
            if { $type == "motion" } {
                #set ini [$htmlw index sel.first]
                set ini [$htmlw index insert]
                if { $ini == "" } {
                    $htmlw sel clear
                } else {
                    set idx [$htmlw index @$x,$y]
                    if { $idx <= $ini } {
                        $htmlw sel set $idx $ini
                    } else {
                        $htmlw sel set $ini $idx
                    }
                }
            }
            set isout 0
            if { $x > [winfo width $htmlw] } {
                $htmlw xview scroll 1 units
                set isout 1
            } elseif { $x <0 } {
                $htmlw xview scroll -1 units
                set isout 1
            }
            if { $y > [winfo height $htmlw] } {
                $htmlw yview scroll 1 units
                set isout 1
            } elseif { $y <0 } {
                $htmlw yview scroll -1 units
                set isout 1
            }
            if { $isout } {
                set HelpPriv(lastafter) [after 100 HelpViewer::ManageSel \
                        $htmlw $w $x $y motionout]
            }
        }
        release {
            #set ini [$htmlw index sel.first]
            set ini [$htmlw index insert]
            if { $ini == "" } {
                $htmlw sel clear
                return
            }
            set idx [$htmlw index @$x,$y]
            if { $idx == $ini } {
                $htmlw sel clear
            } else {
                if { $idx <= $ini } {
                    $htmlw sel set $idx $ini
                } else {
                    $htmlw sel set $ini $idx
                }
            }
            if { $tcl_platform(platform) != "windows"} {
                selection own -command "HelpViewer::LooseSelection $htmlw" $htmlw
            }
        }
        
    }
}


proc HelpViewer::LooseSelection { w } {
    $w sel clear
}

proc HelpViewer::CopySelected { w { offset 0 } { maxBytes 0} } {
    global tcl_platform
    
    set ini [$w index sel.first]
    set end [$w index sel.last]
    if { $ini == "" || $end == "" } { return }
    
    regexp {([0-9]+)[.]([0-9]+)} $ini {} initoc inipos
    regexp {([0-9]+)[.]([0-9]+)} $end {} endtoc endpos

    set rettext ""
    set iposlast [expr $endtoc-$initoc]
    set ipos 0
    
    foreach i [$w token list $initoc $endtoc] {
        set type [lindex $i 1]
        set contents [join [lrange $i 2 end]]
        switch -- $type {
            Text {
                set inichar 0
                set endchar [string length $contents]
                if { $ipos == 0 } {
                    set inichar $inipos
                }
                if { $ipos == $iposlast } {
                    set endchar [expr $endpos-1]
                }
                append rettext [string range $contents $inichar $endchar]
            }
            Space {
                if { [lindex $contents 1] == 0 } {
                    append rettext " "
                } else {
                    append rettext "\n"
                }
            }
        }
        incr ipos
    }
    if { $tcl_platform(platform) == "windows"} {
        clipboard clear -displayof $w
        clipboard append -displayof $w $rettext
    } else {
        return [string range $rettext $offset [expr $offset+$maxBytes-1]]
    }
}

# what can be: HTML or Word or CSV
proc HelpViewer::SaveHTMLAs { w what } {
    
    set fromfile [GiveLastFile $w]
    switch $what {
        HTML {
            set types {
                {{HTML file}      {.html .htm}   }
                {{All Files}       *             }
            }
            set ext ".html"
            set initial [file tail $fromfile]
        }
        Word {
            set types {
                {{Word file}      {.doc}         }
                {{All Files}       *             }
            }
            set ext ".doc"
            set initial [file root [file tail $fromfile]].doc
        }
        CSV {
            set types {
                {{CSV file}      {.csv .txt}     }
                {{All Files}       *             }
            }
            set ext ".csv"
            set initial [file root [file tail $fromfile]].csv
        }
    }
    if { [file exists ConcretePrefs::reportexportdir] && \
                [file isdir $ConcretePrefs::reportexportdir] } {
        set defaultdir $ConcretePrefs::reportexportdir
    } else { set defaultdir "" }
    
    if { $::tcl_platform(platform) == "windows" } {
        set tofile [tk_getSaveFile -defaultextension $ext -filetypes $types \
                -initialfile $initial -parent $w -initialdir $defaultdir \
                -title "Save Results"]
    } else {
        set tofile [Browser-ramR file save]
    }
    
    
    if { $tofile == "" } { return }
    
    catch {
        set ConcretePrefs::reportexportdir [file dirname $filename]
    }
    
    if { [file ext $tofile] == ".html" || [file ext $tofile] == ".htm" } {
        set reportexportdir [file dirname $tofile]
        set imgdir [file join $reportexportdir timages]
        if { [file exists $imgdir] } {
            set retval [tk_dialogRAM  $w._tmp Warning \
                    [concat "Are you sure to delete directory "\
                    " '$imgdir' and all its contents?"]\
                    warning 0 OK Cancel]
            if { $retval == 1 } { return }
            if { [catch {
                    file delete -force $imgdir
                } err] } {
                WarnWin "error: Could not delete directory '$imgdir' ($err)"
                return
            }
        }
        
        if { [catch {
                file copy -force [file join [file dirname $fromfile] timages] \
                        $imgdir
                file copy -force $fromfile $tofile
            } err] } {
            WarnWin [concat "Problems exporting report to '$tofile' ($err). "\
                    "Check write permissions and disk space"]
            return
        }
    } elseif { [file ext $tofile] == ".doc" || [file ext $tofile] == ".rtf" } {
        rtf:HTML2RTF $fromfile $tofile "Ram Series"
    } elseif { [file ext $tofile] == ".csv" || [file ext $tofile] == ".txt" } {
        rtf:HTML2CSV $fromfile $tofile "Ram Series"
    } else {
        WarnWin "Unknown extension for file '$tofile'"
        return
    }
    set comm [FindApplicationForOpening $tofile]
    # do not visualize
    set comm ""
    if { $comm == "" } {
        WarnWin "Report exported OK to file '$tofile'"
    } else {
        set text "Report exported OK to file '$tofile' Do you want to visualize it?"
        set retval [tk_messageBox -default no -icon question -message $text \
                -parent $w -title "Report exported" -type yesno]
        if { $retval == "yes" } {
            eval exec $comm [list [file native $tofile]] &
        }
    }
}
proc HelpViewer::HTMLToClipBoardCSV { w } {
    set fromfile [GiveLastFile $w]
    rtf:HTML2CSV $fromfile "" "Ram Series"
    WarnWin Done
}
proc HelpViewer::FindApplicationForOpening { file } {
    if { $::tcl_platform(platform) == "windows" } {
        return [auto_execok start]
    } else {
        set comm ""
        switch [string tolower [file extension $file]] {
            ".htm" - ".html" {
                set comm [auto_execok konqueror]
                if { $comm == "" } {
                    set comm [auto_execok netscape]
                }
            }
            ".csv" - ".txt" {
                set comm [auto_execok kspread]
            }
        }
    }
    return $comm
}

proc HelpViewer::HelpWindow { file { base .} { geom "" } { title "" } } {
    variable HelpBaseDir
    variable html
    variable tree
    variable searchlistbox1
    variable searchlistbox2
    variable notebook
    
    if { [info command html] == "" } {
        set text "Package tkhtml could not be load, and so, it is not possible to see the help.\n"
        append text "The RamDebugger distribution only contains tkhtml libraries "
        append text "for Windows and Linux.\n"
        append text "You must get Tkhtml for other OS separately and install it in order to use the help"
        WarnWin $text
        return
    }
    
    global lastDir tcl_platform argv0
    set imagesdir [file join [file dirname [info script]] images]
    
    if { $tcl_platform(platform) != "windows" } {
        option add *Scrollbar*Width 10
        option add *Scrollbar*BorderWidth 1
        option add *Button*BorderWidth 1
    }
    option add *Menu*TearOff 0
    
    if { $tcl_platform(platform) != "windows" } {
        #          option add *background AntiqueWhite3
        #          option add *Button*background bisque3
        #          option add *Menu*background bisque3
        #          option add *Button*foreground black
        #          option add *Entry*background thistle
        #          option add *DisabledForeground grey60
        #          option add *HighlightBackground AntiqueWhite3
    }
    
    catch { destroy $base }
    
    if { $title == "" } { set title Help }
    
    if { [file isdir $file] } {
        set HelpBaseDir $file
    } else {
        # set HelpBaseDir [file dirname $file]
    }
    set HelpBaseDir [filenormalize $HelpBaseDir]
    
    #          if { $geom == "" } {
    #              set width 400
    #              set height 500
    #              set x [expr [winfo screenwidth $base]/2-$width/2]
    #              set y [expr [winfo screenheight $base]/2-$height/2]
    #              wm geom $base ${width}x${height}+${x}+${y}
    #          } else {
    #              wm geom $base $geom
    #          }
    #wm withdraw .
    if { [info procs InitWindow] != "" } {
        InitWindow $base $title PostHelpViewerWindowGeom
    } else {
        toplevel $base
        wm title $base $title
    }
	wm withdraw .
    wm withdraw $base
	
	
    # These images are used in place of GIFs or of form elements
    #
    
    if { [lsearch [image names] biggray] == -1 } {
        
        image create photo biggray -data {
            R0lGODdhPAA+APAAALi4uAAAACwAAAAAPAA+AAACQISPqcvtD6OctNqLs968+w+G4kiW5omm
            6sq27gvH8kzX9o3n+s73/g8MCofEovGITCqXzKbzCY1Kp9Sq9YrNFgsAO///
        }
        image create photo smgray -data {
            R0lGODdhOAAYAPAAALi4uAAAACwAAAAAOAAYAAACI4SPqcvtD6OctNqLs968+w+G4kiW5omm
            6sq27gvH8kzX9m0VADv/
        }
        image create photo nogifbig -data {
            R0lGODdhJAAkAPEAAACQkADQ0PgAAAAAACwAAAAAJAAkAAACmISPqcsQD6OcdJqKM71PeK15
            AsSJH0iZY1CqqKSurfsGsex08XuTuU7L9HywHWZILAaVJssvgoREk5PolFo1XrHZ29IZ8oo0
            HKEYVDYbyc/jFhz2otvdcyZdF68qeKh2DZd3AtS0QWcDSDgWKJXY+MXS9qY4+JA2+Vho+YPp
            FzSjiTIEWslDQ1rDhPOY2sXVOgeb2kBbu1AAADv/
        }
        image create photo nogifsm -data {
            R0lGODdhEAAQAPEAAACQkADQ0PgAAAAAACwAAAAAEAAQAAACNISPacHtD4IQz80QJ60as25d
            3idKZdR0IIOm2ta0Lhw/Lz2S1JqvK8ozbTKlEIVYceWSjwIAO///
        }
    }
    
    if { [lsearch [image names] imatge_fletxa_e] == -1 } {
        
        image create photo imatge_fletxa_e -data {
            R0lGODlhJwAeAJECAE5qmoWh0f///wAAACH5BAEAAAIALAAAAAAnAB4AAAJb
            lI+py+0Po5y00mBzCCDf3XnRBooQWZoNmqoK27oHTNc2Y+c69+4+HJr9hqSg
            gIjkIZJDo4Hpcz6hOemUSrNeUYCu9wsOdx1AGY5rPsfSyzVbqH0r34s4/Y4v
            AAA7
        }
        image create photo imatge_fletxa_d -data {
            R0lGODlhJwAeAJECAE5qmoWh0f///wAAACH5BAEAAAIALAAAAAAnAB4AAAJa
            lI+py+0Po5y0WhfuDVlT3nkRGIoYaT4klzYr677yPMf0fTP4Ti/8/1IAh6AE
            cQgAII6/pJGJcz6hM6kiic1qtwCZtWV4fcGC1ZhMOqM56nUb/SYLlPK63VAA
            ADs=
        }
        image create photo imatge_quit -data {
            R0lGODlhIAAeAJECAE5qmoWh0f///wAAACH5BAEAAAIALAAAAAAgAB4AAAJm
            lI+py+0Powq02kulwNwC2YVfVAHmiaYgNWpP6QYvG8sNrFU3nesLHgr+eEFh
            AlgMHYlJ5QHZxJiezKintalaA1METpAKm64T3oqLpXJr3fI613anIXPvtmet
            D/MasT/uEig4eFAAADs=
        }
        image create photo imatge_save -data {
            R0lGODlhIAAeAOcAAEdjk05qmktnl1VxoWuHt2yIuUhklUlllVJunmSAsHuX
            x4ik1Iml1YSg0EhklE9rm197q3aSwoai0oej04Wh0YSg0V57q01pmVt3p3GN
            vYGez3yazpuy2YGe0XWRwVdzo2yIuIGdzYKf0IGe0KC229Lc7vz9/v///4Og
            0FFtnUpmllNvn2eDs32ZyX2bzn+cz5ev2MfU6vT3+6W63YSh02N/r1BsnGJ+
            rnmVxYSh0X6cz4+o1bvL5uzw+Njh8HqWxkpnl4Cdz4ij0rDC4eLp9P7+/1Rw
            oExomIKezoKg0miEtEdklGmFtY2o1Pj6/H6by4ql04+p1Yej1Fh0pNvj8evw
            +L/N54mk022JuWSAsYOh06i83vT2+8bT6pau14Kez/r7/fv8/dHc7qC123iY
            zVx4qHaTw36c0NDb7dzk8qq933mYzXuZz4ah0aK11ZSs04Kf0XKOvmB8rIWi
            1J602ufs9rXG44ul03qZzXmYzoOf0Zmv1LvH2Nbb3OPk3b/K2X+d0Pn6/fH1
            +sDP55Kr1niYzoCd0JKq07PC19HX297g3d3f3djc3Nfb3Iai0WF9rXGOvoOg
            0pCq1X+dz3uZzn2bz42n07LD3MvT2tzf3d3g3dnd3KG11XiUxMXP2tXY16Kp
            p8vPz9vf39ve3MPN2X+c0MnT4H+Kiic5PomTluLl5drd3Iul0mWBsaK32b7D
            wDlKTlRjZt3h4eXl3qm61oqm1tne4FNiZTpKT7rAwd3h4Nre3MTO2aO21Yei
            0V56qsLO4Y6Xlig7P3mFh+Pl5Kq71oum0oCe0YSi1Jmw1svOzIaPj8fLyLLB
            15Gq04Oh1Iek1H6aylNvoM3U2sPP4Jyy14Kg04ej1YOg0YCe0oaj1XeTw3yY
            yIWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh
            0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh0YWh
            0YWh0YWh0YWh0YWh0YWh0SH5BAEAAP8ALAAAAAAgAB4AAAj+AP8JHEiwoEEA
            AQwqXHhQwAACBQwwnFjwAIIEChYwaJCQIkMHDyBEkMBgAoUKDCx4NOjgAoYM
            DUpS0LCBAocOHg6s/AdAwAcQIRgsoCBiwwgSJUycQCEhhUcVK1i0WLBAAgoX
            L2DEkHGi64kZNGowPGDjBo4JDCTk0OFiB48eXuP60PEDiMIUESjIDLJByBAi
            cQOfKCJkghGFR5BIKIpiho8igiMPSaJkCUsmDJqUcBK58wkiOp4cUThgAhTP
            qKNImaJQgAIdVFALrmLlCgMsDg5m0bJFdlcuXbywrUDhywWFCCRUAOM5jJgx
            GsiIoEBdbxmFB8ycQRM5jRoKa9j+tHHzBk71BXF0GpQzh07cOnbu4MmjZw+f
            Pn7+AKpO3YbCBw1oEIgggxCyQSGGHIJIIooswggjjTjCHwOPYAdJJJJMQkkl
            llyCSSaabPLgg4pwMkJ1E3SigkIYMECdI558Akoooow44iik7IciAgpdEIIE
            FJRiyimopKKKjSOuwgpx1DHQCgAsFTBUB668AksssiDJyCiz0NIBdRPUosBo
            Bn0wFAU52HILLrno8uAuiuzCSy++oCWBB78EcJxBR7QAJCDABCPMMMRokgkm
            xRhzDDIT/FBDCuotBAALLsKRjDLLMJNIM8508Aw00ShhxIorSWMSBXBMQ001
            elhzDRI1WExxBJQ7/aPCWRRgQ0E22lAQRxkX5FYrQTekVdI2cjwQ6bAEpbAA
            N60gQCqziK0gAK3UBgQAOw==
        }
        
        image create photo appbook16 -data {
            R0lGODlhEAAQAIQAAPwCBAQCBDyKhDSChGSinFSWlEySjCx+fHSqrGSipESO
            jCR6dKTGxISytIy6vFSalBxydAQeHHyurAxubARmZCR+fBx2dDyKjPz+/MzK
            zLTS1IyOjAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAVkICCOZGmK
            QXCWqTCoa0oUxnDAZIrsSaEMCxwgwGggHI3E47eA4AKRogQxcy0mFFhgEW3M
            CoOKBZsdUrhFxSUMyT7P3bAlhcnk4BoHvb4RBuABGHwpJn+BGX1CLAGJKzmK
            jpF+IQAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0K
            qSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpo
            dHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
        }
        image create photo appbookopen16 -data {
            R0lGODlhEAAQAIUAAPwCBAQCBExCNGSenHRmVCwqJPTq1GxeTHRqXPz+/Dwy
            JPTq3Ny+lOzexPzy5HRuVFSWlNzClPTexIR2ZOzevPz29AxqbPz6/IR+ZDyK
            jPTy5IyCZPz27ESOjJySfDSGhPTm1PTizJSKdDSChNzWxMS2nIR6ZKyijNzO
            rOzWtIx+bLSifNTGrMy6lIx+ZCRWRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAae
            QEAAQCwWBYJiYEAoGAFIw0E5QCScAIVikUgQqNargtFwdB9KSDhxiEjMiUlg
            HlB3E48IpdKdLCxzEAQJFxUTblwJGH9zGQgVGhUbbhxdG4wBHQQaCwaTb10e
            mB8EBiAhInp8CSKYIw8kDRSfDiUmJ4xCIxMoKSoRJRMrJyy5uhMtLisTLCQk
            C8bHGBMj1daARgEjLyN03kPZc09FfkEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJ
            RiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwg
            cmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
        }
        image create photo filedocument16 -data {
            R0lGODlhEAAQAIUAAPwCBFxaXNze3Ly2rJSWjPz+/Ozq7GxqbJyanPT29HRy
            dMzOzDQyNIyKjERCROTi3Pz69PTy7Pzy7PTu5Ozm3LyqlJyWlJSSjJSOhOzi
            1LyulPz27PTq3PTm1OzezLyqjIyKhJSKfOzaxPz29OzizLyidIyGdIyCdOTO
            pLymhOzavOTStMTCtMS+rMS6pMSynMSulLyedAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaQ
            QIAQECgajcNkQMBkDgKEQFK4LFgLhkMBIVUKroWEYlEgMLxbBKLQUBwc52Hg
            AQ4LBo049atWQyIPA3pEdFcQEhMUFYNVagQWFxgZGoxfYRsTHB0eH5UJCJAY
            ICEinUoPIxIcHCQkIiIllQYEGCEhJicoKYwPmiQeKisrKLFKLCwtLi8wHyUl
            MYwM0tPUDH5BACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24g
            Mi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZl
            ZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
        }
        image create photo viewmag16 -data {
            R0lGODlhEAAQAIUAAPwCBCQmJDw+PAwODAQCBMza3NTm5MTW1HyChOTy9Mzq
            7Kze5Kzm7OT29Oz6/Nzy9Lzu7JTW3GTCzLza3NTy9Nz29Ize7HTGzHzK1AwK
            DMTq7Kzq9JTi7HTW5HzGzMzu9KzS1IzW5Iza5FTK1ESyvLTa3HTK1GzGzGzG
            1DyqtIzK1AT+/AQGBATCxHRydMTCxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZ8
            QIAQEBAMhkikgFAwHAiC5FCASCQUCwYiKiU0HA9IRAIhSAcTSuXBsFwwk0wy
            YNBANpyOxPMxIzMgCyEiHSMkGCV+SAQQJicoJCllUgBUECEeKhAIBCuUSxMK
            IFArBIpJBCxmLQQuL6eUAFCusJSzr7GLArS5Q7O1tmZ+QQAh/mhDcmVhdGVk
            IGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0KqSBEZXZlbENvciAxOTk3
            LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpodHRwOi8vd3d3LmRldmVs
            Y29yLmNvbQA7
        }
        
    }
    
    ################################################################################
    # menu is not mapped in this version
    ################################################################################
    
    #     frame $base.mbar -bd 2 -relief raised
    #     menubutton $base.mbar.file -text File -underline 0 -menu $base.mbar.file.m
    #     pack $base.mbar.file -side left -padx 5
    #     set m [menu $base.mbar.file.m]
    #     $m add command -label Open -underline 0 -command "HelpViewer::Load $base.h.h"
    #     $m add command -label Refresh -underline 0 -command "HelpViewer::Refresh $base.h.h"
    #     $m add separator
    #     $m add command -label Index -acc Ctrl-i -command "\
    #                              HelpViewer::LoadFile $base.h.h [list $file] ;\
    #                              set HelpViewer::lastDir [list [file dirname $file]]"
    #     $m add command -label Refresh -acc Ctrl-r -command "HelpViewer::Refresh $base.h.h"
    #     $m add separator
    #     $m add command -label Close -acc Ctrl-q -command "destroy $base"
    #     bind $base <Control-o> "HelpViewer::Load $base.h.h"
    #     bind $base <Control-r> "$m invoke Refresh"
    #     bind $base <Control-i> "$m invoke Index"
    #     bind $base <Control-q> "$m invoke Close"
    
    #     menubutton $base.mbar.edit -text Edit -underline 0 -menu $base.mbar.edit.m
    #     pack $base.mbar.edit -side left -padx 5
    #     set m [menu $base.mbar.edit.m]
    #     $m add command -label Copy -acc Ctrl-c -command "HelpViewer::CopySelected $base.h.h"
    #     bind $base <Control-c> "$m invoke Copy"
    
    #     menubutton $base.mbar.go -text Go -underline 0 -menu $base.mbar.go.m
    #     pack $base.mbar.go -side left -padx 5
    #     set History::menu [menu $base.mbar.go.m]
    #     $History::menu add command -label Backward -acc Alt-<- -state disabled -command \
    #     "History::GoBackward $base.h.h"
    #     $History::menu add command -label Forward -acc Alt--> -state disabled -command \
    #     "History::GoForward $base.h.h"
    #     bind $base <Alt-Left> "$History::menu invoke Backward"
    #     bind $base <Alt-Right> "$History::menu invoke Forward"
    
    global showImages
    set showImages 1
    #    $m add checkbutton -label {Show Images} -variable showImages
    #trace variable showImages w "Refresh $base.h.h"
    
    ################################################################################
    # the HTML viewer
    ################################################################################
    
    set pw [PanedWindow $base.pw -side top -pad 0 -weights available -grid 0 -activator line]
    if { [catch {
            foreach "weight1 weight2" [RamDebugger::ManagePanes $pw h "5 12"] break
        }]} {
        set weight1 5
        set weight2 12
    }

	set pane1 [$pw add -weight $weight1 ]
    
    NoteBook $pane1.nb -homogeneous 1 -bd 1 -internalborderwidth 3 \
             -grid "0 py3"
    set notebook $pane1.nb
    
    set f1 [$pane1.nb insert end tree -text "Contents" -image appbook16]
    set sw [ScrolledWindow $f1.lf -relief sunken -borderwidth 1 -grid "0"]
    set tree [Tree $sw.tree -bg white\
            -relief flat -borderwidth 2 -width 15 -highlightthickness 0\
            -redraw 1 -deltay 18 -bg white\
            -opencmd   "HelpViewer::moddir 1 $sw.tree" \
            -closecmd  "HelpViewer::moddir 0 $sw.tree" \
            -width 5  \
            ]
    $sw setwidget $tree
    
    set font [option get $tree font Font]
    if { $font != "" } {
        $tree configure -deltay [expr [font metrics $font -linespace]]
    }
    if { $::tcl_platform(platform) != "windows" } {
        $tree configure  -selectbackground \#678db2 -selectforeground white
    }
    $pane1.nb itemconfigure tree -raisecmd "focus $tree"
    
    set f2 [$pane1.nb insert end search -text "Search" -image viewmag16]
    label $f2.l1 -text "S:" -grid 0
    entry $f2.e1 -textvariable HelpViewer::searchstring -grid "1 py3" -bg white
	
    $pane1.nb itemconfigure search -raisecmd "tkTabToWindow $f2.e1"
    bind $f2.e1 <Return> "focus $f2.lf1.lb; HelpViewer::SearchInAllHelp"
    
    
    ScrolledWindow $f2.lf1 -relief sunken -borderwidth 1 -grid "0 2"
    set searchlistbox1 [listbox $f2.lf1.lb -listvar HelpViewer::SearchFound -bg white \
            -exportselection 0]
    $f2.lf1 setwidget $f2.lf1.lb
    
    ScrolledWindow $f2.lf2 -relief sunken -borderwidth 1 -grid "0 2"
    set searchlistbox2 [listbox $f2.lf2.lb -listvar HelpViewer::SearchFound2 -grid "0 2" \
            -bg white -exportselection 0]
    $f2.lf2 setwidget $f2.lf2.lb
    
    bind $f2.lf1.lb <FocusIn> "if { \[%W curselection] == {} } { %W selection set 0 }"
    bind $f2.lf1.lb <Double-1> "focus $f2.lf2.lb; HelpViewer::SearchInAllHelpL1"
    bind $f2.lf1.lb <Return> "focus $f2.lf2.lb; HelpViewer::SearchInAllHelpL1"
    bind $f2.lf2.lb <FocusIn> "if { \[%W curselection] == {} } { %W selection set 0 }"
    bind $f2.lf2.lb <Double-1> "HelpViewer::SearchInAllHelpL2"
    bind $f2.lf2.lb <Return> "HelpViewer::SearchInAllHelpL2"
    
    set HelpViewer::SearchFound ""
    set HelpViewer::SearchFound2 ""
    
    supergrid::go $f1
    supergrid::go $f2
    $pane1.nb compute_size
    $pane1.nb raise tree
    
    set pane2 [$pw add -weight $weight2]
    set sw [ScrolledWindow $pane2.lf -relief sunken -borderwidth 0 -grid "0 2"]
    set html [html $sw.h \
            -padx 5 \
            -pady 9 \
            -formcommand HelpViewer::FormCmd \
            -imagecommand HelpViewer::ImageCmd \
            -scriptcommand HelpViewer::ScriptCmd \
            -appletcommand HelpViewer::AppletCmd \
            -underlinehyperlinks 0 \
            -bg white -tablerelief raised \
            -resolvercommand HelpViewer::ResolveUri \
            -exportselection 1 \
            -takefocus 1 \
            -fontcommand HelpViewer::pickFont \
            -width 550 \
            -height 500 \
            -borderwidth 0 \
            ]
    $sw setwidget $html
    
    bind $html.x <1> "focus $html; HelpViewer::HrefBinding $html %x %y"
    
    bind $base <Control-c> "HelpViewer::CopySelected $html"
    
    set buttFrame [frame $base.buts -grid "0 ew"]
    button $base.buts.b1 -image imatge_fletxa_e -relief flat \
            -command "History::GoBackward $html" -height 50 -grid "0 e" \
            -highlightthickness 0
    button $base.buts.b2 -image imatge_fletxa_d -relief flat \
            -command "History::GoForward $html" -height 50 -grid "1 w" \
            -highlightthickness 0

    menubutton $base.buts.b3 -text "More..." -relief flat \
            -menu $base.buts.b3.m -grid "2 e" -activebackground grey93

    menu $base.buts.b3.m

    $base.buts.b3.m add command -label "Home" -acc "" -command \
            "History::GoHome $html"
    $base.buts.b3.m add command -label "Previous" -acc "Alt-Left" -command \
            "History::GoBackward $html"
    $base.buts.b3.m add command -label "Next" -acc "Alt-Right" -command \
            "History::GoForward $html"
    $base.buts.b3.m add separator
    $base.buts.b3.m add command -label "Search in page..." -acc "Ctrl+F" -command \
            "focus $html; HelpViewer::SearchWindow"
    $base.buts.b3.m add command -label "Search more" -acc "F3" -command \
            "focus $html; HelpViewer::Search"
    $base.buts.b3.m add separator
    $base.buts.b3.m add command -label "Close" -acc "ESC" -command \
            "help_exit"
    
    bind $html.x <3> [list tk_popup $base.buts.b3.m %X %Y]
    
    #     menubutton $base.buts.b3 -image imatge_save -bg grey93 -relief flat \
    #             -menu $base.buts.b3.m -height 50 -grid "2 e" -activebackground grey93
    
    #     menu $base.buts.b3.m
    #     $base.buts.b3.m add command -label "As HTML" -command \
    #             "HelpViewer::SaveHTMLAs $base HTML"
    #     $base.buts.b3.m add command -label "As RTF file (Word)" -command \
    #             "HelpViewer::SaveHTMLAs $base Word"
    #     $base.buts.b3.m add command -label "As CSV file (Excel)" -command \
    #             "HelpViewer::SaveHTMLAs $base CSV"
    #     $base.buts.b3.m add command -label "Copy to clipboard (Excel)" -command \
    #             "HelpViewer::HTMLToClipBoardCSV $base"
    
    if { $HelpPrefs::RunningAlone } {
		button $base.buts.b4 -image imatge_quit -relief flat \
                -command "exit" -height 50 -grid "3 e" \
                -highlightthickness 0
    } else {
		button $base.buts.b4 -image imatge_quit -relief flat \
                -command "help_exit" -height 50 -grid "3 e" \
                -highlightthickness 0
    }
    
    supergrid::go $pane1
    supergrid::go $pane2
    supergrid::go $buttFrame
    supergrid::go $base
    
    grid columnconf $base.buts "0 1" -weight 1
    grid columnconf $base.buts "2 3 4" -weight 0
    
    #     if { $HelpPrefs::RunningAlone } {
    #         grid $base.mbar -col 0 -row 0 -columnspan 3 -sticky ew
    #     }
    
    # This procedure is called when the user selects the File/Open
    # menu option.
    #
    set lastDir [pwd]
    
    #      $base.h.h token handler Frameset "FrameCmd $base"
    #      $base.h.h token handler Frame "FrameCmd $base"
    #      $base.h.h token handler /Frameset "FrameCmd $base"
    
    
    # This binding changes the cursor when the mouse move over
    # top of a hyperlink.
    #
    bind HtmlClip <Motion> {
        set parent [winfo parent %W]
        set url [$parent href %x %y]
        if {[string length $url] > 0} {
            $parent configure -cursor hand2
        } else {
            $parent configure -cursor {}
        }
    }
    
    
    if {[string equal "unix" $::tcl_platform(platform)]} {
        bind $html.x <4> { %W yview scroll -1 units }
        bind $html.x <5> { %W yview scroll 1 units }
        bind $tree.c <4> { %W yview scroll -5 units }
        bind $tree.c <5> { %W yview scroll 5 units }
    }
    
    focus $html
    
    bind $html
    bind $html <Prior> {
        %W yview scroll -1 pages
    }
    
    bind $html <Next> {
        %W yview scroll 1 pages
    }
    bind $html <Home> {
        %W yview moveto 0
    }
    
    bind $html <End> {
        %W yview moveto 1
    }
    
    
    bind $base <1> "HelpViewer::ManageSel $html %W %x %y press"
    bind $base <B1-Motion> "HelpViewer::ManageSel $html %W %x %y motion"
    bind $base <ButtonRelease-1> "HelpViewer::ManageSel $html %W %x %y release"
    if { $tcl_platform(platform) != "windows"} {
        selection handle $html "HelpViewer::CopySelected $html"
    }
    
    $tree bindText  <ButtonPress-1>        "HelpViewer::Select $tree 1"
    $tree bindText  <Double-ButtonPress-1> "HelpViewer::Select $tree 2"
    $tree bindImage  <ButtonPress-1>        "HelpViewer::Select $tree 1"
    $tree bindImage  <Double-ButtonPress-1> "HelpViewer::Select $tree 2"
    $tree bindText <Control-ButtonPress-1>        "HelpViewer::Select $tree 3"
    $tree bindImage  <Control-ButtonPress-1>        "HelpViewer::Select $tree 3"
    $tree bindText <Shift-ButtonPress-1>        "HelpViewer::Select $tree 4"
    $tree bindImage  <Shift-ButtonPress-1>        "HelpViewer::Select $tree 4"
    # dirty trick
    foreach i [bind $tree.c] {
        bind $tree.c $i "+ [list after idle [list HelpViewer::Select $tree 0 {}]]"
    }
    bind $tree.c <Return> "HelpViewer::Select $tree 1 {}"
    bind $tree.c <KeyPress> "if \[string is wordchar -strict {%A}] {HelpViewer::KeyPress %A}"
    bind $tree.c <Alt-KeyPress-Left> ""
    bind $tree.c <Alt-KeyPress-Right> ""
    bind $tree.c <Alt-KeyPress> { break }
    
    bind [winfo toplevel $html] <Alt-Left> "History::GoBackward $html; break"
    bind [winfo toplevel $html] <Alt-Right> "History::GoForward $html; break"
    
    FillDir $tree root
    
    bind [winfo toplevel $html] <Control-f> "focus $html; HelpViewer::SearchWindow ; break"
    bind [winfo toplevel $html] <F3> "focus $html; HelpViewer::Search ; break"
    #if { [info script] == $::argv0 } {
    #    bind [winfo toplevel $html] <Escape> "exit"
    #} else {        bind [winfo toplevel $html] <Escape> "destroy [winfo toplevel $html]"
    #}
    bind [winfo toplevel $html] <Escape> "help_exit"
    bind [winfo toplevel $html] <Control-f> "focus $html; HelpViewer::SearchWindow ; break"
    
    
    bind [winfo toplevel $html] <Alt-KeyPress-c> [list $notebook raise tree]
    bind [winfo toplevel $html] <Control-KeyPress-i> [list $notebook raise search]
    bind [winfo toplevel $html] <Alt-KeyPress-i> [list $notebook raise search]
    bind [winfo toplevel $html] <Control-KeyPress-s> [list $notebook raise search]
    bind [winfo toplevel $html] <Alt-KeyPress-s> [list $notebook raise search]
    
    
    # If an arguent was specified, read it into the HTML widget.
    #
    update
    if {$file!=""} {
        LoadFile $html $file
    }
    set x [expr [winfo screenwidth $base]/2-400]
    set y [expr [winfo screenheight $base]/2-300]
    wm geom $base 650x400+${x}+$y
    update idletasks
    wm deiconify $base
    
    return $html
}


proc HelpViewer::HelpSearchWord { word } {
    variable notebook
    
    set HelpViewer::searchstring $word
    $notebook raise search
    SearchInAllHelp
}


proc HelpViewer::FillDir { tree node } {
    variable HelpBaseDir
    variable displayArrangeList
	variable workingFolderArrangeList
	
	set files ""
    if { $node == "root" } {
        set dir $HelpBaseDir
		set files $displayArrangeList
	} elseif { [ string match "*Working with openCONFIGURATOR" [lindex [$tree itemcget $node -data] 1] ] == 1} {
		set dir [lindex [$tree itemcget $node -data] 1]
		set files $workingFolderArrangeList
    } else {
        set dir [lindex [$tree itemcget $node -data] 1]
		foreach i [glob -nocomplain -dir $dir *] {
		    lappend files [file tail $i]
		}
		set files [lsort -dictionary $files]
    }
    
    set idxfolder 0
    
	#hardcoding the list files and folders to be displayed
    #foreach i [glob -nocomplain -dir $dir *] {
    #    lappend files [file tail $i]
    #}
	
    #foreach i [lsort -dictionary $files] { }
	foreach i $files {
        set fullpath [file join $dir $i]
        regsub {^[0-9]+} $i {} name
        regsub -all {\s} $fullpath _ item
        if { [file isdir $fullpath] } {
            if { [string equal -nocase $i "images"] } { continue }
            #$tree insert $idxfolder $node $item -image appbook16 -text $name \
                    -data [list folder $fullpath] -drawcross allways
			$tree insert end $node $item -image appbook16 -text $name \
                    -data [list folder $fullpath] -drawcross allways 
            incr idxfolder
        } elseif { [string match .htm* [file ext $i]] } {
            set name [file root $i]
            $tree insert end $node $item -image filedocument16 -text $name \
                    -data [list file $fullpath] 
        }
    }
}

proc HelpViewer::moddir { idx tree node } {
    variable HelpBaseDir
    
    if { $idx && [$tree itemcget $node -drawcross] == "allways" } {
        FillDir $tree $node
        $tree itemconfigure $node -drawcross auto 
        
        if { [llength [$tree nodes $node]] } {
            $tree itemconfigure $node -image appbookopen16
        } else {
            $tree itemconfigure $node -image appbook16
        }
    } else {
        if { [lindex [$tree itemcget $node -data] 0] == "folder" } {
            switch $idx {
                0 { set img appbook16 }
                1 { set img appbookopen16 }
            }
            $tree itemconfigure $node -image $img 
        }
    }
}

proc HelpViewer::KeyPress { a } {
    variable tree
    variable searchstring
    
    set node [$tree selection get]
    if { [llength $node] != 1 } { return }
    
    append searchstring $a
    after 300 [list set HelpViewer::searchstring ""]
    
    if { [$tree itemcget $node -open] == 1 && [llength [$tree nodes $node]] > 0 } {
        set parent $node
        set after 1
    } else {
        set parent [$tree parent $node]
        set after 0
    }
    
    foreach i [$tree nodes $parent] {
        if { !$after } {
            if { $i == $node } {
                if { [string length $HelpViewer::searchstring] > 1 } {
                    set after 2
                } else {
                    set after 1
                }
            }
        }
        if { $after == 2 && [string match -nocase $HelpViewer::searchstring* \
                    [$tree itemcget $i -text]] } {
            $tree selection clear
            $tree selection set $i
            $tree see $i
            return
        }
        if { $after == 1 } { set after 2 }
    }
    foreach i [$tree nodes [$tree parent $node]] {
        if { $i == $node } { return }
        if { [string match -nocase $HelpViewer::searchstring* [$tree itemcget $i -text]] } {
            $tree selection clear
            $tree selection set $i
            $tree see $i
            return
        }
    }
}

proc HelpViewer::Select { tree num node } {
    variable dblclick
    variable html
    
    if { $node == "" } {
        set node [$tree selection get]
        if { [llength $node] != 1 } { return }
    } elseif { ![$tree exists $node] } {
        return
    }
    set dblclick 1
    
    
    if { $num >= 1 } {
        if { [$tree itemcget $node -open] == 0 } {
            $tree itemconfigure $node -open 1
            set idx 1
        } else {
            $tree itemconfigure $node -open 0
            set idx 0
        }
        moddir $idx $tree $node
        if { $num == 1 && $idx == 0 } {
            return
        }
        $tree selection set $node
        if { [llength [$tree selection get]] == 1 } {
            set data [$tree itemcget [$tree selection get] -data]
            if { $num >= 1 && $num <= 2 } {
                LoadFile $html [lindex $data 1]
            }
        }
        return
    }
}

proc HelpViewer::TryToSelect { name } {
    variable HelpBaseDir
    variable tree
    
    set nameL [file split $name]
    
    set level [llength [file split $HelpBaseDir]]
    set node root
    while 1 {
        set found 0
        foreach i [$tree nodes $node] {
            if { [lindex [$tree itemcget $i -data] 1] == [eval file join [lrange $nameL 0 $level]] } {
                set found 1
                break
            }
        }
        if { !$found } { return }
        if { [lindex [$tree itemcget $i -data] 0] == "folder" } {
            if { [$tree itemcget $i -open] == 0 } {
                $tree itemconfigure $i -open 1
            }
            moddir 1 $tree $i
        }
        
        if { $level == [llength $nameL]-1 } {
            Select $tree 3 $i
            return
        }
        set node $i
        incr level
    }
}

proc HelpViewer::Search {} {
    variable html
    
    if { ![info exists ::HelpViewer::searchstring] } {
        WarnWin "Before using 'Continue search', use 'Search'" [winfo toplevel $html]
        return
    }
    if { $HelpViewer::searchstring != "" } {
        
        set comm [list $html text find $HelpViewer::searchstring]
        if { $::HelpViewer::searchcase == 0 } {
            lappend comm nocase
        }
        
        if { $HelpViewer::SearchType == "-forwards" } {
            if { $HelpViewer::SearchPos != "" } {
                lappend comm after $HelpViewer::SearchPos
            } else {
                lappend comm after 1.0
            }
        } else {
            if { $HelpViewer::SearchPos != "" } {
                lappend comm before $HelpViewer::SearchPos
            } else {
                lappend comm before end
            }
        }
        set idx1 ""
        foreach "idx1 idx2" [eval $comm] break
        
        if { $idx1 == "" } {
            bell
        } else {
            scan $idx2 "%d.%d" line char
            set idx2 $line.[expr $char+1]
            $html selection set $idx1 [$html index $idx2]
            
            set y [lindex [$html coords $idx1] 1]
            if { $y == "" } { set y 0 }
            set height [lindex [$html coords end] 1]
            
            foreach "f1 f2" [$html yview] break
            set ys [expr $y/double($height)-($f2-$f1)/2.0]
            if { $ys < 0 } { set ys 0 }
            $html yview moveto $ys
            $html refresh
            
            set HelpViewer::SearchPos $idx1
            
            
            
        }
    }
}

proc HelpViewer::SearchWindow {} {
    variable html

    set f [DialogWin::Init $html "Search" separator]
    set w [winfo toplevel $f]

    label $f.l1 -text "Text:" -grid 0
    entry $f.e1 -textvariable ::HelpViewer::searchstring -grid "1 px3 py3"
    
    set f25 [frame $f.f25 -bd 1 -relief ridge -grid "0 2 w px3"]
    radiobutton $f25.r1 -text Forward -variable ::HelpViewer::SearchType \
            -value -forwards -grid "0 w"
    radiobutton $f25.r2 -text Backward -variable ::HelpViewer::SearchType \
            -value -backwards -grid "0 w"
    
    set f3 [frame $f.f3 -grid "0 2 w"]
    checkbutton $f3.cb1 -text "Consider case" -variable ::HelpViewer::searchcase \
            -grid 0
    checkbutton $f3.cb2 -text "From beginning" -variable ::HelpViewer::searchFromBegin \
            -grid 1
	
    supergrid::go $f
    
    if { ![info exists ::HelpViewer::searchstring] } {
        set ::HelpViewer::searchstring ""
    }
    
    set ::HelpViewer::searchmode -exact
    set ::HelpViewer::searchcase 0
    set ::HelpViewer::searchFromBegin 0
    set ::HelpViewer::SearchType -forwards
    
    tkTabToWindow $f.e1
    bind $w <Return> "DialogWin::InvokeOK"
    
    set action [DialogWin::CreateWindow]
    switch $action {
        0 {
            DialogWin::DestroyWindow
            return
        }
        1 {
            if { $::HelpViewer::searchstring == "" } {
                DialogWin::DestroyWindow
                return
            }
            set ::HelpViewer::SearchPos ""
            Search
            DialogWin::DestroyWindow
        }
    }
}

proc HelpViewer::CreateIndex {} {
    variable HelpBaseDir
    variable Index
    variable IndexFilesTitles
    variable progressbar
    variable progressbarStop
    variable html
    
    if { [array exists Index] } { return }
    if { [file exists [file join $HelpBaseDir wordindex]] } {
        set fin [open [file join $HelpBaseDir wordindex] r]
        foreach "IndexFilesTitles aa" [read $fin] break
        array set Index $aa
        close $fin
        return
    }
    
    WaitState 1
    
    ProgressDlg $html.prdg -textvariable HelpViewer::progressbarT -variable \
            HelpViewer::progressbar -title "Creating search index" \
            -troughcolor \#e0e8f0 -stop Stop -command "set HelpViewer::progressbarStop 1"
    set progressbar 0
    set progressbarStop 0
    
    catch { unset Index }
    
    set files [::fileutil::findByPattern $HelpBaseDir "*.htm *.html"]
    
    set len [llength [file split $HelpBaseDir]]
    set ipos 0
    set numfiles [llength $files]
    
    set IndexFilesTitles ""
    
    foreach i $files {
        set HelpViewer::progressbar [expr int($ipos*50/$numfiles)]
        set HelpViewer::progressbarT $HelpViewer::progressbar%
        if { $HelpViewer::progressbarStop } {
            destroy .prdg
            return
        }
        
        set fin [open $i r]
        set aa [read $fin]
        
        set file [eval file join [lrange [file split $i] $len end]]
        set title ""
        regexp {(?i)<title>(.*?)</title>} $aa {} title
        if { $title == "" } {
            regexp {(?i)<h([1234])>(.*?)</h\1>} $aa {} {} title
        }
        lappend IndexFilesTitles [list $file $title]
        set IndexPos [expr [llength $IndexFilesTitles]-1]
        
        foreach j [regexp -inline -all -- {-?\w{3,}} $aa] {
            if { [string is integer $j] || [string length $j] > 25 || [regexp {_[0-9]+$} $j] } {
                continue
            }
            lappend Index([string tolower $j]) $IndexPos
        }
        close $fin
        incr ipos
    }
    
    proc IndexesSortCommand { e1 e2 } {
        upvar freqs freqsL
        if { $freqsL($e1) > $freqsL($e2) } { return -1 }
        if { $freqsL($e1) < $freqsL($e2) } { return 1 }
        return 0
    }
    
    set names [array names Index]
    set len [llength $names]
    set ipos 0
    foreach i $names {
        set HelpViewer::progressbar [expr 50+int($ipos*50/$len)]
        set HelpViewer::progressbarT $HelpViewer::progressbar%
        if { $HelpViewer::progressbarStop } {
            destroy .prdg
            return
        }
        foreach j $Index($i) {
            set title [lindex [lindex $IndexFilesTitles $j] 1]
            if { [string match -nocase *$i* $title] } {
                set icr 10
            } else { set icr 1 }
            if { ![info exists freqs($j)] } {
                set freqs($j) $icr
            } else { incr freqs($j) $icr }
        }
        #          if { $i == "variable" } {
        #              puts "-----variable-----"
        #              foreach j $Index($i) {
        #                  puts [lindex $IndexFilesTitles $j]-----$j
        #              }
        #              parray freqs
        #          }
        set Index($i) [lrange [lsort -command HelpViewer::IndexesSortCommand [array names freqs]] \
                0 4]
        
        #          if { $i == "variable" } {
        #              puts "-----variable-----"
        #              foreach j [lsort -command HelpViewer::IndexesSortCommand [array names freqs]] {
        #                  puts [lindex $IndexFilesTitles $j]-----$j
        #              }
        #          }
        unset freqs
        incr ipos
    }
    
    set HelpViewer::progressbar 100
    set HelpViewer::progressbarT $HelpViewer::progressbar%
    destroy $html.prdg
    set fout [open [file join $HelpBaseDir wordindex] w]
    puts -nonewline $fout [list $IndexFilesTitles [array get Index]]
    close $fout
    WaitState 0
}

proc HelpViewer::IsWordGood { word otherwords } {
    variable Index
    variable IndexFilesTitles
    
    if { $otherwords == "" } { return 1 }
    
    if { ![info exists Index($word)] } { return 0 }
    
    foreach i $Index($word) {
        set file [lindex [lindex $IndexFilesTitles $i] 0]
        if { [HasFileTheWord $file $otherwords] } { return 1 }
    }
    return 0
}

proc HelpViewer::HasFileTheWord { file otherwords } {
    variable HelpBaseDir
    variable Index
    variable IndexFilesTitles
    variable FindWordInFileCache
    
    set fullfile [file join $HelpBaseDir $file]
    
    foreach word $otherwords {
        if { [info exists FindWordInFileCache($file,$word)] } {
            if { !$FindWordInFileCache($file,$word) } { return 0 }
            continue
        }
        set fin [open $fullfile r]
        set aa [read $fin]
        close $fin
        if { [string match -nocase *$word* $aa] } {
            set FindWordInFileCache($file,$word) 1
        } else {
            set FindWordInFileCache($file,$word) 0
            return 0
        }
    }
    return 1
}

proc HelpViewer::SearchInAllHelp {} {
    variable HelpBaseDir
    variable Index
    variable searchlistbox1
    
    set word [string tolower $HelpViewer::searchstring]
    CreateIndex
    
    set HelpViewer::SearchFound ""
    set HelpViewer::SearchFound2 ""
    
    if { [string trim $word] == "" } { return }
    
    set words [regexp -all -inline {\S+} $word]
    if { [llength $words] > 1 } {
        set word [lindex $words 0]
        set otherwords [lrange $words 1 end]
    } else { set otherwords "" }
    
    set ipos 0
    set iposgood -1
    foreach i [array names Index *$word*] {
        if { ![IsWordGood $i $otherwords] } { continue }
        
        lappend HelpViewer::SearchFound $i
        if { [string equal $word [lindex $i 0]] } { set iposgood $ipos }
        incr ipos
    }
    if { $iposgood == -1 && [llength [GiveManHelpNames $HelpViewer::searchstring]] > 0 } {
        lappend HelpViewer::SearchFound $HelpViewer::searchstring
        set iposgood $ipos
    }
    
    if { $iposgood >= 0 } {
        $searchlistbox1 selection clear 0 end
        $searchlistbox1 selection set $iposgood
        $searchlistbox1 see $iposgood
        SearchInAllHelpL1
    }
}

proc HelpViewer::SearchInAllHelpL1 {} {
    variable Index
    variable IndexFilesTitles
    variable SearchFound2
    variable SearchFound2data
    variable searchlistbox1
    variable searchlistbox2
    
    set SearchFound2 ""
    set SearchFound2data ""
    
    set sels [$searchlistbox1 curselection]
    if { $sels == "" } {
        bell
        return
    }
    
    set words [regexp -all -inline {\S+} $HelpViewer::searchstring]
    if { [llength $words] > 1 } {
        set otherwords [lrange $words 1 end]
    } else { set otherwords "" }
    
    set ipos 0
    set iposgood -1
    set iposgoodW -1
    foreach i $sels {
        set word [$searchlistbox1 get $i]
        if { [info exists Index($word)] } {
            foreach i $Index($word) {
                foreach "file title" [lindex $IndexFilesTitles $i] break
                
                if { ![HasFileTheWord $file $otherwords] } { continue }
                
                if { [lsearch $HelpViewer::SearchFound2 $title] != -1 } { continue }
                
                lappend SearchFound2 $title
                lappend SearchFound2data $i
                if { [string match -nocase *$word* $title] } {
                    set W 1
                    foreach i $otherwords {
                        if { [string match -nocase *$i* $title] } { incr W }
                    }
                    if { [string match -nocase *$HelpViewer::searchstring* $title] } { incr W }
                    if { [string equal -nocase $HelpViewer::searchstring $title] } { incr W }
                    
                    if { $W > $iposgoodW } {
                        set iposgood $ipos
                        set iposgoodW $W
                    }
                }
                incr ipos
            }
        }
        foreach i [GiveManHelpNames $word] {
            lappend SearchFound2 $i
            if { $iposgood == -1 } {
                set iposgood $ipos
            } else { set iposgood -2 }
            incr ipos
        }
    }
    if { $iposgood < 0 && $ipos > 0 } { set iposgood 0 }
    if { $iposgood >= 0 } {
        focus $searchlistbox2
        $searchlistbox2 selection clear 0 end
        $searchlistbox2 selection set $iposgood
        $searchlistbox2 see $iposgood
        SearchInAllHelpL2
    }
}

proc HelpViewer::SearchInAllHelpL2 {} {
    variable HelpBaseDir
    variable SearchFound2data
    variable IndexFilesTitles
    variable SearchFound2
    variable SearchFound2data
    variable html
    variable searchlistbox2
    
    set sels [$searchlistbox2 curselection]
    if { [llength $sels] != 1 } {
        bell
        return
    }
    if { [regexp {(.*)\(man (.*)\)} [lindex $SearchFound2 $sels]] } {
        SearchManHelpFor $html [lindex $SearchFound2 $sels]
    } else {
        set i [lindex $SearchFound2data $sels]
        set file [file join $HelpBaseDir [lindex [lindex $IndexFilesTitles $i] 0]]
        
        LoadFile $html $file 1
    }
}

proc HelpViewer::WaitState { what } {
    variable tree
    variable html
    
    switch $what {
        1 {
            $tree configure -cursor watch
            $html configure -cursor watch
        }
        0 {
            $tree configure -cursor ""
            $html configure -cursor ""
        }
    }
    update
}

#if { [info script] == $argv0 } {
#    wm withdraw .
#    package require Tkhtml
#    package require Img
#    if { $::tcl_platform(platform) != "windows"} {
#        set file {/c/TclTk/RamDebugger/help}
#    } else {
#        set file {/Documents and Settings/ramsan/Mis documentos/myTclTk/RamDebugger/help}
#        
#        bind all <MouseWheel> {
#            set w %W
#            while { $w != [winfo toplevel $w] } {
#                catch {
#                    set ycomm [$w cget -yscrollcommand]
#                    if { $ycomm != "" } {
#                        $w yview scroll [expr int(-1*%D/36)] units
#                        break
#                    }
#                }
#                set w [winfo parent $w]
#            }
#        }
#        
#        
#    }F
#    HelpViewer::HelpWindow $file
#} else  {
#    set HelpViewer::HelpBaseDir [file join [info script] help]
#}

HelpViewer::HelpWindow [file join $masterRootDir help "Project Wizard.html"] .help
