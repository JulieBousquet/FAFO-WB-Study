

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
distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

xtset, clear 
xtset indid_2010 year 

             





    xi: reg employed_olf_3m ln_agg_wp_orig i.district_iid i.year $controls ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_wp) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_wp) 
    estimates store m_`outcome', title(Model `outcome')
  



















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
