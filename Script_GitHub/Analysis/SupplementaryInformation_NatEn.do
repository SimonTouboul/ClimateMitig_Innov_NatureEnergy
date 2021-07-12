*=== Nature Energy: July 2021
*=== Paper title: 
*				Global Trends in the Invention and Diffusion 
*				of Climate Change Mitigation Technologies
*=== Objective: FIGURES & TABLES: Supplementary Information




							*== *==  FIGURES ==* ==*
							
*== Supplementary Figure 1: Yearly trends in CCMT inventions by field.
*== Evolution HVI CCMT by technology fields (1995-2017): Index 1995
use  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year",clear
keep if publn_year <2018 & publn_year >1994
keep technology tech_name publn_year world_hvi_CCMT 
duplicates drop
gen world_CCMT = world_hvi_CCMT if publn_year ==1995
egen world_CCMT1995 = sum(world_CCMT), by(technology)
gen world_CCMT_bas95 = world_hvi_CCMT / world_CCMT1995
keep techno tech_name publn_year world_CCMT_bas95 
duplicates drop
sort techno publn_year
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Figure1.xlsx", replace firstrow(variables)
ren world_CCMT_bas95 hvi
drop tech_name
drop if techno =="Y02"
reshape wide hvi, i(publn_year) j(techno) string
line hvi* publn_year, sort ///
xtitle("Publication year") ytitle("Index [Year(0)] = 1995") ///
 graphregion(fcolor(white))
graph export "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Figure1.png", replace 


*== Supplementary Figure 2: Correlation Renewable R&D and share renewable inventions 
*in all inventions from 1995-2017
*== Correlation share RD&D energy techno in total (OECD GERD) R&D spending (share of GDP) 
*AND share CCMT inventions in all inventions
use "$datapath/Final_database/mitigation_inv_subCAT_inventor_ctry_year_subtechNAME.dta", clear
keep if sub_te =="Y02E10" 
replace techno ="Y02"
mmerge techno invt_iso publn_year using "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year" ///
 , unmatched(master) ukeep(nb_hvi_all)
ren invt_iso iso3
mmerge iso3 using "$otherpath/CountryID", unmatched(master) ukeep(name prio)
keep if prio ==1
drop prio
ren (name publn_year iso3) (country year invt_iso)
replace country ="United States" if country=="United States of America"
mmerge country year using "$droppath\data\R&D_data\Merged_PublicRDDSpending_OECDandIEA_shGDP.dta"
* Select public RD in Renewables
egen Renew_RD = sum(RD_in_GERD) ///
if Eco_Sector == "Renewables" , ///
by(techno country year)
tab country _m
keep if _m ==3
browse
gen sh_RenewPat_in_ALL = nb_hvi_CCMT / nb_hvi_all 
egen avge_sh_RenewPat_12_17 = mean(sh_RenewPat_in_ALL) if year>=2012 & year <=2017, by(country techno)
egen avge_sh_RenewPat_95_17 = mean(sh_RenewPat_in_ALL) if year>=1995 & year <=2017, by(country techno)
egen avge_sh_Renew_12_17 =mean(Renew_RD) if year>=2012 & year <=2017, by(country techno)
egen avge_sh_RenewRD_95_17 = mean(Renew_RD) if year>=1995 & year <=2017, by(country techno)
replace  avge_sh_Renew_12_17 = avge_sh_Renew_12_17
replace  avge_sh_RenewRD_95_17 = avge_sh_RenewRD_95_17
keep Eco_Sector country invt_iso avge*
duplicates drop
drop if avge_sh_RenewPat_12_17 ==.
duplicates drop
keep if Eco_Sector == "Renewables"
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Figure2.xlsx", replace firstrow(variables)
twoway scatter avge_sh_RenewPat_95_17 avge_sh_RenewRD_95_17 if avge_sh_RenewRD_95_17 <0.006


