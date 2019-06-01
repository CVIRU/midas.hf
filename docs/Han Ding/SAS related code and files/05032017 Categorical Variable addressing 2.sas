/*05032017 Categorical Variable addressing 2*/

/*Continueing the 04202017 Categorical Variable addressing*/
*First ,copy hf_readm.his_table_draft_b (n= 176855*7)and hf_readm.Survdata_allandhfcause_draft3(n=226185*46)
 to the work library;

**Something needs special notice here, the n of his_table_draft9 is 176855 some of the patients only only one admission record 
 and that admission is the index admission. Moreover, when we merge this 146855 rows history table with the 226185 rows of 
hf_readm.Survdata_allandhfcause_draft3, we need to be very careful.*/


*Now we have hf_readm.his_table_draft_b (n= 176855*7)and hf_readm.Survdata_allandhfcause_draft3(n=226185*46);
* We want to join the column of his_table_draft_b into Survdata_allandhfcause_draft3, when there is no such patient_id, we gave it a value of 0;

* Survdata_allandhfcause_draft3 Left Join his_table_draft_b;

data survdata_histable;
  merge hf_readm.Survdata_allandhfcause_draft3 hf_readm.his_table_draft_b;
  by patient_id;
run;

data survdata_histable2;
  set survdata_histable;
  if his_diabetes = . then his_diabetes = 0;
  if his_hypertension = . then his_hypertension =  0;
  if his_chd = . then his_chd = 0;
  if his_ckd = . then his_ckd =0;
  if his_copd = . then his_copd= 0;
run;

*Let's see what variables we need when we tryingt o fit a cox model;
* Categorical independent variables: sex L=2 race L=3 prime L =4
  his_diabetes L=2 his_hypertension L=2 his_chd L=2 his_ckd L=2 his_copd L=2;
* Numerical independent variables; 
* age admission_year length_index_adm;

* First, let's prepare the data well.;

* Define an variable admission_year;
data survdata_histable3;
  set survdata_histable2;
  admission_year= year(adm_date);
run;

*See the numerical variable's correlation;

proc corr data =survdata_histable3 plots(maxpoints=none) = matrix(histogram);
  var time_allcausereadmi age admission_year length_index_adm;
  run;

proc corr data =survdata_histable3 plots(maxpoints=none) = matrix(histogram);
  var his_diabetes his_hypertension his_chd his_ckd his_copd;
  run;

/*How to use a saved format*/
*Try 1;
libname hf_readm "C:\Users\Work\Desktop\RWJ medical school Research projects\Heart_Failure_Readmission\Heart_Failure_Readmission\SAS_Library_HF";

proc format library = hf_readm;
options fmtsearch = (hf_readm.formats work);
proc freq data = survdata_histable3;
  tables sex race prime;
  format race race. prime primefmt.;
run;

*Try2 ;

libname hf_readm 'C:\Users\Work\Desktop\RWJ medical school Research projects\Heart_Failure_Readmission\Heart_Failure_Readmission\SAS_Library_HF';
libname hf_fmt 'C:\Users\Work\Desktop\RWJ medical school Research projects\Heart_Failure_Readmission\Heart_Failure_Readmission\SAS_Library_HF\Formats';
options fmtsearch = (hf_fmt hf_readm hf_readm.Formats);

proc freq data = survdata_histable3;
  tables sex race prime;
  format race race. prime primefmt.;
run;


*Try3;

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

ods listing;
proc freq data = survdata_histable3  ;
  tables  sex race prime/missing NOCUM;
  format race $race. prime $primefmt.;
run;

ods listing close;


*Let us fit the cox model as a preliminary step;
*Event1;
ods html;
proc phreg data = survdata_histable3;
class sex race prime his_diabetes his_hypertension his_chd his_ckd his_copd;
model time_allcausereadmi*censor_allcausereadmi(0) = 
       age admission_year length_index_adm
       sex race prime his_diabetes his_hypertension his_chd his_ckd his_copd;
format race $race. prime $primefmt.;
run;
quit;



