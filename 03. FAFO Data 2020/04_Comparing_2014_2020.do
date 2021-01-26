

use "$data_2014_final/Jordan2014_ROS_HH_RSI.dta", clear
desc 

/*
 obs:        21,524                          
 vars:       738                          
*/

distinct hhid 
* 3860

distinct iid 
* 21524 

************ DEMOGRAPHICS ************

*Governorate
tab governorate, m 
tab q101, m 
/*
Governorate |      Freq.     Percent        Cum.
------------+-----------------------------------
      Amman |      4,821       22.40       22.40
      Irbid |      6,269       29.13       51.52
     Mafraq |     10,434       48.48      100.00
------------+-----------------------------------
      Total |     21,524      100.00
*/


desc q102 q103 q104 q105 q106 q107 q108

*District
bys q101: tab q102, m 
bys q101: distinct q102
/*
Amman: 9
Irbid: 9
Mafraq: 4
*/

*Sub-District
bys q101: distinct q103
desc q103 

*Locality
desc q104
bys q101: distinct q104
/*
Amman: 12
Irbid: 16
Mafraq: 14
*/
*Area
desc q105 
*Neighborhood
desc q106
*Block Number
desc q107
*Building Number
desc q108

*************
** REFUGEE **
*************

*Household Head info
tab nat_hh, m 
tab nat_samp, m   
tab HHgroup, m 
codebook HHgroup 
/*
            tabulation:  Freq.   Numeric  Label
                         3,675         1  Household in Zaatari camp
                         9,253         2  Household with Syrian refugee
                                          head outside camp
                         7,950         3  Household with Jordanian
                                          non-refugee head
                           646         4  Other

*/
tab HHrefugee
tab HHrefugee, m
codebook HHrefugee

*br HHrefugee HHgroup nat_samp nat_hh survey_hh survey_rsi survey_ros
format HHrefugee nat_samp nat_hh  %15.0g
format HHgroup  %50.0g

*Roster infi
*Citizenship
tab q307, m 
ren q307 nationality

*Refugee status 
tab q308, m 
replace q308 = 2 if mi(q308) & hhid == 2223004 

ren q308 refugee 

******************
** WORK PERMITS **
******************

*RSI
tab r301 , m
*Refugee and in RSI
tab r301 if survey_rsi == 1 & refugee == 1 , m
/*
Applied for |
work permit |
for current |
   main job |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |         60       13.02       13.02
         No |        349       75.70       88.72
          . |         52       11.28      100.00
------------+-----------------------------------
      Total |        461      100.00
*/

*ROSTER
*Employed 
tab q502 
tab q503 
tab q504
codebook q531
codebook q528
preserve
keep if q502 == 1 | q503 == 1 | q504 == 1
keep if refugee == 1 
tab q528, m //Type contract
tab q531, m //Work permit
*br hhid iid q502 q503 q504 r301 q528 q531 if mi(q531)
*format q528  %30.0g
restore
replace q531 = r301 if iid == 11237021
replace q531 = r301 if iid == 21122121
replace q531 = 1 if q528 == 1 //if written agreement = permit
replace q531 = 2 if q528 == 2 //if oral agreement = NO permit
replace q531 = 2 if q528 == 3 //if neither = NO permit


/*

Work permit |
   for main |
        job |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |         52        8.46        8.46
         No |        563       91.54      100.00
------------+-----------------------------------
      Total |        615      100.00


*/
ren r301 rsi_work_permit
ren q531 ros_work_permit 

tab ros_work_permit, m 

recode rsi_work_permit (2=0)
recode ros_work_permit (2=0) 
lab def yesno 1 "Yes" 0 "No", modify
lab val ros_work_permit yesno
lab val rsi_work_permit yesno

tab ros_work_permit if (q502 == 1 | q503 == 1 | q504 == 1) & (refugee == 1)  , m
*Yes |         52        8.46       
*No  |        563       91.54  

tab rsi_work_permit if survey_rsi == 1 & refugee == 1 , m
* Yes |         60       13.02       13.02
*  No |        349       75.70       88.72


******************
**** OUTCOMES ****
******************

**** EMPLOYEMENT ****

tab q502  
tab q503  
tab q504 

*Age
tab q305
*drop if q305 < 15 //Keep only adult sample 

*Has never worked
tab q501
codebook q501
*drop if q501 == 97 //Keep only adult who has worked at least once in their life

*The var
gen ros_employed = 0
replace ros_employed = 1 if q502 == 1 | q503 == 1 | q504 == 1
tab ros_employed, m
*Note that if they were employed, then they were eligible to RSI.
*So in RSI, is only employed people
tab ros_employed if (q305 >= 15) & (q501 != 97) 

