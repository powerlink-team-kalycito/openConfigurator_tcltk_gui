####################################################################################################
#
#
#  NAME:     notebookManager.tcl
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
    global co_data

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
    label $tabInnerf0_1.la_generate -text ""
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
    entry $tabInnerf1.en_upper1 -state disabled -width 20
    bind $tabInnerf1.en_upper1 <FocusOut> "NoteBookManager::LimitFocusChanged $tabInnerf1 $tabInnerf1.en_upper1"
    entry $tabInnerf1.en_lower1 -state disabled -width 20
    bind $tabInnerf1.en_lower1 <FocusOut> "NoteBookManager::LimitFocusChanged $tabInnerf1 $tabInnerf1.en_lower1"
    entry $tabInnerf1.en_pdo1 -state disabled -width 20
    entry $tabInnerf1.en_default1 -state disabled -width 20
    entry $tabInnerf1.en_value1 -width 20 -textvariable tmpValue$_pageCounter  -relief ridge -bg white
    bind $tabInnerf1.en_value1 <FocusOut> "NoteBookManager::ValueFocusChanged $tabInnerf1 $tabInnerf1.en_value1"
	    
    if {"$tcl_platform(platform)" == "windows"} {
        set comboWidth 17
    } else {
        set comboWidth 18
    }
	    	
    set dataCoList [list BIT BOOLEAN INTEGER8 INTEGER16 INTEGER24 INTEGER32 INTEGER40 INTEGER48 INTEGER56 INTEGER64 \
                    UNSIGNED8 UNSIGNED16 UNSIGNED24 UNSIGNED32 UNSIGNED40 UNSIGNED48 UNSIGNED56 UNSIGNED64 REAL32 REAL64 MAC_ADDRESS IP_ADDRESS OCTET_STRING]
    ComboBox $tabInnerf1.co_data1 -values $dataCoList -editable no -textvariable co_data -width $comboWidth
    set objCoList [list DEFTYPE DEFSTRUCT VAR ARRAY RECORD]
    ComboBox $tabInnerf1.co_obj1 -values $objCoList -editable no -textvariable co_obj -modifycmd "NoteBookManager::ChangeValidation $tabInnerf0 $tabInnerf1 $tabInnerf1.co_obj1" -width $comboWidth 
    set accessCoList [list const ro wo rw]
    ComboBox $tabInnerf1.co_access1 -values $accessCoList -editable no -textvariable co_access -modifycmd "NoteBookManager::ChangeValidation $tabInnerf0 $tabInnerf1 $tabInnerf1.co_access1" -width $comboWidth
    set pdoColist [list NO DEFAULT OPTIONAL RPDO TPDO]
    ComboBox $tabInnerf1.co_pdo1 -values $pdoColist -editable no -textvariable co_pdo -modifycmd "NoteBookManager::ChangeValidation $tabInnerf0 $tabInnerf1  $tabInnerf1.co_pdo1" -width $comboWidth

    set frame1 [frame $tabInnerf1.frame1]
    set ra_dec [radiobutton $frame1.ra_dec -text "Dec" -variable ra_dataType -value dec -command "NoteBookManager::ConvertDec $tabInnerf0 $tabInnerf1"]
    set ra_hex [radiobutton $frame1.ra_hex -text "Hex" -variable ra_dataType -value hex -command "NoteBookManager::ConvertHex $tabInnerf0 $tabInnerf1"]

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
    grid config $tabInnerf1.co_data1 -row 0 -column 1 -padx 5 
    grid remove $tabInnerf1.co_data1    
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
        bind $tabInnerf0_1.la_generate <1> "$tabInnerf0_1.ch_gen toggle ; Validation::SetPromptFlag"
        $tabInnerf0_1.la_generate configure -text "Include Index in CDC generation"
    } elseif { $choice == "subindex" } {
        $tabTitlef0 configure -text "Sub Index" 
        $tabTitlef1 configure -text "Properties" 

        label $tabInnerf0.la_sidx -text "Sub Index  "  
        entry $tabInnerf0.en_sidx1 -state disabled -width 20

        grid config $tabInnerf0.la_sidx -row 2 -column 0 -sticky w 
        grid config $tabInnerf0.en_sidx1 -row 2 -column 1 -padx 5
        grid config $tabInnerf0.la_nam -row 2 -column 2 -sticky w 
        grid config $tabInnerf0.en_nam1 -row 2 -column 3  -sticky e -columnspan 1
        
        grid config $tabInnerf0_1 -row 4 -column 0 -columnspan 2 -sticky w
        grid config $tabInnerf0_1.la_generate -row 0 -column 0 -sticky w 
        grid config $tabInnerf0_1.ch_gen -row 0 -column 1 -sticky e -padx 5
        grid config $tabInnerf0.la_empty3 -row 5 -column 0 -columnspan 2
        bind $tabInnerf0_1.la_generate <1> "$tabInnerf0_1.ch_gen toggle ; Validation::SetPromptFlag"
        $tabInnerf0_1.la_generate configure -text "Include Subindex in CDC generation"
    }

    set fram [frame $frame.f1]  
    label $fram.la_empty -text "  " -height 1
    if { $choice == "index" } {
        set indexSaveBtn [ button $fram.bt_sav -text " Save " -width 8 ]
    } elseif { $choice == "subindex" } {
        set subindexSaveBtn [ button $fram.bt_sav -text " Save " -width 8 ]
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
#  NoteBookManager::create_nodeFrame
# 
#  Arguments : nbpath  - frame path to create
#              choice  - choice for pdo to create frame
#
#  Results : basic frame on which all widgets are created
#	         tablelist widget path
#
#  Description : Creates the tablelist for TPDO and RPDO
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_nodeFrame {nbpath choice} {
    variable _pageCounter
    incr _pageCounter
    
    global ra_statType$_pageCounter
    global ra_nodeDataType
    global tmpNodeName$_pageCounter
    global tmpNodeNo$_pageCounter
    global tmpNodeTime$_pageCounter
    global mnPropSaveBtn
    global cnPropSaveBtn
    global tcl_platform
    global co_cnNodeList$_pageCounter
    global ch_advanced
    global spCycleNoList$_pageCounter
    
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
    set tabTitlef0 [TitleFrame $uf.tabTitlef0 -text "Properties" ]
    set tabInnerf0 [$tabTitlef0 getframe]
    #$tabInnerf0 configure -width 150
    set tabTitlef1 [TitleFrame $tabInnerf0.tabTitlef1 -text "" ]
    set tabInnerf1 [$tabTitlef1 getframe]
    set tabInnerf0_1 [frame $tabInnerf0.frame1 ]
    set cycleFrame [frame $tabInnerf0.cycleframe ]
	
    label $tabInnerf0.la_nodeName     -text "Node name"
    label $tabInnerf0.la_empty1       -text ""
    label $tabInnerf0.la_align1	      -text ""
    label $tabInnerf0.la_align2	      -text ""
    label $tabInnerf0.la_nodeNo       -text "Node number"
    label $tabInnerf0.la_empty2       -text ""
    label $tabInnerf0.la_time         -text ""
    label $tabInnerf0.cycleframe.la_ms           -text "µs"
    label $tabInnerf0.la_empty3       -text ""
    label $tabInnerf1.la_advOption1   -text ""
    label $tabInnerf1.la_advOptionUnit1   -text ""
    label $tabInnerf1.la_empty4       -text ""
    label $tabInnerf1.la_advOption2   -text ""
    label $tabInnerf1.la_advOptionUnit2   -text ""
    label $tabInnerf1.la_empty5       -text ""
    label $tabInnerf1.la_advOption3   -text ""
    label $tabInnerf1.la_advOptionUnit3   -text ""
    label $tabInnerf1.la_empty6       -text ""
    label $tabInnerf1.la_seperat1     -text ""
    label $tabInnerf1.la_empty7       -text ""
    label $tabInnerf1.la_advOption4   -text ""
    label $tabInnerf1.la_empty8       -text ""
    label $tabInnerf1.la_advOptionUnit4 -text ""
    
    entry $tabInnerf0.en_nodeName -width 20 -textvariable tmpNodeName$_pageCounter -relief ridge -justify center -bg white -validate key -vcmd "Validation::IsValidStr %P"
    entry $tabInnerf0.en_nodeNo   -width 20 -textvariable tmpNodeNo$_pageCounter -relief ridge -justify center -bg white 
    entry $tabInnerf0.cycleframe.en_time     -width 20 -textvariable tmpNodeTime$_pageCounter -relief ridge -justify center -bg white  
    entry $tabInnerf1.en_advOption1 -state disabled -width 20
    entry $tabInnerf1.en_advOption2 -state disabled -width 20
    entry $tabInnerf1.en_advOption3 -state disabled -width 20
    entry $tabInnerf1.en_advOption4 -state disabled -width 20

    set frame1 [frame $tabInnerf0.formatframe1]
    #set ra_dec [radiobutton $frame1.ra_dec -text "Dec" -variable ra_nodeDataType -value "dec" -command ""]
    #set ra_hex [radiobutton $frame1.ra_hex -text "Hex" -variable ra_nodeDataType -value "hex" -command ""]
    set ra_StNormal [radiobutton $tabInnerf1.ra_StNormal -text "Normal station"      -variable ra_statType$_pageCounter -value "StNormal" ]
    set ra_StMulti  [radiobutton $tabInnerf1.ra_StMulti  -text "Multiplexed station" -variable ra_statType$_pageCounter -value "StMulti" ]
    set ra_StChain  [radiobutton $tabInnerf1.ra_StChain  -text "Chained station"     -variable ra_statType$_pageCounter -value "StChain" ]

    grid config $tabTitlef0 -row 0 -column 0 -sticky ew -ipady 7 ;# -ipadx 10
    #label $uf.la_empty -text ""
    #grid config $uf.la_empty -row 1 -column 0
    #grid config $tabTitlef1 -row 2 -column 0 -sticky ew

    grid config $tabInnerf0.la_align1    -row 0 -column 0 -padx 5
    grid config $tabInnerf0.la_nodeNo    -row 2 -column 1 -sticky w
    grid config $tabInnerf0.en_nodeNo    -row 2 -column 2 -sticky w -padx 5
    grid config $tabInnerf0.la_align2    -row 0 -column 3 -padx 170
    grid config $tabInnerf0.la_empty1    -row 1 -column 1
    grid config $tabInnerf0.la_nodeName  -row 0 -column 1 -sticky w
    grid config $tabInnerf0.en_nodeName  -row 0 -column 2 -sticky w -padx 5
    grid config $tabInnerf0.la_empty2    -row 3 -column 1
    grid config $tabInnerf0.la_time      -row 4 -column 1 -sticky w
	grid config $tabInnerf0.cycleframe   -row 4 -column 2 -columnspan 2 -sticky w
    grid config $tabInnerf0.cycleframe.en_time      -row 0 -column 0 -sticky w -padx 5
	grid config $tabInnerf0.cycleframe.la_ms      -row 0 -column 1 -sticky w
    grid config $tabInnerf0.la_empty3    -row 5 -column 1
    grid config $frame1                  -row 6 -column 2 -padx 5 
    
    #grid config $ra_dec -row 0 -column 0 -sticky w
    #grid config $ra_hex -row 0 -column 1 -sticky w

    
    if { $choice == "mn" } {
        $tabInnerf0.la_time  configure -text "Cycle Time"
	
        $tabInnerf0.tabTitlef1 configure -text "Advanced" 
        $tabInnerf0.en_nodeNo configure -state disabled
	$tabInnerf1.la_advOption4 configure  -text "Loss of SoC Tolerance"
	$tabInnerf1.la_advOptionUnit4 configure -text "µs"
        $tabInnerf1.la_advOption1 configure -text "Asynchronous MTU size"
        $tabInnerf1.la_advOptionUnit1 configure -text "Byte"
        $tabInnerf1.la_advOption2 configure -text "Asynchronous Timeout"
        $tabInnerf1.la_advOptionUnit2 configure -text "ns"
        $tabInnerf1.la_advOption3 configure -text "Multiplexing prescaler"
	
	grid config $tabInnerf1.la_advOption4 -row 0 -column 1 -sticky w
	grid config $tabInnerf1.en_advOption4 -row 0 -column 2 -padx 5
	grid config $tabInnerf1.la_advOptionUnit4 -row 0 -column 3 -sticky w
        grid config $tabInnerf1.la_empty8     -row 1 -column 1
        grid config $tabInnerf1.la_advOption1 -row 2 -column 1 -sticky w
        grid config $tabInnerf1.en_advOption1 -row 2 -column 2 -padx 5
        grid config $tabInnerf1.la_advOptionUnit1 -row 2 -column 3 -sticky w
        grid config $tabInnerf1.la_empty4     -row 3 -column 1
        grid config $tabInnerf1.la_advOption2 -row 4 -column 1 -sticky w
        grid config $tabInnerf1.en_advOption2 -row 4 -column 2 -padx 5
        grid config $tabInnerf1.la_advOptionUnit2 -row 4 -column 3 -sticky w
        grid config $tabInnerf1.la_empty5     -row 5 -column 1
        grid config $tabInnerf1.la_advOption3 -row 6 -column 1 -sticky w
        grid config $tabInnerf1.en_advOption3 -row 6 -column 2 -padx 5
        grid config $tabInnerf1.la_advOptionUnit3 -row 6 -column 3 -sticky w
        grid config $tabInnerf1.la_empty6     -row 7 -column 1
	
        #$ra_dec configure -command "NoteBookManager::ConvertMNDec $tabInnerf0 $tabInnerf1"
        #$ra_hex configure -command "NoteBookManager::ConvertMNHex $tabInnerf0 $tabInnerf1"
    } elseif { $choice == "cn" } {
        if {"$tcl_platform(platform)" == "windows"} {
            set spinWidth 19
        } else {
            set spinWidth 19
        }
        set cnNodeList [NoteBookManager::GenerateCnNodeList]
        spinbox $tabInnerf0.sp_nodeNo -state normal -textvariable co_cnNodeList$_pageCounter \
            -validate key -vcmd "Validation::CheckCnNodeNumber %P" -bg white \
            -from 1 -to 239 -increment 1 -justify center -width $spinWidth
        
        grid forget $tabInnerf0.en_nodeNo
        grid config $tabInnerf0.sp_nodeNo    -row 2 -column 2 -sticky w -padx 5
        $tabInnerf0.la_time  configure -text "PollResponse Timeout"
        #1#grid config $tabInnerf0.la_ms      -row 4 -column 3 -sticky w
        $tabInnerf0.tabTitlef1 configure -text "Type of station" 
	
        set tabTitlef2 [TitleFrame $tabInnerf1.tabTitlef2 -text "Advanced" ]
        set tabInnerf2 [$tabTitlef2 getframe]
        set ch_adv [checkbutton $tabInnerf2.ch_adv -onvalue 1 -offvalue 0 -command "NoteBookManager::forceCycleChecked $tabInnerf2 ch_advanced" -variable ch_advanced -text "Force Cycle"]
        spinbox $tabInnerf2.sp_cycleNo -state normal -textvariable spCycleNoList$_pageCounter \
            -bg white -width $spinWidth \
            -from 1 -to 239 -increment 1 -justify center
        
        grid config $ra_StNormal          -row 0 -column 0 -sticky w -padx 5
        grid config $tabInnerf1.la_empty4 -row 1 -column 0
        grid config $ra_StChain           -row 2 -column 0 -sticky w -padx 5
        grid config $tabInnerf1.la_empty5 -row 3 -column 0
        grid config $ra_StMulti           -row 4 -column 0 -sticky w -padx 5
        #grid config $tabInnerf1.la_empty6 -row 5 -column 0 -columnspan 2
        grid config $tabTitlef2           -row 5 -column 0 -sticky e -columnspan 2 -padx 20;# -ipadx 10
        grid config $tabInnerf1.la_empty7 -row 7 -column 0
        
        grid config $ch_adv                -row 0 -column 0
        grid config $tabInnerf2.sp_cycleNo -row 0 -column 1 
        
	#$ra_dec configure -command "NoteBookManager::ConvertCNDec $tabInnerf0 $tabInnerf1"
    #    $ra_hex configure -command "NoteBookManager::ConvertCNHex $tabInnerf0 $tabInnerf1"
        $ra_StNormal configure -command "NoteBookManager::StationRadioChanged $tabInnerf2 StNormal"
        $ra_StMulti configure -command "NoteBookManager::StationRadioChanged $tabInnerf2 StMulti"
        $ra_StChain configure -command "NoteBookManager::StationRadioChanged $tabInnerf2 StChain"
    }
    grid config $tabTitlef1 -row 8 -column 1 -columnspan 2 -sticky ew
    
    set fram [frame $frame.f1]  
    label $fram.la_empty -text "  " -height 1
    if { $choice == "mn" } {
        set mnPropSaveBtn [ button $fram.bt_sav -text " Save " -width 8 -command ""]
        set resultList [list $outerFrame $tabInnerf0 $tabInnerf1 $sf ]
    } elseif { $choice == "cn" } {
        set cnPropSaveBtn [ button $fram.bt_sav -text " Save " -width 8 -command ""]
        set resultList [list $outerFrame $tabInnerf0 $tabInnerf1 $sf $tabInnerf2]
    }
    label $fram.la_empty1 -text "  "
    button $fram.bt_dis -text "Discard" -width 8 -command "NoteBookManager::DiscardValue $tabInnerf0 $tabInnerf1"
    grid config $fram.la_empty -row 0 -column 0 -columnspan 2
    grid config $fram.bt_sav -row 1 -column 0 -sticky s
    grid config $fram.la_empty1 -row 1 -column 1 -sticky s
    grid config $fram.bt_dis -row 1 -column 2 -sticky s
    pack $fram -side bottom
    
    return $resultList
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
        set infoWindow [Console::InitInfoWindow $scrollWin]
        set window $infoWindow
        lappend infoWindow $nbpath $nbname
        $nbpath itemconfigure $nbname -image [Bitmap::get file]
    } elseif {$choice == 2} {
        set errWindow [Console::InitErrorWindow $scrollWin]
        set window $errWindow
        lappend errWindow $nbpath $nbname
        $nbpath itemconfigure $nbname -image [Bitmap::get error_small]
    } elseif {$choice == 3} {    
        set warWindow [Console::InitWarnWindow $scrollWin]
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
    set frmPath [$nbpath insert end $nbname -text "Network Browser"]

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
proc NoteBookManager::ConvertDec {framePath0 framePath1} {
    global lastConv
    global userPrefList
    global nodeSelect
    global UPPER_LIMIT
    global LOWER_LIMIT
    
    if { $lastConv != "dec"} {
        set lastConv dec
        set schRes [lsearch $userPrefList [list $nodeSelect *]]
        if {$schRes  == -1} {
            lappend userPrefList [list $nodeSelect dec]
        } else {
            set userPrefList [lreplace $userPrefList $schRes $schRes [list $nodeSelect dec] ]
        }
        $framePath0.en_idx1 configure -state normal
        set indexId [string range [$framePath0.en_idx1 get] 2 end]
        $framePath0.en_idx1 configure -state disabled
        if { [expr 0x$indexId <= 0x1fff] } {
            $framePath1.en_data1 configure -state normal
            set dataType [$framePath1.en_data1 get]
            $framePath1.en_data1 configure -state disabled
        } else {
            set state [$framePath1.co_data1 cget -state]
            $framePath1.co_data1 configure -state normal
            set dataType [NoteBookManager::GetComboValue $framePath1.co_data1]
            $framePath1.co_data1 configure -state $state
        }

        set state [$framePath1.en_value1 cget -state]
        $framePath1.en_value1 configure -validate none -state normal
        NoteBookManager::InsertDecimal $framePath1.en_value1 $dataType
        $framePath1.en_value1 configure -validate key -vcmd "Validation::IsDec %P $framePath1.en_value1 %d %i $dataType" -state $state

        set state [$framePath1.en_default1 cget -state]
        $framePath1.en_default1 configure -validate none -state normal
        NoteBookManager::InsertDecimal $framePath1.en_default1 $dataType
        $framePath1.en_default1 configure -validate key -vcmd "Validation::IsDec %P $framePath1.en_default1 %d %i $dataType" -state $state
	
        set state [$framePath1.en_lower1 cget -state]
        $framePath1.en_lower1 configure -validate none -state normal
        NoteBookManager::InsertDecimal $framePath1.en_lower1 $dataType
        set LOWER_LIMIT [$framePath1.en_lower1 get]
        $framePath1.en_lower1 configure -validate key -vcmd "Validation::IsDec %P $framePath1.en_lower1 %d %i $dataType" -state $state
        
        set state [$framePath1.en_upper1 cget -state]
        $framePath1.en_upper1 configure -validate none -state normal
        NoteBookManager::InsertDecimal $framePath1.en_upper1 $dataType
        set UPPER_LIMIT [$framePath1.en_upper1 get]
        $framePath1.en_upper1 configure -validate key -vcmd "Validation::IsDec %P $framePath1.en_upper1 %d %i $dataType" -state $state
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
proc NoteBookManager::InsertDecimal {entryPath dataType} {
    set entryValue [$entryPath get]
    if { [string match -nocase "0x*" $entryValue] } {
    	set entryValue [string range $entryValue 2 end]
    }
   
    $entryPath delete 0 end
    set entryValue [lindex [Validation::InputToDec $entryValue $dataType] 0]
    $entryPath insert 0 $entryValue
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
proc NoteBookManager::ConvertHex {framePath0 framePath1} {
    global lastConv
    global userPrefList
    global nodeSelect
    global UPPER_LIMIT
    global LOWER_LIMIT
    
    if { $lastConv != "hex"} {
        set lastConv hex
        set schRes [lsearch $userPrefList [list $nodeSelect *]]
        if {$schRes  == -1} {
            lappend userPrefList [list $nodeSelect hex]
        } else {
           set userPrefList [lreplace $userPrefList $schRes $schRes [list $nodeSelect hex] ]
        }
        $framePath0.en_idx1 configure -state normal
        set indexId [string range [$framePath0.en_idx1 get] 2 end]
        $framePath0.en_idx1 configure -state disabled
        if { [expr 0x$indexId <= 0x1fff] } {
            $framePath1.en_data1 configure -state normal
            set dataType [$framePath1.en_data1 get]
            $framePath1.en_data1 configure -state disabled
        } else {
            set state [$framePath1.co_data1 cget -state]
            $framePath1.co_data1 configure -state normal
            set dataType [NoteBookManager::GetComboValue $framePath1.co_data1]
            $framePath1.co_data1 configure -state $state
        }
        set state [$framePath1.en_value1 cget -state]
        $framePath1.en_value1 configure -validate none -state normal
        NoteBookManager::InsertHex $framePath1.en_value1 $dataType
        $framePath1.en_value1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath1.en_value1 %d %i $dataType" -state $state

        set state [$framePath1.en_default1 cget -state]
        $framePath1.en_default1 configure -validate none -state normal
        NoteBookManager::InsertHex $framePath1.en_default1 $dataType
        $framePath1.en_default1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath1.en_default1 %d %i $dataType" -state $state

        set state [$framePath1.en_lower1 cget -state]
        $framePath1.en_lower1 configure -validate none -state normal
        NoteBookManager::InsertHex $framePath1.en_lower1 $dataType
        set LOWER_LIMIT [$framePath1.en_lower1 get]
        $framePath1.en_lower1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath1.en_lower1 %d %i $dataType" -state $state
        
        set state [$framePath1.en_upper1 cget -state]
        $framePath1.en_upper1 configure -validate none -state normal
        NoteBookManager::InsertHex $framePath1.en_upper1 $dataType
        set UPPER_LIMIT [$framePath1.en_upper1 get]
        $framePath1.en_upper1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath1.en_upper1 %d %i $dataType" -state $state
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
proc NoteBookManager::InsertHex {entryPath dataType} {
    set entryValue [$entryPath get]
    if { $entryValue != "" } {
        $entryPath delete 0 end
        set entryValue [lindex [Validation::InputToHex $entryValue $dataType] 0]
        $entryPath insert 0 $entryValue
    } else {
        $entryPath delete 0 end
        #commented to remove insertion of 0x
        #set entryValue 0x
        $entryPath insert 0 $entryValue
    }
}

##---------------------------------------------------------------------------------------------------
##  NoteBookManager::ConvertMNDec
## 
##  Arguments : framePath0 - path of the frame containing value and default entry widget 
##
##  Results : -
##
##  Description : converts value into decimal and changes validation for entry
##---------------------------------------------------------------------------------------------------
#proc NoteBookManager::ConvertMNDec {framePath0 framePath1} {
#    global lastConv
#    global userPrefList
#    global nodeSelect
#    global MNDatalist
#
#    if { $lastConv != "dec"} {
#        set lastConv dec
#        set schRes [lsearch $userPrefList [list $nodeSelect *]]
#        if {$schRes  == -1} {
#            lappend userPrefList [list $nodeSelect dec]
#        } else {
#            set userPrefList [lreplace $userPrefList $schRes $schRes [list $nodeSelect dec] ]
#        }
#        
#        set schDataRes [lsearch $MNDatalist [list cycleTimeDatatype *]]
#        if {$schDataRes  != -1 } {
#            set dataType [lindex [lindex $MNDatalist $schDataRes] 1]
#            set state [$framePath0.en_time cget -state]
#            $framePath0.en_time configure -validate none -state normal
#            NoteBookManager::InsertDecimal $framePath0.en_time $dataType
#            $framePath0.en_time configure -validate key -vcmd "Validation::IsDec %P $framePath0.en_time %d %i $dataType" -state $state
#        }
#
#        set schDataRes [lsearch $MNDatalist [list asynMTUSizeDatatype *]]
#        if {$schDataRes  != -1 } {
#            set dataType [lindex [lindex $MNDatalist $schDataRes] 1]
#            set state [$framePath1.en_advOption1 cget -state]
#            $framePath1.en_advOption1 configure -validate none -state normal
#            NoteBookManager::InsertDecimal $framePath1.en_advOption1 $dataType
#            $framePath1.en_advOption1 configure -validate key -vcmd "Validation::IsDec %P $framePath1.en_advOption1 %d %i $dataType" -state $state
#        }
#        
#        set schDataRes [lsearch $MNDatalist [list asynTimeoutDatatype *]]
#        if {$schDataRes  != -1 } {
#            set dataType [lindex [lindex $MNDatalist $schDataRes] 1]
#            set state [$framePath1.en_advOption2 cget -state]
#            $framePath1.en_advOption2 configure -validate none -state normal
#            NoteBookManager::InsertDecimal $framePath1.en_advOption2 $dataType
#            $framePath1.en_advOption2 configure -validate key -vcmd "Validation::IsDec %P $framePath1.en_advOption2 %d %i $dataType" -state $state
#        }
#
#        set schDataRes [lsearch $MNDatalist [list multiPrescalerDatatype *]]
#        if {$schDataRes  != -1 } {
#            set dataType [lindex [lindex $MNDatalist $schDataRes] 1]
#            set state [$framePath1.en_advOption3 cget -state]
#            $framePath1.en_advOption3 configure -validate none -state normal
#            NoteBookManager::InsertDecimal $framePath1.en_advOption3 $dataType
#            $framePath1.en_advOption3 configure -validate key -vcmd "Validation::IsDec %P $framePath1.en_advOption3 %d %i $dataType" -state $state
#        }
#    } else {
#        #already dec is selected
#    }
#}
#
##---------------------------------------------------------------------------------------------------
##  NoteBookManager::ConvertMNHex
## 
##  Arguments : framePath - path containing the value and default entry widget 
##
##  Results : -
##
##  Description : converts the value to hexadecimal and changes validation for entry
##---------------------------------------------------------------------------------------------------
#proc NoteBookManager::ConvertMNHex {framePath0 framePath1} {
#    global lastConv
#    global userPrefList
#    global nodeSelect
#    global MNDatalist
#
#    if { $lastConv != "hex"} {
#        set lastConv hex
#        set schRes [lsearch $userPrefList [list $nodeSelect *]]
#        if {$schRes  == -1} {
#            lappend userPrefList [list $nodeSelect hex]
#        } else {
#           set userPrefList [lreplace $userPrefList $schRes $schRes [list $nodeSelect hex] ]
#        }
#
#        set schDataRes [lsearch $MNDatalist [list cycleTimeDatatype *]]
#        if {$schDataRes  != -1 } {
#            set dataType [lindex [lindex $MNDatalist $schDataRes] 1]
#            set state [$framePath0.en_time cget -state]
#            $framePath0.en_time configure -validate none -state normal
#            NoteBookManager::InsertHex $framePath0.en_time $dataType
#            $framePath0.en_time configure -validate key -vcmd "Validation::IsHex %P %s $framePath0.en_time %d %i $dataType" -state $state
#        }
#
#        set schDataRes [lsearch $MNDatalist [list asynMTUSizeDatatype *]]
#        if {$schDataRes  != -1 } {
#            set dataType [lindex [lindex $MNDatalist $schDataRes] 1]
#            set state [$framePath1.en_advOption1 cget -state]
#            $framePath1.en_advOption1 configure -validate none -state normal
#            NoteBookManager::InsertHex $framePath1.en_advOption1 $dataType
#            $framePath1.en_advOption1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath1.en_advOption1 %d %i $dataType" -state $state
#        }
#        
#        set schDataRes [lsearch $MNDatalist [list asynTimeoutDatatype *]]
#        if {$schDataRes  != -1 } {
#            set dataType [lindex [lindex $MNDatalist $schDataRes] 1]
#            set state [$framePath1.en_advOption2 cget -state]
#            $framePath1.en_advOption2 configure -validate none -state normal
#            NoteBookManager::InsertHex $framePath1.en_advOption2 $dataType
#            $framePath1.en_advOption2 configure -validate key -vcmd "Validation::IsHex %P %s $framePath1.en_advOption2 %d %i $dataType" -state $state
#        }
#
#        set schDataRes [lsearch $MNDatalist [list multiPrescalerDatatype *]]
#        if {$schDataRes  != -1 } {
#            set dataType [lindex [lindex $MNDatalist $schDataRes] 1]
#            set state [$framePath1.en_advOption3 cget -state]
#            $framePath1.en_advOption3 configure -validate none -state normal
#            NoteBookManager::InsertHex $framePath1.en_advOption3 $dataType
#            $framePath1.en_advOption3 configure -validate key -vcmd "Validation::IsHex %P %s $framePath1.en_advOption3 %d %i $dataType" -state $state
#        }
#    } else {
#        #already hex is selected
#    }
#}
#
##---------------------------------------------------------------------------------------------------
##  NoteBookManager::ConvertCNDec
## 
##  Arguments : framePath0 - path of the frame containing value and default entry widget 
##
##  Results : -
##
##  Description : converts value into decimal and changes validation for entry
##---------------------------------------------------------------------------------------------------
#proc NoteBookManager::ConvertCNDec {framePath0 framePath1} {
#    global lastConv
#    global userPrefList
#    global nodeSelect
#    global CNDatalist
#
#    if { $lastConv != "dec"} {
#        set lastConv dec
#        set schRes [lsearch $userPrefList [list $nodeSelect *]]
#        if {$schRes  == -1} {
#            lappend userPrefList [list $nodeSelect dec]
#        } else {
#            set userPrefList [lreplace $userPrefList $schRes $schRes [list $nodeSelect dec] ]
#        }
#        
#        set schDataRes [lsearch $CNDatalist [list presponseCycleTimeDatatype *]]
#        if {$schDataRes  != -1 } {
#            set dataType [lindex [lindex $CNDatalist $schDataRes] 1]
#            set state [$framePath0.en_time cget -state]
#            $framePath0.en_time configure -validate none -state normal
#            NoteBookManager::InsertDecimal $framePath0.en_time $dataType
#            $framePath0.en_time configure -validate key -vcmd "Validation::IsDec %P $framePath0.en_time %d %i $dataType" -state $state
#        }
#    } else {
#        #already dec is selected
#    }
#}
#
##---------------------------------------------------------------------------------------------------
##  NoteBookManager::ConvertCNHex
## 
##  Arguments : framePath - path containing the value and default entry widget 
##
##  Results : -
##
##  Description : converts the value to hexadecimal and changes validation for entry
##---------------------------------------------------------------------------------------------------
#proc NoteBookManager::ConvertCNHex {framePath0 framePath1} {
#    global lastConv
#    global userPrefList
#    global nodeSelect
#    global CNDatalist
#
#    if { $lastConv != "hex"} {
#        set lastConv hex
#        set schRes [lsearch $userPrefList [list $nodeSelect *]]
#        if {$schRes  == -1} {
#            lappend userPrefList [list $nodeSelect hex]
#        } else {
#           set userPrefList [lreplace $userPrefList $schRes $schRes [list $nodeSelect hex] ]
#        }
#
#        set schDataRes [lsearch $CNDatalist [list presponseCycleTimeDatatype *]]
#        if {$schDataRes  != -1 } {
#            set dataType [lindex [lindex $CNDatalist $schDataRes] 1]
#            set state [$framePath0.en_time cget -state]
#            $framePath0.en_time configure -validate none -state normal
#            NoteBookManager::InsertHex $framePath0.en_time $dataType
#            $framePath0.en_time configure -validate key -vcmd "Validation::IsHex %P %s $framePath0.en_time %d %i $dataType" -state $state
#        }
#    } else {
#        #already hex is selected
#    }
#}

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
proc NoteBookManager::SaveValue { frame0 frame1 {objectType ""} } {
    global nodeSelect
    global nodeIdList
    global treePath
    global savedValueList 
    global userPrefList
    global lastConv
    global status_save
    global LOWER_LIMIT
    global UPPER_LIMIT
    
    #reloadView will call the Opertions::Singleclicknode so as when for index
    #2000 and above is saved the datatype validation will take effect
    set reloadView 0
    #rebuildNode WrapperInteractions::RebuildNode for 2000 and above index if
    #the datatype is set as ARRAY or RECORD subindex 00 will automatically
    #added rebuild that node alone
    set rebuildNode 0
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
        #set newName []
        tk_messageBox -message "Name field is empty\nValues not saved" -parent .
        Validation::ResetPromptFlag
        return
    }
    
    if { [expr 0x$indexId > 0x1fff] } {
	set lastFocus [focus]
	if { $lastFocus == "$frame1.en_lower1" || $lastFocus == "$frame1.en_upper1" } {
	    #event generate $lastFocus <FocusOut> 
	    #this is the function binded to both the upper limit and lower limit entry boxes
	    NoteBookManager::LimitFocusChanged $frame1 $lastFocus
	}
	
    }
    
    set state [$frame1.en_value1 cget -state]
    $frame1.en_value1 configure -state normal
    set tmpVar1 [$frame1.en_value1 cget -textvariable]
    global $tmpVar1	
    set value [string toupper [subst $[subst $tmpVar1]] ]
    $frame1.en_value1 configure -state $state
    
    if { [expr 0x$indexId > 0x1fff] } {
        set objectType [NoteBookManager::GetComboValue $frame1.co_obj1]
        if { $objectType == "" } {
            tk_messageBox -message "ObjectType not selected\nValues not saved" -title Warning -icon warning -parent .
            Validation::ResetPromptFlag
            return
        }
    }
    
    if { [expr 0x$indexId > 0x1fff] && ( $objectType == "VAR" ) } {
        set dataType [NoteBookManager::GetComboValue $frame1.co_data1]
        set accessType [NoteBookManager::GetComboValue $frame1.co_access1]
        #the objecct type also can be changed
        set objectType [NoteBookManager::GetComboValue $frame1.co_obj1]
        set pdoType [NoteBookManager::GetComboValue $frame1.co_pdo1]
        set upperLimit [$frame1.en_upper1 get]
        set lowerLimit [$frame1.en_lower1 get]
        if {[string match -nocase "INTEGER*" $dataType] || [string match -nocase "UNSIGNED*" $dataType] || [string match -nocase "BOOLEAN" $dataType] || [string match -nocase "REAL*" $dataType]} {
            if {[string match -nocase "0x" $upperLimit]} {
                set upperLimit [] 
            }
            if {[string match -nocase "0x" $lowerLimit]} {
                set lowerLimit []
            }
        }
        set default [NoteBookManager::GetEntryValue $frame1.en_default1]
    } elseif {[expr 0x$indexId > 0x1fff] } {
        if { $objectType == "ARRAY" } {
            set dataType [NoteBookManager::GetComboValue $frame1.co_data1]
        } else {
            set dataType [NoteBookManager::GetEntryValue $frame1.en_data1]
        }
        set pdoType [NoteBookManager::GetEntryValue $frame1.en_pdo1]
        set upperLimit [NoteBookManager::GetEntryValue $frame1.en_upper1]
        set lowerLimit [NoteBookManager::GetEntryValue $frame1.en_lower1]
        set default [NoteBookManager::GetEntryValue $frame1.en_default1]
        if {[string match -nocase "INTEGER*" $dataType] || [string match -nocase "UNSIGNED*" $dataType] || [string match -nocase "BOOLEAN" $dataType] || [string match -nocase "REAL*" $dataType]} {
            if {[string match -nocase "0x" $upperLimit]} {
                set upperLimit [] 
            }
            if {[string match -nocase "0x" $lowerLimit]} {
                set lowerLimit []
            }
        }
        
        set accessType [NoteBookManager::GetEntryValue $frame1.en_access1]
    } else {
        #objects less than 2000 only need name and value access type needed for validation
        set accessType [NoteBookManager::GetEntryValue $frame1.en_access1]
        set dataType [NoteBookManager::GetEntryValue $frame1.en_data1]
    }
    
    #if { [info exists lowerLimit] } {
    #    if { $lowerLimit != "-" } {
    #        set LOWER_LIMIT $lowerLimit
    #    }
    #}
    #if { [info exists upperLimit] } {
    #    if { $upperLimit != "-" } {
    #        set UPPER_LIMIT $upperLimit
    #    }
    #}
    set tempValidateValue $value
    
    if { [string match -nocase "INTEGER*" $dataType] || [string match -nocase "UNSIGNED*" $dataType] || [string match -nocase "BOOLEAN" $dataType ] } {
        #need to convert
        set radioSel [$frame1.frame1.ra_dec cget -variable]
        global $radioSel
        set radioSel [subst $[subst $radioSel]]
        if {$value != ""} {
            if { $radioSel == "hex" } {
                #it is hex value trim leading 0x
                if {[string match -nocase "0x*" $value]} {
                    set value [string range $value 2 end]
                }
                set value [string toupper $value]
                if { $value == "" } {
                    set value ""
                } else {
                    set value 0x$value
                }
            } elseif { $radioSel == "dec" } {
                #is is dec value convert to hex
                set value [lindex [Validation::InputToHex $value $dataType] 0]
                if { $value == "" } {
                    set value ""
                } else {
                    #0x is appended to represent it as hex
                    set value [string range $value 2 end]
                    set value [string toupper $value]
                    set value 0x$value
                }
            } else {
                #invalid condition
            }
        }
    } elseif { [string match -nocase "BIT" $dataType] } {
        if {$value != ""} {
            #convert value to hex and save
            set value 0x[Validation::BintoHex $value]
        }
        #continue
    } elseif { [string match -nocase "REAL*" $dataType] } {
        if { [string match -nocase "0x" $value] } {
            set value ""
        } else {
            #continue    
        }
    } elseif { $dataType == "IP_ADDRESS" } {
        set result [$frame1.en_value1 validate]
        if {$result == 0} {
            tk_messageBox -message "IP address not complete\nValues not saved" -title Warning -icon warning -parent .
            Validation::ResetPromptFlag
            return
        }
    } elseif { $dataType == "MAC_ADDRESS" } {
        set result [$frame1.en_value1 validate]
        if {$result == 0} {
            tk_messageBox -message "MAC address not complete\nValues not saved" -title Warning -icon warning -parent .
            Validation::ResetPromptFlag
            return
        }
    } elseif { [string match -nocase "Visible_String" $dataType] } {
        #continue
    } elseif { [string match -nocase "Octet_String" $dataType] } {
        #continue
		set value [subst $[subst $tmpVar1]]
    }
    if { $value == "" || $dataType == "" || $value == "-" } {
        #no need to check
        if { ($dataType == "") && ([expr 0x$indexId > 0x1fff]) && ( ($objectType == "ARRAY") || ($objectType == "VAR") ) } {
            #for objects less than 1fff and objects greater than 1fff with object type other than
            # ARRAY or VAR, datatype is not editable so allow user to save
            tk_messageBox -message "Datatype not selected\nValues not saved" -title Warning -icon warning -parent .
            Validation::ResetPromptFlag
            return
        }
        if { $value == "-" } {
            tk_messageBox -message "\"-\" cannot be saved for value" -title Warning -icon warning -parent .
            Validation::ResetPromptFlag
            return
        }
    } else {
        #value and datatype is not empty continue
        
    }
    if {[expr 0x$indexId > 0x1fff] } {
	set limitResult [Validation::validateValueandLimit $tempValidateValue $lowerLimit $upperLimit]
	if { [lindex $limitResult 0] == 0 } {
	    Console::DisplayWarning "[lindex $limitResult 1].\nValues not saved"
	    tk_messageBox -message "[lindex $limitResult 1].\nValues not saved" -title Warning -icon warning -parent .
	    Validation::ResetPromptFlag
	    return
	}
    }
    set chkGen [$frame0.frame1.ch_gen cget -variable]
    global $chkGen
    
    if {[string match "*SubIndexValue*" $nodeSelect]} {
        #if { ([expr 0x$indexId > 0x1fff]) && ( ($objectType == "ARRAY") || ($objectType == "VAR") ) } {}
        if { ([expr 0x$indexId > 0x1fff]) } {
            set catchErrCode [SetAllSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $newName $accessType $dataType $pdoType $default $upperLimit $lowerLimit $objectType [subst $[subst $chkGen]] ]
            set reloadView 1
        } else {
            if { [string match -nocase "18??" $indexId] || [string match "14??" $indexId]} {
                if { [string match "01" $subIndexId] } {
                    if { $value == "" || [expr $value > 0xfe] || [expr $value < 0x0] } {
                        tk_messageBox -message "Value should be in range 0x0 to 0xFE\nFor subindex 01 in index $indexId\nValues not saved" -title Warning -icon warning -parent .
                        Validation::ResetPromptFlag
	             		return
                    }
                }
            }

            if { [string match -nocase "1A??" $indexId] || [string match "16??" $indexId]} {
                if { ![string match "00" $subIndexId] } {
                    if { $value == "" || [string length $value] != 18 } {
                        tk_messageBox -message "Value should be a 16 digit hexadecimal\nFor subindex $subIndexId in index $indexId\nValues not saved" -title Warning -icon warning -parent .
                        Validation::ResetPromptFlag
		             	return
                    }
                }
            }
            #if { ($objectType == "ARRAY") || ($objectType == "VAR") } {
            #    set catchErrCode [SetAllSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $newName $accessType $dataType $pdoType $default $upperLimit $lowerLimit $objectType [subst $[subst $chkGen]] ]
            #} else {
                set catchErrCode [SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $newName [subst $[subst $chkGen]] ]
            #}
        }
    } elseif {[string match "*IndexValue*" $nodeSelect]} {
        
        #if { [expr 0x$indexId > 0x1fff] && (($objectType == "ARRAY") || ($objectType == "VAR")) } {}
        if { [expr 0x$indexId > 0x1fff] } {
            # if the index is greater than 1fff and the object type is not ARRAY or RECORD the delete all subobjects if present
            #puts "llength $treePath nodes $nodeSelect ------>[llength [$treePath nodes $nodeSelect] ]" 
            if { [expr 0x$indexId > 0x1fff] && (($objectType != "ARRAY") && ($objectType != "RECORD")) && ([llength [$treePath nodes $nodeSelect] ] > 0) } {
                #puts "entered index save checking indexId->$indexId objectType->$objectType nodeSelect->$nodeSelect"
                set result [tk_messageBox -message "Only the Object Type ARRAY or RECORD can have subindexes.\nThe subindexes of [string toupper $indexId] will be deleted.\nDo you want to continue?" -type okcancel -icon question -title "Question" -parent .]
                switch -- $result {
        		    ok {
                        #continue
        		    }
        		    cancel {
                        Validation::ResetPromptFlag
        			    return
        		    }
        	    }
                #delete the subindex
                foreach sidxTreeNode [$treePath nodes $nodeSelect] {
                    #puts "sidxTreeNode->$sidxTreeNode"
                    set sidx [string range [$treePath itemcget $sidxTreeNode -text] end-2 end-1 ]
                    set catchErrCode [DeleteSubIndex $nodeId $nodeType $indexId $sidx]
                    #need to check the result
                    set ErrCode [ocfmRetCode_code_get $catchErrCode]
                    if { $ErrCode != 0 } {
                        if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
                            set msg "[ocfmRetCode_errorString_get $catchErrCode]"
                        } else {
                            set msg "Unknown Error"
                        }
                        append msg "\nIndex $indexId not saved"
                        tk_messageBox -message "$msg" -title Error -icon error -parent .
                        return
                    }
                    catch {$treePath delete $sidxTreeNode}
                }
            }
            set catchErrCode [SetAllIndexAttributes $nodeId $nodeType $indexId $value $newName $accessType $dataType $pdoType $default $upperLimit $lowerLimit $objectType [subst $[subst $chkGen]] ]
            set reloadView 1
            if { ([string match -nocase "ARRAY" $objectType] == 1) || ([string match -nocase "RECORD" $objectType] == 1) } {
                set rebuildNode 1
            }
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
    if { [lsearch $savedValueList $nodeSelect] == -1 } {
        lappend savedValueList $nodeSelect
    }
    $frame0.en_nam1 configure -bg #fdfdd4
    $frame1.en_value1 configure -bg #fdfdd4
    #rebuild the node if index is saved as VAR since 00 will be added
    if { $rebuildNode == 1 } {
        WrapperInteractions::RebuildNode $nodeSelect
    }
    #reload the view after saving
    if { $reloadView == 1 } {
        Operations::SingleClickNode $nodeSelect
    }
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


    set userPrefList [Operations::DeleteList $userPrefList $nodeSelect 1]
    Validation::ResetPromptFlag
    Operations::SingleClickNode $nodeSelect
    return
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::SaveMNValue
# 
#  Arguments : frame0 - frame containing the widgets describing the object (index id, Object name, subindex id )
#              frame1 - frame containing the widgets describing properties of object	
#	   
#  Results :  - 
#
#  Description : save the entered value for MN property window
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SaveMNValue {nodePos frame0 frame1} {
    global nodeSelect
    global nodeIdList
    global treePath
    global savedValueList 
    global userPrefList
    global lastConv
    global status_save
    global MNDatalist
    

    #gets the nodeId and Type of selected node
    set result [Operations::GetNodeIdType $nodeSelect]
    if {$result != "" } {
        set nodeId [lindex $result 0]
        set nodeType [lindex $result 1]
    } else {
            #must be some other node this condition should never reach
			Validation::ResetPromptFlag
            return
    }
	
    set newNodeName [$frame0.en_nodeName get]
    set stationType 0
    set catchErrCode [UpdateNodeParams $nodeId $nodeId $nodeType $newNodeName $stationType "" 0 ""]
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
    set status_save 1
    #reconfiguring the tree
    $treePath itemconfigure $nodeSelect -text "$newNodeName\($nodeId\)"
    
    #set radioSel [$frame0.formatframe1.ra_dec cget -variable]
    #global $radioSel
    #set radioSel [subst $[subst $radioSel]]
    
    set MNDatatypeObjectPathList [list \
        [list cycleTimeDatatype $Operations::CYCLE_TIME_OBJ $frame0.cycleframe.en_time] \
	[list lossSoCToleranceDatatype $Operations::LOSS_SOC_TOLERANCE $frame1.en_advOption4] \
        [list asynMTUSizeDatatype $Operations::ASYNC_MTU_SIZE_OBJ $frame1.en_advOption1] \
        [list asynTimeoutDatatype $Operations::ASYNC_TIMEOUT_OBJ $frame1.en_advOption2] \
        [list multiPrescalerDatatype $Operations::MULTI_PRESCAL_OBJ $frame1.en_advOption3] ]
    
    set dispMsg 0
    foreach tempDatatype $MNDatalist {
        set schDataRes [lsearch $MNDatatypeObjectPathList [list [lindex $tempDatatype 0] * *]]
        if {$schDataRes  != -1 } {
            set dataType [lindex $tempDatatype 1]
            set entryPath [lindex [lindex $MNDatatypeObjectPathList $schDataRes] 2]
            
            # if entry is disabled no need to save it
            set entryState [$entryPath cget -state]
            if { $entryState != "normal" } {
                continue
            }
            
            set objectList [lindex [lindex $MNDatatypeObjectPathList $schDataRes] 1]
            set value [$entryPath get]
            set result [Validation::CheckDatatypeValue $entryPath $dataType "dec" $value]
            if { [lindex $result 0] == "pass" } {
                #get the flag and name of the object
                set validValue [lindex $result 1]
                if {$validValue == ""} {
                    #value is empty do not save it
                    set dispMsg 1
                    continue
                }

		if { [ lindex $tempDatatype 0 ] == "lossSoCToleranceDatatype" } {
		    if { [ catch { set validValue [expr $validValue * 1000] } ] } {
			#error in conversion
			continue
		    }
		}
                set reqFieldResult [Operations::GetObjectValueData $nodePos $nodeId $nodeType [list 0 9] [lindex $objectList 0] [lindex $objectList 1] ]
                if { [lindex $reqFieldResult 0] == "pass" } {
                    set objName [lindex $reqFieldResult 1]
                    set objFlag [lindex $reqFieldResult 2]
                    #check whether the object is index or subindex
                    if { [lindex $objectList 1] == "" } {
                        # it is an index
                        set saveCmd "SetIndexAttributes $nodeId $nodeType [lindex $objectList 0] $validValue $objName $objFlag"
                    } else {
                        #it is a subindex
                        set saveCmd "SetSubIndexAttributes $nodeId $nodeType [lindex $objectList 0] [lindex $objectList 1] $validValue $objName $objFlag"
                    }
                    #save the value
                    set catchErrCode [eval $saveCmd]
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
                    #value for MN porpety is edited need to change
                    set status_save 1
                    Validation::ResetPromptFlag
                    #$entryPath configure -bg #fdfdd4
                } else {
                    continue
                }
            } else {
                continue
            }
        }
    }
    if { $dispMsg == 1 } {
        Console::DisplayWarning "Empty values in MN properties are not saved"
    }
	Validation::ResetPromptFlag
    #if { [lsearch $savedValueList $nodeSelect] == -1 } {
    #    lappend savedValueList $nodeSelect
    #}
    #$frame0.en_nodeName configure -bg #fdfdd4
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::SaveCNValue
# 
#  Arguments : frame0 - frame containing the widgets describing the object (index id, Object name, subindex id )
#              frame1 - frame containing the widgets describing properties of object	
#	   
#  Results :  - 
#
#  Description : save the entered value for MN property window
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SaveCNValue {nodePos nodeId nodeType frame0 frame1 frame2 {multiPrescalDatatype ""}} {
    global nodeSelect
    global nodeIdList
    global treePath
    global savedValueList 
    global userPrefList
    global lastConv
    global status_save
    global CNDatalist
    global cnPropSaveBtn

    	
    #save node name and node number
    set newNodeId [$frame0.sp_nodeNo get]
    set newNodeId [string trim $newNodeId]
    if {  ( $newNodeId == "" ) || ( ( [string is int $newNodeId] == 1 ) && ( [expr $newNodeId <= 0] ) && ( [expr $newNodeId <= 239] ) ) } {
        tk_messageBox -message "CN node should be in range 1 to 239" -title Warning -icon warning -parent .
        Validation::ResetPromptFlag
        return
    }
    # check whether the node is changed or not
    if { $nodeId != $newNodeId } {
        #chec k that the node id is not an existing node id
        set schDataRes [lsearch $nodeIdList $newNodeId]
        if { $schDataRes != -1 } {
            tk_messageBox -message "The node number \"$newNodeId\" already exists" -title Warning -icon warning -parent .
            Validation::ResetPromptFlag
            return
        }
    }
    
    #validate whether the entered cycle reponse time is greater tha 1F98 03 value
    set validateResult [$frame0.cycleframe.en_time validate]
    switch -- $validateResult {
        0 {
				#NOTE:: the minimum value is got from vcmd
   				set minimumvalue [ lindex [$frame0.cycleframe.en_time cget -vcmd] end-2]
				tk_messageBox -message "The Entered value should not be less than the minimum value $minimumvalue" -parent . -icon warning -title "Error"
   				Validation::ResetPromptFlag
        }
        1 {
				set validateResultConfirm [$frame0.cycleframe.en_time validate]

				switch -- $validateResultConfirm {
					0 {
 				        set minimumvalue [ lindex [$frame0.cycleframe.en_time cget -vcmd] end-3]
						set answer [tk_messageBox -message "The Entered value is less than the Set latency value $minimumvalue, Do you wish to continue? " -parent . -type yesno -icon question -title "Warning"]
						switch -- $answer {

							yes {
									#continue
							}
							no	{
									tk_messageBox -message "The Poll Response Timeout values are unchanged" -type ok
									Validation::ResetPromptFlag
            						return
							}
						}
					}
					1 {
						#continue
					}
				}		          
 
        }
	
    }
    set newNodeName [$frame0.en_nodeName get]
    set stationType [NoteBookManager::RetStationEnumValue]
    set saveSpinVal ""
    #if the check button is enabled and a valid value is obtained from spin box call the API
    set chkState [$frame2.ch_adv cget -state]
    set chkVar [$frame2.ch_adv cget -variable]
    global $chkVar
    set chkVal [subst $[subst $chkVar] ]
    #check the state and if it is selected.
    if { ($chkState == "normal") && ($chkVal == 1) && ($multiPrescalDatatype != "") } {
        #check wheteher a valid data is set or not
        set spinVar [$frame2.sp_cycleNo cget -textvariable]
        global $spinVar
        set spinVal [subst $[subst $spinVar] ]
        set spinVal [string trim $spinVal]
        if { ($spinVal != "") && ([$frame2.sp_cycleNo validate] == 1) } {
            # the entered spin box value is validated save it convert the value to hexadecimal
            # remove the 0x appended to the converted value
            set saveSpinVal [string range [lindex [Validation::InputToHex $spinVal $multiPrescalDatatype] 0] 2 end]
        } else {
            #failed the validation
            tk_messageBox -message "The entered cycle number is not valid" -title Warning -icon warning -parent .
            Validation::ResetPromptFlag
            return
        }
    }
    
    #set radioSel [$frame0.formatframe1.ra_dec cget -variable]
    #global $radioSel
    #set radioSel [subst $[subst $radioSel]]
    
    set CNDatatypeObjectPathList [list \
        [list presponseCycleTimeDatatype $Operations::PRES_TIMEOUT_OBJ $frame0.cycleframe.en_time] ]
    
    foreach tempDatatype $CNDatalist {
        set schDataRes [lsearch $CNDatatypeObjectPathList [list [lindex $tempDatatype 0] * *]]
        if {$schDataRes  != -1 } {
            set dataType [lindex $tempDatatype 1]
            set entryPath [lindex [lindex $CNDatatypeObjectPathList $schDataRes] 2]
            
            # if entry is disabled no need to save it
            set entryState [$entryPath cget -state]
            if { $entryState != "normal" } {
                # if entry is disabled no need to save it"
                set validValue ""
                continue
            }
            set objectList [lindex [lindex $CNDatatypeObjectPathList $schDataRes] 1]
            set value [$entryPath get]
            set result [Validation::CheckDatatypeValue $entryPath $dataType "dec" $value]
            if { [lindex $result 0] == "pass" } {
                #get the flag and name of the object
                set validValue [lindex $result 1]
		if { $validValue != "" } {
		    if { [ catch { set validValue [expr $validValue * 1000] } ] } {
			set validValue ""
		    }
		}
            } else {
                set validValue ""
            }
            
        }
    }

    set catchErrCode [UpdateNodeParams $nodeId $newNodeId $nodeType $newNodeName $stationType $saveSpinVal $chkVal $validValue]
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
    set status_save 1
    #if the forced cycle no is changed and saved subobjects will be added to MN
    #based on the internal logic so need to rebuild the mn tree
    #delete the OBD node and rebuild the tree
    set MnTreeNode [lindex [$treePath nodes ProjectNode] 0]
    set tmpNode [string range $MnTreeNode 2 end]
    #there can be one OBD in MN so -1 is hardcoded
    set ObdTreeNode OBD$tmpNode-1
    catch {$treePath delete $ObdTreeNode}
    #insert the OBD ico only for expert view mode
    if { [string match "EXPERT" $Operations::viewType ] == 1 } {
        $treePath insert 0 $MnTreeNode $ObdTreeNode -text "OBD" -open 0 -image [Bitmap::get pdo]
    }
    set mnNodeType 0
    set mnNodeId 240
    thread::send [tsv::get application importProgress] "StartProgress"
    if { [ catch { set result [WrapperInteractions::Import $ObdTreeNode $mnNodeType $mnNodeId] } ] } {   
        # error has occured
        thread::send  [tsv::set application importProgress] "StopProgress"
        Operations::CloseProject
        return 0
    }
    thread::send  [tsv::set application importProgress] "StopProgress"
    
    #save is success reconfigure tree, cnSaveButton and nodeIdlist
    set schDataRes [lsearch $nodeIdList $nodeId]
    set nodeIdList [lreplace $nodeIdList $schDataRes $schDataRes $newNodeId]
    set nodeId $newNodeId
    $cnPropSaveBtn configure -command "NoteBookManager::SaveCNValue $nodePos $nodeId $nodeType $frame0 $frame1 $frame2 $multiPrescalDatatype"
    $treePath itemconfigure $nodeSelect -text "$newNodeName\($nodeId\)"
    Validation::ResetPromptFlag
    #operations based on station type
    #if { [lsearch $savedValueList $nodeSelect] == -1 } {
    #    lappend savedValueList $nodeSelect
    #}
    #$frame0.en_nodeName configure -bg #fdfdd4
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
			1 {
                $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 2 $tablePath $rowIndex $columnIndex $win"
            }
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
            1 {
                if {[string length $text] < 1 || [string length $text] > 2} {
	                bell
                    $tablePath rejectinput
                } else {
                }
            }
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
    if { $text == "" } {
        return $text
    } else {
        return 0x$text
    }
    
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
	global populatedCommParamList 

    set result [$tableWid finishediting]
    if {$result == 0} {
        Validation::ResetPromptFlag
        return 
    } else {
    }
    # should save entered values to corresponding subindex
    set result [Operations::GetNodeIdType $nodeSelect]
    set nodeId [lindex $result 0]
    set nodeType [lindex $result 1]
    set rowCount 0
    set flag 0
    
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
	    tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]\nValues not saved" -parent . -title Error -icon error
        } else {
	    tk_messageBox -message "Unknown Error\nValues not saved" -parent . -title Error -icon error
        }
        Validation::ResetPromptFlag
        return
    }
	#sort the tablelist based on the No column
	$tableWid sortbycolumn 0 -increasing
	update
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
                set indexPos [new_intp] 
                set subIndexPos [new_intp] 
                set catchErrCode [IfSubIndexExists $nodeId $nodeType $indexId $subIndexId $subIndexPos $indexPos]
                if { [ocfmRetCode_code_get $catchErrCode] == 0 } {
                    set indexPos [intp_value $indexPos] 
                    set subIndexPos [intp_value $subIndexPos]
                    #to get include subindex in cdc generation
                    set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 9 ]
		    set ErrCode [ocfmRetCode_code_get [lindex $tempIndexProp 0]]
		    if {$ErrCode == 0} {	
			    set incFlag [lindex $tempIndexProp 1]
		    } else {
			    set incFlag 0
		    }
                } else {
                    set incFlag 0
                }
		if { [expr [expr 0x$index > 0x0000 ] && [expr 0x$subindex > 0x00 ] && [expr 0x$length > 0x0000 ]]} {
		    SetSubIndexAttributes $nodeId $nodeType $indexId "00" "0x$subIndexId" "NumberOfEntries" 1
		}
                SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $name $incFlag
                incr rowCount
            }
        }
    }
	
	#saving the nodeid to communication parameter subindex 01
	foreach childIndex $populatedCommParamList {
		set treeNode [lindex $childIndex 1]
		if {[$treePath exists $treeNode] == 0} {
			continue;
		}
        set indexId [string range [$treePath itemcget $treeNode -text] end-4 end-1]
        foreach childSubIndex [$treePath nodes $treeNode] {
            set subIndexId [string range [$treePath itemcget $childSubIndex -text] end-2 end-1]
			set name [string range [$treePath itemcget $childSubIndex -text] 0 end-6] 
			set rowCount [lindex [lindex $childIndex 2] 0]
            if { [string match "01" $subIndexId] } {
				#
				if { $rowCount == ""} {
					break
				}
                set enteredNodeId [string range [$tableWid cellcget $rowCount,1 -text] 2 end] 
                set value $enteredNodeId
                #0x is appended when saving value to indicate it is a hexa decimal number
                if { ([string length $value] < 1) || ([string length $value] > 2) } {
                    set flag 1
                    break
                } else {
                    set value 0x$value
                }
                set indexPos [new_intp] 
                set subIndexPos [new_intp] 
                set catchErrCode [IfSubIndexExists $nodeId $nodeType $indexId $subIndexId $subIndexPos $indexPos]
                if { [ocfmRetCode_code_get $catchErrCode] == 0 } {
                    set indexPos [intp_value $indexPos] 
                    set subIndexPos [intp_value $subIndexPos]
                    #to get include subindex in cdc generation
                    set tempIndexProp [GetSubIndexAttributesbyPositions $nodePos $indexPos $subIndexPos 9 ]
		    set ErrCode [ocfmRetCode_code_get [lindex $tempIndexProp 0]]
		    if {$ErrCode == 0} {	
			    set incFlag [lindex $tempIndexProp 1]
		    } else {
			    set incFlag 0
		    }
                } else {
                    set incFlag 0
                }
                SetSubIndexAttributes $nodeId $nodeType $indexId $subIndexId $value $name $incFlag
                #incr rowCount
				break
            }
        }
    }
    if { $flag == 1} {
        Console::DisplayInfo "Values which are completely filled (Offset, Length, Index and Sub Index) only saved"
    }

    #PDO entries value is changed need to save 
    set status_save 1
    #set populatedPDOList ""
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
    set comboState [$comboPath cget -state]
    set value [$comboPath getvalue]
    if { $value == -1 } {
        #nothing was selected
        $comboPath configure -state $comboState
        return []
    }
    set valueList [$comboPath cget -values]
    $comboPath configure -state $comboState
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
        $comboPath configure -editable yes
        global $comboVar
        set $comboVar ""
        $comboPath configure -editable no
    } else {
        $comboPath setvalue @$selectedValue
    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::ChangeValidation
# 
#  Arguments : comboPath  - path of the Combobox widget
#              value      - value to set into the Combobox widget
#	   
#  Results : selected value
#
#  Description : gets the selected value and sets the value into the Combobox widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::ChangeValidation {framePath0 framePath comboPath {objectType ""}} {
    global userPrefList
    global nodeSelect
    global lastConv
    global chkPrompt
    global UPPER_LIMIT
    global LOWER_LIMIT
    
    set chkPrompt 1
    if {[string match "*.co_data1" $comboPath]} {
        set value [$comboPath getvalue]
        set valueList [$comboPath cget -values]
        set dataType [lindex $valueList $value]
        set stdDataType [string toupper $dataType]
        
        #grid $framePath.frame1.ra_dec
        #grid $framePath.frame1.ra_hex
        #$framePath.frame1.ra_hex select
        #set lastConv hex
        #
        ##delete the the node in userpreference list else create problem in conversion
        #set userPrefList [Operations::DeleteList $userPrefList $nodeSelect 1]
        
        global lastConv
    
        grid $framePath.frame1.ra_dec
        grid $framePath.frame1.ra_hex
        
        $framePath.en_value1 configure -validate none
        #$framePath.en_value1 delete 0 end
        $framePath.en_upper1 configure -validate none
        $framePath.en_upper1 delete 0 end
        $framePath.en_lower1 configure -validate none
        $framePath.en_lower1 delete 0 end
        if { $lastConv == "dec" } {
            $framePath.en_value1 configure -validate key -vcmd "Validation::IsDec %P $framePath.en_value1 %d %i $dataType"
        } elseif { $lastConv == "hex"} {   
            $framePath.en_value1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath.en_value1 %d %i $dataType"
            $framePath.en_value1 insert 0 0x
        } else {
            $framePath.en_value1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath.en_value1 %d %i $dataType"
            $framePath.frame1.ra_hex select
            set lastConv "hex"
        }
        
        #$framePath.en_value1 configure -validate none
        #$framePath.en_value1 delete 0 end
        #$framePath.en_value1 insert 0 0x
        #$framePath.en_value1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath.en_value1 %d %i $dataType"
        #$framePath.en_upper1 configure -validate none
        #$framePath.en_upper1 delete 0 end
        set UPPER_LIMIT ""
        $framePath.en_lower1 configure -validate none
        $framePath.en_lower1 delete 0 end
        set LOWER_LIMIT ""
        
        if { $objectType == "VAR" || $objectType == ""} {
            #upper and lower limit are editable only when object type is VAR and if 
            #index is greater than 1FFF. the combo box appears only for index greater than 1fff
            $framePath.en_upper1 configure -validate none -state normal
            $framePath.en_upper1 delete 0 end
            #$framePath.en_upper1 insert 0 0x
            if { $lastConv == "dec" } {
                $framePath.en_upper1 configure -validate key -vcmd "Validation::IsDec %P $framePath.en_upper1 %d %i $dataType"
            } else {
                $framePath.en_upper1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath.en_upper1 %d %i $dataType"
            }
            $framePath.en_lower1 configure -validate none -state normal
            $framePath.en_lower1 delete 0 end
            #$framePath.en_lower1 insert 0 0x
            if { $lastConv == "dec" } {
                $framePath.en_lower1 configure -validate key -vcmd "Validation::IsDec %P $framePath.en_lower1 %d %i $dataType"
            } else {
                $framePath.en_lower1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath.en_lower1 %d %i $dataType"
            }
        }
        switch -- $stdDataType {
            BIT {
                set lastConv ""
                grid remove $framePath.frame1.ra_dec
                grid remove $framePath.frame1.ra_hex
                $framePath.en_value1 configure -validate none
                $framePath.en_value1 delete 0 end
                $framePath.en_value1 configure -validate key -vcmd "Validation::CheckBitNumber %P"
                $framePath.en_upper1 configure -validate none
                $framePath.en_upper1 delete 0 end
                $framePath.en_upper1 configure -state disabled
                $framePath.en_lower1 configure -validate none
                $framePath.en_lower1 delete 0 end
                $framePath.en_lower1 configure -state disabled
            }
            BOOLEAN {
            }
            INTEGER8 {
            }
            UNSIGNED8 {
            }
            INTEGER16 {
            }
            UNSIGNED16 {
            }
            INTEGER24 {
            }
            UNSIGNED24 {
            }
            INTEGER32 {
            }
            UNSIGNED32 {
            }
            INTEGER40 {
            }   
            UNSIGNED40 {
            }
            INTEGER48 {
            }
            UNSIGNED48 {
            }
            INTEGER56 {
            }
            UNSIGNED56 {
            }
            INTEGER64 {
            }
            UNSIGNED64 {
            }
            REAL32 {
                grid remove $framePath.frame1.ra_dec
                grid remove $framePath.frame1.ra_hex
                tk_messageBox -message "Floating point not supported for $dataType.\nPlease refer IEEE 754 standard to represent the floating point number as a hexadecimal value." -parent .
            }
            REAL64 {
                grid remove $framePath.frame1.ra_dec
                grid remove $framePath.frame1.ra_hex
                tk_messageBox -message "Floating point not supported for $dataType.\nPlease refer IEEE 754 standard to represent the floating point number as a hexadecimal value." -parent .
            }
            MAC_ADDRESS {
                set lastConv ""
                grid remove $framePath.frame1.ra_dec
                grid remove $framePath.frame1.ra_hex
                $framePath.en_value1 configure -validate none
                $framePath.en_value1 delete 0 end
                $framePath.en_value1 configure -validate key -vcmd "Validation::IsMAC %P %V"
                $framePath.en_upper1 configure -validate none
                $framePath.en_upper1 delete 0 end
                $framePath.en_upper1 configure -state disabled
                $framePath.en_lower1 configure -validate none
                $framePath.en_lower1 delete 0 end
                $framePath.en_lower1 configure -state disabled
            }
            IP_ADDRESS {
                set lastConv ""
                grid remove $framePath.frame1.ra_dec
                grid remove $framePath.frame1.ra_hex
                $framePath.en_value1 configure -validate none
                $framePath.en_value1 delete 0 end
                $framePath.en_value1 configure -validate key -vcmd "Validation::IsIP %P %V"
                $framePath.en_upper1 configure -validate none
                $framePath.en_upper1 delete 0 end
                $framePath.en_upper1 configure -state disabled
                $framePath.en_lower1 configure -validate none
                $framePath.en_lower1 delete 0 end
                $framePath.en_lower1 configure -state disabled
            }
	    OCTET_STRING {
                set lastConv ""
                grid remove $framePath.frame1.ra_dec
                grid remove $framePath.frame1.ra_hex
		$framePath.en_value1 configure -validate none
                $framePath.en_value1 delete 0 end
		$framePath.en_value1 configure -validate key -vcmd "Validation::IsValidStr %P"
                $framePath.en_upper1 configure -validate none
                $framePath.en_upper1 delete 0 end
                $framePath.en_upper1 configure -state disabled
                $framePath.en_lower1 configure -validate none
                $framePath.en_lower1 delete 0 end
                $framePath.en_lower1 configure -state disabled
            }
        }
        set validateResult [$framePath.en_value1 validate]
	switch -- $validateResult {
	    0 {
		$framePath.en_value1 delete 0 end
	    }
	}
    } elseif {[string match "*.co_obj1" $comboPath]} {
        #based on the object type selected make other fields editable
        #VAR except default type all are editable
        #ARRAy datatype name and value are ediable
        #for all other object types only name and value are ediable
        set value [$comboPath getvalue]
        set valueList [$comboPath cget -values]
        set selObjectType [lindex $valueList $value]
        set selObjectType [string toupper $selObjectType]
        #reconfigure the modifycmd of data combobox with object type
        $framePath.co_data1 configure -modifycmd "NoteBookManager::ChangeValidation $framePath0 $framePath $framePath.co_data1 $selObjectType"
       
        switch -- $selObjectType {
            VAR {
                grid remove $framePath.en_data1
                grid $framePath.co_data1

                grid remove $framePath.en_access1
                grid $framePath.co_access1
            
                grid remove $framePath.en_pdo1
                grid $framePath.co_pdo1
                
                set objectDatatype [NoteBookManager::GetComboValue $framePath.co_data1]
                #setting the datatype to last saved and changing the validation based on it
                NoteBookManager::ChangeEntryValidationForDatatype $framePath $framePath.en_value1 $objectDatatype
                
                #enable the entry boxes upper and lower limit
                $framePath.en_upper1 configure -state normal
                $framePath.en_lower1 configure -state normal
                $framePath.en_value1 configure -state normal
            }
            ARRAY {
                grid remove $framePath.en_data1
                grid $framePath.co_data1
                
                grid $framePath.en_access1
                grid remove $framePath.co_access1
                
                grid $framePath.en_pdo1
                grid remove $framePath.co_pdo1
                
                set objectDatatype [NoteBookManager::GetComboValue $framePath.co_data1]
                #setting the datatype to last saved and changing the validation based on it
                NoteBookManager::ChangeEntryValidationForDatatype $framePath $framePath.en_value1 $objectDatatype
                
                #disable the entry boxes upper and lower limit
                $framePath.en_upper1 configure -state disabled
                $framePath.en_lower1 configure -state disabled
                $framePath.en_value1 delete 0 end
                $framePath.en_value1 configure -state disabled
            }
            default {
                grid $framePath.en_data1
                grid remove $framePath.co_data1
                
                grid $framePath.en_access1
                grid remove $framePath.co_access1
                
                grid $framePath.en_pdo1
                grid remove $framePath.co_pdo1
                set objectDatatype [NoteBookManager::GetEntryValue $framePath.en_data1]
                #setting the datatype to last saved and changing the validation based on it
                NoteBookManager::ChangeEntryValidationForDatatype $framePath $framePath.en_value1 $objectDatatype
                #disable the entry boxes upper and lower limit
                $framePath.en_upper1 configure -state disabled
                $framePath.en_lower1 configure -state disabled
                $framePath.en_value1 delete 0 end
                $framePath.en_value1 configure -state disabled
            }
        }
        
    } elseif {[string match "*.co_access1" $comboPath]} {
        set value [$comboPath getvalue]
        set valueList [$comboPath cget -values]
        set accessType [lindex $valueList $value]
        set stdAccessType [string toupper $accessType]
        switch -- $stdAccessType {
            RO {
                $framePath0.frame1.ch_gen configure -state disabled
                $framePath0.frame1.ch_gen deselect
            }
            CONST {
                $framePath0.frame1.ch_gen configure -state disabled
                $framePath0.frame1.ch_gen deselect
            }
            default {
                $framePath0.frame1.ch_gen configure -state normal
            }
        }
        
    }
    focus -force $framePath.en_value1
    return
}

proc NoteBookManager::ChangeEntryValidationForDatatype {framePath entryPath dataType } {
    global lastConv
    
    grid $framePath.frame1.ra_dec
    grid $framePath.frame1.ra_hex
    if { $lastConv == "dec" } {
        $entryPath configure -validate key -vcmd "Validation::IsDec %P $entryPath %d %i $dataType"
    } elseif { $lastConv == "hex"} {   
        $entryPath configure -validate key -vcmd "Validation::IsHex %P %s $entryPath %d %i $dataType"
    } else {
        $entryPath configure -validate key -vcmd "Validation::IsHex %P %s $entryPath %d %i $dataType"
        $framePath.frame1.ra_hex select
        set lastConv "hex"
    }
    
    set stdDataType [string toupper $dataType]
    switch -- $stdDataType {
        BIT {
            set lastConv ""
            grid remove $framePath.frame1.ra_dec
            grid remove $framePath.frame1.ra_hex
            $entryPath configure -validate key -vcmd "Validation::CheckBitNumber %P"
        }
        BOOLEAN {
        }
        INTEGER8 {
        }
        UNSIGNED8 {
        }
        INTEGER16 {
        }
        UNSIGNED16 {
        }
        INTEGER24 {
        }
        UNSIGNED24 {
        }
        INTEGER32 {
        }
        UNSIGNED32 {
        }
        INTEGER40 {
        }   
        UNSIGNED40 {
        }
        INTEGER48 {
        }
        UNSIGNED48 {
        }
        INTEGER56 {
        }
        UNSIGNED56 {
        }
        INTEGER64 {
        }
        UNSIGNED64 {
        }
        REAL32 {
            grid remove $framePath.frame1.ra_dec
            grid remove $framePath.frame1.ra_hex
            tk_messageBox -message "Floating point not supported for $dataType.\nPlease refer IEEE 754 standard to represent the floating point number as a hexadecimal value." -parent .
        }
        REAL64 {
            grid remove $framePath.frame1.ra_dec
            grid remove $framePath.frame1.ra_hex
            tk_messageBox -message "Floating point not supported for $dataType.\nPlease refer IEEE 754 standard to represent the floating point number as a hexadecimal value." -parent .
        }
        MAC_ADDRESS {
            set lastConv ""
            grid remove $framePath.frame1.ra_dec
            grid remove $framePath.frame1.ra_hex
            $entryPath configure -validate key -vcmd "Validation::IsMAC %P %V"
        }
        IP_ADDRESS {
            set lastConv ""
            grid remove $framePath.frame1.ra_dec
            grid remove $framePath.frame1.ra_hex
            $entryPath configure -validate key -vcmd "Validation::IsIP %P %V"
        }
	OCTET_STRING {
	    set lastConv ""
            grid remove $framePath.frame1.ra_dec
            grid remove $framePath.frame1.ra_hex
	}
    }
    set validateResult [$entryPath validate]
    switch -- $validateResult {
        0 {
            $entryPath delete 0 end
            if {[string match "*.en_lower1" $entryPath]} {
                set LOWER_LIMIT ""
            } elseif {[string match "*.en_upper1" $entryPath]} {
                set UPPER_LIMIT ""
            }
        }
        1 {
            #the value is valid can continue
        }
    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::GetEntryValue
# 
#  Arguments : entryPath - path of the entry box widget
#	   
#  Results : selected value
#
#  Description : gets the value entered in entry widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::GetEntryValue {entryPath} {
    set entryState [$entryPath cget -state]
    set entryValue [$entryPath get]
    $entryPath configure -state $entryState
    return $entryValue
    
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::GetEntryValue
# 
#  Arguments : entryPath - path of the entry box widget
#	   
#  Results : selected value
#
#  Description : gets the value entered in entry widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SetEntryValue {entryPath insertValue} {
    set entryState [$entryPath cget -state]
    $entryPath configure -state normal
    $entryPath delete 0 end
    $entryPath insert 0 $insertValue
    $entryPath configure -state $entryState
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::GenerateCnNodeList
# 
#  Arguments : comboPath  - path of the Combobox widget
#              value      - value to set into the Combobox widget
#	   
#  Results : selected value
#
#  Description : gets the selected value and sets the value into the Combobox widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::GenerateCnNodeList {} {
    set cnNodeList ""
    for { set inc 1 } { $inc < 240 } { incr inc } {
        lappend cnNodeList $inc
    }
    return $cnNodeList
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::StationRadioChanged
# 
#  Arguments : framePath   - path of frame containing the check button
#              radioVal   - varaible of the radio buttons
#	   
#  Results : -
#
#  Description : enables or disasbles the spinbox based on the check button selection
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::StationRadioChanged {framePath radioVal } {
	global lastRadioVal
	if { $lastRadioVal != $radioVal } {
		Validation::SetPromptFlag
	}
	set lastRadioVal $radioVal
    set spinVar [$framePath.sp_cycleNo cget -textvariable]
    global $spinVar
    if { $radioVal == "StNormal" } {
        #set $spinVar ""
        $framePath.ch_adv deselect
        $framePath.ch_adv configure -state disabled
    	$framePath.sp_cycleNo configure  -state disabled
    } elseif { $radioVal == "StMulti" } {
        $framePath.ch_adv configure -state normal
    	#$framePath.sp_cycleNo configure  -state normal -validate key
    } elseif { $radioVal == "StChain" } {
        #set $spinVar ""
        $framePath.ch_adv deselect
    	$framePath.ch_adv configure -state disabled
    	$framePath.sp_cycleNo configure  -state disabled
    } else {
    
    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::forceCycleChecked
# 
#  Arguments : framePath   - path of frame containing the check button
#              check_var   - varaible of the check box
#	   
#  Results : -
#
#  Description : enables or disasbles the spinbox based on the check button selection
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::forceCycleChecked { framePath check_var } {
    global $check_var
	Validation::SetPromptFlag
    set check_value [subst $[subst $check_var]]
    if { $check_value == 1 } {
        $framePath.sp_cycleNo configure -state normal -bg white
    } else {
        $framePath.sp_cycleNo configure -state disabled
    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::RetStationEnumValue
# 
#  Arguments : -
#	   
#  Results : -
#
#  Description : enables or disasbles the spinbox based on the check button selection
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::RetStationEnumValue {  } {
    global f4
    set radioButtonFrame [lindex $f4 2]
    set ra_StNormal $radioButtonFrame.ra_StNormal
    set radioVar [$ra_StNormal cget -variable]
    
    global $radioVar
    set radioVal [subst $[subst $radioVar]]
    
    switch -- $radioVal {
        StNormal {			 
            set returnVal 0
        }
        StMulti {
            set returnVal 1
        }
        StChain {
            set returnVal 2
        }
    }
        
    return $returnVal
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::LimitFocusChanged
# 
#  Arguments : -
#	   
#  Results : -
#
#  Description : based on the entry path it validates value with upper limit or lower limit
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::LimitFocusChanged {framePath entryPath} {
    catch {
        global UPPER_LIMIT
        global LOWER_LIMIT
    
        set dontCompareValue 0
        set valueState [$framePath.en_value1 cget -state]
        set valueInput [$framePath.en_value1 get]
#        puts "LimitFocusChanged UPPER_LIMIT->$UPPER_LIMIT LOWER_LIMIT->$LOWER_LIMIT"
#        puts "LimitFocusChanged valueState->$valueState valueInput->$valueInput"
        if { $valueState != "normal" || $valueInput == "" || $valueInput == "-" || [string match -nocase "0x" $valueInput] } {
            
            set dontCompareValue 1
            #puts "LimitFocusChanged dontCompareValue->$dontCompareValue"
        }
        
        set msg ""
        if {[string match "*.en_lower1" $entryPath]} {
            set lowervalueState [$framePath.en_lower1 cget -state]
            set lowervalueInput [$framePath.en_lower1 get]
            if { $lowervalueInput == "" || $lowervalueInput == "-" || [string match -nocase "0x" $lowervalueInput] } {
                set lowervalueInput ""
                set LOWER_LIMIT ""
                return 1
            }
            if { $lowervalueState != "normal" } {
                return 1
            }
            #puts "@@@@ lowervalueInput->$lowervalueInput"
            if { $lowervalueInput != "" && $UPPER_LIMIT != ""} {
                if { [ catch { set lowerlimitResult [expr $lowervalueInput <= $UPPER_LIMIT] } ] } {
                    SetEntryValue $framePath.en_lower1 ""
                    set LOWER_LIMIT ""
                    set msg "Error in comparing lowerlimit($lowervalueInput) and upperlimit($UPPER_LIMIT). lowerlimit is made empty"
                    #puts "$msg"
                }
                if { $lowerlimitResult == 0 } {
                    SetEntryValue $framePath.en_lower1 ""
                    set LOWER_LIMIT ""
                    set msg "The entered lowerlimit($lowervalueInput) is greater than upperlimit($UPPER_LIMIT). lowerlimit is made empty"
                }
                if {$msg != ""} {
                    #tk_messageBox -message "$msg" -parent . -title "Warning" -icon warning
                    Console::DisplayWarning $msg
                    return 0
                }
            }
            set LOWER_LIMIT $lowervalueInput
            #puts "@@@@@ LOWER_LIMIT->$LOWER_LIMIT"
            if { $LOWER_LIMIT != "" && $dontCompareValue == 0} {
                if { [ catch { set lowerlimitResult [expr $valueInput >= $LOWER_LIMIT] } ] } {
                    #SetEntryValue $framePath.en_value1 $LOWER_LIMIT
		    set msg "Error in comparing input($valueInput) and lowerlimit($lowervalueInput)."
		    #tk_messageBox -message "$msg" -parent . -title "Warning" -icon warning
		    Console::DisplayWarning $msg
                    return 1
                }
                #puts "lowerlimitResult->$lowerlimitResult"
                if { $lowerlimitResult == 0 } {
                    SetEntryValue $framePath.en_value1 $LOWER_LIMIT
		    set msg "The entered input($valueInput) is lesser than lowerlimit($LOWER_LIMIT).lower limit is copied into the value"
		    #tk_messageBox -message "$msg" -parent . -title "Warning" -icon warning
		    Console::DisplayWarning $msg
                    return 1
                }
            }
        } elseif {[string match "*.en_upper1" $entryPath]} {
            set uppervalueState [$framePath.en_upper1 cget -state]
            set uppervalueInput [$framePath.en_upper1 get]
            if { $uppervalueInput == "" || $uppervalueInput == "-" || [string match -nocase "0x" $uppervalueInput] } {
                set uppervalueInput ""
                set UPPER_LIMIT ""
                return 1
            }
            if { $uppervalueState != "normal" } {
                return 1
            }
            #puts "@@@@ uppervalueInput->$uppervalueInput"
            if { $uppervalueInput != "" && $LOWER_LIMIT != "" } {
                if { [ catch { set upperlimitResult [expr $uppervalueInput >= $LOWER_LIMIT] } ] } {
                    SetEntryValue $framePath.en_upper1 ""
                    set UPPER_LIMIT ""
                    set msg "Error in comparing upperlimit($uppervalueInput) and lowerlimit($LOWER_LIMIT). upperlimit is made empty"
                    #puts "$msg"
                }
                #puts "upperlimitResult->$upperlimitResult"
                if { $upperlimitResult == 0 } {
                    SetEntryValue $framePath.en_upper1 ""
                    set UPPER_LIMIT ""
                    set msg "The entered upperlimit($uppervalueInput) is lesser than lowerlimit($LOWER_LIMIT). upperlimit is made empty"
                }
                if {$msg != ""} {
                    #tk_messageBox -message "$msg" -parent . -title "Warning" -icon warning
		    Console::DisplayWarning $msg
                    return 0
                }
            }
            set UPPER_LIMIT $uppervalueInput
            #puts "@@@@@ UPPER_LIMIT->$UPPER_LIMIT"
            if { $UPPER_LIMIT != "" && $dontCompareValue == 0} {
                if { [ catch { set upperlimitResult [expr $valueInput <= $UPPER_LIMIT] } ] } {
                    #SetEntryValue $framePath.en_value1 $UPPER_LIMIT
		    set msg "Error in comparing input($valueInput) and upperlimit($UPPER_LIMIT)."
		    #tk_messageBox -message "$msg" -parent . -title "Warning" -icon warning
		    Console::DisplayWarning $msg
                    return 1
                }
                if { $upperlimitResult == 0 } {
                    SetEntryValue $framePath.en_value1 $UPPER_LIMIT
    		    set msg "The entered input($valueInput) is greater than upperlimit($UPPER_LIMIT). upperlimit is copied into the value"
		    #tk_messageBox -message "$msg" -parent . -title "Warning" -icon warning
		    Console::DisplayWarning $msg
                    return 1
                }
            }
        }
    }
}

proc NoteBookManager::ValueFocusChanged {framePath entryPath} {
    catch {
        set valueState [$entryPath cget -state]
        set valueInput [$entryPath get]
        if { $valueState != "normal" || $valueInput == "" || $valueInput == "-" || [string match -nocase "0x" $valueInput] } {
            return
        }
        if { [string match "*.en_value1" $entryPath] } {
            set limitResult [Validation::CheckAgainstLimits $entryPath $valueInput ]
            if { [lindex $limitResult 0] == 0 } {
		Console::DisplayWarning [lindex $limitResult 1]
		#tk_messageBox -message "[lindex $limitResult 1]" -title "Warning" -icon warning
                return 0
            }
        }
            return 1
    }
}