
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


use "$data_2014_base/Jordan2014_ROS_HH_RSI.dta", clear

*
distinct hhid 
distinct iid
distinct rsi_id 

codebook merge_ros 
/*            tabulation:  Freq.   Numeric  Label
                        17,664         2  using only (2)
                         3,860         3  matched (3)
*/
codebook merge_rsi 
/*
            tabulation:  Freq.   Numeric  Label
                        19,812         2  using only (2)
                         1,712         3  matched (3)
*/
tab governorate, m
bys HHrefugee: tab governorate 
bys HHrefugee: tab HHsex , m

preserve
keep if merge_ros == 3 //Not in roster, just HHhead
drop if HHgroup == 1 //Not in camp
bys HHrefugee: tab ur_rl , m
restore 

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

*District
tab q102, m 
ren q102 q102_district
tab q102_district, m
codebook governorate
/*
            tabulation:  Freq.   Numeric  Label
                         4,821        11  Amman
                         6,269        21  Irbid
                        10,434        22  Mafraq

*/


tab q103, m 
ren q103 q103_sub_district
tab q103_sub_district, m
/*Sub-distric |
          t |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      3,276       84.87       84.87
          2 |        210        5.44       90.31
          3 |        142        3.68       93.99
          4 |        196        5.08       99.07
          5 |         36        0.93      100.00
------------+-----------------------------------
      Total |      3,860      100.00
*/

*Locality
tab q104, m 
ren q104 q104_locality

*Area
tab q105, m 
ren q105 q105_area 

*Neighborhood
tab q106, m
ren q106 q106_neighborhood

*Block
tab q107, m
ren q107 q107_block
tab q107_1, m  

*Building
tab q108, m 
ren q108 q108_building 

*Household in Building
tab q109, m 
ren q109 q109_hh_building

*Dwellings
tab q110, m 
ren q110 q110_dwellings_building

*Household in Block
tab q111, m 
ren q111 q111_hh_block

*Kish table number
tab q112, m 
ren q112 q112_kish_table_nb

*Main respondent hh quest
tab q113, m 
ren q113 q113_main_resp_hh
tab q113_main_resp_hh, m

*Mains respondent RSI quest
tab q114, m 
ren q114 q114_main_resp_rsi

*Interview status
tab q123, m 
ren q123 q123_interview_compl
tab r123, m 
ren r123 r123_interview_status

*Total hh member
tab q115_t, m 
ren q115_t q115_t_hh_members

	*Male
	tab q115_m, m 
	ren q115_m q115_m_hh_members

	tab q115_f, m 
	ren q115_f q115_f_hh_members

	*Category
	tab q115_tnew, m 
	ren q115_tnew q115_t_hh_members_cat
	tab q115_mnew, m 
	ren q115_mnew q115_m_hh_members_cat
	tab q115_fnew, m 
	ren q115_fnew q115_f_hh_members_cat

  order q115_t_hh_members q115_t_hh_members_cat ///
        q115_m_hh_members q115_m_hh_members_cat ///
        q115_f_hh_members q115_f_hh_members_cat ///
        , a(r123_interview_status) 


su q115_t_hh_members
su q115_m_hh_members
su q115_f_hh_members

bys nat_hh: su q115_t_hh_members 

tab q303, m
tab q303 nat_hh 
*Industries - RSI

tab r222 if merge_rsi == 3, m

codebook nat_hh
tab q514 if nat_hh == 1


*Work permits

 
tab r301, m
tab r301 if nat_hh == 1
tab r304 if nat_hh == 1

tab q531  if nat_hh == 1


*Percentage of people who work in their locality

tab q520, m

/*                    Main job location |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
             In this hara/ neighborhood |        297        1.38        1.38
In this living area (camp/ town/ villag |        677        3.15        4.53
               Outside this living area |      1,416        6.58       11.10
                         Outside Jordan |         25        0.12       11.22
                                      . |     19,109       88.78      100.00
----------------------------------------+-----------------------------------
                                  Total |     21,524      100.00

*/

tab r500,m

*Problem with this variable, mix btw 500 and 501
tab q501, m
tab q502, m
tab q503, m
tab q504, m
tab q505, m
codebook q502

*Those who work 
preserve
keep if q502 == 1 | q503 == 1 | q504 == 1 | q505 == 1 
tab q520, m
tab q519, m
tab q521, m 
tab q524new, m
restore

/*
                      Main job location |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
             In this hara/ neighborhood |        297       12.26       12.26
In this living area (camp/ town/ villag |        677       27.94       40.20
               Outside this living area |      1,416       58.44       98.64
                         Outside Jordan |         25        1.03       99.67
                                      . |          8        0.33      100.00
----------------------------------------+-----------------------------------
                                  Total |      2,423      100.00


*/


/*
Work inside |
     Syrian |
   refugees |
       camp |      Freq.     Percent        Cum.
------------+-----------------------------------
        All |        115        4.75        4.75
       Some |         72        2.97        7.72
       None |      2,236       92.28      100.00
------------+-----------------------------------
      Total |      2,423      100.00
*/



