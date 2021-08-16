
cap log close
clear all
set more off, permanently
set mem 100m


   ****************************************************************************
   **                            DATA JLMPS                                  **
   **                 MERGING OF DATASETS 2010-2016 JLMPS + IV SS            **  
   ** ---------------------------------------------------------------------- **
   ** Type Do  :  DATA JLMPS   MERGING IV/CONSTRUCTING OUTCOME VARIABLES     **
   **                                                                        **
   ** Authors  : Julie Bousquet                                              **
   ****************************************************************************


*Merge JLMPS and SHIFT SHARE
use "$data_final/02_JLMPS_10_16.dta", clear


merge m:1 district_iid using "$data_final/03_ShiftShare_IV.dta" 
drop _merge 

merge m:1 governorate_iid using "$data_temp/07_Ctrl_Nb_Refugee_byGov.dta"
drop _merge

tab work_permit, m //more accurate version 
tab work_permit_orig, m
tab IV_SS, m
*NO INSTRUMENT / NO WP IN 2010
replace IV_SS = 0 if year == 2010
tab IV_SS , m


tab nationality q11203
tab q11203
tab nationality_cl
tab year 

*save "$data_final/05_IV_JLMPS_Analysis.dta", replace
save "$data_final/05_IV_JLMPS_MergingIV.dta", replace




use "$data_final/05_IV_JLMPS_MergingIV.dta", clear


*Missing district IN 2010: nb 25 - Husaynia 

*AGGREGATED NUMBER OF WORK PERMIT
preserve
tab forced_migr
codebook forced_migr
drop if forced_migr != 1
distinct district_iid
tab work_permit, m
collapse (sum) work_permit if year == 2016, by(district_iid)
ren work_permit agg_wp_2016
gen year = 2016
tempfile wp2016
save `wp2016'
restore

merge m:1 district_iid using `wp2016'
drop _merge

gen agg_wp = agg_wp_2016
replace agg_wp = 0 if year == 2010 //No WP in 2016
replace agg_wp = 0 if mi(agg_wp) //No WP in District
*A few districts do not have indiv with WP: should I remove them?
*drop if mi(agg_wp)
tab agg_wp, m
tab agg_wp year, m
*br agg_wp year IV_SS 
*sort year 


* ORIGINAL *

*AGGREGATED NUMBER OF WORK PERMIT
preserve
tab forced_migr
codebook forced_migr
drop if forced_migr != 1
distinct district_iid
tab work_permit_orig, m
collapse (sum) work_permit_orig if year == 2016, by(district_iid)
ren work_permit_orig agg_wp_orig_2016
gen year = 2016
tempfile wp_orig_2016
save `wp_orig_2016'
restore

merge m:1 district_iid using `wp_orig_2016'
drop _merge

gen agg_wp_orig = agg_wp_orig_2016
replace agg_wp_orig = 0 if year == 2010 //No WP in 2016
replace agg_wp_orig = 0 if mi(agg_wp_orig) //No WP in District
*A few districts do not have indiv with WP: should I remove them?
*drop if mi(agg_wp)
tab agg_wp_orig, m
tab agg_wp_orig year, m
*br agg_wp year IV_SS 
*sort year 

bys year: distinct district_iid
bys year: tab district_iid
bys year: tab district_en

/*---------*********************************************************************-----------
-----------*********************************************************************-----------
                                   VARIABLES CLEANING 
-----------*********************************************************************-----------
-----------*********************************************************************-----------*/

                                       **********
                                       *Controls*
                                       **********

*********************
** NUMBER REFUGEES **
*********************

tab NbRefbyGovoutcamp, m
ren NbRefbyGovoutcamp nb_refugees_bygov
replace nb_refugees_bygov = 0 if year == 2010
lab var nb_refugees_bygov "[CTRL] Number of refugees out of camps by governorate in 2016"

gen ln_nb_refugees_bygov = ln(1 + nb_refugees_bygov) if year == 2016
lab var ln_nb_refugees_bygov "[CTRL] LOG Number of refugees out of camps by governorate in 2016"
*ln_ref, as of now, does not include refugees in 2010, only in 2016

*********
** AGE **
*********

/*respondents' age and age squared. */
su age
lab var age "[CTRL] Age"

gen age2 = age^2
lab var age2 "[CTRL] Age Square"

