

cap log close
clear all
set more off, permanently
set mem 100m

log using "$out_analysis/07_Heterogenous.log", replace

   ****************************************************************************
   **                            DATA JLMPS                                  **
   **                 HETEROGENOUS ANALYSIS - V2 FOR TRIALS                  **  
   ** ---------------------------------------------------------------------- **
   ** Type Do  :  DATA JLMPS HETEROGENOUS ANALYSIS REGRESSION                **
   **                                                                        **
   ** Authors  : Julie Bousquet                                              **
   ****************************************************************************


use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

*adoupdate, update
*findfile  ivreg2.ado
*adoupdate, update **
*ssc inst ivreg2, replace


***********************************************************************
**DEFINING THE SAMPLE *************************************************
***********************************************************************


**************
* JORDANIANS *
**************

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

*18744

***************
* EMPLOYED *
*************** 

/*
Number of outcomes among the employed,

[NB: We undertook sensitivity analysis as to whether analyzing these outcomes
unconditional on employment, rather than among the employed, changed our
results; it did not lead to substantive changes (results available from authors on
request).]*/


*EMPLOYED ONLY (EITHER IN 2010 OR IN 2010)
/*
drop if miss_16_10 == 1
drop if unemp_16_10 == 1
drop if olf_16_10 == 1
drop if emp_16_miss_10 == 1
drop if emp_10_miss_16 == 1
drop if unemp_16_miss_10 == 1
drop if unemp_10_miss_16 == 1
drop if olf_16_miss_10 == 1
drop if olf_10_miss_16 == 1 
*/
keep if emp_16_10 == 1 

tab educ1d 
tab fteducst 
tab mteducst
tab ftempst 
tab ln_nb_refugees_bygov 
tab age  // Age
tab age2 // Age square
tab ln_distance_dis_camp //  LOG Distance (km) between JORD districts and ZAATARI CAMP in 2016
tab gender //  Gender - 1 Male 0 Female
tab hhsize //  Total o. of Individuals in the Household



                                  ************
                                  *   PANEL  *
                                  ************

* SET THE PANEL STRUCTURE
xtset, clear 
*xtset year
xtset indid_2010 year 


** HETEROG 

***************
* WP INDUSTRY *
***************

preserve 
/*
Number of outcomes among the employed,

[NB: We undertook sensitivity analysis as to whether analyzing these outcomes
unconditional on employment, rather than among the employed, changed our
results; it did not lead to substantive changes (results available from authors on
request).]*/

foreach globals of global globals_list {
  foreach outcome of global `globals'  {  
    gen cons=1
    qui xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
       (c.$dep_var#i.wp_industry_jlmps_3m = c.IHS_IV_SS#i.wp_industry_jlmps_3m) ///
       c.cons#i.wp_industry_jlmps_3m ///       
       [pweight = expan_indiv], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k(wp_industry_jlmps_3m#c.$dep_var) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(wp_industry_jlmps_3m#c.$dep_var) 
    drop cons
  } 
}
restore 

*EMPLOYMENT 

preserve

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year 
drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

drop if miss_16_10 == 1

  foreach outcome of global outcome_var_empl  {  
    gen cons=1
    qui xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
       (c.$dep_var#i.wp_industry_jlmps_3m = c.IHS_IV_SS#i.wp_industry_jlmps_3m) ///
       c.cons#i.wp_industry_jlmps_3m ///       
       [pweight = expan_indiv], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k(wp_industry_jlmps_3m#c.$dep_var) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(wp_industry_jlmps_3m#c.$dep_var) 
    drop cons
  } 

restore 



**********
* GENDER *
**********

preserve 

codebook gender

foreach globals of global globals_list {
  foreach outcome of global `globals'  {  
    gen cons=1
    qui xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
       (c.$dep_var#i.gender = c.IHS_IV_SS#i.gender) ///
       c.cons#i.gender ///       
       [pweight = expan_indiv], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k(gender#c.$dep_var) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(gender#c.$dep_var) 
    drop cons
  } 
}

restore

*EMPLOYMENT 

preserve

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year 
drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

drop if miss_16_10 == 1

  foreach outcome of global outcome_var_empl {  
    gen cons=1
    qui xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
       (c.$dep_var#i.gender = c.IHS_IV_SS#i.gender) ///
       c.cons#i.gender ///       
       [pweight = expan_indiv], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k(gender#c.$dep_var) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(gender#c.$dep_var) 
    drop cons
  } 

restore 


*********************
* EDUCATION *
*************

tab bi_education, m 

preserve 

codebook bi_education

foreach globals of global globals_list {
  foreach outcome of global `globals'  {  
    gen cons=1
    qui xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       $controls  i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
       (c.$dep_var#i.bi_education = c.IHS_IV_SS#i.bi_education) ///
       c.cons#i.bi_education ///       
       [pweight = expan_indiv], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k(bi_education#c.$dep_var) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(bi_education#c.$dep_var) 
    drop cons
  } 
}

restore

*EMPLOYMENT 

preserve 

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year 
drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

drop if miss_16_10 == 1

  foreach outcome of global outcome_var_empl {  
    gen cons=1
    qui xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       $controls  i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
       (c.$dep_var#i.bi_education = c.IHS_IV_SS#i.bi_education) ///
       c.cons#i.bi_education ///       
       [pweight = expan_indiv], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k(bi_education#c.$dep_var) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(bi_education#c.$dep_var) 
    drop cons
  } 

restore


*********************
* EDUCATION *
*************

tab informal, m 


preserve 

codebook informal

foreach globals of global globals_list {
  foreach outcome of global `globals'  {  
    gen cons=1
    qui xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       $controls  i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
       (c.$dep_var#i.informal = c.IHS_IV_SS#i.informal) ///
       c.cons#i.informal ///       
       [pweight = expan_indiv], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k(informal#c.$dep_var) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(informal#c.$dep_var) 
    drop cons
  } 
}

restore

*EMPLOYMENT 

preserve 

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year 
drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

drop if miss_16_10 == 1

  foreach outcome of global outcome_var_empl {  
    gen cons=1
    qui xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       $controls  i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
       (c.$dep_var#i.informal = c.IHS_IV_SS#i.informal) ///
       c.cons#i.informal ///       
       [pweight = expan_indiv], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k(informal#c.$dep_var) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(informal#c.$dep_var) 
    drop cons
  } 

restore

log close
