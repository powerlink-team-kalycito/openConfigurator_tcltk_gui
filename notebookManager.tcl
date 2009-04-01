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
#            tabInnerf0 - frame containing widgets describing the object (index id, Object name, subindex id )
#            tabInnerf1 - frame containing widgets describing properties of object	
#
#  Description : Creates the GUI for Index and subindex
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_tab { nbpath choice } {
    variable _pageCounter
    incr _pageCounter

    global tcl_platform
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

    entry $tabInnerf0.en_idx1 -state disabled -width 20
    entry $tabInnerf0.en_nam1 -width 20 -textvariable tmpNam$_pageCounter -relief ridge -justify center -bg white -width 30 -validate key -vcmd "Validation::IsValidStr %P"
    entry $tabInnerf1.en_obj1 -state disabled -width 20  
    entry $tabInnerf1.en_data1 -state disabled -width 20
    entry $tabInnerf1.en_access1 -state disabled -width 20
    entry $tabInnerf1.en_upper1 -state disabled -width 20 -validate key -vcmd "Validation::IsHex %P %s $tabInnerf1.en_upper1 %d %i"
    entry $tabInnerf1.en_lower1 -state disabled -width 20 -validate key -vcmd "Validation::IsHex %P %s $tabInnerf1.en_lower1 %d %i"
    entry $tabInnerf1.en_pdo1 -state disabled -width 20
    entry $tabInnerf1.en_default1 -state disabled -width 20
    entry $tabInnerf1.en_value1 -width 20 -textvariable tmpValue$_pageCounter  -relief ridge -justify center -bg white -validate key -vcmd "Validation::IsDec %P $tabInnerf1.en_value1 %d %i"
	    
    if {"$tcl_platform(platform)" == "windows"} {
        set comboWidth 17
    } else {
        set comboWidth 19
    }
	    	
    set objCoList [list DEFTYPE DEFSTRUCT VAR ARRAY RECORD]
    ttk::combobox $tabInnerf1.co_obj1 -values $objCoList -state readonly -textvariable co_obj -width $comboWidth
    set accessCoList [list const ro wr rw readWriteInput readWriteOutput noAccess]
    ttk::combobox $tabInnerf1.co_access1 -values $accessCoList -state readonly -textvariable co_access -width $comboWidth
    set pdoColist [list NO DEFAULT OPTIONAL RPDO TPDO]
    ttk::combobox $tabInnerf1.co_pdo1 -values $pdoColist -state readonly -textvariable co_pdo -width $comboWidth

    set frame1 [frame $tabInnerf1.frame1]
    set ra_dec [radiobutton $frame1.ra_dec -text "Dec" -variable ra_dataType -value dec -command "NoteBookManager::ConvertDec $tabInnerf1"]
    set ra_hex [radiobutton $frame1.ra_hex -text "Hex" -variable ra_dataType -value hex -command "NoteBookManager::ConvertHex $tabInnerf1"]

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
    grid remove $ra_dec
    grid remove $ra_hex
    if {$choice == "index"} {
        $tabTitlef0 configure -text "Index" 
        $tabTitlef1 configure -text "Properties" 
        grid config $tabInnerf0.la_idx -row 0 -column 0 -sticky w
        grid config $tabInnerf0.en_idx1 -row 0 -column 1 -sticky w -padx 0
        grid config $tabInnerf0.la_nam -row 2 -column 0 -sticky w 
        grid config $tabInnerf0.en_nam1 -row 2 -column 1  -sticky w -columnspan 1
        grid config $tabInnerf0_1 -row 4 -column 0 -columnspan 2 -sticky w
        grid config $tabInnerf0_1.la_generate -row 0 -column 0 -sticky w 
        grid config $tabInnerf0_1.ch_gen -row 0 -column 1 -sticky e -padx 5
        grid config $tabInnerf0.la_empty3 -row 5 -column 0 -columnspan 2
    } elseif { $choice == "subindex" } {
        $tabTitlef0 configure -text "Sub Index" 
        $tabTitlef1 configure -text "Properties" 

        label $tabInnerf0.la_sidx -text "Sub Index  "  
        entry $tabInnerf0.en_sidx1 -state disabled -width 20

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

    return [list $outerFrame $tabInnerf0 $tabInnerf1 $sf]
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::create_table
# 
#  Arguments : nbpath  - frame path to create
#              choice  - choice for pdo to create frame
#
#  Results : basic frame on which all widgets are created
#	         tablelist widget path
#
#  Description : Creates the tablelist for TPDO and RPDO
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_table {nbpath choice} {
    variable _pageCounter
    incr _pageCounter

    global tableSaveBtn

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
#              tabname - title for the created tab
#              choice  - choice to create Information, Error and Warning windows
#
#  Results : path of the inserted frame in notebook
#
#  Description : Creates displaying Information, Error and Warning messages windows
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_infoWindow {nbpath tabname choice} {
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
    entry $treeFrame.en_find -textvariable FindSpace::txtFindDym -width 10 -background white -validate key -vcmd "FindSpace::Find %P"
    button $treeFrame.bt_next -text " Next " -command "FindSpace::Next" -image [Bitmap::get right] -relief flat
    button $treeFrame.bt_prev -text " Prev " -command "FindSpace::Prev" -image [Bitmap::get left] -relief flat
    grid config $treeFrame.en_find -row 0 -column 0 -sticky ew
    grid config $treeFrame.bt_prev -row 0 -column 1 -sticky s -padx 5
    grid config $treeFrame.bt_next -row 0 -column 2 -sticky s

    return [list $frmPath $treeBrowser]
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::ConvertDec
# 
#  Arguments : framePath - path of the frame containing value and default entry widget 
#
#  Results : -
#
#  Description : converts value into decimal and changes validation for entry
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::ConvertDec {framePath} {
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

        set state [$framePath.en_value1 cget -state]
        $framePath.en_value1 configure -validate none -state normal
        NoteBookManager::InsertDecimal $framePath.en_value1
        $framePath.en_value1 configure -validate key -vcmd "Validation::IsDec %P $framePath.en_value1 %d %i" -state $state

        set state [$framePath.en_default1 cget -state]
        $framePath.en_default1 configure -state normal
        NoteBookManager::InsertDecimal $framePath.en_default1
        $framePath.en_default1 configure -state $state	
    } else {
        #already dec is selected
    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::InsertDecimal
# 
#  Arguments : entryPath - path of the entry widget 
#
#  Results : -
#
#  Description : Convert the value into decimal and insert into the entry widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::InsertDecimal {entryPath} {
    set entryValue [$entryPath get]
    if { [string match -nocase "0x*" $entryValue] } {
    	set entryValue [string range $entryValue 2 end]
    }
   
    if { $entryValue == 0 } {
        # value is zero 
        $entryPath delete 0 end
        $entryPath insert 0 $entryValue
    } elseif { $entryValue != "" } {
        #counting the leading zero if they are present
        set zeroCount [NoteBookManager::CountLeadZero $entryValue]
        if { [ catch {set entryValue [expr 0x$entryValue]} ] } {
            #error raised should not convert
        } else {
            #appending trimmed leading zero if any
            set entryValue [ NoteBookManager::AppendZero $entryValue [expr $zeroCount+[string length $entryValue] ] ] 
            $entryPath delete 0 end
            $entryPath insert 0 $entryValue
        }
    } else {
        #value is empty clear previous data
        $entryPath delete 0 end
    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::ConvertHex
# 
#  Arguments : framePath - path containing the value and default entry widget 
#
#  Results : -
#
#  Description : converts the value to hexadecimal and changes validation for entry
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::ConvertHex {framePath} {
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

        set state [$framePath.en_value1 cget -state]
        $framePath.en_value1 configure -validate none -state normal
        NoteBookManager::InsertHex $framePath.en_value1
        $framePath.en_value1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath.en_value1 %d %i" -state $state

        set state [$framePath.en_default1 cget -state]
        $framePath.en_default1 configure -state normal
        NoteBookManager::InsertHex $framePath.en_default1
        $framePath.en_default1 configure -state $state
    } else {
        #already hex is selected
    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::InsertHex
# 
#  Arguments : entryPath - path of the entry widget 
#
#  Results : -
#
#  Description : Convert the value into hexadecimal and insert into the entry widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::InsertHex {entryPath} {
    set entryValue [$entryPath get]
    if { $entryValue != "" } {
        $entryPath delete 0 end
        set entryValue [Validation::InputToHex $entryValue]
        $entryPath insert 0 $entryValue
    } else {
        $entryPath delete 0 end
        set entryValue 0x
        $entryPath insert 0 $entryValue
    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::AppendZero
# 
#  Arguments : input     - string to be append with zero
#              reqLength - length upto zero needs to be appended
#  Results : -
#
#  Description : Append zeros into the input until the required length is reached
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::AppendZero {input reqLength} {
    while {[string length $input] < $reqLength} {
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
            #continue with next check
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
#              frame1 - frame containing the widgets describing properties of object	
#	   
#  Results :  - 
#
#  Description : save the entered value for index and subindex
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SaveValue {frame0 frame1} {
    global nodeSelect
    global nodeIdList
    global treePath
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
    } elseif {[string match "*IndexValue*" $nodeSelect]} {
        set indexId [string range $oldName end-4 end-1 ]
        set indexId [string toupper $indexId]
        set oldName [string range $oldName end-7 end ]
    } else {
        return
    }

    #gets the nodeId and Type of selected node
    set result [Operations::GetNodeIdType $nodeSelect]
    if {$result != "" } {
	    set nodeId [lindex $result 0]
        set nodeType [lindex $result 1]
    } else {
            #must be some other node this condition should never reach
            return
    }
	
    set tmpVar0 [$frame0.en_nam1 cget -textvariable]
    global $tmpVar0
    set newName [subst $[subst $tmpVar0]]
    if { $newName == "" } {
        set newName []
    }
    set state [$frame1.en_value1 cget -state]
    $frame1.en_value1 configure -state normal
    set tmpVar1 [$frame1.en_value1 cget -textvariable]
    global $tmpVar1	
    set value [string toupper [subst $[subst $tmpVar1]] ]
	
    if { [expr 0x$indexId > 0x1fff] } {
        set dataType [$frame1.en_data1 get]
        set accessType [$frame1.co_access1 get]
        set objectType [$frame1.co_obj1 get]
        set pdoType [$frame1.co_pdo1 get]
        set upperLimit [$frame1.en_upper1 get]
        set lowerLimit [$frame1.en_lower1 get]
        set default [$frame1.en_default1 get]
    } else {
        set radioSel [$frame1.frame1.ra_dec cget -variable]
        global $radioSel
        set radioSel [subst $[subst $radioSel]]
        $frame1.en_data1 configure -state normal
        set dataType [$frame1.en_data1 get]
        $frame1.en_data1 configure -state disabled
        if {$value != ""} {
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
                #it is hex value trim leading 0x
                set value [string range $value 2 end]
                set value [string toupper $value]
                if { $value == "" } {
                    set value []
                } else {
                    set value 0x$value
                }
            } elseif { $radioSel == "dec" } {
                #is is dec value convert to hex
                set value [Validation::InputToHex $value]
                if { $value == "" } {
                    set value []
                } else {
                    #0x is appended to represent it as hex
                    set value [string range $value 2 end]
                    set value [string toupper $value]
                    set value 0x$value
                }
            } else {
                #invalid condition
            }
        } else {
            #no value has been inputed by user
            set value []
        }
    }
    if { $value == "" || $dataType == ""  } {
        #no need to check
    } else {
        foreach stdDataType [list Integer8 Unsigned8 Integer16 Unsigned16 Integer32 Unsigned32 Integer24 Unsigned24 Integer40 Unsigned40 \
                             Integer48 Unsigned48 Integer56 Unsigned56 Integer64 Unsigned64 ] {
            puts "string match -nocase $stdDataType $dataType ->[string match -nocase $stdDataType $dataType]"
            if { [string match -nocase $stdDataType $dataType] } {
                #matched to a datatype in list and value is non empty
                switch -- $stdDataType {
                    Integer8 {
                        set decLimit 127
                        set hexLimit 0x7F
                    }
                    Unsigned8 {
                        set decLimit 255
                        set hexLimit 0xFF
                        
                    }
                    Integer16 {
                        set decLimit 32767
                        set hexLimit 0x7FFF
                    }
                    Unsigned16 {
                        set decLimit 65535
                        set hexLimit 0xFFFF
                    }
                    Integer32 {
                        set decLimit 2147483647
                        set hexLimit 0x7FFFFFFF
                    }
                    Unsigned32 {
                        set decLimit 4294967295
                        set hexLimit 0xFFFFFFFF
                    }
                    Integer24 {
                        set decLimit 8388607
                        set hexLimit 0x7FFFFF
                    }
                    Unsigned24 {
                        set decLimit 16777215
                        set hexLimit 0xFFFFFF
                    }
                    Integer40 {
                        set decLimit 549755813887
                        set hexLimit 0x7FFFFFFFFF
                    }
                    Unsigned40 {
                        set decLimit 1099511627775
                        set hexLimit 0xFFFFFFFFFF
                    }
                    Integer48 {
                        set decLimit 140737488355327
                        set hexLimit 0x7FFFFFFFFFFF
                    }
                    Unsigned48 {
                        set decLimit 281474976710655
                        set hexLimit 0xFFFFFFFFFFFF
                    }
                    Integer56 {
                        set decLimit 36028797018963967
                        set hexLimit 0x7FFFFFFFFFFFFF
                    }
                    Unsigned56 {
                        set decLimit 72057594037927935
                        set hexLimit 0xFFFFFFFFFFFFFF
                    }
                    Integer64 {
                        set decLimit 9223372036854775807
                        set hexLimit 0x7FFFFFFFFFFFFFFF
                    }
                    Unsigned64 {
                        set decLimit 18446744073709551615
                        set hexLimit 0xFFFFFFFFFFFFFFFF
                    }
                }
                
                if { [string match -nocase "0x*" $value] } {
                    set checkno [ Validation::CheckHexaNumber [string range $value 2 end] ]
                    set msg "Not a valid Hexadecimal number"
                    set maxlimit $hexLimit
                    set minlimit 0x0
                } else {
                    set checkno [ Validation::CheckDecimalNumber $value ]
                    set msg "Not a valid Decimal number"
                    set maxlimit $decLimit
                     set minlimit 0
                }
                if { $checkno == 0 } {
                    tk_messageBox -message $msg -parent .
                    Validation::ResetPromptFlag
                    return
                }
                if { [expr $value > $maxlimit] || [expr $value < $minlimit] } {
                    #out of range
                    tk_messageBox -message "value out of range for $dataType\n Should be in range $minlimit to $maxlimit" -parent .
                    Validation::ResetPromptFlag
                    return
                }
                break
            } else {
                #continue to check till end of value
            }
        }
        
    }
    if {[string match "*SubIndexValue*" $nodeSelect]} {
        if { [expr 0x$indexId > 0x1fff] } {
            set catchErrCode [SetALLSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $newName $accessType $dataType $pdoType $default $upperLimit $lowerLimit $objectType 0]
        } else {
            if { [string match -nocase "18??" $indexId] || [string match "14??" $indexId]} {
                if { [string match "01" $subIndexId] } {
                    if { $value == "" || [expr $value > 0xef] || [expr $value < 0x0] } {
                        tk_messageBox -message "Value should be between 0x0 to 0xEF\nFor subindex 01 in index $indexId\nEdited values not saved" -title Warning -icon warning -parent .
                        Validation::ResetPromptFlag
	             		return
                    }
                }
            }

            if { [string match -nocase "1A??" $indexId] || [string match "16??" $indexId]} {
                if { ![string match "00" $subIndexId] } {
                    if { $value == "" || [string length $value] != 18 } {
                        tk_messageBox -message "Value should be a 16 digit hexadecimal\nFor subindex $subIndexId in index $indexId\nEdited values not saved" -title Warning -icon warning -parent .
                        Validation::ResetPromptFlag
		             	return
                    }
                }
            }
            set catchErrCode [SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $newName]
        }
    } elseif {[string match "*IndexValue*" $nodeSelect]} {
        set chkGen [$frame0.frame1.ch_gen cget -variable]
        global $chkGen
        if { [expr 0x$indexId > 0x1fff] } {
            set catchErrCode [SetALLIndexAttributes $nodeId $nodeType $indexId $value $newName $accessType $dataType $pdoType $default $upperLimit $lowerLimit $objectType [subst $[subst $chkGen]] ]
        } else {
            set catchErrCode [SetIndexAttributes $nodeId $nodeType $indexId $value $newName [subst $[subst $chkGen]] ]
        }
    } else {
        #invalid condition
        return
    }
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode != 0 } {
        if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
            tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .
        } else {
            tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
        }
        Validation::ResetPromptFlag
        return
    }

    #value for Index or SubIndex is edited need to change
    set status_save 1
    Validation::ResetPromptFlag	
    set newName [append newName $oldName]
    $treePath itemconfigure $nodeSelect -text $newName
    lappend savedValueList $nodeSelect
    $frame0.en_nam1 configure -bg #fdfdd4
    $frame1.en_value1 configure -bg #fdfdd4
    $frame1.en_value1 configure -state $state
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
    global nodeSelect
    global nodeIdList
    global treePath
    global userPrefList
    global lastConv

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
    #gets the nodeId and Type of selected node
    set result [Operations::GetNodeIdType $nodeSelect]
    if {$result != "" } {
        set nodeId [lindex $result 0]
        set nodeType [lindex $result 1]
    } else {
        return
    }

    set nodePos [new_intp]
    set ExistfFlag [new_boolp]
    set catchErrCode [IfNodeExists $nodeId $nodeType $nodePos $ExistfFlag]
    set nodePos [intp_value $nodePos]
    set ExistfFlag [boolp_value $ExistfFlag]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode == 0 && $ExistfFlag == 1 } {
        #the node exist continue 
    } else {
        if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
            tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .
        } else {
            tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
        }
        return
    }

    if {[string match "*SubIndexValue*" $nodeSelect]} {
        set indexPos [new_intp] 
        set subIndexPos [new_intp] 
        set catchErrCode [IfSubIndexExists $nodeId $nodeType $indexId $subIndexId $subIndexPos $indexPos]
        set indexPos [intp_value $indexPos] 
        set subIndexPos [intp_value $subIndexPos] 
        set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 0 ]
        set IndexName [lindex $tempIndexProp 1]
        set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 2 ]
        set dataType [lindex $tempIndexProp 1]		
        set tempIndexProp [GetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId 4 ]
        set DefaultValue [lindex $tempIndexProp 1]
        set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 5 ]
        set IndexActualValue [lindex $tempIndexProp 1]
    } else {
        set indexPos [new_intp] 
        set catchErrCode [IfIndexExists $nodeId $nodeType $indexId $indexPos] 
        set indexPos [intp_value $indexPos] 
        set tempIndexProp [GetIndexAttributesbyPositions $nodePos $indexPos 0 ]
        set IndexName [lindex $tempIndexProp 1]
        set tempIndexProp [GetIndexAttributesbyPositions $nodePos $indexPos 2 ]
        set dataType [lindex $tempIndexProp 1]	
        set tempIndexProp [GetIndexAttributesbyPositions $nodePos $indexPos 4 ]
        set DefaultValue [lindex $tempIndexProp 1]
        set tempIndexProp [GetIndexAttributesbyPositions $nodePos $indexPos 5 ]
        set IndexActualValue [lindex $tempIndexProp 1]
        set tempIndexProp [GetIndexAttributesbyPositions $nodePos $indexPos 9 ]
        set cdc_gen  [lindex $tempIndexProp 1]
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
                #convert default hexadecimal to decimal 
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
#  Arguments : tablePath   - path of the tablelist widget
#	           rowIndex    - row of the edited cell
#			   columnIndex - column of the edited cell
#			   text        - entered value
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
#  Arguments : tablePath   - path of the tablelist widget
#	           rowIndex    - row of the edited cell
#			   columnIndex - column of the edited cell
#			   text        - entered value
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
                } else {
                }
            }
            3 {
                if {[string length $text] != 4} {
                    bell
                    $tablePath rejectinput
                } else {
                }
            }
            4 {
                if {[string length $text] != 4} {
                    bell
                    $tablePath rejectinput
                } else {
                }
            }
            5 {
                if {[string length $text] != 2} {
	                bell
                    $tablePath rejectinput
                } else {
                }
            }
    }
    return 0x$text
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::SaveTable
# 
#  Arguments : tableWid - path of the tablelist widget
#	   
#  Results : -
#
#  Description : to validate and save the validated values in tablelist widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SaveTable {tableWid} {
    global nodeSelect
    global treePath
    global status_save
    global populatedPDOList

    set result [$tableWid finishediting]
    if {$result == 0} {
        return 
    } else {
    }
    # should save entered values to corresponding subindex
    set result [Operations::GetNodeIdType $nodeSelect]
    set nodeId [lindex $result 0]
    set nodeType [lindex $result 1]
    set rowCount 0
    set flag 0
	foreach childIndex $populatedPDOList {
        set indexId [string range [$treePath itemcget $childIndex -text] end-4 end-1]
        foreach childSubIndex [$treePath nodes $childIndex] {
            set subIndexId [string range [$treePath itemcget $childSubIndex -text] end-2 end-1]
            if {[string match "00" $subIndexId]} {
            } else {
                set name [string range [$treePath itemcget $childSubIndex -text] 0 end-6] 
                set offset [string range [$tableWid cellcget $rowCount,2 -text] 2 end] 
                set length [string range [$tableWid cellcget $rowCount,3 -text] 2 end] 
                set reserved 00
                set index [string range [$tableWid cellcget $rowCount,4 -text] 2 end] 
                set subindex [string range [$tableWid cellcget $rowCount,5 -text] 2 end]
                set value $length$offset$reserved$subindex$index
                #0x is appended when saving value to indicate it is a hexa decimal number
                if { [string length $value] != 16 } {
                    set flag 1
                    incr rowCount
                    continue
                } else {
                    set value 0x$value
                }
                SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $name
                incr rowCount
            }
        }
    }

    if { $flag == 1} {
        DisplayInfo "Values which completely filled are (Offset, Length, Index and Sub Index) only saved"
    }

    #PDO entries value is changed need to save 
    set status_save 1
    set populatedPDOList ""
    Validation::ResetPromptFlag
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

    global nodeSelect

    Validation::ResetPromptFlag

    Operations::SingleClickNode $nodeSelect
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::GetComboValue
# 
#  Arguments : comboPath - path of the Combobox widget
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
#              value      - value to set into the Combobox widget
#	   
#  Results : selected value
#
#  Description : gets the selected value and sets the value into the Combobox widget
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