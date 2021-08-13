



cap log close
clear all
set more off, permanently
set mem 100m

*log using "$analysis_do/01_Data_Cleaning_EL1.log", replace

   ****************************************************************************
   **                            DATA JLMPS                                  **
   **                  DESCRIPTIVE STATISTICS AND ANALYSIS                   **  
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


***********************************************************************
**DEFINING THE SAMPLE *************************************************
***********************************************************************

**************
* JORDANIANS *
**************
codebook nationality_cl
lab list Lnationality_cl
/*
                        53,094         1  Jordanian
                         3,003         2  Syrian
                           623         3  Egyptian
                         2,551         4  Other Arab
                           132         5  Other

*/

keep if nationality_cl == 1 //Keep only the jordanians
*keep if nationality_cl != 2 //Keep all but the syrians
tab year 
tab age

***************
* WORKING AGE *
*************** 

*Keep only working age pop? 15-64 ? As defined by the ERF
tab age year 
drop if age < 15 
drop if age > 64
tab year 

**********************************
* PEOPLE SURVEYED IN BOTH ROUNDS *
**********************************

*br indid indid_2010 indid_2016 year
*SAMPLE: SAME INDIVIDUALS WERE SURVEYED IN 2010 AND 2016
*BUT A FEW WERE NOT (ALL REFUGEE WEREN'T SURVEYED IN 2010)
*AND A FEW JORDANIANS. I DECDIE TO KEEP ONLY THE PANEL STRUCTURE 
*FOR FIXED EFFECT AT THE INDIV LEVEL 

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



*********************************************************************
*********************************************************************

************
*REGRESSION*
************
global    outcome_var_empl ///
                unemployed /// From unemp2m - ext def, search not req; 1 week, empl or unemp, OLF is miss
                unempdurmth ///    Current unemployment duration (in months)
                jobless2  ///  Jobless, Extended Definition (Among non-students)
                employed_3m  ///   From uswrkst2 - ext def, search not req; 3 months, empl or unemp, OLF is miss
                employed_1w  ///   From uswrkst1 - ext def, search not req; 1 week, empl or unemp, OLF is miss
                employed_3m_olf  ///   From usemp2 - ext def, 3 months, 1 empl - 0 unemp&OLF
                employed_1w_olf  ///   From cremp2 - ext def, 1 week, 1 empl - 0 unemp&OLF
                job_stability_permanent_1w /// From crstablp - Stability of employement (1w) - 1 permanent - 0 temp, seas, cas
                job_stability_permanent_3m /// From usstablp - Stability of employement (3m) - 1 permanent - 0 temp, seas, cas
                job_regular_1w /// From crirreg - Current job (1w) is regular - 1 Yes - 0 No
                job_regular_3m /// From usirreg - Usual job (3m) is regular - 1 Yes - 0 No
                incidence_soc_insur_1w /// Incidence of wrk social insurance in prim. job (ref. 1-week)
                incidence_soc_insur_3m /// Incidence of wrk social insurance in prim. job (ref. 3-month)
                incidence_wrk_contract_1w ///  Incidence of wrk contract in prim. job (ref. 1-week)
                incidence_wrk_contract_3m ///  Incidence of wrk contract in prim. job (ref. 3-month)
                job_formal_1w  /// Formality of prim. job (ref. 1-Week) - 0 Informal - 1 Formal
                job_formal_3m  /// Formality of prim. job (ref. 3-month) - 0 Informal - 1 Formal
                informal  ///  1 Informal - 0 Formal - Informal if no contract (uscontrp=0) and no insurance (ussocinsp=0)
                wp_industry_jlmps_1w  ///  Industries with work permits for refugees - Economic Activity of prim. job 1w
                wp_industry_jlmps_3m ///   Industries with work permits for refugees - Economic Activity of prim. job 3m
                member_union_3m /// Member of a syndicate/trade union (ref. 3-mnths)
                skills_required_pjob  ///  Does primary job require any skill
                stability_main_job /// From job1_07 : Degree of stability - Job 01 - 1 Stable
                permanent_contract // From job1_08 : Type of work contract - Job 01 - 1 Permanent

global outcome_var_wage ///
                basic_wage_3m  /// Basic Wage (3-month)
                real_basic_wage_3m /// CORRECTED INFLATION - Basic Wage (3-month)
                ln_basic_rwage_3m ///  LOG Basic Wage (3-month)
                IHS_basic_rwage_3m /// IHS Basic Wage (3-month)
                ln_basic_rwage_natives_cond /// CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING - NATIVES LOG Basic Wage (3m)
                ln_basic_rwage_uncond_unemp_olf /// UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - NATIVES - LOG - Basic Wage (3-month)
                ln_basic_rwage_uncond_unemp /// UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - NATIVES LOG Basic (3m)
                total_wage_3m  /// Total Wages (3-month)
                real_total_wage_3m /// CORRECTED INFLATION - Total Wage (3-month)
                ln_total_rwage_3m  /// LOG Total Wage (3-month)
                IHS_total_rwage_3m /// IHS Total Wage (3-month)
                ln_total_rwage_natives_cond /// CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING - NATIVES LOG Total Wage (3m)
                ln_total_rwage_uncond_unemp_olf /// UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - NATIVES - LOG - Total Wage (3-month)
                ln_total_rwage_uncond_unemp /// UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - NATIVES LOG Total (3m)
                mthly_wage /// Monthly Wage (Prim.& Second. Jobs)
                real_mthly_wage /// CORRECTED INFLATION - Monthly Wage (Prim.& Second. Jobs)
                ln_mthly_rwage /// LOG Monthly Wage (Prim.& Second. Jobs)
                hourly_wage /// Hourly Wage (Prim.& Second. Jobs)
                real_hourly_wage  ///  CORRECTED INFLATION - Hourly Wage (Prim.& Second. Jobs)
                ln_hourly_rwage /// LOG Hourly Wage (Prim.& Second. Jobs)
                daily_wage_irregular   /// Average Daily Wage (Irregular Workers)
                real_daily_wage_irregular  /// CORRECTED INFLATION - Average Daily Wage (Irregular Workers)
                ln_daily_rwage_irregular  //  LOG Average Daily Wage (Irregular Workers)

global outcome_var_hours ///
                work_hours_pday_1w /// No. of Hours/Day (Ref. 1 Week) Market Work
                work_hours_pday_1w_w  ///  Winsorized 
                work_hours_pday_3m /// No. of Hours/Day (Ref. 3 mnths) Market Work
                work_hours_pday_3m_w ///   Winsorized 
                work_hours_pweek_1w /// Crr. No. of Hours/Week, Market & Subsistence Work, (Ref. 1 Week)
                work_hours_pweek_1w_w  /// Winsorized
                work_hours_pweek_3m /// Usual No. of Hours/Week, Market & Subsistence Work, (Ref. 3-month)
                work_hours_pweek_3m_w ///  Winsorized
                work_days_pweek_1w /// No. of Days/Week (Ref. 1 Week) Market Work
                work_days_pweek_3m /// Avg. num. of wrk. days per week during 3 mnth.
                work_hours_pmonth_informal /// Average worked hour per month for irregular job
                work_hours_pmonth_informal_w //   Winsorized
**************
*GLOBALS 
global    controls ///
          age age2 sex hhsize 

/*global    lm_out ///
          ln_wage_natives_cond     /// Wage Cond   (no empl = . / out LF = .)
           usemp1 /// Employed
          unemp1 /// Unemp 
           crnumhrs1 /// Hours of work per week
          informal // Informal if no contract and no insurance
*/
         *ln_wage_uncond_unemp     /// Wage Uncond (no empl = 0 / out LF = .)
          *ln_wage_uncond_unemp_olf /// Wage Uncond (no empl = 0 / out LF = 0)
         *crnumdys /// Days of work per week
          *crhrsday /// Hours of work per day 

************************
* DESCRIPTIVE STATISTICS
************************

*Summary statstics
bys year: sum IV_SS agg_wp work_permit ///
              $outcome_var_empl  $outcome_var_wage $outcome_var_hours ///
              $controls ln_ref NbRefbyGovoutcamp ///
              educ1d fteducst mteducst [aweight = expan_indiv] 

mdesc $outcome_var_empl  $outcome_var_wage $outcome_var_hours 

*Dividing into treated areas: WP against NO WP: District differences?
tab agg_wp, m
gen bi_agg_wp = 1 if agg_wp != 0
replace bi_agg_wp = 0 if agg_wp == 0
tab bi_agg_wp, m

reg age agg_wp
ttest age == agg_wp


************
*REGRESSION*
************

* SET THE PANEL STRUCTURE
xtset, clear 
*xtset year
xtset indid_2010 year 



***************************************************

  ********** M1: SIMPLE OLS: 

***************************************************

foreach outcome of global outcome_var_empl {
  xi: reg `outcome' agg_wp ///
          $controls i.educ1d i.fteducst i.mteducst ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  codebook `outcome', c
  estimates table, k(agg_wp) star(.05 .01 .001)
}

foreach outcome of global outcome_var_wage {
  xi: reg `outcome' agg_wp ///
          $controls i.educ1d i.fteducst i.mteducst ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  codebook `outcome', c
  estimates table, k(agg_wp) star(.05 .01 .001)
}

foreach outcome of global outcome_var_hours {
  xi: reg `outcome' agg_wp ///
          $controls i.educ1d i.fteducst i.mteducst ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust
  codebook `outcome', c 
  estimates table, k(agg_wp) star(.05 .01 .001)
}

************ M1 with automatic tables

tab ln_wage_natives_cond
tab educ1d
codebook educ1d
lab def Leduc1d   1  "Illiterate" ///
                  2  "Read and Write" ///
                  3  "Basic Education" ///
                  4  "Secondary Educ" ///
                  5  "Post Secondary" ///
                  6  "University" ///
                  7  "Post Graduate" ///
                  , modify
lab val educ1d Leduc1d 

codebook agg_wp
lab var agg_wp "Work Permits"

reg ln_wage_natives_cond agg_wp $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv], cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m1, title(Model 1)

