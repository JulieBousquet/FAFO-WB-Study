

cap log close
clear all
set more off, permanently
set mem 100m

*log using "$analysis_do/01_Data_Cleaning_EL1.log", replace

	****************************************************************************
	**                               DATA CLEANING                            **  
	** ---------------------------------------------------------------------- **
	** Type Do  : 	DATA CLEANING FAFO 2020                                   **
  	**                                                                        **
	** Authors  : Julie Bousquet                                              **
	****************************************************************************

use "$data_2020_final/Jordan2020_HH_RSI.dta", clear

**** INDUSTRIES AND OCCUPATION ****

* Industry 
tab QR501 
*ren QR501 industry
encode QR501, gen(industry)
*Occupation 
tab QR502
*ren QR502 occupation
encode QR502, gen(occupation)


sort industry
*br industry
egen id = group(industry) 
duplicates tag id, gen(dup)
bys id: gen idn = _n
*drop if idn != 1
*drop if dup > 0
list industry
*br industry
*gen id = _n 

tempfile tempfile_indus
save `tempfile_indus'


import excel "$data_2020_base\Industry_2020.xlsx", sheet("MAIN") firstrow clear
*gen id = _n 
egen id = group(industry_ar) 

merge m:m id  using `tempfile_indus'

drop _merge dup 

*https://ilostat.ilo.org/resources/concepts-and-definitions/classification-economic-activities/

ren industry industry_orig
*br industry_orig industry_ar

gen industry = industry_en
replace industry = "Manufacturing" if industry_en == "Wood Carving"
replace industry = "Manufacturing" if industry_en == "Carpenter"
replace industry = "Manufacturing" if industry_en == "Wood carpenter"
replace industry = "Manufacturing" if industry_en == "Wood Carving"
replace industry = "Manufacturing" if industry_en == "Dairy factory"
replace industry = "Manufacturing" if industry_en == "Factory"
replace industry = "Manufacturing" if industry_en == "Factory worker"
replace industry = "Manufacturing" if industry_en == "Plastic parts for pipe fittings"
replace industry = "Manufacturing" if industry_en == "Tobacco company"
replace industry = "Manufacturing" if industry_en == "Oily"
replace industry = "Manufacturing" if industry_en == "In the assembly of scrap"
replace industry = "Manufacturing" if industry_en == "Epic"
replace industry = "Manufacturing" if industry_en == "manufacturing"
replace industry = "Manufacturing" if industry_en == "Factor" & iid == 133015931

replace industry = "Administrative and support service activities" if industry_en == "Security and Protection" 
replace industry = "Administrative and support service activities" if industry_en == "security"
replace industry = "Administrative and support service activities" if industry_en == "Business Administration"
replace industry = "Administrative and support service activities" if industry_en == "guard"
replace industry = "Administrative and support service activities" if industry_en == "Smith"
replace industry = "Administrative and support service activities" if industry_en == "Municipal guarding"
replace industry = "Administrative and support service activities" if industry_en == "secretary"
replace industry = "Administrative and support service activities" if industry_en == "clerk"

replace industry = "Construction" if industry_en == "Construction work / plumbing"
replace industry = "Construction" if industry_en == "Tile tiling houses"
replace industry = "Construction" if industry_en == "Tiling houses"
replace industry = "Construction" if industry_en == "Repairing"
replace industry = "Construction" if industry_en == "Construction services"
replace industry = "Construction" if industry_en == "Painting and decoration"
replace industry = "Construction" if industry_en == "Painter"
replace industry = "Construction" if industry_en == "Maintenance of homes"
replace industry = "Construction" if industry_en == "Tile worker"
replace industry = "Construction" if industry_en == "A builder"
replace industry = "Construction" if industry_en == "Stone worker"
replace industry = "Construction" if industry_en == "Carpentry worker"
replace industry = "Construction" if industry_en == "Tile art"
replace industry = "Construction" if industry_en == "Maintenance services"
replace industry = "Construction" if industry_en == "A stone"
replace industry = "Construction" if industry_en == "Dressing Shahf"
replace industry = "Construction" if industry_en == "Brady Industry"
replace industry = "Construction" if industry_en == "Clay"
replace industry = "Construction" if industry_en == "A worker on a tank"
replace industry = "Construction" if industry_en == "Cache operator"
replace industry = "Construction" if industry_en == "Daily worker"
replace industry = "Construction" if industry_en == "Thrash"
replace industry = "Construction" if industry_en == "Kahla buildings"
replace industry = "Construction" if industry_en == "As a sash"
replace industry = "Construction" if industry_en == "Mossorgi" 
replace industry = "Construction" if industry_en == "Mawalat"
replace industry = "Construction" if industry_en == "Construction work"
replace industry = "Construction" if industry_en == "Building"
replace industry = "Construction" if industry_en == "Carpentry"
replace industry = "Construction" if industry_en == "Maintenance"
replace industry = "Construction" if industry_en == "Tiles"
replace industry = "Construction" if industry_en == "sewing"
replace industry = "Construction" if industry_en == "Factor" & iid == 134058181 
replace industry = "Construction" if industry_en == "Factor" & iid == 1330162101
replace industry = "Construction" if industry_en == "Factor" & iid == 2210159122
replace industry = "Construction" if industry_en == "Factor" & iid == 1340340112
replace industry = "Construction" if industry_en == "Factor" & iid == 1330396131
replace industry = "Construction" if industry_en == "Factor" & iid == 133011392
replace industry = "Construction" if industry_en == "Factor" & iid == 133123391
replace industry = "Construction" if industry_en == "Factor" & iid == 1110974142
replace industry = "Construction" if industry_en == "Factor" & iid == 2210294161

replace industry = "Wholesale and retail trade" if industry_en == "Aluminum seller"
replace industry = "Wholesale and retail trade" if industry_en == "Aluminum"
replace industry = "Wholesale and retail trade" if industry_en == "salesassistant"
replace industry = "Wholesale and retail trade" if industry_en == "fixing cars"
replace industry = "Wholesale and retail trade" if industry_en == "Repair and install car wheels"
replace industry = "Wholesale and retail trade" if industry_en == "Car wash and grease"
replace industry = "Wholesale and retail trade" if industry_en == "Working aluminum"
replace industry = "Wholesale and retail trade" if industry_en == "Aluminum industry"
replace industry = "Wholesale and retail trade" if industry_en == "Plastic industry"
replace industry = "Wholesale and retail trade" if industry_en == "Wholesale stores upload and download"
replace industry = "Wholesale and retail trade" if industry_en == "upload and download"
replace industry = "Wholesale and retail trade" if industry_en == "Download khedler"
replace industry = "Wholesale and retail trade" if industry_en == "Packaging and packing"
replace industry = "Wholesale and retail trade" if industry_en == "Download agent download"
replace industry = "Wholesale and retail trade" if industry_en == "Download merchandise" 
replace industry = "Wholesale and retail trade" if industry_en == "distribution"
replace industry = "Wholesale and retail trade" if industry_en == "glass"
replace industry = "Wholesale and retail trade" if industry_en == "Upload and download agent"
replace industry = "Wholesale and retail trade" if industry_en == "Baleet assistant"
replace industry = "Wholesale and retail trade" if industry_en == "Load factor"
replace industry = "Wholesale and retail trade" if industry_en == "trade"
replace industry = "Wholesale and retail trade" if industry_en == "Factor" & iid == 1330396122
replace industry = "Wholesale and retail trade" if industry_en == "Factor" & iid == 1130731151

