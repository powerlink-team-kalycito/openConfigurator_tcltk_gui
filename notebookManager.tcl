####################################################################################################
#
#
#  NAME:     manager.tcl
#
#  PURPOSE:  Creates the windows (tablelist, console, tabs, tree) 
#
#  AUTHOR:   Kalycito Infotech Pvt Ltd
#
#  Copyright :(c) Kalycito Infotech Private Limited
#
#***************************************************************************************************
#  COPYRIGHT NOTICE: 
#
#  Project:      openCONFIGURATOR 
#
#  License:
#
#    Redistribution and use in source and binary forms, with or without
#    modification, are permitted provided that the following conditions
#    are met:
#
#    1. Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
#    3. Neither the name of Kalycito Infotech Private Limited nor the names of 
#       its contributors may be used to endorse or promote products derived
#       from this software without prior written permission. For written
#       permission, please contact info@kalycito.com.
#
#    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#    POSSIBILITY OF SUCH DAMAGE.
#
#    Severability Clause:
#
#        If a provision of this License is or becomes illegal, invalid or
#        unenforceable in any jurisdiction, that shall not affect:
#        1. the validity or enforceability in that jurisdiction of any other
#           provision of this License; or
#        2. the validity or enforceability in other jurisdictions of that or
#           any other provision of this License.
#
#***************************************************************************************************
#
#  REVISION HISTORY:
#  
####################################################################################################


