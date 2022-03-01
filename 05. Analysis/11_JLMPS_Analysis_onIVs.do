

************************************************
// ALL THE IVS
************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

xtset, clear 
destring indid_2010 Findid, replace
mdesc indid_2010
xtset indid_2010 year 

codebook $dep_var
lab var $dep_var "Work Permits"


ren resc_IV_SS_1 IV_1 
ren resc_IV_SS_2 IV_2 
ren resc_IV_SS_3 IV_3 
ren resc_IV_SS_4 IV_4 

*global IVs  IV_1 IV_32 IV_3 IV_4

***************
*   SAMPLE *
*************** 

tab nationality_cl year 
*drop if nationality_cl != 1

*Keep only working age pop? 15-64 ? As defined by the ERF
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

keep if emp_16_10 == 1

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

cls 

*EXTRACT THE KP STAT
foreach IV of global IVs {
    codebook `IV', c
        qui xi: ivreg2  ln_total_rwage_3m ///
                    i.district_iid i.year ///
                    $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                    ($dep_var = `IV') ///
                    [pweight = panel_wt_10_16], ///
                    cluster(district_iid) robust ///
                    partial(i.district_iid) 
          estimates store m_`IV', title(Model `IV')

      }




ereturn list
mat list e(b)
estout  m_IV_1 m_IV_2 m_IV_3 m_IV_4 ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop($dep_var $fe _Iyear_2016 ln_nb_refugees_bygov  $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(rkf, fmt(0) label(KP-Stat))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

esttab  m_IV_1 m_IV_2 m_IV_3 m_IV_4  ///
      using "$out_analysis/IV_reg_KPStats.tex",  replace booktabs ///
mtitles("IV1" "IV3" "IV4" "IV5") nonumbers ///
 drop($dep_var $fe _Iyear_2016 ln_nb_refugees_bygov  $controls)  ///
    nofloat ///
   stats(rkf, fmt(0) labels("KP-Stat")) ///
    nonotes



* whpw wdpw 

cls 















**************
* MODEL 4 IVs*
**************


use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

xtset, clear 
destring indid_2010 Findid, replace
mdesc indid_2010
xtset indid_2010 year 

codebook $dep_var
lab var $dep_var "Work Permits"


*ren work_hours_pweek_3m_w whpw
*ren work_hours_pday_3m_w wdpw 

ren resc_IV_SS_1 IV_1 
ren resc_IV_SS_2 IV_2 
ren resc_IV_SS_3 IV_3 
ren resc_IV_SS_4 IV_4 


***************
*   SAMPLE *
*************** 

tab nationality_cl year 
*drop if nationality_cl != 1

*Keep only working age pop? 15-64 ? As defined by the ERF
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

keep if emp_16_10 == 1

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

cls 



foreach IV of global IVs {
    codebook `IV', c
  foreach outcome of global outcome_cond {
    qui xi: ivreg2  `outcome' ///
                i.district_iid i.year ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                ($dep_var = `IV') ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($dep_var) 
    estimates store `IV'_`outcome', title(Model `outcome')
  }
}

ereturn list
mat list e(b)
estout $IV_1_cond  ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop($fe _Iyear_2016 ln_nb_refugees_bygov $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(N r2_a rkf, fmt(0 2 0) labels("Obs" "Adj. R-Squared" "KP-Stat")) 

                *******************************************************
                ******** MERGE ALL THE ANALYSES IN ONE TABLE **********
                *******************************************************


esttab $IV_1_cond   /// 
      using "$out_analysis/IV_reg_MERGE.tex",  ///
      prehead("\begin{tabular}{l*{10}{c}} \toprule ") ///
      posthead("& & & & & & & & & & \\ & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) \\ \midrule \midrule \multicolumn{11}{l}{\textbf{\textit{PANEL A: IV1}}} \\ \midrule ") ///
      fragment replace label ///
    drop($fe $controls ln_nb_refugees_bygov  _Iyear_2016)   ///
      mtitles("\multirow{2}{*}{Formal}" "\multirow{2}{*}{Private}" "\multirow{2}{*}{Open}" "\multirow{2}{*}{Stable}" "\multirow{2}{*}{Union}" "\multirow{2}{*}{Skills}" "\multirow{2}{*}{\shortstack[c]{Total\\ Wage (ln)}}" "\multirow{2}{*}{\shortstack[c]{Hourly\\ Wage (ln)}}" "\multirow{2}{*}{\shortstack[c]{Work Hours\\ Per Week}}" "\multirow{2}{*}{\shortstack[c]{Working Days \\ Per Week}}") ///
      stats(rkf, fmt(0) labels("\\\\[-0.5cm] KP-Stat \\\\[-0.6cm]"))  ///
      b(%8.3f) se(%8.3f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $IV_2_cond   /// 
      using "$out_analysis/IV_reg_MERGE.tex",  ///
      posthead("\midrule \midrule \multicolumn{11}{l}{\textbf{\textit{PANEL B: IV 2}}} \\ \midrule  ") ///
      fragment append label ///
      drop($fe $controls ln_nb_refugees_bygov _Iyear_2016)   ///
      stats(rkf, fmt(0) labels("\\\\[-0.5cm] KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $IV_3_cond  /// 
      using "$out_analysis/IV_reg_MERGE.tex",  ///
      posthead("\midrule \midrule \multicolumn{11}{l}{\textbf{\textit{PANEL C: IV 3}}} \\ \midrule  ") ///
      fragment append label ///
      drop($fe $controls ln_nb_refugees_bygov _Iyear_2016)   ///
      stats(rkf, fmt(0) labels("\\\\[-0.5cm] KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $IV_4_cond /// 
      using "$out_analysis/IV_reg_MERGE.tex",  ///
      posthead("\midrule \midrule \multicolumn{11}{l}{\textbf{\textit{PANEL D: IV 4}}} \\ \midrule  ") ///
      fragment append label ///
      drop($fe $controls ln_nb_refugees_bygov  _Iyear_2016)   ///
      stats(N rkf, fmt(0 0) labels("\\\\[-0.5cm] N" "KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") ///
      postfoot("\bottomrule  \\\\[-0.6cm]  \end{tabular}  ")

















/* OBSOLETE 

*OUTCOME CONDITIONAL ON EMPLOYEMENT
global    outcome_cond_temp ///
              job_stable_3m ///  From usstablp - Stability of employement (3m) - 1 permanent - 0 temp, seas, cas
              formal  /// 0 Informal - 1 Formal - Informal if no contract (uscontrp=0) OR no insurance (ussocinsp=0)
              private /// Economic Sector of Primary Job  3m - 0 Public 1 Private
              wp_industry_jlmps_3m  /// Industries with work permits for refugees - Economic Activity of prim. job 3m
              member_union_3m /// Member of a syndicate/trade union (ref. 3-mnths)
              skills_required_pjob ///  Does primary job require any skill
              ln_total_rwage_3m  /// LOG Total Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING
              ln_hourly_rwage  /// LOG Hourly Wage (Prim.& Second. Jobs)
              whpw  /// Winsorized - Usual No. of Hours/Week, Market Work, (Ref. 3-month)
              wdpw  // Avg. num. of wrk. days per week during 3 mnth.


foreach IV of global IVs {
    codebook `IV', c
  foreach outcome of global outcome_cond_temp {
    qui xi: ivreg2  `outcome' ///
                i.district_iid i.year ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                ($dep_var = `IV') ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($dep_var) 
    estimates store m_`IV'_`outcome', title(Model `outcome')
  }


ereturn list
mat list e(b)
estout m_`IV'_job_stable_3m m_`IV'_formal m_`IV'_private m_`IV'_wp_industry_jlmps_3m ///
      m_`IV'_member_union_3m m_`IV'_skills_required_pjob  ///
      m_`IV'_ln_total_rwage_3m  m_`IV'_ln_hourly_rwage ///
      m_`IV'_whpw m_`IV'_wdpw ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop($fe _Iyear_2016 ln_nb_refugees_bygov $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r rkf, fmt(2 0 0) label(R-sqr dfres KP-Stat))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_`IV'_job_stable_3m m_`IV'_formal m_`IV'_private ///
         m_`IV'_wp_industry_jlmps_3m ///
      m_`IV'_member_union_3m m_`IV'_skills_required_pjob  ///
      m_`IV'_ln_total_rwage_3m  m_`IV'_ln_hourly_rwage ///
      m_`IV'_whpw m_`IV'_wdpw /// 
      using "$out_analysis/IV_reg_`IV'.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Private" "Open" "Union" "Skills" "Total W"  "Hourly W" "WH pweek" "WD pweek") ///
  drop($fe _Iyear_2016 ln_nb_refugees_bygov $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   *title("`IV' Results IV Regression"\label{tab1}) nofloat ///
   stats(N r2_a rkf, fmt(0 2 0) labels("Obs" "Adj. R-Squared" "KP Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 


estimates drop m_`IV'_job_stable_3m m_`IV'_formal ///
    m_`IV'_private m_`IV'_wp_industry_jlmps_3m ///
      m_`IV'_member_union_3m m_`IV'_skills_required_pjob  ///
      m_`IV'_ln_total_rwage_3m  m_`IV'_ln_hourly_rwage ///
       m_`IV'_whpw m_`IV'_wdpw

}



*/