replace industry = "Services" if industry_en == "Vendor"
replace industry = "Services" if industry_en == "Mall services"
replace industry = "Services" if industry_en == "Shopping mall"
replace industry = "Services" if industry_en == "Supermarket employee"
replace industry = "Services" if industry_en == "B store cleaning supplies"
replace industry = "Services" if industry_en == "I want cars"
replace industry = "Services" if industry_en == "Sale"
replace industry = "Services" if industry_en == "Selling clothes"
replace industry = "Services" if industry_en == "Carpet cleaning"
replace industry = "Services" if industry_en == "shaving"
replace industry = "Services" if industry_en == "tailor"
replace industry = "Services" if industry_en == "Tailor"
replace industry = "Services" if industry_en == "bus driver"
replace industry = "Services" if industry_en == "Beckham driver"
replace industry = "Services" if industry_en == "Making bags"
replace industry = "Services" if industry_en == "Tailor worker"
replace industry = "Services" if industry_en == "Sales agent"
replace industry = "Services" if industry_en == "car wash"
replace industry = "Services" if industry_en == "Tailoring"
replace industry = "Services" if industry_en == "Sales Officer"
replace industry = "Services" if industry_en == "Cellular devices"
replace industry = "Services" if industry_en == "cooperative"
replace industry = "Services" if industry_en == "Aammal home services"
replace industry = "Services" if industry_en == "Agent services"
replace industry = "Services" if industry_en == "Exhaust oils"
replace industry = "Services" if industry_en == "Coavira"
replace industry = "Services" if industry_en == "Transfer"
replace industry = "Services" if industry_en == "In front of a mosque"
replace industry = "Services" if industry_en == "Carpet washing"
replace industry = "Services" if industry_en == "Driver"
replace industry = "Services" if industry_en == "Super Market"
replace industry = "Services" if industry_en == "clothes designing"
replace industry = "Services" if industry_en == "Factor" & iid == 1110974111
replace industry = "Services" if industry_en == "Officer" & iid == 221005082
replace industry = "Services" if industry_en == "free businees" & iid == 213006991

replace industry = "Other service activities" if industry_en == "Houseware"
replace industry = "Other service activities" if industry_en == "Aid"
replace industry = "Other service activities" if industry_en == "Raising a child"
replace industry = "Other service activities" if industry_en == "Child rearing"
replace industry = "Other service activities" if industry_en == "Arrange cleaning houses"
replace industry = "Other service activities" if industry_en == "Beautifying"
replace industry = "Other service activities" if industry_en == "Beauty and stylist"
replace industry = "Other service activities" if industry_en == "grocery"
replace industry = "Other service activities" if industry_en == "Marketing of baby pads"
replace industry = "Other service activities" if industry_en == "Baby towel packing"
replace industry = "Other service activities" if industry_en == "Clean up"
replace industry = "Other service activities" if industry_en == "Clean Worker"
replace industry = "Other service activities" if industry_en == "laundry"
replace industry = "Other service activities" if industry_en == "Bleacher"
replace industry = "Other service activities" if industry_en == "various works"
replace industry = "Other service activities" if industry_en == "Home project" 
replace industry = "Other service activities" if industry_en == "House work" 
replace industry = "Other service activities" if industry_en == "free businees" & iid == 213006191

replace industry = "Agriculture" if industry_en == "Corn seller"
replace industry = "Agriculture" if industry_en == "Stall seller"
replace industry = "Agriculture" if industry_en == "Cultivation tillage"
replace industry = "Agriculture" if industry_en == "Farmer"
replace industry = "Agriculture" if industry_en == "Vegetable trade"
replace industry = "Agriculture" if industry_en == "Food trade"
replace industry = "Agriculture" if industry_en == "Buying and selling vegetables and fruits"
replace industry = "Agriculture" if industry_en == "Vegetables"
replace industry = "Agriculture" if industry_en == "Agriculture worker"
replace industry = "Agriculture" if industry_en == "Peach trees"
replace industry = "Agriculture" if industry_en == "Azraq reserve" 
replace industry = "Agriculture" if industry_en == "Selling vegetables"
replace industry = "Agriculture" if industry_en == "Selling greenery"

replace industry = "Professional, scientific and technical activities" if industry_en == "engineering"
replace industry = "Professional, scientific and technical activities" if industry_en == "Engineer"
replace industry = "Professional, scientific and technical activities" if industry_en == "Accounting"
replace industry = "Professional, scientific and technical activities" if industry_en == "Station technician worker"
replace industry = "Professional, scientific and technical activities" if industry_en == "Maintenance technician"
replace industry = "Professional, scientific and technical activities" if industry_en == "Electrostatic technician"
replace industry = "Professional, scientific and technical activities" if industry_en == "Dental technician"
replace industry = "Professional, scientific and technical activities" if industry_en == "Electronics technician"
replace industry = "Professional, scientific and technical activities" if industry_en == "Welding technician"
replace industry = "Professional, scientific and technical activities" if industry_en == "Lawyer / law firm"
replace industry = "Professional, scientific and technical activities" if industry_en == "lawyer"
replace industry = "Professional, scientific and technical activities" if industry_en == "Biology Labs"
replace industry = "Professional, scientific and technical activities" if industry_en == "rights"
replace industry = "Professional, scientific and technical activities" if industry_en == "Shipping services"
replace industry = "Professional, scientific and technical activities" if industry_en == "A question about his building"
replace industry = "Professional, scientific and technical activities" if industry_en == "Accountant"

replace industry = "Military" if industry_en == "He works in the army"
replace industry = "Military" if industry_en == "Paratroopers"
replace industry = "Military" if industry_en == "Army"
replace industry = "Military" if industry_en == "army"
replace industry = "Military" if industry_en == "Civil defense"
replace industry = "Military" if industry_en == "Armed forces protect"
replace industry = "Military" if industry_en == "Soldier"
replace industry = "Military" if industry_en == "Officer" & iid == 221015912

replace industry = "Human health and social work activities" if industry_en == "a nurse"
replace industry = "Human health and social work activities" if industry_en == "My hospital"
replace industry = "Human health and social work activities" if industry_en == "Take a nurse"
replace industry = "Human health and social work activities" if industry_en == "nursing"
replace industry = "Human health and social work activities" if industry_en == "medical services"
replace industry = "Human health and social work activities" if industry_en == "Humanitarian work"
replace industry = "Human health and social work activities" if industry_en == "Non-profit organizations volunteer"

replace industry = "Accommodation and food service activities" if industry_en == "Pastries"
replace industry = "Accommodation and food service activities" if industry_en == "Wrap sandwich restaurant"
replace industry = "Accommodation and food service activities" if industry_en == "Falafel restaurant"
replace industry = "Accommodation and food service activities" if industry_en == "Restaurant serving meals"
replace industry = "Accommodation and food service activities" if industry_en == "A productive kitchen"
replace industry = "Accommodation and food service activities" if industry_en == "Restaurants"
replace industry = "Accommodation and food service activities" if industry_en == "Boucherji"
replace industry = "Accommodation and food service activities" if industry_en == "Shawarma processing"
replace industry = "Accommodation and food service activities" if industry_en == "Confectionery processing"
replace industry = "Accommodation and food service activities" if industry_en == "Food processing for the army"
replace industry = "Accommodation and food service activities" if industry_en == "Vegetable cleaning"
replace industry = "Accommodation and food service activities" if industry_en == "Baker equipment baker"
replace industry = "Accommodation and food service activities" if industry_en == "Confectionery industry"
replace industry = "Accommodation and food service activities" if industry_en == "Making pastries"
replace industry = "Accommodation and food service activities" if industry_en == "Cook desserts"
replace industry = "Accommodation and food service activities" if industry_en == "Worker in a shawarma restaurant"
replace industry = "Accommodation and food service activities" if industry_en == "A worker in a cake factory"
replace industry = "Accommodation and food service activities" if industry_en == "Fran bakery"
replace industry = "Accommodation and food service activities" if industry_en == "Coffee works"
replace industry = "Accommodation and food service activities" if industry_en == "Cafeteria"
replace industry = "Accommodation and food service activities" if industry_en == "Bakeries"
replace industry = "Accommodation and food service activities" if industry_en == "bakery"
replace industry = "Accommodation and food service activities" if industry_en == "Bread industry"
replace industry = "Accommodation and food service activities" if industry_en == "Attar"
replace industry = "Accommodation and food service activities" if industry_en == "Baker"
replace industry = "Accommodation and food service activities" if industry_en == "As a grinder"
replace industry = "Accommodation and food service activities" if industry_en == "Candy"
replace industry = "Accommodation and food service activities" if industry_en == "Coffee worker"
replace industry = "Accommodation and food service activities" if industry_en == "Restaurant worker"
replace industry = "Accommodation and food service activities" if industry_en == "Resturant"
replace industry = "Accommodation and food service activities" if industry_en == "Factor" & iid == 2210294151

