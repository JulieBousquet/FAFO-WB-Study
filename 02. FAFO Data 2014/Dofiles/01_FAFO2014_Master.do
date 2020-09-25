/*====================================================================
project:       FAFO - Master Do File
Author:        Julie Bousquet 
----------------------------------------------------------------------
Creation Date:    18 September 2020 
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/


*Master do file, analysis CDD

 clear all

	*Change the data path 
if inlist(c(username), "u0131185", "julie") == 1 {
   
	global github 	`"/users/`c(username)'/Documents/GitHub/FAFO-WB-Study-Jordan/"'
	global dropbox	`"/users/`c(username)'/Dropbox/Fafo-WB Study/Jordan/Jordan 2014/"'
   
   }
   
	****************************
	**  EXPLORATORY ANALYSIS  **
	****************************
	
	*Master to locate the L1 folder
		global data "$dropbox/01. Datasets/"
			global data_base "$data/02. Base"
			global data_temp "$data/03. Temp"
			global data_final "$data/04. Final"
		global do_2014 "$github/02.FAFO Data 2014/Dofiles/"
		global do_master "$github/01. Master Data/Dofiles/"
		global out  "$dropbox/02. Output/"
			

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
