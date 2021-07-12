*=== Nature Energy: Submitted 08 July 2021
*=== Paper title: 
*				Global Trends in the Invention and Diffusion 
*				of Climate Change Mitigation Technologies
*=== Object: CONSTRUCTION OF THE ZEPHYR MITIGATION SPECIFIC DATABASE
*==== USING THE METHODOLOGY IN DECHEZLEPRETRE DUSSAUX GLACHANT 2018


	*== Selection of the mitigation patents
	
	*== Filter  1: Selection of the deals in Zephyr where the acqueror firms have filed at least one mitigation patents in the recipient country
	use "$patstpath/mitigation/all_mitigation_patents_info.dta", clear
	*we drop patent filing when we don't know the name of the inventor
	drop if invt_firm =="" 
	* We try to collect as many countries as possible using PRS_EPO_national_phase
	mmerge appln_id using "$patstpath/general/PRS_EPO_national_phase.dta", unmatched(master) ukeep(country)
	drop _m
	ren earliest_publn_year year
	replace appln_auth = country if country!=""
	drop country
	drop if appln_auth=="EP"
	drop if appln_auth=="WO"
	ren appln_auth targetcountrycode
	keep invt_firm targetcountrycode technology
	ren invt_firm acquirorbvdidnumber
	duplicates drop
	*We have all the firms which have patented an adaptation patents, by technology
	*We then identify deals where the firm acquire a trget firm in a country when it filed a patent
	mmerge acquirorbvdidnumber targetcountrycode using  "$zephyrpath\Zephyr_clean_1995_2016.dta", unmatched(none)
		drop _m
	save "$zephyrpath\Zephyr_acquero_mitigation_1995_2016.dta", replace
	*The previously saved database contains all deals where the acquire firm have filed an mitigation patents in the country of the targeted firm
	
	*== Filter 2: Adding country codes/informations & Identification of the target in the adaptation sectors, adding country codes/informations
	use "$zephyrpath\Zephyr_acquero_mitigation_1995_2016.dta" , clear
	sort targetprimarynacerev2code
	*Infos on acquiror country & target country
	ren targetcountrycode iso2
	mmerge iso2 using "C:\Users\Simon Touboul\Desktop\THESIS\Data\Data_general\Other\CountryID.dta", ukeep(iso3) unmatched(master)
	ren iso3 targetcountryISO
	ren iso2 targetcountrycode
	ren acquirorcountry iso2
	mmerge iso2 using "C:\Users\Simon Touboul\Desktop\THESIS\Data\Data_general\Other\CountryID.dta", ukeep(iso3) unmatched(master)
	ren iso3 acquirorcountryISO
	ren iso2 acquirorcountrycode
	*add income info
	ren acquirorcountryISO invt_iso
	mmerge invt_iso using "C:\Users\Simon Touboul\Desktop\THESIS\Data\Data_general\Other\income_region_World_Bank_2019.dta", unmatched(master) ukeep(income)
	ren  invt_iso acquirorcountryISO
	ren income acquirorincome
	ren targetcountryISO patent_office_iso
	mmerge patent_office_iso using "C:\Users\Simon Touboul\Desktop\THESIS\Data\Data_general\Other\income_region_World_Bank_2019.dta", unmatched(master) ukeep(income)
	ren  patent_office_iso targetcountryISO
	ren income targetincome
	order technology targetcountrycode targetcountryISO targetincome acquirorcountrycode acquirorcountryISO acquirorincome
	drop _m
	save "$zephyrpath/Zephyr_acquero_mitigation_1995_2016.dta", replace
	
	* import the selection of the NACREV2 codes
	import excel "$droppath\data\NACErev2_mitigation_selection_DussauxetAL2018.xlsx", firstrow clear
	sort technology nacerev2
	duplicates drop
	ren nacerev2 targetprimarynacerev2code
	destring targetprimarynacerev2code, replace
	keep if targetprimarynacerev2code !=.
	duplicates drop
	save  "$zephyrpath/Selection_nacerev2_mitigation.dta",replace
	*The previously saved database contains Nacerev2 codes relative to each mitigation technology classes
	
	* We match the technology class of the patented invention from the acquiring firm 
	* with the technology identified using the nace code
	use "$zephyrpath/Zephyr_acquero_mitigation_1995_2016.dta",clear
	keep if targetprimarynacerev2code !=. & technology != ""
	mmerge targetprimarynacerev2code technology using "$zephyrpath/Selection_nacerev2_mitigation.dta", unmatched(none) 
	drop _m
	*We only want to keep the FOREIGN investments for the analysis
	* We keep deals where acquiring country and targeted countries are different
	keep if targetcountrycode != acquirorcountrycode
	duplicates drop
	keep if year<=2016
	* we create the overall category class Y02
	expand 2
	quietly bys technology acquirorcountrycode acquirorbvdidnumber year targetcountrycode dealnumber targetprimarynacerev2code: gen dup=cond(_N==1,0,_n)
	replace technology ="Y02" if dup==2
	drop dup
	*We suppress deals with technology Y02 if they are duplicated
	duplicates drop
	order technology acquirorcountrycode acquirorcountryISO acquirorincome year targetcountrycode targetcountryISO targetincome
	sort technology acquirorcountrycode targetcountrycode year
	save "$zephyrpath/Final_Zephyr_mitigation_1995_2016.dta", replace
	
	
	*===Constructinon of the variables of interest 
	* 1995-2016
	use "$zephyrpath/Final_Zephyr_mitigation_1995_2015.dta", clear
	gen byte x=1
	sort technology targetcountryISO acquirorcountryISO 
	bysort technology targetcountryISO acquirorcountryISO: egen nb_deal_bytech_pair = sum(x)
	bysort technology targetcountryISO: egen nb_deal_bytech_target = sum(x)
	bysort technology acquirorcountryISO: egen nb_deal_bytech_acquiror=sum(x)
	bysort targetprimarynacerev2code targetcountryISO acquirorcountryISO: egen nb_deal_bynace_pair = sum(x) if technology =="Y02"
	bysort targetprimarynacerev2code targetcountryISO: egen nb_deal_bynace_target = sum(x) if technology =="Y02"
	bysort targetprimarynacerev2code acquirorcountryISO: egen nb_deal_bynace_acquiror=sum(x) if technology =="Y02"
	drop x
	save "$zephyrpath/Analysis_Zephyr_mitigation_1995_2015.dta", replace
	
	*2012-2016
	use "$zephyrpath/Final_Zephyr_mitigation_1995_2015.dta", clear
	keep if year>=2012
	gen byte x=1
	sort technology targetcountryISO acquirorcountryISO 
	bysort technology targetcountryISO acquirorcountryISO: egen nb_deal_bytech_pair = sum(x)
	bysort technology targetcountryISO: egen nb_deal_bytech_target = sum(x)
	bysort technology acquirorcountryISO: egen nb_deal_bytech_acquiror=sum(x)
	bysort targetprimarynacerev2code targetcountryISO acquirorcountryISO: egen nb_deal_bynace_pair = sum(x) if technology =="Y02"
	bysort targetprimarynacerev2code targetcountryISO: egen nb_deal_bynace_target = sum(x) if technology =="Y02"
	bysort targetprimarynacerev2code acquirorcountryISO: egen nb_deal_bynace_acquiror=sum(x) if technology =="Y02"
	drop x
	save "$zephyrpath/Analysis_Zephyr_mitigation_2012_2016.dta", replace
	
	

*=============================================
*=============================================
*=============================================	END


*=============================================	END
*=============================================
*=============================================
*=============================================
*=============================================
