//The following do file is used to allocate parcel, farm, and capital equipment ownership to individual members of a household and covert the data into parcel level, farm level, and household level.

set seed 123456789

. use "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\s01_me_sen2021.dta", clear


* Ensure variables are numeric and padded appropriately
gen str3 gpad = string(grappe, "%03.0f")
gen str3 mpad = string(menage, "%03.0f")

* Concatenate them into a single string
gen str6 hh_str     = gpad + mpad
* Convert to numeric (double to handle large numbers)
gen double hh_id     = real(hh_str)
drop gpad mpad hh_str

. save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\s01_me_sen2021_final.dta", replace

********************************************************************
  use "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\s19_me_sen2021_final.dta", clear

 keep if s19q03==1  | s19q13!=.

 replace s19q06__0=1 if s19q06__0==.
 ren s19q06__0 membres__id
 save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\s19_me_sen2021_final1.dta", replace
 
*****************************************************************
. use "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\s16a_me_sen2021_final.dta", clear

replace parcel_owner = 1 if parcel_owner==. & s16aq05==2
ren parcel_owner membres__id

 merge m:1 hh_id membres__id using "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\s01_me_sen2021_final.dta"
//drop if _merge==1
 drop _merge
 merge m:m hh_id membres__id using "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\s19_me_sen2021_final1.dta"

keep if farm_area!=. | s19q13!=.
drop _merge
gen rental_rate_equip= s19q13/hh_farm_area if (s19q13>0 & s19q13!=. )
egen rental_rate_equip_mean = mean(rental_rate_equip),by (s19q02)
gen capital_cost_hh=s19q13
replace capital_cost_hh=rental_rate_equip_mean*hh_farm_area if s19q03==1 //& (s19q13==0 | s19q13==.) 
replace capital_cost_hh=s19q09 if  s19q02==126 |  s19q02==136 |  s19q02==137 |  s19q02==139
egen hh_capital_cost= total(capital_cost_hh),by (hh_id)
gen capital_cost_ph=hh_capital_cost/hh_farm_area


gen capital_cost_farm=s19q13
replace capital_cost_farm=rental_rate_equip_mean*farm_area if s19q03==1 //& (s19q13==0 | s19q13==.) 
replace capital_cost_farm=s19q09 if  s19q02==126 |  s19q02==136 |  s19q02==137 |  s19q02==139
egen farm_capital_cost= total(capital_cost_farm),by (farm_id)
gen farm_capital_cost_ph=capital_cost_farm/farm_area


gen capital_cost_parcel=s19q13
replace capital_cost_parcel=rental_rate_equip_mean*parcel_area if s19q03==1 //& (s19q13==0 | s19q13==.) 
replace capital_cost_parcel=s19q09 if  s19q02==126 |  s19q02==136 |  s19q02==137 |  s19q02==139
egen parcel_capital_cost= total(capital_cost_parcel),by (parcel_id)
gen parcel_capital_cost_ph=capital_cost_parcel/parcel_area

*****************
merge m:1 hh_id using "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\s16b_me_sen2021_final.dta"

keep if _merge==3
drop _merge

//replace s19q09= s19q13 if s19q09==.
//egen capital_asset= total(s19q09 ),by (hh_id)
//gen capital_asset_ph=capital_asset/hh_farm_area
sum farm_area parcel_area hh_farm_area


// farm size category

. save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\s19_me_sen2021_final2.dta", replace

duplicates drop parcel_id, force


/********************************************/
gen			farmsizeclass1 = . 
		replace		farmsizeclass1 = 1 if parcel_area>=0.01 & parcel_area<=1
		replace		farmsizeclass1 = 2 if parcel_area>1 & parcel_area<=2
		replace		farmsizeclass1 = 3 if parcel_area>2 & parcel_area<=5
		replace		farmsizeclass1 = 4 if parcel_area>5 & parcel_area!=.
		lab			def farmsizeclass1 1 "0.01-1 ha" 2 "1-2 ha" 3 "2-5 ha" 4 ">5 ha"
		lab			val farmsizeclass1 farmsizeclass1
		
gen			farmsizeclass1b = . 
		replace		farmsizeclass1b = 1 if parcel_area>=0.01 & parcel_area<=1
		replace		farmsizeclass1b = 2 if parcel_area>1 & parcel_area<=2
		replace		farmsizeclass1b = 3 if parcel_area>2 & parcel_area<=5
		replace		farmsizeclass1b = 4 if parcel_area>5 & parcel_area<100
		lab			def farmsizeclass1b 1 "0.01-1 ha" 2 "1-2 ha" 3 "2-5 ha" 4 ">5 ha"
		lab			val farmsizeclass1b farmsizeclass1b
		
gen			farmsizeclass2 = . 
		replace		farmsizeclass2 = 1 if parcel_area>=0.01 & parcel_area<=1
		replace		farmsizeclass2 = 2 if parcel_area>1 & parcel_area<=2
		replace		farmsizeclass2 = 3 if parcel_area>2 & parcel_area<=5
		replace		farmsizeclass2 = 4 if parcel_area>5 & parcel_area<=20
		replace		farmsizeclass2 = 5 if parcel_area>20 & parcel_area!=.
	lab			def farmsizeclass2 1 "0.01-1 ha" 2 "1-2 ha" 3 "2-5 ha" 4 "5-20 ha" 5 ">20 ha"
	lab			val farmsizeclass2 farmsizeclass2

