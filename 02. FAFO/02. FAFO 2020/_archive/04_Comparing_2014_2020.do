

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
tab HHgr1
drop if HHgr1 == 1 //Remove everyone in camp

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
sort q101 
gen governorate_en = ""
replace governorate_en = "Amman" if q101 == 11
replace governorate_en = "Irbid" if q101 == 21 
replace governorate_en = "Mafraq" if q101 == 22 

egen governorate_id = group(governorate_en)

sort governorate_id q102
gen district_en = ""
replace district_en = "Qasabet Amman" if q102 == 1 & governorate_en == "Amman"
replace district_en = "Marka" if  q102 == 2 & governorate_en == "Amman"
replace district_en = "Quaismeh" if  q102 == 3 & governorate_en == "Amman"
replace district_en = "Wadi Essier" if  q102 == 5 & governorate_en == "Amman"
replace district_en = "Qasabet Irbid" if  q102 == 1 & governorate_en == "Irbid"
replace district_en = "Qasabet El-Mafraq" if  q102 == 1 & governorate_en == "Mafraq"
replace district_en = "Badiah Shamaliyyeh" if  q102 == 2 & governorate_en == "Mafraq"
replace district_en = "Badiah Shamaliyyeh Gharbiyyeh" if  q102 == 3 & governorate_en == "Mafraq"

tab district_en, m 
drop if mi(district_en) // remove those that are not in the district 2020

sort  district_en 
egen district_id = group(district_en)

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

tab q101, nol
/*
       11  Amman
       21  Irbid
       22  Mafraq
*/

tab q102, m 
tab q103, m

save "$data_2014_final/Jordan2014_02_Clean.dta", replace









































use "$data_2020_final/Jordan2020_02_Clean.dta", clear

/*
      district_en |      Freq.     Percent        Cum.
------------------+-----------------------------------
    Al Quwaysimah |         21        1.69        1.69
    Irbid Qasabah |        285       22.95       24.64
   Mafraq Qasabah |        101        8.13       32.77
            Marka |         22        1.77       34.54
North West Badiah |         35        2.82       37.36
   Northern Badia |        163       13.12       50.48
      Oman Kasbah |        104        8.37       58.86
         Russeifa |        107        8.62       67.47
     Wadi As-Seir |        146       11.76       79.23
    Zarqa Qasabah |        258       20.77      100.00
------------------+-----------------------------------
            Total |      1,242      100.00

*/

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
ren QR608   rsi_wage_income_lm_cont
ren QR609   rsi_wage_income_typ_cont

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
ren QR705   rsi_se_income_lm_cont
ren QR706   rsi_se_income_typ_cont

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


save "$data_2020_temp/Jordan2020_03_Compared.dta", replace





