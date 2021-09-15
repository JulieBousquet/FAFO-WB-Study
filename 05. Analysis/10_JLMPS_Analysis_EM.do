
cap log close
clear all
set more off, permanently
set mem 100m

log using "$out_analysis/10_JLMPS_Analysis_EM.log", replace

   ****************************************************************************
   **                            DATA JLMPS                                  **
   **                 REGRESSION ANALYSIS - EXTENSIVE MARGINS                **  
   ** ---------------------------------------------------------------------- **
   ** Type Do  :  DATA JLMPS   REGRESSION ANALYSIS                           **
   **                                                                        **
   ** Authors  : Julie Bousquet                                              **
   ****************************************************************************


use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

*adoupdate, update
*findfile  ivreg2.ado
*adoupdate, update **
*ssc inst ivreg2, replace



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


*EMPLOYED ONLY (EITHER IN 2010 OR IN 2016
drop if emp_16_miss_10 == 1
drop if emp_10_miss_16 == 1
drop if unemp_16_miss_10 == 1
drop if unemp_10_miss_16 == 1
drop if olf_16_miss_10 == 1
drop if olf_10_miss_16 == 1 

drop if miss_16_10 == 1
drop if unemp_16_10 == 1
drop if olf_16_10 == 1
drop if olf_10_unemp_16 == 1 
drop if olf_16_unemp_10  == 1 

/*
drop if emp_10_olf_16  == 1 
drop if emp_16_olf_10  == 1 
drop if unemp_10_emp_16  == 1 
drop if unemp_16_emp_10  == 1 
*/

*keep if emp_16_10 == 1 

                                  ************
                                  *   PANEL  *
                                  ************

* SET THE PANEL STRUCTURE
xtset, clear 
*xtset year
xtset indid_2010 year 



                                  ************
                                  *REGRESSION*
                                  ************

*LINEAR PROBABILITY MODEL 

              ***************************************************
                *****     M1: PROBA OF EMPLOYEMENT       *******
              ***************************************************

bys year: tab employed_3cat_3m 


reg $dep_var IHS_IV_SS $controls educ1d fteducst mteducst ftempst ln_nb_refugees_bygov
predict pred_agg_wp 

cgmlogit try pred_agg_wp year district_iid ///
         $controls educ1d fteducst mteducst ftempst ln_nb_refugees_bygov ///
         , cluster(district_iid)
 

recode employed_olf_3m (2=1) (1=0), gen(bi_employed_olf_3m)
lab var bi_employed_olf_3m "BINARY: 1 empl - 0 unemp&OL - From uswrkstsr1 - mkt def, search req; 3m"
recode employed_3m (2=1) (1=0), gen(bi_employed_3m)
lab var bi_employed_3m "BINARY: 1 empl - 0 unemp - OLF Miss - From uswrkstsr1 - mkt def, search req; 3m"
 



 xi: ivprobit bi_employed_olf_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
         ($dep_var = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         vce(cl district_iid) 
codebook employed_olf_3m, c
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

tab employed_3m 
tab employed_3cat_3m 
bys year : tab employed_olf_3m $dep_var

    * With equivalent first-stage
    gen smpl=0
    replace smpl=1 if e(sample)==1

    reg $dep_var IHS_IV_SS ///
            i.year i.district_iid ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            if smpl == 1 [pweight = expan_indiv], ///
            cluster(district_iid) robust
    predict 


gen

