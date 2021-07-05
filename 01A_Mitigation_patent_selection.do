

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

 
 use "$datapath/Y02_PatstatCAT_mitigation.dta", clear
 replace technology=substr(cpc_code,1,4)
 save "$datapath/bycat_PatstatCAT_mitigation.dta", replace
 
  use "$datapath/Y02_PatstatCAT_mitigation.dta", clear
  append using "$datapath/bycat_PatstatCAT_mitigation.dta"
  save "$datapath/Patstat_mitigation2018.dta", replace
 
 /// Focus on subfields: Renewables (Energy CCMT) 
  use "$datapath/Y02_PatstatCAT_mitigation.dta", clear
  keep if [regexm(cpc_code,"Y02E10")==1]
  save "$datapath/Focus_RE_PatstatCAT_mitigation_2018.dta", replace



 


*=============================================
*=============================================
*=============================================
*=============================================
*=============================================
