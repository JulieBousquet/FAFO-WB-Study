












use "$data_final/02_JLMPS_10_16.dta", clear

use "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", clear

tab nationality_cl year , m 

drop if age > 64 & year == 2016
drop if age > 60 & year == 2010 //60 in 2010 so 64 in 2016
drop if age < 15 & year == 2016 
drop if age < 11 & year == 2010 //11 in 2010 so 15 in 2016

keep if emp_16_10 == 1 

distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

                                  ************
                                  *   PANEL  *
                                  ************

* SET THE PANEL STRUCTURE
xtset, clear 
*xtset year
destring indid_2010 Findid, replace
mdesc indid_2010
xtset indid_2010 year 

codebook $dep_var
lab var $dep_var "Work Permits (ln)"


tab usempstp, m
tab crinstsec, m
tab total_wage_3m usempstp
