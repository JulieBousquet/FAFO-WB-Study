
cap log close
clear all
set more off, permanently
set mem 100m

log using "$out_analysis/03_IV.log", replace

	****************************************************************************
	**                            DATA IV CREATION                            **  
	** ---------------------------------------------------------------------- **
	** Type Do  : 	DATA IV JLMPS                                              **
  	**                                                                        **
	** Authors  : Julie Bousquet                                              **
	****************************************************************************


********************************
**** SHARE 1: EMPLOYEMENT ******
********************************

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


*NEW CODE NEW CODE 
*With more accurate GPSs / LOCALITY Information
duplicates drop district_en, force

tab district_en, m 
tab district_lat, m
tab district_long, m

keep district_en district_lat district_long governorate_iid



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

ren governorate_iid gov
keep gov governorate_syria gov_syria_long gov_syria_lat district_en district_lat district_long

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

save "$data_temp/04_IV_Share_Empl_Syria", replace



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
*CHANGE: replace industry_en = "industry" if industry_orig == "Wholesale and retail trade; repair of motor vehicles "
replace industry_en = "services" if industry_orig == "Wholesale and retail trade; repair of motor vehicles "
replace industry_en = "transportation" if industry_orig == "Transportation and storage "
replace industry_en = "food" if industry_orig == "Hospitality and food service activities "
*CHANGE: replace industry_en = "services" if industry_orig == "Information and communication "
replace industry_en = "industry" if industry_orig == "Information and communication "
*CHANGE: replace industry_en = "banking" if industry_orig == "Real estate activities "
replace industry_en = "services" if industry_orig == "Real estate activities "
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

***************************
* SHARE 2 : GOV OF ORIGIN *
***************************

* SYRIAN GOVERNROATE OF ORIGIN REFUGES
import excel "$data_UNHCR_base/Datasets_WP_RegisteredSyrians.xlsx" , sheet("Registered Syrian by Gov Orig") firstrow clear
*I will use 2016
save "$data_temp/06_IV_Share_GovOrig_Refugee.dta", replace 


**CONTROL: Number of refugees
import excel "$data_UNHCR_base/Datasets_WP_RegisteredSyrians.xlsx", sheet("WP_REF - byGov byYear") firstrow clear

*tab Year
*keep if Year == 2016 
ren Year year
keep if year == 2016 

sort Governorate
ren Governorate governorate_en
sort governorate_en
egen governorate_iid = group(governorate_en)

keep year governorate_en governorate_iid NbRefbyGovoutcamp NbWP
*save "$data_UNHCR_final/UNHCR_NbRef_byGov.dta", replace
save "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta", replace



/****************************************
THE SHARE OF EMPLOYED IN OPEN  IN JORDAN 
****************************************/

import excel "$data_sec_DOS\Table 5.4 - Jord 15+ by Gov, Sex and Main Current Economic Activity (Percent) - 2010.xlsx", sheet("ForStata") firstrow clear
*br

bys Sector: egen tot_empl_1 = sum(Amman) if Sector != "n.a" 
bys Sector: egen tot_empl_2 = sum(Balqa) if Sector != "n.a" 
bys Sector: egen tot_empl_3 = sum(Zarqa) if Sector != "n.a" 
bys Sector: egen tot_empl_4 = sum(Madaba) if Sector != "n.a" 
bys Sector: egen tot_empl_5 = sum(Irbid) if Sector != "n.a" 
bys Sector: egen tot_empl_6 = sum(Mafraq) if Sector != "n.a" 
bys Sector: egen tot_empl_7 = sum(Jerash) if Sector != "n.a" 
bys Sector: egen tot_empl_8 = sum(Ajloun) if Sector != "n.a" 
bys Sector: egen tot_empl_9 = sum(Karak) if Sector != "n.a" 
bys Sector: egen tot_empl_10 = sum(Tafielah) if Sector != "n.a" 
bys Sector: egen tot_empl_11 = sum(Maan) if Sector != "n.a" 
bys Sector: egen tot_empl_12 = sum(Aqaba) if Sector != "n.a" 

replace tot_empl_1 = Amman if Sector == "n.a"
replace tot_empl_2 = Balqa if Sector == "n.a"
replace tot_empl_3 = Zarqa if Sector == "n.a"
replace tot_empl_4 = Madaba if Sector == "n.a"
replace tot_empl_5 = Irbid if Sector == "n.a"
replace tot_empl_6 = Mafraq if Sector == "n.a"
replace tot_empl_7 = Jerash if Sector == "n.a"
replace tot_empl_8 = Ajloun if Sector == "n.a"
replace tot_empl_9 = Karak if Sector == "n.a"
replace tot_empl_10 = Tafielah if Sector == "n.a"
replace tot_empl_11 = Maan if Sector == "n.a"
replace tot_empl_12 = Aqaba if Sector == "n.a"

keep tot_empl_* Sector 
duplicates drop
replace Sector = "Total" if Sector == "n.a"

reshape long tot_empl_, i(Sector) j(gov)

replace gov = 13 if gov == 3 
replace gov = 14 if gov == 4
replace gov = 21 if gov == 5 
replace gov = 22 if gov == 6
replace gov = 23 if gov == 7
replace gov = 24 if gov == 8 
replace gov = 31 if gov == 9 
replace gov = 32 if gov == 10 
replace gov = 33 if gov == 11 
replace gov = 34 if gov == 12
replace gov = 11 if gov == 1 
replace gov = 12 if gov == 2 

lab def gov 11 "Amman" ///
            12 "Balqa" ///
            13 "Zarqa" ///
            14 "Madaba" ///
            21 "Irbid" ///
            22 "Mafraq" ///
            23 "Jarash" ///
            24 "Ajloun" ///
            31 "Karak" ///
            32 "Tafileh" ///
            33 "Ma'an"  ///
            34 "Aqaba", ///
            modify

lab val gov gov

preserve 
keep if Sector == "Total"
ren tot_empl_ tot_empl
tempfile total_empl_db 
save `total_empl_db'
restore 

ren tot_empl_ empl_bysector

drop if Sector == "Total"
merge m:1 gov using `total_empl_db'
drop _merge 
gen share_empl = empl_bysector / tot_empl

drop empl_bysector tot_empl
reshape wide share_empl , i(gov) j(Sector) string

save "$data_temp/08_Share_empl_open_byGov.dta", replace


/**************
THE INSTRUMENT 
**************/

use "$data_temp/04_IV_Share_Empl_Syria", clear 

***********************************************
* SHARE 3 : DISTANCE FROM SYR GOV TO DIST JOR *
***********************************************

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
merge m:1 id_gov_syria using "$data_temp/06_IV_Share_GovOrig_Refugee.dta", keepusing(nb_ref_syr_bygov_2016)
drop _merge 

merge m:1 gov using "$data_temp/08_Share_empl_open_byGov.dta"
drop _merge
****************
****************
  *  SS IV  *
****************
****************

*gen distance_dis_gov_2 = distance_dis_gov^2
*gen IV_SS = (wp_2016*share_empl_syr*nb_ref_syr_bygov_2016)/distance_dis_gov_2 


gen IV_SS = (wp_2016*share_empl_syr*share_emplOpen*nb_ref_syr_bygov_2016)/distance_dis_gov 
collapse (sum) IV_SS, by(district_en)
lab var IV_SS "IV: Shift Share"

tab district_en
sort district_en
egen district_iid = group(district_en) 


save "$data_final/03_ShiftShare_IV", replace 

log close

*use "$data_final/03_ShiftShare_IV", clear 

