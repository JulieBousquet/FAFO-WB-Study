


cap log close
clear all
set more off, permanently
set mem 100m

*log using "$out_analysis/11_IVRef_Analysis.log", replace

   ****************************************************************************
   **                            DATA IV REF                                 **
   **      HETERO ANALYSIS ON THE EFFECT OF REF INFLOW FOR SEC ANALYSIS      **  
   ** ---------------------------------------------------------------------- **
   ** Type Do  :  DATA JLMPS - FALLAH ET AL INSTRU      - HETEROGENOUS       **
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




                            ******************************
                            ** HETEROGENOUS ANALYSIS *****
                            ******************************


use "$data_final/07_IV_Ref_WP.dta", clear

tab ln_prop_hh_syrians year 
tab ln_IV_Ref_NETW year 


*tab IV_Ref_DIST 
corr prop_hh_syrians  IV_Ref_NETW
*corr prop_hh_syrians  IV_Ref_DIST

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




              *****************************************************************
              *****************************************************************
              ************************ GENDER *********************************
              *****************************************************************
              *****************************************************************




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



*Gender; 
tab gender, m 
codebook gender  


codebook gender
tab gender
lab var gender "Gender"

gen inter_gender = gender*$dep_var_ref
*gen inter_formal_IV = gender*$IV_var_ref
lab var inter_gender "Nbr Ref x gender"


