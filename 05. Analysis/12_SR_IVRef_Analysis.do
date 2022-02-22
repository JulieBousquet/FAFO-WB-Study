




cap log close
clear all
set more off, permanently
set mem 100m

*log using "$out_analysis/11_IVRef_Analysis.log", replace

   ****************************************************************************
   **                            DATA IV REF                                 **
   **          ANALYSIS ON THE EFFECT OF REF INFLOW FOR SEC ANALYSIS         **  
   ** ---------------------------------------------------------------------- **
   ** Type Do  :  DATA JLMPS - FALLAH ET AL INSTRU                           **
   **                                                                        **
   ** Authors  : Julie Bousquet                                              **
   ****************************************************************************




              *************
              * ANALYSES  *
              ************* 

*Sampling weights.  

*SEs clustered one admin level above treatment variation, 
*unless variation is available only at highly aggregated level 
*(e.g. district). 

*Robust SEs  
*Sample:  
*hosts/natives 
*Working Age 15-64 
*Individual-level analysis for most variables  

/*
global dep_var_ref  ln_hh_syrians_bydis 
*ln_prop_hh_syrians
global iv_ref       ln_IV_Ref_NETW

global dep_var_wp ln_agg_wp_orig
global iv_wp      IV_WP_DIST
  
global outcomes_uncond  employed_olf_3m   ///
                        unemployed_olf_3m ///
                        lfp_3m_empl ///
                        lfp_3m_temp ///
                        lfp_3m_employer ///
                        lfp_3m_se ///
                        lfp_3m_unpaid
*employed_olf_7d 
*unemployed_olf_7d


global outcomes_cond  ln_total_rwage_3m ///
                      ln_hourly_rwage ///
                      m_ln_whpw_3m ///
                      formal
*ln_rmthly_wage_main 
*ln_rhourly_wage_main 
 *wh_pw_7d_w formal 

global controls age age2 gender 

global heterogenous gender urb_rural_camps lfp_3m bi_education
*/

/* CHANGE
- use the 3 month ref period for all outcomes 
- do the individual analysis on restricted sample
- change the treat var to have the number of refugee and not the share
+ check what it means at the loc or distr level
- make sure i did the cpi correction correctly
- use total wage and hourly wage
*/



use "$data_final/07_IV_Ref_WP.dta", clear

tab ln_hh_syrians_bydis year 
tab ln_IV_Ref_NETW year 


*tab IV_Ref_DIST 
corr ln_hh_syrians_bydis  ln_IV_Ref_NETW
corr prop_hh_syrians  IV_Ref_NETW

corr hh_syrians_bydis  IV_Ref_DIST

tab agg_wp_orig 
*tab IV_WP_NETW 
tab IV_WP_DIST  
*corr agg_wp_orig  IV_WP_NETW
corr ln_agg_wp_orig  IV_WP_DIST




                              ************
                              *  SAMPLE  *
                              ************ 
tab nationality_cl year 
drop if nationality_cl != 1
*keep if gender == 1 

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016


/*ONLY THOSE WHO WERE SURVEYED IN BOTH PERIODS?*/

