



cap log close
clear all
set more off, permanently
set mem 100m

*log using "$out_analysis/11_IVRef_Analysis.log", replace

   ****************************************************************************
   **                            DATA SYNTHESIS REPORT                       **
   **                              FOR SEC ANALYSIS                          **  
   ** ---------------------------------------------------------------------- **
   ** Type Do  :  DATA JLMPS - FALLAH ET AL INSTRU                           **
   **                                                                        **
   ** Authors  : Julie Bousquet                                              **
   ****************************************************************************



use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

*lab var $dep_var "Work Permits"
*lab var IV_SS_ref_inflow "LOG IV Nb Refugees"

*tab nb_refugees_bygov
*tab IV_SS_ref_inflow

tab tot_nb_ref_2016
                            *****************
                            * IV VARIABLES  *
                            ***************** 


                      ***** REFUGEE INFLOW *****

*Network based IV Refugee Inflow 
tab pct_hh_syr_eg_2004,m 
tab pct_hh_syr_eg_2004_bydis, m 

*gen ref_2016_total = 513032
gen IV_Ref_NETW = tot_nb_ref_2016 * pct_hh_syr_eg_2004_bydis
*gen IV_Ref_NETW =  pct_hh_syr_eg_2004
replace IV_Ref_NETW = 0 if year == 2010
lab var IV_Ref_NETW "SS IV for refugee inflow based on historical network"
tab IV_Ref_NETW year 
tab IV_Ref_NETW district_iid 

  gen ln_IV_Ref_NETW = ln(1+IV_Ref_NETW)
  lab var ln_IV_Ref_NETW "LN SS IV for refugee inflow based on historical network"
  replace ln_IV_Ref_NETW = 0 if year == 2010
  tab ln_IV_Ref_NETW year 

  *gen resc_IV_Ref_NETW = IV_Ref_NETW / 10000000
  *su resc_IV_Ref_NETW

*Distance based IV Refugee Inflow 
gen IV_Ref_DIST = tot_nb_ref_2016* (1/ distance_dis_camp)
replace IV_Ref_DIST = 0 if year == 2010
lab var IV_Ref_DIST "SS IV for refugee inflow based on distance"

  gen ln_IV_Ref_DIST = ln(1+IV_Ref_DIST)
  lab var ln_IV_Ref_DIST "LN SS IV for refugee inflow based on distance"
  replace ln_IV_Ref_DIST = 0 if year == 2010
  tab ln_IV_Ref_DIST year 


                          ***** WORK PERMITS ****

*Network based IV WP 
gen wp_2016_total = 73580
gen IV_WP_NETW = wp_2016_total * pct_hh_syr_eg_2004_bydis
replace IV_WP_NETW = 0 if year == 2010
lab var IV_WP_NETW "SS IV for nb of work permits based on historical network"

  gen ln_IV_WP_NETW = ln(1+IV_WP_NETW)
  lab var ln_IV_WP_NETW "LN SS IV for work permits based on historical network"
  replace ln_IV_WP_NETW = 0 if year == 2010
  tab ln_IV_WP_NETW year 

*Distance based IV WP
tab IV_SS_1
ren IV_SS_1 IV_WP_DIST 
lab var IV_WP_DIST "SS IV for nb of work permits based on distance"
tab IV_WP_DIST year 

  gen ln_IV_WP_DIST = ln(1+IV_WP_DIST)
  lab var ln_IV_WP_DIST "LN SS IV for work permits based on distance"
  replace ln_IV_WP_DIST = 0 if year == 2010
  tab ln_IV_WP_DIST year 






                          ************************
                          * TREATMENT VARIABLES  *
                          ************************ 



*PROPORTION OF HOUSEHOLD SYRIANS IN JORDAN 2016, by loc
tab prop_hh_syrians, m 
*replace prop_hh_syrians = 0 if year == 2010 
lab var prop_hh_syrians "Prop HH Syrians"

  gen ln_prop_hh_syrians = ln(1+prop_hh_syrians)
  lab var ln_prop_hh_syrians "Prop HH Syrians (ln)"
  replace ln_prop_hh_syrians = 0 if year == 2010 
  tab ln_prop_hh_syrians year 
  su ln_prop_hh_syrians

