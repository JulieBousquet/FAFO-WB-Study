
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

tab year 

merge m:1 district_id using "$data_2020_final/Jordan2020_IV"
drop if _merge == 2
drop _merge

merge m:1 governorate_id using "$data_UNHCR_final/UNHCR_NbRef_byGov.dta"
drop if _merge == 2
drop _merge

bys year: tab governorate_en, m
bys year: tab district_en, m

replace IV_SS = 0 if year == 2014

*2SLS
*First stage

*Number of refugee with work permits 
*In 2020
bys year: tab rsi_work_permit, m
bys year governorate_en: tab rsi_work_permit, m

reg rsi_work_permit IV_SS NbRefugeesoutcamp i.year c.district_id, robust cl(district_id) 

predict iv_WPhat, xb

reg  rsi_work_hours_7d 			iv_WPhat i.year c.district_id ros_age ros_gender hh_hhsize hh_gender, robust cl(district_id)	
reg  rsi_se_income_lm_cont 		iv_WPhat i.year c.district_id ros_age ros_gender hh_hhsize hh_gender, robust cl(district_id)	
reg  rsi_wage_income_lm_cont 	iv_WPhat i.year c.district_id ros_age ros_gender hh_hhsize hh_gender, robust cl(district_id)	
reg  ros_employed 				iv_WPhat i.year c.district_id ros_age ros_gender hh_hhsize hh_gender, robust cl(district_id)	

/* 2020
rsi_work_hours_m 
rsi_work_hours_7d 
rsi_se_income_typ_cont 
rsi_se_income_lm_cont 
hh_se_income_l12m_cat 
hh_se_income_lm_cat 
rsi_wage_income_typ_cont 
rsi_wage_income_lm_cont 
hh_wage_income_l12m_cat 
hh_wage_income_lm_cat 
ros_employed
ros_gender 
ros_age
hh_gender 
hh_hhsize 
hh_poor
*/

/*2014
rsi_work_hours_7d 
rsi_wage_income_lm_cont 
rsi_work_permit 
ros_gender 
ros_age 
ros_work_permit 
ros_wage_income_lm_cont 
ros_employed 
ros_wage_income_lm_cont_ln
hh_gender 
hh_hhsize
*/

ivregress 2sls rsi_work_hours_7d 		i.year c.district_id ros_age ros_gender hh_hhsize hh_gender (rsi_work_permit = IV_SS), robust cl(district_id)
ivregress 2sls rsi_se_income_lm_cont 	i.year c.district_id ros_age ros_gender hh_hhsize hh_gender (rsi_work_permit = IV_SS), robust cl(district_id)
ivregress 2sls rsi_wage_income_lm_cont 	i.year c.district_id ros_age ros_gender hh_hhsize hh_gender (rsi_work_permit = IV_SS), robust cl(district_id)
ivregress 2sls ros_employed 			i.year c.district_id ros_age ros_gender hh_hhsize hh_gender (rsi_work_permit = IV_SS), robust cl(district_id)

/*
matrix list e(b)
*Saving the coefficients of IV
matrix 	b= e(b)
svmat 	b, name(iv1_1_)

return list 
matrix list e(b)
*Saving the coefficients of OLS
matrix 	b= e(b)
svmat 	b, name(ols)

collapse (mean) ols*
matrix list e(V)
*Store the SE for beta0, beta1, beta2
matrix se_0 = _se[_cons]
matrix se_1 = _se[rsi_work_permit]

svmat 	se_0, name(se_0)
ren 	se_01 se_0
svmat 	se_1, name(se_1)
ren 	se_11 se_1
collapse (mean) se*
*/


*In 2014
use "$data_2014_final/Jordan2014_02_Clean.dta", clear
tab rsi_work_permit, m

bys district_en: gen shift_IV = rsi_work_permit if refguees == 1 

























