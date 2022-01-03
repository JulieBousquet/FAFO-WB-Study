
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

                *************************************
                * PROBABILITY OF REMAINING EMPLOYED *
                *************************************
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
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 

*KEEP ALL EMP 2010 AND OLF/EMP/UNEMP 2016
keep if emp_10_olf_16  == 1 | unemp_16_emp_10 == 1 | emp_16_10 == 1 

***************
*** TRANSFO ***
***************
bys year: tab employed_3cat_3m 
recode employed_olf_3m (2=1) (1=0), gen(bi_employed_olf_3m)
lab var bi_employed_olf_3m "BINARY: 1 empl - 0 unemp&OLF - From uswrkstsr1 - mkt def, search req; 3m"
lab def bi_employed_olf_3m 0 "Unemp-OLF" 1 "Empl", modify
lab val bi_employed_olf_3m bi_employed_olf_3m

drop if year == 2010 
/*
ivprobit bi_employed_olf_3m ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ///
         ($dep_var = ln_IV_SS) ///
         [pweight = expan_indiv], ///
         vce(cl locality_iid) 
codebook bi_employed_olf_3m, c
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

margins, dydx($dep_var) 

*/
******************
*** IV REGRESS ***
******************
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls bi_employed_olf_3m  ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = $IV_var) ///
          [pweight = panel_wt_10_16], ///
         vce(cl district_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
margins, dydx($dep_var) 


                *********************************************************
                * PROBABILITY OF BECOMING EMPLOYED, WHEN WAS UNEMPLOYED *
                *********************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 

*KEEP ALL UNEMP 2010 & UNEMP/EMP 2016
keep if unemp_10_emp_16 == 1 | unemp_16_10 == 1 

***************
*** TRANSFO ***
***************
bys year: tab employed_3cat_3m 
recode employed_olf_3m (2=1) (1=0), gen(bi_employed_olf_3m)
lab var bi_employed_olf_3m "BINARY: 1 empl - 0 unemp&OLF - From uswrkstsr1 - mkt def, search req; 3m"
lab def bi_employed_olf_3m 0 "Unemp-OLF" 1 "Empl", modify
lab val bi_employed_olf_3m bi_employed_olf_3m

drop if year == 2010 

******************
*** IV REGRESS ***
******************
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls bi_employed_olf_3m  ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = $IV_var) ///
          [pweight = panel_wt_10_16], ///
         vce(cl district_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
margins, dydx($dep_var) 



        *************************************************************
        * PROBABILITY OF BECOMING FORMALY EMPLOYED [FROM INFORMALY] *
        *************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 

*KEEP ALL Informally in 2010 & formal/info2016
keep if empl_info_10_16 == 1 | ///
        empl_form_16_info_10 == 1

***************
*** TRANSFO ***
***************
bys year: tab formal, nol

drop if year == 2010 

******************
*** IV REGRESS ***
******************
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls formal  ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = $IV_var) ///
          [pweight = panel_wt_10_16], ///
         vce(cl district_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
margins, dydx($dep_var) 





        ****************************************************************
        * PROBABILITY OF BECOMING UNEMPLOYED [FROM INFORMALY EMPLOYED] *
        ****************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 


*KEEP ALL Informally in 2010 & unemp/info2016
keep if empl_info_10_unemp_16 == 1 | ///
        empl_info_10_16 == 1 

***************
*** TRANSFO ***
***************
bys year: tab employed_3cat_3m 
drop if year == 2010 

recode employed_olf_3m (2=0) (0=1), gen(bi_employed_olf_3m_rec)
bys year: tab bi_employed_olf_3m_rec 
lab var bi_employed_olf_3m_rec "BINARY: 0 empl - 1 unemp&OLF - From uswrkstsr1 - mkt def, search req; 3m"
lab def bi_employed_olf_3m_rec 1 "Unemp-OLF" 0 "Empl", modify
lab val bi_employed_olf_3m_rec bi_employed_olf_3m_rec
bys year: tab bi_employed_olf_3m_rec 

******************
*** IV REGRESS ***
******************
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls bi_employed_olf_3m_rec  ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = $IV_var) ///
          [pweight = panel_wt_10_16], ///
         vce(cl district_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
margins, dydx($dep_var) 





        **********************************************************************
        * PROBABILITY OF BECOMING INFORMALY EMPLOYED [FROM FORMALY EMPLOYED] *
        **********************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 


*KEEP ALL Formally in 2010 & formal/info2016
keep if empl_form_10_info_16 == 1 | ///
        empl_form_10_16 == 1 


***************
*** TRANSFO ***
***************
bys year: tab formal, nol

drop if year == 2010 

******************
*** IV REGRESS ***
******************
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls formal  ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = $IV_var) ///
          [pweight = panel_wt_10_16], ///
         vce(cl district_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
margins, dydx($dep_var) 




        **************************************************************
        * PROBABILITY OF BECOMING UNEMPLOYED [FROM FORMALY EMPLOYED] *
        **************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 


*KEEP ALL Formally in 2010 & formal/unemp2016
keep if empl_form_10_unemp_16 == 1 | ///
        empl_form_10_16 == 1 

***************
*** TRANSFO ***
***************
bys year: tab formal, nol
drop if year == 2010 

******************
*** IV REGRESS ***
******************
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls formal  ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = $IV_var) ///
          [pweight = panel_wt_10_16], ///
         vce(cl district_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
margins, dydx($dep_var) 




            **********************************************
            * PROBA OF BEING IN CLOSED SECTOR [FROM OPEN] *
            **********************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 

tab open_10_16, m
tab close_10_16, m
tab open_10_close_16, m
tab close_10_open_16, m

* KEEP ALL CLOSE IN 10 AND OPEN/CLOSE 2016
keep if open_10_16 == 1 | open_10_close_16 == 1 


***************
*** TRANSFO ***
***************
bys year: tab wp_industry_jlmps_3m 
drop if year == 2010 

bys year: tab wp_industry_jlmps_3m 
recode wp_industry_jlmps_3m (1=0) (0=1)
lab def wp_indus_em 1 "Close" 0 "Open", modify
lab val wp_industry_jlmps_3m wp_indus_em
bys year: tab wp_industry_jlmps_3m 

******************
*** IV REGRESS ***
******************
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls wp_industry_jlmps_3m  ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = $IV_var) ///
          [pweight = panel_wt_10_16], ///
         vce(cl district_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
margins, dydx($dep_var) 


           **********************************************
            * PROBA OF GOING TO THE PUBLIC SECTOR [FROM PRIVATE] *
            **********************************************


use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

**************
*** SAMPLE ***
**************
tab nationality_cl year 
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 

tab private_10_16, m
tab public_10_16, m
tab private_10_public_16, m
tab public_10_private_16, m

* KEEP ALL PUBLIC IN 10 AND PUBLIC/PRIVATE 2016
keep if private_10_16 == 1 | private_10_public_16 == 1 

***************
*** TRANSFO ***
***************
bys year: tab private 
drop if year == 2010 
codebook private

bys year: tab private 
recode private (1=0) (0=1)
lab def private_em 1 "Public" 0 "Private", modify
lab val private private_em
bys year: tab private 


******************
*** IV REGRESS ***
******************
*The LPM version
*LPM predicted probabilities are NOT restricted to lie between zero and one
xi: ivregress 2sls private  ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
          ($dep_var = $IV_var) ///
          [pweight = panel_wt_10_16], ///
         vce(cl district_iid)
estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
margins, dydx($dep_var) 



        ****************************
        ***************************************************************
       ***************************************************************
        ***************************************************************
       ***************************************************************
        *  *
        ***************************************************************
       ***************************************************************
        ***************************************************************
       ***************************************************************
        ***************************************************************














/*


    *******************************************
    *******************************************
    **** TRYING DIFFERENT MODELS **************
    *******************************************
    *******************************************

*** 2SLS - Sep reg
xi: reg $dep_var ln_IV_SS i.year i.district_iid ///
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
 ($dep_var = ln_IV_SS) ///
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
         i.ftempst  ///
          ($dep_var = ln_IV_SS) ///
          [pweight = expan_indiv], ///
         vce(cl locality_iid)

*** CGM Logit
xi: reg $dep_var ln_IV_SS i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst ///
         i.ftempst  ///
         [pweight = expan_indiv], ///
         vce(cl locality_iid)
predict IV_hat, xb

xi: cgmlogit wp_industry_jlmps_3m IV_hat i.year i.district_iid ///
         $controls i.educ1d i.fteducst i.mteducst i.ftempst  ///
         [pweight = expan_indiv], ///
         cluster(locality_iid) 
margins , dydx(*) 
drop IV_hat

* IV_hat |    .004306   .0171163     0.25   0.801    -.0292414    .0378533

*/


