* 04132017 HF readmision project;
* Now we have two data 
* 1st is Survdata_allcause_draft9 as a  (38 columns)
* 2nd is Survdata_hfcause_draft9 as b (36 columns)

First I want to join them to make Survdata_allandhfcause_draft1;


/*Inner join didn't work, I don't know why?*/
/*proc sql noexec;
  select Survdata_allcause_draft9.*, time_hfcausereadm, censor_hfcausereadmi,
         time_hfcause_readmordeath, censor_hfcausereadmordeath
		 from hf_readm.Survdata_allcause_draft9, hf_readm.Survdata_hfcause_draft9
		 where Survdata_allcause_draft9.patient_id = Survdata_hfcause_draft9.patient_id;
quit;*/

data hf_readm.Survdata_allandhfcause_draft1;
  merge hf_readm.Survdata_allcause_draft9 hf_readm.Survdata_hfcause_draft9;
  by patient_id;
run;

/*By comparing the property, we confirmed that four informative variables have been
 added to Survdata_allcause_draft9 to make Survdata_allandhfcause_draft1*/

/*Add a variable named length_index_adm*/
*length_index_adm is defined as days from adm_date to discharge_date1;

/*SAVE Survdata_allandhfcause_draft2*/

data hf_readm.Survdata_allandhfcause_draft2;
  set hf_readm.Survdata_allandhfcause_draft1;
  length_index_adm = DATDIF(adm_date, discharge_date1, 'act/act');
run;


/*The addressing of outliers*/
proc corr data = Survdata_allandhfcause_draft2 
plots(maxpoints=none)=matrix(histogram);
var  time_allcausereadmi time_allcausedeath time_hfcausereadmi length_index_adm hfhistory_dx1 hfhistory_dx2to9 ;
run;

proc freq data =Survdata_allandhfcause_draft2;
  tables length_index_adm;
run;

proc freq data =Survdata_allandhfcause_draft2;
  tables time_allcausedeath;
run;

proc freq data =Survdata_allandhfcause_draft2;
  tables time_hfcausereadmi;
run;

proc freq data =Survdata_allandhfcause_draft2;
  tables time_allcausereadmi;
run;





proc lifetest data=Survdata_allandhfcause_draft2 plots=hazard(bw=200) ;
time time_allcausereadmi*censor_allcausereadmi(0);
strata sex;
where hfhistory_dx1to9 = 0;
run;

proc lifetest data=Survdata_allandhfcause_draft2 plots=hazard(bw=200) ;
time time_allcausedeath*censor_allcausedeath(0);
strata sex;
where hfhistory_dx1to9 = 0;
run;

proc lifetest data=Survdata_allandhfcause_draft2 plots=hazard(bw=200) ;
time time_allcause_readmordeath*censor_allcausereadmordeath(0);
strata sex;
where hfhistory_dx1to9 = 0;
run;

proc lifetest data=Survdata_allandhfcause_draft2 plots=hazard(bw=200) ;
time time_hfcausereadmi*censor_hfcausereadmi(0);
strata sex;
where hfhistory_dx1to9 = 0;
run;

proc lifetest data=Survdata_allandhfcause_draft2 plots=hazard(bw=200) ;
time time_hfcause_readmordeath*censor_hfcausereadmordeath(0);
strata sex;
where hfhistory_dx1to9 = 0;
run;







/*Add in the usual suspect flags
 1 diabetes c(250, 2500:2509,25000:25093)
 2 hypertension c(4010:4011,
                                                  4019,
                                                  40200,
                                                  40210,
                                                  40290,
                                                  
                                                  40300:40301,
                                                  40310:40311,
                                                  40390:40391,
                                                  
                                                  40400:40404,
                                                  40410:40413,
                                                  40490:40493,
                                                  
                                                  40501,
                                                  40509,
                                                  40511,
                                                  40519,
                                                  40591,
                                                  40599))
 3 CHD
  Didn't found

 4 CKD
   c(585,
                                                  5851:5856,
                                                  5859)
 5 COPD
    c(490, #Bronchitis, not specified as acute or chronic
                                                   #Chronic bronchitis
                                                   491, 
                                                   4910:4912,
                                                   4918:4919,
                                                   49120:49122,
                                                   #Emphysema
                                                   492, 
                                                   4920,
                                                   4928,
                                                   #Asthma
                                                   493, 
                                                   4930:4932,
                                                   4938:4939,
                                                   49300:49302,
                                                   49310:49312,
                                                   49320:49322,
                                                   49381:49382,
                                                   49390:49392,
                                                   #Bronchiectasis
                                                   494, 
                                                   4940:4941,
                                                   #Extrinsic allergic alveolitis
                                                   495, 
                                                   4950:4959,
                                                   #Chronic airway obstruction, not elsewhere classified
                                                   496)
*/





*Creat char list of diabetes;

data diabeteslist_num1;
    input diabeteslist_number;
    datalines;
	250
	;
run;


data diabeteslist_num2;
do  diabeteslist_number= 2500 to 2509 by 1;
   output;
end;
run;
  
data diabeteslist_num3;
do  diabeteslist_number= 25000 to 25093 by 1;
   output;
end;
run; 

data diabeteslist_num;
  set diabeteslist_num1  diabeteslist_num2 diabeteslist_num3;
run;

data hf_readm.diabeteslist_str;
  set diabeteslist_num;
  diabeteslist_char = put (diabeteslist_number, 8.);
  drop diabeteslist_number;


run;

* Compare to this tedious method, we may generate the list in R and import it in here;


/*Make a history table for our convenience*/
* From program 03222017, we can get a table alladm_vars_d1d2subset, this include all patients.
So we need to subset this to creat the history table*/

*From alladm_vars_d1d2subset n=798885, 
we keep only the obs whose patient_id is in hf_readm.Survdata_allandhfcause_draft1 n=226887;

data target_his_table;
  merge alladm_vars_d1d2subset(in =x) hf_readm.Survdata_allandhfcause_draft1(in=y);
  by patient_id;
  if x=1 and y=1;
run;
  
*Double check the unique pid in target_his_table;
proc sql; /*177407*/
  create table ct as
  select count(distinct(patient_id)) as ncount
  from target_his_table;
quit;

proc sql;/*226887*/
  create table ct2 as
  select count(distinct(patient_id)) as ncount
  from hf_readm.Survdata_allandhfcause_draft1;
quit;

proc sql;/*185022*/
  create table ct3 as 
  select count(distinct(patient_id)) as ncount
  from alladm_vars_d1d2subset;
quit;

proc sql;/*236257*/
  create table ct4 as 
  select count(distinct(patient_id)) as ncount
  from alladm_vars;
quit;

/*Here we must check the distict patient_id number carefully, to be continued*/
