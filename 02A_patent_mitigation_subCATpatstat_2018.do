
* log using "C:/Users/Simon Touboul/Dropbox/Adapt_Inv_Transf/Log/02A_CCMTation_Database_construction_LOG_Innov_CCMT_19Jan15.txt", text replace 


*construction file for mitigation innovation study 


**************************************************************************************************************************
*** 			INITIAL DATA SETS 
**************************************************************************************************************************

clear all

cd "$datapath"

use "$datapath/Y02_SubtechCAT_mitigation.dta", clear
keep technology sub_tech appln_id 
duplicates drop

* info on all mitigation patents
mmerge appln_id using "$patstpath/general/appln_info", unmatched(none) ///
ukeep(appln_auth appln_year earliest_filing_year earliest_publn_year ipr_type)
keep if ipr_type==2
drop ipr_type
drop _m
mmerge appln_id using "$patstpath/general/family_info", unmatched(master) ///
ukeep(docdb_family_id)
drop _m
mmerge docdb_family_id using "$patstpath/general/docdb_families", unmatched(master) ///
ukeep(famsize_offices_EPCgrants)
ren famsize_offices_EPCgrants famsize_offices_EPCgrants_docdb
drop _m
mmerge appln_id using "$patstpath/general/appln_inventor_country_nomissing", unmatched(master) ///
ukeep(invt)
drop _m
replace appln_auth="RU" if appln_auth=="SU"
replace appln_auth="DE" if appln_auth=="DD"
replace invt_country="RU" if invt_country=="SU"
replace invt_country="DE" if invt_country=="DD"
duplicates drop
compress
save "$patstpath/mitigation/all_sub_techCAT_mitigation_patents_info", replace	


**************************************************************************************************************************
*** 		1 -	INVENTIONS 
**************************************************************************************************************************

* All mitigation patents
* use docdb family to measure inventions rather than priorities
use "$patstpath/mitigation/all_sub_techCAT_mitigation_patents_info", clear
gen byte HVI = (famsize_offices_EPCgrants_docdb>1)
bys docdb : egen publn_year=min(earliest_publn_year)
keep if publn_year>1969 & publn_year<2018
keep technology sub_tech docdb publn_year invt_country HVI
duplicates drop
gen byte x = 1
bysort docdb technology sub_tech: egen nb_invt = sum(x)
gen invnbinv=1/nb_invt
bysort technology sub_tech invt_country publn_year: egen nb_inv_CCMT = sum(invnbinv)
bysort technology sub_tech invt_country publn_year: egen nb_hvi_CCMT = sum(invnbinv*HVI)
keep technology sub_tech invt_country publn_year nb_inv_CCMT nb_hvi_CCMT  
duplicates drop
bysort  technology sub_tech publn_year: egen world_inv_CCMT = sum(nb_inv_CCMT)
bysort  technology sub_tech publn_year: egen world_hvi_CCMT = sum(nb_hvi_CCMT)
sort technology sub_tech invt_country publn_year
compress
save "$patstpath/mitigation/Mitigation_subCAT_inventor_ctry_year", replace	

*Benchmark = all technologies in PATSTAT 
*(used to set the number of CCMT inventions equals to zeros if number of all technologies not missing)
use "$patstpath/mitigation/Complete_ALL_inventions_by_invtcountry_year", clear
keep if techno =="Y02"
keep  invt_country publn_year nb_inv_all
duplicates drop
save "$patstpath/mitigation/Complete_ALL_inventions_SUBCAT_by_invtcountry_year", replace

**************************************************************************************************************************
*** 		3 - TRANSFERS 
**************************************************************************************************************************


* USING DOCDB: Patents by authority by invt country by appln_year
use "$patstpath/mitigation/all_sub_techCAT_mitigation_patents_info", clear
keep technology sub_tech docdb earliest_publn_year invt_country appln_auth appln_id
duplicates drop
mmerge appln_id using "$patstpath/general/PRS_EPO_national_phase", unmatched(master) ukeep(country)
replace appln_auth = country if country!=""
drop country
sort docdb_family_id technology sub_tech invt_country appln_auth earliest_publn_year
bys docdb_family_id : egen publn_year = min(earliest_publn_year)
drop earliest_publn_year appln_id
duplicates drop
keep if publn_year >1969 & publn_year < 2018
drop if appln_auth=="EP"
drop if appln_auth=="WO"
drop _m
duplicates drop
gen byte x = 1
bysort docdb technology sub_tech appln_auth : egen nb_invt = sum(x)
gen invnbinv=1/(nb_invt)
keep technology sub_tech docdb publn_year appln_auth invt invnbinv nb_inv
duplicates drop
compress
save "$patstpath/mitigation/all_mitigation_subCAT_patents_marketdataset", replace

