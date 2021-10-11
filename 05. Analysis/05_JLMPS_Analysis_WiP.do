

cap log close
clear all
set more off, permanently
set mem 100m

log using "$out_analysis/05_JLMPS_Analysis_WiP.log", replace

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
*adoupdate, update 
*ssc inst ivreg2, replace



tab educ1d 
tab fteducst 
tab mteducst
tab ftempst 
tab ln_nb_refugees_bygov 
tab age  // Age
tab age2 // Age square
tab ln_invdistance_dis_camp //  LOG Inverse Distance (km) between JORD districts and ZAATARI CAMP in 2016
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
drop if miss_16_10 == 1
drop if unemp_16_10 == 1
drop if olf_16_10 == 1
drop if emp_16_miss_10 == 1
drop if emp_10_miss_16 == 1
drop if unemp_16_miss_10 == 1
drop if unemp_10_miss_16 == 1
drop if olf_16_miss_10 == 1
drop if olf_10_miss_16 == 1 
drop if emp_10_olf_16  == 1 
drop if emp_16_olf_10  == 1 
drop if unemp_10_emp_16  == 1 
drop if unemp_16_emp_10  == 1 
drop if olf_10_unemp_16 == 1 
drop if olf_16_unemp_10  == 1 

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

              ***************************************************
                *****         M1: SIMPLE OLS:           *******
              ***************************************************

codebook agg_wp
lab var agg_wp "Work Permits"

**********************
********* OLS ********
**********************

foreach globals of global globals_list {
  foreach outcome of global `globals' {
    qui xi: reg `outcome' $dep_var ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            [pweight = expan_indiv],  ///
            cluster(locality_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store m_`outcome', title(Model `outcome')
  }
}

ereturn list
mat list e(b)
estout m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 ln_nb_refugees_bygov _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
      m_work_hours_pweek_3m_w  m_work_days_pweek_3m /// 
      using "$out_analysis/reg_01_OLS.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Informal" "Industry" "Union" "Skills" "Total W" "Hourly W" "WH pweek" "WD pweek") ///
        drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 ln_nb_refugees_bygov _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results OLS Regression"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the locality level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m 



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
            cluster(locality_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store m_`outcome', title(Model `outcome')
  }
}


ereturn list
mat list e(b)
estout m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 ln_nb_refugees_bygov _Iyear_2016 ///
        _Idistrict__2 _Idistrict__3 ///
        _Idistrict__4 _Idistrict__5 _Idistrict__6 _Idistrict__7 ///
        _Idistrict__8 _Idistrict__9 _Idistrict__10 _Idistrict__11 ///
        _Idistrict__12 _Idistrict__13 _Idistrict__14 _Idistrict__15 ///
        _Idistrict__16 _Idistrict__17 _Idistrict__18 _Idistrict__19 ///
        _Idistrict__20 _Idistrict__21 _Idistrict__22 _Idistrict__23 ///
        _Idistrict__24  _Idistrict__26 _Idistrict__27 ///
        _Idistrict__28 _Idistrict__29 _Idistrict__30 _Idistrict__31 ///
        _Idistrict__32 _Idistrict__33 _Idistrict__34 _Idistrict__35 ///
        _Idistrict__36 _Idistrict__37 _Idistrict__38 _Idistrict__39 ///
        _Idistrict__40 _Idistrict__41 _Idistrict__42 _Idistrict__43 ///
        _Idistrict__44 _Idistrict__45 _Idistrict__46 _Idistrict__47 ///
        _Idistrict__48 _Idistrict__49 _Idistrict__50 _Idistrict__51 ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
      m_work_hours_pweek_3m_w  m_work_days_pweek_3m /// 
      using "$out_analysis/reg_02_OLS_FE_district_year.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Informal" "Industry" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
        drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 ln_nb_refugees_bygov _Iyear_2016 ///
        _Idistrict__2 _Idistrict__3 ///
        _Idistrict__4 _Idistrict__5 _Idistrict__6 _Idistrict__7 ///
        _Idistrict__8 _Idistrict__9 _Idistrict__10 _Idistrict__11 ///
        _Idistrict__12 _Idistrict__13 _Idistrict__14 _Idistrict__15 ///
        _Idistrict__16 _Idistrict__17 _Idistrict__18 _Idistrict__19 ///
        _Idistrict__20 _Idistrict__21 _Idistrict__22 _Idistrict__23 ///
        _Idistrict__24  _Idistrict__26 _Idistrict__27 ///
        _Idistrict__28 _Idistrict__29 _Idistrict__30 _Idistrict__31 ///
        _Idistrict__32 _Idistrict__33 _Idistrict__34 _Idistrict__35 ///
        _Idistrict__36 _Idistrict__37 _Idistrict__38 _Idistrict__39 ///
        _Idistrict__40 _Idistrict__41 _Idistrict__42 _Idistrict__43 ///
        _Idistrict__44 _Idistrict__45 _Idistrict__46 _Idistrict__47 ///
        _Idistrict__48 _Idistrict__49 _Idistrict__50 _Idistrict__51 ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results OLS Regression with time and district FE"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the locality level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m 


