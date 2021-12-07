
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


*************************************************************************************
**** SHARE 1: SHARE EMPLOYEMENT IN EACH INDUSTRY BY GOVERNORATES 2010 IN SYRIA ******
*************************************************************************************

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
ren Industry industry 
ren Buildingandconstruction construction 
ren Hotelsandrestaurantstrade food 
ren Transportationstoragecommun transportation 
ren Moneyinsuranceandrealestat banking 
ren Services services 

gen share_agriculture = agriculture / total
gen share_industry = industry / total
gen share_construction = construction / total
gen share_food = food / total
gen share_transportation = transportation / total
gen share_banking = banking / total
gen share_services = services / total

/*
egen tot_open = rsum(agriculture construction services)
gen share_open = tot_open/total 
ren total total_empl_syr 

reshape long share_ , i(id_gov_syria) j(industry_id)
*/
ren total total_empl_syr 

drop agriculture industry construction food transportation banking services 
drop total_empl_syr
ren share_agriculture share_1 
ren share_industry share_2
ren share_construction share_3 
ren share_food share_4
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

order id_gov_syria governorate_syria industry_id industry_en share

*Sum by Syrian gov == 1 

save "$data_LFS_final/LFS_Syr_Empl_Share_Indus.dta", replace


*******************************************************************
**** SHARE 2: DISTANCE GOVERNORATE SYRIA TO DISTRICTS JORDAN ******
*******************************************************************

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


sort governorate_syria
list governorate_syria 


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

drop if  Activity == "Total "

replace Activity = "Accomodation and food service activities " if Activity == "Hospitality and food service activities "
drop if Activity == "Activities of extraterritorial organizations and bodies " 
drop if Activity == "Activities of households as employers; undifferentiated goods and services-producing activities of households for own use. "

ren year_2016 wp_2016
ren Activity industry_orig

sort industry_orig 
gen industry_orig_id = _n 
list industry_orig_id industry_orig 

save "$data_temp/05_IV_shift_byIndus_ORIG.dta", replace 


gen industry_en = ""
replace industry_en = "agriculture" if industry_orig == "Agriculture, forestry, and fishing "
replace industry_en = "industry" if industry_orig == "Mining and quarrying "
replace industry_en = "industry" if industry_orig == "Manufacturing "
*CHANGE: replace industry_en = "industry" if industry_orig == "Electricity, gas, steam and air conditioning "
replace industry_en = "services" if industry_orig == "Electricity, gas, steam and air conditioning "
*CHANGE: replace industry_en = "industry" if industry_orig == "Water supply, sewage, waste management activities "
replace industry_en = "services" if industry_orig == "Water supply, sewage, waste management activities "
replace industry_en = "construction" if industry_orig == "Construction "
*CHANGE: replace industry_en = "industry" if industry_orig == "Wholesale and retail trade; repair of motor vehicles "
replace industry_en = "services" if industry_orig == "Wholesale and retail trade; repair of motor vehicles "
replace industry_en = "transportation" if industry_orig == "Transportation and storage "
replace industry_en = "food" if industry_orig == "Accomodation and food service activities "
*CHANGE: replace industry_en = "services" if industry_orig == "Information and communication "
*replace industry_en = "industry" if industry_orig == "Information and communication "
replace industry_en = "transportation" if industry_orig == "Information and communication "
replace industry_en = "banking"  if industry_orig == "Financial and insurance activities "
replace industry_en = "banking" if industry_orig == "Real estate activities "
*CHANGE: replace industry_en = "services" if industry_orig == "Real estate activities "
replace industry_en = "services" if industry_orig == "Professional, scientific and technical activities "
replace industry_en = "services" if industry_orig == "Administrative and support service activities "
replace industry_en = "services" if industry_orig == "Public administration and defense; compulsory social "
replace industry_en = "services" if industry_orig == "Education "
replace industry_en = "services" if industry_orig == "Human health and social work activities "
*replace industry_en = "services" if industry_orig == "Arts, entertainment and recreation "
replace industry_en = "food" if industry_orig == "Arts, entertainment and recreation "
replace industry_en = "services" if industry_orig == "Other service activities "

drop if mi(industry_en)
*It removes the Self employed jobs 

collapse (sum) wp_2016, by(industry_en)
*Harmonize based on Syrian classification of industries

sort industry_en 
gen     industry_id = 1 if industry_en == "agriculture"
replace industry_id = 2 if industry_en == "industry"
replace industry_id = 3 if industry_en == "construction"
replace industry_id = 4 if industry_en == "food"
replace industry_id = 5 if industry_en == "transportation"
replace industry_id = 6 if industry_en == "banking"
replace industry_id = 7 if industry_en == "services"

sort industry_id 
list industry_id industry_en 