*NUMBER OF HOUSEHOLD SYRIANS IN 2016, by loc
tab hh_syrians, m 
tab hh_syrians_bydis, m 
lab var hh_syrians_bydis "Nb HH Syrians"

  gen ln_hh_syrians_bydis = ln(1+hh_syrians_bydis)
  lab var ln_hh_syrians_bydis "Nb HH Syrians (ln)"
  replace ln_hh_syrians_bydis = 0 if year == 2010 
  tab ln_hh_syrians_bydis year 
  su ln_hh_syrians_bydis





*NUMBER OF WP PER DISTRICT, by district 
tab agg_wp_orig, m 
tab agg_wp_orig year, m 
lab var agg_wp_orig "Nb WP"

  tab ln_agg_wp_orig year
  lab var ln_agg_wp_orig "Nb WP (ln)"

*gen dis_code=string(gov, "%02.0f")+string(district, "%02.0f")
*distinct dis_code 
*bys district_iid: egen prop_hh_syrians_bydis = sum(prop_hh_syrians) 
*bys district_iid: egen pct_hh_syr_eg_2004_bydis = sum(prop_hh_syrians) 

*tab prop_hh_syrians_bydis, m 
*tab pct_hh_syr_eg_2004_bydis, m 





                            ***********************
                            *  OUTCOME VARIABLES  *
                            ***********************

  ** outcome variables 

*Wage Employment: 
*reference period 3 months, defined as share of WAP that is employed  
tab uswrkstsr1 // From crwrkstsr1 - mkt def, search req; 7d, 2 empl - 1 unemp&OLF
codebook uswrkstsr1

tab employed_olf_3m, m 

/*7 DAYS
gen employed_olf_7d = 0 if crwrkstsr1 == 2 | crwrkstsr1 == 3 
replace employed_olf_7d = 1 if crwrkstsr1 == 1
tab employed_olf_7d 
lab def employed_olf_7d 0 "Unemployed OLF" 1 "Employed", modify 
lab var employed_olf_7d employed_olf_7d
*/

tab ln_total_rwage_3m , m

/*
*Wage from main job (ln): 
*7 days reference period – on employed only 
tab mnthwg , m 

      *Corrected from inflation
      gen rmthly_wage_main = mnthwg / CPIin17
      lab var rmthly_wage_main "CORRECTED INFLATION - Monthly Wage primary job"

      *LN: Conditional wage: EMPLOYED ONLY
      gen ln_rmthly_wage_main = ln(1+rmthly_wage_main) 
      lab var ln_rmthly_wage_main "LOG Monthly Wage primary job - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING"
*/

tab ln_hourly_rwage, m 

/*
*Hourly wage (ln): 
*7 days reference period – on employed only 
tab hrwg , m 

      *Corrected from inflation
      gen rhourly_wage_main = hrwg / CPIin17
      lab var rhourly_wage_main "CORRECTED INFLATION - Hourly Wage primary job"

      *LN: Conditional wage: EMPLOYED ONLY
      gen ln_rhourly_wage_main = ln(1+rhourly_wage_main) 
      lab var ln_rhourly_wage_main "LOG Hourly Wage primary job - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING"
*/

*Work hours per week: 

tab work_hours_pweek_3m_w, m 

/*
*usual Number of Hours per Week, reference 7 days, 
*corrected for outliers (i.e., cannot work 24h 7d/w). 
*Can convert ‘days worked per week’ to hours if 
*problem with missing data on hours. 
*tab crhrsday, m //No. of Hours/Day (Ref. 1 Week) Market Work
tab crnumhrs1, m //Crr. No. of Hours/Week, Market Work, (Ref. 1 Week).
*tab crnumhrs2, m //Crr. No. of Hours/Week, Market & Subsistence Work, (Ref. 1 Week)

gen wh_pw_7d = crnumhrs1
tab wh_pw_7d
su wh_pw_7d, d
winsor2 wh_pw_7d, s(_w) c(0 98)
su wh_pw_7d_w
lab var wh_pw_7d_w "Work Hours per Week - 7d - Market Work - winsorized"
*/

*LFP (12 months UG/ETH and 3 months JOR/COL): Employer, 
*Wage employment, Self Employed (non ag), unpaid labor 
*(incl family worker) , temporary labor
tab crempstp 
tab usempstp //employment status in prim job (ref. 3 months)
codebook usempstp 
/* 1  Waged employee
   2  Employer
   3  Self-employed
   4  Unpaid family worker */
tab usstablp
codebook usstablp 
/* 1  permanent
   2  temporary
   3  seasonal
   4  casual */
