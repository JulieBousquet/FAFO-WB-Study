*BA Emp
*Retro Data
*v7
*Original 10/17/17
*Updated 3/16/19

set more off

****************
*Annualized labor market statuses since leaving school
****************

use "$data_JLMPS_base/JLMPS 2016 xs v1.1.dta", clear

*Jordanians only
keep if nationality==400

*Adults only
keep if age>=15

*Filling in missing for loop
gen q7109_14=.
gen q7110_14=.

gen q7110_21b=.
gen q7110_23=. 
gen q7110_27=.

foreach j in 06 07 08 09 10 {
gen q71`j'_25=.
}

foreach j in 07 08 09 10 {
gen q71`j'_24=.

gen q71`j'_26=.
}


foreach j in 03 04 05 06 07 08 09 10 {

gen q71`j'_11b=. 
gen q71`j'_15b=. 

}


****In country

forvalues i=1(1)14 {
local year=2018-`i' 

gen in_jo_`year'=1

replace in_jo_`year'=0 if q2138==2 & q2147_1>`year' & q2147_1!=. & q2147_1!=9998
replace in_jo_`year'=0 if q2144_1==2 & q2147_2>`year' & q2147_2!=. & q2147_2!=9998 & q2147_1<=`year' & q2147_1!=. & q2147_1!=9998
replace in_jo_`year'=0 if q2144_2==2 & q2147_3>`year' & q2147_3!=. & q2147_3!=9998 & q2147_2<=`year' & q2147_2!=. & q2147_2!=9998
replace in_jo_`year'=0 if q2144_3==2 & q2147_4>`year' & q2147_4!=. & q2147_4!=9998 & q2147_3<=`year' & q2147_3!=. & q2147_3!=9998
replace in_jo_`year'=0 if q2144_4==2 & q2147_5>`year' & q2147_5!=. & q2147_5!=9998 & q2147_4<=`year' & q2147_4!=. & q2147_4!=9998
replace in_jo_`year'=0 if q2144_5==2 & q2147_6>`year' & q2147_6!=. & q2147_6!=9998 & q2147_5<=`year' & q2147_5!=. & q2147_5!=9998
replace in_jo_`year'=0 if q2144_6==2 & q2147_7>`year' & q2147_7!=. & q2147_7!=9998 & q2147_6<=`year' & q2147_6!=. & q2147_6!=9998
replace in_jo_`year'=0 if q2144_7==2 & q2147_8>`year' & q2147_8!=. & q2147_8!=9998 & q2147_7<=`year' & q2147_7!=. & q2147_7!=9998
replace in_jo_`year'=0 if q2144_8==2 & q2147_9>`year' & q2147_9!=. & q2147_9!=9998 & q2147_8<=`year' & q2147_8!=. & q2147_8!=9998
}


****Work

*Set DK year to missing
foreach var of varlist q7001b q710*_1b q710*_21b {

replace `var'=. if `var'==9999 | `var'==9998
}

