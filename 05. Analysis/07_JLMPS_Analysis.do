


	****************************************************************************
	**                            IV ANALYSIS / REG                           **  
	****************************************************************************

*Merge JLMPS and SHIFT SHARE
use "$data_final/02_JLMPS_10_16.dta", clear

merge m:1 district_iid using "$data_final/03_ShiftShare_IV.dta" 
drop _merge 

merge m:1 governorate_iid using "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta"
drop _merge

tab work_permit, m
tab IV_SS, m
*NO INSTRUMENT / NO WP IN 2010
replace IV_SS = 0 if year == 2010
tab IV_SS , m

save "$data_final/05_IV_JLMPS_Analysis.dta", replace




use "$data_final/05_IV_JLMPS_Analysis.dta", clear

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
tab fteducst
*-Mother
tab mteducst
*-Own
tab educ1d

************
*Instrument*
************

tab IV_SS, m
tab work_permit, m
tab agg_wp, m
corr IV_SS agg_wp //0.64
corr IV_SS agg_wp_orig //0.58

gen log_IV_SS=log(1+IV_SS)
gen IHS_IV_SS=log(IV_SS+((IV_SS^2+1)^0.5))


**********
*Outcomes*
**********

tab basicwg3, m //Basic Wage
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

tab unemp1m, m //Unemp1m
tab crnumdys, m //Days per week
tab crhrsday, m //Hours per day
tab crnumhrs1, m //Hours per week

gen informal = 1 if ussocinsp == 0 
replace informal = 1 if uscontrp == 0 
replace informal = 0 if ussocinsp == 1
replace informal = 0 if uscontrp == 1
tab informal, m

tab informal usemp1



******WEIGHTS*******
*expan_Hh 
*expan_ref_hh
*expan_indiv
*expan_ref_indiv

codebook hhid
destring hhid, replace
codebook indid
destring indid, replace 


save "$data_final/06_IV_JLMPS_Regression.dta", replace


cap log close
clear all
set mem 100m
set more off, permanently

use "$data_final/06_IV_JLMPS_Regression.dta", clear

*adoupdate, update
*findfile  ivreg2.ado
*adoupdate, update **
*ssc inst ivreg2, replace

************
*REGRESSION*
**********

*br indid indid_2010 indid_2016 year
*SAMPLE: SAME INDIVIDUALS WERE SURVEYED IN 2010 AND 2016
*BUT A FEW WERE NOT (ALL REFUGEE WEREN'T SURVEYED IN 2010)
*AND A FEW JORDANIANS. I DECDIE TO KEEP ONLY THE PANEL STRUCTURE 
*FOR FIXED EFFECT AT THE INDIV LEVEL 

*Among the natives
keep if nationality_cl == 1
*Flag those who were surveyed in both rounds 
gen surveyed_2_rounds = 1 if !mi(indid_2010) & !mi(indid_2016)
*Keep only the surveyed in both round
keep if surveyed_2_rounds == 1 

*Common identifier
sort indid_2010
distinct indid_2010 //28316/2 = 14158 while we have 14306: there is an inbalance
*Even if they have an ID for both few actually did not do one of the round 
duplicates tag indid_2010, gen(dup)
bys year: tab dup //(90 in 2010 and 206 in 2016)
*Dropping those who actually did not the two rounds 
drop if dup == 0 
*28020 indiv surveyed twice in 2010 and 2020
mdesc indid_2010
destring indid_2010, replace 


**************
*GLOBALS 
global    controls ///
          age age2 sex hhsize 
global    lm_out ///
          ln_wage_natives_cond     /// Wage Cond   (no empl = . / out LF = .)
           usemp1 /// Employed
          unemp1 /// Unemp 
           crnumhrs1 /// Hours of work per week
          informal // Informal if no contract and no insurance

         *ln_wage_uncond_unemp     /// Wage Uncond (no empl = 0 / out LF = .)
          *ln_wage_uncond_unemp_olf /// Wage Uncond (no empl = 0 / out LF = 0)
         *crnumdys /// Days of work per week
          *crhrsday /// Hours of work per day 

***********************
* DESCRIPTIVE STATISTICS

*Summary statstics
bys year: sum IV_SS agg_wp work_permit ///
              $lm_out $controls ln_ref basicwg3 NbRefbyGovoutcamp ///
              educ1d fteducst mteducst [aweight = expan_indiv] 

*Dividing into treated areas: WP against NO WP: District differences?
tab agg_wp, m
gen bi_agg_wp = 1 if agg_wp != 0
replace bi_agg_wp = 0 if agg_wp == 0
tab bi_agg_wp, m

reg age agg_wp
ttest age == agg_wp


xtset, clear 
*xtset year
xtset indid_2010 year 
**************
*REGRESSIONS

*Apply the same restriction as in the questionnaire
keep if age > 15 & age < 64 
*Keep the Jordanian Sample 
keep if  nationality_cl == 1
tab forced_migr 
*A few jordanian are forced migrants, maybe internal? 

tab year 
/*
       year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2010 |      7,575       43.98       43.98
       2016 |      9,650       56.02      100.00
------------+-----------------------------------
      Total |     17,225      100.00
*/

mdesc ln_wage ln_wage_natives ln_wage_natives_cond ///
      ln_wage_uncond_unemp ln_wage_uncond_unemp_olf


  ********** M1: SIMPLE OLS: 
foreach outcome of global lm_out {
  xi: reg `outcome' agg_wp ///
          $controls i.educ1d i.fteducst i.mteducst ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)
}

  ********** M2: SIMPLE OLS: DISTRICT FE
foreach outcome of global lm_out {
  xi: reg `outcome' agg_wp ///
          i.district_iid ///
          $controls i.educ1d i.fteducst i.mteducst   ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)
}

  ********** M3: YEAR FE / DISTRICT FE
