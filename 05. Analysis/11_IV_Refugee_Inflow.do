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
                





















                                  ************
                                  *REGRESSION*
                                  ************


            ***********************************************************************
              ***** M2: YEAR FE / DISTRICT FE / IVs Nb Refugees    *****
            ***********************************************************************

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
*gen ref_2016_total = 513032
gen IV_Ref_NETW = tot_nb_ref_2016 * pct_hh_syr_eg_2004
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
gen IV_WP_NETW = wp_2016_total * pct_hh_syr_eg_2004
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
*reference period 7 days, defined as share of WAP that is employed  
tab crwrkstsr1 // From crwrkstsr1 - mkt def, search req; 7d, 2 empl - 1 unemp&OLF
codebook crwrkstsr1
gen employed_olf_7d = 0 if crwrkstsr1 == 2 | crwrkstsr1 == 3 
replace employed_olf_7d = 1 if crwrkstsr1 == 1
tab employed_olf_7d 
lab def employed_olf_7d 0 "Unemployed OLF" 1 "Employed", modify 
lab var employed_olf_7d employed_olf_7d

*Wage from main job (ln): 
*7 days reference period – on employed only 
tab mnthwg , m 

      *Corrected from inflation
      gen rmthly_wage_main = mnthwg / CPIin17
      lab var rmthly_wage_main "CORRECTED INFLATION - Monthly Wage primary job"

      *LN: Conditional wage: EMPLOYED ONLY
      gen ln_rmthly_wage_main = ln(1+rmthly_wage_main) 
      lab var ln_rmthly_wage_main "LOG Monthly Wage primary job - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING"


*Hourly wage (ln): 
*7 days reference period – on employed only 
tab hrwg , m 

      *Corrected from inflation
      gen rhourly_wage_main = hrwg / CPIin17
      lab var rhourly_wage_main "CORRECTED INFLATION - Hourly Wage primary job"

      *LN: Conditional wage: EMPLOYED ONLY
      gen ln_rhourly_wage_main = ln(1+rhourly_wage_main) 
      lab var ln_rhourly_wage_main "LOG Hourly Wage primary job - CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING"


*Work hours per week: 
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

global dep_var_ref  ln_prop_hh_syrians
global iv_ref       ln_IV_Ref_NETW

global dep_var_wp ln_agg_wp_orig
global iv_wp      IV_WP_DIST

global outcomes_uncond employed_olf_7d unemployed_olf_7d ///
                lfp_3m_empl ///
                lfp_3m_temp ///
                lfp_3m_employer ///
                lfp_3m_se ///
                lfp_3m_unpaid

global outcomes_cond ln_rmthly_wage_main ln_rhourly_wage_main ///
                wh_pw_7d_w formal 

global controls age age2 gender 

global heterogenous gender urb_rural_camps lfp_3m bi_education




use "$data_final/07_IV_Ref_WP.dta", clear

tab ln_prop_hh_syrians year 
tab ln_IV_Ref_NETW year 


*tab IV_Ref_DIST 
corr prop_hh_syrians  IV_Ref_NETW
*corr prop_hh_syrians  IV_Ref_DIST

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
distinct indid_2010 
duplicates tag indid_2010, gen(dup)
bys year: tab dup
drop if dup == 0
drop dup
tab year

xtset, clear 
xtset indid_2010 year 

              *******************
              * REFUGEE INFLOW  *
              *******************

