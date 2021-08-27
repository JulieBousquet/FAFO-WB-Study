
use "$data_final/05_IV_JLMPS_MergingIV.dta", clear

**********************************
* PEOPLE SURVEYED IN BOTH ROUNDS *
**********************************

*br indid indid_2010 indid_2016 year
*SAMPLE: SAME INDIVIDUALS WERE SURVEYED IN 2010 AND 2016
*BUT A FEW WERE NOT (ALL REFUGEE WEREN'T SURVEYED IN 2010)
*AND A FEW JORDANIANS. I DECDIE TO KEEP ONLY THE PANEL STRUCTURE 
*FOR FIXED EFFECT AT THE INDIV LEVEL 

*replace indid_2016 = indid if mi(indid_2016)
gen surveyed_2_rounds = 1 if in_2010 == 1 & in_2016 == 1 
keep if surveyed_2_rounds == 1 


*Flag those who were surveyed in both rounds 
gen surveyed_2_rounds = 1 if !mi(indid_2010) & !mi(indid_2016)
*Keep only the surveyed in both round
keep if surveyed_2_rounds == 1 
*/

preserv
*Common identifier
sort indid_2010

*br nationality_cl indid_2010 hhid_2010 indid_2016 hhid_2016 district_id subdistrict locality sex brthyr brthmth nationality age agegrp1 agegrp2 reltohd marital

distinct indid_2010 //28316/2 = 14158 while we have 14306: there is an inbalance
*Even if they have an ID for both few actually did not do one of the round 
duplicates tag indid_2010, gen(dup)
bys year: tab dup //(90 in 2010 and 206 in 2016)
*Dropping those who actually did not the two rounds 
drop if dup == 0 

drop surveyed_2_rounds dup

*28020 indiv surveyed twice in 2010 and 2020
mdesc indid_2010
destring indid_2010, replace 
format indid_2010 %12.0g



**************
* JORDANIANS *
**************

preserve 
codebook nationality_cl
lab list Lnationality_cl
/*
                        53,094         1  Jordanian
                         3,003         2  Syrian
                           623         3  Egyptian
                         2,551         4  Other Arab
                           132         5  Other

*/

*keep if nationality_cl == 1 //Keep only the jordanians
*keep if nationality_cl != 2 //Keep all but the syrians
tab nationality_cl year

keep nationality_cl indid_2010 year
reshape wide nationality_cl, i(indid_2010) j(year)

*Correction #1
gen flag = 1 if nationality_cl2010 != nationality_cl2016 
list nationality_cl2016 nationality_cl2010 if flag == 1 
*If Declare JORDANIAN in 2016 but different in 2010
*then JORDANIAN
replace nationality_cl2010 = nationality_cl2016 if flag == 1 & nationality_cl2016 == 1
drop flag 

*Correction #2
gen flag = 1 if nationality_cl2010 != nationality_cl2016 
list nationality_cl2016 nationality_cl2010 if flag == 1 
*If Declare JORDANIAN in 2010 but different in 2016
*then JORDANIAN
replace nationality_cl2016 = nationality_cl2010 if flag == 1 & nationality_cl2010 == 1
drop flag 

*Corection #3
gen flag = 1 if nationality_cl2010 != nationality_cl2016 
list nationality_cl2016 nationality_cl2010 if flag == 1 
*IF Declare OTHER ARAB in 2010 but differnt in 2016
replace nationality_cl2010 = nationality_cl2016 if flag == 1 & nationality_cl2016 == 4
drop flag 

*Corection #4
gen flag = 1 if nationality_cl2010 != nationality_cl2016 
list nationality_cl2016 nationality_cl2010 if flag == 1 
*IF Declare OTHER ARAB in 2016 but differnt in 2010
replace nationality_cl2016 = nationality_cl2010 if flag == 1 & nationality_cl2010 == 4
drop flag 

*br nationality_cl2016 nationality_cl2010 
/*
1  Jordanian
2  Syrian
3  Egyptian
4  Other Arab
5  Other
*/

reshape long nationality_cl, i(indid_2010) j(year)
format indid_2010 %12.0g

tempfile data_nat
save `data_nat'
restore 

drop nationality_cl 
merge 1:1 indid_2010 year using  `data_nat'
drop _merge 



***************
* WORKING AGE *
*************** 

preserve 

keep age indid_2010 year
reshape wide age, i(indid_2010) j(year)
format indid_2010 %12.0g

*br indid_2010 age2016 age2010

sort indid_2010
mdesc age2016 

*There are a lot of discrepencies.
gen age_diff = age2016 - age2010

gen flag = age_diff if age_diff > 6 | age_diff < 0

sort flag
list indid_2010 age2010 age2016 age_diff if !mi(flag) & flag >= 40
list indid_2010 age2010 age2016 age_diff if !mi(flag) & flag > 7 & (age2010 == 58) 
list indid_2010 age2010 age2016 age_diff if !mi(flag) & flag > 7 & (age2016 == 64) 
list indid_2010 age2010 age2016 age_diff if !mi(flag) & flag > 7 & (age2010 == 10) 
list indid_2010 age2010 age2016 age_diff if !mi(flag) & flag > 7 & (age2016 == 22) 
list indid_2010 age2010 age2016 age_diff if !mi(flag) & flag < 0 

gen check = 1 if !mi(flag) & flag >= 20
replace check = 1 if !mi(flag) & flag > 7 & (age2010 == 58)
replace check = 1 if !mi(flag) & flag > 7 & (age2016 == 64)
replace check = 1 if !mi(flag) & flag > 7 & (age2010 == 10) 
replace check = 1 if !mi(flag) & flag > 7 & (age2016 == 22)
replace check = 1 if !mi(flag) & flag < 0
replace check = 1 if !mi(flag) & age_diff== 0

list indid_2010 age2010 age2016 age_diff if check == 1 
replace age2016 = 64 if indid_2010 == 102440701
/*
 indi~2010   age2010   age2016   age_diff
102440701        58        66          8

103700804        14        22          8
102491004        14        22          8 
102210303        14        22          8 
100500106        14        22          8 
103210904        14        22          8 
101460903        14        22          8 
103170608        14        22          8
103800608        14        22          8 
*/
sort age_diff
list indid_2010 age2010 age2016 age_diff if check != 1 
*list indid_2010 age2010 age2016 age_diff if  age2010<64 & age2010>16 & age2016>16 & age2016<64

tempfile age_flag 
save `age_flag'

*drop age2016 age_diff
drop age_diff check flag

*I decide to recreate the age 2016 so that 
*it matches what was declared in 2010
*gen age2016 = age2010 + 6 
*tab age2016, m
*lab var age2016 "Age 2016"

list if age2010 == 0 
list if age2016 == 0 

tab age2016, m
tab age2010, m

reshape long age, i(indid_2010) j(year)
format indid_2010 %12.0g

tempfile data_age
save `data_age'
restore 

*drop age 
merge 1:1 indid_2010 year using  `data_age'
drop _merge

merge m:1 indid_2010 using  `age_flag', keepusing(age_diff check)


*keep indid_2010 age age_diff check 
sort indid_2010
format indid_2010 %12.0g
*keep if check == 1 

tab brthyr
list indid_2010 age brthyr age_diff if check == 1 

mdesc brthyr
gen age2016 = 2016 - brthyr if year == 2016
gen age2010 = 2010 - brthyr if year == 2010

list indid_2010 brthyr age2016 age2010 age age_diff check yrschl  if check == 1
replace age = age2016 if check == 1 & year == 2016 
replace age = age2010 if check == 1 & year == 2010

drop check age2016 age2010 flag













use  "$data_temp/temp_dataset.dta", clear 


codebook employed_3cat_3m
/*
14,270         0  Out of the labor force
1,645         1  Unemployed (&subs)
4,809         2  Employed (no subs)
2,942         .  
*/

preserve 


keep employed_3cat_3m indid_2010 year job1_y dstcrj
reshape wide employed_3cat_3m job1_y dstcrj  , i(indid_2010) j(year)
format indid_2010 %12.0g

replace employed_3cat_3m2010 = 2 if mi(employed_3cat_3m2010) & dstcrj2016 <2010
replace employed_3cat_3m2010 = 2 if mi(employed_3cat_3m2010) & job1_y2016 <2010

*br indid_2010 employed_3m2016 employed_3m2010

*MISS 2016 - MISS 2010
gen miss_16_10 = 1 if mi(employed_3cat_3m2016) & mi(employed_3cat_3m2010)

*UNEMP 2016 - UNEMP 2010
gen unemp_16_10 = 1 if employed_3cat_3m2016 == 1 & employed_3cat_3m2010 == 1 

*OLF 2016 - OLF 2010
gen olf_16_10 = 1 if  employed_3cat_3m2016 == 0 & employed_3cat_3m2010 == 0

*EMPL 2016 - EMPL 2010
gen emp_16_10 = 1 if  employed_3cat_3m2016 == 2 & employed_3cat_3m2010 == 2

*EMP 2016 - MISS 2010 
gen emp_16_miss_10 = 1 if employed_3cat_3m2016 == 2 & mi(employed_3cat_3m2010)  

*EMP 2010 - MISS 2016 
gen emp_10_miss_16 = 1 if employed_3cat_3m2010 == 2 & mi(employed_3cat_3m2016) 

*UNEMP 2016 - MISS 2010 
gen unemp_16_miss_10 = 1 if employed_3cat_3m2016 == 1 & mi(employed_3cat_3m2010)

*UNEMP 2010 - MISS 2016 
gen unemp_10_miss_16 = 1 if employed_3cat_3m2010 == 1 & mi(employed_3cat_3m2016) 

*OLF 2016 - MISS 2010 
gen olf_16_miss_10 = 1 if employed_3cat_3m2016 == 0 & mi(employed_3cat_3m2010) 

*OLF 2010 - MISS 2016
gen olf_10_miss_16 = 1 if employed_3cat_3m2010 == 0 & mi(employed_3cat_3m2016) 

*EMPL 2010 - OLF 2016
gen emp_10_olf_16 = 1 if employed_3cat_3m2010 == 2 & employed_3cat_3m2016 == 0

*EMPL 2016 - OLF 2010
gen emp_16_olf_10 = 1 if employed_3cat_3m2016 == 2 & employed_3cat_3m2010 == 0

*UNEMP 2010 - EMP 2016
gen unemp_10_emp_16 = 1 if employed_3cat_3m2010 == 1 & employed_3cat_3m2016 == 2

*UNEMP 2016 - EMP 2010
gen unemp_16_emp_10 = 1 if employed_3cat_3m2016 == 1 & employed_3cat_3m2010 == 2

*UNEMP 2016 - EMP 2010
gen olf_10_unemp_16 = 1 if employed_3cat_3m2010 == 0 & employed_3cat_3m2016 == 1

*UNEMP 2016 - EMP 2010
gen olf_16_unemp_10 = 1 if employed_3cat_3m2016 == 0 & employed_3cat_3m2010 == 1

/*
gen flag = 1 if   mi(miss_16_10) & ///
                  mi(unemp_16_10) & ///
                  mi(olf_16_10) & ///
                  mi(emp_16_10) & ///
                  mi(emp_16_miss_10) & ///
                  mi(emp_10_miss_16) & ///
                  mi(unemp_16_miss_10) & ///
                  mi(unemp_10_miss_16) & ///
                  mi(olf_16_miss_10) & ///
                  mi(olf_10_miss_16) & ///
                  mi(emp_10_olf_16) & ///
                  mi(emp_16_olf_10) & ///
                  mi(unemp_10_emp_16) & ///
                  mi(unemp_16_emp_10) & ///
                  mi(olf_10_unemp_16) & ///
                  mi(olf_16_unemp_10)
br employed_3cat_3m2010 employed_3cat_3m2016 if flag == 1 
*/

sort indid_2010

tab employed_3cat_3m2010, m 
tab employed_3cat_3m2016, m 

/*
. tab employed_3cat_3m2010, m 

 2010 employed_3cat_3m |      Freq.     Percent        Cum.
-----------------------+-----------------------------------
Out of the labor force |      6,725       56.83       56.83
    Unemployed (&subs) |        645        5.45       62.28
    Employed (no subs) |      2,238       18.91       81.20
                     . |      2,225       18.80      100.00
-----------------------+-----------------------------------
                 Total |     11,833      100.00

. tab employed_3cat_3m2016, m 

 2016 employed_3cat_3m |      Freq.     Percent        Cum.
-----------------------+-----------------------------------
Out of the labor force |      7,545       63.76       63.76
    Unemployed (&subs) |      1,000        8.45       72.21
    Employed (no subs) |      2,571       21.73       93.94
                     . |        717        6.06      100.00
-----------------------+-----------------------------------
                 Total |     11,833      100.00
*/
tab miss_16_10, m  
tab unemp_16_10, m  
tab olf_16_10, m  
tab emp_16_miss_10, m  
tab emp_10_miss_16, m  
tab unemp_16_miss_10, m  
tab unemp_10_miss_16, m  
tab olf_16_miss_10, m  
tab olf_10_miss_16, m
tab emp_10_olf_16, m 
tab emp_16_olf_10, m 
tab unemp_10_emp_16, m 
tab unemp_16_emp_10, m 
tab olf_10_unemp_16, m 
tab olf_16_unemp_10, m 

reshape long employed_3cat_3m, i(indid_2010) j(year)
format indid_2010 %12.0g

tempfile data_empl
save `data_empl'
restore 

drop employed_3cat_3m 
merge 1:1 indid_2010 year using  `data_empl'
drop _merge




