

clear all
set more off, permanently
set mem 100m
set matsize 11000

/*
import excel "$data_UNHCR_base\Datasets_WP_RegisteredSyrians.xlsx", sheet("WP - byIndustry") firstrow clear

keep year_2016 year_2020 Activity

ren year_2020 wp_2020
ren year_2016 wp_2016
ren Activity industry_orig
gen industry_en = ""
replace industry_en = "agriculture" if industry_orig == "Agriculture, forestry, and fishing "
replace industry_en = "industry" if industry_orig == "Mining and quarrying "
replace industry_en = "industry" if industry_orig == "Manufacturing "
replace industry_en = "industry" if industry_orig == "Electricity, gas, steam and air conditioning "
replace industry_en = "industry" if industry_orig == "Water supply, sewage, waste management activities "
replace industry_en = "construction" if industry_orig == "Construction "
replace industry_en = "industry" if industry_orig == "Wholesale and retail trade; repair of motor vehicles "
replace industry_en = "transportation" if industry_orig == "Transportation and storage "
replace industry_en = "food" if industry_orig == "Hospitality and food service activities "
replace industry_en = "services" if industry_orig == "Information and communication "
replace industry_en = "banking" if industry_orig == "Financial and insurance activities "
replace industry_en = "banking" if industry_orig == "Real estate activities "
replace industry_en = "services" if industry_orig == "Professional, scientific and technical activities "
replace industry_en = "services" if industry_orig == "Administrative and support service activities "
replace industry_en = "services" if industry_orig == "Public administration and defense; compulsory social "
replace industry_en = "services" if industry_orig == "Education "
replace industry_en = "services" if industry_orig == "Human health and social work activities "
replace industry_en = "services" if industry_orig == "Arts, entertainment and recreation "
replace industry_en = "services" if industry_orig == "Other service activities "

drop if mi(industry_en)
*It removes the Self employed jobs 

collapse (sum) wp_2016 wp_2020, by(industry_en)
*Harmonize based on Syrian classification of industries

sort industry_en 
gen industry_id = _n
list industry_id industry_en 

/*    +---------------------------+
     | indust~d      industry_en |
     |---------------------------|
  1. |        1      agriculture |
  2. |        2          banking |
  3. |        3     construction |
  4. |        4             food |
  5. |        5         industry |
     |---------------------------|
  6. |        6         services |
  7. |        7   transportation |
     +---------------------------+
*/
save "$data_2020_temp/UNHCR_shift_byOccup_16-20.dta", replace 
*/

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
*merge m:1 industry_id using  "$data_2020_temp/UNHCR_shift_byOccup_16-20.dta"
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
*collapse (sum) IV_share, by(id_gov_syria district_en) //SHARE BY GOV
*reshape wide IV_share, i(district_en) j(id_gov_syria)

collapse (sum) IV_share, by(industry_id district_en)
reshape wide IV_share, i(district_en) j(industry_id)

tab district_en, m
sort district_en
egen district_id = group(district_en) 

tempfile shares
save `shares'
restore

merge m:1 district_id using `shares'
drop _merge 

preserve
*br id_gov_syria district_en wp_2020 industry_en industry_id
sort district_en id_gov_syria industry_en
ren wp_2020 IV_shifts
gen n = _n
collapse (sum) n, by(district_en IV_shifts)
drop n 
gen industry_id = .
replace industry_id = 1 if IV_shifts == 12270
replace industry_id = 2 if IV_shifts == 12
replace industry_id = 3 if IV_shifts == 9402
replace industry_id = 4 if IV_shifts == 1647
replace industry_id = 5 if IV_shifts == 4139
replace industry_id = 6 if IV_shifts == 2223
replace industry_id = 7 if IV_shifts == 93

reshape wide IV_shifts, i(district_en) j(industry_id)

tab district_en, m
sort district_en
egen district_id = group(district_en) 

tempfile shifts
save `shifts'
restore

merge m:1 district_id using `shifts'
drop _merge 
duplicates drop district_id, force

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

/*
merge m:1 governorate_id using "$data_UNHCR_final/UNHCR_NbRef_byGov.dta"
drop if _merge == 2
drop _merge
drop Year 
*/