**********************
********* IV *********
**********************

/*
which ivreg2, all
adoupdate ivreg2, update
adoupdate ivreg2, update

ado uninstall ivreg2
ssc install ivreg2
*/


foreach globals of global globals_list {
  foreach outcome of global `globals' {
    xi: ivreg2  `outcome' ///
                i.year i.district_iid ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                ($dep_var = IHS_IV_SS) ///
                [pweight = expan_indiv], ///
                cluster(locality_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store m_`outcome', title(Model `outcome')

    * With equivalent first-stage
    gen smpl=0
    replace smpl=1 if e(sample)==1

    qui xi: reg $dep_var IHS_IV_SS ///
            i.year i.district_iid ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            if smpl == 1 [pweight = expan_indiv], ///
            cluster(locality_iid) robust
    estimates table, k(IHS_IV_SS) star(.1 .05 .01)    
    estimates store mIV_`outcome', title(Model `outcome')

    drop smpl 
  }
}



ereturn list
mat list e(b)
estout m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 ln_nb_refugees_bygov _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      using "$out_analysis/reg_03_IV_FE_district_year.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Informal" "Industry" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 ln_nb_refugees_bygov _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District and Year FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the locality level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m 
*m2 m3 m4 m5 

ereturn list
mat list e(b)
estout mIV_job_stable_3m mIV_informal mIV_wp_industry_jlmps_3m ///
      mIV_member_union_3m mIV_skills_required_pjob  ///
      mIV_IHS_total_rwage_3m  mIV_IHS_hourly_rwage ///
       mIV_work_hours_pweek_3m_w mIV_work_days_pweek_3m /// 
       , cells(b(star fmt(%9.1f)) se(par fmt(%9.1f))) ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 ln_nb_refugees_bygov _Iyear_2016 ///
        _Idistrict__2 _Idistrict__3 ///
        _Idistrict__4 _Idistrict__5 _Idistrict__6 _Idistrict__7 ///
        _Idistrict__8 _Idistrict__9 _Idistrict__10 _Idistrict__11 ///
        _Idistrict__12 _Idistrict__13 _Idistrict__14 _Idistrict__15 ///
        _Idistrict__16 _Idistrict__17 _Idistrict__18 _Idistrict__19 ///
        _Idistrict__20 _Idistrict__21 _Idistrict__22 _Idistrict__23 ///
        _Idistrict__24  _Idistrict__26 _Idistrict__27 ///
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
esttab mIV_job_stable_3m mIV_informal mIV_wp_industry_jlmps_3m ///
      mIV_member_union_3m mIV_skills_required_pjob  ///
      mIV_IHS_total_rwage_3m  mIV_IHS_hourly_rwage ///
      mIV_work_hours_pweek_3m_w mIV_work_days_pweek_3m /// 
      using "$out_analysis/reg_03_IV_FE_district_year_stage1.tex", se label replace booktabs ///
      cells(b(star fmt(%9.1f)) se(par fmt(%9.1f))) ///
