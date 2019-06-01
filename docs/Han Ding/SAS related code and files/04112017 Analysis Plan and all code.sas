*** 04112017 This week doing;
1 add a variable called length of stay
2 Change the 0 and 1 in the censorship variable; DONE; 
3 add to covariates of *** to cox model
4 Remove dx1-9 from the cox model
5 Make graph about HF caused readmission, HF caused readmission or death


What I am doing in this program file explaination:
  From addadm we modified several 0 and 1 in the censorship process 
  and the data hf_readm.survdata_allcause_draft9 is stored in hf_readm 
  that can be used later
  
  

*** Here I adopted the code from file '03222017 All cause readmission' ;
*** 1st data addadm;
*GT 18 years old, had HF in DX1 during 2000-2013, exclude all cancer in dx1-9 in all years;
*** This is data addadm;


*** From data addadm;
We add in several variables to help us proceed.
1 dx1hf_firstadm flags the index admission obs, dx1hf_firstadm_date indicates the index admission date
2 hfhistory_dx1 hfhistory_dx2to9 hfhistory_dx1to9
We exclude patient that died in the index admission

*We got and saved alladm_vars_v6; n=2723162*27 ;


/*Objective one- all cause readmission*/

/*Run this part first*/
data adms_onorafter_1stHF;  /*1547370*27*/
  set hf_readm.alladm_vars_v6;
  where adm_date >= dx1hf_firstadm_date;
run;

data pid_onceormultiple;
  set adms_onorafter_1stHF;
  keep patient_id;
run;

data pid_multiple;  /*1515786*/
  set pid_onceormultiple;
  by patient_id;
  if first.patient_id and last.patient_id then delete;
run;

data pid_multiple_unique;  /*195303*/
  set pid_multiple;
  by patient_id;
  if first.patient_id;
run;

/*we add one variable multipleadmi to adms_onorafter_1stHF */
data survdata_allcause_draft2; /*1547370*28*/
  merge adms_onorafter_1stHF   pid_multiple_unique(in = inpid_multiple_unique);
  by patient_id;
  if (inpid_multiple_unique) then multipleadmi=1;
  else multipleadmi=0;
run;


data survdata_allcause_once survdata_allcause_multiple;
  set survdata_allcause_draft2;
  IF (multipleadmi=0) THEN OUTPUT survdata_allcause_once;
  ELSE OUTPUT survdata_allcause_multiple;
run;

*****Modification starting from here;

* From data alladm_vars_v6;
*We got 2 datasets survdata_allcause_once  survdata_allcause_multiple 
We are going to swap the way that censorship was defined in the file of '03222017 All Cause Readmission.sas';

/*Little modification from 03222017 All Cause Readmission.sas'*/
data survdata_allcause_once2;/* 31584*30*/
 set survdata_allcause_once;
 censor_allcausereadmi = 0;
 IF(. <death_date< "31dec2013"d) 
   THEN time_allcausereadmi = DATDIF(discharge_date1, death_date,'act/act');
 ELSE time_allcausereadmi = DATDIF(discharge_date1,"31dec2013"d , 'act/act');
RUN;



data survdata_allcause_multiple_2;/* 195303*2*/
  set survdata_allcause_multiple;
  count +1;
  by patient_id adm_date;
  if FIRST.patient_id then count =1;
  if count =2 then output;
  keep patient_id adm_date;
  rename adm_date= second_admission_date;
run;

data survdata_allcause_multiple_3; /*195303*28*/
  set survdata_allcause_multiple;
  by patient_id;
  if first.patient_id;
run;

data survdata_allcause_multiple_4; /*195303*29*/
  merge survdata_allcause_multiple_3  survdata_allcause_multiple_2;
  by patient_id;
run;


/*Censorship modification*/

data survdata_allcause_multiple_5;
  set survdata_allcause_multiple_4;
  time_allcausereadmi = DATDIF(discharge_date1, second_admission_date, 'act/act');
  censor_allcausereadmi = 1;
