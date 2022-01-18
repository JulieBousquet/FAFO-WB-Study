
cap log close
clear all
set more off, permanently
set mem 100m

log using "$out_analysis/06_Robsutness.log", replace

   ****************************************************************************
   **                            DATA JLMPS                                  **
   **              				   ROBUSTNESS ANALYSIS                             **  
   ** ---------------------------------------------------------------------- **
   ** Type Do  :  DATA JLMPS ROBUSTNESS ANALYSIS REGRESSION                  **
   **                                                                        **
   ** Authors  : Julie Bousquet                                              **
   ****************************************************************************


use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear


***********************************************************************
**DEFINING THE SAMPLE *************************************************
***********************************************************************



*********


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

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year
                                  ************
                                  *   PANEL  *
                                  ************

* SET THE PANEL STRUCTURE
xtset, clear 
*xtset year
xtset indid_2010 year 


/*
 								  ************
                                  *REGRESSION*
                                  ************


         ****************************************************************************
         ***** Controlling for c.distance_dis_camp##i.year or usig it as an IV ******
         ****************************************************************************

sum distance_dis_camp year
gen d2016=0
replace d2016=1 if year==2016
gen ldistance_dis_camp=log(distance_dis_camp)
gen inter_dist=ldistance_dis_camp*d2016

sum $controls 

*with the distance to the border $\times$ sector dummy 
xi: ivreg2 ln_basic_rwage_3m ///
    i.year i.district_iid i.crsectrp i.educ1d ///
    i.fteducst i.mteducst age age2 sex hhsize ///
    ($dep_var ln_nb_refugees_bygov= IV_SS_5 inter_dist) ///
    [pweight = panel_wt_10_16], ///
     liml cluster(district_iid) ///
     partial(i.district_iid  i.crsectrp) 
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

*the border $\times$ time dummy
gen interact =  inter_dist*crsectrp

xi: ivreg2 ln_basic_rwage_3m ///
    i.year i.district_iid i.crsectrp i.educ1d ///
    i.fteducst i.mteducst age age2 sex hhsize i.inter_dist i.interact ///
    ($dep_var = $dep_var) ///
    [pweight = panel_wt_10_16], ///
     liml cluster(district_iid) ///
     partial(i.district_iid  i.crsectrp) 
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store m_`outcome', title(Model `outcome')



*$dep_var ln_nb_refugees_bygov = IV_SS_5 ln_IV_SS_ref_inflow)

* The REFUGEE INFLOW ONLY 
    xi: ivreg2 formal  ///
                i.year i.district_iid ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst  ///
                (ln_nb_refugees_bygov = ln_IV_SS_ref_inflow) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook formal, c
    estimates table, k(ln_nb_refugees_bygov) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k(ln_nb_refugees_bygov) 

    * With equivalent first-stage
    gen smpl=0
    replace smpl=1 if e(sample)==1

    xi: reg ln_nb_refugees_bygov ln_IV_SS_ref_inflow ///
            i.year i.district_iid  ///
            $controls i.educ1d i.fteducst i.mteducst i.ftempst  ///
            if smpl == 1 [pweight = panel_wt_10_16], ///
            cluster(district_iid) robust
    estimates table,  k(ln_IV_SS_ref_inflow) star(.1 .05 .01)           
    drop smpl 

corr ln_nb_refugees_bygov ln_IV_SS_ref_inflow

*/




                                  ************
                                  *REGRESSION*
                                  ************


            ***********************************************************************
              ***** M2: YEAR FE / DISTRICT FE / 2 IVs Nb Refugees and WP   *****
            ***********************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year 
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

keep if emp_16_10 == 1 

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

xtset, clear 
xtset indid_2010 year 

lab var $dep_var "Work Permits"
lab var IV_SS_ref_inflow "LOG IV Nb Refugees"

tab nb_refugees_bygov
tab IV_SS_ref_inflow

  foreach outcome of global outcome_cond {
     xi: ivreg2  `outcome' ///
                i.year i.district_iid ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst  ///
                ($dep_var ln_nb_refugees_bygov = $IV_var IV_SS_ref_inflow) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var ln_nb_refugees_bygov) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var ln_nb_refugees_bygov) 
    estimates store m_`outcome', title(Model `outcome')
	}

