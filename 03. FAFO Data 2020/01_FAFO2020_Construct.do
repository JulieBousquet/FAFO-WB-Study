
cap log close
clear all
set more off, permanently
set mem 100m

*log using "$analysis_do/01_Data_Cleaning_EL1.log", replace

	****************************************************************************
	**                               DATA CLEANING                            **  
	** ---------------------------------------------------------------------- **
	** Type Do  : 	DATA CLEANING FAFO 2014                                   **
  	**                                                                        **
	** Authors  : Julie Bousquet                                              **
	****************************************************************************


*********************
* HOUSEHOLD DATASET *
*********************

use "$data_2020_base/Household-Final.dta", clear

tab ID101 

*ID101 ID102 ID103 ID104 ID105 ID106 ID107 qhclust

tab headnation, m
list qhclust qhintvcode qhhhid qhresult if headnation == 10

/*
     +-----------------------------+
     | qhclust   qhintv~e   qhhhid |
     |-----------------------------|
129. | 1150084         18        2 |
     +-----------------------------+
*/

/*
Nationality |      Freq.     Percent        Cum.
------------+-----------------------------------
     Jordan |        259       31.94       31.94
      Syria |        343       42.29       74.23
      Egypt |         20        2.47       76.70
         10 |          1        0.12       76.82
          . |        188       23.18      100.00
------------+-----------------------------------
      Total |        811      100.00
*/

tab qhresult if mi(headnation)

/*
          Result of household interview |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
No (competent) household member at home |         22       11.83       11.83
                                Refused |         72       38.71       50.54
                     No eligible person |          8        4.30       54.84
                  No usable information |          3        1.61       56.45
                  Status not determined |         15        8.06       64.52
Dwelling vacant or address not a dwelli |         17        9.14       73.66
                     Dwelling not found |          5        2.69       76.34
                                  Other |         44       23.66      100.00
----------------------------------------+-----------------------------------
                                  Total |        186      100.00

*/

*I DROP THESE INDIVIDUALS 
drop if mi(headnation) | headnation == 10


tab headnation, m

codebook headnation
gen refugee = 1 if headnation == 2
replace refugee = 2 if headnation == 1 | headnation == 3
lab def refugee 1 "Refugee" 2 "Non refugee", modify
lab val refugee refugee 
lab var refugee "Refugee is 1 if Syrian is 2 if other (Jordan, Egyptian)"
tab refugee, m

use "$data_2020_base/RSI-Final.dta",clear 

*qhclust == 1150084 & qrhhid == 2

tab QH207

/*
        Citizenship of household member |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                 Jordan |        527       42.60       42.60
                                  Syria |        676       54.65       97.25
                                  Egypt |         31        2.51       99.76
                            Palestinian |          3        0.24      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,237      100.00
*/

tab QH207 if qrclust == 1150084 & qrhhid == 2

/*
        Citizenship of household member |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                            Palestinian |          3      100.00      100.00
----------------------------------------+-----------------------------------
                                  Total |          3      100.00

*/

drop if qrclust == 1150084 & qrhhid == 2

tab headnation, m 
tab QR100, m 
tab qrnation, m
tab QH208, m

list qrnation QR100 QH208 headnation if mi(headnation)
codebook qrnation QR100 QH208 headnation
*Jordan 1 - Syria 2 - Egypt 3
replace headnation = 1 if qrnation == 1 
replace headnation = 2 if qrnation == 2
replace headnation = 3 if qrnation == 3

replace qrnation = 1 if headnation == 1 
replace qrnation = 2 if headnation == 2 
replace qrnation = 3 if headnation == 3 

replace QR100 = 1 if headnation == 1 
replace QR100 = 2 if headnation == 2 
replace QR100 = 3 if headnation == 3 

list qrnation QR100 QH208 headnation if mi(QH208)
replace QH208 = "JOD" if mi(QH208)

codebook headnation
gen refugee = 1 if headnation == 2
replace refugee = 2 if headnation == 1 | headnation == 3
lab def refugee 1 "Refugee" 2 "Non refugee", modify
lab val refugee refugee 
lab var refugee "Refugee is 1 if Syrian is 2 if other (Jordan, Egyptian)"
tab refugee, m 

*****************
* CREATE HH HEAD LIST *
*****************

use "$data_2020_base/Household-Final.dta", clear
*Household ID
egen hhid = concat(qhclust qhhhid) , f(%18.0g)
label variable hhid "Household ID"
destring hhid, replace
format hhid %12.0g

duplicates tag hhid, gen(dup)
replace qhresult = 12 if qhclust == 2210159 & qhintvcode == 12 & dup == 1 
drop if (qhresult == 12 | qhresult == 5 | qhresult == . ) & dup == 1
drop if qhrsi == 0
egen iid = concat(qhclust qhhhid qhrsi) , f(%18.0g)
isid iid