*Event2;
proc phreg data = survdata_histable3;
class sex race prime his_diabetes his_hypertension his_chd his_ckd his_copd;
model time_allcausedeath*censor_allcausedeath(0) = 
       age admission_year length_index_adm
       sex race prime his_diabetes his_hypertension his_chd his_ckd his_copd;
format race $race. prime $primefmt.;
run;
quit;
*Event3;
proc phreg data = survdata_histable3;
class sex race prime his_diabetes his_hypertension his_chd his_ckd his_copd;
model time_allcause_readmordeath*censor_allcausereadmordeath(0) = 
       age admission_year length_index_adm
       sex race prime his_diabetes his_hypertension his_chd his_ckd his_copd;
format race $race. prime $primefmt.;
run;
quit;
*Event4;
proc phreg data = survdata_histable3;
class sex race prime his_diabetes his_hypertension his_chd his_ckd his_copd;
model time_hfcausereadmi*censor_hfcausereadmi(0) = 
       age admission_year length_index_adm
       sex race prime his_diabetes his_hypertension his_chd his_ckd his_copd;
format race $race. prime $primefmt.;
run;
quit;
*Event5;
proc phreg data = survdata_histable3;
class sex race prime his_diabetes his_hypertension his_chd his_ckd his_copd;
model time_hfcause_readmordeath*censor_hfcausereadmordeath(0) = 
       age admission_year length_index_adm
       sex race prime his_diabetes his_hypertension his_chd his_ckd his_copd;
format race $race. prime $primefmt.;
run;
quit;


proc freq data = survdata_histable3;
  table prime;
  format prime $primefmt.;
run;
/*Continuing on 05082017*/
/*Step 1: Changing the ref level*/
*Step 2: Use hazardratio statement to find 10 years increase HR;
*Step 3:GENDER AND AGE COMBINATION;
* WM V WF   WM V BF  BM V BF  BM V WF;
/*Notice that we can't use hazardratio state ment to compare the combination of 
 categorical variables 
hazardratio 'H2' race/ at( sex = ALL);
hazardratio 'H3' sex/ at (race =ALL);
hazardratio 'H4'  his_chd / at (his_hypertension =ALL);
hazardratio 'H5' his_hypertension/ at (his_chd =ALL);
to get the result, remember to put interaction term in the model statement*/

/*Notice that the H2 H3 , we can use the hazardratio statement,
but for H4 H5, We must use the contrast statement*/


/*Use this code to get the overall HR of the 5 events*/
*E1;
proc phreg data = survdata_histable3;
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
proc phreg data = survdata_histable3;
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
proc phreg data = survdata_histable3;
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
proc phreg data = survdata_histable3;
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
proc phreg data = survdata_histable3;
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



/*
Addressing the last three contrasts

HYPERTENTION AND CHD VS HYPERTENTION AND NO-CHD
his_chd 0 vs 1 At his_hypertension=1 0.905 0.895 0.915 

HYPERTENTION AND CHD VS NO- HYPERTENTION AND CHD
his_hypertension 0 vs 1 At his_chd=1     0.856   0.838 0.875 

HYPERTENTION AND CHD VS NO- HYPERTENTION AND  NO- CHD

*/


/*Use this code to get contrast*/
*E1;
proc phreg data = survdata_histable3;
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
proc phreg data = survdata_histable3;
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
proc phreg data = survdata_histable3;
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
proc phreg data = survdata_histable3;
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
proc phreg data = survdata_histable3;
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

/*
proc phreg data = survdata_histable3;
format race $race. prime $primefmt.;
class sex race prime
      his_diabetes (ref = '0') his_hypertension (ref = '0') his_chd (ref = '0') 
      his_ckd (ref = '0') his_copd(ref = '0')/ param=ref;
model time_allcausereadmi*censor_allcausereadmi(0) = his_hypertension  his_chd  his_hypertension*his_chd 
      age admission_year length_index_adm sex|race prime his_diabetes his_copd
;
contrast 'test' his_hypertension 0 his_chd 0 his_hypertension*his_chd 1 /estimate = exp e;
run;
quit;
*/

