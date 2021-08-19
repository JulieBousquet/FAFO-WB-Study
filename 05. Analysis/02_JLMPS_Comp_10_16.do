

cap log close
clear all
set more off, permanently
set mem 100m

*log using "$analysis_do/01_Data_Cleaning_EL1.log", replace

   ****************************************************************************
   **                            DATA JLMPS                                  **
   **          INDIVIDUAL COMP AND MERGING OF DATASETS 2010-2016             **  
   ** ---------------------------------------------------------------------- **
   ** Type Do  :  DATA JLMPS   CLEANING/COMPARING/MERGING                    **
   **                                                                        **
   ** Authors  : Julie Bousquet                                              **
   ****************************************************************************



*JLMPS IV

/*
.a Non applicable (99)
.b Don't know (98)
*/

*Dictiornnary of geo unit Jordan as of 2015
import excel "$data_JLMPS_base/Location Codes Arabic 2015 revised 1.19.16 (for 2016).xlsx", firstrow clear
drop SubDistrict SubDistrictID Localities LocalitiesID
duplicates drop district_en, force 
tab district_en 
destring governorate district_id, replace 
sort governorate district_id
save "$data_JLMPS_temp/JLMPS_GeoUnits_Dico.dta", replace


*DATA 2016 ONLY to extract the WORK PERMIT VARIABLE AT THE INDIV LEVEL
use "$data_JLMPS_base/JLMPS 2016 xs v1.1.dta", clear 

tab gov 
codebook gov
lab list Lgov

bys gov: tab district, m 

ren gov governorate
ren district district_id
sort governorate district_id

merge m:1 governorate district_id using "$data_JLMPS_temp/JLMPS_GeoUnits_Dico.dta"
drop _merge 

tab q11207

/*
q11207. Do you |
 have a permit |
    to work in |
       Jordan? |      Freq.     Percent        Cum.
---------------+-----------------------------------
           Yes |        309       17.14       17.14
            No |      1,022       56.68       73.82
Not Applicable |        472       26.18      100.00
---------------+-----------------------------------
         Total |      1,803      100.00
*/
bys forced_migr: tab  q11207

/*
q11207. Do you |
 have a permit |
    to work in |
       Jordan? |      Freq.     Percent        Cum.
---------------+-----------------------------------
           Yes |        134        9.36        9.36
            No |        880       61.45       70.81
Not Applicable |        418       29.19      100.00
---------------+-----------------------------------
         Total |      1,432      100.00
*/

bys nationality_cl: tab  q11207

/*
q11207. Do you |
 have a permit |
    to work in |
       Jordan? |      Freq.     Percent        Cum.
---------------+-----------------------------------
           Yes |        122        9.33        9.33
            No |        786       60.09       69.42
Not Applicable |        400       30.58      100.00
---------------+-----------------------------------
         Total |      1,308      100.00
*/



tab  district_en
sort district_en
egen district_iid = group(district_en) 

tab governorate_en
sort governorate_en
egen governorate_iid = group(governorate_en)

gen year = round 
tab year

/*
       year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2016 |     33,450      100.00      100.00
------------+-----------------------------------
      Total |     33,450      100.00

*/ 

save "$data_JLMPS_final/01_JLMPS_16_xs_clear.dta", replace



*USE LSMS 2016 & LSMS 2010: CROSS SECTIONAL AND THE TWO years
*BUT REMOVED NON HARMNONIZED VARIABLES: WHICH MEANS THAT THE VARIABLES
*ON WORK PERMIT IN 2016 WAS NOT ASKED IN 2010 AND THUS REMOVED HERE.
*I WILL JUST MERGE BY INDIV ID LATER
use "$data_JLMPS_base/JLMPS 2016 rep xs v1.1.dta", clear 


tab gov 
codebook gov
lab list Lgov

bys gov: tab district, m 

ren gov governorate
ren district district_id
sort governorate district_id

merge m:1 governorate district_id using "$data_JLMPS_temp/JLMPS_GeoUnits_Dico.dta"
drop _merge 

tab  district_en
sort district_en
egen district_iid = group(district_en) 

tab governorate_en
sort governorate_en
egen governorate_iid = group(governorate_en)

gen year = round 
tab year 