bys ros_employed: tab q303 if survey_rsi == 1

**** WAGE INCOME ****

*HOUSEHOLD 
codebook q900 // Wage income: if q900 == INCOME 1
tab q900_qy // Wage income last year
tab q900_qm // Wage income last month

*ROSTER
tab q532 //Cash Income Main Job Last month (cont)
tab q532new //Cash Income Main Job Last month (cat)

ren q532 ros_wage_income_lm_cont
gen ros_wage_income_lm_cont_ln = ln(ros_wage_income_lm_cont)

tab q533 //Usual Monthly cash income (cont)
tab q533new //Usual Monthly cash income (cat)

tab q536 //Cash Income Additional Job Last month (cont)
tab q536new //Cash Income Additional Job Last month (cat)
tab q532and536 //Total cash income last month (cont)
tab q532and536new //Total cash Income last month (cat)

*RSI 
tab r204 //Cash Income Main Job Last month (cont)
tab r204new //Cash Income Main Job Last month (cat)

ren r204 rsi_wage_income_lm_cont


tab r205 //Usual Monthly cash income (cont)
tab r205new //Usual Monthly cash income (cat)

tab r226 //Cash Income Additional Job Last month (cont)
tab r226new //Cash Income Additional Job Last month (cat)

**** SELF EMPLOYED INCOME ****
codebook q901 // Self-employment income: if q901 == INCOME 1
tab q901_qy // Self-employment income last year
tab q901_qm // Self-employment income last month

*Section 9: wealth 
*Wage income 
tab q900 
tab q900_qy 
tab q900_qm 
*Self employment income 
tab q901 
tab q901_qy 
tab q901_qm 
*Transfer income 
tab q902 
tab q902_qy 
tab q902_qm 
*Property income 
tab q903 
tab q903_qy 
tab q903_qm 
*Other Income 
tab q904 
tab q904_qy 
tab q904_qm 
*Total income 
tab q905 
tab q905_qy

*Industry
tab q514 
tab q514new

*Occupation 
tab q515 
tab q515new


***** HOURS WORKED ****
tab r203
ren r203 rsi_work_hours_7d

tab r227
tab r228


****** DEMOGRAPHICS ******

tab HHsex , m //Sex of HH
tab RSIsex, m //Sex of RSI resp 
tab q303, m //Sex
ren q303 ros_gender
ren HHsex hh_gender 

tab q115_tnew, m
tab q115_t, m
ren q115_t hh_hhsize

tab q305, m
ren q305 ros_age


*drop if q305 < 15 
*drop if q501 == 97 
*drop if refugee != 1

***** DETERMINANT OF GETTING A WORK PERMIT 
preserve
keep if refugee == 1
logit rsi_work_permit ///
        ros_employed  ///
        ros_wage_income_lm_cont ///
        rsi_work_hours_7d  
restore

***** CHARACTERISTICS OF INDIVIDUAALS/HOUSEHOLDS GETTING A WP

preserve

keep if refugee == 1
ttest hh_hhsize, by(rsi_work_permit)
ttest ros_gender, by(rsi_work_permit)
ttest hh_gender, by(rsi_work_permit)
ttest ros_age, by(rsi_work_permit)
*ttest economy, by(rsi_work_permit)
ttest refugee, by(rsi_work_permit)

logit rsi_work_permit hh_hhsize 
logit rsi_work_permit ros_gender 
logit rsi_work_permit hh_gender 
logit rsi_work_permit ros_age

logit rsi_work_permit ros_age hh_hhsize ros_gender ros_age

  *i.industry i.occupation 
restore

***** HOW DOES HAVING A WP AFFECTS OUTCOME VAR 
preserve

keep if refugee == 1
reg ros_wage_income_lm_cont_ln rsi_work_permit, robust
reg rsi_work_hours_7d rsi_work_permit, robust
reg ros_employed rsi_work_permit, robust
restore

save "$data_2014_final/Jordan2014_02_Clean.dta", replace























































/*
Share
Number of refguees coming from gov X in syra and residing in Jordan
*/
use "$data_2020_final/Jordan2020_02_Clean.dta", clear
tab QR117, m
bys refugee: tab QR117, m