replace industry = "Education" if industry_en == "School. Teaching"
replace industry = "Education" if industry_en == "School"
replace industry = "Education" if industry_en == "Short teacher"
replace industry = "Education" if industry_en == "Tile teacher"
replace industry = "Education" if industry_en == "Computer teacher education sector"
replace industry = "Education" if industry_en == "Sweets teacher"
replace industry = "Education" if industry_en == "Shawarma teacher"
replace industry = "Education" if industry_en == "Coffee teacher"
replace industry = "Education" if industry_en == "Mentor.Teaching"
replace industry = "Education" if industry_en == "Attention to educational outcomes"
replace industry = "Education" if industry_en == "Education and teaching"
replace industry = "Education" if industry_en == "Teaching in camps"
replace industry = "Education" if industry_en == "Teaching Teaching"
replace industry = "Education" if industry_en == "educational"
replace industry = "Education" if industry_en == "Teacher"
replace industry = "Education" if industry_en == "Assistant Director / Education Sector"
replace industry = "Education" if industry_en == "Private tutoring"
replace industry = "Education" if industry_en == "Public security"
replace industry = "Education" if industry_en == "education"
replace industry = "Education" if industry_en == "teaching"

replace industry = "Financial and insurance activities" if industry_en == "Trading"
replace industry = "Financial and insurance activities" if industry_en == "Financial collection"

replace industry = "Hotels and restaurants" if industry_en == "A hotel worker"

replace industry = "Electricity, gas and water supply" if industry_en == "Homes electrician"
replace industry = "Electricity, gas and water supply" if industry_en == "Its services"
replace industry = "Electricity, gas and water supply" if industry_en == "Electrician"
replace industry = "Electricity, gas and water supply" if industry_en == "electricity company"
replace industry = "Electricity, gas and water supply" if industry_en == "Factor" & iid == 115012533

replace industry = "Water supply; sewerage, waste management and remediation activities" if industry_en == "Waste recycling"
replace industry = "Water supply; sewerage, waste management and remediation activities" if industry_en == "Sanitary extensions"
replace industry = "Water supply; sewerage, waste management and remediation activities" if industry_en == "A strategic plan for Yarmouk water"

replace industry = "Information and communication" if industry_en == "Technology solutions company"
replace industry = "Information and communication" if industry_en == "Its writer"

sort industry
list industry
*br industry

tab industry, m
tab industry qremp, m

codebook qremp
list qremp industry occupation if mi(qremp)
list qremp industry occupation if qremp == 3 & !mi(industry)


order industry industry_ar industry_en industry_orig, b(QR501)



*************
** REFUGEE **
*************

tab QH207, m
list headnation if QH207 == .
codebook QH207
codebook headnation
gen refugee = 1 if QH207 == 2
replace refugee = 2 if QH207 == 1 
replace refugee = 3 if QH207 == 3 | QH207 == 10
lab def refugee 1 "Refugee" 2 "Native" 3 "Others", modify
lab val refugee refugee 
lab var refugee "Refugee is 1 if Syrian, is 2 if Native, is 3 if others (Palestinian, Egyptian)"
tab refugee, m

replace refugee = 1 if mi(refugee) & headnation == 2
replace refugee = 2 if mi(refugee) & headnation == 1
replace refugee = 3 if mi(refugee) & headnation == 3
tab refugee, m

*Refugees are only SYRIANS 
*Non refugees can be JORDANIAN - PALESTINIANS - EGYPTIANS

tab QH207, m
gen nationality = 1 if QH207 == 1
replace nationality = 2 if QH207 == 2
replace nationality = 3 if QH207 == 3
replace nationality = 4 if QH207 == 10
replace nationality = 1 if mi(nationality) & headnation == 1
replace nationality = 2 if mi(nationality) & headnation == 2
replace nationality = 3 if mi(nationality) & headnation == 3

lab def nationality 1 "Jordanian" 2 "Syrian" 3 "Egyptian" 4 "Palestinian", modify
lab val nationality nationality 
lab var nationality "Nationality"
tab nationality, m


******************
** WORK PERMITS **
******************

*Teh question was asked as part of the RSI survey,
*Households in HH or ROS only would not have answered.
*
tab merge_rsi
codebook merge_rsi
preserve
*If people are refugee and if they answered to RSI survey
drop if nationality != 2 | merge_rsi == 4 
tab QR201  , m
restore

/*
     Have a valid work permit |      Freq.     Percent        Cum.
------------------------------+-----------------------------------
Yes, have a valid work permit |         52        8.04        8.04
         Yes, but has expired |         49        7.57       15.61
  No, never had a work permit |        546       84.39      100.00
------------------------------+-----------------------------------
                        Total |        647      100.00
*/

preserve
*If we keep only the people who say they work
keep if qremp == 1
bys refugee: tab QR201
restore
/*
     Have a valid work permit |      Freq.     Percent        Cum.
------------------------------+-----------------------------------
Yes, have a valid work permit |         44       23.16       23.16
         Yes, but has expired |         34       17.89       41.05
  No, never had a work permit |        112       58.95      100.00
------------------------------+-----------------------------------
                        Total |        190      100.00
*/
ren QR201 rsi_work_permit

tab rsi_work_permit, m 
codebook rsi_work_permit
recode rsi_work_permit (3=0) (2=1)
lab def yesno 1 "Yes" 0 "No", modify
lab val rsi_work_permit yesno



*********** GEO UNITS *************

tab ID102, m 
tab ID102N, m 
tab ID103N, m

*br ID101 ID101N ID102 ID102N ID103 ID103N ID104 ID104N ID105 ID105N ID106 ID106N ID107 ID107N ID108 ID109
sort ID101 ID102 ID103 ID104 ID105 ID106 ID107 ID108 ID109
gen governorate = ID101
gen governorate_ar = ID101N
codebook ID101 
gen governorate_en = ""
replace governorate_en = "Amman" if governorate == 11
replace governorate_en = "Zarqa" if governorate == 13
replace governorate_en = "Irbid" if governorate == 21
replace governorate_en = "Mafraq" if governorate == 22
tab governorate_en, m

gen district = ID102
gen district_ar = ID102N
gen district_en = ""
gen district_lat = .
gen district_long = .

*AMMAN
preserve
keep if governorate_en == "Amman"
list governorate_en district district_ar
restore
replace district_en = "Oman Kasbah" if district == 1 & governorate_en == "Amman"
replace district_lat = 31.974414651075975 if district_en == "Oman Kasbah"
replace district_long = 35.911453436115245 if district_en == "Oman Kasbah"
*31.974414651075975, 35.911453436115245
replace district_en = "Marka" if district == 2 & governorate_en == "Amman"
replace district_lat = 31.986640871431415 if district_en == "Marka"
replace district_long = 35.99537170646262 if district_en == "Marka"
*31.986640871431415, 35.99537170646262
replace district_en = "Al Quwaysimah" if district == 3 & governorate_en == "Amman"
replace district_lat = 31.90971482167334 if district_en == "Al Quwaysimah"
replace district_long = 35.94899163438272 if district_en == "Al Quwaysimah"
*31.90971482167334, 35.94899163438272
replace district_en = "Wadi As-Seir" if district == 5 & governorate_en == "Amman"
replace district_lat = 31.94278232023675 if district_en == "Wadi As-Seir"
replace district_long = 35.797766588883 if district_en == "Wadi As-Seir"
*31.94278232023675, 35.797766588883

*ZARQA
preserve
keep if governorate_en == "Zarqa"
list governorate_en district district_ar
restore
replace district_en = "Zarqa Qasabah" if district == 1 & governorate_en == "Zarqa"
replace district_lat = 32.065097117788476 if district_en == "Zarqa Qasabah"
replace district_long = 36.086981756472305 if district_en == "Zarqa Qasabah"
*32.065097117788476, 36.086981756472305
replace district_en = "Russeifa" if district == 2 & governorate_en == "Zarqa"
replace district_lat = 32.021339014239544 if district_en == "Russeifa"
replace district_long = 36.02891119926634 if district_en == "Russeifa"
*32.021339014239544, 36.02891119926634

