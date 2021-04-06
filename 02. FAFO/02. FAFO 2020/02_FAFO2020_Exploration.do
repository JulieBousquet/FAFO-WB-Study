
use "$data_2020_final/02_FAFO2020_HH_RSI.dta", clear

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


bys headnation: tab QH401, m
bys headnation: tab QH402, m

***IDs

isid iid 
distinct iid

tab qrhhid , m
tab qhhhid , m
*br qhhhid qrhhid
sort qhhhid qrhhid
gen hhid_clust = qhhhid
replace hhid_clust = qrhhid if mi(hhid_clust)
gen clusterid = qrclust 
replace clusterid = qhclust if mi(clusterid)
drop hhid
egen hhid = concat(clusterid hhid_clust)
distinct hhid


*Geography

*RSI
tab QRID101, m 
*QRID101N QRID102 QRID102N QRID103 QRID103N QRID104 QRID104N QRID105 QRID105N QRID106 QRID106N QRID107 QRID107N QRID108


*HH
tab ID101, m 

bys refugee: tab ID101

tab qrgender, m 
tab QR100A, m 
bys refugee: tab headgender, m
tab QH203, m
*br QH203 qrgender QR100A
codebook qrgender QR100A headgender QH203

gen gender_resp = QR100A 
replace gender_resp = qrgender if mi(gender_resp)
replace gender_resp = headgender if mi(gender_resp)
tab gender_resp, m
lab def gender 1 "Male" 2 "Female", modify
lab val gender_resp gender 
bys refugee: tab gender_resp, m

tab ID102, m 
bys ID101: tab ID102, m 
bys ID101 ID102: tab ID103, m 

bys ID101 ID102: tab ID104, m 
bys ID101 ID102: tab ID106, m 
bys ID101 ID102 refugee: distinct hhid 

su hhsize
bys refugee: su hhsize
*HH
*ID105 ID105N ID106 ID106N ID107 ID107N ID108 ID109

***** MOBILITY

*Employed
tab QR401
tab QR402 
tab QR403 
tab QR404
codebook QR401
gen employed = 1 if QR401 == 1 | QR402 == 1 | QR403 == 1 | QR404 == 1
replace employed = 0 if mi(employed)
tab employed, m
tab qremp, m
*br employed qremp QR401 QR402 QR403 QR404 if qremp == 1 & employed == 0
codebook qremp
tab qhemp, m 
tab employ, m

*ONLY EMPLLOYED AS DECLARED IN RSI
keep if qremp == 1


tab QR504H 
tab QR504M

gen time_commute = 60*QR504H
replace time_commute = time_commute + QR504M
su time_commute
tab time_commute
gen time_cat_commute = 1 if time_commute <= 10 & !mi(time_commute)
replace time_cat_commute = 2 if time_commute > 10 & time_commute <= 30 & !mi(time_commute)
replace time_cat_commute = 3 if time_commute > 30 & time_commute <= 60 & !mi(time_commute)
replace time_cat_commute = 4 if time_commute > 60 & time_commute <= 120 & !mi(time_commute)
replace time_cat_commute = 5 if time_commute > 120 & time_commute <= 180 & !mi(time_commute)
replace time_cat_commute = 6 if time_commute > 180 & !mi(time_commute)
lab def time_cat_commute 1 "0-10 minutes" ///
							2 "11-30 minutes" ///
							3 "Less than 1 hour" ///
							4 "1 hour" ///
							5 "2 hours" ///
							6 "3+ hours" ///
							, modify
lab val time_cat_commute time_cat_commute
bys refugee: tab time_cat_commute

tab QR503, m
tab QR503O, m

bys refugee: tab QR505Y


*WORK PERMIT 

bys refugee: tab QR201
bys refugee: tab QR204, m