/*distinct indid_2010 
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
    qui xi: reg `outcome' $dep_var_ref ///
             i.district_iid i.year $controls ///
            [pw = $weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref) 
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
      using "$out_analysis/SR_REF_reg_OLS_Uncond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "LFP Employee" "LFP Temp" "LFP Employer" "LFP SE" "LFP Unpaid") ///
        drop(age age2 gender  _Iyear_2016  $district ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - Results OLS Regression with time and district FE - UNCOND"\label{tab1}) nofloat ///
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
                [pw = $weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $dep_var_ref  $controls {
        qui reghdfe `y' [pw = $weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $dep_var_ref $controls [pw = $weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($dep_var_ref) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref) 
      estimates store m_`outcome', title(Model `outcome')

      drop `outcome' $controls $dep_var_ref smpl
      
      foreach y in `outcome' $controls $dep_var_ref  {
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
      using "$out_analysis/SR_REF_reg_OLS_Uncond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "LFP Employee" "LFP Temp" "LFP Employer" "LFP SE" "LFP Unpaid") ///
        drop(age age2 gender  ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - Results OLS Regression with time and Individual FE - UNCOND"\label{tab1}) nofloat ///
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
      xi: ivreg2  `outcome' i.year i.district_iid $controls ///
                ($dep_var_ref = $iv_ref) ///
                [pw = $weight], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var_ref) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref) 
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
      using "$out_analysis/SR_REF_reg_IV_Uncond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "LFP Employee" "LFP Temp" "LFP Employer" "LFP SE" "LFP Unpaid") ///
  drop(age age2 gender _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - Results IV with District and Year FE - UNCOND"\label{tab1}) nofloat ///
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
                    ($dep_var_ref = $iv_ref) ///
                    [pw = $weight], ///
                    absorb(year indid_2010) ///
                    cluster(district_iid) 

        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
        foreach y in `outcome' $controls $dep_var_ref $iv_ref { 
          qui reghdfe `y' [pw = $weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
          qui rename `y' o_`y'
          qui rename `y'_c2wr `y'
        }
        qui ivreg2 `outcome' ///
               $controls  ///
               ($dep_var_ref = $iv_ref) ///
               [pw = $weight], ///
               cluster(district_iid) robust ///
               first 
      estimates table, k($dep_var_ref) star(.1 .05 .01) b(%7.4f) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($dep_var_ref) 
      estimates store m_`outcome', title(Model `outcome')
        qui drop `outcome' $dep_var_ref $iv_ref $controls smpl
        foreach y in `outcome' $dep_var_ref $iv_ref $controls {
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
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres F))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_employed_olf_3m m_unemployed_olf_3m m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid   /// 
      using "$out_analysis/SR_REF_reg_IV_Uncond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "LFP Employee" "LFP Temp" "LFP Employer" "LFP SE" "LFP Unpaid") ///
        drop(age age2 gender  ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - Results IV Regression with time and Individual FE - UNCOND"\label{tab1}) nofloat ///
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
    qui xi: reg `outcome' $dep_var_ref ///
             i.district_iid i.year $controls ///
            [pw = $weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout m_ln_total_rwage_3m m_ln_hourly_rwage m_ln_whpw_3m  ///
         m_formal /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop(age age2 gender _Iyear_2016  $district ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_ln_total_rwage_3m m_ln_hourly_rwage m_ln_whpw_3m ///
         m_formal   /// 
      using "$out_analysis/SR_REF_reg_OLS_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop(age age2 gender  _Iyear_2016  $district ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - Results OLS Regression with time and district FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop  m_ln_total_rwage_3m m_ln_hourly_rwage m_ln_whpw_3m ///
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
       qui reghdfe `outcome' $dep_var_ref $controls  ///
               [pw = $weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $dep_var_ref  $controls {
        qui reghdfe `y' [pw = $weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $dep_var_ref $controls [pw = $weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($dep_var_ref) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref) 
      estimates store m_`outcome', title(Model `outcome')

      drop `outcome' $controls $dep_var_ref smpl
      
      foreach y in `outcome' $controls $dep_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout m_ln_total_rwage_3m m_ln_hourly_rwage m_ln_whpw_3m ///
         m_formal   /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(age age2 gender ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_ln_total_rwage_3m m_ln_hourly_rwage m_ln_whpw_3m ///
         m_formal   /// 
      using "$out_analysis/SR_REF_reg_OLS_Cond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop(age age2 gender  ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - Results OLS Regression with time and Individual FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_ln_total_rwage_3m m_ln_hourly_rwage m_ln_whpw_3m ///
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
                ($dep_var_ref = $iv_ref) ///
                [pw = $weight], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var_ref) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($dep_var_ref) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout m_ln_total_rwage_3m m_ln_hourly_rwage m_ln_whpw_3m  ///
         m_formal  ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres KP-Stat))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_ln_total_rwage_3m m_ln_hourly_rwage m_ln_whpw_3m  ///
         m_formal  /// 
      using "$out_analysis/SR_REF_reg_IV_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
  drop(age age2 gender _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - Results IV with District and Year FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a rkf, labels("Obs" "Adj. R-Squared" "KP Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 


estimates drop  m_ln_total_rwage_3m m_ln_hourly_rwage m_ln_whpw_3m ///
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
                    ($dep_var_ref = $iv_ref) ///
                    [pw = $weight], ///
                    absorb(year indid_2010) ///
                    cluster(district_iid) 

        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
        foreach y in `outcome' $controls $dep_var_ref $iv_ref { 
          qui reghdfe `y' [pw = $weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
          qui rename `y' o_`y'
          qui rename `y'_c2wr `y'
        }
        qui ivreg2 `outcome' ///
               $controls  ///
               ($dep_var_ref = $iv_ref) ///
               [pw = $weight], ///
               cluster(district_iid) robust ///
               first 
      estimates table, k($dep_var_ref) star(.1 .05 .01) b(%7.4f) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($dep_var_ref) 
      estimates store m_`outcome', title(Model `outcome')
        qui drop `outcome' $dep_var_ref $iv_ref $controls smpl
        foreach y in `outcome' $dep_var_ref $iv_ref $controls {
          qui rename o_`y' `y' 
        }
    }
restore                

ereturn list
mat list e(b)
estout  m_ln_total_rwage_3m m_ln_hourly_rwage m_ln_whpw_3m ///
                m_formal ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(age age2 gender ///
        _cons $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres F))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab  m_ln_total_rwage_3m m_ln_hourly_rwage m_ln_whpw_3m ///
                m_formal   /// 
      using "$out_analysis/SR_REF_reg_IV_Cond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop(age age2 gender  ///
        _cons $controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - Results IV Regression with time and Individual FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a rkf, labels("Obs" "Adj. R-Squared" "KP-Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop  m_ln_total_rwage_3m m_ln_hourly_rwage m_ln_whpw_3m ///
                m_formal 











































                      ***************************
                      /* FALLAH ET AL ANALYSES */
                      ***************************