*IRBID
preserve
keep if governorate_en == "Irbid"
list governorate_en district district_ar
restore
replace district_en = "Irbid Qasabah" if district == 1 & governorate_en == "Irbid"
replace district_lat = 32.55617401628591 if district_en == "Irbid Qasabah"
replace district_long = 35.84594272084967 if district_en == "Irbid Qasabah"
*32.55617401628591, 35.84594272084967

*MAFRAQ
preserve
keep if governorate_en == "Mafraq"
list governorate_en district district_ar
restore
replace district_en = "Mafraq Qasabah" if district == 1 & governorate_en == "Mafraq"
replace district_lat = 32.33796238830525 if district_en == "Mafraq Qasabah"
replace district_long = 36.18950089558544 if district_en == "Mafraq Qasabah"
*32.33796238830525, 36.18950089558544
replace district_en = "North West Badiah" if district == 2 & governorate_en == "Mafraq"
replace district_lat = 32.37274293678503 if district_en == "North West Badiah"
replace district_long = 36.30590013495499 if district_en == "North West Badiah"
*32.37274293678503, 36.30590013495499
replace district_en = "Northern Badia" if district == 3 & governorate_en == "Mafraq"
replace district_lat = 32.34273721001913 if district_en == "Northern Badia"
replace district_long = 36.21647768671195 if district_en == "Northern Badia"
*32.34273721001913, 36.21647768671195

/*
                   |               governorate_en
       district_en |     Amman      Irbid     Mafraq      Zarqa |     Total
-------------------+--------------------------------------------+----------
     Al Quwaysimah |        21          0          0          0 |        21 
    Mafraq Qasabah |         0          0        101          0 |       101 
             Marka |        22          0          0          0 |        22 
 North West Badiah |         0          0         35          0 |        35 
    Northern Badia |         0          0        163          0 |       163 
       Oman Kasbah |       104          0          0          0 |       104 
          Russeifa |         0          0          0        107 |       107 
      Wadi As-Seir |       146          0          0          0 |       146 
     Irbid Qasabah |         0        285          0          0 |       285 
     Zarqa Qasabah |         0          0          0        258 |       258 
-------------------+--------------------------------------------+----------
             Total |       293        285        299        365 |     1,242 
*/

gen sub_district = ID103
gen sub_district_ar = ID103N
gen sub_district_en = ""
gen sub_district_lat = .
gen sub_district_long = .

*AMMAN
preserve
keep if governorate_en == "Amman"
list governorate_en district_en sub_district sub_district_ar
restore

*District: Oman Kasbah
preserve
keep if governorate_en == "Amman"
keep if district_en == "Oman Kasbah"
list governorate_en district_en sub_district sub_district_ar
restore
replace sub_district_en = "Oman Kasbah"  if sub_district == 1 ///
                                & district_en == "Oman Kasbah" ///
                                & governorate_en == "Amman"
replace sub_district_lat = 31.974414651075975    if sub_district_en == "Oman Kasbah"
replace sub_district_long = 35.911453436115245  if sub_district_en == "Oman Kasbah"
*31.974414651075975, 35.911453436115245
*District: Marka
preserve
keep if governorate_en == "Amman"
keep if district_en == "Marka"
list governorate_en district_en sub_district sub_district_ar
restore
replace sub_district_en = "Marka"  if sub_district == 1 ///
                                & district_en == "Marka" ///
                                & governorate_en == "Amman"
replace sub_district_lat = 31.986640871431415   if sub_district_en == "Marka"
replace sub_district_long =  35.99537170646262 if sub_district_en == "Marka"
*31.986640871431415, 35.99537170646262
*District: Al Quwaysimah
preserve
keep if governorate_en == "Amman"
keep if district_en == "Al Quwaysimah"
list governorate_en district_en sub_district sub_district_ar
restore
replace sub_district_en = "Al Quwaysimah"  if sub_district == 1 ///
                                & district_en == "Al Quwaysimah" ///
                                & governorate_en == "Amman"
replace sub_district_lat = 31.90971482167334   if sub_district_en == "Al Quwaysimah"
replace sub_district_long = 35.94899163438272  if sub_district_en == "Al Quwaysimah"
*31.90971482167334, 35.94899163438272
*District: Wadi As-Seir
preserve
keep if governorate_en == "Amman"
keep if district_en == "Wadi As-Seir"
list governorate_en district_en sub_district sub_district_ar
restore
replace sub_district_en = "Wadi As-Seir"  if sub_district == 1 ///
                                & district_en == "Wadi As-Seir" ///
                                & governorate_en == "Amman"
replace sub_district_lat =  31.94278232023675  if sub_district_en == "Wadi As-Seir"
replace sub_district_long = 35.797766588883  if sub_district_en == "Wadi As-Seir"
*31.94278232023675, 35.797766588883

*ZARQA
preserve
keep if governorate_en == "Zarqa"
list governorate_en district_en sub_district sub_district_ar
restore

*District: Zarqa Qasabah
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Russeifa"
list governorate_en district_en sub_district sub_district_ar
restore
replace sub_district_en = "Russeifa"  if sub_district == 1 ///
                                & district_en == "Russeifa" ///
                                & governorate_en == "Zarqa"
replace sub_district_lat = 32.021339014239544  if sub_district_en == "Russeifa"
replace sub_district_long = 36.02891119926634  if sub_district_en == "Russeifa"
*32.021339014239544, 36.02891119926634

*District: Zarqa Qasabah
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Zarqa Qasabah"
list governorate_en district_en sub_district sub_district_ar
restore
replace sub_district_en = "Zarqa"  if sub_district == 1 ///
                                & district_en == "Zarqa Qasabah" ///
                                & governorate_en == "Zarqa"
replace sub_district_lat =  32.06451522131926  if sub_district_en == "Zarqa"
replace sub_district_long = 36.09110162965672  if sub_district_en == "Zarqa"
*32.06451522131926, 36.09110162965672
replace sub_district_en = "Dhlail"  if sub_district == 3 ///
                                & district_en == "Zarqa Qasabah" ///
                                & governorate_en == "Zarqa"
replace sub_district_lat = 32.11870356364973   if sub_district_en == "Dhlail"
replace sub_district_long = 36.263809282334016  if sub_district_en == "Dhlail"
*32.11870356364973, 36.263809282334016
replace sub_district_en = "Azraq"  if sub_district == 4 ///
                                & district_en == "Zarqa Qasabah" ///
                                & governorate_en == "Zarqa"
replace sub_district_lat =  31.834884097349914  if sub_district_en == "Azraq"
replace sub_district_long = 36.81421742645394  if sub_district_en == "Azraq"
*31.834884097349914, 36.81421742645394

*IRBID
preserve
keep if governorate_en == "Irbid"
list governorate_en district_en sub_district sub_district_ar
restore
replace sub_district_en = "Irbid Qasabah"  if sub_district == 1 ///
                                & district_en == "Irbid Qasabah" ///
                                & governorate_en == "Irbid"
replace sub_district_lat =  32.55617401628591  if sub_district_en == "Irbid Qasabah"
replace sub_district_long = 35.84594272084967  if sub_district_en == "Irbid Qasabah"
*32.55617401628591, 35.84594272084967

*MAFRAQ
preserve
keep if governorate_en == "Mafraq"
list governorate_en district_en sub_district sub_district_ar
restore

*District: Mafraq Qasabah
replace sub_district_en = "Al-Mafraq"  if sub_district == 1 ///
                                & district_en == "Mafraq Qasabah" ///
                                & governorate_en == "Mafraq"
replace sub_district_lat = 32.34490724290661   if sub_district_en == "Al-Mafraq"
replace sub_district_long = 36.22277226912603  if sub_district_en == "Al-Mafraq"
*32.34490724290661, 36.22277226912603
replace sub_district_en = "Balama"  if sub_district == 2 ///
                                & district_en == "Mafraq Qasabah" ///
                                & governorate_en == "Mafraq"