*== Supplementary Figure 3:Correlation of Public green R&D spending in Energy (USD PPP 2020) 
* and share of high value inventions (HVI) CCMT inventions in overall HVI technologies
use "$droppath/data\R&D_data\PublicRDDSpending_IEA2021_USD2020PPPlong.dta", clear
egen world_RD = sum(RD), by(Eco_Sector year)
keep year Eco_Sector  world_RD
* RD_Nuclear = All public Energy R&D spending including Nuclear excluding Fossil Fuels
egen RD_Nuclear = sum(world_RD*(Eco_Sector == "Total")-world_RD*(Eco_Sector == "Fossil_fuels")),by(year)
* RD_Nuclear = All public Energy R&D spending excluding spendings in Nuclear and Fossil Fuels
egen RD_NoNuclear = sum(world_RD*(Eco_Sector == "Total")-world_RD*(Eco_Sector == "Nuclear")-world_RD*(Eco_Sector == "Fossil_fuels")), ///
by(year)
keep year RD_Nuclear RD_NoNuclear
duplicates drop
ren year publn_year
mmerge publn_year using "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year", ukeep(techno world_hvi_all world_hvi_CCMT)
duplicates drop
ren publn_year year 
gen sh_HVI_CCMTinALL = world_hvi_CCMT / world_hvi_all
keep if techno =="Y02" | techno =="Y02E"
sort techno year
order techno year
drop _m
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Figure3.xlsx", replace firstrow(variables)


*== Supplementary Figure 4: Evolution of yearly wind inventions
use "$patstpath/mitigation/Windtech_ZOOM_inventor_ctry_year", clear
keep if Wind_cat =="Wind_Offshore" | Wind_cat=="Wind_Onshore"
keep Wind_cat publn_year world_hvi_CCMT_field
sort Wind_cat publn_year
duplicates drop
keep if publn_year>=1995 & publn_year <=2017
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Figure4.xlsx", replace firstrow(variables)


*== Supplementary Figure 5: Evolution of yearly Information and 
*Communication Technology (ICT) inventions
use  "$datapath/Final_database/CCMT_SubCat_inv_by_fields_inventor_ctry_year.dta" , clear
keep if field =="EnEff_Computing" | field=="EnConso_WirelineNetworks" | field=="EnConso_WireLessNetworks"
keep field publn_year world_hvi_CCMT_field
sort field publn_year
duplicates drop
keep if publn_year>=1995 & publn_year <=2017
gen world_CCMT = world_hvi_CCMT_field if publn_year ==1995
egen world_CCMT1995 = sum(world_CCMT), by(field)
gen world_CCMT_Index95= world_hvi_CCMT_field / world_CCMT1995
keep field publn_year world_hvi_CCMT_field world_CCMT_Index95
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Figure5.xlsx", replace firstrow(variables)


*== Supplementary Figure 6: Evolution of yearly Waste Management inventions
use  "$datapath/Final_database/CCMT_SubCat_inv_by_fields_inventor_ctry_year.dta" , clear
keep if field =="Wastewater_Treatment" | field=="SolideWaste_Mngment" 
keep field publn_year world_hvi_CCMT_field
sort field publn_year
duplicates drop
keep if publn_year>=1995 & publn_year <=2017
gen world_CCMT = world_hvi_CCMT_field if publn_year ==1995
egen world_CCMT1995 = sum(world_CCMT), by(field)
gen world_CCMT_Index95= world_hvi_CCMT_field / world_CCMT1995
keep field publn_year world_hvi_CCMT_field world_CCMT_Index95
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Figure6.xlsx", replace firstrow(variables)


*== Supplementary Figure 7: Yearly evolution of global CCMT share for selected countries
use  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year",clear
keep if publn_year <=2017 & publn_year >=1995
 keep if techno =="Y02"