/*
  Syrian governorate live before |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
                      Al Hasakah |          5        0.74        0.74
                          Aleppo |         74       10.93       11.67
                       Al Raqqah |          6        0.89       12.56
                      Al Suwayda |          1        0.15       12.70
                           Daraa |        224       33.09       45.79
                    Deir El Zour |          2        0.30       46.09
                            Hama |         27        3.99       50.07
                            Homs |        197       29.10       79.17
                           Idlib |          6        0.89       80.06
                        Quneitra |          3        0.44       80.50
                  Rural Damascus |         37        5.47       85.97
                        Damascus |         65        9.60       95.57
                               . |         30        4.43      100.00
---------------------------------+-----------------------------------
                           Total |        677      100.00
*/


/*
*Number of syrians employed in Y industry in Syria pre crisis in each gov
*/
import excel "$data_LFS_base/Workers distribution by governorate.xlsx", clear firstrow sheet("Workers by gov, industries, tot")

tab Governorates
ren Governorates governorate
gen id_region = 1 if governorate == "AL-Hasakeh"
replace id_region = 2 if governorate == "Aleppo"
replace id_region = 3 if governorate == "AL-Rakka"
replace id_region = 4 if governorate == "AL-Sweida"
replace id_region = 5 if governorate == "Damascus"
replace id_region = 6 if governorate == "Dar'a"
replace id_region = 7 if governorate == "Deir-ez-Zor"
replace id_region = 8 if governorate == "Hama"
replace id_region = 9 if governorate == "Homs"
replace id_region = 10 if governorate == "Idleb"
replace id_region = 11 if governorate == "Lattakia"
replace id_region = 12 if governorate == "Quneitra"
replace id_region = 13 if governorate == "Damascus Rural"
replace id_region = 14 if governorate == "Tartous"

drop if governorate == "Total"

ren Agricultureandforestry agriculture 
ren Industry factory 
ren Buildingandconstruction construction 
ren Hotelsandrestaurantstrade trade 
ren Transportationstoragecommun transportation 
ren Moneyinsuranceandrealestat banking 
ren Services services 

/*
Distance between Syrian governoarate (fronteer or centroid or largest city?) AND
Jordan district of residence
*/

/*
shp2dta using "$data_LFS_shp/gadm36_SYR_1.shp", ///
  database("$data_LFS_temp/syr_adm1") ///
  coordinates("$data_LFS_temp/syr_coord1") ///
  genid(id_region) replace
*/

use "$data_LFS_temp/syr_adm1.dta", clear
  rename id_region _ID 
  merge 1:m _ID using "$data_LFS_temp/syr_coord1.dta"
  egen gov_syria_long = mean(_X), by(_ID)
  egen gov_syria_lat = mean(_Y), by(_ID)
  duplicates drop _ID, force
  ren NAME_1 governorate_syria
  keep gov_syria_long gov_syria_lat governorate

tab governorate_syria
replace governorate_syria = "Al Raqqah" if governorate_syria == "Ar Raqqah"
replace governorate_syria = "Al Suwayda" if governorate_syria == "As Suwayda'"
replace governorate_syria = "Daraa" if governorate_syria == "Dar`a"
replace governorate_syria = "Deir El Zour" if governorate_syria == "Dayr Az Zawr"
replace governorate_syria = "Hama" if governorate_syria == "Hamah"
replace governorate_syria = "Homs" if governorate_syria == "Hims"
replace governorate_syria = "Rural Damascus" if governorate_syria == "Rif Dimashq"
replace governorate_syria = "Al Hasakah" if governorate_syria == "Al Ḥasakah"

list governorate_syria 

keep if governorate_syria ==  "Al Hasakah" | ///
        governorate_syria ==  "Aleppo" | ///
        governorate_syria ==  "Al Raqqah" | ///
        governorate_syria ==  "Al Suwayda" | ///
        governorate_syria ==  "Daraa" | ///
        governorate_syria ==  "Deir El Zour" | ///
        governorate_syria ==  "Hama" | ///
        governorate_syria ==  "Homs" | ///
        governorate_syria ==  "Idlib" | ///
        governorate_syria ==  "Quneitra" | ///
        governorate_syria ==  "Damascus" | ///
        governorate_syria ==  "Rural Damascus" 
sort governorate_syria 
gen id_gov_syria = _n
list id_gov_syria governorate_syria

save "$data_2020_final/governorate_loc_syr.dta", replace


use "$data_2020_final/Jordan2020_02_Clean.dta", clear

tab district_en, m 
tab district_lat, m
tab district_long, m
tab sub_district_en, m  
tab locality_en, m 
tab area_en, m 

bys refugee: tab QR117, m
decode QR117, gen(governorate_syria)
tab governorate_syria, m 