replace sub_district_lat =  32.23617954772689  if sub_district_en == "Balama"
replace sub_district_long =  36.087438858069085 if sub_district_en == "Balama"
*32.23617954772689, 36.087438858069085

*District: North West Badiah
replace sub_district_en = "Sabha"  if sub_district == 2 ///
                                & district_en == "North West Badiah" ///
                                & governorate_en == "Mafraq"
replace sub_district_lat = 32.332223817632226   if sub_district_en == "Sabha"
replace sub_district_long = 36.501713399134026  if sub_district_en == "Sabha"
*32.332223817632226, 36.501713399134026

*District: Northern Badia
replace sub_district_en = "Northern Badia Hospital"  if sub_district == 1 ///
                                & district_en == "Northern Badia" ///
                                & governorate_en == "Mafraq"
replace sub_district_lat =  32.26596392290488  if sub_district_en == "Northern Badia Hospital"
replace sub_district_long = 36.45663725566756  if sub_district_en == "Northern Badia Hospital"
*32.26596392290488, 36.45663725566756
replace sub_district_en = "Sama as-Sirhan"  if sub_district == 2 ///
                                & district_en == "Northern Badia" ///
                                & governorate_en == "Mafraq"
replace sub_district_lat =  32.4696026471201  if sub_district_en == "Sama as-Sirhan"
replace sub_district_long =  36.24237254635352 if sub_district_en == "Sama as-Sirhan"
*32.4696026471201, 36.24237254635352
replace sub_district_en = "Hawshah"  if sub_district == 3 ///
                                & district_en == "Northern Badia" ///
                                & governorate_en == "Mafraq"
replace sub_district_lat = 32.45110202348651   if sub_district_en == "Hawshah"
replace sub_district_long = 36.098860874001765  if sub_district_en == "Hawshah"
*32.45110202348651, 36.098860874001765
replace sub_district_en = "Al-Khalidya"  if sub_district == 4 ///
                                & district_en == "Northern Badia" ///
                                & governorate_en == "Mafraq"
replace sub_district_lat =  32.17791959252225  if sub_district_en == "Al-Khalidya"
replace sub_district_long =  36.30187946372356 if sub_district_en == "Al-Khalidya"
*32.17791959252225, 36.30187946372356

bys governorate_en district_en: tab sub_district , m
bys governorate_en district_en: tab sub_district_en , m

tab sub_district_ar , m
tab sub_district_en, m
distinct sub_district_ar
distinct sub_district_en





sort governorate district sub_district ID104

gen locality = ID104
gen locality_ar = ID104N
gen locality_en = ""
gen locality_lat = .
gen locality_long = .

*AMMAN
preserve
keep if governorate_en == "Amman"
list governorate_en district_en sub_district_en locality locality_ar
restore

*District: Al Quwaysimah
*Sub-District: Al Quwaysimah
preserve
keep if governorate_en == "Amman"
keep if district_en == "Al Quwaysimah"
keep if sub_district_en == "Al Quwaysimah"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Umm Kassir"  if    locality        == 13 ///
                                        & sub_district_en == "Al Quwaysimah" ///
                                        & district_en     == "Al Quwaysimah" ///
                                        & governorate_en  == "Amman"
replace locality_lat  = 31.89241931317512 if locality_en == "Umm Kassir"
replace locality_long = 35.91326271522353 if locality_en == "Umm Kassir"
*31.89241931317512, 35.91326271522353

*District: Marka
*Sub-District: Marka
preserve
keep if governorate_en == "Amman"
keep if district_en == "Marka"
keep if sub_district_en == "Marka"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Marka"  if   locality        ==  111 ///
                                & sub_district_en == "Marka" ///
                                & district_en     == "Marka" ///
                                & governorate_en  == "Amman"
replace locality_lat  = 31.986640871431415 if locality_en == "Marka"
replace locality_long = 35.99537170646262 if locality_en == "Marka"
*31.986640871431415, 35.99537170646262

*District: Oman Kasbah
*Sub-District: Oman Kasbah
preserve
keep if governorate_en == "Amman"
keep if district_en == "Oman Kasbah"
keep if sub_district_en == "Oman Kasbah"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Badr"  if      locality        == 116 ///
                                & sub_district_en == "Oman Kasbah" ///
                                & district_en     == "Oman Kasbah" ///
                                & governorate_en  == "Amman"
replace locality_lat  = 31.926361240204557 if locality_en == "Badr"
replace locality_long = 35.90123998988293 if locality_en == "Badr"
*31.926361240204557, 35.90123998988293

*District: Wadi As-Seir
*Sub-District: Wadi As-Seir
preserve
keep if governorate_en == "Amman"
keep if district_en == "Wadi As-Seir"
keep if sub_district_en == "Wadi As-Seir"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Wadi As-Seir"  if      locality        == 11 ///
                                & sub_district_en == "Wadi As-Seir" ///
                                & district_en     == "Wadi As-Seir" ///
                                & governorate_en  == "Amman"
replace locality_lat  = 31.94278232023675 if locality_en == "Wadi As-Seir"
replace locality_long = 35.797766588883  if locality_en == "Wadi As-Seir"
*31.94278232023675, 35.797766588883

replace locality_en = "Marj Al Hamam"  if      locality        == 13 ///
                                & sub_district_en == "Wadi As-Seir" ///
                                & district_en     == "Wadi As-Seir" ///
                                & governorate_en  == "Amman"
replace locality_lat  = 31.89721276228926 if locality_en == "Marj Al Hamam"
replace locality_long = 35.796257729550085 if locality_en == "Marj Al Hamam"
*31.89721276228926, 35.796257729550085

*ZARQA
preserve
keep if governorate_en == "Zarqa"
list governorate_en district_en sub_district_en locality locality_ar
restore

*District: Zarqa Qasabah
*Sub-District: Zarqa
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Zarqa Qasabah"
keep if sub_district_en == "Zarqa"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Zarqa"  if      locality        == 111 ///
                                & sub_district_en == "Zarqa" ///
                                & district_en     == "Zarqa Qasabah" ///
                                & governorate_en  == "Zarqa"
replace locality_lat  = 32.06451522131926 if locality_en == "Zarqa"
replace locality_long = 36.09110162965672 if locality_en == "Zarqa"
*32.06451522131926, 36.09110162965672
*Sub-District: Dhlail
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Zarqa Qasabah"
keep if sub_district_en == "Dhlail"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Dhlail"  if      locality        ==  11 ///
                                & sub_district_en == "Dhlail" ///
                                & district_en     == "Zarqa Qasabah" ///
                                & governorate_en  == "Zarqa"
replace locality_lat  = 32.11870356364973 if locality_en == "Dhlail"
replace locality_long = 36.263809282334016 if locality_en == "Dhlail"
*32.11870356364973, 36.263809282334016
*Sub-District: Azraq
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Zarqa Qasabah"
keep if sub_district_en == "Azraq"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Southern Blue"  if      locality        == 12 ///
                                & sub_district_en == "Azraq" ///
                                & district_en     == "Zarqa Qasabah" ///
                                & governorate_en  == "Zarqa"
replace locality_lat  = 31.834217835939295 if locality_en == "Southern Blue"
replace locality_long = 36.810942010642805 if locality_en == "Southern Blue"
*31.834217835939295, 36.810942010642805
*District: Russeifa
*Sub-District: Russeifa
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Russeifa"
keep if sub_district_en == "Russeifa"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Russeifa"  if      locality        == 11 ///
                                & sub_district_en == "Russeifa" ///
                                & district_en     == "Russeifa" ///
                                & governorate_en  == "Zarqa"
replace locality_lat  = 32.021339014239544 if locality_en == "Russeifa"
replace locality_long = 36.02891119926634 if locality_en == "Russeifa"
*32.021339014239544, 36.02891119926634

*IRBID
preserve
keep if governorate_en == "Irbid"
list governorate_en district_en sub_district_en locality locality_ar
restore

