*=== Nature Energy: July 2021
*=== Paper title: 
*				Global Trends in the Invention and Diffusion 
*				of Climate Change Mitigation Technologies
*=== Objective: FIGURES & TABLES: main text

 		 
		
*== NUMBERS IN THE MAIN TEXT & TABLE 1: : Technology field, EPO classification, definition, and number of inventions.
*== Number of HVI and all CCMT inventions(1995-2017) 
*== Share of each CCMT technology classes in all CCMT 1995-2000 & 2013-2017
use  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year",clear
keep if publn_year <2018 & publn_year >1994
keep technology tech_name world_hvi_all world_hvi_CCMT world_inv_CCMT publn_year
duplicates drop
*=Total number of hvi CCMT inventions patented worldwide for the period 1995-2017,
*=by CCMT technology fields
egen hvi_CCMT_1995_2017 =sum(world_hvi_CCMT) if publn_year <=2017 & publn_year >=1995, by(techno)
*=Total number of all CCMT inventions patented worldwide for the period 1995-2017,
*=by CCMT technology fields
egen inv_CCMT_1995_2017 =sum(world_inv_CCMT) if publn_year <=2017 & publn_year >=1995, by(techno)
keep techno hvi* inv_*
duplicates drop
egen hvi_Y02_1995_2017 = max(hvi_CCMT_1995_2017)
egen inv_Y02_1995_2017 = max(inv_CCMT_1995_2017)
*=Share of hvi CCMT inventions in all CCMT inventions patented worldwide for the period 1995-2017,
gen sh_hvi_in_inv_CCMT_9517 = 100 * hvi_Y02_1995_2017 / inv_Y02_1995_2017
sort techno
duplicates drop
export excel "$droppath/Analysis/SELECT_NatEn/Main/Table1_NbText.xlsx", replace firstrow(variables)


*== FIGURE1: Evolution of global high-value climate change mitigation technology inventions from 1995-2017
*== Evolution HVI CCMT vs All technologies (1995-2017): Index 1995
use  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year",clear
keep if publn_year <2018 & publn_year >1994
keep if technology =="Y02"
keep world_hvi_CCMT world_hvi_all publn_year
duplicates drop
gen world_CCMT = world_hvi_CCMT if publn_year ==1995
egen world_CCMT1995 = sum(world_CCMT)
gen world_all = world_hvi_all if publn_year ==1995
egen world_all1995 = sum(world_all)
gen world_CCMT_bas = world_hvi_CCMT / world_CCMT1995
gen world_all_bas = world_hvi_all / world_all1995
keep world_CCMT_bas world_all_bas publn_year
duplicates drop
browse
sort publn_year
line world_CCMT_bas world_all_bas publn_year, sort ///
legend(label(1 "CCMT inventions") label(2 "All technologies inventions")) ///
xtitle("Publication year") ytitle("Index [Year(0)] = 1995") ///
graphregion(fcolor(white))
graph export "$droppath/Analysis/SELECT_NatEn/Main/Figure1.png", replace	
export excel "$droppath/Analysis/SELECT_NatEn/Main/Figure1.xlsx", replace firstrow(variables)


