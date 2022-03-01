

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


  foreach outcome of global outcome_cond {
    qui xi: reg `outcome' $dep_var ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store OLS_`outcome', title(Model `outcome')
  }


ereturn list
mat list e(b)
estout $OLS_cond /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
      drop($fe_ctrl $controls  _cons ln_nb_refugees_bygov)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(2 0) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based
/*
*erase "$out/reg_infra_access.tex"
esttab $OLS_cond /// 
      using "$out_analysis/WP_reg_01_OLS.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles( "Formal" "Private" "Open" "Stable" "Union" "Skills" "Total W" "Hourly W" "WH pweek" "WD pweek") ///
drop($fe $controls  _cons ln_nb_refugees_bygov)   ///
        starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results OLS Regression"\label{tab1}) nofloat ///
   stats(N r2_a, fmt(0 2) labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 
*/

*estimates drop $m_cond 

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
    estimates store OLS_YD_`outcome', title(Model `outcome')
  }


ereturn list
mat list e(b)
estout $OLS_YD_cond /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop($fe $district $controls _Iyear_2016  _cons ln_nb_refugees_bygov)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based
/*
*erase "$out/reg_infra_access.tex"
esttab $OLS_YD_cond /// 
      using "$out_analysis/WP_reg_02_OLS_FE_district_year.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Formal" "Private" "Open" "Stable" "Union" "Skills" "Total W"  "Hourly W" "WH pweek" "WD pweek") ///
        drop($fe $district $controls _Iyear_2016  _cons ln_nb_refugees_bygov)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results OLS Regression with time and district FE"\label{tab1}) nofloat ///
   stats(N r2_a, fmt(0 2) labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 
*/

*estimates drop $m_cond


**********************
********* IV *********
**********************

/*
which ivreg2, all
adoupdate ivreg2, update
adoupdate ranktest, update

ado uninstall ivreg2
ssc install ivreg2
*/

************
*REGRESSION*
************

cls
  foreach outcome of global outcome_cond {
    qui xi: ivreg2  `outcome' ///
                i.district_iid i.year ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                ($dep_var = $IV_var) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
    estimates store IV_YD_`outcome', title(Model `outcome')

    * With equivalent first-stage
    gen smpl=0
    replace smpl=1 if e(sample)==1

    qui xi: reg $dep_var $IV_var ///
            i.year i.district_iid ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            if smpl == 1 [pweight = panel_wt_10_16], ///
            cluster(district_iid) robust
    estimates table, k($IV_var) star(.1 .05 .01)    
    estimates store FST_`outcome', title(Model `outcome')

    drop smpl 
  }



ereturn list
mat list e(b)
estout $IV_YD_cond ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop($fe _Iyear_2016 $controls  ln_nb_refugees_bygov)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(N r2_a rkf, fmt(0 2 0) labels("Obs" "Adj. R-Squared" "KP-Stat")) //

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based
/*
*erase "$out/reg_infra_access.tex"
esttab $IV_YD_cond  /// 
      using "$out_analysis/WP_reg_03_IV_FE_district_year.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Formal" "Private" "Open" "Stable"  "Union" "Skills" "Total W"  "Hourly W" "WH pweek" "WD pweek") ///
  drop($fe _Iyear_2016  $controls  ln_nb_refugees_bygov) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District and Year FE"\label{tab1}) nofloat ///
   stats(N r2_a rkf, fmt(0 2 0) labels("Obs" "Adj. R-Squared" "KP-Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 
*/

*estimates drop  $m_cond
*m2 m3 m4 m5 

***********************
/*FIRST STAGE MODEL 2*/
***********************

ereturn list
mat list e(b)
estout $FST_cond /// 
       , cells(b(star fmt(%9.2f)) se(par fmt(%9.2f))) ///
  drop($fe _Iyear_2016 $district  $controls  _cons ln_nb_refugees_bygov)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(N r2, fmt(0 2) label(N R-sqr))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $FST_cond /// 
      using "$out_analysis/WP_reg_03_IV_FE_district_year_stage1.tex", se label replace booktabs ///
      cells(b(star fmt(%9.2f)) se(par fmt(%9.3f))) ///