ereturn list
mat list e(b)
estout m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      using "$out_analysis/ROB_reg_m3_2IVs.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Industry" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6  _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Nb Refugee and WP Regression with District and Year FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m 
*m2 m3 m4 m5 

*/

            ***********************************************************************
              ***** M2: YEAR FE / DISTRICT FE / NO CONTROL Nb of Refugee   *****
            ***********************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year 
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

keep if emp_16_10 == 1 

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

xtset, clear 
xtset indid_2010 year 


lab var ln_nb_refugees_bygov "LOG Nb Refugees"
lab var $dep_var "Work Permits"
lab var ln_IV_SS_ref_inflow "LOG IV Nb Refugees"

tab ln_nb_refugees_bygov
tab ln_IV_SS_ref_inflow

*control AGG_WP  

  foreach outcome of global outcome_cond {
    xi: ivreg2  `outcome' ///
                i.district_iid i.year ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst  ///
                ($dep_var = $IV_var) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) 
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store m_`outcome', title(Model `outcome')
  }


ereturn list
mat list e(b)
estout m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      using "$out_analysis/ROB_reg_m3_NOCTRL_REF.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Industry" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District and Year FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
       m_work_hours_pweek_3m_w m_work_days_pweek_3m 
*m2 m3 m4 m5 









/******************************
CONTROL FOR CONFLICT SPILLOVERS
*******************************/


use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year , m 

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

keep if emp_16_10 == 1 

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

xtset, clear 
destring indid_2010 , replace
xtset indid_2010 year 

codebook $dep_var
lab var $dep_var "Work Permits"

*****************************
* 1. 1/distance to border*dt
*****************************

tab distance_dis_camp year 

preserve
keep distance_dis_camp indid_2010 year
reshape wide distance_dis_camp, i(indid_2010) j(year)

replace distance_dis_camp2010 = distance_dis_camp2016 

reshape long distance_dis_camp, i(indid_2010) j(year)
format indid_2010 %12.0g

tempfile data_distcamp
save `data_distcamp'
restore 

drop distance_dis_camp 
merge 1:1 indid_2010 year using  `data_distcamp'
drop _merge 

tab distance_dis_camp year 

gen d2016 = 1 if year == 2016
replace d2016 = 0 if year == 2010
gen dist_year = distance_dis_camp*d2016
tab dist_year, m 


  foreach outcome of global outcome_cond {
    xi: ivreg2  `outcome' ///
                i.district_iid i.year ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ///
                dist_year ln_nb_refugees_bygov ///
                ($dep_var = $IV_var) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) 
   codebook `outcome', c
    estimates table, k($dep_var dist_year) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var dist_year) 
    estimates store m_`outcome', title(Model `outcome')
 }



ereturn list
mat list e(b)
estout m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      using "$out_analysis/ROB_reg_IV_FE_district_year_DISTANCE_TIME.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Private" "Open" "Union" "Skills" "Total W"  "Hourly W" "WH pweek" "WD pweek") ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District, Year and Sector FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m 


/*

         ****************************************************************************
         ***** Controlling for c.distance_dis_camp##i.year or usig it as an IV ******
         ****************************************************************************

sum distance_dis_camp year
gen d2016=0
replace d2016=1 if year==2016
gen ldistance_dis_camp=log(distance_dis_camp)
gen inter_dist=ldistance_dis_camp*d2016

sum $controls 

*with the distance to the border $\times$ sector dummy 
xi: ivreg2 ln_basic_rwage_3m ///
    i.year i.district_iid i.crsectrp i.educ1d ///
    i.fteducst i.mteducst age age2 sex hhsize ///
    ($dep_var ln_nb_refugees_bygov= IV_SS_5 inter_dist) ///
    [pweight = panel_wt_10_16], ///
     liml cluster(district_iid) ///
     partial(i.district_iid  i.crsectrp) 
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 

*the border $\times$ time dummy
gen interact =  inter_dist*crsectrp

xi: ivreg2 ln_basic_rwage_3m ///
    i.year i.district_iid i.crsectrp i.educ1d ///
    i.fteducst i.mteducst age age2 sex hhsize i.inter_dist i.interact ///
    ($dep_var = $dep_var) ///
    [pweight = panel_wt_10_16], ///
     liml cluster(district_iid) ///
     partial(i.district_iid  i.crsectrp) 
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store m_`outcome', title(Model `outcome')


*/

