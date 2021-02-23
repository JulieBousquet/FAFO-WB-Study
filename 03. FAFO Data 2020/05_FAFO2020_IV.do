


cap log close
clear all
set more off, permanently
set mem 100m

*log using "$analysis_do/01_Data_Cleaning_EL1.log", replace

	****************************************************************************
	**                            DATA IV CREATION                            **  
	** ---------------------------------------------------------------------- **
	** Type Do  : 	DATA IV FAFO                                              **
  	**                                                                        **
	** Authors  : Julie Bousquet                                              **
	****************************************************************************


/*
Share
Number of refguees coming from gov X in syra and residing in Jordan
*/
use "$data_2020_final/Jordan2020_02_Clean.dta", clear
tab QR117, m
bys refugee: tab QR117, m

/*
  Syrian governorate live before |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
                      Al Hasakah |          5        0.74        0.74
                          Aleppo |         74       10.93       11.67
                       Al Raqqah |          6        0.89       12.56
                      Al Suwayda |          1        0.15       12.70
                           Daraa |        224       33.09       45.79
                    Deir El Zour |          2        0.30       46.09
                            Hama |         27        3.99       50.07
                            Homs |        197       29.10       79.17
                           Idlib |          6        0.89       80.06
                        Quneitra |          3        0.44       80.50
                  Rural Damascus |         37        5.47       85.97
                        Damascus |         65        9.60       95.57
                               . |         30        4.43      100.00
---------------------------------+-----------------------------------
                           Total |        677      100.00
*/


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

/*
preserve
gen share_1 = agriculture / total
gen share_2 = factory / total
gen share_3 = construction / total
gen share_4 = trade / total
gen share_5 = transportation / total
gen share_6 = banking / total
gen share_7 = services / total

reshape long share_ , i(governorate_syria) j(id_indus)
ren share_ share_empl_syr
gen industry = ""
replace industry = "agriculture" if id_indus == 1 
replace industry = "factory" if id_indus == 2 
replace industry = "construction" if id_indus == 3 
replace industry = "trade" if id_indus == 4 
replace industry = "transportation" if id_indus == 5 
replace industry = "banking" if id_indus == 6 
replace industry = "services" if id_indus == 7 

lab def id_indus 	1 "agriculture" ///
					2 "factory" ///
					3 "construction" ///
					4 "trade" ///
					5 "transportation" ///
					6 "banking" ///
					7 "services" ///
					, modify
lab val id_indus id_indus

order id_gov_syria governorate_syria id_indus industry share_empl_syr total_empl_syr
sort id_gov_syria id_indus

lab var id_gov_syria "ID Governorate Syria"
lab var id_indus "ID Industry Syria"
lab var industry "Name Industry Syria"
lab var share_empl_syr "Employment Share in Syria, 2010, out of total employed in all industries, by gov"
lab var total_empl_syr "Total employment, 2010"

replace share_empl_syr = share_empl_syr*100
 graph bar share_empl_syr, ///
  over(industry, sort(1) descending label(angle(ninety))) ///
  blabel(bar, format(%3.2g)) ///
  title("Employment by industry in Syria") ///
  subtitle("In Percentage") ///
  note("LFS, 2010")
graph export "$out_2020/bar_indus_origin.pdf", as(pdf) replace

graph bar (mean) share_empl_syr, over(industry, sort(1) descending ///
 label(angle(ninety))) asyvars by(governorate_syria) ///
  by(,note("LFS 2010; In Percentage")) ///
by(, title("Employment by industry in Syria"))
graph export "$out_2020/bar_indus_origin_bygov.pdf", as(pdf) replace

restore

*/

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

save "$data_2020_final/governorate_indus_syr_emplshare.dta", replace

/*
Distance between Syrian governoarate (fronteer or centroid or largest city?) AND
Jordan district of residence
*/