foreach outcome of global lm_out {
  *OLS
  xi: reg `outcome' agg_wp ///
          i.district_iid i.year ///
          $controls i.educ1d i.fteducst i.mteducst   ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)
}

foreach outcome of global lm_out {
  *IV
  xi: ivreg2  `outcome' ///
              i.year i.district_iid ///
              $controls i.educ1d i.fteducst i.mteducst  ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first 
  estimates table, star(.05 .01 .001) 
  * With equivalent first-stage
  gen smpl=0
  replace smpl=1 if e(sample)==1

  xi: reg agg_wp IHS_IV_SS ///
          i.year i.district_iid ///
          $controls i.educ1d i.fteducst i.mteducst  ///
          if smpl == 1 [pweight = expan_indiv], ///
          cluster(district_iid) robust
  estimates table, star(.05 .01 .001)           
    drop smpl 
}

  ********** M4: YEAR FE / DISTRICT FE / CONTROL NUMBER OF REFUGEE
foreach outcome of global lm_out {
  *OLS
  xi: reg `outcome' agg_wp ///
          i.district_iid i.year ///
          ln_ref $controls i.educ1d i.fteducst i.mteducst  ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)
}
foreach outcome of global lm_out {
  *IV
  xi: ivreg2  `outcome' ///
              i.year i.district_iid ///
              ln_ref $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first
  estimates table, star(.05 .01 .001)

  * With equivalent first-stage
  gen smpl=0
  replace smpl=1 if e(sample)==1

  xi: reg agg_wp IHS_IV_SS ///
          i.year i.district_iid ///
          ln_ref $controls i.educ1d i.fteducst i.mteducst  ///
          if smpl == 1 [pweight = expan_indiv], ///
          cluster(district_iid) robust
  estimates table, star(.05 .01 .001)           
    drop smpl 
}

  ********** M5:  YEAR FE / DISTRICT FE / SECOTRAL FE 
