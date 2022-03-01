

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
*tab ln_invdistance_dis_camp //  LOG Inverse Distance (km) between JORD districts and ZAATARI CAMP in 2016
tab gender //  Gender - 1 Male 0 Female
tab hhsize //  Total o. of Individuals in the Household

***********************************************************************
**DEFINING THE SAMPLE *************************************************
***********************************************************************

tab year

/*%
[I suggest we partial out both variables (meaning we store 
the residuals from specification where we regress both 
variables on fixed effects and then use scatter plot, 
fitted line, and eventually a non-parametric line). 
I can show you a code].
*/

**************
* JORDANIANS *
**************

tab nationality_cl year , m 
*drop if nationality_cl != 1

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

***************
* WORKING AGE *
*************** 

*Keep only working age pop? 15-64 ? As defined by the ERF
drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016


distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

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
*drop if emp_10_olf_16  == 1 
*drop if emp_16_olf_10  == 1 
*drop if unemp_10_emp_16  == 1 
*drop if unemp_16_emp_10  == 1 
*drop if olf_10_unemp_16 == 1 
*drop if olf_16_unemp_10  == 1 
*/
keep if emp_16_10 == 1 


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
destring indid_2010 Findid, replace
mdesc indid_2010
xtset indid_2010 year 



                                  ************
                                  *REGRESSION*
                                  ************

              ***************************************************
                *****         M1: SIMPLE OLS:           *******
              ***************************************************

codebook $dep_var
lab var $dep_var "Work Permits (ln)"


**********************
********* OLS ********
**********************
global    m1_cond ///
              m1_job_stable_3m ///  From usstablp - Stability of employement (3m) - 1 permanent - 0 temp, seas, cas
              m1_formal  /// 0 Informal - 1 Formal - Informal if no contract (uscontrp=0) OR no insurance (ussocinsp=0)
              m1_private /// Economic Sector of Primary Job  3m - 0 Public 1 Private
              m1_wp_industry_jlmps_3m  /// Industries with work permits for refugees - Economic Activity of prim. job 3m
              m1_member_union_3m /// Member of a syndicate/trade union (ref. 3-mnths)
              m1_skills_required_pjob ///  Does primary job require any skill
              m1_ln_total_rwage_3m  /// LOG Total Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING
              m1_ln_hourly_rwage  /// LOG Hourly Wage (Prim.& Second. Jobs)
              m1_work_hours_pweek_3m_w  /// Winsorized - Usual No. of Hours/Week, Market Work, (Ref. 3-month)
              m1_work_days_pweek_3m  // Avg. num. of wrk. days per week during 3 mnth.

global    m2_cond ///
              m2_job_stable_3m ///  From usstablp - Stability of employement (3m) - 1 permanent - 0 temp, seas, cas
              m2_formal  /// 0 Informal - 1 Formal - Informal if no contract (uscontrp=0) OR no insurance (ussocinsp=0)
              m2_private /// Economic Sector of Primary Job  3m - 0 Public 1 Private
              m2_wp_industry_jlmps_3m  /// Industries with work permits for refugees - Economic Activity of prim. job 3m
              m2_member_union_3m /// Member of a syndicate/trade union (ref. 3-mnths)
              m2_skills_required_pjob ///  Does primary job require any skill
              m2_ln_total_rwage_3m  /// LOG Total Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING
              m2_ln_hourly_rwage  /// LOG Hourly Wage (Prim.& Second. Jobs)
              m2_work_hours_pweek_3m_w  /// Winsorized - Usual No. of Hours/Week, Market Work, (Ref. 3-month)
              m2_work_days_pweek_3m  // Avg. num. of wrk. days per week during 3 mnth.
     

  foreach outcome of global outcome_cond {
    qui xi: reg `outcome' $dep_var ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store m1_`outcome', title(Model `outcome')
  }

  foreach outcome of global outcome_cond {
    eststo: qui xi: reg `outcome' $dep_var ///
            i.district_iid i.year ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store m2_`outcome', title(Model `outcome')
  }






sysuse auto, clear

rename (weight length) (x1 x2)
rename (price mpg headroom) (y1 y2 y3)

local xlist x1 x2
local ylist y1 y2 y3
    eststo clear

