*=== Nature Energy: July 2021
*=== Paper title: 
*				Global Trends in the Invention and Diffusion 
*				of Climate Change Mitigation Technologies

						*== PATEND DATABASE USING BENCHMARK 4 DIGITS 

*=== Objective: 
* - Add information to selected patents (Mitigation and benchmark)
* - Build the finale databases for invetion (number of technology invented per year per country per technology field)
* AND transfers (number of technology transferred between countries (inventor & importer countries) per year per technology technology fields)

* BENCHMARK IDENTIFIED USING THE 4 FIRST DIGITS OF THE IPC CODES


**************************************************************************************************************************
*** 			INITIAL DATA SETS 
**************************************************************************************************************************

clear all



cd "$datapath"

use "$datapath/Patstat_mitigation2018.dta", clear
keep technology appln_id 
duplicates drop

* info on all mitigation patents (filing and pulication year, application authority)
mmerge appln_id using "$patstpath/general/appln_info", unmatched(none)  /// 
ukeep(appln_auth appln_year earliest_filing_year earliest_publn_year ipr_type granted)
* Exclude Design Patent or Utility models
keep if ipr_type==2
drop ipr_type
drop _m
*Add docddb family id to identify patent families
mmerge appln_id using "$patstpath/general/family_info", unmatched(master) ///
 ukeep(docdb_family_id)
drop _m
*Add docddb family size (number of countries where the patent is filed)
mmerge docdb_family_id using "$patstpath/general/docdb_families", unmatched(master) /// 
ukeep(famsize_offices_EPCgrants)
ren famsize_offices_EPCgrants famsize_offices_EPCgrants_docdb
drop _m
*Add information on the inventor country
mmerge appln_id using "$patstpath/general/appln_inventor_country_nomissing", unmatched(master) /// 
 ukeep(invt)
drop _m
replace appln_auth="RU" if appln_auth=="SU"
replace appln_auth="DE" if appln_auth=="DD"
replace invt_country="RU" if invt_country=="SU"
replace invt_country="DE" if invt_country=="DD"
duplicates drop
compress
save "$patstpath/mitigation/all_mitigation_patents_info", replace	
 
* Complete Benchmark (4 digits)
use "$datapath/Complete_4digits_benchmark_Mitig.dta", clear
drop bench_tech
* info on all patentsin the benchmarks (filing and pulication year, application authority)
mmerge appln_id using "$patstpath/general/appln_info", unmatched(none)  /// 
ukeep(appln_auth appln_year earliest_filing_year earliest_publn_year ipr_type granted )
drop _m
keep appln_id appln_auth appln_year earliest_filing_year earliest_publn_year ipr_type granted technology 
* Exclude Design Patent or Utility models
keep if ipr_type==2
drop ipr_type
*Add docddb family id to identify patent families
mmerge appln_id using "$patstpath/general/family_info", unmatched(master)  /// 
ukeep(docdb_family_id)
drop _m
*Add docddb family size (number of countries where the patent is filed)
mmerge docdb_family_id using "$patstpath/general/docdb_families", unmatched(master)  /// 
ukeep(famsize_offices_EPCgrants)
drop _m
*Add information on the inventor country
mmerge appln_id using "$patstpath/general/appln_inventor_country_nomissing", unmatched(master)  /// 
ukeep(invt)
drop _m
replace appln_auth="RU" if appln_auth=="SU"
replace appln_auth="DE" if appln_auth=="DD"
replace invt_country="RU" if invt_country=="SU"
replace invt_country="DE" if invt_country=="DD"
duplicates drop
compress
save "$patstpath/mitigation/Complete_4digits_mitigation_benchmark.dta", replace	


**************************************************************************************************************************
*** 		1 -	INVENTIONS 
**************************************************************************************************************************