gen			farmsizeclass2b = . 
		replace		farmsizeclass2b = 1 if parcel_area>=0.01 & parcel_area<=1
		replace		farmsizeclass2b = 2 if parcel_area>1 & parcel_area<=2
		replace		farmsizeclass2b = 3 if parcel_area>2 & parcel_area<=5
		replace		farmsizeclass2b = 4 if parcel_area>5 & parcel_area<=20
		replace		farmsizeclass2b = 5 if parcel_area>20 & parcel_area<100
	lab			def farmsizeclass2b 1 "0.01-1 ha" 2 "1-2 ha" 3 "2-5 ha" 4 "5-20 ha" 5 ">20 ha"
	lab			val farmsizeclass2b farmsizeclass2b
	
		
gen			farmsizeclass3 = . 
		replace		farmsizeclass3 = 1 if parcel_area>=0.01 & parcel_area<=1
		replace		farmsizeclass3 = 2 if parcel_area>1 & parcel_area<=2
		replace		farmsizeclass3= 3 if parcel_area>2 & parcel_area<=4
		replace		farmsizeclass3 = 4 if parcel_area>4 & parcel_area<=10
		replace		farmsizeclass3 = 5 if parcel_area>10 & parcel_area!=.
		lab			def farmsizeclass3 1 "0.01-1 ha" 2 "1-2 ha" 3 "2-4 ha" 4 "4-10 ha" 5 ">10 ha"
		lab			val farmsizeclass3 farmsizeclass3
		
gen			farmsizeclass3b = . 
		replace		farmsizeclass3b = 1 if parcel_area>=0.01 & parcel_area<=1
		replace		farmsizeclass3b = 2 if parcel_area>1 & parcel_area<=2
		replace		farmsizeclass3b= 3 if parcel_area>2 & parcel_area<=4
		replace		farmsizeclass3b = 4 if parcel_area>4 & parcel_area<=10
		replace		farmsizeclass3b = 5 if parcel_area>10 & parcel_area<100
		lab			def farmsizeclass3b 1 "0.01-1 ha" 2 "1-2 ha" 3 "2-4 ha" 4 "4-10 ha" 5 ">10 ha"
		lab			val farmsizeclass3b farmsizeclass3b
				
/************************************************/
gen     parcel_farm_size =1 if parcel_area>1.162 
replace parcel_farm_size =0 if parcel_area<=1.162 & parcel_area>0.01
replace parcel_farm_size =2 if parcel_area<0.01
label define farm_size 0 "small farms" 1 "large farms" 2 "outliers"
label values parcel_farm_size farm_size

graph pie, over(parcel_farm_size) plabel(_all percent) title("Parcel farm size")

//graph pie, over(farmsizeclass) plabel(_all percent) title("Parcel farm size")

. save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\parcel_level_data.dta", replace

duplicates drop farm_id, force

gen     farm_farm_size =1 if farm_area>1.85
replace farm_farm_size =0 if farm_area<=1.85 & farm_area>0.002
replace farm_farm_size =2 if farm_area<0.002
*label define farm_size1 0 "small farms" 1 "large farms" 2 "outliers"
label values farm_farm_size farm_size

graph pie, over(farm_farm_size) plabel(_all percent) title(" farm farm size")


. save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14farm_level_data.dta", replace


duplicates drop hh_id, force

gen     hh_farm_size =1 if hh_farm_area>3.74
replace hh_farm_size =0 if hh_farm_area<=3.74 & hh_farm_area>0.008
replace hh_farm_size =2 if hh_farm_area<0.008
*label define farm_size2 0 "small farms" 1 "large farms" 2 "outliers"
label values hh_farm_size farm_size

graph pie, over(hh_farm_size) plabel(_all percent) title(" household farm size")

. save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\hh_level_data.dta", replace

 
 // calcul labor and capital intensity by household
 
 
egen family_lab_sowing= rsum(s16aq33b_1 s16aq33b_2 s16aq33b_3 s16aq33b_4 s16aq33b_5 s16aq33b_6 s16aq33b_7 s16aq33b_8 s16aq33b_9 s16aq33b_10 s16aq33b_11 s16aq33b_12 s16aq33b_13 s16aq33b_14 s16aq33b_15 s16aq33b_16 s16aq33b_17 s16aq33b_18 s16aq33b_19 s16aq33b_20 s16aq33b_21 s16aq33b_22 s16aq33b_23 s16aq33b_24)

egen family_lab_maint= rsum(s16aq35b_1 s16aq35a_1 s16aq35b_2 s16aq35a_2 s16aq35b_3 s16aq35a_3 s16aq35b_4 s16aq35a_4 s16aq35b_5 s16aq35a_5 s16aq35b_6 s16aq35a_6 s16aq35b_7 s16aq35a_7 s16aq35b_8 s16aq35a_8 s16aq35b_9 s16aq35a_9 s16aq35b_10 s16aq35a_10 s16aq35b_11 s16aq35a_11 s16aq35b_12 s16aq35a_12 s16aq35b_13 s16aq35a_13 s16aq35b_14 s16aq35a_14 s16aq35b_15 s16aq35a_15 s16aq35b_16 s16aq35a_16 s16aq35b_17 s16aq35a_17 s16aq35b_18 s16aq35a_18 s16aq35b_19 s16aq35a_19 s16aq35b_20 s16aq35a_20 s16aq35b_21 s16aq35a_21 s16aq35b_22 s16aq35a_22 s16aq35b_23 s16aq35a_23 s16aq35b_24 s16aq35a_24 s16aq35b_25 s16aq35a_25 s16aq35b_26 s16aq35a_26 s16aq35b_27 s16aq35a_27 s16aq35b_28 s16aq35a_28)

