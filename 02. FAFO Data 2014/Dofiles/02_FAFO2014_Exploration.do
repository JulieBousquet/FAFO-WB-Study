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

use "$data_2014_base/Jordan2014 ILO HH_UserFile_Jul 2014.dta", clear

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

*** HOUSEHOLD DEMOGRAPHICS

*Highest level of education
tab HHedumax, m 

*Number of children in hh
tab HHchildren, m
*Gender of hh head 
tab HHsex, m 
*Age of hh head
tab HHage, m 
*Citizenship of hh head
tab HHcitizen, m 
*Refugee status od hh head
tab HHrefugee, m 
*Pop group of hh head
tab HHPopGrp, m 
*Hh educ
tab HHedu, m 
*HH income
tab HHincome, m 

order   HHedumax HHchildren HHsex HHage HHcitizen ///
        HHrefugee HHPopGrp HHedu HHincome ///
        , a(q115_f_hh_members_cat) 


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
tab q204new, m 
ren q204new q204_nb_rooms_newcat

tab q205, m 
tab q205new, m 
ren q205new q205_size_dwell_cat

tab q206, m 

tab q207, m 
tab q207new, m 
ren q207new q207_toilet_cleancat

tab q208, m 
tab q209, m 
tab q210, m 

tab q211, m 
tab q211new, m 
ren q211new q211_water_exp_cat

tab q212, m 

tab q213, m 
tab q213new, m
ren q213new q213_energy_exp_cat

tab q213_1, m 
tab q213_1new, m 
ren q213_1new q213_1_gas_exp_cat

tab q213_2, m 
tab q213_2new, m 
ren q213_2new q213_2_petrol_exp_cat

tab q213_3, m 
tab q213_3new, m 
ren q213_3new q213_3_elec_exp_cat

tab q213_4, m
tab q213_4new, m
ren q213_4new q213_4_wood_exp_cat 

tab q213_5, m
tab q213_5new, m 
ren q213_5new q213_5_oth_exp_cat

order   q204 q204_nb_rooms_newcat ///
        q205 q205_size_dwell_cat ///
        q207 q207_toilet_cleancat ///
        q211 q211_water_exp_cat ///
        q213 q213_energy_exp_cat ///
        q213_1 q213_1_gas_exp_cat ///
        q213_2 q213_2_petrol_exp_cat /// 
        q213_3 q213_3_elec_exp_cat ///
        q213_4 q213_4_wood_exp_cat ///
        q213_5 q213_5_oth_exp_cat ///
        , a(q203)


/* SUBSECTION: Tenure */
*  ------------------  *

tab q214, m 

tab q215, m
tab q215new, m 
ren q215new q215_rent_cat

tab q216, m 
tab q217, m 

tab q218, m 
tab q218new, m
ren q218new q218_rent_mkt_cat

tab q219, m 
tab q219_2, m 
tab q220_1, m 
tab q220_2, m 
tab q220_3, m 

tab q221, m 
tab q221new, m
ren q221new q221_inc_rent_cat

tab q222, m 
tab q222new, m 

tab q223_1, m 
tab q223_2, m 

ren q222new q222_q223_free_accom_refug


order q215 q215_rent_cat ///
      q216 q217 ///
      q218 q218_rent_mkt_cat ///
      q219 q219_2 ///
      q220_1 q220_2 q220_3 ///
      q221 q221_inc_rent_cat /// 
      q222 q223_1 q223_2 q222_q223_free_accom_refug ///
      , a(q214)

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
tab inc_wage_y, m
ren inc_wage_y q900_inc_wage_y
tab q900_qy, m 
tab q900_qynew, m
ren q900_qynew q900_qy_inc_wage_cat
tab q900_qm, m 
tab inc_wage_m, m
ren inc_wage_m q900_inc_wage_m
tab q900_qmnew, m
ren q900_qmnew q900_qm_inc_wage_cat

tab q901, m
tab inc_selfemp_y, m 
ren inc_selfemp_y q901_inc_selfemp_y
tab q901_qy, m 
tab q901_qynew, m
ren q901_qynew q901_qy_inc_se_cat
tab q901_qm, m 
tab inc_selfemp_m, m
ren inc_selfemp_m q901_inc_selfemp_m
tab q901_qmnew, m
ren q901_qmnew q901_qm_inc_se_cat

tab q902, m 
tab inc_transfer_y, m
ren inc_transfer_y q902_inc_transfer_y
tab q902_qy, m 
tab q902_qynew, m
ren q902_qynew q902_qy_inc_transf_cat
tab q902_qm, m 
tab inc_transfer_m, m
ren inc_transfer_m q902_inc_transfer_m
tab q902_qmnew, m
ren q902_qmnew q902_qm_inc_transf_cat

