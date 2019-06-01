***04122017 HF Readmission Continue;
*From data Hf_readm.Alladm_vars_v6, we can make another data
called hf_readm.survdata_hfcause

Survdata_allcause_draft9 has 226887 obs (unique patients);

proc sql;
     select count(distinct(patient_id)) as pidnum 
            from Hf_readm.Alladm_vars_v6 ;
quit;

*Alladm_vars_v6 also has 226887 distict patients too;
*subset Alladm_vars_v6 using dx1_hf =1 and seperate 
  the once or multiple admission population;

data adms_onorafter_1stHF_hf;  /*473403*27*/
  set hf_readm.alladm_vars_v6;
  where adm_date >= dx1hf_firstadm_date
        and dx1_hf=1;
run;

data pid_onceormultiple_hf;
  set adms_onorafter_1stHF_hf;
  keep patient_id;
run;

data pid_multiple_hf;  /*343802*/
  set pid_onceormultiple_hf;
  by patient_id;
  if first.patient_id and last.patient_id then delete;
run;

data pid_multiple_unique_hf;  /*97286*/
  set pid_multiple_hf;
  by patient_id;
  if first.patient_id;
run;

data survdata_hfcause_draft2; /*473403*28*/
  merge adms_onorafter_1stHF_hf   pid_multiple_unique_hf(in = inpid_multiple_unique_hf);
  by patient_id;
  if (inpid_multiple_unique_hf) then multipleadmi_hf=1;
  else multipleadmi_hf=0;
run;


data survdata_hfcause_once survdata_hfcause_multiple;
  set survdata_hfcause_draft2;
  IF (multipleadmi_hf=0) THEN OUTPUT survdata_hfcause_once;
  ELSE OUTPUT survdata_hfcause_multiple;
run;

/*Survdata_hfcause_once n= 129601 
Survdata_hfcause_multiple n= 343802*/

data survdata_hfcause_once2;/* 129601*30*/
 set survdata_hfcause_once;
 censor_hfcausereadmi = 0;
 IF(. <death_date< "31dec2013"d) 
   THEN time_hfcausereadmi = DATDIF(discharge_date1, death_date,'act/act');
 ELSE time_hfcausereadmi = DATDIF(discharge_date1,"31dec2013"d , 'act/act');
RUN;

data survdata_hfcause_multiple_2;/*97286*2*/
  set survdata_hfcause_multiple;
  count +1;
  by patient_id adm_date;
  if FIRST.patient_id then count =1;
  if count =2 then output;
  keep patient_id adm_date;
  rename adm_date= second_hfadmission_date;
run;

data survdata_hfcause_multiple_3; /*97286*28*/
  set survdata_hfcause_multiple;
  by patient_id;
  if first.patient_id;
run;

data survdata_hfcause_multiple_4; /*195303*29*/
  merge survdata_hfcause_multiple_3  survdata_hfcause_multiple_2;
  by patient_id;
run;



data survdata_hfcause_multiple_5;
  set survdata_hfcause_multiple_4;
  time_hfcausereadmi = DATDIF(discharge_date1, second_hfadmission_date, 'act/act');
  censor_hfcausereadmi = 1;
run;

data survdata_hfcause_multiple_6; /*97286*31*/
  set survdata_hfcause_multiple_5;
  IF ( adm_date<death_date<second_hfadmission_date) THEN DO;
   censor_hfcausereadmi = 0;
   time_hfcausereadmi= DATDIF(discharge_date1, death_date, 'act/act');
  END;
RUN;

data survdata_hfcause_draft3; /*226887*31*/
     merge survdata_hfcause_multiple_6   survdata_hfcause_once2;
	 by patient_id;
run;

data survdata_hfcause_draft4;
  set survdata_hfcause_draft3;
  age = YRDIF(birth_date, adm_date, 'act/act');
  female = 0;
  IF (sex = 'F') THEN female =1;
run;


*HF readmission or death;

data survdata_hfcause_draft7_single  survdata_hfcause_draft7_multi;
  set survdata_hfcause_draft4;
  if (multipleadmi_hf =0) then output survdata_hfcause_draft7_single;
  else output survdata_hfcause_draft7_multi;
run;

data survdata_hfcause_draft8_single;
  set survdata_hfcause_draft7_single;
  time_hfcause_readmordeath = DATDIF(discharge_date1, "31dec2013"d, 'act/act');
  censor_hfcausereadmordeath =0;
  if (.<death_date< "31dec2013"d) then do;
    time_hfcause_readmordeath = DATDIF(discharge_date1, death_date, 'act/act');
    censor_hfcausereadmordeath =1;
  end;
run;

/*earlier_date is the min among death_date and second_admission_date*/
data survdata_hfcause_draft8_multi1;
  set survdata_hfcause_draft7_multi;
  if (.<death_date< "31dec2013"d) then earlier_date_hfordeath = min ( death_date, second_hfadmission_date) ;
  format earlier_date_hfordeath  MMDDYY10.;
run;



data survdata_hfcause_draft8_multi2;
  set survdata_hfcause_draft8_multi1;
  time_hfcause_readmordeath = DATDIF(discharge_date1, second_hfadmission_date, 'act/act');
  censor_hfcausereadmordeath = 1;
  if (.<death_date< "31dec2013"d) then 
    time_hfcause_readmordeath = DATDIF(discharge_date1, earlier_date_hfordeath, 'act/act');
run;


data hf_readm.survdata_hfcause_draft9;/*226887*36*/
  merge  survdata_hfcause_draft8_single  survdata_hfcause_draft8_multi2;
  by patient_id;
run;


ods graphics on;
title "Time to allcause readmission or death for people that did not have dx1-9 HF history";
proc lifetest data=hf_readm.survdata_hfcause_draft9 plots=hazard(bw=200) ;
time time_hfcause_readmordeath*censor_hfcausereadmordeath(0);
strata sex;
where hfhistory_dx1to9 = 0;
run;
title;
ods graphics off;


