###################################################################################
# proc isIp
# To validate the entering ipaddress
###################################################################################
proc isIP {str type} {
   # modify these if you want to check specific ranges for
   # each portion - now it look for 0 - 255 in each
   set ipnum1 {\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]}
   set ipnum2 {\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]}
   set ipnum3 {\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]}
   set ipnum4 {\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]}
   set fullExp {^($ipnum1)\.($ipnum2)\.($ipnum3)\.($ipnum4)$}
   set partialExp {^(($ipnum1)(\.(($ipnum2)(\.(($ipnum3)(\.(($ipnum4)?)?)?)?)?)?)?)?$}
   set fullExp [subst -nocommands -nobackslashes $fullExp]
   set partialExp [subst -nocommands -nobackslashes $partialExp]
   if [string equal $type focusout] {
      if [regexp -- $fullExp $str] {
         return 1
      } else {
         #tk_messageBox -message "IP is NOT complete!" -title "IP Address" -parent .projconfig
         return 0
      }
   } elseif [string equal $type dstry] {
      if [regexp -- $fullExp $str] {
         return 1
      } else {
         #tk_messageBox -message "IP is NOT complete!" -title "IP Address" -parent .projconfig
         return 0
      }
   } else {
      return [regexp -- $partialExp $str]
   }
} 

#########################################################################################
proc IsInt {input type} {
	if {[expr {[string len $input] <= 3} && {[string is int $input]}]} {
		return 1 
	} else {
		return 0
	} 
}

##################################################
proc tIsValidStr {input} {
	if { [string is wordchar $input]==0 } {
		return 0
	} else {
		return 1
	}
}
##################################################