tab usstablp usempstp
/*
       Job |
 stability |
  in prim. |    employment status in prim job (ref. 3
 job (ref. |                   months)
  3-mnths) | Waged emp   Employer  Self-empl  Unpaid fa |     Total
-----------+--------------------------------------------+----------
 permanent |     4,940        230        426        209 |     5,805 
 temporary |       325          8         15         10 |       358 
  seasonal |        43          9         20          2 |        74 
    casual |       242         27        145          7 |       421 
-----------+--------------------------------------------+----------
     Total |     5,550        274        606        228 |     6,658 
*/

gen lfp_3m = 1 if usempstp == 1 //wage employee - permanent 
replace lfp_3m = 2 if usstablp == 2 | usstablp == 3 | usstablp == 4 //any temp job
replace lfp_3m = 3 if usempstp == 2 //Employer
replace lfp_3m = 4 if usempstp == 3 //Self Employed
replace lfp_3m = 5 if usempstp == 4 //Unpaid Labor
lab def lfp_3m  1 "Wage Employee" ///
                2 "Temporary Worker" ///
                3 "Employer" ///
                4 "Self Employed" ///
                5 "Unpaid Labor" ///
                , modify
lab val lfp_3m lfp_3m
lab var lfp_3m "Labor Force Participation - 3month"
tab lfp_3m, m 

gen     lfp_3m_empl = 0 if !mi(lfp_3m) 
replace lfp_3m_empl = 1 if lfp_3m == 1 
tab     lfp_3m_empl, m 
lab def lfp_3m_empl 0 "Else" 1 "Wage Employee", modify  
lab val lfp_3m_empl lfp_3m_empl
lab var lfp_3m_empl "Wage Employee"

gen     lfp_3m_temp = 0 if !mi(lfp_3m) 
replace lfp_3m_temp = 1 if lfp_3m == 2 
tab     lfp_3m_temp, m 
lab def lfp_3m_temp 0 "Else" 1 "Temporary Worker", modify  
lab val lfp_3m_temp lfp_3m_temp
lab var lfp_3m_temp "Temporary Worker"

gen     lfp_3m_employer = 0 if !mi(lfp_3m) 
replace lfp_3m_employer = 1 if lfp_3m == 3 
tab     lfp_3m_employer, m 
lab def lfp_3m_employer 0 "Else" 1 "Employer", modify  
lab val lfp_3m_employer lfp_3m_employer
lab var lfp_3m_employer "Employer"

gen     lfp_3m_se = 0 if !mi(lfp_3m) 
replace lfp_3m_se = 1 if lfp_3m == 4 
tab     lfp_3m_se, m 
lab def lfp_3m_se 0 "Else" 1 "Self Employed", modify  
lab val lfp_3m_se lfp_3m_se
lab var lfp_3m_se "Self Employed"

gen     lfp_3m_unpaid = 0 if !mi(lfp_3m) 
replace lfp_3m_unpaid = 1 if lfp_3m == 5
tab     lfp_3m_unpaid, m 
lab def lfp_3m_unpaid 0 "Else" 1 "Unpaid Labor", modify  
lab val lfp_3m_unpaid lfp_3m_unpaid
lab var lfp_3m_unpaid "Unpaid Labor"


*Unemployed: 

tab unemployed_3m 
tab unemployed_olf_3m 

*standard unemployed with market definition (search required), 
*defined as share of LF that is unemployed, i.e., 
*inactive working-age respondents are coded missing 
*unemployed_olf_7d // From unempsr1 - mrk def, search req; 3m, empl or unemp&OLF
*unemployed_7d // From unempsr1m - mrk def, search req; 3m, empl or unemp, OLF is miss
tab unempsr1, m //Std. unemployed with mrkt.def. (search required), with missing out of the labo
ren unempsr1 unemployed_olf_7d

*Formal: 
*define as holding a social security or a formal contract 
tab formal

                      **********************
                      * CONTROL VARIABLES  *
                      ********************** 


*Controls – work with two sets if possible:  

*Pre-determined only: gender, age, age squared.  
tab age
tab age2
tab gender



                      ***************************
                      * HETEROGENOUS VARIABLES  *
                      *************************** 


tab gender
tab urb_rural_camps 
tab lfp_3m 
tab bi_education

save "$data_final/07_IV_Ref_WP.dta", replace