/*

                  **************************************
                  ***********     ANALYSIS    **********
                  **************************************

************************************
*Analysis
************************************

*Merging in xs
use "$data_JLMPS_base/JLMPS 2016 xs v1.1.dta", clear

merge 1:1 indid using "$data_Fallah_temp/JLMPS 2016 loc_code in 2010.dta"

gen loc_code=loc_code_2010

gen subdis_code=substr(loc_code,1,5)
replace subdis_code="" if subdis_code=="...."
destring subdis_code, replace

gen dis_code=substr(loc_code,1,4)
replace dis_code="" if dis_code=="...."
destring dis_code, replace

drop _merge

********
*Dist.
********

merge m:1 loc_code using "$data_Fallah_final/IV data.dta"

tabu _merge
drop if _merge==2

drop _merge

********
*2004 census
********

merge m:1 loc_code using "$data_Fallah_base/2004 census pct syr.dta"

tabu _merge
drop if _merge==2

drop _merge


*bys dis_code: egen pct_hh_syr_eg_2004_bydis = sum(prop_hh_syrians) 
*bys dis_code: egen prop_hh_syrians_bydis = sum(prop_hh_syrians) 

*Jordanians only
keep if nationality_cl==1 

*Adults only
keep if age>=15 & age<=64

gen year=round
label val year 
label var year "Year"


foreach var of varlist prop_* {
replace `var'=`var'*100
}

gen lhrwgall=ln(hrwgAllJob)

gen lmnthwgall=ln(mnthwgAllJob)

gen man_prof_=(usocp1d==1 | usocp1d==2 | usocp1d==3) if usocp1d!=.

gen usecactp_comp_=0 if usecactp!=.
*Ag
replace usecactp_comp_=1 if usecactp>=111 & usecactp<=322
*Manuf
replace usecactp_comp_=1 if usecactp>=1010 & usecactp<=3290
*Constr
replace usecactp_comp_=1 if usecactp>=4100 & usecactp<=4390
*Food & beverage
replace usecactp_comp_=1 if usecactp>=5610 & usecactp<=5630
replace usecactp_comp_=1 if usecactp==4630
replace usecactp_comp_=1 if usecactp==4711
replace usecactp_comp_=1 if usecactp==4721
replace usecactp_comp_=1 if usecactp==4722
replace usecactp_comp_=1 if usecactp==4781
*Domestic and cleaning
replace usecactp_comp_=1 if usecactp>=8110 & usecactp<=8130
replace usecactp_comp_=1 if usecactp==9700

*HHS
gen usecactp_hhs_=0 if usecactp!=.
replace usecactp_hhs_=1 if usecactp>=8510 & usecactp<=8690


*Private
gen uspriv_=1 if inlist(ussectrp,3)
replace uspriv_=0 if inlist(ussectrp,1,2,4,5)
 
la var prop_hh_syrian "Percentage of HH Syr."
 
destring loc_code, gen(ds_loc_code)


***********************
******Men--Census Syrians and Egyptians
***********************

foreach outcome of varlist unempsr1 usemp1 usformal lhrwgall ushrswk1 lmnthwgall  ///
man_prof usecactp_comp usecactp_hhs uspriv_ {


ivregress 2sls `outcome'  i.educ1d i.mteducst i.fteducst i.ftempst  ///
c.age c.age#c.age i.dis_code (prop_hh_syrians = pct_hh_syr_eg_2004 ) if sex==1 [aw=expan_indiv], vce(cluster loc_code)

estimates store `outcome'_m_3_c_eg

sort indid
set seed 792834

regress prop_hh_syrians pct_hh_syr_eg_2004  i.educ1d i.mteducst i.fteducst i.ftempst  ///
c.age c.age#c.age i.dis_code if sex==1 & `outcome'!=. [aw=expan_indiv], vce(cluster loc_code)

test pct_hh_syr_eg_2004

estadd scalar Z_fm_3_f=r(F)
estadd scalar Z_pm_3_f=r(p)

estimates store `outcome'_m_3_f_c_eg

}


tab nationality_cl year 
*drop if nationality_cl != 1

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016

drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016


     ivreg2  lmnthwgall ///
                c.age c.age#c.age i.dis_code i.educ1d i.fteducst i.mteducst i.ftempst  ///
                (prop_hh_syrians =  pct_hh_syr_eg_2004) ///
                [pweight = expan_indiv], ///
                cluster(loc_code) robust ///
                partial(i.dis_code)
                

*/