*******************
** DISTANCE CAMP **
*******************

*Distance between zaatari camp and districts jordan
gen dist_zaatari_lat = 32.30888675674741
gen dist_zaatari_long = 36.31329385051756
geodist district_lat district_long dist_zaatari_lat dist_zaatari_long, gen(distance_dis_camp)
tab distance_dis_camp, m
lab var distance_dis_camp "[CTRL] Distance (km) between JORD districts and ZAATARI CAMP in 2016"
replace distance_dis_camp = 0 if year == 2010

gen ln_distance_dis_camp = log(1 + distance_dis_camp) if year == 2016
lab var ln_distance_dis_camp "[CTRL] LOG Distance (km) between JORD districts and ZAATARI CAMP in 2016"

************
** GENDER **
************

tab sex , m 
codebook sex
gen gender = 0 if sex == 2 //Female
replace gender = 1 if sex == 1 //Male
lab def gender 0 "Female" 1 "Male", modify 
lab val gender gender 
lab var gender "[CTRL] Gender - 1 Male 0 Female"

********************
** HOUSEHOLD SIZE **
********************

tab hhsize
codebook hhsize 
lab var hhsize "[CTRL] Total No. of Individuals in the Household"

***************
** EDUCATION **
***************
*Education

*-Own
/*
Seven levels of education are controlled for: (1) illiterate (reference) (2) read & write 
(3) basic (ten years) (4) secondary (two additional years) (5) post-secondary (two additional 
years beyond secondary) (6) university (four additional years beyond secondary) and
(7) post-graduate. 
*/
tab educ1d, m
codebook educ1d
lab var educ1d "[CTRL] Education Levels (1-digit)" 

/*These same education categories are included for mother's and father's education, 
although we aggregate post-graduate studies with university for parents. */

*-Father
tab fteducst, m
codebook fteducst
lab list Leduc1d
replace fteducst = 6 if fteducst == 7
lab def Leduc1d_agg     ///
           1 "Illiterate" ///
           2 "Read and Write" ///
           3 "Basic Education" ///
           4 "Secondary Educ" ///
           5 "Post-Secondary" ///
           6 "University and more", ///
           modify
lab val fteducst Leduc1d_agg
lab var fteducst "[CTRL] Father's Level of education attained" 

*-Mother
tab mteducst, m
replace mteducst = 6 if mteducst == 7
lab val mteducst Leduc1d_agg
lab var mteducst "[CTRL] Mother's Level of education attained" 

/*
father's employment status when the respondent was aged 15 as: (1) waged employee 
(2) employer (3) self-employed (4) unpaid worker (5) non-employed or (6) don't know. 
*/
tab ftempst, m 
lab var ftempst "[CTRL] Father's Employment Status (When Resp. 15)" 


/*
In some specifications we also control for geographic or individual fixed effects (in which
case some invariant controls drop out of the models).
*/


                                       ************
                                       *Instrument*
                                       ************

*THE INSTRUMENT 
tab IV_SS, m 

*THE INSTRUMENT + TRANSFORMATION
gen log_IV_SS=log(1+IV_SS)
gen IHS_IV_SS=log(IV_SS+((IV_SS^2+1)^0.5))

*THE ASKED QUESTION IN QUEST (binary)
tab work_permit, m

*AGGREGATED MEASURE OF WP BASED ON work_permit
tab agg_wp, m
tab agg_wp_orig, m //Adding another more accurate measure

*CORRELATIONS
corr IV_SS agg_wp //0.64
corr IV_SS agg_wp_orig //0.58

/*
labor market status 
employed, unemployed, or out of the labor force

border between unemployment and non-participation
we require individuals to have been actively searching for work during unemployment 
(within the past four weeks in the contemporaneous data sources, within the period of
non-employment for retrospective data)
 
Work is defined in terms of market work in the past three months;
 those who do subsistence work only are considered not working.

Number of outcomes among the employed,
including 

- whether individuals have formal work (with a contract or social
insurance) or informal work (neither a contract nor social insurance).

We also look at whether workers are in an “open sector,” that is, a sector
open to Syrians with work permits (agriculture, manufacturing, construction,
food service, or domestic/cleaning work (Kelberer, 2017)).

While Jordanians may be facing competition in the open sector, they may
also be receiving more opportunities in other sectors, particularly the
public sector. For instance, additional provision of services and international
funds may increase public sector employment, which is open
exclusively to Jordanians, while displacement may occur in the private
sector. We therefore examine the probability of employment in the private
sector among the employed (the complement necessarily being
public sector work). 

To specifically examine whether aid is likely to be
creating jobs in human services, we examine the probability of being
employed in the education or health care field among the employed.

Further, we examine occupations, specifically an outcome of being in a
managerial or professional occupation among the employed, in case
there is occupational upgrading occurring. 

For all workers, we examine hours per week, and for wage workers, we examine both hourly wages
and monthly wages.
*/
                                          **********
                                          *Outcomes*
                                          **********

                                 *******************************
                                 ****    EMPLOYEMENT        ****
                                 *******************************

