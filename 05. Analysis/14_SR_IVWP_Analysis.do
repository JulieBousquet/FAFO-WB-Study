

cap log close
clear all
set more off, permanently
set mem 100m

*log using "$out_analysis/14_IVWP_Analysis.log", replace

   ****************************************************************************
   **                            DATA IV WP                                  **
   **          ANALYSIS ON THE EFFECT OF WP FOR SEC ANALYSIS                 **  
   ** ---------------------------------------------------------------------- **
   ** Type Do  :  DATA JLMPS - FALLAH ET AL INSTRU                           **
   **                                                                        **
   ** Authors  : Julie Bousquet                                              **
   ****************************************************************************




*******************************************************************************
*******************************************************************************
*******************************************************************************
*******************************************************************************
*******************************************************************************
*******************************************************************************
*******************************************************************************
*******************************************************************************
*******************************************************************************




                  ******************
                  ** WORK PERMITS **
                  ******************

                  

use "$data_final/07_IV_Ref_WP.dta", clear

tab nationality_cl year 
drop if nationality_cl != 1
*keep if gender == 1 

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016


/*ONLY THOSE WHO WERE SURVEYED IN BOTH PERIODS?*/
/*
distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year
*/
xtset, clear 
xtset indid_2010 year 

             



                                *******************
                                * REFUGEE INFLOW  *
                                *******************


                           ***************************
                           ***************************
                           *       FULL SAMPLE       *
                           ***************************
                           ***************************


                              ************************
                              ***        OLS       ***
                              ************************

                        ***********************************
                        **           OLS                 **
                        **        UNCONDITIONAL          **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************


  foreach outcome of global outcomes_uncond {
    qui xi: reg `outcome' $dep_var_wp ///
             i.district_iid i.year $controls ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_wp) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_wp) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(age age2 gender _Iyear_2016  $district ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid   /// 
      using "$out_analysis/SR_WP_reg_OLS_Uncond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "LFP Employee" "LFP Temp" "LFP Employer" "LFP SE" "LFP Unpaid") ///
        drop(age age2 gender  _Iyear_2016  $district ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results OLS Regression with time and district FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  
************


                        ***********************************
                        **           OLS                 **
                        **        UNCONDITIONAL          **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global outcomes_uncond {
       qui reghdfe `outcome' $dep_var_ref $controls  ///
                [pw=panel_wt_10_16], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $dep_var_wp  $controls {
        qui reghdfe `y' [pw=panel_wt_10_16] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $dep_var_wp $controls [pw=panel_wt_10_16], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($dep_var_wp) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_wp) 
      estimates store m_`outcome', title(Model `outcome')

      drop `outcome' $controls $dep_var_wp smpl
      
      foreach y in `outcome' $controls $dep_var_wp  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(age age2 gender ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid   /// 
      using "$out_analysis/SR_WP_reg_OLS_Uncond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "LFP Employee" "LFP Temp" "LFP Employer" "LFP SE" "LFP Unpaid") ///
        drop(age age2 gender  ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results OLS Regression with time and Individual FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  
************









                            ***********************
                            ***        IV       ***
                            ***********************


                        ***********************************
                        **           IV                  **
                        **        UNCONDITIONAL          **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************


 foreach outcome of global outcomes_uncond {
    qui xi: ivreg2  `outcome' i.year i.district_iid $controls ///
                ($dep_var_wp = $iv_wp) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var_wp) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($dep_var_wp) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres rkf))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid /// 
      using "$out_analysis/SR_WP_reg_IV_Uncond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "LFP Employee" "LFP Temp" "LFP Employer" "LFP SE" "LFP Unpaid") ///
  drop(age age2 gender _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results IV with District and Year FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a rkf, labels("Obs" "Adj. R-Squared" "KP Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  




                        ***********************************
                        **           IV                  **
                        **        UNCONDITIONAL          **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

preserve
  foreach outcome of global outcomes_uncond {     
      codebook `outcome', c
       qui xi: ivreghdfe `outcome' ///
                    $controls  ///
                    ($dep_var_wp = $iv_wp) ///
                    [pweight = panel_wt_10_16], ///
                    absorb(year indid_2010) ///
                    cluster(district_iid) 

        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
        foreach y in `outcome' $controls $dep_var_wp $iv_wp { 
          qui reghdfe `y' [pw=panel_wt_10_16] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
          qui rename `y' o_`y'
          qui rename `y'_c2wr `y'
        }
        qui ivreg2 `outcome' ///
               $controls  ///
               ($dep_var_wp = $iv_wp) ///
               [pweight = panel_wt_10_16], ///
               cluster(district_iid) robust ///
               first 
      estimates table, k($dep_var_wp) star(.1 .05 .01) b(%7.4f) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_wp) 
      estimates store m_`outcome', title(Model `outcome')
        qui drop `outcome' $dep_var_wp $iv_wp $controls smpl
        foreach y in `outcome' $dep_var_wp $iv_wp $controls {
          qui rename o_`y' `y' 
        }
    }