/*      +---------------------------+
     | indust~d      industry_en |
     |---------------------------|
  1. |        1      agriculture |
  2. |        6          banking |
  3. |        3     construction |
  4. |        4             food |
  5. |        2         industry |
     |---------------------------|
  6. |        7         services |
  7. |        5   transportation |
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

drop governorate_iid
gen governorate_iid = 11 if governorate_en == "Amman"
replace governorate_iid = 12 if governorate_en == "Balqa"
replace governorate_iid = 13 if governorate_en == "Zarqa"
replace governorate_iid = 14 if governorate_en == "Madaba"
replace governorate_iid = 21 if governorate_en == "Irbid"
replace governorate_iid = 22 if governorate_en == "Mafraq"
replace governorate_iid = 23 if governorate_en == "Jarash"
replace governorate_iid = 24 if governorate_en == "Ajloun"
replace governorate_iid = 31 if governorate_en == "Karak"
replace governorate_iid = 32 if governorate_en == "Tafileh"
replace governorate_iid = 33 if governorate_en == "Ma'an"
replace governorate_iid = 34 if governorate_en == "Aqaba"



save "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta", replace



use "$data_final/02_JLMPS_10_16.dta", clear 

keep district_iid governorate_iid district_lat district_long district_en gov

drop governorate_iid
ren gov governorate_iid


duplicates drop district_iid, force

merge m:1 governorate_iid using "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta"
drop _merge

*******************
** DISTANCE CAMP **
*******************

*Distance between zaatari camp and districts jordan
gen dist_zaatari_lat = 32.30888675674741
gen dist_zaatari_long = 36.31329385051756
geodist district_lat district_long dist_zaatari_lat dist_zaatari_long, gen(distance_dis_camp)
tab distance_dis_camp, m
lab var distance_dis_camp "[CTRL] Distance (km) between JORD districts and ZAATARI CAMP in 2016"
replace distance_dis_camp = 0 if year == 2010

gen inv_dist_camp = 1/distance_dis_camp
replace inv_dist_camp = 0 if year == 2010
gen ln_invdistance_dis_camp = log(1 + inv_dist_camp) 

*gen ln_distance_dis_camp = log(1 + distance_dis_camp) 
*if year == 2016
*replace ln_distance_dis_camp = 0 if year == 2010
lab var ln_invdistance_dis_camp "[CTRL] LOG Inverse Distance (km) between JORD districts and ZAATARI CAMP in 2016"


*********************
** NUMBER REFUGEES **
*********************

tab NbRefbyGovoutcamp, m
ren NbRefbyGovoutcamp nb_refugees_bygov
replace nb_refugees_bygov = 0 if year == 2010
lab var nb_refugees_bygov "[CTRL] Number of refugees out of camps by governorate in 2016"
tab nb_refugees_bygov

gen ln_nb_refugees_bygov = ln(1 + nb_refugees_bygov) 
*if year == 2016
*replace ln_nb_refugees_bygov = 0 if year == 2010

lab var ln_nb_refugees_bygov "[CTRL] LOG Number of refugees out of camps by governorate in 2016"
*ln_ref, as of now, does not include refugees in 2010, only in 2016

****** Other
gen IHS_nb_refugees_bygov = log(nb_refugees_bygov + ((nb_refugees_bygov^2 + 1)^0.5))
lab var IHS_nb_refugees_bygov "IHS - Number of refugees out of camps by governorate in 2016"



tab nb_refugees_bygov
gen tot_nb_ref_2016 = 513032 if year == 2016
lab var tot_nb_ref_2016 "Number of Syrian refugee in Jordan in 2016"

*THE INSTRUMENT 
gen IV_SS_ref_inflow = tot_nb_ref_2016*inv_dist_camp
replace IV_SS_ref_inflow = 0 if mi(IV_SS_ref_inflow)
lab var IV_SS_ref_inflow "SSIV for refugee inflow: tot_nb_ref_2016 x inv_dist_camp"

*THE INSTRUMENT 
tab IV_SS_ref_inflow, m 
bys district_iid: tab IV_SS_ref_inflow

distinct IV_SS_ref_inflow

*THE INSTRUMENT + TRANSFORMATION
gen ln_IV_SS_ref_inflow = log(1 + IV_SS_ref_inflow)
lab var ln_IV_SS_ref_inflow "LOG - SSIV for refugee inflow: tot_nb_ref_2016 x inv_dist_camp"
replace ln_IV_SS_ref_inflow = 0 if year == 2010

gen IHS_IV_SS_ref_inflow = log(IV_SS_ref_inflow + ((IV_SS_ref_inflow^2 + 1)^0.5))
lab var IHS_IV_SS_ref_inflow "IHS - SSIV for refugee inflow: tot_nb_ref_2016 x inv_dist_camp"
replace IHS_IV_SS_ref_inflow = 0 if year == 2010



save "$data_final/10_JLMPS_Distance_Zaatari.dta", replace 





/****************************************
THE SHARE OF EMPLOYED IN JORDAN 
****************************************/

import excel "$data_sec_DOS\Table 5.4 - Jord 15+ by Gov, Sex and Main Current Economic Activity (Percent) - 2010.xlsx", sheet("ForStata") firstrow clear
*br
drop Sector
gen Sector = "Open" if Economicactivity == "Agriculture, forestry and fishing" | ///
                        Economicactivity == "Manufacturing" | ///
                        Economicactivity == "Construction" | ///
                        Economicactivity == "Wholesale and retail trade; repair of motor vehicles and motorcycles" | ///
                        Economicactivity == "Human health and social work activities" | ///
                        Economicactivity == "Administrative and support service activities" | ///
                        Economicactivity == "Public Administration and Defence, Compulsory Social Security" | ///
                        Economicactivity == "Other service activities" 
replace Sector = "Close" if mi(Sector)
replace Sector = "n.a" if Economicactivity == "Total"

ren Economicactivity industry_orig

gen industry_en = ""
replace industry_en = "agriculture" if industry_orig == "Agriculture, forestry and fishing"
replace industry_en = "industry" if industry_orig == "Mining and quarrying"
replace industry_en = "industry" if industry_orig == "Manufacturing"
*CHANGE: replace industry_en = "industry" if industry_orig == "Electricity, gas, steam and air conditioning "
replace industry_en = "services" if industry_orig == "Electricity, gas, steam and air conditioning supply"
*CHANGE: replace industry_en = "industry" if industry_orig == "Water supply, sewage, waste management activities "
replace industry_en = "services" if industry_orig == "Water supply, sewerage, waste management and remediation activities"
replace industry_en = "construction" if industry_orig == "Construction"
*CHANGE: replace industry_en = "industry" if industry_orig == "Wholesale and retail trade; repair of motor vehicles "
replace industry_en = "services" if industry_orig == "Wholesale and retail trade; repair of motor vehicles and motorcycles"
replace industry_en = "transportation" if industry_orig == "Transportation and storage"
replace industry_en = "food" if industry_orig == "Accommodation and food service activities"
*CHANGE: replace industry_en = "services" if industry_orig == "Information and communication "
*replace industry_en = "industry" if industry_orig == "Information and communication "
replace industry_en = "transportation" if industry_orig == "Information and communication"
replace industry_en = "banking"  if industry_orig == "Financial and insurance activities"
replace industry_en = "banking" if industry_orig == "Real estate activities"
*CHANGE: replace industry_en = "services" if industry_orig == "Real estate activities "
replace industry_en = "services" if industry_orig == "Professional, scientific and technical activities"
replace industry_en = "services" if industry_orig == "Administrative and support service activities"
replace industry_en = "services" if industry_orig == "Public Administration and Defence, Compulsory Social Security"
replace industry_en = "services" if industry_orig == "Education"
replace industry_en = "services" if industry_orig == "Human health and social work activities"
*replace industry_en = "services" if industry_orig == "Arts, entertainment and recreation "
replace industry_en = "food" if industry_orig == "Arts, entertainment and recreation"
replace industry_en = "services" if industry_orig == "Other service activities"

drop if industry_orig == "Activities of households as employers; undifferentiated goods and services-producing activities of households for own use"
drop if industry_orig == "Activities of extraterritorial organizations and bodies"

order industry_en Sector
bys industry_en: egen tot_empl_1 = sum(Amman) if Sector != "n.a" 
bys industry_en: egen tot_empl_2 = sum(Balqa) if Sector != "n.a" 
bys industry_en: egen tot_empl_3 = sum(Zarqa) if Sector != "n.a" 
bys industry_en: egen tot_empl_4 = sum(Madaba) if Sector != "n.a" 
bys industry_en: egen tot_empl_5 = sum(Irbid) if Sector != "n.a" 
bys industry_en: egen tot_empl_6 = sum(Mafraq) if Sector != "n.a" 
bys industry_en: egen tot_empl_7 = sum(Jerash) if Sector != "n.a" 
bys industry_en: egen tot_empl_8 = sum(Ajloun) if Sector != "n.a" 
bys industry_en: egen tot_empl_9 = sum(Karak) if Sector != "n.a" 
bys industry_en: egen tot_empl_10 = sum(Tafielah) if Sector != "n.a" 
bys industry_en: egen tot_empl_11 = sum(Maan) if Sector != "n.a" 
bys industry_en: egen tot_empl_12 = sum(Aqaba) if Sector != "n.a" 

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

