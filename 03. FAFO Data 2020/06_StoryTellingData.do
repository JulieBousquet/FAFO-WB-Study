
*Storytelling with data


use "$data_2020_temp/Jordan2020_03_Compared.dta", clear


********************
*** SCATTER PLOT ***
********************

*Scatter Plot between Income and Age
twoway (scatter rsi_wage_income_lm_cont QR101)

twoway (scatter rsi_wage_income_lm_cont rsi_work_permit)

***************************
*** KERNEL DISTRIBUTION ***
***************************

twoway (kdensity rsi_wage_income_lm_cont)


*********************
*** QUANTILE PLOT ***
*********************

tab rsi_wage_income_lm_cont

foreach q of numlist 10(10)90 {
	bootstrap, reps(100) cluster(district_en) seed(20200317) nowarn: qreg rsi_wage_income_lm_cont rsi_work_permit, q(`q') 
}

* Horizontal lines (bold dashed) represent OLS estimates with 95% confidence intervals (dotes dashed).
grqreg rsi_wage_income_lm_cont, ci ols olsci  ///
	 level(90) title() title("Treatment Effect on Wage Income") format(%12.0g) 

*Show what part of the distribution in income have a valie work permit
graph export "$out/stwd_Wage_Income.pdf", as(pdf) replace


************************
*** LOGIT REGRESSION ***
************************

***** DETERMINANT OF GETTING A WORK PERMIT 
preserve

keep if refugee == 1
logit rsi_work_permit ///
        ros_employed  ///
        rsi_wage_income_lm_cont ///
        rsi_work_hours_m ///
        
restore
	
	*Settings
	tab refugee
	codebook refugee
	drop if refugee == 3
	
	lab var rsi_wage_income_lm_cont "Wage Income (JD)"
	lab var rsi_work_hours_m "Work Hours"
	lab var ros_employed "Employed"
	* Here we put the key variable as dependent variable in the regression
	local var_reg 	rsi_wage_income_lm_cont rsi_work_hours_m 
				
	foreach var of local var_reg {
		reg `var' i.ros_employed##i.refugee, cluster(district_en) 
		margins refugee, at(ros_employed=(0 1))
		marginsplot , xlab(0 1) plotopts(lw(thick)) ///
			ytitle("") ciopts(lc(gray) lw(thin)) ///
			plot1opts(lc(cranberry) lp(solid) 			mlc(cranberry) 	ms(huge) mfc(white)) ///
			plot2opts(lc(sand) 		lp(dash) 			mlc(sand) 		ms(huge) mfc(sand)) ///
			title("`: variable label `var''") name(`var'_btsp, replace) 
		} 
			graph close 
*It is easy to tell from this table that as the value of read increases the probability of 
*honors being a one is also increasing from a probability of 0.002 to a probability of 0.75.

		grc1leg2 	rsi_wage_income_lm_cont_btsp ///
					rsi_work_hours_m_btsp ///
		, cols(2) ///
		legendfrom(rsi_work_hours_m_btsp) ///
		position(12) ///
		title("Regression Analysis, clustered by district") 	

		graph export 	"$out/stwd_margin_graph.png", width(4000) replace


/*
What could be improved: 
(1) The legend could not have the frame. 
(2) The scales are different. They both start at 0, but represent different 
variables/scales. I could try to start both at 0 and make sure I explain
orally.
(3) Since the graph is not self-explanatory, maybe I could add a text to explain
what is the most important, or where to look at. For instance, the most important
here is the comparison between refugees and hosts, so the right side of both graph. 
I would like you to know that "Being an employed refugee, decrease the work hours by 
3h, compared with being an employed native."
*/