mtitles( "Formal" "Private" "Open" "Stable" "Union" "Skills" "Total W"  "Hourly W" "WH pday" "WD pweek") ///
  drop($fe _Iyear_2016 $district  $controls  _cons ln_nb_refugees_bygov) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results Stage 1 IV Regression with District and Year FE"\label{tab1}) nofloat ///
   stats(N r2_a, fmt(0 2) labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

*estimates drop  $FST_cond




******************************************************************************************
  *****    M3:  YEAR FE / DISTRICT FE / SECOTRAL FE    ******
******************************************************************************************

**********************
********* OLS ********
**********************
/*
foreach globals of global globals_list {
  foreach outcome of global `globals' {
    qui xi: reg `outcome' $dep_var ///
            i.district_iid i.year i.private ///
             $controls i.educ1d i.fteducst i.mteducst i.ftempst  ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01)
  }
}
*/
**********************
********* IV *********
**********************

*Economics Activities
tab usecac1d 
*tab usocp1d 
*tab usempstp 
*tab ussectrp

  foreach outcome of global outcome_cond {
    qui xi: ivreg2  `outcome' ///
                i.year i.district_iid i.usecac1d ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
                ($dep_var = $IV_var) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) ///
                partial(i.district_iid i.usecac1d) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($dep_var) 
    estimates store IV_YDS_`outcome', title(Model `outcome')

    * With equivalent first-stage
    gen smpl=0
    replace smpl=1 if e(sample)==1

    qui xi: reg $dep_var $IV_var ///
            i.year i.district_iid i.usecac1d ///
            $controls i.educ1d i.fteducst i.mteducst i.ftempst ln_nb_refugees_bygov ///
            if smpl == 1 [pweight = panel_wt_10_16], ///
            cluster(district_iid) robust
    estimates table,  k($IV_var) star(.1 .05 .01)          
    drop smpl 
  }


ereturn list
mat list e(b)
estout $IV_YDS_cond ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop($fe _Iyear_2016 $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(N r2_a rkf, fmt(0 2 0) labels("Obs" "Adj. R-Squared" "KP-Stat")) //

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based
/*
*erase "$out/reg_infra_access.tex"
esttab $IV_YDS_cond /// 
      using "$out_analysis/WP_reg_04_IV_FE_district_year_sector.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles( "Formal" "Private" "Open" "Stable" "Union" "Skills" "Total W"  "Hourly W" "WH pweek" "WD pweek") ///
  drop( $fe _Iyear_2016  $controls ln_nb_refugees_bygov) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District, Year and Sector FE"\label{tab1}) nofloat ///
   stats(N r2_a rkf, fmt(0 2 0) labels("Obs" "Adj. R-Squared" "KP-Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 
*/


*estimates drop $m_cond


          ***********************************************************************
            *****    M4:  YEAR FE / INDIV FE     *****
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
                $controls i.educ1d i.fteducst i.mteducst i.ftempst  ///
                [pw=panel_wt_10_16], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      }
        * Then I partial out all variables
      foreach y in `outcome_l1' $dep_var $controls  educ1d fteducst mteducst ftempst  {
        qui reghdfe `y' [pw=panel_wt_10_16], absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      drop `outcome_l1' $controls  educ1d fteducst mteducst ftempst  $dep_var  
      foreach y in `outcome_l1' $controls  educ1d fteducst mteducst ftempst  $dep_var  {
        rename o_`y' `y' 
      } 
      qui reg `outcome_l1' $dep_var $controls i.educ1d i.fteducst i.mteducst i.ftempst  [pw=panel_wt_10_16], cluster(district_iid) robust
      codebook `outcome_l1', c
      estimates table,  k($dep_var) star(.1 .05 .01)           
    }
  }
restore
*/

*ivreg2hdfe 

**********************
********* IV *********
**********************
/*OLD VERSION 
preserve
  foreach outcome of global outcome_cond {     
      codebook `outcome', c
       qui xi: ivreg2 `outcome' ///
                    i.year i.district_iid ///
                    $controls i.educ1d i.fteducst i.mteducst i.ftempst ///
                    ln_nb_refugees_bygov ///
                    ($dep_var = $IV_var) ///
                    [pweight = panel_wt_10_16], ///
                    cluster(district_iid) robust ///
                    partial(i.district_iid) 

        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
        foreach y in `outcome' $controls $dep_var $IV_var ///
            $fe  ln_nb_refugees_bygov {
          qui reghdfe `y' [pw=panel_wt_10_16] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
          qui rename `y' o_`y'
          qui rename `y'_c2wr `y'
        }
        qui ivreg2 `outcome' ///
               $controls $fe ln_nb_refugees_bygov ///
               ($dep_var = $IV_var) ///
               [pweight = panel_wt_10_16], ///
               cluster(district_iid) robust ///
               first 
      estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var) 
      estimates store m_`outcome', title(Model `outcome')
        qui drop `outcome' $dep_var $IV_var $controls $fe smpl ln_nb_refugees_bygov
        foreach y in `outcome' $controls  $dep_var $IV_var $fe ln_nb_refugees_bygov  {
          qui rename o_`y' `y' 
        }
    }
restore                
*/