use "$patstpath/mitigation/all_mitigation_subCAT_patents_marketdataset", clear
bysort technology sub_tech appln_auth invt publn_year: egen nb_pat_CCMT = sum(invnbinv)
keep technology sub_tech appln_auth invt publn_year nb_pat_CCMT
duplicates drop
compress
save "$patstpath/mitigation/mitigation_subCAT_patents_invt_auth_publn_year", replace	

*Benchmark = all technologies in PATSTAT 
*(used to set the number of CCMT tranfserred equals to zeros 
* if number of all technologies tranfserred not missing)
use "$patstpath/mitigation/Complete_ALL_patents_invt_auth_year.dta", clear
keep if techno =="Y02"
keep  appln_auth publn_year invt_country nb_pat_all
save "$patstpath/mitigation/Complete_ALL_patents_SUBCAT_invt_auth_year.dta"

**************************************************************************************************************************
*** 		4 - FINAL FILES
**************************************************************************************************************************

* Inventions
use "$patstpath/mitigation/Mitigation_subCAT_inventor_ctry_year", clear	
order technology sub_tech invt_country publn_year
sort technology sub_tech invt_country publn_year
mmerge invt_country publn_year using "$patstpath/mitigation/Complete_ALL_inventions_by_invtcountry_year"
drop _m
ren invt_country iso2
*Add ISO3 country code for inventor country
mmerge iso2 using "$otherpath/CountryID", unmatched(none) ukeep(iso3)
ren iso3 invt_iso
ren iso2 invt_country
drop _m
save "$datapath/databases/CCMT_subCAT_invt_ctry_year_Induced", replace
*Expand dataset and Set missing values to zeros.
use "$datapath/databases/CCMT_subCAT_invt_ctry_year_Induced", clear
summ publn_year
local min =r(min)
local max =r(max)
local nb_years =`max' -`min' + 1
keep technology sub_tech invt_iso 
sort technology sub_tech invt_iso
duplicates drop
expand `nb_years'
bysort technology sub_tech invt_iso: gen publn_year = `min' -1 + _n
mmerge invt_iso technology sub_tech publn_year using "$datapath/databases/CCMT_subCAT_invt_ctry_year_Induced", unmatched(master)
drop _m invt_country
ren invt_iso iso3
mmerge iso3 using "$otherpath/CountryID", unmatched(none) ukeep(iso2)
ren iso3 invt_iso
ren iso2 invt_country
browse
order technology sub_tech invt_iso publn_year
sort technology sub_tech invt_iso publn_year
*Set the number of inventions equal to zero if the country has invented at least one patent
*within the three years BEFORE AND the three years AFTER the giving year
by technology sub_tech invt_iso: replace nb_inv_all = 0 if nb_inv_all==. & ///
[ [ nb_inv_all[_n-1] >0 & nb_inv_all[_n-1] !=. ] |  ///
 [ nb_inv_all[_n-2] >0 & nb_inv_all[_n-2] !=. ] |  ///
 [ nb_inv_all[_n-3] >0 & nb_inv_all[_n-3] !=. ] ] &  ///
 [ [ nb_inv_all[_n+1] >0 & nb_inv_all[_n+1] !=. ] |  ///
 [ nb_inv_all[_n+2] >0 & nb_inv_all[_n+2] !=. ] |  ///
 [ nb_inv_all[_n+3] >0 & nb_inv_all[_n+3] !=. ] ] 
