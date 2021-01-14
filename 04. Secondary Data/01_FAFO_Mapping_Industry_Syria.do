/*====================================================================
project:       FAFO WP - Identification Workers distribution
Author:        Julie Bousquet 
----------------------------------------------------------------------
Creation Date:    14 Jan 2021 
====================================================================*/

/*====================================================================
                        1: Mapping
====================================================================*/


/*
     +--------------------+
     | _ID         NAME_1 |
     |--------------------|
  1. |   1     Al Ḥasakah |
  2. |   2         Aleppo |
  3. |   3      Ar Raqqah |
  4. |   4    As Suwayda' |
  5. |   5       Damascus |
     |--------------------|
  6. |   6          Dar`a |
  7. |   7   Dayr Az Zawr |
  8. |   8          Hamah |
  9. |   9           Hims |
 10. |  10          Idlib |
     |--------------------|
 11. |  11       Lattakia |
 12. |  12       Quneitra |
 13. |  13    Rif Dimashq |
 14. |  14         Tartus |
     +--------------------+

*/

/*====================================================================
                        1.1: Preparation of the data
====================================================================*/

/*
ssc install spmap
ssc install shp2dta
ssc install mif2dta 
*/

*I first convert the shapefile to coordinates
*Here, the shapefile is the boundaries of the governorate
shp2dta using "$data_LFS_shp/gadm36_SYR_1.shp", ///
	database("$data_LFS_temp/syr_adm1") ///
	coordinates("$data_LFS_temp/syr_coord1") ///
	genid(id_region) replace

*I first convert the shapefile to coordinates
*Here, the shapefile is the boundaries of the governorate
shp2dta using "$data_LFS_shp/gadm36_JOR_1.shp", ///
  database("$data_LFS_temp/jor_adm1") ///
  coordinates("$data_LFS_temp/jor_coord1") ///
  genid(id_region) replace



use "$data_LFS_temp/jor_coord1.dta", clear 
replace _ID = 15 if _ID == 1 
replace _ID = 16 if _ID == 2 
replace _ID = 17 if _ID == 3 
replace _ID = 18 if _ID == 4 
replace _ID = 19 if _ID == 5 
replace _ID = 20 if _ID == 6 
replace _ID = 21 if _ID == 7 
replace _ID = 22 if _ID == 8 
replace _ID = 23 if _ID == 9 
replace _ID = 24 if _ID == 10 
replace _ID = 25 if _ID == 11 
replace _ID = 26 if _ID == 12 
save "$data_LFS_temp/jor_coord1_new.dta", replace 

use "$data_LFS_temp/syr_coord1.dta"
append using "$data_LFS_temp/jor_coord1_new.dta" 
sort _ID 
save "$data_LFS_temp/coord1.dta", replace


*In order to plot the names of the governorate, 
*I take the average of the GPS coordinates
*so the name is in the middle of the polygon
*there must be an easier way to do that
use "$data_LFS_temp/syr_adm1.dta", clear
  rename id_region _ID 
	merge 1:m _ID using "$data_LFS_temp/syr_coord1.dta"
	egen mlong_x = mean(_X), by(_ID)
	egen mlat_y = mean(_Y), by(_ID)
	duplicates drop _ID, force
  ren NAME_1 governorate
save "$data_LFS_temp/governorate_names_syr.dta", replace

use "$data_LFS_temp/jor_adm1.dta", clear
  rename id_region _ID 
  merge 1:m _ID using "$data_LFS_temp/jor_coord1.dta"
  egen mlong_x = mean(_X), by(_ID)
  egen mlat_y = mean(_Y), by(_ID)
  duplicates drop _ID, force
  ren NAME_1 governorate
  ren _ID _ID_jor
save "$data_LFS_temp/governorate_names_jor.dta", replace

use "$data_LFS_temp/governorate_names_syr.dta", clear
append using "$data_LFS_temp/governorate_names_jor.dta"
replace _ID = 15 if _ID_jor == 1 
replace _ID = 16 if _ID_jor == 2 
replace _ID = 17 if _ID_jor == 3 
replace _ID = 18 if _ID_jor == 4 
replace _ID = 19 if _ID_jor == 5 
replace _ID = 20 if _ID_jor == 6 
replace _ID = 21 if _ID_jor == 7 
replace _ID = 22 if _ID_jor == 8 
replace _ID = 23 if _ID_jor == 9 
replace _ID = 24 if _ID_jor == 10 
replace _ID = 25 if _ID_jor == 11 
replace _ID = 26 if _ID_jor == 12  
save "$data_LFS_temp/governorate_names.dta", replace