restore                

ereturn list
mat list e(b)
estout m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(age age2 gender ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres rkf))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid   /// 
      using "$out_analysis/SR_WP_reg_IV_Uncond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "LFP Employee" "LFP Temp" "LFP Employer" "LFP SE" "LFP Unpaid") ///
        drop(age age2 gender  ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results IV Regression with time and Individual FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a rkf, labels("Obs" "Adj. R-Squared" "KP Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  





















               ***************************
               ***************************
               *     EMPLOYED ONLY       *
               ***************************
               ***************************

keep if emp_16_10 == 1 

/*ONLY THOSE WHO WERE SURVEYED IN BOTH PERIODS?*/
/*
distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year
*/


                            ************************
                            ***        OLS       ***
                            ************************

                        ***********************************
                        **           OLS                 **
                        **        CONDITIONAL            **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************



  foreach outcome of global outcomes_cond {
    qui xi: reg `outcome' $dep_var_wp ///
             i.district_iid i.year $controls ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_wp) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_wp) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m_w  ///
         m_formal /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop(age age2 gender _Iyear_2016  $district ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m_w ///
         m_formal   /// 
      using "$out_analysis/SR_WP_reg_OLS_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop(age age2 gender  _Iyear_2016  $district ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results OLS Regression with time and district FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop  m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m_w ///
                m_formal  



                        ***********************************
                        **           OLS                 **
                        **        CONDITIONAL            **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global outcomes_cond {
       qui reghdfe `outcome' $dep_var_wp $controls  ///
                [pw=panel_wt_10_16], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $dep_var_wp  $controls {
        qui reghdfe `y' [pw=panel_wt_10_16] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $dep_var_wp $controls [pw=panel_wt_10_16], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($dep_var_wp) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_wp) 
      estimates store m_`outcome', title(Model `outcome')

      drop `outcome' $controls $dep_var_wp smpl
      
      foreach y in `outcome' $controls $dep_var_wp  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m_w ///
         m_formal   /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(age age2 gender ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m_w ///
         m_formal   /// 
      using "$out_analysis/SR_WP_reg_OLS_Cond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop(age age2 gender  ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results OLS Regression with time and Individual FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m_w ///
         m_formal   
************










                            ***********************
                            ***        IV       ***
                            ***********************


                        ***********************************
                        **           IV                  **
                        **        CONDITIONAL            **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************

cls
 foreach outcome of global outcomes_cond {
     qui xi: ivreg2  `outcome'  i.year i.district_iid $controls ///
                ($dep_var_wp = $iv_wp) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var_wp) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($dep_var_wp) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m_w  ///
         m_formal  ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres KP-Stat))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m_w  ///
         m_formal  /// 
      using "$out_analysis/SR_WP_reg_IV_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
  drop(age age2 gender _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results IV with District and Year FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a rkf, labels("Obs" "Adj. R-Squared" "KP Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 


estimates drop  m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m_w ///
                m_formal  


                        ***********************************
                        **           IV                  **
                        **        CONDITIONAL            **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

preserve
  foreach outcome of global outcomes_cond {     
      codebook `outcome', c
       qui xi: ivreghdfe `outcome' ///
                    $controls  ///
                    ($dep_var_wp = $iv_wp) ///
                    [pweight = panel_wt_10_16], ///
                    absorb(year indid_2010) ///
                    cluster(district_iid) 

        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
        foreach y in `outcome' $controls $dep_var_wp $iv_wp { 
          qui reghdfe `y' [pw=panel_wt_10_16] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
          qui rename `y' o_`y'
          qui rename `y'_c2wr `y'
        }
        qui ivreg2 `outcome' ///
               $controls  ///
               ($dep_var_wp = $iv_wp) ///
               [pweight = panel_wt_10_16], ///
               cluster(district_iid) robust ///
               first 
      estimates table, k($dep_var_wp) star(.1 .05 .01) b(%7.4f) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($dep_var_wp) 
      estimates store m_`outcome', title(Model `outcome')
        qui drop `outcome' $dep_var_wp $iv_wp $controls smpl
        foreach y in `outcome' $dep_var_wp $iv_wp $controls {
          qui rename o_`y' `y' 
        }
    }
restore                

ereturn list
mat list e(b)
estout  m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m_w ///
                m_formal ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(age age2 gender ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres F))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab  m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m_w ///
                m_formal   /// 
      using "$out_analysis/SR_WP_reg_IV_Cond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop(age age2 gender  ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results IV Regression with time and Individual FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a rkf, labels("Obs" "Adj. R-Squared" "KP Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop  m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m_w ///
                m_formal 


































































