

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
*drop if nationality_cl != 1


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

codebook $dep_var
lab var $dep_var "Agg WP"

** HETEROG 

***************
* WP INDUSTRY *
***************

/*
Number of outcomes among the employed,

[NB: We undertook sensitivity analysis as to whether analyzing these outcomes
unconditional on employment, rather than among the employed, changed our
results; it did not lead to substantive changes (results available from authors on
request).]*/

codebook wp_industry_jlmps_3m
lab def wp_industry_jlmps_3m 0 "Close" 1 "Open",modify 
lab val wp_industry_jlmps_3m wp_industry_jlmps_3m
lab var wp_industry_jlmps_3m "Open"

gen inter_open = wp_industry_jlmps_3m*$dep_var 
gen inter_open_IV = wp_industry_jlmps_3m*$IV_var 
lab var inter_open "Agg WP x Open"

  foreach outcome of global outcome_cond  {  
     xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
       (c.$dep_var inter_open = c.$IV_var inter_open_IV) ///
       wp_industry_jlmps_3m ///       
       [pweight = panel_wt_10_16], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k($dep_var inter_open wp_industry_jlmps_3m) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var inter_open wp_industry_jlmps_3m) 
    estimates store m_`outcome', title(Model `outcome')
  } 

ereturn list
mat list e(b)
estout m_job_stable_3m m_formal ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6  _Iyear_2016  ///
         $controls )   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_formal ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      using "$out_analysis/reg_hetero_open_close.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6  _Iyear_2016  ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Heterogenous INDUSTRY - IV Regression, District, Year FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_formal  ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m 
*m2 m3 m4 m5 



**********
* GENDER *
**********


codebook gender
lab var gender "Male"

gen inter_gender = gender*$dep_var 
gen inter_gender_IV = gender*$IV_var  
lab var inter_gender "Agg WP x Male"


  foreach outcome of global outcome_cond  {  
    qui xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       age age2 hhsize i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
       (c.$dep_var inter_gender = c.$IV_var inter_gender_IV) ///
       gender ///       
       [pweight = panel_wt_10_16], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k($dep_var inter_gender gender) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var inter_gender gender) 
    estimates store m_`outcome', title(Model `outcome')
  } 


ereturn list
mat list e(b)
estout m_job_stable_3m m_formal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)))  ///
  drop(age age2 hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
       ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6  _Iyear_2016 ///
        age age2 hhsize)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_formal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      using "$out_analysis/reg_hetero_gender.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Open" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
  drop(age age2 hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
       ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6  _Iyear_2016 ///
         age age2 hhsize) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Heterogenous GENDER - IV Regression, District, Year FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_formal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m 
*m2 m3 m4 m5 




*********************
* EDUCATION *
*************

tab bi_education, m 
codebook bi_education
lab var bi_education "High Education"


gen inter_bi_education = bi_education*$dep_var 
gen inter_bi_education_IV = bi_education*$IV_var 
lab var inter_bi_education "Agg WP x High Education"


  foreach outcome of global outcome_cond {  
    qui xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       $controls i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov  ///
       (c.$dep_var inter_bi_education = c.$IV_var inter_bi_education_IV) ///
       bi_education ///       
       [pweight = panel_wt_10_16], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k($dep_var inter_bi_education bi_education) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var inter_bi_education bi_education) 
    estimates store m_`outcome', title(Model `outcome')
  } 

ereturn list
mat list e(b)
estout m_job_stable_3m m_formal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender hhsize _Ifteducst_2 ///
       ln_nb_refugees_bygov _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6  _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_formal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      using "$out_analysis/reg_hetero_educ.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Open" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
  drop(age age2 gender hhsize _Ifteducst_2 ///
      ln_nb_refugees_bygov  _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6  _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Heterogenous EDUCATION - IV Regression, District, Year FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_formal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m 
*m2 m3 m4 m5 



*********************
* FORMAL *
*************

codebook formal
tab formal
lab var formal "Formal"

gen inter_formal = formal*$dep_var 
gen inter_formal_IV = formal*$IV_var 
lab var inter_formal "Agg WP x Formal"

  foreach outcome of global outcome_cond  {  
    qui xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
       (c.$dep_var inter_formal = c.$IV_var inter_formal_IV) ///
       formal ///       
       [pweight = panel_wt_10_16], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k($dep_var inter_formal formal) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var inter_formal formal) 
    estimates store m_`outcome', title(Model `outcome')
  } 


ereturn list
mat list e(b)
estout m_job_stable_3m m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m ///
      , cells(b(star fmt(%9.2f)) se(par fmt(%9.2f))) ///
  drop(age age2 gender hhsize  _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7  _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6  _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      using "$out_analysis/reg_hetero_formal.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Open" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
  drop(age age2 gender hhsize  _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7  _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6  _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Heterogenous FORMAL - IV Regression, District, Year FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_formal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m 
*m2 m3 m4 m5 




*********************
* PRIVATE *
*************

codebook private
tab private
lab var private "Private"

gen inter_private = private*$dep_var 
gen inter_private_IV = private*$IV_var 
lab var inter_private "Agg WP x Private"

  foreach outcome of global outcome_cond {  
    qui xi: ivreg2  `outcome'  ///
       i.year i.district_iid ///
       $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
       (c.$dep_var inter_private = c.$IV_var inter_private_IV) ///
       private ///       
       [pweight = panel_wt_10_16], ///
       cluster(district_iid) robust ///
       partial(i.district_iid) ///
       first
    codebook `outcome', c
    estimates table,  k($dep_var inter_private private) star(.1 .05 .01) b(%7.4f)
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var inter_private private) 
    estimates store m_`outcome', title(Model `outcome')
  } 


ereturn list
mat list e(b)
estout m_job_stable_3m m_formal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m ///
      , cells(b(star fmt(%9.2f)) se(par fmt(%9.2f))) ///
  drop(age age2 gender hhsize  _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7  _Ifteducst_2 ///
       ln_nb_refugees_bygov _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6  _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_formal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      using "$out_analysis/reg_hetero_private.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Open" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
  drop(age age2 gender hhsize  _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
       ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7  _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6  _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Heterogenous PRIVATE - IV Regression, District, Year FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_formal m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m 
*m2 m3 m4 m5 






log close
