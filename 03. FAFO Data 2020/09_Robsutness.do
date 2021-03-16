
use "$data_2020_final/Jordan2020_geo_Syria_empl_Syria", clear 

*use "$data_2020_final/Jordan2020_geo_Syria.dta", clear 
*tab id_gov_syria

geodist district_lat district_long gov_syria_lat gov_syria_long, gen(distance_dis_gov)
tab distance_dis_gov, m
lab var distance_dis_gov "Distance (km) between JORD districts and SYR centroid governorates"

unique distance_dis_gov //140

drop district_long district_lat gov_syria_long gov_syria_lat
sort district_en governorate_syria 

drop id_district_jordan 
egen id_district_jordan = group(district_en) 

list id_gov_syria governorate_syria
sort district_en governorate_syria industry_id

tab industry_en industry_id
drop industry_id 
egen industry_id = group(industry_en)

merge m:1 industry_id using  "$data_2020_temp/UNHCR_shift_byOccup.dta"
drop _merge 

ren share share_empl_syr 

order id_gov_syria governorate_syria id_district_jordan district_en industry_id industry_en share_empl_syr wp_2020

lab var id_gov_syria "ID Governorate Syria"
lab var governorate_syria "Name Governorate Syria"
lab var id_district_jordan "ID District Jordan"
lab var district_en "Name District Jordan"
lab var industry_id "ID Industry"
lab var industry_en "Name Industry"
lab var share_empl_syr "Share Employment over Governorates Syria"
lab var wp_2020 "WP in Jordan by industry"
lab var distance_dis_gov "Distance Districts Jordan to Governorates Syria"

sort id_gov_syria district_en industry_id

/* STANDARD SS IV
gen IV_SS = (wp_2020*share_empl_syr)/distance_dis_gov 
collapse (sum) IV_SS, by(district_en)
lab var IV_SS "IV: Shift Share"
\*/
*save "$data_2020_final/Jordan2020_IV", replace 

tab district_en, m
sort district_en
egen district_id = group(district_en) 

*bys id_gov_syria: gen IV_SS = (wp_2020*share_empl_syr)/distance_dis_gov 
preserve
bys id_gov_syria: gen IV_share = share_empl_syr/distance_dis_gov 
collapse (sum) IV_share, by(id_gov_syria district_en)
reshape wide IV_share, i(district_en) j(id_gov_syria)

tab district_en, m
sort district_en
egen district_id = group(district_en) 

tempfile shares
save `shares'
restore

merge m:1 district_id using `shares'
br id_gov_syria district_en wp_2020 industry_en
sort district_en id_gov_syria industry_en
collapse (sum) wp_2020, by(id_gov_syria district_en)



save "$data_2020_final/Jordan2020_IV_robust", replace 


**CONTROL: Number of refugees
import excel "$data_UNHCR_base/Datasets_WP_RegisteredSyrians.xlsx", sheet("WP_REF - byGov byYear") firstrow clear

tab Year
keep if Year == 2020 

sort Governorates
ren Governorates governorate_en
sort governorate_en
egen governorate_id = group(governorate_en)

save "$data_UNHCR_final/UNHCR_NbRef_byGov.dta", replace


use "$data_2020_temp/Jordan2020_03_Compared.dta", clear

tab governorate_en
drop if governorate_en == "Zarqa"
tab governorate
sort governorate_en
egen governorate_id = group(governorate_en)

tab district_en
sort district_en
egen district_id = group(district_en) 

gen year = 2020

append using "$data_2014_final/Jordan2014_02_Clean.dta"

keep hhid iid governorate_en governorate_id district_en district_id ///
		rsi_wage_income_lm_cont ros_employed rsi_work_hours_7d ///
		rsi_work_permit year
tab year 

merge m:1 district_id using "$data_2020_final/Jordan2020_IV_robust.dta"
drop if _merge == 2
drop _merge

merge m:1 governorate_id using "$data_UNHCR_final/UNHCR_NbRef_byGov.dta"
drop if _merge == 2
drop _merge

bys year: tab governorate_en, m
bys year: tab district_en, m

*replace IV_SS = 0 if year == 2014

bartik_weight, z() weightstub(IV_SS*) x(rsi_work_permit) y(ros_employed) absorb(year district_id)

/*
Main
----
 y(varname): 			outcome variable        
 x(varname): 			endogeous variable  
 z(varlist): 			variable list of instruments    
 weightstub(varlist): 	variable list of weights       

Options
-------                        
controls(varlist): 		list of control variables        
absorb(varname): 		fixed effect to absorb            
weight_var(varname): 	name of analytic weight variable for regression        
by(varname): 			name of the time variable that is interacted with the shares
*/

 IV_SS NbRefugeesoutcamp