*== FIGURE2: Average annual growth of climate change mitigation technologies. 
*== Average growth rate by CCMT tech fields (1995-2012) vs (2013-2017)
use  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year",clear
keep if publn_year <2018 & publn_year >1993
keep technology tech_name publn_year world_hvi_CCMT world_hvi_all
sort technology publn_year
duplicates drop
bys technology: gen growthCCMT = 100*(world_hvi_CCMT[_n] - world_hvi_CCMT[_n-1]) / world_hvi_CCMT[_n-1] 
keep publn_year growth* technology tech_name
duplicates drop
browse  
*Growth rate 1995-2012
keep if  publn_year <=2012 & publn_year >=1995
egen m_growthCCMT9512 = mean((growthCCMT) * ( publn_year <=2012 & publn_year >=1995)), by(technology)
keep m_growth* techno tech_name
duplicates drop
save "$droppath/Analysis/SELECT_NatEn/Main/Figure2A.dta", replace
*Growth rate 2013-2017
use  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year",clear
keep if  publn_year <=2017 & publn_year >=2013
keep technology tech_name publn_year world_hvi_CCMT world_hvi_all
sort technology publn_year
duplicates drop
bys technology: gen growthCCMT = 100*(world_hvi_CCMT[_n] - world_hvi_CCMT[_n-1]) / world_hvi_CCMT[_n-1] 
keep publn_year growth* technology tech_name
duplicates drop
egen m_growthCCMT1317 = mean((growthCCMT) * ( publn_year <=2017 & publn_year >=2013)), by(technology)
keep techno tech_name  m_growth*
duplicates drop
mmerge techno using  "$droppath/Analysis/SELECT_NatEn/Main/Figure2A.dta"
browse
drop _m
export excel "$droppath/Analysis/SELECT_NatEn/Main/Figure2.xlsx", replace firstrow(variables)


*== FIGURE3: Correlation of oil prices and public energy R&D with inventions in climate change mitigation technologies
*== Evolution share CCMT technologies and oil prices (1970-2017)
use  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year", clear
keep if publn_year <2018 & publn_year >1969
keep if technology =="Y02"
keep techno   world_hvi_CCMT world_hvi_all publn_year
duplicates drop
mmerge publn_year using  "C:\Users\Simon Touboul\Dropbox\Mitig_Innov_Update\data\Crude_oil_prices", unmatched(master)
gen sh_hvi_CCMTinALL = 100 * world_hvi_CCMT / world_hvi_all
keep techno   sh_hvi_CCMTinALL publn_year Crude_oil
duplicates drop
browse
sort publn_year
graph twoway (line sh_hvi_CCMTinALL publn_year, sort yaxis(1) ytitle("Share of HVI CCMT in all technologies", axis(1))) ///
(line Crude_oil publn_year, sort yaxis(2)  ytitle("Oil price (USD/brl 2010 real)", axis(2))) , ///
legend(label(1 "Share CCMT inventions") label(2 "Oil price")) ///
xtitle("Publication year") ///
ylabel(0 (10) 120, angle(0) format(%5.0f) axis(2))  ///
ylabel(0 (1) 11, angle(0) format(%5.0f) axis(1)) ///
 graphregion(fcolor(white))
 graph export "$droppath/Analysis/SELECT_NatEn/Main/Figure3.png", replace	
 export excel "$droppath/Analysis/SELECT_NatEn/Main/Figure3.xlsx", replace firstrow(variables)
 
 
 
 *== FIGURE4: Yearly patent applications across sub-sectors
*== FIGURE4a: ENERGY: Hydrogen, Renewables & Enabling technologies (Storage)
use "$patstpath/mitigation/HydrogenTech_ZOOM_inventor_ctry_year" , clear
keep techno publn_year world_hvi_HAll
ren (techno world_hvi_HAll) (field world_hvi_CCMT_field)
duplicates drop
append using "$datapath/Final_database/CCMT_SubCat_inv_by_fields_inventor_ctry_year.dta"
keep if field =="Renewables" | field=="Enabling_Tech" | field=="Hydrogen"
keep field publn_year world_hvi_CCMT_field
sort field publn_year
duplicates drop
keep if publn_year>=1995 & publn_year <=2017
gen world_CCMT = world_hvi_CCMT_field if publn_year ==1995
egen world_CCMT1995 = sum(world_CCMT), by(field)
gen world_CCMT_Index95= world_hvi_CCMT_field / world_CCMT1995
keep field  publn_year world_hvi_CCMT_field world_CCMT_Index95
 export excel "$droppath/Analysis/SELECT_NatEn/Main/Figure4a.xlsx", replace firstrow(variables)
