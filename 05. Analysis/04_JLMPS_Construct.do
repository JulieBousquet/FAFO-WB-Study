
cap log close
clear all
set more off, permanently
set mem 100m

log using "$out_analysis/04_JLMPS_Construct.log", replace

   ****************************************************************************
   **                            DATA JLMPS                                  **
   **                 MERGING OF DATASETS 2010-2016 JLMPS + IV SS            **  
   ** ---------------------------------------------------------------------- **
   ** Type Do  :  DATA JLMPS   MERGING IV/CONSTRUCTING OUTCOME VARIABLES     **
   **                                                                        **
   ** Authors  : Julie Bousquet                                              **
   ****************************************************************************


*Merge JLMPS and SHIFT SHARE
use "$data_final/02_JLMPS_10_16.dta", clear

drop if district_en == "Husseiniyyeh District"
distinct district_iid

*merge m:1 district_iid using "$data_final/03_ShiftShare_IV_1.dta" 
*tab district_iid if _merge == 2
*drop _merge 

drop governorate_iid
ren gov governorate_iid 


merge m:1 governorate_iid using "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta"
drop _merge
*save "$data_final/10_JLMPS_Distance_Zaatari.dta", replace 

********
*Dist.
********
/*
*NEW FOR SSIV REFUGEE INFLOW
destring locality_iid, replace
merge m:1 locality_iid using "$data_Fallah_final/SS_IV_RefInflow.dta"

tabu _merge
drop if _merge==2


replace pct_hh_syr_eg_2004 = 0 if _merge == 1
drop _merge

tab pct_hh_syr_eg_2004, m
*/
/*
*Those are the districts in which we surveyed refugees
*the other ones, we had no refugees
keep if  district_iid == 1 | ///
                          district_iid == 4  | ///
                          district_iid == 6 | ///
                          district_iid == 7 | ///
                          district_iid == 8 | ///
                          district_iid == 9 | ///
                          district_iid == 11 | ///
                          district_iid == 15 | ///
                          district_iid == 18 | ///
                          district_iid == 19 | ///
                          district_iid == 22 | ///
                          district_iid == 23 | ///
                          district_iid == 24 | ///
                          district_iid == 25 | ///
                          district_iid == 28 | ///
                          district_iid == 29 | ///
                          district_iid == 30 | ///
                          district_iid == 31 | ///
                          district_iid == 32 | ///
                          district_iid == 33 | ///
                          district_iid == 35 | ///
                          district_iid == 36 | ///
                          district_iid == 37 | ///
                          district_iid == 38 | ///
                          district_iid == 39 | ///
                          district_iid == 43 | ///
                          district_iid == 44 | ///
                          district_iid == 45 | ///
                          district_iid == 46 | ///
                          district_iid == 50 | ///
                          district_iid == 51 
*/
tab work_permit, m //more accurate version 
tab work_permit_orig, m

tab nationality q11203
tab q11203
tab nationality_cl
tab year 
*drop if flag_dist_ref != 1 

*save "$data_final/05_IV_JLMPS_Analysis.dta", replace
*save "$data_final/05_IV_JLMPS_MergingIV.dta", replace



*use "$data_final/05_IV_JLMPS_MergingIV.dta", clear

*AGGREGATED NUMBER OF WORK PERMIT

preserve
codebook  nationality_cl
*drop if forced_migr != 1
drop if nationality_cl != 2
gen sample_pop = 1 
collapse (sum) sample_pop if year == 2016, by(district_iid)
bys district_iid: tab sample_pop
keep sample_pop district_iid
tempfile popdist
save `popdist'
restore 


preserve
codebook  nationality_cl
*drop if forced_migr != 1
drop if nationality_cl != 2
*tab forced_migr
*codebook forced_migr
*drop if forced_migr != 1
distinct district_iid
tab work_permit, m
collapse (sum) work_permit if year == 2016, by(district_iid)
distinct district_iid //only 26 districts have WP
ren work_permit agg_wp_2016
gen year = 2016
tempfile wp2016
save `wp2016'
restore

merge m:1 district_iid using `wp2016'
drop _merge

gen agg_wp = agg_wp_2016
replace agg_wp = 0 if year == 2010 //No WP in 2010
replace agg_wp = 0 if mi(agg_wp) //No WP in District
tab district_iid 


gen agg_wp_bi = 1 if agg_wp != 0
replace agg_wp_bi = 0 if agg_wp == 0
bys year: tab district_iid agg_wp_bi 
drop agg_wp_bi

*tab district_iid if nationality_cl == 2 
*gen migr_in_district = 0 if mi(nationality_cl == 2) 
*tab district_iid migr_in_district,m 
*A few districts do not have indiv with WP: should I remove them?
*drop if mi(agg_wp)
lab var agg_wp "From work_permit: aggregated at the district level"
tab agg_wp, m
tab agg_wp year, m
*br agg_wp year IV_SS 
*sort year 

merge m:1 district_iid using `popdist'
drop _merge

gen share_wp = agg_wp / sample_pop  
tab share_wp , m 
tab sample_pop
lab var share_wp "From work_permit: share of refugees with work permit at the district level"
replace share_wp = 0 if year == 2010 //No WP in 2010
replace share_wp = 0 if mi(share_wp) //No WP in District
gen share_wp_100 = 100*share_wp
lab var share_wp_100 "PERCENTAGE - From work_permit: share of refugees with work permit at the district level"




/*
*Missing district IN 2010: nb 25 - Husaynia 

*AGGREGATED NUMBER OF WORK PERMIT
preserve
tab forced_migr
codebook forced_migr
drop if forced_migr != 1
distinct district_iid
tab work_permit, m
collapse (sum) work_permit if year == 2016, by(district_iid)
ren work_permit agg_wp_2016
gen year = 2016
tempfile wp2016
save `wp2016'
restore

merge m:1 district_iid using `wp2016'
drop _merge

gen agg_wp = agg_wp_2016
replace agg_wp = 0 if year == 2010 //No WP in 2016
replace agg_wp = 0 if mi(agg_wp) //No WP in District
*A few districts do not have indiv with WP: should I remove them?
*drop if mi(agg_wp)
lab var agg_wp "From work_permit: aggregated at the district level"
tab agg_wp, m
tab agg_wp year, m
*br agg_wp year IV_SS 
*sort year 
*/


* ORIGINAL *

/*Original means that it is the standard variable asked in the questionnaire
     RECODE of q11207 (q11207. Do you have a permit to work in Jordan?)

NON ORIGINAL means that it is the variable original plus a small transfo
from me: added the refugee who said they had a legal contract 
while also declaring having no work permit (or missing in the WP Q)
I am using this one in the analysis 
work_permit_orig + 1 to refugees who said they have no WP but a legal contract

*/

*AGGREGATED NUMBER OF WORK PERMIT
preserve
tab forced_migr
codebook forced_migr
*drop if forced_migr != 1
drop if nationality_cl != 2
distinct district_iid
tab work_permit_orig, m
collapse (sum) work_permit_orig if year == 2016, by(district_iid)
ren work_permit_orig agg_wp_orig_2016
gen year = 2016
tempfile wp_orig_2016
save `wp_orig_2016'
restore

merge m:1 district_iid using `wp_orig_2016'
drop _merge

gen agg_wp_orig = agg_wp_orig_2016
replace agg_wp_orig = 0 if year == 2010 //No WP in 2016
replace agg_wp_orig = 0 if mi(agg_wp_orig) //No WP in District
*A few districts do not have indiv with WP: should I remove them?
*drop if mi(agg_wp)
tab agg_wp_orig, m
lab var agg_wp_orig "From work_permit_orig: aggregated at the district level"
tab agg_wp_orig year, m
*br agg_wp year IV_SS 
*sort year 


*LOG AND IHS TRANSOFRMATION
gen ln_agg_wp_orig = ln(1+agg_wp_orig)
gen IHS_agg_wp_orig = log(agg_wp_orig + ((agg_wp_orig^2 + 1)^0.5))

gen ln_agg_wp = ln(1+agg_wp)
gen IHS_agg_wp = log(agg_wp + ((agg_wp^2 + 1)^0.5))


bys year: distinct district_iid
bys year: tab district_iid
bys year: tab district_en

***********************************************************************
**PREPARING THE SAMPLE ************************************************
***********************************************************************

**********************************
* PEOPLE SURVEYED IN BOTH ROUNDS *
**********************************

