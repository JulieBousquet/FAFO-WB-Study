
************************************************
//  SUMMARY STATISTICS
************************************************

**************************
* OUTCOME AND CONTROLS
**************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

bys year: su agg_wp_orig
bys year: su IV_SS_5

drop if nationality_cl != 1
drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

drop if miss_16_10 == 1
*drop if emp_16_miss_10 == 1
*drop if emp_10_miss_16 == 1
*drop if unemp_16_miss_10 == 1
*drop if unemp_10_miss_16 == 1
*drop if olf_16_miss_10 == 1
*drop if olf_10_miss_16 == 1 

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

bys year: su unempdurmth  // Current unemployment duration (in months)
*bys year: tab unempdurmth  // Current unemployment duration (in months)

codebook employed_3m
recode employed_3m (1=0) (2=1)
lab def employed_3m 0 "Unemployed" 1 "Employed", modify
lab val employed_3m employed_3m
tab employed_3m
bys year: su employed_3m  // From uswrkstsr1 - mkt def, search req; 3m, 2 empl - 1 unemp - OLF miss

ttest employed_3m, by(year)
/*
drop if unemp_16_10 == 1
drop if olf_16_10 == 1

drop if emp_16_miss_10 == 1
drop if emp_10_miss_16 == 1
drop if unemp_16_miss_10 == 1
drop if unemp_10_miss_16 == 1
drop if olf_16_miss_10 == 1
drop if olf_10_miss_16 == 1 
*/

keep if emp_16_10 == 1 

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

*OUTCOME VARIABLES
bys year: su job_stable_3m //  From usstablp - Stability of employement (3m) - 1 permanent - 0 temp, seas, cas
bys year: su formal  // 0 Informal - 1 Formal - Informal if no contract (uscontrp=0) OR no insurance (ussocinsp=0)
bys year: su wp_industry_jlmps_3m  // Industries with work permits for refugees - Economic Activity of prim. job 3m
bys year: su member_union_3m // Member of a syndicate/trade union (ref. 3-mnths)
bys year: su skills_required_pjob //  Does primary job require any skill
bys year: su real_basic_wage_3m  //  Basic Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING
bys year: su real_total_wage_3m  //  Total Wage (3-month) - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING
bys year: su real_monthly_wage //  Monthly Wage (Prim.& Second. Jobs)
bys year: su real_hourly_wage  //  Hourly Wage (Prim.& Second. Jobs)
bys year: su work_hours_pday_3m_w  // Winsorized - No. of Hours/Day (Ref. 3 mnths) Market Work
bys year: su work_hours_pweek_3m_w  // Winsorized - Usual No. of Hours/Week, Market Work, (Ref. 3-month)
bys year: su work_days_pweek_3m  // Avg. num. of wrk. days per week during 3 mnth.

*CONTROL VARIABLES
bys year: su age 
ttest age, by(year)

bys year: su gender
ttest gender, by(year)

bys year: su hhsize 
ttest hhsize, by(year)

bys year: su educ1d //  Education Levels (1-digit)
ttest educ1d, by(year)

bys year: su fteducst //  Father's Level of education attained
ttest fteducst, by(year)

bys year: su mteducst //  Mother's Level of education attained
ttest mteducst, by(year)

bys year: su ftempst //  Father's Employment Status (When Resp. 15)
ttest ftempst, by(year)













**************************
* TT TEST BY DISTRICT WITH WP - 2016
**************************

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

gen agg_wp_bi = 1 if agg_wp_orig != 0
replace agg_wp_bi = 0 if agg_wp_orig == 0
tab district_iid agg_wp_bi if year == 2016

drop if nationality_cl != 1
drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

drop if miss_16_10 == 1

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year


codebook employed_3m
recode employed_3m (1=0) (2=1)
lab def employed_3m 0 "Unemployed" 1 "Employed", modify
lab val employed_3m employed_3m
tab employed_3m
bys year: su employed_3m  // From uswrkstsr1 - mkt def, search req; 3m, 2 empl - 1 unemp - OLF miss

ttest employed_3m if year == 2016, by(agg_wp_bi)

keep if emp_16_10 == 1 

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

ttest job_stable_3m if year == 2016, by(agg_wp_bi)
ttest formal if year == 2016, by(agg_wp_bi)
ttest wp_industry_jlmps_3m if year == 2016, by(agg_wp_bi)
ttest member_union_3m if year == 2016, by(agg_wp_bi)
ttest skills_required_pjob if year == 2016, by(agg_wp_bi)
ttest real_basic_wage_3m if year == 2016, by(agg_wp_bi)
ttest real_total_wage_3m if year == 2016, by(agg_wp_bi)
ttest real_monthly_wage if year == 2016, by(agg_wp_bi)
ttest real_hourly_wage if year == 2016, by(agg_wp_bi)
ttest work_hours_pday_3m_w if year == 2016, by(agg_wp_bi)
ttest work_hours_pweek_3m_w if year == 2016, by(agg_wp_bi)
ttest work_days_pweek_3m if year == 2016, by(agg_wp_bi)