bys year: tab governorate_en, m
bys year: tab district_en, m

/*
replace IV_shifts1 = 0 if year == 2014
replace IV_shifts2 = 0 if year == 2014
replace IV_shifts3 = 0 if year == 2014
replace IV_shifts4 = 0 if year == 2014
replace IV_shifts5 = 0 if year == 2014
replace IV_shifts6 = 0 if year == 2014
replace IV_shifts7 = 0 if year == 2014
br  IV_share* IV_shifts* district_en year
*/

local IV_share IV_share
local IV_shifts IV_shifts

*PROBLEM WITH MY MEMORE
gen n = _n 
drop if n > 6000

*CORE Instrument
*with time variation
forvalues t = 2014(6)2020 {
	foreach var of varlist `IV_share'* {
		gen t`t'_`var' = (year == `t') * `var'
		}
	foreach var of varlist `IV_shifts'* {
		gen t`t'_`var'b = `var' if year == `t'
		egen t`t'_`var' = max(t`t'_`var'b), by(district_en)
		drop t`t'_`var'b
		}
	}

replace rsi_work_permit = 0 if mi(rsi_work_permit) 

bartik_weight, 	z(t*_`IV_share'*) ///
				weightstub(t*_`IV_shifts'*) ///
				x(rsi_work_permit) ///
				y(rsi_wage_income_lm_cont) 


*drop if year == 2020

*without time varaition
/*
bartik_weight, 	z(`IV_share'*) ///
				weightstub(`IV_shifts'*) ///
				x(rsi_work_permit) ///
				y(rsi_wage_income_lm_cont) 
*/

mat beta = r(beta)
mat alpha = r(alpha)
mat gamma = r(gam)
mat pi = r(pi)
mat G = r(G)
desc `IV_share'*, varlist
local varlist = r(varlist)

clear
svmat beta
svmat alpha
svmat gamma
svmat pi
svmat G

gen ind = ""
*gen year = ""
local t = 1
foreach var in `varlist' {
	if regexm("`var'", "`IV_share'(.*)") {
		qui replace ind = regexs(1) if _n == `t'
		}
	local t = `t' + 1
	}

return list 

mat beta = r(beta)
mat alpha = r(alpha)
mat gamma = r(gam)
mat pi = r(pi)
mat G = r(G)

matrix list beta
matrix list alpha
matrix list gamma
matrix list pi 
matrix list G

/*
r(alpha): Rotemberg weight vector 
r(beta): just-identified coefficient vector
r(G): ghrowth weight vector   
*/

/*
Main
----
 y(varname): 			outcome variable: EMPLOYED        
 x(varname): 			endogeous variable: WORK PERMIT
 z(varlist): 			variable list of instruments: SHARE: INDUS COM IN SYR * DIST TO GOV  
 weightstub(varlist): 	variable list of weights : SHIFT: (1) REF WITH WP BY GOV (2) REF WITH WP BY INDUS

Options
-------                        
controls(varlist): 		list of control variables        
absorb(varname): 		fixed effect to absorb            
weight_var(varname): 	name of analytic weight variable for regression        
by(varname): 			name of the time variable that is interacted with the shares
*/



/* ANNA CODE !!!!!!!!!

foreach var of varlist `ind_stub'* {
	if regexm("`var'", "`ind_stub'(.*)") {
		local ind = regexs(1)
		} // extracts last part of the variable name: country name (e.g. "Somalia") and saved in local ind
	tempvar temp // define variable "temp" that will be constructed as variable below as temporary variable -> not to be saved in dataset when exiting Stata
	gen `temp' = `var' * `growth_stub'`ind' // constructing the z variable again (?), always for the share_countryX that matches the shift_countryX of same country X
	regress `x' `temp' `controls' [pweight=`weight'], cluster(ea) // first stage
	local pi_`ind' = _b[`temp'] // save first-stage beta coefficients
	test `temp'
	local F_`ind' = r(F) // save first-stage F-stat
	regress `y' `temp' `controls' [pweight=`weight'], cluster(ea) // reduced form
	local gamma_`ind' = _b[`temp'] // save reduced-form beta coefficients
	drop `temp'
	}

*/
