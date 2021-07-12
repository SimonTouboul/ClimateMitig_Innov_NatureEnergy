*=== Nature Energy: July 2021
*=== Paper title: 
*				Global Trends in the Invention and Diffusion 
*				of Climate Change Mitigation Technologies

						*== PATENT DATABSE BUILT AT THE SUB-CATEGORY LEVEL
						
*=== Objective: 
* - Add information to selected patents (Mitigation)
* - Build the finale databases for invention (number of technology invented per year
* per country per sub-technology field (6 first CPC codes))
* AND transfers (number of technology transferred between countries (inventor & importer countries)
* per year per technology technology field (6 first CPC codes))



**************************************************************************************************************************
*** 			INITIAL DATA SETS 
**************************************************************************************************************************

clear all

cd "$datapath"

use "$datapath/Y02_SubtechCAT_mitigation.dta", clear
keep technology sub_tech appln_id 
duplicates drop

* info on all mitigation patents (filing and pulication year, application authority)
mmerge appln_id using "$patstpath/general/appln_info", unmatched(none) ///
ukeep(appln_auth appln_year earliest_filing_year earliest_publn_year ipr_type)
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
save "$patstpath/mitigation/all_sub_techCAT_mitigation_patents_info", replace	


**************************************************************************************************************************
*** 		1 -	INVENTIONS 
**************************************************************************************************************************

* All mitigation patents
* use docdb family to measure inventions rather than priorities
use "$patstpath/mitigation/all_sub_techCAT_mitigation_patents_info", clear
* Define High Value Inventions (HVI) as patents filed in at least 2 countries
gen byte HVI = (famsize_offices_EPCgrants_docdb>1)
*Define the publication year of the invention as the earliest publication year within the family
bys docdb : egen publn_year=min(earliest_publn_year)
keep if publn_year>1969 & publn_year<2018
keep technology sub_tech docdb publn_year invt_country HVI
duplicates drop
gen byte x = 1
* Identify the number of inventors of this technology
bysort docdb technology sub_tech: egen nb_invt = sum(x)
gen invnbinv=1/nb_invt
*Count number of patents invented per year per country per sub-technology fields 
*(HVI or not)
* For both CCMT technologies and the benchmark
bysort technology sub_tech invt_country publn_year: egen nb_inv_CCMT = sum(invnbinv)
bysort technology sub_tech invt_country publn_year: egen nb_hvi_CCMT = sum(invnbinv*HVI)
keep technology sub_tech invt_country publn_year nb_inv_CCMT nb_hvi_CCMT  
duplicates drop
* Count number of patents invented per year worldwide per sub-technology fields 
*(HVI or not)
* For both CCMT technologies and the benchmark
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
*Add detailed information on countries where the patent has been filed
*(detailed information on patents filed at the EPO for example)
mmerge appln_id using "$patstpath/general/PRS_EPO_national_phase", unmatched(master) ukeep(country)
replace appln_auth = country if country!=""
drop country
sort docdb_family_id technology sub_tech invt_country appln_auth earliest_publn_year
*Define the publication year of the invention as the earliest publication year within the family
bys docdb_family_id : egen publn_year = min(earliest_publn_year)
drop earliest_publn_year appln_id
duplicates drop
keep if publn_year >1969 & publn_year < 2018
drop if appln_auth=="EP"
drop if appln_auth=="WO"
drop _m
duplicates drop
gen byte x = 1
* Identify the number of inventors of this technology
bysort docdb technology sub_tech appln_auth : egen nb_invt = sum(x)
gen invnbinv=1/(nb_invt)
keep technology sub_tech docdb publn_year appln_auth invt invnbinv nb_inv
duplicates drop
compress
save "$patstpath/mitigation/all_mitigation_subCAT_patents_marketdataset", replace

use "$patstpath/mitigation/all_mitigation_subCAT_patents_marketdataset", clear
*Count number of patents transferred between inventor country and importer/recipient country
* per pair (country/importer) , per year and per sub-technology fields
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
*** 		4 - FINAL FILES:Merge mitigation technologies (CCMT) with the benchmark (All)
**************************************************************************************************************************