preserve
  foreach outcome of global outcome_cond {     
      codebook `outcome', c
       qui xi: ivreghdfe `outcome' ///
                    $controls i.educ1d i.fteducst i.mteducst i.ftempst ///
                    ($dep_var = $IV_var) ///
                    [pw = panel_wt_10_16], ///
                    absorb(year indid_2010) ///
                    cluster(district_iid) 

        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
        foreach y in `outcome' $controls $dep_var $IV_var $fe ln_nb_refugees_bygov { 
          qui reghdfe `y' [pw = panel_wt_10_16] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
          qui rename `y' o_`y'
          qui rename `y'_c2wr `y'
        }
        qui ivreg2 `outcome' ///
               $controls $fe ln_nb_refugees_bygov  ///
               ($dep_var = $IV_var) ///
               [pw = panel_wt_10_16], ///
               cluster(district_iid) robust ///
               first 
      estimates table, k($dep_var) star(.1 .05 .01) b(%7.4f) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($dep_var) 
      estimates store IV_YI_`outcome', title(Model `outcome')
        qui drop `outcome' $dep_var $IV_var $controls $fe smpl ln_nb_refugees_bygov
        foreach y in `outcome' $controls  $dep_var $IV_var $fe ln_nb_refugees_bygov  {
          qui rename o_`y' `y' 
        }
    }
restore                



