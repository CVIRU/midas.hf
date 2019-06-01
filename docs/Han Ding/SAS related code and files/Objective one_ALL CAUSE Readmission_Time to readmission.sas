/*Objective two- ALL CAUSE Readmission- Time to Readmission*/
data survdata1_draft1;
    set hf_readm.md6;
	keep Patient_ID SEX RACE PRIME PATIENT_BIRTH_DATE ADMISSION_DATE newdtd
    /*ADD history , age ,time_allcausereadmission, censor_allreadmission later*/;
run;

data survdata1_draft1_newdtd1;
    set survdata1_draft1;
    newdtd1 = input( newdtd, MMDDYY10.);
	format newdtd1 YYMMDD10.;
    /*ADD history , age ,time_allcausereadmission, censor_allreadmission later*/
run;

data survdata1_draft2;
  merge survdata1_draft1_newdtd1 Pid_no_history_1st(in = inPid_no_history_1st);
  by Patient_ID;
  if  (inPid_no_history_1st) THEN hf_history = 1;
  ELSE hf_history = 0;
run;

data survdata1_draft3;
  set survdata1_draft2;
    age=YRDIF(patient_birth_date ,admission_date );
RUN;


PROC FREQ data = survdata1_draft4;
  TABLES newdtd1/ MISSING;
RUN;

data survdata1_draft4;
  set survdata1_draft3;
  by patient_id;
  if first.patient_id;
run;

data pid_onceormultiple;
  set survdata1_draft3;
  keep patient_id;
run;

/*We want to get the pid that occur more than once it's called  pid_multiple */
data pid_multiple;
  set pid_onceormultiple;
  by patient_id;
  if first.patient_id and last.patient_id then delete;
run;

data pid_multiple_unique;
  set pid_multiple;
  by patient_id;
  if first.patient_id;
run;

/*add a variable called multipleadmi*/
data survdata1_draft5; /*11 variables*/
  merge survdata1_draft3   pid_multiple(in = inpid_multiple);
  by patient_id;
  if (inpid_multiple) then multipleadmi=1;
  else multipleadmi=0;
run;



/*We'd better work on draft5*/
data survdata1_once survdata1_multiple;
  set survdata1_draft5;
  IF (multipleadmi=0) THEN OUTPUT survdata1_once;
  ELSE OUTPUT survdata1_multiple;
run;
  

/*IF there is only one row for a patient_id in md6
  2-1/ IF the newdtd is missing or it's after the end date, 
       THEN time_all_admi <- end of study date - 1st admission date, we censored it on the end of study date Dec 31 2013
  2-2/ IF the newdtd is before the end date, 
       THEN time_all_admi <- newdtd- 1st admission date we censored it on the newdtd*/

data survdata1_once_2;/*144407*/?
 set survdata1_once;
 censor_allcausereadmi = 1;
 IF(. <newdtd1< "31dec2013"d) THEN time_allcausereadmi = DATDIF(admission_date, newdtd1,'act/act');
 ELSE time_allcausereadmi = DATDIF(admission_date,"31dec2013"d , 'act/act');
RUN;

/*********we will use this survdata1_once_2 to combine with the multiple category to make the final dataset*************/




/*we want to get the 2nd admission date for each patient*/
/*Just add a variable called 2nd_admission_date for each row*/

data survdata1_multiple_2;/*94394*/
  set survdata1_multiple;
  count +1;
  by patient_id admission_date;
  if FIRST.patient_id then count =1;
  if count =2 then output;
  keep patient_id admission_date;
  rename admission_date= second_admission_date;
run;

data survdata1_multiple_3;
  set survdata1_multiple;
  by patient_id;
  if first.patient_id;
run;

data survdata1_multiple_4;
 merge survdata1_multiple_2 survdata1_multiple_3;
 by patient_id;
run;

/*IF there is more than one rows for a patient_id in md6  
  1-1/ IF the newdtd is missing or it's after the second admission
       THEN  time_all_admi <- 2nd admition_date - 1st admission_date & censorship <- 0
  1-2/ IF the newdtd is between the two admission date, then newdtd must be before end of study date
       then we censored it on the newdtd ( but I doubt this situation's exist or not?)*/

data survdata1_multiple_5;
  set survdata1_multiple_4;
  time_allcausereadmi = DATDIF(admission_date, second_admission_date, 'act/act');
  censor_allcausereadmi = 0;
run;

data survdata1_multiple_6;/*94394*/
  set survdata1_multiple_5;
  IF ( admission_date<newdtd1<second_admission_date) THEN DO;
   censor_allcausereadmi = 1;
   time_allcausereadmi= DATDIF(admission_date, newdtd1, 'act/act');
  END;
RUN;


/*very WEIRD, there are 27 cases that admission_date<newdtd1<second_admission_date stands! How can this be?*/
PROC FREQ data=survdata1_multiple_6;
  TABLES censor_allcausereadmi/ MISSING;
RUN;

PROC PRINT data=survdata1_multiple_6;
 WHERE censor_allcausereadmi=1;
RUN;

DATA survdata1_draft6;
  MERGE survdata1_multiple_6 survdata1_once_2;
  BY patient_id;
RUN;

/*****survdata1_draft6 is the dataset for objective 1*/


/**Let's look at the data*/
/* let's use numeric format of sex, 0=male, 1=female*/
PROC FREQ data=survdata1_multiple_6;
  TABLES sex/ MISSING;
RUN;


data survdata1_draft7;
  set hf_readm.survdata1_draft6;
  sex_num =0;
  IF (sex = 'F') THEN sex_num =1;
RUN;

data survdata1_draft7_nohis survdata1_draft7_his;
  set survdata1_draft7;
  if hf_history = 0 then output survdata1_draft7_nohis;/*100715*/
  else output survdata1_draft7_his;/*138086*/
run;

/*Scatter Plot*/
proc corr data = survdata1_draft7 plots(maxpoints=none)=matrix(histogram);
var  sex_num   time_allcausereadmi  age  hf_history ;
run;



/*Subsetting into female and male*/
data survdata1_draft7_nohis_f survdata1_draft7_nohis_m;
  set survdata1_draft7_nohis;
  if sex ='F' THEN output survdata1_draft7_nohis_f ;
  ELSE output survdata1_draft7_nohis_m;
RUN;



proc lifetest data=survdata1_draft7_nohis_f atrisk ;
time time_allcausereadmi*censor_allcausereadmi(1);
run;

proc lifetest data=survdata1_draft7_nohis_m atrisk ;
time time_allcausereadmi*censor_allcausereadmi(1);
run; 
