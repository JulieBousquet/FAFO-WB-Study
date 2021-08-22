

cap log close
clear all
set more off, permanently
set mem 100m

log using "$out_JLMPS/02_Analysis_select_models.log", replace

   ****************************************************************************
   **                            DATA JLMPS                                  **
   **                 REGRESSION ANALYSIS - V2 FOR TRIALS                    **  
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


*EMPLOYED ONLY (EITHER IN 2010 OR IN 2010)
drop if miss_16_10 == 1
*drop if unemp_16_10 == 1
*drop if olf_16_10 == 1
drop if emp_16_miss_10 == 1
drop if emp_10_miss_16 == 1
drop if unemp_16_miss_10 == 1
drop if unemp_10_miss_16 == 1
drop if olf_16_miss_10 == 1
drop if olf_10_miss_16 == 1 



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

              ***************************************************
                *****         M1: SIMPLE OLS:           *******
              ***************************************************

**********************
********* OLS ********
**********************

foreach globals of global globals_list {
  foreach outcome of global `globals' {
    qui xi: reg `outcome' $dep_var ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            [pweight = expan_indiv],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.05 .01 .001) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
  }
}


            ***********************************************************************
              ***** M2: YEAR FE / DISTRICT FE / CONTROL NUMBER OF REFUGEE   *****
            ***********************************************************************

**********************
********* OLS ********
**********************

foreach globals of global globals_list {
  foreach outcome of global `globals' {
    qui xi: reg `outcome' $dep_var ///
            i.district_iid i.year ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            [pweight = expan_indiv],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.05 .01 .001) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

  }
}

**********************
********* IV *********
**********************

foreach globals of global globals_list {
  foreach outcome of global `globals' {
    qui xi: ivreg2  `outcome' ///
                i.year i.district_iid ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                ($dep_var = IHS_IV_SS) ///
                [pweight = expan_indiv], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var) star(.05 .01 .001) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

    * With equivalent first-stage
    gen smpl=0
    replace smpl=1 if e(sample)==1

    qui xi: reg $dep_var IHS_IV_SS ///
            i.year i.district_iid ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            if smpl == 1 [pweight = expan_indiv], ///
            cluster(district_iid) robust
    estimates table, k(IHS_IV_SS) star(.05 .01 .001)           
    drop smpl 
  }
}

******************************************************************************************
  *****    M3:  YEAR FE / DISTRICT FE / SECOTRAL FE / CONTROL NUMBER OF REFUGEE   ******
******************************************************************************************

**********************
********* OLS ********
**********************

foreach globals of global globals_list {
  foreach outcome of global `globals' {
    qui xi: reg `outcome' $dep_var ///
            i.district_iid i.year i.crsectrp ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            [pweight = expan_indiv],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.05 .01 .001)
  }
}

**********************
********* IV *********
**********************

foreach globals of global globals_list {
  foreach outcome of global `globals' {
    qui xi: ivreg2  `outcome' ///
                i.year i.district_iid i.crsectrp ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                ($dep_var = IHS_IV_SS) ///
                [pweight = expan_indiv], ///
                cluster(district_iid) ///
                partial(i.district_iid i.crsectrp) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var) star(.05 .01 .001) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

    * With equivalent first-stage
    gen smpl=0
    replace smpl=1 if e(sample)==1

    qui xi: reg $dep_var IHS_IV_SS ///
            i.year i.district_iid i.crsectrp ///
            $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            if smpl == 1 [pweight = expan_indiv], ///
            cluster(district_iid) robust
    estimates table,  k(IHS_IV_SS) star(.05 .01 .001)           
    drop smpl 
  }
}

          ***********************************************************************
            *****    M4:  YEAR FE / INDIV FE / CONTROL NUMBER OF REFUGEE    *****
          ***********************************************************************

**********************
********* OLS ********
**********************

preserve
foreach globals of global globals_list {
  foreach outcome_l1 of global `globals' {
      foreach outcome_l2 of global  `globals' {
       qui reghdfe `outcome_l2' $dep_var ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                [pw=expan_indiv], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      }
        * Then I partial out all variables
      foreach y in `outcome_l1' $dep_var $controls  educ1d fteducst mteducst ftempst ln_nb_refugees_bygov {
        qui reghdfe `y' [pw=expan_indiv], absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      drop `outcome_l1' $controls  educ1d fteducst mteducst ftempst ln_nb_refugees_bygov $dep_var  
      foreach y in `outcome_l1' $controls  educ1d fteducst mteducst ftempst ln_nb_refugees_bygov $dep_var  {
        rename o_`y' `y' 
      } 
      qui reg `outcome_l1' $dep_var $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov [pw=expan_indiv], cluster(district_iid) robust
      codebook `outcome_l1', c
      estimates table,  k($dep_var) star(.05 .01 .001)           
    }
  }