* Inventions
use "$patstpath/mitigation/Mitigation_subCAT_inventor_ctry_year", clear	
order technology sub_tech invt_country publn_year
sort technology sub_tech invt_country publn_year
mmerge invt_country publn_year /// 
 using "$patstpath/mitigation/Complete_ALL_inventions_by_invtcountry_year"
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
mmerge invt_iso technology sub_tech publn_year  /// 
 using "$datapath/databases/CCMT_subCAT_invt_ctry_year_Induced", unmatched(master)
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
mmerge appln_auth publn_year invt_country  /// 
using "$patstpath/mitigation/Complete_ALL_patents_invt_auth_year.dta"
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
mmerge invt_iso technology sub_tech patent_office_iso publn_year  /// 
using "$datapath/databases/CCMT_subCAT_invt_auth_publn_year_Induced", ///
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


* ==== Add Country income group ===  
* == Income group for inventor country: creation of income_invt ==
mmerge invt_iso using "$otherpath/income_region_World_Bank_2019", unmatched(master)  /// 
ukeep(income region)
rename income income_invt
rename region region_invt
drop _merge

* == Income group for recipient country: creation of income_office ==
mmerge patent_office_iso using "$otherpath/income_region_World_Bank_2019", unmatched(master) /// 
 ukeep(income region)
rename income income_office
rename region region_office
drop _merge

drop if income_office =="" | income_invt ==""

save "$datapath/Final_database/mitigation_transfers_subCAT_inventor_ctry_office_year", replace


*====
*====
*====
*==== NAME subtechnology fields & add information on CCMT inventions by technology classes

use  "$datapath/Final_database/mitigation_inv_subCAT_inventor_ctry_year", clear
drop if technology ==""
drop nb_inv_all nb_hvi_all nb_inv_granted_all nb_hvi_granted_all world_inv_all ///
 world_hvi_all world_inv_granted_all world_hvi_granted_all
 duplicates drop
* Define name of sub-tehcnology field
gen field = ""
*Y02B
replace field = "RE_inBuildings" if [regexm(sub_tech,"Y02B10")==1]
replace field = "Lighting" if [regexm(sub_tech,"Y02B20")==1]
replace field = "Heating" if [regexm(sub_tech,"Y02B30")==1]
replace field = "Eff_HomeAppliances" if [regexm(sub_tech,"Y02B40")==1]
replace field = "EnergyEff_Elevators" if [regexm(sub_tech,"Y02B50")==1]
replace field = "Eff_EnduseElec" if [regexm(sub_tech,"Y02B70")==1]
replace field = "TermalPeformance" if [regexm(sub_tech,"Y02B80")==1]
replace field = "Others_Y02B" if [regexm(sub_tech,"Y02B90")==1]

*Y02C
replace field = "C02_CCS" if [regexm(sub_tech,"Y02C10")==1]
replace field = "nonC02_CCS" if [regexm(sub_tech,"Y02C20")==1]

*Y02D
replace field = "EnEff_Computing" if [regexm(sub_tech,"Y02D10")==1]
replace field = "EnConso_CommNetworks" if [regexm(sub_tech,"Y02D30")==1]
replace field = "EnConso_WirelineNetworks" if [regexm(sub_tech,"Y02D50")==1]
replace field = "EnConso_WireLessNetworks" if [regexm(sub_tech,"Y02D70")==1]

*Y02E
replace field = "Renewables" if [regexm(sub_tech,"Y02E10")==1]
replace field = "CombustionWithMitig" if [regexm(sub_tech,"Y02E20")==1]
replace field = "Nuclear" if [regexm(sub_tech,"Y02E30")==1]
replace field = "EffElec_ProdDistrib" if [regexm(sub_tech,"Y02E40")==1]
replace field = "NonFossilFuel" if [regexm(sub_tech,"Y02E50")==1]
replace field = "Enabling_Tech" if [regexm(sub_tech,"Y02E60")==1]
replace field = "OtherTech_EnergyConv" if [regexm(sub_tech,"Y02E70")==1]

