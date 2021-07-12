*=== Nature Energy: July 2021
*=== Paper title: 
*				Global Trends in the Invention and Diffusion 
*				of Climate Change Mitigation Technologies
*=== Objective: 
* - Define paths to do files and databases
* - List all do files used to build dabases and make the analysis

clear all


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

global zephyrpath "C:\Users\Simon Touboul\Desktop\THESIS\Data\Data_general\FDI\ZEPHYR\"



*=================================						=================================
*================================= 	I: DATA BUILDING	=================================
*=================================						=================================


*===========
*=========== 	SELECTION OF ALL MITIGATION PATENTS & BENCHMARK

* Select mitigation related patents, and identify the technology categories and sub-categories
do "$dopath/Data_building/01A_Mitigation_patent_selection"  

* Select patents to create the benchmark related to each technology categories 
* Identify patents included in the benchmark using the 3 or 4 first digits of there IPC codes
do "$dopath/Data_building/01B_Benchmark_construction"  

*===========
*=========== 	CONSTRUCTION OF THE DATABASES FROM PATSTAT DATA

*MAIN DATASETS

* Create final databases on invention and transfer of CCMT technologies
* We identify the benchmark using the 3 first digits of the IPC codes
* Technologies are classified using technology categories (4 first digits of their CPC codes)
do "$dopath/Data_building/02A_patent_mitigation_patstatCAT_2018"


*BENCHMARK 4 DIGITS 

* Create final databases on invention and transfer of CCMT technologies
* We identify the benchmark using the 4 first digits of the IPC codes
* Technologies are classified using technology categories (4 first digits of their CPC codes)
do "$dopath/Data_building/02B_patent_mitigation_4digits_patstatCAT_2018"

*FOCUS SUB-CATEGORIES

* Create final databases on invention and transfer of CCMT technologies
* We identify the benchmark using the 3 first digits of the IPC codes
* Technologies are classified using technology sub-categories (6 first digits of their CPC codes)
do "$dopath/Data_building/02C_patent_mitigation_subCATpatstat_2018"

*===========
*=========== 	DATA MANAGEMENT OTHER DATABASES

*Foreign Direct Investment (FDI) deals related to CCMT 

* Select FDI deals related to mitigation technolgies 
* Build database targeting CCMT related FDI deals transferred between countries
do "$dopath/Data_building/03_Construction_FDI_MitigationDatabase"


*Public R&D spending in Energy (IEA)

* Manage Public R&D spending in Energy by sectors (IEA)
do "$dopath/Data_building/04_Public_R&D_DataManagement"



*=================================						=================================
*================================= 		II: ANAYSIS		=================================
*=================================						=================================

* Figures, Tables and Numbers for the main text
do "$dopath/Analysis/MainText_NatEn"

* Figures, Tables and Numbers for the Supplementary Information document (Appendix)
do "$dopath/Analysis/SupplementaryInformation_NatEn"

*=============================================
*=============================================
*=============================================
*=============================================
*=============================================