***************************************************************************
* 2. 1/distance to Syrian governorate*intensity of conflict in governorate
***************************************************************************

*** GET DATA IN 2010 **



/*
ACLED
"Raleigh, Clionadh, Andrew Linke, Håvard Hegre and Joakim Karlsen. (2010). 
“Introducing ACLED-Armed Conflict Location and Event Data.” 
Journal of Peace Research 47(5) 651-660."
key : pjAwSYakTpR0iRErpG3x
*/


/*
import excel using "$data_ACLED_base/Acled - Syria - 2009-01-01-2017-01-31.xlsx", firstrow clear

ren admin1 governorate_syria
list governorate_syria 

replace governorate_syria = "Al Raqqah" if governorate_syria == "Ar Raqqa"
replace governorate_syria = "Al Suwayda" if governorate_syria == "As Sweida"
replace governorate_syria = "Daraa" if governorate_syria == "Dara"
replace governorate_syria = "Deir El Zour" if governorate_syria == "Deir ez Zor"
replace governorate_syria = "Idlib" if governorate_syria == "Idleb"
replace governorate_syria = "Rural Damascus" if governorate_syria == "Damascus Rural"
replace governorate_syria = "Al Hasakah" if governorate_syria == "Al Hasakeh"


sort governorate_syria 
egen id_gov_syria = group(governorate_syria)

gen conflict = 1 if !mi(event_type)
collapse (sum) conflict, by(year id_gov_syria)


merge m:m id_gov_syria using "$data_temp/04_IV_Share_Empl_Syria" 

*Distance between governorates syria and districts jordan
geodist district_lat district_long gov_syria_lat gov_syria_long, gen(distance_dis_gov)
tab distance_dis_gov, m
lab var distance_dis_gov "Distance (km) between JORD districts and SYR centroid governorates"

unique distance_dis_gov //714

drop district_long district_lat gov_syria_long gov_syria_lat
sort district_en governorate_syria 

drop id_district_jordan 
egen district_iid = group(district_en) 

list id_gov_syria governorate_syria
sort district_en governorate_syria industry_id


drop if district_en == "Husseiniyyeh District"
distinct district_iid 

collapse (sum) distance_dis_gov, by(district_iid)

merge 1:m district_iid using "$data_final/06_IV_JLMPS_Construct_Outcomes.dta"



tab nationality_cl year , m 

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

keep if emp_16_10 == 1 

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

xtset, clear 
destring indid_2010 , replace
xtset indid_2010 year 

codebook $dep_var
lab var $dep_var "Work Permits"

tab distance_dis_gov year 

*duplicates drop governorate_syria, force
*list id_gov_syria governorate_syria


foreach outcome of global outcome_cond {
    xi: ivreg2  `outcome' ///
                i.district_iid i.year ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ///
                ln_nb_refugees_bygov ///
                distance_dis_gov ///
                ($dep_var = $IV_var) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store m_`outcome', title(Model `outcome')
  }
*/



************* 

/******************************
CONTROL PRIVATE / PUBLIC SECTOR
*******************************/

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year , m 

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

keep if emp_16_10 == 1 

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

xtset, clear 
destring indid_2010 , replace
xtset indid_2010 year 

codebook $dep_var
lab var $dep_var "Work Permits"


gen d2016 = 1 if year == 2016
replace d2016 = 0 if year == 2010
gen private_dt = private*d2016
tab private_dt, m 
tab private_dt year 

  foreach outcome of global outcome_cond {
     xi: ivreg2  `outcome' ///
                i.year i.district_iid  ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ///
                ln_nb_refugees_bygov ///
                i.private_dt ///
                ($dep_var = $IV_var) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) ///
                partial(i.district_iid) 
    codebook `outcome', c
    estimates table, k($dep_var _Iprivate_d_1) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var _Iprivate_d_1) 
    estimates store m_`outcome', title(Model `outcome')
  }