*keep tot_empl_* Sector industry_en
duplicates drop industry_en, force
replace industry_en = "Total" if Sector == "n.a"
keep tot_empl_*  industry_en

reshape long tot_empl_, i(industry_en) j(gov)

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
keep if industry_en == "Total"
ren tot_empl_ tot_empl
tempfile total_empl_db 
save `total_empl_db'
restore 

ren tot_empl_ empl_bysector

drop if industry_en == "Total"
merge m:1 gov using `total_empl_db'
drop _merge 
gen share_empl = empl_bysector / tot_empl

drop empl_bysector tot_empl
reshape wide share_empl , i(gov) j(industry_en) string

/*

egen industry_id = group(industry_en)
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
merge m:1 industry_id using  "$data_temp/05_IV_shift_byIndus.dta" 
drop _merge

*drop Economicactivity 
*order gov industry_orig_id industry_orig wp_2016  share_empl

gen inter_wp_empl = wp_2016 * share_empl

collapse (sum) inter_wp_empl, by(gov)

*/


save "$data_temp/08_Share_empl_Jordan_byGov_byIndus.dta", replace



/****************************************
THE SHARE OF EMPLOYED IN OPEN  IN JORDAN 
****************************************/

import excel "$data_sec_DOS\Table 5.4 - Jord 15+ by Gov, Sex and Main Current Economic Activity (Percent) - 2010.xlsx", sheet("ForStata") firstrow clear
*br
drop Sector
gen Sector = "Open" if Economicactivity == "Agriculture, forestry and fishing" | ///
                        Economicactivity == "Manufacturing" | ///
                        Economicactivity == "Construction" | ///
                        Economicactivity == "Wholesale and retail trade; repair of motor vehicles and motorcycles" | ///
                        Economicactivity == "Human health and social work activities" | ///
                        Economicactivity == "Administrative and support service activities" | ///
                        Economicactivity == "Public Administration and Defence, Compulsory Social Security" | ///
                        Economicactivity == "Other service activities" 
replace Sector = "Close" if mi(Sector)
replace Sector = "n.a" if Economicactivity == "Total"

order Economicactivity Sector
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




/****************************************
THE SHARE OF EMPLOYED BY INDUSTRY IN JORDAN 
****************************************/

import excel "$data_sec_DOS\Table 5.4 - Jord 15+ by Gov, Sex and Main Current Economic Activity (Percent) - 2010.xlsx", sheet("ForStata") firstrow clear
*br
drop Sector
gen Sector = "Open" if Economicactivity == "Agriculture, forestry and fishing" | ///
                        Economicactivity == "Manufacturing" | ///
                        Economicactivity == "Construction" | ///
                        Economicactivity == "Wholesale and retail trade; repair of motor vehicles and motorcycles" | ///
                        Economicactivity == "Human health and social work activities" | ///
                        Economicactivity == "Administrative and support service activities" | ///
                        Economicactivity == "Public Administration and Defence, Compulsory Social Security" | ///
                        Economicactivity == "Other service activities" 
replace Sector = "Close" if mi(Sector)
replace Sector = "n.a" if Economicactivity == "Total"

drop if Economicactivity == "Activities of households as employers; undifferentiated goods and services-producing activities of households for own use"
drop if Economicactivity == "Activities of extraterritorial organizations and bodies"

sort Economicactivity 

gen     industry_orig_id = 1 if Economicactivity == "Accommodation and food service activities"
replace industry_orig_id = 2 if Economicactivity == "Administrative and support service activities"
replace industry_orig_id = 3 if Economicactivity == "Agriculture, forestry and fishing"
replace industry_orig_id = 4 if Economicactivity == "Arts, entertainment and recreation" 
replace industry_orig_id = 5 if Economicactivity == "Construction"
replace industry_orig_id = 6 if Economicactivity == "Education"
replace industry_orig_id = 7 if Economicactivity == "Electricity, gas, steam and air conditioning supply"
replace industry_orig_id = 8 if Economicactivity == "Financial and insurance activities"
replace industry_orig_id = 9 if Economicactivity == "Human health and social work activities"
replace industry_orig_id = 10 if Economicactivity == "Information and communication"
replace industry_orig_id = 11 if Economicactivity == "Manufacturing"
replace industry_orig_id = 12 if Economicactivity == "Mining and quarrying"
replace industry_orig_id = 13 if Economicactivity == "Other service activities"
replace industry_orig_id = 14 if Economicactivity == "Professional, scientific and technical activities"
replace industry_orig_id = 15 if Economicactivity == "Public Administration and Defence, Compulsory Social Security"
replace industry_orig_id = 16 if Economicactivity == "Real estate activities"
replace industry_orig_id = 17 if Economicactivity == "Transportation and storage"
replace industry_orig_id = 18 if Economicactivity == "Water supply, sewerage, waste management and remediation activities"
replace industry_orig_id = 19 if Economicactivity == "Wholesale and retail trade; repair of motor vehicles and motorcycles"

order Economicactivity industry_orig_id


replace Economicactivity = "Agriculture" if Economicactivity == "Agriculture, forestry and fishing"
replace Economicactivity = "Mining" if Economicactivity == "Mining and quarrying"
replace Economicactivity = "Manufacturing" if Economicactivity == "Manufacturing"
replace Economicactivity = "Electricity" if Economicactivity == "Electricity, gas, steam and air conditioning supply"
replace Economicactivity = "Water" if Economicactivity == "Water supply, sewerage, waste management and remediation activities"
replace Economicactivity = "Construction" if Economicactivity == "Construction"
replace Economicactivity = "Wholesale" if Economicactivity == "Wholesale and retail trade; repair of motor vehicles and motorcycles"
replace Economicactivity = "Transportation" if Economicactivity == "Transportation and storage"
replace Economicactivity = "Accommodation" if Economicactivity == "Accommodation and food service activities"
replace Economicactivity = "Information" if Economicactivity == "Information and communication"
replace Economicactivity = "Financial" if Economicactivity == "Financial and insurance activities"
replace Economicactivity = "Real" if Economicactivity == "Real estate activities"
replace Economicactivity = "Professional" if Economicactivity == "Professional, scientific and technical activities"
replace Economicactivity = "Administrative" if Economicactivity == "Administrative and support service activities"
replace Economicactivity = "Public" if Economicactivity == "Public Administration and Defence, Compulsory Social Security"
replace Economicactivity = "Education" if Economicactivity == "Education"
replace Economicactivity = "Human" if Economicactivity == "Human health and social work activities"
replace Economicactivity = "Arts" if Economicactivity == "Arts, entertainment and recreation"
replace Economicactivity = "Other" if Economicactivity == "Other service activities"


