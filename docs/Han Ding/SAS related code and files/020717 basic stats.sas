/* md6 consists of two datasets, no_history and history
  we want to see some basic stats for md6 grouped by age and subsetted by sex
But md6 is multiple admission for a patient, so we first build the md6_1st dataset and then make stat on that*/

/* Build md6_1st_stat n= 238801*6 */

data md6_1st_stat;
    set hf_readm.md6;
	keep Patient_ID ADMISSION_DATE PATIENT_BIRTH_DATE SEX RACE PRIME;
    by patient_id;
	if first.patient_id;
run;

 
/* I want to add one variable named history into the md6_1st_stat n= 238801 based on no_history_1st n = 138086*/
data pid_No_history_1st;
  set No_history_1st;
  keep patient_id;
  /*rename patient_id = pid;*/
run;

/* Wrong method
data md6_1st_stat_his;
  set md6_1st_stat  ;
  hf_history =.;
  IF (PATIENT_ID IN pid_No_history_1st) THEN hf_history = 0;
  ELSE hf_history =1;
RUN; */

DATA md6_1st_stat_his;
  MERGE md6_1st_stat Pid_no_history_1st(in = inPid_no_history_1st);
  by Patient_ID;
  if  (inPid_no_history_1st) THEN hf_history = 1;
  ELSE hf_history = 0;
RUN;

/*tried too hard on others
DATA md6_1st_stat_his_age;
  SET md6_1st_stat_his;
  BY patient_id;
    age=intck('day','patient_birth_date' ,'admission_date' );
	PUT age =;
RUN; */

DATA md6_1st_stat_his_age;
  SET md6_1st_stat_his;
    age=YRDIF(patient_birth_date ,admission_date );
RUN;



DATA md6_1st_stat_his_age_f   md6_1st_stat_his_age_m;
  SET md6_1st_stat_his_age;
  IF (SEX = "F") THEN OUTPUT md6_1st_stat_his_age_f;
  ELSE OUTPUT md6_1st_stat_his_age_m;
RUN;


/*female stat*/
PROC FREQ DATA=md6_1st_stat_his_age_f;
  TABLES hf_history ;
RUN;

PROC FORMAT;
  VALUE $prime '008' = 'Others'
               'BLUE CROSS P' = 'Others'
			   'HMO'= 'Others'
               'medicaid'  = 'Medicaid/Self Pay'
			   'self pay'= 'Medicaid/Self Pay'
			   'medicare' = 'Medicare'
			   'COMMERCIAL' = 'Commercial';
RUN;


PROC FREQ DATA=md6_1st_stat_his_age_f;
  TABLES prime ;
  FORMAT prime $prime.;
RUN;


PROC FREQ DATA = md6_1st_stat_his_age_f;
  TABLES race / missing;
RUN;
/*Notice the missing race data here*/


PROC FORMAT;
  VALUE $race '1' = 'White'
              '2' = 'Black'
			  other = 'Other'
  ;
RUN;		  

PROC FREQ DATA=md6_1st_stat_his_age_f;
  TABLES race /missing;
  FORMAT race $race.;
RUN;


/*0-18
18-29
30-39
40-49
50-59
60-69
70-79
80+*/
PROC FREQ DATA=md6_1st_stat_his_age_f;
  TABLES AGE ;
RUN;

PROC FORMAT; 
  VALUE agegroup 18 -< 30 = '18-29'
                 30 -< 40 = '30-39'
				 40 -< 50 = '40-49'
				 50 -< 60 = '50-59'
				 60 -< 70 = '60-69'
				 70 -< 80 = '70-79'
				 80 -< 90 = '80-89'
				 90 -  high = '90+';
RUN;

PROC FREQ DATA=md6_1st_stat_his_age_f;
  TABLES age /missing;
  FORMAT age agegroup.;
RUN;






/*Male Stats*/
PROC FREQ DATA=md6_1st_stat_his_age_m;
  TABLES hf_history ;
RUN;

PROC FORMAT;
  VALUE $prime '008' = 'Others'
               'BLUE CROSS P' = 'Others'
			   'HMO'= 'Others'
               'medicaid'  = 'Medicaid/Self Pay'
			   'self pay'= 'Medicaid/Self Pay'
			   'medicare' = 'Medicare'
			   'COMMERCIAL' = 'Commercial';
RUN;


PROC FREQ DATA=md6_1st_stat_his_age_m;
  TABLES prime ;
  FORMAT prime $prime.;
RUN;


PROC FREQ DATA = md6_1st_stat_his_age_m;
  TABLES race / missing;
RUN;
/*Notice the missing race data here*/


PROC FORMAT;
  VALUE $race '1' = 'White'
              '2' = 'Black'
			  other = 'Other'
  ;
RUN;		  

PROC FREQ DATA=md6_1st_stat_his_age_m;
  TABLES race /missing;
  FORMAT race $race.;
RUN;


/*0-18
18-29
30-39
40-49
50-59
60-69
70-79
80+*/
PROC FREQ DATA=md6_1st_stat_his_age_m;
  TABLES AGE ;
RUN;

PROC FORMAT; 
  VALUE agegroup 18 -< 30 = '18-29'
                 30 -< 40 = '30-39'
				 40 -< 50 = '40-49'
				 50 -< 60 = '50-59'
				 60 -< 70 = '60-69'
				 70 -< 80 = '70-79'
				 80 -< 90 = '80-89'
				 90 -  high = '90+';
RUN;

PROC FREQ DATA=md6_1st_stat_his_age_m;
  TABLES age /missing;
  FORMAT age agegroup.;
RUN;







