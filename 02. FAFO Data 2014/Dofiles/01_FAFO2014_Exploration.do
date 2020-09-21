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

use "$data_base/Jordan2014 ILO HH_UserFile_Jul 2014.dta", clear

*Questionnaire Number
tab ques_no, m 
ren ques_no hhid

*Household relative weight 
tab HHrel_wt, m

*RSI relative weight
tab RSIrel_wt, m 

*Name gornorates
tab governorate, m 
/*
Governorate |      Freq.     Percent        Cum.
------------+-----------------------------------
      Amman |        923       23.91       23.91
      Irbid |      1,051       27.23       51.14
     Mafraq |      1,886       48.86      100.00
------------+-----------------------------------
      Total |      3,860      100.00
*/
*Governorate
tab q101, m 
ren q101 q101_governorate
drop governorate

*Stratum
tab Stratum, m 

*Cluster ID
tab ClusterID, m 

*Urban / Rural
tab ur_rl, m 
ren ur_rl urban_rural
/*
Urban/rural |
   location |
    outside |
       camp |      Freq.     Percent        Cum.
------------+-----------------------------------
      Urban |      2,344       60.73       60.73
      Rural |        726       18.81       79.53
          . |        790       20.47      100.00
------------+-----------------------------------
      Total |      3,860      100.00
*/

*Nationality: at least one syrian member
tab nat_hh, m 
ren nat_hh nationality_hh
/*
  Household |
nationality |
 : At least |
 one Syrian |
     member |      Freq.     Percent        Cum.
------------+-----------------------------------
     Syrian |      2,305       59.72       59.72
      Other |      1,555       40.28      100.00
------------+-----------------------------------
      Total |      3,860      100.00
*/

*Nationality: as listed
tab nat_samp, m 
ren nat_samp nationality_listed
/*
  Household |
nationality |
  as listed |      Freq.     Percent        Cum.
------------+-----------------------------------
     Syrian |      2,297       59.51       59.51
      Other |      1,563       40.49      100.00
------------+-----------------------------------
      Total |      3,860      100.00
*/

tab HHgroup, m 
/*

                        Household group |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
              Household in Zaatari camp |        790       20.47       20.47
Household with Syrian refugee head outs |      1,403       36.35       56.81
outside camp
Household with Jordanian non-refugee he |      1,526       39.53       96.35
head
                                  Other |        141        3.65      100.00
----------------------------------------+-----------------------------------
                                  Total |      3,860      100.00
*/

tab HHgr1, m
/*  
  Household |
 in Zaatari |
       camp |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      3,070       79.53       79.53
          1 |        790       20.47      100.00
------------+-----------------------------------
      Total |      3,860      100.00
*/ 
tab HHgr2, m 
/*  Household |
with Syrian |
    refugee |
       head |
    outside |
       camp |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      2,457       63.65       63.65
          1 |      1,403       36.35      100.00
------------+-----------------------------------
      Total |      3,860      100.00
*/

tab HHgr3, m 
/*  Household |
       with |
  Jordanian |
non-refugee |
       head |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      2,334       60.47       60.47
          1 |      1,526       39.53      100.00
------------+-----------------------------------
      Total |      3,860      100.00
*/

tab HHgr4, m 
/*
  Household |
 with other |
       head |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      3,719       96.35       96.35
          1 |        141        3.65      100.00
------------+-----------------------------------
      Total |      3,860      100.00
*/

tab year, m 
*2014

*District
tab q102, m 
ren q102 q102_district
tab q102_district, m
/*
   District |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      1,349       34.95       34.95
          2 |        599       15.52       50.47
          3 |      1,278       33.11       83.58
          4 |        208        5.39       88.96
          5 |        141        3.65       92.62
          6 |        145        3.76       96.37
          7 |         47        1.22       97.59
          8 |         31        0.80       98.39
          9 |         62        1.61      100.00
------------+-----------------------------------
      Total |      3,860      100.00
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
ren q113 q113_main_resp_hh_quest

*Mains respondent RSI quest
tab q114, m 
ren q114 q114_main_resp_rsi_quest

*Interview status
tab q123, m 
ren q123 q123_interview_compl
tab r123, m 
ren r123 r123_interview_status

br q123_interview_compl

*Total hh member
tab q115_t, m 
ren q115_t q115_t_hh_members

	*Male
	tab q115_m, m 
	ren q115_m q115_m_hh_m_members

	tab q115_f, m 
	ren q115_f q115_f_hh_f_members

	order q115_tnew q115_mnew q115_fnew, a(q115_f_hh_f_members) 

	*Category
	tab q115_tnew, m 
	ren q115_tnew q115_t_hh_members_cat
	tab q115_mnew, m 
	ren q115_mnew q115_m_hh_members_cat
	tab q115_fnew, m 
	ren q115_fnew q115_f_hh_members_cat

/********************************************
SECTION 2 : THE DWELLING AND ITS ENVIRONMENT
*********************************************/