ereturn list
mat list e(b)
estout m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      using "$out_analysis/ROB_reg_IV_FE_district_year_PRIVATE_TIME.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Private" "Open" "Union" "Skills" "Total W"  "Hourly W" "WH pweek" "WD pweek") ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District, Year and Sector FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 



/******************************
CONTROL ALL SECTORS - OCCUPATION
*******************************/

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year , m 

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

keep if emp_16_10 == 1 

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

xtset, clear 
destring indid_2010 , replace
xtset indid_2010 year 

codebook $dep_var
lab var $dep_var "Work Permits"

gen d2016 = 1 if year == 2016
replace d2016 = 0 if year == 2010
gen open_dt = wp_industry_jlmps_3m*d2016
tab open_dt, m 
tab open_dt year 

  foreach outcome of global outcome_cond {
    xi: ivreg2  `outcome' ///
                i.year i.district_iid  ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ///
                 ln_nb_refugees_bygov ///
                 i.open_dt ///
                ($dep_var = $IV_var) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) ///
                partial(i.district_iid) 
    codebook `outcome', c
    estimates table, k($dep_var _Iopen_dt_1) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var  _Iopen_dt_1) 
    estimates store m_`outcome', title(Model `outcome')

  }


ereturn list
mat list e(b)
estout m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_job_stable_3m m_formal m_private m_wp_industry_jlmps_3m ///
      m_member_union_3m m_skills_required_pjob  ///
      m_ln_total_rwage_3m  m_ln_hourly_rwage ///
      m_work_hours_pweek_3m_w m_work_days_pweek_3m /// 
      using "$out_analysis/ROB_reg_IV_FE_district_year_OPEN_TIME.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Private" "Open" "Union" "Skills" "Total W"  "Hourly W" "WH pweek" "WD pweek") ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        ln_nb_refugees_bygov _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6 _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District, Year and Sector FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 



















          ***********************************************************************
            *****    M4:  PARTIAL OUT + SCATTER    *****
          ***********************************************************************

/*INSTRUCTION: I suggest we partial out both variables (meaning we store the residuals 
from specification where we regress both variables on fixed effects and then use scatter plot, 
fitted line, and eventually a non-parametric line).*/

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year 
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

keep if emp_16_10 == 1 

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

xtset, clear 
xtset indid_2010 year 

reg $dep_var i.district_iid i.year  [pweight = panel_wt_10_16], cluster(district_iid) robust 
predict dep_var_res
tab dep_var_res

reg $IV_var i.district_iid i.year   [pweight = panel_wt_10_16], cluster(district_iid) robust 
predict iv_var_res
tab iv_var_res
*winsor2 iv_var_res, replace cuts(0 90)
tab iv_var_res
reg dep_var_res iv_var_res

twoway (scatter dep_var_res iv_var_res, mcolor(gray) msize(small) legend(label(1 "Fitted Values"))) ///
(lfit dep_var_res iv_var_res, lwidth(thick) legend(label(2 "Linear Prediction"))) ///
, graphregion(color(white))

*|| (lpoly dep_var_res iv_var_res, lwidth(thick)  kernel(epan2) degree(4) legend(label(3 "Local Poly"))) ///
*|| (fpfit dep_var_res iv_var_res, lwidth(thick) legend(label(4 "Fractional Poly"))) ///


graph export "$out_analysis\fitted_values_IVres.png", as(png) replace


/*
twoway scatter dep_var_res iv_var_res || lfit dep_var_res iv_var_res

*ssc des krls
*net install krls

twoway (scatter dep_var_res iv_var_res, mcolor(gray) msize(small)) ///
|| (lfit dep_var_res iv_var_res, lcolor(black) lwidth(thick)) ///
, legend(off) graphregion(color(white))

twoway (scatter dep_var_res iv_var_res, mcolor(gray) msize(small)) ///
|| (lpoly dep_var_res iv_var_res, kernel(epan2) degree(4) lcolor(black) lwidth(thick)) ///
, legend(off) graphregion(color(white))

twoway (scatter dep_var_res iv_var_res, mcolor(gray) msize(small)) ///
|| (lowess dep_var_res iv_var_res, lcolor(black) lwidth(thick)) ///
, legend(off) graphregion(color(white))
*/

