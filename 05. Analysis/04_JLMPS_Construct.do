
cap log close
clear all
set more off, permanently
set mem 100m


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


merge m:1 district_iid using "$data_final/03_ShiftShare_IV.dta" 
drop _merge 

merge m:1 governorate_iid using "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta"
drop _merge

tab work_permit, m //more accurate version 
tab work_permit_orig, m
tab IV_SS, m
*NO INSTRUMENT / NO WP IN 2010
replace IV_SS = 0 if year == 2010
tab IV_SS , m


tab nationality q11203
tab q11203
tab nationality_cl
tab year 

*save "$data_final/05_IV_JLMPS_Analysis.dta", replace
save "$data_final/05_IV_JLMPS_MergingIV.dta", replace




use "$data_final/05_IV_JLMPS_MergingIV.dta", clear


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
tab agg_wp, m
tab agg_wp year, m
*br agg_wp year IV_SS 
*sort year 


* ORIGINAL *

*AGGREGATED NUMBER OF WORK PERMIT
preserve
tab forced_migr
codebook forced_migr
drop if forced_migr != 1
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
tab agg_wp_orig year, m
*br agg_wp year IV_SS 
*sort year 

bys year: distinct district_iid
bys year: tab district_iid
bys year: tab district_en

/*---------*********************************************************************-----------
-----------*********************************************************************-----------
                                   VARIABLES CLEANING 
-----------*********************************************************************-----------
-----------*********************************************************************-----------*/

                                       **********
                                       *Controls*
                                       **********

tab NbRefbyGovoutcamp, m
replace NbRefbyGovoutcamp = 0 if year == 2010
gen ln_ref = ln(1 + NbRefbyGovoutcamp)
*ln_ref, as of now, does not include refugees in 2010, only in 2016

gen age2 = age^2

*Distance between zaatari camp and districts jordan
gen dist_zaatari_lat = 32.30888675674741
gen dist_zaatari_long = 36.31329385051756
geodist district_lat district_long dist_zaatari_lat dist_zaatari_long, gen(distance_dis_camp)
tab distance_dis_camp, m
lab var distance_dis_camp "Distance (km) between JORD districts and ZAATARI CAMP"

*Education
*-Father
tab fteducst, m
codebook fteducst
*-Mother
tab mteducst, m
*-Own
tab educ1d, m

                                       ************
                                       *Instrument*
                                       ************

*THE INSTRUMENT 
tab IV_SS, m 

*THE INSTRUMENT + TRANSFORMATION
gen log_IV_SS=log(1+IV_SS)
gen IHS_IV_SS=log(IV_SS+((IV_SS^2+1)^0.5))

*THE ASKED QUESTION IN QUEST (binary)
tab work_permit, m

*AGGREGATED MEASURE OF WP BASED ON work_permit
tab agg_wp, m
tab agg_wp_orig, m //Adding another more accurate measure

*CORRELATIONS
corr IV_SS agg_wp //0.64
corr IV_SS agg_wp_orig //0.58


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


codebook    yrjob1 job1_m job1_y job1_01 job1_02 job1_03 job1_04 job1_05 job1_06 ///
            job1_07 job1_08 job1_09 job1_10m job1_10y job1_11 job1_12 job1_13 ///
            job1_14m job1_14y job1_15 job1_16dis job1_16g job1_16o_nh job1_17

*drop if uswrkst1 == 3
ren employed employed_2016 

gen employed_3m = 1 if uswrkst2 == 1
replace employed_3m = 0 if uswrkst2 == 2 
replace employed_3m = . if uswrkst2 == 3
tab employed_3m, m 
lab var employed_3m "From uswrkst2 - ext def, search not req; 3 months, empl or unemp, OLF is miss"

gen employed_1w = 1 if uswrkst2 == 1
replace employed_1w = 0 if uswrkst2 == 2 
replace employed_1w = . if uswrkst2 == 3
tab employed_1w, m 
lab var employed_1w "From uswrkst2 - ext def, search not req; 1 week, empl or unemp, OLF is miss"