foreach outcome of global lm_out {
  *OLS
  xi: reg `outcome' agg_wp ///
          i.district_iid i.year i.crsectrp ///
          $controls i.educ1d i.fteducst i.mteducst  ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)
}

foreach outcome of global lm_out {
  *IV
  xi: ivreg2  `outcome' ///
              i.year i.district_iid i.crsectrp ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)

  * With equivalent first-stage
  gen smpl=0
  replace smpl=1 if e(sample)==1

  xi: reg agg_wp IHS_IV_SS ///
          i.year i.district_iid i.crsectrp ///
          $controls i.educ1d i.fteducst i.mteducst  ///
          if smpl == 1 [pweight = expan_indiv], ///
          cluster(district_iid) robust
  estimates table, star(.05 .01 .001)           
    drop smpl 
}

  ********** M6:  YEAR FE / DISTRICT FE / SECOTRAL FE / CONTROL NUMBER OF REFUGEE
foreach outcome of global lm_out {
  *OLS
  xi: reg `outcome' agg_wp ///
          i.district_iid i.year i.crsectrp ///
          ln_ref $controls i.educ1d i.fteducst i.mteducst  ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)
}
foreach outcome of global lm_out {
  *IV
  xi: ivreg2  `outcome' ///
              i.year i.district_iid i.crsectrp ///
              ln_ref $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)
  * With equivalent first-stage
  gen smpl=0
  replace smpl=1 if e(sample)==1

  xi: reg agg_wp IHS_IV_SS ///
          i.year i.district_iid i.crsectrp ///
          ln_ref $controls i.educ1d i.fteducst i.mteducst  ///
          if smpl == 1 [pweight = expan_indiv], ///
          cluster(district_iid) robust
  estimates table, star(.05 .01 .001)           
    drop smpl 
}

  ********** M7: YEAR FE / INDIV FE 
foreach outcome of global lm_out {
  *OLS
  reghdfe `outcome' agg_wp ///
          $controls i.educ1d i.fteducst i.mteducst ///
          [pw=expan_indiv], ///
          absorb(year indid_2010) ///
          cluster(district_iid) 
}
  /*
  * Then I partial out all variables
  foreach y in ln_wage agg_wp $controls educ1d fteducst mteducst   {
    reghdfe `y' [pw=expan_indiv], absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  drop ln_wage $controls educ1d fteducst mteducst  agg_wp  
  foreach y in ln_wage $controls educ1d fteducst mteducst  agg_wp  {
    rename o_`y' `y' 
  } 
  reg ln_wage agg_wp  $controls [pw=expan_indiv], cluster(district_iid) robust
  */
  *IV

 foreach outcome of global lm_out {
 preserve
  xi: ivreg2  `outcome' ///
              i.year i.district_iid ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) 

  gen smpl=0
  replace smpl=1 if e(sample)==1
  * Then I partial out all variables
  foreach y in `outcome' $controls agg_wp IHS_IV_SS educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2 `outcome' ///
         $controls educ1d fteducst mteducst ///
         (agg_wp = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         cluster(district_iid) robust ///
         first
  drop `outcome' agg_wp IHS_IV_SS $controls educ1d fteducst mteducst smpl
  foreach y in `outcome' $controls  agg_wp IHS_IV_SS {
    rename o_`y' `y' 
  }
  restore
}

  ********** M8:  YEAR FE / INDIV FE / CONTROL NUMBER OF REFUGEE
foreach outcome of global lm_out {
  *OLS
  reghdfe `outcome' agg_wp ///
          ln_ref $controls i.educ1d i.fteducst i.mteducst ///
          [pw=expan_indiv], ///
          absorb(year indid_2010) ///
          cluster(district_iid) 
  }
  foreach outcome of global lm_out {
  *IV
  preserve
  xi: ivreg2  `outcome' ///
              i.year i.district_iid ///
              ln_ref $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) 

  gen smpl=0
  replace smpl=1 if e(sample)==1

  * Then I partial out all variables
  foreach y in `outcome' agg_wp IHS_IV_SS $controls ln_ref educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2  `outcome' ///
          ln_ref $controls educ1d fteducst mteducst ///
          (agg_wp = IHS_IV_SS) ///
          [pweight = expan_indiv], ///
          cluster(district_iid) robust ///
          first
  drop `outcome' agg_wp IHS_IV_SS $controls ln_ref educ1d fteducst mteducst smpl
  foreach y in `outcome' agg_wp IHS_IV_SS $controls ln_ref educ1d fteducst mteducst  {
    rename o_`y' `y' 
  }
  restore
}