* All mitigation patents
* use docdb family to measure inventions rather than priorities
use "$patstpath/mitigation/all_mitigation_patents_info", clear
* Define HVI patents as patents filed in at least 2 countries
gen byte HVI = (famsize_offices_EPCgrants_docdb>1)
* Is the patented technology (docdb) granted ?
egen GR = sum(granted), by(docdb techno)
gen granted_docdb = (GR>0)
*Define the publication year of the invention as the earliest publication year within the family
bys docdb : egen publn_year=min(earliest_publn_year)
keep if publn_year>1969 & publn_year<2018
keep technology docdb publn_year invt_country HVI granted_docdb
duplicates drop
gen byte x = 1
* Identify the number of inventors of this technology
bysort docdb technology : egen nb_invt = sum(x)
gen invnbinv=1/nb_invt
*Count number of patents invented per year per country per technology fields 
*(granted or not, HVI or not)
* For both CCMT technologies and the benchmark
bysort technology  invt_country publn_year: egen nb_inv_CCMT = sum(invnbinv)
bysort technology  invt_country publn_year: egen nb_hvi_CCMT = sum(invnbinv*HVI)
bysort technology  invt_country publn_year: egen nb_inv_granted_CCMT = sum(invnbinv*granted_docdb)
bysort technology  invt_country publn_year: egen nb_hvi_granted_CCMT = sum(invnbinv*HVI*granted_docdb)
keep invt_country publn_year technology nb_inv_CCMT nb_hvi_CCMT nb_inv_granted_CCMT nb_hvi_granted_CCMT  
duplicates drop
* Count number of patents invented per year worldwide per technology fields 
*(granted or not, HVI or not)
* For both CCMT technologies and the benchmark
bysort  technology  publn_year: egen world_inv_CCMT = sum(nb_inv_CCMT)
bysort  technology  publn_year: egen world_hvi_CCMT = sum(nb_hvi_CCMT)
bysort  technology  publn_year: egen world_inv_granted_CCMT = sum(nb_inv_granted_CCMT)
bysort  technology  publn_year: egen world_hvi_granted_CCMT = sum(nb_hvi_granted_CCMT)
sort technology  invt_country publn_year
compress
save "$patstpath/mitigation/Mitigation_tech_inventor_ctry_year", replace	

* All innovation using docdb (all technologies)
use "$patstpath/mitigation/Complete_4digits_mitigation_benchmark.dta", clear
* Define High Value Inventions (HVI) as patents filed in at least 2 countries
gen byte HVI = (famsize_offices_EPCgrants_docdb>1)
* Is the patented technology (docdb) granted ?
egen GR = sum(granted), by(docdb techno)
gen granted_docdb = (GR>0)
*Define the publication year of the invention as the earliest publication year within the family
bys docdb : egen publn_year=min(earliest_publn_year)
keep if publn_year>1969 & publn_year<2018
keep technology docdb publn_year invt_country HVI granted_docdb
duplicates drop
gen byte x = 1
* Identify the number of inventors of this technology
bysort technology  docdb: egen nb_invt = sum(x)
gen invnbinv=1/nb_inv
*Count number of patents invented per year per country per technology fields 
*(granted or not, HVI or not)
bysort technology  invt_country publn_year : egen nb_inv_all = sum(invnbinv)
bysort technology  invt_country publn_year : egen nb_hvi_all = sum(invnbinv*HVI)
bysort technology  invt_country publn_year : egen nb_inv_granted_all = sum(invnbinv*granted_docdb)
bysort technology  invt_country publn_year : egen nb_hvi_granted_all = sum(invnbinv*HVI*granted_docdb)
keep technology publn_year invt_country nb_inv_all nb_hvi_all nb_inv_granted_all nb_hvi_granted_all 
duplicates drop
* Count number of patents invented per year worldwide per technology fields 
*(granted or not, HVI or not)
bysort technology publn_year : egen world_inv_all = sum(nb_inv_all)
bysort technology publn_year : egen world_hvi_all = sum(nb_hvi_all)
bysort  technology publn_year: egen world_inv_granted_all = sum(nb_inv_granted_all)
bysort  technology publn_year: egen world_hvi_granted_all = sum(nb_hvi_granted_all)
save "$patstpath/mitigation/Complete_4digits_ALL_inventions_by_invtcountry_year", replace	




