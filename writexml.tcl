#########################################################################
#									
# Script:	writexml.tcl						
#									
# Author:	Kalycito Infotech Pvt Ltd		
#									
# Description:	Write the xml file with the Updated Datas.
#
# Version:	1.2
#
#########################################################################
##set RootDir [pwd]
# Includes
source $RootDir/sxml_writer.tcl
source $RootDir/header.tcl 
source $RootDir/record.tcl

#########################################################################							
# Proc Name:	write_ele 						
# Inputs:	-
# Outputs:	-	
# Description:	write the ele_name to the XML file
#########################################################################

proc write_ele { } {
	global myfd
	global ele_name
	## write the Element Name
	set x [sxml::writer::element $myfd $ele_name]
	if { $x < 0 } {
		puts "error1"
	        puts stderr [sxml::writer::get_error $myfd]
	        exit 2
	}
	if { $x < 0 } {	
		puts "error2"
	        puts stderr [sxml::writer::get_error $myfd]
	        exit 3
	}
	return 0
}
#########################################################################							
# Proc Name:	write_name_data						
# Inputs:	-
# Outputs:	-	
# Description:	write the ele_name,ele_data to the XML file
#########################################################################
proc write_name_data { } {
	global myfd
	global ele_name
	global ele_data
	## write the Element Name and Data
	set x [sxml::writer::element $myfd $ele_name]
	if { $x < 0 } {
		puts "error3"
	        puts stderr [sxml::writer::get_error $myfd]
	        exit 2
	}
	set x [sxml::writer::data $myfd $ele_data ]
	set x [sxml::writer::pop_element $myfd]
	puts "Data is $ele_data"
	if { $x < 0 } {
		puts "error4"
	        puts stderr [sxml::writer::get_error $myfd]
	        exit 3
	}
	return 0
}
#Main to write a file
###########################################################################							
# Proc Name:	initwritexml 						
# Inputs:	-writefile (Filename for writting)
# Outputs:	-	
# Description:	write the ele_name,ele_attributes,ele_data to the XML file
###########################################################################

proc initwritexml { writefile } {
	global tg_count
	global pro_count
	global totaltc
	set TotalTestGroup $tg_count
	set TotalProfile $pro_count
	variable ele_name
	variable ele_data 
	variable myfd
	global PjtDir
	## Get the File name
	set file $writefile
	variable root_ttname "Project"
	## File opened for Writting
	## Root as "Project"
	set x [sxml::writer::init $file 1]
	puts "Filetowrit->$file"
	if { $x < 0 } {
		puts "error5"
		puts stderr [sxml::writer::get_error $x]
        	exit 1
	}
	set myfd $x
	set myfd1 $x
	sxml::writer::set_attr $myfd compact 1
	set x [sxml::writer::element $myfd $root_ttname]
	if { $x < 0 } {
		puts "error6"
	       	puts stderr [sxml::writer::get_error $myfd]
       	 	exit 2
	}
	## Write Project Details 
	sxml::writer::attribute $myfd "Name" [instProject cget -memProjectName]
	sxml::writer::attribute $myfd "Timeout" [instProject cget -memTimeout]
	sxml::writer::attribute $myfd "ExecProfile" [instProject cget -memExecProfile]
	set err [sxml::writer::attribute $myfd "Mode" [instProject cget -memMode]]
	if { $err < 0 } {
		puts "error7"
	     puts stderr "[sxml::writer::get_error $myfd]"
	     exit 10
	}
	## Write Profile Details
	for {set ProfileCount 1} {$ProfileCount <= $TotalProfile} {incr ProfileCount} {
		set ele_name "Profile"
		write_ele
		set err [sxml::writer::attribute $myfd "Name" [arrProfile($ProfileCount) cget -memProfileName]]
		if { $err < 0 } {
			puts "error8"
			puts stderr "[sxml::writer::get_error $myfd]"
		 	exit 10
		}	
		set x [sxml::writer::pop_element $myfd]		
	}
	set ele_name "Usrinclpath"
	set ele_data [instProject cget -memUserInclude_path]
	write_name_data
	set ele_name "Toolboxpath"
	set ele_data [instProject cget -memTollbox_path]
	write_name_data
	## Write TestGroup Details 
	for {set GroupCount 1 } {$GroupCount <= $TotalTestGroup} {incr GroupCount } {
		set ele_name "TestGroup"
		write_ele
		sxml::writer::attribute $myfd "Name" [arrTestGroup($GroupCount) cget -memGroupName]
		sxml::writer::attribute $myfd "ExecMode" [arrTestGroup($GroupCount) cget -memGroupExecMode]
		sxml::writer::attribute $myfd "ExecCount" [arrTestGroup($GroupCount) cget -memGroupExecCount]
		set err [sxml::writer::attribute $myfd "Checked" [arrTestGroup($GroupCount) cget -memChecked]]
		if { $err < 0 } {
			puts "error9"
		     puts stderr "[sxml::writer::get_error $myfd]"
		     exit 10
		}
		set ele_name "Helpmsg"
		set ele_data [arrTestGroup($GroupCount) cget -memHelpMsg]
		write_name_data
		# Writting TestCases
		set currenttotalcase $totaltc($GroupCount) 
		for {set CaseCount 1 } {$CaseCount <= $currenttotalcase} {incr CaseCount } {
			set ele_name "TestCase"
			write_ele
			sxml::writer::attribute $myfd "Path" [arrTestCase($GroupCount)($CaseCount) cget -memCasePath]
			sxml::writer::attribute $myfd "ExecCount" [arrTestCase($GroupCount)($CaseCount) cget -memCaseExecCount]
			sxml::writer::attribute $myfd "RunOptions" [arrTestCase($GroupCount)($CaseCount) cget -memCaseRunoptions]
			set profile [string trim [arrTestCase($GroupCount)($CaseCount) cget -memCaseProfile] "\{"]
			set err [sxml::writer::attribute $myfd "Profile" $profile]
			if { $err < 0 } {
				puts "error9"
			      puts stderr "[sxml::writer::get_error $myfd]"
			      exit 10
			}
			# Writing HeaderFile for each Testcase
			set ele_name "Header"
			set ele_data [arrTestCase($GroupCount)($CaseCount) cget -memHeaderPath]
			write_name_data
			set x [sxml::writer::pop_element $myfd]
		}
		set x [sxml::writer::pop_element $myfd]							
	}
	# End the file
	set x [sxml::writer::finalize $myfd]
	if { $x < 0 } {
		puts "error10"
	     	puts stderr [sxml::writer::get_error $myfd]
       		exit 2
	}
	close $myfd1
	return "xmlCompleted"
}
