cap log close
clear all
set more off, permanently
set mem 100m

*log using "$analysis_do/01_Data_Cleaning_EL1.log", replace

	****************************************************************************
	**                               DATA CONSTRUCT                           **  
	** ---------------------------------------------------------------------- **
	** Type Do  : 	DATA CLEANING FAFO 2014                                   **
  **                                                                        **
	** Authors  : Julie Bousquet                                              **
	****************************************************************************


*****************
* MERGE DATASET *
*****************

use "$data_2014_base/Jordan2014 ILO ROS_UserFile_Jul 2014.dta", clear

*Household ID
ren   		ques_no hhid 
distinct 	hhid

*The unique identifier is: the HHID + the serial number of household
*The head, who was initally surveyed, is the number 1
egen      iid = concat(hhid q300), f(%18.0g)
destring  iid, replace
isid      iid 
lab var   iid "Individual ID: concat hhid and serial number"

tempfile roster
save `roster' 

*
use "$data_2014_base/Jordan2014 ILO HH_UserFile_Jul 2014.dta", clear 

*Household ID
ren   ques_no hhid 

*Since the head always has number 1 as a serial number,
*I create the unique id of the head, in order to match
*with the ROS dataset. In that case, we are able to have 
*all the info of the head, ROS + HH, and the info
*of the rest of the household
gen   hid = 1

egen  iid = concat(hhid hid), f(%18.0g)
destring  iid, replace
isid      iid 
lab var   iid "Individual ID: concat hhid and head serial number = 1"

egen rsi_id = concat(hhid q114), f(%18.0g)
destring  rsi_id, replace
isid rsi_id

distinct iid 
*3860 Household Heads 

*Then, supposely, we can merge on iid. There should be 3,860 match
merge 1:1 iid using `roster'
ren _merge merge_ros

gen survey_hh = 1 if merge_ros == 3
lab var survey_hh "Individual did the HH survey (+did ROS)"
*3,860

gen survey_ros = 1 if merge_ros == 2 
lab var survey_ros "Individual did the ROSTER survey"
*17,664


sort hhid iid

tempfile head_roster
save `head_roster' 

use "$data_2014_base/Jordan2014 ILO RSI_UserFile_Jul 2014.dta", clear 

*Household ID
ren   ques_no hhid 

egen rsi_id = concat(hhid q114), f(%18.0g)
destring  rsi_id, replace
isid rsi_id

*Then, supposely, we can merge on iid. There should be 1,712 match
merge 1:m rsi_id using `head_roster'
ren _merge merge_rsi


gen survey_rsi = 1 if merge_rsi == 3 
lab var survey_rsi "Individual did the RSI survey"
*1,712
order survey_rsi, b(r201)

*First variable of ROS Dataset
order survey_hh, b(q107_1)
*First variable of RSI Dataset
order survey_ros , b(q300)

order hhid iid rsi_id

isid iid 

sort hhid iid

tab merge_rsi 
replace rsi_id = . if merge_rsi == 2 
distinct rsi_id

save "$data_2014_final/Jordan2014_ROS_HH_RSI.dta", replace