/* DEF - Above 15 and below 65 , employed according to EXTENDED def where search is not 
required in a period of 3 months (use uswrkst2) */ 

codebook uswrkst1 uswrkst2
   *Work status during ref. 3-month, market def. (search is not required)
   tab uswrkst1, m  
   *Work status during ref. 3-month, extend def. (search is not required)
   tab uswrkst2, m 

codebook crwrkstsr1 crwrkstsr2  
   *Work status during ref. week, market def. (search required)
   tab crwrkstsr1, m 
   *Work status during ref. week, extend. def. (search required)
   tab crwrkstsr2, m 

codebook uswrkstsr1 uswrkstsr2
   *Work status during ref. 3-month, market def. (search required)
   tab uswrkstsr1, m 
   *Work status during ref. 3-month, extend def. (search required)
   tab uswrkstsr2, m 

codebook crempstp usempstp scempst
   *Employment status in prim job (ref. 1-week)
   tab crempstp, m  
   *Employment status in prim job (ref. 3 months)
   tab usempstp, m  
   *Employment status in secondary job (ref 3-month)
   tab scempst, m  


codebook    yrjob1 job1_m job1_y job1_01 job1_02 job1_03 job1_04 job1_05 job1_06 ///
            job1_07 job1_08 job1_09 job1_10m job1_10y job1_11 job1_12 job1_13 ///
            job1_14m job1_14y job1_15 job1_16dis job1_16g job1_16o_nh job1_17

*drop if uswrkst1 == 3
ren employed employed_2016 

gen employed_3m = 1 if uswrkst2 == 1
replace employed_3m = 0 if uswrkst2 == 2 
replace employed_3m = . if uswrkst2 == 3
tab employed_3m, m 
lab var employed_3m "From uswrkst2 - ext def, search not req; 3 months, 1 empl - 0 unemp, OLF is miss"

gen employed_1w = 1 if uswrkst2 == 1
replace employed_1w = 0 if uswrkst2 == 2 
replace employed_1w = . if uswrkst2 == 3
tab employed_1w, m 
lab var employed_1w "From uswrkst1 - ext def, search not req; 1 week, 1 empl - 0 unemp, OLF is miss"

gen employed_1w_olf = cremp2
lab var employed_1w_olf "From cremp2 - ext def, 1 week, 1 empl - 0 unemp&OLF"
tab employed_1w_olf, m 

gen employed_3m_olf = usemp2
lab var employed_3m_olf "From usemp2 - ext def, 3 months, 1 empl - 0 unemp&OLF"
tab employed_3m_olf, m 

*Job stability in prim. job (ref. 1-week)
tab crstablp, m 
codebook crstablp
gen job_stability_permanent_1w = 1 if crstablp == 1 
replace job_stability_permanent_1w = 0 if crstablp != 1 & !mi(crstablp)
lab var job_stability_permanent_1w "From crstablp - Stability of employement (1w) - 1 permanent - 0 temp, seas, cas"
tab job_stability_permanent_1w, m

*Job stability in prim. job (ref. 3-mnths)
tab usstablp, m 
codebook usstablp
gen job_stability_permanent_3m = 1 if usstablp == 1 
replace job_stability_permanent_3m = 0 if usstablp != 1 & !mi(usstablp)
lab var job_stability_permanent_3m "From usstablp - Stability of employement (3m) - 1 permanent - 0 temp, seas, cas"
tab job_stability_permanent_3m, m



*CPIin17
*crirreg

*EMPLOYEMENT with out of the labor force included 
*(cr = current)

