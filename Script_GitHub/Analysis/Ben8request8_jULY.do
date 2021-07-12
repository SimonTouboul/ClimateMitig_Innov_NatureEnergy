*WHAT BEN ASKED 8JULY




*== FIGUREX1: Source and destination of transferred climate change mitigation technologies from 2013-2017
*Matrix: transfer high-BRICS
use "$datapath/Final_database/mitigation_transfers_tech_inventor_ctry_office_year", clear
keep if publn_year >=2013 & publn_year <=2017
keep if technology == "Y02"
drop if income_office=="" |income_invt==""
drop if invt_country =="" |patent_office==""
*target BRICS (excluding India)
replace income_office ="BRICS" if patent_office_iso =="BRA" | patent_office_iso =="CHN" | ///
patent_office_iso =="RUS" | patent_office_iso =="ZAF" | patent_office_iso =="IND"
replace income_office ="Middle income" if income_office == "Upper middle income"
replace income_office ="Middle income" if income_office == "Lower middle income"
*target BRICS (excluding India)
replace income_invt ="BRICS" if invt_iso =="BRA" | invt_iso =="CHN" | ///
invt_iso =="RUS" | invt_iso =="ZAF" | invt_iso =="IND"
replace income_invt ="Middle income" if income_invt == "Upper middle income"
replace income_invt ="Middle income" if income_invt == "Lower middle income"
egen tot_transfer = sum(nb_pat_CCMT) if invt_country != patent_office
egen nb_inv_income_CCMT = sum(nb_pat_CCMT) if invt_country != patent_office, by(income_office income_invt)
keep if nb_inv_income !=.
keep nb_inv_income income_office income_invt tot_transfer
duplicates drop
gen share_transfer_CCMT = 100 * nb_inv_income/tot_transfer
keep nb_inv_income income_office income_invt share_transfer tot_transfer
sort income_invt income_off
order income* share
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/FigureX1.xlsx", replace firstrow(variables)
 
 
*== Matrix transfers countries (mitigation) 2013-2017: 
* Threshold 0.001
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
keep if share >=0.001
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
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/FigureX2_001.xlsx", replace firstrow(variables)



*== Matrix transfers countries (mitigation) 2013-2017: 
* Threshold 0.1
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
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/FigureX2_01.xlsx", replace firstrow(variables)


*=== Share of worldwide transfered CCMT HVI invented and received per country 
* relative to their CO2 emissions
*NOTE: CO2 emissions data come from Our World In Data, and can be downlodaded threw this link:
*https://github.com/owid/co2-data#readme
import excel  "$otherpath\co2_emissions_tons_OurWorldInData.xlsx", clear firstrow
ren iso_country invt_iso
use  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year",clear
keep if techno =="Y02"
keep if publn_year<=2017 & publn_year >=2013
egen tot_inv_HVI_1317 = sum(nb_hvi_CCMT), by(invt_iso)
egen mean_inv_HVI_1317 = mean(nb_hvi_CCMT), by(invt_iso)
keep techno invt_iso tot_inv_HVI_1317 mean_inv_HVI_1317
duplicates drop
ren invt_iso patent_office_iso
mmerge techno patent_office_iso using "$datapath/Final_database/mitigation_transfers_tech_inventor_ctry_office_year", ///
unmatched(none) ukeep(publn_year patent_office_name nb_pat_CCMT invt_iso)
keep if publn_year<=2017 & publn_year >=2013
keep if invt_iso != patent_office_iso
egen yr_CCMT_1317 = sum(nb_pat_CCMT), by(publn_year patent_office_iso)
keep patent_office_name patent_office_iso publn_year tot_* mean* yr_CCMT_1317
duplicates drop
egen tot_imp_HVI_1317 = sum(yr_CCMT_1317), by(patent_office_iso)
egen mean_imp_HVI_1317 = mean(yr_CCMT_1317), by(patent_office_iso)
keep patent_office_name patent_office_iso tot_* mean*
duplicates drop
ren(patent_office_name patent_office_iso) (Country iso)
sort Country
browse
order iso Country tot_inv_HVI_1317 mean_inv_HVI_1317 tot_imp_HVI_1317 mean_imp_HVI_1317
export excel "$droppath/Analysis/SELECT_NatEn/Appendix/FigureX3.xlsx", replace firstrow(variables)





import excel  "$otherpath\co2_emissions_tons_OurWorldInData.xlsx", clear firstrow
ren iso_country invt_iso

