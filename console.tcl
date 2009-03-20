###############################################################################################
#
#
# NAME:	 console.tcl
#
# PURPOSE:  purpose description
#
# AUTHOR:   Kalycito Infotech Pvt Ltd
#
# COPYRIGHT NOTICE:
#
#********************************************************************************
# (c) Kalycito Infotech Private Limited
#
#  Project:	  openCONFIGURATOR 
#
#  Description:  Contains the procedures for Console window
#
#
#  License:
#
#	Redistribution and use in source and binary forms, with or without
#	modification, are permitted provided that the following conditions
#	are met:
#
#	1. Redistributions of source code must retain the above copyright
#	   notice, this list of conditions and the following disclaimer.
#
#	2. Redistributions in binary form must reproduce the above copyright
#	   notice, this list of conditions and the following disclaimer in the
#	   documentation and/or other materials provided with the distribution.
#
#	3. Neither the name of Kalycito Infotech Private Limited nor the names of 
#	   its contributors may be used to endorse or promote products derived
#	   from this software without prior written permission. For written
#	   permission, please contact info@kalycito.com.
#
#	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#	COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#	POSSIBILITY OF SUCH DAMAGE.
#
#	Severability Clause:
#
#		If a provision of this License is or becomes illegal, invalid or
#		unenforceable in any jurisdiction, that shall not affect:
#		1. the validity or enforceability in that jurisdiction of any other
#		   provision of this License; or
#		2. the validity or enforceability in other jurisdictions of that or
#		   any other provision of this License.
#
#********************************************************************************
#
#  REVISION HISTORY:
# $Log:	  $
###############################################################################################


#Console
global Console
global infoWindow
global warWindow
global errWindow

###############################################################################################
#proc LeftKeyPressEvent
#Input       : window
#Output      : -
#Description : Procedure for binding, moves cursor left
###############################################################################################
#proc LeftKeyPressEvent {window} {
#	if {[$window compare insert >= prompt]} {
#		set currentPos [lindex [split [$window index insert] "."] 1]
#		set toPos [lindex [split [$window index prompt] "."] 1]
#		if {$currentPos <= $toPos} {
#			return {}
#		} else  {
#			$window mark set insert insert-1c
#		}
#	} else  {
#		$window mark set insert "insert -1c"
#	}
#}

###############################################################################################
#proc RightKeyPressEvent
#Input       : window
#Output      : -
#Description : Procedure for binding, moves cursor right
###############################################################################################
#proc RightKeyPressEvent {window} {
#	$window mark set insert "insert +1c"
#}

###############################################################################################
#proc BackSpaceKeyPressEvent
#Input       : window
#Output      : -
#Description : Procedure for binding, deletes a character
###############################################################################################
#proc BackSpaceKeyPressEvent {window} {
	
#	if {[$window compare insert <= prompt]} {
#		return {}
#	}  else  {
#		$window delete insert-1c
#	}
#}

###############################################################################################
#proc infoInit
#Input       : window, width, height
#Output      : text widget
#Description : Create the console window and bind required procedures
###############################################################################################
proc infoInit {win {width 60} {height 5}} {
	global Console
	global promptChar
	global window
	global ConfigData
	
	set window $win
	set promptChar $
	
	if {$window == "."} {
		set window ""
	}
	set Console [interp create]
		
	$Console alias setValues SetValues
   
	text $window.t -width $width -height $height -bg white 
	catch {$window.t configure -font $ConfigData(options,fonts,editorFont)}
	
	$window.t tag configure output -foreground blue
	$window.t tag configure promptChar -foreground grey40
	$window.t tag configure error -foreground red
	$window.t insert end "$promptChar " promptChar
	$window.t mark set promptChar insert
	$window.t mark gravity promptChar left
	$window.t configure -state disabled
	#bind $window.t <Key-Left> {LeftKeyPressEvent %W ; break}
	#bind $window.t <Key-Right> {RightKeyPressEvent %W ; break}
	#bind $window.t <Key-BackSpace> {BackSpaceKeyPressEvent %W;break}
	pack $window.t -fill both -expand yes
	return $window.t
}
	
###############################################################################################
#proc DisplayInfo
#Input       : text to be inserted, window, text widget, flash, see
#Output      : -
#Description : Displays the text in text widget for console window
###############################################################################################
proc DisplayInfo {var {tag output} {win {}} {flash 0} {see 1}} {
	global promptChar
	global infoWindow
	
	if {$win == {}} {
		set win [lindex $infoWindow 0]
	}
	$win configure -state normal
	$win mark gravity promptChar right
	$win insert end $var $tag
	if {[string index $var [expr [string length $var]-1]] != "\n"} {
		$win insert end "\n"
	}
	set promptChar $
	$win insert end "$promptChar " promptChar
	$win mark gravity promptChar left
	if $see {$win see insert}
	update
	$win configure -state disabled
	[lindex $infoWindow 1] raise [lindex $infoWindow 2]
	return
}