**** MAP OF SYRIA
use "$data_LFS_temp/governorate_names.dta", clear
spmap using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(eggshell) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Number of project", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

/*====================================================================
               1.2: Mapping: workers distribution by OCCUPATION
====================================================================*/

import excel "$data_LFS_base/Workers distribution by governorate.xlsx", clear firstrow sheet("Workers by gov, occupation, tot")

tab Governorates
ren Governorates governorate
gen id_region = 1 if governorate == "AL-Hasakeh"
replace id_region = 2 if governorate == "Aleppo"
replace id_region = 3 if governorate == "AL-Rakka"
replace id_region = 4 if governorate == "AL-Sweida"
replace id_region = 5 if governorate == "Damascus"
replace id_region = 6 if governorate == "Dar'a"
replace id_region = 7 if governorate == "Deir-ez-Zor"
replace id_region = 8 if governorate == "Hama"
replace id_region = 9 if governorate == "Homs"
replace id_region = 10 if governorate == "Idleb"
replace id_region = 11 if governorate == "Lattakia"
replace id_region = 12 if governorate == "Quneitra"
replace id_region = 13 if governorate == "Damascus Rural"
replace id_region = 14 if governorate == "Tartous"

drop if governorate == "Total"

ren Legislatorsseniorofficialsan managers
ren Specialists specialists 
ren TechniciansandSpecialistsassi technicians 
ren Clerks clerks 
ren Servicesandsalesworkers services 
ren Agricultureandfishingworkers agri 
ren Artisansandprofessionsassocia artisans
ren Factoriesandmachinesoperators factories 
ren Elementaryoccupationsworkers elementary

merge 1:1 id_region using "$data_LFS_temp/syr_adm1.dta"
ren id_region _ID
drop _merge 
append using "$data_LFS_temp/jor_adm1.dta"
replace _ID = 15 if id_region == 1 
replace _ID = 16 if id_region == 2 
replace _ID = 17 if id_region == 3 
replace _ID = 18 if id_region == 4 
replace _ID = 19 if id_region == 5 
replace _ID = 20 if id_region == 6 
replace _ID = 21 if id_region == 7 
replace _ID = 22 if id_region == 8 
replace _ID = 23 if id_region == 9 
replace _ID = 24 if id_region == 10 
replace _ID = 25 if id_region == 11 
replace _ID = 26 if id_region == 12  

save "$data_LFS_temp/occup_bygov.dta", replace

**** MAP OF SYRIA
use "$data_LFS_temp/occup_bygov.dta", clear
spmap managers using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Workers as Managers", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_occup_managers_bygov.pdf", as(pdf)  replace

**** MAP OF SYRIA
use "$data_LFS_temp/occup_bygov.dta", clear
spmap specialists using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Workers as Specialists", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_occup_specialists_bygov.pdf", as(pdf) replace

**** MAP OF SYRIA
use "$data_LFS_temp/occup_bygov.dta", clear
spmap technicians using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Workers as Technicians", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_occup_technicians_bygov.pdf", as(pdf) replace

**** MAP OF SYRIA
use "$data_LFS_temp/occup_bygov.dta", clear
spmap clerks using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Workers as Clerks", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_occup_clerks_bygov.pdf", as(pdf) replace

  **** MAP OF SYRIA
use "$data_LFS_temp/occup_bygov.dta", clear
spmap services using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Workers in Services", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_occup_services_bygov.pdf", as(pdf) replace

  **** MAP OF SYRIA
use "$data_LFS_temp/occup_bygov.dta", clear
spmap agri using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Workers in Agriculture", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_occup_agri_bygov.pdf", as(pdf) replace

  **** MAP OF SYRIA
use "$data_LFS_temp/occup_bygov.dta", clear
spmap artisans using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Workers as Artisans", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_occup_artisans_bygov.pdf", as(pdf) replace

  **** MAP OF SYRIA
use "$data_LFS_temp/occup_bygov.dta", clear
spmap factories using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Workers in Factories", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_occup_factories_bygov.pdf", as(pdf) replace

  **** MAP OF SYRIA