*Employed with mrket definition (ref 1-week)
tab cremp1, m 
*Employed with extend. def. (ref. 1-week)
tab cremp2, m 
*Employed with mrkt. def. (ref. 3-mnths)
tab usemp1, m 
*Employed with ext. definition (ref. 3-mnths)
tab usemp2, m 
*employment status in prim job (ref. 1-week)
tab crempstp, m 

*Economic sector of prim. job (ref. 1-week)
tab crsectrp, m 
*Occup. of crr. jb (4-digit based on ISCO 2008, ref. 1-week)
tab croccupp, m 
*1 digit
tab crocp1d, m 
*2 digit
tab crocp2d, m 
*3 digit
tab crocp3d, m 
*Economic Activity of prim. job (4-digit based on ISIC4, ref. 1-week)
tab crecactp, m 
*1 digit
tab crecac1d, m 
*2 digit
tab crecac2d, m 
*3 digit
tab crecac3d, m 

*WORK PERMIT AUTHORIZED SECORS:  construction, care work, agriculture, manufacturing, and food industry
*Economic activity of crr. job (Sections(1digit), based on ISIC4, ref. 1-week)
tab crecac1d, m
codebook crecac1d
lab list ecac1d
gen wp_industry_jlmps_1w = 0 if !mi(crecac1d)
replace wp_industry_jlmps_1w = 1 if crecac1d == 0 | ///
                                 crecac1d == 2 | ///
                                 crecac1d == 5 | ///
                                 crecac1d == 8 | ///
                                 crecac1d == 16 
tab wp_industry_jlmps_1w, m 
lab var wp_industry_jlmps_1w "Industries with work permits for refugees - Economic Activity of prim. job 1w"

*Economic activity of prim. job (Sections(1digit), based on ISIC4, ref. 3-mnths)
tab usecac1d, m 
codebook usecac1d
lab list ecac1d
gen wp_industry_jlmps_3m = 0 if !mi(usecac1d)
replace wp_industry_jlmps_3m = 1 if usecac1d == 0 | ///
                                 usecac1d == 2 | ///
                                 usecac1d == 5 | ///
                                 usecac1d == 8 | ///
                                 usecac1d == 16 
tab wp_industry_jlmps_3m, m 
lab var wp_industry_jlmps_3m "Industries with work permits for refugees - Economic Activity of prim. job 3m"

*Where are the OLF/UNEMPL ?
tab wp_industry_jlmps_1w uswrkstsr2, m

*Institutional Sector Crr. Job (ref 1-week)
tab crinstsec, m 
*employment status in prim job (ref. 3 months)
tab usempstp, m 
*Economic sector of prim. job (ref. 3-mnths)
tab ussectrp, m 

*Wrk in establish. in primary job (ref. 3-mnths)
tab usestblp, m 

*Occup. of prim. jb (4-digit based on ISCO 2008,ref. 3-mnths)
tab usoccupp, m 
*Occup. of prim. job (1-digit based on ISCO 2008, ref. 3-mnths)
tab usocp1d, m 
*Occup. of prim. job (2-digit based on ISCO 2008, ref. 3-mnths)
tab usocp2d, m 
*Occup. of prim. jb (3-digit based on ISCO 2008,ref. 3-mnths)
tab usocp3d, m 
*Economic activity of prim. job (4-digit, based on ISIC4, ref. 3-mnths)
tab usecactp, m 
*Economic activity of prim. job (Sections(1digit), based on ISIC4, ref. 3-mnths)
tab usecac1d, m 
*Economic activity of prim. job (2-digit, based on ISIC4, ref. 3-mnths)
tab usecac2d, m 
*Economic activity of prim. job (3-digit, based on ISIC4, ref. 3-mnths)
tab usecac3d, m 

*Institutional Sector Prim. Job (ref 3-month)
tab usinstsec, m 


                                 *******************************
                                 ****       INFORMAL        ****
                                 *******************************

*Informal if NO WORK CONTRACT and NO INSURANCE

tab ussocinsp
tab uscontrp
gen informal = 1 if ussocinsp == 0 
replace informal = 1 if uscontrp == 0 
replace informal = 0 if ussocinsp == 1
replace informal = 0 if uscontrp == 1
tab informal, m
lab var informal "1 Informal - 0 Formal - Informal if no contract (uscontrp=0) and no insurance (ussocinsp=0)"
tab informal usemp1

