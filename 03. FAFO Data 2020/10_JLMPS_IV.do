



use "$data_JLMPS_2016/00. Orig/JLMPS 2016 xs v1.1 STATA/JLMPS 2016 xs v1.1.dta", clear 


tab gov 
codebook gov
lab list Lgov
keep if gov == 11 | gov == 21 | gov == 22  
/*
11 Amman
21 Irbid
22 Mafraq
*/

bys gov: tab district, m 

gen district_en = ""
*Amman 11
replace district_en = "Marka" if district == 2 & gov == 11
replace district_en = "Qasabet Amman" if district == 1 & gov == 11
replace district_en = "Quaismeh" if district == 3 & gov == 11
replace district_en = "Wadi Essier" if district == 5 & gov == 11

*Irbid 21
replace district_en = "Qasabet Irbid" if district == 1 & gov == 21

*Mafraq 22
replace district_en = "Badiah Shamaliyyeh" if district == 2 & gov == 22
replace district_en = "Badiah Shamaliyyeh Gharbiyyeh" if district == 3 & gov == 22
replace district_en = "Qasabet El-Mafraq" if district == 1 & gov == 22

drop if mi(district_en)
/*
 Amman
 -----
 Marka 
 Amman 
 Quaismeh
 Wadi Essier 

 Irbid
 -----
 Qasabet Irbid

 Mafraq
 ------
 Badiah Shamaliyyeh 
 Badiah Shamaliyyeh Gharbiyyeh 
 Qasabet El-Mafraq 
*/

tab q11207

/*
q11207. Do you |
 have a permit |
    to work in |
       Jordan? |      Freq.     Percent        Cum.
---------------+-----------------------------------
           Yes |        123       11.94       11.94
            No |        584       56.70       68.64
Not Applicable |        323       31.36      100.00
---------------+-----------------------------------
         Total |      1,030      100.00


*/
bys forced_migr: tab  q11207

/*
-> forced_migr = Yes

q11207. Do you |
 have a permit |
    to work in |
       Jordan? |      Freq.     Percent        Cum.
---------------+-----------------------------------
           Yes |         75        8.24        8.24
            No |        532       58.46       66.70
Not Applicable |        303       33.30      100.00
---------------+-----------------------------------
         Total |        910      100.00
*/

bys nationality_cl: tab  q11207

/*
-> nationality_cl = Syrian

q11207. Do you |
 have a permit |
    to work in |
       Jordan? |      Freq.     Percent        Cum.
---------------+-----------------------------------
           Yes |         79        8.63        8.63
            No |        529       57.81       66.45
Not Applicable |        307       33.55      100.00
---------------+-----------------------------------
         Total |        915      100.00
*/



tab district_en
sort district_en
egen district_id = group(district_en) 

sort gov
gen governorate_en = ""
replace governorate_en = "Amman" if gov == 11
replace governorate_en = "Irbid" if gov == 21
replace governorate_en = "Mafraq" if gov == 22
sort governorate_en
egen governorate_id = group(governorate_en)

save "$data_JLMPS_2016_final/JLMPS_IV.dta", replace


keep indid district_id governorate_id q11207 nationality_cl forced_migr

*indid_2010
*isid indid

merge 1:1 indid using "$data_JLMPS_2016_final/JLMPS_2010-2016_xs.dta"

tab _merge round
drop _merge 
tab governorate_id , m
tab district_id , m
tab nationality_cl, m 
tab forced_migr, m 
codebook forced_migr //1 yes
codebook nationality_cl //2 Syrian
drop if nationality_cl != 1 & nationality_cl != 2
replace forced_migr = 1 if nationality_cl == 2 & mi(forced_migr)
replace forced_migr = 0 if nationality_cl == 1 & mi(forced_migr)

tab q11207, m 
ren q11207 work_permit
codebook work_permit
bys nationality_cl: tab work_permit, m
replace work_permit = 2 if mi(work_permit) & round == 2010 & nationality_cl == 2

bys round: tab nationality_cl

ren round year 
bys year: tab governorate_en, m
bys year: tab district_en, m

merge m:1 district_id using "$data_2020_final/Jordan2020_IV" 

drop if _merge == 2 
drop _merge 

merge m:1 governorate_id using "$data_UNHCR_final/UNHCR_NbRef_byGov.dta"
drop if _merge == 2
drop _merge

tab work_permit 
codebook work_permit
drop if work_permit == 99
* replace work_permit = 0 if work_permit == 99

replace IV_SS = 0 if year == 2010
tab IV_SS , m

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
xi: ivreg2 basicwg3 i.year i.district_id (agg_work_permit= IV_SS) if nationality_cl==1, cluster(district_id)
















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


use  "$data_UNHCR_final/UNHCR_NbRef_byGov.dta", clear