* Set number of CCMT inventions, granted, HVI ... equals to zero if number of all inventions equals to zero
replace nb_inv_CCMT=0 if nb_inv_CCMT==. & nb_inv_all !=.
replace nb_hvi_CCMT=0 if nb_hvi_CCMT==. & nb_inv_all !=.
bysort publn_year technology sub_tech: egen world_inv_CCMT2 = max(world_inv_CCMT)
bysort publn_year technology sub_tech: egen world_hvi_CCMT2 = max(world_hvi_CCMT)
replace world_inv_CCMT = world_inv_CCMT2 if world_inv_CCMT ==.
replace world_hvi_CCMT = world_hvi_CCMT2 if world_hvi_CCMT ==.
drop world_inv_CCMT2 world_hvi_CCMT2 
replace nb_inv_all=nb_inv_CCMT if nb_inv_all==.
bysort publn_year technology sub_tech: egen world_inv_all2 = max(world_inv_all)
replace world_inv_all=world_inv_all2 if world_inv_all==.
sort technology sub_tech invt_iso publn_year
drop world_inv_all2 
drop _m
save "$datapath/Final_database/mitigation_inv_subCAT_inventor_ctry_year", replace


* Transfers
use "$patstpath/mitigation/mitigation_subCAT_patents_invt_auth_publn_year", clear	
keep if publn_year>1969 & publn_year<2018
mmerge appln_auth publn_year invt_country using "$patstpath/mitigation/Complete_ALL_patents_invt_auth_year.dta"
drop _m
ren invt_country iso2
*Add ISO3 country codes for both inventor and recipient countries
mmerge iso2 using "$otherpath/CountryID", unmatched(none) ukeep(iso3)
ren iso3 invt_iso
ren iso2 invt_country
ren appln_auth iso2
mmerge iso2 using "$otherpath/CountryID", unmatched(none) ukeep(iso3)
ren iso3 patent_office_iso
ren iso2 patent_office
drop _m
compress
save "$datapath/databases/CCMT_subCAT_invt_auth_publn_year_Induced", replace
*Expand dataset and Set missing values to zeros.
use "$datapath/databases/CCMT_subCAT_invt_auth_publn_year_Induced", clear
summ publn_year
local min =r(min)
local max =r(max)
local nb_years =`max' -`min' + 1
sort technology sub_tech invt_iso patent_office_iso
keep technology sub_tech invt_iso patent_office_iso
duplicates drop
expand `nb_years'
bysort technology sub_tech invt_iso patent_office_iso: gen publn_year = `min' -1 + _n
mmerge invt_iso technology sub_tech patent_office_iso publn_year using "$datapath/databases/CCMT_subCAT_invt_auth_publn_year_Induced", ///
unmatched(master)
sort technology sub_tech invt_iso patent_office_iso publn_year
*Set the number of patents transferred equals to zero if countries have 'exchanged' at least one patent
*within the three years BEFORE AND the three years AFTER the giving year
by technology sub_tech invt_iso patent_office_iso: replace nb_pat_all = 0 if nb_pat_all==. & ///
[ [ nb_pat_all[_n-1] >0 & nb_pat_all[_n-1] !=. ] |  ///
 [ nb_pat_all[_n-2] >0 & nb_pat_all[_n-2] !=. ] |  ///
 [ nb_pat_all[_n-3] >0 & nb_pat_all[_n-3] !=. ] ] &  ///
 [ [ nb_pat_all[_n+1] >0 & nb_pat_all[_n+1] !=. ] |  ///
 [ nb_pat_all[_n+2] >0 & nb_pat_all[_n+2] !=. ] |  ///
 [ nb_pat_all[_n+3] >0 & nb_pat_all[_n+3] !=. ] ] 
drop patent_office invt_country _m
order technology sub_tech invt_iso patent_office_iso publn_year
ren invt_iso iso3
mmerge iso3 using "$otherpath/CountryID", unmatched(none) ukeep(iso2)
ren iso3 invt_iso
ren iso2 invt_country
ren patent_office_iso iso3
mmerge iso3 using "$otherpath/CountryID", unmatched(none) ukeep(iso2)
ren iso3 patent_office_iso
ren iso2 patent_office
replace nb_pat_CCMT=0 if nb_pat_CCMT==. & nb_pat_all!=.
drop _m
duplicates drop
sort techno sub_tech invt_iso patent_office_iso publn_year
compress
save "$datapath/Final_database/mitigation_transfers_subCAT_inventor_ctry_office_year", replace


*=============================================
*=============================================
*=============================================
*=============================================
*=============================================

*=============================================
*=============================================
*=============================================
*=============================================
*=============================================

*=============================================
*=============================================
*=============================================
*=============================================
*=============================================

*=============================================
*=============================================
*=============================================
*=============================================
*=============================================

*=============================================
*=============================================
*=============================================
*=============================================
*=============================================

*=============================================
*=============================================
*=============================================
*=============================================
*=============================================