*District: Irbid Qasabah
*Sub-District: Irbid Qasabah
preserve
keep if governorate_en == "Irbid"
keep if district_en == "Irbid Qasabah"
keep if sub_district_en == "Irbid Qasabah"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Irbid Qasabah"  if      locality        == 111 ///
                                & sub_district_en == "Irbid Qasabah" ///
                                & district_en     == "Irbid Qasabah" ///
                                & governorate_en  == "Irbid"
replace locality_lat  = 32.55617401628591 if locality_en == "Irbid Qasabah"
replace locality_long = 35.84594272084967 if locality_en == "Irbid Qasabah"
*32.55617401628591, 35.84594272084967

*MAFRAQ
preserve
keep if governorate_en == "Mafraq"
list governorate_en district_en sub_district_en locality locality_ar
restore

*District: Mafraq Qasabah
*Sub-District: Al-Mafraq
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Mafraq Qasabah"
keep if sub_district_en == "Al-Mafraq"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Al-Mafraq"  if      locality        == 111 ///
                                & sub_district_en == "Al-Mafraq" ///
                                & district_en     == "Mafraq Qasabah" ///
                                & governorate_en  == "Mafraq"
replace locality_lat  = 32.34490724290661 if locality_en == "Al-Mafraq"
replace locality_long = 36.22277226912603 if locality_en == "Al-Mafraq"
*32.34490724290661, 36.22277226912603
*District: Mafraq Qasabah
*Sub-District: Balama
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Mafraq Qasabah"
keep if sub_district_en == "Balama"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Balama"  if      locality        == 11 ///
                                & sub_district_en == "Balama" ///
                                & district_en     == "Mafraq Qasabah" ///
                                & governorate_en  == "Mafraq"
replace locality_lat  = 32.23617954772689 if locality_en == "Balama"
replace locality_long = 36.087438858069085 if locality_en == "Balama"
*32.23617954772689, 36.087438858069085

*District: North West Badiah
*Sub-District: Sabha
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "North West Badiah"
keep if sub_district_en == "Sabha"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Sabha"  if      locality        == 11 ///
                                & sub_district_en == "Sabha" ///
                                & district_en     == "North West Badiah" ///
                                & governorate_en  == "Mafraq"
replace locality_lat  = 32.332223817632226 if locality_en == "Sabha"
replace locality_long = 36.501713399134026 if locality_en == "Sabha"
*32.332223817632226, 36.501713399134026

*District: Northern Badia 
*Sub-District: Northern Badia Hospital
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Northern Badia"
keep if sub_district_en == "Northern Badia Hospital"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Zaatari Village"  if      locality        == 11 ///
                                & sub_district_en == "Northern Badia Hospital" ///
                                & district_en     == "Northern Badia" ///
                                & governorate_en  == "Mafraq"
replace locality_lat  = 32.311040581204125 if locality_en == "Zaatari Village"
replace locality_long = 36.302097600102336 if locality_en == "Zaatari Village"
*32.311040581204125, 36.302097600102336

*District: Northern Badia 
*Sub-District: Northern Badia Hospital
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Northern Badia"
keep if sub_district_en == "Northern Badia Hospital"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Mansoura"  if      locality        == 14 ///
                                & sub_district_en == "Northern Badia Hospital" ///
                                & district_en     == "Northern Badia" ///
                                & governorate_en  == "Mafraq"
replace locality_lat  = 32.414497624348755 if locality_en == "Mansoura"
replace locality_long = 36.17090089184302 if locality_en == "Mansoura"
*32.414497624348755, 36.17090089184302

*District: Northern Badia 
*Sub-District: Sama as-Sirhan
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Northern Badia"
keep if sub_district_en == "Sama as-Sirhan"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Mugayyir as-Sirhan"  if      locality        == 12 ///
                                & sub_district_en == "Sama as-Sirhan" ///
                                & district_en     == "Northern Badia" ///
                                & governorate_en  == "Mafraq"
replace locality_lat  = 32.46168958388526 if locality_en == "Mugayyir as-Sirhan"
replace locality_long = 36.19496674381929 if locality_en == "Mugayyir as-Sirhan"
*32.46168958388526, 36.19496674381929

*District: Northern Badia 
*Sub-District: Sama as-Sirhan
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Northern Badia"
keep if sub_district_en == "Sama as-Sirhan"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Al-mutila"  if      locality        == 18 ///
                                & sub_district_en == "Sama as-Sirhan" ///
                                & district_en     == "Northern Badia" ///
                                & governorate_en  == "Mafraq"
replace locality_lat  = 32.4696026471201 if locality_en == "Al-mutila"
replace locality_long = 36.24237254635352 if locality_en == "Al-mutila"
*32.4696026471201, 36.24237254635352
*District: Northern Badia
*Sub-District: Hawshah
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Northern Badia"
keep if sub_district_en == "Hawshah"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "Al-Hamra"  if      locality        == 12 ///
                                & sub_district_en == "Hawshah" ///
                                & district_en     == "Northern Badia" ///
                                & governorate_en  == "Mafraq"
replace locality_lat  = 32.44249328026196 if locality_en == "Al-Hamra"
replace locality_long = 36.14888702081348 if locality_en == "Al-Hamra"
*32.44249328026196, 36.14888702081348
*District: Northern Badia
*Sub-District: Al-Khalidya
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Northern Badia"
keep if sub_district_en == "Al-Khalidya"
list governorate_en district_en sub_district_en locality locality_ar
restore
replace locality_en = "New Khalidiya"  if      locality        == 11 ///
                                & sub_district_en == "Al-Khalidya" ///
                                & district_en     == "Northern Badia" ///
                                & governorate_en  == "Mafraq"
replace locality_lat  = 32.150380261153956 if locality_en == "New Khalidiya"
replace locality_long = 36.28513832703932 if locality_en == "New Khalidiya"
*32.150380261153956, 36.28513832703932

tab locality_en, m
tab locality_ar, m

bys governorate_en: tab locality_en, m


gen area = ID105
gen area_ar = ID105N
gen area_en = ""
gen area_lat = .
gen area_long = .

sort governorate district sub_district locality area

list governorate_en district_en sub_district_en locality_en area area_ar if governorate_en == "Amman"
list governorate_en district_en sub_district_en locality_en area area_ar if governorate_en == "Zarqa"
list governorate_en district_en sub_district_en locality_en area area_ar if governorate_en == "Irbid"
list governorate_en district_en sub_district_en locality_en area area_ar if governorate_en == "Mafraq"


*AMMAN
preserve
keep if governorate_en == "Amman"
list governorate_en district_en sub_district_en locality_en area area_ar
restore

*District: 
*Sub-District: 
*Locality: 
preserve
keep if governorate_en == "Amman"
keep if district_en == "Oman Kasbah"
keep if sub_district_en == "Oman Kasbah"
keep if locality_en == "Badr"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Badr"  if            area == 7 ///
                                        & locality_en == "Badr" /// 
                                        & sub_district_en == "Oman Kasbah" ///
                                        & district_en     == "Oman Kasbah" ///
                                        & governorate_en  == "Amman"
replace area_lat  = 31.926361240204557 if area_en == "Badr"
replace area_long = 35.90123998988293 if area_en == "Badr"
*31.926361240204557, 35.90123998988293

*District: Marka
*Sub-District: Marka
*Locality: Marka
preserve
keep if governorate_en == "Amman"
keep if district_en == "Marka"
keep if sub_district_en == "Marka"
keep if locality_en == "Marka"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Marka"  if            area == 3 ///
                                        & locality_en == "Marka" /// 
                                        & sub_district_en == "Marka" ///
                                        & district_en     == "Marka" ///
                                        & governorate_en  == "Amman"
replace area_lat  = 31.986640871431415 if area_en == "Marka"
replace area_long = 35.99537170646262 if area_en == "Marka"
*31.986640871431415, 35.99537170646262

*District: Al Quwaysimah 
*Sub-District: Al Quwaysimah
*Locality: Umm Kassir
preserve
keep if governorate_en == "Amman"
keep if district_en == "Al Quwaysimah"
keep if sub_district_en == "Al Quwaysimah"
keep if locality_en == "Umm Kassir"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Al-Muqabalayn"  if            area == 13 ///
                                        & locality_en == "Umm Kassir" /// 
                                        & sub_district_en == "Al Quwaysimah" ///
                                        & district_en     == "Al Quwaysimah" ///
                                        & governorate_en  == "Amman"