tab q903, m
tab inc_property_y, m
ren inc_property_y q903_inc_property_y
tab q903_qy, m 
tab q903_qynew, m
ren q903_qynew q903_qy_inc_prop_cat
tab q903_qm, m 
tab inc_property_m, m
ren inc_property_m q903_inc_property_m
tab q903_qmnew, m
ren q903_qmnew q903_qm_inc_prop_cat

tab q904, m 
tab inc_other_y, m
ren inc_other_y q904_inc_other_y
tab q904_qy, m 
tab q904_qynew, m
ren q904_qynew q904_qy_inc_oth_cat
tab q904_qm, m 
tab inc_other_m, m
ren inc_other_m q904_inc_other_m
tab q904_qmnew, m
ren q904_qmnew q904_qm_inc_oth_cat

tab q905, m 
tab q905_qy, m
tab q905_qyupd, m 
tab q905_qyupdnew, m
ren q905_qyupdnew q905_qyupd_inc_totadj_cat
tab q905_qyupd_inc_totadj_cat, m

*Total income last month
tab HHallincome, m 
ren HHallincome income_m_total_hh
tab HHallincome_new, m 
ren HHallincome_new income_m_total_hh_cat

*Usual month cash income of ALL hh members
tab HHwage, m 
ren HHwage wage_m_hh
tab HHwage_new, m 
ren HHwage_new wage_m_hh_cat

*Usual month cash income of all hh members aged 18+
tab HHadultinc, m 
ren HHadultinc income_m_adult18
tab HHadultinc_new, m 
ren HHadultinc_new income_m_adult18_cat

*Usual month cash income of MALE hh members aged 
tab HHmaleinc, m 
ren HHmaleinc income_m_male
tab HHmaleinc_new, m 
ren HHmaleinc_new income_m_male_cat

*Usual month cash income of all hh members aged 25+
tab HHadultinc2, m 
ren HHadultinc2 income_m_adult25
tab HHadultinc2_new, m 
ren HHadultinc2_new income_m_adult25_cat


order   q900_qy q900_inc_wage_y q900_qy_inc_wage_cat ///
        q900_qm q900_inc_wage_m q900_qm_inc_wage_cat ///
        q901 q901_inc_selfemp_y q901_qy q901_qy_inc_se_cat ///
        q901_qm q901_inc_selfemp_m q901_qm_inc_se_cat ///
        q902 q902_inc_transfer_y q902_qy q902_qy_inc_transf_cat ///
        q902_qm q902_inc_transfer_m q902_qm_inc_transf_cat ///
        q903 q903_inc_property_y q903_qy q903_qy_inc_prop_cat ///
        q903_qm q903_inc_property_m q903_qm_inc_prop_cat ///
        q904 q904_inc_other_y q904_qy q904_qy_inc_oth_cat ///
        q904_qm q904_inc_other_m q904_qm_inc_oth_cat ///
        q905 q905_qy ///
        q905_qyupd q905_qyupd_inc_totadj_cat ///
        income_m_total_hh income_m_total_hh_cat wage_m_hh ///
        wage_m_hh_cat income_m_adult18 income_m_adult18_cat ///
        income_m_male income_m_male_cat income_m_adult25 ///
        income_m_adult25_cat ///
        , a(q900)

/* SUBSECTION: Economics Self-Assessment */
*  -------------------------------------  *

tab q906, m 
tab q907, m 
tab q907new, m
ren q907new q907_eco_status_cat

order q907_eco_status_cat, a(q907)

/* SUBSECTION: Poverty Support */
*  ---------------------------  *

*National poverty support (NPS)
tab q908_a1, m 
tab q908_j1, m
tab q908_j1new, m
ren q908_j1new q908_j1_aid_nps_cat 
tab q908_b1, m 
tab q908_c1, m 
tab q908_d1, m 

*Hashemite charity packages
tab q908_a2, m 
tab q908_j2, m 
tab q908_j2new, m
ren q908_j2new q908_j2_aid_charity_cat
tab q908_b2, m 
tab q908_c2, m 
tab q908_d2, m

*Zakat committee
tab q908_a3, m 
tab q908_j3, m
tab q908_j3new, m
ren q908_j3new q908_j3_aid_zakat_cat
tab q908_b3, m 
tab q908_c3, m 
tab q908_d3, m 

*Religious organization
tab q908_a4, m 
tab q908_j4, m 
tab q908_j4new, m 
ren q908_j4new q908_j4_aid_rel_cat
tab q908_b4, m 
tab q908_c4, m 
tab q908_d4, m