/*



             *****************
              * WORK PERMITS  *
              *****************

**** OLS *****
  foreach outcome of global outcomes_uncond {
    qui xi: reg `outcome' $dep_var_wp ///
             i.district_iid i.year $controls ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_wp) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_wp) 
    estimates store m_`outcome', title(Model `outcome')
  }



ereturn list
mat list e(b)
estout m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop(age age2 gender _Iyear_2016 ///
        _Idistrict__2 _Idistrict__3 ///
        _Idistrict__4 _Idistrict__5 _Idistrict__6 _Idistrict__7 ///
        _Idistrict__8 _Idistrict__9 _Idistrict__10 _Idistrict__11 ///
        _Idistrict__12 _Idistrict__13 _Idistrict__14 _Idistrict__15 ///
        _Idistrict__16  _Idistrict__18 _Idistrict__19 ///
        _Idistrict__20 _Idistrict__21 _Idistrict__22 _Idistrict__23 ///
        _Idistrict__24 _Idistrict__25 _Idistrict__26 _Idistrict__27 ///
        _Idistrict__28 _Idistrict__29 _Idistrict__30 _Idistrict__31 ///
        _Idistrict__32 _Idistrict__33 _Idistrict__34 _Idistrict__35 ///
        _Idistrict__36 _Idistrict__37 _Idistrict__38 _Idistrict__39 ///
        _Idistrict__40 _Idistrict__41 _Idistrict__42 _Idistrict__43 ///
        _Idistrict__44 _Idistrict__45 _Idistrict__46 _Idistrict__47 ///
        _Idistrict__48 _Idistrict__49 _Idistrict__50 _Idistrict__51 ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid   /// 
      using "$out_analysis/WP_reg_OLS_Uncond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "LFP Employee" "LFP Temp" "LFP Employer" "LFP SE" "LFP Unpaid") ///
        drop(age age2 gender  _Iyear_2016 ///
        _Idistrict__2 _Idistrict__3 ///
        _Idistrict__4 _Idistrict__5 _Idistrict__6 _Idistrict__7 ///
        _Idistrict__8 _Idistrict__9 _Idistrict__10 _Idistrict__11 ///
        _Idistrict__12 _Idistrict__13 _Idistrict__14 _Idistrict__15 ///
        _Idistrict__16 _Idistrict__18 _Idistrict__19 ///
        _Idistrict__20 _Idistrict__21 _Idistrict__22 _Idistrict__23 ///
        _Idistrict__24 _Idistrict__25 _Idistrict__26 _Idistrict__27 ///
        _Idistrict__28 _Idistrict__29 _Idistrict__30 _Idistrict__31 ///
        _Idistrict__32 _Idistrict__33 _Idistrict__34 _Idistrict__35 ///
        _Idistrict__36 _Idistrict__37 _Idistrict__38 _Idistrict__39 ///
        _Idistrict__40 _Idistrict__41 _Idistrict__42 _Idistrict__43 ///
        _Idistrict__44 _Idistrict__45 _Idistrict__46 _Idistrict__47 ///
        _Idistrict__48 _Idistrict__49 _Idistrict__50 _Idistrict__51 ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results OLS Regression with time and district FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  
************


**** IV ****  
 foreach outcome of global outcomes_uncond {
      xi: ivreg2  `outcome' i.year i.district_iid $controls ///
                ($dep_var_wp = $iv_wp) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var_wp) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_wp) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres KP-Stat))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid /// 
      using "$out_analysis/WP_reg_IV_Uncond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "LFP Employee" "LFP Temp" "LFP Employer" "LFP SE" "LFP Unpaid") ///
  drop(age age2 gender _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results IV with District and Year FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a rkf, labels("Obs" "Adj. R-Squared" "KP Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  






****************
*EMPLOYED ONLY *
****************

keep if emp_16_10 == 1 

/*ONLY THOSE WHO WERE SURVEYED IN BOTH PERIODS?*/
distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

  foreach outcome of global outcomes_cond {
    qui xi: reg `outcome' $dep_var_wp ///
             i.district_iid i.year $controls ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_wp) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_wp) 
    estimates store m_`outcome', title(Model `outcome')
  }


