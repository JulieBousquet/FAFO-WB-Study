

cap log close
clear all
set more off, permanently
set mem 100m


   ****************************************************************************
   **                            DATA JLMPS                                  **
   **               		  	   GLOBALS                                   **  
   ** ---------------------------------------------------------------------- **
   ** Type Do  :  DATA JLMPS   GLOBALS                                       **
   **                                                                        **
   ** Authors  : Julie Bousquet                                              **
   ****************************************************************************


*********************************************************************
*********************************************************************

                              ************
                              *  GLOBALS *
                              ************

global    dep_var   agg_wp 
*global    dep_var   share_wp_100
*global    dep_var   agg_wp_orig

/*
global    outcome_var_empl ///
              unemployed_3m /// From unempsr1m - mrk def, search req; 3m, empl or unemp, OLF is miss
              unempdurmth  ///  Current unemployment duration (in months)
              employed_3m  ///From uswrkstsr1 - mkt def, search req; 3m, 2 empl - 1 unemp - OLF miss
              IHS_b_rwage_unolf ///UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - IHS - Basic Wage (3-month)
              IHS_b_rwage_unemp ///UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - IHS Basic (3m)
              IHS_t_rwage_unolf ///UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - IHS - Total Wage (3-month)
              IHS_t_rwage_unemp //UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - IHS Total (3m)
*/
global    outcome_var_empl ///
              unemployed_3m /// From unempsr1m - mrk def, search req; 3m, empl or unemp, OLF is miss
              unempdurmth  ///  Current unemployment duration (in months)
              employed_3m  ///From uswrkstsr1 - mkt def, search req; 3m, 2 empl - 1 unemp - OLF miss
              ln_b_rwage_unolf ///UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - LOG - Basic Wage (3-month)
              ln_b_rwage_unemp ///UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - LOG Basic (3m)
              ln_t_rwage_unolf ///UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - LOG - Total Wage (3-month)
              ln_t_rwage_unemp // UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - LOG Total (3m)

global    outcome_var_job ///
              job_stable_3m ///  From usstablp - Stability of employement (3m) - 1 permanent - 0 temp, seas, cas
              informal  /// 1 Informal - 0 Formal - Informal if no contract (uscontrp=0) and no insurance (ussocinsp=0)
              wp_industry_jlmps_3m  /// Industries with work permits for refugees - Economic Activity of prim. job 3m
              member_union_3m /// Member of a syndicate/trade union (ref. 3-mnths)
              skills_required_pjob //  Does primary job require any skill
  
/*
global    outcome_var_wage ///
              IHS_basic_rwage_3m  /// IHS Basic Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING
              IHS_total_rwage_3m  /// IHS Total Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING
              IHS_monthly_rwage /// IHS Monthly Wage (Prim.& Second. Jobs)
              IHS_hourly_rwage  // IHS Hourly Wage (Prim.& Second. Jobs)
*/

global    outcome_var_wage ///
              ln_total_rwage_3m  /// LOG Total Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING
              ln_hourly_rwage  // LOG Hourly Wage (Prim.& Second. Jobs)
              *ln_monthly_rwage  /// LOG Monthly Wage (Prim.& Second. Jobs)
              *ln_basic_rwage_3m  // LOG Basic Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING

*IHS_daily_rwage_irregular // IHS Average Daily Wage (Irregular Workers)

global    outcome_var_hours ///
              work_hours_pweek_3m_w  /// Winsorized - Usual No. of Hours/Week, Market Work, (Ref. 3-month)
              work_hours_pday_3m_w  // Winsorized - No. of Hours/Day (Ref. 3 mnths) Market Work
              *work_days_pweek_3m  // Avg. num. of wrk. days per week during 3 mnth.

*work_hours_pm_informal_w  //  Winsorized - Average worked hour per month for irregular job
  
global    globals_list ///
            outcome_var_job outcome_var_wage outcome_var_hours

global controls ///
          age  /// Age
          age2 /// Age square
          gender ///  Gender - 1 Male 0 Female
          hhsize //  Total No. of Individuals in the Household
     *     ln_invdistance_dis_camp //  LOG Distance (km) between JORD districts and ZAATARI CAMP in 2016

/*SPECIAL TREATMENTS
          ln_nb_refugees_bygov /// LOG Number of refugees out of camps by governorate in 2016
          educ1d ///  Education Levels (1-digit)
          fteducst ///  Father's Level of education attained
          mteducst ///  Mother's Level of education attained
          ftempst ///  Father's Employment Status (When Resp. 15)

*/


/*


cap log close
clear all
set more off, permanently
set mem 100m


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
                ln_basic_rwage_uncond_unolf /// UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - NATIVES - LOG - Basic Wage (3-month)
                ln_basic_rwage_uncond_unemp /// UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - NATIVES LOG Basic (3m)
                total_wage_3m  /// Total Wages (3-month)
                real_total_wage_3m /// CORRECTED INFLATION - Total Wage (3-month)
                ln_total_rwage_3m  /// LOG Total Wage (3-month)
                IHS_total_rwage_3m /// IHS Total Wage (3-month)
                ln_total_rwage_natives_cond /// CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING - NATIVES LOG Total Wage (3m)
                ln_total_rwage_uncond_unolf /// UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - NATIVES - LOG - Total Wage (3-month)
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




************
*REGRESSION*
************

* SET THE PANEL STRUCTURE
xtset, clear 
*xtset year
xtset indid_2010 year 


*/