/* SUBSECTION: Dwelling and its amenities */
*  --------------------------------------  *

*In / Out of camps
tab q200, m 
/*
   Household located |
  within the Zaatari |
        refugee camp |      Freq.     Percent        Cum.
---------------------+-----------------------------------
     In Zaatari camp |        790       20.47       20.47
Outside Zaatari camp |      3,070       79.53      100.00
---------------------+-----------------------------------
               Total |      3,860      100.00
*/

tab q201_t, m 
tab q201_1, m 
tab q201_2, m 
tab q201_3, m 

tab q202, m 
tab q203, m 
tab q204, m 
tab q205, m 
tab q206, m 
tab q207, m 
tab q208, m 
tab q209, m 
tab q210, m 
tab q211, m 
tab q212, m 
tab q213, m 
tab q213_1, m 
tab q213_2, m 
tab q213_3, m 
tab q213_4, m 
tab q213_5, m

order q213, a(q212)
order 	q204new q205new q207new q211new ///
		q213new q213_1new q213_2new q213_3new ///
		q213_4new q213_5new , a(q213_5)

tab q204new, m 
tab q205new, m 
tab q207new, m 
tab q211new, m 
tab q213new, m 
tab q213_1new, m 
tab q213_2new, m 
tab q213_3new, m 
tab q213_4new, m 
tab q213_5new, m 


/* SUBSECTION: Tenure */
*  ------------------  *

tab q214, m 
tab q215, m 
tab q216, m 
tab q217, m 
tab q218, m 
tab q219, m 
tab q219_2, m 
tab q220_1, m 
tab q220_2, m 
tab q220_3, m 
tab q221, m 
tab q222, m 
tab q223_1, m 
tab q223_2, m 

order q215new q218new q221new q222new, a(q223_2)

tab q215new, m 
tab q218new, m 
tab q221new, m 
tab q222new, m 

/* SUBSECTION: Safety and satisfaction with housing conditions */
*  -----------------------------------------------------------  *

tab q224, m
tab q225, m 

/*****************
SECTION 9 : WEALTH
******************/

/* SUBSECTION: Income */
*  ------------------  *

tab q900, m 
tab q900_qy, m 
tab q900_qm, m 
tab q901, m 
tab q901_qy, m 
tab q901_qm, m 
tab q902, m 
tab q902_qy, m 
tab q902_qm, m 
tab q903, m 
tab q903_qy, m 
tab q903_qm, m 
tab q904, m 
tab q904_qy, m 
tab q904_qm, m 
tab q905, m 
tab q905_qy, m

order 	q900_qynew q901_qynew q902_qynew q903_qynew ///
		q904_qynew q905_qyupd q905_qyupdnew q900_qmnew ///
		q901_qmnew q902_qmnew q903_qmnew q904_qmnew ///
		, a(q905_qy)

tab q900_qynew, m 
tab q901_qynew, m 
tab q902_qynew, m 
tab q903_qynew, m 
tab q904_qynew, m 
tab q905_qyupd, m 
tab q905_qyupdnew, m 
tab q900_qmnew, m 
tab q901_qmnew, m 
tab q902_qmnew, m 
tab q903_qmnew, m 
tab q904_qmnew, m 

/* SUBSECTION: Economics Self-Assessment */
*  -------------------------------------  *

tab q906, m 
tab q907, m 

/* SUBSECTION: Poverty Support */
*  ---------------------------  *