run;

data survdata_allcause_multiple_6; /*195303*31*/
  set survdata_allcause_multiple_5;
  IF ( adm_date<death_date<second_admission_date) THEN DO;
   censor_allcausereadmi = 0;
   time_allcausereadmi= DATDIF(discharge_date1, death_date, 'act/act');
  END;
RUN;

data survdata_allcause_draft3; /*226887*31*/
     merge survdata_allcause_multiple_6   survdata_allcause_once2;
	 by patient_id;
run;

data survdata_allcause_draft4;
  set survdata_allcause_draft3;
  age = YRDIF(birth_date, adm_date, 'act/act');
  female = 0;
  IF (sex = 'F') THEN female =1;
run;

*some modification;

ods graphics on;
title "Time to allcause readmission for people that did not have dx1-9 HF history";
proc lifetest data=survdata_allcause_draft4 plots=hazard(bw=200);
time time_allcausereadmi*censor_allcausereadmi(0);
strata sex;
where hfhistory_dx1to9 = 0;
run;
title;
ods html close;


/***Objective two: ALL CAUSE MORTALITY -TIME TO DEATH****************/
data survdata_allcause_draft5;
  set survdata_allcause_draft4;
  time_allcausedeath = DATDIF(discharge_date1,"31dec2014"d, 'act/act');
  censor_allcausedeath = 0;
RUN;


data survdata_allcause_draft6;
  set survdata_allcause_draft5;
  IF (.< death_date )THEN DO ;
    censor_allcausedeath =1;
	time_allcausedeath = DATDIF(discharge_date1, death_date, 'act/act');
  END;
RUN;

proc lifetest data=survdata_allcause_draft6 plots=hazard(bw=200);
time time_allcausedeath*censor_allcausedeath(0);
strata sex;
where hfhistory_dx1to9 = 0;
run;

/******OBJECTIVE THREE: ALL CAUSE READMISSION OR DEATH, TIME TO THE Earlier Event
  EITHER IT'S ALL CAUSE READMISSION OR DEATH*/

data survdata_allcause_draft7_single  survdata_allcause_draft7_multi;
  set survdata_allcause_draft6;
  if (multipleadmi =0) then output survdata_allcause_draft7_single;
  else output survdata_allcause_draft7_multi;
run;

data survdata_allcause_draft8_single;
  set survdata_allcause_draft7_single;
  time_allcause_readmordeath = DATDIF(discharge_date1, "31dec2013"d, 'act/act');
  censor_allcausereadmordeath =0;
  if (.<death_date< "31dec2013"d) then do;
    time_allcause_readmordeath = DATDIF(discharge_date1, death_date, 'act/act');
    censor_allcausereadmordeath =1;
  end;
run;

/*earlier_date is the min among death_date and second_admission_date*/
data survdata_allcause_draft8_multi1;
  set survdata_allcause_draft7_multi;
  if (.<death_date< "31dec2013"d) then earlier_date = min ( death_date, second_admission_date) ;
  format earlier_date  MMDDYY10.;
run;



data survdata_allcause_draft8_multi2;
  set survdata_allcause_draft8_multi1;
  time_allcause_readmordeath = DATDIF(discharge_date1, second_admission_date, 'act/act');
  censor_allcausereadmordeath = 1;
  if (.<death_date< "31dec2013"d) then 
    time_allcause_readmordeath = DATDIF(discharge_date1, earlier_date, 'act/act');
run;


data hf_readm.survdata_allcause_draft9;
  merge  survdata_allcause_draft8_single  survdata_allcause_draft8_multi2;
  by patient_id;
run;

ods graphics on;
title "Time to allcause readmission or death for people that did not have dx1-9 HF history";
proc lifetest data=hf_readm.survdata_allcause_draft9 plots=hazard(bw=200) ;
time time_allcause_readmordeath*censor_allcausereadmordeath(0);
strata sex;
where hfhistory_dx1to9 = 0;
run;
title;
ods graphics off;