mtitles("Stable" "Informal" "Industry" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 ln_nb_refugees_bygov _Iyear_2016 ///
        _Idistrict__2 _Idistrict__3 ///
        _Idistrict__4 _Idistrict__5 _Idistrict__6 _Idistrict__7 ///
        _Idistrict__8 _Idistrict__9 _Idistrict__10 _Idistrict__11 ///
        _Idistrict__12 _Idistrict__13 _Idistrict__14 _Idistrict__15 ///
        _Idistrict__16 _Idistrict__17 _Idistrict__18 _Idistrict__19 ///
        _Idistrict__20 _Idistrict__21 _Idistrict__22 _Idistrict__23 ///
        _Idistrict__24  _Idistrict__26 _Idistrict__27 ///
        _Idistrict__28 _Idistrict__29 _Idistrict__30 _Idistrict__31 ///
        _Idistrict__32 _Idistrict__33 _Idistrict__34 _Idistrict__35 ///
        _Idistrict__36 _Idistrict__37 _Idistrict__38 _Idistrict__39 ///
        _Idistrict__40 _Idistrict__41 _Idistrict__42 _Idistrict__43 ///
        _Idistrict__44 _Idistrict__45 _Idistrict__46 _Idistrict__47 ///
        _Idistrict__48 _Idistrict__49 _Idistrict__50 _Idistrict__51 ///
        _cons $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results Stage 1 IV Regression with District and Year FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the locality level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop mIV_job_stable_3m mIV_informal mIV_wp_industry_jlmps_3m ///
      mIV_member_union_3m mIV_skills_required_pjob  ///
      mIV_IHS_total_rwage_3m  mIV_IHS_hourly_rwage ///
       mIV_work_hours_pweek_3m_w mIV_work_days_pweek_3m 


******************************************************************************************
  *****    M3:  YEAR FE / DISTRICT FE / SECOTRAL FE / CONTROL NUMBER OF REFUGEE   ******
******************************************************************************************

**********************
********* OLS ********
**********************
/*
foreach globals of global globals_list {
  foreach outcome of global `globals' {
    qui xi: reg `outcome' $dep_var ///
            i.district_iid i.year i.sector_3m ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            [pweight = expan_indiv],  ///
            cluster(locality) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01)
  }
}
*/
**********************
********* IV *********
**********************

foreach globals of global globals_list {
  foreach outcome of global `globals' {
    qui xi: ivreg2  `outcome' ///
                i.year i.district_iid i.sector_3m ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                ($dep_var = IHS_IV_SS) ///
                [pweight = expan_indiv], ///
                cluster(locality_iid) ///
                partial(i.district_iid i.sector_3m) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store m_`outcome', title(Model `outcome')

    * With equivalent first-stage
    gen smpl=0
    replace smpl=1 if e(sample)==1

    qui xi: reg $dep_var IHS_IV_SS ///
            i.year i.district_iid i.sector_3m ///
            $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            if smpl == 1 [pweight = expan_indiv], ///
            cluster(locality_iid) robust
    estimates table,  k(IHS_IV_SS) star(.1 .05 .01)          
    drop smpl 
  }
}


ereturn list
mat list e(b)
estout m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 ln_nb_refugees_bygov _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      using "$out_analysis/reg_04_IV_FE_district_year_sector.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Informal" "Industry" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 ln_nb_refugees_bygov _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District, Year and Sector FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the locality level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m 


          ***********************************************************************
            *****    M4:  YEAR FE / INDIV FE / CONTROL NUMBER OF REFUGEE    *****
          ***********************************************************************

**********************
********* OLS ********
**********************
/*
preserve
foreach globals of global globals_list {
  foreach outcome_l1 of global `globals' {
      foreach outcome_l2 of global  `globals' {
       qui reghdfe `outcome_l2' $dep_var ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                [pw=expan_indiv], ///
                absorb(year indid_2010) ///
                cluster(locality_iid) 
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
      qui reg `outcome_l1' $dep_var $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov [pw=expan_indiv], cluster(locality_iid) robust
      codebook `outcome_l1', c
      estimates table,  k($dep_var) star(.1 .05 .01)           
    }
  }
restore
*/



**********************
********* IV *********
**********************