*br indid indid_2010 indid_2016 year
*SAMPLE: SAME INDIVIDUALS WERE SURVEYED IN 2010 AND 2016
*BUT A FEW WERE NOT (ALL REFUGEE WEREN'T SURVEYED IN 2010)
*AND A FEW JORDANIANS. I DECDIE TO KEEP ONLY THE PANEL STRUCTURE 
*FOR FIXED EFFECT AT THE INDIV LEVEL 
gen surveyed_2_rounds = 1 if in_2010 == 1 & in_2016 == 1 
keep if surveyed_2_rounds == 1 

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
drop if dup == 0
bys year: tab dup
drop surveyed_2_rounds dup

*28020 indiv surveyed twice in 2010 and 2020
mdesc indid_2010
destring indid_2010, replace 
format indid_2010 %12.0g


**************
* JORDANIANS *
**************

preserve 
codebook nationality_cl
lab list Lnationality_cl
/*
                        53,094         1  Jordanian
                         3,003         2  Syrian
                           623         3  Egyptian
                         2,551         4  Other Arab
                           132         5  Other

*/

*keep if nationality_cl == 1 //Keep only the jordanians
*keep if nationality_cl != 2 //Keep all but the syrians
tab nationality_cl year

keep nationality_cl indid_2010 year
reshape wide nationality_cl, i(indid_2010) j(year)

*Correction #1
gen flag = 1 if nationality_cl2010 != nationality_cl2016 
list nationality_cl2016 nationality_cl2010 if flag == 1 
*If Declare JORDANIAN in 2016 but different in 2010
*then JORDANIAN
replace nationality_cl2010 = nationality_cl2016 if flag == 1 & nationality_cl2016 == 1
drop flag 

*Correction #2
gen flag = 1 if nationality_cl2010 != nationality_cl2016 
list nationality_cl2016 nationality_cl2010 if flag == 1 
*If Declare JORDANIAN in 2010 but different in 2016
*then JORDANIAN
replace nationality_cl2016 = nationality_cl2010 if flag == 1 & nationality_cl2010 == 1
drop flag 

*Corection #3
gen flag = 1 if nationality_cl2010 != nationality_cl2016 
list nationality_cl2016 nationality_cl2010 if flag == 1 
*IF Declare OTHER ARAB in 2010 but differnt in 2016
replace nationality_cl2010 = nationality_cl2016 if flag == 1 & nationality_cl2016 == 4
drop flag 

*Corection #4
gen flag = 1 if nationality_cl2010 != nationality_cl2016 
list nationality_cl2016 nationality_cl2010 if flag == 1 
*IF Declare OTHER ARAB in 2016 but differnt in 2010
replace nationality_cl2016 = nationality_cl2010 if flag == 1 & nationality_cl2010 == 4
drop flag 

*br nationality_cl2016 nationality_cl2010 
/*
1  Jordanian
2  Syrian
3  Egyptian
4  Other Arab
5  Other
*/

reshape long nationality_cl, i(indid_2010) j(year)
format indid_2010 %12.0g

tempfile data_nat
save `data_nat'
restore 

drop nationality_cl 
merge 1:1 indid_2010 year using  `data_nat'
drop _merge 



***************
* LOCALITY *
*************** 

drop locality_iid

preserve 
*codebook locality

*keep if nationality_cl == 1 //Keep only the jordanians
*keep if nationality_cl != 2 //Keep all but the syrians
tab locality_id year, m 

keep locality_id indid_2010 year
reshape wide locality_id, i(indid_2010) j(year)

replace locality_id2010 = locality_id2016 if mi(locality_id2010)
tab locality_id2010
tab locality_id2016

reshape long locality_id, i(indid_2010) j(year)
format indid_2010 %12.0g

tempfile data_nat
save `data_nat'
restore 

*ORIGINAL CODE ORIGINAL CODE 
*drop locality 
*NEW CODE NEW CODE 
drop locality_id 
*END LOCALITY LOCALITY 

merge 1:1 indid_2010 year using  `data_nat'
drop _merge 

tab locality_id, m 

*ORIGINAL CODE ORIGINAL CODE 
*egen locality_iid = concat(district_iid locality)

*NEW CODE NEW CODE 
egen locality_iid = group(district_iid locality_id)
*END NEW CODE END NEW CODE 

tab locality_iid, m 
tab  locality_iid year
distinct locality_iid
bys district_iid: tab locality_iid








************
* DISTRICT *
************ 

*drop district_iid

preserve 
*codebook locality

*keep if nationality_cl == 1 //Keep only the jordanians
*keep if nationality_cl != 2 //Keep all but the syrians
tab district_iid year, m 

keep district_iid indid_2010 year
reshape wide district_iid, i(indid_2010) j(year)

gen district_move_10_16 = 0
replace district_move_10_16 = 1 if district_iid2010 != district_iid2016 


tab district_move_10_16
*sort district_move_10_16

reshape long district_iid, i(indid_2010) j(year)
format indid_2010 %12.0g

tempfile data_distr
save `data_distr'
restore 

*ORIGINAL CODE ORIGINAL CODE 
drop district_iid 

merge 1:1 indid_2010 year using  `data_distr'
drop _merge 

tab district_iid, m 


lab def district_move_10_16 1 "Moved" 0 "Stayed", modify
lab val district_move_10_16 district_move_10_16

tab district_move_10_16, m 




***************
* WORKING AGE *
*************** 

preserve 

keep age indid_2010 year
reshape wide age, i(indid_2010) j(year)
format indid_2010 %12.0g

*br indid_2010 age2016 age2010

sort indid_2010
mdesc age2016 

*There are a lot of discrepencies.
gen age_diff = age2016 - age2010

gen flag = age_diff if age_diff > 6 | age_diff < 0

sort flag
list indid_2010 age2010 age2016 age_diff if !mi(flag) & flag >= 40
list indid_2010 age2010 age2016 age_diff if !mi(flag) & flag > 7 & (age2010 == 58) 
list indid_2010 age2010 age2016 age_diff if !mi(flag) & flag > 7 & (age2016 == 64) 
list indid_2010 age2010 age2016 age_diff if !mi(flag) & flag > 7 & (age2010 == 10) 
list indid_2010 age2010 age2016 age_diff if !mi(flag) & flag > 7 & (age2016 == 22) 
list indid_2010 age2010 age2016 age_diff if !mi(flag) & flag < 0 

gen check = 1 if !mi(flag) & flag >= 20
replace check = 1 if !mi(flag) & flag > 7 & (age2010 == 58)
replace check = 1 if !mi(flag) & flag > 7 & (age2016 == 64)
replace check = 1 if !mi(flag) & flag > 7 & (age2010 == 10) 
replace check = 1 if !mi(flag) & flag > 7 & (age2016 == 22)
replace check = 1 if !mi(flag) & flag < 0
replace check = 1 if !mi(flag) & age_diff== 0

list indid_2010 age2010 age2016 age_diff if check == 1 

sort age_diff
list indid_2010 age2010 age2016 age_diff if check != 1 
*list indid_2010 age2010 age2016 age_diff if  age2010<64 & age2010>16 & age2016>16 & age2016<64

tempfile age_flag 
save `age_flag'

*drop age2016 age_diff
drop age_diff check flag

*I decide to recreate the age 2016 so that 
*it matches what was declared in 2010
*gen age2016 = age2010 + 6 
*tab age2016, m
*lab var age2016 "Age 2016"

list if age2010 == 0 
list if age2016 == 0 

tab age2016, m
tab age2010, m

reshape long age, i(indid_2010) j(year)
format indid_2010 %12.0g

tempfile data_age
save `data_age'
restore 

drop age 
merge 1:1 indid_2010 year using  `data_age'
drop _merge

merge m:1 indid_2010 using  `age_flag', keepusing(age_diff check)
drop _merge


*keep indid_2010 age age_diff check 
sort indid_2010
format indid_2010 %12.0g
*keep if check == 1 

tab brthyr
list indid_2010 age brthyr age_diff if check == 1 

mdesc brthyr
gen age2016 = 2016 - brthyr if year == 2016
gen age2010 = 2010 - brthyr if year == 2010

list indid_2010 brthyr age2016 age2010 age age_diff check yrschl  if check == 1
replace age = age2016 if check == 1 & year == 2016 
replace age = age2010 if check == 1 & year == 2010

drop check age2016 age2010 


/*---------*********************************************************************-----------
-----------*********************************************************************-----------
                                   VARIABLES CLEANING 
-----------*********************************************************************-----------
-----------*********************************************************************-----------*/


                                       **********
                                       *Controls*
                                       **********

*********************
** NUMBER REFUGEES **
*********************

tab NbRefbyGovoutcamp, m
ren NbRefbyGovoutcamp nb_refugees_bygov
replace nb_refugees_bygov = 0 if year == 2010
lab var nb_refugees_bygov "[CTRL] Number of refugees out of camps by governorate in 2016"
tab nb_refugees_bygov

gen ln_nb_refugees_bygov = ln(1 + nb_refugees_bygov) 
*if year == 2016
*replace ln_nb_refugees_bygov = 0 if year == 2010

lab var ln_nb_refugees_bygov "[CTRL] LOG Number of refugees out of camps by governorate in 2016"
lab var ln_nb_refugees_bygov "Number of refugees (ln)"
*ln_ref, as of now, does not include refugees in 2010, only in 2016

****** Other
gen IHS_nb_refugees_bygov = log(nb_refugees_bygov + ((nb_refugees_bygov^2 + 1)^0.5))
lab var IHS_nb_refugees_bygov "IHS - Number of refugees out of camps by governorate in 2016"


**************
* IV NETWORK *
**************
/*
egen tot_nbr_ref = sum(nb_refugees_bygov)
tab tot_nbr_ref, m 
tab pct_hh_syr_eg_2004, m 
gen IV_network = tot_nbr_ref * pct_hh_syr_eg_2004
tab IV_network, m 

corr IV_network nb_refugees_bygov
*/
*********
** AGE **
*********

/*respondents' age and age squared. */
su age
lab var age "Age"

gen age2 = age^2
lab var age2 "Age Square"

*******************
** DISTANCE CAMP **
*******************

*Distance between zaatari camp and districts jordan
gen dist_zaatari_lat = 32.30888675674741
gen dist_zaatari_long = 36.31329385051756
geodist district_lat district_long dist_zaatari_lat dist_zaatari_long, gen(distance_dis_camp)
tab distance_dis_camp, m
lab var distance_dis_camp "[CTRL] Distance (km) between JORD districts and ZAATARI CAMP in 2016"
replace distance_dis_camp = 0 if year == 2010

gen inv_dist_camp = 1/distance_dis_camp
replace inv_dist_camp = 0 if year == 2010
gen ln_invdistance_dis_camp = log(1 + inv_dist_camp) 

*gen ln_distance_dis_camp = log(1 + distance_dis_camp) 
*if year == 2016
*replace ln_distance_dis_camp = 0 if year == 2010
lab var ln_invdistance_dis_camp "[CTRL] LOG Inverse Distance (km) between JORD districts and ZAATARI CAMP in 2016"

tab nb_refugees_bygov
gen tot_nb_ref_2016 = 513032 if year == 2016
lab var tot_nb_ref_2016 "Number of Syrian refugee in Jordan in 2016"

*THE INSTRUMENT 
gen IV_SS_ref_inflow = tot_nb_ref_2016*inv_dist_camp
replace IV_SS_ref_inflow = 0 if mi(IV_SS_ref_inflow)
lab var IV_SS_ref_inflow "SSIV for refugee inflow: tot_nb_ref_2016 x inv_dist_camp"

*THE INSTRUMENT 
tab IV_SS_ref_inflow, m 
bys district_iid: tab IV_SS_ref_inflow

distinct IV_SS_ref_inflow

*THE INSTRUMENT + TRANSFORMATION
gen ln_IV_SS_ref_inflow = log(1 + IV_SS_ref_inflow)
lab var ln_IV_SS_ref_inflow "LOG - SSIV for refugee inflow: tot_nb_ref_2016 x inv_dist_camp"
replace ln_IV_SS_ref_inflow = 0 if year == 2010

gen IHS_IV_SS_ref_inflow = log(IV_SS_ref_inflow + ((IV_SS_ref_inflow^2 + 1)^0.5))
lab var IHS_IV_SS_ref_inflow "IHS - SSIV for refugee inflow: tot_nb_ref_2016 x inv_dist_camp"
replace IHS_IV_SS_ref_inflow = 0 if year == 2010

************
** GENDER **
************

tab sex , m 
codebook sex
gen gender = 0 if sex == 2 //Female
replace gender = 1 if sex == 1 //Male
lab def gender 0 "Female" 1 "Male", modify 
lab val gender gender 
lab var gender "Gender 1 Male 0 Female"

********************
** HOUSEHOLD SIZE **
********************

tab hhsize
codebook hhsize 
lab var hhsize "Total No. of Individuals in the Household"

***************
** EDUCATION **
***************
*Education

*-Own
/*
Seven levels of education are controlled for: (1) illiterate (reference) (2) read & write 
(3) basic (ten years) (4) secondary (two additional years) (5) post-secondary (two additional 
years beyond secondary) (6) university (four additional years beyond secondary) and
(7) post-graduate. 
*/
tab educ1d, m
codebook educ1d
lab var educ1d "Education Levels (1-digit)" 

/*These same education categories are included for mother's and father's education, 
although we aggregate post-graduate studies with university for parents. */

*-Father
tab fteducst, m
codebook fteducst
lab list Leduc1d
replace fteducst = 6 if fteducst == 7
lab def Leduc1d_agg     ///
           1 "Illiterate" ///
           2 "Read and Write" ///
           3 "Basic Education" ///
           4 "Secondary Educ" ///
           5 "Post-Secondary" ///
           6 "University and more", ///
           modify
lab val fteducst Leduc1d_agg
lab var fteducst "Father's Level of education attained" 

*-Mother
tab mteducst, m
replace mteducst = 6 if mteducst == 7
lab val mteducst Leduc1d_agg
lab var mteducst "Mother's Level of education attained" 

/*
father's employment status when the respondent was aged 15 as: (1) waged employee 
(2) employer (3) self-employed (4) unpaid worker (5) non-employed or (6) don't know. 
*/
tab ftempst, m 
lab var ftempst "Father's Employment Status (When Resp. 15)" 


/*
In some specifications we also control for geographic or individual fixed effects (in which
case some invariant controls drop out of the models).
*/



                                          **********
                                          *Outcomes*
                                          **********

                                 *******************************
                                 ****    EMPLOYEMENT        ****
                                 *******************************

/* DEF - Above 15 and below 65 , employed according to EXTENDED def where search is not 
required in a period of 3 months (use uswrkst2) */ 

codebook uswrkst1 uswrkst2
   *Work status during ref. 3-month, market def. (search is not required)
   tab uswrkst1, m  
   *Work status during ref. 3-month, extend def. (search is not required)
   tab uswrkst2, m 

codebook crwrkstsr1 crwrkstsr2  
   *Work status during ref. week, market def. (search required)
   tab crwrkstsr1, m 
   *Work status during ref. week, extend. def. (search required)
   tab crwrkstsr2, m 

codebook uswrkstsr1 uswrkstsr2
   *Work status during ref. 3-month, market def. (search required)
   tab uswrkstsr1, m 
   *Work status during ref. 3-month, extend def. (search required)
   tab uswrkstsr2, m 

codebook crempstp usempstp scempst
   *Employment status in prim job (ref. 1-week)
   tab crempstp, m  
   *Employment status in prim job (ref. 3 months)
   tab usempstp, m  
   *Employment status in secondary job (ref 3-month)
   tab scempst, m  

*RETROSPECTIVE JOBS
/*codebook    yrjob1 job1_m job1_y job1_01 job1_02 job1_03 job1_04 job1_05 job1_06 ///
            job1_07 job1_08 job1_09 job1_10m job1_10y job1_11 job1_12 job1_13 ///
            job1_14m job1_14y job1_15 job1_16dis job1_16g job1_16o_nh job1_17
*/
/*
Work is defined in terms of market work in the past three months;
 those who do subsistence work only are considered not working.

Self-employed 
Unpaid family worker 
*/

*Predefine variable . obsolete
ren employed employed_2016 


tab uswrkstsr1, m 
codebook uswrkstsr1
/* 1  Employed
 2  Unemployed
 3  Out of Labor Force*/

tab usempstp, m 
codebook usempstp
/*  1  Waged employee
  2  Employer
  3  Self-employed
  4  Unpaid family worker*/

  *EMPLOYED IS uswrkstsr1 == 1 & (usempstp != 3 | usempstp != 4)
  *UNEMPLOYED IS uswrkstsr1 == 2 | (usempstp == 3 | usempstp == 4)

*** OLF AS A CATEGORY ***
gen employed_3cat_3m = 2 if uswrkstsr1 == 1 & (usempstp != 3 | usempstp != 4) //EMPLOYED BUT NO SUBS WORK
replace employed_3cat_3m = 1 if uswrkstsr1 == 2 // UNEMP
replace employed_3cat_3m = 1 if uswrkstsr1 == 1 & (usempstp == 3 | usempstp == 4) //EMPLOYED IN SUBS WORK
replace employed_3cat_3m = 0 if uswrkstsr1 == 3 //OLF 
tab employed_3cat_3m, m 
lab def employed_3cat_3m 2 "Employed (no subs)" 1 "Unemployed (&subs)" 0 "Out of the labor force", modify 
lab val employed_3cat_3m employed_3cat_3m
lab var employed_3cat_3m "From uswrkstsr1 - mkt def, search req; 3m, 2 empl - 1 unemp - 0 OLF"

*** OLF AS MISSING ***
gen employed_3m = 2 if uswrkstsr1 == 1 & (usempstp != 4) //EMPLOYED BUT NO SUBS WORK
replace employed_3m = 2 if uswrkstsr1 == 1 & usempstp == 3 //SE EMPLOYED
replace employed_3m = 1 if uswrkstsr1 == 2 // UNEMP
replace employed_3m = 1 if uswrkstsr1 == 1 & (usempstp == 4) //EMPLOYED IN SUBS WORK
replace employed_3m = . if uswrkstsr1 == 3 //OLF MISS
tab employed_3m, m 
tab employed_3m usempstp
tab uswrkstsr1 usempstp
codebook uswrkstsr1
codebook usempstp
lab def employed_3m 2 "Employed (no subs)" 1 "Unemployed (&subs)", modify 
lab val employed_3m employed_3m
lab var employed_3m "From uswrkstsr1 - mkt def, search req; 3m, 2 empl (wage, se, employer) - 1 unemp - OLF miss"

*** OLF AS UNEMPLOYED ***
gen employed_olf_3m = 2 if uswrkstsr1 == 1 & (usempstp != 4) //EMPLOYED BUT NO SUBS WORK
replace employed_olf_3m = 2 if uswrkstsr1 == 1 & usempstp == 3 //SE EMPLOYED
replace employed_olf_3m = 1 if uswrkstsr1 == 2 // UNEMP
replace employed_olf_3m = 1 if uswrkstsr1 == 1 & (usempstp == 4) //EMPLOYED IN SUBS WORK
replace employed_olf_3m = 1 if uswrkstsr1 == 3 //OLF MISS
tab employed_olf_3m, m 
lab def employed_olf_3m 2 "Employed (no subs)" 1 "Unemployed or OLF (&subs)", modify 
lab val employed_olf_3m employed_olf_3m
lab var employed_olf_3m "From uswrkstsr1 - mkt def, search req; 3m, 2 empl - 1 unemp&OLF"

*Job stability in prim. job (ref. 3-mnths)
tab usstablp, m 
codebook usstablp
gen job_stable_3m = 1 if usstablp == 1 
replace job_stable_3m = 0 if usstablp != 1 & !mi(usstablp)
lab var job_stable_3m "From usstablp - Stability of employement (3m) - 1 permanent - 0 temp, seas, cas"
tab job_stable_3m, m

            *Unconditional : IF UNEMPLOYED & OLF: IS 0
            gen job_stable_3m_unolf = job_stable_3m if employed_3cat_3m == 2
            replace job_stable_3m_unolf = 0 if employed_3cat_3m  == 1 | employed_3cat_3m  == 0 
            tab job_stable_3m_unolf
            lab var job_stable_3m_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: 0 - job_stable_3m"

*LABOR FORCE PARTICIPATION
*The labor force participation rate indicates the percentage of all people of working age who 
*are employed or are actively seeking work

*CPIin17
*crirreg

*EMPLOYEMENT with out of the labor force included 
*(cr = current)

*Employed with mrket definition (ref 1-week)
tab cremp1, m 
*Employed with extend. def. (ref. 1-week)
tab cremp2, m 
*Employed with mrkt. def. (ref. 3-mnths)
tab usemp1, m 
*Employed with ext. definition (ref. 3-mnths)
tab usemp2, m 
*employment status in prim job (ref. 1-week)
tab crempstp, m 

*Economic sector of prim. job (ref. 1-week)
tab crsectrp, m 
*Occup. of crr. jb (4-digit based on ISCO 2008, ref. 1-week)
tab croccupp, m 
*1 digit
tab crocp1d, m 
*2 digit
tab crocp2d, m 
*3 digit
tab crocp3d, m 
*Economic Activity of prim. job (4-digit based on ISIC4, ref. 1-week)
tab crecactp, m 
*1 digit
tab crecac1d, m 
*2 digit
tab crecac2d, m 
*3 digit
tab crecac3d, m 

                                 *******************************
                                 ****      SECTORS WP       ****
                                 *******************************

*WORK PERMIT AUTHORIZED SECORS:  construction [5], care work [16], 
*agriculture [0], manufacturing [2], and food industry [8]
*Economic activity of crr. job (Sections(1digit), based on ISIC4, ref. 1-week)
tab crecac1d, m

*Economic activity of prim. job (Sections(1digit), based on ISIC4, ref. 3-mnths)
tab usecac1d, m 
codebook usecac1d
lab list ecac1d
gen wp_industry_jlmps_3m = 0 if !mi(usecac1d)
replace wp_industry_jlmps_3m = 1 if   usecac1d == 0 | /// Agriculture, forestry and fishing
                                      usecac1d == 2 | /// Manufacturing
                                      usecac1d == 5 | /// Construction
                                      usecac1d == 6 | /// Wholesale and retail trade; repair of motor vehicles and motorcycles
                                      usecac1d == 8 | /// Accomodation and food service activities
                                      usecac1d == 13 | /// Administrative and support service activities
                                      usecac1d == 14 | /// Public administration and defense; compulsory social security
                                      usecac1d == 18 // Other service activities 
/*       ORIGINAL                               
replace wp_industry_jlmps_3m = 1 if   usecac1d == 0 | /// 
                                      usecac1d == 2 | ///
                                      usecac1d == 5 | ///
                                      usecac1d == 8 | ///
                                      usecac1d == 16 
                                      */
tab wp_industry_jlmps_3m, m 
lab var wp_industry_jlmps_3m "Industries with work permits for refugees - Economic Activity of prim. job 3m"
lab def wp_industry_jlmps_3m 0 "Close sector" 1 "Open Sector", modify
lab val wp_industry_jlmps_3m wp_industry_jlmps_3m

*Where are the OLF/UNEMPL ?
tab wp_industry_jlmps_3m uswrkstsr2, m









preserve 

keep wp_industry_jlmps_3m indid_2010 year 
reshape wide wp_industry_jlmps_3m, i(indid_2010) j(year)
format indid_2010 %12.0g

*br indid_2010 employed_3m2016 employed_3m2010

*MISS 2016 - MISS 2010
gen open_10_16 = 1 if  wp_industry_jlmps_3m2010 == 1  & wp_industry_jlmps_3m2016 == 1
gen close_10_16 = 1 if wp_industry_jlmps_3m2010 == 0 & wp_industry_jlmps_3m2016 == 0
gen open_10_close_16 = 1 if  wp_industry_jlmps_3m2010 == 1  & wp_industry_jlmps_3m2016 == 0
gen close_10_open_16 = 1 if wp_industry_jlmps_3m2010 == 0 & wp_industry_jlmps_3m2016 == 1

tab open_10_16, m
tab close_10_16, m
tab open_10_close_16, m
tab close_10_open_16, m

reshape long wp_industry_jlmps_3m, i(indid_2010) j(year)
format indid_2010 %12.0g

tempfile data_empl
save `data_empl'
restore 

drop wp_industry_jlmps_3m 
merge 1:1 indid_2010 year using  `data_empl'
drop _merge



*Institutional Sector Crr. Job (ref 1-week)
tab crinstsec, m 
*Institutional Sector Crr. Job (ref 3-months)
tab usinstsec, m
*employment status in prim job (ref. 3 months)
tab usempstp, m 
gen lf_participation = usempstp

*Economic sector of prim. job (ref. 3-mnths)
tab ussectrp, m 

codebook ussectrp
gen private = 0 if ussectrp == 1 | ///Government
                     ussectrp == 2 //Public
replace private = 1 if   ussectrp == 3 | ///Private
                           ussectrp == 5 //International
tab job1_05 if ussectrp == 4
replace private = 0 if ussectrp == 4 & job1_05 == 1 //Other => Gov
replace private = 1 if ussectrp == 4 & job1_05 == 3 //Other => Private
lab def private 0 "Public" 1 "Private", modify
lab val private private
lab var private "Economic Sector of Primary Job 3m - 0 Public 1 Private"






preserve 

keep private indid_2010 year 
reshape wide private, i(indid_2010) j(year)
format indid_2010 %12.0g

*br indid_2010 employed_3m2016 employed_3m2010

*MISS 2016 - MISS 2010
gen private_10_16 = 1 if  private2010 == 1  & private2016 == 1
gen public_10_16 = 1 if private2010 == 0 & private2016 == 0
gen private_10_public_16 = 1 if private2010 == 1  & private2016 == 0
gen public_10_private_16 = 1 if private2010 == 0 & private2016 == 1

tab private_10_16, m
tab private_10_16, m
tab private_10_public_16, m
tab public_10_private_16, m

reshape long private, i(indid_2010) j(year)
format indid_2010 %12.0g

tempfile data_private
save `data_private'
restore 

drop private 
merge 1:1 indid_2010 year using  `data_private'
drop _merge





tab usecac2d if ussectrp == 4
codebook usecac2d



*Wrk in establish. in primary job (ref. 3-mnths)
tab usestblp, m 

*Occup. of prim. jb (4-digit based on ISCO 2008,ref. 3-mnths)
tab usoccupp, m 
*Occup. of prim. job (1-digit based on ISCO 2008, ref. 3-mnths)
tab usocp1d, m 
*Occup. of prim. job (2-digit based on ISCO 2008, ref. 3-mnths)
tab usocp2d, m 
*Occup. of prim. jb (3-digit based on ISCO 2008,ref. 3-mnths)
tab usocp3d, m 
*Economic activity of prim. job (4-digit, based on ISIC4, ref. 3-mnths)
tab usecactp, m 
*Economic activity of prim. job (Sections(1digit), based on ISIC4, ref. 3-mnths)
tab usecac1d, m 
*Economic activity of prim. job (2-digit, based on ISIC4, ref. 3-mnths)
tab usecac2d, m 
*Economic activity of prim. job (3-digit, based on ISIC4, ref. 3-mnths)
tab usecac3d, m 

*Institutional Sector Prim. Job (ref 3-month)
tab usinstsec, m 


*br usocp1d usocp2d usecac1d usecac2d


*tab usoccupp usocp1d usocp2d usocp3d 
*tab usecactp usecac1d usecac2d usecac3d

***********************************************************************
**PREPARING THE SAMPLE ************************************************
***********************************************************************

***************
* EMPLOYED *
*************** 

/*
Number of outcomes among the employed,

[NB: We undertook sensitivity analysis as to whether analyzing these outcomes
unconditional on employment, rather than among the employed, changed our
results; it did not lead to substantive changes (results available from authors on
request).]*/

*save "$data_temp/temp_dataset.dta", replace 
*use  "$data_temp/temp_dataset.dta", clear 

codebook employed_3cat_3m
/*
14,270         0  Out of the labor force
1,645         1  Unemployed (&subs)
4,809         2  Employed (no subs)
2,942         .  
*/


                                 *******************************
                                 ****       INFORMAL        ****
                                 *******************************

/* whether individuals have formal work (with a contract or social
insurance) or informal work (neither a contract nor social insurance).
*/

*Informal if NO WORK CONTRACT and NO INSURANCE

* Incidence of wrk social insurance in prim. job (ref. 3-month)
tab ussocinsp
/*
Yes = 1 : has a social insurance
No = 0
*/

*  Incidence of wrk contract in prim. job (ref. 3-month) 
tab uscontrp
/*
Yes = 1 : has a contract
No = 0
*/

gen formal = 1 if ussocinsp == 1 | uscontrp == 1
replace formal = 0 if uscontrp == 0 | uscontrp == 0 & !mi(formal)
tab formal
lab var formal "1 Formal - 0 Informal - Formal if contract (uscontrp=0) OR insurance (ussocinsp=0)"
tab formal usemp1
lab def formal 1 "Formal" 0 "Informal", modify
lab val formal formal
tab formal


/*
gen informal = 1 if ussocinsp == 0 
replace informal = 1 if uscontrp == 0 
replace informal = 0 if ussocinsp == 1
replace informal = 0 if uscontrp == 1
tab informal, m
lab var informal "1 Informal - 0 Formal - Informal if no contract (uscontrp=0) and no insurance (ussocinsp=0)"
tab informal usemp1

lab def informal 1 "Informal" 0 "Formal", modify
lab val informal informal
tab informal, m 
*/
/*
bys year: tab informal , nol
recode informal (1=0) (0=1), gen(bi_formal)
lab def bi_formal 1 "Formal" 0 "Informal", modify
lab val bi_formal bi_formal
lab var bi_formal "Formal Employment - 1 Formal 0 Informal"
bys year: tab bi_formal , nol
*/
preserve 

keep employed_3cat_3m indid_2010 year job1_y dstcrj formal
reshape wide employed_3cat_3m job1_y dstcrj formal, i(indid_2010) j(year)
format indid_2010 %12.0g

replace employed_3cat_3m2010 = 2 if mi(employed_3cat_3m2010) & dstcrj2016 <2010
replace employed_3cat_3m2010 = 2 if mi(employed_3cat_3m2010) & job1_y2016 <2010



*br indid_2010 employed_3m2016 employed_3m2010

*MISS 2016 - MISS 2010
gen miss_16_10 = 1 if mi(employed_3cat_3m2016) & mi(employed_3cat_3m2010)

*UNEMP 2016 - UNEMP 2010
gen unemp_16_10 = 1 if employed_3cat_3m2016 == 1 & employed_3cat_3m2010 == 1 

*OLF 2016 - OLF 2010
gen olf_16_10 = 1 if  employed_3cat_3m2016 == 0 & employed_3cat_3m2010 == 0

*EMPL 2016 - EMPL 2010
gen emp_16_10 = 1 if  employed_3cat_3m2016 == 2 & employed_3cat_3m2010 == 2

*EMP 2016 - MISS 2010 
gen emp_16_miss_10 = 1 if employed_3cat_3m2016 == 2 & mi(employed_3cat_3m2010)  

*EMP 2010 - MISS 2016 
gen emp_10_miss_16 = 1 if employed_3cat_3m2010 == 2 & mi(employed_3cat_3m2016) 

*UNEMP 2016 - MISS 2010 
gen unemp_16_miss_10 = 1 if employed_3cat_3m2016 == 1 & mi(employed_3cat_3m2010)

*UNEMP 2010 - MISS 2016 
gen unemp_10_miss_16 = 1 if employed_3cat_3m2010 == 1 & mi(employed_3cat_3m2016) 

*OLF 2016 - MISS 2010 
gen olf_16_miss_10 = 1 if employed_3cat_3m2016 == 0 & mi(employed_3cat_3m2010) 

*OLF 2010 - MISS 2016
gen olf_10_miss_16 = 1 if employed_3cat_3m2010 == 0 & mi(employed_3cat_3m2016) 

*EMPL 2010 - OLF 2016
gen emp_10_olf_16 = 1 if employed_3cat_3m2010 == 2 & employed_3cat_3m2016 == 0

*EMPL 2016 - OLF 2010
gen emp_16_olf_10 = 1 if employed_3cat_3m2016 == 2 & employed_3cat_3m2010 == 0

*UNEMP 2010 - EMP 2016
gen unemp_10_emp_16 = 1 if employed_3cat_3m2010 == 1 & employed_3cat_3m2016 == 2

*UNEMP 2016 - EMP 2010
gen unemp_16_emp_10 = 1 if employed_3cat_3m2016 == 1 & employed_3cat_3m2010 == 2

*UNEMP 2016 - EMP 2010
gen olf_10_unemp_16 = 1 if employed_3cat_3m2010 == 0 & employed_3cat_3m2016 == 1

*UNEMP 2016 - EMP 2010
gen olf_16_unemp_10 = 1 if employed_3cat_3m2016 == 0 & employed_3cat_3m2010 == 1

codebook employed_3cat_3m2010
codebook formal2010
gen empl_form_10_info_16 = 1 if  formal2010 == 1 & ///
                                 formal2016 == 0
gen empl_form_16_info_10 = 1 if  formal2010 == 0 & ///
                                 formal2016 == 1
gen empl_form_10_16 = 1 if  formal2010 == 1 & ///
                            formal2016 == 1
gen empl_info_10_16 = 1 if  formal2010 == 0 & ///
                            formal2016 == 0
gen empl_form_10_unemp_16 = 1 if  formal2010 == 1 & ///
                                  employed_3cat_3m2010 == 1 
gen empl_info_10_unemp_16 = 1 if  formal2010 == 0 & ///
                                  employed_3cat_3m2010 == 1 

/*
gen flag = 1 if   mi(miss_16_10) & ///
                  mi(unemp_16_10) & ///
                  mi(olf_16_10) & ///
                  mi(emp_16_10) & ///
                  mi(emp_16_miss_10) & ///
                  mi(emp_10_miss_16) & ///
                  mi(unemp_16_miss_10) & ///
                  mi(unemp_10_miss_16) & ///
                  mi(olf_16_miss_10) & ///
                  mi(olf_10_miss_16) & ///
                  mi(emp_10_olf_16) & ///
                  mi(emp_16_olf_10) & ///
                  mi(unemp_10_emp_16) & ///
                  mi(unemp_16_emp_10) & ///
                  mi(olf_10_unemp_16) & ///
                  mi(olf_16_unemp_10)
br employed_3cat_3m2010 employed_3cat_3m2016 if flag == 1 
*/
sort indid_2010

tab employed_3cat_3m2010, m 
tab employed_3cat_3m2016, m 

/*
. tab employed_3cat_3m2010, m 

 2010 employed_3cat_3m |      Freq.     Percent        Cum.
-----------------------+-----------------------------------
Out of the labor force |      6,725       56.83       56.83
    Unemployed (&subs) |        645        5.45       62.28
    Employed (no subs) |      2,238       18.91       81.20
                     . |      2,225       18.80      100.00
-----------------------+-----------------------------------
                 Total |     11,833      100.00

. tab employed_3cat_3m2016, m 

 2016 employed_3cat_3m |      Freq.     Percent        Cum.
-----------------------+-----------------------------------
Out of the labor force |      7,545       63.76       63.76
    Unemployed (&subs) |      1,000        8.45       72.21
    Employed (no subs) |      2,571       21.73       93.94
                     . |        717        6.06      100.00
-----------------------+-----------------------------------
                 Total |     11,833      100.00
*/
tab miss_16_10, m  
tab unemp_16_10, m  
tab olf_16_10, m  
tab emp_16_miss_10, m  
tab emp_10_miss_16, m  
tab unemp_16_miss_10, m  
tab unemp_10_miss_16, m  
tab olf_16_miss_10, m  
tab olf_10_miss_16, m
tab emp_10_olf_16, m 
tab emp_16_olf_10, m 
tab unemp_10_emp_16, m 
tab unemp_16_emp_10, m 
tab olf_10_unemp_16, m 
tab olf_16_unemp_10, m 
tab empl_form_10_info_16, m
tab empl_form_16_info_10, m
tab empl_form_10_16, m
tab empl_info_10_16, m
tab empl_form_10_unemp_16, m
tab empl_info_10_unemp_16, m


reshape long employed_3cat_3m formal, i(indid_2010) j(year)
format indid_2010 %12.0g

tempfile data_empl
save `data_empl'
restore 

drop employed_3cat_3m formal
merge 1:1 indid_2010 year using  `data_empl'
drop _merge


                                 *******************************
                                 ****       INFORMAL        ****
                                 *******************************

/* whether individuals have formal work (with a contract or social
insurance) or informal work (neither a contract nor social insurance).
*/

*Informal if NO WORK CONTRACT and NO INSURANCE
/*

tab ussocinsp
tab uscontrp
gen informal = 1 if ussocinsp == 0 
replace informal = 1 if uscontrp == 0 
replace informal = 0 if ussocinsp == 1
replace informal = 0 if uscontrp == 1
tab informal, m
lab var informal "1 Informal - 0 Formal - Informal if no contract (uscontrp=0) and no insurance (ussocinsp=0)"
tab informal usemp1

lab def informal 1 "Informal" 0 "Formal", modify
lab val informal informal
tab informal, m 
*/ 
*Usual main job(ref. 3-month) is irregular
tab usirreg, m 
codebook  usirreg
gen job_regular_3m = 1 if usirreg == 0  
replace job_regular_3m = 0 if usirreg == 1
lab var job_regular_3m "From usirreg - Usual job (3m) is regular - 1 Yes - 0 No"

*Incidence of wrk social insurance in prim. job (ref. 3-month)
tab ussocinsp, m 
ren ussocinsp incidence_soc_insur_3m

*Incidence of wrk contract in prim. job (ref. 3-month)
tab uscontrp, m 
ren uscontrp incidence_wrk_contract_3m

*Formality of prim. job (ref. 3-month)
tab usformal, m 
ren usformal job_formal_3m
lab var job_formal_3m "Formality of prim. job (ref. 3-month) - 0 Informal - 1 Formal"

*Check the treatment of OLF
tab unempdurmth uswrkst2 , m


                              *******************************
                              ****    UNEMPLOYMENT       ****
                              *******************************

/*
border between unemployment and non-participation
we require individuals to have been actively searching for work during unemployment 
(within the past four weeks in the contemporaneous data sources, within the period of
non-employment for retrospective data)

search          byte    %9.0g      noyes      If individual is searching for a job
srchdurmth      float   %9.0g                 Search duration (in months)

*/

*UNEMP 
*‘strict’ or ‘narrow’ definition which includes only active
*job seekers

tab unemp2m, m //Unemp1m
tab employed_3m, m

tab unemp2m employed_3m, m
*br * if  unemp2m == 1 & employed_3m  == 1 //Currently unemployed but employed in the last 3 months
*br * if  unemp2m == . & employed_3m  == 1 //Currently out of the labor force but employed in the last 3 months

tab uswrkstsr1, m 
codebook uswrkstsr1
/* 1  Employed
 2  Unemployed
 3  Out of Labor Force*/

* Std. unemployed with mrk. def. (search required), with missing out of the labor 
tab unempsr1m, m 
gen unemployed_3cat_3m = 3 if unempsr1m == 1
replace unemployed_3cat_3m = 2 if unempsr1m == 0
replace unemployed_3cat_3m = 1 if uswrkstsr1 == 3
lab def unemployed_3cat_3m 3 "Unemployed" 2 "Employed" 1 "OLF", modify
lab val unemployed_3cat_3m unemployed_3cat_3m
lab var unemployed_3cat_3m "From unempsr1m - mrk def, search req; 3m, 3 empl 2 unemp 1 OLF"
tab unemployed_3cat_3m, m 

* Std. unemployed with mrk. def. (search required), with missing out of the labor 
tab unempsr1m, m 
gen unemployed_3m = 2 if unempsr1m == 1
replace unemployed_3m = 1 if unempsr1m == 0

lab def unemployed_3m 2 "Unemployed" 1 "Employed", modify
lab val unemployed_3m unemployed_3m
lab var unemployed_3m "From unempsr1m - mrk def, search req; 3m, empl or unemp, OLF is miss"
tab unemployed_3m, m 

*Std. unemployed with mrkt def. (search is required)
tab unempsr1, m
gen unemployed_olf_3m = 2 if unempsr1 == 1 & uswrkstsr1 == 2
replace unemployed_olf_3m = 2 if unempsr1 == 0 & uswrkstsr1 == 3
replace unemployed_olf_3m = 2 if unempsr1 == . & uswrkstsr1 == 3
replace unemployed_olf_3m = 1 if unempsr1 == 0 & uswrkstsr1 == 1
replace unemployed_olf_3m = 1 if unempsr1 == . & uswrkstsr1 == 1
replace unemployed_olf_3m = 1 if unempsr1 == 1 & uswrkstsr1 == 1

lab def unemployed_olf_3m 2 "Unemployed or OLF" 1 "Employed ", modify
lab val unemployed_olf_3m unemployed_olf_3m
lab var unemployed_olf_3m "From unempsr1 - mrk def, search req; 3m, empl or unemp&OLF"
tab unemployed_olf_3m, m 

*Current unemployment duration (in months)
tab unempdurmth, m 
*Broad unemployed with mrkt definition (search is not required)
tab unemp1, m 
*Broad unemployed with extend. def. (search is not required)
tab unemp2, m 
*Std. unemployed with mrkt def. (search is required)
tab unempsr1, m
* Std. unemployed with extend. def. (search is required)
tab unempsr2, m 
*Unemployed broad mrk def. (search is not required), with missing if out of labor force 
tab unemp1m, m 
*Unemployed broad ext. def. (search is not required), with missing if out of labor force 
tab unemp2m, m 
* Std. unemployed with mrk. def. (search required), with missing out of the labor 
tab unempsr1m, m 
* Std. unemployed with ext. def. (search required), with missing out of the labor 
tab unempsr2m, m 
*Unempl. worked before, missing if OLF or employed (mkt defn)
tab unwrkevr1, m 
*Unempl. worked before, missing if OLF or employed (ext. defn)
tab unwrkevr2, m 
*If individual is searching for a job
tab search, m 
*Search duration (in months)
tab srchdurmth, m 
*Reason for not searching for a job
tab rsnnosrch, m 
* Available and willing to work?
tab avail, m 
*Has individual ever worked?
tab evrwrk, m 
*Reason out of the labor force
tab rsnolf, m 
*Jobless, Market Definition (Among non-students)
tab jobless1, m 
*Jobless, Extended Definition (Among non-students)
tab jobless2, m 


                                 *******************************
                                 ****     DAYS OF WORK      ****
                                 *******************************

*No. of Days/Week (Ref. 1 Week) Market Work
tab crnumdys, m 
ren crnumdys work_days_pweek_1w

*Avg. num. of wrk. days per week during 3 mnth.
tab usnumdys, m 
ren usnumdys work_days_pweek_3m
tab work_days_pweek_3m , m
replace work_days_pweek_3m = . if work_days_pweek_3m == 0

            *Unconditional work hours per day: IF UNEMPLOYED & OLF: WAGE IS 0
            gen work_days_pweek_3m_unolf = work_days_pweek_3m if employed_3cat_3m == 2
            replace work_days_pweek_3m_unolf = 0 if employed_3cat_3m  == 1 | employed_3cat_3m  == 0 
            tab work_days_pweek_3m_unolf
            lab var work_days_pweek_3m_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: 0 - work day per week (3-month)"

            *Unconditional work hours per day: IF UNEMPLOYED : WAGE IS 0 / IF OLF: WAGE IS MISSING
            gen work_days_pweek_3m_unemp = work_days_pweek_3m if employed_3cat_3m == 2
            replace work_days_pweek_3m_unemp = 0 if employed_3cat_3m == 1 //UNEMP
            replace work_days_pweek_3m_unemp = . if employed_3cat_3m == 0 //OLF
            tab work_days_pweek_3m_unemp
            lab var work_days_pweek_3m_unemp "UNCONDITIONAL - UNEMPLOYED work day per week 0 / OLF work day pweek MISSING - work day pw (3m)"

                                 *******************************
                                 ****    HOURS OF WORK      ****
                                 *******************************

/*
For all workers, we examine hours per week, */

*No. of Hours/Day (Ref. 1 Week) Market Work
tab crhrsday, m 

*ssc install winsor2
*h winsor2

*No. of Hours/Day (Ref. 3 mnths) Market Work
tab ushrsday, m 
ren ushrsday work_hours_pday_3m
tab work_hours_pday_3m

tab work_hours_pday_3m
su work_hours_pday_3m, d
winsor2 work_hours_pday_3m, s(_w) c(0 98)
su work_hours_pday_3m_w

            *Unconditional work hours per day: IF UNEMPLOYED & OLF: WAGE IS 0
            gen work_hours_pday_3m_w_unolf = work_hours_pday_3m_w if employed_3cat_3m == 2
            replace work_hours_pday_3m_w_unolf = 0 if employed_3cat_3m  == 1 | employed_3cat_3m  == 0 
            tab work_hours_pday_3m_w_unolf
            lab var work_hours_pday_3m_w_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: 0 - work hours day (3-month)"

            *Unconditional work hours per day: IF UNEMPLOYED : WAGE IS 0 / IF OLF: WAGE IS MISSING
            gen work_hours_pday_3m_w_unemp = work_hours_pday_3m_w if employed_3cat_3m == 2
            replace work_hours_pday_3m_w_unemp = 0 if employed_3cat_3m == 1 //UNEMP
            replace work_hours_pday_3m_w_unemp = . if employed_3cat_3m == 0 //OLF
            tab work_hours_pday_3m_w_unemp
            lab var work_hours_pday_3m_w_unemp "UNCONDITIONAL - UNEMPLOYED work hours 0 / OLF work hours day MISSING - work hours (3m)"

*Crr. No. of Hours/Week, Market Work, (Ref. 1 Week).
tab crnumhrs1, m 

*Crr. No. of Hours/Week, Market & Subsistence Work, (Ref. 1 Week)
tab crnumhrs2, m 

*Usual No. of Hours/Week, Market Work, (Ref. 3-month).
tab ushrswk1, m 
ren ushrswk1 work_hours_pweek_3m
tab crnumhrs1 if work_hours_pweek_3m == 0 
tab work_hours_pweek_3m usempstp
replace work_hours_pweek_3m = crnumhrs1 if work_hours_pweek_3m == 0

tab work_hours_pweek_3m
su work_hours_pweek_3m, d
winsor2 work_hours_pweek_3m, s(_w) c(0 99)
su work_hours_pweek_3m_w

            *Unconditional work hours per day: IF UNEMPLOYED & OLF: WAGE IS 0
            gen work_hours_pw_3m_w_unolf = work_hours_pweek_3m if employed_3cat_3m == 2
            replace work_hours_pw_3m_w_unolf = 0 if employed_3cat_3m  == 1 | employed_3cat_3m  == 0 
            tab work_hours_pw_3m_w_unolf
            lab var work_hours_pw_3m_w_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: 0 - work hours week (3-month)"

            *Unconditional work hours per day: IF UNEMPLOYED : WAGE IS 0 / IF OLF: WAGE IS MISSING
            gen work_hours_pw_3m_w_unemp = work_hours_pweek_3m if employed_3cat_3m == 2
            replace work_hours_pw_3m_w_unemp = 0 if employed_3cat_3m == 1 //UNEMP
            replace work_hours_pw_3m_w_unemp = . if employed_3cat_3m == 0 //OLF
            tab work_hours_pw_3m_w_unemp
            lab var work_hours_pw_3m_w_unemp "UNCONDITIONAL - UNEMPLOYED work hours week 0 / OLF work hours MISSING - work hours (3m)"


*Usual No. of Hours/Week, Market & Subsistence Work, (Ref. 3-month)
tab ushrswk2, m 


*Usual No. of Hours in 3 months Market Work (Ref. 3-month)
tab ushrs3mnth, m 

*Average worked hour per month for irregular job
tab avhrspmir, m 
ren avhrspmir work_hours_pm_informal
replace work_hours_pm_informal = . if work_hours_pm_informal == 0 

replace work_hours_pm_informal = 672 if work_hours_pm_informal > 672 & !mi(work_hours_pm_informal)
tab work_hours_pm_informal
su work_hours_pm_informal, d
winsor2 work_hours_pm_informal, s(_w) c(0 98)
su work_hours_pm_informal_w


tab work_hours_pm_informal formal , m
tab work_hours_pm_informal uswrkst2 , m
tab work_hours_pm_informal job_formal_3m , m

                                    *******************************
                                    ****       WAGE            ****
                                    *******************************
save "$data_temp/temp_dataset.dta", replace 

use  "$data_temp/temp_dataset.dta", clear 
/*
keep if emp_16_10 == 1 

tab nationality_cl year 
drop if nationality_cl != 1


***************
* WORKING AGE *
*************** 

*Keep only working age pop? 15-64 ? As defined by the ERF
drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016


br wgscj3 basicwg3 ovrtime3 otherwg3 ttmonwg3 mnthwgAllJob mnthwg hrwgAllJob hrwg avdwirmn schrwg scmnthwg  

tab mnthwgAllJob

keep if mi(basicwg3)
keep if !mi(mnthwgAllJob)
*/


tab mnthwgAllJob
tab hrwgAllJob
sort mnthwgAllJob
*br mnthwgAllJob
winsor2 mnthwgAllJob, replace cuts(0.03 99.94)
tab mnthwgAllJob, m 
winsor2 hrwgAllJob, replace cuts(0 99.95)
replace basicwg3 = mnthwgAllJob * 3 if mi(basicwg3)
replace ttmonwg3 = mnthwgAllJob * 3 if mi(ttmonwg3)

tab basicwg3
winsor2 basicwg3, replace cuts(0.3 99.98)
tab ttmonwg3
winsor2 ttmonwg3, replace cuts(0.3 99.98)

/*and for wage workers, we examine both hourly wages
and monthly wages. Around 86% of employed Jordanians were wage workers in 2016. Given the
limited number of non-wage workers we do not analyze them separately.*/

tab basicwg3, m //Basic Wage
tab basicwg3 uswrkst2
tab ttmonwg3, m //Total Wage

su basicwg3 ttmonwg3

tab scmnthwg if ttmonwg3 == 0
tab wgscj3

         *** WAGE ***

*How wage in the longest main job calc.
tab mtwgdet, m 

*Basic Wage (3-month): Conditional wage: EMPLOYED ONLY
tab basicwg3, m 
ren basicwg3 basic_wage_3m

      *Corrected from inflation
      gen real_basic_wage_3m = basic_wage_3m / CPIin17
      lab var real_basic_wage_3m "CORRECTED INFLATION - Basic Wage (3-month)"

      *LN: Conditional wage: EMPLOYED ONLY
      gen ln_basic_rwage_3m = ln(1+real_basic_wage_3m) 
      lab var ln_basic_rwage_3m "LOG Basic Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING"

      *IHS
      gen IHS_basic_rwage_3m = log(real_basic_wage_3m+((real_basic_wage_3m^2+1)^0.5))
      lab var IHS_basic_rwage_3m "IHS Basic Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING"


      *Unconditional wage: IF UNEMPLOYED & OLF: WAGE IS 0
      gen IHS_b_rwage_unolf = IHS_basic_rwage_3m if employed_3cat_3m == 2
      replace IHS_b_rwage_unolf = 0 if employed_3cat_3m  == 1 | employed_3cat_3m  == 0 
      tab IHS_b_rwage_unolf
      lab var IHS_b_rwage_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - IHS - Basic Wage (3-month)"

      *Unconditional wage: IF UNEMPLOYED & OLF: WAGE IS 0
      gen ln_b_rwage_unolf = ln_basic_rwage_3m if employed_3cat_3m == 2
      replace ln_b_rwage_unolf = 0 if employed_3cat_3m  == 1 | employed_3cat_3m  == 0 
      tab ln_b_rwage_unolf
      lab var ln_b_rwage_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - LOG - Basic Wage (3-month)"

      *Unconditional wage: IF UNEMPLOYED : WAGE IS 0 / IF OLF: WAGE IS MISSING
      gen IHS_b_rwage_unemp = IHS_basic_rwage_3m if employed_3cat_3m == 2
      replace IHS_b_rwage_unemp = 0 if employed_3cat_3m == 1 //UNEMP
      replace IHS_b_rwage_unemp = . if employed_3cat_3m == 0 //OLF
      tab IHS_b_rwage_unemp
      lab var IHS_b_rwage_unemp "UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - IHS Basic (3m)"

     *Unconditional wage: IF UNEMPLOYED : WAGE IS 0 / IF OLF: WAGE IS MISSING
      gen ln_b_rwage_unemp = ln_basic_rwage_3m if employed_3cat_3m == 2
      replace ln_b_rwage_unemp = 0 if employed_3cat_3m == 1 //UNEMP
      replace ln_b_rwage_unemp = . if employed_3cat_3m == 0 //OLF
      tab ln_b_rwage_unemp
      lab var ln_b_rwage_unemp "UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - LOG Basic (3m)"


tab IHS_b_rwage_unemp employed_3cat_3m, m 
tab IHS_b_rwage_unolf employed_3cat_3m, m 

su IHS_b_rwage_unemp  
su IHS_b_rwage_unolf 

*Bonuses and incentives (3-month)
tab bonuses3, m 
*Overtime Wage (3-month)
tab ovrtime3, m 
*Other Wage (3-month)
tab otherwg3, m 
*Profit Sharing (3-month)
tab prftshr3, m 


*Total Wages (3-month)
tab ttmonwg3, m 
ren ttmonwg3 total_wage_3m

tab total_wage_3m

      *Corrected from inflation
      gen real_total_wage_3m = total_wage_3m / CPIin17
      lab var real_total_wage_3m "CORRECTED INFLATION - Total Wage (3-month)"

      *LN
      gen ln_total_rwage_3m = ln(1+real_total_wage_3m)
      lab var ln_total_rwage_3m "LOG Total Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING"

      *IHS
      gen IHS_total_rwage_3m = log(real_total_wage_3m+((real_total_wage_3m^2+1)^0.5))
      lab var IHS_total_rwage_3m "IHS Total Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING"

      *Unconditional wage: IF UNEMPLOYED & OLF: WAGE IS 0
      gen IHS_t_rwage_unolf = IHS_total_rwage_3m if employed_3cat_3m == 2
      replace IHS_t_rwage_unolf = 0 if employed_3cat_3m  == 1 | employed_3cat_3m  == 0 
      tab IHS_t_rwage_unolf
      lab var IHS_t_rwage_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - IHS - Total Wage (3-month)"

     *Unconditional wage: IF UNEMPLOYED & OLF: WAGE IS 0
      gen ln_t_rwage_unolf = ln_total_rwage_3m if employed_3cat_3m == 2
      replace ln_t_rwage_unolf = 0 if employed_3cat_3m  == 1 | employed_3cat_3m  == 0 
      tab ln_t_rwage_unolf
      lab var ln_t_rwage_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - LOG - Total Wage (3-month)"

      *Unconditional wage: IF UNEMPLOYED : WAGE IS 0 / IF OLF: WAGE IS MISSING
      gen IHS_t_rwage_unemp = IHS_total_rwage_3m if employed_3cat_3m == 2
      replace IHS_t_rwage_unemp = 0 if employed_3cat_3m == 1 //UNEMP
      replace IHS_t_rwage_unemp = . if employed_3cat_3m == 0 //OLF
      tab IHS_t_rwage_unemp
      lab var IHS_t_rwage_unemp "UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - IHS Total (3m)"

      *Unconditional wage: IF UNEMPLOYED : WAGE IS 0 / IF OLF: WAGE IS MISSING
      gen ln_t_rwage_unemp = ln_total_rwage_3m if employed_3cat_3m == 2
      replace ln_t_rwage_unemp = 0 if employed_3cat_3m == 1 //UNEMP
      replace ln_t_rwage_unemp = . if employed_3cat_3m == 0 //OLF
      tab ln_t_rwage_unemp
      lab var ln_t_rwage_unemp "UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - LOG Total (3m)"

         *** PRIMARY ***

*Monthly Wage (Primary Job)
tab mnthwg, m 
*Hourly Wage (Primary Job)
tab hrwg, m 

         *** SECONDARY ***

*Secondary job hourly wage
tab schrw, m 
*Secondary job monthly wage
tab scmnthwg, m 

         *** PRIMARY & SECONDARY ***

*Hourly Wage (Prim.& Second. Jobs)
tab hrwgAllJob, m 
su hrwgAllJob, d 
ren hrwgAllJob hourly_wage 
lab var hourly_wage "Hourly Wage (Prim.& Second. Jobs)"

tab hourly_wage
su hourly_wage
*su hourly_wage if hourly_wage < `r(max)'
*return list
*replace hourly_wage = `r(mean)' if hourly_wage > `r(max)' & !mi(hourly_wage)

      *Corrected from inflation
      gen real_hourly_wage = hourly_wage / CPIin17
      lab var real_hourly_wage "CORRECTED INFLATION - Hourly Wage (Prim.& Second. Jobs)"

         *LOG
         gen ln_hourly_rwage = ln(1 + real_hourly_wage)
         lab var ln_hourly_rwage "LOG Hourly Wage (Prim.& Second. Jobs)"

           *Unconditional hourly wage: IF UNEMPLOYED & OLF: WAGE IS 0
            gen ln_hourly_rwage_unolf = ln_hourly_rwage if employed_3cat_3m == 2
            replace ln_hourly_rwage_unolf = 0 if employed_3cat_3m  == 1 | employed_3cat_3m  == 0 
            tab ln_hourly_rwage_unolf
            lab var ln_hourly_rwage_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - LOG - Hourly Wage (3-month)"

            *Unconditional hourly wage: IF UNEMPLOYED : WAGE IS 0 / IF OLF: WAGE IS MISSING
            gen ln_hourly_rwage_unemp = ln_hourly_rwage if employed_3cat_3m == 2
            replace ln_hourly_rwage_unemp = 0 if employed_3cat_3m == 1 //UNEMP
            replace ln_hourly_rwage_unemp = . if employed_3cat_3m == 0 //OLF
            tab ln_hourly_rwage_unemp
            lab var ln_hourly_rwage_unemp "UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - LOG Hourly Wage (3m)"

         *IHS
         gen IHS_hourly_rwage = log(real_hourly_wage + ((real_hourly_wage^2 + 1)^0.5))
         lab var IHS_hourly_rwage "IHS Hourly Wage (Prim.& Second. Jobs)"

*Monthly Wage (Prim.& Second. Jobs)
tab mnthwgAllJob, m 
su mnthwgAllJob, d 
ren mnthwgAllJob monthly_wage 
lab var monthly_wage "Monthly Wage (Prim.& Second. Jobs)"

tab monthly_wage
su monthly_wage
*su monthly_wage if monthly_wage < `r(max)'
*return list
*replace monthly_wage = `r(mean)' if monthly_wage > `r(max)' & !mi(monthly_wage)

      *Corrected from inflation
      gen real_monthly_wage = monthly_wage / CPIin17
      lab var real_monthly_wage "CORRECTED INFLATION - Monthly Wage (Prim.& Second. Jobs)"

         *LOG
         gen ln_monthly_rwage = ln(1 + real_monthly_wage)
         lab var ln_monthly_rwage "LOG Monthly Wage (Prim.& Second. Jobs)"

           *Unconditional hourly wage: IF UNEMPLOYED & OLF: WAGE IS 0
            gen ln_monthly_rwage_unolf = ln_monthly_rwage if employed_3cat_3m == 2
            replace ln_monthly_rwage_unolf = 0 if employed_3cat_3m  == 1 | employed_3cat_3m  == 0 
            tab ln_monthly_rwage_unolf
            lab var ln_monthly_rwage_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - LOG - monthly Wage (3-month)"

            *Unconditional hourly wage: IF UNEMPLOYED : WAGE IS 0 / IF OLF: WAGE IS MISSING
            gen ln_monthly_rwage_unemp = ln_hourly_rwage if employed_3cat_3m == 2
            replace ln_monthly_rwage_unemp = 0 if employed_3cat_3m == 1 //UNEMP
            replace ln_monthly_rwage_unemp = . if employed_3cat_3m == 0 //OLF
            tab ln_monthly_rwage_unemp
            lab var ln_monthly_rwage_unemp "UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - LOG monthly Wage (3m)"

         *IHS
         gen IHS_monthly_rwage = log(real_monthly_wage + ((real_monthly_wage^2 + 1)^0.5))
         lab var IHS_monthly_rwage "IHS Monthly Wage (Prim.& Second. Jobs)"

         *** IRREGULAR ***

*Average Daily Wage (Irregular Workers)
tab avdwirmn
ren avdwirmn daily_wage_irregular

tab daily_wage_irregular
su daily_wage_irregular
su daily_wage_irregular if daily_wage_irregular < `r(max)'
return list
replace daily_wage_irregular = `r(mean)' if daily_wage_irregular > `r(max)' & !mi(daily_wage_irregular)

      *Corrected from inflation
      gen real_daily_wage_irregular = daily_wage_irregular / CPIin17
      lab var real_daily_wage_irregular "CORRECTED INFLATION - Average Daily Wage (Irregular Workers)"

         *LOG
         gen ln_daily_rwage_irregular = ln(1 + real_daily_wage_irregular)
         lab var ln_daily_rwage_irregular "LOG Average Daily Wage (Irregular Workers)"

         *IHS
         gen IHS_daily_rwage_irregular = log(real_daily_wage_irregular + ((real_daily_wage_irregular^2 + 1)^0.5))
         lab var IHS_daily_rwage_irregular "IHS Average Daily Wage (Irregular Workers)"


                                    *******************************
                                    ****       UNION           ****
                                    *******************************

*Member of a syndicate/trade union (ref. 3-mnths)
tab unionont
ren unionont member_union_3m

            *Unconditional : IF UNEMPLOYED & OLF: IS 0
            gen member_union_3m_unolf = member_union_3m if employed_3cat_3m == 2
            replace member_union_3m_unolf = 0 if employed_3cat_3m  == 1 | employed_3cat_3m  == 0 
            tab member_union_3m_unolf
            lab var member_union_3m_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: 0 - member_union_3m"


                                    *******************************
                                    ****       SKILLS          ****
                                    *******************************

codebook skilreq edreq skillev 
*Does primary job require any skill
tab skilreq 
ren skilreq skills_required_pjob 

            *Unconditional : IF UNEMPLOYED & OLF: IS 0
            gen skills_required_pjob_unolf = skills_required_pjob if employed_3cat_3m == 2
            replace skills_required_pjob_unolf = 0 if employed_3cat_3m  == 1 | employed_3cat_3m  == 0 
            tab skills_required_pjob_unolf
            lab var skills_required_pjob_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: 0 - skills_required_pjob"


*Minimum education requirements for job
tab edreq 

*The level of his skill
tab skillev

                                    *******************************
                                    ****       CONTRACT        ****
                                    *******************************

codebook job1_01 job1_07 job1_08 job1_09
*Employment status - Job 01
tab job1_01
*Degree of stability - Job 01
tab job1_07
gen stability_main_job = 1 if job1_07 == 1 
replace stability_main_job = 0 if job1_07 != 1 & !mi(job1_07)
lab var stability_main_job "From job1_07 : Degree of stability - Job 01 - 1 Stable"

*Type of work contract - Job 01
tab job1_08
gen permanent_contract = 1 if job1_08 == 1 
replace permanent_contract = 0 if job1_08 == 2 | job1_08 == 3
lab var permanent_contract "From job1_08 : Type of work contract - Job 01 - 1 Permanent"


***************************************************************************


                              ***********************************
                              ****       HETEROGENOUS        ****
                              ***********************************



                                    *******************************
                                    ****  EDUCATION BINARY     ****
                                    *******************************

tab educ1d, m 
codebook educ1d
gen bi_education = 1 if educ1d == 7 | /// Post Graduate
                  educ1d == 6 | /// University
                  educ1d == 5 | /// Post Secondary
                  educ1d == 4  //Secondary
replace bi_education = 0 if educ1d == 3 | /// Basic Education
                     educ1d == 2 | /// Read and Write
                     educ1d == 1 // Illiterate
lab def bi_education 1 "Secondary or more" 0 "Below Secondary", modify
lab val bi_education bi_education
lab var bi_education "Educated is from Secondary education until post graduate"


******WEIGHTS*******
*expan_Hh 
*expan_ref_hh
*expan_indiv
*expan_ref_indiv

codebook hhid
destring hhid, replace
codebook indid
destring indid, replace 



/*
*TRYYYYYYYYYYY

drop IV_SS_OP ln_IV_SS_OP IHS_IV_SS_OP 
drop share_emp_open_bydis _merge
*total_empl 
*total_empl_op
drop share_emplOpen share_emplClose

preserve 

keep if year == 2010
distinct district_iid 

tab employed_3m, nol
gen bi_emplyed_3m = 0 if employed_3m == 1 
replace bi_emplyed_3m = 1 if employed_3m == 2 
lab def bi_emplyed_3m 0 "Unemployed (&subs)" 1 "Employed (no subs)", modify 
lab val bi_emplyed_3m bi_emplyed_3m
tab bi_emplyed_3m

bys district_iid: egen total_empl = sum(bi_emplyed_3m) if year == 2010 
tab total_empl, m    

tab wp_industry_jlmps_3m, nol
bys district_iid: egen total_empl_op = sum(wp_industry_jlmps_3m) if year == 2010 
tab total_empl_op, m 

bys district_iid : gen share_emp_open_bydis = total_empl_op / total_empl
tab share_emp_open_bydis, m 

duplicates drop district_iid, force

keep share_emp_open_bydis district_iid 
tempfile new_iv
save `new_iv'

restore 

merge m:1 district_iid using `new_iv'

*Missing 17 because that disrict was probably not surveyed in 2010
replace share_emp_open_bydis = 0 if district_iid == 17

gen IV_SS_OP = IV_SS * share_emp_open_bydis if share_emp_open_bydis != 0
replace IV_SS_OP = IV_SS if share_emp_open_bydis == 0 

*THE INSTRUMENT + TRANSFORMATION
gen ln_IV_SS_OP = log(1 + IV_SS_OP)
gen IHS_IV_SS_OP = log(IV_SS_OP + ((IV_SS_OP^2 + 1)^0.5))

*THE ASKED QUESTION IN QUEST (binary)
tab work_permit, m

*AGGREGATED MEASURE OF WP BASED ON work_permit
tab agg_wp, m
tab agg_wp_orig, m //Adding another more accurate measure

*CORRELATIONS
corr IV_SS_OP agg_wp  //0.64
corr IV_SS_OP agg_wp_orig //0.59
corr IV_SS_OP share_wp //0.55
*/
*save "$data_final/06_IV_JLMPS_Regression.dta", replace

save "$data_temp/06_IV_JLMPS_Construct_Outcomes_nowp.dta", replace




/* IV 1 : Layman term: Expected demand for work P at destination
IV1: 1/Dist_camp_d* Nbr WP_t
Layman term: Expected demand for work P at destination

Story : We start with the Fallah e al. IV augmented by the number of work permits allocated in Jordan 
*/

use "$data_temp/06_IV_JLMPS_Construct_Outcomes_nowp.dta", clear

merge m:1 district_iid using "$data_final/03_ShiftShare_IV_1.dta" 
tab district_iid if _merge == 1
drop _merge 

*THE INSTRUMENT 
tab IV_SS_1, m 

*NO INSTRUMENT / NO WP IN 2010
replace IV_SS_1 = 0 if year == 2010
tab IV_SS_1 , m

*THE INSTRUMENT + TRANSFORMATION
gen ln_IV_SS_1 = log(1 + IV_SS_1)
gen IHS_IV_SS_1 = log(IV_SS_1 + ((IV_SS_1^2 + 1)^0.5))

su IV_SS_1
*gen resc_IV_SS_1 = IV_SS_1/100 //orig
gen resc_IV_SS_1 = IV_SS_1/10000
su resc_IV_SS_1
lab var resc_IV_SS_1 "IV1"


*THE ASKED QUESTION IN QUEST (binary)
tab work_permit, m
*AGGREGATED MEASURE OF WP BASED ON work_permit
tab agg_wp, m
tab agg_wp_orig, m //Adding another more accurate measure

*CORRELATIONS
corr IV_SS_1 agg_wp  //
corr IV_SS_1 agg_wp_orig //
corr IV_SS_1 share_wp //

*save "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", replace




/* IV2: Nbr_refugees_t * 1/Dist_camp_d* Nbr WP_t
Layman term: Expected demand for work P at destination

Story: Augmented by the number of refugees since it will affect the demand for work permits
*/

/*
*use "$data_final/06_IV_JLMPS_Construct_Outcomes_nowp.dta", clear

merge m:1 district_iid using "$data_final/03_ShiftShare_IV_2.dta" 
tab district_iid if _merge == 1
drop _merge 

*THE INSTRUMENT 
tab IV_SS_2, m 

*NO INSTRUMENT / NO WP IN 2010
replace IV_SS_2 = 0 if year == 2010
tab IV_SS_2 , m

*THE INSTRUMENT + TRANSFORMATION
gen ln_IV_SS_2 = log(1 + IV_SS_2)
gen IHS_IV_SS_2 = log(IV_SS_2 + ((IV_SS_2^2 + 1)^0.5))

su IV_SS_2
gen resc_IV_SS_2 = IV_SS_2/10000
su resc_IV_SS_2
lab var resc_IV_SS_2 "IV2"


*THE ASKED QUESTION IN QUEST (binary)
tab work_permit, m
*AGGREGATED MEASURE OF WP BASED ON work_permit
tab agg_wp, m
tab agg_wp_orig, m //Adding another more accurate measure

*CORRELATIONS
corr IV_SS_2 agg_wp  //
corr IV_SS_2 agg_wp_orig //
corr IV_SS_2 share_wp //


*/



/**************
THE INSTRUMENT : IV3
**************/

/* IV3: [Nbr_refugees_ot* 1/dist_od] * [1/Dist_camp_d* Nbr WP_t]
Layman term: Expected demand for work P at destination

Story: Augmented by the number of refugees by destination district since it will affect the demand for work permits
*/

merge m:1 district_iid using "$data_final/03_ShiftShare_IV_3.dta" 
tab district_iid if _merge == 1
drop _merge 

*THE INSTRUMENT 
tab IV_SS_3, m 

*NO INSTRUMENT / NO WP IN 2010
replace IV_SS_3 = 0 if year == 2010
tab IV_SS_3 , m

*THE INSTRUMENT + TRANSFORMATION
gen ln_IV_SS_3 = log(1 + IV_SS_3)
gen IHS_IV_SS_3 = log(IV_SS_3 + ((IV_SS_3^2 + 1)^0.5))

su IV_SS_3
*gen resc_IV_SS_3 = IV_SS_3/1000 //orig
gen resc_IV_SS_3 = IV_SS_3/1000000000
su resc_IV_SS_3
lab var resc_IV_SS_3 "IV3"

*THE ASKED QUESTION IN QUEST (binary)
tab work_permit, m
*AGGREGATED MEASURE OF WP BASED ON work_permit
tab agg_wp, m
tab agg_wp_orig, m //Adding another more accurate measure

*CORRELATIONS
corr IV_SS_3 agg_wp  //
corr IV_SS_3 agg_wp_orig //
corr IV_SS_3 share_wp //






/**************
THE INSTRUMENT : IV4
**************/

/*
IV4: [Nbr_refugees_ot* 1/dist_od] * [1/Dist_camp_d* Nbr WP_t] * [Nbr WP_st * (Txemploi_s,d)]
Story: Augmented by the number of refugees by destination district since it will affect the demand 
for work permits and the sector composition at destination to approximate for expected supply of WP
Advantage using Jordanian sector
*/

merge m:1 district_iid using "$data_final/03_ShiftShare_IV_4.dta" 
tab district_iid if _merge == 1
drop if _merge == 1
drop _merge 

*THE INSTRUMENT 
tab IV_SS_4, m 

*NO INSTRUMENT / NO WP IN 2010
replace IV_SS_4 = 0 if year == 2010
tab IV_SS_4 , m

*THE INSTRUMENT + TRANSFORMATION
gen ln_IV_SS_4 = log(1 + IV_SS_4)
gen IHS_IV_SS_4 = log(IV_SS_4 + ((IV_SS_4^2 + 1)^0.5))

su IV_SS_4
gen resc_IV_SS_4 = IV_SS_4/1000000
su resc_IV_SS_4
lab var resc_IV_SS_4 "IV4"


*THE ASKED QUESTION IN QUEST (binary)
tab work_permit, m
*AGGREGATED MEASURE OF WP BASED ON work_permit
tab agg_wp, m
tab agg_wp_orig, m //Adding another more accurate measure

*CORRELATIONS
corr IV_SS_4 agg_wp  //
corr IV_SS_4 agg_wp_orig //
corr IV_SS_4 share_wp //







/**************
THE INSTRUMENT : IV5
**************/

/*
IV5: [Nbr_refugees_ot* 1/dist_od] * [1/Dist_camp_d* Nbr WP_t] * 
[Nbr WP_st * (Txemploi_s,o- Txemploi_s,d)^0.5]]

Layman term: Expected demand for work augmented with expected skill matching between origin 
and destination
*/



merge m:1 district_iid using "$data_final/03_ShiftShare_IV_5.dta" 
tab district_iid if _merge == 1
drop if _merge == 1
drop _merge 

*THE INSTRUMENT 
tab IV_SS_5, m 

*NO INSTRUMENT / NO WP IN 2010
replace IV_SS_5 = 0 if year == 2010
tab IV_SS_5 , m

*THE INSTRUMENT + TRANSFORMATION
gen ln_IV_SS_5 = log(1 + IV_SS_5)
gen IHS_IV_SS_5 = log(IV_SS_5 + ((IV_SS_5^2 + 1)^0.5))
su IV_SS_5
gen resc_IV_SS_5 = IV_SS_5/100000000
su resc_IV_SS_5 
*lab var resc_IV_SS_5 "IV5"

*THE ASKED QUESTION IN QUEST (binary)
tab work_permit, m
*AGGREGATED MEASURE OF WP BASED ON work_permit
tab agg_wp, m
tab agg_wp_orig, m //Adding another more accurate measure

*CORRELATIONS
corr IV_SS_5 agg_wp  //
corr IV_SS_5 agg_wp_orig //
corr IV_SS_5 share_wp //


save "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", replace


/*

/**************
THE INSTRUMENT : IV6
**************/

/*
IV6: 
[Nbr_refugees_ot* 1/dist_od] * [1/Dist_camp_d* Nbr WP_t] 
AND
[Nbr WP_st * (Txemploi_s,o- Txemploi_s,d)^0.5]]

  Decomposition of IV5
*/



merge m:1 district_iid using "$data_final/03_ShiftShare_IV_6.dta" 
tab district_iid if _merge == 1
drop if _merge == 1
drop _merge 

*THE INSTRUMENT 
tab IV_SS_6A, m 
tab IV_SS_6B, m 

*NO INSTRUMENT / NO WP IN 2010
replace IV_SS_6A = 0 if year == 2010
tab IV_SS_6A , m

*NO INSTRUMENT / NO WP IN 2010
replace IV_SS_6B = 0 if year == 2010
tab IV_SS_6B , m

*THE INSTRUMENT + TRANSFORMATION
gen ln_IV_SS_6A = log(1 + IV_SS_6A)
gen IHS_IV_SS_6A = log(IV_SS_6A + ((IV_SS_6A^2 + 1)^0.5))

*THE INSTRUMENT + TRANSFORMATION
gen ln_IV_SS_6B = log(1 + IV_SS_6B)
gen IHS_IV_SS_6B = log(IV_SS_6B + ((IV_SS_6B^2 + 1)^0.5))

*THE ASKED QUESTION IN QUEST (binary)
tab work_permit, m
*AGGREGATED MEASURE OF WP BASED ON work_permit
tab agg_wp, m
tab agg_wp_orig, m //Adding another more accurate measure

*CORRELATIONS
corr IV_SS_6A agg_wp  //
corr IV_SS_6A agg_wp_orig //
corr IV_SS_6A share_wp //

*CORRELATIONS
corr IV_SS_6B agg_wp  //
corr IV_SS_6B agg_wp_orig //
corr IV_SS_6B share_wp //



*/






log close
