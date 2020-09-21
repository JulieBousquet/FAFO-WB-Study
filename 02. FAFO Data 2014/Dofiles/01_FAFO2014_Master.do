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
   
	global github 	`"/users/`c(username)'/Documents/GitHub/FAFO-WB-Study/"'
	global dropbox	`"/users/`c(username)'/Dropbox/Fafo-WB Study/Jordan/"'
   
   }
   
 *Folder globals
   global analysis_dt               "$dropbox/Jordan 2014" 
   global analysis_do               "$github/Dofiles" 
   global analysis_out              "$dropbox/Output" 



exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
