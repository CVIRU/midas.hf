/*Cox Model Analysis plan*/
*03/27/2017;
/*Data we can work on is hf_readm.Survdata_allcause_draft9*/


proc phreg data = whas500;
class gender;
model lenfol*fstat(0) = gender age;;
run;


proc phreg data=whas500 plots=survival;
class gender;
model lenfol*fstat(0) = gender age;;
run;

/*When only plots=survival is specified on the proc phreg statement, SAS will produce one graph, a “reference curve” of the 
survival function at the reference level of all categorical predictors and at the mean of all continuous predictors.*/

data covs;
format gender gender.;
input gender age;
datalines;
0 69.845947
1 69.845947
;
run;

proc phreg data = whas500 plots(overlay)=(survival);
class gender;
model lenfol*fstat(0) = gender age;
baseline covariates=covs out=base / rowid=gender;
run;
;


proc phreg data = whas500;
class gender;
model lenfol*fstat(0) = gender|age bmi|bmi hr ;
run;

/*We would probably prefer this model to the simpler model with just gender and age as explanatory factors for a couple of reasons. 
First, each of the effects, including both interactions, are significant. 
Second, all three fit statistics, -2 LOG L, AIC and SBC, are each 20-30 points lower in the larger model, 
suggesting the including the extra parameters improve the fit of the model substantially.*/



data covs2;
format gender gender.;
input gender age bmi hr;
datalines;
0 40 26.614 87.018
0 60 26.614 87.018
0 80 26.614 87.018
1 40 26.614 87.018
1 60 26.614 87.018
1 80 26.614 87.018
;
run;

proc phreg data = whas500 plots(overlay=group)=(survival);
class gender;
model lenfol*fstat(0) = gender|age bmi|bmi hr ;
baseline covariates=covs2  / rowid=age group=gender;
run;

/*In the Cox proportional hazards model, additive changes in the covariates are assumed 
to have constant multiplicative effects on the hazard rate (expressed as the hazard ratio (HRHR)):*/

proc contents data= hf_readm.Survdata_allcause_draft9;
run;

/*The variables that we wanna keep are
 DX1-9, cause, prime,patient_id, race, sex, status,adm_date,
age,birth_date,death_date,discharge_date1,
hfhistory_dx1  hfhistory_dx1to9  hfhistory_dx2to9  multipleadmi,
rownum_in_mda,
time_allcausereadmi, time_allcausedeath, time_allcause_readmordeath
censor_allcausereadmi, censor_allcausedeath, censor_allcausereadmordeath*/

/*Test*/
data test;
  set hf_readm.Survdata_allcause_draft9;
  index_adm_year = year(adm_date);
run;

/*Variables that we want to test are:
 hfhistory_dx1 hfhistory_dx1to9 hfhistory_dx2to9
*/

proc phreg data = test;
class sex hfhistory_dx1 hfhistory_dx1to9 hfhistory_dx2to9;
model time_allcausereadmi*censor_allcausereadmi(1) = sex age index_adm_year 
      hfhistory_dx1 hfhistory_dx1to9 hfhistory_dx2to9;
run;


proc phreg data = test;
class sex hfhistory_dx1 hfhistory_dx1to9 hfhistory_dx2to9;
model time_allcausedeath*censor_allcausedeath(1) = sex age index_adm_year 
      hfhistory_dx1 hfhistory_dx1to9 hfhistory_dx2to9;
run;

proc phreg data = test;
class sex hfhistory_dx1 hfhistory_dx1to9 hfhistory_dx2to9;
model time_allcause_readmordeath*censor_allcausereadmordeath(1) = sex age index_adm_year 
      hfhistory_dx1 hfhistory_dx1to9 hfhistory_dx2to9;
run;


/*Focusing on event1*/
proc phreg data=test plots=survival;
class sex hfhistory_dx1 hfhistory_dx1to9 hfhistory_dx2to9;
model time_allcausereadmi*censor_allcausereadmi(1) = sex age index_adm_year 
      hfhistory_dx1 hfhistory_dx1to9 hfhistory_dx2to9;
run;

/*Let’s get survival curves (cumulative hazard curves are also available) for 
males and female at the mean age of 69.845947 in the manner we just described.*/

data covs;
format sex $3.;
input sex $ age;
datalines;
M 75.369504
F 75.369504
;
run;

proc phreg data = test plots(overlay)=(survival);
class sex;
model time_allcausereadmi*censor_allcausereadmi(1) = sex age;
baseline covariates=covs out=base / rowid=sex;
run;


/*Focusing on event2*/


proc phreg data = test plots(overlay)=(survival);
class sex;
model time_allcausedeath*censor_allcausedeath(1) = sex age;
baseline covariates=covs out=base / rowid=sex;
run;

/*Focusing on event3*/
proc phreg data = test plots(overlay)=(survival);
class sex;
model time_allcause_readmordeath*censor_allcausereadmordeath(1) = sex age;
baseline covariates=covs out=base / rowid=sex;
run;
