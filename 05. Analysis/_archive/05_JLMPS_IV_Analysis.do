




*use "$data_JLMPS_final/01_JLMPS_10_16_Clean.dta", clear
*use "$data_JLMPS_final/JLMPS_2010-2016.dta", clear 
use "$data_final/02_JLMPS_10_16.dta", clear 

merge m:1 district_id using "$data_final/03_ShiftShare_IV.dta" 

drop if _merge == 2 
drop _merge 

merge m:1 governorate_id using "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta"
drop if _merge == 2
drop _merge

tab work_permit 
codebook work_permit
drop if work_permit == 99
* replace work_permit = 0 if work_permit == 99

replace IV_SS = 0 if year == 2010
tab IV_SS , m


save "$data_final/05_IV_JLMPS_Analysis.dta", replace













preserve
keep if nationality_cl == 2 //REFUGEE
*gen ref = 1 
*
reg work_permit nationality_cl IV_SS  i.year c.district_id, robust cl(district_id) 
*NbRefugeesoutcamp
predict iv_WPhat, xb
*pwcorr iv_WPhat work_permit
tab iv_WPhat , m
collapse (mean) iv_WPhat, by(district_id year) // sampling wieghts [pweight=weight]
tempfile instru
save `instru'
restore 

merge m:1 district_id year using `instru'
*share refugee with wp

bys nationality_cl: tab work_permit
tab nationality_cl

keep if nationality_cl == 1 //NATIVES

reg  basicwg3 			iv_WPhat
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat i.year
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat c.district_id
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat i.year c.district_id
estimates table, star(.05 .01 .001)

reg  basicwg3 			iv_WPhat, robust
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat i.year, robust
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat c.district_id, robust
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat i.year c.district_id, robust
estimates table, star(.05 .01 .001)

reg  basicwg3 			iv_WPhat, robust cl(district_id)	
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat i.year, robust cl(district_id)	
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat c.district_id, robust cl(district_id)	
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat i.year c.district_id, robust cl(district_id)	
estimates table, star(.05 .01 .001)

reg  basicwg3 			iv_WPhat i.year c.district_id , robust cl(district_id)	

*HAUSNAB TEST OF ENDO 
ivregress 2sls basicwg3 (work_permit = IV_SS)
est store IV
reg  basicwg3 work_permit 	
hausman IV 
drop _est_IV


reg  usemp1 			iv_WPhat i.year c.district_id , robust cl(district_id)	
reg  cremp1 			iv_WPhat i.year c.district_id , robust cl(district_id)	
reg  crhrsday 			iv_WPhat i.year c.district_id , robust cl(district_id)	

 ros_age ros_gender hh_hhsize hh_gender, robust cl(district_id)	
reg  rsi_wage_income_lm_cont 	iv_WPhat i.year c.district_id ros_age ros_gender hh_hhsize hh_gender, robust cl(district_id)	
reg  ros_employed 				iv_WPhat i.year c.district_id ros_age ros_gender hh_hhsize hh_gender, robust cl(district_id)	
















/*
use "$data_2020_final/Jordan2020_IV_fullds", clear 

*2SLS
*First stage

*Number of refugee with work permits 
*In 2020
bys year: tab rsi_work_permit, m
bys year governorate_en: tab rsi_work_permit, m

tab nationality, m


reg rsi_work_permit IV_SS NbRefugeesoutcamp i.year c.district_id, robust cl(district_id) 

predict iv_WPhat, xb

collapse (mean) iv_WPhat, by(district_en governorate_en)

merge 1:m district_en using "$data_JLMPS_2016_final/JLMPS_2010-2016_xs.dta"
drop _merge 
ren round year 

*/


use "$data_final/05_IV_JLMPS_Analysis.dta", clear

preserve
keep if nationality_cl == 2 //REFUGEE
drop if year == 2010
collapse (sum) work_permit, by(district_id) 
keep work_permit district_id 
bys district_id: tab work_permit  
rename work_permit agg_work_permit
tempfile instru
save `instru'
restore 

merge m:1 district_id using `instru'
tab year agg_work_permit

tab agg_work_permit, m

tab _merge nationality_cl

tab district_id agg_work_permit
xtset district_id 
xi: ivreg2 basicwg3 i.year i.district_id (agg_work_permit= IV_SS) if nationality_cl==1 , cluster(district_id)


************ NEW USING JF ********
use "$data_final/05_IV_JLMPS_Analysis.dta", clear

preserve
keep if nationality_cl == 2 //REFUGEE
drop if year == 2010
collapse (sum) work_permit if year == 2016, by(district_id)
ren work_permit agg_wp
tempfile wp2016
save `wp2016'
restore

merge m:1 district_id using `wp2016'
drop _merge

tab agg_wp

xtset district_id year

ivreg2 basicwg3 i.district_id i.year (agg_wp= IV_SS) if nationality_cl==1  [aw=expan_indiv] , cluster(district_id)



/* IV ANNA
ivreghdfe ln_cons_real  (l1_ln_dist_50_ind=l1_ln_Netw_IV_ind_50) [pw=pw], absorb(hh_id year) cluster(ea) first savefirst savefprefix(f2_50_c3)

acreg ln_cons_real  (l1_ln_dist_50_ind=l1_ln_Netw_IV_ind_50) [pw=pw], id(hh_id) time(year) pfe1(hh_id) pfe2(year) spatial latitude(LAT_DD_MOD) longitude(LON_DD_MOD) dist(50) bartlett
*/