use "$data_LFS_temp/occup_bygov.dta", clear
spmap elementary using "$data_LFS_temp/coord1.dta",    ///
  id(_ID) fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///  
  legend(title("Workers in Elementary Occupations", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_occup_elementary_bygov.pdf", as(pdf) replace

 


/*====================================================================
               1.3: Mapping: workers distribution by INDSUTRY
====================================================================*/


import excel "$data_LFS_base/Workers distribution by governorate.xlsx", clear firstrow sheet("Workers by gov, industries, tot")

tab Governorates
ren Governorates governorate
gen id_region = 1 if governorate == "AL-Hasakeh"
replace id_region = 2 if governorate == "Aleppo"
replace id_region = 3 if governorate == "AL-Rakka"
replace id_region = 4 if governorate == "AL-Sweida"
replace id_region = 5 if governorate == "Damascus"
replace id_region = 6 if governorate == "Dar'a"
replace id_region = 7 if governorate == "Deir-ez-Zor"
replace id_region = 8 if governorate == "Hama"
replace id_region = 9 if governorate == "Homs"
replace id_region = 10 if governorate == "Idleb"
replace id_region = 11 if governorate == "Lattakia"
replace id_region = 12 if governorate == "Quneitra"
replace id_region = 13 if governorate == "Damascus Rural"
replace id_region = 14 if governorate == "Tartous"

drop if governorate == "Total"

ren Agricultureandforestry agriculture 
ren Industry factory 
ren Buildingandconstruction construction 
ren Hotelsandrestaurantstrade trade 
ren Transportationstoragecommun transportation 
ren Moneyinsuranceandrealestat banking 
ren Services services 


merge 1:1 id_region using "$data_LFS_temp/syr_adm1.dta"
ren id_region _ID
drop _merge 
append using "$data_LFS_temp/jor_adm1.dta"
replace _ID = 15 if id_region == 1 
replace _ID = 16 if id_region == 2 
replace _ID = 17 if id_region == 3 
replace _ID = 18 if id_region == 4 
replace _ID = 19 if id_region == 5 
replace _ID = 20 if id_region == 6 
replace _ID = 21 if id_region == 7 
replace _ID = 22 if id_region == 8 
replace _ID = 23 if id_region == 9 
replace _ID = 24 if id_region == 10 
replace _ID = 25 if id_region == 11 
replace _ID = 26 if id_region == 12  

save "$data_LFS_temp/indus_bygov.dta", replace


**** MAP OF SYRIA
use "$data_LFS_temp/indus_bygov.dta", clear
spmap agriculture using "$data_LFS_temp/coord1.dta",    ///
  id(_ID)  fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///          
  legend(title("Workers in Agriculture and Forestry", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_indus_agriculture_bygov.pdf", as(pdf) replace


**** MAP OF SYRIA
use "$data_LFS_temp/indus_bygov.dta", clear
spmap factory using "$data_LFS_temp/coord1.dta",    ///
  id(_ID)  fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///          
  legend(title("Workers in Factories", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_indus_factory_bygov.pdf", as(pdf) replace


**** MAP OF SYRIA
use "$data_LFS_temp/indus_bygov.dta", clear
spmap construction using "$data_LFS_temp/coord1.dta",    ///
  id(_ID)  fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///          
  legend(title("Workers in Constrution", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_indus_construction_bygov.pdf", as(pdf) replace

**** MAP OF SYRIA
use "$data_LFS_temp/indus_bygov.dta", clear
spmap trade using "$data_LFS_temp/coord1.dta",    ///
  id(_ID)  fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///          
  legend(title("Workers in Hotels and Restaurants trade", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_indus_trade_bygov.pdf", as(pdf) replace


**** MAP OF SYRIA
use "$data_LFS_temp/indus_bygov.dta", clear
spmap transportation using "$data_LFS_temp/coord1.dta",    ///
  id(_ID)  fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///          
  legend(title("Workers in Transportation", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_indus_transportation_bygov.pdf", as(pdf) replace


**** MAP OF SYRIA
use "$data_LFS_temp/indus_bygov.dta", clear
spmap banking using "$data_LFS_temp/coord1.dta",    ///
  id(_ID)  fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///          
  legend(title("Workers in Banking", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_indus_banking_bygov.pdf", as(pdf) replace

**** MAP OF SYRIA
use "$data_LFS_temp/indus_bygov.dta", clear
spmap services using "$data_LFS_temp/coord1.dta",    ///
  id(_ID)  fcolor(Blues) ocolor(sienna) osize( vthin)   ///
  label(data("$data_LFS_temp/governorate_names.dta") xcoord(mlong_x)      ///
        ycoord(mlat_y) label(governorate) color(black) size(*0.7) position(0 6)) ///          
  legend(title("Workers in Services", size(*0.5)                      ///
        justification(left)) region(lcolor(white) fcolor(white))        ///
        position(4))                          ///
   plotregion(margin(small) icolor(white) color(white))         ///
   graphregion(icolor(white) color(white))    

  graph export "$out_LFS/map_indus_services_bygov.pdf", as(pdf) replace


import excel "$data_LFS_base/Workers distribution by governorate.xlsx", clear firstrow sheet("Workers by gov, occupation, tot")

ren Governorates governorate 
drop if governorate == "Total"

/*
     +--------------------+
     | _ID         NAME_1 |
     |--------------------|
  1. |   1     Al Ḥasakah |
  2. |   2         Aleppo |
  3. |   3      Ar Raqqah |
  4. |   4    As Suwayda' |
  5. |   5       Damascus |
     |--------------------|
  6. |   6          Dar`a |
  7. |   7   Dayr Az Zawr |
  8. |   8          Hamah |
  9. |   9           Hims |
 10. |  10          Idlib |
     |--------------------|
 11. |  11       Lattakia |
 12. |  12       Quneitra |
 13. |  13    Rif Dimashq |
 14. |  14         Tartus |
     +--------------------+
     */

replace governorate = "Al Ḥasakah" if governorate == "AL-Hasakeh"
replace governorate = "Ar Raqqah" if governorate == "AL-Rakka"
replace governorate = "As Suwayda'" if governorate == "AL-Sweida"
replace governorate = "Dayr Az Zawr" if governorate == "Deir-ez-Zor"
replace governorate = "Tartus" if governorate == "Tartous"
replace governorate = "Hamah" if governorate == "Hama"
replace governorate = "Hims" if governorate == "Homs"
replace governorate = "Idlib" if governorate == "Idleb"
replace governorate = "Rif Dimashq" if governorate == "Damascus Rural"


ren Legislatorsseniorofficialsan occup_1
ren Specialists occup_2 
ren TechniciansandSpecialistsassi occup_3 
ren Clerks occup_4
ren Servicesandsalesworkers occup_5
ren Agricultureandfishingworkers occup_6 
ren Artisansandprofessionsassocia occup_7
ren Factoriesandmachinesoperators occup_8 
ren Elementaryoccupationsworkers occup_9

gen id = _n
reshape long occup_, i(id) j(occupation)
label def occupation 1 "Managers" ///
                      2 "Specialists" ///
                      3 "Technicians" ///
                      4 "Clerks" ///
                      5 "Services" ///
                      6 "Agri" ///
                      7 "Artisans" ///
                      8 "Factories" ///
                      9 "Elementary" ///
                      , modify
lab val occupation occupation

graph pie occup_, over(occupation) ///
  plabel(_all percent, size(small) format(%3.1g)) ///
  by(, title("Distribution of Workers in Occupation by Governorate", size(medium)) ///
    note("LFS, Syria, 2010")) by(, legend(at(15))) ///
    legend(size(small) ///
    region(fcolor(none) margin(zero) lcolor(none)) ///
    bmargin(zero)) by(governorate)
  graph export "$out_LFS/pie_occup_bygov.pdf", as(pdf) replace


import excel "$data_LFS_base/Workers distribution by governorate.xlsx", clear firstrow sheet("Workers by gov, industries, tot")

ren Governorates governorate 
drop if governorate == "Total"

replace governorate = "Al Ḥasakah" if governorate == "AL-Hasakeh"
replace governorate = "Ar Raqqah" if governorate == "AL-Rakka"
replace governorate = "As Suwayda'" if governorate == "AL-Sweida"
replace governorate = "Dayr Az Zawr" if governorate == "Deir-ez-Zor"
replace governorate = "Tartus" if governorate == "Tartous"
replace governorate = "Hamah" if governorate == "Hama"
replace governorate = "Hims" if governorate == "Homs"
replace governorate = "Idlib" if governorate == "Idleb"
replace governorate = "Rif Dimashq" if governorate == "Damascus Rural"


ren Agricultureandforestry indus_1 
ren Industry indus_2 
ren Buildingandconstruction indus_3 
ren Hotelsandrestaurantstrade indus_4 
ren Transportationstoragecommun indus_5 
ren Moneyinsuranceandrealestat indus_6 
ren Services indus_7 

gen id = _n
reshape long indus_, i(id) j(industry)
label def industry  1 "Agriculture" ///
                      2 "Factory" ///
                      3 "Construction" ///
                      4 "Hotels and Restaurants" ///
                      5 "Transportation" ///
                      6 "Banking" ///
                      7 "Services" ///
                      , modify
lab val industry industry

graph pie indus_, over(industry) ///
  plabel(_all percent, size(small) format(%3.1g)) ///
  by(, title("Distribution of Workers in Industry by Governorate", size(medium)) ///
    note("LFS, Syria, 2010")) by(, legend(at(15))) ///
    legend(size(small) ///
    region(fcolor(none) margin(zero) lcolor(none)) ///
    bmargin(zero)) by(governorate)
  graph export "$out_LFS/pie_indus_bygov.pdf", as(pdf) replace




exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><