sum ln_wage_natives_cond if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

reg usemp1 agg_wp $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv], cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m2, title(Model 2)

sum usemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

reg unemp1 agg_wp $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv], cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m3, title(Model 3)

sum unemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

reg crnumhrs1 agg_wp $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv],  cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m4, title(Model 4)

sum crnumhrs1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

reg informal agg_wp $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv], cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m5, title(Model 5)

sum informal if agg_wp == 1
estadd scalar ctrl_mean = r(mean)


ereturn list
mat list e(b)
estout m1 m2 m3 m4 m5, cells(b(star fmt(3)) se(par fmt(2))) ///
  drop(age age2 sex hhsize 1.educ1d 2.educ1d 3.educ1d 4.educ1d ///
        5.educ1d 6.educ1d 7.educ1d 1.fteducst 2.fteducst ///
        3.fteducst 4.fteducst 5.fteducst 6.fteducst ///
        1.mteducst 2.mteducst 3.mteducst 4.mteducst 5.mteducst ///
        6.mteducst _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m1 m2 m3 m4 m5 using "$out_JLMPS/reg_01_OLS.tex", se label replace booktabs ///
mtitles("Wage" "Employ" "Unemploy" "Nb. Hours" "Informal") ///
scalars(ctrl_mean)  drop(age age2 sex hhsize 1.educ1d 2.educ1d 3.educ1d 4.educ1d ///
        5.educ1d 6.educ1d 7.educ1d 1.fteducst 2.fteducst ///
        3.fteducst 4.fteducst 5.fteducst 6.fteducst ///
        1.mteducst 2.mteducst 3.mteducst 4.mteducst 5.mteducst ///
        6.mteducst _cons $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results OLS Regression"\label{tab1}) nofloat ///
   stats(N r2_a ctrl_mean, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m1 m2 m3 m4 m5 


***************************************************

  ********** M2: SIMPLE OLS: DISTRICT FE 

***************************************************


foreach outcome of global outcome_var_empl {
  qui xi: reg `outcome' agg_wp i.district_iid ///
          $controls i.educ1d i.fteducst i.mteducst ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
    codebook `outcome', c
  estimates table, k(agg_wp) star(.05 .01 .001)
}

foreach outcome of global outcome_var_wage {
  xi: reg `outcome' agg_wp i.district_iid ///
          $controls i.educ1d i.fteducst i.mteducst ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  codebook `outcome', c
  estimates table, k(agg_wp) star(.05 .01 .001)
}

foreach outcome of global outcome_var_hours {
  xi: reg `outcome' agg_wp i.district_iid ///
          $controls i.educ1d i.fteducst i.mteducst ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  codebook `outcome', c
  estimates table, k(agg_wp) star(.05 .01 .001)
}


reg ln_wage_natives_cond agg_wp i.district_iid $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv], cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m1, title(Model 1)

sum ln_wage_natives_cond if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

reg usemp1 agg_wp i.district_iid $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv], cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m2, title(Model 2)

sum usemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

reg unemp1 agg_wp i.district_iid $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv], cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m3, title(Model 3)