/*
   Place where most of the work is |
                       carried out |      Freq.     Percent        Cum.
-----------------------------------+-----------------------------------
                           At home |         48        1.98        1.98
                 At client’s place |        104        4.29        6.27
                     Formal office |      1,026       42.34       48.62
                   Factory/Atelier |        372       15.35       63.97
                       Farm/Garden |         71        2.93       66.90
                 Construction site |        183        7.55       74.45
                      Mines/Quarry |         16        0.66       75.11
Shop/Kiosk/Coffee house/Restaurant |        339       13.99       89.10
           Different places/Mobile |        171        7.06       96.16
      Fixed street or market stall |         76        3.14       99.30
                             Other |         15        0.62       99.92
                                 . |          2        0.08      100.00
-----------------------------------+-----------------------------------
                             Total |      2,423      100.00
*/



/*
 Time on average |
        spend on |
   travelling to |
            work |      Freq.     Percent        Cum.
-----------------+-----------------------------------
    0-10 minutes |        519       21.42       21.42
   11-30 minutes |      1,012       41.77       63.19
Less than 1 hour |         97        4.00       67.19
          1 hour |        463       19.11       86.30
         2 hours |        186        7.68       93.97
        3+ hours |         89        3.67       97.65
               . |         57        2.35      100.00
-----------------+-----------------------------------
           Total |      2,423      100.00
*/

*Disgregated by nationality

preserve
keep if q502 == 1 | q503 == 1 | q504 == 1 | q505 == 1 

tab nat_hh, m 
tab HHgroup, m
tab HHrefugee, m
codebook HHrefugee

/*
            tabulation:  Freq.   Numeric  Label
                           624         1  Refugee
                         1,799         2  Not refugee
*/

tab q524new HHrefugee

/*
 Time on average |
        spend on |   Refugee status of
   travelling to |    household head
            work |   Refugee  Not refug |     Total
-----------------+----------------------+----------
    0-10 minutes |       148        371 |       519 
   11-30 minutes |       310        702 |     1,012 
Less than 1 hour |        27         70 |        97 
          1 hour |        99        364 |       463 
         2 hours |        16        170 |       186 
        3+ hours |         9         80 |        89 
-----------------+----------------------+----------
           Total |       609      1,757 |     2,366 

*/
drop if HHgroup == 1 //Not in camp

bys HHrefugee: tab q524new

tab q519 HHrefugee

/*
      Work |
    inside |
    Syrian |   Refugee status of
  refugees |    household head
      camp |   Refugee  Not refug |     Total
-----------+----------------------+----------
       All |        90         25 |       115 
      Some |        22         50 |        72 
      None |       512      1,724 |     2,236 
-----------+----------------------+----------
     Total |       624      1,799 |     2,423 

*/

tab q520 HHrefugee

/*
                      |   Refugee status of
                      |    household head
    Main job location |   Refugee  Not refug |     Total
----------------------+----------------------+----------
In this hara/ neighbo |       105        192 |       297 
In this living area ( |       246        431 |       677 
Outside this living a |       263      1,153 |     1,416 
       Outside Jordan |         8         17 |        25 
----------------------+----------------------+----------
                Total |       622      1,793 |     2,415 

*/
restore

preserve
keep if merge_ros == 3 //Not in roster, just HHhead
drop if HHgroup == 1 //Not in camp
bys governorate: tab q102_district, m
bys governorate: tab q102_district q103_sub_district
bys governorate: tab q102_district q104_locality
tab q103_sub_district q104_locality if governorate == 11 & q102_district == 9
*bys HHrefugee: tab q102_district governorate  
bys q102_district: tab q103_sub_district q104_locality if governorate == 22 

bys governorate q102_district: table  q104_locality 
bys governorate q102_district: table  q104_locality q105_area
restore 


preserve
keep if merge_ros == 3 //Not in roster, just HHhead
drop if HHgroup == 1 //Not in camp
bys governorate q102_district q103_sub_district: table  q104_locality 
restore 


preserve
keep if merge_ros == 3 //Not in roster, just HHhead
drop if HHgroup == 1 //Not in camp
bys governorate q102_district q103_sub_district : table  q104_locality q105_area 
restore 

preserve
keep if merge_ros == 3 //Not in roster, just HHhead
drop if HHgroup == 1 //Not in camp
bys governorate q102_district q103_sub_district q104_locality q105_area: table   q106_neighborhood  
restore 

preserve
*keep if merge_ros == 3 //Not in roster, just HHhead
drop if HHgroup == 1 //Not in camp
bys governorate q102_district HHrefugee: distinct hhid  
restore 



tab HHrefugee

preserve
*keep if merge_ros == 3 //Not in roster, just HHhead
keep if q502 == 1 | q503 == 1 | q504 == 1 | q505 == 1 
drop if HHgroup == 1 //Not in camp
bys HHrefugee: tab q520 
bys HHrefugee: tab q524new 
bys HHrefugee: tab q523new
restore

*RSI Sample
preserve
keep if merge_rsi == 3
drop if HHgroup == 1 //Not in camp
*keep if merge_ros == 3 //Not in roster, just HHhead
bys HHrefugee: tab r301
bys HHrefugee: tab r302
bys HHrefugee: tab r303
bys HHrefugee: tab r304
bys HHrefugee: tab r305
bys HHrefugee: tab r306
bys HHrefugee: tab r307
restore


preserve
*keep if merge_ros == 3 //Not in roster, just HHhead
keep if HHgroup == 1 //Not in campt
tab q801
tab q802
restore

tab q303, m
bys HHrefugee: tab q303, m