restore


**********************
********* IV *********
**********************

preserve
foreach globals of global globals_list {
  foreach outcome_l1 of global `globals'  {     
      codebook `outcome_l1', c
      qui xi: ivreg2 `outcome_l1' ///
                    i.year i.district_iid ///
                    $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                    ($dep_var = IHS_IV_SS) ///
                    [pweight = expan_indiv], ///
                    cluster(district_iid) robust ///
                    partial(i.district_iid) 

        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
        foreach y in `outcome_l1' $controls $dep_var IHS_IV_SS educ1d fteducst mteducst ftempst ln_nb_refugees_bygov {
          qui reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
          qui rename `y' o_`y'
          qui rename `y'_c2wr `y'
        }
        qui ivreg2 `outcome_l1' ///
               $controls educ1d fteducst mteducst ftempst ln_nb_refugees_bygov ///
               ($dep_var = IHS_IV_SS) ///
               [pweight = expan_indiv], ///
               cluster(district_iid) robust ///
               first 
      estimates table, k($dep_var) star(.05 .01 .001) b(%7.4f) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
        qui drop `outcome_l1' $dep_var IHS_IV_SS $controls educ1d fteducst mteducst ftempst smpl ln_nb_refugees_bygov
        foreach y in `outcome_l1' $controls  $dep_var IHS_IV_SS educ1d fteducst mteducst ftempst ln_nb_refugees_bygov  {
          qui rename o_`y' `y' 
        }
    }
  }
restore                





















************************************************
// ANALYSIS EMPLOYED / UNEMPLOYED USING MODEL 4 
************************************************

            ***********************************************************************
              ***** M2: YEAR FE / DISTRICT FE / CONTROL NUMBER OF REFUGEE   *****
            ***********************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year 
drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

drop if miss_16_10 == 1
*drop if emp_16_miss_10 == 1
*drop if emp_10_miss_16 == 1
*drop if unemp_16_miss_10 == 1
*drop if unemp_10_miss_16 == 1
*drop if olf_16_miss_10 == 1
*drop if olf_10_miss_16 == 1 


              ***************************************************
                *****         M1: SIMPLE OLS:           *******
              ***************************************************

**********************
********* OLS ********
**********************

  foreach outcome of global outcome_var_empl {
    qui xi: reg `outcome' $dep_var ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            [pweight = expan_indiv],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.05 .01 .001) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
  }


            ***********************************************************************
              ***** M2: YEAR FE / DISTRICT FE / CONTROL NUMBER OF REFUGEE   *****
            ***********************************************************************

**********************
********* OLS ********
**********************

  foreach outcome of global outcome_var_empl {
    qui xi: reg `outcome' $dep_var ///
            i.district_iid i.year ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            [pweight = expan_indiv],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.05 .01 .001) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

  }

**********************
********* IV *********
**********************

  foreach outcome of global outcome_var_empl {
    qui xi: ivreg2  `outcome' ///
                i.year i.district_iid ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                ($dep_var = IHS_IV_SS) ///
                [pweight = expan_indiv], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var) star(.05 .01 .001) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

    * With equivalent first-stage
    gen smpl=0
    replace smpl=1 if e(sample)==1

    qui xi: reg $dep_var IHS_IV_SS ///
            i.year i.district_iid ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            if smpl == 1 [pweight = expan_indiv], ///
            cluster(district_iid) robust
    estimates table, k(IHS_IV_SS) star(.05 .01 .001)           
    drop smpl 
  }


******************************************************************************************
  *****    M3:  YEAR FE / DISTRICT FE / SECOTRAL FE / CONTROL NUMBER OF REFUGEE   ******
******************************************************************************************

**********************
********* IV *********
**********************

  foreach outcome of global outcome_var_empl {
    qui xi: ivreg2  `outcome' ///
                i.year i.district_iid i.crsectrp ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                ($dep_var = IHS_IV_SS) ///
                [pweight = expan_indiv], ///
                cluster(district_iid) ///
                partial(i.district_iid i.crsectrp) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var) star(.05 .01 .001) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

    * With equivalent first-stage
    gen smpl=0
    replace smpl=1 if e(sample)==1

    qui xi: reg $dep_var IHS_IV_SS ///
            i.year i.district_iid i.crsectrp ///
            $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            if smpl == 1 [pweight = expan_indiv], ///
            cluster(district_iid) robust
    estimates table,  k(IHS_IV_SS) star(.05 .01 .001)           
    drop smpl 
  }

          ***********************************************************************
            *****    M4:  YEAR FE / INDIV FE / CONTROL NUMBER OF REFUGEE    *****
          ***********************************************************************

