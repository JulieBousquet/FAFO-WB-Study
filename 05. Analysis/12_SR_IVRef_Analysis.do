




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


use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

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

                        ***********************************
                        **           OLS                 **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************

  foreach outcome of global SR_outcome {
    qui xi: reg `outcome' $SR_treat_var_ref ///
             i.district_iid i.year $SR_controls ///
            [pw = $SR_weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($SR_treat_var_ref) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref) 
    estimates store REFOLS_YD_`outcome', title(Model `outcome')
  }


ereturn list
mat list e(b)
estout $REFOLS_YD_p1 $REFOLS_YD_p2 /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _Iyear_2016  $district _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based




                        ***********************************
                        **           OLS                 **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

*"Partialling Out" Previous equation implies that regressing y on x1 and x2 gives same effect of x1 
*as regressing y on residuals from a regression of x1 on x2.

preserve
  foreach outcome of global SR_outcome {
       qui reghdfe `outcome' $SR_treat_var_ref $SR_controls  ///
                [pw = $SR_weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $SR_treat_var_ref  $SR_controls {
        qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $SR_treat_var_ref $SR_controls [pw = $SR_weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($SR_treat_var_ref) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_ref) 
      estimates store REFOLS_YI_`outcome', title(Model `outcome')

      drop `outcome' $SR_controls $SR_treat_var_ref smpl
      
      foreach y in `outcome' $SR_controls $SR_treat_var_ref  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $REFOLS_YI_p1 $REFOLS_YI_p2  /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2, fmt(0 2) label(N R-sqr))



                            ***********************
                            ***        IV       ***
                            ***********************


                        ***********************************
                        **           IV                  **
************************** DISTRICT + YEAR FIXED EFFECTS ***************************************
                        ***********************************


 foreach outcome of global SR_outcome {
     qui xi: ivreg2  `outcome' i.year i.district_iid $SR_controls ///
                ($SR_treat_var_ref = $SR_IV_ref) ///
                [pw = $SR_weight], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($SR_treat_var_ref) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($SR_treat_var_ref) 
    estimates store REFIV_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $REFIV_YD_p1 $REFIV_YD_p2 ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop( _Iyear_2016 $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(N r2 rkf, fmt(0 2 0) label(N R-sqr KP-Stat))


   /* AUTOCORELL
    xi: ivreg2  employed_olf_7d i.year i.district_iid $SR_controls ///
                ($SR_treat_var_ref = $SR_IV_ref) ///
                [pw = $SR_weight], ///
                cluster(district_iid) robust ///
                partial(i.district_iid)
 
global SR_treat_var_ref  ln_hh_syrians_bydis 
*ln_prop_hh_syrians
global SR_IV_ref         IV_Ref_NETW

    qui xi: reg   $SR_treat_var_ref   $SR_IV_ref  i.district_iid i.year ///
            [pw = $SR_weight],  robust cluster(district_iid)                
    vif  



    codebook `outcome', c
    estimates table, k($SR_treat_var_ref) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($SR_treat_var_ref) 
    estimates store REFIV_YD_`outcome', title(Model `outcome')
*/
                        ***********************************
                        **           IV                  **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

preserve
  foreach outcome of global SR_outcome {     
      codebook `outcome', c
       qui xi: ivreghdfe `outcome' ///
                    $SR_controls  ///
                    ($SR_treat_var_ref = $SR_IV_ref) ///
                    [pw = $SR_weight], ///
                    absorb(year indid_2010) ///
                    cluster(district_iid) 

        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
        foreach y in `outcome' $SR_controls $SR_treat_var_ref $SR_IV_ref { 
          qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
          qui rename `y' o_`y'
          qui rename `y'_c2wr `y'
        }
        qui ivreg2 `outcome' ///
               $SR_controls  ///
               ($SR_treat_var_ref = $SR_IV_ref) ///
               [pw = $SR_weight], ///
               cluster(district_iid) robust ///
               first 
      estimates table, k($SR_treat_var_ref) star(.1 .05 .01) b(%7.4f) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($SR_treat_var_ref) 
      estimates store REFIV_YI_`outcome', title(Model `outcome')
        qui drop `outcome' $SR_treat_var_ref $SR_IV_ref $SR_controls smpl
        foreach y in `outcome' $SR_treat_var_ref $SR_IV_ref $SR_controls {
          qui rename o_`y' `y' 
        }
    }
