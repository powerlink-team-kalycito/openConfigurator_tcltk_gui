#########################################################################
#									
# Script:	xmlread.tcl						
#									
# Author:	Kalycito Infotech Pvt Ltd		
#									
# Description:	Reads the xml file and Updates the Data Structure.
#
# Version:	1.2
#
#########################################################################

# Includes
#package require xml3.1


	set flag 0
	set tg_count 0
	set tc_count 0
	set pro_count 0
	
###########################################################################							
# Proc Name:	readxml						
# Inputs:	projectfile 
# Outputs:	global data - structures for project, testgroup, testcase	
# Description:	Declares structures and calls procedure to read elements,data
# and attributes from xml.
###########################################################################
proc DeclareStructure { } {
	global tg_count
	global tc_count
	global pro_count

	set tg_count 0
	set tc_count 0
	set pro_count 0
	struct::record define recProjectDetail {
		memProjectName
		memTimeout
		memExecProfile
		memMode
		memUserInclude_path
		memTollbox_path
	}
	struct::record define recProfile {
		memProfileName
	}	
	struct::record define recTestGroup {
		memGroupName
		memGroupExecMode
		memGroupExecCount
		memChecked
		memHelpMsg
	}


	struct::record define recTestCase {
		memCasePath
		memCaseExecCount
		memCaseRunoptions
		memCaseProfile
		memHeaderPath
	}

		createproject instProject
}
proc readxml { projectfile } {
	
	##puts "Reading XML End"
	set id [open $projectfile r]
	puts Eror->$projectfile
	#set parser [::xml::parser -elementstartcommand GetAttlist -characterdatacommand GetData]
	#$parser parse [read $id]
}
############################################################################################
# proc GetAttlist
# Input name:xml element attlist:attributes of the element args:namespace
# Get the attributes from the xml creates necessary instances and stores it in the structure
############################################################################################

proc GetAttlist {name attlist args} {
	#global instProject	
	global pro_count
	global tg_count
	global tc_count
	global flag
	global totaltc
	global arrProfile
	global arrTestGroup
	global arrTestCase
	set attri [ split $attlist ]
	if {![string compare $name "Project"]} {
		instProject configure -memProjectName [lindex $attri 1]
		instProject configure -memTimeout [lindex $attri 3]
		instProject configure -memExecProfile [lindex $attri 5]
		instProject configure -memMode [lindex $attri 7]
	} elseif {![string compare $name "Usrinclpath"]} {
		set flag 1
	} elseif {![string compare $name "Toolboxpath"]} {
		set flag 2
	} elseif {![string compare $name "Profile"]} {
		incr pro_count
		recProfile arrProfile($pro_count)
		arrProfile($pro_count) configure -memProfileName [lindex $attri 1]
	} elseif {![string compare $name "TestGroup"]} {
		incr tg_count	
		set tc_count 0
		set totaltc($tg_count) 0
		recTestGroup arrTestGroup($tg_count)
		arrTestGroup($tg_count) configure -memGroupName [lindex $attri 1]
		arrTestGroup($tg_count) configure -memGroupExecMode [lindex $attri 3]
		arrTestGroup($tg_count) configure -memGroupExecCount [lindex $attri 5]
		arrTestGroup($tg_count) configure -memChecked [lindex $attri 7]
	} elseif {![string compare $name "Helpmsg"]} {
		set flag 3
	} elseif {![string compare $name "TestCase"]} {
		incr totaltc($tg_count)
		incr tc_count	
		recTestCase arrTestCase($tg_count)($tc_count)
		arrTestCase($tg_count)($tc_count) configure -memCasePath [lindex $attri 1]
		arrTestCase($tg_count)($tc_count) configure -memCaseExecCount [lindex $attri 3]
		arrTestCase($tg_count)($tc_count) configure -memCaseRunoptions [lindex $attri 5]
		arrTestCase($tg_count)($tc_count) configure -memCaseProfile [lindex $attri 7]
	} elseif {![string compare $name "Header"]} {
		set flag 4
	} 
}
################################################################################
# proc GetData
# Get the element data from the xml and stores it in the structure
################################################################################
proc GetData {data args} {
	#global instProject	
	global pro_count
	global tg_count
	global tc_count
	global flag
	global totaltc
	global header
	global arrTestGroup
	set length [string length [string trim $data]]
	if {$length != 0} {
		if {$flag == 1} {
			instProject configure -memUserInclude_path $data
			set flag 0
		} elseif {$flag == 2} {
			instProject configure -memTollbox_path $data
			set flag 0
		} elseif {$flag == 3 } {
				arrTestGroup($tg_count) configure -memHelpMsg $data
				set flag 0
		} elseif {$flag == 4} {
			arrTestCase($tg_count)($tc_count) configure -memHeaderPath $data
			set flag 0
		}
	} else {	
		#puts $data
	}
	 
}