**********************
********* IV *********
**********************

preserve
  foreach outcome_l1 of global outcome_var_empl  {     
      codebook `outcome_l1', c
      qui xi: ivreg2 `outcome_l1' ///
                    i.year i.district_iid ///
                    $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                    ($dep_var = IHS_IV_SS) ///
                    [pweight = expan_indiv], ///
                    cluster(district_iid) robust ///
                    partial(i.district_iid) 

        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
        foreach y in `outcome_l1' $controls $dep_var IHS_IV_SS educ1d fteducst mteducst ftempst ln_nb_refugees_bygov {
          qui reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
          qui rename `y' o_`y'
          qui rename `y'_c2wr `y'
        }
        qui ivreg2 `outcome_l1' ///
               $controls educ1d fteducst mteducst ftempst ln_nb_refugees_bygov ///
               ($dep_var = IHS_IV_SS) ///
               [pweight = expan_indiv], ///
               cluster(district_iid) robust ///
               first 
      estimates table, k($dep_var) star(.05 .01 .001) b(%7.4f) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
        qui drop `outcome_l1' $dep_var IHS_IV_SS $controls educ1d fteducst mteducst ftempst smpl ln_nb_refugees_bygov
        foreach y in `outcome_l1' $controls  $dep_var IHS_IV_SS educ1d fteducst mteducst ftempst ln_nb_refugees_bygov  {
          qui rename o_`y' `y' 
        }
    }
restore                


log close

************************************************
//  SUMMARY STATISTICS
************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear


preserve

bys year: su work_permit
bys year: su agg_wp 
bys year: su IHS_IV_SS

drop if nationality_cl != 1
drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

drop if miss_16_10 == 1
*drop if emp_16_miss_10 == 1
*drop if emp_10_miss_16 == 1
*drop if unemp_16_miss_10 == 1
*drop if unemp_10_miss_16 == 1
*drop if olf_16_miss_10 == 1
*drop if olf_10_miss_16 == 1 

bys year: su unemployed_3m // From unempsr1m - mrk def, search req; 3m, empl or unemp, OLF is miss
bys year: su unempdurmth  // Current unemployment duration (in months)
bys year: su employed_3m  // From uswrkstsr1 - mkt def, search req; 3m, 2 empl - 1 unemp - OLF miss

drop if unemp_16_10 == 1
drop if olf_16_10 == 1


bys year: su job_stability_permanent_3m //  From usstablp - Stability of employement (3m) - 1 permanent - 0 temp, seas, cas
bys year: su informal  // 1 Informal - 0 Formal - Informal if no contract (uscontrp=0) and no insurance (ussocinsp=0)
bys year: su wp_industry_jlmps_3m  // Industries with work permits for refugees - Economic Activity of prim. job 3m
bys year: su member_union_3m // Member of a syndicate/trade union (ref. 3-mnths)
bys year: su skills_required_pjob //  Does primary job require any skill
  
bys year: su real_basic_wage_3m  // IHS Basic Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING
bys year: su real_total_wage_3m  // IHS Total Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING
bys year: su real_monthly_wage // IHS Monthly Wage (Prim.& Second. Jobs)
bys year: su real_hourly_wage  // IHS Hourly Wage (Prim.& Second. Jobs)

bys year: su work_hours_pday_3m_w  // Winsorized - No. of Hours/Day (Ref. 3 mnths) Market Work
bys year: su work_hours_pweek_3m_w  // Winsorized - Usual No. of Hours/Week, Market Work, (Ref. 3-month)
bys year: su work_days_pweek_3m  // Avg. num. of wrk. days per week during 3 mnth.
  
bys year: su age 
bys year: su gender
bys year: su hhsize 
bys year: su distance_dis_camp //  LOG Distance (km) between JORD districts and ZAATARI CAMP in 2016
bys year: su nb_refugees_bygov // LOG Number of refugees out of camps by governorate in 2016
bys year: su educ1d //  Education Levels (1-digit)
bys year: su fteducst //  Father's Level of education attained
bys year: su mteducst //  Mother's Level of education attained
bys year: su ftempst //  Father's Employment Status (When Resp. 15)


restore

preserve


tab nationality_cl year 
drop if nationality_cl != 1
drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016
drop if miss_16_10 == 1
drop if emp_16_miss_10 == 1
drop if emp_10_miss_16 == 1
drop if unemp_16_miss_10 == 1
drop if unemp_10_miss_16 == 1
drop if olf_16_miss_10 == 1
drop if olf_10_miss_16 == 1 

restore