###############################################################################################
#proc errorInit
#Input       : window, width, height
#Output      : text widget
#Description : Create the error window and bind required procedures
###############################################################################################
proc errorInit {win {width 60} {height 5}} {
	global Console
	global promptChar
	global window
	global ConfigData
	
	set window $win
	set promptChar $
	
	if {$window == "."} {
		set window ""
	}
	set Console [interp create]
		
	$Console alias setValues SetValues
	text $window.t -width $width -height $height -bg white
	catch {$window.t configure -font $ConfigData(options,fonts,editorFont)}
	
	$window.t tag configure output -foreground blue 
	$window.t tag configure promptChar -foreground grey40
	$window.t tag configure error -foreground red
	$window.t insert end "$promptChar " promptChar
	$window.t mark set promptChar insert
	$window.t mark gravity promptChar left
	$window.t configure -state disabled
	#bind $window.t <Key-Left> {LeftKeyPressEvent %W ; break}
	#bind $window.t <Key-Right> {RightKeyPressEvent %W ; break}
	#bind $window.t <Key-BackSpace> {BackSpaceKeyPressEvent %W;break}
	pack $window.t -fill both -expand yes
	return $window.t
}

###############################################################################################
#proc DisplayErrMsg
#Input       : text to be inserted, window, text widget, flash, see
#Output      : -
#Description : Displays the text in text widget for error window
###############################################################################################
proc DisplayErrMsg {var {tag output} {win {}} {flash 0} {see 1}} {
	global promptChar
	global errWindow
	
	if {$win == {}} {
		set win [lindex $errWindow 0]
	}
	$win configure -state normal
	$win mark gravity promptChar right
	$win insert end $var $tag
	if {[string index $var [expr [string length $var]-1]] != "\n"} {
		$win insert end "\n"
	}
	set promptChar $
	$win insert end "$promptChar " promptChar
	$win mark gravity promptChar left
	if $see {$win see insert}
	update
	$win configure -state disabled
	[lindex $errWindow 1] raise [lindex $errWindow 2]
	return
}

###############################################################################################
#proc warnInit
#Input       : window, width, height
#Output      : text widget
#Description : Create the warning window and bind required procedures
###############################################################################################
proc warnInit {win {width 60} {height 5}} {
	global Console
	global promptChar
	global window
	global ConfigData
	
	set window $win
	set promptChar $
	
	if {$window == "."} {
		set window ""
	}
	set Console [interp create]
		
	$Console alias setValues SetValues
	$Console alias puts DisplayWarning
	text $window.t -width $width -height $height -bg white
	catch {$window.t configure -font $ConfigData(options,fonts,editorFont)}
	
	$window.t tag configure output -foreground blue
	$window.t tag configure promptChar -foreground grey40
	$window.t tag configure error -foreground red
	$window.t insert end "$promptChar " promptChar
	$window.t mark set promptChar insert
	$window.t mark gravity promptChar left
	$window.t configure -state disabled
	#bind $window.t <Key-Left> {LeftKeyPressEvent %W ; break}
	#bind $window.t <Key-Right> {RightKeyPressEvent %W ; break}
	#bind $window.t <Key-BackSpace> {BackSpaceKeyPressEvent %W;break}
	pack $window.t -fill both -expand yes
	return $window.t
}

###############################################################################################
#proc DisplayWarning
#Input       : text to be inserted, window, text widget, flash, see
#Output      : -
#Description : Displays the text in text widget for warning window
###############################################################################################
proc DisplayWarning {var {tag output} {win {}} {flash 0} {see 1}} {
	global promptChar
	global warWindow
	
	if {$win == {}} {
		set win [lindex $warWindow 0]
	}
	$win configure -state normal
	$win mark gravity promptChar right
	$win insert end $var $tag
	if {[string index $var [expr [string length $var]-1]] != "\n"} {
		$win insert end "\n"
	}
	set promptChar $
	$win insert end "$promptChar " promptChar
	$win mark gravity promptChar left
	if $see {$win see insert}
	update
	$win configure -state disabled
	[lindex $warWindow 1] raise [lindex $warWindow 2]
	return
}

proc ClearMsgs {} {
	global infoWindow
	global warWindow
	global errWindow
	
	foreach window [list [lindex $infoWindow 0] [lindex $warWindow 0]  [lindex $errWindow 0] ] {
		$window configure -state normal
		$window delete 1.0 end
		$window configure -state disabled
	}
}

# this won't be executed if console.tcl is sourced by another app
if {[string compare [info script] $argv0] == 0} {
	infoInit .
}