replace s16aq37b_1=. if s16aq37b_1==9999
egen family_lab_harvest= rsum(s16aq37b_1 s16aq37b_2 s16aq37b_3 s16aq37b_4 s16aq37b_5 s16aq37b_6 s16aq37b_7 s16aq37b_8 s16aq37b_9 s16aq37b_10 s16aq37b_11 s16aq37b_12 s16aq37b_13 s16aq37b_14 s16aq37b_15 s16aq37b_16 s16aq37b_17 s16aq37b_18 s16aq37b_19 s16aq37b_20 s16aq37b_21 s16aq37b_22 s16aq37b_23 s16aq37b_24 s16aq37b_25 s16aq37b_26 s16aq37b_27 s16aq37b_28 s16aq37b_29 s16aq37b_30 s16aq37b_31 s16aq37b_32 s16aq37b_33)

egen family_labor_all=rsum(family_lab_sowing family_lab_maint family_lab_harvest)
***************************************************************
gen paid_man_day_sowing   = s16aq39a_1*s16aq39b_1
gen paid_woman_day_sowing = s16aq39a_2*s16aq39b_2
gen paid_boys_day_sowing  = s16aq39a_3*s16aq39b_3
gen paid_girls_day_sowing = s16aq39a_4*s16aq39b_4

egen paid_all_day_sowing  = rsum(paid_man_day_sowing paid_woman_day_sowing paid_boys_day_sowing paid_girls_day_sowing)

gen paid_man_day_maint   = s16aq41a_1*s16aq41b_1
gen paid_woman_day_maint = s16aq41a_2*s16aq41b_2
gen paid_boys_day_maint  = s16aq41a_3*s16aq41b_3
gen paid_girls_day_maint = s16aq41a_4*s16aq41b_4

egen paid_all_day_maint  = rsum(paid_man_day_maint paid_woman_day_maint paid_boys_day_maint paid_girls_day_maint)

gen paid_man_day_harvest   = s16aq43a_1*s16aq43b_1
gen paid_woman_day_harvest = s16aq43a_2*s16aq43b_2
gen paid_boys_day_harvest  = s16aq43a_3*s16aq43b_3
gen paid_girls_day_harvest = s16aq43a_4*s16aq43b_4

egen paid_all_day_harvest  = rsum(paid_man_day_harvest paid_woman_day_harvest paid_boys_day_harvest paid_girls_day_harvest)

egen pail_labor_all= rsum(paid_all_day_sowing paid_all_day_maint paid_all_day_harvest)
egen parcel_labor_all = rsum (family_labor_all pail_labor_all)
 
egen hh_farm_labor_all = total (parcel_labor_all),by (hh_id)

gen labor_intensity=hh_farm_labor_all/hh_farm_area
gen capital_intensity= capital_cost_ph

tabstat labor_intensity capital_intensity, by(hh_farm_size)
 
graph bar labor_intensity if hh_farm_size!=2, over(hh_farm_size) blabel(bar, size(small)) title("Labor intensity by household farm size",size(small)) name(graph1, replace)
 
graph bar capital_intensity if hh_farm_size!=2, over(hh_farm_size) blabel(bar, size(small)) title("Capital intensity by household farm size", size(small)) name(graph2, replace)

graph combine graph1 graph2
 

merge 1:m hh_id using "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\s16c_me_sen2021_final.dta"

keep if _merge==3
drop _merge  


save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\hh_agri.dta", replace


reorder hh_id farm_id parcel_id membres__id

// estimate pourcentage each crops by household farm size

graph hbar (percent) if hh_farm_size!=2, over(hh_farm_size) blabel(bar, size(vsmall) pos(center) format(%3.1f)) over(crops, sort(1) descending label(labsize(vsmall))) stack asyvars percentage  title("Percentage crops by household farm size", size(small))



/*

// examine the capital and labour intensities of various crops grown by small and large farms

graph hbar capital_intensity if hh_farm_size!=2, by(hh_farm_size) over(crops, label(labsize(vsmall)))  title("Capital Intensity by Crop and Farm Size", size(vmall)) //stack asyvars pas bon

graph hbar labor_intensity if hh_farm_size!=2, by(hh_farm_size) over(crops, label(labsize(vsmall)))  title("labor Intensity by Crop and Farm Size", size(vmall)) //stack asyvars pas bon 

// calculate the various crops' productivity and associate it with farm size

ren s16cq16c production 
drop if production==.

gen productivity = production/parcel_area  // revoir en terme monétaire 

su productivity

gen labor_productivity = production/labor_intensity // pas avec labor intensity mais plutot avec labor all 
gen capital_productivity= production/capital_intensity

su labor_productivity capital_productivity productivity

tabstat productivity, by(crops) stats(mean sd n)

graph bar productivity if hh_farm_size!=2, over(hh_farm_size)
graph bar labor_productivity if hh_farm_size!=2, over(hh_farm_size)
graph bar capital_productivity if hh_farm_size!=2, over(hh_farm_size)

graph hbar productivity if hh_farm_size!=2, by(hh_farm_size) over(crops, label(labsize(vsmall)))  //title("labor Intensity by Crop and Farm Size", size(vmall)) //stack asyvars

// some regressions

reg productivity hh_farm_area if hh_farm_size!=2

reg productivity i.hh_farm_size if hh_farm_size!=2
*/
save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\hh_dataset_final.dta", replace

 
 
/////////////////////////////////////////////////////////////////////////////////////
///////////// 
////////////                        FARM LEVEL               ////////////////////////   
////////////   
//////////////////////////////////////////////////////////////////////////////////////

use "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\farm_level_data.dta", clear