**************************************************************************************************************************
*** 		3 - TRANSFERS 
**************************************************************************************************************************


* USING DOCDB: Patents by authority by invt country by appln_year

use "$patstpath/mitigation/all_mitigation_patents_info", clear
keep technology docdb earliest_publn_year invt_country appln_auth appln_id granted
egen GR = sum(granted), by(docdb techno appln_auth)
* Is the patented technology (docdb) granted ?
gen granted_docdb = (GR>0)
drop GR granted
duplicates drop
*Add detailed information on countries where the patent has been filed
*(detailed information on patents filed at the EPO for example)
mmerge appln_id using "$patstpath/general/PRS_EPO_national_phase", unmatched(master) ukeep(country)
replace appln_auth = country if country!=""
drop country
sort docdb_family_id technology  invt_country appln_auth earliest_publn_year granted_docdb
*Define the publication year of the invention as the earliest publication year within the family
bys docdb_family_id : egen publn_year = min(earliest_publn_year)
drop earliest_publn_year
duplicates drop
keep if publn_year >1969 & publn_year < 2018
drop if appln_auth=="EP"
drop if appln_auth=="WO"
drop _m
duplicates drop
gen byte x = 1
* Identify the number of inventors of this technology
bysort docdb technology appln_auth : egen nb_invt = sum(x)
gen invnbinv=1/(nb_invt)
keep technology  docdb publn_year appln_auth invt invnbinv nb_inv granted_docdb
duplicates drop
compress
save "$patstpath/mitigation/all_mitigation_patents_marketdataset", replace

use "$patstpath/mitigation/all_mitigation_patents_marketdataset", clear
*Count number of patents transferred between inventor country and importer/recipient country
* per pair (country/importer) , per year and per sub-technology fields
bysort technology  appln_auth invt publn_year: egen nb_pat_CCMT = sum(invnbinv)
bysort technology  appln_auth invt publn_year: egen nb_pat_granted_CCMT = sum(invnbinv*granted_docdb)
keep technology  appln_auth invt publn_year nb_pat_CCMT  nb_pat_granted_CCMT
duplicates drop
compress
save "$patstpath/mitigation/mitigation_patents_invt_auth_publn_year", replace	


* Benchmark : Patents by authority by invt country by year 
use "$patstpath/mitigation/Complete_4digits_mitigation_benchmark.dta", clear
keep appln_id earliest_publn_year invt_country appln_auth technology famsize_offices_EPCgrants_docdb docdb granted
* Is the patented technology (docdb) granted ?
egen GR = sum(granted), by(docdb techno appln_auth)
gen granted_docdb = (GR>0)
drop GR granted
duplicates drop
*Add detailed information on countries where the patent has been filed
*(detailed information on patents filed at the EPO for example)
mmerge appln_id using "$patstpath/general/PRS_EPO_national_phase", unmatched(master)  /// 
ukeep(country)
replace appln_auth = country if country!=""
drop country
*Define the publication year of the invention as the earliest publication year within the family
bys docdb : egen publn_year=min(earliest_publn_year)
drop earliest_publn_year 
keep if publn_year>1969 & publn_year<2018
drop if appln_auth=="EP"
drop if appln_auth=="WO"
duplicates drop
gen byte x = 1
* Identify the number of inventors of this technology
bysort docdb technology  appln_auth: egen nb_invt = sum(x)
gen invnbinv=1/nb_invt
*Count number of patents transferred between inventor country and importer/recipient country
* per pair (country/importer) , per year and per sub-technology fields
bysort  technology  appln_auth invt_country publn_year : egen nb_pat_all = sum(invnbinv)
bysort  technology  appln_auth invt_country publn_year : egen nb_pat_granted_all = sum(invnbinv*granted_docdb)
keep  appln_auth invt_country publn_year nb_pat_all nb_pat_granted_all technology 
duplicates drop
compress
save "$patstpath/mitigation/Complete_4digits_ALL_patents_invt_auth_year.dta", replace


**************************************************************************************************************************
*** 		4 - FINAL FILES: Merge mitigation technologies (CCMT) with the benchmark (All)
**************************************************************************************************************************