order Economicactivity Sector
bys Economicactivity: egen tot_empl_1 = sum(Amman) if Sector != "n.a" 
bys Economicactivity: egen tot_empl_2 = sum(Balqa) if Sector != "n.a" 
bys Economicactivity: egen tot_empl_3 = sum(Zarqa) if Sector != "n.a" 
bys Economicactivity: egen tot_empl_4 = sum(Madaba) if Sector != "n.a" 
bys Economicactivity: egen tot_empl_5 = sum(Irbid) if Sector != "n.a" 
bys Economicactivity: egen tot_empl_6 = sum(Mafraq) if Sector != "n.a" 
bys Economicactivity: egen tot_empl_7 = sum(Jerash) if Sector != "n.a" 
bys Economicactivity: egen tot_empl_8 = sum(Ajloun) if Sector != "n.a" 
bys Economicactivity: egen tot_empl_9 = sum(Karak) if Sector != "n.a" 
bys Economicactivity: egen tot_empl_10 = sum(Tafielah) if Sector != "n.a" 
bys Economicactivity: egen tot_empl_11 = sum(Maan) if Sector != "n.a" 
bys Economicactivity: egen tot_empl_12 = sum(Aqaba) if Sector != "n.a" 

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

replace Sector = "Total" if Sector == "n.a"
keep tot_empl_* Economicactivity industry_orig_id
*wp_2016 
duplicates drop

reshape long tot_empl_, i(Economicactivity) j(gov)

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
keep if Economicactivity == "Total"
ren tot_empl_ tot_empl
tempfile total_empl_db 
save `total_empl_db'
restore 

ren tot_empl_ empl_bysector

drop if Economicactivity == "Total"
merge m:1 gov using `total_empl_db'
drop _merge 
gen share_empl = empl_bysector / tot_empl

drop empl_bysector tot_empl
*reshape wide share_empl , i(industry_orig_id) j(gov) 



merge m:1 industry_orig_id using  "$data_temp/05_IV_shift_byIndus_ORIG.dta" 
drop _merge

drop Economicactivity 
order gov industry_orig_id industry_orig wp_2016  share_empl

gen inter_wp_empl = wp_2016 * share_empl

collapse (sum) inter_wp_empl, by(gov)

save "$data_temp/08_Share_empl_byGov_byIndus_ORIG_WP.dta", replace





*************************************
* SHARE EMPL JORD DISTRICT BY INDUS *
*************************************

use "$data_final/02_JLMPS_10_16.dta", clear

*** OLF AS MISSING ***
gen employed_3m = 2 if uswrkstsr1 == 1 & (usempstp != 3 | usempstp != 4) //EMPLOYED BUT NO SUBS WORK
replace employed_3m = 1 if uswrkstsr1 == 2 // UNEMP
replace employed_3m = 1 if uswrkstsr1 == 1 & (usempstp == 3 | usempstp == 4) //EMPLOYED IN SUBS WORK
replace employed_3m = . if uswrkstsr1 == 3 //OLF MISS
tab employed_3m, m 
lab def employed_3m 2 "Employed (no subs)" 1 "Unemployed (&subs)", modify 
lab val employed_3m employed_3m
lab var employed_3m "From uswrkstsr1 - mkt def, search req; 3m, 2 empl - 1 unemp - OLF miss"

keep if year == 2010
distinct district_iid 

tab employed_3m, nol
gen bi_emplyed_3m = 0 if employed_3m == 1 
replace bi_emplyed_3m = 1 if employed_3m == 2 
lab def bi_emplyed_3m 0 "Unemployed (&subs)" 1 "Employed (no subs)", modify 
lab val bi_emplyed_3m bi_emplyed_3m
tab bi_emplyed_3m

keep district_iid bi_emplyed_3m usecac1d
drop if bi_emplyed_3m == .
drop if bi_emplyed_3m == 0 
bys district_iid: egen total_empl = sum(bi_emplyed_3m) 
tab total_empl, m    

*Economic activity of prim. job (Sections(1digit), based on ISIC4, ref. 3-mnths)
tab usecac1d,m 

codebook usecac1d
lab list ecac1d

/*OLD VERSION 
gen empl_byindus = "agriculture" if usecac1d == 0
replace empl_byindus = "industry" if usecac1d == 1
replace empl_byindus = "industry" if usecac1d == 2
replace empl_byindus = "industry" if usecac1d == 3
replace empl_byindus = "industry" if usecac1d == 4
replace empl_byindus = "construction" if usecac1d == 5
replace empl_byindus = "services" if usecac1d == 6
replace empl_byindus = "transportation" if usecac1d == 7
replace empl_byindus = "food" if usecac1d == 8
replace empl_byindus = "industry" if usecac1d == 9
replace empl_byindus = "banking" if usecac1d == 10
replace empl_byindus = "services" if usecac1d == 11
replace empl_byindus = "services" if usecac1d == 12
replace empl_byindus = "services" if usecac1d == 13
replace empl_byindus = "services" if usecac1d == 14
replace empl_byindus = "services" if usecac1d == 15
replace empl_byindus = "services" if usecac1d == 16
replace empl_byindus = "services" if usecac1d == 17
replace empl_byindus = "services" if usecac1d == 18
*/

*CORRECT UPDATED VERSION
gen empl_byindus = "agriculture" if usecac1d == 0
replace empl_byindus = "industry" if usecac1d == 1
replace empl_byindus = "industry" if usecac1d == 2
replace empl_byindus = "services" if usecac1d == 3
replace empl_byindus = "services" if usecac1d == 4
replace empl_byindus = "construction" if usecac1d == 5
replace empl_byindus = "services" if usecac1d == 6
replace empl_byindus = "transportation" if usecac1d == 7
replace empl_byindus = "food" if usecac1d == 8
replace empl_byindus = "transportation" if usecac1d == 9
replace empl_byindus = "banking" if usecac1d == 10
replace empl_byindus = "banking" if usecac1d == 11
replace empl_byindus = "services" if usecac1d == 12
replace empl_byindus = "services" if usecac1d == 13
replace empl_byindus = "services" if usecac1d == 14
replace empl_byindus = "services" if usecac1d == 15
replace empl_byindus = "services" if usecac1d == 16
replace empl_byindus = "food" if usecac1d == 17
replace empl_byindus = "services" if usecac1d == 18

tab empl_byindus, m 


egen industry_id = group(empl_byindus)
list industry_id empl_byindus 

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

drop if mi(industry_id) 

bys district_iid: egen total_empl_indus = count(empl_byindus)

bys district_iid: egen total_empl_services = count(empl_byindus) if empl_byindus == "services"
gen share_empl_services = 0
bys district_iid: replace share_empl_services = total_empl_services/total_empl_indus
tab share_empl_services

