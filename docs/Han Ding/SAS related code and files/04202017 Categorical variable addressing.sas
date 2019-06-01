/*04202017 Categorical variable addressing*/
*Format that we are using are: Race Primefmt;

*** Prepare data for the cox model;
*Cox model Sex age race prime admission_year length_index_adm
LOOK BACK FIVE YEARS FROM THE INDEX ADM_DATE 
usual susbpect: diabetes, hypertension, CKD, COPD and CHD.



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
I chose to use first four digits as '4140' as the definition of CHD

http://www.icd9data.com/2015/Volume1/390-459/410-414/414/default.htm
  Non-specific code 414 Other forms of chronic ischemic heart disease
Non-specific code 414.0 Coronary atherosclerosis
Specific code 414.00 Coronary atherosclerosis of unspecified type of vessel, native or graft convert 414.00 to ICD-10-CM
Specific code 414.01 Coronary atherosclerosis of native coronary artery convert 414.01 to ICD-10-CM
Specific code 414.02 Coronary atherosclerosis of autologous vein bypass graft convert 414.02 to ICD-10-CM
Specific code 414.03 Coronary atherosclerosis of nonautologous biological bypass graft convert 414.03 to ICD-10-CM
Specific code 414.04 Coronary atherosclerosis of artery bypass graft convert 414.04 to ICD-10-CM
Specific code 414.05 Coronary atherosclerosis of unspecified bypass graft convert 414.05 to ICD-10-CM
Specific code 414.06 Coronary atherosclerosis of native coronary artery of transplanted heart convert 414.06 to ICD-10-CM
Specific code 414.07 Coronary atherosclerosis of bypass graft (artery) (vein) of transplanted heart convert 414.07 to ICD-10-CM

 4 CKD
   Starting with '585'.
   c(585,
                                                  5851:5856,
                                                  5859)
 5 COPD
   Starting with '49'
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


*find the time table for each patient in Survdata_allandhfcause_draft3;
/*Method: from Alladm_vars_v6 we build a historical visit table for each patient that are in the Survdata_allandhfcause_draft3 */

*Get the pid in Survdata_allandhfcause_draft3;
data pid_s_allandhf_draft3;
  set hf_readm.Survdata_allandhfcause_draft3;
  keep patient_id;
run;

*Subset Alladm_vars_v6 by pid_s_allandhf_draft3;
proc sql; /*226887*/
  create table ct as 
  select count(distinct(patient_id)) as ncount
  from hf_readm.Alladm_vars_v6;
quit;
  


data his_table_draft1;
  merge hf_readm.Alladm_vars_v6(in = x) pid_s_allandhf_draft3(in = y);
  by patient_id;
  if x=1 and y=1;
run;


proc sql; /*226185*/
  create table ct2 as 
  select count(distinct(patient_id)) as ncount2
  from his_table_draft1;
quit;

data his_table_draft2;
  set his_table_draft1;
  d1 = intnx('year', dx1hf_firstadm_date ,-5,"sameday");
 format d1 MMDDYY10.;
run;

proc sql;
  create table his_table_draft3 as
  select * 
  from his_table_draft2
  where adm_date >d1 and adm_date < dx1hf_firstadm_date;
quit;

proc sql; /*176855 Notice that : some of the patients only only one admission record 
 and that admission is the index admission*/
  create table ct3 as 
  select count(distinct(patient_id)) as ncount3
  from his_table_draft3;
quit;

*Using this data his_table_draft3, we want to check whether a specific obs in the data's dx1-dx9
include diabetes or not;
*diabetes c(250, 2500:2509,25000:25093);
*check hf_readm.Diabeteslist_str;
data test;
  set his_table_draft3 hf_readm.Diabeteslist_str;
  array diagnosis_array {9} $7 DIAGNOSIS___PRINCIPAL_MAIN DIAGNOSIS___2ND_MAIN_CODE DIAGNOSIS___3RD_MAIN_CODE
                            DIAGNOSIS___4TH_MAIN_CODE DIAGNOSIS___5TH_MAIN_CODE DIAGNOSIS___6TH_MAIN_CODE
                            DIAGNOSIS___7TH_MAIN_CODE DIAGNOSIS___8TH_MAIN_CODE DIAGNOSIS___9TH_MAIN_CODE;
  array diabetelist_array {1} $8 diabeteslist_char;
  array diabete_in_array {9} ;
  do i =1 to 9 ;
    if diagnosis_array{i} in diabetelist_array  then diabete_in_array{i} =1;
	else diabete_in_array{i} =0;
  end;
