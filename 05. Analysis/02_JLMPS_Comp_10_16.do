



** JLMPS

/*
use "$data_JLMPS_base/JLMPS 2010.dta", clear

bys q101: tab q102

import excel using "$data_JLMPS_base/Geographic Codes (Arabic-English).xlsx", firstrow clear

tab districtlabelEN
tab districtlabelAR
sort districtlabelEN  
list districtlabelAR districtlabelEN 
*districtcode

use "$data_FAFO2020_final/01_Jordan2020_Clean.dta", clear
tab governorate_en
tab district_en

use "$data_FAFO2014_final/01_Jordan2014_Clean.dta", clear 
tab governorate_en
tab district_en
bys governorate_en: tab district_en
/*
      district_en |      Freq.     Percent        Cum.
------------------+-----------------------------------
    Al Quwaysimah |         21        1.69        1.69
    Irbid Qasabah |        285       22.95       24.64
   Mafraq Qasabah |        101        8.13       32.77
            Marka |         22        1.77       34.54
North West Badiah |         35        2.82       37.36
   Northern Badia |        163       13.12       50.48
      Oman Kasbah |        104        8.37       58.86
         Russeifa |        107        8.62       67.47
     Wadi As-Seir |        146       11.76       79.23
    Zarqa Qasabah |        258       20.77      100.00
------------------+-----------------------------------
            Total |      1,242      100.00

*/
/*
Quaismeh                      Al Quwaysimah 
Qasabet Irbid                 Irbid Qasabah
Qasabet El- Mafraq            Mafraq Qasabah
Marka                         Marka
Badiah Shamaliyyeh            North West Badiah
Badiah Shamaliyyeh Gharbiyyeh Northern Badia
Qasabet Amman  District       Oman Kasbah
Russeifa                      Russeifa 
Wadi Essier District          Wadi As-Seir
Qasabet Ezzarqa               Zarqa Qasabah
*/

*/















use "$data_JLMPS_final/01_JLMPS_10_16_xs_clear.dta", clear

keep indid district_id governorate_id q11207 nationality_cl forced_migr

*indid_2010
*isid indid

*merge 1:1 indid using "$data_JLMPS_temp/JLMPS_2010-2016_xs.dta"
merge 1:1 indid using "$data_JLMPS_final/02_JLMPS_10_16_rep_xs_clear.dta"


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

*save "$data_JLMPS_final/JLMPS_2010-2016.dta", replace
save "$data_final/02_JLMPS_10_16.dta", replace

*/
















/*

keep indid district_id governorate_id q11207 nationality_cl forced_migr

*indid_2010
*isid indid


*merge 1:1 indid using "$data_JLMPS_final/JLMPS_2010-2016_xs.dta"
merge 1:1 indid  "$data_JLMPS_final/01_JLMPS_10_16_Clean.dta"

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

save "$data_JLMPS_2016_final/JLMPS_2010-2016.dta", replace
*/