ereturn list
mat list e(b)
estout m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m  ///
         m_formal /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop(age age2 gender _Iyear_2016 ///
        _Idistrict__2 _Idistrict__3 ///
        _Idistrict__4 _Idistrict__5 _Idistrict__6 _Idistrict__7 ///
        _Idistrict__8 _Idistrict__9 _Idistrict__10 _Idistrict__11 ///
        _Idistrict__12 _Idistrict__13 _Idistrict__14 _Idistrict__15 ///
        _Idistrict__16  _Idistrict__18 _Idistrict__19 ///
        _Idistrict__20 _Idistrict__21 _Idistrict__22 _Idistrict__23 ///
        _Idistrict__24 _Idistrict__25 _Idistrict__26 _Idistrict__27 ///
        _Idistrict__28 _Idistrict__29 _Idistrict__30 _Idistrict__31 ///
        _Idistrict__32 _Idistrict__33 _Idistrict__34 _Idistrict__35 ///
        _Idistrict__36 _Idistrict__37 _Idistrict__38 _Idistrict__39 ///
        _Idistrict__40 _Idistrict__41 _Idistrict__42 _Idistrict__43 ///
        _Idistrict__44 _Idistrict__45 _Idistrict__46 _Idistrict__47 ///
        _Idistrict__48 _Idistrict__49 _Idistrict__50 _Idistrict__51 ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m  ///
         m_formal   /// 
      using "$out_analysis/WP_reg_OLS_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop(age age2 gender  _Iyear_2016 ///
        _Idistrict__2 _Idistrict__3 ///
        _Idistrict__4 _Idistrict__5 _Idistrict__6 _Idistrict__7 ///
        _Idistrict__8 _Idistrict__9 _Idistrict__10 _Idistrict__11 ///
        _Idistrict__12 _Idistrict__13 _Idistrict__14 _Idistrict__15 ///
        _Idistrict__16 _Idistrict__18 _Idistrict__19 ///
        _Idistrict__20 _Idistrict__21 _Idistrict__22 _Idistrict__23 ///
        _Idistrict__24 _Idistrict__25 _Idistrict__26 _Idistrict__27 ///
        _Idistrict__28 _Idistrict__29 _Idistrict__30 _Idistrict__31 ///
        _Idistrict__32 _Idistrict__33 _Idistrict__34 _Idistrict__35 ///
        _Idistrict__36 _Idistrict__37 _Idistrict__38 _Idistrict__39 ///
        _Idistrict__40 _Idistrict__41 _Idistrict__42 _Idistrict__43 ///
        _Idistrict__44 _Idistrict__45 _Idistrict__46 _Idistrict__47 ///
        _Idistrict__48 _Idistrict__49 _Idistrict__50 _Idistrict__51 ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results OLS Regression with time and district FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop  m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m ///
                m_formal  


cls
 foreach outcome of global outcomes_cond {
     xi: ivreg2  `outcome' i.year i.district_iid $controls ///
                ($dep_var_wp = $iv_wp) ///
                [pweight = panel_wt_10_16], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var_wp) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_wp) 
    estimates store m_`outcome', title(Model `outcome')
  }


ereturn list
mat list e(b)
estout m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m  ///
         m_formal  ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres KP-Stat))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m  ///
         m_formal  /// 
      using "$out_analysis/WP_reg_IV_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
  drop(age age2 gender _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results IV with District and Year FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a rkf, labels("Obs" "Adj. R-Squared" "KP-Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop  m_ln_total_rwage_3m m_ln_hourly_rwage m_work_hours_pweek_3m ///
                m_formal  


*/




