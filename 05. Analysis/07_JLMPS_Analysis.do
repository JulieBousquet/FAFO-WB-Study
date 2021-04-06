

cap log close
clear all
set more off, permanently
set mem 100m

*log using "$analysis_do/01_Data_Cleaning_EL1.log", replace

	****************************************************************************
	**                            DATA IV CREATION                            **  
	** ---------------------------------------------------------------------- **
	** Type Do  : 	DATA IV JLMPS                                              **
  	**                                                                        **
	** Authors  : Julie Bousquet                                              **
	****************************************************************************

*JLMPS IV

/*
.a Non applicable (99)
.b Don't know (98)
*/

*Dictiornnary of geo unit Jordan as of 2015
import excel "$data_JLMPS_base/Location Codes Arabic 2015 revised 1.19.16 (for 2016).xlsx", firstrow clear
drop SubDistrict SubDistrictID Localities LocalitiesID
duplicates drop district_en, force 
tab district_en 
destring governorate district_id, replace 
sort governorate district_id
save "$data_JLMPS_temp/JLMPS_GeoUnits_Dico.dta", replace


*DATA 2016 ONLY
use "$data_JLMPS_base/JLMPS 2016 xs v1.1.dta", clear 

tab gov 
codebook gov
lab list Lgov

bys gov: tab district, m 

ren gov governorate
ren district district_id
sort governorate district_id

merge m:1 governorate district_id using "$data_JLMPS_temp/JLMPS_GeoUnits_Dico.dta"
drop _merge 

tab q11207

/*
q11207. Do you |
 have a permit |
    to work in |
       Jordan? |      Freq.     Percent        Cum.
---------------+-----------------------------------
           Yes |        309       17.14       17.14
            No |      1,022       56.68       73.82
Not Applicable |        472       26.18      100.00
---------------+-----------------------------------
         Total |      1,803      100.00
*/
bys forced_migr: tab  q11207

/*
q11207. Do you |
 have a permit |
    to work in |
       Jordan? |      Freq.     Percent        Cum.
---------------+-----------------------------------
           Yes |        134        9.36        9.36
            No |        880       61.45       70.81
Not Applicable |        418       29.19      100.00
---------------+-----------------------------------
         Total |      1,432      100.00
*/

bys nationality_cl: tab  q11207

/*
q11207. Do you |
 have a permit |
    to work in |
       Jordan? |      Freq.     Percent        Cum.
---------------+-----------------------------------
           Yes |        122        9.33        9.33
            No |        786       60.09       69.42
Not Applicable |        400       30.58      100.00
---------------+-----------------------------------
         Total |      1,308      100.00
*/



tab  district_en
sort district_en
egen district_iid = group(district_en) 

tab governorate_en
sort governorate_en
egen governorate_iid = group(governorate_en)

gen year = round 
tab year

/*
       year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2016 |     33,450      100.00      100.00
------------+-----------------------------------
      Total |     33,450      100.00

*/ 

save "$data_JLMPS_final/01_JLMPS_16_xs_clear.dta", replace



*USE LSMS 2016 & LSMS 2010
use "$data_JLMPS_base/JLMPS 2016 rep xs v1.1.dta", clear 


tab gov 
codebook gov
lab list Lgov

bys gov: tab district, m 

ren gov governorate
ren district district_id
sort governorate district_id

merge m:1 governorate district_id using "$data_JLMPS_temp/JLMPS_GeoUnits_Dico.dta"
drop _merge 

tab  district_en
sort district_en
egen district_iid = group(district_en) 

tab governorate_en
sort governorate_en
egen governorate_iid = group(governorate_en)

gen year = round 
tab year 

/*
       year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2010 |     25,953       43.69       43.69
       2016 |     33,450       56.31      100.00
------------+-----------------------------------
      Total |     59,403      100.00
*/

save "$data_JLMPS_final/02_JLMPS_10_16_rep_xs_clear.dta", replace


use "$data_JLMPS_final/01_JLMPS_16_xs_clear.dta", clear

*q11207: Do you have a permit to work in Jordan?
*Apply to All individuals 15-59 years old who are neither Jordanian (nationality) 
*nor born in Jordan,  i.e. NOT Jordanian in Q207 and not in Jordan (=2) in Q2138

*Additional interesting variables: MODULE 11.2 MIGRATION
*q11201a q11201b q11202 q11203 q11204a q11204b q11205 q11206 
*q11208a q11208b q11212 q11213 q11214

*Work Permit 
tab q11207
*Understanding the NON APPLICABLE OPTION in work permit variable.
*"NA (do not work)" is specified in Q. 
*Check that
tab q11207 evrwrk 
*384 have never worked
bys sex: tab q11207 evrwrk 
*100 male and 284 female
tab brthyr
tab age
preserve
drop if age < 15 | age >59
tab age q11207  
restore 
*Larger proprtion of individual below 30 are in the "non applicable" category
tab q11207 q5301 
*449 did not get any employment in the last 3 months.
*But also only 17 have a work permit AND worked in the last 3 months
tab q11207 q5303
tab q11207 q5304
tab q11207 q6137
*Most are wage workers (204 wiht WP and 154 without WP 21 NA)
bys nationality_cl: tab q11207 q6145
tab q11207 nationality_cl
preserve
drop if nationality_cl != 2
tab q11207 , m
restore


