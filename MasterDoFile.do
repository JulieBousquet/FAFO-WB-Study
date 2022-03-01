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
	*global github 	`"/users/`c(username)'/OneDrive/Documents/GitHub/FAFO-WB-Study-Jordan/"'
	global dropbox	`"/users/`c(username)'/Dropbox/Fafo-WB Study/Jordan/06. DataWork/"'
   
   }
   
   
	****************************
	**       MASTER DATA      **
	****************************
	*Master to locate the folder
	global masterdata "$dropbox/01. Master Data/"
		global data_master 	 	"$masterdata/01. Datasets/"
		global out_master		"$masterdata/02. Output/"

	global do_master 	"$github/01. Master Data/Dofiles/"


	**********************
	**     ANALYSIS     **
	**********************
	*Master to locate the folder
	global folder_analysis "$dropbox/05. Analysis/"
		global data_analysis	"$folder_analysis/01. Datasets/"
			global data_base 		"$data_analysis/01. Base"
			global data_temp 		"$data_analysis/02. Temp"
			global data_final 		"$data_analysis/03. Final"
		global out_analysis	"$folder_analysis/02. Output/"
	global do_analysis 	"$github/05. Analysis"

	

	****************************
	**        FAFO            **
	****************************

	*Master to locate the folder
	global data_fafo "$dropbox/02. FAFO/"

	****************************
	**        FAFO 2014       **
	****************************
		
	*Master to locate the folder
	global folder_fafo2014 "$data_fafo/01. FAFO 2014/"
		global data_fafo2014 		"$folder_fafo2014/01. Datasets/"
			global data_2014_base 		"$data_fafo2014/02. Base"
			global data_2014_temp 		"$data_fafo2014/03. Temp"
			global data_2014_final 		"$data_fafo2014/04. Final"
		global out_2014  		"$folder_fafo2014/02. Output/"

	****************************
	**        FAFO 2020       **
	****************************
	*Master to locate the folder
	global folder_fafo2020 "$data_fafo/02. FAFO 2020/"
		global data_fafo2020 		"$folder_fafo2020/01. Datasets/"
			global data_2020_base 		"$data_fafo2020/02. Base"
			global data_2020_temp 		"$data_fafo2020/03. Temp"
			global data_2020_final 		"$data_fafo2020/04. Final"
		global out_2020  		"$folder_fafo2020/02. Output/"

	****************************
	**        JLMPS           **
	****************************

	*Master to locate the folder
	global folder_JLMPS "$dropbox/03. JLMPS/"
		global data_JLMPS 		"$folder_JLMPS/02. Datasets/"
			global data_JLMPS_base 		"$data_JLMPS/01. Base"
			global data_JLMPS_temp 		"$data_JLMPS/02. Temp"
			global data_JLMPS_final 	"$data_JLMPS/03. Final"
		global out_JLMPS  	"$folder_JLMPS/03. Output/"


	****************************
	**     SECONDARY DATA     **
	****************************

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


			***********************************
			**    SECONDARY DATA: RELIEF     **
			***********************************
			*Master to locate the folder
			global data_sec_RW "$dropbox/04. Secondary Data/05. Relief World/"
				global data_RW 		"$data_sec_RW/01. Datasets/"
					global data_RW_base 	"$data_RW/01. Base"
					global data_RW_temp 	"$data_RW/02. Temp"
					global data_RW_final 	"$data_RW/03. Final"


			***********************************
			**    SECONDARY DATA: DOS     **
			***********************************
			*Master to locate the folder
			global data_sec_DOS "$dropbox/04. Secondary Data/02. Data Jordan_MSc/DoS/"


			***********************************
			**    SECONDARY DATA: ACLED     **
			***********************************
			*Master to locate the folder
			global data_sec_ACLED "$dropbox/04. Secondary Data/08. Conflicts Syria/01. ACLED"
				global data_ACLED 		"$data_sec_ACLED/01. Datasets/"
					global data_ACLED_base 	"$data_ACLED/01. Base"
					global data_ACLED_temp 	"$data_ACLED/02. Temp"
					global data_ACLED_final "$data_ACLED/03. Final"


			***********************************
			**    SECONDARY DATA: IPMUS     **
			***********************************
			*Master to locate the folder
			global data_sec_IPMUS "$dropbox/04. Secondary Data/09. IPMUS"
				global data_IPMUS 		"$data_sec_IPMUS/01. Datasets/"
					global data_IPMUS_base 	"$data_IPMUS/01. Base"
					global data_IPMUS_temp 	"$data_IPMUS/02. Temp"
					global data_IPMUS_final "$data_IPMUS/03. Final"


			***********************************
			**    SECONDARY DATA: FALLAH     **
			***********************************
			*Master to locate the folder
			global data_sec_Fallah "$dropbox/04. Secondary Data/10. Fallah et al"
				global data_Fallah 	"$data_sec_Fallah/01. Datasets/"
					global data_Fallah_base 	"$data_Fallah/01. Base"
					global data_Fallah_temp 	"$data_Fallah/02. Temp"
					global data_Fallah_final 	"$data_Fallah/03. Final"


		


	*****************************
	**     RUN THE GLOBALS     **
	*****************************
	qui do "$do_analysis/00_Globals.do"

	*qui do "$do_analysis/01_SR_JLMPS_Ref_Inflow.do"
	*qui do "$do_analysis/02_JLMPS_Comp_10_16.do"
	*qui do "$do_analysis/03_IV_WiP.do"
	*qui do "$do_analysis/04_JLMPS_Construct.do"
	*qui do "$do_analysis/05_JLMPS_SummaryStats.do"
	*qui do "$do_analysis/06_JLMPS_Analysis_WiP.do"
	*qui do "$do_analysis/07_JLMPS_Robsutness.do"
	*qui do "$do_analysis/08_JLMPS_Heterogenous.do"
	*qui do "$do_analysis/09_JLMPS_Sample_Check.do"
	*qui do "$do_analysis/10_JLMPS_Analysis_EM.do"
	*qui do "$do_analysis/11_JLMPS_Analysis_onIVs.do"
	*qui do "$do_analysis/.do"




/*
ren job_stable_3m stable_3m 
ren wp_industry_jlmps_3m wp_ind_3m
ren member_union_3m union_3m
ren skills_required_pjob skilled 
ren ln_total_rwage_3m ln_trwage_3m 
ren ln_hourly_rwage ln_hrwage_3m 
ren work_hours_pweek_3m_w whpw_3m 
ren work_days_pweek_3m wdpw_3m 

*/




exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