keep techno invt_iso publn_year nb_hvi_CCMT 
duplicates drop
egen world_hvi = sum(nb_hvi_CCMT), by(publn_year techno)
gen sh_world_HVI = 100 * nb_hvi_CCMT / world_hvi
sort publn_year
keep techno invt_iso publn_year sh_world_HVI
duplicates drop
* Identify "Rest of the world" by invt_iso == "OOO"
replace invt_iso ="OOO" if invt_iso !="USA" & invt_iso !="FRA" & invt_iso !="DEU" & invt_iso !="JPN" ///
& invt_iso !="KOR" & invt_iso !="CHN" & invt_iso !="TWN" & invt_iso !="GBR" ///
& invt_iso !="ITA" & invt_iso !="CAN"
egen s=sum(sh_world_HVI), by(invt_iso publn_year techno)
replace sh_world_HVI =s
drop s
duplicates drop
keep if invt_iso =="USA" | invt_iso =="FRA" | invt_iso =="DEU" | invt_iso =="JPN" ///
| invt_iso =="KOR" | invt_iso =="CHN" | invt_iso =="TWN" | invt_iso =="GBR" ///
 | invt_iso =="ITA" | invt_iso =="CAN" | invt_iso =="OOO"
sort techno invt_iso publn_year
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Figure7.xlsx", replace firstrow(variables)
reshape wide sh_world_HVI, i(publn_year) j(invt_iso) str
 foreach var of varlist sh_world_HVI* {
   	local newname : subinstr local var "sh_world_HVI" ""
  	ren `var' `newname', replace
 } 
line USA FRA DEU JPN KOR CHN TWN GBR ITA CAN OOO publn_year , sort ///
xtitle("Publication year") ytitle("Share of global HVI CCMT inventions") ///
ylabel(0 (5) 30 ) ///
graphregion(fcolor(white))
graph export "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Figure7.png", replace


*== Supplementary Figure 8: Share of CCMT invented or received via transfers 
* per country relative to global share of CO2-emissions

*=== Share of worldwide transfered CCMT HVI invented and received per country 
* relative to their CO2 emissions
*NOTE: CO2 emissions data come from Our World In Data, and can be downlodaded threw this link:
*https://github.com/owid/co2-data#readme
import excel  "$otherpath\co2_emissions_tons_OurWorldInData.xlsx", clear firstrow
ren (iso_country year) (invt_iso publn_year)
mmerge invt_iso publn_year using "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year", ///
unmatched(none)
keep if techno =="Y02"
keep if publn_year<=2017 & publn_year >=2013
duplicates drop
egen tot_inv_HVI_1317 = sum(nb_hvi_CCMT), by(invt_iso)
egen mean_inv_HVI_1317 = mean(nb_hvi_CCMT), by(invt_iso)
egen tot_co2_1317 = sum(co2), by(invt_iso)
egen mean_co2_1317 = mean(co2), by(invt_iso)
keep techno invt_iso ///
tot_inv_HVI_1317 mean_inv_HVI_1317 ///
tot_co2_1317 mean_co2_1317
duplicates drop
order techno invt_iso ///
tot_inv_HVI_1317 mean_inv_HVI_1317 ///
tot_co2_1317 mean_co2_1317
ren invt_iso patent_office_iso
mmerge techno patent_office_iso using "$datapath/Final_database/mitigation_transfers_tech_inventor_ctry_office_year", ///
unmatched(none) ukeep(publn_year patent_office_name nb_pat_CCMT invt_iso)
keep if publn_year<=2017 & publn_year >=2013
keep if invt_iso != patent_office_iso
duplicates drop
egen yr_CCMT_1317 = sum(nb_pat_CCMT), by(publn_year patent_office_iso)
keep patent_office_name patent_office_iso publn_year tot_* mean* yr_CCMT_1317
duplicates drop
egen tot_imp_HVI_1317 = sum(yr_CCMT_1317), by(patent_office_iso)
egen mean_imp_HVI_1317 = mean(yr_CCMT_1317), by(patent_office_iso)
keep patent_office_name patent_office_iso tot_* mean* 
order patent_office_name patent_office_iso tot_* mean* 
duplicates drop
ren(patent_office_name patent_office_iso) (Country iso)
order Country iso 
sort Country
browse
order iso Country tot_inv_HVI_1317 mean_inv_HVI_1317 tot_imp_HVI_1317 mean_imp_HVI_1317
egen world_CO2 = sum(tot_co2_1317)
gen sh_CO2world = tot_co2_1317 / world_CO2
egen world_INV = sum(tot_inv_HVI_1317)
gen sh_INVworld = tot_inv_HVI_1317 / world_INV
gen INV_vsCO2 = sh_INVworld / sh_CO2world
egen world_IMP = sum(tot_imp_HVI_1317)
gen sh_IMPworld = tot_imp_HVI_1317 / world_IMP
gen IMP_vsCO2 = sh_IMPworld / sh_CO2world
gen IMPINV_vsCO2 = INV_vsCO2 + IMP_vsCO2
gsort -IMPINV_vsCO2
export excel  "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Figure7.xlsx", replace firstrow(variables)