*Y02P
replace field = "MetalProcess" if [regexm(sub_tech,"Y02P10")==1]
replace field = "ChemicalIndus" if [regexm(sub_tech,"Y02P20")==1]
replace field = "Petrochemical" if [regexm(sub_tech,"Y02P30")==1]
replace field = "MineralsProcess" if [regexm(sub_tech,"Y02P40")==1]
replace field = "AgriAgroIndus" if [regexm(sub_tech,"Y02P60")==1]
replace field = "FinalGoodsProcess" if [regexm(sub_tech,"Y02P70")==1]
replace field = "SectorWideIndusAppli" if [regexm(sub_tech,"Y02P80")==1]
replace field = "OtherProd_Mitig" if [regexm(sub_tech,"Y02P90")==1]

*Y02T
replace field = "Road_Transport" if [regexm(sub_tech,"Y02T10")==1]
replace field = "Rail_Transport" if [regexm(sub_tech,"Y02T30")==1]
replace field = "Aero_Transport" if [regexm(sub_tech,"Y02T50")==1]
replace field = "Maritime_Transport" if [regexm(sub_tech,"Y02T70")==1]
replace field = "Other_Transport" if [regexm(sub_tech,"Y02T90")==1]

*Y02W
replace field = "Wastewater_Treatment" if [regexm(sub_tech,"Y02W10")==1]
replace field = "SolideWaste_Mngment" if [regexm(sub_tech,"Y02W30")==1]
replace field = "Other_Waste" if [regexm(sub_tech,"Y02W90")==1]

ren (world_inv_CCMT world_hvi_CCMT) (world_inv_CCMT_field world_hvi_CCMT_field)
save "$datapath/Final_database/mitigation_inv_subCAT_inventor_ctry_year_subtechNAME", replace
*Add information on CCMT inventions by technology fields (Y02B,Y02C, Y02D, ...)
use "$datapath/Final_database/mitigation_inv_subCAT_inventor_ctry_year_subtechNAME", clear
keep techno sub field publn_year world_inv_CCMT_field world_hvi_CCMT_field
order techno sub field publn_year world_inv_CCMT_field world_hvi_CCMT_field
duplicates drop
mmerge techno publn_year using "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year",  /// 
ukeep(world*) unmatched(none)
ren world_inv_CCMT world_inv_CCMT_tech
ren world_hvi_CCMT world_hvi_CCMT_tech
drop world_inv_granted* world_hvi_granted*
duplicates drop
drop _m
sort techno sub_tech publn_year
save "$datapath/Final_database/CCMT_SubCat_inv_by_fields_inventor_ctry_year.dta", replace


*====
*====
*====
*==== BUILD OTHER CCMT DATABASES TO TARGET SPECIFIC TECHNOLOGIES

