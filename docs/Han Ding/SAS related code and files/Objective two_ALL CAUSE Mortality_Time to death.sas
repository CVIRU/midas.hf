/*Objective two- ALL CAUSE Mortality- Time to death*/
/* 238801 each row for one patient
Patient_ID   time_all_death  censorship  sex(subset later) age  prime  race  history*/


/*Make our survival model needed data -  survdata2_draft1*/
data survdata2_draft1;
    set hf_readm.md6;
	keep Patient_ID SEX RACE PRIME PATIENT_BIRTH_DATE ADMISSION_DATE newdtd
    /*ADD history , age ,time_allcausedeath, censor_allcausedeath later*/;
run;

data survdata2_draft1_newdtd1;
    set survdata2_draft1;
    newdtd1 = input( newdtd, MMDDYY10.);
	format newdtd1 YYMMDD10.;
    /*ADD history , age ,time_allcausedeath, censor_allcausedeath later*/
run;

/*ADD in history */
data survdata2_draft2;
  merge survdata2_draft1_newdtd1 Pid_no_history_1st(in = inPid_no_history_1st);
  by Patient_ID;
  if  (inPid_no_history_1st) THEN hf_history = 1;
  ELSE hf_history = 0;
run;

/*ADD in age */
data survdata2_draft3;
  set survdata2_draft2;
    age=YRDIF(patient_birth_date ,admission_date );
RUN;
/*We actually just need the first admission here*/
data survdata2_draft4;
  set survdata2_draft3;
  by patient_id;
  if first.patient_id;
run;

/*NEWDTD1 IS missing in 84479 out of 238801 patient*/
PROC FREQ data = survdata2_draft4;
  TABLES newdtd1/ MISSING;
RUN;


/*Add in censor_allcausedeath time_allcausedeath*/
/*data survdata2_draft5;
  set survdata2_draft4;
  enddate_deathrecord = "12dec2014"d;
  censor_allcausedeath = 1;
  time_allcausedeath = DATDIF("12dec2014"d - admission_date);
  IF (.< newdtd1 )THEN DO ;
    censor_allcausedeath =0;
	time_allcausedeath = DATDIF(admission_date, newdtd1);
  END;
RUN;*/
 

data survdata2_draft5;
  set survdata2_draft4;
  time_allcausedeath = DATDIF(admission_date,"31dec2014"d, 'act/act');
  censor_allcausedeath = 1;
RUN;

data survdata2_draft6;
  set survdata2_draft5;
  IF (.< newdtd1 )THEN DO ;
    censor_allcausedeath =0;
	time_allcausedeath = DATDIF(admission_date, newdtd1, 'act/act');
  END;
RUN;


/*survdata2_draft6 is our dataset for objective 2*/
data survdata2_draft7;
  set hf_readm.survdata2_draft6;
  sex_num =0;
  IF (sex = 'F') THEN sex_num =1;
RUN;

data survdata2_draft7_nohis survdata2_draft7_his;
  set survdata2_draft7;
  if hf_history = 0 then output survdata2_draft7_nohis;/*100715*/
  else output survdata2_draft7_his;/*138086*/
run;

data survdata2_draft7_nohis_f survdata2_draft7_nohis_m;
  set survdata2_draft7_nohis;
  if sex ='F' THEN output survdata2_draft7_nohis_f ;
  ELSE output survdata2_draft7_nohis_m;
RUN;

proc lifetest data=survdata2_draft7_nohis_f atrisk plots=survival(cb);
time time_allcausedeath*censor_allcausedeath(1);
run;

proc lifetest data=survdata2_draft7_nohis_m atrisk plots=survival(cb);
time time_allcausedeath*censor_allcausedeath(1);
run; 
