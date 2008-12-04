#########################################################################
#									
# Script:	xmlread.tcl						
#									
# Author:	Kalycito Infotech Pvt Ltd		
#									
# Description:	Reads the xml file and Updates the Data Structure.
#
# Version:	Initially released version.
#
#########################################################################
set RootDir [pwd]
# Includes
source $RootDir/sxml.tcl
#########################################################################							
# Proc Name:	getdata 						
# Inputs:	cstack,cdata,saved_data,cattr,saved_attr
# Outputs:	-	
# Description:	Get the required data from xml put to the namelist
#########################################################################

proc getdata {cstack cdata saved_data cattr saved_attr } {
upvar $saved_data sdata
upvar $saved_attr sattr
global namelist
global tmpcount
	set namelist($tmpcount) $cdata
	incr tmpcount
        return 0
}
###########################################################################							
# Proc Name:	ignoreproc 						
# Inputs:	cstack,cdata,saved_data,cattr,saved_attr
# Outputs:	-	
# Description:	Ignore the other xml data.
###########################################################################
proc ignoreproc {cstack cdata saved_data cattr saved_attr args} {
	return 0
}
###########################################################################							
# Proc Name:	getvalue						
# Inputs:	datatoget 
# Outputs:	global data - namelist	
# Description:	Open the xml file and get the required data to the namelist
###########################################################################
proc getvalue { datatoget } {
	variable count
	global filename
	
	set id [sxml::init $filename]	
	if { $id == -1 } {
        	puts "Error: Unable to parse test file!"
        	exit 1
	}
	
	# Regisiter the two routines written above.				

	#set x [sxml::set_attr $id extended 1]
	sxml::register_routine $id $datatoget getdata

	# Parse the data!							
	set count 1

	set x [sxml::parse $id]

	# Remove the reference for this file from the parser.			
	sxml::end $id
	
}

###########################################################################							
# Proc Name:	readresultxml						
# Inputs:	projectfile 
# Outputs:	global data - structures for project, testgroup, testcase	
# Description:	Collect Datas from XML and Create the required instances to 
#		store them.
###########################################################################
proc readresultxml { projectfile } {
	global namelist

	
	variable filename 
	set filename $projectfile
	# Read Project Details 
	# set count=1 because the namelist(count)
	# Read ProjectName for the Project
	set tmpcount 1
	set datatoget "testsuite:summary:total"
	getvalue $datatoget

	for {set temp 1} {$temp <= 2} {incr temp} {
	set total($temp) $namelist($temp)	
	}
	#set GrandTotal [expr {[$total(1)]+[$total(2)]}]
	#puts $GrandTotal
	
##initwritexml "outputtree11.xml"
##inserttree
}