*====
*==== ZOOM on Hydrogen technologies: Inventions
use "$patstpath/mitigation/all_sub_techCAT_mitigation_patents_info", clear
keep if sub_tech=="Y02E60" | sub_tech=="Y02E70" | sub_tech=="Y02P30" | sub_tech=="Y02P90" | sub_tech=="Y02T90" 
mmerge appln_id using "$datapath/Y02_SubtechCAT_mitigation.dta", unmatched(none) ukeep(cpc)
*Select technpologies corresponding to various kind of Hydrogen CCMT techno
keep if substr(cpc_code,1,8)=="Y02E60/3" | cpc_code =="Y02E70/10" | cpc_code =="Y02P30/30" | ///
cpc_code =="Y02P90/45" | substr(cpc_code,1,8)=="Y02T90/4"
*name categories
gen Hydrogen_cat =""
replace Hydrogen_cat = "H_Storage" if substr(cpc_code,1,9)=="Y02E60/32"
replace Hydrogen_cat = "H_Distrib" if cpc_code =="Y02E60/34" 
replace Hydrogen_cat = "H_Prod_NoCarbon" if substr(cpc_code,1,9)=="Y02E60/36"
replace Hydrogen_cat = "H_Electrolys_NoFossilFuel" if cpc_code =="Y02E70/10" 
replace Hydrogen_cat = "CCS_H_Prod" if cpc_code =="Y02P30/30" 
replace Hydrogen_cat = "H_Tech_Prod_Process" if cpc_code =="Y02P90/45" 
replace Hydrogen_cat = "H_Fuel_transport" if substr(cpc_code,1,8)=="Y02T90/4"
keep Hydrogen_cat earliest_publn_year invt_country docdb famsize_offices_EPCgrants_docdb
duplicates drop
gen byte HVI = (famsize_offices_EPCgrants_docdb>1)
bys docdb : egen publn_year=min(earliest_publn_year)
keep if publn_year>1969 & publn_year<2018
keep docdb Hydrogen_cat publn_year invt_country HVI
duplicates drop
sort docdb invt_country Hydrogen_cat
quietly by docdb invt_country: gen dup_Hydro = cond(_N==1,0,_n)
keep Hydrogen_cat docdb publn_year invt_country HVI dup_Hydro
duplicates drop
gen byte x = 1
bysort docdb Hydrogen_cat: egen nb_invt = sum(x)
gen invnbinv=1/nb_invt
bysort Hydrogen_cat invt_country publn_year: egen nb_inv_Hcat = sum(invnbinv)
bysort Hydrogen_cat invt_country publn_year: egen nb_hvi_Hcat = sum(invnbinv*HVI)
bysort invt_country publn_year: egen nb_inv_HAll = sum(invnbinv*(dup_Hydro <=1))
bysort invt_country publn_year: egen nb_hvi_HAll = sum(invnbinv*HVI*(dup_Hydro <=1))
keep Hydrogen_cat invt_country publn_year nb_inv_Hcat nb_hvi_Hcat nb_inv_HAll nb_hvi_HAll
duplicates drop
sort invt_country publn_year 
quietly by invt_country publn_year: gen dup_invtyr = cond(_N==1,0,_n)
bysort Hydrogen_cat publn_year: egen world_inv_Hcat = sum(nb_inv_Hcat)
bysort Hydrogen_cat publn_year: egen world_hvi_Hcat = sum(nb_hvi_Hcat)
bysort publn_year: egen world_inv_HAll = sum(nb_inv_HAll*(dup_invtyr<=1))
bysort publn_year: egen world_hvi_HAll = sum(nb_hvi_HAll*(dup_invtyr<=1))
gen techno ="Hydrogen"
sort techno Hydrogen_cat invt_country publn_year
order techno Hydrogen_cat invt_country publn_year
compress
save "$patstpath/mitigation/HydrogenTech_ZOOM_inventor_ctry_year", replace
export excel "$droppath/Analysis/Zoom_Subcat/HydrogenTech_ZOOM_inventor_ctry_year.xlsx", replace firstrow(variables)