/*
shp2dta using "$data_LFS_shp/gadm36_SYR_1.shp", ///
  database("$data_LFS_temp/syr_adm1") ///
  coordinates("$data_LFS_temp/syr_coord1") ///
  genid(id_region) replace
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
preserve
ren governorate_syria govs_1 
ren gov_syria_long govs_long_1
ren gov_syria_lat govs_lat_1
gen id_gov_syria_1 = 1
tempfile district_1 
save `district_1'
restore 

preserve
ren governorate_syria govs_2
ren gov_syria_long govs_long_2
ren gov_syria_lat govs_lat_2
gen id_gov_syria_2 = 2
tempfile district_2 
save `district_2'
restore 

preserve
ren governorate_syria govs_3
ren gov_syria_long govs_long_3
ren gov_syria_lat govs_lat_3
gen id_gov_syria_3 = 3
tempfile district_3 
save `district_3'
restore 

preserve
ren governorate_syria govs_4
ren gov_syria_long govs_long_4
ren gov_syria_lat govs_lat_4
gen id_gov_syria_4 = 4
tempfile district_4 
save `district_4'
restore 

preserve
ren governorate_syria govs_5
ren gov_syria_long govs_long_5
ren gov_syria_lat govs_lat_5
gen id_gov_syria_5 = 5
tempfile district_5 
save `district_5'
restore 

preserve
ren governorate_syria govs_6
ren gov_syria_long govs_long_6
ren gov_syria_lat govs_lat_6
gen id_gov_syria_6 = 6
tempfile district_6 
save `district_6'
restore 

preserve
ren governorate_syria govs_7
ren gov_syria_long govs_long_7
ren gov_syria_lat govs_lat_7
gen id_gov_syria_7 = 7
tempfile district_7 
save `district_7'
restore 

preserve
ren governorate_syria govs_8
ren gov_syria_long govs_long_8
ren gov_syria_lat govs_lat_8
gen id_gov_syria_8 = 8
tempfile district_8 
save `district_8'
restore 

preserve
ren governorate_syria govs_9
ren gov_syria_long govs_long_9
ren gov_syria_lat govs_lat_9
gen id_gov_syria_9 = 9
tempfile district_9 
save `district_9'
restore 

preserve
ren governorate_syria govs_10
ren gov_syria_long govs_long_10
ren gov_syria_lat govs_lat_10
gen id_gov_syria_10 = 10
tempfile district_10 
save `district_10'
restore

*use "$data_2020_final/Jordan2020_02_Clean.dta", clear
use "$data_2020_temp/Jordan2020_03_Compared.dta", clear


tab governorate 
/*
11 Amman
13 Zarqa
21 Irbid
22 Mafraq
*/
lab def governorate 11 "Amman" ///
                    13 "Zarqa" ///
                    21 "Irbid" ///
                    22 "Mafraq" ///
                    , modify
lab val governorate governorate 

tab district_en, m 
tab district_lat, m
tab district_long, m
tab sub_district_en, m  
tab locality_en, m 
tab area_en, m 

keep district_en  district_lat district_long
duplicates drop district_en , force
tab district_en 
*bys refugee: tab QR117, m
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

egen governorate_syria = concat(govs_9 govs_8 govs_7 govs_6 govs_5 govs_4 govs_3 govs_2 govs_10 govs_1)
egen gov_syria_long = rsum(govs_long_9 govs_long_8 govs_long_7 govs_long_6 govs_long_5 govs_long_4 govs_long_3 govs_long_2 govs_long_10 govs_long_1)
egen gov_syria_lat = rsum(govs_lat_9 govs_lat_8 govs_lat_7 govs_lat_6 govs_lat_5 govs_lat_4 govs_lat_3 govs_lat_2 govs_lat_10 govs_lat_1)
tab governorate_syria, m
tab gov_syria_long, m
tab gov_syria_lat, m

keep governorate_syria gov_syria_long gov_syria_lat district_en district_lat district_long

save "$data_2020_final/Jordan2020_geo_Syria.dta", replace 


use "$data_2020_final/Jordan2020_geo_Syria.dta", clear 

sort governorate_syria district_en
egen id_gov_syria = group(governorate_syria)
gen id_district_jordan = _n 

levelsof id_gov_syria, local(gov_lev)
levelsof id_district_jordan, local(dis_lev)
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

