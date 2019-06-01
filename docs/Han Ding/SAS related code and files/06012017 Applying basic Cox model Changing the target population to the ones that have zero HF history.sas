/*06012017 Applying basic Cox model Changing the target population to the ones that have zero HF history*/
/*Based much on the code files below*/
*05032017 Categorical Variable addressing 2;

/*Purpose*/
*1. Applying basic Cox model Changing the target population to the ones that have zero HF history;
*2. Build the contrast that was mentioned by Kostis;


*Step1 : copy hf_readm.his_table_draft_b (n= 176855*7)and hf_readm.Survdata_allandhfcause_draft3(n=226185*46)
 to the work library;
 
*Join them;

data survdata_histable;
  merge hf_readm.Survdata_allandhfcause_draft3 hf_readm.his_table_draft_b;
  by patient_id;
run;

*deal with missing data;
data survdata_histable2;
  set survdata_histable;
  if his_diabetes = . then his_diabetes = 0;
  if his_hypertension = . then his_hypertension =  0;
  if his_chd = . then his_chd = 0;
  if his_ckd = . then his_ckd =0;
  if his_copd = . then his_copd= 0;
run;

* First, let's prepare the data well.;

* Define an variable admission_year;
data survdata_histable3;
  set survdata_histable2;
  admission_year= year(adm_date);
run;

* Define formats;
PROC FORMAT;
  VALUE $race '1' = 'White'
              '2' = 'Black'
			  other = 'Other Race'
              ;
RUN;	
proc format ;
  value $primefmt '008' = '4 Commercial'
                      'BLUE CROSS P' = '4 Commercial'
					  'HMO' = '4 Commercial'
					  'COMMERCIAL' = '4 Commercial'
					  'medicaid' = '3 Medicaid'
                      'self pay'  = '1 Self Pay'
					  'medicare' = '2 Medicare' 
					  ;
run;

/*KEY Step*/
/*Subset the survdata_histable3 to exclude patient with hf history*/
data survdata_histable4; /*131690*52*/
  set survdata_histable3;
  where hfhistory_dx1to9 =0;
run;

ods html;
proc freq data = survdata_histable4  ;
  tables  sex race prime/missing NOCUM;
  format race $race. prime $primefmt.;
run;

ods html close;

*E1;
proc phreg data = survdata_histable4;
format race $race. prime $primefmt.;
class sex race prime
      his_diabetes (ref = '0') his_hypertension (ref = '0') his_chd (ref = '0') 
      his_ckd (ref = '0') his_copd(ref = '0')/ param=ref;
model time_allcausereadmi*censor_allcausereadmi(0) = 
       age admission_year length_index_adm
       sex race  prime his_diabetes his_hypertension his_chd his_ckd his_copd
       ;
run;
quit;


*E2;
proc phreg data = survdata_histable4;
format race $race. prime $primefmt.;
class sex race prime
      his_diabetes (ref = '0') his_hypertension (ref = '0') his_chd (ref = '0') 
      his_ckd (ref = '0') his_copd(ref = '0')/ param=ref;
model  time_allcausedeath*censor_allcausedeath(0) = 
       age admission_year length_index_adm
       sex race  prime his_diabetes his_hypertension his_chd his_ckd his_copd
       ;
run;
quit;
*E3;
proc phreg data = survdata_histable4;
format race $race. prime $primefmt.;
class sex race prime
      his_diabetes (ref = '0') his_hypertension (ref = '0') his_chd (ref = '0') 
      his_ckd (ref = '0') his_copd(ref = '0')/ param=ref;
model time_allcause_readmordeath*censor_allcausereadmordeath(0) = 
       age admission_year length_index_adm
       sex race  prime his_diabetes his_hypertension his_chd his_ckd his_copd
       ;
run;
quit;
*E4;
proc phreg data = survdata_histable4;
format race $race. prime $primefmt.;
class sex race prime
      his_diabetes (ref = '0') his_hypertension (ref = '0') his_chd (ref = '0') 
      his_ckd (ref = '0') his_copd(ref = '0')/ param=ref;
model time_hfcausereadmi*censor_hfcausereadmi(0)  = 
       age admission_year length_index_adm
       sex race  prime his_diabetes his_hypertension his_chd his_ckd his_copd
       ;
run;
quit;
*E5;
proc phreg data = survdata_histable4;
format race $race. prime $primefmt.;
class sex race prime
      his_diabetes (ref = '0') his_hypertension (ref = '0') his_chd (ref = '0') 
      his_ckd (ref = '0') his_copd(ref = '0')/ param=ref;
