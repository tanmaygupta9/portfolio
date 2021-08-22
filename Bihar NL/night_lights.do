/*
*****************************************************************************

* This do-file runs all difference-in-difference and triple difference models for night lights 

In particular, it performs the analysis for Tables 2 and 3 of the paper

Note: Standard errors are clustered at state level throughout

*****************************************************************************
*/




cd "/Users/tanmaygupta/Dropbox/Spring 2021/ECMA 31320/Project/project_work/nightlights" 

use "nightlights_panel.dta", clear 



gen did = (state == "bihar" & year >= 2006) 

gen prop_sc = pca_p_sc/pca_tot_p
gen prop_st = pca_p_st/pca_tot_p
gen prop_lit = pca_p_lit/pca_tot_p




*****************************Diff-in-diff: Table 2*************************
gl controls "pca_tot_p vd_area vd_tar_road pca_p_sc pca_p_lit pca_p_st emp_rate"
gl fe "i.state i.year"


//no interaction 
xi: reg lpnl did $fe $controls, robust cluster(state)
est sto nl1  

gen emp_did = emp_rate*did
xi: reg lpnl did $fe $controls emp_did, robust cluster(state) 
eststo nl2 


//with interaction terms

gl all_interactions "emp_did elec_all_did elec_agri_did tar_road_did pop_did area_did rural_did sc_did st_did lit_did"

*just emp 
xi: reg lpnl did $fe $controls emp_did, robust cluster(state) 

*all 
xi: reg lpnl did $fe $controls $interactions, robust cluster(state) 



***************************** Triple-differences: Table 3 *****************************


//non-farm employment 


destring state_id, replace 
reg lpnl i.state_id i.year c.emp_rate#i.state_id c.emp_rate#i.year i.year#i.state_id emp_did, robust cluster(state_id)

//development -- proxied for by electricity and road availability (a good proxy in India)

gen elec_all_did = did*vd_power_all
gen elec_agri_did = did*vd_power_agr
gen tar_road_did = did*vd_tar_road

//neg
reg lpnl i.state_id i.year vd_power_all#i.state_id vd_power_all#i.year i.year#i.state_id elec_all_did, robust cluster(state_id)

//pos
reg lpnl i.state_id i.year vd_power_agr#i.state_id vd_power_agr#i.year i.year#i.state_id elec_agri_did, robust cluster(state_id)

//pos 
reg lpnl i.state_id i.year vd_tar_road#i.state_id vd_tar_road#i.year i.year#i.state_id tar_road_did, robust cluster(state_id)


//village characteristics: population, area, how rural/urban it is, social factors: SC/ST, literacy rate

gen prop_rural = pca_tot_p_r/pca_tot_p
//gen prop_sc = pca_p_sc/pca_tot_p 
//gen prop_st = pca_p_st/pca_tot_p 
//gen prop_lit = pca_p_lit/pca_tot_p 

gen pop_did = did*pca_tot_p 
gen area_did = did*vd_area 
gen rural_did = did*prop_rural 
gen sc_did = did*prop_sc 
gen st_did = did*prop_st 
gen lit_did = did*prop_lit 

reg lpnl i.state_id i.year c.pca_tot_p#i.state_id c.pca_tot_p#i.year i.year#i.state_id pop_did, robust cluster(state_id)

reg lpnl i.state_id i.year c.vd_area#i.state_id c.vd_area#i.year i.year#i.state_id area_did, robust cluster(state_id)

reg lpnl i.state_id i.year c.prop_rural#i.state_id c.prop_rural#i.year i.year#i.state_id rural_did, robust cluster(state_id)

reg lpnl i.state_id i.year c.prop_sc#i.state_id c.prop_sc#i.year i.year#i.state_id sc_did, robust cluster(state_id)

reg lpnl i.state_id i.year c.prop_st#i.state_id c.prop_st#i.year i.year#i.state_id st_did, robust cluster(state_id)

reg lpnl i.state_id i.year c.prop_lit#i.state_id c.prop_lit#i.year i.year#i.state_id lit_did, robust cluster(state_id)
















 





