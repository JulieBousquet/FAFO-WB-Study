
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


use "$data_base/Jordan2014_ROS_HH_RSI.dta", clear


distinct hhid 
distinct iid
distinct rsi_id 


tab governorate, m
tab ur_rl, m 
tab nat_hh, m
tab nat_samp, m
tab HHgroup, m


*District
tab q102, m 
ren q102 q102_district
tab q102_district, m

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


