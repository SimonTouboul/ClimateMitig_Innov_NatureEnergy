*=== Nature Energy: July 2021
*=== Paper title: 
*				Global Trends in the Invention and Diffusion 
*				of Climate Change Mitigation Technologies
*=== Objective: 
* - Selection of patents (application id) protecting climate change mitigation technologies


**************************************************************************************************************************
*** 			SELECTION OF TECHNOLOGY CODES (CPC CODES) TO BUILD Databases/
**************************************************************************************************************************

**************************************************************************************************************************
*** 		1A -	Selection of mitigation patents
**************************************************************************************************************************
 
 * Select mitigation patents (CPC codes begin with Y02), excluding Y02A (adaptation patents)
 use "$patstpath/general/CPC_codes.dta", clear 
 keep if [regexm(cpc_code,"Y02")==1] & [regexm(cpc_code,"Y02A")!=1]
 gen technology=substr(cpc_code,1,3)
 save "$datapath/Y02_PatstatCAT_mitigation.dta", replace

 * Identify the technology fields using the four first digit of the CPC codes 
 use "$datapath/Y02_PatstatCAT_mitigation.dta", clear
 replace technology=substr(cpc_code,1,4)
 save "$datapath/bycat_PatstatCAT_mitigation.dta", replace
 
 * Append both databases (All mitigation patents, technology =Y02 with mitigation 
 * patents by technology fields)
  use "$datapath/Y02_PatstatCAT_mitigation.dta", clear
  append using "$datapath/bycat_PatstatCAT_mitigation.dta"
  save "$datapath/Patstat_mitigation2018.dta", replace

 /// Focus on subfields: variable sub_tech identify technologies using the 6 first digits 
 * of the CPC codes
  use "$datapath/Y02_PatstatCAT_mitigation.dta", clear
  replace technology=substr(cpc_code,1,4)
  gen sub_tech=substr(cpc_code,1,6)
  save "$datapath/Y02_SubtechCAT_mitigation.dta", replace
 
 /// Focus on subfields: Renewables (Energy CCMT) 
  use "$datapath/Y02_PatstatCAT_mitigation.dta", clear
  keep if [regexm(cpc_code,"Y02E10")==1]
  save "$datapath/Focus_RE_PatstatCAT_mitigation_2018.dta", replace

*=============================================
*=============================================
*=============================================
*=============================================
*=============================================