/*
       year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2010 |     25,953       43.69       43.69
       2016 |     33,450       56.31      100.00
------------+-----------------------------------
      Total |     59,403      100.00
*/

save "$data_JLMPS_final/02_JLMPS_10_16_rep_xs_clear.dta", replace


use "$data_JLMPS_final/01_JLMPS_16_xs_clear.dta", clear

*q11207: Do you have a permit to work in Jordan?
*Apply to All individuals 15-59 years old who are neither Jordanian (nationality) 
*nor born in Jordan,  i.e. NOT Jordanian in Q207 and not in Jordan (=2) in Q2138

*Additional interesting variables: MODULE 11.2 MIGRATION
*q11201a q11201b q11202 q11203 q11204a q11204b q11205 q11206 
*q11208a q11208b q11212 q11213 q11214

*Work Permit 
tab q11207
*Do you have a legal contract?
bys forced_migr: tab q6145 q11207 
*TRIAL NOT: give 1 to refugees who said they have no WP but a legal contract
*replace q11207 = 1 if q6145 == 1 & forced_migr == 1 

*Understanding the NON APPLICABLE OPTION in work permit variable.
*"NA (do not work)" is specified in Q. 
*Check that
tab q11207 evrwrk 
*384 have never worked
bys sex: tab q11207 evrwrk 
*100 male and 284 female
tab brthyr
tab age
preserve
drop if age < 15 | age >59
tab age q11207  
restore 
*Larger proprtion of individual below 30 are in the "non applicable" category
tab q11207 q5301 
*449 did not get any employment in the last 3 months.
*But also only 17 have a work permit AND worked in the last 3 months
tab q11207 q5303
tab q11207 q5304
tab q11207 q6137
*Most are wage workers (204 wiht WP and 154 without WP 21 NA)
bys nationality_cl: tab q11207 q6145
tab q11207 nationality_cl
preserve
drop if nationality_cl != 2
tab q11207 , m
restore


*EMPLOYED: YES TO q5101, q5102, q5103, q5301, q5302 
codebook q5101 // 1 Yes 2 No 98 DK
tab q5101, m //Employed in last 7 days
tab q5102, m //Employed but temp absent
tab q5103_01, m //
tab q5103_02, m //
tab q5103_03, m //
tab q5103_04, m //
tab q5103_05, m //
tab q5103_06, m //
tab q5103_07, m //
tab q5103_08, m //
tab q5103_09, m //
tab q5103_10, m //
tab q5103_11, m //
tab q5103_12, m //
tab q5103_13, m //
tab q5301, m //Any empl last 3 month 
tab q5302_01, m //
tab q5302_02, m //
tab q5302_03, m //
tab q5302_04, m //
tab q5302_05, m //
tab q5302_06, m //
tab q5302_07, m //
tab q5302_08, m //
tab q5302_09, m //
tab q5302_10, m //
tab q5302_11, m //
tab q5302_12, m //
tab q5302_13, m //
gen employed = 1 if q5101 == 1 | q5102 == 1 | q5301 == 1 
replace employed = 0 if q5101 == 2 | q5102 == 2 | q5301 == 2 
replace employed = .b if q5101 == 98 | q5102 == 98 | q5301 == 98 
tab employed, m
lab def yesnodk 0 "No" 1 "Yes" .b "Don't know", modify
lab val employed yesnodk
tab employed, m

*Industry
/*
a. agricultural work (e.g., harvesting, cutting clover, irrigation)     
b. raising poultry/livestock     
c. producing ghee/cheese/butter     
d. preparing food/vegetables     
e. producing straw products/carpets/textile/ropes     
f. offering part-time services for others in a house/shop/hotel      
g. street seller     
h. construction worker     
i. collecting fuel/woodcutting      
j. sewing/embroidery/crochet     
k. sales & marketing    
l. trainee/apprentice      
m. working from home (IT programmers, etc.)  
*/

*Can you have worked in 2 differnt industry? 
gen flag = 1 if q5103_02 == 1 & ( q5103_01 == 1 | q5103_03 == 1 )
tab flag, m 
drop flag
*YES ! 
gen industry_en = ""

