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
global conWindow
global warWindow
global errWindow

###############################################################################################
#proc onKeyLeft
#Input       : window
#Output      : -
#Description : Procedure for binding, moves cursor left
###############################################################################################
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

###############################################################################################
#proc onKeyRight
#Input       : window
#Output      : -
#Description : Procedure for binding, moves cursor right
###############################################################################################
proc onKeyRight {win} {
	$win mark set insert "insert +1c"
}

###############################################################################################
#proc onKeyBackSpace
#Input       : window
#Output      : -
#Description : Procedure for binding, deletes a character
###############################################################################################
proc onKeyBackSpace {win} {
	
	if {[$win compare insert <= prompt]} {
		return {}
	}  else  {
		$win delete insert-1c
	}
}

###############################################################################################
#proc consoleInit
#Input       : window, width, height
#Output      : text widget
#Description : Create the console window and bind required procedures
###############################################################################################
proc consoleInit {win {width 60} {height 5}} {
	global Console
	global prompt
	global window
	global EditorData
	
	set window $win
	set prompt $
	
	if {$window == "."} {
		set window ""
	}
	set Console [interp create]
		
	$Console alias setValues SetValues
   
	text $window.t -width $width -height $height -bg white 
	catch {$window.t configure -font $EditorData(options,fonts,editorFont)}
	
	$window.t tag configure output -foreground blue
	$window.t tag configure prompt -foreground grey40
	$window.t tag configure error -foreground red
	$window.t insert end "$prompt " prompt
	$window.t mark set prompt insert
	$window.t mark gravity prompt left
	bind $window.t <Key-Left> {onKeyLeft %W ; break}
	bind $window.t <Key-Right> {onKeyRight %W ; break}
	bind $window.t <Key-BackSpace> {onKeyBackSpace %W;break}
	pack $window.t -fill both -expand yes
	return $window.t
}
	
###############################################################################################
#proc conPuts
#Input       : text to be inserted, window, text widget, flash, see
#Output      : -
#Description : Displays the text in text widget for console window
###############################################################################################
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
	set prompt $
	$win insert end "$prompt " prompt
	$win mark gravity prompt left
	if $see {$win see insert}
	update
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
	global prompt
	global window
	global EditorData
	
	set window $win
	set prompt $
	
	if {$window == "."} {
		set window ""
	}
	set Console [interp create]
		
	$Console alias setValues SetValues
	text $window.t -width $width -height $height -bg white
	catch {$window.t configure -font $EditorData(options,fonts,editorFont)}
	
	$window.t tag configure output -foreground blue 
	$window.t tag configure prompt -foreground grey40
	$window.t tag configure error -foreground red
	$window.t insert end "$prompt " prompt
	$window.t mark set prompt insert
	$window.t mark gravity prompt left
	bind $window.t <Key-Left> {onKeyLeft %W ; break}
	bind $window.t <Key-Right> {onKeyRight %W ; break}
	bind $window.t <Key-BackSpace> {onKeyBackSpace %W;break}
	pack $window.t -fill both -expand yes
	return $window.t
}

###############################################################################################
#proc errorPuts
#Input       : text to be inserted, window, text widget, flash, see
#Output      : -
#Description : Displays the text in text widget for error window
###############################################################################################
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
	set prompt $
	$win insert end "$prompt " prompt
	$win mark gravity prompt left
	if $see {$win see insert}
	update
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
	global prompt
	global window
	global EditorData
	
	set window $win
	set prompt $
	
	if {$window == "."} {
		set window ""
	}
	set Console [interp create]
		
	$Console alias setValues SetValues
	$Console alias puts warnPuts
	text $window.t -width $width -height $height -bg white
	catch {$window.t configure -font $EditorData(options,fonts,editorFont)}
	
	$window.t tag configure output -foreground blue
	$window.t tag configure prompt -foreground grey40
	$window.t tag configure error -foreground red
	$window.t insert end "$prompt " prompt
	$window.t mark set prompt insert
	$window.t mark gravity prompt left
	bind $window.t <Key-Left> {onKeyLeft %W ; break}
	bind $window.t <Key-Right> {onKeyRight %W ; break}
	bind $window.t <Key-BackSpace> {onKeyBackSpace %W;break}
	pack $window.t -fill both -expand yes
	return $window.t
}

###############################################################################################
#proc warnPuts
#Input       : text to be inserted, window, text widget, flash, see
#Output      : -
#Description : Displays the text in text widget for warning window
###############################################################################################
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
	set prompt $
	$win insert end "$prompt " prompt
	$win mark gravity prompt left
	if $see {$win see insert}
	update
	return
}

# this won,t be executed if console.tcl is sourced by another app
if {[string compare [info script] $argv0] == 0} {
	consoleInit .
}