*== FIGURE4b: ENERGY SUB-CATEGORY SOLAR: Polycrystalline PV, Organic PV, CUInSe2
use  "$patstpath/mitigation/SolarPVtech_ZOOM_inventor_ctry_year" , clear
keep if PV_cat =="Organic" | PV_cat=="CuInSe2" | PV_cat=="Polycrystalline"
keep PV_cat publn_year world_hvi_CCMT_field
sort PV_cat publn_year
duplicates drop
keep if publn_year>=1995 & publn_year <=2017
gen world_CCMT = world_hvi_CCMT_field if publn_year ==1995
egen world_CCMT1995 = sum(world_CCMT), by(PV_cat)
gen world_CCMT_Index95= world_hvi_CCMT_field / world_CCMT1995
keep PV_cat publn_year world_hvi_CCMT_field world_CCMT_Index95
export excel "$droppath/Analysis/SELECT_NatEn/Main/Figure4b.xlsx", replace firstrow(variables)
*== FIGURE4c: BUILDINGS: Efficient home appliances, Heating
use  "$datapath/Final_database/CCMT_SubCat_inv_by_fields_inventor_ctry_year.dta" , clear
keep if field =="Lighting" | field=="Heating" | field=="Eff_HomeAppliances"
keep field publn_year world_hvi_CCMT_field
sort field publn_year
duplicates drop
keep if publn_year>=1995 & publn_year <=2017
gen world_CCMT = world_hvi_CCMT_field if publn_year ==1995
egen world_CCMT1995 = sum(world_CCMT), by(field)
gen world_CCMT_Index95= world_hvi_CCMT_field / world_CCMT1995
keep field publn_year world_hvi_CCMT_field world_CCMT_Index95
export excel "$droppath/Analysis/SELECT_NatEn/Main/Figure4d.xlsx", replace firstrow(variables)
*== FIGURE4d: MANUFACTURING: Chemical Industry, Industrial and consumer goods,
* Metal processing & Minerals processing
use  "$datapath/Final_database/CCMT_SubCat_inv_by_fields_inventor_ctry_year.dta" , clear
keep if field =="MetalProcess" | field=="ChemicalIndus" | field=="MineralsProcess"| field=="FinalGoodsProcess"
keep field publn_year world_hvi_CCMT_field
sort field publn_year
duplicates drop
keep if publn_year>=1995 & publn_year <=2017
gen world_CCMT = world_hvi_CCMT_field if publn_year ==1995
egen world_CCMT1995 = sum(world_CCMT), by(field)
gen world_CCMT_Index95= world_hvi_CCMT_field / world_CCMT1995
keep field publn_year world_hvi_CCMT_field world_CCMT_Index95
export excel "$droppath/Analysis/SELECT_NatEn/Main/Figure4d.xlsx", replace firstrow(variables)
*== FIGURE4e: CARBON CAPTURE AND STORAGE (CCS): CO2 CCS & other GHG CCS
use  "$datapath/Final_database/CCMT_SubCat_inv_by_fields_inventor_ctry_year.dta" , clear
keep if field =="C02_CCS" | field=="nonC02_CCS"
keep field publn_year world_hvi_CCMT_field
sort field publn_year
duplicates drop
keep if publn_year>=1995 & publn_year <=2017
gen world_CCMT = world_hvi_CCMT_field if publn_year ==1995
egen world_CCMT1995 = sum(world_CCMT), by(field)
gen world_CCMT_Index95= world_hvi_CCMT_field / world_CCMT1995
keep field publn_year world_hvi_CCMT_field world_CCMT_Index95
 export excel "$droppath/Analysis/SELECT_NatEn/Main/Figure4e.xlsx", replace firstrow(variables)
