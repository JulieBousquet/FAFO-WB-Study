
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

use "$data_2020_base/RSI-Final.dta",clear 