tab q908_a1, m 
tab q908_j1, m 
tab q908_b1, m 
tab q908_c1, m 
tab q908_d1, m 
tab q908_a2, m 
tab q908_j2, m 
tab q908_b2, m 
tab q908_c2, m 
tab q908_d2, m 
tab q908_a3, m 
tab q908_j3, m 
tab q908_b3, m 
tab q908_c3, m 
tab q908_d3, m 
tab q908_a4, m 
tab q908_j4, m 
tab q908_b4, m 
tab q908_c4, m 
tab q908_d4, m 
tab q908_a5, m 
tab q908_j5, m 
tab q908_b5, m 
tab q908_c5, m 
tab q908_d5, m 
tab q908_a6, m 
tab q908_j6, m 
tab q908_b6, m 
tab q908_c6, m 
tab q908_d6, m 
tab q908_a7, m 
tab q908_j7, m 
tab q908_b7, m 
tab q908_c7, m 
tab q908_d7, m 
tab q908_a8, m 
tab q908_j8, m 
tab q908_b8, m 
tab q908_c8, m 
tab q908_d8, m 
tab q908_9t, m 
tab q908_a9, m 
tab q908_j9, m 
tab q908_b9, m 
tab q908_c9, m 
tab q908_d9, m 
tab q909, m 

order 	q907new q908_j1new q908_j2new q908_j3new q908_j4new ///
		q908_j5new q908_j6new q908_j7new q908_j8new q908_j9new ///
		q909new, a(q909)

tab q907new, m 
tab q908_j1new, m 
tab q908_j2new, m 
tab q908_j3new, m 
tab q908_j4new, m 
tab q908_j5new, m 
tab q908_j6new, m 
tab q908_j7new, m 
tab q908_j8new, m 
tab q908_j9new, m 
tab q909new, m 

/* SUBSECTION: Consumer Durables */
*  -----------------------------  *

tab q910_1, m 
tab q910_2, m 
tab q910_3, m 
tab q910_4, m 
tab q910_5, m 
tab q910_6, m 
tab q910_7, m 
tab q910_7no, m 
tab q910_8, m 
tab q910_8no, m 
tab q910_9, m 
tab q910_10, m 
tab q910_11, m 
tab q910_12, m 
tab q910_13, m 
tab q910_14, m 
tab q910_15, m 
tab q910_16, m 
tab q910_17, m 
tab q910_17n, m 
tab q910_18, m 
tab q910_18n, m 
tab q910_19, m 
tab q910_20, m 
tab q910_21, m 
tab q910_21n, m 
tab q910_22, m 
tab q910_23, m 
tab q910_24, m 
tab q910_25, m 
tab q910_26, m 
tab q910_27, m 
tab q910_27n, m 
tab q910_28, m 
tab q910_28n, m 
tab q910_29, m 
tab q910_30, m 
tab q910_30n, m 
tab q910_31, m 

*Interview Check: does the hh has a refugee from Syria
tab q911, m 

/* SUBSECTION: Consumer Durables */
*  -----------------------------  *

tab q912_1, m 
tab q912_2, m 
tab q912_3, m 
tab q912_4, m 
tab q912_5, m 
tab q912_6, m 
tab q912_7, m 
tab q912_7no, m 
tab q912_8, m 
tab q912_8no, m 
tab q912_9, m 
tab q912_10, m 
tab q912_11, m 
tab q912_12, m 
tab q912_13, m 
tab q912_14, m 
tab q912_15, m 
tab q912_16, m 
tab q912_17, m 
tab q912_17n, m 
tab q912_18, m 
tab q912_18n, m 
tab q912_19, m 
tab q912_20, m 
tab q912_21, m 
tab q912_21n, m 
tab q912_22, m 
tab q912_23, m 
tab q912_24, m 
tab q912_25, m 
tab q912_26, m 
tab q912_27, m 
tab q912_27n, m 
tab q912_28, m 
tab q912_28n, m 
tab q912_29, m 
tab q912_30, m 
tab q912_30n, m 
tab q912_31, m 



tab inc_wage_y, m 
tab inc_selfemp_y, m 
tab inc_transfer_y, m 
tab inc_property_y, m 
tab inc_other_y, m 
tab inc_wage_m, m 
tab inc_selfemp_m, m 
tab inc_transfer_m, m 
tab inc_property_m, m 
tab inc_other_m, m 
tab HHallincome, m 
tab HHallincome_new, m 
tab HHwage, m 
tab HHwage_new, m 
tab HHadultinc, m 
tab HHadultinc_new, m 
tab HHmaleinc, m 
tab HHmaleinc_new, m 
tab HHadultinc2, m 
tab HHadultinc2_new, m 
tab money, m 
tab amount, m 
tab food, m 
tab shelter, m 
tab other, m 
tab int_money, m 
tab int_amount, m 
tab int_food, m 
tab int_shelter, m 
tab int_other, m 
tab Depratio_1, m 
tab Depratio2_1, m 
tab Depratio3_1, m 
tab DepRatio, m 
tab DepRatio2, m 
tab DepRatio3, m 
tab GroupDepRatio, m 
tab GroupDepRatio2, m 
tab GroupDepRatio3, m 
tab HHedumax, m 
tab wealthidx, m 
tab wealthidx5, m 
tab wealthidx3, m 
tab HHchildren, m 
tab HHsex, m 
tab HHage, m 
tab HHcitizen, m 
tab HHrefugee, m 