run;

/*Something is wrong, mainly because diabeteslist_char variable that loaded into the data is a missing value*/

 *try another method;


data test2; 
  set his_table_draft3 hf_readm.Diabeteslist_str;
  match = 0;
  if DIAGNOSIS___PRINCIPAL_MAIN in diabeteslist_char
    THEN match = 1;
run;


/*Not working since diabeteslist_char is not an array*/

/*The SQL approach example*/
DATA CODES;
    DO CODE=1 TO 100;
        OUTPUT;
    END;
RUN;

DATA MY_CODES;
    DO CODE=50 TO 150;
        OUTPUT;
    END;
RUN;

Proc sql;
Create Table Check as
select a.*, case when a.code=b.code then 1
                else 0 end as match
from MY_CODES a
left join codes b
on a.code=b.code;
quit;



/*****************DO NOT NEED TO RUN START***************/
/*My SQL approach test code*/
proc sql;
  create table check2 as
  select a.*, case when a.DIAGNOSIS___PRINCIPAL_MAIN = b.diabeteslist_char then 1
                   else 0 end as match
  from his_table_draft3 a
  left join hf_readm.Diabeteslist_str b
  on a.DIAGNOSIS___PRINCIPAL_MAIN = b.diabeteslist_char;
quit;


proc freq data = check2;
 table match;
run;
/*All match is zero*/



/*My 2nd SQL approach test code*/


proc sql;
  create table check3 as
  select a.*, case when a.DIAGNOSIS___PRINCIPAL_MAIN = b.diabeteslist_char then 1
                   else 0 end as match
  from his_table_draft3 a, hf_readm.Diabeteslist_str b
  where a.DIAGNOSIS___PRINCIPAL_MAIN = b.diabeteslist_char;
quit;

/*Check3 is empty rows*/

/*****************DO NOT NEED TO RUN END***************/

/*Use substring and array*/

data his_table_draft4;
  set his_table_draft3;
  array diagnosis_array {9} $7 DIAGNOSIS___PRINCIPAL_MAIN DIAGNOSIS___2ND_MAIN_CODE DIAGNOSIS___3RD_MAIN_CODE
                            DIAGNOSIS___4TH_MAIN_CODE DIAGNOSIS___5TH_MAIN_CODE DIAGNOSIS___6TH_MAIN_CODE
                            DIAGNOSIS___7TH_MAIN_CODE DIAGNOSIS___8TH_MAIN_CODE DIAGNOSIS___9TH_MAIN_CODE;
  array diabetesflag_dx {9};
do i = 1 to 9;
  if substr(diagnosis_array{i},1,3) = '250' then diabetesflag_dx{i}=1;
  else diabetesflag_dx{i}=0;
end;
run;

/*Result is right, success*/

/*Now addressing the hypertension, in ICD9 code, if the first 2 digits are 40,
  then I consider it a hypertension*/

data his_table_draft5;
  set his_table_draft4;
  array diagnosis_array {9} $7 DIAGNOSIS___PRINCIPAL_MAIN DIAGNOSIS___2ND_MAIN_CODE DIAGNOSIS___3RD_MAIN_CODE
                            DIAGNOSIS___4TH_MAIN_CODE DIAGNOSIS___5TH_MAIN_CODE DIAGNOSIS___6TH_MAIN_CODE
                            DIAGNOSIS___7TH_MAIN_CODE DIAGNOSIS___8TH_MAIN_CODE DIAGNOSIS___9TH_MAIN_CODE;
  array hypertensionflag_dx {9};
  do i = 1 to 9;
    if substr( diagnosis_array{i},1,2) = '40' then hypertensionflag_dx{i} =1;
	else hypertensionflag_dx{i} = 0;
  end;
run;
/*Result is right, success*/


/*Addressing CHD 
I chose to use first four digits as '4140' as the definition of CHD*/

  

data his_table_draft6;
  set his_table_draft5;
  array diagnosis_array {9} $7 DIAGNOSIS___PRINCIPAL_MAIN DIAGNOSIS___2ND_MAIN_CODE DIAGNOSIS___3RD_MAIN_CODE
                            DIAGNOSIS___4TH_MAIN_CODE DIAGNOSIS___5TH_MAIN_CODE DIAGNOSIS___6TH_MAIN_CODE
                            DIAGNOSIS___7TH_MAIN_CODE DIAGNOSIS___8TH_MAIN_CODE DIAGNOSIS___9TH_MAIN_CODE;
  array chdflag_dx {9};
  do i = 1 to 9;
    if substr( diagnosis_array{i},1,4) = '4140' then chdflag_dx{i} =1;
	else chdflag_dx{i} = 0;
  end;