// calcul labor and capital intensity by household
 
 
egen family_lab_sowing= rsum(s16aq33b_1 s16aq33b_2 s16aq33b_3 s16aq33b_4 s16aq33b_5 s16aq33b_6 s16aq33b_7 s16aq33b_8 s16aq33b_9 s16aq33b_10 s16aq33b_11 s16aq33b_12 s16aq33b_13 s16aq33b_14 s16aq33b_15 s16aq33b_16 s16aq33b_17 s16aq33b_18 s16aq33b_19 s16aq33b_20 s16aq33b_21 s16aq33b_22 s16aq33b_23 s16aq33b_24)

egen family_lab_maint= rsum(s16aq35b_1 s16aq35a_1 s16aq35b_2 s16aq35a_2 s16aq35b_3 s16aq35a_3 s16aq35b_4 s16aq35a_4 s16aq35b_5 s16aq35a_5 s16aq35b_6 s16aq35a_6 s16aq35b_7 s16aq35a_7 s16aq35b_8 s16aq35a_8 s16aq35b_9 s16aq35a_9 s16aq35b_10 s16aq35a_10 s16aq35b_11 s16aq35a_11 s16aq35b_12 s16aq35a_12 s16aq35b_13 s16aq35a_13 s16aq35b_14 s16aq35a_14 s16aq35b_15 s16aq35a_15 s16aq35b_16 s16aq35a_16 s16aq35b_17 s16aq35a_17 s16aq35b_18 s16aq35a_18 s16aq35b_19 s16aq35a_19 s16aq35b_20 s16aq35a_20 s16aq35b_21 s16aq35a_21 s16aq35b_22 s16aq35a_22 s16aq35b_23 s16aq35a_23 s16aq35b_24 s16aq35a_24 s16aq35b_25 s16aq35a_25 s16aq35b_26 s16aq35a_26 s16aq35b_27 s16aq35a_27 s16aq35b_28 s16aq35a_28)

replace s16aq37b_1=. if s16aq37b_1==9999
egen family_lab_harvest= rsum(s16aq37b_1 s16aq37b_2 s16aq37b_3 s16aq37b_4 s16aq37b_5 s16aq37b_6 s16aq37b_7 s16aq37b_8 s16aq37b_9 s16aq37b_10 s16aq37b_11 s16aq37b_12 s16aq37b_13 s16aq37b_14 s16aq37b_15 s16aq37b_16 s16aq37b_17 s16aq37b_18 s16aq37b_19 s16aq37b_20 s16aq37b_21 s16aq37b_22 s16aq37b_23 s16aq37b_24 s16aq37b_25 s16aq37b_26 s16aq37b_27 s16aq37b_28 s16aq37b_29 s16aq37b_30 s16aq37b_31 s16aq37b_32 s16aq37b_33)

egen family_labor_all=rsum(family_lab_sowing family_lab_maint family_lab_harvest)
***************************************************************
gen paid_man_day_sowing   = s16aq39a_1*s16aq39b_1
gen paid_woman_day_sowing = s16aq39a_2*s16aq39b_2
gen paid_boys_day_sowing  = s16aq39a_3*s16aq39b_3
gen paid_girls_day_sowing = s16aq39a_4*s16aq39b_4

egen paid_all_day_sowing  = rsum(paid_man_day_sowing paid_woman_day_sowing paid_boys_day_sowing paid_girls_day_sowing)

gen paid_man_day_maint   = s16aq41a_1*s16aq41b_1
gen paid_woman_day_maint = s16aq41a_2*s16aq41b_2
gen paid_boys_day_maint  = s16aq41a_3*s16aq41b_3
gen paid_girls_day_maint = s16aq41a_4*s16aq41b_4

egen paid_all_day_maint  = rsum(paid_man_day_maint paid_woman_day_maint paid_boys_day_maint paid_girls_day_maint)

gen paid_man_day_harvest   = s16aq43a_1*s16aq43b_1
gen paid_woman_day_harvest = s16aq43a_2*s16aq43b_2
gen paid_boys_day_harvest  = s16aq43a_3*s16aq43b_3
gen paid_girls_day_harvest = s16aq43a_4*s16aq43b_4

egen paid_all_day_harvest  = rsum(paid_man_day_harvest paid_woman_day_harvest paid_boys_day_harvest paid_girls_day_harvest)

egen pail_labor_all= rsum(paid_all_day_sowing paid_all_day_maint paid_all_day_harvest)
egen parcel_labor_all = rsum (family_labor_all pail_labor_all)

egen farm_labor_all = total (parcel_labor_all),by (farm_id)

gen labor_intensity=farm_labor_all/farm_area
gen capital_intensity= farm_capital_cost_ph

tabstat labor_intensity capital_intensity, by(farm_farm_size)
 
graph bar labor_intensity if farm_farm_size!=2, over(farm_farm_size) blabel(bar, size(small)) title("Labor intensity by farm size",size(small)) name(graph1, replace)
 
graph bar capital_intensity if farm_farm_size!=2, over(farm_farm_size) blabel(bar, size(small)) title("Capital intensity by farm size", size(small)) name(graph2, replace)

graph combine graph1 graph2

merge 1:m hh_id farm_id using "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\s16c_me_sen2021_final.dta"

keep if _merge==3
drop _merge  

/*// calcul labor and capital intensity by crops

graph hbar labor_intensity, over(crops, label(labsize(vsmall))) 

graph hbar capital_intensity, over(crops, label(labsize(vsmall)))

*/
reorder hh_id farm_id parcel_id membres__id

// estimate pourcentage each crops by household farm size

graph hbar (percent) if farm_farm_size!=2, over(farm_farm_size) blabel(bar, size(vsmall) pos(center) format(%3.1f)) over(crops, sort(1) descending label(labsize(vsmall))) stack asyvars percentage  title("Percentage crops by farm size (farm level)", size(small))
 

save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\farm_dataset_final", replace