*== Supplementary Figure 9: Transfer rates across different technologies
*== Average transfer rates by technology fields 2013-2017
use  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year", clear
keep if publn_year >=2013 & publn_year <=2017
keep world_hvi_CCMT world_inv_CCMT world_hvi_all world_inv_all publn_year technology tech_name
duplicates drop
sort tech_nam publn_year
gen export_rate_year_CCMT = 100 * world_hvi_CCMT / world_inv_CCMT
gen export_rate_year_all = 100 * world_hvi_all / world_inv_all
sort techno
by technology: egen export_rate_CCMT_1317 = mean(export_rate_year_CCMT)
by technology: egen export_rate_all_1317 = mean(export_rate_year_all) if technology =="Y02"
drop export_rate_year_CCMT export_rate_year_all
keep techno tech_name export_rate*
duplicates drop 
set obs `=_N+1'
replace export_rate_all_1317 = sum(export_rate_all_1317)
replace export_rate_CCMT_1317 = export_rate_all_1317 if tech_name == ""
replace tech_name  = "All technology fields" if  tech_name == ""
ren export_rate_CCMT_1317 export_rate_1317
keep tech_name  export_rate_1317
duplicates drop
gen cat =0
replace cat = 2 if  tech_name =="All technology fields" 
replace cat = 1 if   tech_name=="All mitigation" 
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Figure8.xlsx", replace firstrow(variables)
graph bar export_rate_1317 , over(tech_name , label(angle(45)) ) ///
ytitle("Share of technology transferred (%)") ylab(, angle(0) nogrid) ///
legend(label(2 "2013-2017") ) ///
graphregion(fcolor(white))


						*== *==  TABLES ==* ==*
							
*== Supplementary Table 1: Renewable R&D and share renewable inventions
* in all inventions from 1995-2017. 
*== Share RD&D energy techno in total (OECD GERD) R&D spending (share of GDP) 
* AND share CCMT inventions in all inventions
use "$datapath/Final_database/mitigation_inv_subCAT_inventor_ctry_year_subtechNAME.dta", clear
keep if sub_te =="Y02E10" 
replace techno ="Y02"
mmerge techno invt_iso publn_year using "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year" ///
 , unmatched(master) ukeep(nb_hvi_all)
ren invt_iso iso3
mmerge iso3 using "$otherpath/CountryID", unmatched(master) ukeep(name prio)
keep if prio ==1
drop prio
ren (name publn_year iso3) (country year invt_iso)
replace country ="United States" if country=="United States of America"
mmerge country year using "$droppath\data\R&D_data\Merged_PublicRDDSpending_OECDandIEA_shGDP.dta"
* Select public RD in Renewables
egen Renew_RD = sum(RD_in_GERD) ///
if Eco_Sector == "Renewables" , ///
by(techno country year)
tab country _m
keep if _m ==3
browse
gen sh_RenewPat_in_ALL = nb_hvi_CCMT / nb_hvi_all 
egen avge_sh_RenewPat_12_17 = mean(sh_RenewPat_in_ALL) if year>=2012 & year <=2017, by(country techno)
egen avge_sh_RenewPat_95_17 = mean(sh_RenewPat_in_ALL) if year>=1995 & year <=2017, by(country techno)
egen avge_sh_Renew_12_17 =mean(Renew_RD) if year>=2012 & year <=2017, by(country techno)
egen avge_sh_RenewRD_95_17 = mean(Renew_RD) if year>=1995 & year <=2017, by(country techno)
replace  avge_sh_Renew_12_17 = avge_sh_Renew_12_17
replace  avge_sh_RenewRD_95_17 = avge_sh_RenewRD_95_17
keep Eco_Sector country invt_iso avge*
duplicates drop
drop if avge_sh_RenewPat_12_17 ==.
duplicates drop
keep if Eco_Sector == "Renewables"
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Table1.xlsx", replace firstrow(variables)

*== Supplementary Table 2: Yearly number of high-value CCMT inventions in specific country,
* all HVI inventions in country, and the share of CCMT in all inventions
use  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year",clear
keep if publn_year <=2017 & publn_year >=1995
keep if techno =="Y02"
keep techno invt_iso invt_name publn_year nb_hvi_CCMT nb_hvi_all
duplicates drop
keep if invt_iso =="USA" | invt_iso =="FRA" | invt_iso =="DEU" | invt_iso =="JPN" ///
| invt_iso =="KOR" | invt_iso =="CHN" | invt_iso =="TWN" | invt_iso =="GBR" ///
 | invt_iso =="ITA" | invt_iso =="CAN" | invt_iso =="SWE"
sort techno invt_iso publn_year
drop invt_iso
gen spe_hvi = nb_hvi_CCMT / nb_hvi_all
order techno invt_name
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Table2.xlsx", replace firstrow(variables)


*== Supplementary Table 3: Detailed NAC codes for trade analysis


*== Supplementary Table 4: HS codes for green traded products analysis


*== Supplementary Table 5: FDI deals 2012-2016
*== Matrix deals FDI between among groups 
use "$zephyrpath/Analysis_Zephyr_mitigation_2012_2016.dta", clear
keep technology targetcountrycode acquirorcountrycode nb_deal_bytech_pair year targetincome acquirorincome
duplicates drop
replace targetincome ="Middle income" if targetincome=="Lower middle income"
replace targetincome ="Middle income" if targetincome=="Upper middle income"
replace acquirorincome ="Middle income" if acquirorincome=="Lower middle income"
replace acquirorincome ="Middle income" if acquirorincome=="Upper middle income"
egen tot_deal_byincome = sum(nb_deal_bytech_pair), by(technology targetincome acquirorincome) 
egen tot_deal_by_tech=sum(nb_deal_bytech_pair), by(technology)
gen sh = 100 * tot_deal_byincome / tot_deal_by_tech
keep technology targetincome acquirorincome tot_deal_byincome tot_deal_by_tech sh
duplicates drop
sort technology sh
browse
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Table5.xlsx", firstrow(variables) replace

*== Supplementary Table 6: Transfer of green traded products from 2013-2019


*== Supplementary Table 7: Yearly export of green products by income class 
*based on World Bank ( 2020) classification


*== Supplementary Table8 to Table 11: Average % invention transfer between source (left side)
*  and destination (horizontal)
use "$datapath/Final_database/mitigation_transfers_tech_inventor_ctry_office_year", clear
keep if publn_year >=2013 & publn_year <=2017
keep if technology == "Y02"
drop if income_office==" |region_office==" |income_invt==" |region_invt=="
drop if invt_country ==" |patent_office=="
replace income_office ="Middle income" if income_office == "Upper middle income"
replace income_office ="Middle income" if income_office == "Lower middle income"
replace income_invt ="Middle income" if income_invt == "Upper middle income"
replace income_invt ="Middle income" if income_invt == "Lower middle income"
drop if income_invt =="Low income" | income_office =="Low income"
*Drop coutrnies
drop if patent_office_name =="India" | patent_office_name =="Saudi Arabia" ///
|patent_office_name =="Dominican Republic" |patent_office_name =="Czechia" ///
|patent_office_name =="Hungary" | patent_office_name =="Bosnia and Herzegovina"
drop if invt_name =="India" | invt_name =="Saudi Arabia" |invt_name =="Dominican Republic" ///
|invt_name =="Czechia" |invt_name =="Hungary" | invt_name =="Bosnia and Herzegovina"
egen tot_transfer = sum(nb_pat_CCMT) if invt_country != patent_office
egen nb_inv_ctries_CCMT = sum(nb_pat_CCMT) if invt_country != patent_office, by(invt_iso patent_office_iso)
keep if nb_inv_ctries_CCMT !=.
keep invt_name patent_office_name nb_inv_ctries_CCMT tot_transfer
duplicates drop
gen share_transfer_CCMT = 100 * nb_inv_ctries_CCMT/tot_transfer
keep invt_name patent_office_name share_transfer_CCMT
*WE KEEP ONLY PAIRS OF COUTNRIES EXCHANGIONG AT LEAST 0.001% OF all CCMT technologies
keep if share >=0.01
gsort -share_transfer
*Change invt_names
replace invt_name ="USA" if invt_name =="United States of America"
replace invt_name ="SouthKorea" if invt_name =="South Korea"
replace invt_name ="UK" if invt_name =="United Kingdom"
replace invt_name ="CzechRep" if invt_name =="Czech Republic"
replace invt_name ="SaudiArabia" if invt_name =="Saudi Arabia"
replace invt_name ="SouthAfrica" if invt_name =="South Africa"
replace invt_name ="NewZealand" if invt_name =="New Zealand"
replace invt_name ="HongKong" if invt_name =="Hong Kong"
replace invt_name ="UAE" if invt_name =="United Arab Emirates"
replace invt_name ="CostaRica" if invt_name =="Costa Rica"
replace invt_name ="Brunei" if invt_name =="Brunei Darussalam"
replace invt_name ="SriLanka" if invt_name =="Sri Lanka"
replace invt_name ="DominicanRe" if invt_name =="Dominican Republic"
replace invt_name ="BosniaHerzegovina" if invt_name =="Bosnia and Herzegovina"
replace invt_name ="SanMarino" if invt_name =="San Marino"
replace invt_name ="Salvador" if invt_name =="El Salvador"

*Change patent office name
replace patent_office_name ="USA" if patent_office_name =="United States of America"
replace patent_office_name ="SouthKorea" if patent_office_name =="South Korea"
replace patent_office_name ="UK" if patent_office_name =="United Kingdom"
replace patent_office_name ="CzechRep" if patent_office_name =="Czech Republic"
replace patent_office_name ="SaudiArabia" if patent_office_name =="Saudi Arabia"
replace patent_office_name ="SouthAfrica" if patent_office_name =="South Africa"
replace patent_office_name ="NewZealand" if patent_office_name =="New Zealand"
replace patent_office_name ="HongKong" if patent_office_name =="Hong Kong"
replace patent_office_name ="UAE" if patent_office_name =="United Arab Emirates"
replace patent_office_name ="CostaRica" if patent_office_name =="Costa Rica"
replace patent_office_name ="Brunei" if patent_office_name =="Brunei Darussalam"
replace patent_office_name ="SriLanka" if patent_office_name =="Sri Lanka"
replace patent_office_name ="DominicanRe" if patent_office_name =="Dominican Republic"
replace patent_office_name ="BosniaHerzegovina" if patent_office_name =="Bosnia and Herzegovina"
replace patent_office_name ="SanMarino" if patent_office_name =="San Marino"
replace patent_office_name ="Salvador" if patent_office_name =="El Salvador"
*Reshape to get matrix
ren share sh
reshape wide sh, i(invt_name) j(patent_office_name) string
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/SI_Table8Table11.xlsx", firstrow(variables) replace

*=============================================
*=============================================
*=============================================	END


*=============================================	END
*=============================================
*=============================================
*=============================================
*=============================================
