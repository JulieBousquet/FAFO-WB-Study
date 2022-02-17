

cap log close
clear all
set more off, permanently
set mem 100m

*log using "$out_analysis/14_IVWP_Analysis.log", replace

   ****************************************************************************
   **                            DATA IV WP                                  **
   **                          MERGING RESULTS                               **  
   ** ---------------------------------------------------------------------- **
   ** Type Do  :  DATA JLMPS - FALLAH ET AL INSTRU                           **
   **                                                                        **
   ** Authors  : Julie Bousquet                                              **
   ****************************************************************************


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

 



  foreach outcome of global outcomes_uncond {

    xi: reg `outcome' $dep_var_wp ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook employed_olf_3m, c
    estimates table, k($dep_var_wp) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_wp) 
    estimates store m_`outcome'

} 
    coefplot (m_employed_olf_3m, label(Employed)) ///
             (m_unemployed_olf_3m, label(Unemployed))  ///
             (m_lfp_3m_empl, label(Type: Wage Worker))  ///
             (m_lfp_3m_temp, label(Type: Temporary))  ///
             (m_lfp_3m_employer, label(Type: Employer))  ///
             (m_lfp_3m_se, label(Type: SE))  ///
             (m_lfp_3m_unpaid, label(Type: Unpaid)) , bylabel(Jordan) ///
             mlabposition(12) mlabsize(vsmall)  mlabel(string(@b, "%5.2f"))  ///
             || , bylabel(Uganda)  ///
         || ,  drop(age age2 gender _Iyear_2016 ///
        $district ///
        _cons $controls) xline(0)  msymbol(S) 




  foreach outcome of global outcomes_uncond {
       qui xi: reg `outcome' $dep_var_wp i.district_iid i.year $controls ///
               [pweight = panel_wt_10_16],  ///
               cluster(district_iid) robust 
       estimates store Jordan_`outcome'
   }

  foreach outcome of global outcomes_uncond {
       qui xi: reg `outcome' $dep_var_wp i.district_iid i.year $controls  ///
               [pweight = panel_wt_10_16],  ///
               cluster(district_iid) robust 
       estimates store Uganda_`outcome'
   }


coefplot    (Jordan_employed_olf_3m), bylabel(Jordan) ///
         || (Uganda_employed_olf_3m ), bylabel(Uganda) ///
         || (Jordan_unemployed_olf_3m, offset(-0.15)), bylabel(Jordan)  ///
         || (Uganda_unemployed_olf_3m), bylabel(Uganda)  ///
         || (Jordan_lfp_3m_empl), bylabel(Jordan) ///
         || (Uganda_lfp_3m_empl), bylabel(Uganda)   ///
         || (Jordan_lfp_3m_temp), bylabel(Jordan)  ///
         || (Uganda_lfp_3m_temp), bylabel(Uganda)   ///
         || (Jordan_lfp_3m_employer), bylabel(Jordan)  ///
         || (Uganda_lfp_3m_employer), bylabel(Uganda)  ///
         || (Jordan_lfp_3m_se), bylabel(Jordan) ///
         || (Uganda_lfp_3m_se), bylabel(Uganda)   ///
         || (Jordan_lfp_3m_unpaid), bylabel(Jordan)  ///
         || (Uganda_lfp_3m_unpaid), bylabel(Uganda)  ///
         ||   , drop($controls _Iyear_2016 $district _cons) xline(0) ///
     bycoefs  ///
     ytick( 2.5 4.5 6.5 8.5 10.5 12.5,  glpattern(dash) glwidth(*0.5) glcolor(gray)) ///
     grid(glpattern(dash) glwidth(*2) glcolor(gray)) ///
     group(1 2 = "{bf:Employed}" 3 4 = "{bf:Unemployed}" ///
      5 6 = "{bf: Type: Wage Empl}" 7 8 = "{bf:Type: Temp}"   ///
      9 10 = "{bf:Type: Employer}" 11 12 = "{bf:Type: SE}" ///
      13 14= "{bf:Type: Unpaid}", nogap  angle(horizontal))   ///
      graphregion(color(white)) bgcolor(white) legend(off) label ///
      yscale(range(-0.01 0.03)) ymtick(-0.01(0.005)0.03) ///
      mlabposition(2) mlabsize(vsmall)  mlabel(string(@b, "%5.3f"))
  





codebook gender
tab gender
lab var gender "Gender"

gen inter_gender = gender*$dep_var_ref
*gen inter_formal_IV = gender*$IV_var_ref
lab var inter_gender "Nbr Ref x Gender"


**** OLS *****
  foreach outcome of global outcomes_uncond {
    qui xi: reg `outcome' $dep_var_ref inter_gender gender ///
                age age2 ///
                i.district_iid i.year  ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref inter_gender gender) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref inter_gender gender) 
    estimates store m_`outcome', title(Model `outcome')
  }







   coefplot  (m_employed_olf_3m, label("Employed") ) ///
               ,  bylabel(Jordan) ///
                mlabel(string(@b, "%5.2f")) mlabposition(12) mlabsize(vsmall) ///
             || (m_employed_olf_3m, label("Employed")) ///
             , bylabel(Uganda)  ///
                 mlabel(string(@b, "%5.2f")) mlabposition(12) mlabsize(vsmall) ///
             || (m_unemployed_olf_3m, label("Unemployed"))  ///
              ,  bylabel(Jordan)  mlabel(string(@b, "%5.2f")) mlabposition(12) mlabsize(vsmall) ///
             || (m_unemployed_olf_3m, label("Unemployed"))  ///
             , bylabel(Uganda)  ///
            ||  ,  drop(age age2 _Iyear_2016   $district ///
        _cons ) xline(0) 

  coefplot  (m_employed_olf_3m, label("Employed") ) ///
               , bylabel(Jordan) mlabel(string(@b, "%5.2f")) mlabposition(12) mlabsize(vsmall) ///
             || (m_employed_olf_3m, label("Employed")) ///
             , bylabel(Uganda)  ///
           ||  ,  drop(age age2 _Iyear_2016  $district ///
        _cons ) xline(0)    ytitle("Employed")


      coefplot  (m_unemployed_olf_3m, label("Unemployed"))  ///
              , bylabel(Jordan)  mlabel(string(@b, "%5.2f")) mlabposition(12) mlabsize(vsmall) ///
             || (m_unemployed_olf_3m, label("Unemployed"))  ///
             , bylabel(Uganda)  ///
            ||  ,  drop(age age2 _Iyear_2016  $district ///
        _cons ) xline(0) 







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
                      work_hours_pweek_3m ///
                      formal