*EMPLOYED: YES TO q5101, q5102, q5103, q5301, q5302 
codebook q5101 // 1 Yes 2 No 98 DK
tab q5101, m //Employed in last 7 days
tab q5102, m //Employed but temp absent
tab q5103_01, m //
tab q5103_02, m //
tab q5103_03, m //
tab q5103_04, m //
tab q5103_05, m //
tab q5103_06, m //
tab q5103_07, m //
tab q5103_08, m //
tab q5103_09, m //
tab q5103_10, m //
tab q5103_11, m //
tab q5103_12, m //
tab q5103_13, m //
tab q5301, m //Any empl last 3 month 
tab q5302_01, m //
tab q5302_02, m //
tab q5302_03, m //
tab q5302_04, m //
tab q5302_05, m //
tab q5302_06, m //
tab q5302_07, m //
tab q5302_08, m //
tab q5302_09, m //
tab q5302_10, m //
tab q5302_11, m //
tab q5302_12, m //
tab q5302_13, m //
gen employed = 1 if q5101 == 1 | q5102 == 1 | q5301 == 1 
replace employed = 0 if q5101 == 2 | q5102 == 2 | q5301 == 2 
replace employed = .b if q5101 == 98 | q5102 == 98 | q5301 == 98 
tab employed, m
lab def yesnodk 0 "No" 1 "Yes" .b "Don't know", modify
lab val employed yesnodk
tab employed, m

*Industry
/*
a. agricultural work (e.g., harvesting, cutting clover, irrigation)		
b. raising poultry/livestock 		
c. producing ghee/cheese/butter		
d. preparing food/vegetables		
e. producing straw products/carpets/textile/ropes		
f. offering part-time services for others in a house/shop/hotel		
g. street seller		
h. construction worker		
i. collecting fuel/woodcutting		
j. sewing/embroidery/crochet		
k. sales & marketing		
l. trainee/apprentice		
m. working from home (IT programmers, etc.)	
*/

*Can you have worked in 2 differnt industry? 
gen flag = 1 if q5103_02 == 1 & ( q5103_01 == 1 | q5103_03 == 1 )
tab flag, m 
drop flag
*YES ! 
gen industry_en = ""

gen ind_agri 			= "Agriculture" 	 			if q5103_01 == 1 | q5302_01 == 1 
gen ind_livestock		= "Rasing Livestock" 			if q5103_02 == 1 | q5302_02 == 1 
gen ind_prod_milk		= "Produce Milk-Based Products" if q5103_03 == 1 | q5302_03 == 1 
gen ind_prod_food		= "Produce Food Products" 		if q5103_04 == 1 | q5302_04 == 1 
gen ind_prod_textile	= "Produce Textile" 			if q5103_05 == 1 | q5302_05 == 1 
gen ind_services		= "Services" 					if q5103_06 == 1 | q5302_06 == 1 
gen ind_street_seller	= "Street Seller" 				if q5103_07 == 1 | q5302_07 == 1 
gen ind_construction	= "Construction" 				if q5103_08 == 1 | q5302_08 == 1 
gen ind_coll_fuel		= "Collect Fuel" 				if q5103_09 == 1 | q5302_09 == 1 
gen ind_sew				= "Sewing" 						if q5103_10 == 1 | q5302_10 == 1 
gen ind_sales			= "Sales and Marketing" 		if q5103_11 == 1 | q5302_11 == 1 
gen ind_trainee			= "Trainee" 					if q5103_12 == 1 | q5302_12 == 1 
gen ind_home			= "Work From Home (IT, etc)" 	if q5103_13 == 1 | q5302_13 == 1 

/*
replace industry_en = "transportation" if industry_id == 5 
replace industry_en = "banking" if industry_id == 6 
*/

*Harmonize the industries based on the classification for the IV
*Aggregate several categories
gen agg_ind_agri 		= "Agriculture" 	if ind_agri == "Agriculture" | ///
											   ind_livestock == "Rasing Livestock" | ///
											   ind_prod_milk == "Produce Milk-Based Products" | ///
											   ind_prod_food == "Produce Food Products" 
gen agg_ind_industry 	= "Industry"		if ind_prod_textile == "Produce Textile" | ///
											   ind_coll_fuel == "Services"  
gen agg_ind_construction = "Construction"	if ind_construction == "Street Seller" 
gen agg_ind_services	= "Services"		if ind_services == "Construction" | ///
											   ind_home == "Collect Fuel"  | ///
											   ind_sew == "Sewing" | ///
											   ind_sales == "Sales and Marketing" | ///
											   ind_trainee == "Trainee"
gen agg_ind_food 		= "Food"			if ind_street_seller == "Work From Home (IT, etc)"


*DECISION : 
tab employed, m //YES = 1 
codebook q11207 //WP yes = 1
tab employed q11207

recode q11207 (2=0) (99=.a) , gen(work_permit)
tab work_permit, m
lab def yesnona 0 "No" 1 "Yes" .a "Non Applicable"
lab val work_permit yesnona
*If refugees with NA work (employed = 1), then we will say they do not 
*have a work permit. 
replace work_permit = 0 if q11207 == 99 & employed == 1 & nationality_cl == 2 //Syrians
*If refugees with NA DO NOT work, then we will say missing.
replace work_permit = . if q11207 == 99 & employed == 0 & nationality_cl == 2 //Syrians
tab work_permit

keep 	indid district_iid governorate_iid work_permit nationality_cl forced_migr ///
		q11201a q11201b q11202 q11203 q11204a q11204b q11205 q11206 ///
		q11208a q11208b q11212 q11213 q11214 employed