foreach x of local xlist {
    foreach y of local ylist {
        eststo reg_`x'_`y': reg `y' `x' 
        }
    }

esttab reg_x1_y1 reg_x1_y2 reg_x1_y3 using "$out_analysis/reg_test_tex.tex", label  fragment  replace
esttab reg_x2_y1 reg_x2_y2 reg_x2_y3 using "$out_analysis/reg_test_tex.tex", label fragment  append


esttab $m1_cond $m2_cond    /// 
      using "$out_analysis/TRY.tex",  se label replace booktabs  compress ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Private" "Open" "Union" "Skills" "Total W" "Hourly W" "WH pweek" "WD pweek") ///
drop($fe $controls  _cons ln_nb_refugees_bygov $district)   ///
        starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results RegressionS"\label{tab1}) nofloat ///
   stats(N r2_a, fmt(0 2) labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    refcat(Population_GDP "Panel 1"  Median_Age_GDP "Panel 2", nolabel)


esttab $m1_cond $m2_cond using "$out_analysis/TRY.tex", replace /// 
     


esttab $m1_cond   /// 
      using "$out_analysis/TRY.tex",  label replace   ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Private" "Open" "Union" "Skills" "Total W" "Hourly W" "WH pweek" "WD pweek") ///
drop($fe $controls  _cons ln_nb_refugees_bygov)   ///
        starlevels(* 0.1 ** 0.05 *** 0.01)  nofloat ///
   stats(N r2_a, fmt(0 2) labels("Obs" "Adj. R-Squared")) ///
    nonotes booktabs not

esttab $m2_cond   /// 
      using "$out_analysis/TRY.tex",       ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Private" "Open" "Union" "Skills" "Total W" "Hourly W" "WH pweek" "WD pweek") ///
drop($fe $controls  _cons $district ln_nb_refugees_bygov _Iyear_2016)   ///
        starlevels(* 0.1 ** 0.05 *** 0.01) ///
   stats(N r2_a, fmt(0 2) labels("Obs" "Adj. R-Squared")) ///
    nonotes nonumber label   append  booktabs not


*& b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) \\

esttab $m1_cond   /// 
      using "$out_analysis/TRY.tex",  ///
      prehead(" \begin{tabular}{l*{10}{c}} \toprule ") ///
      posthead("& & & & & & & & & & \\ & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) \\ \midrule \midrule \multicolumn{11}{l}{\textbf{\textit{PANEL A: OLS}}} \\ ") ///
      fragment replace label ///
    drop($fe $controls  _cons ln_nb_refugees_bygov )   ///
      mtitles("\multirow{2}{*}{Stable}" "\multirow{2}{*}{Formal}" "\multirow{2}{*}{Private}" "\multirow{2}{*}{Open}" "\multirow{2}{*}{Union}" "\multirow{2}{*}{Skills}" "\multirow{2}{*}{\shortstack[c]{Total\\ Wage (ln)}}" "\multirow{2}{*}{\shortstack[c]{Hourly\\ Wage (ln)}}" "\multirow{2}{*}{\shortstack[c]{Work Hours\\ Per Week}}" "\multirow{2}{*}{\shortstack[c]{Working Days \\ Per Week}}") ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]")) ///
      b(%8.3f) se(%8.3f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") ///



esttab $m2_cond   /// 
      using "$out_analysis/TRY.tex",  ///
      posthead("\midrule \midrule \multicolumn{11}{l}{\textbf{\textit{PANEL B: OLS}}} \\ ") ///
      fragment label ///
      drop($fe $controls  _cons $district ln_nb_refugees_bygov _Iyear_2016)   ///
      append stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") ///
      postfoot("\bottomrule  \\\\[-0.6cm] \multicolumn{11}{l}{\footnotesize Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01}\\   \end{tabular} ")





      label replace   ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Private" "Open" "Union" "Skills" "Total W" "Hourly W" "\shortstack[c]{Work Hours\\ Per Week}" "WD pweek") ///
drop($fe $controls  _cons ln_nb_refugees_bygov)   ///
        starlevels(* 0.1 ** 0.05 *** 0.01)  nofloat ///
   stats(N r2_a, fmt(0 2) labels("Obs" "Adj. R-Squared")) ///
    nonotes booktabs not

esttab $m2_cond   /// 
      using "$out_analysis/TRY.tex",       ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Private" "Open" "Union" "Skills" "Total W" "Hourly W" "WH pweek" "WD pweek") ///
drop($fe $controls  _cons $district ln_nb_refugees_bygov _Iyear_2016)   ///
        starlevels(* 0.1 ** 0.05 *** 0.01) ///
   stats(N r2_a, fmt(0 2) labels("Obs" "Adj. R-Squared")) ///
    nonotes nonumber label   append  booktabs not   
            ***********************************************************************
              ***** M2: YEAR FE / DISTRICT FE    *****
            ***********************************************************************

**********************
********* OLS ********
**********************

  foreach outcome of global outcome_cond {
    qui xi: reg `outcome' $dep_var ///
            i.district_iid i.year ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store m_`outcome', title(Model `outcome')
  }


ereturn list
mat list e(b)
estout $m_cond /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop($fe $district $controls _Iyear_2016  _cons ln_nb_refugees_bygov)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $m_cond /// 
      using "$out_analysis/WP_reg_02_OLS_FE_district_year.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Stable" "Formal" "Private" "Open" "Union" "Skills" "Total W"  "Hourly W" "WH pweek" "WD pweek") ///
        drop($fe $district $controls _Iyear_2016  _cons ln_nb_refugees_bygov)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results OLS Regression with time and district FE"\label{tab1}) nofloat ///
   stats(N r2_a, fmt(0 2) labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 



************
* CONTROLS *
************

ereturn list
mat list e(b)
estout  m_ln_total_rwage_3m   /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop(age2 $district)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_ln_total_rwage_3m   /// 
      using "$out_analysis/CTRL_reg_02_OLS_FE_district_year.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total W") ///
        drop(age2 $district)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results OLS Regression with time and district FE"\label{tab1}) nofloat ///
   stats(N r2_a, fmt(0 2) labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 


estimates drop $m_cond
