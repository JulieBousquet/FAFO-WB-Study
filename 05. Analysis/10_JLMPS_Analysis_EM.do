
cap log close
clear all
set more off, permanently
set mem 100m

log using "$out_analysis/10_JLMPS_Analysis_EM.log", replace

   ****************************************************************************
   **                            DATA JLMPS                                  **
   **                 REGRESSION ANALYSIS - EXTENSIVE MARGINS                **  
   ** ---------------------------------------------------------------------- **
   ** Type Do :  DATA JLMPS - REGRESSION ANALYSIS - LINEAR PROBABILITY MODEL **
   **                                                                        **
   ** Authors  : Julie Bousquet                                              **
   ****************************************************************************

*adoupdate, update
*which ivprobit, all

*findfile  ivreg2.ado
*adoupdate, update **
*ssc inst ivreg2, replace


/* ALL THE EMPLOYMENT STATUSES
drop if emp_16_miss_10 == 1
drop if emp_10_miss_16 == 1
drop if unemp_16_miss_10 == 1
drop if unemp_10_miss_16 == 1
drop if olf_16_miss_10 == 1
drop if olf_10_miss_16 == 1 
drop if miss_16_10 == 1
drop if olf_10_unemp_16 == 1 
drop if olf_16_unemp_10  == 1 
drop if emp_10_olf_16  == 1 
drop if emp_16_olf_10  == 1 
drop if unemp_10_emp_16  == 1 
drop if unemp_16_emp_10  == 1 
drop if unemp_16_10 == 1
drop if olf_16_10 == 1
*/


* PROBABILITY OF REMAINING EMPLOYED. 
/*
Take ALL employed in 2010 
Take employed, unemp, and OLF in 2016

Drop the 2010 sample since we only care 
about the determinant of individuals who 
stayed employed in 2016. Since all 2010 are 
employed, we can drop them.
And then we compare the EMPLOYED and UNEMP/OLF 
and see whether having a WP has been a determinant
in being employed (=remaining employed)
*/

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 

keep if emp_10_olf_16  == 1 | unemp_16_emp_10 == 1 | emp_16_10 == 1 

***************
*** TRANSFO ***
***************
bys year: tab employed_3cat_3m 
recode employed_olf_3m (2=1) (1=0), gen(bi_employed_olf_3m)
lab var bi_employed_olf_3m "BINARY: 1 empl - 0 unemp&OL - From uswrkstsr1 - mkt def, search req; 3m"
lab def bi_employed_olf_3m 0 "Unemp-OLF" 1 "Empl", modify
lab val bi_employed_olf_3m bi_employed_olf_3m

drop if year == 2010 