/////////////////////////////////////////////////////////////////////////////////////
///////////// 
////////////                        Parcel LEVEL               ////////////////////////   
////////////   
//////////////////////////////////////////////////////////////////////////////////////


use "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\parcel_level_data.dta", clear

// calcul labor and capital intensity by parcel level 

graph hbar, over(s01qpreload_sex) over(s01qpreload_relation, sort(1) descending) blabel(bar, size(small) pos(center) format(%3.1f)) stack asyvars percentage
 
egen family_lab_sowing= rsum(s16aq33b_1 s16aq33b_2 s16aq33b_3 s16aq33b_4 s16aq33b_5 s16aq33b_6 s16aq33b_7 s16aq33b_8 s16aq33b_9 s16aq33b_10 s16aq33b_11 s16aq33b_12 s16aq33b_13 s16aq33b_14 s16aq33b_15 s16aq33b_16 s16aq33b_17 s16aq33b_18 s16aq33b_19 s16aq33b_20 s16aq33b_21 s16aq33b_22 s16aq33b_23 s16aq33b_24)

egen family_lab_maint= rsum(s16aq35b_1 s16aq35a_1 s16aq35b_2 s16aq35a_2 s16aq35b_3 s16aq35a_3 s16aq35b_4 s16aq35a_4 s16aq35b_5 s16aq35a_5 s16aq35b_6 s16aq35a_6 s16aq35b_7 s16aq35a_7 s16aq35b_8 s16aq35a_8 s16aq35b_9 s16aq35a_9 s16aq35b_10 s16aq35a_10 s16aq35b_11 s16aq35a_11 s16aq35b_12 s16aq35a_12 s16aq35b_13 s16aq35a_13 s16aq35b_14 s16aq35a_14 s16aq35b_15 s16aq35a_15 s16aq35b_16 s16aq35a_16 s16aq35b_17 s16aq35a_17 s16aq35b_18 s16aq35a_18 s16aq35b_19 s16aq35a_19 s16aq35b_20 s16aq35a_20 s16aq35b_21 s16aq35a_21 s16aq35b_22 s16aq35a_22 s16aq35b_23 s16aq35a_23 s16aq35b_24 s16aq35a_24 s16aq35b_25 s16aq35a_25 s16aq35b_26 s16aq35a_26 s16aq35b_27 s16aq35a_27 s16aq35b_28 s16aq35a_28)

replace s16aq37b_1=. if s16aq37b_1==9999
egen family_lab_harvest= rsum(s16aq37b_1 s16aq37b_2 s16aq37b_3 s16aq37b_4 s16aq37b_5 s16aq37b_6 s16aq37b_7 s16aq37b_8 s16aq37b_9 s16aq37b_10 s16aq37b_11 s16aq37b_12 s16aq37b_13 s16aq37b_14 s16aq37b_15 s16aq37b_16 s16aq37b_17 s16aq37b_18 s16aq37b_19 s16aq37b_20 s16aq37b_21 s16aq37b_22 s16aq37b_23 s16aq37b_24 s16aq37b_25 s16aq37b_26 s16aq37b_27 s16aq37b_28 s16aq37b_29 s16aq37b_30 s16aq37b_31 s16aq37b_32 s16aq37b_33)

egen family_labor_all=rsum(family_lab_sowing family_lab_maint family_lab_harvest)
***************************************************************
gen paid_man_day_sowing   = s16aq39a_1*s16aq39b_1
gen paid_woman_day_sowing = s16aq39a_2*s16aq39b_2
gen paid_boys_day_sowing  = s16aq39a_3*s16aq39b_3
gen paid_girls_day_sowing = s16aq39a_4*s16aq39b_4

egen paid_all_day_sowing  = rsum(paid_man_day_sowing paid_woman_day_sowing paid_boys_day_sowing paid_girls_day_sowing)

gen paid_man_day_maint   = s16aq41a_1*s16aq41b_1
gen paid_woman_day_maint = s16aq41a_2*s16aq41b_2
gen paid_boys_day_maint  = s16aq41a_3*s16aq41b_3
gen paid_girls_day_maint = s16aq41a_4*s16aq41b_4

egen paid_all_day_maint  = rsum(paid_man_day_maint paid_woman_day_maint paid_boys_day_maint paid_girls_day_maint)

gen paid_man_day_harvest   = s16aq43a_1*s16aq43b_1
gen paid_woman_day_harvest = s16aq43a_2*s16aq43b_2
gen paid_boys_day_harvest  = s16aq43a_3*s16aq43b_3
gen paid_girls_day_harvest = s16aq43a_4*s16aq43b_4

egen paid_all_day_harvest  = rsum(paid_man_day_harvest paid_woman_day_harvest paid_boys_day_harvest paid_girls_day_harvest)


egen pail_labor_all= rsum(paid_all_day_sowing paid_all_day_maint paid_all_day_harvest)
egen parcel_labor_all = rsum (family_labor_all pail_labor_all)

gen labor_intensity=parcel_labor_all/parcel_area

egen cap_cost_parcel = rsum(parcel_capital_cost hh_seed_cost hh_fer_pest_cost)
gen capital_intensity= parcel_capital_cost_ph

gen cap_int=cap_cost_parcel/parcel_area

save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\labor_cap_int_data.dta", replace

use "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\labor_cap_int_data.dta", clear



gen			farmsizeclass4 = . 
		replace		farmsizeclass4 = 1 if parcel_area<=1.01171411 & parcel_area >0.01
		replace		farmsizeclass4 = 2 if parcel_area>1.01171411 & parcel_area<=5.05857053
		replace		farmsizeclass4 = 3 if parcel_area>5.05857053 
		
		lab			def farmsizeclass4 1 "Small" 2 "Medium" 3 "Large"
		lab			val farmsizeclass4 farmsizeclass4
		