/*

***********************
*Pre-trends
***********************

*Merging into retro

use "$data_Fallah_final/JLMPS 2016 long.dta", clear


foreach num of numlist 2004/2017 {

gen int_`num'=0
replace int_`num'= prop_hh_syrians if year==`num'

la var int_`num' "Int. `num' and %  HH Syr."
}

la var prop_hh_syrian "Percentage of HH Syr."

destring indid, gen(ds_indid)

gen subdis_code=substr(loc_code,1,5)
replace subdis_code="" if subdis_code=="...."
destring subdis_code, replace

gen dis_code=substr(loc_code,1,4)
replace dis_code="" if dis_code=="...."
destring dis_code, replace


********
*Dist.
********

merge m:1 loc_code using "$data_Fallah_final/IV data.dta"

tabu _merge
drop if _merge==2

drop _merge

********
*2004 census
********

merge m:1 loc_code using "$data_Fallah_base/2004 census pct syr.dta"

tabu _merge
drop if _merge==2

drop _merge


*Testing pretrends - 2004 inst. 

foreach outcome of varlist lm_2 lm_3 formal_  man_prof_ usecactp_comp_ usecactp_hhs_ uspriv_  {

*Men
regress `outcome' pct_hh_syr_eg_2004 b2010.year b2010.year#c.pct_hh_syr_eg_2004 i.educ1d i.mteducst i.fteducst i.ftempst  ///
c.age c.age#c.age i.dis_code if sex==1 & year<=2010 [aw=expan_indiv], vce(cluster loc_code)

estimates store est_pret_men_`outcome'

}


*Testing pretrends - Zataari inst. 

foreach outcome of varlist lm_2 lm_3 formal_  man_prof_ usecactp_comp_ usecactp_hhs_ uspriv_ {

*Men
regress `outcome' ZataariCamp b2010.year b2010.year#c.ZataariCamp i.educ1d i.mteducst i.fteducst i.ftempst  ///
c.age c.age#c.age i.dis_code if sex==1 & year<=2010 [aw=expan_indiv], vce(cluster loc_code)

estimates store est_preZ_men_`outcome'

}

 *Men main results

* esttab est_pret_men* est_preZ_men*  using "Graphs/IV_pre_male.csv",  cells(b(star fmt(%9.3f)) se(par))  ///     
* stats(N r2, fmt(%9.0g %9.3f)) label  ///
* nobase noomit replace keep(*year* pct_* *ZataariCamp*) ///

*/
