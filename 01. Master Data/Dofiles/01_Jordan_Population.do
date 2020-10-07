
import excel "$data_base\DOS Jordan (2019) - Population by Locality.xlsx", sheet("All") firstrow clear
tab Governorate
tab Municipality
tab Locality 

egen total_gov = sum(Population), by(Governorate)
egen total_muni = sum(Population), by(Municipality)
egen total_local = sum(Population), by(Locality)

bys Governorate: distinct Municipality
 tabstat Population, stat(mean sum min max ) 
 su Population, d
 return list
bys Governorate: tabstat Population, stat(mean sum min max) 
bys Governorate: tabstat Population, stat(n mean sum min max)  by(Municipality)
bys Governorate Municipality: tabstat Population, stat(mean sum min max)  by(Locality)

graph bar (sum) Population, over(Governorate)  blabel(total)
graph export "$out\Population_Jordan.png", as(png) replace

egen gov_id = group(Governorate)
bys Municipality: gen loc_id = _n

levelsof gov_id, local(levels) 
  foreach gov of local levels {
   egen mun_id_`gov' = group(Municipality) if gov_id == `gov'
  }
gen mun_id = mun_id_1 
replace mun_id = mun_id_2 if mi(mun_id) 
replace mun_id = mun_id_3 if mi(mun_id) 
drop mun_id_*

graph bar (sum) Population if Governorate == "Amman", ///
  over(mun_id, label(angle(ninety) labsize(vsmall))) ///
  nofill blabel(total, size(vsmall) orientation(vertical)) ///
  ylabel(, labsize(small) angle(horizontal)) ///
  title("Total Population, Amman") subtitle("by District")
graph export "$out\Population_by_District_Amman.png", as(png) replace

graph bar (sum) Population if Governorate == "Irbid", ///
  over(mun_id, label(angle(ninety) labsize(vsmall))) ///
  nofill blabel(total, size(vsmall) orientation(vertical)) ///
  ylabel(, labsize(small) angle(horizontal)) ///
    title("Total Population, Irbid") subtitle("by District")
graph export "$out\Population_by_District_Irbid.png", as(png) replace

graph bar (sum) Population if Governorate == "Mafraq", ///
  over(mun_id, label(angle(ninety) labsize(vsmall))) ///
  nofill blabel(total, size(vsmall) orientation(vertical)) ///
  ylabel(, labsize(small) angle(horizontal)) ///
    title("Total Population, Mafraq") subtitle("by District")
graph export "$out\Population_by_District_Mafraq.png", as(png) replace



graph bar (sum) Population if Governorate == "Amman", ///
  over(loc_id, label(angle(ninety) labsize(vsmall))) ///
  nofill blabel(total, size(vsmall) orientation (vertical)) ///
  ylabel(, labsize(small) angle(horizontal)) ///
  by(, title("Total Population Amman") subtitle("by District, by Locality")) ///
  by(Municipality) subtitle(, size(medsmall))
graph export "$out\Population_by_Loc_Amman.pdf", as(pdf) replace

graph bar (sum) Population if Governorate == "Irbid", ///
  over(loc_id, label(angle(ninety) labsize(vsmall))) ///
  nofill blabel(total, size(vsmall) orientation (vertical)) ///
  ylabel(, labsize(small) angle(horizontal)) ///
  by(, title("Total Population Irbid") subtitle("by District, by Locality")) ///
  by(Municipality) subtitle(, size(medsmall))
graph export "$out\Population_by_Loc_Irbid.pdf", as(pdf) replace

graph bar (sum) Population if Governorate == "Mafraq", ///
  over(loc_id, label(angle(ninety) labsize(vsmall))) ///
  nofill blabel(total, size(vsmall) orientation (vertical)) ///
  ylabel(, labsize(small) angle(horizontal)) ///
  by(, title("Total Population Mafraq") subtitle("by District, by Locality")) ///
  by(Municipality) subtitle(, size(medsmall))
graph export "$out\Population_by_Loc_Mafraq.pdf", as(pdf) replace



