/*
Lowess smoothing
fpfit fractional polynomial plot
linear prediction plot
local polynomial smooth plot
*/






log close









***********************************
** WORK IN PROGRESS **









/*
*************

import excel "$data_UNHCR_base\Datasets_WP_RegisteredSyrians.xlsx", sheet("WP - byIndustry") firstrow clear

keep year_2016 year_2020 Activity

ren year_2020 wp_2020
ren year_2016 wp_2016
ren Activity industry_orig
gen industry_en = ""
replace industry_en = "agriculture" if industry_orig == "Agriculture, forestry, and fishing "
replace industry_en = "industry" if industry_orig == "Mining and quarrying "
replace industry_en = "industry" if industry_orig == "Manufacturing "
replace industry_en = "industry" if industry_orig == "Electricity, gas, steam and air conditioning "
replace industry_en = "industry" if industry_orig == "Water supply, sewage, waste management activities "
replace industry_en = "construction" if industry_orig == "Construction "
replace industry_en = "industry" if industry_orig == "Wholesale and retail trade; repair of motor vehicles "
replace industry_en = "transportation" if industry_orig == "Transportation and storage "
replace industry_en = "food" if industry_orig == "Hospitality and food service activities "
replace industry_en = "services" if industry_orig == "Information and communication "
replace industry_en = "banking" if industry_orig == "Financial and insurance activities "
replace industry_en = "banking" if industry_orig == "Real estate activities "
replace industry_en = "services" if industry_orig == "Professional, scientific and technical activities "
replace industry_en = "services" if industry_orig == "Administrative and support service activities "
replace industry_en = "services" if industry_orig == "Public administration and defense; compulsory social "
replace industry_en = "services" if industry_orig == "Education "
replace industry_en = "services" if industry_orig == "Human health and social work activities "
replace industry_en = "services" if industry_orig == "Arts, entertainment and recreation "
replace industry_en = "services" if industry_orig == "Other service activities "

drop if mi(industry_en)
*It removes the Self employed jobs 

collapse (sum) wp_2016 wp_2020, by(industry_en)
*Harmonize based on Syrian classification of industries

sort industry_en 
gen industry_id = _n
list industry_id industry_en 

/*    +---------------------------+
     | indust~d      industry_en |
     |---------------------------|
  1. |        1      agriculture |
  2. |        2          banking |
  3. |        3     construction |
  4. |        4             food |
  5. |        5         industry |
     |---------------------------|
  6. |        6         services |
  7. |        7   transportation |
     +---------------------------+
*/
save "$data_2020_temp/UNHCR_shift_byOccup_16-20.dta", replace 
*/



****************************
/*
use "$data_temp/04_IV_geo_empl_Syria", clear 

*use "$data_2020_final/Jordan2020_geo_Syria.dta", clear 
*tab id_gov_syria

geodist district_lat district_long gov_syria_lat gov_syria_long, gen(distance_dis_gov)
tab distance_dis_gov, m
lab var distance_dis_gov "Distance (km) between JORD districts and SYR centroid governorates"

unique distance_dis_gov //140

drop district_long district_lat gov_syria_long gov_syria_lat
sort district_en governorate_syria 

drop id_district_jordan 
egen id_district_jordan = group(district_en) 

list id_gov_syria governorate_syria
sort district_en governorate_syria industry_id

tab industry_en industry_id
drop industry_id 
egen industry_id = group(industry_en)

merge m:1 industry_id using  "$data_temp/05_IV_shift_byIndus.dta"
*merge m:1 industry_id using  "$data_2020_temp/UNHCR_shift_byOccup_16-20.dta"
drop _merge 

ren share share_empl_syr 

order id_gov_syria governorate_syria id_district_jordan district_en industry_id industry_en share_empl_syr wp_2020

lab var id_gov_syria "ID Governorate Syria"
lab var governorate_syria "Name Governorate Syria"
lab var id_district_jordan "ID District Jordan"
lab var district_en "Name District Jordan"
lab var industry_id "ID Industry"
lab var industry_en "Name Industry"
lab var share_empl_syr "Share Employment over Governorates Syria"
lab var wp_2020 "WP in Jordan by industry"
lab var distance_dis_gov "Distance Districts Jordan to Governorates Syria"

sort id_gov_syria district_en industry_id

/* STANDARD SS IV
gen IV_SS = (wp_2020*share_empl_syr)/distance_dis_gov 
collapse (sum) IV_SS, by(district_en)
lab var IV_SS "IV: Shift Share"
\*/
*save "$data_2020_final/Jordan2020_IV", replace 