bys district_iid: egen total_empl_agriculture = count(empl_byindus) if empl_byindus == "agriculture"
gen share_empl_agriculture = 0
bys district_iid: replace share_empl_agriculture = total_empl_agriculture/total_empl_indus
tab share_empl_agriculture

bys district_iid: egen total_empl_industry = count(empl_byindus) if empl_byindus == "industry"
gen share_empl_industry = 0
bys district_iid: replace share_empl_industry = total_empl_industry/total_empl_indus
tab share_empl_industry

bys district_iid: egen total_empl_construction = count(empl_byindus) if empl_byindus == "construction"
gen share_empl_construction = 0
bys district_iid: replace share_empl_construction = total_empl_construction/total_empl_indus
tab share_empl_construction

bys district_iid: egen total_empl_transportation = count(empl_byindus) if empl_byindus == "transportation"
gen share_empl_transportation = 0
bys district_iid: replace share_empl_transportation = total_empl_transportation/total_empl_indus
tab share_empl_transportation

bys district_iid: egen total_empl_banking = count(empl_byindus) if empl_byindus == "banking"
gen share_empl_banking = 0
bys district_iid: replace share_empl_banking = total_empl_banking/total_empl_indus
tab share_empl_banking

bys district_iid: egen total_empl_food = count(empl_byindus) if empl_byindus == "food"
gen share_empl_food = 0
bys district_iid: replace share_empl_food = total_empl_food/total_empl_indus
tab share_empl_food

/*keep district_iid industry_id total_empl empl_byindus total_empl_indus ///
        share_empl_services share_empl_agriculture share_empl_industry ///
        share_empl_construction share_empl_transportation share_empl_banking ///
        share_empl_food
*/
egen share_empl_byindus = rsum(share_empl_services share_empl_agriculture ///
        share_empl_industry ///
        share_empl_construction share_empl_transportation share_empl_banking ///
        share_empl_food)


drop if usecac1d == 19 | usecac1d == 20

*CORRECT UPDATED VERSION
gen empl_byindus_orig = "Agriculture, forestry and fishing" if usecac1d == 0
replace empl_byindus_orig = "Mining and quarrying" if usecac1d == 1
replace empl_byindus_orig = "Manufacturing" if usecac1d == 2
replace empl_byindus_orig = "Electricity,gas,steam and air conditioning supply" if usecac1d == 3
replace empl_byindus_orig = "Water supply;sewage,waste management and remediation activities" if usecac1d == 4
replace empl_byindus_orig = "Construction" if usecac1d == 5
replace empl_byindus_orig = "Wholesale and retail trade; repair of motor vehicles and motorcycles" if usecac1d == 6
replace empl_byindus_orig = "Transportation and storage" if usecac1d == 7
replace empl_byindus_orig = "Accomodation and food service activities" if usecac1d == 8
replace empl_byindus_orig = "Information and communication" if usecac1d == 9
replace empl_byindus_orig = "Financial and insurance activities" if usecac1d == 10
replace empl_byindus_orig = "Real estate activities" if usecac1d == 11
replace empl_byindus_orig = "Professional, scientific and technical activities" if usecac1d == 12
replace empl_byindus_orig = "Administrative and support service activities" if usecac1d == 13
replace empl_byindus_orig = "Public administration and defense; compulsory social security" if usecac1d == 14
replace empl_byindus_orig = "Education" if usecac1d == 15
replace empl_byindus_orig = "Human health and social work activities" if usecac1d == 16
replace empl_byindus_orig = "Arts, entertainment and recreation" if usecac1d == 17
replace empl_byindus_orig = "Other service activities" if usecac1d == 18

tab empl_byindus_orig, m 

sort empl_byindus_orig
egen industry_orig_id = group(usecac1d)
tab industry_orig_id

bys district_iid: egen total_empl_indus_orig = count(empl_byindus_orig)

bys district_iid: egen total_empl_orig_agri = count(empl_byindus_orig) if empl_byindus_orig == "Agriculture, forestry and fishing"
gen share_empl_orig_agri = 0
bys district_iid: replace share_empl_orig_agri = total_empl_orig_agri/total_empl_indus_orig
tab share_empl_orig_agri

bys district_iid: egen total_empl_orig_mine = count(empl_byindus_orig) if empl_byindus_orig == "Mining and quarrying"
gen share_empl_orig_mine = 0
bys district_iid: replace share_empl_orig_mine = total_empl_orig_mine/total_empl_indus_orig
tab share_empl_orig_mine

bys district_iid: egen total_empl_orig_manuf = count(empl_byindus_orig) if empl_byindus_orig == "Manufacturing"
gen share_empl_orig_manuf = 0
bys district_iid: replace share_empl_orig_manuf = total_empl_orig_manuf/total_empl_indus_orig
tab share_empl_orig_manuf

bys district_iid: egen total_empl_orig_elec = count(empl_byindus_orig) if empl_byindus_orig == "Electricity,gas,steam and air conditioning supply"
gen share_empl_orig_elec = 0
bys district_iid: replace share_empl_orig_elec = total_empl_orig_elec/total_empl_indus_orig
tab share_empl_orig_elec

bys district_iid: egen total_empl_orig_water = count(empl_byindus_orig) if empl_byindus_orig == "Water supply;sewage,waste management and remediation activities"
gen share_empl_orig_water = 0
bys district_iid: replace share_empl_orig_water = total_empl_orig_water/total_empl_indus_orig
tab share_empl_orig_water

bys district_iid: egen total_empl_orig_const = count(empl_byindus_orig) if empl_byindus_orig == "Construction"
gen share_empl_orig_const = 0
bys district_iid: replace share_empl_orig_const = total_empl_orig_const/total_empl_indus_orig
tab share_empl_orig_const

bys district_iid: egen total_empl_orig_whole = count(empl_byindus_orig) if empl_byindus_orig == "Wholesale and retail trade; repair of motor vehicles and motorcycles"
gen share_empl_orig_whole = 0
bys district_iid: replace share_empl_orig_whole = total_empl_orig_whole/total_empl_indus_orig
tab share_empl_orig_whole

bys district_iid: egen total_empl_orig_transp = count(empl_byindus_orig) if empl_byindus_orig == "Transportation and storage"
gen share_empl_orig_transp = 0
bys district_iid: replace share_empl_orig_transp = total_empl_orig_transp/total_empl_indus_orig
tab share_empl_orig_transp

bys district_iid: egen total_empl_orig_accom = count(empl_byindus_orig) if empl_byindus_orig == "Accomodation and food service activities"
gen share_empl_orig_accom = 0
bys district_iid: replace share_empl_orig_accom = total_empl_orig_accom/total_empl_indus_orig
tab share_empl_orig_accom