gen ind_agri         = "Agriculture"            if q5103_01 == 1 | q5302_01 == 1 
gen ind_livestock    = "Rasing Livestock"          if q5103_02 == 1 | q5302_02 == 1 
gen ind_prod_milk    = "Produce Milk-Based Products" if q5103_03 == 1 | q5302_03 == 1 
gen ind_prod_food    = "Produce Food Products"     if q5103_04 == 1 | q5302_04 == 1 
gen ind_prod_textile = "Produce Textile"        if q5103_05 == 1 | q5302_05 == 1 
gen ind_services     = "Services"               if q5103_06 == 1 | q5302_06 == 1 
gen ind_street_seller   = "Street Seller"             if q5103_07 == 1 | q5302_07 == 1 
gen ind_construction = "Construction"           if q5103_08 == 1 | q5302_08 == 1 
gen ind_coll_fuel    = "Collect Fuel"           if q5103_09 == 1 | q5302_09 == 1 
gen ind_sew          = "Sewing"                 if q5103_10 == 1 | q5302_10 == 1 
gen ind_sales        = "Sales and Marketing"       if q5103_11 == 1 | q5302_11 == 1 
gen ind_trainee         = "Trainee"                if q5103_12 == 1 | q5302_12 == 1 
gen ind_home         = "Work From Home (IT, etc)"  if q5103_13 == 1 | q5302_13 == 1 

/*
replace industry_en = "transportation" if industry_id == 5 
replace industry_en = "banking" if industry_id == 6 
*/

*Harmonize the industries based on the classification for the IV
*Aggregate several categories
gen agg_ind_agri     = "Agriculture"   if ind_agri == "Agriculture" | ///
                                    ind_livestock == "Rasing Livestock" | ///
                                    ind_prod_milk == "Produce Milk-Based Products" | ///
                                    ind_prod_food == "Produce Food Products" 
gen agg_ind_industry    = "Industry"      if ind_prod_textile == "Produce Textile" | ///
                                    ind_coll_fuel == "Services"  
gen agg_ind_construction = "Construction" if ind_construction == "Street Seller" 
gen agg_ind_services = "Services"      if ind_services == "Construction" | ///
                                    ind_home == "Collect Fuel"  | ///
                                    ind_sew == "Sewing" | ///
                                    ind_sales == "Sales and Marketing" | ///
                                    ind_trainee == "Trainee"
gen agg_ind_food     = "Food"       if ind_street_seller == "Work From Home (IT, etc)"


*DECISION : 
tab employed, m //YES = 1 
codebook q11207 //WP yes = 1
tab employed q11207

*Why NON APPLICABLE ? Should be 0/1/or missing?
recode q11207 (2=0) (99=.a) , gen(work_permit_orig)
tab work_permit_orig, m
lab def yesnona 0 "No" 1 "Yes" .a "Non Applicable"
lab val work_permit_orig yesnona
*If refugees with NA work (employed = 1), then we will say they do not 
*have a work permit. 
replace work_permit_orig = 0 if q11207 == 99 & employed == 1 & nationality_cl == 2 //Syrians
*If refugees with NA DO NOT work, then we will say missing.
replace work_permit_orig = . if q11207 == 99 & employed == 0 & nationality_cl == 2 //Syrians
tab work_permit_orig
lab var work_permit "From q11207. Do you have a permit to work in Jordan? - 1 Yes 0 No"

*TRIAL: give 1 to refugees who said they have no WP but a legal contract
tab q6145
gen work_permit = work_permit_orig 
*replace work_permit = 1 if q6145 == 1 & forced_migr == 1 //Forced Migrants
replace work_permit = 1 if q6145 == 1 & nationality_cl == 2 //Syrians
lab val work_permit yesnona
lab var work_permit "From work_permit_orig + 1 to refugees who said they have no WP but a legal contract"

keep  indid district_iid governorate_iid work_permit work_permit_orig ///
    nationality_cl forced_migr ///
      q11201a q11201b q11202 q11203 q11204a q11204b q11205 q11206 ///
      q11208a q11208b q11212 q11213 q11214 employed

*MERGE BY INDIVD ID TO INCLUDET THE WORK PERMIT VARIABLE INTO THE MAIN
*DATASET
merge 1:1 indid using "$data_JLMPS_final/02_JLMPS_10_16_rep_xs_clear.dta"

