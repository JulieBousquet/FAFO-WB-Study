

use "$data_2014_final/Jordan2014_ROS_HH_RSI.dta", clear
desc 

/*
 obs:        21,524                          
 vars:       738                          
*/

distinct hhid 
* 3860

distinct iid 
* 21524 

************ DEMOGRAPHICS ************

*Governorate
tab governorate, m 
tab q101, m 
/*
Governorate |      Freq.     Percent        Cum.
------------+-----------------------------------
      Amman |      4,821       22.40       22.40
      Irbid |      6,269       29.13       51.52
     Mafraq |     10,434       48.48      100.00
------------+-----------------------------------
      Total |     21,524      100.00
*/


desc q102 q103 q104 q105 q106 q107 q108

*District
bys q101: tab q102, m 
bys q101: distinct q102
/*
Amman: 9
Irbid: 9
Mafraq: 4
*/

*Sub-District
bys q101: distinct q103
desc q103 

*Locality
desc q104
bys q101: distinct q104
/*
Amman: 12
Irbid: 16
Mafraq: 14
*/
*Area
desc q105 
*Neighborhood
desc q106
*Block Number
desc q107
*Building Number
desc q108

*************
** REFUGEE **
*************

*Household Head info
tab nat_hh, m 
tab nat_samp, m   
tab HHgroup, m 
codebook HHgroup 
/*
            tabulation:  Freq.   Numeric  Label
                         3,675         1  Household in Zaatari camp
                         9,253         2  Household with Syrian refugee
                                          head outside camp
                         7,950         3  Household with Jordanian
                                          non-refugee head
                           646         4  Other

*/
tab HHrefugee
tab HHrefugee, m
codebook HHrefugee

*br HHrefugee HHgroup nat_samp nat_hh survey_hh survey_rsi survey_ros
format HHrefugee nat_samp nat_hh  %15.0g
format HHgroup  %50.0g

*Roster infi
*Citizenship
tab q307, m 
ren q307 nationality

*Refugee status 
tab q308, m 
replace q308 = 2 if mi(q308) & hhid == 2223004 

ren q308 refugee 

******************
** WORK PERMITS **
******************

*RSI
tab r301 , m
*Refugee and in RSI
tab r301 if survey_rsi == 1 & refugee == 1 , m
/*
Applied for |
work permit |
for current |
   main job |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |         60       13.02       13.02
         No |        349       75.70       88.72
          . |         52       11.28      100.00
------------+-----------------------------------
      Total |        461      100.00
*/

*ROSTER
*Employed 
tab q502 
tab q503 
tab q504
codebook q531
codebook q528
preserve
keep if q502 == 1 | q503 == 1 | q504 == 1
keep if refugee == 1 
tab q528, m //Type contract
tab q531, m //Work permit
*br hhid iid q502 q503 q504 r301 q528 q531 if mi(q531)
*format q528  %30.0g
restore
replace q531 = r301 if iid == 11237021
replace q531 = r301 if iid == 21122121
replace q531 = 1 if q528 == 1 //if written agreement = permit
replace q531 = 2 if q528 == 2 //if oral agreement = NO permit
replace q531 = 2 if q528 == 3 //if neither = NO permit


/*

Work permit |
   for main |
        job |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |         52        8.46        8.46
         No |        563       91.54      100.00
------------+-----------------------------------
      Total |        615      100.00


*/
ren r301 rsi_work_permit
ren q531 ros_work_permit 

tab ros_work_permit, m 

recode rsi_work_permit (2=0)
recode ros_work_permit (2=0) 
lab def yesno 1 "Yes" 0 "No", modify
lab val ros_work_permit yesno
lab val rsi_work_permit yesno

tab ros_work_permit if (q502 == 1 | q503 == 1 | q504 == 1) & (refugee == 1)  , m
*Yes |         52        8.46       
*No  |        563       91.54  

tab rsi_work_permit if survey_rsi == 1 & refugee == 1 , m
* Yes |         60       13.02       13.02
*  No |        349       75.70       88.72


******************
**** OUTCOMES ****
******************

**** EMPLOYEMENT ****

tab q502  
tab q503  
tab q504 

*Age
tab q305
*drop if q305 < 15 //Keep only adult sample 

*Has never worked
tab q501
codebook q501
*drop if q501 == 97 //Keep only adult who has worked at least once in their life

*The var
gen ros_employed = 0
replace ros_employed = 1 if q502 == 1 | q503 == 1 | q504 == 1
tab ros_employed, m
*Note that if they were employed, then they were eligible to RSI.
*So in RSI, is only employed people
tab ros_employed if (q305 >= 15) & (q501 != 97) 