*** Controlling for c.distance_dis_camp##i.year or usig it as an IV
***********************************************************************************
***********************************************************************************
***********************************************************************************

sum distance_dis_camp year
gen d2016=0
replace d2016=1 if year==2016
gen ldistance_dis_camp=log(distance_dis_camp)
gen inter_dist=ldistance_dis_camp*d2016

sum $controls 

xi: ivreg2 ln_wage i.year i.district_iid i.crsectrp i.educ1d i.fteducst i.mteducst age age2 sex hhsize (agg_wp ln_ref= log_IV_SS inter_dist) ///
  if forced_migr==0 & usemp1 == 1 & nationality_cl == 1  [pweight = expan_indiv],  liml cluster(district_iid) ///
                      partial(i.district_iid  i.crsectrp) 
  
  
    





/*
  ********** M1: SIMPLE OLS: 
  xi: reg ln_wage_natives_cond agg_wp ///
          $controls i.educ1d i.fteducst i.mteducst ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)

  ********** M2: SIMPLE OLS: DISTRICT FE
  xi: reg ln_wage_natives_cond agg_wp ///
          i.district_iid ///
          $controls i.educ1d i.fteducst i.mteducst   ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)

  ********** M3: YEAR FE / DISTRICT FE
  *OLS
  xi: reg ln_wage_natives_cond agg_wp ///
          i.district_iid i.year ///
          $controls i.educ1d i.fteducst i.mteducst   ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)
  *IV
  xi: ivreg2  ln_wage_natives_cond ///
              i.year i.district_iid ///
              $controls i.educ1d i.fteducst i.mteducst  ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first 
  estimates table, star(.05 .01 .001) 
  * With equivalent first-stage
  gen smpl=0
  replace smpl=1 if e(sample)==1

  xi: reg agg_wp IHS_IV_SS ///
          i.year i.district_iid ///
          $controls i.educ1d i.fteducst i.mteducst  ///
          if smpl == 1 [pweight = expan_indiv], ///
          cluster(district_iid) robust
  estimates table, star(.05 .01 .001)           
    drop smpl 

  ********** M4: YEAR FE / DISTRICT FE / CONTROL NUMBER OF REFUGEE
  *OLS
  xi: reg ln_wage_natives_cond agg_wp ///
          i.district_iid i.year ///
          ln_ref $controls i.educ1d i.fteducst i.mteducst  ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)
  *IV
  xi: ivreg2  ln_wage_natives_cond ///
              i.year i.district_iid ///
              ln_ref $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first
  estimates table, star(.05 .01 .001)

  * With equivalent first-stage
  gen smpl=0
  replace smpl=1 if e(sample)==1

  xi: reg ln_wage_natives_cond IHS_IV_SS ///
          i.year i.district_iid ///
          ln_ref $controls i.educ1d i.fteducst i.mteducst  ///
          if smpl == 1 [pweight = expan_indiv], ///
          cluster(district_iid) robust
  estimates table, star(.05 .01 .001)           
    drop smpl 

  ********** M5:  YEAR FE / DISTRICT FE / SECOTRAL FE 
  *OLS
  xi: reg ln_wage_natives_cond agg_wp ///
          i.district_iid i.year i.crsectrp ///
          $controls i.educ1d i.fteducst i.mteducst  ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)
  *IV
  xi: ivreg2  ln_wage_natives_cond ///
              i.year i.district_iid i.crsectrp ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)

  * With equivalent first-stage
  gen smpl=0
  replace smpl=1 if e(sample)==1

  xi: reg agg_wp IHS_IV_SS ///
          i.year i.district_iid i.crsectrp ///
          $controls i.educ1d i.fteducst i.mteducst  ///
          if smpl == 1 [pweight = expan_indiv], ///
          cluster(district_iid) robust
  estimates table, star(.05 .01 .001)           
    drop smpl 

  ********** M6:  YEAR FE / DISTRICT FE / SECOTRAL FE / CONTROL NUMBER OF REFUGEE
  *OLS
  xi: reg ln_wage_natives_cond agg_wp ///
          i.district_iid i.year i.crsectrp ///
          ln_ref $controls i.educ1d i.fteducst i.mteducst  ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)
  *IV
  xi: ivreg2  ln_wage_natives_cond ///
              i.year i.district_iid i.crsectrp ///
              ln_ref $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)
  * With equivalent first-stage
  gen smpl=0
  replace smpl=1 if e(sample)==1

  xi: reg agg_wp IHS_IV_SS ///
          i.year i.district_iid i.crsectrp ///
          ln_ref $controls i.educ1d i.fteducst i.mteducst  ///
          if smpl == 1 [pweight = expan_indiv], ///
          cluster(district_iid) robust
  estimates table, star(.05 .01 .001)           
    drop smpl 

  *PANEL STRUCTURE BASED ON THE INDIVIDUAL AND THE YEAR
  xtset, clear 
  xtset indid_2010  year 

  ********** M7: YEAR FE / INDIV FE 
  *OLS
  reghdfe ln_wage_natives_cond agg_wp ///
          $controls i.educ1d i.fteducst i.mteducst ///
          [pw=expan_indiv], ///
          absorb(year indid_2010) ///
          cluster(district_iid) 
  /*
  * Then I partial out all variables
  foreach y in ln_wage agg_wp $controls educ1d fteducst mteducst   {
    reghdfe `y' [pw=expan_indiv], absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  drop ln_wage $controls educ1d fteducst mteducst  agg_wp  
  foreach y in ln_wage $controls educ1d fteducst mteducst  agg_wp  {
    rename o_`y' `y' 
  } 
  reg ln_wage agg_wp  $controls [pw=expan_indiv], cluster(district_iid) robust
  */
  *IV
  preserve
  xi: ivreg2  ln_wage_natives_cond ///
              i.year i.district_iid ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) 

  gen smpl=0
  replace smpl=1 if e(sample)==1
  * Then I partial out all variables
  foreach y in ln_wage_natives_cond $controls agg_wp IHS_IV_SS educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2 ln_wage_natives_cond ///
         $controls educ1d fteducst mteducst ///
         (agg_wp = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         cluster(district_iid) robust ///
         first
  drop ln_wage_natives_cond agg_wp IHS_IV_SS $controls educ1d fteducst mteducst smpl
  foreach y in ln_wage_natives_cond $controls  agg_wp IHS_IV_SS {
    rename o_`y' `y' 
  }
  restore

  ********** M8:  YEAR FE / INDIV FE / CONTROL NUMBER OF REFUGEE
  *OLS
  reghdfe ln_wage_natives_cond agg_wp ///
          ln_ref $controls i.educ1d i.fteducst i.mteducst ///
          [pw=expan_indiv], ///
          absorb(year indid_2010) ///
          cluster(district_iid) 
  *IV
  preserve
  xi: ivreg2  ln_wage_natives_cond ///
              i.year i.district_iid ///
              ln_ref $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) 

  gen smpl=0
  replace smpl=1 if e(sample)==1

  * Then I partial out all variables
  foreach y in ln_wage_natives_cond agg_wp IHS_IV_SS $controls educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2  ln_wage_natives_cond ///
          ln_ref $controls educ1d fteducst mteducst ///
          (agg_wp = IHS_IV_SS) ///
          [pweight = expan_indiv], ///
          cluster(district_iid) robust ///
          first
  drop ln_wage_natives_cond agg_wp IHS_IV_SS $controls  educ1d fteducst mteducst smpl
  foreach y in ln_wage_natives_cond agg_wp IHS_IV_SS $controls {
    rename o_`y' `y' 
  }
  restore