*crr. main job(ref. week) is irregular
tab crirreg, m 
codebook  crirreg
gen job_regular_1w = 1 if crirreg == 0  
replace job_regular_1w = 0 if crirreg == 1
lab var job_regular_1w "From crirreg - Current job (1w) is regular - 1 Yes - 0 No"
tab job_regular_1w, m 

*Usual main job(ref. 3-month) is irregular
tab usirreg, m 
codebook  usirreg
gen job_regular_3m = 1 if usirreg == 0  
replace job_regular_3m = 0 if usirreg == 1
lab var job_regular_3m "From usirreg - Usual job (3m) is regular - 1 Yes - 0 No"

*Incidence of wrk social insurance in prim. job (ref. 1-Week)
tab crsocinsp, m 
ren crsocinsp incidence_soc_insur_1w

*Incidence of wrk contract in prim. job (ref. 1-Week)
tab crcontrp, m 
ren crcontrp incidence_wrk_contract_1w

*Formality of prim. job (ref. 1-Week)
tab crformal, m 
codebook crformal
ren crformal job_formal_1w 
lab var job_formal_1w "Formality of prim. job (ref. 1-Week) - 0 Informal - 1 Formal"

*Incidence of wrk social insurance in prim. job (ref. 3-month)
tab ussocinsp, m 
ren ussocinsp incidence_soc_insur_3m

*Incidence of wrk contract in prim. job (ref. 3-month)
tab uscontrp, m 
ren uscontrp incidence_wrk_contract_3m

*Formality of prim. job (ref. 3-month)
tab usformal, m 
ren usformal job_formal_3m
lab var job_formal_3m "Formality of prim. job (ref. 3-month) - 0 Informal - 1 Formal"

*Check the treatment of OLF
tab uswrkst2 job_stability_permanent_1w, m
tab uswrkst2 job_regular_1w, m
tab uswrkst2 incidence_soc_insur_1w, m
tab uswrkst2 incidence_wrk_contract_1w, m
tab uswrkst2 job_formal_1w, m
tab unempdurmth uswrkst2 , m


                              *******************************
                              ****    UNEMPLOYMENT       ****
                              *******************************

tab unemp2m, m //Unemp1m
tab employed_3m, m

tab unemp2m employed_3m, m
*br * if  unemp2m == 1 & employed_3m  == 1 //Currently unemployed but employed in the last 3 months
*br * if  unemp2m == . & employed_3m  == 1 //Currently out of the labor force but employed in the last 3 months

gen unemployed = unemp2m 
lab var unemployed "From unemp2m - ext def, search not req; 1 week, empl or unemp, OLF is miss"
tab unemployed, m
* UNEMPLOYEMENT

*Current unemployment duration (in months)
tab unempdurmth, m 
*Broad unemployed with mrkt definition (search is not required)
tab unemp1, m 
*Broad unemployed with extend. def. (search is not required)
tab unemp2, m 
*Std. unemployed with mrkt def. (search is required)
tab unempsr1, m
* Std. unemployed with extend. def. (search is required)
tab unempsr2, m 
*Unemployed broad mrk def. (search is not required), with missing if out of labor force 
tab unemp1m, m 
*Unemployed broad ext. def. (search is not required), with missing if out of labor force 
tab unemp2m, m 
* Std. unemployed with mrk. def. (search required), with missing out of the labor 
tab unempsr1m, m 
* Std. unemployed with ext. def. (search required), with missing out of the labor 
tab unempsr2m, m 
*Unempl. worked before, missing if OLF or employed (mkt defn)
tab unwrkevr1, m 
*Unempl. worked before, missing if OLF or employed (ext. defn)
tab unwrkevr2, m 
*If individual is searching for a job
tab search, m 
*Search duration (in months)
tab srchdurmth, m 
*Reason for not searching for a job
tab rsnnosrch, m 
* Available and willing to work?
tab avail, m 
*Has individual ever worked?
tab evrwrk, m 
*Reason out of the labor force
tab rsnolf, m 
*Jobless, Market Definition (Among non-students)
tab jobless1, m 
*Jobless, Extended Definition (Among non-students)
tab jobless2, m 

tab jobless2 employed_3m, m

*Check the treatment of OLF
tab uswrkst2 unemployed , m
tab uswrkst2 jobless2 , m
tab uswrkst2 informal , m


                                 *******************************
                                 ****     DAYS OF WORK      ****
                                 *******************************