model  time_hfcause_readmordeath*censor_hfcausereadmordeath(0) = 
       age admission_year length_index_adm
       sex race  prime his_diabetes his_hypertension his_chd his_ckd his_copd
       ;
run;
quit;


*Contrast;
*E1;
proc phreg data = survdata_histable4;
format race $race. prime $primefmt.;
class sex race prime
      his_diabetes (ref = '0') his_hypertension (ref = '0') his_chd (ref = '0') 
      his_ckd (ref = '0') his_copd(ref = '0')/ param=ref;
model time_allcausereadmi*censor_allcausereadmi(0) = 
       age admission_year length_index_adm
       sex|race prime his_diabetes his_hypertension|his_chd his_ckd his_copd
       ;
hazardratio 'H1' age / units=10 cl=both;
hazardratio 'H2' race/ diff=all at( sex = ALL);
hazardratio 'H3' SEX/ diff= all at (race = ALL);
hazardratio 'H4' his_hypertension/ diff = all at (his_chd =ALL);
hazardratio 'H5' his_chd/ diff= all at (his_hypertension=ALL);
run;
quit;

*E2;
proc phreg data = survdata_histable4;
format race $race. prime $primefmt.;
class sex race prime
      his_diabetes (ref = '0') his_hypertension (ref = '0') his_chd (ref = '0') 
      his_ckd (ref = '0') his_copd(ref = '0')/ param=ref;
model time_allcausedeath*censor_allcausedeath(0) = 
       age admission_year length_index_adm
       sex|race prime his_diabetes his_hypertension|his_chd his_ckd his_copd
       ;
hazardratio 'H1' age / units=10 cl=both;
hazardratio 'H2' race/ diff=all at( sex = ALL);
hazardratio 'H3' SEX/ diff= all at (race = ALL);
hazardratio 'H4' his_hypertension/ diff = all at (his_chd =ALL);
hazardratio 'H5' his_chd/ diff= all at (his_hypertension=ALL);
run;
quit;
*E3;
proc phreg data = survdata_histable4;
format race $race. prime $primefmt.;
class sex race prime
      his_diabetes (ref = '0') his_hypertension (ref = '0') his_chd (ref = '0') 
      his_ckd (ref = '0') his_copd(ref = '0')/ param=ref;
model time_allcause_readmordeath*censor_allcausereadmordeath(0) = 
       age admission_year length_index_adm
       sex|race prime his_diabetes his_hypertension|his_chd his_ckd his_copd
       ;
hazardratio 'H1' age / units=10 cl=both;
hazardratio 'H2' race/ diff=all at( sex = ALL);
hazardratio 'H3' SEX/ diff= all at (race = ALL);
hazardratio 'H4' his_hypertension/ diff = all at (his_chd =ALL);
hazardratio 'H5' his_chd/ diff= all at (his_hypertension=ALL);
run;
quit;
*E4;
proc phreg data = survdata_histable4;
format race $race. prime $primefmt.;
class sex race prime
      his_diabetes (ref = '0') his_hypertension (ref = '0') his_chd (ref = '0') 
      his_ckd (ref = '0') his_copd(ref = '0')/ param=ref;
model time_hfcausereadmi*censor_hfcausereadmi(0) = 
       age admission_year length_index_adm
       sex|race prime his_diabetes his_hypertension|his_chd his_ckd his_copd
       ;
hazardratio 'H1' age / units=10 cl=both;
hazardratio 'H2' race/ diff=all at( sex = ALL);
hazardratio 'H3' SEX/ diff= all at (race = ALL);
hazardratio 'H4' his_hypertension/ diff = all at (his_chd =ALL);
hazardratio 'H5' his_chd/ diff= all at (his_hypertension=ALL);
run;
quit;
*E5;
proc phreg data = survdata_histable4;
format race $race. prime $primefmt.;
class sex race prime
      his_diabetes (ref = '0') his_hypertension (ref = '0') his_chd (ref = '0') 
      his_ckd (ref = '0') his_copd(ref = '0')/ param=ref;
model time_hfcause_readmordeath*censor_hfcausereadmordeath(0) = 
       age admission_year length_index_adm
       sex|race prime his_diabetes his_hypertension|his_chd his_ckd his_copd
       ;
hazardratio 'H1' age / units=10 cl=both;
hazardratio 'H2' race/ diff=all at( sex = ALL);
hazardratio 'H3' SEX/ diff= all at (race = ALL);
hazardratio 'H4' his_hypertension/ diff = all at (his_chd =ALL);
hazardratio 'H5' his_chd/ diff= all at (his_hypertension=ALL);
run;
quit;
