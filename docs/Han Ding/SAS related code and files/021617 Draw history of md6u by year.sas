/*021617 Draw history of md6u by year*/

data md6fmt;
 set hf_readm.md6;
   format admission_date MMDDYY10.;
   format discharge_date MMDDYY10.;
   format patient_birth_date MMDDYY10.;
run;

data md6_1st_stat;
    set md6fmt;
	keep Patient_ID ADMISSION_DATE PATIENT_BIRTH_DATE SEX RACE PRIME;
    by patient_id;
	if first.patient_id;
run;

/*subset md6_1st_stat n=238801 to create 
md6u_DX19history ,md6u_DX1history,  md6u_DX29history 
three subsets in total*/

/*Using Piduni_with_dx1to9history, Piduni_with_dx1history,
Piduni_with_dx2to9history to build*/


/*proc sql;
  create table test as
  select patient_id
  from md6_1st_stat
  intersect 
  select patient_id
  from Piduni_with_dx1to9history
quit;
 WRONG METHOD*/

DATA md6u_history;
  MERGE md6_1st_stat Piduni_with_dx1to9history(in = inPiduni_with_dx1to9history);
  by Patient_ID;
  if  (inPiduni_with_dx1to9history) THEN DX1to9_hf_history = 1;
  ELSE DX1to9_hf_history = 0;

  MERGE md6_1st_stat Piduni_with_dx1history(in = inPiduni_with_dx1history);
  by Patient_ID;
  if  (inPiduni_with_dx1history) THEN DX1_hf_history = 1;
  ELSE DX1_hf_history = 0;

  MERGE md6_1st_stat Piduni_with_dx2to9history(in = inPiduni_with_dx2to9history);
  by Patient_ID;
  if  (inPiduni_with_dx2to9history) THEN DX2to9_hf_history = 1;
  ELSE DX2to9_hf_history = 0;
RUN;

data md6u_history1;
  set md6u_history;
  admission_year = year(admission_date);
run;


title 'Comparing multiple types of HF history by admission year' ;
ODS HTML FILE='C:\Users\Work\Desktop\RWJ medical school Research projects\Heart_Failure_Readmission\Heart_Failure_Readmission\SAS_Library_HF\Results\history_by_year.html';  


proc freq data = md6u_history1;
  tables DX1to9_hf_history * admission_year/missing;
run;

proc freq data = md6u_history1;
  tables DX1_hf_history * admission_year/missing;
run;

proc freq data = md6u_history1;
  tables DX2to9_hf_history * admission_year/missing;
run;
quit;
  ODS HTML CLOSE;

  


