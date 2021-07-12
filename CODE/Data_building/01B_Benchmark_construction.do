*=== Nature Energy: July 2021
*=== Paper title: 
*				Global Trends in the Invention and Diffusion 
*				of Climate Change Mitigation Technologies
*=== Objective: 
* - Select patents constituting the benchmark related to each CCMT technology fields

*======== 
*======== 
*======== SELECTION OF THE BENCHMARK FOR EACH CCMT Y02 TECHNOLOGY CATEGORIES ===========
*======== 				
*======== 
*======== 

*== Selection of the technology codes to create the benchmark for each technoloy fields
* Pourcentage of coverage used: 75% 
*(we select the ipc code which are the most represented in the given technology 
* class until covering 75% of the CCMT patents by technology)

/// 1: Add ipc codes to the selected mitigation patents
use "$datapath/Patstat_mitigation2018.dta", clear
mmerge appln_id using "$patstpath/general/ipc_codes.dta", unmatched(none)
drop _m
save "$datapath/Merge_ipc_Y02_classification_Mitig.dta",replace


*=== A : SELECTION BENCHMARK 3 FIRST DIGITS

 ///  Select the benchmark using the 3 first digits of the ipc_codes
 /// Select icp_codes representing 75% of all patents by technology class
 /// Except CCMT patents in Y02, for whose we take all patents in PATSTAT as a benchmark 
 use "$datapath/Merge_ipc_Y02_classification_Obvious.dta", clear
 drop if technology =="Y02" //For Y02, we use the entire PATSTAT database as a benchmark
 * The benchmark is defined using the three first digit of the ipc_code
 gen benchmark=substr(ipc_code,1,3)
 browse
 gen byte x=1
 * Number of patents by benchmark (ipc code) within a technology field
 egen nb_bench_tech = sum(x), by(technology benchmark)
 
  * Number of patents by technology field
 egen nb_technology= sum(x), by(technology)
 
 * Select ipc code(3-digits) representing 75% of all patents in the technology class
 gsort technology -nb_bench_tech
 keep technology benchmark nb_bench_tech nb_techno
 duplicates drop
 gen share_tech = nb_bench_tech / nb_technology
 gsort technology -share_tech
 bysort technology: gen sum_share = sum(share_tech)
 gen bench_tech = benchmark if sum_share <0.75
 keep technology bench_tech share_tech sum_share
 drop if bench_tech ==""
 duplicates drop
 save "$datapath/Selected_3digits_benchmark_Mitig.dta", replace


*== Construction of the benchmark by technology: selection of all the technologies 
* with the IPC codes corresponding to the benchmark identified

/// Selection of the technologies (appln_id) using the 3 first IPC identification characters  
/// Keep only one appln_id by benchmark
use "$patstpath/general/ipc_codes.dta", clear
gen bench_tech=substr(ipc_code,1,3)
sort appln_id bench_tech
quietly by appln_id bench_tech: gen dup=cond(_N==1,0,_n)
drop if dup>1
keep appln_id bench_tech
save "$patstpath/general/ipc_codes_IPC3.dta",replace

/// Merge ipc 3 digits with those constituting the selected benchmarks
use  "$datapath/Selected_3digits_benchmark_Mitig.dta", clear
keep technology bench_tech
duplicates drop
mmerge bench_tech using "$patstpath/general/ipc_codes_IPC3.dta", unmatch(master)
drop _m
*Add all patents contained in PATSTAT to constitute the benchmark for all CCMT (Technology ="Y02")
append using "$patstpath/general/ipc_codes_IPC3.dta"
replace technology ="Y02" if technology==""
sort technology appln_id
quietly by technology appln_id: gen dup=cond(_N==1,0,_n)
drop if dup>1
compress
drop dup
save "$datapath/Complete_3digits_benchmark_Mitig.dta", replace



*=== B : SELECTION BENCHMARK 4 FIRST DIGITS

 ///  Select the benchmark using the 4 first digits of the ipc_codes
 /// Select icp_codes representing 75% of all patents by technology class
 /// Except CCMT patents in Y02, for whose we take all patents in PATSTAT as a benchmark 
 use "$datapath/Merge_ipc_Y02_classification_Obvious.dta", clear
 drop if technology =="Y02" //For Y02, we use the entire PATSTAT database as a benchmark
 * The benchmark is defined using the four first digit of the ipc_code
 gen benchmark=substr(ipc_code,1,4)
 browse
 gen byte x=1
 * Number of patents by benchmark (ipc code) within a technology field
 egen nb_bench_tech = sum(x), by(technology benchmark)
 
  * Number of patents by technology field
 egen nb_technology= sum(x), by(technology)
 
 * Select ipc code(4-digits) representing 75% of all patents in the technology class
 gsort technology -nb_bench_tech
 keep technology benchmark nb_bench_tech nb_techno
 duplicates drop
 gen share_tech = nb_bench_tech / nb_technology
 gsort technology -share_tech
 bysort technology: gen sum_share = sum(share_tech)
 gen bench_tech = benchmark if sum_share <0.75
 keep technology bench_tech share_tech sum_share
 drop if bench_tech ==""
 duplicates drop
 save "$datapath/Selected_4digits_benchmark_Mitig.dta", replace


*== Construction of the benchmark by technology: 
*Selection of all the technologies with the IPCC codes coresponding to the benchmark identified

/// Selection of the technologies (appln_id) using the 4 first IPC identification characters  
/// Keep only one appln_id by benchmark
use "$patstpath/general/ipc_codes.dta", clear
gen bench_tech=substr(ipc_code,1,4)
sort appln_id bench_tech
quietly by appln_id bench_tech: gen dup=cond(_N==1,0,_n)
drop if dup>1
keep appln_id bench_tech
save "$patstpath/general/ipc_codes_IPC4.dta",replace

/// Merge ipc 4 digits with those constituting the selected benchmarks
use  "$datapath/Selected_4digits_benchmark_Obvious.dta", clear
keep technology bench_tech
duplicates drop
mmerge bench_tech using "$patstpath/general/ipc_codes_IPC4.dta", unmatch(master)
drop _m
*Add all patents contained in PATSTAT to constitute the benchmark for all CCMT (Technology ="Y02")
append using "$patstpath/general/ipc_codes_IPC4.dta"
replace technology ="Y02" if technology==""
sort technology appln_id
quietly by technology appln_id: gen dup=cond(_N==1,0,_n)
drop if dup>1
compress
drop dup
save "$datapath/Complete_4digits_benchmark_Mitig.dta", replace



*=============================================
*=============================================
*=============================================
*=============================================
*=============================================
