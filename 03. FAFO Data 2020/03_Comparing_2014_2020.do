

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



















tab QR502 if rsi_work_permit == 1







































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
br industry
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
br industry_orig industry_ar

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
br industry

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
replace refugee = 2 if QH207 == 1 | QH207 == 3 | QH207 == 10
lab def refugee 1 "Refugee" 2 "Non refugee", modify
lab val refugee refugee 
lab var refugee "Refugee is 1 if Syrian is 2 if other (Jordan, Egyptian)"
tab refugee, m

replace refugee = 1 if mi(refugee) & headnation == 2
replace refugee = 2 if mi(refugee) & (headnation == 1 | headnation == 3)
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

gen rsi_wage_income_lm_cont_ln = ln(rsi_wage_income_lm_cont)

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
