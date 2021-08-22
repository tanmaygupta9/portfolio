/*
*****************************************************************************

* This do-file runs all difference-in-difference and triple difference models for employment 

In particular, it performs the analysis for Tables 4 and 5 of the paper

Note: Standard errors are clustered at state level throughout

*****************************************************************************
*/



cd "/Users/tanmaygupta/Dropbox/Spring 2021/ECMA 31320/Project/project_work" 


use "employment/emp_panel.dta", clear 

*States in consideration
//only run conditional on inc == 1
gen inc = (state == "bihar"|state == "uttar pradesh"|state == "jharkhand"|state == "uttarakhand"|state == "haryana"|state == "punjab"|state == "rajasthan"|state == "chhattisgarh"|state == "madhya pradesh"|state == "gujarat"|state == "maharashtra")


foreach var in total_emp services manufacturing { 
	gen log_`var' = log(1 + (`var'/pca_tot_p))
}


keep if inc == 1 

gen did = (state == "bihar" & year >= 2006)



gl controls "pca_tot_p vd_area vd_tar_road pca_p_sc pca_p_st pca_p_lit"


//labelling variables 

label var log_total_emp "Total Emp."
label var log_manufacturing "Manufacturing" 
label var log_services "Services" 
*label var loglit "Literacy"

label variable did "Bihar Post-2006"
label variable pca_tot_p "Population" 
label variable vd_area "Area" 
label variable vd_tar_road "Tar road" 
label variable pca_p_sc "SC" 
label variable pca_p_st "ST"
label variable pca_p_lit "Literate"


******* difference-in-differences (Table 4) *****

eststo clear 

//total employment 

 
xi: reg log_total_emp i.state i.year $controls did, robust cluster(state) 

eststo emp



//services 
xi: reg log_services i.state i.year $controls did, robust cluster(state) 
est sto emp_services


//manufacturing
xi: reg log_manufacturing i.state i.year $controls did, robust cluster(state) 

est sto emp_manuf 

//literacy rate 
use "census panel/census_panel.dta", clear 

gen inc = (state == "bihar"|state == "uttar pradesh"|state == "jharkhand"|state == "uttarakhand"|state == "haryana"|state == "punjab"|state == "rajasthan"|state == "chhattisgarh"|state == "madhya pradesh"|state == "gujarat"|state == "maharashtra")



gen loglit = log(1 + (lit/pop)) 
gen did = (state == "bihar" & year >= 2006)

keep if inc == 1 

gl controls2 "pop area tar_road sc st emp_rate"


xi: reg loglit i.state i.year $controls2 did, robust cluster(state)
est sto lit 



//generate tex table 
esttab emp emp_services emp_manuf lit using "tables/emp_did.txt", se(3) replace label b(3) keep(did $controls) order(did $controls) constant nogaps stats(r_squared N, fmt(3 0)) fragment tex 





******* Triple-differences (Table 5) *********

*1. development vars 

sort shrid year  
by shrid: gen power_all_01 = (vd_power_all[2] == 1)
by shrid: gen power_agri_01 = (vd_power_agr[2] == 1)
by shrid: gen tar_road_01 = (vd_tar_road[2] == 1)



gen elec_all_did = did*power_all_01
gen elec_agri_did = did*power_agri_01
gen tar_road_did = did*tar_road_01 


destring state_id, replace 

reg log_total_emp i.state_id i.year power_all_01#i.state_id power_all_01#i.year i.year#i.state_id elec_all_did, robust cluster(state_id)
reg log_manufacturing i.state_id i.year power_all_01#i.state_id power_all_01#i.year i.year#i.state_id elec_all_did, robust cluster(state_id)
reg log_services i.state_id i.year power_all_01#i.state_id power_all_01#i.year i.year#i.state_id elec_all_did, robust cluster(state_id)


reg loglit i.state_id i.year power_all_01#i.state_id power_all_01#i.year i.year#i.state_id elec_all_did, robust cluster(state_id)




reg log_total_emp i.state_id i.year power_agri_01#i.state_id power_agri_01#i.year i.year#i.state_id elec_agri_did, robust cluster(state_id)
reg log_manufacturing i.state_id i.year power_agri_01#i.state_id power_agri_01#i.year i.year#i.state_id elec_agri_did, robust cluster(state_id)
reg log_services i.state_id i.year power_agri_01#i.state_id power_agri_01#i.year i.year#i.state_id elec_agri_did, robust cluster(state_id)
reg loglit i.state_id i.year power_agri_01#i.state_id power_agri_01#i.year i.year#i.state_id elec_agri_did, robust cluster(state_id)





reg log_total_emp i.state_id i.year tar_road_01#i.state_id tar_road_01#i.year i.year#i.state_id tar_road_did, robust cluster(state_id)
reg log_manufacturing i.state_id i.year tar_road_01#i.state_id tar_road_01#i.year i.year#i.state_id tar_road_did, robust cluster(state_id)
reg log_services i.state_id i.year tar_road_01#i.state_id tar_road_01#i.year i.year#i.state_id tar_road_did, robust cluster(state_id)
reg loglit i.state_id i.year tar_road_01#i.state_id tar_road_01#i.year i.year#i.state_id tar_road_did, robust cluster(state_id)



*2. Village vars 
gen pop_did = did*pca_tot_p 
gen area_did = did*vd_area
gen rural_did = did*(pca_tot_p_r/pca_tot_p)
gen sc_did = did*(pca_p_sc/pca_tot_p)
gen st_did = did*(pca_p_st/pca_tot_p)

gen rural_prop = pca_tot_p_r/pca_tot_p
gen sc_prop = pca_p_sc/pca_tot_p
gen st_prop = pca_p_st/pca_tot_p


foreach var in log_total_emp log_manufacturing log_services {
	reg `var' i.state_id i.year c.pca_tot_p#i.state_id c.pca_tot_p#i.year i.year#i.state_id pop_did, robust cluster(state_id)	
}

foreach var in log_total_emp log_manufacturing log_services {
	reg `var' i.state_id i.year c.area#i.state_id c.area#i.year i.year#i.state_id area_did, robust cluster(state_id)	
}

foreach var in log_total_emp log_manufacturing log_services loglit {
	reg `var' i.state_id i.year c.rural_prop#i.state_id c.rural_prop#i.year i.year#i.state_id rural_did, robust cluster(state_id)	
}

foreach var in log_total_emp log_manufacturing log_services{
	reg `var' i.state_id i.year c.sc_prop#i.state_id c.sc_prop#i.year i.year#i.state_id sc_did, robust cluster(state_id)	
}

foreach var in log_total_emp log_manufacturing log_services  {
	reg `var' i.state_id i.year c.st_prop#i.state_id c.st_prop#i.year i.year#i.state_id st_did, robust cluster(state_id)	
}