use "$patstpath/mitigation/all_mitigation_patents_info", clear
keep appln_id
duplicates drop
mmerge appln_id using "$patstpath/general/Y_codes", unmatched(master)
drop _m
save "$datapath/Final_database/all_mitigation_patents_Y02codes", replace

* Inventions
use "$patstpath/mitigation/Mitigation_tech_inventor_ctry_year", clear	
order technology invt_country publn_year
sort technology invt_country publn_year
mmerge invt_country publn_year technology  /// 
using "$patstpath/mitigation/Complete_4digits_ALL_inventions_by_invtcountry_year"
drop _m
ren invt_country iso2
*Add ISO3 country code for inventor country
mmerge iso2 using "$otherpath/CountryID", unmatched(none) ukeep(iso3)
ren iso3 invt_iso
ren iso2 invt_country
drop _m
save "$datapath/databases/CCMT_4digits_tech_invt_ctry_year_Induced", replace**Expand dataset and Set missing values to zeros.
*Expand dataset and Set missing values to zeros.
use "$datapath/databases/CCMT_4digits_tech_invt_ctry_year_Induced", clear
summ publn_year
local min =r(min)
local max =r(max)
local nb_years =`max' -`min' + 1
keep technology invt_iso 
sort technology invt_iso
duplicates drop
expand `nb_years'
bysort technology invt_iso: gen publn_year = `min' -1 + _n
mmerge invt_iso technology publn_year  /// 
 using "$datapath/databases/CCMT_4digits_tech_invt_ctry_year_Induced", unmatched(master)
drop _m invt_country
ren invt_iso iso3
mmerge iso3 using "$otherpath/CountryID", unmatched(none) ukeep(iso2)
ren iso3 invt_iso
ren iso2 invt_country
browse
order technology invt_iso publn_year
sort technology invt_iso publn_year
*Set the number of inventions equal to zero if the country has invented at least one patent
*within the three years BEFORE AND the three years AFTER the giving year
by technology invt_iso: replace nb_inv_all = 0 if nb_inv_all==. & ///
[ [ nb_inv_all[_n-1] >0 & nb_inv_all[_n-1] !=. ] |  ///
 [ nb_inv_all[_n-2] >0 & nb_inv_all[_n-2] !=. ] |  ///
 [ nb_inv_all[_n-3] >0 & nb_inv_all[_n-3] !=. ] ] &  ///
 [ [ nb_inv_all[_n+1] >0 & nb_inv_all[_n+1] !=. ] |  ///
 [ nb_inv_all[_n+2] >0 & nb_inv_all[_n+2] !=. ] |  ///
 [ nb_inv_all[_n+3] >0 & nb_inv_all[_n+3] !=. ] ] 
 * Set number of CCMT inventions, granted, HVI ... equals to zero if number of all inventions equals to zero
