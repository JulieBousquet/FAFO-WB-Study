
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
drop if olf_10_unemp_16 == 1 
drop if olf_16_unemp_10  == 1 

/* I keep only the ones that are changing of jobs status? Or 
even the ones that did not change of status ? 
so i would keep in addition the ones who stayed unemployed or olf
but we do not care about the ones that did change from olf to unemp
drop if emp_10_olf_16  == 1 
drop if emp_16_olf_10  == 1 
drop if unemp_10_emp_16  == 1 
drop if unemp_16_emp_10  == 1 

drop if unemp_16_10 == 1
drop if olf_16_10 == 1
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

******************
* EMPLOYED 3 CAT *
******************

bys year: tab employed_3cat_3m 

recode employed_olf_3m (2=1) (1=0), gen(bi_employed_olf_3m)
lab var bi_employed_olf_3m "BINARY: 1 empl - 0 unemp&OL - From uswrkstsr1 - mkt def, search req; 3m"
lab def bi_employed_olf_3m 0 "Unemp-OLF" 1 "Empl", modify
lab val bi_employed_olf_3m bi_employed_olf_3m

recode employed_3m (2=1) (1=0), gen(bi_employed_3m)
lab var bi_employed_3m "BINARY: 1 empl - 0 unemp - OLF Miss - From uswrkstsr1 - mkt def, search req; 3m"
lab def bi_employed_3m 0 "Unemp" 1 "Empl", modify
lab val bi_employed_3m bi_employed_3m
 

xi: ivprobit bi_employed_olf_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
         ($dep_var = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         vce(cl district_iid) 
codebook bi_employed_olf_3m, c
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

margins, dydx($dep_var) predict(pr)

/*marginsplot , xlab(0 1) plotopts(lw(thick)) ///
     ytitle("") ciopts(lc(gray) lw(thin)) ///
     plot1opts(lc(cranberry) lp(solid) ///
     mlc(cranberry) ms(huge) mfc(white)) ///
     title("`$dep_var'") name(`$dep_var'_btsp, replace) 
*/        

/*
------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      agg_wp |   .0005639   .0017444     0.32   0.746     -.002855    .0039829
------------------------------------------------------------------------------

*/

*IV regress
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls bi_employed_olf_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst ///
         i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = IHS_IV_SS) ///
          [pweight = expan_indiv], ///
         vce(cl district_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

******************
* EMPLOYED 3 CAT *
******************

xi: ivprobit bi_employed_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
         ($dep_var = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         vce(cl district_iid) 
codebook bi_employed_3m, c
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

margins, dydx($dep_var) predict(pr)

/*
------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      agg_wp |   .0001628   .0040696     0.04   0.968    -.0078134     .008139
------------------------------------------------------------------------------

*/

    * With equivalent first-stage
    gen smpl=0
    replace smpl=1 if e(sample)==1

    reg $dep_var IHS_IV_SS ///
            i.year i.district_iid ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            if smpl == 1 [pweight = expan_indiv], ///
            cluster(district_iid) robust
    estimates table, k(IHS_IV_SS) star(.1 .05 .01)    
    estimates store mIV_`outcome', title(Model `outcome')

*IV regress
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls bi_employed_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst ///
         i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = IHS_IV_SS) ///
          [pweight = expan_indiv], ///
         vce(cl district_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 


              ***************************************************
                *****  M2: PROBA OF BEING IN OPEN SECTOR   *****
              ***************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year 
drop if nationality_cl != 1

*Keep only working age pop? 15-64 ? As defined by the ERF
drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

*EMPLOYED ONLY (EITHER IN 2010 OR IN 2016
keep if emp_16_10 == 1 

* SET THE PANEL STRUCTURE
xtset, clear 
xtset indid_2010 year 


bys year: tab wp_industry_jlmps_3m 
lab def wp_industry_jlmps_3m 0 "Close sector" 1 "Open Sector", modify
lab val wp_industry_jlmps_3m wp_industry_jlmps_3m

xi: ivprobit wp_industry_jlmps_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
         ($dep_var = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         vce(cl district_iid) 
codebook wp_industry_jlmps_3m, c
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

margins , dydx($dep_var) predict(pr)

/*
------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      agg_wp |   .0010768   .0026969     0.40   0.690     -.004209    .0063626
------------------------------------------------------------------------------
*/

*IV regress
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls wp_industry_jlmps_3m i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst ///
         i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = IHS_IV_SS) ///
          [pweight = expan_indiv], ///
         vce(cl district_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 



              ***************************************************
                *****  M2: PROBA OF BEING IN FORMAL SECTOR   *****
              ***************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year 
drop if nationality_cl != 1

*Keep only working age pop? 15-64 ? As defined by the ERF
drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

*EMPLOYED ONLY (EITHER IN 2010 OR IN 2016
*keep if emp_16_10 == 1 

* SET THE PANEL STRUCTURE
xtset, clear 
xtset indid_2010 year 

bys year: tab informal , nol
recode informal (1=0) (0=1), gen(bi_formal)
lab def bi_formal 1 "Formal" 0 "Informal", modify
lab val bi_formal bi_formal
lab var bi_formal "Formal Employment - 1 Formal 0 Informal"
bys year: tab bi_formal , nol

xi: ivprobit bi_formal i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
         ($dep_var = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         vce(cl district_iid)  
codebook bi_formal, c
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

margins, dydx($dep_var) predict(pr)

/*
------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      agg_wp |   .0001269   .0022347     0.06   0.955    -.0042531     .004507
------------------------------------------------------------------------------
*/

*IV regress
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls bi_formal i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst ///
         i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = IHS_IV_SS) ///
          [pweight = expan_indiv], ///
         vce(cl district_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

/*
---------------------------
    Variable |   active    
-------------+-------------
      agg_wp | -0.0018     
---------------------------
*/

    *******************************************
    *******************************************
    **** TRYING DIFFERENT MODELS **************
    *******************************************
    *******************************************

*** 2SLS - Sep reg
xi: reg $dep_var IHS_IV_SS i.year i.district_iid ///
$controls i.educ1d i.fteducst i.mteducst ///
[pweight = expan_indiv] , vce(cl district_iid)
predict IV_hat, xb

xi: probit wp_industry_jlmps_3m IV_hat i.year i.district_iid ///
$controls i.educ1d i.fteducst i.mteducst ///
[pweight = expan_indiv] ///
, vce(cl district_iid)
*IV_hat |  -.0024044   .0088933    -0.27   0.787    -.0198349    .0150262
drop IV_hat

*** IV Probit
*IV Probit predicted probabilities are restricted to lie between zero and one
xi: ivprobit wp_industry_jlmps_3m  i.year ///
 i.district_iid $controls i.educ1d i.fteducst i.mteducst ///
 ($dep_var = IHS_IV_SS) ///
 [pweight = expan_indiv] /// 
 ,vce(cl district_iid)
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
         vce(cl district_iid)

*** CGM Logit
xi: reg $dep_var IHS_IV_SS i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst ///
         i.ftempst ln_nb_refugees_bygov ///
         [pweight = expan_indiv], ///
         vce(cl district_iid)
predict IV_hat, xb

xi: cgmlogit wp_industry_jlmps_3m IV_hat i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
         [pweight = expan_indiv], ///
         cluster(district_iid) 
margins , dydx(*) 
drop IV_hat

* IV_hat |    .004306   .0171163     0.25   0.801    -.0292414    .0378533