use "$data_2020_final/governorate_indus_syr_emplshare.dta", clear

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 1(1)10 {
    preserve 
    keep if id_gov_syria == 1 
    merge m:1 id_gov_syria using `gov_1_dist_`jdis''
    drop _merge
    tempfile gov_1_dist_`jdis'
    save `gov_1_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 11(1)20 {
    preserve 
    keep if id_gov_syria == 2 
    merge m:1 id_gov_syria using `gov_2_dist_`jdis''
    drop _merge
    tempfile gov_2_dist_`jdis'
    save `gov_2_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 21(1)30 {
    preserve 
    keep if id_gov_syria == 3 
    merge m:1 id_gov_syria using `gov_3_dist_`jdis''
    drop _merge
    tempfile gov_3_dist_`jdis'
    save `gov_3_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 31(1)40 {
    preserve 
    keep if id_gov_syria == 4 
    merge m:1 id_gov_syria using `gov_4_dist_`jdis''
    drop _merge
    tempfile gov_4_dist_`jdis'
    save `gov_4_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 41(1)50 {
    preserve 
    keep if id_gov_syria == 5 
    merge m:1 id_gov_syria using `gov_5_dist_`jdis''
    drop _merge
    tempfile gov_5_dist_`jdis'
    save `gov_5_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 51(1)60 {
    preserve 
    keep if id_gov_syria == 6 
    merge m:1 id_gov_syria using `gov_6_dist_`jdis''
    drop _merge
    tempfile gov_6_dist_`jdis'
    save `gov_6_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 61(1)70 {
    preserve 
    keep if id_gov_syria == 7 
    merge m:1 id_gov_syria using `gov_7_dist_`jdis''
    drop _merge
    tempfile gov_7_dist_`jdis'
    save `gov_7_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 71(1)80 {
    preserve 
    keep if id_gov_syria == 8 
    merge m:1 id_gov_syria using `gov_8_dist_`jdis''
    drop _merge
    tempfile gov_8_dist_`jdis'
    save `gov_8_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 81(1)90 {
    preserve 
    keep if id_gov_syria == 9 
    merge m:1 id_gov_syria using `gov_9_dist_`jdis''
    drop _merge
    tempfile gov_9_dist_`jdis'
    save `gov_9_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 91(1)100 {
    preserve 
    keep if id_gov_syria == 10 
    merge m:1 id_gov_syria using `gov_10_dist_`jdis''
    drop _merge
    tempfile gov_10_dist_`jdis'
    save `gov_10_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 101(1)110 {
    preserve 
    keep if id_gov_syria == 11 
    merge m:1 id_gov_syria using `gov_11_dist_`jdis''
    drop _merge
    tempfile gov_11_dist_`jdis'
    save `gov_11_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 111(1)120 {
    preserve 
    keep if id_gov_syria == 12 
    merge m:1 id_gov_syria using `gov_12_dist_`jdis''
    drop _merge
    tempfile gov_12_dist_`jdis'
    save `gov_12_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 121(1)130 {
    preserve 
    keep if id_gov_syria == 13 
    merge m:1 id_gov_syria using `gov_13_dist_`jdis''
    drop _merge
    tempfile gov_13_dist_`jdis'
    save `gov_13_dist_`jdis''
    restore 
  }

levelsof id_gov_syria, local(gov_lev)
  qui forvalues jdis = 131(1)140 {
    preserve 
    keep if id_gov_syria == 14 
    merge m:1 id_gov_syria using `gov_14_dist_`jdis''
    drop _merge
    tempfile gov_14_dist_`jdis'
    save `gov_14_dist_`jdis''
    restore 
  }




use `gov_1_dist_1', clear 
  qui forvalues jdis = 2(1)10 {
    append using `gov_1_dist_`jdis''
  } 

append using `gov_2_dist_1' 
  qui forvalues jdis = 11(1)20 {
    append using `gov_2_dist_`jdis''
  } 

append using `gov_3_dist_1' 
  qui forvalues jdis = 21(1)30 {
    append using `gov_3_dist_`jdis''
  } 

append using `gov_4_dist_1' 
  qui forvalues jdis = 31(1)40 {
    append using `gov_4_dist_`jdis''
  } 

append using `gov_5_dist_1' 
  qui forvalues jdis = 41(1)50 {
    append using `gov_5_dist_`jdis''
  } 

append using `gov_6_dist_1' 
  qui forvalues jdis = 51(1)60 {
    append using `gov_6_dist_`jdis''
  } 

append using `gov_7_dist_1' 
  qui forvalues jdis = 61(1)70 {
    append using `gov_7_dist_`jdis''
  } 

append using `gov_8_dist_1' 
  qui forvalues jdis = 71(1)80 {
    append using `gov_8_dist_`jdis''
  } 

append using `gov_9_dist_1' 
  qui forvalues jdis = 81(1)90 {
    append using `gov_9_dist_`jdis''
  } 

append using `gov_10_dist_1' 
  qui forvalues jdis = 91(1)100 {
    append using `gov_10_dist_`jdis''
  } 

append using `gov_11_dist_1' 
  qui forvalues jdis = 101(1)110 {
    append using `gov_11_dist_`jdis''
  } 

append using `gov_12_dist_1' 
  qui forvalues jdis = 111(1)120 {
    append using `gov_12_dist_`jdis''
  } 

append using `gov_13_dist_1' 
  qui forvalues jdis = 121(1)130 {
    append using `gov_13_dist_`jdis''
  } 

append using `gov_14_dist_1' 
  qui forvalues jdis = 131(1)140 {
    append using `gov_14_dist_`jdis''
  } 

save "$data_2020_final/Jordan2020_geo_Syria_empl_Syria", replace


use "$data_2020_final/governorate_indus_syr_emplshare.dta", clear

/*
***************************
******** MAPPING **********
***************************

preserve
keep district_en district_lat district_long
duplicates drop district_en, force 
ren district_en geo_unit 
ren district_long geo_long 
ren district_lat geo_lat
tempfile district_geo 
save `district_geo'
restore 
preserve 
keep governorate_syria gov_syria_long gov_syria_lat
duplicates drop governorate_syria, force 
ren governorate_syria geo_unit 
ren gov_syria_long geo_long 
ren gov_syria_lat geo_lat
tempfile gov_syria_geo
save `gov_syria_geo'
restore 

use  `district_geo', clear 
gen gunit = "Districts"
append using `gov_syria_geo'
replace gunit = "Governorates" if mi(gunit) & (geo_unit != "-99 Missing" & ///
                                             geo_unit != "-98 Non Applicable")
drop if geo_unit == "-99 Missing" 
drop if geo_unit == "-98 Non Applicable" 

encode gunit, gen(unit)

save "$data_2020_temp/Jordan2020_geo.dta", replace 



*ssc install geodist
*h geodist

**** MAP OF JORDAN AND SYRIA (VIZUALIZING DISTANCE)
use "$data_LFS_temp/governorate_names.dta", clear
spmap using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(eggshell) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Number of project", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    ///
   point(data("$data_2020_temp/Jordan2020_geo.dta") xcoord(geo_long)      ///
        ycoord(geo_lat) by(unit) size(*0.7) fcolor(red blue))

graph export "$out_2020/map_districtJOR_ALLgovSYR.pdf", as(pdf) replace

********************************
*/

/*
SHIFT 
*/


/*
import excel "$data_UNHCR_base\Datasets_WP_RegisteredSyrians.xlsx", sheet("WP_REF - byGov byYear") firstrow clear

/* Data collected by hand

*WP_Registered - byYear 
Sheet for the number of work permit per year, and the number of 
registered refugee per year. Aim is to compute the share of 
refugees with work permit every year

*RegisteredRef - byMonth
Sheet with the number of refugees every month since 2016. 
With a separation by whether they are in the camps or 
in urban areas.

*WP - byIndustry
WP by Industry for 2016, 2017, 2018, 2019 and 2020.

*WP - byGov
WP every other months and by governorate of interest (Amman,
Irbid, Zarqa, Mafraq)

*WP_REF - byGov byYear
Number of refugees with WP and number of refugee ; from 2015 to 2020 ;
per gorvernorate
*/

ren Year year
ren Governorates governorate_en
ren NbRefugeesoutcamp nb_refugee_bygov
ren TotalRefoutcamp tot_refugee
ren NbofWP nb_wp_bygov
ren TotalWP tot_wp

lab var year "Year"
lab var governorate "Governorate"
lab var nb_refugee_bygov "Number of refugees outside camps, by governorate by year"
lab var tot_refugee "Total number of refugee by year"
lab var nb_wp_bygov "Number of work permits, bu governroate by year"
lab var tot_wp "Total number of work permit, by year"

sort year governorate
gen share_wp = nb_wp_bygov / nb_refugee_bygov


gen governorate = . 
replace governorate = 11 if governorate_en == "Amman"
replace governorate = 13 if governorate_en == "Zarqa"
replace governorate = 21 if governorate_en == "Irbid"
replace governorate = 22 if governorate_en == "Mafraq"
/*
11 Amman
13 Zarqa
21 Irbid
22 Mafraq
*/
lab def governorate 11 "Amman" ///
                    13 "Zarqa" ///
                    21 "Irbid" ///
                    22 "Mafraq" ///
                    , modify
lab val governorate governorate 

*TRHEE OPTIONS
*1) Mean number of WP, per gov
*collapse (mean) nb_wp_bygov, by(governorate)
*2) Mean share of WP per refugee, per gov
*collapse (mean) share_wp, by(governorate)
*3) Keep share of wp in year 2020
keep if year == 2020
codebook governorate 
save "$data_2020_temp/UNHCR_shift_byGov.dta", replace 
*/

import excel "$data_UNHCR_base\Datasets_WP_RegisteredSyrians.xlsx", sheet("WP - byIndustry") firstrow clear

keep year_2020 Activity

ren year_2020 wp_2020
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

collapse (sum) wp_2020, by(industry_en)
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
save "$data_2020_temp/UNHCR_shift_byOccup.dta", replace 

/**************
THE INSTRUMENT 
**************/

use "$data_2020_final/Jordan2020_geo_Syria_empl_Syria", clear 

*use "$data_2020_final/Jordan2020_geo_Syria.dta", clear 
*tab id_gov_syria

geodist district_lat district_long gov_syria_lat gov_syria_long, gen(distance_dis_gov)
tab distance_dis_gov, m
lab var distance_dis_gov "Distance (km) between JORD districts and SYR centroid governorates"

unique distance_dis_gov //140

drop district_long district_lat gov_syria_long gov_syria_lat
sort district_en governorate_syria 

drop id_district_jordan 
egen id_district_jordan = group(district_en) 

list id_gov_syria governorate_syria
sort district_en governorate_syria industry_id

tab industry_en industry_id
drop industry_id 
egen industry_id = group(industry_en)

merge m:1 industry_id using  "$data_2020_temp/UNHCR_shift_byOccup.dta"
drop _merge 

ren share share_empl_syr 

order id_gov_syria governorate_syria id_district_jordan district_en industry_id industry_en share_empl_syr wp_2020

lab var id_gov_syria "ID Governorate Syria"
lab var governorate_syria "Name Governorate Syria"
lab var id_district_jordan "ID District Jordan"
lab var district_en "Name District Jordan"
lab var industry_id "ID Industry"
lab var industry_en "Name Industry"
lab var share_empl_syr "Share Employment over Governorates Syria"
lab var wp_2020 "WP in Jordan by industry"
lab var distance_dis_gov "Distance Districts Jordan to Governorates Syria"

sort id_gov_syria district_en industry_id

gen IV_SS = (wp_2020*share_empl_syr)/distance_dis_gov 
collapse (sum) IV_SS, by(district_en)
lab var IV_SS "IV: Shift Share"

tab district_en, m
sort district_en
egen district_id = group(district_en) 

save "$data_2020_final/Jordan2020_IV", replace 

/*
drop if refugee != 1 
codebook governorate 
lab def governorate 11 "Amman" ///
                    13 "Zarqa" ///
                    21 "Irbid" ///
                    22 "Mafraq" ///
                    , modify
lab val governorate governorate 
merge m:1 governorate using "$data_2020_temp/UNHCR_shift.dta" 
drop _merge

tab QR117, m
bys refugee: tab QR117, m

ren QR117 gov_syr_origin_ref

keep iid gov_syr_origin_ref distance_dis_gov id_gov_syria share_* district_en rsi_work_permit
bys district_en: gen share_IV = ( gov_syr_origin_ref * share_agriculture ) / distance_dis_gov
bys district_en: gen shift_IV = rsi_work_permit 

gen IV = share_IV * shift_IV
tab IV, m
*/