bysort farm_id: gen nparcels=_N
bysort farm_id (parcel_id): keep if _n==1
tabstat nparcels, by (farmsizeclass4)

/* Summary for variables: nparcels
Group variable: farmsizeclass4 

farmsizeclass4 |      Mean
---------------+----------
         Small |  1.196309
        Medium |  1.128549
         Large |    1.3125
---------------+----------
         Total |  1.172352
--------------------------

*/
gen farmsizeclass4b = .
replace farmsizeclass4b = 1 if parcel_area<=1.01171411/1.196309 & parcel_area >0.01
replace farmsizeclass4b = 2 if parcel_area>1.01171411/1.196309 & parcel_area<=5.05857053/1.128549
replace farmsizeclass4b = 3 if parcel_area>5.05857053/1.3125
lab def farmsizeclass4b 1 "Small" 2 "Medium" 3 "Large"
lab val farmsizeclass4b farmsizeclass4b
save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\labor_cap_int_data1.dta", replace	
/*graph pie, over(farmsizeclass1) plabel(_all percent) title("Farm size") 
graph pie, over(farmsizeclass1b) plabel(_all percent) title("Farm size") 
graph pie, over(farmsizeclass2) plabel(_all percent) title("Farm size") 
graph pie, over(farmsizeclass2b) plabel(_all percent) title("Farm size") 
graph pie, over(farmsizeclass3) plabel(_all percent) title("Farm size") 
graph pie, over(farmsizeclass3b) plabel(_all percent) title("Farm size") 
graph pie, over(farmsizeclass4) plabel(_all percent) title("Farm size") 
graph pie, over(farmsizeclass4b) plabel(_all percent) title("Farm size") */


use "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\labor_cap_int_data1.dta", clear	

tabstat labor_intensity capital_intensity, by(farmsizeclass4b)

//tabstat labor_intensity capital_intensity, by(parcel_farm_size)


graph bar capital_intensity , over(farmsizeclass4b) blabel(bar, size(small)) title("Capital intensity by parcel farm size",size(small)) name(graph1, replace)

graph bar labor_intensity , over(farmsizeclass4b) blabel(bar, size(small)) title("Labor intensity by parcel farm size",size(small)) name(graph1, replace)


************************************************************
************************************************************
graph bar labor_intensity if parcel_size!=2, over(parcel_farm_size) blabel(bar, size(small)) title("Capital intensity by parcel farm size", size(small)) name(graph1, replace)
graph bar capital_intensity if parcel_size!=2, over(parcel_farm_size) blabel(bar, size(small)) title("Capital intensity by parcel farm size", size(small)) name(graph2, replace)
graph combine graph1 graph2

graph bar capital_intensity, over(farmsizeclass4) blabel(bar, size(small)) title("Capital intensity by parcel farm size", size(small)) name(graph2, replace)
************************************************************
merge 1:m hh_id farm_id parcel_id using "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\s16c_me_sen2021_final.dta"

keep if _merge==3
drop _merge 

* Créer variable "crop_cat" vide
/*gen crop_cat = ""

* Céréales : Mil (1), Sorgho (2), Riz Paddy (3), Maïs (4), Fonio (7)
replace crop_cat = "Cereals" if inlist(crops, 1, 2, 3, 4, 7)

* Légumineuses/pulses : Niébé (8), Haricot vert (37), autres légumes secs
replace crop_cat = "Vegetables/pulses/fruits" if inlist(crops, 8, 11, 12, 13, 14, 15, 16, 17, 20, 22, 23, 24, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,25, 26, 53, 54, 56, 58, 59, 60)

* Cultures de rente : Arachide (10), Sésame (13), Coton (43), Anacarde (55), etc.
replace crop_cat = "Cash crops" if inlist(crops, 10, 13, 43, 55)

* Fourrages : Maïs (4) si utilisé en fourrage, Fodder (si code existe)
//replace crop_cat = "Fodder" if inlist(16C04, /* codes fourrages spécifiques */)

* Fruits : Agrume (53), Manguier (54), Ananas (56), Banane douce (58), Goyavier (59), Noix de coco (60), Pastèque (26), Melon (25)
//replace crop_cat = "Fruits" if inlist(crops, 25, 26, 53, 54, 56, 58, 59, 60)

* Autres cultures
//replace crop_cat = "Other crops" if inlist(crops, 65)

tab crop_cat */


save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\parcel_dataset_pre.dta", replace

// import price dataset

use "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\ehcvm_prix_sen2021.dta", clear

// harmoniser les noms des produits 
decode codpr, gen(codpr_txt)
                
* Initialiser la variable harmonisée
gen produit_harmonise = ""

* Céréales
replace produit_harmonise = "Mil" if inlist(codpr_txt, "Mil", "Farine de mil", "Semoule de mil")
replace produit_harmonise = "Riz" if inlist(codpr_txt, "Riz local entier","Riz local brisé","Riz importé brisé","Riz importé entier")
replace produit_harmonise = "Maïs" if inlist(codpr_txt, "Maïs en épi", "Maïs en grain", "Farine de maïs", "Semoule de mais")
replace produit_harmonise = "Sorgho" if codpr_txt == "Sorgho"
replace produit_harmonise = "Fonio" if codpr_txt == "Fonio"
replace produit_harmonise = "Blé" if inlist(codpr_txt, "Blé", "Farine de blé local ou importé")
* Légumineuses
replace produit_harmonise = "Niébé" if strpos(codpr_txt, "Niébé") | strpos(codpr_txt, "Haricot")
replace produit_harmonise = "Arachide" if strpos(codpr_txt, "Arachide")
replace produit_harmonise = "Néré" if strpos(codpr_txt, "Soumbala") | codpr_txt == "Néré"
replace produit_harmonise = "Sésame" if codpr_txt == "Sésame"
replace produit_harmonise = "Soja" if strpos(codpr_txt, "soja")