replace area_lat  = 31.903458101435962 if area_en == "Al-Muqabalayn"
replace area_long = 35.917039265647816 if area_en == "Al-Muqabalayn"
*31.903458101435962, 35.917039265647816

*District: Wadi As-Seir
*Sub-District: Wadi As-Seir
*Locality: Wadi As-Seir
preserve
keep if governorate_en == "Amman"
keep if district_en == "Wadi As-Seir"
keep if sub_district_en == "Wadi As-Seir"
keep if locality_en == "Wadi As-Seir"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Wadi As-Seir"  if            area == 14 ///
                                        & locality_en == "Wadi As-Seir" /// 
                                        & sub_district_en == "Wadi As-Seir" ///
                                        & district_en     == "Wadi As-Seir" ///
                                        & governorate_en  == "Amman"
replace area_lat  = 31.94278232023675 if area_en == "Wadi As-Seir"
replace area_long = 35.797766588883 if area_en == "Wadi As-Seir"
*31.94278232023675, 35.797766588883 

*District: Wadi As-Seir
*Sub-District: Wadi As-Seir
*Locality: Marj Al Hamam
preserve
keep if governorate_en == "Amman"
keep if district_en == "Wadi As-Seir"
keep if sub_district_en == "Wadi As-Seir"
keep if locality_en == "Marj Al Hamam"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Marj Al Hamam"  if            area == 1 ///
                                        & locality_en == "Marj Al Hamam" /// 
                                        & sub_district_en == "Wadi As-Seir" ///
                                        & district_en     == "Wadi As-Seir" ///
                                        & governorate_en  == "Amman"
replace area_lat  = 31.89721276228926 if area_en == "Marj Al Hamam"
replace area_long = 35.796257729550085 if area_en == "Marj Al Hamam"
*31.89721276228926, 35.796257729550085




*AMMAN
preserve
keep if governorate_en == "Zarqa"
list governorate_en district_en sub_district_en locality_en area area_ar
restore

*District: Zarqa Qasabah
*Sub-District: Zarqa
*Locality: Zarqa
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Zarqa Qasabah"
keep if sub_district_en == "Zarqa"
keep if locality_en == "Zarqa"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "First Area"  if            area == 1 ///
                                        & locality_en == "Zarqa" /// 
                                        & sub_district_en == "Zarqa" ///
                                        & district_en     == "Zarqa Qasabah" ///
                                        & governorate_en  == "Zarqa"
list area_en ID106N if area_en == "First Area"
replace area_lat  = 32.0691308838672 if area_en == "First Area"
replace area_long = 36.082654486715775 if area_en == "First Area"
*32.0691308838672, 36.082654486715775

*District: Zarqa Qasabah
*Sub-District: Zarqa
*Locality: Zarqa
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Zarqa Qasabah"
keep if sub_district_en == "Zarqa"
keep if locality_en == "Zarqa"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Second Area"  if            area == 2 ///
                                        & locality_en == "Zarqa" /// 
                                        & sub_district_en == "Zarqa" ///
                                        & district_en     == "Zarqa Qasabah" ///
                                        & governorate_en  == "Zarqa"
list area_en ID106N if area_en == "Second Area"
replace area_lat  = 32.03985570620314 if area_en == "Second Area"
replace area_long = 36.09459668475456 if area_en == "Second Area"
*32.03985570620314, 36.09459668475456

*District: Zarqa Qasabah
*Sub-District: Zarqa
*Locality: Zarqa
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Zarqa Qasabah"
keep if sub_district_en == "Zarqa"
keep if locality_en == "Zarqa"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Sixth Area"  if            area == 6 ///
                                        & locality_en == "Zarqa" /// 
                                        & sub_district_en == "Zarqa" ///
                                        & district_en     == "Zarqa Qasabah" ///
                                        & governorate_en  == "Zarqa"
list area_en ID106N if area_en == "Sixth Area"
replace area_lat  = 32.07380581797431 if area_en == "Sixth Area"
replace area_long = 36.08956394598998 if area_en == "Sixth Area"
*32.07380581797431, 36.08956394598998

*District: Zarqa Qasabah
*Sub-District: Dhlail
*Locality: Dhlail
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Zarqa Qasabah"
keep if sub_district_en == "Dhlail"
keep if locality_en == "Dhlail"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Dhlail"  if            area == 1 ///
                                        & locality_en == "Dhlail" /// 
                                        & sub_district_en == "Dhlail" ///
                                        & district_en     == "Zarqa Qasabah" ///
                                        & governorate_en  == "Zarqa"
replace area_lat  = 32.11870356364973 if area_en == "Dhlail"
replace area_long = 36.263809282334016 if area_en == "Dhlail"
*2.11870356364973, 36.263809282334016

*District: Zarqa Qasabah
*Sub-District: Azraq
*Locality: Southern Blue
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Zarqa Qasabah"
keep if sub_district_en == "Azraq"
keep if locality_en == "Southern Blue"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Southern Blue"  if            area == 1 ///
                                        & locality_en == "Southern Blue" /// 
                                        & sub_district_en == "Azraq" ///
                                        & district_en     == "Zarqa Qasabah" ///
                                        & governorate_en  == "Zarqa"
replace area_lat  = 31.834217835939295 if area_en == "Southern Blue"
replace area_long = 36.810942010642805 if area_en == "Southern Blue"
*31.834217835939295, 36.810942010642805

*District: Russeifa
*Sub-District: Russeifa
*Locality: Russeifa
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Russeifa"
keep if sub_district_en == "Russeifa"
keep if locality_en == "Russeifa"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Al-meriat"  if            area == 1 ///
                                        & locality_en == "Russeifa" /// 
                                        & sub_district_en == "Russeifa" ///
                                        & district_en     == "Russeifa" ///
                                        & governorate_en  == "Zarqa"
replace area_lat  = 31.60882713502509 if area_en == "Al-meriat"
replace area_long = 36.00189692062163 if area_en == "Al-meriat"
*31.60882713502509, 36.00189692062163

*District: Russeifa
*Sub-District: Russeifa
*Locality: Russeifa
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Russeifa"
keep if sub_district_en == "Russeifa"
keep if locality_en == "Russeifa"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Al-Qadisiyah"  if            area == 2 ///
                                        & locality_en == "Russeifa" /// 
                                        & sub_district_en == "Russeifa" ///
                                        & district_en     == "Russeifa" ///
                                        & governorate_en  == "Zarqa"
replace area_lat  = 32.037955146121476 if area_en == "Al-Qadisiyah"
replace area_long = 36.03420914994394 if area_en == "Al-Qadisiyah"
*32.037955146121476, 36.03420914994394

*District: Russeifa
*Sub-District: Russeifa
*Locality: Russeifa
preserve
keep if governorate_en == "Zarqa"
keep if district_en == "Russeifa"
keep if sub_district_en == "Russeifa"
keep if locality_en == "Russeifa"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Al-Rashid"  if         area == 4 ///
                                        & locality_en == "Russeifa" /// 
                                        & sub_district_en == "Russeifa" ///
                                        & district_en     == "Russeifa" ///
                                        & governorate_en  == "Zarqa"
list area_en ID106N if area_en == "Al-Rashid"
replace area_lat  = 32.02839782374531 if area_en == "Al-Rashid"
replace area_long = 36.02495112130838 if area_en == "Al-Rashid"
*32.02839782374531, 36.02495112130838


*IRBID 
preserve
keep if governorate_en == "Irbid"
list governorate_en district_en sub_district_en locality_en area area_ar
restore

*District: Irbid Qasabah
*Sub-District: Irbid Qasabah
*Locality: Irbid Qasabah
preserve
keep if governorate_en == "Irbid"
keep if district_en == "Irbid Qasabah"
keep if sub_district_en == "Irbid Qasabah"
keep if locality_en == "Irbid Qasabah"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Al-Nozha"  if            area == 4 ///
                                        & locality_en == "Irbid Qasabah" /// 
                                        & sub_district_en == "Irbid Qasabah" ///
                                        & district_en     == "Irbid Qasabah" ///
                                        & governorate_en  == "Irbid"
