

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

tab q533 //Usual Monthly cash income (cont)
tab q533new //Usual Monthly cash income (cat)

tab q536 //Cash Income Additional Job Last month (cont)
tab q536new //Cash Income Additional Job Last month (cat)
tab q532and536 //Total cash income last month (cont)
tab q532and536new //Total cash Income last month (cat)

*RSI 
tab r204 //Cash Income Main Job Last month (cont)
tab r204new //Cash Income Main Job Last month (cat)

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
*r203 r203new
*r227 
*r228 


**** WORKING HOURS  ****

tab QR506, m //Number of hours work during the past 7 das
tab QR507, m //Number of hours work during the past month
ren QR506 rsi_work_hours_7d
ren QR507 rsi_work_hours_m



*drop if q305 < 15 
*drop if q501 == 97 
*drop if refugee != 1
logit ros_work_permit ros_employed refugee



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
ttest hhsize, by(rsi_work_permit)
ttest qrgender, by(rsi_work_permit)
ttest economy, by(rsi_work_permit)
ttest refugee, by(rsi_work_permit)
ttest qrage, by(rsi_work_permit)

logit rsi_work_permit hhsize qrgender qrage economy refugee
 
  *i.industry i.occupation 
restore

***** HOW DOES HAVING A WP AFFECTS OUTCOME VAR 
preserve

keep if refugee == 1
reg rsi_wage_income_lm_cont_ln rsi_work_permit, robust
reg rsi_work_hours_m rsi_work_permit, robust
reg ros_employed rsi_work_permit, robust
restore








































use "$data_2020_final/Jordan2020_HH_RSI.dta", clear

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

gen rsi_wage_income_lm_cont_ln = ln(rsi_wage_income_lm_cont)

ren QH502_2 hh_wage_income_lm_cat
ren QH502_4 hh_wage_income_l12m_cat
ren QR608 	rsi_wage_income_lm_cont
ren QR609 	rsi_wage_income_typ_cont

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

**** INDUSTRIES AND OCCUPATION ****

* Industry 
tab QR501 
*ren QR501 industry
encode QR501, gen(industry)
*Occupation 
tab QR502
*ren QR502 occupation
encode QR502, gen(occupation)




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
ttest hhsize, by(rsi_work_permit)
ttest qrgender, by(rsi_work_permit)
ttest economy, by(rsi_work_permit)
ttest refugee, by(rsi_work_permit)
ttest qrage, by(rsi_work_permit)

logit rsi_work_permit hhsize qrgender qrage economy refugee

  *i.industry i.occupation 
restore

***** HOW DOES HAVING A WP AFFECTS OUTCOME VAR 
preserve

keep if refugee == 1
reg rsi_wage_income_lm_cont_ln rsi_work_permit, robust
reg rsi_work_hours_m rsi_work_permit, robust
reg ros_employed rsi_work_permit, robust
restore