###########################################################################							
# Proc Name:	InsertTree						
# Inputs:	 
# Outputs:	
# Description:	Based on the Global Data draw the treeview. 
#
###########################################################################
proc InsertTree { } {
	global updatetree
	global PjtDir
	#global instProject	
	global pro_count
	global tg_count
	global flag
	global totaltc
	global arrProfile
	global arrTestGroup
	global arrTestCase
	# Get the Project Details from instProject
	set ProjectName [instProject cget -memProjectName]
	set TotalTestGroup $tg_count
	puts "TotalTestGroup->$tg_count"	
        set toolBoxDir [instProject cget -memTollbox_path]
	#exec rm *~
	#Insert Project Tree
	$updatetree insert end root PjtName -text "POWERLINK Network" -open 1 -image [Bitmap::get openfold]
	$updatetree insert end root OBD -text "openPOWERLINK MN" -open 1 -image [Bitmap::get right]
	# Insert Config file of the Project
#	set child [$updatetree insert end TestSuite OBD -text "Object Dictionary" -open 1 -image [Bitmap::get right]]
		# Insert Config for the Project
#		set child [$updatetree insert 0 DevDesSettings Index_1 -text "Index_2"  -open 0 -image [Bitmap::get file]]

#		set child [$updatetree insert 0 DevDesSettings Index_2 -text "Index_1"  -open 0 -image [Bitmap::get file]]
		
	#set child [$updatetree insert end OBD MNOBD -text "Controlled Node" -open 1 -image [Bitmap::get right]]

#		set child [$updatetree insert 0 MNOBD Index_3 -text "Index_1"  -open 0 -image [Bitmap::get file]]

	##puts TotalTestGroup$TotalTestGroup
	for {set GroupCount 1 } {$GroupCount <= $TotalTestGroup} {incr GroupCount } {
		
		set tgname [testgroup($GroupCount) cget -groupName]
		set groupexecmode [testgroup($GroupCount) cget -groupExecMode]
		set groupexecount [testgroup($GroupCount) cget -groupExecCount]
		set currenttotalcase [testgroup($GroupCount) cget -groupTestCase]
		
		##puts totalcase$currenttotalcase
		# Insert TestGroup Node
        	set child [$updatetree insert $GroupCount OBD TestGroup:$GroupCount -text "$tgname" -open 1 -image [Bitmap::get openfold]]
		# Insert Config under the Group
		set child [$updatetree insert 0 TestGroup:$GroupCount Config:$GroupCount -text "Config"  -open 0 -image [Bitmap::get right]]
		# Insert groupExecCount, groupTestCase
		set child [$updatetree insert 1 Config:$GroupCount groupExecMode:$GroupCount -text $groupexecmode  -open 0 -image [Bitmap::get palette]]
		set child [$updatetree insert 2 Config:$GroupCount groupExecCount:$GroupCount -text $groupexecount  -open 0 -image [Bitmap::get palette]]
                # Insert TestCase Node
		for {set CaseCount 1 } {$CaseCount <= $currenttotalcase} {incr CaseCount } {				
				set casename [testcase($GroupCount)($CaseCount) cget -caseName]
				set execcount [testcase($GroupCount)($CaseCount) cget -caseExecCount]
				set header [testcase($GroupCount)($CaseCount) cget -caseHeader]
				# Spliting Name from whole path
				set tmpsplit [split $casename /]
				set tmpcasename [lindex $tmpsplit [expr [llength $tmpsplit] - 1]]
				# Spliting header from whole path
				set tmpsplit [split $header /]
				set tmpheader [lindex $tmpsplit [expr [llength $tmpsplit] - 1]]
			set child [$updatetree insert $CaseCount TestGroup:$GroupCount path:$GroupCount:$CaseCount -text $tmpcasename  -open 0 -image [Bitmap::get file]]
			set child [$updatetree insert 1 path:$GroupCount:$CaseCount  ExecCount:$GroupCount:$CaseCount -text $execcount -open 0 -image [Bitmap::get palette]]
			set child [$updatetree insert 2 path:$GroupCount:$CaseCount  header:$GroupCount:$CaseCount -text $tmpheader -open 0 -image [Bitmap::get palette]]
		}
	}	
}
#################################################################
# proc for creating a new instance of Testcase
# Input:group number and current node number
#################################################################
proc createtestcase { name groupno nodeno } {
	set value1 $groupno
	
	set value2 $nodeno
	if {$name=="arrTestCase"} {
		recTestCase arrTestCase($value1)($value2)
	} elseif {$name=="cpyofTestCase"} {
		recTestCase cpyofTestCase($value1)($value2)
	} else {
		recTestCase tempTestCase($value1)($value2)
	}
	#global arrTestCase($value1)($value2)
}

#################################################################
# proc for creating a new instance of TestGroup
# Input:Group number
#################################################################
proc createtestgroup { name groupno } {
	set value1 $groupno
	if {$name=="arrTestGroup"} {
		recTestGroup arrTestGroup($value1)
	} elseif {$name=="cpyofTestGroup"} {
		recTestGroup cpyofTestGroup($value1)
	} else {
		recTestGroup tempTestGroup($value1)
	}
}
#################################################################
# proc for creating a new instance of recProfile
# Input:Profile number
#################################################################
proc createprofile { name profileno } {
	if {$name=="arrProfile"} {
		recProfile arrProfile($profileno)
	} elseif {$name=="cpyofProfile"} {
		recProfile cpyofProfile($profileno)
	} else {
		recProfile tempProfile($profileno)
	}
}
#################################################################
# proc for creating a new instance of Project
##################################################################
proc createproject {name } {
	recProjectDetail $name
}
	
#################################################################
# proc for freeup the  memory Testcase or Testgroup
#################################################################
proc freegroup { value } {

	struct::record show values $value
	
}