*No. of Days/Week (Ref. 1 Week) Market Work
tab crnumdys, m 
ren crnumdys work_days_pweek_1w

*Avg. num. of wrk. days per week during 3 mnth.
tab usnumdys, m 
ren usnumdys work_days_pweek_3m
tab work_days_pweek_3m , m
replace work_days_pweek_3m = . if work_days_pweek_3m == 0


                                 *******************************
                                 ****    HOURS OF WORK      ****
                                 *******************************

*No. of Hours/Day (Ref. 1 Week) Market Work
tab crhrsday, m 
ren crhrsday work_hours_pday_1w
tab work_hours_pday_1w

*Infrastructure use 
*ssc install winsor2
*h winsor2

tab work_hours_pday_1w
su work_hours_pday_1w, d

winsor2 work_hours_pday_1w, s(_w) c(0 98)
su work_hours_pday_1w_w

*No. of Hours/Day (Ref. 3 mnths) Market Work
tab ushrsday, m 
ren ushrsday work_hours_pday_3m
tab work_hours_pday_3m

tab work_hours_pday_1w
su work_hours_pday_3m, d
winsor2 work_hours_pday_3m, s(_w) c(0 98)
su work_hours_pday_3m_w

*Crr. No. of Hours/Week, Market Work, (Ref. 1 Week).
tab crnumhrs1, m 

*Crr. No. of Hours/Week, Market & Subsistence Work, (Ref. 1 Week)
tab crnumhrs2, m 
ren crnumhrs2 work_hours_pweek_1w
tab work_hours_pweek_1w, m 

tab work_hours_pweek_1w
su work_hours_pweek_1w, d
winsor2 work_hours_pweek_1w, s(_w) c(0 98)
su work_hours_pweek_1w_w

*Usual No. of Hours/Week, Market Work, (Ref. 3-month).
tab ushrswk1, m 

*Usual No. of Hours/Week, Market & Subsistence Work, (Ref. 3-month)
tab ushrswk2, m 
ren ushrswk2 work_hours_pweek_3m
tab work_hours_pweek_1w if work_hours_pweek_3m == 0 
tab work_hours_pweek_3m usempstp
replace work_hours_pweek_3m = work_hours_pweek_1w if work_hours_pweek_3m == 0

tab work_hours_pweek_3m
su work_hours_pweek_3m, d
winsor2 work_hours_pweek_3m, s(_w) c(0 98)
su work_hours_pweek_3m_w

tab work_days_pweek_1w uswrkst2, m
tab work_hours_pweek_3m if uswrkst2 == 3, m
tab work_days_pweek_3m uswrkst2, m
tab work_hours_pday_3m if uswrkst2 == 3, m

*Usual No. of Hours in 3 months Market Work (Ref. 3-month)
tab ushrs3mnth, m 

*Average worked hour per month for irregular job
tab avhrspmir, m 
ren avhrspmir work_hours_pmonth_informal
replace work_hours_pmonth_informal = . if work_hours_pmonth_informal == 0 

replace work_hours_pmonth_informal = 672 if work_hours_pmonth_informal > 672 & !mi(work_hours_pmonth_informal)
tab work_hours_pmonth_informal
su work_hours_pmonth_informal, d
winsor2 work_hours_pmonth_informal, s(_w) c(0 98)
su work_hours_pmonth_informal_w


tab work_hours_pmonth_informal informal , m
tab work_hours_pmonth_informal uswrkst2 , m
tab work_hours_pmonth_informal job_formal_3m , m

                                    *******************************
                                    ****       WAGE            ****
                                    *******************************

tab basicwg3, m //Basic Wage
tab basicwg3 uswrkst2
tab ttmonwg3, m //Total Wage

su basicwg3 ttmonwg3

tab scmnthwg if ttmonwg3 == 0
tab wgscj3

         *** WAGE ***

*How wage in the longest main job calc.
tab mtwgdet, m 

