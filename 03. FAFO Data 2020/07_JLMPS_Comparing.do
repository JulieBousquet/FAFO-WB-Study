
** JLMPS

use "$data_JLMPS_2010_base/final JLMPS.dta", clear

bys q101: tab q102

import excel using "$data_JLMPS_2010_base/Geographic Codes (Arabic-English).xlsx", firstrow clear

tab districtlabelEN
tab districtlabelAR
list districtlabelAR districtlabelEN

use "$data_2020_final/Jordan2020_02_Clean.dta", clear

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