* Tubercules & racines
replace produit_harmonise = "Manioc" if strpos(codpr_txt, "Manioc") | strpos(codpr_txt, "Gari") | strpos(codpr_txt, "Attiéke")
replace produit_harmonise = "Patate douce" if codpr_txt == "Patate douce"
replace produit_harmonise = "Pomme de terre" if codpr_txt == "Pomme de terre"
replace produit_harmonise = "Igname" if codpr_txt == "Igname"
replace produit_harmonise = "Taro" if strpos(codpr_txt, "Taro")

* Légumes
replace produit_harmonise = "Gombo" if strpos(codpr_txt, "Gombo")
replace produit_harmonise = "Oseille (bissap)" if strpos(codpr_txt, "oseille") | strpos(codpr_txt, "bissap")
replace produit_harmonise = "Tomate" if strpos(codpr_txt, "Tomate")
replace produit_harmonise = "Poivron" if strpos(codpr_txt, "Poivron")
replace produit_harmonise = "Carotte" if strpos(codpr_txt, "Carotte")
replace produit_harmonise = "Aubergine" if strpos(codpr_txt, "Aubergine")
replace produit_harmonise = "Oignon" if strpos(codpr_txt, "Oignon")
replace produit_harmonise = "Concombre" if codpr_txt == "Concombre"
replace produit_harmonise = "Chou" if strpos(codpr_txt, "Choux")
replace produit_harmonise = "Laitue" if strpos(codpr_txt, "laitue")
replace produit_harmonise = "Courge" if strpos(codpr_txt, "Courge")

* Fruits
replace produit_harmonise = "Banane douce" if codpr_txt == "Banane douce"
replace produit_harmonise = "Plantain" if codpr_txt == "Plantain"
replace produit_harmonise = "Mangue" if codpr_txt == "Mangue"
replace produit_harmonise = "Papaye" if codpr_txt == "Papaye"
replace produit_harmonise = "Pastèque" if codpr_txt == "Pastèque"
replace produit_harmonise = "Melon" if codpr_txt == "Melon"
replace produit_harmonise = "Ananas" if codpr_txt == "Ananas"
replace produit_harmonise = "Avocat" if codpr_txt == "Avocats"
replace produit_harmonise = "Agrume" if strpos(codpr_txt, "Orange") | strpos(codpr_txt, "Citron") | strpos(codpr_txt, "Agrume")
replace produit_harmonise = "Dattes" if codpr_txt == "Dattes"
replace produit_harmonise = "Pomme" if codpr_txt == "Pommes"
replace produit_harmonise = "Fruit de baobab" if strpos(codpr_txt, "Fruit de baobab (bouye)")
replace produit_harmonise = "Noix de cajou" if codpr_txt == "Noix de cajou"
replace produit_harmonise = "Noix de coco" if codpr_txt == "Noix de coco"
replace produit_harmonise = "Néré" if codpr_txt == "Néré"

* Épices
replace produit_harmonise = "Piment" if strpos(codpr_txt, "Piment")
replace produit_harmonise = "Gingembre" if strpos(codpr_txt, "Gingembre")
replace produit_harmonise = "Poivre" if strpos(codpr_txt, "Poivre")


rename produit_harmonise crops

collapse (mean) prix, by(crops)


encode crops, gen(crops1)
drop crops 
ren crops1 crops
merge 1:m crops using "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\parcel_dataset_pre.dta"
*drop if _merge==1 

* Create a categorical variable for the crop types
decode crops, gen(crops1)
gen str30 croptype = ""
* Supposons que votre variable s'appelle "crops"
* On crée une nouvelle variable "category"

* Céréales
replace  croptype= "Cereals" if inlist(crops1, "Blé", "Maïs", "Mil", "Riz", "Fonio")

* Légumes / Légumineuses
replace croptype = "Vegetables/Pulses" if inlist(crops1, "Aubergine", "Carotte", "Concombre", "Courge", "Gombo", "Laitue") 
 replace croptype = "Vegetables/Pulses" if  inlist(crops1, "Taro", "Niébé", "Oignon", "Oseille (bissap)", "Piment", "Poivron")

* Fruits
replace croptype = "Fruits" if inlist(crops1, "Agrume", "Ananas", "Dattes", "Fruit de baobab", "Papaye", "Pastèque", "Pomme", "Noix de coco","Néré")

* Cultures de rente / Cash crops
replace croptype = "Cash crops" if inlist(crops1, "Arachide", "Gingembre", "Poivre", "Soja")

* Vérifier la distribution
tab croptype

//graph hbar prix, over(crops, sort(1) descending) blabel(bar, size(vsmall) pos(center) format(%3.1f))

graph hbar prix, over(croptype, sort(1) descending) blabel(bar, size(vsmall) pos(center) format(%3.1f)) title("Price by crops category")

/////////////////////////////////////////////////////////

// calcul labor and capital intensity by crops

graph hbar labor_intensity, over(croptype, sort(1) descending label(labsize(vsmall))) blabel(bar, size(vsmall)) title("labor intensity by crops category")


//graph hbar labor_intensity, over(cat_culture, sort(1) descending label(labsize(vsmall))) blabel(bar, size(vsmall))

graph hbar capital_intensity, over(croptype, sort(1) descending label(labsize(vsmall))) blabel(bar, size(vsmall)) title("capital intensity by crops category")