*== FIGURE4f: TRANSPORT: Air transport, Maritime, Rail, Electric Vehicles (EVs)
use "$patstpath/mitigation/ElecVehicles_ZOOM_inventor_ctry_year" , clear
keep techno publn_year world_hvi_EVall
ren (techno world_hvi_EVall) (field world_hvi_CCMT_field)
duplicates drop
append using "$datapath/Final_database/CCMT_SubCat_inv_by_fields_inventor_ctry_year.dta"
keep if field =="Elec_Vehicles" | field=="Aero_Transport" | field=="Rail_Transport"| field=="Maritime_Transport"
keep field publn_year world_hvi_CCMT_field
sort field publn_year
duplicates drop
keep if publn_year>=1995 & publn_year <=2017
gen world_CCMT = world_hvi_CCMT_field if publn_year ==1995
egen world_CCMT1995 = sum(world_CCMT), by(field)
gen world_CCMT_Index95= world_hvi_CCMT_field / world_CCMT1995
keep field  publn_year world_hvi_CCMT_field world_CCMT_Index95
 export excel "$droppath/Analysis/SELECT_NatEn/Main/Figure4f.xlsx", replace firstrow(variables)
 
 	
*== FIGURE5: Top-10 inventor countries in CCMT
*== % of CCMT  inventions made by TOP 10 inventor countries (2013-2017) vs(2000-2005)
* 2013-2017
use "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year", clear
keep if publn_year >=2013 & publn_year <=2017
keep if techno =="Y02"
keep techno invt_iso invt_name publn_year income ///
nb_hvi_CCMT nb_hvi_all world_hvi_CCMT world_hvi_all
duplicates drop
*Identification TOP 10 inventors 2013-2017
egen sall =sum(nb_hvi_all), by(invt_iso)
egen sCCMT =sum(nb_hvi_CCMT), by(invt_iso)
keep invt_iso invt_name sall sCCMT 
duplicates drop
gsort -sCCMT
gen byte x=1
gen rank = sum(x)
replace invt_name = "Others" if rank>=11
replace rank = 11 if rank>=11
egen tot_ctry_CCMT = sum(sCCMT), by(invt_name)
egen tot_ctry_ALL = sum(sall), by(invt_name)
drop s* x invt_iso
duplicates drop
egen world_CCMT = sum(tot_ctry_CCMT)
egen world_ALL = sum(tot_ctry_ALL)
gen sh_worldHVI_CCMT1317 = 100 * tot_ctry_CCMT / world_CCMT
gen sh_worldHVI_ALL1317 = 100 * tot_ctry_ALL / world_ALL
gen cat = 0 if rank<=10
replace cat = 1 if rank ==11
keep cat rank invt_name sh_worldHVI_CCMT sh_worldHVI_ALL
order cat rank invt_name sh_worldHVI_CCMT sh_worldHVI_ALL
sort cat rank 
save "$droppath/Analysis/SELECT_NatEn/Main/Figure5a.dta", replace
* 2000-2005
use "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year", clear
keep if publn_year >=2000 & publn_year <=2005
keep if techno =="Y02"
keep techno invt_iso invt_name publn_year income ///
nb_hvi_CCMT nb_hvi_all world_hvi_CCMT world_hvi_all
duplicates drop
egen tot_ctry_ALL =sum(nb_hvi_all), by(invt_iso)
egen tot_ctry_CCMT =sum(nb_hvi_CCMT), by(invt_iso)
keep invt_iso invt_name tot_ctry_ALL tot_ctry_CCMT 
duplicates drop
egen world_CCMT = sum(tot_ctry_CCMT)
egen world_ALL = sum(tot_ctry_ALL)
gen sh_worldHVI_CCMT0005 = 100 * tot_ctry_CCMT / world_CCMT
gen sh_worldHVI_ALL0005 = 100 * tot_ctry_ALL / world_ALL
keep invt_name sh_worldHVI_CCMT sh_worldHVI_ALL
order invt_name sh_worldHVI_CCMT sh_worldHVI_ALL
*add percentage of CCMT inventions 2013-2017
mmerge invt_name using "$droppath/Analysis/SELECT_NatEn/Main/Figure5a.dta"
keep if cat !=.
browse
order cat rank invt_name sh_worldHVI_CCMT* sh_worldHVI_ALL*
sort cat rank
drop _m
export excel "$droppath/Analysis/SELECT_NatEn/Main/Figure5.xlsx", replace firstrow(variables)