*Other Jordanian NGO/Charity
tab q908_a5, m 
tab q908_j5, m 
tab q908_j5new, m
ren q908_j5new q908_j5_aid_jord_cat
tab q908_b5, m 
tab q908_c5, m 
tab q908_d5, m 

*UNRWA
tab q908_a6, m 
tab q908_j6, m 
tab q908_j6new, m
ren q908_j6new q908_j6_aid_unrwa_cat
tab q908_b6, m 
tab q908_c6, m 
tab q908_d6, m 

*Other international NGO
tab q908_a7, m 
tab q908_j7, m
tab q908_j7new, m 
ren q908_j7new q908_j7_aid_ngo_cat
tab q908_b7, m 
tab q908_c7, m 
tab q908_d7, m

*Other country/embassy
tab q908_a8, m 
tab q908_j8, m 
tab q908_j8new, m
ren q908_j8new q908_j8_aid_country_cat
tab q908_b8, m 
tab q908_c8, m 
tab q908_d8, m 

*Other
tab q908_a9, m 
tab q908_j9, m 
tab q908_j9new, m
ren q908_j9new q908_j9_aid_oth_cat
tab q908_b9, m 
tab q908_c9, m 
tab q908_d9, m 
tab q908_9t, m 

order q908_a1 q908_j1 q908_j1_aid_nps_cat q908_b1 q908_c1 q908_d1 ///
      q908_a2 q908_j2 q908_j2_aid_charity_cat q908_b2 q908_c2 q908_d2 ///
      q908_a3 q908_j3 q908_j3_aid_zakat_cat q908_b3 q908_c3 q908_d3 ///
      q908_a4 q908_j4 q908_j4_aid_rel_cat q908_b4 q908_c4 q908_d4 ///
      q908_a5 q908_j5 q908_j5_aid_jord_cat q908_b5 q908_c5 q908_d5 ///
      q908_a6 q908_j6 q908_j6_aid_unrwa_cat q908_b6 q908_c6 q908_d6 ///
      q908_a7 q908_j7 q908_j7_aid_ngo_cat q908_b7 q908_c7 q908_d7 ///
      q908_a8 q908_j8 q908_j8_aid_country_cat q908_b8 q908_c8 q908_d8 ///
      q908_a9 q908_j9 q908_j9_aid_oth_cat q908_b9 q908_c9 q908_d9 ///
      q908_9t, a(q907_eco_status_cat)


*Poverty Support

*Did the hh receive any kind of assistance in last 6 months
tab money, m 
*Created  from variables: q908_a*

*Total amount in assistance
tab amount, m
*Created from variables: q908_j* 

*Did the hh receive food assistance in last 6 months
tab food, m 
*Created from variables: q908_b*

*Did the hh receive shelter assitance in last 6 months
tab shelter, m 
*Created from variables: q908_c*

*Did the hh receive other assitance in last 6 months
tab other, m 
*Created from variables: q908_d*

*From international providers 
*Q: WHO IS INCLUDED AS "INTERNATIONAL PROVIDERS"
tab int_money, m 
tab int_amount, m 
tab int_food, m 
tab int_shelter, m 
tab int_other, m 

order   money amount food shelter other ///
        int_money int_amount int_food int_shelter int_other ///
        , a(q908_9t)

tab q909, m 
tab q909new, m
ren q909new q909_min_inc

order   q909 q909_min_inc ///
        , a(int_other)

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

*Share of hh members in employment
tab Depratio_1, m
*Demographic dependents per hh member 
tab Depratio2_1, m 
*Economic dependents per hh member
tab Depratio3_1, m 

*Share of hh members in employment
tab DepRatio, m 
*Demographic dependents per hh member
tab DepRatio2, m 
*Economic dependents per hh member
tab DepRatio3, m 

*Employed community members per economic dependent
tab GroupDepRatio, m 
*Demographic dependents per working age comunity member
tab GroupDepRatio2, m 
*Economic dependents per employed community member 
tab GroupDepRatio3, m 


*Wealth index
tab wealthidx, m 
*Wealth index quintiles
tab wealthidx5, m 
*Wealth index tertile
tab wealthidx3, m 

tab dtot___, m


*CREATION OF THE UNIQUE ID for matching 

egen iid = concat(hhid q113_main_resp_hh)
isid iid 
lab var iid "Individual ID: concat hhid and main resp nb"

******************
* ROSter DATASET *
******************

use "$data_2014_base/Jordan2014 ILO ROS_UserFile_Jul 2014.dta", clear
isid ques_no
sort ques_no

*Serial Number of household member
tab q300 , m

