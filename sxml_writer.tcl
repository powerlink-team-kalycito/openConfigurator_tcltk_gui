#########################################################################
#									#
# Script:	sxml_writer.tcl (namespace sxml::writer)		#
#									#
# Provides:	sxml::writer namespace (init finalize get_error element	#
#					attribute data pop_element)	#
#									#
#		These commands provide a simple interface for 		#
#		generating a very simple XML file, which can be parsed	#
#		by the sxml module, or other XML parser.		#	#									#
# Version:	@(#)0.1 Initially released version. (SE)>		#
# Version:	@(#)0.2 Several improvements - see log. (SE)>		#
#									#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#									#
# Version:	0.2							#
# Change:	Several small improvements:				#
#		1. Support to overwrite existing files.			#
#		2. Support for ">" character translation.		#
#		3. Added support for "original" or "compact" file	#
#		   writing, which alters the layout of the written	#
#		   file.						#
#									#
# Version:								#
# Date:									#
# Author:								#
# Change:								#
#									#
#########################################################################

namespace eval sxml::writer {

namespace export init finalize get_error element attribute data
namespace export pop_element set_attr

variable xml_stack
variable xml_fd
variable xml_celement
variable xml_cattr
variable xml_wroteheader
variable xml_fdcount 0
variable xml_err
variable xml_swritten
variable xml_int_attrs

# Write out the header text if necessary

proc write_header_if_needed {fd} {
variable xml_fd
variable xml_wroteheader
variable xml_err

	set xfd $xml_fd($fd)
	if { $xml_wroteheader($fd) == 0 } {
		set x [catch {puts $xfd "<?xml version=\"1.0\"?>\n"}]
		if { $x } {
			set xml_err($fd) "Unable to write to file."
			return -1
		}
		set xml_wroteheader($fd) 1
	}
	return 0
}

#########################################################################
# Write out the specified data at the specifyied level of indentation.	#
#########################################################################

proc write_data {fd data level} {
variable xml_err

	set indent ""
	for {set x 0} {$x < $level} {incr x} {
		append indent "  "
	}

	set value [xml_stringify $data]
	set e [catch {puts $fd "$indent$data"}]
	if { $e } {
		set xml_err($fd) "Unable to write to file."
		return -1
	}
	return 0
}

# Take the details given as arguments and write them out to
# the given file descriptor

proc write_start_tag {fd tag cattrs level} {
variable xml_err
variable xml_fd
variable xml_int_attrs

	set xfd $xml_fd($fd)
	set indent ""
	for {set x 0} {$x < $level} {incr x} {
		append indent "  "
	}

	set x [llength $cattrs]
	set y 0

	#################################################################
	# If we have no attributes simply write out the start tag ...	#
	# but indent 2 x level 						#
	#################################################################

	if { $x == 0 } {
		if { $xml_int_attrs($fd,compact) == 0 } {
			set e [catch {puts $xfd "$indent<$tag>"}]
		} else {
			set e [catch {puts -nonewline $xfd "$indent<$tag>"}]
		}
		if { $e } {
			set xml_err($fd) "Unable to write to file."
			return -1
		}
		return 0
	}

	#################################################################
	# Other write out the tag, but don't close the quote		#
	#################################################################

	if { $xml_int_attrs($fd,compact) == 0 } {
		set e [catch {puts $xfd "$indent<$tag"}]
	} else {
		set e [catch {puts -nonewline $xfd "$indent<$tag"}]
	}
	if { $e } {
		set xml_err($fd) "Unable to write to file."
		return -1
	}
	set indent2 "$indent  "
	while { $y < $x } {
		set attr [lindex $cattrs $y]
		incr y
		set value [lindex $cattrs $y]
		incr y

		#########################################################
		# Convert the value to a valid XML string...		#
		#########################################################

		set value [xml_stringify $value]
		if { $xml_int_attrs($fd,compact) == 0 } {
			set e [catch {puts $xfd "$indent2$attr=\"$value\""}]
		} else {
			set e [catch {puts -nonewline $xfd " $attr=\"$value\""}]
		}
		if { $e } {
			set xml_err($fd) "Unable to write to file."
			return -1
		}
	}
	#################################################################
	# Finally write out the end of tag for this element...		#
	#################################################################
	if { $xml_int_attrs($fd,compact) == 0 } {
		set e [catch {puts $xfd "$indent>"}]
	} else {
		set e [catch {puts -nonewline $xfd ">"}]
	}
	if { $e } {
		set xml_err($fd) "Unable to write to file."
		return -1
	}
	return 0
}

# Take a normal string and convert to valid XML chars...

proc xml_stringify {str} {

	# Very basic at the moment!!!!!!!!!

	set rstr ""
	set x 0
	set y [string length $str]
	while { $x < $y } {
		set ch [string index $str $x]
		case $ch {
			{&}	{set ch "&amp;"}
			{<}	{set ch "&lt;"}
			{>}	{set ch "&gt;"}
			{"}	{set ch "&quot;"}
			{'}	{set ch "&apos;"}
		}
		# "
		append rstr $ch
		incr x
	}
	return $rstr
}

# Start the writing of a file - must supply file name to write...

proc init {fname {overwrite 0} } {
variable xml_stack
variable xml_celement
variable xml_cattr
variable xml_err
variable xml_fdcount
variable xml_fd
variable xml_wroteheader
variable xml_int_attrs

	if { [file exists $fname] && $overwrite == 0} {
		set xml_err(-1) "File \"$fname\" already exists."
		return -1
	}

	if { [catch {set fd [open $fname w]}] } {
		set xml_err(-1) "Unable to open \"$fname\" for writing."
		return -1
	}
	set xml_fd($xml_fdcount) $fd
	set xml_wroteheader($xml_fdcount) 0
	set xml_stack($xml_fdcount) {}
	set xml_celement($xml_fdcount) {}
	set xml_cattr($xml_fdcount) {}
	set xml_int_attrs($xml_fdcount,compact) 0
	set xml_int_attrs($xml_fdcount,needindent) 0
	set y $xml_fdcount
	incr xml_fdcount
	return $y
}

# The procedure allowing attributes to be set for a file...

proc set_attr {fd attr value} {
variable xml_fd
variable xml_int_attrs

	# Double check the fd is valid first

	if { ! [info exists xml_fd($fd)] } {
		set xml_err($fd) "Invalid descriptor specified."
		return -1
	}
	# If the variable name specified does not exist then we assume 
	# that the attribute name is invalid.

	if { ! [info exists xml_int_attrs($fd,$attr)] } {
		set xml_err($fd) "Invalid attribute specified."
		return -1
	}
	set xml_int_attrs($fd,$attr) $value
	return 0
}


# The finalize function closes of an existing file...

proc finalize {fd {alllevels 1} } {
variable xml_stack
variable xml_celement
variable xml_cattr
variable xml_err
variable xml_fdcount
variable xml_fd
variable xml_wroteheader
variable xml_swritten
variable xml_int_attrs

	# Double check the fd is valid first

	if { ! [info exists xml_fd($fd)] } {
		set xml_err($fd) "Invalid descriptor specified."
		return -1
	}
	
	# Ok the file is still open, so see if we've anything
	# to write - this will refuse to write an empty file...

	if { [llength $xml_stack($fd)] == 0 } {
		set xml_err($fd) "No data specified - will not write empty file!"
		return -2
	}

	# Ok, so we have some data - but do we still need to write out
	# the header line...
	
	if { [write_header_if_needed $fd] != 0 } {
		return -1
	}

	# Ok, the header has been written, so if we've any data
	# left to write we need to do it now...

	# For each element left on the stack we do some processing...

	set max_el [expr [llength $xml_stack($fd)] - 1]
	set max_el2 $max_el
	set i "  "

	#################################################################
	# Create the indent string first of all for showing data	#
	#################################################################

	for {set xx 0} {$xx < $max_el} {incr xx} {
		append i "  "
	}

	while { $max_el >= 0 } {
		set c_element [lindex $xml_stack($fd) $max_el]

		#########################################################
		# Write out the start tag - including any stored 	#
		# attributes if at deepest level.			#
		#########################################################
		
		if { ! [info exists xml_cattr($fd)] } {
			set xml_cattr($fd) {}
		}

		if { $xml_swritten($fd,$max_el) == 0 } {
			if { [write_start_tag $fd $c_element $xml_cattr($fd) $max_el] != 0 } {
				return -1
			}
			set xml_swritten($fd,$max_el) 1
			if { $xml_int_attrs($fd,compact) == 1 && $max_el != $max_el2 } {
				set e [catch {puts $xml_fd($fd) ""}]
				if { $e } {
					set xml_err($fd) "Unable to write to file."
					return -1
				}
			}
		}

		#########################################################
		# If at deepest level clear any stored attributes	#
		#########################################################

		if { $max_el == $max_el2 } {
			set xml_cattr($fd) {}
		}

		#########################################################
		# Write out any data stored at this level now...	#
		#########################################################

		set c_data [lindex $xml_celement($fd) $max_el]
		set c_data [xml_stringify $c_data]
		if { $xml_int_attrs($fd,compact) == 0 } {
			set e [catch {puts $xml_fd($fd) "$i$c_data"}]
		} else {
			set e [catch {puts -nonewline $xml_fd($fd) "$c_data"}]
		}
		if { $e } {
			set xml_err($fd) "Unable to write to file."
			return -1
		}
		#########################################################
		# Now write out the end tag for this level.		#
		#########################################################
		set i [string range $i 0 [expr ($max_el) * 2 - 1]]
		if { $xml_int_attrs($fd,compact) == 0 || $xml_int_attrs($fd,needindent) == 1 } {
			set e [catch {puts $xml_fd($fd) "$i</$c_element>"}]
		} else {
			set e [catch {puts $xml_fd($fd) "</$c_element>"}]
			set xml_int_attrs($fd,needindent) 1
		}
		if { $e } {
			set xml_err($fd) "Unable to write to file."
			return -1
		}

		#########################################################
		# Check if we just want to close the current level, and	#
		# if so, exit this level if necessary.			#
		#########################################################

		if { $alllevels == 0 } {
			set xml_stack($fd) [lrange $xml_stack($fd) 0 [expr $max_el - 1]]
			break
		}
		incr max_el -1
	}
	if { $alllevels == 0 } {
		if { [llength $xml_stack($fd)] == 0 } {
			catch {close $fd}
			unset xml_fd($fd)
			return 0
		}
		return 0
	}
	catch {close $fd}
	unset xml_fd($fd)
	return 0
}

#########################################################################
# This procedure is called when you wish to add a new element. It will	#
# add the element to stack, but will not actually write anything to 	#
# the file.								#
#########################################################################

proc element {fd name} {
variable xml_stack
variable xml_cattr
variable xml_celement
variable xml_fd
variable xml_err
variable xml_swritten
variable xml_int_attrs

	# Double check the fd is valid first

	if { ! [info exists xml_fd($fd)] } {
		set xml_err($fd) "Invalid descriptor specified."
		return -1
	}
	
	# If we've not got an empty stack, then now is the
	# time to write out the details...

	if { [llength $xml_stack($fd)] > 0 } {
		set i [llength $xml_stack($fd)]
		incr i -1
		if { ! [info exists xml_swritten($fd,$i)] } {
			set xml_swritten($fd,$i) 0
		}
		if { $xml_swritten($fd,$i) == 0 } {
			set tag [lindex $xml_stack($fd) $i]
			if { [write_header_if_needed $fd] != 0 } {
				return -1
			}
			set e [write_start_tag $fd $tag $xml_cattr($fd) $i]
			if { $e != 0 } {
				return -1
			}
			set xml_swritten($fd,$i) 1
			if { $xml_int_attrs($fd,compact) == 1 } {
				set e [catch {puts $xml_fd($fd) ""}]
				if { $e != 0 } {
					set xml_err($fd) "Unable to write to file."
					return -1
				}
			}
		}
		write_data $fd "[lindex $xml_celement($fd) $i]" $i
		set xml_int_attrs($fd,needindent) 0
	}
	# Add the element name to stack and clear out the
	# attribute details...

	lappend xml_stack($fd) $name
	set i [llength $xml_stack($fd)]

	incr i -1
	if { ! [info exists xml_celement($fd)] } {
		set xml_celement($fd) {}
	} else {
		set xml_celement($fd) "[lrange $xml_celement($fd) 0 [expr $i - 1]] {} [lrange $xml_celement($fd) [expr $i + 1] end]"
	}

	set xml_swritten($fd,$i) 0
	set xml_cattr($fd) {}
	return 0
}

proc attribute {fd name value} {
variable xml_stack
variable xml_cattr
variable xml_fd
variable xml_err

	# Double check the fd is valid first

	if { ! [info exists xml_fd($fd)] } {
		set xml_err($fd) "Invalid descriptor specified."
		return -1
	}

	# Make sure the stack size is greater than 0

	if { [llength $xml_stack($fd)] == 0 } {
		set xml_err($fd) "Attributes can only specifed after an element."
	}

	# Add this element details...

	lappend xml_cattr($fd) $name $value
	return 0
}

proc data {fd data} {
variable xml_stack
variable xml_celement
variable xml_fd
variable xml_err

	# Double check the fd is valid first

	if { ! [info exists xml_fd($fd)] } {
		set xml_err($fd) "Invalid descriptor specified."
		return -1
	}

	# Make sure the stack size is greater than 0

	if { [llength $xml_stack($fd)] == 0 } {
		set xml_err($fd) "Attributes can only specifed after an element."
	}

	# Now append this data for this item..
	set i [llength $xml_stack($fd)]
	incr i -1
	set x [lindex $xml_celement($fd) $i]
	append x $data
	set xml_celement($fd) "[lrange $xml_celement($fd) 0 [expr $i - 1]] {$x} [lrange $xml_celement($fd) [expr $i + 1] end]"
	return 0
}

# This takes the last element of the stack and writes out the
# details to the file. Similar to the finalise operation really.

proc pop_element {fd} {

	return [finalize $fd 0]
}

proc get_error {fd} {
variable xml_err

	if { [info exists xml_err($fd)] } {
		return $xml_err($fd)
	}
	return ""
}

}