*/



***** FROM STEP TO STORE RESULTS ******



*INDEP
tab q48a_well, m 
tab q48e_bridge, m 
tab q48f_pipes, m 
tab q48g_hall, m 
tab q48h_church, m 
tab q51g_hall_roof_qual, m 
tab q51h_church_roof_qual, m 
tab q50h_church_wall_qual, m 
tab q50g_hall_wall_qual, m

reg IND_infra_access i.cdd_var i.year_survey i.pro_id i.q8_projecttype $controls, cluster(q4_cddid)
estimates store m1, title(Model 1)

sum IND_infra_access if cdd_var == 1
estadd scalar ctrl_mean = r(mean)

reg number_infra i.cdd_var i.year_survey i.pro_id i.q8_projecttype $controls, cluster(q4_cddid)
estimates store m2, title(Model 2)

sum number_infra if cdd_var == 1
estadd scalar ctrl_mean = r(mean)

reg q48a_well i.cdd_var i.year_survey i.pro_id i.q8_projecttype $controls, cluster(q4_cddid)
estimates store m3, title(Model 3)

sum q48a_well if cdd_var == 1
estadd scalar ctrl_mean = r(mean)

reg q48e_bridge i.cdd_var i.year_survey i.pro_id i.q8_projecttype $controls, cluster(q4_cddid)
estimates store m4, title(Model 4)

