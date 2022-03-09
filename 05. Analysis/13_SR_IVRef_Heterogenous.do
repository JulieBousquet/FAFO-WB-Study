


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


use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

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


                              ************************
                              ***        OLS       ***
                              ************************

                        ***********************************
                        **           OLS                 **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************



*Gender; 
tab gender, m 
codebook gender  


codebook gender
tab gender
lab var gender "Gender"

gen inter_gender = gender*$SR_treat_var_ref
*gen inter_formal_IV = gender*$IV_var_ref
lab var inter_gender "Nbr Ref x gender"

global het_var          gender
global inter_het_var    inter_gender

**** OLS *****
  foreach outcome of global SR_outcome {
    qui xi: reg `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                age age2 ///
                i.district_iid i.year  ///
            [pw = $SR_weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
    estimates store REFGEN_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $REFGEN_YD_p1 $REFGEN_YD_p2 /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(age age2 _Iyear_2016  $district ///
        _cons)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))





                        ***********************************
                        **           OLS                 **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global SR_outcome {
       qui reghdfe `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                age age2 ///  
                [pw = $SR_weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $SR_treat_var_ref  $inter_het_var $het_var ///
                age age2  {
        qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $SR_treat_var_ref $inter_het_var $het_var age age2 /// 
       [pw = $SR_weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($SR_treat_var_ref  $inter_het_var $het_var) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
      estimates store REFGEN_YI_`outcome', title(Model `outcome')

      drop `outcome' $inter_het_var $het_var age age2   $SR_treat_var_ref smpl
      
      foreach y in `outcome' $inter_het_var $het_var age age2  $SR_treat_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $REFGEN_YI_p1 $REFGEN_YI_p2 /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop(age age2 _cons)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))






****************************************************
****************************************************
************* GRAPH HETERO GENDER ******************
****************************************************
****************************************************

     coefplot (REFGEN_YD_employed_olf_$rp), bylabel(Employed)  ///
             || (REFGEN_YD_unemployed_$rp), bylabel(Unemployed)  ///
             || (REFGEN_YD_lfp_empl_$rp), bylabel(Type: Wage Worker)  ///
             || (REFGEN_YD_lfp_temp_$rp), bylabel(Type: Temporary)  ///
             || (REFGEN_YD_lfp_employer_$rp), bylabel(Type: Employer)  ///
             || (REFGEN_YD_lfp_se_$rp), bylabel(Type: SE) ///
             || (REFGEN_YD_act_ag_$rp), bylabel(Activity: Agricultural)  ///
             || (REFGEN_YD_act_manuf_$rp), bylabel(Activity: Manufacturing)  ///
             || (REFGEN_YD_act_com_$rp), bylabel(Activity: Commerce)  ///
             || (REFGEN_YD_act_serv_$rp), bylabel(Activity: Services)  ///
             || (REFGEN_YD_ln_mrwage_main), bylabel(Monthly Wage (ln)) ///
             || (REFGEN_YD_ln_hrwage_main), bylabel(Hourly Wage (ln)) ///
             || (REFGEN_YD_ln_whpw_w_$rp), bylabel(Work Hours p.w. (ln)) ///
             || (REFGEN_YD_formal), bylabel(Formal) ///
             || , drop( _Iyear_2016 $district _cons age age2) ///
              xline(0) msymbol(d) ///
              label subtitle(, size(vsmall) fcolor(white) nobox ) ///
             xlabel("") ylabel(1 "Treat" 2 "Inter" 3 "VoI") ///
             mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
             cond(@pval<.05, string(@b,"%9.3f") + "**", ///
             cond(@pval<.1, string(@b,"%9.3f") + "*", ///
             string(@b, "%5.3f")  ) ) ) ) mlabposition(10) mlabsize(tiny) ///
             byopts(graphregion(color(white)) bgcolor(white) ///
              title("Effect Sizes: Gender", size(small))) ///
                yscale(noline alt)  xscale(noline alt) legend(nobox ///
                region(lstyle(none)) size(vsmall) cols(4) ring(0) )  ///
            levels(99.9 99 95) ciopts(lwidth(*1) lcolor(*.6)) xla(none) xtitle("") xsc(noline) ///
            keep($SR_treat_var_ref $inter_het_var $het_var)


graph export "$out_analysis\SR_HET_GENDER_Combined_Graph_REF.pdf", as(pdf) replace









              *****************************************************************
              *****************************************************************
              ************************ URBAN **********************************
              *****************************************************************
              *****************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear


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

                              ************************
                              ***        OLS       ***
                              ************************

                        ***********************************
                        **           OLS                 **
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

gen inter_urban = urban*$SR_treat_var_ref
*gen inter_formal_IV = urban*$IV_var_ref
lab var inter_urban "Nbr Ref x urban"

global het_var          urban
global inter_het_var    inter_urban
 


**** OLS *****
  foreach outcome of global SR_outcome {
    qui xi: reg `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls  ///
                i.district_iid i.year  ///
            [pw = $SR_weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
    estimates store REFURB_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $REFURB_YD_p1 $REFURB_YD_p2 /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016  $district _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))





                        ***********************************
                        **           OLS                 **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global SR_outcome {
       qui reghdfe `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls ///  
                [pw = $SR_weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls {
        qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $SR_treat_var_ref $inter_het_var $het_var $SR_controls /// 
       [pw = $SR_weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
      estimates store REFURB_YI_`outcome', title(Model `outcome')

      drop `outcome' $inter_het_var $het_var $SR_controls  $SR_treat_var_ref smpl
      
      foreach y in `outcome' $inter_het_var $het_var $SR_controls $SR_treat_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $REFURB_YI_p1 $REFURB_YI_p2 /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))




****************************************************
****************************************************
************* GRAPH HETERO URBAN *************************
****************************************************
****************************************************



coefplot (REFURB_YD_employed_olf_$rp), bylabel(Employed)  ///
             || (REFURB_YD_unemployed_$rp), bylabel(Unemployed)  ///
             || (REFURB_YD_lfp_empl_$rp), bylabel(Type: Wage Worker)  ///
             || (REFURB_YD_lfp_temp_$rp), bylabel(Type: Temporary)  ///
             || (REFURB_YD_lfp_employer_$rp), bylabel(Type: Employer)  ///
             || (REFURB_YD_lfp_se_$rp), bylabel(Type: SE) ///
             || (REFURB_YD_act_ag_$rp), bylabel(Activity: Agricultural)  ///
             || (REFURB_YD_act_manuf_$rp), bylabel(Activity: Manufacturing)  ///
             || (REFURB_YD_act_com_$rp), bylabel(Activity: Commerce)  ///
             || (REFURB_YD_act_serv_$rp), bylabel(Activity: Services)  ///
             || (REFURB_YD_ln_mrwage_main), bylabel(Total Wage (ln)) ///
             || (REFURB_YD_ln_hrwage_main), bylabel(Hourly Wage (ln)) ///
             || (REFURB_YD_ln_whpw_w_$rp), bylabel(Work Hours p.w. (ln)) ///
             || (REFURB_YD_formal), bylabel(Formal) ///
             || , drop( _Iyear_2016 $district _cons $SR_controls) ///
              xline(0) msymbol(d) ///
              label subtitle(, size(vsmall) fcolor(white) nobox ) ///
             xlabel("") ylabel(1 "Treat" 2 "Inter" 3 "VoI") ///
             mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
             cond(@pval<.05, string(@b,"%9.3f") + "**", ///
             cond(@pval<.1, string(@b,"%9.3f") + "*", ///
             string(@b, "%5.3f")  ) ) ) ) mlabposition(10) mlabsize(tiny) ///
             byopts(graphregion(color(white)) bgcolor(white) ///
              title("Effect Sizes: Urban", size(small))) ///
                yscale(noline alt)  xscale(noline alt) legend(nobox ///
                region(lstyle(none)) size(vsmall) cols(4) ring(0) )  ///
            levels(99.9 99 95) ciopts(lwidth(*1) lcolor(*.6)) xla(none) xtitle("") xsc(noline) ///
            keep($SR_treat_var_ref $inter_het_var $het_var)


graph export "$out_analysis\SR_HET_URBAN_Combined_Graph_REF.pdf", as(pdf) replace













              *****************************************************************
              *****************************************************************
              ************************ EDUCATION ******************************
              *****************************************************************
              *****************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear


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


                              ************************
                              ***        OLS       ***
                              ************************

                        ***********************************
                        **           OLS                 **
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

gen inter_educ = bi_education*$SR_treat_var_ref
*gen inter_formal_IV = bi_education*$IV_var_ref
lab var inter_educ "Nbr Ref x education"

global het_var          bi_education
global inter_het_var    inter_educ


**** OLS *****
  foreach outcome of global SR_outcome {
     qui xi: reg `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls  ///
                i.district_iid i.year  ///
            [pw = $SR_weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
    estimates store REFEDU_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $REFEDU_YD_p1 $REFEDU_YD_p2 /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016 $district _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))





                        ***********************************
                        **           OLS                 **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global SR_outcome {
       qui reghdfe `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls ///  
                [pw = $SR_weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls {
        qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $SR_treat_var_ref $inter_het_var $het_var $SR_controls /// 
       [pw = $SR_weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
      estimates store REFEDU_YI_`outcome', title(Model `outcome')

      drop `outcome' $inter_het_var $het_var $SR_controls  $SR_treat_var_ref smpl
      
      foreach y in `outcome' $inter_het_var $het_var $SR_controls $SR_treat_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $REFEDU_YI_p1 $REFEDU_YI_p2 /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))



****************************************************
****************************************************
************* GRAPH HETERO EDUCATION *************************
****************************************************
****************************************************


    coefplot (REFEDU_YD_employed_olf_$rp), bylabel(Employed)  ///
             || (REFEDU_YD_unemployed_$rp), bylabel(Unemployed)  ///
             || (REFEDU_YD_lfp_empl_$rp), bylabel(Type: Wage Worker)  ///
             || (REFEDU_YD_lfp_temp_$rp), bylabel(Type: Temporary)  ///
             || (REFEDU_YD_lfp_employer_$rp), bylabel(Type: Employer)  ///
             || (REFEDU_YD_lfp_se_$rp), bylabel(Type: SE) ///
             || (REFEDU_YD_act_ag_$rp), bylabel(Activity: Agricultural) ///
             || (REFEDU_YD_act_manuf_$rp), bylabel(Activity: Manufacturing)  ///
             || (REFEDU_YD_act_com_$rp), bylabel(Activity: Commerce)  ///
             || (REFEDU_YD_act_serv_$rp), bylabel(Activity: Services)  ///
             || (REFEDU_YD_ln_mrwage_main), bylabel(Total Wage (ln)) ///
             || (REFEDU_YD_ln_hrwage_main), bylabel(Hourly Wage (ln)) ///
             || (REFEDU_YD_ln_whpw_w_$rp), bylabel(Work Hours p.w. (ln)) ///
             || (REFEDU_YD_formal), bylabel(Formal) ///
             || , drop(_Iyear_2016 $district _cons $SR_controls) ///
              xline(0) msymbol(d) ///
              label subtitle(, size(vsmall) fcolor(white) nobox ) ///
             xlabel("") ylabel(1 "Treat" 2 "Inter" 3 "VoI") ///
             mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
             cond(@pval<.05, string(@b,"%9.3f") + "**", ///
             cond(@pval<.1, string(@b,"%9.3f") + "*", ///
             string(@b, "%5.3f")  ) ) ) ) mlabposition(10) mlabsize(tiny) ///
             byopts(graphregion(color(white)) bgcolor(white) ///
              title("Effect Sizes: Education", size(small))) ///
                yscale(noline alt)  xscale(noline alt) legend(nobox ///
                region(lstyle(none)) size(vsmall) cols(4) ring(0) )  ///
            levels(99.9 99 95) ciopts(lwidth(*1) lcolor(*.6)) xla(none) xtitle("") xsc(noline) ///
            keep($SR_treat_var_ref $inter_het_var $het_var)


graph export "$out_analysis\SR_HET_EDUC_Combined_Graph_REF.pdf", as(pdf) replace












*********************************************
*********************************************
********* MERGE TABLES UNCOND **********************
*********************************************
*********************************************



esttab $REFGEN_YD_p1   /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_p1.tex",  ///
      prehead("\begin{tabular}{l*{6}{c}} \toprule ") ///
      posthead("& & & & & &  \\  & b (se) & b (se) & b (se) & b (se) & b (se) & b (se)  \\ \midrule \midrule \multicolumn{7}{c}{\textit{\textbf{GENDER}}} \\ \multicolumn{7}{c}{\textit{PANEL A: District and Year Fixed Effects}} \\  \midrule ") ///
      fragment replace label ///
    drop($district _cons age age2 _Iyear_2016)   ///
      mtitles("\multirow{2}{*}{Employed}" "\multirow{2}{*}{Unemployed}" "\multirow{2}{*}{Total Wage (ln)}" "\multirow{2}{*}{Hourly Wage (ln)}" "\multirow{2}{*}{\shortstack[c]{Work Hours\\ p.w. (ln)}}" "\multirow{2}{*}{Formal}") ///
      varlabel(inter_gender "Nbr Ref x Gender" gender "Gender (Male)") ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]")) ///
      b(%8.3f) se(%8.3f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFGEN_YI_p1  /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_p1.tex",  ///
      posthead("\midrule  \multicolumn{7}{c}{\textit{PANEL B: Individual and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop(  _cons  age age2 )   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      varlabel(inter_gender "Nbr Ref x Gender" gender "Gender (Male)") ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFURB_YD_p1    /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_p1.tex",  ///
      posthead("\midrule \midrule \multicolumn{7}{c}{\textit{\textbf{URBAN}}} \\ \multicolumn{7}{c}{\textit{PANEL C: District and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons $district _Iyear_2016)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      varlabel(inter_urban "Nbr Ref x Urban" urban "Urban") ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFURB_YI_p1    /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_p1.tex",  ///
      posthead("\midrule \multicolumn{7}{c}{\textit{PANEL D: Individual and Year Fixed Effects}} \\  \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons )   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      varlabel(inter_urban "Nbr Ref x Urban" urban "Urban") ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFEDU_YD_p1    /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_p1.tex",  ///
      posthead("\midrule \midrule \multicolumn{7}{c}{\textit{\textbf{EDUCATION}}} \\ \multicolumn{7}{c}{\textit{PANEL E: District and Year Fixed Effects}} \\  \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons $district _Iyear_2016)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      varlabel(inter_educ "Nbr Ref x Education" bi_education "Education") ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFEDU_YI_p1  /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_p1.tex",  ///
      posthead("\midrule \multicolumn{7}{c}{\textit{PANEL F: Individual and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      varlabel(inter_educ "Nbr Ref x Education" bi_education "Education") ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") ///
      postfoot("\bottomrule  \end{tabular}  ")

















esttab $REFGEN_YD_p2   /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_p2.tex",  ///
      prehead("\begin{tabular}{l*{8}{c}} \toprule ") ///
      posthead("& & & & & & & & \\ & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se)  \\ \midrule \midrule \multicolumn{9}{c}{\textit{\textbf{GENDER}}} \\ \multicolumn{9}{c}{\textit{PANEL A: District and Year Fixed Effects}} \\  \midrule ") ///
      fragment replace label ///
    drop($district _cons age age2 _Iyear_2016)   ///
      mtitles("\multirow{2}{*}{Employee}" "\multirow{2}{*}{Temporary}" "\multirow{2}{*}{Employer}" "\multirow{2}{*}{SE}" "\multirow{2}{*}{Agriculture}" "\multirow{2}{*}{Manufacturing}" "\multirow{2}{*}{Commerce}" "\multirow{2}{*}{Services}") ///
      varlabel(inter_gender "Nbr Ref x Gender" gender "Gender (Male)") ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]")) ///
      b(%8.3f) se(%8.3f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFGEN_YI_p2  /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_p2.tex",  ///
      posthead("\midrule  \multicolumn{9}{c}{\textit{PANEL B: Individual and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop(  _cons  age age2 )   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      varlabel(inter_gender "Nbr Ref x Gender" gender "Gender (Male)") ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFURB_YD_p2    /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_p2.tex",  ///
      posthead("\midrule \midrule \multicolumn{9}{c}{\textit{\textbf{URBAN}}} \\ \multicolumn{9}{c}{\textit{PANEL C: District and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons $district _Iyear_2016)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      varlabel(inter_urban "Nbr Ref x Urban" urban "Urban") ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFURB_YI_p2    /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_p2.tex",  ///
      posthead("\midrule \multicolumn{9}{c}{\textit{PANEL D: Individual and Year Fixed Effects}} \\  \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons )   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      varlabel(inter_urban "Nbr Ref x Urban" urban "Urban") ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\hline") //

esttab $REFEDU_YD_p2    /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_p2.tex",  ///
      posthead("\midrule \midrule \multicolumn{9}{c}{\textit{\textbf{EDUCATION}}} \\ \multicolumn{9}{c}{\textit{PANEL E: District and Year Fixed Effects}} \\  \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons $district _Iyear_2016)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      varlabel(inter_educ "Nbr Ref x Education" bi_education "Education") ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFEDU_YI_p2  /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_p2.tex",  ///
      posthead("\midrule \multicolumn{9}{c}{\textit{PANEL F: Individual and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      varlabel(inter_educ "Nbr Ref x Education" bi_education "Education") ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") ///
      postfoot("\bottomrule  \end{tabular}  ")














         

              *************************************************************************
              *************************************************************************
              ************************ LFP WAGE EMPL **********************************
              *************************************************************************
              *************************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear


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


xtset, clear 
xtset indid_2010 year 


                              ************************
                              ***        OLS       ***
                              ************************

                        ***********************************
                        **           OLS                 **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************



 ***********
 ** URBAN **
 ***********

*Rural/urban 
tab lfp_7d, m 
tab lfp_empl_7d, m 
lab var lfp_empl_7d "Wage Employee"

gen inter_lfp_empl_7d = lfp_empl_7d*$SR_treat_var_ref
*gen inter_formal_IV = urban*$IV_var_ref
lab var inter_lfp_empl_7d "Nbr Ref x Wage Empl"

global het_var          lfp_empl_7d
global inter_het_var    inter_lfp_empl_7d


**** OLS *****
  foreach outcome of global SR_outcome_HET_LFP {
    qui xi: reg `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls  ///
                i.district_iid i.year  ///
            [pw = $SR_weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
    estimates store WEMP_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $SR_outcome_WEMP_YD /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016 $district _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))



                        ***********************************
                        **           OLS                 **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global SR_outcome_HET_LFP {
       qui reghdfe `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls ///  
                [pw = $SR_weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls {
        qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $SR_treat_var_ref $inter_het_var $het_var $SR_controls /// 
       [pw = $SR_weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
      estimates store WEMP_YI_`outcome', title(Model `outcome')

      drop `outcome' $inter_het_var $het_var $SR_controls  $SR_treat_var_ref smpl
      
      foreach y in `outcome' $inter_het_var $het_var $SR_controls $SR_treat_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $SR_outcome_WEMP_YI /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))




********************************************************************
********************************************************************
************* GRAPH HETERO WAGE EMPLOYMENT *************************
********************************************************************
********************************************************************



coefplot      (WEMP_YD_act_ag_$rp), bylabel(Activity: Agricultural)  ///
             || (WEMP_YD_act_manuf_$rp), bylabel(Activity: Manufacturing)  ///
             || (WEMP_YD_act_com_$rp), bylabel(Activity: Commerce)  ///
             || (WEMP_YD_act_serv_$rp), bylabel(Activity: Services)  ///
             || (WEMP_YD_ln_mrwage_main), bylabel(Total Wage (ln)) ///
             || (WEMP_YD_ln_hrwage_main), bylabel(Hourly Wage (ln)) ///
             || (WEMP_YD_ln_whpw_w_$rp), bylabel(Work Hours p.w. (ln)) ///
             || (WEMP_YD_formal), bylabel(Formal) ///
             || , drop( _Iyear_2016 $district _cons $SR_controls) ///
              xline(0) msymbol(d) ///
              label subtitle(, size(vsmall) fcolor(white) nobox ) ///
             xlabel("") ylabel(1 "Treat" 2 "Inter" 3 "VoI") ///
             mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
             cond(@pval<.05, string(@b,"%9.3f") + "**", ///
             cond(@pval<.1, string(@b,"%9.3f") + "*", ///
             string(@b, "%5.3f")  ) ) ) ) mlabposition(10) mlabsize(tiny) ///
             byopts(graphregion(color(white)) bgcolor(white) ///
              title("Effect Sizes: Wage Employment", size(small))) ///
                yscale(noline alt)  xscale(noline alt) legend(nobox ///
                region(lstyle(none)) size(vsmall) cols(4) ring(0) )  ///
            levels(99.9 99 95) ciopts(lwidth(*1) lcolor(*.6)) xla(none) xtitle("") xsc(noline) ///
            keep($SR_treat_var_ref $inter_het_var $het_var)


graph export "$out_analysis\SR_HET_WEMP_Combined_Graph_REF.pdf", as(pdf) replace





              *************************************************************************
              *************************************************************************
              ************************ LFP TEMPORARY **********************************
              *************************************************************************
              *************************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear


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


xtset, clear 
xtset indid_2010 year 


                              ************************
                              ***        OLS       ***
                              ************************

                        ***********************************
                        **           OLS                 **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************



 ***********
 ** URBAN **
 ***********

*Rural/urban 
tab lfp_7d, m 
tab lfp_temp_7d, m 
lab var lfp_temp_7d "Temporary"

gen inter_lfp_temp_7d = lfp_temp_7d*$SR_treat_var_ref
*gen inter_formal_IV = urban*$IV_var_ref
lab var inter_lfp_temp_7d "Nbr Ref x Temporary"

global het_var          lfp_temp_7d
global inter_het_var    inter_lfp_temp_7d
 

**** OLS *****
  foreach outcome of global SR_outcome_HET_LFP {
    qui xi: reg `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls  ///
                i.district_iid i.year  ///
            [pw = $SR_weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
    estimates store TEMP_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $SR_outcome_TEMP_YD /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016 $district _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))



                        ***********************************
                        **           OLS                 **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global SR_outcome_HET_LFP {
       qui reghdfe `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls ///  
                [pw = $SR_weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls {
        qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $SR_treat_var_ref $inter_het_var $het_var $SR_controls /// 
       [pw = $SR_weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
      estimates store TEMP_YI_`outcome', title(Model `outcome')

      drop `outcome' $inter_het_var $het_var $SR_controls  $SR_treat_var_ref smpl
      
      foreach y in `outcome' $inter_het_var $het_var $SR_controls $SR_treat_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $SR_outcome_TEMP_YI /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))




********************************************************************
********************************************************************
************* GRAPH HETERO Temporary *************************
********************************************************************
********************************************************************



coefplot      (TEMP_YD_act_ag_$rp), bylabel(Activity: Agricultural)  ///
             || (TEMP_YD_act_manuf_$rp), bylabel(Activity: Manufacturing)  ///
             || (TEMP_YD_act_com_$rp), bylabel(Activity: Commerce)  ///
             || (TEMP_YD_act_serv_$rp), bylabel(Activity: Services)  ///
             || (TEMP_YD_ln_mrwage_main), bylabel(Total Wage (ln)) ///
             || (TEMP_YD_ln_hrwage_main), bylabel(Hourly Wage (ln)) ///
             || (TEMP_YD_ln_whpw_w_$rp), bylabel(Work Hours p.w. (ln)) ///
             || (TEMP_YD_formal), bylabel(Formal) ///
             || , drop( _Iyear_2016 $district _cons $SR_controls) ///
              xline(0) msymbol(d) ///
              label subtitle(, size(vsmall) fcolor(white) nobox ) ///
             xlabel("") ylabel(1 "Treat" 2 "Inter" 3 "VoI") ///
             mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
             cond(@pval<.05, string(@b,"%9.3f") + "**", ///
             cond(@pval<.1, string(@b,"%9.3f") + "*", ///
             string(@b, "%5.3f")  ) ) ) ) mlabposition(10) mlabsize(tiny) ///
             byopts(graphregion(color(white)) bgcolor(white) ///
              title("Effect Sizes: Temporary", size(small))) ///
                yscale(noline alt)  xscale(noline alt) legend(nobox ///
                region(lstyle(none)) size(vsmall) cols(4) ring(0) )  ///
            levels(99.9 99 95) ciopts(lwidth(*1) lcolor(*.6)) xla(none) xtitle("") xsc(noline) ///
            keep($SR_treat_var_ref $inter_het_var $het_var)


graph export "$out_analysis\SR_HET_TEMP_Combined_Graph_REF.pdf", as(pdf) replace










              *************************************************************************
              *************************************************************************
              ************************ LFP SELF EMP ***********************************
              *************************************************************************
              *************************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear


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


xtset, clear 
xtset indid_2010 year 


                              ************************
                              ***        OLS       ***
                              ************************

                        ***********************************
                        **           OLS                 **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************



 ***********
 ** URBAN **
 ***********

*Rural/urban 
tab lfp_7d, m 
tab lfp_se_7d, m 
lab var lfp_se_7d "Self Employment"

gen inter_lfp_se_7d = lfp_se_7d*$SR_treat_var_ref
*gen inter_formal_IV = urban*$IV_var_ref
lab var inter_lfp_se_7d "Nbr Ref x Self Empl"

global het_var          lfp_se_7d
global inter_het_var    inter_lfp_se_7d

**** OLS *****
  foreach outcome of global SR_outcome_HET_LFP {
    qui xi: reg `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls  ///
                i.district_iid i.year  ///
            [pw = $SR_weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
    estimates store SE_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $SR_outcome_SE_YD /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016 $district _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))



                        ***********************************
                        **           OLS                 **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global SR_outcome_HET_LFP {
       qui reghdfe `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls ///  
                [pw = $SR_weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls {
        qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $SR_treat_var_ref $inter_het_var $het_var $SR_controls /// 
       [pw = $SR_weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
      estimates store SE_YI_`outcome', title(Model `outcome')

      drop `outcome' $inter_het_var $het_var $SR_controls  $SR_treat_var_ref smpl
      
      foreach y in `outcome' $inter_het_var $het_var $SR_controls $SR_treat_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $SR_outcome_SE_YI /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))




********************************************************************
********************************************************************
************* GRAPH HETERO WAGE EMPLOYMENT *************************
********************************************************************
********************************************************************



coefplot      (SE_YD_act_ag_$rp), bylabel(Activity: Agricultural)  ///
             || (SE_YD_act_manuf_$rp), bylabel(Activity: Manufacturing)  ///
             || (SE_YD_act_com_$rp), bylabel(Activity: Commerce)  ///
             || (SE_YD_act_serv_$rp), bylabel(Activity: Services)  ///
             || (SE_YD_ln_mrwage_main), bylabel(Total Wage (ln)) ///
             || (SE_YD_ln_hrwage_main), bylabel(Hourly Wage (ln)) ///
             || (SE_YD_ln_whpw_w_$rp), bylabel(Work Hours p.w. (ln)) ///
             || (SE_YD_formal), bylabel(Formal) ///
             || , drop( _Iyear_2016 $district _cons $SR_controls) ///
              xline(0) msymbol(d) ///
              label subtitle(, size(vsmall) fcolor(white) nobox ) ///
             xlabel("") ylabel(1 "Treat" 2 "Inter" 3 "VoI") ///
             mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
             cond(@pval<.05, string(@b,"%9.3f") + "**", ///
             cond(@pval<.1, string(@b,"%9.3f") + "*", ///
             string(@b, "%5.3f")  ) ) ) ) mlabposition(10) mlabsize(tiny) ///
             byopts(graphregion(color(white)) bgcolor(white) ///
              title("Effect Sizes: Self Employment", size(small))) ///
                yscale(noline alt)  xscale(noline alt) legend(nobox ///
                region(lstyle(none)) size(vsmall) cols(4) ring(0) )  ///
            levels(99.9 99 95) ciopts(lwidth(*1) lcolor(*.6)) xla(none) xtitle("") xsc(noline) ///
            keep($SR_treat_var_ref $inter_het_var $het_var)


graph export "$out_analysis\SR_HET_SE_Combined_Graph_REF.pdf", as(pdf) replace


*********************************************
*********************************************
********* MERGE TABLES UNCOND **********************
*********************************************
*********************************************


esttab $SR_outcome_WEMP_YD   /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_LFP.tex",  ///
      prehead("\begin{tabular}{l*{8}{c}} \toprule ") ///
      posthead("& & & & & & & & \\  & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) \\ \midrule \midrule \multicolumn{9}{c}{\textit{\textbf{WAGE EMPLOYMENT}}} \\ \multicolumn{9}{c}{\textit{PANEL A: District and Year Fixed Effects}} \\  \midrule ") ///
      fragment replace label ///
      drop($district _cons $SR_controls _Iyear_2016)   ///
      mtitles("\multirow{2}{*}{Agriculture}" "\multirow{2}{*}{Manufacturing}" "\multirow{2}{*}{Commerce}" "\multirow{2}{*}{Services}" "\multirow{2}{*}{\shortstack[c]{Total Wage\\ (ln)}}" "\multirow{2}{*}{\shortstack[c]{Hourly Wage\\ (ln)}}" "\multirow{2}{*}{\shortstack[c]{Work Hours\\ p.w. (ln)}}" "\multirow{2}{*}{Formal}") ///
      varlabel(inter_lfp_empl_7d "Nbr Ref x Wage Empl" lfp_empl_7d "Wage Empl") ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]")) ///
      b(%8.3f) se(%8.3f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $SR_outcome_WEMP_YI  /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_LFP.tex",  ///
      posthead("\midrule  \multicolumn{9}{c}{\textit{PANEL B: Individual and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop(  _cons $SR_controls)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      varlabel(inter_lfp_empl_7d "Nbr Ref x Wage Empl" lfp_empl_7d "Wage Empl") ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $SR_outcome_TEMP_YD    /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_LFP.tex",  ///
      posthead("\midrule \midrule \multicolumn{9}{c}{\textit{\textbf{TEMPORARY}}} \\ \multicolumn{9}{c}{\textit{PANEL C: District and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons $district _Iyear_2016)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      varlabel(inter_lfp_temp_7d "Nbr Ref x Temporary" lfp_temp_7d "Temporary") ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $SR_outcome_TEMP_YI    /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_LFP.tex",  ///
      posthead("\midrule \multicolumn{9}{c}{\textit{PANEL D: Individual and Year Fixed Effects}} \\  \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons )   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      varlabel(inter_lfp_temp_7d "Nbr Ref x Temporary" lfp_temp_7d "Temporary") ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\hline") //

esttab $SR_outcome_SE_YD    /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_LFP.tex",  ///
      posthead("\midrule \midrule \multicolumn{9}{c}{\textit{\textbf{SELF EMPLOYED}}} \\ \multicolumn{9}{c}{\textit{PANEL E: District and Year Fixed Effects}} \\  \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons $district _Iyear_2016)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      varlabel(inter_lfp_se_7d "Nbr Ref x SE" lfp_se_7d "SE") ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\hline") //

esttab $SR_outcome_SE_YI  /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_LFP.tex",  ///
      posthead("\midrule \multicolumn{9}{c}{\textit{PANEL F: Individual and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      varlabel(inter_lfp_se_7d "Nbr Ref x SE" lfp_se_7d "SE") ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") ///
      postfoot("\bottomrule   \end{tabular}  ")







              *************************************************************************
              *************************************************************************
              ************************ ACTIVITY : AG **********************************
              *************************************************************************
              *************************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear


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


xtset, clear 
xtset indid_2010 year 


                              ************************
                              ***        OLS       ***
                              ************************

                        ***********************************
                        **           OLS                 **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************



 ***********
 ** URBAN **
 ***********

*Rural/urban 
tab activity_7d, m 
tab act_ag_7d, m 
lab var act_ag_7d "Agriculture"

gen inter_act_ag_7d = act_ag_7d*$SR_treat_var_ref
*gen inter_formal_IV = urban*$IV_var_ref
lab var inter_act_ag_7d "Nbr Ref x Agri"

global het_var          act_ag_7d
global inter_het_var    inter_act_ag_7d


**** OLS *****
  foreach outcome of global SR_outcome_HET_ACT {
    qui xi: reg `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls  ///
                i.district_iid i.year  ///
            [pw = $SR_weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
    estimates store AG_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $SR_outcome_AG_YD /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016 $district _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))



                        ***********************************
                        **           OLS                 **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global SR_outcome_HET_ACT {
       qui reghdfe `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls ///  
                [pw = $SR_weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls {
        qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $SR_treat_var_ref $inter_het_var $het_var $SR_controls /// 
       [pw = $SR_weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
      estimates store AG_YI_`outcome', title(Model `outcome')

      drop `outcome' $inter_het_var $het_var $SR_controls  $SR_treat_var_ref smpl
      
      foreach y in `outcome' $inter_het_var $het_var $SR_controls $SR_treat_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $SR_outcome_AG_YI /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))




**************************************************************************
**************************************************************************
************* GRAPH HETERO ACTIVITY AGRICULTURE  *************************
**************************************************************************
**************************************************************************

coefplot      (AG_YD_lfp_empl_$rp), bylabel(Wage Employee)  ///
             || (AG_YD_lfp_temp_$rp), bylabel(Temporary)  ///
             || (AG_YD_lfp_employer_$rp), bylabel(Employer)  ///
             || (AG_YD_lfp_se_$rp), bylabel(Self-Employed)  ///
             || (AG_YD_ln_mrwage_main), bylabel(Total Wage (ln)) ///
             || (AG_YD_ln_hrwage_main), bylabel(Hourly Wage (ln)) ///
             || (AG_YD_ln_whpw_w_$rp), bylabel(Work Hours p.w. (ln)) ///
             || (AG_YD_formal), bylabel(Formal) ///
             || , drop( _Iyear_2016 $district _cons $SR_controls) ///
              xline(0) msymbol(d) ///
              label subtitle(, size(vsmall) fcolor(white) nobox ) ///
             xlabel("") ylabel(1 "Treat" 2 "Inter" 3 "VoI") ///
             mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
             cond(@pval<.05, string(@b,"%9.3f") + "**", ///
             cond(@pval<.1, string(@b,"%9.3f") + "*", ///
             string(@b, "%5.3f")  ) ) ) ) mlabposition(10) mlabsize(tiny) ///
             byopts(graphregion(color(white)) bgcolor(white) ///
              title("Effect Sizes: Agriculture", size(small))) ///
                yscale(noline alt)  xscale(noline alt) legend(nobox ///
                region(lstyle(none)) size(vsmall) cols(4) ring(0) )  ///
            levels(99.9 99 95) ciopts(lwidth(*1) lcolor(*.6)) xla(none) xtitle("") xsc(noline) ///
            keep($SR_treat_var_ref $inter_het_var $het_var)


graph export "$out_analysis\SR_HET_AG_Combined_Graph_REF.pdf", as(pdf) replace








              ****************************************************************************
              ****************************************************************************
              ************************ ACTIVITY : MANUF **********************************
              ****************************************************************************
              ****************************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear


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


xtset, clear 
xtset indid_2010 year 


                              ************************
                              ***        OLS       ***
                              ************************

                        ***********************************
                        **           OLS                 **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************



 ***********
 ** URBAN **
 ***********

*Rural/urban 
tab activity_7d, m 
tab act_manuf_7d, m 
lab var act_manuf_7d "Manufacturing"

gen inter_act_manuf_7d = act_manuf_7d*$SR_treat_var_ref
*gen inter_formal_IV = urban*$IV_var_ref
lab var inter_act_manuf_7d "Nbr Ref x Manuf"

global het_var          act_manuf_7d
global inter_het_var    inter_act_manuf_7d


**** OLS *****
  foreach outcome of global SR_outcome_HET_ACT {
    qui xi: reg `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls  ///
                i.district_iid i.year  ///
            [pw = $SR_weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
    estimates store MANUF_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $SR_outcome_MANUF_YD /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016 $district _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))



                        ***********************************
                        **           OLS                 **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global SR_outcome_HET_ACT {
       qui reghdfe `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls ///  
                [pw = $SR_weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls {
        qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $SR_treat_var_ref $inter_het_var $het_var $SR_controls /// 
       [pw = $SR_weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
      estimates store MANUF_YI_`outcome', title(Model `outcome')

      drop `outcome' $inter_het_var $het_var $SR_controls  $SR_treat_var_ref smpl
      
      foreach y in `outcome' $inter_het_var $het_var $SR_controls $SR_treat_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $SR_outcome_MANUF_YI /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))




********************************************************************
********************************************************************
************* GRAPH HETERO MANUFACTURING ***************************
********************************************************************
********************************************************************

coefplot      (MANUF_YD_lfp_empl_$rp), bylabel(Wage Employee)  ///
             || (MANUF_YD_lfp_temp_$rp), bylabel(Temporary)  ///
             || (MANUF_YD_lfp_employer_$rp), bylabel(Employer)  ///
             || (MANUF_YD_lfp_se_$rp), bylabel(Self-Employed)  ///
             || (MANUF_YD_ln_mrwage_main), bylabel(Total Wage (ln)) ///
             || (MANUF_YD_ln_hrwage_main), bylabel(Hourly Wage (ln)) ///
             || (MANUF_YD_ln_whpw_w_$rp), bylabel(Work Hours p.w. (ln)) ///
             || (MANUF_YD_formal), bylabel(Formal) ///
             || , drop( _Iyear_2016 $district _cons $SR_controls) ///
              xline(0) msymbol(d) ///
              label subtitle(, size(vsmall) fcolor(white) nobox ) ///
             xlabel("") ylabel(1 "Treat" 2 "Inter" 3 "VoI") ///
             mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
             cond(@pval<.05, string(@b,"%9.3f") + "**", ///
             cond(@pval<.1, string(@b,"%9.3f") + "*", ///
             string(@b, "%5.3f")  ) ) ) ) mlabposition(10) mlabsize(tiny) ///
             byopts(graphregion(color(white)) bgcolor(white) ///
              title("Effect Sizes: Manufacturing", size(small))) ///
                yscale(noline alt)  xscale(noline alt) legend(nobox ///
                region(lstyle(none)) size(vsmall) cols(4) ring(0) )  ///
            levels(99.9 99 95) ciopts(lwidth(*1) lcolor(*.6)) xla(none) xtitle("") xsc(noline) ///
            keep($SR_treat_var_ref $inter_het_var $het_var)


graph export "$out_analysis\SR_HET_MANUF_Combined_Graph_REF.pdf", as(pdf) replace




              ****************************************************************************
              ****************************************************************************
              ************************ ACTIVITY : COMMERCE *******************************
              ****************************************************************************
              ****************************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear


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


xtset, clear 
xtset indid_2010 year 


                              ************************
                              ***        OLS       ***
                              ************************

                        ***********************************
                        **           OLS                 **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************



 ***********
 ** URBAN **
 ***********

*Rural/urban 
tab activity_7d, m 
tab act_com_7d, m 
lab var act_com_7d "Commerce"

gen inter_act_com_7d = act_com_7d*$SR_treat_var_ref
*gen inter_formal_IV = urban*$IV_var_ref
lab var inter_act_com_7d "Nbr Ref x Commerce"

global het_var          act_com_7d
global inter_het_var    inter_act_com_7d


**** OLS *****
  foreach outcome of global SR_outcome_HET_ACT {
    qui xi: reg `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls  ///
                i.district_iid i.year  ///
            [pw = $SR_weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
    estimates store COM_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $SR_outcome_COM_YD /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016 $district _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))



                        ***********************************
                        **           OLS                 **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global SR_outcome_HET_ACT {
       qui reghdfe `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls ///  
                [pw = $SR_weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls {
        qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $SR_treat_var_ref $inter_het_var $het_var $SR_controls /// 
       [pw = $SR_weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
      estimates store COM_YI_`outcome', title(Model `outcome')

      drop `outcome' $inter_het_var $het_var $SR_controls  $SR_treat_var_ref smpl
      
      foreach y in `outcome' $inter_het_var $het_var $SR_controls $SR_treat_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $SR_outcome_COM_YI /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))




***************************************************************
***************************************************************
************* GRAPH HETERO COMMERCE ***************************
***************************************************************
***************************************************************

coefplot      (COM_YD_lfp_empl_$rp), bylabel(Wage Employee)  ///
             || (COM_YD_lfp_temp_$rp), bylabel(Temporary)  ///
             || (COM_YD_lfp_employer_$rp), bylabel(Employer)  ///
             || (COM_YD_lfp_se_$rp), bylabel(Self-Employed)  ///
             || (COM_YD_ln_mrwage_main), bylabel(Total Wage (ln)) ///
             || (COM_YD_ln_hrwage_main), bylabel(Hourly Wage (ln)) ///
             || (COM_YD_ln_whpw_w_$rp), bylabel(Work Hours p.w. (ln)) ///
             || (COM_YD_formal), bylabel(Formal) ///
             || , drop( _Iyear_2016 $district _cons $SR_controls) ///
              xline(0) msymbol(d) ///
              label subtitle(, size(vsmall) fcolor(white) nobox ) ///
             xlabel("") ylabel(1 "Treat" 2 "Inter" 3 "VoI") ///
             mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
             cond(@pval<.05, string(@b,"%9.3f") + "**", ///
             cond(@pval<.1, string(@b,"%9.3f") + "*", ///
             string(@b, "%5.3f")  ) ) ) ) mlabposition(10) mlabsize(tiny) ///
             byopts(graphregion(color(white)) bgcolor(white) ///
              title("Effect Sizes: Commerce", size(small))) ///
                yscale(noline alt)  xscale(noline alt) legend(nobox ///
                region(lstyle(none)) size(vsmall) cols(4) ring(0) )  ///
            levels(99.9 99 95) ciopts(lwidth(*1) lcolor(*.6)) xla(none) xtitle("") xsc(noline) ///
            keep($SR_treat_var_ref $inter_het_var $het_var)


graph export "$out_analysis\SR_HET_COM_Combined_Graph_REF.pdf", as(pdf) replace









              ****************************************************************************
              ****************************************************************************
              ************************ ACTIVITY : SERVICES *******************************
              ****************************************************************************
              ****************************************************************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear


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


xtset, clear 
xtset indid_2010 year 


                              ************************
                              ***        OLS       ***
                              ************************

                        ***********************************
                        **           OLS                 **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************



 ***********
 ** URBAN **
 ***********

*Rural/urban 
tab activity_7d, m 
tab act_serv_7d, m 
lab var act_serv_7d "Services"

gen inter_act_serv_7d = act_serv_7d*$SR_treat_var_ref
*gen inter_formal_IV = urban*$IV_var_ref
lab var inter_act_serv_7d "Nbr Ref x Services"

global het_var          act_serv_7d
global inter_het_var    inter_act_serv_7d


**** OLS *****
  foreach outcome of global SR_outcome_HET_ACT {
    qui xi: reg `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls  ///
                i.district_iid i.year  ///
            [pw = $SR_weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
    estimates store SERV_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $SR_outcome_SERV_YD /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016 $district _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))



                        ***********************************
                        **           OLS                 **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global SR_outcome_HET_ACT {
       qui reghdfe `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls ///  
                [pw = $SR_weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $SR_treat_var_ref $inter_het_var $het_var ///
                $SR_controls {
        qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $SR_treat_var_ref $inter_het_var $het_var $SR_controls /// 
       [pw = $SR_weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($SR_treat_var_ref $inter_het_var $het_var) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref $inter_het_var $het_var) 
      estimates store SERV_YI_`outcome', title(Model `outcome')

      drop `outcome' $inter_het_var $het_var $SR_controls  $SR_treat_var_ref smpl
      
      foreach y in `outcome' $inter_het_var $het_var $SR_controls $SR_treat_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $SR_outcome_SERV_YI /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))




***************************************************************
***************************************************************
************* GRAPH HETERO SERVICES ***************************
***************************************************************
***************************************************************

coefplot      (SERV_YD_lfp_empl_$rp), bylabel(Wage Employee)  ///
             || (SERV_YD_lfp_temp_$rp), bylabel(Temporary)  ///
             || (SERV_YD_lfp_employer_$rp), bylabel(Employer)  ///
             || (SERV_YD_lfp_se_$rp), bylabel(Self-Employed)  ///
             || (SERV_YD_ln_mrwage_main), bylabel(Total Wage (ln)) ///
             || (SERV_YD_ln_hrwage_main), bylabel(Hourly Wage (ln)) ///
             || (SERV_YD_ln_whpw_w_$rp), bylabel(Work Hours p.w. (ln)) ///
             || (SERV_YD_formal), bylabel(Formal) ///
             || , drop( _Iyear_2016 $district _cons $SR_controls) ///
              xline(0) msymbol(d) ///
              label subtitle(, size(vsmall) fcolor(white) nobox ) ///
             xlabel("") ylabel(1 "Treat" 2 "Inter" 3 "VoI") ///
             mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
             cond(@pval<.05, string(@b,"%9.3f") + "**", ///
             cond(@pval<.1, string(@b,"%9.3f") + "*", ///
             string(@b, "%5.3f")  ) ) ) ) mlabposition(10) mlabsize(tiny) ///
             byopts(graphregion(color(white)) bgcolor(white) ///
              title("Effect Sizes: Services", size(small))) ///
                yscale(noline alt)  xscale(noline alt) legend(nobox ///
                region(lstyle(none)) size(vsmall) cols(4) ring(0) )  ///
            levels(99.9 99 95) ciopts(lwidth(*1) lcolor(*.6)) xla(none) xtitle("") xsc(noline) ///
            keep($SR_treat_var_ref $inter_het_var $het_var)


graph export "$out_analysis\SR_HET_SERV_Combined_Graph_REF.pdf", as(pdf) replace




global het_var          act_ag_7d
global inter_het_var    inter_act_ag_7d global het_var          act_manuf_7d
global inter_het_var    inter_act_manuf_7d lobal het_var          act_com_7d
global inter_het_var    inter_act_com_7d global het_var          act_serv_7d
global inter_het_var    inter_act_serv_7d



*********************************************
*********************************************
********* MERGE TABLES UNCOND **********************
*********************************************
*********************************************


esttab $SR_outcome_AG_YD   /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_ACT_p1.tex",  ///
      prehead("\begin{tabular}{l*{8}{c}} \toprule ") ///
      posthead("& & & & & & & & \\  & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) \\ \midrule \midrule \multicolumn{9}{c}{\textit{\textbf{AGRICULTURE}}} \\ \multicolumn{9}{c}{\textit{PANEL A: District and Year Fixed Effects}} \\  \midrule ") ///
      fragment replace label ///
    drop($district _cons $SR_controls _Iyear_2016)   ///
      mtitles("\multirow{2}{*}{Wage Employee}" "\multirow{2}{*}{Temporary}" "\multirow{2}{*}{Employer}" "\multirow{2}{*}{Self-Empl.}" "\multirow{2}{*}{\shortstack[c]{Total Wage\\ (ln)}}" "\multirow{2}{*}{\shortstack[c]{Hourly Wage\\ (ln)}}" "\multirow{2}{*}{\shortstack[c]{Work Hours\\ p.w. (ln)}}" "\multirow{2}{*}{Formal}") ///
      varlabel(inter_act_ag_7d "Nbr Ref x Agri" act_ag_7d "Agriculture") ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]")) ///
      b(%8.3f) se(%8.3f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\hline") //

esttab $SR_outcome_AG_YI  /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_ACT_p1.tex",  ///
      posthead("\midrule  \multicolumn{9}{c}{\textit{PANEL B: Individual and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop(  _cons $SR_controls)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      varlabel(inter_act_ag_7d "Nbr Ref x Agri" act_ag_7d "Agriculture") ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\hline") //

esttab $SR_outcome_MANUF_YD    /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_ACT_p1.tex",  ///
      posthead("\midrule \midrule \multicolumn{9}{c}{\textit{\textbf{MANUFACTURING}}} \\ \multicolumn{9}{c}{\textit{PANEL C: District and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons $district _Iyear_2016)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      varlabel(inter_act_manuf_7d "Nbr Ref x Manuf" act_manuf_7d "Manufacturing") ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\hline") //

esttab $SR_outcome_MANUF_YI    /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_ACT_p1.tex",  ///
      posthead("\midrule \multicolumn{9}{c}{\textit{PANEL D: Individual and Year Fixed Effects}} \\  \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons )   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      varlabel(inter_act_manuf_7d "Nbr Ref x Manuf" act_manuf_7d "Manufacturing") ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $SR_outcome_COM_YD    /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_ACT_p1.tex",  ///
      posthead("\midrule \midrule \multicolumn{9}{c}{\textit{\textbf{COMMERCE}}} \\ \multicolumn{9}{c}{\textit{PANEL E: District and Year Fixed Effects}} \\  \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons $district _Iyear_2016)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      varlabel(inter_act_com_7d "Nbr Ref x Commerce" act_com_7d "Commerce") ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\hline") //

esttab $SR_outcome_COM_YI  /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_ACT_p1.tex",  ///
      posthead("\midrule \multicolumn{9}{c}{\textit{PANEL F: Individual and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      varlabel(inter_act_com_7d "Nbr Ref x Commerce" act_com_7d "Commerce") ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") ///
      postfoot("\bottomrule  \end{tabular}  ")











esttab $SR_outcome_SERV_YD   /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_ACT_p2.tex",  ///
      prehead("\begin{tabular}{l*{8}{c}} \toprule ") ///
      posthead("& & & & & & & & \\  & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) \\ \midrule \midrule \multicolumn{9}{c}{\textit{\textbf{SERVICES}}} \\ \multicolumn{9}{c}{\textit{PANEL A: District and Year Fixed Effects}} \\  \midrule ") ///
      fragment replace label ///
    drop($district _cons $SR_controls _Iyear_2016)   ///
      mtitles("\multirow{2}{*}{Wage Employee}" "\multirow{2}{*}{Temporary}" "\multirow{2}{*}{Employer}" "\multirow{2}{*}{Self-Empl.}" "\multirow{2}{*}{\shortstack[c]{Total Wage\\ (ln)}}" "\multirow{2}{*}{\shortstack[c]{Hourly Wage\\ (ln)}}" "\multirow{2}{*}{\shortstack[c]{Work Hours\\ p.w. (ln)}}" "\multirow{2}{*}{Formal}") ///
      varlabel(inter_act_serv_7d "Nbr Ref x Services" act_serv_7d "Services") ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]")) ///
      b(%8.3f) se(%8.3f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $SR_outcome_SERV_YI  /// 
      using "$out_analysis/SR_REF_HET_reg_MERGE_ACT_p2.tex",  ///
      posthead("\midrule \multicolumn{9}{c}{\textit{PANEL B: Individual and Year Fixed Effects}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      varlabel(inter_act_serv_7d "Nbr Ref x Services" act_serv_7d "Services") ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") ///
      postfoot("\bottomrule \end{tabular}  ")