sum unemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

reg crnumhrs1 agg_wp i.district_iid $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv],  cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m4, title(Model 4)

sum crnumhrs1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

reg informal agg_wp i.district_iid $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv], cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m5, title(Model 5)

sum informal if agg_wp == 1
estadd scalar ctrl_mean = r(mean)


ereturn list
mat list e(b)
estout m1 m2 m3 m4 m5, cells(b(star fmt(3)) se(par fmt(2))) ///
  drop(age age2 sex hhsize 1.educ1d 2.educ1d 3.educ1d 4.educ1d ///
        5.educ1d 6.educ1d 7.educ1d 1.fteducst 2.fteducst ///
        3.fteducst 4.fteducst 5.fteducst 6.fteducst ///
        1.mteducst 2.mteducst 3.mteducst 4.mteducst 5.mteducst ///
        6.mteducst ///
        1.district_iid 2.district_iid 3.district_iid 4.district_iid ///
        5.district_iid 6.district_iid 7.district_iid 8.district_iid ///
        9.district_iid 10.district_iid 11.district_iid 12.district_iid ///
        13.district_iid 14.district_iid 15.district_iid 16.district_iid ///
        17.district_iid 18.district_iid 19.district_iid 20.district_iid ///
        21.district_iid 22.district_iid 23.district_iid 24.district_iid ///
        25.district_iid ///
        26.district_iid 27.district_iid 28.district_iid 29.district_iid ///
        30.district_iid 31.district_iid 32.district_iid 33.district_iid ///
        34.district_iid 35.district_iid 36.district_iid 37.district_iid ///
        38.district_iid 39.district_iid 40.district_iid 41.district_iid ///
        42.district_iid 43.district_iid 44.district_iid 45.district_iid ///
        46.district_iid 47.district_iid 48.district_iid 49.district_iid ///
        50.district_iid 51.district_iid  ///
         _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m1 m2 m3 m4 m5 using "$out_JLMPS/reg_02_OLS_FE_district.tex", se label replace booktabs ///
mtitles("Wage" "Employ" "Unemploy" "Nb. Hours" "Informal") ///
scalars(ctrl_mean)  drop(age age2 sex hhsize 1.educ1d 2.educ1d 3.educ1d 4.educ1d ///
        5.educ1d 6.educ1d 7.educ1d 1.fteducst 2.fteducst ///
        3.fteducst 4.fteducst 5.fteducst 6.fteducst ///
        1.mteducst 2.mteducst 3.mteducst 4.mteducst 5.mteducst ///
        6.mteducst ///
        1.district_iid 2.district_iid 3.district_iid 4.district_iid ///
        5.district_iid 6.district_iid 7.district_iid 8.district_iid ///
        9.district_iid 10.district_iid 11.district_iid 12.district_iid ///
        13.district_iid 14.district_iid 15.district_iid 16.district_iid ///
        17.district_iid 18.district_iid 19.district_iid 20.district_iid ///
        21.district_iid 22.district_iid 23.district_iid 24.district_iid ///
        25.district_iid ///
        26.district_iid 27.district_iid 28.district_iid 29.district_iid ///
        30.district_iid 31.district_iid 32.district_iid 33.district_iid ///
        34.district_iid 35.district_iid 36.district_iid 37.district_iid ///
        38.district_iid 39.district_iid 40.district_iid 41.district_iid ///
        42.district_iid 43.district_iid 44.district_iid 45.district_iid ///
        46.district_iid 47.district_iid 48.district_iid 49.district_iid ///
        50.district_iid 51.district_iid  ///
        _cons $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results OLS Regression with District FE"\label{tab1}) nofloat ///
   stats(N r2_a ctrl_mean, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m1 m2 m3 m4 m5 


***************************************************

  ********** M3: YEAR FE / DISTRICT FE

***************************************************

foreach outcome of global lm_out {
  *OLS
  xi: reg `outcome' agg_wp ///
          i.district_iid i.year ///
          $controls i.educ1d i.fteducst i.mteducst   ///
          [pweight = expan_indiv],  ///
          cluster(district_iid) robust 
  estimates table, star(.05 .01 .001)
}


reg ln_wage_natives_cond agg_wp i.district_iid i.year $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv], cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m1, title(Model 1)

sum ln_wage_natives_cond if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

reg usemp1 agg_wp i.district_iid i.year $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv], cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m2, title(Model 2)

sum usemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

reg unemp1 agg_wp i.district_iid i.year $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv], cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m3, title(Model 3)

sum unemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

reg crnumhrs1 agg_wp i.district_iid i.year $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv],  cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m4, title(Model 4)

sum crnumhrs1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

reg informal agg_wp i.district_iid i.year $controls i.educ1d i.fteducst i.mteducst ///
    [pweight = expan_indiv], cluster(district_iid) robust
estimates table, star(.05 .01 .001)
estimates store m5, title(Model 5)

sum informal if agg_wp == 1
estadd scalar ctrl_mean = r(mean)


ereturn list
mat list e(b)
estout m1 m2 m3 m4 m5, cells(b(star fmt(3)) se(par fmt(2))) ///
  drop(age age2 sex hhsize 1.educ1d 2.educ1d 3.educ1d 4.educ1d ///
        5.educ1d 6.educ1d 7.educ1d 1.fteducst 2.fteducst ///
        3.fteducst 4.fteducst 5.fteducst 6.fteducst ///
        1.mteducst 2.mteducst 3.mteducst 4.mteducst 5.mteducst ///
        6.mteducst 2010.year 2016.year ///
        1.district_iid 2.district_iid 3.district_iid 4.district_iid ///
        5.district_iid 6.district_iid 7.district_iid 8.district_iid ///
        9.district_iid 10.district_iid 11.district_iid 12.district_iid ///
        13.district_iid 14.district_iid 15.district_iid 16.district_iid ///
        17.district_iid 18.district_iid 19.district_iid 20.district_iid ///
        21.district_iid 22.district_iid 23.district_iid 24.district_iid ///
        25.district_iid ///
        26.district_iid 27.district_iid 28.district_iid 29.district_iid ///
        30.district_iid 31.district_iid 32.district_iid 33.district_iid ///
        34.district_iid 35.district_iid 36.district_iid 37.district_iid ///
        38.district_iid 39.district_iid 40.district_iid 41.district_iid ///
        42.district_iid 43.district_iid 44.district_iid 45.district_iid ///
        46.district_iid 47.district_iid 48.district_iid 49.district_iid ///
        50.district_iid 51.district_iid  ///
         _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m1 m2 m3 m4 m5 using "$out_JLMPS/reg_03_OLS_FE_district_year.tex", se label replace booktabs ///
mtitles("Wage" "Employ" "Unemploy" "Nb. Hours" "Informal") ///
scalars(ctrl_mean)  drop(age age2 sex hhsize 1.educ1d 2.educ1d 3.educ1d 4.educ1d ///
        5.educ1d 6.educ1d 7.educ1d 1.fteducst 2.fteducst ///
        3.fteducst 4.fteducst 5.fteducst 6.fteducst ///
        1.mteducst 2.mteducst 3.mteducst 4.mteducst 5.mteducst ///
        6.mteducst 2010.year 2016.year ///
        1.district_iid 2.district_iid 3.district_iid 4.district_iid ///
        5.district_iid 6.district_iid 7.district_iid 8.district_iid ///
        9.district_iid 10.district_iid 11.district_iid 12.district_iid ///
        13.district_iid 14.district_iid 15.district_iid 16.district_iid ///
        17.district_iid 18.district_iid 19.district_iid 20.district_iid ///
        21.district_iid 22.district_iid 23.district_iid 24.district_iid ///
        25.district_iid ///
        26.district_iid 27.district_iid 28.district_iid 29.district_iid ///
        30.district_iid 31.district_iid 32.district_iid 33.district_iid ///
        34.district_iid 35.district_iid 36.district_iid 37.district_iid ///
        38.district_iid 39.district_iid 40.district_iid 41.district_iid ///
        42.district_iid 43.district_iid 44.district_iid 45.district_iid ///
        46.district_iid 47.district_iid 48.district_iid 49.district_iid ///
        50.district_iid 51.district_iid  ///
        _cons $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results OLS Regression with District and Year FE"\label{tab1}) nofloat ///
   stats(N r2_a ctrl_mean, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m1 m2 m3 m4 m5 


********* IV *********

/*
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

*/

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
  estimates store m1, title(Model 1)

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

estimates store m11, title(Model 11)

sum ln_wage_natives_cond if agg_wp == 1
estadd scalar ctrl_mean = r(mean)



 *IV
  xi: ivreg2  usemp1 ///
              i.year i.district_iid ///
              $controls i.educ1d i.fteducst i.mteducst  ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first 
  estimates table, star(.05 .01 .001) 
  estimates store m2, title(Model 2)

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

estimates store m21, title(Model 21)

sum usemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

 *IV
  xi: ivreg2  unemp1 ///
              i.year i.district_iid ///
              $controls i.educ1d i.fteducst i.mteducst  ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first 
  estimates table, star(.05 .01 .001) 
  estimates store m3, title(Model 3)

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

estimates store m31, title(Model 31)

sum unemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

 *IV
  xi: ivreg2  crnumhrs1 ///
              i.year i.district_iid ///
              $controls i.educ1d i.fteducst i.mteducst  ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first 
  estimates table, star(.05 .01 .001) 
  estimates store m4, title(Model 4)

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

estimates store m41, title(Model 41)

sum crnumhrs1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

 *IV
  xi: ivreg2  informal ///
              i.year i.district_iid ///
              $controls i.educ1d i.fteducst i.mteducst  ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first 
  estimates table, star(.05 .01 .001) 
  estimates store m5, title(Model 5)

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

estimates store m51, title(Model 51)

sum informal if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

ereturn list
mat list e(b)
estout m1 m2 m3 m4 m5, cells(b(star fmt(3)) se(par fmt(2))) ///
  drop(age age2 sex hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m1 m2 m3 m4 m5 using "$out_JLMPS/reg_04_IV_FE_district_year.tex", se label replace booktabs ///
mtitles("Wage" "Employ" "Unemploy" "Nb. Hours" "Informal") ///
scalars(ctrl_mean)  drop(age age2 sex hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District and Year FE"\label{tab1}) nofloat ///
   stats(N r2_a ctrl_mean, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m1 m2 m3 m4 m5
*m2 m3 m4 m5 

ereturn list
mat list e(b)
estout m11 m21 m31 m41 m51, cells(b(star fmt(3)) se(par fmt(2))) ///
  drop(age age2 sex hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iyear_2016 ///
        _Idistrict__2 _Idistrict__3 ///
        _Idistrict__4 _Idistrict__5 _Idistrict__6 _Idistrict__7 ///
        _Idistrict__8 _Idistrict__9 _Idistrict__10 _Idistrict__11 ///
        _Idistrict__12 _Idistrict__13 _Idistrict__14 _Idistrict__15 ///
        _Idistrict__16 _Idistrict__17 _Idistrict__18 _Idistrict__19 ///
        _Idistrict__20 _Idistrict__21 _Idistrict__22 _Idistrict__23 ///
        _Idistrict__24 _Idistrict__25 _Idistrict__26 _Idistrict__27 ///
        _Idistrict__28 _Idistrict__29 _Idistrict__30 _Idistrict__31 ///
        _Idistrict__32 _Idistrict__33 _Idistrict__34 _Idistrict__35 ///
        _Idistrict__36 _Idistrict__37 _Idistrict__38 _Idistrict__39 ///
        _Idistrict__40 _Idistrict__41 _Idistrict__42 _Idistrict__43 ///
        _Idistrict__44 _Idistrict__45 _Idistrict__46 _Idistrict__47 ///
        _Idistrict__48 _Idistrict__49 _Idistrict__50 _Idistrict__51 ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m11 m21 m31 m41 m51 using "$out_JLMPS/reg_04_IV_FE_district_year_stage1.tex", se label replace booktabs ///
mtitles("Wage" "Employ" "Unemploy" "Nb. Hours" "Informal") ///
scalars(ctrl_mean)  drop(age age2 sex hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iyear_2016 ///
        _Idistrict__2 _Idistrict__3 ///
        _Idistrict__4 _Idistrict__5 _Idistrict__6 _Idistrict__7 ///
        _Idistrict__8 _Idistrict__9 _Idistrict__10 _Idistrict__11 ///
        _Idistrict__12 _Idistrict__13 _Idistrict__14 _Idistrict__15 ///
        _Idistrict__16 _Idistrict__17 _Idistrict__18 _Idistrict__19 ///
        _Idistrict__20 _Idistrict__21 _Idistrict__22 _Idistrict__23 ///
        _Idistrict__24 _Idistrict__25 _Idistrict__26 _Idistrict__27 ///
        _Idistrict__28 _Idistrict__29 _Idistrict__30 _Idistrict__31 ///
        _Idistrict__32 _Idistrict__33 _Idistrict__34 _Idistrict__35 ///
        _Idistrict__36 _Idistrict__37 _Idistrict__38 _Idistrict__39 ///
        _Idistrict__40 _Idistrict__41 _Idistrict__42 _Idistrict__43 ///
        _Idistrict__44 _Idistrict__45 _Idistrict__46 _Idistrict__47 ///
        _Idistrict__48 _Idistrict__49 _Idistrict__50 _Idistrict__51 ///
        _cons $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results Stage 1 IV Regression with District and Year FE"\label{tab1}) nofloat ///
   stats(N r2_a ctrl_mean, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m11 m21 m31 m41 m51


***************************************************

  ********** M4: YEAR FE / DISTRICT FE / CONTROL NUMBER OF REFUGEE

***************************************************

/*
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
*/


xi: ivreg2    ln_wage_natives_cond ///
              i.year i.district_iid ///
              ln_ref $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first
estimates table, star(.05 .01 .001)

estimates store m1, title(Model 1)

sum ln_wage_natives_cond if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

xi: ivreg2    usemp1 ///
              i.year i.district_iid ///
              ln_ref $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first
estimates table, star(.05 .01 .001)

estimates store m2, title(Model 2)

sum usemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)


xi: ivreg2    unemp1 ///
              i.year i.district_iid ///
              ln_ref $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first
estimates table, star(.05 .01 .001)

estimates store m3, title(Model 3)

sum unemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)


xi: ivreg2    crnumhrs1 ///
              i.year i.district_iid ///
              ln_ref $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first
estimates table, star(.05 .01 .001)

estimates store m4, title(Model 4)

sum crnumhrs1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)


xi: ivreg2    informal ///
              i.year i.district_iid ///
              ln_ref $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) ///
              first
estimates table, star(.05 .01 .001)

estimates store m5, title(Model 5)

sum informal if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

ereturn list
mat list e(b)
estout m1 m2 m3 m4 m5, cells(b(star fmt(3)) se(par fmt(2))) ///
  drop(age age2 sex hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m1 m2 m3 m4 m5 using "$out_JLMPS/reg_05_IV_FE_district_year_ctrlref.tex", se label replace booktabs ///
mtitles("Wage" "Employ" "Unemploy" "Nb. Hours" "Informal") ///
scalars(ctrl_mean)  drop(age age2 sex hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District and Year FE, controling for the number of refugees"\label{tab1}) nofloat ///
   stats(N r2_a ctrl_mean, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m1 m2 m3 m4 m5

***************************************************

  ********** M5:  YEAR FE / DISTRICT FE / SECOTRAL FE 

***************************************************

/*
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
*/

  xi: ivreg2  ln_wage_natives_cond ///
              i.year i.district_iid i.crsectrp ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)
  estimates store m1, title(Model 1)

sum ln_wage_natives_cond if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  xi: ivreg2  usemp1 ///
              i.year i.district_iid i.crsectrp ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)
  estimates store m2, title(Model 2)

sum usemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  xi: ivreg2  unemp1 ///
              i.year i.district_iid i.crsectrp ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)
  estimates store m3, title(Model 3)

sum unemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  xi: ivreg2  crnumhrs1 ///
              i.year i.district_iid i.crsectrp ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)
  estimates store m4, title(Model 4)

sum crnumhrs1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  xi: ivreg2  informal ///
              i.year i.district_iid i.crsectrp ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)
  estimates store m5, title(Model 5)

sum informal if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

ereturn list
mat list e(b)
estout m1 m2 m3 m4 m5, cells(b(star fmt(3)) se(par fmt(2))) ///
  drop(age age2 sex hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m1 m2 m3 m4 m5 using "$out_JLMPS/reg_06_IV_FE_district_year_sector.tex", se label replace booktabs ///
mtitles("Wage" "Employ" "Unemploy" "Nb. Hours" "Informal") ///
scalars(ctrl_mean)  drop(age age2 sex hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District, Year and Sectoral FE"\label{tab1}) nofloat ///
   stats(N r2_a ctrl_mean, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m1 m2 m3 m4 m5

***************************************************

  ********** M6:  YEAR FE / DISTRICT FE / SECOTRAL FE / CONTROL NUMBER OF REFUGEE

***************************************************


/*

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

*/

  xi: ivreg2  ln_wage_natives_cond ///
              i.year i.district_iid i.crsectrp ln_ref ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)
  estimates store m1, title(Model 1)

sum ln_wage_natives_cond if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  xi: ivreg2  usemp1 ///
              i.year i.district_iid i.crsectrp ln_ref ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)
  estimates store m2, title(Model 2)

sum usemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  xi: ivreg2  unemp1 ///
              i.year i.district_iid i.crsectrp ln_ref ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)
  estimates store m3, title(Model 3)

sum unemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  xi: ivreg2  crnumhrs1 ///
              i.year i.district_iid i.crsectrp ln_ref ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)
  estimates store m4, title(Model 4)

sum crnumhrs1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  xi: ivreg2  informal ///
              i.year i.district_iid i.crsectrp ln_ref ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid i.crsectrp) ///
              first
  estimates table, star(.05 .01 .001)
  estimates store m5, title(Model 5)
  
sum informal if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

ereturn list
mat list e(b)
estout m1 m2 m3 m4 m5, cells(b(star fmt(3)) se(par fmt(2))) ///
  drop(age age2 sex hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iyear_2016 ln_ref ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m1 m2 m3 m4 m5 using "$out_JLMPS/reg_07_IV_FE_district_year_sector_ctrlref.tex", se label replace booktabs ///
mtitles("Wage" "Employ" "Unemploy" "Nb. Hours" "Informal") ///
scalars(ctrl_mean)  drop(age age2 sex hhsize ///
        ln_ref _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iyear_2016 ln_ref ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District, Year and Sectoral FE, controling for the nb of refugees"\label{tab1}) nofloat ///
   stats(N r2_a ctrl_mean, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m1 m2 m3 m4 m5


***************************************************

  ********** M7: YEAR FE / INDIV FE 

***************************************************

/*
foreach outcome of global lm_out {
  *OLS
  reghdfe `outcome' agg_wp ///
          $controls i.educ1d i.fteducst i.mteducst ///
          [pw=expan_indiv], ///
          absorb(year indid_2010) ///
          cluster(district_iid) 
}
  
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
*/

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

  estimates table, star(.05 .01 .001)
  estimates store m1, title(Model 1)
  
sum ln_wage_natives_cond if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  restore

  preserve
  xi: ivreg2  usemp1 ///
              i.year i.district_iid ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) 

  gen smpl=0
  replace smpl=1 if e(sample)==1
  * Then I partial out all variables
  foreach y in usemp1 $controls agg_wp IHS_IV_SS educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2 usemp1 ///
         $controls educ1d fteducst mteducst ///
         (agg_wp = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         cluster(district_iid) robust ///
         first
  drop usemp1 agg_wp IHS_IV_SS $controls educ1d fteducst mteducst smpl
  foreach y in usemp1 $controls  agg_wp IHS_IV_SS {
    rename o_`y' `y' 
  }

  estimates table, star(.05 .01 .001)
  estimates store m2, title(Model 2)
  
sum usemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  restore


preserve
  xi: ivreg2  unemp1 ///
              i.year i.district_iid ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) 

  gen smpl=0
  replace smpl=1 if e(sample)==1
  * Then I partial out all variables
  foreach y in unemp1 $controls agg_wp IHS_IV_SS educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2 unemp1 ///
         $controls educ1d fteducst mteducst ///
         (agg_wp = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         cluster(district_iid) robust ///
         first
  drop unemp1 agg_wp IHS_IV_SS $controls educ1d fteducst mteducst smpl
  foreach y in unemp1 $controls  agg_wp IHS_IV_SS {
    rename o_`y' `y' 
  }

  estimates table, star(.05 .01 .001)
  estimates store m3, title(Model 3)
  
sum unemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  restore

  preserve
  xi: ivreg2  crnumhrs1 ///
              i.year i.district_iid ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) 

  gen smpl=0
  replace smpl=1 if e(sample)==1
  * Then I partial out all variables
  foreach y in crnumhrs1 $controls agg_wp IHS_IV_SS educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2 crnumhrs1 ///
         $controls educ1d fteducst mteducst ///
         (agg_wp = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         cluster(district_iid) robust ///
         first
  drop crnumhrs1 agg_wp IHS_IV_SS $controls educ1d fteducst mteducst smpl
  foreach y in crnumhrs1 $controls  agg_wp IHS_IV_SS {
    rename o_`y' `y' 
  }

  estimates table, star(.05 .01 .001)
  estimates store m4, title(Model 4)
  
sum crnumhrs1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  restore

  preserve
  xi: ivreg2  informal ///
              i.year i.district_iid ///
              $controls i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) 

  gen smpl=0
  replace smpl=1 if e(sample)==1
  * Then I partial out all variables
  foreach y in informal $controls agg_wp IHS_IV_SS educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2 informal ///
         $controls educ1d fteducst mteducst ///
         (agg_wp = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         cluster(district_iid) robust ///
         first
  drop informal agg_wp IHS_IV_SS $controls educ1d fteducst mteducst smpl
  foreach y in informal $controls  agg_wp IHS_IV_SS {
    rename o_`y' `y' 
  }

  estimates table, star(.05 .01 .001)
  estimates store m5, title(Model 5)
  
sum informal if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  restore


ereturn list
mat list e(b)
estout m1 m2 m3 m4 m5, cells(b(star fmt(3)) se(par fmt(2))) ///
  drop(age age2 sex hhsize educ1d fteducst mteducst _cons ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m1 m2 m3 m4 m5 using "$out_JLMPS/reg_08_IV_FE_year_indiv.tex", se label replace booktabs ///
mtitles("Wage" "Employ" "Unemploy" "Nb. Hours" "Informal") ///
scalars(ctrl_mean)  drop(age age2 sex hhsize  educ1d fteducst mteducst ///
       _cons ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with Year and Individual FE"\label{tab1}) nofloat ///
   stats(N r2_a ctrl_mean, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m1 m2 m3 m4 m5



***************************************************

  ********** M8:  YEAR FE / INDIV FE / CONTROL NUMBER OF REFUGEE 

***************************************************

/*
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
*/

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
  foreach y in ln_wage_natives_cond $controls agg_wp IHS_IV_SS ln_ref educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2 ln_wage_natives_cond ///
         ln_ref $controls educ1d fteducst mteducst ///
         (agg_wp = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         cluster(district_iid) robust ///
         first
  drop ln_wage_natives_cond agg_wp IHS_IV_SS $controls ln_ref educ1d fteducst mteducst smpl
  foreach y in ln_wage_natives_cond $controls  agg_wp IHS_IV_SS ln_ref {
    rename o_`y' `y' 
  }

  estimates table, star(.05 .01 .001)
  estimates store m1, title(Model 1)
  
sum ln_wage_natives_cond if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  restore

  preserve
  xi: ivreg2  usemp1 ///
              i.year i.district_iid ///
              $controls ln_ref i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) 

  gen smpl=0
  replace smpl=1 if e(sample)==1
  * Then I partial out all variables
  foreach y in usemp1 $controls agg_wp IHS_IV_SS ln_ref educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2 usemp1 ///
         $controls educ1d fteducst mteducst ///
         (agg_wp = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         cluster(district_iid) robust ///
         first
  drop usemp1 agg_wp IHS_IV_SS $controls ln_ref educ1d fteducst mteducst smpl
  foreach y in usemp1 $controls  agg_wp IHS_IV_SS ln_ref {
    rename o_`y' `y' 
  }

  estimates table, star(.05 .01 .001)
  estimates store m2, title(Model 2)
  
sum usemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  restore


preserve
  xi: ivreg2  unemp1 ///
              i.year i.district_iid ///
              $controls ln_ref i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) 

  gen smpl=0
  replace smpl=1 if e(sample)==1
  * Then I partial out all variables
  foreach y in unemp1 $controls agg_wp IHS_IV_SS ln_ref educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2 unemp1 ///
         $controls ln_ref educ1d fteducst mteducst ///
         (agg_wp = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         cluster(district_iid) robust ///
         first
  drop unemp1 agg_wp IHS_IV_SS $controls ln_ref educ1d fteducst mteducst smpl
  foreach y in unemp1 $controls  agg_wp IHS_IV_SS {
    rename o_`y' `y' 
  }

  estimates table, star(.05 .01 .001)
  estimates store m3, title(Model 3)
  
sum unemp1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  restore

  preserve
  xi: ivreg2  crnumhrs1 ///
              i.year i.district_iid ///
              $controls ln_ref i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) 

  gen smpl=0
  replace smpl=1 if e(sample)==1
  * Then I partial out all variables
  foreach y in crnumhrs1 $controls agg_wp IHS_IV_SS ln_ref educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2 crnumhrs1 ///
         $controls ln_ref educ1d fteducst mteducst ///
         (agg_wp = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         cluster(district_iid) robust ///
         first
  drop crnumhrs1 agg_wp IHS_IV_SS $controls ln_ref educ1d fteducst mteducst smpl
  foreach y in crnumhrs1 $controls  agg_wp IHS_IV_SS {
    rename o_`y' `y' 
  }

  estimates table, star(.05 .01 .001)
  estimates store m4, title(Model 4)
  
sum crnumhrs1 if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  restore

  preserve
  xi: ivreg2  informal ///
              i.year i.district_iid ///
              $controls ln_ref i.educ1d i.fteducst i.mteducst ///
              (agg_wp = IHS_IV_SS) ///
              [pweight = expan_indiv], ///
              cluster(district_iid) robust ///
              partial(i.district_iid) 

  gen smpl=0
  replace smpl=1 if e(sample)==1
  * Then I partial out all variables
  foreach y in informal $controls ln_ref agg_wp IHS_IV_SS educ1d fteducst mteducst  {
    reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
    rename `y' o_`y'
    rename `y'_c2wr `y'
  }
  ivreg2 informal ///
         $controls educ1d fteducst mteducst ///
         (agg_wp = IHS_IV_SS) ///
         [pweight = expan_indiv], ///
         cluster(district_iid) robust ///
         first
  drop informal agg_wp IHS_IV_SS $controls ln_ref educ1d fteducst mteducst smpl
  foreach y in informal $controls  agg_wp IHS_IV_SS {
    rename o_`y' `y' 
  }

  estimates table, star(.05 .01 .001)
  estimates store m5, title(Model 5)
  
sum informal if agg_wp == 1
estadd scalar ctrl_mean = r(mean)

  restore



ereturn list
mat list e(b)
estout m1 m2 m3 m4 m5, cells(b(star fmt(3)) se(par fmt(2))) ///
  drop(age age2 sex hhsize educ1d fteducst mteducst _cons ///
         $controls ln_ref)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m1 m2 m3 m4 m5 using "$out_JLMPS/reg_09_IV_FE_year_indiv_ctrlref.tex", se label replace booktabs ///
mtitles("Wage" "Employ" "Unemploy" "Nb. Hours" "Informal") ///
scalars(ctrl_mean)  drop(age age2 sex hhsize ln_ref educ1d fteducst mteducst ///
       _cons ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with Year and Individual FE, controling for the number of refugees"\label{tab1}) nofloat ///
   stats(N r2_a ctrl_mean, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m1 m2 m3 m4 m5




























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