bys district_iid: egen total_empl_orig_info = count(empl_byindus_orig) if empl_byindus_orig == "Information and communication"
gen share_empl_orig_info = 0
bys district_iid: replace share_empl_orig_info = total_empl_orig_info/total_empl_indus_orig
tab share_empl_orig_info

bys district_iid: egen total_empl_orig_fi = count(empl_byindus_orig) if empl_byindus_orig == "Financial and insurance activities"
gen share_empl_orig_fi = 0
bys district_iid: replace share_empl_orig_fi = total_empl_orig_fi/total_empl_indus_orig
tab share_empl_orig_fi

bys district_iid: egen total_empl_orig_real = count(empl_byindus_orig) if empl_byindus_orig == "Real estate activities"
gen share_empl_orig_real = 0
bys district_iid: replace share_empl_orig_real = total_empl_orig_real/total_empl_indus_orig
tab share_empl_orig_real

bys district_iid: egen total_empl_orig_pro = count(empl_byindus_orig) if empl_byindus_orig == "Professional, scientific and technical activities"
gen share_empl_orig_pro  = 0
bys district_iid: replace share_empl_orig_pro  = total_empl_orig_pro /total_empl_indus_orig
tab share_empl_orig_pro 

bys district_iid: egen total_empl_orig_admin = count(empl_byindus_orig) if empl_byindus_orig == "Administrative and support service activities"
gen share_empl_orig_admin = 0
bys district_iid: replace share_empl_orig_admin = total_empl_orig_admin/total_empl_indus_orig
tab share_empl_orig_admin

bys district_iid: egen total_empl_orig_public = count(empl_byindus_orig) if empl_byindus_orig == "Public administration and defense; compulsory social security"
gen share_empl_orig_public = 0
bys district_iid: replace share_empl_orig_public = total_empl_orig_public/total_empl_indus_orig
tab share_empl_orig_public

bys district_iid: egen total_empl_orig_educ = count(empl_byindus_orig) if empl_byindus_orig == "Education"
gen share_empl_orig_educ = 0
bys district_iid: replace share_empl_orig_educ = total_empl_orig_educ/total_empl_indus_orig
tab share_empl_orig_educ

bys district_iid: egen total_empl_orig_hum = count(empl_byindus_orig) if empl_byindus_orig == "Human health and social work activities"
gen share_empl_orig_hum = 0
bys district_iid: replace share_empl_orig_hum = total_empl_orig_hum/total_empl_indus_orig
tab share_empl_orig_hum

bys district_iid: egen total_empl_orig_art = count(empl_byindus_orig) if empl_byindus_orig == "Arts, entertainment and recreation"
gen share_empl_orig_art = 0
bys district_iid: replace share_empl_orig_art = total_empl_orig_art/total_empl_indus_orig
tab share_empl_orig_art

bys district_iid: egen total_empl_orig_oth = count(empl_byindus_orig) if empl_byindus_orig == "other service activities"
gen share_empl_orig_oth = 0
bys district_iid: replace share_empl_orig_oth = total_empl_orig_oth/total_empl_indus_orig
tab share_empl_orig_oth
/*
keep district_iid industry_id total_empl empl_byindus total_empl_indus ///
        share_empl_services share_empl_agriculture share_empl_industry ///
        share_empl_construction share_empl_transportation share_empl_banking ///
        share_empl_food
*/
egen share_empl_byindus_orig = rsum(share_empl_orig_agri share_empl_orig_mine ///
        share_empl_orig_manuf share_empl_orig_elec share_empl_orig_water ///
        share_empl_orig_const share_empl_orig_whole share_empl_orig_transp ///
        share_empl_orig_accom share_empl_orig_info share_empl_orig_fi ///
        share_empl_orig_real share_empl_orig_pro share_empl_orig_admin ///
        share_empl_orig_public share_empl_orig_educ share_empl_orig_hum ///
        share_empl_orig_art share_empl_orig_oth)

preserve
keep district_iid industry_id total_empl empl_byindus total_empl_indus ///
        share_empl_byindus

duplicates drop district_iid empl_byindus, force
sort district_iid industry_id
drop if mi(empl_byindus)
distinct district_iid

save "$data_temp/09_Share_empl_byDist_byIndus.dta", replace
restore

preserve 
keep district_iid industry_orig_id total_empl empl_byindus_orig total_empl_indus_orig ///
        share_empl_byindus_orig

duplicates drop district_iid empl_byindus_orig, force
drop if mi(empl_byindus_orig)
distinct district_iid

save "$data_temp/09_Share_empl_byDist_byIndus_ORIG.dta", replace

restore

*Missing 17 because that disrict was probably not surveyed in 2010
















/*


/**************
THE INSTRUMENT ORIGINAL
**************/


use "$data_temp/04_IV_Share_Empl_Syria", clear 

*sort district_en
*egen district_iid = group(district_en) 

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
egen district_iid = group(district_en) 

list id_gov_syria governorate_syria
sort district_en governorate_syria industry_id

tab industry_en industry_id
drop industry_id 
egen industry_id = group(industry_en)

*merge m:1 industry_id using  "$data_UNHCR_temp/UNHCR_shift_byOccup.dta"
merge m:1 industry_id using  "$data_temp/05_IV_shift_byIndus.dta"
drop _merge 
ren share share_empl_syr 

merge m:m industry_id district_iid using "$data_temp/09_Share_empl_byDist_byIndus.dta",
drop _merge 

*drop if district_iid == 17 
replace share_empl_byindus = 0.00001 if mi(share_empl_byindus) &  district_iid != 17
tab share_empl_byindus, m 

gen diff_share = (share_empl_syr - share_empl_byindus)^0.5 * share_empl_byindus
tab diff_share, m 

order id_gov_syria governorate_syria district_iid ///
		district_en industry_id industry_en share_empl_syr wp_2016

lab var id_gov_syria "ID Governorate Syria"
lab var governorate_syria "Name Governorate Syria"
lab var district_iid "ID District Jordan"
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

merge m:1 district_iid using "$data_final/10_JLMPS_Distance_Zaatari.dta", keepusing(distance_dis_camp) 


****************
****************
  *  SS IV  *
****************
****************

 

*WORKING MODELS
gen IV_SS = (wp_2016                             ) / (distance_dis_camp)  
gen IV_SS_OP = (wp_2016 * nb_ref_syr_bygov_2016                              ) / (distance_dis_camp)  
*gen IV_SS_2 = (wp_2016 * nb_ref_syr_bygov_2016 * diff_share * share_emplOpen) / (distance_dis_camp)  
*gen IV_SS_3 = (wp_2016 * nb_ref_syr_bygov_2016 * diff_share                 ) / (distance_dis_camp * distance_dis_gov) 
*gen IV_SS_4 = (wp_2016 * nb_ref_syr_bygov_2016 * diff_share * share_emplOpen) / (distance_dis_camp * distance_dis_gov)


tab IV_SS, m 
tab IV_SS_OP, m 