bys ros_employed: tab q303 if survey_rsi == 1

**** WAGE INCOME ****

*HOUSEHOLD 
codebook q900 // Wage income: if q900 == INCOME 1
tab q900_qy // Wage income last year
tab q900_qm // Wage income last month

*ROSTER
tab q532 //Cash Income Main Job Last month (cont)
tab q532new //Cash Income Main Job Last month (cat)

ren q532 ros_wage_income_lm_cont
gen ros_wage_income_lm_cont_ln = ln(ros_wage_income_lm_cont)

tab q533 //Usual Monthly cash income (cont)
tab q533new //Usual Monthly cash income (cat)

tab q536 //Cash Income Additional Job Last month (cont)
tab q536new //Cash Income Additional Job Last month (cat)
tab q532and536 //Total cash income last month (cont)
tab q532and536new //Total cash Income last month (cat)

*RSI 
tab r204 //Cash Income Main Job Last month (cont)
tab r204new //Cash Income Main Job Last month (cat)

ren r204 rsi_wage_income_lm_cont


tab r205 //Usual Monthly cash income (cont)
tab r205new //Usual Monthly cash income (cat)

tab r226 //Cash Income Additional Job Last month (cont)
tab r226new //Cash Income Additional Job Last month (cat)

**** SELF EMPLOYED INCOME ****
codebook q901 // Self-employment income: if q901 == INCOME 1
tab q901_qy // Self-employment income last year
tab q901_qm // Self-employment income last month

*Section 9: wealth 
*Wage income 
tab q900 
tab q900_qy 
tab q900_qm 
*Self employment income 
tab q901 
tab q901_qy 
tab q901_qm 
*Transfer income 
tab q902 
tab q902_qy 
tab q902_qm 
*Property income 
tab q903 
tab q903_qy 
tab q903_qm 
*Other Income 
tab q904 
tab q904_qy 
tab q904_qm 
*Total income 
tab q905 
tab q905_qy

*Industry
tab q514 
tab q514new

*Occupation 
tab q515 
tab q515new


***** HOURS WORKED ****
tab r203
ren r203 rsi_work_hours_7d

tab r227
tab r228


****** DEMOGRAPHICS ******

tab HHsex , m //Sex of HH
tab RSIsex, m //Sex of RSI resp 
tab q303, m //Sex
ren q303 ros_gender
ren HHsex hh_gender 

tab q115_tnew, m
tab q115_t, m
ren q115_t hh_hhsize

tab q305, m
ren q305 ros_age


*drop if q305 < 15 
*drop if q501 == 97 
*drop if refugee != 1

***** DETERMINANT OF GETTING A WORK PERMIT 
preserve
keep if refugee == 1
logit rsi_work_permit ///
        ros_employed  ///
        ros_wage_income_lm_cont ///
        rsi_work_hours_7d  
restore

***** CHARACTERISTICS OF INDIVIDUAALS/HOUSEHOLDS GETTING A WP

preserve

keep if refugee == 1
ttest hh_hhsize, by(rsi_work_permit)
ttest ros_gender, by(rsi_work_permit)
ttest hh_gender, by(rsi_work_permit)
ttest ros_age, by(rsi_work_permit)
*ttest economy, by(rsi_work_permit)
ttest refugee, by(rsi_work_permit)

logit rsi_work_permit hh_hhsize 
logit rsi_work_permit ros_gender 
logit rsi_work_permit hh_gender 
logit rsi_work_permit ros_age

logit rsi_work_permit ros_age hh_hhsize ros_gender ros_age

  *i.industry i.occupation 
restore

***** HOW DOES HAVING A WP AFFECTS OUTCOME VAR 
preserve

keep if refugee == 1
reg ros_wage_income_lm_cont_ln rsi_work_permit, robust
reg rsi_work_hours_7d rsi_work_permit, robust
reg ros_employed rsi_work_permit, robust
restore

save "$data_2014_final/Jordan2014_02_Clean.dta", replace

























































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



desc 

/*
 obs:         1,243                          
 vars:        572                         
*/

distinct hhid 
* 622 

distinct iid 
* 1242

************ DEMOGRAPHICS ************

*Governorate
tab ID101, m 
/*
Governorate |      Freq.     Percent        Cum.
------------+-----------------------------------
      Amman |        293       23.59       23.59
      Zarqa |        365       29.39       52.98
      Irbid |        285       22.95       75.93
     Mafraq |        299       24.07      100.00
------------+-----------------------------------
      Total |      1,242      100.00
*/