*====
*==== ZOOM on energy sub-category solar: Inventions
use "$patstpath/mitigation/all_sub_techCAT_mitigation_patents_info", clear
keep if sub_tech=="Y02E10"
mmerge appln_id using "$datapath/Y02_SubtechCAT_mitigation.dta", unmatched(none) ukeep(cpc)
keep if substr(cpc_code,1,4) =="Y02E"
*Select technologies corresponding to various kind of PV cells techno
keep if cpc_code =="Y02E10/541" | cpc_code =="Y02E10/542" | cpc_code =="Y02E10/543" | ///
cpc_code =="Y02E10/544" | cpc_code =="Y02E10/545" | cpc_code =="Y02E10/546" | ///
cpc_code =="Y02E10/547" | cpc_code =="Y02E10/548" | cpc_code =="Y02E10/549" 
duplicates drop
gen byte HVI = (famsize_offices_EPCgrants_docdb>1)
bys docdb : egen publn_year=min(earliest_publn_year)
keep if publn_year>1969 & publn_year<2018
keep technology sub_tech cpc_code docdb publn_year invt_country HVI
duplicates drop
gen byte x = 1
bysort docdb technology sub_tech cpc_code: egen nb_invt = sum(x)
gen invnbinv=1/nb_invt
bysort technology sub_tech cpc_code invt_country publn_year: egen nb_inv_CCMT_field = sum(invnbinv)
bysort technology sub_tech cpc_code invt_country publn_year: egen nb_hvi_CCMT_field = sum(invnbinv*HVI)
keep technology sub_tech cpc_code invt_country publn_year nb_inv_CCMT_field nb_hvi_CCMT_field 
duplicates drop
bysort  technology sub_tech cpc_code publn_year: egen world_inv_CCMT_field = sum(nb_inv_CCMT_field)
bysort  technology sub_tech cpc_code publn_year: egen world_hvi_CCMT_field = sum(nb_hvi_CCMT_field)
sort technology sub_tech cpc_code invt_country publn_year
order technology sub_tech cpc_code invt_country publn_year
*Name categories
gen PV_cat =""
replace PV_cat = "CuInSe2" if cpc_code =="Y02E10/541"
replace PV_cat = "DyeSensitized" if cpc_code =="Y02E10/542" 
replace PV_cat = "GroupII_VI" if cpc_code =="Y02E10/543" 
replace PV_cat = "GroupIII_V" if cpc_code =="Y02E10/544" 
replace PV_cat = "Microcrystalline" if cpc_code =="Y02E10/545" 
replace PV_cat = "Polycrystalline" if cpc_code =="Y02E10/546" 
replace PV_cat = "Monocrystalline" if cpc_code =="Y02E10/547" 
replace PV_cat = "Amorphous" if cpc_code =="Y02E10/548"
replace PV_cat = "Organic" if cpc_code =="Y02E10/549"
compress
order technology sub_tech cpc_code PV_cat
save "$patstpath/mitigation/SolarPVtech_ZOOM_inventor_ctry_year", replace

*====
*==== ZOOM on energy sub-category wind: Inventions
use "$patstpath/mitigation/all_sub_techCAT_mitigation_patents_info", clear
keep if sub_tech=="Y02E10"
mmerge appln_id using "$datapath/Y02_SubtechCAT_mitigation.dta", unmatched(none) ukeep(cpc)
keep if substr(cpc_code,1,4) =="Y02E"
*Select technologies corresponding to various wind onshore and offshore
keep if cpc_code =="Y02E10/727" | cpc_code =="Y02E10/728"
duplicates drop
gen byte HVI = (famsize_offices_EPCgrants_docdb>1)
bys docdb : egen publn_year=min(earliest_publn_year)
keep if publn_year>1969 & publn_year<2018
keep technology sub_tech cpc_code docdb publn_year invt_country HVI
duplicates drop
gen byte x = 1
bysort docdb technology sub_tech cpc_code: egen nb_invt = sum(x)
gen invnbinv=1/nb_invt
bysort technology sub_tech cpc_code invt_country publn_year: egen nb_inv_CCMT_field = sum(invnbinv)
bysort technology sub_tech cpc_code invt_country publn_year: egen nb_hvi_CCMT_field = sum(invnbinv*HVI)
keep technology sub_tech cpc_code invt_country publn_year nb_inv_CCMT_field nb_hvi_CCMT_field 
duplicates drop
bysort  technology sub_tech cpc_code publn_year: egen world_inv_CCMT_field = sum(nb_inv_CCMT_field)
bysort  technology sub_tech cpc_code publn_year: egen world_hvi_CCMT_field = sum(nb_hvi_CCMT_field)
sort technology sub_tech cpc_code invt_country publn_year
order technology sub_tech cpc_code invt_country publn_year
*Name categories
gen Wind_cat =""
replace Wind_cat = "Wind_Offshore" if cpc_code =="Y02E10/727"
replace Wind_cat = "Wind_Onshore" if cpc_code =="Y02E10/728" 
compress
order technology sub_tech cpc_code Wind_cat
save "$patstpath/mitigation/Windtech_ZOOM_inventor_ctry_year", replace