**** OLS *****
  foreach outcome of global outcomes_uncond {
    qui xi: reg `outcome' $dep_var_ref inter_gender gender ///
                age age2 ///
                i.district_iid i.year  ///
            [pw = $weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref inter_gender gender) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_gender gender) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $outreg_uncond  /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(age age2 _Iyear_2016  $district ///
        _cons)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_uncond   /// 
      using "$out_analysis/SR_REF_reg_HET_GENDER_OLS_Uncond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "Employee" "Temp" "Employer" "SE" "Ag" "Manuf" "Commerce" "Services") ///
        drop(age age2 _Iyear_2016 $district _cons)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET GENDER - Results OLS Regression with time and district FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop $outreg_uncond





                        ***********************************
                        **           OLS                 **
                        **        UNCONDITIONAL          **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global outcomes_uncond {
       qui reghdfe `outcome' $dep_var_ref inter_gender gender ///
                age age2 ///  
                [pw = $weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $dep_var_ref  inter_gender gender ///
                age age2  {
        qui reghdfe `y' [pw = $weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $dep_var_ref inter_gender gender  age age2 /// 
       [pw = $weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($dep_var_ref  inter_gender gender) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref  inter_gender gender) 
      estimates store m_`outcome', title(Model `outcome')

      drop `outcome' inter_gender gender age age2   $dep_var_ref smpl
      
      foreach y in `outcome' inter_gender gender age age2  $dep_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $outreg_uncond /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(age age2 _cons)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_uncond /// 
      using "$out_analysis/SR_REF_reg_HET_GENDER_OLS_Uncond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "Employee" "Temp" "Employer" "SE" "Ag" "Manuf" "Commerce" "Services") ///
        drop(age age2  _cons )   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET GENDER - Results OLS Regression with time and Individual FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop $outreg_uncond
************






                                     ***************************
                                     ***************************
                                     *     EMPLOYED ONLY       *
                                     ***************************
                                     ***************************



drop if miss_16_10 == 1
drop if unemp_16_10 == 1
drop if olf_16_10 == 1
drop if emp_16_miss_10 == 1
drop if emp_10_miss_16 == 1
drop if unemp_16_miss_10 == 1
drop if unemp_10_miss_16 == 1
drop if olf_16_miss_10 == 1
drop if olf_10_miss_16 == 1 

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
    qui xi: reg `outcome' $dep_var_ref inter_gender gender ///
                age age2 ///
             i.district_iid i.year ///
            [pw = $weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref inter_gender gender) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_gender gender) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $outreg_cond /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop(age age2 _Iyear_2016 $district  _cons)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_cond   /// 
      using "$out_analysis/SR_REF_reg_HET_GENDER_OLS_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop(age age2 _Iyear_2016  $district _cons )   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET GENDER - Results OLS Regression with time and district FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop  $outreg_cond


                        ***********************************
                        **           OLS                 **
                        **        CONDITIONAL            **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global outcomes_cond {
       qui reghdfe `outcome' $dep_var_ref inter_gender gender ///
                age age2 ///  
                [pw = $weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $dep_var_ref inter_gender gender age age2 {
        qui reghdfe `y' [pw = $weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $dep_var_ref inter_gender gender age age2  [pw = $weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($dep_var_ref inter_gender gender ) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_gender gender ) 
      estimates store m_`outcome', title(Model `outcome')

      drop `outcome' inter_gender gender age age2 $dep_var_ref smpl
      
      foreach y in `outcome' inter_gender gender age age2 $dep_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $outreg_cond   /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(age age2   _cons )   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_cond   /// 
      using "$out_analysis/SR_REF_reg_HET_GENDER_OLS_Cond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop(age age2 _cons )   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET GENDER - Results OLS Regression with time and Individual FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop $outreg_cond  
************




















              *****************************************************************
              *****************************************************************
              ************************ URBAN **********************************
              *****************************************************************
              *****************************************************************

use "$data_final/07_IV_Ref_WP.dta", clear


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



 ***********
 ** URBAN **
 ***********

*Rural/urban 
replace urban = 0 if urban == 2  
lab def urban 0 "Rural" 1 "Urban", modify
lab val urban urban 

tab urban, m 
codebook urban  


codebook urban
tab urban
lab var urban "Urban"

gen inter_urban = urban*$dep_var_ref
*gen inter_formal_IV = urban*$IV_var_ref
lab var inter_urban "Nbr Ref x urban"


**** OLS *****
  foreach outcome of global outcomes_uncond {
    qui xi: reg `outcome' $dep_var_ref inter_urban urban ///
                $controls_SR  ///
                i.district_iid i.year  ///
            [pw = $weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref inter_urban urban) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_urban urban) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $outreg_uncond /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016  $district _cons $controls_SR)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_uncond  /// 
      using "$out_analysis/SR_REF_reg_HET_URBAN_OLS_Uncond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "Employee" "Temp" "Employer" "SE" "Ag" "Manuf" "Commerce" "Services") ///
        drop( _Iyear_2016  $district  _cons $controls_SR)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET URBAN - Results OLS Regression with time and district FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop $outreg_uncond





                        ***********************************
                        **           OLS                 **
                        **        UNCONDITIONAL          **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global outcomes_uncond {
       qui reghdfe `outcome' $dep_var_ref inter_urban urban ///
                $controls_SR ///  
                [pw = $weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $dep_var_ref  inter_urban urban ///
                $controls_SR {
        qui reghdfe `y' [pw = $weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $dep_var_ref inter_urban urban $controls_SR /// 
       [pw = $weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($dep_var_ref  inter_urban urban) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref  inter_urban urban) 
      estimates store m_`outcome', title(Model `outcome')

      drop `outcome' inter_urban urban $controls_SR  $dep_var_ref smpl
      
      foreach y in `outcome' inter_urban urban $controls_SR $dep_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $outreg_uncond  /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $controls_SR)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_uncond  /// 
      using "$out_analysis/SR_REF_reg_HET_URBAN_OLS_Uncond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "Employee" "Temp" "Employer" "SE" "Ag" "Manuf" "Commerce" "Services") ///
        drop(  _cons $controls_SR)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET URBAN - Results OLS Regression with time and Individual FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop $outreg_uncond
************






                                     ***************************
                                     ***************************
                                     *     EMPLOYED ONLY       *
                                     ***************************
                                     ***************************


drop if miss_16_10 == 1
drop if unemp_16_10 == 1
drop if olf_16_10 == 1
drop if emp_16_miss_10 == 1
drop if emp_10_miss_16 == 1
drop if unemp_16_miss_10 == 1
drop if unemp_10_miss_16 == 1
drop if olf_16_miss_10 == 1
drop if olf_10_miss_16 == 1 

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
    qui xi: reg `outcome' $dep_var_ref inter_urban urban ///
                $controls_SR ///
             i.district_iid i.year ///
            [pw = $weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref inter_urban urban) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_urban urban) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $outreg_cond /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop( _Iyear_2016  $district _cons $controls_SR)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_cond   /// 
      using "$out_analysis/SR_REF_reg_HET_URBAN_OLS_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop( _Iyear_2016 $district _cons $controls_SR)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET URBAN - Results OLS Regression with time and district FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop  $outreg_cond  



                        ***********************************
                        **           OLS                 **
                        **        CONDITIONAL            **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global outcomes_cond {
       qui reghdfe `outcome' $dep_var_ref inter_urban urban ///
                $controls_SR ///  
                [pw = $weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $dep_var_ref inter_urban urban $controls_SR {
        qui reghdfe `y' [pw = $weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $dep_var_ref inter_urban urban $controls_SR [pw = $weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($dep_var_ref inter_urban urban) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_urban urban) 
      estimates store m_`outcome', title(Model `outcome')

      drop `outcome' inter_urban urban $controls_SR $dep_var_ref smpl
      
      foreach y in `outcome' inter_urban urban $controls_SR $dep_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $outreg_cond   /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(  _cons $controls_SR)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_cond  /// 
      using "$out_analysis/SR_REF_reg_HET_URBAN_OLS_Cond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop(age age2 gender  ///
        _cons $controls_SR)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET URBAN - Results OLS Regression with time and Individual FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop $outreg_cond 
************















              *****************************************************************
              *****************************************************************
              ************************ EDUCATION ******************************
              *****************************************************************
              *****************************************************************

use "$data_final/07_IV_Ref_WP.dta", clear


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



 ***************
 ** EDUCATION **
 ***************

tab bi_education, m 
codebook bi_education  


codebook bi_education
tab bi_education
lab var bi_education "Education"

gen inter_educ = bi_education*$dep_var_ref
*gen inter_formal_IV = bi_education*$IV_var_ref
lab var inter_educ "Nbr Ref x education"


**** OLS *****
  foreach outcome of global outcomes_uncond {
    qui xi: reg `outcome' $dep_var_ref inter_educ bi_education ///
                $controls_SR  ///
                i.district_iid i.year  ///
            [pw = $weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref inter_educ bi_education) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_educ bi_education) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $outreg_uncond /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016 $district _cons $controls_SR)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_uncond  /// 
      using "$out_analysis/SR_REF_reg_HET_EDUC_OLS_Uncond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "Employee" "Temp" "Employer" "SE" "Ag" "Manuf" "Commerce" "Services") ///
        drop( _Iyear_2016  $district _cons $controls_SR)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET EDUC - Results OLS Regression with time and district FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop $outreg_uncond





                        ***********************************
                        **           OLS                 **
                        **        UNCONDITIONAL          **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global outcomes_uncond {
       qui reghdfe `outcome' $dep_var_ref inter_educ bi_education ///
                $controls_SR ///  
                [pw = $weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $dep_var_ref  inter_educ bi_education ///
                $controls_SR {
        qui reghdfe `y' [pw = $weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $dep_var_ref inter_educ bi_education $controls_SR /// 
       [pw = $weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($dep_var_ref  inter_educ bi_education) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref  inter_educ bi_education) 
      estimates store m_`outcome', title(Model `outcome')

      drop `outcome' inter_educ bi_education $controls_SR  $dep_var_ref smpl
      
      foreach y in `outcome' inter_educ bi_education $controls_SR $dep_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $outreg_uncond /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $controls_SR)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_uncond   /// 
      using "$out_analysis/SR_REF_reg_HET_EDUC_OLS_Uncond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "Employee" "Temp" "Employer" "SE" "Ag" "Manuf" "Commerce" "Services") ///
        drop( _cons $controls_SR)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET EDUC - Results OLS Regression with time and Individual FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop $outreg_uncond  
************






                                     ***************************
                                     ***************************
                                     *     EMPLOYED ONLY       *
                                     ***************************
                                     ***************************



drop if miss_16_10 == 1
drop if unemp_16_10 == 1
drop if olf_16_10 == 1
drop if emp_16_miss_10 == 1
drop if emp_10_miss_16 == 1
drop if unemp_16_miss_10 == 1
drop if unemp_10_miss_16 == 1
drop if olf_16_miss_10 == 1
drop if olf_10_miss_16 == 1 

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
    qui xi: reg `outcome' $dep_var_ref inter_educ bi_education ///
                $controls_SR ///
             i.district_iid i.year ///
            [pw = $weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref inter_educ bi_education) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_educ bi_education) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $outreg_cond /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop( _Iyear_2016  $district _cons $controls_SR)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_cond  /// 
      using "$out_analysis/SR_REF_reg_HET_EDUC_OLS_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop( _Iyear_2016  $district _cons $controls_SR)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET EDUC - Results OLS Regression with time and district FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop  $outreg_cond  



                        ***********************************
                        **           OLS                 **
                        **        CONDITIONAL            **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global outcomes_cond {
       qui reghdfe `outcome' $dep_var_ref inter_educ bi_education ///
                $controls_SR ///  
                [pw = $weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $dep_var_ref inter_educ bi_education $controls_SR {
        qui reghdfe `y' [pw = $weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $dep_var_ref inter_educ bi_education $controls_SR [pw = $weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($dep_var_ref inter_educ bi_education) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_educ bi_education) 
      estimates store m_`outcome', title(Model `outcome')

      drop `outcome' inter_educ bi_education $controls_SR $dep_var_ref smpl
      
      foreach y in `outcome' inter_educ bi_education $controls_SR $dep_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $outreg_cond /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $controls_SR)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_cond  /// 
      using "$out_analysis/SR_REF_reg_HET_EDUC_OLS_Cond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop( _cons $controls_SR)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET EDUC - Results OLS Regression with time and Individual FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop $outreg_cond 
************











/*


 *********
 ** LFP **
 *********

*LFP/Type of work: 
tab lfp_3m
tab lfp_empl_7d
tab lfp_temp_7d 
tab lfp_employer_7d 
tab lfp_se_7d 
*tab lfp_3m_unpaid


              *****************************************************************
              *****************************************************************
              ************************ LFP ******************************
              *****************************************************************
              *****************************************************************

use "$data_final/07_IV_Ref_WP.dta", clear


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



 ***************
 ** EDUCATION **
 ***************

tab bi_education, m 
codebook bi_education  


codebook bi_education
tab bi_education
lab var bi_education "Education"

gen inter_educ = bi_education*$dep_var_ref
*gen inter_formal_IV = bi_education*$IV_var_ref
lab var inter_educ "Nbr Ref x education"


**** OLS *****
  foreach outcome of global outcomes_uncond {
    qui xi: reg `outcome' $dep_var_ref inter_educ bi_education ///
                $controls_SR  ///
                i.district_iid i.year  ///
            [pw = $weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref inter_educ bi_education) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_educ bi_education) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $outreg_uncond  /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016  $district _cons $controls_SR)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_uncond    /// 
      using "$out_analysis/SR_REF_reg_HET_EDUC_OLS_Uncond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "Employee" "Temp" "Employer" "SE" "Ag" "Manuf" "Commerce" "Services") ///
        drop( _Iyear_2016  $district _cons $controls_SR)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET EDUC - Results OLS Regression with time and district FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop $outreg_uncond 





                        ***********************************
                        **           OLS                 **
                        **        UNCONDITIONAL          **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global outcomes_uncond {
       qui reghdfe `outcome' $dep_var_ref inter_educ bi_education ///
                $controls_SR ///  
                [pw = $weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $dep_var_ref  inter_educ bi_education ///
                $controls_SR {
        qui reghdfe `y' [pw = $weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $dep_var_ref inter_educ bi_education $controls_SR /// 
       [pw = $weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($dep_var_ref  inter_educ bi_education) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref  inter_educ bi_education) 
      estimates store m_`outcome', title(Model `outcome')

      drop `outcome' inter_educ bi_education $controls_SR  $dep_var_ref smpl
      
      foreach y in `outcome' inter_educ bi_education $controls_SR $dep_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $outreg_uncond  /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $controls_SR)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_uncond   /// 
      using "$out_analysis/SR_REF_reg_HET_EDUC_OLS_Uncond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "Employee" "Temp" "Employer" "SE" "Ag" "Manuf" "Commerce" "Services") ///
        drop( _cons $controls_SR)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET EDUC - Results OLS Regression with time and Individual FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop $outreg_uncond 
************






                                     ***************************
                                     ***************************
                                     *     EMPLOYED ONLY       *
                                     ***************************
                                     ***************************


drop if miss_16_10 == 1
drop if unemp_16_10 == 1
drop if olf_16_10 == 1
drop if emp_16_miss_10 == 1
drop if emp_10_miss_16 == 1
drop if unemp_16_miss_10 == 1
drop if unemp_10_miss_16 == 1
drop if olf_16_miss_10 == 1
drop if olf_10_miss_16 == 1 

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
    qui xi: reg `outcome' $dep_var_ref inter_educ bi_education ///
                $controls_SR ///
             i.district_iid i.year ///
            [pw = $weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref inter_educ bi_education) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_educ bi_education) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $outreg_cond  /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
        drop( _Iyear_2016 $district _cons $controls_SR)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_cond /// 
      using "$out_analysis/SR_REF_reg_HET_EDUC_OLS_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop( _Iyear_2016 $district _cons $controls_SR)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET EDUC - Results OLS Regression with time and district FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop  $outreg_cond



                        ***********************************
                        **           OLS                 **
                        **        CONDITIONAL            **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global outcomes_cond {
       qui reghdfe `outcome' $dep_var_ref inter_educ bi_education ///
                $controls_SR ///  
                [pw = $weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $dep_var_ref inter_educ bi_education $controls_SR {
        qui reghdfe `y' [pw = $weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $dep_var_ref inter_educ bi_education $controls_SR [pw = $weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($dep_var_ref inter_educ bi_education) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_educ bi_education) 
      estimates store m_`outcome', title(Model `outcome')

      drop `outcome' inter_educ bi_education $controls_SR $dep_var_ref smpl
      
      foreach y in `outcome' inter_educ bi_education $controls_SR $dep_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $outreg_cond   /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $controls_SR)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab $outreg_cond /// 
      using "$out_analysis/SR_REF_reg_HET_EDUC_OLS_Cond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Total Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
        drop( _cons $controls_SR)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - HET EDUC - Results OLS Regression with time and Individual FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop $outreg_cond 
************


*/