*District
bys ID101: tab ID102, m 
bys ID101: distinct ID102
/*
Amman: 4
Zarqa: 2
Irbid: 1
Mafraq: 3
*/

*Sub-District
bys ID101: distinct ID103
desc ID103 

*Locality
desc ID104
bys ID101: distinct ID104
/*
Amman: 4
Zarqa: 3
Irbid: 1
Mafraq: 5
*/
*Area
desc ID105 
*Neighborhood
desc ID106
*Block Number
desc ID107
*Building Number
desc ID108


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

******************
**** OUTCOMES ****
******************

**** EMPLOYEMENT ****

*If yes to 1, 2, 3, 4: Employed 
tab QH301, m 
tab QH302, m
tab QH303, m 
tab QH304, m 
*If yes to 5, 6, 7: Unemployed 
tab QH305, m 
tab QH306, m 
tab QH307, m
*Otherwise, out of the labor force

*Variable created by FAFO 
tab qhemp, m 
codebook qhemp
gen ros_employed = 0
replace ros_employed = 1 if QH301 == 1 | QH302 == 1 | QH303== 1 | QH304 == 1
tab ros_employed, m
lab val ros_employed yesno

tab QH205, m //only have 16yo or more
tab ros_employed 

bys qhemp: tab QH203  if survey_rsi == 1


**** WAGE INCOME ****

*HH survey
tab QH502_2, m //Wage income last month (cat)
tab QH502_4, m //Wage income last 12 months (cat)

*RSI survey
tab QR608, m //wage income last month (cont)
tab QR609, m //wage income typical (cont)

mdesc QH502_2 QH502_4 QR608 QR609


ren QH502_2 hh_wage_income_lm_cat
ren QH502_4 hh_wage_income_l12m_cat
ren QR608 	rsi_wage_income_lm_cont
ren QR609 	rsi_wage_income_typ_cont

gen rsi_wage_income_lm_cont_ln = ln(1+ rsi_wage_income_lm_cont)
tab rsi_wage_income_lm_cont_ln, m

**** SELF-EMPLOYED INCOME ****

*HH survey
tab QH503_2, m //se income last month (cat)
tab QH503_4, m //se income last 12 months (cat)

*Section 5.1: INCOME
tab QH504_A // Income private transfer = 1
tab QH504_B // Income private transfer last 12 months (cat)

tab QH505_A // Income institutional transfer = 1
tab QH505_B // Income institutional transfer last 12 months (cat)

tab QH506_A // Income properties = 1
tab QH506_B // Income proeperties last 12 monhts (cat)

tab QH507_A // Other income = 1
tab QH507_B // Other income last 12 monhts (Cat)

tab QH507O

*RSI survey
tab QR705, m //se income last month (cont)
tab QR706, m //se income last 12 months (cont)

mdesc QH503_2 QH503_4 QR705 QR706

ren QH503_2 hh_se_income_lm_cat
ren QH503_4 hh_se_income_l12m_cat
ren QR705 	rsi_se_income_lm_cont
ren QR706 	rsi_se_income_typ_cont

**** ADDITIONAL INCOME ****

*RSI : Additional Income 

tab QR805, m
tab QR806, m

**** WORKING HOURS  ****

tab QR506, m //Number of hours work during the past 7 das
tab QR507, m //Number of hours work during the past month
ren QR506 rsi_work_hours_7d
ren QR507 rsi_work_hours_m


bys refugee : tab rsi_work_permit ros_employed , m
/*
-> refugee = Refugee

    Have a |
valid work |     ros_employed
    permit |        No        Yes |     Total
-----------+----------------------+----------
        No |       434        112 |       546 
       Yes |        23         78 |       101 
-----------+----------------------+----------
     Total |       457        190 |       647 
*/

****** DEMOGRAPHICS ******

tab qrgender, m
tab headgender, m
ren qrgender ros_gender
ren headgender hh_gender 

tab hhsize, m 
ren hhsize hh_hhsize

tab qrage, m
ren qrage ros_age

tab economy, m 
ren economy hh_poor


***** DETERMINANT OF GETTING A WORK PERMIT 
preserve

keep if refugee == 1
logit rsi_work_permit ///
        ros_employed  ///
        rsi_wage_income_lm_cont ///
        rsi_work_hours_m ///
        
restore

