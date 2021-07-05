	/*=== MASTER FILE FOR INNOVATION & MITIGATION PATENTS===
		=== Last update: 07/02/2019 === */

clear all

log using "C:/Users/Simon Touboul/Dropbox\Mitig_Innov_Update\Log\19Jan08_LOG_Innov_Mitig.txt", text replace 

*=== Definition of the different paths


global droppath "C:/Users/Simon Touboul/Dropbox/Mitig_Innov_Update" 

global compupath "C:\Users\Simon Touboul\Desktop\THESIS\Data\Mitig_Innov_Update"

global dopath "$droppath/Do"

global datapath "$compupath/Mitigation"

global patstpath "C:\Users\Simon Touboul\Desktop\THESIS\Data\Data_general/Patstat"

global otherpath "C:\Users\Simon Touboul\Desktop\THESIS\Data\Data_general/Other"

global climpath "C:\Users\Simon Touboul\Desktop\THESIS\Data\Data_general/Climate_Indices"

global Rpath "C:/Users/Simon Touboul/Dropbox/R"

global Chinapath "$droppath/Focus_China"

*===========
*=========== 	SELECTION OF ALL MITIGATION PATENTS & BENCHMARK
do "$dopath/01A_Mitigation_patent_selection"  

do "$dopath/01A_Mitigation_patent_subcat_selection"  


do "$dopath/01B_Benchmark_construction"  

*===========
*=========== 	CONSTRUCTION OF THE DATABASES FROM PATSTAT DATA

*	MITIGATION PATENTS

do "$dopath/02A_patent_mitigation_patstatCAT_2018"

do "$dopath/02A_patent_mitigation_4digits_patstatCAT_2018"

do "$dopath/02A_patent_mitigation_subCATpatstat_2018"



do "$dopath/02B_Detail_Public_privateCCMT_Patents"

do "$dopath/02B_patent_Focus_Renewable_energy_patstatCAT_2018"


*===========
*=========== 	MERGE DATASETS WITH OTHER DATA (Population, GDP, vulnerability,income, ...)

*	INVENTION DATASETS

do "$dopath/03A_Merge_invent"



*	TRANSFER DATASETS

do "$dopath/03B_Merge_transfers"


		
		
*===========
*=========== 	CREATION OF THE VARIABLES USED FOR THE ANALYSIS

*Invention	
do "$dopath/05A_crea_var_invent"	
*do "$path/Inventors/05A_crea_var_invent_2000_2005"
*do "$dopath/05A_crea_var_invent_2012_2017"		

*Transfer	
do "$dopath/05B_crea_var_transfer"	
*do "$path/Transfers/05B_crea_var_transfer_2000_2005"
*do "$dopath/05B_crea_var_transfer_2012_2017"	

		
*=============================================
*=============================================
*=============================================

*FOCUS subcategories

do "$dopath/01A_Mitigation_patent_subcat_selection"  

do "$dopath/02A_patent_mitigation_subCATpatstat_2018"


*=============================================
*=============================================
*=============================================
*=============================================
*=============================================

	log close