run;

/*Addressing CKD  Starting with '585' and COPD Starting with '49'*/
data his_table_draft7;
   set his_table_draft6;
   array diagnosis_array {9} $7 DIAGNOSIS___PRINCIPAL_MAIN DIAGNOSIS___2ND_MAIN_CODE DIAGNOSIS___3RD_MAIN_CODE
                            DIAGNOSIS___4TH_MAIN_CODE DIAGNOSIS___5TH_MAIN_CODE DIAGNOSIS___6TH_MAIN_CODE
                            DIAGNOSIS___7TH_MAIN_CODE DIAGNOSIS___8TH_MAIN_CODE DIAGNOSIS___9TH_MAIN_CODE;
   array ckdflag_dx {9};
   array copdflag_dx {9};
   do i = 1 to 9;
   if substr( diagnosis_array{i},1,3) = '585' then ckdflag_dx{i} =1;
   else ckdflag_dx{i} =0;
   if substr( diagnosis_array{i},1,2) = '49' then copdflag_dx{i} =1;
   else copdflag_dx{i} =0;
   end;
run;


*Now we have the flag variables for diabete, hypertension, CHD, CKD & COPD, For each obs we find the max of
  the array of these 5 disease;
data his_table_draft8;
  set his_table_draft7;
  array diabetesflag_dx {9} ;
  array hypertensionflag_dx {9};
  array chdflag_dx {9}; 
  array ckdflag_dx {9};
  array copdflag_dx {9};
  diabetesflag_yes = max( of diabetesflag_dx{*});
  hypertensionflag_yes = max( of hypertensionflag_dx{*});
  chdflag_yes = max( of chdflag_dx{*});
  ckdflag_yes = max( of ckdflag_dx{*});
  copdflag_yes = max( of copdflag_dx{*});
run;

data his_table_draft9; /*n=176855*84*/
  set his_table_draft8;
  by patient_id;
  if first.patient_id then 
    do; 
      diabetesflag_yesnumber = 0 ;
      hypertensionflag_yesnumber =0;
      chdflag_yesnumber =0;
	  ckdflag_yesnumber =0;
	  copdflag_yesnumber =0;
    end;
  
  diabetesflag_yesnumber + diabetesflag_yes;
  hypertensionflag_yesnumber + hypertensionflag_yes;
  chdflag_yesnumber +chdflag_yes;
  ckdflag_yesnumber + ckdflag_yes;
  copdflag_yesnumber +copdflag_yes;
  if last.patient_id;

run;

*We only keep several columns here;

data his_table_draft_a(keep= patient_id rownum_in_mda 
     diabetesflag_yesnumber hypertensionflag_yesnumber chdflag_yesnumber  ckdflag_yesnumber copdflag_yesnumber
     his_diabetes his_hypertension his_chd his_ckd his_copd); /*n=176855*84*/
  set his_table_draft9;
  if diabetesflag_yesnumber >0 then his_diabetes =1;
  else his_diabetes =0;
  if hypertensionflag_yesnumber >0 then his_hypertension =1;
  else his_hypertension =0; 
  if chdflag_yesnumber >0 then his_chd =1;
  else his_chd =0;
  if ckdflag_yesnumber >0 then his_ckd =1;
  else his_ckd =0;
  if copdflag_yesnumber >0 then his_copd =1;
  else his_copd =0;
run;
 
data hf_readm.his_table_draft_b; /*n= 176855*7*/
  set his_table_draft_a;
  keep patient_id rownum_in_mda  his_diabetes his_hypertension his_chd his_ckd his_copd;
run;


*Something needs special notice here, the n of his_table_draft9 is 176855 some of the patients only only one admission record 
 and that admission is the index admission. Moreover, when we merge this 146855 rows history table with the 226185 rows of 
hf_readm.Survdata_allandhfcause_draft3, we need to be very careful.*/


*Now we have hf_readm.his_table_draft_b (n= 176855*7)and hf_readm.Survdata_allandhfcause_draft3(n=226185*46);
* We want to join the column of his_table_draft_b into Survdata_allandhfcause_draft3, when there is no such patient_id, we gave it a value of 0;

/*Go to 05032017 Categorical Variable addressing 2*/