collapse (sum) IV_SS IV_SS_OP , by(district_en)
lab var IV_SS "IV: Shift Share"

*ren IV_SS IV_SS_OP

tab district_en
sort district_en
egen district_iid = group(district_en) 


save "$data_final/03_ShiftShare_IV", replace 

*/



/**************
THE INSTRUMENT : IV1
**************/

/* IV 1 : Layman term: Expected demand for work P at destination
IV1: 1/Dist_camp_d* Nbr WP_t
Layman term: Expected demand for work P at destination

Story : We start with the Fallah e al. IV augmented by the number of work permits allocated in Jordan 
*/

use "$data_final/10_JLMPS_Distance_Zaatari.dta" , clear

lab var district_iid "ID District Jordan"
gen wp_2016 = 73580
lab var wp_2016 "WP 2016 in Jordan by industry"

sort district_iid governorate_iid

*WORKING MODELS
gen IV_SS_1 = (wp_2016) / (distance_dis_camp)  

tab IV_SS_1, m 

collapse (sum) IV_SS_1, by(district_en)
lab var IV_SS_1 "IV: Shift Share"

*ren IV_SS IV_SS_OP

tab district_en
sort district_en
egen district_iid = group(district_en) 

drop if district_en == "Husseiniyyeh District"
distinct district_iid
save "$data_final/03_ShiftShare_IV_1", replace 



/**************
THE INSTRUMENT : IV2
**************/

/* IV2: Nbr_refugees_t * 1/Dist_camp_d* Nbr WP_t
Layman term: Expected demand for work P at destination

Story: Augmented by the number of refugees since it will affect the demand for work permits
*/

use "$data_final/10_JLMPS_Distance_Zaatari.dta" , clear

lab var district_iid "ID District Jordan"
gen wp_2016 = 73580
lab var wp_2016 "WP 2016 in Jordan by industry"

sort district_iid

*WORKING MODELS
gen IV_SS_2 = (wp_2016*ln_nb_refugees_bygov) / (distance_dis_camp)  

tab IV_SS_2, m 

collapse (sum) IV_SS_2, by(district_en)
lab var IV_SS_2 "IV: Shift Share"

tab district_en
sort district_en
egen district_iid = group(district_en) 

drop if district_en == "Husseiniyyeh District"
distinct district_iid

save "$data_final/03_ShiftShare_IV_2", replace 





/**************
THE INSTRUMENT : IV3
**************/

/* IV3: [Nbr_refugees_ot* 1/dist_od] * [1/Dist_camp_d* Nbr WP_t]
Layman term: Expected demand for work P at destination

Story: Augmented by the number of refugees by destination district since it will affect the demand for work permits
*/

use "$data_temp/04_IV_Share_Empl_Syria", clear 

*Distance between governorates syria and districts jordan
geodist district_lat district_long gov_syria_lat gov_syria_long, gen(distance_dis_gov)
tab distance_dis_gov, m
lab var distance_dis_gov "Distance (km) between JORD districts and SYR centroid governorates"

unique distance_dis_gov //714

drop district_long district_lat gov_syria_long gov_syria_lat
sort district_en governorate_syria 

drop id_district_jordan 
egen district_iid = group(district_en) 

list id_gov_syria governorate_syria
sort district_en governorate_syria industry_id

tab industry_en industry_id
drop industry_id 
egen industry_id = group(industry_en)


merge m:1 district_iid using "$data_final/10_JLMPS_Distance_Zaatari.dta" 

lab var district_iid "ID District Jordan"
gen wp_2016 = 73580
lab var wp_2016 "WP 2016 in Jordan by industry"

sort district_iid

*WORKING MODELS
gen IV_SS_3 = (ln_nb_refugees_bygov/distance_dis_gov) * (wp_2016/distance_dis_camp)  

tab IV_SS_3, m 

collapse (sum) IV_SS_3, by(district_en)
lab var IV_SS_3 "IV: Shift Share"

tab district_en
sort district_en
egen district_iid = group(district_en) 

drop if district_en == "Husseiniyyeh District"
distinct district_iid

save "$data_final/03_ShiftShare_IV_3", replace 
















/**************
THE INSTRUMENT : IV4
**************/

/*
IV4: [Nbr_refugees_ot* 1/dist_od] * [1/Dist_camp_d* Nbr WP_t] * [Nbr WP_st * (Txemploi_s,d)]
Story: Augmented by the number of refugees by destination district since it will affect the demand 
for work permits and the sector composition at destination to approximate for expected supply of WP
Advantage using Jordanian sector
*/

use "$data_temp/04_IV_Share_Empl_Syria", clear 

*Distance between governorates syria and districts jordan
geodist district_lat district_long gov_syria_lat gov_syria_long, gen(distance_dis_gov)
tab distance_dis_gov, m
lab var distance_dis_gov "Distance (km) between JORD districts and SYR centroid governorates"

unique distance_dis_gov //714

drop district_long district_lat gov_syria_long gov_syria_lat
sort district_en governorate_syria 

drop id_district_jordan 
egen district_iid = group(district_en) 

list id_gov_syria governorate_syria
sort district_en governorate_syria industry_id
keep if industry_id == 1 

drop industry_en industry_id share

merge m:1 gov using "$data_temp/08_Share_empl_byGov_byIndus_ORIG_WP.dta"
drop _merge 


merge m:1 district_iid using "$data_final/10_JLMPS_Distance_Zaatari.dta" 
*drop if _merge == 2 
drop _merge 

lab var district_iid "ID District Jordan"
gen wp_2016_total = 73580
lab var wp_2016_total "WP 2016 in Jordan by industry"

sort district_iid

*WORKING MODELS
gen IV_SS_4 = (ln_nb_refugees_bygov/distance_dis_gov) * (wp_2016_total/distance_dis_camp) * inter_wp_empl 

tab IV_SS_4, m 

collapse (sum) IV_SS_4, by(district_en)
lab var IV_SS_4 "IV: Shift Share"

tab district_en
sort district_en
egen district_iid = group(district_en) 

drop if district_en == "Husseiniyyeh District"
distinct district_iid

save "$data_final/03_ShiftShare_IV_4", replace 








/**************
THE INSTRUMENT : IV5
**************/

/*
IV5: [Nbr_refugees_ot* 1/dist_od] * [1/Dist_camp_d* Nbr WP_t] * 
[Nbr WP_st * (Txemploi_s,o- Txemploi_s,d)^0.5]]

Layman term: Expected demand for work augmented with expected skill matching between origin 
and destination
*/

use "$data_temp/04_IV_Share_Empl_Syria", clear 

*Distance between governorates syria and districts jordan
geodist district_lat district_long gov_syria_lat gov_syria_long, gen(distance_dis_gov)
tab distance_dis_gov, m
lab var distance_dis_gov "Distance (km) between JORD districts and SYR centroid governorates"

unique distance_dis_gov //714

