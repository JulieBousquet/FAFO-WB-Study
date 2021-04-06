

*DATA 2016 ONLY
use "$data_JLMPS_base/JLMPS 2016 xs v1.1.dta", clear 


tab gov 
codebook gov
lab list Lgov
*To be in line with the 
*keep if gov == 11 | gov == 21 | gov == 22  
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

*save "$data_JLMPS_final/01_JLMPS_10_16_Clean.dta", replace
save "$data_JLMPS_final/01_JLMPS_10_16_xs_clear.dta", replace










*USE LSMS 2016 & LSMS 2010

use "$data_JLMPS_base/JLMPS 2016 rep xs v1.1.dta", clear 

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

*save "$data_JLMPS_temp/JLMPS_2010-2016_xs.dta", replace
save "$data_JLMPS_final/02_JLMPS_10_16_rep_xs_clear.dta", replace

















/*

*USE LSMS 2016 & LSMS 2010

use "$data_JLMPS_2016_base/JLMPS 2016 rep xs v1.1.dta", clear 

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

save "$data_JLMPS_temp/JLMPS_2010-2016_xs.dta", replace


*/
















/*


use "$data_JLMPS_final/01_JLMPS_10_16_Clean.dta", clear

keep indid district_id governorate_id q11207 nationality_cl forced_migr

*indid_2010
*isid indid

merge 1:1 indid using "$data_JLMPS_final/JLMPS_2010-2016_xs.dta"

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

save "$data_JLMPS_final/JLMPS_2010-2016.dta", replace

*/