*Basic Wage (3-month)
tab basicwg3, m 
ren basicwg3 basic_wage_3m

      *Corrected from inflation
      gen real_basic_wage_3m = basic_wage_3m / CPIin17
      lab var real_basic_wage_3m "CORRECTED INFLATION - Basic Wage (3-month)"

      *LN
      gen ln_basic_rwage_3m = ln(1+real_basic_wage_3m)
      lab var ln_basic_rwage_3m "LOG Basic Wage (3-month)"

      *IHS
      gen IHS_basic_rwage_3m = log(real_basic_wage_3m+((real_basic_wage_3m^2+1)^0.5))
      lab var IHS_basic_rwage_3m "IHS Basic Wage (3-month)"

      *Conditional wage: EMPLOYED ONLY & WAGE ONLY JORDANIANS
      gen ln_basic_rwage_natives_cond = ln_basic_rwage_3m if nationality_cl == 1 & employed_3m == 1 
      lab var ln_basic_rwage_natives_cond "CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING - NATIVES LOG Basic Wage (3m)"

      *Unconditional wage: IF UNEMPLOYED & OLF: WAGE IS 0
      gen ln_basic_rwage_uncond_unolf = ln_basic_rwage_natives_cond if employed_3m_olf  == 1
      replace ln_basic_rwage_uncond_unolf = 0 if employed_3m_olf  == 0
      tab ln_basic_rwage_uncond_unolf
      lab var ln_basic_rwage_uncond_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - NATIVES - LOG - Basic Wage (3-month)"

      *Unconditional wage: IF UNEMPLOYED : WAGE IS 0 / IF OLF: WAGE IS MISSING
      gen ln_basic_rwage_uncond_unemp = ln_basic_rwage_natives_cond if employed_3m == 1
      replace ln_basic_rwage_uncond_unemp = 0 if employed_3m == 0
      replace ln_basic_rwage_uncond_unemp = . if mi(employed_3m) 
      tab ln_basic_rwage_uncond_unemp
      lab var ln_basic_rwage_uncond_unemp "UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - NATIVES LOG Basic (3m)"

*Bonuses and incentives (3-month)
tab bonuses3, m 
*Overtime Wage (3-month)
tab ovrtime3, m 
*Other Wage (3-month)
tab otherwg3, m 
*Profit Sharing (3-month)
tab prftshr3, m 


*Total Wages (3-month)
tab ttmonwg3, m 
ren ttmonwg3 total_wage_3m

tab total_wage_3m

      *Corrected from inflation
      gen real_total_wage_3m = total_wage_3m / CPIin17
      lab var real_total_wage_3m "CORRECTED INFLATION - Total Wage (3-month)"

      *LN
      gen ln_total_rwage_3m = ln(1+real_total_wage_3m)
      lab var ln_total_rwage_3m "LOG Total Wage (3-month)"

      *IHS
      gen IHS_total_rwage_3m = log(real_total_wage_3m+((real_total_wage_3m^2+1)^0.5))
      lab var IHS_total_rwage_3m "IHS Total Wage (3-month)"

      *Conditional wage: EMPLOYED ONLY & WAGE ONLY JORDANIANS
      gen ln_total_rwage_natives_cond = ln_total_rwage_3m if nationality_cl == 1  & employed_3m == 1 
      lab var ln_total_rwage_natives_cond "CONDITIONAL - UNEMPLOYED & OLF: WAGE MISSING - NATIVES LOG Total Wage (3m)"

      *Unconditional wage: IF UNEMPLOYED & OLF: WAGE IS 0
      gen ln_total_rwage_uncond_unolf = ln_total_rwage_natives_cond if employed_3m_olf  == 1
      replace ln_total_rwage_uncond_unolf = 0 if employed_3m_olf  == 0
      tab ln_total_rwage_uncond_unolf
      lab var ln_total_rwage_uncond_unolf "UNCONDITIONAL - UNEMPLOYED & OLF: WAGE 0 - NATIVES - LOG - Total Wage (3-month)"

      *Unconditional wage: IF UNEMPLOYED : WAGE IS 0 / IF OLF: WAGE IS MISSING
      gen ln_total_rwage_uncond_unemp = ln_total_rwage_natives_cond if employed_3m == 1
      replace ln_total_rwage_uncond_unemp = 0 if employed_3m == 0
      replace ln_total_rwage_uncond_unemp = . if mi(employed_3m) 
      tab ln_total_rwage_uncond_unemp
      lab var ln_total_rwage_uncond_unemp "UNCONDITIONAL - UNEMPLOYED WAGE 0 / OLF WAGE MISSING - NATIVES LOG Total (3m)"


         *** PRIMARY ***