//graph hbar capital_intensity, over(cat_culture, sort(1) descending label(labsize(vsmall))) blabel(bar, size(vsmall))


reorder hh_id farm_id parcel_id membres__id


*************************************************

// estimate pourcentage each crops by household farm size

graph hbar (percent) , over(farmsizeclass4b) blabel(bar, size(vsmall) pos(center) format(%3.1f)) over(croptype, sort(1) descending label(labsize(vsmall))) stack asyvars percentage  title("Percentage crops by parcel farm size", size(small))



/*graph hbar (percent), over(farmsizeclass3) blabel(bar, size(vsmall) pos(center) format(%3.1f)) over(crop_cat, sort(1) descending label(labsize(vsmall))) stack asyvars percentage  title("Percentage crops by parcel farm size", size(small))

graph hbar (percent), over(farmsizeclass4) blabel(bar, size(vsmall) pos(center) format(%3.1f)) over(crop_cat, sort(1) descending label(labsize(vsmall))) stack asyvars percentage  title("Percentage crops by parcel farm size", size(small))
*/

// examine the capital and labour intensities of various crops grown by small and large farms

graph hbar capital_intensity , over(farmsizeclass4b) over(croptype, sort(1) descending label(labsize(vsmall)))  title("Capital Intensity by Crop and Farm Size", size(vmall)) blabel(bar, size(vsmall) pos(outside) format(%3.1f)) //stack asyvars



graph hbar labor_intensity , over(farmsizeclass4b) over(croptype, sort(1) descending label(labsize(vsmall)))  title("labor Intensity by Crop and Farm Size", size(vmall)) blabel(bar, size(vsmall) pos(outside) format(%3.1f)) //stack asyvars

// crops by gender


//graph hbar, over(s01qpreload_sex) over(croptype, sort(1) descending label(labsize(vsmall))) blabel(bar, size(vsmall) pos(center) format(%3.1f)) title("Crops by gender")  name(g1, replace) stack asyvars percent

//graph hbar, over(s01qpreload_sex) over(crop_cat, sort(1) descending label(labsize(vsmall))) blabel(bar, size(vsmall) pos(center) format(%3.1f)) title("Crops by gender")  name(g1, replace) //stack asyvars 

// crops by gender of head household

graph hbar if s01qpreload_relation==1, over(s01qpreload_sex) over(croptype, sort(1) descending label(labsize(vsmall))) blabel(bar, size(vsmall) pos(center) format(%3.1f)) title("Crops by gender of head household", size(vsmall))  name(g2, replace) stack asyvars percent
 
 
//graph hbar if s01qpreload_relation==1, over(s01qpreload_sex) over(crop_cat, sort(1) descending label(labsize(vsmall))) blabel(bar, size(vsmall) pos(center) format(%3.1f)) title("Crops by gender of head household", size(vsmall))  name(g2, replace) stack asyvars
//graph combine g1 g2


// days workers by gender and crops

graph bar parcel_labor_all if s01qpreload_relation==1 , over(s01qpreload_sex) blabel(bar,size(vsmall)) title("Labor by gender")

 
graph bar family_labor_all if s01qpreload_relation==1 , over(s01qpreload_sex) blabel(bar,size(vsmall)) title("Family Labor by gender")

graph bar pail_labor_all if s01qpreload_relation==1, over(s01qpreload_sex) blabel(bar,size(vsmall)) title("Labor workers by gender")
graph hbar parcel_labor_all if s01qpreload_relation==1, over(s01qpreload_sex) over(croptype, sort(1) descending label(labsize(vsmall))) blabel(bar, size(vsmall) pos(center) format(%3.1f)) title("Labor by gender and crops", size(vsmall))  name(g2, replace) stack asyvars

//graph hbar parcel_labor_all, over(s01qpreload_sex) over(cat_culture, sort(1) descending label(labsize(vsmall))) /*blabel(bar, size(vsmall) pos(center) format(%3.1f))*/ title("Labor by gender and crops", size(vsmall))  name(g2, replace) stack asyvars






// calculate the various crops' productivity and associate it with farm size


* production in monetary term 

gen prod = s16cq16c*prix

drop if prod==.

gen productivity = prod/parcel_area 

su productivity

gen labor_productivity = prod/parcel_labor_all
gen capital_productivity= prod/parcel_capital_cost

su labor_productivity capital_productivity productivity

tabstat productivity, by(croptype) stats(mean sd n)

graph bar productivity , over(farmsizeclass4b) blabel(bar, size(small)) title("Productivity per area in hectar")

graph bar labor_productivity, over(farmsizeclass4b) blabel(bar, size(small)) title("labor productivity")


graph bar capital_productivity, over(farmsizeclass4b) blabel(bar, size(small)) title("Capital productivity")




graph hbar productivity , over(farmsizeclass4b) over(croptype, sort(1) descending label(labsize(vsmall))) title("Productivity by farm size and crops category") blabel(bar, size(small))


graph hbar labor_productivity , over(farmsizeclass4b) over(croptype, sort(1) descending label(labsize(vsmall)))  blabel(bar, size(small)) title("Labor productivity by farm size and crops category")
graph hbar capital_productivity , over(farmsizeclass4b) over(croptype, sort(1) descending label(labsize(vsmall))) blabel(bar, size(small)) title("Capital productivity by farm size and crops category")

* family labor percent 

save "D:\DATA_CLEAN_THESE\My these\SEN_2021_EHCVM-2_v01_M_STATA14\SEN_2021_EHCVM-2_v01_M_STATA14\parcel_dataset_final.dta", replace


encode croptype, gen(crop_cat)
reg productivity i.crop_cat i.farmsizeclass4b
 
 