sum q48e_bridge if cdd_var == 1
estadd scalar ctrl_mean = r(mean)

reg q48f_pipes i.cdd_var i.year_survey i.pro_id i.q8_projecttype $controls, cluster(q4_cddid)
estimates store m5, title(Model 5)

sum q48f_pipes if cdd_var == 1
estadd scalar ctrl_mean = r(mean)

reg q48g_hall i.cdd_var i.year_survey i.pro_id i.q8_projecttype $controls, cluster(q4_cddid)
estimates store m6, title(Model 6)

sum q48g_hall if cdd_var == 1
estadd scalar ctrl_mean = r(mean)

reg q48h_church i.cdd_var i.year_survey i.pro_id i.q8_projecttype $controls, cluster(q4_cddid)
estimates store m7, title(Model 7)

sum q48h_church if cdd_var == 1
estadd scalar ctrl_mean = r(mean)

reg infra_wall_qual i.cdd_var i.year_survey i.pro_id i.q8_projecttype $controls, cluster(q4_cddid)
estimates store m8, title(Model 8)

sum infra_wall_qual if cdd_var == 1
estadd scalar ctrl_mean = r(mean)

reg infra_roof_qual i.cdd_var i.year_survey i.pro_id i.q8_projecttype $controls, cluster(q4_cddid)
estimates store m9, title(Model 9)

sum infra_roof_qual if cdd_var == 1
estadd scalar ctrl_mean = r(mean)

ereturn list
mat list e(b)
estout m1 m2 m3 m4 m5 m6 m7 m8 m9, cells(b(star fmt(3)) se(par fmt(2))) ///
  drop(1.cdd_var ///
    2016.year_survey 2017.year_survey 2018.year_survey 2019.year_survey ///
    1.pro_id 2.pro_id 3.pro_id 4.pro_id 5.pro_id 6.pro_id ///
    1.q8_projecttype 2.q8_projecttype 3.q8_projecttype 4.q8_projecttype ///
    5.q8_projecttype 6.q8_projecttype $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m1 m2 m3 m4 m5 m6 m7 m8 m9 using "$out/reg_01_infra_access.tex", se label replace booktabs ///
mtitles("INDEX" "Number Infra" "Well" "Bridge" "Pipes" "Hall" "Church" "Wall Qual" "Roof Qual") ///
scalars(ctrl_mean)  drop(1.cdd_var ///
    2016.year_survey 2017.year_survey 2018.year_survey 2019.year_survey ///
    1.pro_id 2.pro_id 3.pro_id 4.pro_id 5.pro_id 6.pro_id ///
    1.q8_projecttype 2.q8_projecttype 3.q8_projecttype 4.q8_projecttype ///
    5.q8_projecttype 6.q8_projecttype $controls _cons) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Presence of following infrastructures in village"\label{tab1}) nofloat ///
   stats(N r2_a ctrl_mean, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the community level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m1 m2 m3 m4 m5 m6 m7 m8 m9