#---------------------------------------------------------------------------------------------------
#  NameSpace Declaration
#
#  namespace : NoteBookManager
#---------------------------------------------------------------------------------------------------
namespace eval NoteBookManager {
    variable _pageCounter 0
    variable _consoleCounter 0
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::create_tab
# 
#  Arguments : nbpath  - frame path to create
#              choice  - choice for index or subindex to create frame
# 
#  Results : outerFrame - Basic frame 
#	   		 tabInnerf0 - frame containing widgets describing the object (index id, Object name, subindex id )
#		     tabInnerf1 - frame containing widgets describing properties of object	
#
#  Description : Creates the GUI for Index and subindex
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_tab { nbpath choice } {

		variable _pageCounter
    incr _pageCounter

		#-------------------------
		#	Global variables
		#-------------------------
    global tmpNam$_pageCounter
    global tmpValue$_pageCounter
		global tmpEntryValue
		global ra_dataType
		global ch_generate
		global indexSaveBtn
		global subindexSaveBtn
		global co_access
		global co_obj
		global co_pdo

    set nbname "page$_pageCounter"

		set outerFrame [frame $nbpath.$nbname -relief raised -borderwidth 1 ]
		set frame [frame $outerFrame.frame -relief flat -borderwidth 10  ] 
		pack $frame -expand yes -fill both

       set scrollWin [ScrolledWindow $frame.scrollWin]
    pack $scrollWin -fill both -expand true

    set sf [ScrollableFrame $scrollWin.sf]
    $scrollWin setwidget $sf

    set uf [$sf getframe]
  	$uf configure -height 20 
		set tabTitlef0 [TitleFrame $uf.tabTitlef0 -text "Sub Index" ]
		set tabInnerf0 [$tabTitlef0 getframe]
		set tabTitlef1 [TitleFrame $uf.tabTitlef1 -text "Properties" ]
		set tabInnerf1 [$tabTitlef1 getframe]
		set tabInnerf0_1 [frame $tabInnerf0.frame1 ]

		label $tabInnerf0.la_idx     -text "Index  " 
    label $tabInnerf0.la_empty1 -text "" 
    label $tabInnerf0.la_empty2 -text "" 
		label $tabInnerf0.la_nam     -text "Name           " 
    label $tabInnerf0.la_empty3 -text ""
		label $tabInnerf0_1.la_generate -text "Include index in CDC generation"
		label $tabInnerf1.la_obj     -text "Object Type" 
    label $tabInnerf1.la_empty4 -text "" 
		label $tabInnerf1.la_data    -text "Data Type"  
    label $tabInnerf1.la_empty5 -text "" 
		label $tabInnerf1.la_access  -text "Access Type"  
    label $tabInnerf1.la_empty6 -text "" 
		label $tabInnerf1.la_value   -text "Value" 
		label $tabInnerf1.la_default -text "Default Value" 
		label $tabInnerf1.la_upper   -text "Upper Limit" 
		label $tabInnerf1.la_lower   -text "Lower Limit" 
		label $tabInnerf1.la_pdo   -text "PDO Mapping" 

		entry $tabInnerf0.en_idx1 -state disabled 
		entry $tabInnerf0.en_nam1 -textvariable tmpNam$_pageCounter -relief ridge -justify center -bg white -width 30 -validate key -vcmd "Validation::IsValidStr %P"
		entry $tabInnerf1.en_obj1 -state disabled   
		entry $tabInnerf1.en_data1 -state disabled
		entry $tabInnerf1.en_access1 -state disabled
		entry $tabInnerf1.en_upper1 -state disabled -validate key -vcmd "Validation::IsHex %P %s $tabInnerf1.en_upper1 %d %i"
		entry $tabInnerf1.en_lower1 -state disabled -validate key -vcmd "Validation::IsHex %P %s $tabInnerf1.en_lower1 %d %i"
		entry $tabInnerf1.en_pdo1 -state disabled
		entry $tabInnerf1.en_default1 -state disabled
		entry $tabInnerf1.en_value1 -textvariable tmpValue$_pageCounter  -relief ridge -justify center -bg white -validate key -vcmd "Validation::IsDec %P $tabInnerf1.en_value1 %d %i"
	
		set objCoList [list DEFTYPE DEFSTRUCT VAR ARRAY RECORD]
		ttk::combobox $tabInnerf1.co_obj1 -values $objCoList -state readonly -textvariable co_obj
		#set dataCoList ""
		#ComboBox $tabInnerf1.co_data1 -values $dataCoList -modifycmd "" -editable no
		set accessCoList [list const ro wr rw readWriteInput readWriteOutput noAccess]
		ttk::combobox $tabInnerf1.co_access1 -values $accessCoList -state readonly -textvariable co_access
		set pdoColist [list NO DEFAULT OPTIONAL RPDO TPDO]
		ttk::combobox $tabInnerf1.co_pdo1 -values $pdoColist -state readonly -textvariable co_pdo
	
		set frame1 [frame $tabInnerf1.frame1]
 	  set ra_dec [radiobutton $frame1.ra_dec -text "Dec" -variable ra_dataType -value dec -command "NoteBookManager::ConvertDec $tabInnerf1"]
		set ra_hex [radiobutton $frame1.ra_hex -text "Hex" -variable ra_dataType -value hex -command "NoteBookManager::ConvertHex $tabInnerf1"]
		set ra_ip  [radiobutton $frame1.ra_ip -text "IP address" -variable ra_dataType -value ip -command "ConvertIP $tabInnerf1"]
		set ra_mac  [radiobutton $frame1.ra_mac -text "MAC address" -variable ra_dataType -value mac -command "ConvertMAC $tabInnerf1"]
    
		set ch_gen [checkbutton $tabInnerf0_1.ch_gen -onvalue 1 -offvalue 0 -command { Validation::SetPromptFlag } -variable ch_generate]
	
		grid config $tabTitlef0 -row 0 -column 0 -sticky ew
		label $uf.la_empty -text ""
		grid config $uf.la_empty -row 1 -column 0
		grid config $tabTitlef1 -row 2 -column 0 -sticky ew
	
		grid config $tabInnerf0.la_idx -row 0 -column 0 -sticky w
		grid config $tabInnerf0.en_idx1 -row 0 -column 1 -padx 5
		grid config $tabInnerf0.la_empty1 -row 1 -column 0 -columnspan 2
		grid config $tabInnerf0.la_empty2 -row 3 -column 0 -columnspan 2
		
		grid config $tabInnerf1.la_data -row 0 -column 0 -sticky w
		#grid config $tabInnerf1.co_data1 -row 0 -column 1 -padx 5
		#grid remove $tabInnerf1.co_data1
		grid config $tabInnerf1.en_data1 -row 0 -column 1 -padx 5
	
		grid config $tabInnerf1.la_upper -row 0 -column 2 -sticky w
		grid config $tabInnerf1.en_upper1 -row 0 -column 3 -padx 5
	
		grid config $tabInnerf1.la_access -row 0 -column 4 -sticky w
		grid config $tabInnerf1.co_access1 -row 0 -column 5 -padx 5 
		grid remove $tabInnerf1.co_access1
		grid config $tabInnerf1.en_access1 -row 0 -column 5 -padx 5 
	
		grid config $tabInnerf1.la_empty4 -row 1 -column 0 -columnspan 2
	
		grid config $tabInnerf1.la_obj -row 2 -column 0 -sticky w 
		grid config $tabInnerf1.co_obj1 -row 2 -column 1 -padx 5
		grid remove $tabInnerf1.co_obj1
		grid config $tabInnerf1.en_obj1 -row 2 -column 1 -padx 5
	
		grid config $tabInnerf1.la_lower -row 2 -column 2 -sticky w
		grid config $tabInnerf1.en_lower1 -row 2 -column 3 -padx 5
	
		grid config $tabInnerf1.la_pdo -row 2 -column 4 -sticky w
		grid config $tabInnerf1.co_pdo1 -row 2 -column 5 -padx 5
		grid remove $tabInnerf1.co_pdo1
		grid config $tabInnerf1.en_pdo1 -row 2 -column 5 -padx 5

		grid config $tabInnerf1.la_empty5 -row 3 -column 0 -columnspan 2

		grid config $tabInnerf1.la_value -row 4 -column 0 -sticky w
		grid config $tabInnerf1.en_value1 -row 4 -column 1 -padx 5 
	
		grid config $frame1 -row 4 -column 3 -padx 5 -columnspan 2 -sticky w
		grid config $tabInnerf1.la_default -row 4 -column 4 -sticky w
		grid config $tabInnerf1.en_default1 -row 4 -column 5 -padx 5 
		grid config $tabInnerf1.la_empty6 -row 5 -column 0 -columnspan 2
	
		grid config $ra_dec -row 0 -column 0 -sticky w
		grid config $ra_hex -row 0 -column 1 -sticky w
		grid config $ra_ip -row 0 -column 2 -sticky w
		grid config $ra_mac -row 0 -column 3 -sticky w
	
		grid remove $ra_dec
		grid remove $ra_hex
		grid remove $ra_ip
		grid remove $ra_mac

   	if {$choice == "index"} {
			$tabTitlef0 configure -text "Index" 
			$tabTitlef1 configure -text "Properties" 
			grid config $tabInnerf0.la_idx -row 0 -column 0 -sticky w
			grid config $tabInnerf0.en_idx1 -row 0 -column 1 -sticky w -padx 0
			grid config $tabInnerf0.la_nam -row 2 -column 0 -sticky w 
			grid config $tabInnerf0.en_nam1 -row 2 -column 1  -sticky w -columnspan 1
			#grid config $tabInnerf0.la_generate -row 4 -column 0 -columnspan 2 -sticky w
			grid config $tabInnerf0_1 -row 4 -column 0 -columnspan 2 -sticky w
			grid config $tabInnerf0_1.la_generate -row 0 -column 0 -sticky w 
			grid config $tabInnerf0_1.ch_gen -row 0 -column 1 -sticky e -padx 5
			#grid config $tabInnerf0_1.la_generate -row 0 -column 0 -sticky w
			#grid config $tabInnerf0_1.ra_genYes -row 0 -column 1 -sticky e
			#grid config $tabInnerf0_1.ra_genNo -row 0 -column 2 -sticky e
			grid config $tabInnerf0.la_empty3 -row 5 -column 0 -columnspan 2
		} elseif { $choice == "subindex" } {
			$tabTitlef0 configure -text "Sub Index" 
			$tabTitlef1 configure -text "Properties" 

			label $tabInnerf0.la_sidx -text "Sub Index  "  
			entry $tabInnerf0.en_sidx1 -state disabled

			grid config $tabInnerf0.la_sidx -row 2 -column 0 -sticky w 
			grid config $tabInnerf0.en_sidx1 -row 2 -column 1 -padx 5
			grid config $tabInnerf0.la_nam -row 2 -column 2 -sticky w 
			grid config $tabInnerf0.en_nam1 -row 2 -column 3  -sticky e -columnspan 1
 	 }

  	set fram [frame $frame.f1]  
   	label $fram.la_empty -text "  " -height 1
		if { $choice == "index" } {
			set indexSaveBtn [ button $fram.bt_sav -text " Save " -width 8 -command "NoteBookManager::SaveValue $tabInnerf0 $tabInnerf1"]
		} elseif { $choice == "subindex" } {
			set subindexSaveBtn [ button $fram.bt_sav -text " Save " -width 8 -command "NoteBookManager::SaveValue $tabInnerf0 $tabInnerf1"]
		}
  	label $fram.la_empty1 -text "  "
   	button $fram.bt_dis -text "Discard" -width 8 -command "NoteBookManager::DiscardValue $tabInnerf0 $tabInnerf1"
   	grid config $fram.la_empty -row 0 -column 0 -columnspan 2
   	grid config $fram.bt_sav -row 1 -column 0 -sticky s
   	grid config $fram.la_empty1 -row 1 -column 1 -sticky s
   	grid config $fram.bt_dis -row 1 -column 2 -sticky s
   	pack $fram -side bottom

    return [list $outerFrame $tabInnerf0 $tabInnerf1 ]
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::create_table
# 
#  Arguments : nbpath  - frame path to create
#              choice  - choice for pdo to create frame
#
#  Results : basic frame on which all widgets are created
#	    	 tablelist widget path
#
#  Description : Creates the tablelist for TPDO and RPDO
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_table {nbpath choice} {

		#-------------------------
		#	Global variables
		#-------------------------
		global tableSaveBtn

    variable _pageCounter
    incr _pageCounter
    set nbname "page$_pageCounter"

		set outerFrame [frame $nbpath.$nbname -relief raised -borderwidth 1 ] 
		set frmPath [frame $outerFrame.frmPath -relief flat -borderwidth 10  ]
		pack $frmPath -expand yes -fill both

    set scrollWin [ScrolledWindow $frmPath.scrollWin ]
    pack $scrollWin -fill both -expand true
    set st $frmPath.st

    catch "font delete custom1"
    font create custom1 -size 9 -family TkDefaultFont

		if {$choice == "pdo"} {
			set st [tablelist::tablelist $st \
	   		-columns {0 "No" left
		     		0 "Node Id" center
	      		0 "Offset" center
	      		0 "Length" center
	      		0 "Index" center
	      		0 "Sub Index" center} \
    			-setgrid 0 -width 0 \
    			-stripebackground gray98 \
    			-resizable 1 -movablecolumns 0 -movablerows 0 \
    			-showseparators 1 -spacing 10 -font custom1 \
					-editstartcommand NoteBookManager::StartEdit -editendcommand NoteBookManager::EndEdit ]

			$st columnconfigure 0 -editable no 
			$st columnconfigure 1 -editable no
			$st columnconfigure 2 -editable yes -editwindow entry	
			$st columnconfigure 3 -editable yes -editwindow entry
			$st columnconfigure 4 -editable yes -editwindow entry
			$st columnconfigure 5 -editable yes -editwindow entry
		} else {
			#invalid choice
			return
		}

		$scrollWin setwidget $st
    pack $st -fill both -expand true
    $st configure -height 4 -width 40 -stretch all	

   	set fram [ frame $frmPath.f1 ]  
   	label $fram.la_empty -text "  " -height 1 
   	set tableSaveBtn [ button $fram.bt_sav -text " Save " -width 8 -command "NoteBookManager::SaveTable $st" ]
   	label $fram.la_empty1 -text "  "
   	button $fram.bt_dis -text "Discard" -width 8 -command "NoteBookManager::DiscardTable $st"
   	grid config $fram.la_empty -row 0 -column 0 -columnspan 2
   	grid config $fram.bt_sav -row 1 -column 0 -sticky s
   	grid config $fram.la_empty1 -row 1 -column 1 -sticky s
   	grid config $fram.bt_dis -row 1 -column 2 -sticky s
   	pack $fram -side top

    return  [list $outerFrame $st]
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::create_infoWindow
# 
#  Arguments : nbpath  - path of the notebook
#	       	   tabname - title for the created tab
#              choice  - choice to create Information, Error and Warning windows
#
#  Results : path of the inserted frame in notebook
#
#  Description : Creates displaying Information, Error and Warning messages windows
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_infoWindow {nbpath tabname choice} {

		#-------------------------
		#	Global variables
		#-------------------------
		global infoWindow
    global warWindow
    global errWindow

		variable _consoleCounter
   	incr _consoleCounter

   	set nbname Console$_consoleCounter
   	set frmPath [$nbpath insert end $nbname -text $tabname]
    
   	set scrollWin [ScrolledWindow::create $frmPath.scrollWin -auto both]
   	if {$choice == 1} {
	  	set infoWindow [InitInfoWindow $scrollWin]
		  set window $infoWindow
		  lappend infoWindow $nbpath $nbname
		  $nbpath itemconfigure $nbname -image [Bitmap::get file]
    } elseif {$choice == 2} {
		  set errWindow [InitErrorWindow $scrollWin]
		  set window $errWindow
		  lappend errWindow $nbpath $nbname
		  $nbpath itemconfigure $nbname -image [Bitmap::get error_small]
    } elseif {$choice == 3} {    
		  set warWindow [InitWarnWindow $scrollWin]
		  set window $warWindow
		  lappend warWindow $nbpath $nbname
		  $nbpath itemconfigure $nbname -image [Bitmap::get warning_small]
    } else {
		  #invalid selection
  	  return
    }
    
		$window configure -wrap word
   	ScrolledWindow::setwidget $scrollWin $window
   	pack $scrollWin -fill both -expand yes

   	#raised the window after creating it 
   	$nbpath raise $nbname
   	return $frmPath
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::create_treeBrowserWindow
# 
#  Arguments : nbpath  - path of the notebook
#
#  Results : path of the inserted frame in notebook
#	     	 path of the tree widget
#
#  Description : Creates the tree widget in notebook
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_treeBrowserWindow {nbpath } {

		#-------------------------
		#	Global variables
		#-------------------------
		global treeFrame
		global treePath
	
		set nbname objectTree
    set frmPath [$nbpath insert end $nbname -text "Tree Browser"]
   
   	set scrollWin [ScrolledWindow::create $frmPath.scrollWin -auto both]
   	set treeBrowser [Tree $frmPath.scrollWin.treeBrowser \
  	 	-width 15\
  	 	-highlightthickness 0\
  	 	-bg white  \
  	 	-deltay 15 \
  	 	-padx 15 \
  	 	-dropenabled 0 -dragenabled 0 -relief ridge 
    ]
		$scrollWin setwidget $treeBrowser
		set treePath $treeBrowser
	
   	pack $scrollWin -side top -fill both -expand yes -pady 1
   	set treeFrame [frame $frmPath.f1]
	pack $treeFrame -side bottom -pady 5
	#grid config $treeFrame -row 0 -column 0 -sticky s -pady 5 
   	entry $treeFrame.en_find -textvariable FindSpace::txtFindDym -width 10 -background white -validate key -vcmd "FindSpace::Find %P"
  	button $treeFrame.bt_next -text " Next " -command "FindSpace::Next" -image [Bitmap::get right] -relief flat
   	button $treeFrame.bt_prev -text " Prev " -command "FindSpace::Prev" -image [Bitmap::get left] -relief flat
   	grid config $treeFrame.en_find -row 0 -column 0 -sticky ew
   	grid config $treeFrame.bt_prev -row 0 -column 1 -sticky s -padx 5
   	grid config $treeFrame.bt_next -row 0 -column 2 -sticky s
	#pack forget $treeFrame
   	return [list $frmPath $treeBrowser]
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::ConvertDec
# 
#  Arguments : tmpValue - path that containing value and default entry widget 
#
#  Results : -
#
#  Description : converts value into decimal and changes validation for entry
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::ConvertDec {tmpValue} {

		#-------------------------
		#	Global variables
		#-------------------------
    global lastConv
		global userPrefList
		global nodeSelect
		
		if { $lastConv != "dec"} {
		  set lastConv dec
		  set schRes [lsearch $userPrefList [list $nodeSelect *]]
		  if {$schRes  == -1} {
		    lappend userPrefList [list $nodeSelect dec]
		  } else {
		    set userPrefList [lreplace $userPrefList $schRes $schRes [list $nodeSelect dec] ]
		  }

		  set state [$tmpValue.en_value1 cget -state]
		  $tmpValue.en_value1 configure -validate none -state normal
		  NoteBookManager::InsertDecimal $tmpValue.en_value1
		  $tmpValue.en_value1 configure -validate key -vcmd "Validation::IsDec %P $tmpValue.en_value1 %d %i" -state $state
		
		  set state [$tmpValue.en_default1 cget -state]
		  $tmpValue.en_default1 configure -state normal
		  NoteBookManager::InsertDecimal $tmpValue.en_default1
		  $tmpValue.en_default1 configure -state $state	
		} else {
			#already dec is selected
		}
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::InsertDecimal
# 
#  Arguments : tmpValue - path of the entry widget 
#
#  Results : -
#
#  Description : Convert the value into decimal and insert into the entry widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::InsertDecimal {tmpValue} {
	set tmpVal [$tmpValue get]
	set tmpVal [string range $tmpVal 2 end]
	if { $tmpVal == 0 } {
		#puts "# value is zero save as it is "
		$tmpValue delete 0 end
		$tmpValue insert 0 $tmpVal
	} elseif { $tmpVal != "" } {
		  set zeroCount [NoteBookManager::CountLeadZero $tmpVal] ; #counting the leading zero if they are present
		if { [ catch {set tmpVal [expr 0x$tmpVal]} ] } {
				#error raised should not convert
				#puts "error raised INSERT DEC tmpVal->$tmpVal"
		} else {
				set tmpVal [ NoteBookManager::AppendZero $tmpVal [expr $zeroCount+[string length $tmpVal] ] ] ; #appending trimmed leading zero if any
				#puts "INSERT DEC $tmpValue->$tmpVal"
				$tmpValue delete 0 end
				$tmpValue insert 0 $tmpVal
		}
	} else {
			#puts "#value is empty no need to insert delete the previous entry to clear 0x "
			$tmpValue delete 0 end
	}
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::ConvertHex
# 
#  Arguments : tmpValue - path containing the value and default entry widget 
#
#  Results : -
#
#  Description : converts the value to hexadecimal and changes validation for entry
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::ConvertHex {tmpValue} {

		#-------------------------
		#	Global variables
		#-------------------------
		global lastConv
		global userPrefList
		global nodeSelect
	
		if { $lastConv != "hex"} {
		  set lastConv hex
			set schRes [lsearch $userPrefList [list $nodeSelect *]]
			if {$schRes  == -1} {
		    lappend userPrefList [list $nodeSelect hex]
			} else {
		    set userPrefList [lreplace $userPrefList $schRes $schRes [list $nodeSelect hex] ]
			}
		
			set state [$tmpValue.en_value1 cget -state]
			#puts "NoteBookManager::ConvertHex state->$state"
		  $tmpValue.en_value1 configure -validate none -state normal
			NoteBookManager::InsertHex $tmpValue.en_value1
			$tmpValue.en_value1 configure -validate key -vcmd "Validation::IsHex %P %s $tmpValue.en_value1 %d %i" -state $state
		
			set state [$tmpValue.en_default1 cget -state]
			$tmpValue.en_default1 configure -state normal
			NoteBookManager::InsertHex $tmpValue.en_default1
			$tmpValue.en_default1 configure -state $state
		} else {
			#puts "NoteBookManager::ConvertHex already selected"
			#already hex is selected
		}
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::InsertHex
# 
#  Arguments : tmpValue - path of the entry widget 
#
#  Results : -
#
#  Description : Convert the value into hexadecimal and insert into the entry widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::InsertHex {tmpValue} {
		puts "\n InserHex  [$tmpValue get] state=[$tmpValue cget -state]"
		set tmpVal [$tmpValue get]
		puts "tmpVal->$tmpVal"
		if {$tmpVal != ""} {
			puts "tmpVal->$tmpVal"
			$tmpValue delete 0 end
			set tmpVal [Validation::InputToHex $tmpVal]
			puts "InsertHex after conversion tmpVal->$tmpVal "
			$tmpValue insert 0 $tmpVal
		} else {
			$tmpValue delete 0 end
			set tmpVal 0x
			$tmpValue insert 0 $tmpVal
		}
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::AppendZero
# 
#  Arguments : input  - string to be append with zero
#	       	   length - length upto append the zero
#  Results : -
#
#  Description : Append zeros into the input until the required length is reached
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::AppendZero {input length} {
	while {[string length $input] < $length} {
		set input 0$input
	}
	return $input
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::CountLeadZero
# 
#  Arguments : input - string 
#	   
#  Results : loopCount - number of leading zeros in input
#
#  Description : Count the leading zeros of the input
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::CountLeadZero {input} {
	for { set loopCount 0 } { $loopCount < [string length $input] } {incr loopCount} {
	        if { [string match 0 [string index $input $loopCount] ] == 1 } {
	        	#continue
	        } else {
		    break
		}
	}
	return $loopCount
    
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::SaveValue
# 
#  Arguments : frame0 - frame containing the widgets describing the object (index id, Object name, subindex id )
#	           frame1 - frame containing the widgets describing properties of object	
#	   
#  Results :  - 
#
#  Description : save the entered value for index and subindex
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SaveValue {frame0 frame1} {
    
	#-------------------------
	#	Global variables
	#-------------------------
	global nodeSelect
	global nodeIdList
	global treePath
	#this list contains Nodes whose value are changed using save option
	global savedValueList 
	global userPrefList
	global lastConv
	global status_save


	set oldName [$treePath itemcget $nodeSelect -text]
	if {[string match "*SubIndexValue*" $nodeSelect]} {
		set subIndexId [string range $oldName end-2 end-1]
		set subIndexId [string toupper $subIndexId]
		set parent [$treePath parent $nodeSelect]
		set indexId [string range [$treePath itemcget $parent -text ] end-4 end-1]
		set indexId [string toupper $indexId]
		set oldName [string range $oldName end-5 end ]
	} else {
		set indexId [string range $oldName end-4 end-1 ]
		set indexId [string toupper $indexId]
		set oldName [string range $oldName end-7 end ]
	}

        #gets the nodeId and Type of selected node
        set result [Operations::GetNodeIdType $nodeSelect]
        if {$result != "" } {
        	set nodeId [lindex $result 0]
		set nodeType [lindex $result 1]
	} else {
		#must be some other node this condition should never reach
		#puts "\n\nNoteBookManager::SaveValue->SHOULD NEVER HAPPEN 1!!\n\n"
		return
	}
	
	set tmpVar0 [$frame0.en_nam1 cget -textvariable]
	global $tmpVar0
	set newName [subst $[subst $tmpVar0]]
	#puts "newName->[subst $[subst $tmpVar0]]->[$frame0.en_nam1 get]"
	
	#puts "state=[$frame1.en_value1 cget -state]"
	set state [$frame1.en_value1 cget -state]
	$frame1.en_value1 configure -state normal
	set tmpVar1 [$frame1.en_value1 cget -textvariable]
	global $tmpVar1	
	set value [string toupper [subst $[subst $tmpVar1]] ]
	#puts "value->$value"
	
	if { [expr 0x$indexId > 0x1fff] } {
	  #puts "\nSAVE NOT IMPLEMENTED FOR INDEX ABOVE 1FFF AND ITS SUBINDEX  \n"
		#tk_messageBox -message "Save not implemented for index above 1FFF and its subindex" -parent .
		##puts "0x$indexId is greater than 0x1fff save not yet implemented"
		#return
		
		set dataType [$frame1.en_data1 get]
		#puts "frame1.co_access1 get ->[$frame1.co_access1 cget -values]"
		set accessType [$frame1.co_access1 get]
		#set objectType [$frame1.co_obj1 getvalue]
		set objectType [$frame1.co_obj1 get]
		set pdoType [$frame1.co_pdo1 get]
		set upperLimit [$frame1.en_upper1 get]
		set lowerLimit [$frame1.en_lower1 get]
		set default [$frame1.en_default1 get]
	} else {
		#continue
	
		set radioSel [$frame1.frame1.ra_dec cget -variable]
		global $radioSel
		#puts "radioSel->$radioSel"
		set radioSel [subst $[subst $radioSel]]
		#puts "radioSel after sub ->$radioSel"
	
		$frame1.en_data1 configure -state normal
		set dataType [$frame1.en_data1 get]
		$frame1.en_data1 configure -state disabled
		#puts "dataType->$dataType"

		if {$value != ""} {
		  
			#$frame1.en_data1 configure -state normal
			#set dataType [$frame1.en_data1 get]
			#$frame1.en_data1 configure -state disabled
			#puts "dataType->$dataType"
			if { $dataType == "IP_ADDRESS" } {
				set result [$frame1.en_value1 validate]
				if {$result == 0} {
					tk_messageBox -message "IP address not complete\n values not saved" -title Warning -icon warning -parent .
					return
				}
			} elseif { $dataType == "MAC_ADDRESS" } {	
				set result [$frame1.en_value1 validate]
				if {$result == 0} {
					tk_messageBox -message "MAC address not complete\n values not saved" -title Warning -icon warning -parent .	
					return
				}
			} elseif { $dataType ==  "Visible_String" } {
				#continue
			} elseif { $radioSel == "hex" } {
				puts "#it is hex value trim leading 0x"
				set value [string range $value 2 end]
				set value [string toupper $value]
				if { $value == "" } {
					set value []
				} else {
					set value 0x$value
				}
			} elseif { $radioSel == "dec" } {  
				puts "#is is dec value convert to hex"
				#set value [string trimleft $value 0] ; trimming zero leads to error
				#puts "value after trim for dec :$value"
				set value [Validation::InputToHex $value]
				if { $value == "" } {
					set value []
				} else {
				        #0x is appended to represent it as hex
				        set value [string range $value 2 end]
				        #puts "value after conv for dec :$value"
				        set value [string toupper $value]
				        set value 0x$value
				}
			} else {
				#puts "\n\n\nNoteBookManager::SaveValue->Should Never Happen 1!!!\n\n\n"
			}
		} else {
			#no value has been inputed by user
			set value []
		}
	}
	
	if {[string match "*SubIndexValue*" $nodeSelect]} {
	    	if { [expr 0x$indexId > 0x1fff] } {
			#DllExport ocfmRetCode SetALLSubIndexAttributes(int NodeID, ENodeType NodeType, 
			#char* IndexID, char* SubIndexID, char* ActualValue,
			#char* IndexName, char* Access, char* dataTypeName,
			#char* pdoMappingVal, char* defaultValue, char* highLimit,
			#char* lowLimit, char* objType);
			#TODO 0 is hardcoded
			puts "SetALLSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $newName $accessType $dataType $pdoType $default $upperLimit $lowerLimit $objectType 0"
			set catchErrCode [SetALLSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $newName $accessType $dataType $pdoType $default $upperLimit $lowerLimit $objectType 0]
			#return
		} else {
	        	#DllExport ocfmRetCode SetSubIndexAttributes(int NodeID, ENodeType NodeType, char* IndexID, char* SubIndexID, char* IndexValue, char* IndexName);
			puts "SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $newName"
			set catchErrCode [SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $newName]
			#puts "catchErrCode->$catchErrCode"
		}
	} elseif {[string match "*IndexValue*" $nodeSelect]} {
	    	set chkGen [$frame0.frame1.ch_gen cget -variable]
		global $chkGen
		if { [expr 0x$indexId > 0x1fff] } {
			#DllExport ocfmRetCode SetALLIndexAttributes(int NodeID, ENodeType NodeType, 
			#char* IndexID, char* ActualValue, char* IndexName, char* Access, char* dataTypeName,
			#char* pdoMappingVal, char* defaultValue, char* highLimit,char* lowLimit,
			#char* objType, EFlag flagIfIncludedInCdc);
			puts "SetALLIndexAttributes $nodeId $nodeType $indexId $value $newName $accessType $dataType $pdoType $default $upperLimit $lowerLimit $objectType [subst $[subst $chkGen]]"
			set catchErrCode [SetALLIndexAttributes $nodeId $nodeType $indexId $value $newName $accessType $dataType $pdoType $default $upperLimit $lowerLimit $objectType [subst $[subst $chkGen]] ]
			#return
		} else {
			#DllExport ocfmRetCode SetIndexAttributes(int NodeID, ENodeType NodeType, char* IndexID, char* IndexValue, char* IndexName);
			puts "SetIndexAttributes $nodeId $nodeType $indexId $value $newName $chkGen->[subst $[subst $chkGen]]"
			set catchErrCode [SetIndexAttributes $nodeId $nodeType $indexId $value $newName [subst $[subst $chkGen]] ]
			#puts "catchErrCode->$catchErrCode"
		}
	} else {
		puts "\n\n\nNoteBookManager::SaveValue->Should Never Happen 2!!!$nodeSelect->$$nodeSelect\n\n\n"
		return
	}
	set ErrCode [ocfmRetCode_code_get $catchErrCode]
	#puts "ErrCode:$ErrCode"
	if { $ErrCode != 0 } {
		#tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning
		if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .
		} else {
			tk_messageBox -message "Unknown Error" -title Warning -icon warning -parent .
                        puts "Unknown Error in NoteBookManager::SaveValue ->[ocfmRetCode_errorString_get $catchErrCode]\n"
		}
		return
	}

	#value for Index or SubIndex is edited need to change
	set status_save 1
	#set chkPrompt 0
	
	set newName [append newName $oldName]
	#puts "newName->$newName"
	$treePath itemconfigure $nodeSelect -text $newName
	
        lappend savedValueList $nodeSelect
        $frame0.en_nam1 configure -bg #fdfdd4
        $frame1.en_value1 configure -bg #fdfdd4
	
	
	$frame1.en_value1 configure -state $state
	
	Validation::ResetPromptFlag
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::DiscardValue
# 
#  Arguments : frame0 - frame containing widgets describing the object (index id, Object name, subindex id )
#	           frame1 - frame containing widgets describing properties of object	
#	   
#  Results : -
#
#  Description : Discards the entered values and displays last saved values
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::DiscardValue {frame0 frame1} {

	#-------------------------
	#	Global variables
	#-------------------------
	global nodeSelect
	global nodeIdList
	global treePath
	global userPrefList
	
	global lastConv

	#puts "\n\n  NoteBookManager::DiscardValue \n"

	set oldName [$treePath itemcget $nodeSelect -text]
	if {[string match "*SubIndexValue*" $nodeSelect]} {
		set subIndexId [string range $oldName end-2 end-1]
		set parent [$treePath parent $nodeSelect]
		set indexId [string range [$treePath itemcget $parent -text] end-4 end-1]
		set parent [$treePath parent $parent]

	} else {
		set indexId [string range $oldName end-4 end-1 ]
		set parent [$treePath parent $nodeSelect]
	}

	#if { [expr 0x$indexId > 0x1fff] } {
	#	Validation::ResetPromptFlag
	#	Operations::SingleClickNode $nodeSelect
	#	return
	#} else {
	#    
	#}

	
	#gets the nodeId and Type of selected node
	set result [Operations::GetNodeIdType $nodeSelect]
	if {$result != "" } {
		set nodeId [lindex $result 0]
		set nodeType [lindex $result 1]
	} else {
		#must be some other node this condition should never reach
		#puts "\n\NoteBookManager::DiscardValue->SHOULD NEVER HAPPEN 1!!\n\n"
		return
	}
	
	set nodePos [new_intp]
	puts "IfNodeExists nodeId->$nodeId nodeType->$nodeType nodePos->$nodePos"
	#IfNodeExists API is used to get the nodePosition which is needed fro various operation	
	#set catchErrCode [IfNodeExists $nodeId $nodeType $nodePos]

	set ExistfFlag [new_boolp]
	set catchErrCode [IfNodeExists $nodeId $nodeType $nodePos $ExistfFlag]
	set nodePos [intp_value $nodePos]
	set ExistfFlag [boolp_value $ExistfFlag]
	set ErrCode [ocfmRetCode_code_get $catchErrCode]
	#puts "ErrCode:$ErrCode"
	if { $ErrCode == 0 && $ExistfFlag == 1 } {
		#the node exist continue 
	} else {
		if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
			tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Warning -icon warning -parent .
		} else {
			tk_messageBox -message "Unknown Error" -title Warning -icon warning -parent .
                        puts "Unknown Error ->[ocfmRetCode_errorString_get $catchErrCode]"
		}
		return
	}

	if {[string match "*SubIndexValue*" $nodeSelect]} {
	    
	    	set indexPos [new_intp] 
		set subIndexPos [new_intp] 
		set catchErrCode [IfSubIndexExists $nodeId $nodeType $indexId $subIndexId $subIndexPos $indexPos]
		set indexPos [intp_value $indexPos] 
		set subIndexPos [intp_value $subIndexPos] 
	    
		#puts "GetSubIndexAttributes nodeId->$nodeId nodeType->$nodeType indexId->$indexId subIndexId->$subIndexId 0"
		set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 0 ]
		#set tempIndexProp [GetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId 0]
		set IndexName [lindex $tempIndexProp 1]
		
		set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 2 ]
		#set tempIndexProp [GetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId 2]
		set dataType [lindex $tempIndexProp 1]		
		
		set tempIndexProp [GetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId 4 ]
		set DefaultValue [lindex $tempIndexProp 1]
		
		set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 5 ]
		#set tempIndexProp [GetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId 5]
		set IndexActualValue [lindex $tempIndexProp 1]
		
		
	} else {
	    	set indexPos [new_intp] 
		#DllExport ocfmRetCode IfIndexExists(int NodeID, ENodeType NodeType, char* IndexID, int* IndexPos)
		set catchErrCode [IfIndexExists $nodeId $nodeType $indexId $indexPos] 
		set indexPos [intp_value $indexPos] 
	    
		#puts "GetIndexAttributes nodeId->$nodeId nodeType->$nodeType indexId->$indexId 0"
		set tempIndexProp [GetIndexAttributesbyPositions $nodePos $indexPos 0 ]
		#set tempIndexProp [GetIndexAttributes $nodeId $nodeType $indexId 0]
		set IndexName [lindex $tempIndexProp 1]
		
		set tempIndexProp [GetIndexAttributesbyPositions $nodePos $indexPos 2 ]
		#set tempIndexProp [GetIndexAttributes $nodeId $nodeType $indexId 2]
		set dataType [lindex $tempIndexProp 1]	
		
		set tempIndexProp [GetIndexAttributesbyPositions $nodePos $indexPos 4 ]
		set DefaultValue [lindex $tempIndexProp 1]
		#set IndexActualValue []
		
		set tempIndexProp [GetIndexAttributesbyPositions $nodePos $indexPos 5 ]
		#set tempIndexProp [GetIndexAttributes $nodeId $nodeType $indexId 5]
		set IndexActualValue [lindex $tempIndexProp 1]
		#set IndexActualValue []
		
		set tempIndexProp [GetIndexAttributesbyPositions $nodePos $indexPos 9 ]
		#set tempIndexProp [GetIndexAttributes $nodeId $nodeType $indexId 9]
		set cdc_gen  [lindex $tempIndexProp 1]
		
		#puts "cdc_gen->$cdc_gen"
		if { $cdc_gen == 1 } {
		    $frame0.frame1.ch_gen select
		} else {
		    $frame0.frame1.ch_gen deselect
		}
	}

	$frame0.en_nam1 configure -validate none
	$frame0.en_nam1 delete 0 end
	$frame0.en_nam1 insert 0 $IndexName
	$frame0.en_nam1 configure -validate key

	set state [$frame1.en_value1 cget -state]
	$frame1.en_value1 configure -validate none  -state normal
	$frame1.en_value1 delete 0 end
	$frame1.en_value1 insert 0 $IndexActualValue

	set defaultState [$frame1.en_default1 cget -state]
	$frame1.en_default1 configure -state normal
	$frame1.en_default1 delete 0 end
	$frame1.en_default1 insert 0 $DefaultValue
	$frame1.en_default1 configure -state $defaultState

	#puts "IndexName->$IndexName"
	#puts "IndexActualValue->$IndexActualValue"
	#after inserting value select appropriate radio button
	if { $dataType == "IP_ADDRESS" } {
		$frame1.en_value1 configure -validate key -vcmd "Validation::IsIP %P %V" 
	} elseif { $dataType == "MAC_ADDRESS" } {
		$frame1.en_value1 configure -validate key -vcmd "Validation::IsMAC %P %V"
	} elseif { $dataType == "Visible_String" } {
		$frame1.en_value1 configure -validate key -vcmd "Validation::IsValidStr %P" 
	} else {
	
		#if userPrefList is not changed it cumulates into other problems
	
		if {[string match -nocase "0x*" $IndexActualValue]} {
			set lastConv hex
			
			set schRes [lsearch $userPrefList [list $nodeSelect *]]
			if {$schRes  == -1} {
				lappend userPrefList [list $nodeSelect hex]
			} else {
			    set userPrefList [lreplace $userPrefList $schRes $schRes [list $nodeSelect hex] ]
			}
			
			if {[string match -nocase "0x*" $DefaultValue ]} {
				#default value is already in hexadecimal no need to convert
			} else {
				set defaultState [$frame1.en_default1 cget -state]
				$frame1.en_default1 configure -state normal
			
				NoteBookManager::InsertHex $frame1.en_default1
				
				$frame1.en_default1 configure -state $defaultState
			}
			$frame1.frame1.ra_hex select
			$frame1.en_value1 configure -validate key -vcmd "Validation::IsHex %P %s $frame1.en_value1 %d %i" 
		} else {
			set lastConv dec
			
			set schRes [lsearch $userPrefList [list $nodeSelect *]]
			if {$schRes  == -1} {
			    lappend userPrefList [list $nodeSelect dec]
			} else {
			    set userPrefList [lreplace $userPrefList $schRes $schRes [list $nodeSelect dec] ]
			}
			
			if {[string match -nocase "0x*" $DefaultValue]} {
				puts "CONVERT DEFAULT HEXADECIMAL VALUE TO decimal $DefaultValue"
				set defaultState [$frame1.en_default1 cget -state]
				$frame1.en_default1 configure -state normal
				
				NoteBookManager::InsertDecimal $frame1.en_default1
				
				$frame1.en_default1 configure -state $defaultState
			} else {
				#default value is already in decimal no need to convert
			}
			$frame1.frame1.ra_dec select
			$frame1.en_value1 configure -validate key -vcmd "Validation::IsDec %P $frame1.en_value1 %d %i" 
		}
	}
	
	$frame1.en_value1 configure -state $state
	Validation::ResetPromptFlag
	
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::StartEdit
# 
#  Arguments : tbl  - path of the tablelist widget
#	           row  - row of the edited cell
#			   col  - column of the edited cell
#			   text - entered value
#	   
#  Results : text - to be displayed in tablelist
#
#  Description : to validate the entered value
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::StartEdit {tablePath rowIndex columnIndex text} {
	set win [$tablePath editwinpath]
  	switch -- $columnIndex {
        	2 {	
		  $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 4 $tablePath $rowIndex $columnIndex $win"
        	}
        	3 {
		  $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 4 $tablePath $rowIndex $columnIndex $win"
        	}
        	4 {
		    $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 4 $tablePath $rowIndex $columnIndex $win"
        	}
       	 	5 {
		    $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 2 $tablePath $rowIndex $columnIndex $win"
        	}
    	}

	return $text
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::EndEdit
# 
#  Arguments : tbl  - path of the tablelist widget
#	           row  - row of the edited cell
#			   col  - column of the edited cell
#			   text - entered value
#	   
#  Results : text - to be displayed in tablelist
#
#  Description : to validate the entered value when focus leave the cell
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::EndEdit {tablePath rowIndex columnIndex text} {
	if { [string match -nocase "0x*" $text] } {
		set text [string range $text 2 end]
	} else {
		$tablePath rejectinput
	}
  	switch -- $columnIndex {
        	2 {
			if {[string length $text] != 4} {
				bell
				$tablePath rejectinput
				#return ""
			} else {
			}
        	}
	        3 {
			if {[string length $text] != 4} {
				bell
				$tablePath rejectinput
				#return ""
			} else {
			}
        	}
        	4 {
			if {[string length $text] != 4} {
				bell
				$tablePath rejectinput
				#return ""
			} else {
			}
        	}
        	5 {
			if {[string length $text] != 2} {
				bell
				$tablePath rejectinput
				#return ""
			} else {
			}
        	}
	}
	 return 0x$text
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::SaveTable
# 
#  Arguments : tableWid  - path of the tablelist widget
#	   
#  Results : -
#
#  Description : to validate and save the validated values in tablelist widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SaveTable {tableWid} {

	#-------------------------
	#	Global variables
	#-------------------------
	global nodeSelect
	global treePath
	global status_save
	#global chkPrompt
	global populatedPDOList
	
	#puts "nodeSelect->$nodeSelect"
	set result [$tableWid finishediting]
	if {$result == 0} {
		# value entered doesnt pass the -editendcommand of tablelist widget do not save value
		return 
	} else {
		#continue doing
	}
	#puts "\n\n\tNoteBookManager::SaveTable->tablelist is having valid value entered\n\n"
	# should save entered values to corresponding subindex
	set result [Operations::GetNodeIdType $nodeSelect]
	set nodeId [lindex $result 0]
	set nodeType [lindex $result 1]
	set rowCount 0
	#foreach childIndex [$treePath nodes $nodeSelect]
	set flag 0
	foreach childIndex $populatedPDOList {
	 	set indexId [string range [$treePath itemcget $childIndex -text] end-4 end-1]
		foreach childSubIndex [$treePath nodes $childIndex] {
			set subIndexId [string range [$treePath itemcget $childSubIndex -text] end-2 end-1]
			if {[string match "00" $subIndexId]} {
			} else {
				set name [string range [$treePath itemcget $childSubIndex -text] 0 end-6] 
				#set offset [NoteBookManager::AppendZero [string range [$tableWid cellcget $rowCount,2 -text] 2 end] 4]
				#set length [NoteBookManager::AppendZero [string range [$tableWid cellcget $rowCount,3 -text] 2 end] 4]
				#set reserved 00
				#set index [NoteBookManager::AppendZero [string range [$tableWid cellcget $rowCount,4 -text] 2 end] 4]
				#set subindex [NoteBookManager::AppendZero [string range [$tableWid cellcget $rowCount,5 -text] 2 end] 2]
				
				set offset [string range [$tableWid cellcget $rowCount,2 -text] 2 end] 
				set length [string range [$tableWid cellcget $rowCount,3 -text] 2 end] 
				set reserved 00
				set index [string range [$tableWid cellcget $rowCount,4 -text] 2 end] 
				set subindex [string range [$tableWid cellcget $rowCount,5 -text] 2 end]

				set value $length$offset$reserved$subindex$index
				
				#puts "tableWid cellcget $rowCount,1 -text ====>$value"
				#0x is appended when saving value to indicate it is a hexa decimal number
				#puts "SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId 0x$value $name"
				
				if { [string length $value] != 16 } {
					puts "NOT SAVED -> SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $name"
					set flag 1
					incr rowCount
					continue
				} else {
					set value 0x$value
				}
				puts "SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $name"
				SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $name
				incr rowCount
			}
		}
	}
	
	if { $flag == 1} {
	    DisplayInfo "\nValues which are not completely filled are not saved\n "
	}

	#PDO entries value is changed need to save 
	set status_save 1
	
	#set chkPrompt 0

	set populatedPDOList ""
	Validation::ResetPromptFlag


#	set size [$tableWid size] ; # SIZE GIVES NO OF ROWS
#	#puts size->$size
#	#puts "totala_row->[expr $size/[$tableWid columncount] ]"
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::DiscardTable
# 
#  Arguments : tableWid  - path of the tablelist widget
#	   
#  Results : -
#
#  Description : Discards the entered values and displays last saved values
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::DiscardTable {tableWid} {

	#-------------------------
	#	Global variables
	#-------------------------
	global nodeSelect

	Validation::ResetPromptFlag

	Operations::SingleClickNode $nodeSelect
	#$tableWid finishediting
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::GetComboValue
# 
#  Arguments : comboPath  - path of the Combobox widget
#	   
#  Results : selected value
#
#  Description : gets the selected index and returns the corresponding value
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::GetComboValue {comboPath} {
    set value [$comboPath get]
    if { $value == -1 } {
		#nothing was selected
		return []
    }
    set valueList [$comboPath cget -values]
    return [lindex $valueList $value]
    
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::SetComboValue
# 
#  Arguments : comboPath  - path of the Combobox widget
#	   
#  Results : selected value
#
#  Description : gets the selected index and returns the corresponding value
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SetComboValue {comboPath value} {
    set valueList [$comboPath cget -values]
    set selectedValue [lsearch -exact $valueList $value]
    if { $selectedValue == -1} {
	    set comboVar [$comboPath cget -textvariable]
	    global $comboVar
	    set $comboVar ""
	    $comboPath configure -state readonly
    } else {
	    $comboPath set [lindex $valueList $selectedValue]
    }
    
}