preserve
foreach globals of global globals_list {
  foreach outcome of global `globals'  {     
      codebook `outcome', c
      qui xi: ivreg2 `outcome' ///
                    i.year i.district_iid ///
                    $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                    ($dep_var = IHS_IV_SS) ///
                    [pweight = expan_indiv], ///
                    cluster(locality_iid) robust ///
                    partial(i.district_iid) 

        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
        foreach y in `outcome' $controls $dep_var IHS_IV_SS educ1d fteducst mteducst ftempst ln_nb_refugees_bygov {
          qui reghdfe `y' [pw=expan_indiv] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
          qui rename `y' o_`y'
          qui rename `y'_c2wr `y'
        }
        qui ivreg2 `outcome' ///
               $controls educ1d fteducst mteducst ftempst ln_nb_refugees_bygov ///
               ($dep_var = IHS_IV_SS) ///
               [pweight = expan_indiv], ///
               cluster(locality_iid) robust ///
               first 
      estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
      estimates store m_`outcome', title(Model `outcome')
        qui drop `outcome' $dep_var IHS_IV_SS $controls educ1d fteducst mteducst ftempst smpl ln_nb_refugees_bygov
        foreach y in `outcome' $controls  $dep_var IHS_IV_SS educ1d fteducst mteducst ftempst ln_nb_refugees_bygov  {
          qui rename o_`y' `y' 
        }
    }
  }
restore                


ereturn list
mat list e(b)
estout m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m  ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender hhsize educ1d fteducst mteducst ftempst _cons ///
       ln_nb_refugees_bygov  $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

esttab m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m  ///
      using "$out_analysis/reg_05_IV_FE_year_indiv.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Informal" "Industry" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
 drop(age age2 gender hhsize  educ1d fteducst mteducst ftempst ///
      ln_nb_refugees_bygov _cons ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with Year and Individual FE"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the locality level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_informal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_IHS_total_rwage_3m  m_IHS_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m 









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


*drop if miss_16_10 == 1
drop if unemp_16_10 == 1
drop if olf_16_10 == 1
*drop if emp_16_miss_10 == 1
*drop if emp_10_miss_16 == 1
*drop if unemp_16_miss_10 == 1
*drop if unemp_10_miss_16 == 1
*drop if olf_16_miss_10 == 1
*drop if olf_10_miss_16 == 1 
drop if emp_10_olf_16  == 1 
drop if emp_16_olf_10  == 1 
drop if unemp_10_emp_16  == 1 
drop if unemp_16_emp_10  == 1 
drop if olf_10_unemp_16 == 1 
drop if olf_16_unemp_10  == 1 


            ***********************************************************************
              ***** M2: YEAR FE / DISTRICT FE / CONTROL NUMBER OF REFUGEE   *****
            ***********************************************************************


**********************
********* IV *********
**********************

  foreach outcome of global outcome_var_empl {
    qui xi: ivreg2  `outcome' ///
                i.year i.district_iid ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                ($dep_var = IHS_IV_SS) ///
                [pweight = expan_indiv], ///
                cluster(locality_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout m_employed_3m m_unemployed_3m m_unempdurmth  ///
    m_IHS_b_rwage_unolf m_IHS_b_rwage_unemp m_IHS_t_rwage_unolf ///
    m_IHS_t_rwage_unemp ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 ln_nb_refugees_bygov _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_employed_3m m_unemployed_3m m_unempdurmth  ///
    m_IHS_b_rwage_unolf m_IHS_b_rwage_unemp m_IHS_t_rwage_unolf ///
    m_IHS_t_rwage_unemp ///
      using "$out_analysis/reg_03_IV_FE_district_year_empl.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "Duration Unemp" "Basic W OLF" "Basic W" "Total W OLF" "Total W") ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 ln_nb_refugees_bygov _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District and Year FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the locality level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_employed_3m m_unemployed_3m m_unempdurmth  ///
    m_IHS_b_rwage_unolf m_IHS_b_rwage_unemp m_IHS_t_rwage_unolf ///
    m_IHS_t_rwage_unemp 




************************************************
//  SUMMARY STATISTICS
************************************************




use "$data_final/05_IV_JLMPS_MergingIV.dta", clear

keep if nationality_cl == 2 
bys year: su IV_SS


use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear


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

/*
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


bys year: su job_stable_3m //  From usstablp - Stability of employement (3m) - 1 permanent - 0 temp, seas, cas
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


log close


