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
	global dropbox	`"/users/`c(username)'/Dropbox/Fafo-WB Study/Jordan/"'
   
   }
   
	****************************
	**        DATA 2014       **
	****************************
	
	*Master to locate the folder
	global data_fafo2014 "$dropbox/06. Data Jordan 2014/"
		global data_2014 		"$data_fafo2014/01. Datasets/"
			global data_2014_base 		"$data_2014/02. Base"
			global data_2014_temp 		"$data_2014/03. Temp"
			global data_2014_final 		"$data_2014/04. Final"
		global out_2014  		"$data_fafo2014/02. Output/"
		global do_2014 			"$github/02. FAFO Data 2014/Dofiles/"

		global do_master 	"$github/01. Master Data/Dofiles/"
	

	****************************
	**        DATA 2020       **
	****************************
	*Master to locate the folder
	global data_fafo2020 "$dropbox/07. Data Jordan 2020/"
		global data_2020 		"$data_fafo2020/01. Datasets/"
			global data_2020_base 		"$data_2020/02. Base"
			global data_2020_temp 		"$data_2020/03. Temp"
			global data_2020_final 		"$data_2020/04. Final"
		global out_2020  		"$data_fafo2020/02. Output/"
		global do_2020			"$github/03. FAFO Data 2020/Dofiles/"


	****************************
	**       MASTER DATA      **
	****************************
	*Master to locate the folder
	global masterdata "$dropbox/08. Master Data/"
		global data 	 		"$masterdata/01. Datasets/"
			global data_base 		"$data/02. Base"
			global data_temp 		"$data/03. Temp"
			global data_final 		"$data/04. Final"
		global out  			"$masterdata/02. Output/"
		global do				"$github/01. Master Data/Dofiles/"

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