sort governorate_syria
egen id_gov_syria = group(governorate_syria)
tab id_gov_syria 
list id_gov_syria governorate_syria

replace governorate_syria = "-99 Missing" if mi(governorate_syria) & refugee == 1
replace governorate_syria = "-98 Non Applicable" if mi(governorate_syria) & (refugee == 2 | refugee == 3)

merge m:1 id_gov_syria using "$data_2020_final/governorate_loc_syr.dta"
drop _merge

tab governorate_syria, m
tab gov_syria_long, m
tab gov_syria_lat, m

save "$data_2020_final/Jordan2020_geo_Syria.dta", replace 


keep  gov_syria_lat gov_syria_long district_lat district_long sub_district_long ///
      sub_district_lat area_long area_lat governorate_en locality_long locality_lat ///
      locality_en district_en sub_district_en governorate_syria

preserve
keep district_en district_lat district_long
duplicates drop district_en, force 
ren district_en geo_unit 
ren district_long geo_long 
ren district_lat geo_lat
tempfile district_geo 
save `district_geo'
restore 
preserve 
keep governorate_syria gov_syria_long gov_syria_lat
duplicates drop governorate_syria, force 
ren governorate_syria geo_unit 
ren gov_syria_long geo_long 
ren gov_syria_lat geo_lat
tempfile gov_syria_geo
save `gov_syria_geo'
restore 

use  `district_geo', clear 
gen gunit = "Districts"
append using `gov_syria_geo'
replace gunit = "Governorates" if mi(gunit) & (geo_unit != "-99 Missing" & ///
                                             geo_unit != "-98 Non Applicable")
drop if geo_unit == "-99 Missing" 
drop if geo_unit == "-98 Non Applicable" 

encode gunit, gen(unit)

save "$data_2020_temp/Jordan2020_geo.dta", replace 



*ssc install geodist
h geodist

**** MAP OF JORDAN + POINT DISTRICT
use "$data_LFS_temp/governorate_names.dta", clear
spmap using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(eggshell) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Number of project", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    ///
   point(data("$data_2020_final/Jordan2020_02_Clean.dta") xcoord(district_long)      ///
        ycoord(district_lat) size(*0.7) fcolor(blue)) 

*MAP OF SYRIA + POINT GOVERNROATE
use "$data_LFS_temp/governorate_names.dta", clear
spmap using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(eggshell) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Number of project", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    ///
   point(data("$data_2020_final/governorate_loc_syr.dta") xcoord(gov_syria_long)      ///
        ycoord(gov_syria_lat) size(*0.7) fcolor(blue)) 

use "$data_2020_final/Jordan2020_02_Clean.dta", clear


**** MAP OF JORDAN AND SYRIA (VIZUALIZING DISTANCE)
use "$data_LFS_temp/governorate_names.dta", clear
spmap using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(eggshell) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Number of project", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    ///
   point(data("$data_2020_temp/Jordan2020_geo.dta") xcoord(geo_long)      ///
        ycoord(geo_lat) by(unit) size(*0.7) fcolor(red blue))

graph export "$out_2020/map_districtJOR_govSYR.pdf", as(pdf) replace

use "$data_2020_final/Jordan2020_geo_Syria.dta", clear 

h geodist

geodist district_lat district_long gov_syria_lat gov_syria_long, gen(distance_dis_gov)
tab distance_dis_gov, m
lab var distance_dis_gov "Distance (km) between JORD districts and SYR centroid governorates"

geodist sub_district_lat sub_district_long gov_syria_lat gov_syria_long, gen(distance_subdis_gov)
tab distance_subdis_gov, m
lab var distance_subdis_gov "Distance (km) between JORD sub-districts and SYR centroid governorates"

geodist locality_lat locality_long gov_syria_lat gov_syria_long, gen(distance_loc_gov)
tab distance_loc_gov, m 
lab var distance_loc_gov "Distance (km) between JORD localities and SYR centroid governorates"

geodist area_lat area_long gov_syria_lat gov_syria_long, gen(distance_area_gov)
tab distance_area_gov, m
lab var distance_area_gov "Distance (km) between JORD areas and SYR centroid governorates"

unique distance_dis_gov //53
unique distance_subdis_gov //63
unique distance_loc_gov //69
unique distance_area_gov //82

/*
SHIFT 
*/

*Number of refugee with work permits 
*In 2020
use "$data_2020_final/Jordan2020_02_Clean.dta", clear
tab rsi_work_permit, m
*In 2014
use "$data_2014_final/Jordan2014_02_Clean.dta", clear
tab rsi_work_permit, m

