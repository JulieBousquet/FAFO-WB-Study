


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

list governorate_syria 

keep if governorate_syria ==  "Al Hasakah" | ///
        governorate_syria ==  "Aleppo" | ///
        governorate_syria ==  "Al Raqqah" | ///
        governorate_syria ==  "Al Suwayda" | ///
        governorate_syria ==  "Daraa" | ///
        governorate_syria ==  "Deir El Zour" | ///
        governorate_syria ==  "Hama" | ///
        governorate_syria ==  "Homs" | ///
        governorate_syria ==  "Idlib" | ///
        governorate_syria ==  "Quneitra" | ///
        governorate_syria ==  "Damascus" | ///
        governorate_syria ==  "Rural Damascus" 
sort governorate_syria 
gen id_gov_syria = _n
list id_gov_syria governorate_syria

drop if governorate == "Total"
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


drop agriculture factory construction trade transportation banking services 

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

list governorate_syria 

keep if governorate_syria ==  "Al Hasakah" | ///
        governorate_syria ==  "Aleppo" | ///
        governorate_syria ==  "Al Raqqah" | ///
        governorate_syria ==  "Al Suwayda" | ///
        governorate_syria ==  "Daraa" | ///
        governorate_syria ==  "Deir El Zour" | ///
        governorate_syria ==  "Hama" | ///
        governorate_syria ==  "Homs" | ///
        governorate_syria ==  "Idlib" | ///
        governorate_syria ==  "Quneitra" | ///
        governorate_syria ==  "Damascus" | ///
        governorate_syria ==  "Rural Damascus" 
sort governorate_syria 
gen id_gov_syria = _n
list id_gov_syria governorate_syria

save "$data_2020_final/governorate_loc_syr.dta", replace


use "$data_2020_final/Jordan2020_02_Clean.dta", clear

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

bys refugee: tab QR117, m
decode QR117, gen(governorate_syria)
tab governorate_syria, m 

sort governorate_syria
egen id_gov_syria = group(governorate_syria)
tab id_gov_syria 
list id_gov_syria governorate_syria

replace governorate_syria = "-99 Missing" if mi(governorate_syria) & refugee == 1
replace governorate_syria = "-98 Non Applicable" if mi(governorate_syria) & (refugee == 2 | refugee == 3)

merge m:1 id_gov_syria using "$data_2020_final/governorate_loc_syr.dta"
drop _merge

tab governorate_syria, m
tab gov_syria_long, m
tab gov_syria_lat, m

save "$data_2020_final/Jordan2020_geo_Syria.dta", replace 


keep  gov_syria_lat gov_syria_long district_lat district_long sub_district_long ///
      sub_district_lat area_long area_lat governorate_en locality_long locality_lat ///
      locality_en district_en sub_district_en governorate_syria

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

graph export "$out_2020/map_districtJOR_govSYR.pdf", as(pdf) replace


/*
SHIFT 
*/

*Number of refugee with work permits 
*In 2020
use "$data_2020_final/Jordan2020_02_Clean.dta", clear
tab rsi_work_permit, m
bys governorate_en: tab rsi_work_permit, m
*In 2014
use "$data_2014_final/Jordan2014_02_Clean.dta", clear
tab rsi_work_permit, m

bys district_en: gen shift_IV = rsi_work_permit if refguees == 1 

import excel "$data_sec_UNHCR\Datasets_WP_RegisteredSyrians.xlsx", sheet("WP_REF - byGov byYear") firstrow clear

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
save "$data_2020_temp/UNHCR_shift.dta", replace 


/**************
THE INSTRUMENT 
**************/

use "$data_2020_final/Jordan2020_geo_Syria.dta", clear 
tab id_gov_syria
*Merge with number of employed syrian by gov, by indus 
*remember:
merge m:1 id_gov_syria using "$data_2020_final/governorate_indus_syr_emplshare.dta"
drop _merge
*h geodist
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

geodist district_lat district_long gov_syria_lat gov_syria_long, gen(distance_dis_gov)
tab distance_dis_gov, m
lab var distance_dis_gov "Distance (km) between JORD districts and SYR centroid governorates"

geodist sub_district_lat sub_district_long gov_syria_lat gov_syria_long, gen(distance_subdis_gov)
tab distance_subdis_gov, m
lab var distance_subdis_gov "Distance (km) between JORD sub-districts and SYR centroid governorates"

geodist locality_lat locality_long gov_syria_lat gov_syria_long, gen(distance_loc_gov)
tab distance_loc_gov, m 
lab var distance_loc_gov "Distance (km) between JORD localities and SYR centroid governorates"

geodist area_lat area_long gov_syria_lat gov_syria_long, gen(distance_area_gov)
tab distance_area_gov, m
lab var distance_area_gov "Distance (km) between JORD areas and SYR centroid governorates"

unique distance_dis_gov //53
unique distance_subdis_gov //63
unique distance_loc_gov //69
unique distance_area_gov //82

tab QR117, m
bys refugee: tab QR117, m

ren QR117 gov_syr_origin_ref

keep iid gov_syr_origin_ref distance_dis_gov id_gov_syria share_* district_en rsi_work_permit
bys district_en: gen share_IV = ( gov_syr_origin_ref * share_agriculture ) / distance_dis_gov
bys district_en: gen shift_IV = rsi_work_permit 

gen IV = share_IV * shift_IV
tab IV, m
