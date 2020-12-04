

use "$data_2014_base/Jordan2014_ROS_HH_RSI.dta", clear

desc 

/*
  obs:        21,524                          
 vars:           738                          
 size:    20,039,055  
*/

distinct hhid 
* 3860

distinct iid 
*21524 

use "$data_2020_base/Jordan2020_HH_RSI.dta", clear

desc 

/*
  obs:         1,544                          
 vars:           568                         
 size:     2,299,252                          
*/

distinct iid 