*We're going to use a giant 'loop' 
*We want to look at 14 years (7 pre (2004 2005 2006 2007 2008 2009 2010), 7 post (2011, 2012, 2013, 2014, 2015, 2016, 2017
forvalues i=1(1)14 {
local year=2018-`i' 

*First we want to identify which status is relevant for that year, stat_`year'
*Before enttry
 gen stat_`year'=0 if `year'<q7001b & q7001b!=.
 replace stat_`year'=0 if `year'<q7101_1b & q7001b==. & q7101_1b!=.
 replace stat_`year'=0 if `year'<q7101_1b & `year'>=q7001b & q7101_1b!=.
 replace stat_`year'=0 if evrwrk==0
 
*Entry OLF 
 replace stat_`year'=1 if `year'>=q7001b & `year'<q7101_1b & q7101_1b <. & (q7002==1 & (q7003==2 | q7004==2))
*Entry Unemp 
 replace stat_`year'=2 if `year'>=q7001b & `year'<q7101_1b & q7101_1b <. & (q7002==1 & (q7003==1 & q7004==1))
 replace stat_`year'=2 if evrwrk==0 & q5208b<=`year' & (search==1 | q5213==1)
 
 
*Job loop
foreach j in 01 02 03 04 05 06 07 08 09 10 {

*No change
replace stat_`year'=(`j'*3) if `year'>=q71`j'_1b & q71`j'_20==2 & q71`j'_1b<. & stat_`year'==. 

*With start and end
replace stat_`year'=(`j'*3) if `year'>=q71`j'_1b & q71`j'_20==1 & q71`j'_21b>`year' & q71`j'_21b<. & stat_`year'==. 

 }

*OLF loop
forvalues j=1(1)5  {
local k=`j'+1
*No change
replace stat_`year'=(`j'*3+1) if `year'>=q710`j'_21b & q710`j'_20==1 & q710`j'_21b<. & (q710`j'_23==1 & (q710`j'_24==2 | q710`j'_25==2)) & q710`j'_27==2 & stat_`year'==. 
replace stat_`year'=(`j'*3+1) if `year'>=q710`j'_21b & q710`j'_20==1 & q710`j'_21b<. & (q710`j'_23==2) & q710`j'_27==2 & stat_`year'==. 


*With start and end
replace stat_`year'=(`j'*3+1) if `year'>=q710`j'_21b & q710`j'_20==1 & q710`j'_21b<. & (q710`j'_23==1 & (q710`j'_24==2 | q710`j'_25==2)) & q710`j'_27==1 & q710`k'_1b<. & q710`k'_1b>`year'  & stat_`year'==. 
replace stat_`year'=(`j'*3+1) if `year'>=q710`j'_21b & q710`j'_20==1 & q710`j'_21b<. & (q710`j'_23==2) & q710`j'_27==1 & q710`k'_1b<. & q710`k'_1b>`year'  & stat_`year'==. 

 }
 
*Unemp loop
forvalues j=1(1)5  {
local k=`j'+1
*No change
replace stat_`year'=(`j'*3+2) if `year'>=q710`j'_21b & q710`j'_20==1 & q710`j'_21b<. & (q710`j'_23==1 & (q710`j'_24==1 & q710`j'_25==1)) & q710`j'_27==2 & stat_`year'==. 

*With start and end
replace stat_`year'=(`j'*3+2) if `year'>=q710`j'_21b & q710`j'_20==1 & q710`j'_21b<. & (q710`j'_23==1 & (q710`j'_24==1 & q710`j'_25==1)) & q710`j'_27==1 & q710`k'_1b<. & q710`k'_1b>`year'  & stat_`year'==. 

 } 
 
************ 
*LM status
************
 gen lm_`year'=1 if stat_`year'==0
 replace lm_`year'=1 if inlist(stat_`year',1,4,7,10,13,16)
 replace lm_`year'=2 if inlist(stat_`year',2,5,8,11,14,17)
 replace lm_`year'=3 if inlist(stat_`year',3,6,9,12,15,18)
 }
 
 
 *Checks
 tabu stat_2017 evrwrk, miss
 tabu stat_2004 evrwrk, miss

 tabu lm_2017 evrwrk, miss
 tabu lm_2004 evrwrk, miss

 la def Llm 1 "OLF" 2 "Unemp" 3 "Emp"
la val lm_* Llm
 
 tabu lm_2017 crwrkst1
 