tab district_en, m
sort district_en
egen district_id = group(district_en) 

*bys id_gov_syria: gen IV_SS = (wp_2020*share_empl_syr)/distance_dis_gov 
preserve
bys id_gov_syria: gen IV_share = share_empl_syr/distance_dis_gov 
*collapse (sum) IV_share, by(id_gov_syria district_en) //SHARE BY GOV
*reshape wide IV_share, i(district_en) j(id_gov_syria)

collapse (sum) IV_share, by(industry_id district_en)
reshape wide IV_share, i(district_en) j(industry_id)

tab district_en, m
sort district_en
egen district_id = group(district_en) 

tempfile shares
save `shares'
restore

merge m:1 district_id using `shares'
drop _merge 

preserve
*br id_gov_syria district_en wp_2020 industry_en industry_id
sort district_en id_gov_syria industry_en
ren wp_2020 IV_shifts
gen n = _n
collapse (sum) n, by(district_en IV_shifts)
drop n 
gen industry_id = .
replace industry_id = 1 if IV_shifts == 12270
replace industry_id = 2 if IV_shifts == 12
replace industry_id = 3 if IV_shifts == 9402
replace industry_id = 4 if IV_shifts == 1647
replace industry_id = 5 if IV_shifts == 4139
replace industry_id = 6 if IV_shifts == 2223
replace industry_id = 7 if IV_shifts == 93

reshape wide IV_shifts, i(district_en) j(industry_id)

tab district_en, m
sort district_en
egen district_id = group(district_en) 

tempfile shifts
save `shifts'
restore

merge m:1 district_id using `shifts'
drop _merge 
duplicates drop district_id, force

save "$data_temp/08_IV_robust", replace 

/*
**CONTROL: Number of refugees
import excel "$data_UNHCR_base/Datasets_WP_RegisteredSyrians.xlsx", sheet("WP_REF - byGov byYear") firstrow clear

tab Year
keep if Year == 2020 

sort Governorates
ren Governorates governorate_en
sort governorate_en
egen governorate_id = group(governorate_en)

save "$data_UNHCR_final/UNHCR_NbRef_byGov.dta", replace
*/

/*
*use "$data_2020_temp/Jordan2020_03_Compared.dta", clear
use "$data_2020_final/01_FAFO2020_Clean.dta", clear

tab governorate_en
drop if governorate_en == "Zarqa"
tab governorate
sort governorate_en
egen governorate_id = group(governorate_en)

tab district_en
sort district_en
egen district_id = group(district_en) 

gen year = 2020

*append using "$data_2014_final/Jordan2014_02_Clean.dta"
append using "$data_2014_final/01_FAFO2014_Clean.dta"
*/

use "$data_final/01_FAFO_14_20.dta", clear
keep hhid iid governorate_en governorate_id district_en district_id ///
		rsi_wage_income_lm_cont ros_employed rsi_work_hours_7d ///
		rsi_work_permit year
tab year 

merge m:1 district_id using "$data_temp/08_IV_robust.dta"
drop if _merge == 2
drop _merge

/*
merge m:1 governorate_id using "$data_UNHCR_final/UNHCR_NbRef_byGov.dta"
drop if _merge == 2
drop _merge
drop Year 
*/

bys year: tab governorate_en, m
bys year: tab district_en, m