ivprobit bi_employed_olf_3m ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ///
         ln_nb_refugees_bygov ///
         ($dep_var = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         vce(cl locality_iid) 
codebook bi_employed_olf_3m, c
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

margins, dydx($dep_var) 


*PROBABILITY OF BECOMING EMPLOYED, WHEN WAS UNEMPLOYED
use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 

keep if unemp_10_emp_16 == 1 | unemp_16_10 == 1 

***************
*** TRANSFO ***
***************
bys year: tab employed_3cat_3m 
recode employed_olf_3m (2=1) (1=0), gen(bi_employed_olf_3m)
lab var bi_employed_olf_3m "BINARY: 1 empl - 0 unemp&OL - From uswrkstsr1 - mkt def, search req; 3m"
lab def bi_employed_olf_3m 0 "Unemp-OLF" 1 "Empl", modify
lab val bi_employed_olf_3m bi_employed_olf_3m

drop if year == 2010 

ivprobit bi_employed_olf_3m ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ///
         ln_nb_refugees_bygov ///
         ($dep_var = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         vce(cl locality_iid) 
codebook bi_employed_olf_3m, c
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

margins, dydx($dep_var) 


*PROBABILITY OF BEING EMPLOYED INTERACTED BY EDUCATION LEVEL
tab bi_education, m 

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 

*keep if emp_10_olf_16  == 1 | unemp_16_emp_10 == 1 | emp_16_10 == 1 

***************
*** TRANSFO ***
***************
bys year: tab employed_3cat_3m 
recode employed_olf_3m (2=1) (1=0), gen(bi_employed_olf_3m)
lab var bi_employed_olf_3m "BINARY: 1 empl - 0 unemp&OL - From uswrkstsr1 - mkt def, search req; 3m"
lab def bi_employed_olf_3m 0 "Unemp-OLF" 1 "Empl", modify
lab val bi_employed_olf_3m bi_employed_olf_3m

gen aggwp_educ =  bi_education#c.agg_wp

xtset, clear 
xtset indid_2010 year

xi: ivprobit bi_employed_olf_3m /// 
         bi_education ///
         i.year i.district_iid ///
         $controls i.fteducst i.mteducst i.ftempst ///
         ln_nb_refugees_bygov ///
         (agg_wp aggwp_educ = IHS_IV_SS c.IHS_IV_SS#bi_education) ///
         [pweight = expan_indiv], ///
         vce(cl locality_iid) 
codebook bi_employed_olf_3m, c
estimates table, k($dep_var aggwp_educ) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var aggwp_educ) 

margins, dydx($dep_var) 












              ***************************************************
                *****     M1: PROBA OF EMPLOYEMENT       *******
              ***************************************************


use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 

drop if emp_16_miss_10 == 1
drop if emp_10_miss_16 == 1
drop if unemp_16_miss_10 == 1
drop if unemp_10_miss_16 == 1
drop if olf_16_miss_10 == 1
drop if olf_10_miss_16 == 1 
drop if miss_16_10 == 1
drop if olf_10_unemp_16 == 1 
drop if olf_16_unemp_10  == 1 


xtset, clear 
xtset indid_2010 year



                    *******************************
                    * EMPLOYED WITH UNEMP AND OLF *
                    *******************************

***************
*** TRANSFO ***
***************
bys year: tab employed_3cat_3m 
recode employed_olf_3m (2=1) (1=0), gen(bi_employed_olf_3m)
lab var bi_employed_olf_3m "BINARY: 1 empl - 0 unemp&OL - From uswrkstsr1 - mkt def, search req; 3m"
lab def bi_employed_olf_3m 0 "Unemp-OLF" 1 "Empl", modify
lab val bi_employed_olf_3m bi_employed_olf_3m

*****************
*** IV PROBIT ***
*****************
xi: ivprobit bi_employed_olf_3m ///
         i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ///
         ln_nb_refugees_bygov ///
         ($dep_var = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         vce(cl locality_iid) 
codebook bi_employed_olf_3m, c
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

margins, dydx($dep_var) 
marginsplot, yline(0)


/*
------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      agg_wp |   .0121604   .0074541     1.63   0.103    -.0024493    .0267702
------------------------------------------------------------------------------
*/

******************
*** IV REGRESS ***
******************
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls bi_employed_olf_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst ///
         i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = IHS_IV_SS) ///
          [pweight = expan_indiv], ///
         vce(cl locality_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

/*
------------------------
    Variable | active   
-------------+----------
      agg_wp |  0.0027  
             |  0.0017  
-------------+----------
           N |   16992  
        r2_a |  0.3734  
------------------------
*/







                    ******************************
                    * EMPLOYED UNEMP WITHOUT OLF *
                    ******************************


***************
*** TRANSFO ***
***************
recode employed_3m (2=1) (1=0), gen(bi_employed_3m)
lab var bi_employed_3m "BINARY: 1 empl - 0 unemp - OLF Miss - From uswrkstsr1 - mkt def, search req; 3m"
lab def bi_employed_3m 0 "Unemp" 1 "Empl", modify
lab val bi_employed_3m bi_employed_3m
 
*****************
*** IV PROBIT ***
*****************
xi: ivprobit bi_employed_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
         ($dep_var = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         vce(cl locality_iid) 
codebook bi_employed_3m, c
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

margins, dydx($dep_var) 
/*
------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      agg_wp |   .0284384   .0126855     2.24   0.025     .0035752    .0533016
------------------------------------------------------------------------------
*/

******************
*** IV REGRESS ***
******************
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls bi_employed_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst ///
         i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = IHS_IV_SS) ///
          [pweight = expan_indiv], ///
         vce(cl locality_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

/*
------------------------
    Variable | active   
-------------+----------
      agg_wp |  0.0065**  
             |  0.0030  
-------------+----------
           N |    6553  
        r2_a |  0.0101  
------------------------
*/





              ***************************************************
                *****  M2: PROBA OF BEING IN OPEN SECTOR   *****
              ***************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
drop if nationality_cl != 1
drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 
keep if emp_16_10 == 1 

xtset, clear 
xtset indid_2010 year 

***************
*** TRANSFO ***
***************
bys year: tab wp_industry_jlmps_3m 
lab def wp_industry_jlmps_3m 0 "Close sector" 1 "Open Sector", modify
lab val wp_industry_jlmps_3m wp_industry_jlmps_3m

*****************
*** IV PROBIT ***
*****************
*drop if year == 2010 

ivprobit wp_industry_jlmps_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
         ($dep_var = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         vce(cl locality_iid) 
codebook wp_industry_jlmps_3m, c
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

margins , dydx($dep_var) 

/*
------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      agg_wp |   .0009102   .0086361     0.11   0.916    -.0160162    .0178366
------------------------------------------------------------------------------
*/

******************
*** IV REGRESS ***
******************
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls wp_industry_jlmps_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst ///
         i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = IHS_IV_SS) ///
          [pweight = expan_indiv], ///
         vce(cl locality_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

/*
------------------------
    Variable | active   
-------------+----------
      agg_wp |  0.0010  
             |  0.0024  
-------------+----------
           N |    3500  
        r2_a |  0.0821  
------------------------
*/


              ***************************************************
               *****  M3: PROBA OF BEING IN FORMAL SECTOR  *****
              ***************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
drop if nationality_cl != 1
drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 

egen indiv_2y = count(indid_2010), by(indid_2010)
tab indiv_2y
drop if indiv_2y == 1
keep if emp_16_10 == 1 

*keep formally empl 2010 
*gen flag  = 1 if bi_formal == 1 & year == 2010

*multinomial analysis with empl formal, informal, unemp
* SET THE PANEL STRUCTURE
xtset, clear 
xtset indid_2010 year 

***************
*** TRANSFO ***
***************
tab empl_form_10_info_16, m
tab empl_form_16_info_10, m
tab empl_form_10_16, m
tab empl_info_10_16, m
tab empl_form_10_unemp_16, m
tab empl_info_10_unemp_16, m

*****************
*** IV PROBIT ***
*****************
*drop if year == 2010 
ivprobit bi_formal i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
         ($dep_var = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         vce(cl locality_iid)  
codebook bi_formal, c
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

margins, dydx($dep_var) 
/*
------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      agg_wp |  -.0076658   .0121725    -0.63   0.529    -.0315235    .0161919
------------------------------------------------------------------------------

*/

******************
*** IV REGRESS ***
******************
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls bi_formal i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst ///
         i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = IHS_IV_SS) ///
          [pweight = expan_indiv], ///
         vce(cl locality_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

/*
------------------------
    Variable | active   
-------------+----------
      agg_wp | -0.0037  
             |  0.0032  
-------------+----------
           N |    3513  
        r2_a |  0.1762  
------------------------
*/








/*


    *******************************************
    *******************************************
    **** TRYING DIFFERENT MODELS **************
    *******************************************
    *******************************************

*** 2SLS - Sep reg
xi: reg $dep_var IHS_IV_SS i.year i.district_iid ///
$controls i.educ1d i.fteducst i.mteducst ///
[pweight = expan_indiv] , vce(cl locality_iid)
predict IV_hat, xb

xi: probit wp_industry_jlmps_3m IV_hat i.year i.district_iid ///
$controls i.educ1d i.fteducst i.mteducst ///
[pweight = expan_indiv] ///
, vce(cl locality_iid)
*IV_hat |  -.0024044   .0088933    -0.27   0.787    -.0198349    .0150262
drop IV_hat

*** IV Probit
*IV Probit predicted probabilities are restricted to lie between zero and one
xi: ivprobit wp_industry_jlmps_3m  i.year ///
 i.district_iid $controls i.educ1d i.fteducst i.mteducst ///
 ($dep_var = IHS_IV_SS) ///
 [pweight = expan_indiv] /// 
 ,vce(cl locality_iid)
*agg_wp |  -.0029554    .008754    -0.34   0.736     -.020113    .0142022
margins, dydx($dep_var) 

*IV regress
*The LPM version
** I WANT THIS !
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls wp_industry_jlmps_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst ///
         i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = IHS_IV_SS) ///
          [pweight = expan_indiv], ///
         vce(cl locality_iid)

*** CGM Logit
xi: reg $dep_var IHS_IV_SS i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst ///
         i.ftempst ln_nb_refugees_bygov ///
         [pweight = expan_indiv], ///
         vce(cl locality_iid)
predict IV_hat, xb

xi: cgmlogit wp_industry_jlmps_3m IV_hat i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
         [pweight = expan_indiv], ///
         cluster(locality_iid) 
margins , dydx(*) 
drop IV_hat

* IV_hat |    .004306   .0171163     0.25   0.801    -.0292414    .0378533

*/


