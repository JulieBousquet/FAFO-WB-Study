
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