ereturn list
mat list e(b)
estout $IV_YI_cond  ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop($fe _cons ln_nb_refugees_bygov  $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(N r2_a rkf, fmt(0 2 0) labels("Obs" "Adj. R-Squared" "KP-Stat")) ///

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based
/*
esttab $IV_YI_cond  ///
      using "$out_analysis/WP_reg_05_IV_FE_year_indiv.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Formal" "Private" "Open" "Stable" "Union" "Skills" "Total W"  "Hourly W" "WH pweek" "WD pweek") ///
 drop($fe _cons ln_nb_refugees_bygov  $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with Year and Individual FE"\label{tab1}) nofloat ///
   stats(N r2_a rkf, fmt(0 2 0) labels("Obs" "Adj. R-Squared" "KP-Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 
*/




                *******************************************************
                ******** MERGE ALL THE ANALYSES IN ONE TABLE **********
                *******************************************************


esttab $OLS_cond   /// 
      using "$out_analysis/WP_reg_MERGE.tex",  ///
      prehead("\begin{tabular}{l*{10}{c}} \toprule ") ///
      posthead("& & & & & & & & & & \\ & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) \\ \midrule \midrule \multicolumn{11}{l}{\textbf{\textit{PANEL A: OLS}}} \\ \midrule ") ///
      fragment replace label ///
    drop($fe $controls  _cons ln_nb_refugees_bygov )   ///
      mtitles("\multirow{2}{*}{Formal}" "\multirow{2}{*}{Private}" "\multirow{2}{*}{Open}" "\multirow{2}{*}{Stable}" "\multirow{2}{*}{Union}" "\multirow{2}{*}{Skills}" "\multirow{2}{*}{\shortstack[c]{Total\\ Wage (ln)}}" "\multirow{2}{*}{\shortstack[c]{Hourly\\ Wage (ln)}}" "\multirow{2}{*}{\shortstack[c]{Work Hours\\ Per Week}}" "\multirow{2}{*}{\shortstack[c]{Working Days \\ Per Week}}") ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]")) ///
      b(%8.3f) se(%8.3f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $OLS_YD_cond   /// 
      using "$out_analysis/WP_reg_MERGE.tex",  ///
      posthead("\midrule \midrule \multicolumn{11}{l}{\textbf{\textit{PANEL B: OLS - Year and District Fixed Effects}}} \\ \midrule  ") ///
      fragment append label ///
      drop($fe $controls  _cons $district ln_nb_refugees_bygov _Iyear_2016)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $IV_YD_cond   /// 
      using "$out_analysis/WP_reg_MERGE.tex",  ///
      posthead("\midrule \midrule \multicolumn{11}{l}{\textbf{\textit{PANEL C: OLS - Year and District Fixed Effects}}} \\ \midrule  ") ///
      fragment append label ///
      drop($fe $controls ln_nb_refugees_bygov _Iyear_2016)   ///
      stats(N r2_a rkf, fmt(0 2 0) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $" "KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $IV_YDS_cond   /// 
      using "$out_analysis/WP_reg_MERGE.tex",  ///
      posthead("\midrule \midrule \multicolumn{11}{l}{\textbf{\textit{PANEL D: IV - Year, District, and Industry Fixed Effects}}} \\ \midrule  ") ///
      fragment append label ///
      drop($fe $controls ln_nb_refugees_bygov _Iyear_2016)   ///
      stats(N r2_a rkf, fmt(0 2 0) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $" "KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $IV_YI_cond   /// 
      using "$out_analysis/WP_reg_MERGE.tex",  ///
      posthead("\midrule \midrule \multicolumn{11}{l}{\textbf{\textit{PANEL E: IV - Year and Individual Fixed Effects}}} \\ \midrule  ") ///
      fragment append label ///
      drop($fe $controls _cons ln_nb_refugees_bygov )   ///
      stats(N r2_a rkf, fmt(0 2 0) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $" "KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") ///
      postfoot("\bottomrule  \\\\[-0.6cm]  \end{tabular}  ")





                *******************************************************
                ******** MERGE ALL THE CONTROLS IN ONE TABLE **********
                *******************************************************


*CONTROL VARIABLES
codebook educ1d 
codebook fteducst //  Father's Level of education attained
codebook mteducst //  Mother's Level of education attained
codebook ftempst //  Father's Employment Status (When Resp. 15)
/*
1  Illiterate
2  Read & Write
3  Basic Education
4  Secondary Educ
5  Post-Secondary
6  University
7  Post-Graduate
*/


ereturn list
mat list e(b)
estout OLS_ln_trwage_3m OLS_YD_ln_trwage_3m IV_YD_ln_trwage_3m IV_YDS_ln_trwage_3m IV_YI_ln_trwage_3m /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
      drop($district _cons) ///
   legend  varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2_a rkf, fmt(0 2 0) labels("Obs" "Adj. R-Squared" "KP-Stat")) //


esttab OLS_ln_trwage_3m OLS_YD_ln_trwage_3m IV_YD_ln_trwage_3m IV_YDS_ln_trwage_3m IV_YI_ln_trwage_3m  /// 
      using "$out_analysis/CTRL_reg_MERGE.tex",  ///
      prehead("\begin{tabular}{l*{5}{c}} \toprule ") ///
      posthead("& & & & & \\ & & & & & \\ \midrule \midrule \multicolumn{6}{c}{\textbf{\textbf{Total Wage (ln)}}}  \\ \midrule ") ///
      fragment replace label ///
      b(%8.2f) se(%8.2f) ///
      drop($district _cons) refcat( _Ieduc1d_2 "\midrule \emph{Education}  " ///
                    _Ifteducst_2 "\midrule \emph{Father's Education}  " ///
                    _Imteducst_2 "\midrule \emph{Mother's Education}  " ///
                    _Iftempst_2 "\midrule \emph{Father when 15's Education} " ///
                    , nolabel ) ///
                    varlabels(ln_agg_wp_orig "Work Permits (ln)" ///
                    age "Age" ///
                    age2 "Age Square" ///
                    gender "Gender (Male)" ///
                    hhsize "HH Size" ///
                    _Ieduc1d_2 "Read and Write" ///
                    _Ieduc1d_3 "Basic" ///
                    _Ieduc1d_4 "Secondary" ///
                    _Ieduc1d_5 "Post-Secondary" ///
                    _Ieduc1d_6 "University" ///
                    _Ieduc1d_7 "Post-Graduate" ///
                    _Ifteducst_2 "Read and Write" ///
                    _Ifteducst_3 "Basic" ///
                    _Ifteducst_4 "Secondary" ///
                    _Ifteducst_5 "Post-Secondary" ///
                    _Ifteducst_6 "University and More" ///
                    _Imteducst_2 "Read and Write" ///
                    _Imteducst_3 "Basic" ///
                    _Imteducst_4 "Secondary" ///
                    _Imteducst_5 "Post-Secondary" ///
                    _Imteducst_6 "University and More" ///
                    _Iftempst_2 "Read and Write" ///
                    _Iftempst_3 "Basic" ///
                    _Iftempst_4 "Secondary" ///
                    _Iftempst_5 "Post-Secondary" ///
                    _Iftempst_6 "University and More" ///
                    ln_nb_refugees_bygov "\midrule Nb Refugees (ln)" ///
                    _Iyear_2016 "Year: 2016") ///
mtitles("\multirow{3}{*}{\shortstack[c]{PANEL A: OLS}}" "\multirow{3}{*}{\shortstack[c]{PANEL B: OLS \\ FE: Year, District}}" "\multirow{3}{*}{\shortstack[c]{PANEL C: IV \\ FE: Year, District}}" "\multirow{3}{*}{\shortstack[c]{PANEL D: IV \\ FE: Year, District \\ Industry}}" "\multirow{3}{*}{\shortstack[c]{PANEL E: IV \\ FE: Year, Individual}}")  ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results OLS Regression"\label{tab1}) nofloat ///
      stats(N r2_a rkf, fmt(0 2 0) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $" "KP-Stat \\\\[-0.6cm]"))  ///
    nonotes nonumbers ///
          prefoot("\\\\[-0.5cm] \hline") ///
      postfoot("\bottomrule  \\\\[-0.6cm]  \end{tabular}  ")












/*
************************************************
// ANALYSIS EMPLOYED / UNEMPLOYED USING MODEL 4 
************************************************

            ***********************************************************************
              ***** M2: YEAR FE / DISTRICT FE /   *****
            ***********************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year 
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016


*drop if miss_16_10 == 1
*drop if unemp_16_10 == 1
*drop if olf_16_10 == 1
*drop if emp_16_miss_10 == 1
*drop if emp_10_miss_16 == 1
*drop if unemp_16_miss_10 == 1
*drop if unemp_10_miss_16 == 1
*drop if olf_16_miss_10 == 1
*drop if olf_10_miss_16 == 1 
*drop if emp_10_olf_16  == 1 
*drop if emp_16_olf_10  == 1 
*drop if unemp_10_emp_16  == 1 
*drop if unemp_16_emp_10  == 1 
*drop if olf_10_unemp_16 == 1 
*drop if olf_16_unemp_10  == 1 


            ***********************************************************************
              ***** M2: YEAR FE / DISTRICT FE /   *****
            ***********************************************************************


**********************
********* IV *********
**********************

  foreach outcome of global outcome_uncond {
    qui xi: ivreg2  `outcome' ///
                i.year i.district_iid ///
                $controls i.educ1d i.fteducst i.mteducst i.ftempst  ///
                ($dep_var = IV_SS_5) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
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
    m_ln_b_rwage_unolf m_ln_b_rwage_unemp m_ln_t_rwage_unolf ///
    m_ln_t_rwage_unemp ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
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
esttab m_employed_3m m_unemployed_3m m_unempdurmth  ///
    m_ln_b_rwage_unolf m_ln_b_rwage_unemp m_ln_t_rwage_unolf ///
    m_ln_t_rwage_unemp ///
      using "$out_analysis/reg_03_IV_FE_district_year_empl.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "Duration Unemp" "Basic W OLF" "Basic W" "Total W OLF" "Total W") ///
  drop(age age2 gender hhsize _Ieduc1d_2 _Ieduc1d_3 _Ieduc1d_4 _Ieduc1d_5 ///
        _Ieduc1d_6 _Ieduc1d_7 _Ifteducst_2 ///
        _Ifteducst_3 _Ifteducst_4 _Ifteducst_5 _Ifteducst_6 ///
        _Imteducst_2 _Imteducst_3 _Imteducst_4 _Imteducst_5 ///
        _Imteducst_6 _Iftempst_2 _Iftempst_3 _Iftempst_4 _Iftempst_5 ///
        _Iftempst_6  _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("Results IV Regression with District and Year FE"\label{tab1}) nofloat ///
   stats(N r2_a , labels("Obs" "Adj. R-Squared" "Control Mean")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_employed_3m m_unemployed_3m m_unempdurmth  ///
    m_ln_b_rwage_unolf m_ln_b_rwage_unemp m_ln_t_rwage_unolf ///
    m_ln_t_rwage_unemp 


*/












log close