merge 1:1 indid using "$data_JLMPS_final/02_JLMPS_10_16_rep_xs_clear.dta"

tab year, m
tab _merge year
drop _merge 
tab governorate_iid , m
tab district_iid , m
tab nationality_cl, m 
/*
Nationality |
      (five |
categories) |      Freq.     Percent        Cum.
------------+-----------------------------------
  Jordanian |     53,094       89.38       89.38
     Syrian |      3,003        5.06       94.43
   Egyptian |        623        1.05       95.48
 Other Arab |      2,551        4.29       99.78
      Other |        132        0.22      100.00
------------+-----------------------------------
      Total |     59,403      100.00
*/
tab forced_migr, m 
/*
     Forced |
    migrant |
  household |      Freq.     Percent        Cum.
------------+-----------------------------------
         No |     28,471       47.93       47.93
        Yes |      4,979        8.38       56.31
          . |     25,953       43.69      100.00
------------+-----------------------------------
      Total |     59,403      100.00
*/

tab nationality_cl forced_migr
/*
Nationalit |
   y (five |    Forced migrant
categories |       household
         ) |        No        Yes |     Total
-----------+----------------------+----------
 Jordanian |    26,875      1,523 |    28,398 
    Syrian |        65      2,853 |     2,918 
  Egyptian |       322          0 |       322 
Other Arab |     1,099        600 |     1,699 
     Other |       110          3 |       113 
-----------+----------------------+----------
     Total |    28,471      4,979 |    33,450 
*/
bys year: tab nationality_cl 
bys year: tab nationality_cl forced_migr

tab forced_migr_2011, m

codebook forced_migr //1 yes
codebook nationality_cl //2 Syrian

*Harmonize 2010 and 2016
*Natives (label 1) are not forced migrants
replace forced_migr = 0 if nationality_cl == 1 & year == 2010

*In 2016: 65 hh Syrians are NOT forced migrant.
*There were not refugees in 2010 datasets, just a few Syrians.
*I say that a Syrian in 2010 is not a forced migrant
replace forced_migr = 0 if nationality_cl == 2 & year == 2010
*only 85 syrians in 2010

* Egyptians (label 3) are not forced migrants
replace forced_migr = 0 if nationality_cl == 3 & year == 2010

*but there are two more categories
* "others" (laber 4) and "other arab" (label 5). 
replace forced_migr = 0 if nationality_cl == 4 & year == 2010
replace forced_migr = 0 if nationality_cl == 5 & year == 2010


*SIMILAR PROCEDURE FOR THE VARIABLE IN 2011

tab forced_migr_2011, m
codebook forced_migr_2011 //1 yes
replace forced_migr_2011 = 0 if nationality_cl == 1 & year == 2010
replace forced_migr_2011 = 0 if nationality_cl == 2 & year == 2010
replace forced_migr_2011 = 0 if nationality_cl == 3 & year == 2010
replace forced_migr_2011 = 0 if nationality_cl == 4 & year == 2010
replace forced_migr_2011 = 0 if nationality_cl == 5 & year == 2010

*In nationality_cl: we may want to keep 1 natives and 2 syrians  
*keep if nationality_cl == 1 | nationality_cl == 2 

*WORK PERMIT 
codebook work_permit // 2 = No , 1 = Yes , 99 = NA
bys nationality_cl: tab work_permit, m
*144 Egyptians have a WP 
*29  Other Arabs have a WP 
*14  Other have a WP  

*No work permits in 2010: put to missing 
replace work_permit = . if mi(work_permit) & round == 2010 
tab work_permit year , m 

tab  nationality_cl work_permit  if year == 2016 
tab work_permit, m

*Why NON APPLICABLE ? Should be 0/1/or missing?

bys year: tab governorate_en, m
bys year: tab district_en, m

*save "$data_JLMPS_final/JLMPS_2010-2016.dta", replace
save "$data_final/02_JLMPS_10_16.dta", replace














******** IV **********

	****************************************************************************
	**                            DATA IV CREATION                            **  
	****************************************************************************


*****************************
**** SHARE EMPLOYEMENT ******
*****************************

/*
*Number of syrians employed in Y industry in Syria pre crisis in each gov
*/
import excel "$data_LFS_base/Workers distribution by governorate.xlsx", clear firstrow sheet("Workers by gov, industries, tot")

tab Governorates
ren Governorates governorate_syria
tab governorate_syria
replace governorate_syria = "Al Raqqah" if governorate_syria == "AL-Rakka"
replace governorate_syria = "Al Suwayda" if governorate_syria == "AL-Sweida"
replace governorate_syria = "Daraa" if governorate_syria == "Dar'a"
replace governorate_syria = "Deir El Zour" if governorate_syria == "Deir-ez-Zor"
replace governorate_syria = "Idlib" if governorate_syria == "Idleb"
replace governorate_syria = "Rural Damascus" if governorate_syria == "Damascus Rural"
replace governorate_syria = "Al Hasakah" if governorate_syria == "AL-Hasakeh"

drop if governorate_syria == "Total"

list governorate_syria 

sort governorate_syria 
gen id_gov_syria = _n
list id_gov_syria governorate_syria

ren Total total
ren Agricultureandforestry agriculture 
ren Industry factory 
ren Buildingandconstruction construction 
ren Hotelsandrestaurantstrade trade 
ren Transportationstoragecommun transportation 
ren Moneyinsuranceandrealestat banking 
ren Services services 