br HHcitizen HHrefugee

tab HHPopGrp, m 
tab HHedu, m 
tab HHincome, m 
tab dtot___, m

******************
* ROSter DATASET *
******************

use "$data_base/Jordan2014 ILO ROS_UserFile_Jul 2014.dta", clear
isid ques_no
sort ques_no
*Serial Number of household member
tab q300 , m

***************
* RSI DATASET *
***************

use "$data_base/Jordan2014 ILO RSI_UserFile_Jul 2014.dta", clear
isid ques_no

tab r301, m
/*
Applied for |
work permit |
for current |
   main job |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |        105        6.13        6.13
         No |        389       22.72       28.86
          . |      1,218       71.14      100.00
------------+-----------------------------------
      Total |      1,712      100.00
*/

tab r302, m
/*
Type of work |
      permit |      Freq.     Percent        Cum.
-------------+-----------------------------------
 Agriculture |         11        0.64        0.64
Construction |         30        1.75        2.39
    Services |         32        1.87        4.26
 Restaurants |         14        0.82        5.08
    Industry |         16        0.93        6.02
       Other |          1        0.06        6.07
           . |      1,608       93.93      100.00
-------------+-----------------------------------
       Total |      1,712      100.00
*/

tab r303, m 
/*
Main reason for choosing |
this type of work permit |      Freq.     Percent        Cum.
-------------------------+-----------------------------------
Matched the relevant job |         77        4.50        4.50
                Cheapest |          3        0.18        4.67
          Easiest to get |          8        0.47        5.14
Employer made the choice |         16        0.93        6.07
                      dk |          1        0.06        6.13
                       . |      1,607       93.87      100.00
-------------------------+-----------------------------------
                   Total |      1,712      100.00
*/

tab r304, m 
/*
 Success in |
getting the |
work permit |
applied for |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |         72        4.21        4.21
         No |         32        1.87        6.07
          . |      1,608       93.93      100.00
------------+-----------------------------------
      Total |      1,712      100.00
*/

tab r305, m 
/*
     Who paid for this work permit |      Freq.     Percent        Cum.
-----------------------------------+-----------------------------------
                  Paid by employee |         45        2.63        2.63
                  Paid by employer |         18        1.05        3.68
Paid by both employee and employer |          8        0.47        4.15
                             Other |          1        0.06        4.21
                                 . |      1,640       95.79      100.00
-----------------------------------+-----------------------------------
                             Total |      1,712      100.00
*/

tab r306, m 
/*  Main reason for not applying for work |
                    permit for main job |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
Too hard to get/ procedure too complica |         51        2.98        2.98
      Have tried without success before |         19        1.11        4.09
                No sponsor to guarantee |         13        0.76        4.85
                          Too expensive |        226       13.20       18.05
              Work permit not necessary |         48        2.80       20.85
      Not possible to get a work permit |         12        0.70       21.55
Work permit not available for UNHCR reg |         18        1.05       22.61
                                  Other |          1        0.06       22.66
                                      . |      1,324       77.34      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,712      100.00
*/

tab r307, 
/*   Previous |
work permit |
  in Jordan |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |         45        2.63        2.63
         No |        449       26.23       28.86
          . |      1,218       71.14      100.00
------------+-----------------------------------
      Total |      1,712      100.00

*/




*****************
* MERGE DATASET *
*****************

use "$data_base/Jordan2014 ILO HH_UserFile_Jul 2014.dta", clear 

*RSI
merge 1:1 ques_no using "$data_base/Jordan2014 ILO RSI_UserFile_Jul 2014.dta"
ren _merge merge_rsi
/*
   Result                           # of obs.
    -----------------------------------------
    not matched                         2,148
        from master                     2,148  (_merge==1)
        from using                          0  (_merge==2)

    matched                             1,712  (_merge==3)
    -----------------------------------------
*/

*1,712 individuals selected in RSI (1 by household)

merge 1:m ques_no using "$data_base/Jordan2014 ILO ROS_UserFile_Jul 2014.dta"
ren _merge merge_ros

*Gen Individual ID 
egen iid = concat(ques_no q300)

isid iid 
ren ques_no hhid