by technology invt_iso: replace nb_hvi_all = 0 if nb_hvi_all==. & nb_inv_all == 0
by technology invt_iso: replace nb_inv_granted_all = 0 if nb_inv_granted_all==. & nb_inv_all == 0
by technology invt_iso: replace nb_hvi_granted_all = 0 if nb_hvi_granted_all==. & nb_inv_all == 0
replace nb_inv_CCMT=0 if nb_inv_CCMT==. & nb_inv_all !=.
replace nb_hvi_CCMT=0 if nb_hvi_CCMT==. & nb_inv_all !=.
replace nb_inv_granted_CCMT=0 if nb_inv_granted_CCMT==. & nb_inv_granted_all !=.
replace nb_hvi_granted_CCMT=0 if nb_hvi_granted_CCMT==. & nb_inv_granted_all !=.
bysort publn_year technology: egen world_inv_CCMT2 = max(world_inv_CCMT)
bysort publn_year technology: egen world_hvi_CCMT2 = max(world_hvi_CCMT)
replace world_inv_CCMT = world_inv_CCMT2 if world_inv_CCMT ==.
replace world_hvi_CCMT = world_hvi_CCMT2 if world_hvi_CCMT ==.
bysort publn_year technology: egen world_inv_granted_CCMT2 = max(world_inv_granted_CCMT)
bysort publn_year technology: egen world_hvi_granted_CCMT2 = max(world_hvi_granted_CCMT)
replace world_inv_granted_CCMT = world_inv_granted_CCMT2 if world_inv_granted_CCMT ==.
replace world_hvi_granted_CCMT = world_hvi_granted_CCMT2 if world_hvi_granted_CCMT ==.
drop world_inv_CCMT2 world_hvi_CCMT2 world_inv_granted_CCMT2 world_hvi_granted_CCMT2
replace nb_inv_all=nb_inv_CCMT if nb_inv_all==.
replace nb_hvi_all=nb_hvi_CCMT if nb_hvi_all==.
replace nb_inv_granted_all=nb_inv_granted_CCMT if nb_inv_granted_all==.
replace nb_hvi_granted_all=nb_hvi_granted_CCMT if nb_hvi_granted_all==.
bysort publn_year technology: egen world_inv_all2 = max(world_inv_all)
bysort publn_year technology: egen world_hvi_all2 = max(world_hvi_all)
replace world_inv_all=world_inv_all2 if world_inv_all==.
replace world_hvi_all=world_hvi_all2 if world_hvi_all==.
bysort publn_year technology: egen world_inv_granted_all2 = max(world_inv_granted_all)
bysort publn_year technology: egen world_hvi_granted_all2 = max(world_hvi_granted_all)
replace world_inv_granted_all=world_inv_granted_all2 if world_inv_granted_all==.
replace world_hvi_granted_all=world_hvi_granted_all2 if world_hvi_granted_all==.
sort technology invt_iso publn_year
drop world_inv_all2 world_hvi_all2 world_inv_granted_all2 world_hvi_granted_all2
drop _m
* Create a variable with the name of the technology field
gen tech_name =""
replace tech_name ="All mitigation" if technology=="Y02"
replace tech_name ="Buildings" if technology=="Y02B"
replace tech_name ="CCS" if technology=="Y02C"
replace tech_name ="ICT" if technology=="Y02D"
replace tech_name ="Energy" if technology=="Y02E"
replace tech_name  ="Manufacturing" if technology=="Y02P"
replace tech_name ="Transportation" if technology=="Y02T"
replace tech_name ="Waste Management" if technology=="Y02W"


* ==== Add Country Name ===  
*Inventor Country
ren invt_iso iso3
mmerge iso3 using "$otherpath/CountryID", unmatched(master) ukeep(name prio)
keep if prio ==1
drop prio
ren iso3 invt_iso
ren name invt_name

* ==== Add Country Income group (World Bank) ===  
mmerge invt_iso using "$otherpath/income_region_World_Bank_2019", unmatched(master)  /// 
 ukeep(income)

drop if income ==""
drop if invt_name =="Czechia" 

save "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year_4digits", replace


* Transfers
use "$patstpath/mitigation/mitigation_patents_invt_auth_publn_year", clear	
keep if publn_year>1969 & publn_year<2018
mmerge technology appln_auth publn_year invt_country  /// 
using "$patstpath/mitigation/Complete_4digits_ALL_patents_invt_auth_year.dta"
drop _m
ren invt_country iso2
mmerge iso2 using "$otherpath/CountryID", unmatched(none) ukeep(iso3)
ren iso3 invt_iso
ren iso2 invt_country
ren appln_auth iso2
mmerge iso2 using "$otherpath/CountryID", unmatched(none) ukeep(iso3)
ren iso3 patent_office_iso
ren iso2 patent_office
drop _m
compress
save "$datapath/databases/CCMT_4digits_tech_invt_auth_publn_year_Induced", replace
use "$datapath/databases/CCMT_4digits_tech_invt_auth_publn_year_Induced", clear
summ publn_year
local min =r(min)
local max =r(max)
local nb_years =`max' -`min' + 1
sort technology invt_iso patent_office_iso
keep technology invt_iso patent_office_iso
duplicates drop
expand `nb_years'
bysort technology  invt_iso patent_office_iso: gen publn_year = `min' -1 + _n
mmerge invt_iso technology patent_office_iso publn_year /// 
 using "$datapath/databases/CCMT_4digits_tech_invt_auth_publn_year_Induced", ///