*CPIin17
*crirreg

*******************************
****    UNEMPLOYMENT       ****
*******************************

tab unemp2m, m //Unemp1m
tab employed_3m, m

tab unemp2m employed_3m, m
br * if  unemp2m == 1 & employed_3m  == 1 //Currently unemployed but employed in the last 3 months
br * if  unemp2m == . & employed_3m  == 1 //Currently out of the labor force but employed in the last 3 months

gen unemployed = unemp2m 
lab var unemployed "From unemp2m - ext def, search not req; 1 week, empl or unemp, OLF is miss"

* UNEMPLOYEMENT

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
****       WAGE            ****
*******************************

tab basicwg3, m //Basic Wage
tab ttmonwg3, m //Total Wage

su basicwg3 ttmonwg3

tab scmnthwg if ttmonwg3 == 0
tab wgscj3
*Primary 
tab mtwgdet, m 
tab basicwg3, m 
tab bonuses3, m 
tab ovrtime3, m 
tab otherwg3, m 
tab prftshr3, m 
tab ttmonwg3, m 
tab mnthwgAllJob, m 
tab mnthwg, m 
tab hrwgAllJob, m 
tab hrwg, m 
tab avdwirmn, m 

*Secondary
tab schrw, m 
tab scmnthwg, m 

/*
              storage   display    value
variable name   type    format     label      variable label
-----------------------------------------------------------------
mtwgdet         byte    %53.0g     q10101_lab How wage in the longest main job calc.
basicwg3        float   %9.0g                 Basic Wage (3-month)
ovrtime3        float   %9.0g                 Overtime Wage (3-month)
otherwg3        float   %9.0g                 Other Wage (3-month)
ttmonwg3        float   %9.0g                 Total Wages (3-month)
mnthwgAllJob    float   %9.0g                 Monthly Wage (Prim.& Second. Jobs)
mnthwg          float   %9.0g                 Monthly Wage (Primary Job)
hrwgAllJob      float   %9.0g                 Hourly Wage (Prim.& Second. Jobs)
hrwg            float   %9.0g                 Hourly Wage (Primary Job)
avdwirmn        int     %9.0g                 Average Daily Wage (Irregular Workers)
schrwg          float   %9.0g                 Secondary job hourly wage
scmnthwg        float   %9.0g                 Secondary job monthly wage
*/










gen ln_wage = ln(1+basicwg3)
tab ln_wage, m
gen IHS_wage=log(basicwg3+((basicwg3^2+1)^0.5))

*WAGE ONLY 
gen ln_wage_natives = ln_wage if nationality_cl == 1

*Unconditional wage: IF UNEMPLOYED (&OUT LF): WAGE IS 0
gen ln_wage_uncond_unemp_olf = ln_wage_natives if usemp1 == 1
replace ln_wage_uncond_unemp_olf = 0 if usemp1 == 0
tab ln_wage_uncond_unemp_olf

*Unconditional wage: IF UNEMPLOYED : WAGE IS 0 / IF OUT OF LF : WAGE IS MISSING
gen ln_wage_uncond_unemp = ln_wage_natives if usemp1 == 1
replace ln_wage_uncond_unemp = 0 if usemp1 == 0
replace ln_wage_uncond_unemp = . if mi(unemp1m) 
tab ln_wage_uncond_unemp

*Conditional wage: EMPLOYED ONLY
gen ln_wage_natives_cond = ln_wage_natives if usemp1 == 1 
tab ln_wage_natives_cond

tab mnthwgAllJob, m //Monthly wage
gen ln_mthly_wage = ln(1+mnthwgAllJob)

su hrwgAllJob, d //Hourly wage
gen ln_hourly_wage = ln(1+hrwgAllJob)