************ 
*Formality of employment
************ 
 
 forvalues i=1(1)14 {
local year=2018-`i' 

 gen formal_`year'=.
foreach j in 01 02 03 04 05 06 07 08 09 10 {
 replace formal_`year'=0 if stat_`year'==(`j'*3) & (q71`j'_9==1 | q71`j'_9==2) & q71`j'_10==2 & q71`j'_11b>`year' &  q71`j'_11b!=9998
 replace formal_`year'=0 if stat_`year'==(`j'*3) & q71`j'_9==3
 replace formal_`year'=0 if stat_`year'==(`j'*3) & q71`j'_13==1 & q71`j'_14==2 & q71`j'_15b>`year' &  q71`j'_15b!=9998
 replace formal_`year'=0 if stat_`year'==(`j'*3) & q71`j'_13==2
 
 
 replace formal_`year'=1 if stat_`year'==(`j'*3) & (q71`j'_9==1 | q71`j'_9==2) & q71`j'_10==1
 replace formal_`year'=1 if stat_`year'==(`j'*3) & (q71`j'_9==1 | q71`j'_9==2) & q71`j'_10==2 & q71`j'_11b<=`year' &  q71`j'_11b!=9998
 replace formal_`year'=1 if stat_`year'==(`j'*3) & (q71`j'_13==1 | q71`j'_13==2) & q71`j'_14==1
 replace formal_`year'=1 if stat_`year'==(`j'*3) & (q71`j'_13==1 | q71`j'_13==2) & q71`j'_14==2 & q71`j'_15b<=`year' &  q71`j'_15b!=9998
 
 }
 }
 
 tabu formal_2017 usformal if usemp1==1 & lm_2017==3, miss
 tabu formal_2016 usformal if usemp1==1 & lm_2016==3, miss


************ 
*Occupation
************ 
 
  forvalues i=1(1)14 {
local year=2018-`i' 

 gen usoccupp_`year'=.
foreach j in 01 02 03 04 05 06 07 08 09 10 {
 replace usoccupp_`year'=q71`j'_3 if stat_`year'==(`j'*3)

 
 }
 gen usocp1d_`year'=int(usoccupp_`year'/1000) 
label value usocp1d_* ocp1digit

gen man_prof_`year'=(usocp1d_`year'==1 | usocp1d_`year'==2 | usocp1d_`year'==3) if usocp1d_`year'!=.
 }
 
 
 
 tabu usocp1d_2017 usocp1d if usemp1==1 & lm_2017==3, miss
 


