

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

use "$data_2020_final/Jordan2020_HH_RSI.dta", clear

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