list area_en ID106N if area_en == "Al-Nozha"
replace area_lat  = 32.55124499173366 if area_en == "Al-Nozha"
replace area_long = 35.855454869030616 if area_en == "Al-Nozha"
*32.55124499173366, 35.855454869030616

*District: Irbid Qasabah
*Sub-District: Irbid Qasabah
*Locality: Irbid Qasabah
preserve
keep if governorate_en == "Irbid"
keep if district_en == "Irbid Qasabah"
keep if sub_district_en == "Irbid Qasabah"
keep if locality_en == "Irbid Qasabah"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Al-Rabiyeh"  if            area == 5 ///
                                        & locality_en == "Irbid Qasabah" /// 
                                        & sub_district_en == "Irbid Qasabah" ///
                                        & district_en     == "Irbid Qasabah" ///
                                        & governorate_en  == "Irbid"
list area_en ID106N if area_en == "Al-Rabiyeh"
replace area_lat  = 32.52607293775749 if area_en == "Al-Rabiyeh"
replace area_long = 35.84590842717352 if area_en == "Al-Rabiyeh"
*32.52607293775749, 35.84590842717352

*MAFRAQ

preserve
keep if governorate_en == "Mafraq"
list governorate_en district_en sub_district_en locality_en area area_ar
restore

*District: Mafraq Qasabah
*Sub-District: Al-Mafraq
*Locality: Al-Mafraq
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Mafraq Qasabah"
keep if sub_district_en == "Al-Mafraq"
keep if locality_en == "Al-Mafraq"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Al-Mafraq"  if            area == 1 ///
                                        & locality_en == "Al-Mafraq" /// 
                                        & sub_district_en == "Al-Mafraq" ///
                                        & district_en     == "Mafraq Qasabah" ///
                                        & governorate_en  == "Mafraq"
replace area_lat  = 32.34490724290661 if area_en == "Al-Mafraq"
replace area_long = 36.22277226912603 if area_en == "Al-Mafraq"
*32.34490724290661, 36.22277226912603

*District: Mafraq Qasabah
*Sub-District: Balama
*Locality: Balama
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Mafraq Qasabah"
keep if sub_district_en == "Balama"
keep if locality_en == "Balama"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Balama"  if            area == 1 ///
                                        & locality_en == "Balama" /// 
                                        & sub_district_en == "Balama" ///
                                        & district_en     == "Mafraq Qasabah" ///
                                        & governorate_en  == "Mafraq"
replace area_lat  = 32.23617954772689 if area_en == "Al-Mafraq"
replace area_long = 36.087438858069085 if area_en == "Al-Mafraq"
*32.23617954772689, 36.087438858069085


*District: North West Badiah
*Sub-District: Sabha
*Locality: Sabha
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "North West Badiah"
keep if sub_district_en == "Sabha"
keep if locality_en == "Sabha"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Sabha"  if            area == 1 ///
                                        & locality_en == "Sabha" /// 
                                        & sub_district_en == "Sabha" ///
                                        & district_en     == "North West Badiah" ///
                                        & governorate_en  == "Mafraq"
replace area_lat  = 32.332223817632226 if area_en == "Sabha"
replace area_long = 36.501713399134026 if area_en == "Sabha"
*32.332223817632226, 36.501713399134026

*District: Northern Badia
*Sub-District: Northern Badia Hospital
*Locality: Zaatari Village
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Northern Badia"
keep if sub_district_en == "Northern Badia Hospital"
keep if locality_en == "Zaatari Village"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Zaatari Village"  if            area == 1 ///
                                        & locality_en == "Zaatari Village" /// 
                                        & sub_district_en == "Northern Badia Hospital" ///
                                        & district_en     == "Northern Badia" ///
                                        & governorate_en  == "Mafraq"
replace area_lat  = 32.311040581204125 if area_en == "Zaatari Village"
replace area_long = 36.302097600102336 if area_en == "Zaatari Village"
*32.311040581204125, 36.302097600102336


*District: Northern Badia
*Sub-District: Northern Badia Hospital
*Locality: Mansoura
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Northern Badia"
keep if sub_district_en == "Northern Badia Hospital"
keep if locality_en == "Mansoura"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Mansoura"  if            area == 1 ///
                                        & locality_en == "Mansoura" /// 
                                        & sub_district_en == "Northern Badia Hospital" ///
                                        & district_en     == "Northern Badia" ///
                                        & governorate_en  == "Mafraq"
replace area_lat  = 32.414497624348755 if area_en == "Mansoura"
replace area_long = 36.17090089184302 if area_en == "Mansoura"
*32.414497624348755, 36.17090089184302



*District: Northern Badia
*Sub-District: Sama as-Sirhan
*Locality: Mugayyir as-Sirhan
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Northern Badia"
keep if sub_district_en == "Sama as-Sirhan"
keep if locality_en == "Mugayyir as-Sirhan"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Mugayyir as-Sirhan"  if            area == 1 ///
                                        & locality_en == "Mugayyir as-Sirhan" /// 
                                        & sub_district_en == "Sama as-Sirhan" ///
                                        & district_en     == "Northern Badia" ///
                                        & governorate_en  == "Mafraq"
replace area_lat  = 32.46168958388526  if area_en == "Mugayyir as-Sirhan"
replace area_long = 36.19496674381929  if area_en == "Mugayyir as-Sirhan"
*32.46168958388526, 36.19496674381929


*District: Northern Badia
*Sub-District: 
*Locality:Al-mutila
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Northern Badia"
keep if sub_district_en == "Sama as-Sirhan"
keep if locality_en == "Al-mutila"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Al-mutila"  if            area == 1 ///
                                        & locality_en == "Al-mutila" /// 
                                        & sub_district_en == "Sama as-Sirhan" ///
                                        & district_en     == "Northern Badia" ///
                                        & governorate_en  == "Mafraq"
replace area_lat  = 32.4696026471201 if area_en == "Al-mutila"
replace area_long = 36.24237254635352 if area_en == "Al-mutila"
*32.4696026471201, 36.24237254635352

*District: Northern Badia
*Sub-District: Hawshah
*Locality: Al-Hamra
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Northern Badia"
keep if sub_district_en == "Hawshah"
keep if locality_en == "Al-Hamra"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "Al-Hamra"  if            area == 1 ///
                                        & locality_en == "Al-Hamra" /// 
                                        & sub_district_en == "Hawshah" ///
                                        & district_en     == "Northern Badia" ///
                                        & governorate_en  == "Mafraq"
replace area_lat  = 32.44249328026196 if area_en == "Al-Hamra"
replace area_long = 36.14888702081348 if area_en == "Al-Hamra"
*32.44249328026196, 36.14888702081348



*District: Northern Badia
*Sub-District: Al-Khalidya
*Locality: New Khalidiya
preserve
keep if governorate_en == "Mafraq"
keep if district_en == "Northern Badia"
keep if sub_district_en == "Al-Khalidya"
keep if locality_en == "New Khalidiya"
list governorate_en district_en sub_district_en locality_en area area_ar
restore
replace area_en = "New Khalidiya"  if            area == 1 ///
                                        & locality_en == "New Khalidiya" /// 
                                        & sub_district_en == "Al-Khalidya" ///
                                        & district_en     == "Northern Badia" ///
                                        & governorate_en  == "Mafraq"
replace area_lat  = 32.150380261153956 if area_en == "New Khalidiya"
replace area_long = 36.28513832703932 if area_en == "New Khalidiya"
*32.150380261153956, 36.28513832703932

gen neighborhood = ID106
gen neighborhood_ar = ID106N
*gen neighborhood_en = ""

gen block_nb = ID107
gen building_nb = ID108 
gen apt_nb = ID109


save "$data_2020_final/Jordan2020_02_Clean.dta", replace

/*
duplicates tab ID103N, gen(dup)
egen id_subdis = group(ID103N) 
bys id_subdis: gen id_subdisdrop = _n
drop if id_subdisdrop != 1
list ID103N
tab ID103, m 

*/
