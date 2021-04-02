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
	global dropbox	`"/users/`c(username)'/Dropbox/Fafo-WB Study/Jordan/06. DataWork/"'
   
   }
   
   
	****************************
	**       MASTER DATA      **
	****************************
	*Master to locate the folder
	global masterdata "$dropbox/01. Master Data/"
		global data 	 		"$masterdata/01. Datasets/"
			global data_base 		"$data/02. Base"
			global data_temp 		"$data/03. Temp"
			global data_final 		"$data/04. Final"
		global out  			"$masterdata/02. Output/"
		global do				"$github/01. Master Data/Dofiles/"


	****************************
	**        DATA 2014       **
	****************************
	
	*Master to locate the folder
	global data_fafo2014 "$dropbox/02. Data Jordan 2014/"
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
	global data_fafo2020 "$dropbox/03. Data Jordan 2020/"
		global data_2020 		"$data_fafo2020/01. Datasets/"
			global data_2020_base 		"$data_2020/02. Base"
			global data_2020_temp 		"$data_2020/03. Temp"
			global data_2020_final 		"$data_2020/04. Final"
		global out_2020  		"$data_fafo2020/02. Output/"
		global do_2020			"$github/03. FAFO Data 2020/Dofiles/"


	*********************************
	**     SECONDARY DATA: LFS     **
	*********************************
	*Master to locate the folder
	global data_sec_LFS "$dropbox/04. Secondary Data/01. Labor Force Survey Syria 2010/"
		global data_LFS 		"$data_sec_LFS/01. Datasets/"
			global data_LFS_base 		"$data_LFS/02. Base"
			global data_LFS_temp 		"$data_LFS/03. Temp"
			global data_LFS_final 		"$data_LFS/04. Final"
			global data_LFS_shp			"$data_LFS/05. Shapefile"
		global out_LFS  		"$data_sec_LFS/02. Output/"
		global do_LFS			"$github/04. Secondary Data/Dofiles/"


	***********************************
	**     SECONDARY DATA: UNHCR     **
	***********************************
	*Master to locate the folder
	global data_sec_UNHCR "$dropbox/04. Secondary Data/04. UNHCR/"
		global data_UNHCR		"$data_sec_UNHCR/01. Datasets/"
			global data_UNHCR_base 		"$data_UNHCR/01. Base"
			global data_UNHCR_temp 		"$data_UNHCR/02. Temp"
			global data_UNHCR_final 	"$data_UNHCR/03. Final"
		global out_UNHCR  		"$data_sec_UNHCR/02. Output/"

	*********************************
	**    SECONDARY DATA: JLMPS    **
	*********************************

	*Master to locate the folder
	global data_sec_JLMPS "$dropbox/04. Secondary Data/05. JLMPS/"
		* 2010 *
		global data_sec_JLMPS_2010 "$data_sec_JLMPS/2010/"
			global data_JLMPS_2010 		"$data_sec_JLMPS_2010/01. Datasets/"
				global data_JLMPS_2010_base 		"$data_JLMPS_2010/01. Base"
				global data_JLMPS_2010_temp 		"$data_JLMPS_2010/02. Temp"
				global data_JLMPS_2010_final 		"$data_JLMPS_2010/03. Final"
			global out_JLMPS_2010  		"$data_sec_JLMPS_2010/02. Output/"

		* 2016 *
		global data_sec_JLMPS_2016 "$data_sec_JLMPS/2016/"
			global data_JLMPS_2016 		"$data_sec_JLMPS_2016/02. Datasets/"
				global data_JLMPS_2016_base 		"$data_JLMPS_2016/01. Base"
				global data_JLMPS_2016_temp 		"$data_JLMPS_2016/02. Temp"
				global data_JLMPS_2016_final 		"$data_JLMPS_2016/03. Final"
			global out_JLMPS_2016  		"$data_sec_JLMPS_2016/02. Output/"


	***********************************
	**    SECONDARY DATA: RELIEF     **
	***********************************
	*Master to locate the folder
	global data_sec_RW "$dropbox/04. Secondary Data/07. Relief World/"
		global data_RW 		"$data_sec_RW/01. Datasets/"
			global data_RW_base 	"$data_RW/01. Base"
			global data_RW_temp 	"$data_RW/02. Temp"
			global data_RW_final 	"$data_RW/03. Final"


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