*== FIGURE6: Climate change mitigation technology specialisation from 2013-2017
*== Specialization in CCMT for TOP 10 inventor countries (2013-2017) vs (200-2005)
*2013-2017
use  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year",clear
keep if publn_year <=2017 & publn_year >=2013
keep if techno =="Y02"
keep techno invt_iso invt_name publn_year income ///
nb_hvi_CCMT nb_hvi_all world_hvi_CCMT world_hvi_all
duplicates drop
*Identification of countries inventing at least 0.1% of all CCMT inveted worldwide
egen sCCMT =sum(nb_hvi_CCMT), by(invt_iso)
egen worldCCMT =sum(nb_hvi_CCMT)
gen sh_world_CCMT = 100 * sCCMT / worldCCMT
gen spe = 100 * nb_hvi_CCMT / nb_hvi_all
egen spe_CCMT1317=mean(spe), by(invt_iso)
keep invt_iso invt_name spe_CCMT1317 sh_world_CCMT
duplicates drop
set obs `=_N+1'
egen mean = mean(spe_CCMT1317)
replace spe_CCMT1317 = mean if invt_iso ==""
replace invt_name = "World" if invt_iso ==""
replace sh_world_CCMT = 1 if  invt_name == "World" 
drop mean
keep if sh_world_CCMT >=0.1
browse
sort invt_iso
save "$droppath/Analysis/SELECT_NatEn/Main/Figure6a.dta", replace
*2000-2005
use  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year",clear
keep if publn_year <=2005 & publn_year >=2000
keep if techno =="Y02"
keep techno invt_iso invt_name publn_year income ///
nb_hvi_CCMT nb_hvi_all world_hvi_CCMT world_hvi_all
duplicates drop
*Identification of countries inventing at least 0.1% of all CCMT inveted worldwide
gen spe = 100 * nb_hvi_CCMT / nb_hvi_all
egen spe_CCMT0005=mean(spe), by(invt_iso)
keep invt_iso invt_name spe_CCMT0005 
duplicates drop
mmerge invt_iso using "$droppath/Analysis/SELECT_NatEn/Main/Figure6a.dta", unmatched(using)
drop _m
order invt* spe*
export excel "$droppath/Analysis/SELECT_NatEn/Main/Figure6.xlsx", replace firstrow(variables)


*== FIGURE7: Source and destination of transferred climate change mitigation technologies from 2013-2017
*== Matrix transfers income (mitigation) 2013-2017
use "$datapath/Final_database/mitigation_transfers_tech_inventor_ctry_office_year", clear
keep if publn_year >=2013 & publn_year <=2017
keep if technology == "Y02"
drop if income_office=="" |income_invt=="" 
drop if invt_country =="" |patent_office==""
replace income_office ="Middle income" if income_office == "Upper middle income"
replace income_office ="Middle income" if income_office == "Lower middle income"
replace income_invt ="Middle income" if income_invt == "Upper middle income"
replace income_invt ="Middle income" if income_invt == "Lower middle income"
egen tot_transfer = sum(nb_pat_CCMT) if invt_country != patent_office
egen nb_inv_income_CCMT = sum(nb_pat_CCMT) if invt_country != patent_office, by(income_office income_invt)
keep if nb_inv_income !=.
keep nb_inv_income income_office income_invt tot_transfer
duplicates drop
gen share_transfer_CCMT = 100 * nb_inv_income/tot_transfer
keep nb_inv_income income_office income_invt share_transfer tot_transfer
gsort -share_transfer
order income* share
export excel "$droppath/Analysis/SELECT_NatEn/Main/Figure7.xlsx", replace firstrow(variables)
 
 

*=============================================
*=============================================
*=============================================	END


*=============================================	END
*=============================================
*=============================================
*=============================================
*=============================================
