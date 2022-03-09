


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




              *****************
              * SUMMARY STAT  *
              ***************** 


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

su $SR_outcome, d 

tab ln_hh_syrians_bydis , m 
su hh_syrians_bydis, d
return list 
gen 		bi_ref = 0 if hh_syrians_bydis < `r(p50)' & hh_syrians_bydis != 0 
replace 	bi_ref = 1 if hh_syrians_bydis >= `r(p50)' & hh_syrians_bydis != 0 
tab 		bi_ref year

foreach out of global SR_outcome {
	tab `out', m 
	mdesc `out'
	bys year: tab `out', m 
	bys year: su `out' [aw=$SR_weight], d 
	bys bi_ref: tab `out', m 
	bys bi_ref: su `out' [aw=$SR_weight], d 
}



foreach out of global SR_outcome {
	tab `out', m 
	mdesc `out'
	ttest `out', by(bi_ref) 
	ttest `out', by(year) 
}


lab var employed_olf_7d "Employed"
lab var unemployed_7d "Unemployed"
lab var lfp_empl_7d "Wage Employee"
lab var lfp_temp_7d "Daily Labor"
lab var lfp_employer_7d "Employer"
lab var lfp_se_7d "Self-Employed"
lab var act_ag_7d "Agriculture"
lab var act_manuf_7d "Manufacturing"
lab var act_com_7d "Commerce"
lab var act_serv_7d "Services"
lab var ln_mrwage_main "Monthly Wage (ln)"
lab var ln_hrwage_main "Hourly Wage (ln)"
lab var ln_whpw_w_7d "Work Hours p.w. (ln)"
lab var formal "Formal"

su 		$SR_outcome [aw=expan_indiv]

eststo sumstat: 	 qui estpost su 	$SR_outcome [aw=$SR_weight]

esttab 	sumstat ///
		using "$out_analysis/SR_REF_SummStat.tex", ///
		cells(" count(fmt(0))  mean(fmt(2) label(Mean)) sd(fmt(2) label(SD)) min(fmt(2)) max(fmt(2))") ///
		label  booktabs replace gaps star(* 0.10 ** 0.05 *** 0.01) ///
		collabels(\multicolumn{1}{l}{{Obs}} \multicolumn{1}{c}{{Mean}} \multicolumn{1}{c}{{Std.Dev.}} \multicolumn{1}{l}{{Min}} \multicolumn{1}{l}{{Max}}) 



eststo no_ref: 	qui estpost su 		$SR_outcome  [aw=$SR_weight] if bi_ref == 0 & year == 2016
eststo ref: 		qui estpost su 		$SR_outcome  [aw=$SR_weight] if bi_ref == 1 & year == 2016
eststo diff_ref: 	 estpost ttest 	$SR_outcome  , by(bi_ref) unequal

esttab 	no_ref ref diff_ref ///
		using "$out_analysis/SR_REF_SummStat_RefIntense.tex", ///
		cells("mean(pattern(1 1 0) fmt(2) label(Mean)) sd(pattern(1 1 0) label(SD)) count(pattern(1 1 0) fmt(0)) b(star pattern(0 0 1) fmt(2) label(Diff)) t(pattern(0 0 1) par fmt(2)) count(pattern(0 0 1) fmt(0))") ///
		label nonumber booktabs replace gaps star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("\textbf{No Refugees}" "\textbf{Refugees}" "\textbf{Difference in Mean}") ///
		collabels(\multicolumn{1}{c}{{Mean}} \multicolumn{1}{c}{{Std.Dev.}} \multicolumn{1}{l}{{Obs}} \multicolumn{1}{l}{{b}} \multicolumn{1}{l}{{t}} \multicolumn{1}{l}{{Obs}} ) 


eststo year2010: 	estpost su 		$SR_outcome  [aw=$SR_weight] if year == 2010
eststo year2016: 	estpost su 		$SR_outcome  [aw=$SR_weight] if year == 2016
eststo diff_year:  estpost ttest 	$SR_outcome  , by(year) unequal

esttab 	year2010 year2016 diff_year ///
		using "$out_analysis/SR_REF_SummStat_Year.tex", ///
		cells("mean(pattern(1 1 0) fmt(2) label(Mean)) sd(pattern(1 1 0) label(SD)) count(pattern(1 1 0) fmt(0)) b(star pattern(0 0 1) fmt(2) label(Diff)) t(pattern(0 0 1) par fmt(2)) count(pattern(0 0 1) fmt(0))") ///
		label nonumber booktabs replace gaps star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("\textbf{Year 2010}" "\textbf{Year 2016}" "\textbf{Difference in Mean}") ///
		collabels(\multicolumn{1}{c}{{Mean}} \multicolumn{1}{c}{{Std.Dev.}} \multicolumn{1}{l}{{Obs}} \multicolumn{1}{l}{{b}} \multicolumn{1}{l}{{t}} \multicolumn{1}{l}{{Obs}} ) 