tempfile filetemp
save `filetemp' 

use "$data_2020_base/RSI-Final.dta",clear 

egen hhid = concat(qrclust qrhhid) , f(%18.0g)
label variable hhid "Household ID"
destring hhid, replace
distinct hhid 
format hhid %12.0g

egen iid = concat(qrclust qrhhid qrrsi) , f(%18.0g)
isid iid
drop if hhid == 11306617 & qrrsi == 3

merge 1:1 iid using `filetemp'
ren _merge merge_rsi
sort merge_rsi

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         1,028
        from master                       733  (_merge==1)
        from using                        295  (_merge==2)

    matched                               505  (_merge==3)
    -----------------------------------------

Matched: are the ones in HH survey and RSI surveys
  505 observations
From using: are the ones in HH Survey only. They did not get a RSI code,
so they can't be match WITH rsi. THey are all the household heads who 
did not do RSI
  306 observations
From Master: are the ones in RSI. 
  733 observations : it includes the RSI + the roster data
*/

*RSI
tab merge_rsi, m
lab def merge_rsi 1 "RSI" 2 "HH" 3 "RSI and HH", modify
lab val merge_rsi merge_rsi
tab merge_rsi, m

drop if merge_rsi == 1
drop if qhresult != 1 & merge_rsi == 2

destring iid, replace
format iid %12.0g
isid iid

keep iid hhid 
replace iid = 113066171  if hhid == 11306617

save "$data_2020_temp/list_household_heads.dta", replace



*****************
* MERGE DATASET *
*****************

*The "RSI data" also includes the roster data 
*while the "household data" includes only the 
*household head data. 

use "$data_2020_base/Household-Final.dta", clear

*Household ID
egen hhid = concat(qhclust qhhhid)
label variable hhid "Household ID"

destring hhid, replace
format hhid %12.0g

duplicates tag hhid, gen(dup)

list qhclust qhhhid if dup == 1 
tab qhresult 
codebook qhresult
replace qhresult = 12 if qhclust == 2210159 & qhintvcode == 12 & dup == 1 
drop if (qhresult == 12 | qhresult == 5 | qhresult == . ) & dup == 1
drop dup 
isid hhid 



tempfile merge_hh
save `merge_hh' 

use "$data_2020_base/RSI-Final.dta",clear 

egen hhid = concat(qrclust qrhhid)
label variable hhid "Household ID"
destring hhid, replace
distinct hhid 
format hhid %12.0g


drop if hhid == 11306617 & qrrsi == 3

tab qrresult , m
codebook qrresult
*br if qrresult != 1 & qrresult != 2 & qrresult != 6
*drop if (qrresult == 12 | qrresult == 5 | qrresult == . ) & dup == 1
*drop dup 
*isid hhid 

gen survey_rsi = 1 
lab var survey_rsi "Individual did the RSI survey"

merge m:1 hhid using `merge_hh'
ren _merge merge_rsi

sort merge_rsi

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           188
        from master                         0  (_merge==1)
        from using                        188  (_merge==2)

    matched                             1,238  (_merge==3)
    -----------------------------------------

Matched: are the ones in HH survey and RSI surveys
  1,238 observations
From using: are the ones in HH Survey only. They did not get a RSI code,
so they can't be match WITH rsi. THey are all the household heads who 
did not do RSI
  188 observations
*/

*RSI
tab merge_rsi, m
lab def merge_rsi 1 "RSI" 2 "HH" 3 "RSI and HH" 4 "ROS and HH", modify
lab val merge_rsi merge_rsi
tab merge_rsi, m
lab var merge_rsi "Merge variable between HH survey and RSI survey"

drop if merge_rsi == 2 & qhresult != 1

*Some did only the ROS surve and not the RSI (even tho they are in the RSI
*dataset: this is because FAFO merged without indicatng this)
replace merge_rsi = 4 if qrresult != 1 & qrresult != 2 & qrresult != 6

*183 househods did neither the HH survey neither the RSI survey neither the roster
*i drop them for now

egen rsiid = concat(hhid qrrsi) , f(%18.0g)
replace rsiid = "" if mi(qrrsi)
label variable rsiid "RSI individual ID"
destring rsiid, replace
format rsiid %18.0g

mdesc rsiid
*5 Households  did not do the RSI survey AT ALL (like no one was selected in the 
*household to do the RSI)

bys hhid: gen id_count = _n
egen iid = concat(hhid id_count) , f(%18.0g)
label variable iid "Individual unique ID"
destring iid, replace
format iid %18.0g
isid iid

*MERGE WITH HOUSEHOLD HEAD LIST TO LOCATE THEM
merge 1:1 iid using "$data_2020_temp/list_household_heads.dta"

gen survey_hh = 1 if _merge == 3
lab var survey_hh "Individual did the HH survey"
drop _merge 
replace survey_hh = 1 if qhrsi == 0
drop id_count

order iid hhid rsiid  
order survey_rsi survey_hh, b(ID101)
     

save "$data_2020_final/Jordan2020_HH_RSI.dta", replace
