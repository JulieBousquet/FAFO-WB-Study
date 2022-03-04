

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

                  

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

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


  foreach outcome of global SR_outcome {
    qui xi: reg `outcome' $SR_treat_var_wp ///
             i.district_iid i.year $SR_controls ///
            [pw = $SR_weight],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($SR_treat_var_wp) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_wp) 
    estimates store WPOLS_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $WPOLS_YD_p1 $WPOLS_YD_p2 /// 
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
       qui reghdfe `outcome' $SR_treat_var_wp $SR_controls  ///
                [pw = $SR_weight], ///
                absorb(year indid_2010) ///
                cluster(district_iid) 
      
        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
      foreach y in `outcome' $SR_treat_var_wp  $SR_controls {
        qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
        rename `y' o_`y'
        rename `y'_c2wr `y'
      }
      
      qui reg `outcome' $SR_treat_var_wp $SR_controls [pw = $SR_weight], cluster(district_iid) robust
      codebook `outcome', c
      estimates table,  k($SR_treat_var_wp) star(.1 .05 .01) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_wp) 
      estimates store WPOLS_YI_`outcome', title(Model `outcome')

      drop `outcome' $SR_controls $SR_treat_var_wp smpl
      
      foreach y in `outcome' $SR_controls $SR_treat_var_wp  {
        rename o_`y' `y' 
      } 
    }
restore


ereturn list
mat list e(b)
estout $WPOLS_YI_p1 $WPOLS_YI_p2  /// 
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
                ($SR_treat_var_wp = $SR_IV_wp) ///
                [pw = $SR_weight], ///
                cluster(district_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($SR_treat_var_wp) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a rkf) k($SR_treat_var_wp) 
    estimates store WPIV_YD_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout $WPIV_YD_p1 $WPIV_YD_p2 ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop( _Iyear_2016 $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(N r2 rkf, fmt(0 2 0) label(N R-sqr KP-Stat))





                        ***********************************
                        **           IV                  **
************************** INDIVIDUAL + YEAR FIXED EFFECTS ***************************************
                        ***********************************

preserve
  foreach outcome of global SR_outcome {     
      codebook `outcome', c
       qui xi: ivreghdfe `outcome' ///
                    $SR_controls  ///
                    ($SR_treat_var_wp = $SR_IV_wp) ///
                    [pw = $SR_weight], ///
                    absorb(year indid_2010) ///
                    cluster(district_iid) 

        qui gen smpl=0
        qui replace smpl=1 if e(sample)==1
        * Then I partial out all variables
        foreach y in `outcome' $SR_controls $SR_treat_var_wp $SR_IV_wp { 
          qui reghdfe `y' [pw = $SR_weight] if smpl==1, absorb(year indid_2010) residuals(`y'_c2wr)
          qui rename `y' o_`y'
          qui rename `y'_c2wr `y'
        }
        qui ivreg2 `outcome' ///
               $SR_controls  ///
               ($SR_treat_var_wp = $SR_IV_wp) ///
               [pw = $SR_weight], ///
               cluster(district_iid) robust ///
               first 
      estimates table, k($SR_treat_var_wp) star(.1 .05 .01) b(%7.4f) 
      estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($SR_treat_var_wp) 
      estimates store WPIV_YI_`outcome', title(Model `outcome')
        qui drop `outcome' $SR_treat_var_wp $SR_IV_wp $SR_controls smpl
        foreach y in `outcome' $SR_treat_var_wp $SR_IV_wp $SR_controls {
          qui rename o_`y' `y' 
        }
    }
restore                