************ 
*Economic activity
************ 
 
  forvalues i=1(1)14 {
local year=2018-`i' 

 gen usecactp_`year'=.
foreach j in 01 02 03 04 05 06 07 08 09 10 {
 replace usecactp_`year'=q71`j'_4 if stat_`year'==(`j'*3)

 
 }
 gen usecactp_comp_`year'=0 if usecactp_`year'!=.
*Ag
replace usecactp_comp_`year'=1 if usecactp_`year'>=111 & usecactp_`year'<=322
*Manuf
replace usecactp_comp_`year'=1 if usecactp_`year'>=1010 & usecactp_`year'<=3290
*Constr
replace usecactp_comp_`year'=1 if usecactp_`year'>=4100 & usecactp_`year'<=4390
*Food & beverage
replace usecactp_comp_`year'=1 if usecactp_`year'>=5610 & usecactp_`year'<=5630
replace usecactp_comp_`year'=1 if usecactp_`year'==4630
replace usecactp_comp_`year'=1 if usecactp_`year'==4711
replace usecactp_comp_`year'=1 if usecactp_`year'==4721
replace usecactp_comp_`year'=1 if usecactp_`year'==4722
replace usecactp_comp_`year'=1 if usecactp_`year'==4781
*Domestic and cleaning
replace usecactp_comp_`year'=1 if usecactp_`year'>=8110 & usecactp_`year'<=8130
replace usecactp_comp_`year'=1 if usecactp_`year'==9700
 
 }
 
 
 
 tabu usecactp_comp_2017 usecac1d if usemp1==1 & lm_2017==3, miss

************ 
*Human Services
************ 
 
  forvalues i=1(1)14 {
local year=2018-`i' 

 gen usecactp_hhs_`year'=0 if usecactp_`year'!=.
*HHS
 replace usecactp_hhs_`year'=1 if usecactp_`year'>=8510 & usecactp_`year'<=8690

 }
 
 
 
 tabu usecac2d usecactp_hhs_2017 if usemp1==1 & lm_2017==3, miss

************ 
*Sector
************ 
 
  forvalues i=1(1)14 {
local year=2018-`i' 

 gen ussec_`year'=.
foreach j in 01 02 03 04 05 06 07 08 09 10 {
 replace ussec_`year'=q71`j'_6 if stat_`year'==(`j'*3)

 
 }
 gen uspriv_`year'=1 if inlist(ussec_`year',4,5)
replace uspriv_`year'=0 if inlist(ussec_`year',1,2,3,6,97,98)
 
 }
 
 
 
 tabu uspriv_2017 ussectrp if usemp1==1 & lm_2017==3, miss

 
 
************ 
*Geo
************

forvalues i=1(1)14 {
local year=2018-`i'  


gen gov_`year'=.

replace gov_`year'=q2139_gov if q2141==2 
replace gov_`year'=q2139_gov if q2141==1 & q2147_1>`year' & q2147_1!=. & q2147_1!=9998

replace gov_`year'=q2145_gov_1 if q2143==1 & q2147_1<=`year' & q2147_1!=. & q2147_1!=9998
replace gov_`year'=q2145_gov_1 if q2147_2>`year' & q2147_2!=. & q2147_2!=9998 & q2147_1<=`year' & q2147_1!=. & q2147_1!=9998

replace gov_`year'=q2145_gov_2 if q2143==2 & q2147_2<=`year' & q2147_2!=. & q2147_2!=9998
replace gov_`year'=q2145_gov_2 if q2144_2==2 & q2147_3>`year' & q2147_3!=. & q2147_3!=9998 & q2147_2<=`year' & q2147_2!=. & q2147_2!=9998

replace gov_`year'=q2145_gov_3 if q2143==3 & q2147_3<=`year' & q2147_3!=. & q2147_3!=9998
replace gov_`year'=q2145_gov_3 if q2144_3==2 & q2147_4>`year' & q2147_4!=. & q2147_4!=9998 & q2147_3<=`year' & q2147_3!=. & q2147_3!=9998

replace gov_`year'=q2145_gov_4 if q2143==4 & q2147_4<=`year' & q2147_4!=. & q2147_4!=9998
replace gov_`year'=q2145_gov_4 if q2144_4==2 & q2147_5>`year' & q2147_5!=. & q2147_5!=9998 & q2147_4<=`year' & q2147_4!=. & q2147_4!=9998

replace gov_`year'=q2145_gov_5 if q2143==5 & q2147_5<=`year' & q2147_5!=. & q2147_5!=9998
replace gov_`year'=q2145_gov_5 if q2144_5==2 & q2147_6>`year' & q2147_6!=. & q2147_6!=9998 & q2147_5<=`year' & q2147_5!=. & q2147_5!=9998

replace gov_`year'=q2145_gov_6 if q2143==6 & q2147_6<=`year' & q2147_6!=. & q2147_6!=9998
replace gov_`year'=q2145_gov_6 if q2144_6==2 & q2147_7>`year' & q2147_7!=. & q2147_7!=9998 & q2147_6<=`year' & q2147_6!=. & q2147_6!=9998

replace gov_`year'=q2145_gov_7 if q2143==7 & q2147_7<=`year' & q2147_7!=. & q2147_7!=9998
replace gov_`year'=q2145_gov_7 if q2144_7==2 & q2147_8>`year' & q2147_8!=. & q2147_8!=9998 & q2147_7<=`year' & q2147_7!=. & q2147_7!=9998

gen dis_`year'=.

replace dis_`year'=q2139_dis if q2141==2 
replace dis_`year'=q2139_dis if q2141==1 & q2147_1>`year' & q2147_1!=. & q2147_1!=9998

replace dis_`year'=q2145_dis_1 if q2143==1 & q2147_1<=`year' & q2147_1!=. & q2147_1!=9998
replace dis_`year'=q2145_dis_1 if q2147_2>`year' & q2147_2!=. & q2147_2!=9998 & q2147_1<=`year' & q2147_1!=. & q2147_1!=9998

replace dis_`year'=q2145_dis_2 if q2143==2 & q2147_2<=`year' & q2147_2!=. & q2147_2!=9998
replace dis_`year'=q2145_dis_2 if q2144_2==2 & q2147_3>`year' & q2147_3!=. & q2147_3!=9998 & q2147_2<=`year' & q2147_2!=. & q2147_2!=9998

replace dis_`year'=q2145_dis_3 if q2143==3 & q2147_3<=`year' & q2147_3!=. & q2147_3!=9998
replace dis_`year'=q2145_dis_3 if q2144_3==2 & q2147_4>`year' & q2147_4!=. & q2147_4!=9998 & q2147_3<=`year' & q2147_3!=. & q2147_3!=9998

replace dis_`year'=q2145_dis_4 if q2143==4 & q2147_4<=`year' & q2147_4!=. & q2147_4!=9998
replace dis_`year'=q2145_dis_4 if q2144_4==2 & q2147_5>`year' & q2147_5!=. & q2147_5!=9998 & q2147_4<=`year' & q2147_4!=. & q2147_4!=9998

replace dis_`year'=q2145_dis_5 if q2143==5 & q2147_5<=`year' & q2147_5!=. & q2147_5!=9998
replace dis_`year'=q2145_dis_5 if q2144_5==2 & q2147_6>`year' & q2147_6!=. & q2147_6!=9998 & q2147_5<=`year' & q2147_5!=. & q2147_5!=9998

replace dis_`year'=q2145_dis_6 if q2143==6 & q2147_6<=`year' & q2147_6!=. & q2147_6!=9998
replace dis_`year'=q2145_dis_6 if q2144_6==2 & q2147_7>`year' & q2147_7!=. & q2147_7!=9998 & q2147_6<=`year' & q2147_6!=. & q2147_6!=9998

replace dis_`year'=q2145_dis_7 if q2143==7 & q2147_7<=`year' & q2147_7!=. & q2147_7!=9998
replace dis_`year'=q2145_dis_7 if q2144_7==2 & q2147_8>`year' & q2147_8!=. & q2147_8!=9998 & q2147_7<=`year' & q2147_7!=. & q2147_7!=9998

gen subdis_`year'=.

replace subdis_`year'=q2139_subdis if q2141==2 
replace subdis_`year'=q2139_subdis if q2141==1 & q2147_1>`year' & q2147_1!=. & q2147_1!=9998

replace subdis_`year'=q2145_subdis_1 if q2143==1 & q2147_1<=`year' & q2147_1!=. & q2147_1!=9998
replace subdis_`year'=q2145_subdis_1 if q2147_2>`year' & q2147_2!=. & q2147_2!=9998 & q2147_1<=`year' & q2147_1!=. & q2147_1!=9998

replace subdis_`year'=q2145_subdis_2 if q2143==2 & q2147_2<=`year' & q2147_2!=. & q2147_2!=9998
replace subdis_`year'=q2145_subdis_2 if q2144_2==2 & q2147_3>`year' & q2147_3!=. & q2147_3!=9998 & q2147_2<=`year' & q2147_2!=. & q2147_2!=9998

replace subdis_`year'=q2145_subdis_3 if q2143==3 & q2147_3<=`year' & q2147_3!=. & q2147_3!=9998
replace subdis_`year'=q2145_subdis_3 if q2144_3==2 & q2147_4>`year' & q2147_4!=. & q2147_4!=9998 & q2147_3<=`year' & q2147_3!=. & q2147_3!=9998

replace subdis_`year'=q2145_subdis_4 if q2143==4 & q2147_4<=`year' & q2147_4!=. & q2147_4!=9998
replace subdis_`year'=q2145_subdis_4 if q2144_4==2 & q2147_5>`year' & q2147_5!=. & q2147_5!=9998 & q2147_4<=`year' & q2147_4!=. & q2147_4!=9998

replace subdis_`year'=q2145_subdis_5 if q2143==5 & q2147_5<=`year' & q2147_5!=. & q2147_5!=9998
replace subdis_`year'=q2145_subdis_5 if q2144_5==2 & q2147_6>`year' & q2147_6!=. & q2147_6!=9998 & q2147_5<=`year' & q2147_5!=. & q2147_5!=9998

replace subdis_`year'=q2145_subdis_6 if q2143==6 & q2147_6<=`year' & q2147_6!=. & q2147_6!=9998
replace subdis_`year'=q2145_subdis_6 if q2144_6==2 & q2147_7>`year' & q2147_7!=. & q2147_7!=9998 & q2147_6<=`year' & q2147_6!=. & q2147_6!=9998

replace subdis_`year'=q2145_subdis_7 if q2143==7 & q2147_7<=`year' & q2147_7!=. & q2147_7!=9998
replace subdis_`year'=q2145_subdis_7 if q2144_7==2 & q2147_8>`year' & q2147_8!=. & q2147_8!=9998 & q2147_7<=`year' & q2147_7!=. & q2147_7!=9998

gen locality_`year'=.

replace locality_`year'=q2139_locality if q2141==2 
replace locality_`year'=q2139_locality if q2141==1 & q2147_1>`year' & q2147_1!=. & q2147_1!=9998

replace locality_`year'=q2145_locality_1 if q2143==1 & q2147_1<=`year' & q2147_1!=. & q2147_1!=9998
replace locality_`year'=q2145_locality_1 if q2147_2>`year' & q2147_2!=. & q2147_2!=9998 & q2147_1<=`year' & q2147_1!=. & q2147_1!=9998

replace locality_`year'=q2145_locality_2 if q2143==2 & q2147_2<=`year' & q2147_2!=. & q2147_2!=9998
replace locality_`year'=q2145_locality_2 if q2144_2==2 & q2147_3>`year' & q2147_3!=. & q2147_3!=9998 & q2147_2<=`year' & q2147_2!=. & q2147_2!=9998

replace locality_`year'=q2145_locality_3 if q2143==3 & q2147_3<=`year' & q2147_3!=. & q2147_3!=9998
replace locality_`year'=q2145_locality_3 if q2144_3==2 & q2147_4>`year' & q2147_4!=. & q2147_4!=9998 & q2147_3<=`year' & q2147_3!=. & q2147_3!=9998

replace locality_`year'=q2145_locality_4 if q2143==4 & q2147_4<=`year' & q2147_4!=. & q2147_4!=9998
replace locality_`year'=q2145_locality_4 if q2144_4==2 & q2147_5>`year' & q2147_5!=. & q2147_5!=9998 & q2147_4<=`year' & q2147_4!=. & q2147_4!=9998

replace locality_`year'=q2145_locality_5 if q2143==5 & q2147_5<=`year' & q2147_5!=. & q2147_5!=9998
replace locality_`year'=q2145_locality_5 if q2144_5==2 & q2147_6>`year' & q2147_6!=. & q2147_6!=9998 & q2147_5<=`year' & q2147_5!=. & q2147_5!=9998

replace locality_`year'=q2145_locality_6 if q2143==6 & q2147_6<=`year' & q2147_6!=. & q2147_6!=9998
replace locality_`year'=q2145_locality_6 if q2144_6==2 & q2147_7>`year' & q2147_7!=. & q2147_7!=9998 & q2147_6<=`year' & q2147_6!=. & q2147_6!=9998

replace locality_`year'=q2145_locality_7 if q2143==7 & q2147_7<=`year' & q2147_7!=. & q2147_7!=9998
replace locality_`year'=q2145_locality_7 if q2144_7==2 & q2147_8>`year' & q2147_8!=. & q2147_8!=9998 & q2147_7<=`year' & q2147_7!=. & q2147_7!=9998

gen loc_code_`year'=string(gov_`year', "%02.0f")+string(dis_`year', "%02.0f")+string(subdis_`year', "%01.0f")+string(locality_`year', "%03.0f")

}
 
 
 
keep lm_* formal*  man_prof_* usecactp_comp_*  usecactp_hhs_* in_jo_* uspriv_* indid loc_code_*

save "$data_Fallah_temp/JLMPS 2016 annualized.dta", replace
 
*Stat 2010 vs. current loc_code

count if loc_code_2010!=loc_code_2016
count
 
*Keep 2010 loc_code

keep indid loc_code_2010

gen dis_code_2010=substr(loc_code_2010,1,5)

save "$data_Fallah_temp/JLMPS 2016 loc_code in 2010.dta", replace 


****************
*Merging into JLMPS
****************

use "$data_JLMPS_base/JLMPS 2016 xs v1.1.dta", clear

*Jordanians only
keep if nationality==400

*Adults only
keep if age>=15

*Merging work history

merge 1:1 indid using "$data_Fallah_temp/JLMPS 2016 annualized.dta"

tabu _merge
drop _merge

*Stats on transitions

tabu lm_2010 lm_2016 if age<=64 [aw=expan_indiv], row nofreq

*Keep only covariates of interest

keep indid sex brthyr educ1d gov urban ftempst fteduc mteduc ftocp1d expan_indiv evrwrk lm_* ///
   loc_code_* formal_*  man_prof_* in_jo_* usecactp_comp_* usecactp_hhs_* ///
 uspriv* loc_code_*

gen loc_code=loc_code_2010



 
*Reshape

reshape long lm_@ formal_@ man_prof_@ in_jo_@ usecactp_comp_@ usecactp_hhs_@ ///
uspriv_@ loc_code_@, i(indid) j(year)

*Need to keep 15-64 in year, in jordan

gen age_inyr=year-brthyr

keep if age_inyr>=15 & age_inyr<=64

keep if in_jo==1
keep if loc_code!="...."

set scheme s1mono

*Check data quality
tabu year lm_ if sex==1 [aw=expan_indiv], row nofreq
tabu year lm_ if sex==2 [aw=expan_indiv], row nofreq


*Pre v. post
gen post=0
replace post=1 if year>=2011


tabu lm_, gen(lm_)

gen ed_high=. 
replace ed_high=0 if educ1d>=1 & educ1d<=3
replace ed_high=1 if educ1d>=4 & educ1d<=7

tabu ed_high educ1d, miss

*Merging on 2010 locality
destring loc_code, gen(ds_loc_code)

merge m:1 loc_code using "$data_Fallah_base/Nationality all v1.dta"

tabu _merge

keep if _merge==3

drop _merge 

foreach var of varlist prop_* {
replace `var'=`var'*100
}

save "$data_Fallah_final/JLMPS 2016 long.dta", replace



******************************
*Distance from Camps/Amman
******************************

import excel "$data_Fallah_base/Location Codes Arabic 2015 revised 1.19.16 (for 2016) Google for import.xls", sheet("Distance to locakity") firstrow clear

drop H-L

destring gov district subdistrict locality, replace

gen loc_code=string(gov, "%02.0f")+string(district, "%02.0f")+string(subdistrict, "%01.0f")+string(locality, "%03.0f")

duplicates drop

rename Amman Amman

foreach var of varlist ZataariCamp AzraqCamp Amman {

egen subd_mean_`var'=mean(`var'), by(gov district subdistrict)

replace `var'=subd_mean_`var' if `var'==.

}



merge m:1 loc_code using "$data_Fallah_base/Nationality all v1.dta"

drop _merge

save "$data_Fallah_final/IV data.dta", replace




**********************
* MERGE TO LSMS DATA *
**********************


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