restore                

ereturn list
mat list e(b)
estout $REFIV_YI_p1 $REFIV_YI_p2   /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2 rkf, fmt(0 2 0) label(N R-sqr KP-Stat))



*********************************************
*********************************************
********* MERGE TABLES **********************
*********************************************
*********************************************


esttab $REFOLS_YD_p1   /// 
      using "$out_analysis/SR_REF_reg_MERGE_p1.tex",  ///
      prehead("\begin{tabular}{l*{6}{c}} \toprule ") ///
      posthead("& & & & & & \\ & b (se) & b (se) & b (se) & b (se) & b (se) & b (se)  \\ \midrule \midrule \multicolumn{7}{c}{\textit{\textbf{District and Year Fixed Effects}}} \\ \multicolumn{7}{c}{\textit{PANEL A: OLS}} \\ \midrule ") ///
      fragment replace label ///
    drop($SR_controls $district _cons _Iyear_2016)   ///
      mtitles("\multirow{2}{*}{Employed}" "\multirow{2}{*}{Unemployed}" "\multirow{2}{*}{\shortstack[c]{Monthly Wage\\ (ln)}}" "\multirow{2}{*}{\shortstack[c]{Hourly Wage\\ (ln)}}" "\multirow{2}{*}{\shortstack[c]{Work Hours\\ p.w. (ln)}}" "\multirow{2}{*}{Formal}") ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]")) ///
      b(%8.3f) se(%8.3f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFIV_YD_p1  /// 
      using "$out_analysis/SR_REF_reg_MERGE_p1.tex",  ///
      posthead("\midrule  \multicolumn{7}{c}{\textit{PANEL B: IV}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _Iyear_2016)   ///
      stats(N r2_a rkf, fmt(0 2 0) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $" "KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFOLS_YI_p1    /// 
      using "$out_analysis/SR_REF_reg_MERGE_p1.tex",  ///
      posthead("\midrule \midrule \multicolumn{7}{c}{\textit{\textbf{Individual and Year Fixed Effects}}} \\ \multicolumn{7}{c}{\textit{PANEL C: OLS}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFIV_YI_p1  /// 
      using "$out_analysis/SR_REF_reg_MERGE_p1.tex",  ///
      posthead("\midrule  \multicolumn{7}{c}{\textit{PANEL D: IV}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a rkf, fmt(0 2 0) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $" "KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") ///
      postfoot("\bottomrule  \end{tabular}  ")




esttab $REFOLS_YD_p2   /// 
      using "$out_analysis/SR_REF_reg_MERGE_p2.tex",  ///
      prehead("\begin{tabular}{l*{8}{c}} \toprule ") ///
      posthead("& & & & & & & & \\ & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se)  \\ \midrule \midrule \multicolumn{9}{c}{\textit{\textbf{District and Year Fixed Effects}}} \\ \multicolumn{9}{c}{\textit{PANEL A: OLS}} \\ \midrule ") ///
      fragment replace label ///
    drop($SR_controls $district _cons _Iyear_2016)   ///
      mtitles("\multirow{2}{*}{Employee}" "\multirow{2}{*}{Temporary}" "\multirow{2}{*}{Employer}" "\multirow{2}{*}{SE}" "\multirow{2}{*}{Agriculture}" "\multirow{2}{*}{Manufacturing}" "\multirow{2}{*}{Commerce}" "\multirow{2}{*}{Services}") ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      b(%8.3f) se(%8.3f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFIV_YD_p2  /// 
      using "$out_analysis/SR_REF_reg_MERGE_p2.tex",  ///
      posthead("\midrule  \multicolumn{9}{c}{\textit{PANEL B: IV}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _Iyear_2016)   ///
      stats(N r2_a rkf, fmt(0 2 0) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $" "KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFOLS_YI_p2    /// 
      using "$out_analysis/SR_REF_reg_MERGE_p2.tex",  ///
      posthead("\midrule \midrule \multicolumn{9}{c}{\textbf{\textit{Individual and Year Fixed Effects}}} \\ \multicolumn{9}{c}{\textbf{\textit{PANEL C: OLS}}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") //

esttab $REFIV_YI_p2  /// 
      using "$out_analysis/SR_REF_reg_MERGE_p2.tex",  ///
      posthead("\midrule  \multicolumn{9}{c}{\textit{PANEL D: IV}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a rkf, fmt(0 2 0) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $" "KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot(" \hline") ///
      postfoot("\bottomrule   \end{tabular}  ")



*******************************************
*******************************************
******** GRAPH ****************************
*******************************************
*******************************************

    coefplot (REFOLS_YD_employed_olf_$rp, label(Employed))  ///
             (REFOLS_YD_unemployed_$rp, label(Unemployed))  ///
             (REFOLS_YD_lfp_empl_$rp, label(Type: Wage Worker))  ///
             (REFOLS_YD_lfp_temp_$rp, label(Type: Temporary))  ///
             (REFOLS_YD_lfp_employer_$rp, label(Type: Employer))  ///
             (REFOLS_YD_lfp_se_$rp, label(Type: SE))  ///
             (REFOLS_YD_act_ag_$rp, label(Activity: Agricultural))  ///
             (REFOLS_YD_act_manuf_$rp, label(Activity: Manufacturing))  ///
             (REFOLS_YD_act_com_$rp, label(Activity: Commerce))  ///
             (REFOLS_YD_act_serv_$rp, label(Activity: Services))  ///
             (REFOLS_YD_ln_mrwage_main, label(Monthly Wage (ln))) ///
             (REFOLS_YD_ln_hrwage_main, label(Hourly Wage (ln))) ///
             (REFOLS_YD_ln_whpw_w_$rp, label(Work Hours p.w. (ln))) ///
             (REFOLS_YD_formal, label(Formal)) , bylabel("OLS District Year") ///
             || (REFIV_YD_employed_olf_$rp, label(Employed)) ///
             (REFIV_YD_unemployed_$rp, label(Unemployed))  ///
             (REFIV_YD_lfp_empl_$rp, label(Type: Wage Worker))  ///
             (REFIV_YD_lfp_temp_$rp, label(Type: Temporary))  ///
             (REFIV_YD_lfp_employer_$rp, label(Type: Employer))  ///
             (REFIV_YD_lfp_se_$rp, label(Type: SE))  ///
             (REFIV_YD_act_ag_$rp, label(Activity: Agricultural))  ///
             (REFIV_YD_act_manuf_$rp, label(Activity: Manufacturing))  ///
             (REFIV_YD_act_com_$rp, label(Activity: Commerce))  ///
             (REFIV_YD_act_serv_$rp, label(Activity: Services))  ///
             (REFIV_YD_ln_mrwage_main, label(Monthly Wage (ln))) ///
             (REFIV_YD_ln_hrwage_main, label(Hourly Wage (ln))) ///
             (REFIV_YD_ln_whpw_w_$rp, label(Work Hours p.w. (ln))) ///
             (REFIV_YD_formal, label(Formal)) , bylabel("IV District Year") ///
             || (REFOLS_YI_employed_olf_$rp, label(Employed))  ///
             (REFOLS_YI_unemployed_$rp, label(Unemployed))  ///
             (REFOLS_YI_lfp_empl_$rp, label(Type: Wage Worker))  ///
             (REFOLS_YI_lfp_temp_$rp, label(Type: Temporary))  ///
             (REFOLS_YI_lfp_employer_$rp, label(Type: Employer))  ///
             (REFOLS_YI_lfp_se_$rp, label(Type: SE))  ///
             (REFOLS_YI_act_ag_$rp, label(Activity: Agricultural))  ///
             (REFOLS_YI_act_manuf_$rp, label(Activity: Manufacturing))  ///
             (REFOLS_YI_act_com_$rp, label(Activity: Commerce))  ///
             (REFOLS_YI_act_serv_$rp, label(Activity: Services))  ///
             (REFOLS_YI_ln_mrwage_main, label(Monthly Wage (ln))) ///
             (REFOLS_YI_ln_hrwage_main, label(Hourly Wage (ln))) ///
             (REFOLS_YI_ln_whpw_w_$rp, label(Work Hours p.w. (ln))) ///
             (REFOLS_YI_formal, label(Formal)) , bylabel("OLS Indiv Year") ///
             || (REFIV_YI_employed_olf_$rp, label(Employed)) ///
             (REFIV_YI_unemployed_$rp, label(Unemployed))  ///
             (REFIV_YI_lfp_empl_$rp, label(Type: Wage Worker))  ///
             (REFIV_YI_lfp_temp_$rp, label(Type: Temporary))  ///
             (REFIV_YI_lfp_employer_$rp, label(Type: Employer))  ///
             (REFIV_YI_lfp_se_$rp, label(Type: SE))  ///
             (REFIV_YI_act_ag_$rp, label(Activity: Agricultural))  ///
             (REFIV_YI_act_manuf_$rp, label(Activity: Manufacturing))  ///
             (REFIV_YI_act_com_$rp, label(Activity: Commerce))  ///
             (REFIV_YI_act_serv_$rp, label(Activity: Services))  ///
             (REFIV_YI_ln_mrwage_main, label(Monthly Wage (ln))) ///
             (REFIV_YI_ln_hrwage_main, label(Hourly Wage (ln))) ///
             (REFIV_YI_ln_whpw_w_$rp, label(Work Hours p.w. (ln))) ///
             (REFIV_YI_formal, label(Formal)) , bylabel("IV Indiv Year") ///
             || , drop(_Iyear_2016 $district _cons $SR_controls) ///
              xline(0) msymbol(d) ///
              label subtitle(, size(vsmall) fcolor(white) nobox ) ///
             xlabel("") ylabel("") ///
             mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
             cond(@pval<.05, string(@b,"%9.3f") + "**", ///
             cond(@pval<.1, string(@b,"%9.3f") + "*", ///
             string(@b, "%5.3f")  ) ) ) ) mlabposition(10) mlabsize(tiny) ///
             byopts(graphregion(color(white)) bgcolor(white) ///
              title("Effect Sizes", size(small))) ///
                yscale(noline alt)  xscale(noline alt) legend(nobox ///
                region(lstyle(none)) size(vsmall) cols(4) ring(0) )  ///
            levels(99.9 99 95) ciopts(lwidth(*1) lcolor(*.6)) xla(none) xtitle("") xsc(noline)


graph export "$out_analysis\SR_Combined_Graph_REF.pdf", as(pdf) replace




























*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based
/*
*erase "$out/reg_infra_access.tex"
esttab $IV_YI_uncond    /// 
      using "$out_analysis/SR_REF_reg_IV_Uncond_FE_INDIV_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "Employee" "Temp" "Employer" "SE" "Ag" "Manuf" "Commerce" "Services") ///
        drop(age age2 gender  ///
        _cons $SR_controls)   ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - Results IV Regression with time and Individual FE - UNCOND"\label{tab1}) nofloat ///
   stats(N rkf, fmt(0 0) labels("Obs" "KP Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 
*/
*estimates drop $outreg_uncond 







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