ereturn list
mat list e(b)
estout $WPIV_YI_p1 $WPIV_YI_p2 /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
        drop( _cons $SR_controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
   stats(N r2 rkf, fmt(0 2 0) label(N R-sqr KP-Stat))



*********************************************
*********************************************
********* MERGE TABLES **********************
*********************************************
*********************************************


esttab $WPOLS_YD_p1   /// 
      using "$out_analysis/SR_WP_reg_MERGE_p1.tex",  ///
      prehead("\begin{tabular}{l*{6}{c}} \toprule ") ///
      posthead("& & & & & & \\ & b (se) & b (se) & b (se) & b (se) & b (se) & b (se)  \\ \midrule \midrule \multicolumn{7}{c}{\textit{\textbf{District and Year Fixed Effects}}} \\ \multicolumn{7}{c}{\textit{PANEL A: OLS}} \\ \midrule ") ///
      fragment replace label ///
    drop($SR_controls $district _cons _Iyear_2016)   ///
      mtitles("\multirow{2}{*}{Employed}" "\multirow{2}{*}{Unemployed}" "\multirow{2}{*}{\shortstack[c]{Total Wage\\ (ln)}}" "\multirow{2}{*}{\shortstack[c]{Hourly Wage\\ (ln)}}" "\multirow{2}{*}{\shortstack[c]{Work Hours\\ p.w.}}" "\multirow{2}{*}{Formal}") ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]")) ///
      b(%8.3f) se(%8.3f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $WPIV_YD_p1  /// 
      using "$out_analysis/SR_WP_reg_MERGE_p1.tex",  ///
      posthead("\midrule  \multicolumn{7}{c}{\textit{PANEL B: IV}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _Iyear_2016)   ///
      stats(N r2_a rkf, fmt(0 2 0) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $" "KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $WPOLS_YI_p1    /// 
      using "$out_analysis/SR_WP_reg_MERGE_p1.tex",  ///
      posthead("\midrule \midrule \multicolumn{7}{c}{\textit{\textbf{Individual and Year Fixed Effects}}} \\ \multicolumn{7}{c}{\textit{PANEL C: OLS}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $WPIV_YI_p1  /// 
      using "$out_analysis/SR_WP_reg_MERGE_p1.tex",  ///
      posthead("\midrule  \multicolumn{7}{c}{\textit{PANEL D: IV}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a rkf, fmt(0 2 0) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $" "KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") ///
      postfoot("\bottomrule  \\\\[-0.6cm]  \end{tabular}  ")




esttab $WPOLS_YD_p2   /// 
      using "$out_analysis/SR_WP_reg_MERGE_p2.tex",  ///
      prehead("\begin{tabular}{l*{8}{c}} \toprule ") ///
      posthead("& & & & & & & & \\ & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se) & b (se)  \\ \midrule \midrule \multicolumn{9}{c}{\textit{\textbf{District and Year Fixed Effects}}} \\ \multicolumn{9}{c}{\textit{PANEL A: OLS}} \\ \midrule ") ///
      fragment replace label ///
    drop($SR_controls $district _cons _Iyear_2016)   ///
      mtitles("\multirow{2}{*}{Employee}" "\multirow{2}{*}{Temporary}" "\multirow{2}{*}{Employer}" "\multirow{2}{*}{SE}" "\multirow{2}{*}{Agriculture}" "\multirow{2}{*}{Manufacturing}" "\multirow{2}{*}{Commerce}" "\multirow{2}{*}{Services}") ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]")) ///
      b(%8.3f) se(%8.3f) starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $WPIV_YD_p2  /// 
      using "$out_analysis/SR_WP_reg_MERGE_p2.tex",  ///
      posthead("\midrule  \multicolumn{9}{c}{\textit{PANEL B: IV}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _Iyear_2016)   ///
      stats(N r2_a rkf, fmt(0 2 0) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $" "KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $WPOLS_YI_p2    /// 
      using "$out_analysis/SR_WP_reg_MERGE_p2.tex",  ///
      posthead("\midrule \midrule \multicolumn{9}{c}{\textit{\textbf{Individual and Year Fixed Effects}}}\\ \multicolumn{9}{c}{\textit{PANEL C: OLS}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a, fmt(0 2) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $ \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") //

esttab $WPIV_YI_p2  /// 
      using "$out_analysis/SR_WP_reg_MERGE_p2.tex",  ///
      posthead("\midrule  \multicolumn{9}{c}{\textit{PANEL D: IV}} \\ \midrule  ") ///
      fragment append label ///
      drop($SR_controls _cons)   ///
      stats(N r2_a rkf, fmt(0 2 0) labels("\\\\[-0.5cm] N" "Adj. $ R^{2} $" "KP-Stat \\\\[-0.6cm]"))  ///
      r2 b(%8.3f) se(%8.3f) ///
      nomtitles nonumbers starlevels(* 0.1 ** 0.05 *** 0.01) ///
      prefoot("\\\\[-0.5cm] \hline") ///
      postfoot("\bottomrule  \\\\[-0.6cm]  \end{tabular}  ")





*******************************************
*******************************************
******** GRAPH ****************************
*******************************************
*******************************************



    coefplot (WPOLS_YD_employed_olf_$rp, label(Employed))  ///
             (WPOLS_YD_unemployed_olf_$rp, label(Unemployed))  ///
             (WPOLS_YD_lfp_empl_$rp, label(Type: Wage Worker))  ///
             (WPOLS_YD_lfp_temp_$rp, label(Type: Temporary))  ///
             (WPOLS_YD_lfp_employer_$rp, label(Type: Employer))  ///
             (WPOLS_YD_lfp_se_$rp, label(Type: SE))  ///
             (WPOLS_YD_act_ag_$rp, label(Activity: Agricultural))  ///
             (WPOLS_YD_act_manuf_$rp, label(Activity: Manufacturing))  ///
             (WPOLS_YD_act_com_$rp, label(Activity: Commerce))  ///
             (WPOLS_YD_act_serv_$rp, label(Activity: Services))  ///
             (WPOLS_YD_ln_trwage_$rp, label(Total Wage (ln))) ///
             (WPOLS_YD_ln_hrwage_main, label(Hourly Wage (ln))) ///
             (WPOLS_YD_ln_whpw_w_$rp, label(Work Hours p.w.)) ///
             (WPOLS_YD_formal, label(Formal)) , bylabel("OLS District Year") ///
             || (WPIV_YD_employed_olf_$rp, label(Employed)) ///
             (WPIV_YD_unemployed_olf_$rp, label(Unemployed))  ///
             (WPIV_YD_lfp_empl_$rp, label(Type: Wage Worker))  ///
             (WPIV_YD_lfp_temp_$rp, label(Type: Temporary))  ///
             (WPIV_YD_lfp_employer_$rp, label(Type: Employer))  ///
             (WPIV_YD_lfp_se_$rp, label(Type: SE))  ///
             (WPIV_YD_act_ag_$rp, label(Activity: Agricultural))  ///
             (WPIV_YD_act_manuf_$rp, label(Activity: Manufacturing))  ///
             (WPIV_YD_act_com_$rp, label(Activity: Commerce))  ///
             (WPIV_YD_act_serv_$rp, label(Activity: Services))  ///
             (WPIV_YD_ln_trwage_$rp, label(Total Wage (ln))) ///
             (WPIV_YD_ln_hrwage_main, label(Hourly Wage (ln))) ///
             (WPIV_YD_ln_whpw_w_$rp, label(Work Hours p.w.)) ///
             (WPIV_YD_formal, label(Formal)) , bylabel("IV District Year") ///
             || (WPOLS_YI_employed_olf_$rp, label(Employed))  ///
             (WPOLS_YI_unemployed_olf_$rp, label(Unemployed))  ///
             (WPOLS_YI_lfp_empl_$rp, label(Type: Wage Worker))  ///
             (WPOLS_YI_lfp_temp_$rp, label(Type: Temporary))  ///
             (WPOLS_YI_lfp_employer_$rp, label(Type: Employer))  ///
             (WPOLS_YI_lfp_se_$rp, label(Type: SE))  ///
             (WPOLS_YI_act_ag_$rp, label(Activity: Agricultural))  ///
             (WPOLS_YI_act_manuf_$rp, label(Activity: Manufacturing))  ///
             (WPOLS_YI_act_com_$rp, label(Activity: Commerce))  ///
             (WPOLS_YI_act_serv_$rp, label(Activity: Services))  ///
             (WPOLS_YI_ln_trwage_$rp, label(Total Wage (ln))) ///
             (WPOLS_YI_ln_hrwage_main, label(Hourly Wage (ln))) ///
             (WPOLS_YI_ln_whpw_w_$rp, label(Work Hours p.w.)) ///
             (WPOLS_YI_formal, label(Formal)) , bylabel("OLS Indiv Year") ///
             || (WPIV_YI_employed_olf_$rp, label(Employed)) ///
             (WPIV_YI_unemployed_olf_$rp, label(Unemployed))  ///
             (WPIV_YI_lfp_empl_$rp, label(Type: Wage Worker))  ///
             (WPIV_YI_lfp_temp_$rp, label(Type: Temporary))  ///
             (WPIV_YI_lfp_employer_$rp, label(Type: Employer))  ///
             (WPIV_YI_lfp_se_$rp, label(Type: SE))  ///
             (WPIV_YI_act_ag_$rp, label(Activity: Agricultural))  ///
             (WPIV_YI_act_manuf_$rp, label(Activity: Manufacturing))  ///
             (WPIV_YI_act_com_$rp, label(Activity: Commerce))  ///
             (WPIV_YI_act_serv_$rp, label(Activity: Services))  ///
             (WPIV_YI_ln_trwage_$rp, label(Total Wage (ln))) ///
             (WPIV_YI_ln_hrwage_main, label(Hourly Wage (ln))) ///
             (WPIV_YI_ln_whpw_w_$rp, label(Work Hours p.w.)) ///
             (WPIV_YI_formal, label(Formal)) , bylabel("IV Indiv Year") ///
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
                yscale(noline alt)  xscale(noline alt) legend( nobox ///
                region(lstyle(none)) size(vsmall) cols(4) ring(0) )  ///
            levels(99.9 99 95) ciopts(lwidth(*1) lcolor(*.6)) xla(none) xtitle("") xsc(noline)


graph export "$out_analysis\SR_Combined_Graph_WP.pdf", as(pdf) replace

























































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

  foreach outcome of global SR_outcome_cond {
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
 foreach outcome of global SR_outcome_cond {
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




