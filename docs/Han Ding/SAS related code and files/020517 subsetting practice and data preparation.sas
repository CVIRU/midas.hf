LIBNAME HF_readm
'C:\Users\Work\Desktop\RWJ medical school Research projects\Heart_Failure_Readmission\Heart_Failure_Readmission\SAS_Library_HF';
/*proc datasets library=HF_readm nolist;
run; */
proc contents data=hf_readm.md6 (read=green) out=hf_readm.md6content;
   title  'The Contents of the md6 Data Set';
run;

data HF_readm.pidmd34u;
 set HF_readm.pidmd34u;
 keep x
run;

/*#Subset md6, keep only the observations whose patient id is not included in pidmd34u #100715, we got md8 (n=249299) */


PROC PRINT DATA = md6(keep = Patient_ID);
run;

PROC FREQ DATA=md6;
  TABLES PATIENT_BIRTH_DATE / MISSING ;
RUN;





/* This is the wrong method, we need to merge*/
data history not_history;
  set md6;
  if (Patient_ID in pidmd34u) THEN OUTPUT history;
  ELSE OUTPUT not_history;
run;

/*CHANGE THE VARIABLE NAME*/
DATA pidmd34u ;
 set pidmd34u (RENAME = (x = Patient_ID));
RUN;

proc sort data=md6 out=md6_pidsorted;
by Patient_ID;
run; 

data history no_history; /*no_history is md8, history is md11*/
merge md6_pidsorted Pidmd34u(in=inPidmd34u2);
by Patient_ID;
if (inPidmd34u2) THEN OUTPUT history;
ELSE OUTPUT no_history;
run; 


data no_history_1st;
    set no_history;
    by patient_id;
	if first.patient_id;
run;

 data history_1st;
    set history;
    by patient_id;
	if first.patient_id;
run;


 
  