tab avdwirmn , m //Informal Wage 
gen ln_avdwirmn = ln(1+avdwirmn)



*******************************
****     DAYS OF WORK      ****
*******************************

tab crnumdys, m //Days per week

*******************************
****    HOURS OF WORK      ****
*******************************

tab crhrsday, m //Hours per day
tab crnumhrs1, m //Hours per week


*******************************
****       INFORMAL        ****
*******************************

gen informal = 1 if ussocinsp == 0 
replace informal = 1 if uscontrp == 0 
replace informal = 0 if ussocinsp == 1
replace informal = 0 if uscontrp == 1
tab informal, m

tab informal usemp1




*CODEBOOKS
codebook    unempdurmth unemp1 unemp2 unempsr1 unempsr2 unemp1m unemp2m unempsr1m ///
            unempsr2m unwrkevr1 unwrkevr2 search srchdurmth rsnnosrch avail evrwrk ///
            rsnolf jobless1 jobless2 cremp1 cremp2 usemp1 usemp2 crempstp crstablp ///
            crsectrp crirreg croccupp crocp1d crocp2d crocp3d crecactp crecac1d ///
            crecac2d crecac3d crsocinsp crcontrp crformal crinstsec usempstp ussectrp ///
            usstablp usestblp usirreg usoccupp usocp1d usocp2d usocp3d usecactp usecac1d ///
            usecac2d usecac3d ussocinsp uscontrp usformal usinstsec crnumdys crhrsday ///
            crnumhrs1 crnumhrs2 ushrsday ushrswk1 ushrswk2 usnumdys ushrs3mnth avhrspmir



*EMPLOYEMENT 
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
*Job stability in prim. job (ref. 1-week)
tab crstablp, m 
*Economic sector of prim. job (ref. 1-week)
tab crsectrp, m 
*crr. main job(ref. week) is irregular
tab crirreg, m 
*Occup. of crr. jb (4-digit based on ISCO 2008, ref. 1-week)
tab croccupp, m 
*
tab crocp1d, m 
*
tab crocp2d, m 
*
tab crocp3d, m 
*
tab crecactp, m 
*
tab crecac1d, m 
*
tab crecac2d, m 
*
tab crecac3d, m 
*
tab crsocinsp, m 
*
tab crcontrp, m 
*
tab crformal, m 
*
tab crinstsec, m 
*
tab usempstp, m 
*
tab ussectrp, m 
*
tab usstablp, m 
*
tab usestblp, m 
*
tab usirreg, m 
*
tab usoccupp, m 
*
tab usocp1d, m 
*
tab usocp2d, m 
*
tab usocp3d, m 
*
tab usecactp, m 
*
tab usecac1d, m 
*
tab usecac2d, m 
*
tab usecac3d, m 
*
tab ussocinsp, m 
*
tab uscontrp, m 
*
tab usformal, m 
*
tab usinstsec, m 
*
tab crnumdys, m 
*
tab crhrsday, m 
*
tab crnumhrs1, m 
*
tab crnumhrs2, m 
*
tab ushrsday, m 
*
tab ushrswk1, m 
*
tab ushrswk2, m 
*
tab usnumdys, m 
*
tab ushrs3mnth, m 
*
tab avhrspmir, m 
*
*tab

*WAGE 
*mtwgdet basicwg3 bonuses3 ovrtime3 otherwg3 prftshr3 ttmonwg3 mnthwgAllJob mnthwg hrwgAllJob hrwg avdwirmn

*job1_01 job1_02 job1_03 job1_04 job1_05 job1_07 job1_08 job1_12 job1_16dis job1_16g job1_16o_nh

******WEIGHTS*******
*expan_Hh 
*expan_ref_hh
*expan_indiv
*expan_ref_indiv

codebook hhid
destring hhid, replace
codebook indid
destring indid, replace 

*save "$data_final/06_IV_JLMPS_Regression.dta", replace
save "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", replace