*Questionnaire Number
tab ques_no, m 
ren ques_no hhid

*Household relative weight 
tab HHrel_wt, m

*RSI relative weight
tab RSIrel_wt, m 

*Name gornorates
tab governorate, m 

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

*Nationality: at least one syrian member
tab nat_hh, m 
ren nat_hh nationality_hh

*Nationality: as listed
tab nat_samp, m 
ren nat_samp nationality_listed

tab HHgroup, m 

tab HHgr1, m
 
tab HHgr2, m 

tab HHgr3, m 

tab HHgr4, m 

tab year, m 
*2014

*District
tab q102, m 
ren q102 q102_district
tab q102_district, m

*Sub district
tab q103, m 
ren q103 q103_sub_district
tab q103_sub_district, m

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

egen iid = concat(hhid q300)
isid iid 
lab var iid "Individual ID: concat hhid and main resp nb"

*Mains respondent RSI quest
tab q114, m 
ren q114 q114_main_resp_rsi

*Interview status
tab q123, m 
ren q123 q123_interview_compl

*Total hh member
tab q115_t, m 
ren q115_t q115_t_hh_members

  *Male
  tab q115_m, m 
  ren q115_m q115_m_hh_members

  tab q115_f, m 
  ren q115_f q115_f_hh_members

  order q115_t_hh_members  ///
        q115_m_hh_members  ///
        q115_f_hh_members  ///
        , a(q123_interview_compl) 


***************
* RSI DATASET *
***************

use "$data_2014_base/Jordan2014 ILO RSI_UserFile_Jul 2014.dta", clear

isid ques_no

*Questionnaire Number
tab ques_no, m 
ren ques_no hhid

*Household relative weight 
tab HHrel_wt, m

*RSI relative weight
tab RSIrel_wt, m 

*Name gornorates
tab governorate, m 

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

*Nationality: at least one syrian member
tab nat_hh, m 
ren nat_hh nationality_hh

*Nationality: as listed
tab nat_samp, m 
ren nat_samp nationality_listed

tab HHgroup, m 

tab HHgr1, m
 
tab HHgr2, m 

tab HHgr3, m 

tab HHgr4, m 

tab year, m 
*2014

*District
tab q102, m 
ren q102 q102_district
tab q102_district, m

*Sub district
tab q103, m 
ren q103 q103_sub_district
tab q103_sub_district, m

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

*Total hh member
tab q115_t, m 
ren q115_t q115_t_hh_members

  *Male
  tab q115_m, m 
  ren q115_m q115_m_hh_members

  tab q115_f, m 
  ren q115_f q115_f_hh_members

  order q115_t_hh_members  ///
        q115_m_hh_members  ///
        q115_f_hh_members  ///
        , a(q123_interview_compl) 



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

use "$data_2014_base/Jordan2014 ILO ROS_UserFile_Jul 2014.dta", clear

*Household ID
ren   ques_no hhid 

*The unique identifier is: the HHID + the serial number of household
*The head, who was initally surveyed, is the number 1
egen      iid = concat(hhid q300)
destring  iid, replace
isid      iid 
lab var   iid "Individual ID: concat hhid and serial number"

tempfile filetemp
save `filetemp' 


use "$data_2014_base/Jordan2014 ILO HH_UserFile_Jul 2014.dta", clear 

*Household ID
ren   ques_no hhid 

*Since the head always has number 1 as a serial number,
*I create the unique id of the head, in order to match
*with the ROS dataset. In that case, we are able to have 
*all the info of the head, ROS + HH, and the info
*of the rest of the household
gen   hid = 1

egen  iid = concat(hhid hid)
destring  iid, replace
isid      iid 
lab var   iid "Individual ID: concat hhid and head serial number = 1"

egen rsi_id = concat(hhid q114)
destring  rsi_id, replace
isid rsi_id

*Then, supposely, we can merge on iid. There should be 3,860 match
merge 1:1 iid using `filetemp'
ren _merge merge_ros

sort hhid iid

tempfile filetemp2
save `filetemp2' 

use "$data_2014_base/Jordan2014 ILO RSI_UserFile_Jul 2014.dta", clear 

*Household ID
ren   ques_no hhid 

egen rsi_id = concat(hhid q114)
destring  rsi_id, replace
isid rsi_id

*Then, supposely, we can merge on iid. There should be 1,712 match
merge 1:m rsi_id using `filetemp2'
ren _merge merge_rsi

order hhid iid rsi_id

isid iid 

sort hhid iid

tab merge_rsi 
replace rsi_id = . if merge_rsi == 2 
distinct rsi_id

save "$data_2014_base/Jordan2014_ROS_HH_RSI.dta", replace