drop district_long district_lat gov_syria_long gov_syria_lat
sort district_en governorate_syria 

drop id_district_jordan 
egen district_iid = group(district_en) 

list id_gov_syria governorate_syria
sort district_en governorate_syria industry_id

tab industry_en industry_id
drop industry_id 
egen industry_id = group(industry_en)

*merge m:1 industry_id using  "$data_UNHCR_temp/UNHCR_shift_byOccup.dta"
merge m:1 industry_id using  "$data_temp/05_IV_shift_byIndus.dta"
drop _merge 
ren share share_empl_syr 

*merge m:m industry_id district_iid using "$data_temp/09_Share_empl_byDist_byIndus.dta",
*drop _merge 

merge m:1 gov industry_id using "$data_temp/08_Share_empl_Jordan_byGov_byIndus"
drop _merge 

*drop if district_iid == 17 
*replace share_empl_byindus = 0.00001 if mi(share_empl_byindus) &  district_iid != 17
*tab share_empl_byindus, m 

*gen diff = abs(share_empl_syr - share_empl_byindus)
gen diff_share = (abs(share_empl_syr - share_empl)^0.5) * share_empl
tab diff_share, m 

order id_gov_syria governorate_syria district_iid ///
    district_en industry_id industry_en share_empl_syr wp_2016

lab var id_gov_syria "ID Governorate Syria"
lab var governorate_syria "Name Governorate Syria"
lab var district_iid "ID District Jordan"
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

merge m:1 district_iid using "$data_final/10_JLMPS_Distance_Zaatari.dta",
drop _merge

merge m:1 governorate_iid using "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta"
drop _merge

lab var district_iid "ID District Jordan"
gen wp_2016_total = 73580
lab var wp_2016_total "WP 2016 in Jordan by industry"

sort district_iid

*WORKING MODELS
gen IV_SS_5 = (ln_nb_refugees_bygov/distance_dis_gov) * (wp_2016_total/distance_dis_camp) * wp_2016 * diff_share 

tab IV_SS_5, m 

collapse (sum) IV_SS_5, by(district_en)
lab var IV_SS_5 "IV: Shift Share"

tab district_en
sort district_en
egen district_iid = group(district_en) 

drop if district_en == "Husseiniyyeh District"
distinct district_iid

save "$data_final/03_ShiftShare_IV_5", replace 
















/**************
THE INSTRUMENT : IV6
**************/

/*
IV6: 
[Nbr_refugees_ot* 1/dist_od] * [1/Dist_camp_d* Nbr WP_t] 
AND
[Nbr WP_st * (Txemploi_s,o- Txemploi_s,d)^0.5]]

  Decomposition of IV5
*/

use "$data_temp/04_IV_Share_Empl_Syria", clear 

*Distance between governorates syria and districts jordan
geodist district_lat district_long gov_syria_lat gov_syria_long, gen(distance_dis_gov)
tab distance_dis_gov, m
lab var distance_dis_gov "Distance (km) between JORD districts and SYR centroid governorates"

unique distance_dis_gov //714

drop district_long district_lat gov_syria_long gov_syria_lat
sort district_en governorate_syria 

drop id_district_jordan 
egen district_iid = group(district_en) 

list id_gov_syria governorate_syria
sort district_en governorate_syria industry_id

tab industry_en industry_id
drop industry_id 
egen industry_id = group(industry_en)

*merge m:1 industry_id using  "$data_UNHCR_temp/UNHCR_shift_byOccup.dta"
merge m:1 industry_id using  "$data_temp/05_IV_shift_byIndus.dta"
drop _merge 
ren share share_empl_syr 

*merge m:m industry_id district_iid using "$data_temp/09_Share_empl_byDist_byIndus.dta",
*drop _merge 

merge m:1 gov industry_id using "$data_temp/08_Share_empl_Jordan_byGov_byIndus"
drop _merge 

*drop if district_iid == 17 
*replace share_empl_byindus = 0.00001 if mi(share_empl_byindus) &  district_iid != 17
*tab share_empl_byindus, m 

*gen diff = abs(share_empl_syr - share_empl_byindus)
gen diff_share = (abs(share_empl_syr - share_empl)^0.5) * share_empl
tab diff_share, m 

order id_gov_syria governorate_syria district_iid ///
    district_en industry_id industry_en share_empl_syr wp_2016

lab var id_gov_syria "ID Governorate Syria"
lab var governorate_syria "Name Governorate Syria"
lab var district_iid "ID District Jordan"
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

merge m:1 district_iid using "$data_final/10_JLMPS_Distance_Zaatari.dta",
drop _merge

merge m:1 governorate_iid using "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta"
drop _merge

lab var district_iid "ID District Jordan"
gen wp_2016_total = 73580
lab var wp_2016_total "WP 2016 in Jordan by industry"

sort district_iid

*WORKING MODELS
gen IV_SS_6A = (ln_nb_refugees_bygov/distance_dis_gov) * (wp_2016_total/distance_dis_camp) 
gen IV_SS_6B =  wp_2016 * diff_share 

tab IV_SS_6A, m 
tab IV_SS_6B, m 

collapse (sum) IV_SS_6A IV_SS_6B, by(district_en)
lab var IV_SS_6A "IVA: Shift Share"
lab var IV_SS_6B "IVB: Shift Share"

tab district_en
sort district_en
egen district_iid = group(district_en) 

drop if district_en == "Husseiniyyeh District"
distinct district_iid

save "$data_final/03_ShiftShare_IV_6", replace 


































use "$data_final/10_JLMPS_Distance_Zaatari.dta" , clear

lab var district_iid "ID District Jordan"
gen wp_2016 = 73580
lab var wp_2016 "WP 2016 in Jordan by industry"

sort district_iid

****************
****************
  *  SS IV  *
****************
****************

merge m:1 governorate_iid using "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta"
drop _merge



*********************
** NUMBER REFUGEES **
*********************

tab NbRefbyGovoutcamp, m
ren NbRefbyGovoutcamp nb_refugees_bygov
replace nb_refugees_bygov = 0 if year == 2010
lab var nb_refugees_bygov "[CTRL] Number of refugees out of camps by governorate in 2016"
tab nb_refugees_bygov

gen ln_nb_refugees_bygov = ln(1 + nb_refugees_bygov) 
*if year == 2016
*replace ln_nb_refugees_bygov = 0 if year == 2010

lab var ln_nb_refugees_bygov "[CTRL] LOG Number of refugees out of camps by governorate in 2016"
*ln_ref, as of now, does not include refugees in 2010, only in 2016

****** Other
gen IHS_nb_refugees_bygov = log(nb_refugees_bygov + ((nb_refugees_bygov^2 + 1)^0.5))
lab var IHS_nb_refugees_bygov "IHS - Number of refugees out of camps by governorate in 2016"



log close

*use "$data_final/03_ShiftShare_IV", clear 