tab year, m
tab _merge year
drop _merge 
tab governorate_iid , m
tab district_iid , m
tab nationality_cl, m 
/*
Nationality |
      (five |
categories) |      Freq.     Percent        Cum.
------------+-----------------------------------
  Jordanian |     53,094       89.38       89.38
     Syrian |      3,003        5.06       94.43
   Egyptian |        623        1.05       95.48
 Other Arab |      2,551        4.29       99.78
      Other |        132        0.22      100.00
------------+-----------------------------------
      Total |     59,403      100.00
*/
tab forced_migr, m 
/*
     Forced |
    migrant |
  household |      Freq.     Percent        Cum.
------------+-----------------------------------
         No |     28,471       47.93       47.93
        Yes |      4,979        8.38       56.31
          . |     25,953       43.69      100.00
------------+-----------------------------------
      Total |     59,403      100.00
*/

tab nationality_cl forced_migr
/*
Nationalit |
   y (five |    Forced migrant
categories |       household
         ) |        No        Yes |     Total
-----------+----------------------+----------
 Jordanian |    26,875      1,523 |    28,398 
    Syrian |        65      2,853 |     2,918 
  Egyptian |       322          0 |       322 
Other Arab |     1,099        600 |     1,699 
     Other |       110          3 |       113 
-----------+----------------------+----------
     Total |    28,471      4,979 |    33,450 
*/
bys year: tab nationality_cl 
bys year: tab nationality_cl forced_migr

tab forced_migr_2011, m

codebook forced_migr //1 yes
codebook nationality_cl //2 Syrian

*Harmonize 2010 and 2016
*Natives (label 1) are not forced migrants
replace forced_migr = 0 if nationality_cl == 1 & year == 2010

*In 2016: 65 hh Syrians are NOT forced migrant.
*There were not refugees in 2010 datasets, just a few Syrians.
*I say that a Syrian in 2010 is not a forced migrant
replace forced_migr = 0 if nationality_cl == 2 & year == 2010
*only 85 syrians in 2010

* Egyptians (label 3) are not forced migrants
replace forced_migr = 0 if nationality_cl == 3 & year == 2010

*but there are two more categories
* "others" (laber 4) and "other arab" (label 5). 
replace forced_migr = 0 if nationality_cl == 4 & year == 2010
replace forced_migr = 0 if nationality_cl == 5 & year == 2010


*SIMILAR PROCEDURE FOR THE VARIABLE IN 2011

tab forced_migr_2011, m
codebook forced_migr_2011 //1 yes
replace forced_migr_2011 = 0 if nationality_cl == 1 & year == 2010
replace forced_migr_2011 = 0 if nationality_cl == 2 & year == 2010
replace forced_migr_2011 = 0 if nationality_cl == 3 & year == 2010
replace forced_migr_2011 = 0 if nationality_cl == 4 & year == 2010
replace forced_migr_2011 = 0 if nationality_cl == 5 & year == 2010

*In nationality_cl: we may want to keep 1 natives and 2 syrians  
*keep if nationality_cl == 1 | nationality_cl == 2 

*WORK PERMIT 
codebook work_permit // 2 = No , 1 = Yes , 99 = NA
bys nationality_cl: tab work_permit, m
*144 Egyptians have a WP 
*29  Other Arabs have a WP 
*14  Other have a WP  

*No work permits in 2010: put to missing 
replace work_permit = . if mi(work_permit) & round == 2010 
tab work_permit year , m 

tab  nationality_cl work_permit  if year == 2016 
tab work_permit, m
bys work_permit: distinct district_iid  
*WP are only in 27 distircts. That may be a problem once 
*we aggregate

bys year: tab governorate_en, m
bys year: tab district_en, m

*Employed
tab cremp1, m //1 weeks
bys year: tab cremp1
tab usemp1, m //3 months
bys year: tab usemp1


*save "$data_JLMPS_final/JLMPS_2010-2016.dta", replace
save "$data_final/02_JLMPS_10_16.dta", replace











use "$data_JLMPS_final/02_JLMPS_10_16_rep_xs_clear.dta", clear

















*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************
*********************************************************************





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













/*

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

*We assume that a Syrian is a forced migrant even tho this is not necessarly the case
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
*save "$data_final/02_JLMPS_10_16.dta", replace

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
