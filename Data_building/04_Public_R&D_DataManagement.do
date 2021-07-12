*=== Nature Energy: July 2021
*=== Paper title: 
*				Global Trends in the Invention and Diffusion 
*				of Climate Change Mitigation Technologies
*=== Objective: 
* - Manage data on Public R&D spending in Energy from IEA


*====== Analyse RDD spending by eco sector
*===== Data source: 
*== 				1  : RD&D spending bty Energy sector : IEA (May 2021): https://www.iea.org/data-and-statistics/data-product/energy-technology-rd-and-d-budget-database-2
*== 				1  : Total R&DD sopending (GERD) : OECD https://stats.oecd.org/viewhtml.aspx?datasetcode=MSTI_PUB&lang=en#


*=== Manage OECD total R&D expenditure 1995-2019
import delimited using "$droppath/data\R&D_data\OECD_R&D_Totalexpenditure_percentGDP.csv", varnames(1) clear
browse
reshape long yr, i(country x) j(year) 
ren yr totGERD_percent_GDP
drop x
save"$droppath/data\R&D_data\OECD_R&D_Totalexpenditure_percentGDP.dta", replace


*==Manage IEA dataset: long to wide (columns = Economic sectors): USD 2020 PPP
use "$droppath/data\R&D_data\PublicRDDSpending_IEA2021_USD2020PPP_long.dta", clear
drop world miss
browse
replace Eco_Sector = "Energy_eff" if Eco_Sector =="Energy efficiency"
replace Eco_Sector = "Energy_eff" if Eco_Sector =="Energy efficiency "
replace Eco_Sector = "Fossil_fuels" if Eco_Sector =="Fossil fuels"
replace Eco_Sector = "Fossil_fuels" if Eco_Sector =="Fossil fuels "
replace Eco_Sector = "Hydro_fuel_cell" if Eco_Sector =="Hydrogen and fuel cells"
replace Eco_Sector = "Hydro_fuel_cell" if Eco_Sector =="Hydrogen and fuel cells "
replace Eco_Sector = "Nuclear" if Eco_Sector =="Nuclear "
replace Eco_Sector = "Cross_cutt_tech" if Eco_Sector =="Other cross-cutting technologies/research"
replace Eco_Sector = "Cross_cutt_tech" if Eco_Sector =="Other cross-cutting technologies/research "
replace Eco_Sector = "Renewables" if Eco_Sector =="Renewables "
replace Eco_Sector = "Total" if Eco_Sector =="Total Budget"
replace Eco_Sector = "Total" if Eco_Sector =="Total Budget "
replace Eco_Sector = "Unallocated" if Eco_Sector =="Unallocated "
replace Eco_Sector = "Otr_power_storage" if Eco_Sector =="Other power and storage technologies"
replace Eco_Sector = "Otr_power_storage" if Eco_Sector =="Other power and storage technologies "
tab Eco
ren RD_spending RD
reshape wide RD, i(Country Currency year) j(Eco_Sector) string
save"$droppath/data\R&D_data\PublicRDDSpending_IEA2021_USD2020PPP_wide.dta", replace

*=== Manage Nominal GDP (Millions) from IEA 
import delimited using "$droppath/data\R&D_data\NominalGDP_IEA.csv", varnames(1) clear
browse
reshape long yr, i(country indicator) j(year) 
ren yr GDP_nominal
drop indicator
save"$droppath/data\R&D_data\NominalGDP_IEA.dta", replace

*==Manage IEA dataset: long to wide (columns = Economic sectors): Nominal currency (millions)
import delimited using "$droppath/data\R&D_data\PublicRDDSpending_IEA2021_Nominal.csv", varnames(1) clear
browse
drop currency
ren economicindicators Eco_Sector
replace Eco_Sector = "Energy_eff" if Eco_Sector =="Energy efficiency"
replace Eco_Sector = "Energy_eff" if Eco_Sector =="Energy efficiency "
replace Eco_Sector = "Fossil_fuels" if Eco_Sector =="Fossil fuels"
replace Eco_Sector = "Fossil_fuels" if Eco_Sector =="Fossil fuels "
replace Eco_Sector = "Hydro_fuel_cell" if Eco_Sector =="Hydrogen and fuel cells"
replace Eco_Sector = "Hydro_fuel_cell" if Eco_Sector =="Hydrogen and fuel cells "
replace Eco_Sector = "Nuclear" if Eco_Sector =="Nuclear "
replace Eco_Sector = "Cross_cutt_tech" if Eco_Sector =="Other cross-cutting technologies/research"
replace Eco_Sector = "Cross_cutt_tech" if Eco_Sector =="Other cross-cutting technologies/research "
replace Eco_Sector = "Renewables" if Eco_Sector =="Renewables "
replace Eco_Sector = "Total" if Eco_Sector =="Total Budget"
replace Eco_Sector = "Total" if Eco_Sector =="Total Budget "
replace Eco_Sector = "Unallocated" if Eco_Sector =="Unallocated "
replace Eco_Sector = "Otr_power_storage" if Eco_Sector =="Other power and storage technologies"
replace Eco_Sector = "Otr_power_storage" if Eco_Sector =="Other power and storage technologies "
tab Eco
reshape long yr, i(country Eco_Sector) j(year)
dropmiss v* yr Eco, force
ren yr RD_spending_nominal
mmerge country year using "$droppath/data\R&D_data\NominalGDP_IEA.dta", unmatched(none)
gen RD_shGDP = 100 * RD_spending_nominal/GDP_nominal
keep country year Eco_Sector RD_shGDP
save"$droppath/data\R&D_data\PublicRDDSpending_IEA2021_shGDP_wide.dta", replace

*=== Merge R&D data
use "$droppath/data\R&D_data\PublicRDDSpending_IEA2021_shGDP_wide.dta", clear
keep if year>=1995
mmerge country year using "$droppath/data\R&D_data\OECD_R&D_Totalexpenditure_percentGDP.dta"
gen RD_in_GERD = RD_shGDP / totGERD 
save "$droppath/data\R&D_data\Merged_PublicRDDSpending_OECDandIEA_shGDP.dta", replace
drop _m
export excel "$droppath/data\R&D_data\Merged_PublicRDDSpending_OECDandIEA_shGDP.xls", firstrow(variables) replace




*=============================================
*=============================================
*=============================================	END


*=============================================	END
*=============================================
*=============================================
*=============================================
*=============================================