*====
*==== ZOOM on Electric Vehicles related technologies
use "$patstpath/mitigation/all_sub_techCAT_mitigation_patents_info", clear
keep if sub_tech=="Y0210" | sub_tech=="Y02E70" | sub_tech=="Y02P30" | sub_tech=="Y02P90" | sub_tech=="Y02T90" 
mmerge appln_id using "$datapath/Y02_SubtechCAT_mitigation.dta", unmatched(none) ukeep(cpc)
*Select technpologies corresponding to various kind of PV cells techno
keep if  substr(cpc_code,1,9)=="Y02E10/70" | substr(cpc_code,1,9)=="Y02T90/12"  | cpc_code =="Y02T90/14" | ///
substr(cpc_code,1,9)=="Y02T90/16" | cpc_code =="Y02T90/16" 
*name categories
gen EV_cat =""
replace EV_cat = "En_Storage_Electromobility" if substr(cpc_code,1,9)=="Y02E10/70"
replace EV_cat = "Electric_Charge_EV" if substr(cpc_code,1,9)=="Y02T90/12" 
replace EV_cat = "Plug_In_EV" if cpc_code =="Y02T90/14"
replace EV_cat = "ICT_ElecVehicles" if substr(cpc_code,1,9)=="Y02T90/16" 
replace EV_cat = "Fuel_Cell_Powered_EV" if cpc_code =="Y02T90/16" 
keep EV_cat earliest_publn_year invt_country docdb famsize_offices_EPCgrants_docdb 
duplicates drop
gen byte HVI = (famsize_offices_EPCgrants_docdb>1)
bys docdb : egen publn_year=min(earliest_publn_year)
keep if publn_year>1969 & publn_year<2018
keep docdb EV_cat publn_year invt_country HVI
duplicates drop
sort docdb invt_country EV_cat
quietly by docdb invt_country: gen dup_EV = cond(_N==1,0,_n)
keep EV_cat docdb publn_year invt_country HVI dup_EV
duplicates drop
gen byte x = 1
bysort docdb EV_cat: egen nb_invt = sum(x)
gen invnbinv=1/nb_invt
bysort  EV_cat invt_country publn_year: egen nb_inv_EVcat = sum(invnbinv)
bysort  EV_cat invt_country publn_year: egen nb_hvi_EVcat = sum(invnbinv*HVI)
bysort  invt_country publn_year: egen nb_inv_EVall = sum(invnbinv*(dup_EV <=1))
bysort  invt_country publn_year: egen nb_hvi_EVall = sum(invnbinv*HVI*(dup_EV <=1))
keep  EV_cat invt_country publn_year nb_inv_EVca nb_hvi_EVcat nb_inv_EVall nb_hvi_EVall
duplicates drop
sort invt_country publn_year 
quietly by invt_country publn_year: gen dup_invtyr = cond(_N==1,0,_n)
bysort  EV_cat publn_year: egen world_inv_EVcat = sum(nb_inv_EVcat)
bysort  EV_cat publn_year: egen world_hvi_EVcat = sum(nb_hvi_EVcat)
bysort  publn_year: egen world_inv_EVall = sum(nb_inv_EVall*(dup_invtyr<=1))
bysort  publn_year: egen world_hvi_EVall = sum(nb_hvi_EVall*(dup_invtyr<=1))
gen techno ="Elec_Vehicles"
sort techno EV_cat invt_country publn_year
order techno EV_cat invt_country publn_year
compress
save "$patstpath/mitigation/ElecVehicles_ZOOM_inventor_ctry_year", replace
export excel "$droppath/Analysis/Zoom_Subcat/ElecVehicles_ZOOM_inventor_ctry_year.xlsx", replace firstrow(variables)


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