gen share_agriculture = agriculture / total
gen share_factory = factory / total
gen share_construction = construction / total
gen share_trade = trade / total
gen share_transportation = transportation / total
gen share_banking = banking / total
gen share_services = services / total

ren total total_empl_syr

drop agriculture factory construction trade transportation banking services 
drop total_empl_syr
ren share_agriculture share_1 
ren share_factory share_2
ren share_construction share_3 
ren share_trade share_4
ren share_transportation share_5
ren share_banking share_6 
ren share_services share_7

reshape long share_ , i(id_gov_syria) j(industry_id)
gen industry_en = ""
replace industry_en = "agriculture" if industry_id == 1 
replace industry_en = "industry" if industry_id == 2 
replace industry_en = "construction" if industry_id == 3 
replace industry_en = "food" if industry_id == 4 
replace industry_en = "transportation" if industry_id == 5 
replace industry_en = "banking" if industry_id == 6 
replace industry_en = "services" if industry_id == 7 
ren share_ share 

*Sum by Syrian gov == 1 

save "$data_LFS_final/LFS_Syr_Empl_Share_Indus.dta", replace

/*
Distance between Syrian governoarate (fronteer or centroid or largest city?) AND
Jordan district of residence
*/

use "$data_LFS_temp/syr_adm1.dta", clear
  rename id_region _ID 
  merge 1:m _ID using "$data_LFS_temp/syr_coord1.dta"
  egen gov_syria_long = mean(_X), by(_ID)
  egen gov_syria_lat = mean(_Y), by(_ID)
  duplicates drop _ID, force
  ren NAME_1 governorate_syria
  keep gov_syria_long gov_syria_lat governorate

tab governorate_syria
replace governorate_syria = "Al Raqqah" if governorate_syria == "Ar Raqqah"
replace governorate_syria = "Al Suwayda" if governorate_syria == "As Suwayda'"
replace governorate_syria = "Daraa" if governorate_syria == "Dar`a"
replace governorate_syria = "Deir El Zour" if governorate_syria == "Dayr Az Zawr"
replace governorate_syria = "Hama" if governorate_syria == "Hamah"
replace governorate_syria = "Homs" if governorate_syria == "Hims"
replace governorate_syria = "Rural Damascus" if governorate_syria == "Rif Dimashq"
replace governorate_syria = "Al Hasakah" if governorate_syria == "Al Ḥasakah"
replace governorate_syria = "Tartous" if governorate_syria == "Tartus"

list governorate_syria 

sort governorate_syria


*gen id_gov_syria = _n
*list id_gov_syria governorate_syria