***** CHARACTERISTICS OF INDIVIDUAALS/HOUSEHOLDS GETTING A WP
preserve

keep if refugee == 1
ttest hh_hhsize, by(rsi_work_permit)
ttest ros_gender, by(rsi_work_permit)
ttest hh_gender, by(rsi_work_permit)
ttest ros_age, by(rsi_work_permit)
ttest hh_poor, by(rsi_work_permit)
ttest refugee, by(rsi_work_permit)

logit rsi_work_permit hh_hhsize ros_gender hh_gender ros_age hh_poor 

  *i.industry i.occupation 
restore

***** HOW DOES HAVING A WP AFFECTS OUTCOME VAR 
preserve

keep if refugee == 1
reg rsi_wage_income_lm_cont_ln rsi_work_permit, robust
reg rsi_work_hours_m rsi_work_permit, robust
reg ros_employed rsi_work_permit, robust
restore

preserve
keep if refugee == 1
tab rsi_work_permit QR112
tab rsi_work_permit QR113 
tab rsi_work_permit QR114 
tab rsi_work_permit QR115

tab rsi_work_permit QR301 

tab QR501 rsi_work_permit
tab QR502 rsi_work_permit

tab rsi_work_permit QR512
tab QR514 rsi_work_permit 
tab rsi_work_permit QR601

tab QR605S rsi_work_permit 
corr  QR605S rsi_work_permit

corr rsi_work_permit QR1312
corr rsi_work_permit QR1313_1 QR1313_2 QR1313_3 QR1313_4 QR1313_5 QR1314 QR1315

foreach var of varlist * {
    capture assert missing(`var')
    if !_rc drop `var'
}


 tab QR213
 tab rsi_work_permit QR213 
 corr rsi_work_permit QR213

 gen indsutry_wp = 0 
 replace indsutry_wp = QR204 if rsi_work_permit == 1 
 replace indsutry_wp = QR213 if rsi_work_permit == 1 & mi(indsutry_wp)

 tab indsutry_wp rsi_work_permit 
 corr industry indsutry_wp 

 *Documented migrants

drop if refugee == 2
tab QR112, m
tab QR113, m
tab QR114, m
tab QR115, m
tab QR215, m
* B = No need/No Necessary

tab QR112 rsi_work_permit 
tab QR114 rsi_work_permit 
tab QR215 rsi_work_permit 
tab industry rsi_work_permit 
mdesc industry
tab employ, m
tab employ rsi_work_permit 

tab QR117, m

 graph bar, ///
  over(QR117, sort(1) descending label(angle(ninety))) ///
  blabel(bar, format(%3.2g)) ///
  title("In which Syrian governorate did you live before" "ariving to Jordan?") ///
  subtitle(In Percentage) ///
  note("n=677, missing=30" "FAFO, 2020, RSI")
graph export "$out_LFS/bar_gov_origin.pdf", as(pdf) replace

restore

lab list nationality
/*
           1 Jordanian
           2 Syrian
           3 Egyptian
           4 Palestinian
*/
tab industry rsi_work_permit  if nationality == 2
tab industry rsi_work_permit  if nationality == 1

*save "$data_2020_final/Jordan2020_02_Clean.dta", replace

*********** INSTRUMENT *************



*use "$data_2020_final/Jordan2020_02_Clean.dta", clear

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


duplicates tab ID103N, gen(dup)
egen id_subdis = group(ID103N) 
bys id_subdis: gen id_subdisdrop = _n
drop if id_subdisdrop != 1
list ID103N
tab ID103, m 


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
h geodist

**** MAP OF JORDAN + POINT DISTRICT
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
   point(data("$data_2020_final/Jordan2020_02_Clean.dta") xcoord(district_long)      ///
        ycoord(district_lat) size(*0.7) fcolor(blue)) 

*MAP OF SYRIA + POINT GOVERNROATE
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
   point(data("$data_2020_final/governorate_loc_syr.dta") xcoord(gov_syria_long)      ///
        ycoord(gov_syria_lat) size(*0.7) fcolor(blue)) 

use "$data_2020_final/Jordan2020_02_Clean.dta", clear


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

use "$data_2020_final/Jordan2020_geo_Syria.dta", clear 

h geodist

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

/*
SHIFT 
*/

*Number of refugee with work permits 
*In 2020
use "$data_2020_final/Jordan2020_02_Clean.dta", clear
tab rsi_work_permit, m
*In 2014
use "$data_2014_final/Jordan2014_02_Clean.dta", clear
tab rsi_work_permit, m