**** OLS *****
  foreach outcome of global outcomes_uncond {
    qui xi: reg `outcome' $dep_var_ref ///
             i.district_iid i.year $controls ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout m_employed_olf_7d m_unemployed_olf_7d m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  /// 
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) F(par fmt(%9.3f))) ///
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
esttab m_employed_olf_7d m_unemployed_olf_7d m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid   /// 
      using "$out_analysis/REF_reg_OLS_Uncond_FE_DIS_YEAR.tex", se label replace booktabs ///
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
   title("REF - Results OLS Regression with time and district FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_employed_olf_7d m_unemployed_olf_7d m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  
************



*** IV ***
 foreach outcome of global outcomes_uncond {
      xi: ivreg2  `outcome' i.year i.district_iid $controls ///
                ($dep_var_ref = $iv_ref) ///
                [pweight = panel_wt_10_16], ///
                cluster(locality_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var_ref) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout m_employed_olf_7d m_unemployed_olf_7d m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres rkf))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_employed_olf_7d m_unemployed_olf_7d m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid /// 
      using "$out_analysis/REF_reg_IV_Uncond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Employed" "Unemployed" "LFP Employee" "LFP Temp" "LFP Employer" "LFP SE" "LFP Unpaid") ///
  drop(age age2 gender _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - Results IV with District and Year FE - UNCOND"\label{tab1}) nofloat ///
   stats(N r2_a rkf, labels("Obs" "Adj. R-Squared" "KP Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_employed_olf_7d m_unemployed_olf_7d m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid  

*m2 m3 m4 m5 
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

*** OLS ***
  foreach outcome of global outcomes_cond {
    qui xi: reg `outcome' $dep_var_ref ///
             i.district_iid i.year $controls ///
            [pweight = panel_wt_10_16],  ///
            cluster(district_iid) robust 
    codebook `outcome', c
    estimates table, k($dep_var_ref) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout m_ln_rmthly_wage_main m_ln_rhourly_wage_main m_wh_pw_7d_w ///
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
esttab m_ln_rmthly_wage_main m_ln_rhourly_wage_main m_wh_pw_7d_w ///
         m_formal   /// 
      using "$out_analysis/REF_reg_OLS_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Mthly Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
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
   title("REF - Results OLS Regression with time and district FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a, labels("Obs" "Adj. R-Squared")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_ln_rmthly_wage_main m_ln_rhourly_wage_main m_wh_pw_7d_w ///
         m_formal  

*** IV ***
cls
 foreach outcome of global outcomes_cond {
      xi: ivreg2  `outcome'  i.year i.district_iid $controls ///
                ($dep_var_ref = $iv_ref) ///
                [pweight = panel_wt_10_16], ///
                cluster(locality_iid) robust ///
                partial(i.district_iid) ///
                first
    codebook `outcome', c
    estimates table, k($dep_var_ref) star(.1 .05 .01) b(%7.4f) 
    estimates table, b(%7.4f) se(%7.4f) stats(N r2_a) k($dep_var_ref) 
    estimates store m_`outcome', title(Model `outcome')
  }

ereturn list
mat list e(b)
estout m_ln_rmthly_wage_main m_ln_rhourly_wage_main m_wh_pw_7d_w ///
         m_formal  ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres KP-Stat))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_ln_rmthly_wage_main m_ln_rhourly_wage_main m_wh_pw_7d_w ///
         m_formal  /// 
      using "$out_analysis/REF_reg_IV_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Mthly Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
  drop(age age2 gender _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("REF - Results IV with District and Year FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a rkf, labels("Obs" "Adj. R-Squared" "KP Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_ln_rmthly_wage_main m_ln_rhourly_wage_main m_wh_pw_7d_w ///
         m_formal 















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
estout m_employed_olf_7d m_unemployed_olf_7d m_lfp_3m_empl ///
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
esttab m_employed_olf_7d m_unemployed_olf_7d m_lfp_3m_empl ///
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

estimates drop m_employed_olf_7d m_unemployed_olf_7d m_lfp_3m_empl ///
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
estout m_employed_olf_7d m_unemployed_olf_7d m_lfp_3m_empl ///
         m_lfp_3m_temp m_lfp_3m_employer m_lfp_3m_se m_lfp_3m_unpaid ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres KP-Stat))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_employed_olf_7d m_unemployed_olf_7d m_lfp_3m_empl ///
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

estimates drop m_employed_olf_7d m_unemployed_olf_7d m_lfp_3m_empl ///
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

  foreach outcome of global outcomes_cond {
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
estout m_ln_rmthly_wage_main m_ln_rhourly_wage_main m_wh_pw_7d_w ///
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
esttab m_ln_rmthly_wage_main m_ln_rhourly_wage_main m_wh_pw_7d_w ///
         m_formal   /// 
      using "$out_analysis/WP_reg_OLS_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Mthly Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
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

estimates drop m_ln_rmthly_wage_main m_ln_rhourly_wage_main m_wh_pw_7d_w ///
         m_formal  


cls
 foreach outcome of global outcomes_cond {
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
estout m_ln_rmthly_wage_main m_ln_rhourly_wage_main m_wh_pw_7d_w ///
         m_formal  ///
      , cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
  drop(age age2 gender _Iyear_2016 ///
         $controls)   ///
   legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)           ///
   stats(r2 df_r rkf, fmt(3 0 1) label(R-sqr dfres KP-Stat))

*** (**) [*] indicates significance at the 99%
*(95%) [90%] level. Based

*erase "$out/reg_infra_access.tex"
esttab m_ln_rmthly_wage_main m_ln_rhourly_wage_main m_wh_pw_7d_w ///
         m_formal  /// 
      using "$out_analysis/WP_reg_IV_Cond_FE_DIS_YEAR.tex", se label replace booktabs ///
      cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) ///
mtitles("Mthly Wage (ln)" "Hrly Wage (ln)" "Work Hours p.w." "Formal") ///
  drop(age age2 gender _Iyear_2016 ///
         $controls) starlevels(* 0.1 ** 0.05 *** 0.01) ///
   title("WP - Results IV with District and Year FE - COND"\label{tab1}) nofloat ///
   stats(N r2_a rkf, labels("Obs" "Adj. R-Squared" "KP-Stat")) ///
    nonotes ///
    addnotes("Standard errors clustered at the district level. Significance levels: *p $<$ 0.1, ** p $<$ 0.05, *** p $<$ 0.01") 

estimates drop m_ln_rmthly_wage_main m_ln_rhourly_wage_main m_wh_pw_7d_w ///
         m_formal 











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