*Monthly Wage (Primary Job)
tab mnthwg, m 
*Hourly Wage (Primary Job)
tab hrwg, m 

         *** SECONDARY ***

*Secondary job hourly wage
tab schrw, m 
*Secondary job monthly wage
tab scmnthwg, m 

         *** PRIMARY & SECONDARY ***

*Monthly Wage (Prim.& Second. Jobs)
tab mnthwgAllJob, m 
su mnthwgAllJob 

ren mnthwgAllJob mthly_wage 
lab var mthly_wage "Monthly Wage (Prim.& Second. Jobs)"

tab mthly_wage

      *Corrected from inflation
      gen real_mthly_wage = mthly_wage / CPIin17
      lab var real_mthly_wage "CORRECTED INFLATION - Monthly Wage (Prim.& Second. Jobs)"

      *LOG
      gen ln_mthly_rwage = ln(1+real_mthly_wage)
      lab var ln_mthly_rwage "LOG Monthly Wage (Prim.& Second. Jobs)"


*Hourly Wage (Prim.& Second. Jobs)
tab hrwgAllJob, m 
su hrwgAllJob, d 
ren hrwgAllJob hourly_wage 
lab var hourly_wage "Hourly Wage (Prim.& Second. Jobs)"

tab hourly_wage
su hourly_wage
su hourly_wage if hourly_wage < `r(max)'
return list
replace hourly_wage = `r(mean)' if hourly_wage > `r(max)' & !mi(hourly_wage)

      *Corrected from inflation
      gen real_hourly_wage = hourly_wage / CPIin17
      lab var real_hourly_wage "CORRECTED INFLATION - Hourly Wage (Prim.& Second. Jobs)"

      *LOG
      gen ln_hourly_rwage = ln(1+real_hourly_wage)
      lab var ln_hourly_rwage "LOG Hourly Wage (Prim.& Second. Jobs)"

         *** IRREGULAR ***

*Average Daily Wage (Irregular Workers)
tab avdwirmn, m 
ren avdwirmn daily_wage_irregular

tab daily_wage_irregular
su daily_wage_irregular
su daily_wage_irregular if daily_wage_irregular < `r(max)'
return list
replace daily_wage_irregular = `r(mean)' if daily_wage_irregular > `r(max)' & !mi(daily_wage_irregular)

      *Corrected from inflation
      gen real_daily_wage_irregular = daily_wage_irregular / CPIin17
      lab var real_daily_wage_irregular "CORRECTED INFLATION - Average Daily Wage (Irregular Workers)"

      *LOG
      gen ln_daily_rwage_irregular = ln(1 + real_daily_wage_irregular)
      lab var ln_daily_rwage_irregular "LOG Average Daily Wage (Irregular Workers)"


                                    *******************************
                                    ****       UNION           ****
                                    *******************************

*Member of a syndicate/trade union (ref. 3-mnths)
tab unionont
ren unionont member_union_3m

                                    *******************************
                                    ****       SKILLS          ****
                                    *******************************

codebook skilreq edreq skillev 
*Does primary job require any skill
tab skilreq 
ren skilreq skills_required_pjob 

*Minimum education requirements for job
tab edreq 

*The level of his skill
tab skillev

                                    *******************************
                                    ****       CONTRACT        ****
                                    *******************************

codebook job1_01 job1_07 job1_08 job1_09
*Employment status - Job 01
tab job1_01
*Degree of stability - Job 01
tab job1_07
gen stability_main_job = 1 if job1_07 == 1 
replace stability_main_job = 0 if job1_07 != 1 & !mi(job1_07)
lab var stability_main_job "From job1_07 : Degree of stability - Job 01 - 1 Stable"

*Type of work contract - Job 01
tab job1_08
gen permanent_contract = 1 if job1_08 == 1 
replace permanent_contract = 0 if job1_08 == 2 | job1_08 == 3
lab var permanent_contract "From job1_08 : Type of work contract - Job 01 - 1 Permanent"

******WEIGHTS*******
*expan_Hh 
*expan_ref_hh
*expan_indiv
*expan_ref_indiv

codebook hhid
destring hhid, replace
codebook indid
destring indid, replace 

*save "$data_final/06_IV_JLMPS_Regression.dta", replace
save "$data_final/06_IV_JLMPS_Construct_Outcomes.dta", replace
