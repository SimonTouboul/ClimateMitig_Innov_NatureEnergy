

**************************************************************************************************************************
*** 			SELECTION OF TECHNOLOGY CODES (CPC CODES) TO BUILD Databases/
**************************************************************************************************************************

**************************************************************************************************************************
*** 		1A -	Selection of mitigation patents
**************************************************************************************************************************
 
 
 use "$patstpath/general/CPC_codes.dta", clear 
 keep if [regexm(cpc_code,"Y02")==1] & [regexm(cpc_code,"Y02A")!=1]
 gen technology=substr(cpc_code,1,3)
 save "$datapath/Y02_PatstatCAT_mitigation.dta", replace


 /// Focus on subfields
  use "$datapath/Y02_PatstatCAT_mitigation.dta", clear
  replace technology=substr(cpc_code,1,4)
  gen sub_tech=substr(cpc_code,1,6)
  save "$datapath/Y02_SubtechCAT_mitigation.dta", replace



 


*=============================================
*=============================================
*=============================================
*=============================================
*=============================================