unmatched(master)
sort technology invt_iso patent_office_iso publn_year
*Set the number of patents transferred equals to zero if countries have 'exchanged' at least one patent
*within the three years BEFORE AND the three years AFTER the giving year
by technology invt_iso patent_office_iso: replace nb_pat_all = 0 if nb_pat_all==. & ///
[ [ nb_pat_all[_n-1] >0 & nb_pat_all[_n-1] !=. ] |  ///
 [ nb_pat_all[_n-2] >0 & nb_pat_all[_n-2] !=. ] |  ///
 [ nb_pat_all[_n-3] >0 & nb_pat_all[_n-3] !=. ] ] &  ///
 [ [ nb_pat_all[_n+1] >0 & nb_pat_all[_n+1] !=. ] |  ///
 [ nb_pat_all[_n+2] >0 & nb_pat_all[_n+2] !=. ] |  ///
 [ nb_pat_all[_n+3] >0 & nb_pat_all[_n+3] !=. ] ] 
drop patent_office invt_country _m
order technology invt_iso patent_office_iso publn_year
ren invt_iso iso3
mmerge iso3 using "$otherpath/CountryID", unmatched(none) ukeep(iso2)
ren iso3 invt_iso
ren iso2 invt_country
ren patent_office_iso iso3
mmerge iso3 using "$otherpath/CountryID", unmatched(none) ukeep(iso2)
ren iso3 patent_office_iso
ren iso2 patent_office
replace nb_pat_CCMT=0 if nb_pat_CCMT==. & nb_pat_all>=0 & nb_pat_all!=.
replace nb_pat_granted_all=0 if nb_pat_granted_all==. & nb_pat_all>=0 & nb_pat_all!=.
replace nb_pat_granted_CCMT=0 if nb_pat_granted_CCMT==. & nb_pat_all>=0 & nb_pat_all!=.
drop _m
duplicates drop
sort techno invt_iso patent_office_iso publn_year
compress
* Create a variable with the name of the technology field
gen tech_name =""
replace tech_name ="All mitigation" if technology=="Y02"
replace tech_name ="Buildings" if technology=="Y02B"
replace tech_name ="CCS" if technology=="Y02C"
replace tech_name ="ICT" if technology=="Y02D"
replace tech_name ="Energy" if technology=="Y02E"
replace tech_name  ="Manufacturing" if technology=="Y02P"
replace tech_name ="Transportation" if technology=="Y02T"
replace tech_name ="Waste Management" if technology=="Y02W"


* ==== Add Country Name ===  
*Inventor country
ren invt_iso iso3
mmerge iso3 using "$otherpath/CountryID", unmatched(master) ukeep(name prio)
keep if prio ==1
drop prio
ren iso3 invt_iso
ren name invt_name
drop _merge

*Patent office
ren patent_office_iso iso3
mmerge iso3 using "$otherpath/CountryID", unmatched(master) ukeep(name prio)
keep if prio ==1
drop prio
ren iso3 patent_office_iso
ren name patent_office_name
drop _merge


* ==== Add Country income group ===  
* == Income group for inventor country: creation of income_invt ==
mmerge invt_iso using "$otherpath/income_region_World_Bank_2019", unmatched(master)  /// 
ukeep(income region)
rename income income_invt
rename region region_invt
drop _merge

* == Income group for recipient country: creation of income_office ==
mmerge patent_office_iso using "$otherpath/income_region_World_Bank_2019", unmatched(master)  /// 
ukeep(income region)
rename income income_office
rename region region_office
drop _merge

drop if income_office =="" | income_invt ==""
drop if invt_name =="Czechia" | patent_office_name =="Czechia"

save "$datapath/Final_database/mitigation_transfers_tech_inventor_ctry_office_year_4digits", replace

*log close