*THERE ARE IN TOTAL 51 DISTRICTS 
*I need to run this loop 51 times
*Alshuwnat aljanubia
forvalues x = 1(1)51 {
	preserve
		ren governorate_syria govs_`x'
		ren gov_syria_long govs_long_`x'
		ren gov_syria_lat govs_lat_`x'
		gen id_gov_syria_`x' = `x'
		tempfile district_`x'
		save `district_`x''
	restore
}



use "$data_JLMPS_temp/JLMPS_GeoUnits_Dico.dta", clear

tab district_en, m 
tab district_lat, m
tab district_long, m

keep district_en district_lat district_long



gen id_gov_syria_1 = _n
merge m:m id_gov_syria_1 using `district_1'
drop _merge 
ren id_gov_syria_1 id_gov_syria_2
merge m:m id_gov_syria_2 using `district_2'
drop _merge 
ren id_gov_syria_2 id_gov_syria_3
merge m:m id_gov_syria_3 using `district_3'
drop _merge 
ren id_gov_syria_3 id_gov_syria_4
merge m:m id_gov_syria_4 using `district_4'
drop _merge 
ren id_gov_syria_4 id_gov_syria_5
merge m:m id_gov_syria_5 using `district_5'
drop _merge 
ren id_gov_syria_5 id_gov_syria_6
merge m:m id_gov_syria_6 using `district_6'
drop _merge 
ren id_gov_syria_6 id_gov_syria_7
merge m:m id_gov_syria_7 using `district_7'
drop _merge 
ren id_gov_syria_7 id_gov_syria_8
merge m:m id_gov_syria_8 using `district_8'
drop _merge 
ren id_gov_syria_8 id_gov_syria_9
merge m:m id_gov_syria_9 using `district_9'
drop _merge 
ren id_gov_syria_9 id_gov_syria_10
merge m:m id_gov_syria_10 using `district_10'
drop _merge 
ren id_gov_syria_10 id_gov_syria_11
merge m:m id_gov_syria_11 using `district_11'
drop _merge 
ren id_gov_syria_11 id_gov_syria_12
merge m:m id_gov_syria_12 using `district_12'
drop _merge 
ren id_gov_syria_12 id_gov_syria_13
merge m:m id_gov_syria_13 using `district_13'
drop _merge
ren id_gov_syria_13 id_gov_syria_14
merge m:m id_gov_syria_14 using `district_14'
drop _merge
ren id_gov_syria_14 id_gov_syria_15
merge m:m id_gov_syria_15 using `district_15'
drop _merge
ren id_gov_syria_15 id_gov_syria_16
merge m:m id_gov_syria_16 using `district_16'
drop _merge
ren id_gov_syria_16 id_gov_syria_17
merge m:m id_gov_syria_17 using `district_17'
drop _merge
ren id_gov_syria_17 id_gov_syria_18
merge m:m id_gov_syria_18 using `district_18'
drop _merge
ren id_gov_syria_18 id_gov_syria_19
merge m:m id_gov_syria_19 using `district_19'
drop _merge
ren id_gov_syria_19 id_gov_syria_20
merge m:m id_gov_syria_20 using `district_20'
drop _merge
ren id_gov_syria_20 id_gov_syria_21
merge m:m id_gov_syria_21 using `district_21'
drop _merge
ren id_gov_syria_21 id_gov_syria_22
merge m:m id_gov_syria_22 using `district_22'
drop _merge
ren id_gov_syria_22 id_gov_syria_23
merge m:m id_gov_syria_23 using `district_23'
drop _merge
ren id_gov_syria_23 id_gov_syria_24
merge m:m id_gov_syria_24 using `district_24'
drop _merge
ren id_gov_syria_24 id_gov_syria_25
merge m:m id_gov_syria_25 using `district_25'
drop _merge
ren id_gov_syria_25 id_gov_syria_26
merge m:m id_gov_syria_26 using `district_26'
drop _merge
ren id_gov_syria_26 id_gov_syria_27
merge m:m id_gov_syria_27 using `district_27'
drop _merge
ren id_gov_syria_27 id_gov_syria_28
merge m:m id_gov_syria_28 using `district_28'
drop _merge
ren id_gov_syria_28 id_gov_syria_29
merge m:m id_gov_syria_29 using `district_29'
drop _merge
ren id_gov_syria_29 id_gov_syria_30
merge m:m id_gov_syria_30 using `district_30'
drop _merge
ren id_gov_syria_30 id_gov_syria_31
merge m:m id_gov_syria_31 using `district_31'
drop _merge
ren id_gov_syria_31 id_gov_syria_32
merge m:m id_gov_syria_32 using `district_32'
drop _merge
ren id_gov_syria_32 id_gov_syria_33
merge m:m id_gov_syria_33 using `district_33'
drop _merge
ren id_gov_syria_33 id_gov_syria_34
merge m:m id_gov_syria_34 using `district_34'
drop _merge
ren id_gov_syria_34 id_gov_syria_35
merge m:m id_gov_syria_35 using `district_35'
drop _merge
ren id_gov_syria_35 id_gov_syria_36
merge m:m id_gov_syria_36 using `district_36'
drop _merge
ren id_gov_syria_36 id_gov_syria_37
merge m:m id_gov_syria_37 using `district_37'
drop _merge
ren id_gov_syria_37 id_gov_syria_38
merge m:m id_gov_syria_38 using `district_38'
drop _merge
ren id_gov_syria_38 id_gov_syria_39
merge m:m id_gov_syria_39 using `district_39'
drop _merge
ren id_gov_syria_39 id_gov_syria_40
merge m:m id_gov_syria_40 using `district_40'
drop _merge
ren id_gov_syria_40 id_gov_syria_41
merge m:m id_gov_syria_41 using `district_41'
drop _merge
ren id_gov_syria_41 id_gov_syria_42
merge m:m id_gov_syria_42 using `district_42'
drop _merge
ren id_gov_syria_42 id_gov_syria_43
merge m:m id_gov_syria_43 using `district_43'
drop _merge
ren id_gov_syria_43 id_gov_syria_44
merge m:m id_gov_syria_44 using `district_44'
drop _merge
ren id_gov_syria_44 id_gov_syria_45
merge m:m id_gov_syria_45 using `district_45'
drop _merge
ren id_gov_syria_45 id_gov_syria_46
merge m:m id_gov_syria_46 using `district_46'
drop _merge
ren id_gov_syria_46 id_gov_syria_47
merge m:m id_gov_syria_47 using `district_47'
drop _merge
ren id_gov_syria_47 id_gov_syria_48
merge m:m id_gov_syria_48 using `district_48'
drop _merge
ren id_gov_syria_48 id_gov_syria_49
merge m:m id_gov_syria_49 using `district_49'
drop _merge
ren id_gov_syria_49 id_gov_syria_50
merge m:m id_gov_syria_50 using `district_50'
drop _merge
ren id_gov_syria_50 id_gov_syria_51
merge m:m id_gov_syria_51 using `district_51'
drop _merge


egen governorate_syria = concat(govs_51 govs_50 govs_49 govs_48 govs_47 govs_46 govs_45 govs_44 govs_43 govs_42 govs_41 govs_40 govs_39 govs_38 govs_37 govs_36 govs_35 govs_34 govs_33 govs_32 govs_31 govs_30 govs_29 govs_28 govs_27 govs_26 govs_25 govs_24 govs_23 govs_22 govs_21 govs_20 govs_19 govs_18 govs_17 govs_16 govs_15 govs_14 govs_13 govs_12 govs_11 govs_10 govs_9 govs_8 govs_7 govs_6 govs_5 govs_4 govs_3 govs_2 govs_1)
egen gov_syria_long = rsum(govs_long_51 govs_long_50 govs_long_49 govs_long_48 govs_long_47 govs_long_46 govs_long_45 govs_long_44 govs_long_43 govs_long_42 govs_long_41 govs_long_40 govs_long_39 govs_long_38 govs_long_37 govs_long_36 govs_long_35 govs_long_34 govs_long_33 govs_long_32 govs_long_31 govs_long_30 govs_long_29 govs_long_28 govs_long_27 govs_long_26 govs_long_25 govs_long_24 govs_long_23 govs_long_22 govs_long_21 govs_long_20 govs_long_19 govs_long_18 govs_long_17 govs_long_16 govs_long_15 govs_long_14 govs_long_13 govs_long_12 govs_long_11 govs_long_10 govs_long_9 govs_long_8 govs_long_7 govs_long_6 govs_long_5 govs_long_4 govs_long_3 govs_long_2 govs_long_1)
egen gov_syria_lat = rsum(govs_lat_51 govs_lat_50 govs_lat_49 govs_lat_48 govs_lat_47 govs_lat_46 govs_lat_45 govs_lat_44 govs_lat_43 govs_lat_42 govs_lat_41 govs_lat_40 govs_lat_39 govs_lat_38 govs_lat_37 govs_lat_36 govs_lat_35 govs_lat_34 govs_lat_33 govs_lat_32 govs_lat_31 govs_lat_30 govs_lat_29 govs_lat_28 govs_lat_27 govs_lat_26 govs_lat_25 govs_lat_24 govs_lat_23 govs_lat_22 govs_lat_21 govs_lat_20 govs_lat_19 govs_lat_18 govs_lat_17 govs_lat_16 govs_lat_15 govs_lat_14 govs_lat_13 govs_lat_12 govs_lat_11 govs_lat_10 govs_lat_9 govs_lat_8 govs_lat_7 govs_lat_6 govs_lat_5 govs_lat_4 govs_lat_3 govs_lat_2 govs_lat_1)
tab governorate_syria, m
tab gov_syria_long, m
tab gov_syria_lat, m

keep governorate_syria gov_syria_long gov_syria_lat district_en district_lat district_long

*save "$data_temp/Jordan2020_geo_Syria.dta", replace 
save "$data_temp/03_IV_geo_Syria.dta", replace 










use "$data_temp/03_IV_geo_Syria.dta", clear 

sort governorate_syria district_en
egen id_gov_syria = group(governorate_syria)
gen id_district_jordan = _n 

qui levelsof id_gov_syria, local(gov_lev)
*14
qui levelsof id_district_jordan, local(dis_lev)
*714
qui foreach igov of local gov_lev {
  qui foreach jdis of local dis_lev {
    preserve
    keep if id_gov_syria == `igov'
    keep if id_district_jordan == `jdis'
    tempfile gov_`igov'_dist_`jdis'
    save `gov_`igov'_dist_`jdis''
    restore
  }
}

use "$data_LFS_final/LFS_Syr_Empl_Share_Indus.dta", clear


levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 1(1)51 {
    preserve 
    keep if id_gov_syria == 1 
    merge m:1 id_gov_syria using `gov_1_dist_`jdis''
    drop _merge
    tempfile gov_1_dist_`jdis'
    save `gov_1_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 52(1)102 {
    preserve 
    keep if id_gov_syria == 2 
    merge m:1 id_gov_syria using `gov_2_dist_`jdis''
    drop _merge
    tempfile gov_2_dist_`jdis'
    save `gov_2_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 103(1)153 {
    preserve 
    keep if id_gov_syria == 3 
    merge m:1 id_gov_syria using `gov_3_dist_`jdis''
    drop _merge
    tempfile gov_3_dist_`jdis'
    save `gov_3_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 154(1)204 {
    preserve 
    keep if id_gov_syria == 4 
    merge m:1 id_gov_syria using `gov_4_dist_`jdis''
    drop _merge
    tempfile gov_4_dist_`jdis'
    save `gov_4_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 205(1)255 {
    preserve 
    keep if id_gov_syria == 5 
    merge m:1 id_gov_syria using `gov_5_dist_`jdis''
    drop _merge
    tempfile gov_5_dist_`jdis'
    save `gov_5_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 256(1)306 {
    preserve 
    keep if id_gov_syria == 6 
    merge m:1 id_gov_syria using `gov_6_dist_`jdis''
    drop _merge
    tempfile gov_6_dist_`jdis'
    save `gov_6_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 307(1)357 {
    preserve 
    keep if id_gov_syria == 7 
    merge m:1 id_gov_syria using `gov_7_dist_`jdis''
    drop _merge
    tempfile gov_7_dist_`jdis'
    save `gov_7_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 358(1)408 {
    preserve 
    keep if id_gov_syria == 8 
    merge m:1 id_gov_syria using `gov_8_dist_`jdis''
    drop _merge
    tempfile gov_8_dist_`jdis'
    save `gov_8_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 409(1)459 {
    preserve 
    keep if id_gov_syria == 9 
    merge m:1 id_gov_syria using `gov_9_dist_`jdis''
    drop _merge
    tempfile gov_9_dist_`jdis'
    save `gov_9_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 460(1)510 {
    preserve 
    keep if id_gov_syria == 10 
    merge m:1 id_gov_syria using `gov_10_dist_`jdis''
    drop _merge
    tempfile gov_10_dist_`jdis'
    save `gov_10_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 511(1)561 {
    preserve 
    keep if id_gov_syria == 11 
    merge m:1 id_gov_syria using `gov_11_dist_`jdis''
    drop _merge
    tempfile gov_11_dist_`jdis'
    save `gov_11_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 562(1)612 {
    preserve 
    keep if id_gov_syria == 12 
    merge m:1 id_gov_syria using `gov_12_dist_`jdis''
    drop _merge
    tempfile gov_12_dist_`jdis'
    save `gov_12_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 613(1)663 {
    preserve 
    keep if id_gov_syria == 13 
    merge m:1 id_gov_syria using `gov_13_dist_`jdis''
    drop _merge
    tempfile gov_13_dist_`jdis'
    save `gov_13_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 664(1)714 {
    preserve 
    keep if id_gov_syria == 14 
    merge m:1 id_gov_syria using `gov_14_dist_`jdis''
    drop _merge
    tempfile gov_14_dist_`jdis'
    save `gov_14_dist_`jdis''
    restore 
  }





use `gov_1_dist_1', clear 
  qui forvalues jdis = 2(1)51 {
    append using `gov_1_dist_`jdis''
  } 

append using `gov_2_dist_1' 
  qui forvalues jdis = 52(1)102 {
    append using `gov_2_dist_`jdis''
  } 

append using `gov_3_dist_1' 
  qui forvalues jdis = 103(1)153 {
    append using `gov_3_dist_`jdis''
  } 

append using `gov_4_dist_1' 
  qui forvalues jdis = 154(1)204 {
    append using `gov_4_dist_`jdis''
  } 

append using `gov_5_dist_1' 
  qui forvalues jdis = 205(1)255 {
    append using `gov_5_dist_`jdis''
  } 

append using `gov_6_dist_1' 
  qui forvalues jdis = 256(1)306 {
    append using `gov_6_dist_`jdis''
  } 

append using `gov_7_dist_1' 
  qui forvalues jdis = 307(1)357 {
    append using `gov_7_dist_`jdis''
  } 

append using `gov_8_dist_1' 
  qui forvalues jdis = 358(1)408 {
    append using `gov_8_dist_`jdis''
  } 

append using `gov_9_dist_1' 
  qui forvalues jdis = 409(1)459 {
    append using `gov_9_dist_`jdis''
  } 

append using `gov_10_dist_1' 
  qui forvalues jdis = 460(1)510 {
    append using `gov_10_dist_`jdis''
  } 

append using `gov_11_dist_1' 
  qui forvalues jdis = 511(1)561 {
    append using `gov_11_dist_`jdis''
  } 

append using `gov_12_dist_1' 
  qui forvalues jdis = 562(1)612 {
    append using `gov_12_dist_`jdis''
  } 

append using `gov_13_dist_1' 
  qui forvalues jdis = 613(1)663 {
    append using `gov_13_dist_`jdis''
  } 

append using `gov_14_dist_1' 
  qui forvalues jdis = 664(1)714 {
    append using `gov_14_dist_`jdis''
  } 

save "$data_temp/04_IV_geo_empl_Syria", replace



import excel "$data_UNHCR_base\Datasets_WP_RegisteredSyrians.xlsx", sheet("WP - byIndustry") firstrow clear

keep year_2016 Activity

ren year_2016 wp_2016
ren Activity industry_orig
gen industry_en = ""
replace industry_en = "agriculture" if industry_orig == "Agriculture, forestry, and fishing "
replace industry_en = "industry" if industry_orig == "Mining and quarrying "
replace industry_en = "industry" if industry_orig == "Manufacturing "
replace industry_en = "industry" if industry_orig == "Electricity, gas, steam and air conditioning "
replace industry_en = "industry" if industry_orig == "Water supply, sewage, waste management activities "
replace industry_en = "construction" if industry_orig == "Construction "
replace industry_en = "industry" if industry_orig == "Wholesale and retail trade; repair of motor vehicles "
replace industry_en = "transportation" if industry_orig == "Transportation and storage "
replace industry_en = "food" if industry_orig == "Hospitality and food service activities "
replace industry_en = "services" if industry_orig == "Information and communication "
replace industry_en = "banking" if industry_orig == "Financial and insurance activities "
replace industry_en = "banking" if industry_orig == "Real estate activities "
replace industry_en = "services" if industry_orig == "Professional, scientific and technical activities "
replace industry_en = "services" if industry_orig == "Administrative and support service activities "
replace industry_en = "services" if industry_orig == "Public administration and defense; compulsory social "
replace industry_en = "services" if industry_orig == "Education "
replace industry_en = "services" if industry_orig == "Human health and social work activities "
replace industry_en = "services" if industry_orig == "Arts, entertainment and recreation "
replace industry_en = "services" if industry_orig == "Other service activities "

drop if mi(industry_en)
*It removes the Self employed jobs 

collapse (sum) wp_2016, by(industry_en)
*Harmonize based on Syrian classification of industries

sort industry_en 
gen industry_id = _n
list industry_id industry_en 

/*    +---------------------------+
     | indust~d      industry_en |
     |---------------------------|
  1. |        1      agriculture |
  2. |        2          banking |
  3. |        3     construction |
  4. |        4             food |
  5. |        5         industry |
     |---------------------------|
  6. |        6         services |
  7. |        7   transportation |
     +---------------------------+
*/
*save "$data_UNHCR_temp/UNHCR_shift_byOccup.dta", replace 
save "$data_temp/05_IV_shift_byIndus.dta", replace 

* GOVERNROATE OF ORIGIN REFUGES
import excel "$data_RW_base/syr_ref_bygov.xlsx", firstrow clear
*save "$data_RW_final/syr_ref_bygov.dta", replace 
save "$data_temp/06_Ctrl_GovOrig_Refugee.dta", replace 


**CONTROL: Number of refugees
import excel "$data_UNHCR_base/Datasets_WP_RegisteredSyrians.xlsx", sheet("WP_REF - byGov byYear") firstrow clear

*tab Year
*keep if Year == 2016 
ren Year year
keep if year == 2016 

sort Governorates
ren Governorates governorate_en
sort governorate_en
egen governorate_iid = group(governorate_en)

*save "$data_UNHCR_final/UNHCR_NbRef_byGov.dta", replace
save "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta", replace

*GET THE NUMBER OF REFUGEES BY GOVERNORATE , NOT ONLY FOR THE 4 SELECTED !!!!!
*GO IN THE EXCEL FILE AND CHANGE THAT USING THE PDFS, FOR 2016 FOR NOW

/**************
THE INSTRUMENT 
**************/



use "$data_temp/04_IV_geo_empl_Syria", clear 

*Distance between governorates syria and districts jordan
geodist district_lat district_long gov_syria_lat gov_syria_long, gen(distance_dis_gov)
tab distance_dis_gov, m
lab var distance_dis_gov "Distance (km) between JORD districts and SYR centroid governorates"

unique distance_dis_gov //714

drop district_long district_lat gov_syria_long gov_syria_lat
sort district_en governorate_syria 

drop id_district_jordan 
egen id_district_jordan = group(district_en) 

list id_gov_syria governorate_syria
sort district_en governorate_syria industry_id

tab industry_en industry_id
drop industry_id 
egen industry_id = group(industry_en)

*merge m:1 industry_id using  "$data_UNHCR_temp/UNHCR_shift_byOccup.dta"
merge m:1 industry_id using  "$data_temp/05_IV_shift_byIndus.dta"

drop _merge 

ren share share_empl_syr 

order id_gov_syria governorate_syria id_district_jordan ///
		district_en industry_id industry_en share_empl_syr wp_2016

lab var id_gov_syria "ID Governorate Syria"
lab var governorate_syria "Name Governorate Syria"
lab var id_district_jordan "ID District Jordan"
lab var district_en "Name District Jordan"
lab var industry_id "ID Industry"
lab var industry_en "Name Industry"
lab var share_empl_syr "Share Employment over Governorates Syria"
lab var wp_2016 "WP 2016 in Jordan by industry"
lab var distance_dis_gov "Distance Districts Jordan to Governorates Syria"

sort id_gov_syria district_en industry_id

*merge m:1 id_gov_syria using "$data_RW_final/syr_ref_bygov.dta"
merge m:1 id_gov_syria using "$data_temp/06_Ctrl_GovOrig_Refugee.dta"


* STANDARD SS IV
gen IV_SS = (wp_2016*share_empl_syr*nb_ref_syr_bygov)/distance_dis_gov 
collapse (sum) IV_SS, by(district_en)
lab var IV_SS "IV: Shift Share"

tab district_en
sort district_en
egen district_iid = group(district_en) 


save "$data_final/03_ShiftShare_IV", replace 



***************************

	****************************************************************************
	**                            IV ANALYSIS / REG                           **  
	****************************************************************************



use "$data_final/02_JLMPS_10_16.dta", clear

merge m:1 district_iid using "$data_final/03_ShiftShare_IV.dta" 
drop _merge 

*merge m:1 governorate_id using "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta"
*drop if _merge == 2
*drop _merge

tab work_permit, m
tab IV_SS, m
replace IV_SS = 0 if year == 2010
tab IV_SS , m

*merge m:1 governorate_iid using "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta", keepusing(year NbRefugeesoutcamp)


save "$data_final/05_IV_JLMPS_Analysis.dta", replace

use "$data_final/05_IV_JLMPS_Analysis.dta", clear

preserve
tab forced_migr
codebook forced_migr
drop if forced_migr != 1
collapse (sum) work_permit if year == 2016, by(district_iid)
ren work_permit agg_wp_2016
gen year = 2016
tempfile wp2016
save `wp2016'
restore

merge m:1 district_iid using `wp2016'
drop _merge

gen agg_wp = agg_wp_2016
replace agg_wp = 0 if mi(agg_wp)

tab agg_wp, m

xi: ivreg2 rsi_wage_income_lm_cont 

xtset district_iid  
xtivreg basicwg3 i.year i.district_iid (agg_wp= IV_SS)  if forced_migr==0, re first
xtoverid, nois

xi: ivreg2 basicwg3 i.year i.district_iid (agg_wp= IV_SS) if forced_migr==0, cluster(district_iid)
ivregress 2sls basicwg3 (agg_wp = IV_SS)
est store IV









reg  basicwg3 			iv_WPhat
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat i.year
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat c.district_id
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat i.year c.district_id
estimates table, star(.05 .01 .001)

reg  basicwg3 			iv_WPhat, robust
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat i.year, robust
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat c.district_id, robust
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat i.year c.district_id, robust
estimates table, star(.05 .01 .001)

reg  basicwg3 			iv_WPhat, robust cl(district_id)	
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat i.year, robust cl(district_id)	
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat c.district_id, robust cl(district_id)	
estimates table, star(.05 .01 .001)
reg  basicwg3 			iv_WPhat i.year c.district_id, robust cl(district_id)	
estimates table, star(.05 .01 .001)

reg  basicwg3 			iv_WPhat i.year c.district_id , robust cl(district_id)	

*HAUSNAB TEST OF ENDO 
ivregress 2sls basicwg3 (work_permit = IV_SS)
est store IV
reg  basicwg3 work_permit 	
hausman IV 
drop _est_IV


reg  usemp1 			iv_WPhat i.year c.district_id , robust cl(district_id)	
reg  cremp1 			iv_WPhat i.year c.district_id , robust cl(district_id)	
reg  crhrsday 			iv_WPhat i.year c.district_id , robust cl(district_id)	
















