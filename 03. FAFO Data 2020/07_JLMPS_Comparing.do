
** JLMPS

use "$data_JLMPS_2010_base/final JLMPS.dta", clear

bys q101: tab q102

import excel using "$data_JLMPS_2010_base/Geographic Codes (Arabic-English).xlsx", firstrow clear

tab districtlabelEN
tab districtlabelAR
sort districtlabelEN  
list districtlabelAR districtlabelEN 
districtcode

use "$data_2020_final/Jordan2020_02_Clean.dta", clear
tab governorate_en
tab district_en

use "$data_2014_final/Jordan2014_02_Clean.dta", clear 
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

save "$data_JLMPS_2016_final/JLMPS_2010-2016_xs.dta", replace