/*
replace IV_shifts1 = 0 if year == 2014
replace IV_shifts2 = 0 if year == 2014
replace IV_shifts3 = 0 if year == 2014
replace IV_shifts4 = 0 if year == 2014
replace IV_shifts5 = 0 if year == 2014
replace IV_shifts6 = 0 if year == 2014
replace IV_shifts7 = 0 if year == 2014
br  IV_share* IV_shifts* district_en year
*/

local IV_share IV_share
local IV_shifts IV_shifts

*PROBLEM WITH MY MEMORE
gen n = _n 
drop if n > 6000

*CORE Instrument
*with time variation
forvalues t = 2014(6)2020 {
	foreach var of varlist `IV_share'* {
		gen t`t'_`var' = (year == `t') * `var'
		}
	foreach var of varlist `IV_shifts'* {
		gen t`t'_`var'b = `var' if year == `t'
		egen t`t'_`var' = max(t`t'_`var'b), by(district_en)
		drop t`t'_`var'b
		}
	}

replace rsi_work_permit = 0 if mi(rsi_work_permit) 

bartik_weight, 	z(t*_`IV_share'*) ///
				weightstub(t*_`IV_shifts'*) ///
				x(rsi_work_permit) ///
				y(rsi_wage_income_lm_cont) 


*drop if year == 2020

*without time varaition
/*
bartik_weight, 	z(`IV_share'*) ///
				weightstub(`IV_shifts'*) ///
				x(rsi_work_permit) ///
				y(rsi_wage_income_lm_cont) 
*/

mat beta = r(beta)
mat alpha = r(alpha)
mat gamma = r(gam)
mat pi = r(pi)
mat G = r(G)
desc `IV_share'*, varlist
local varlist = r(varlist)

clear
svmat beta
svmat alpha
svmat gamma
svmat pi
svmat G

gen ind = ""
*gen year = ""
local t = 1
foreach var in `varlist' {
	if regexm("`var'", "`IV_share'(.*)") {
		qui replace ind = regexs(1) if _n == `t'
		}
	local t = `t' + 1
	}

return list 

mat beta = r(beta)
mat alpha = r(alpha)
mat gamma = r(gam)
mat pi = r(pi)
mat G = r(G)

matrix list beta
matrix list alpha
matrix list gamma
matrix list pi 
matrix list G

/*
r(alpha): Rotemberg weight vector 
r(beta): just-identified coefficient vector
r(G): ghrowth weight vector   
*/

/*
Main
----
 y(varname): 			outcome variable: EMPLOYED        
 x(varname): 			endogeous variable: WORK PERMIT
 z(varlist): 			variable list of instruments: SHARE: INDUS COM IN SYR * DIST TO GOV  
 weightstub(varlist): 	variable list of weights : SHIFT: (1) REF WITH WP BY GOV (2) REF WITH WP BY INDUS

Options
-------                        
controls(varlist): 		list of control variables        
absorb(varname): 		fixed effect to absorb            
weight_var(varname): 	name of analytic weight variable for regression        
by(varname): 			name of the time variable that is interacted with the shares
*/



/* ANNA CODE !!!!!!!!!

foreach var of varlist `ind_stub'* {
	if regexm("`var'", "`ind_stub'(.*)") {
		local ind = regexs(1)
		} // extracts last part of the variable name: country name (e.g. "Somalia") and saved in local ind
	tempvar temp // define variable "temp" that will be constructed as variable below as temporary variable -> not to be saved in dataset when exiting Stata
	gen `temp' = `var' * `growth_stub'`ind' // constructing the z variable again (?), always for the share_countryX that matches the shift_countryX of same country X
	regress `x' `temp' `controls' [pweight=`weight'], cluster(ea) // first stage
	local pi_`ind' = _b[`temp'] // save first-stage beta coefficients
	test `temp'
	local F_`ind' = r(F) // save first-stage F-stat
	regress `y' `temp' `controls' [pweight=`weight'], cluster(ea) // reduced form
	local gamma_`ind' = _b[`temp'] // save reduced-form beta coefficients
	drop `temp'
	}

*/


*/
