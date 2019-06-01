/*02202017 Subsetting the mda for all caused readmission*/
/*Change format on admission_date, discharge_date, patient_birth_date, newdtd*/
/*New variables are named adm_date,birth_date,death_date,discharge_date1*/
/*NOTICE THAT WE NEED TO USE MDA2, NOT MDA*/

data work.md_format;
  set hf_readm.mda2;
   adm_date = input (admission_date ,MMDDYY10.);
   format adm_date MMDDYY10.;

   birth_date = input (patient_birth_date ,MMDDYY10.);
   format birth_date MMDDYY10.;

   death_date = input (newdtd ,MMDDYY10.);
   format death_date MMDDYY10.;

   discharge_date1 = input (discharge_date ,MMDDYY10.);
   format discharge_date1 MMDDYY10.;

run;

/*Exclude admissions that <18 years old when 2000*/
proc sql;
  create table md_adult as /*17438660* 53*/
  select *
  from md_format
  where birth_date < '01JAN1982'd;
quit;


/*PURPOSE:
Identify all of the pid that admissions that that have any HF in his DIAGNOSIS___PRINCIPAL_MAIN*/
/*METHOD: 
SUBSETTING BY CREATING AN VARIABLE CALLED DX1_HF*/
data md_dx1hf;
  set md_adult; 
   if (DIAGNOSIS___PRINCIPAL_MAIN in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then DX1_HF = 1;
 else DX1_HF = 0;
run;


/*4.01% of all admissions have HF in their DX1*/
/*
   proc freq data = md_dx1hf;  
  tables DX1_HF/ missing;
run;
*/

/*keeping only the admissions that have HF*/
data md_dx1hfyes; /*698892 *54 */
  set md_dx1hf;
  where dx1_hf =1;
run;

/*We also wanna subset the admissions that are within 2000-2013 window*/
/*472952*54*/
data md_dx1hfyes_00to13;
  set md_dx1hfyes;
  where adm_date between "01JAN2000"d and "12DEC2013"d;
run;

/*get the unique pid that we want to use to subset md_dx1hf*/
data md_dx1hfyes_00to13_pidu (keep = patient_id); /* 237987*/
  set md_dx1hfyes_00to13;
  by patient_id;
  if first.patient_id;
run;

/*get all of md_dx1hfyes_00to13_pidu associated rows from md_dx1hf*/

/* Don't run, this will make the PC die
proc sql;
  
  select * 
    from md_dx1hf
	having patient_id = any
	  (select patient_id 
	    from md_dx1hfyes_pidu);
quit;
*/

/*Try data merge First sort both data*/
/*This method works perfectly*/

proc sort data = md_dx1hf;
  by patient_id;
run;

/*md_dx1hfyes_00to13_pidu   237987   is the unique number of patient that we care about*/
/*Notice that this number is slightly different than the number that I got from R which is 238801*/

proc sort data = md_dx1hfyes_00to13_pidu;
  by patient_id;
run;

/*2,811,809 *54 */
/*md_dx1hfyes_allrows is all of the admissions
 that 18 years old, 2000-2013 admitted for HF in 
DX1's patients'  through out all midas database*/
data md_dx1hfyes_allrows;
  merge md_dx1hf(in = x) md_dx1hfyes_00to13_pidu(in = y);
  by patient_id;
  if x=1 and y=1;
run;

/*Cancer deduction*/
/*Among md_dx1hfyes_allrows, we find all rows that have any cancer in dx1-9, we get the 
pid of these rows and delete the rows associated with these patients from Md_dx1hfyes_00to13 */


/*Making a char list of the cancer codes that I want to exclude*/

/*
data hf_readm.cancerlist_chr;
  input cancerchr $ @@;
cards;
2390 2391 2392 2393 2394 2395 2396 2397 2398 23981 23989 2399 
1400 1401 1403 1404 1405 1406 1408 1409
;

proc print data= cancerlist_chr;
  title 'double trailing @@';
run;
*/

ods html close; /* close previous */
ods html; /* open new */
/*Check whether my codes in the cancerlist_chr exist in md_dx1hfyes_allrows, yes confirmed*/
/*proc freq data = md_dx1hfyes_allrows;
  tables DIAGNOSIS___PRINCIPAL_MAIN/ missing;
run;*/

/*make cancer1 - cancer9  9 variables to identify each rows that have any of the cancer*/

  
data md_dx1hfyes_allrows_cancer1to9; /* */
  set md_dx1hfyes_allrows;
  if (DIAGNOSIS___PRINCIPAL_MAIN in ("2390","2391","2392","2393","2394","2395","2396",
"2397","2398","23981","23989","2399","1400","1401","1403","1404","1405","1406","1408","1409"))
 then dx1 = 1;
  else dx1 = 0;

   if (DIAGNOSIS___2ND_MAIN_CODE in ("2390","2391","2392","2393","2394","2395","2396",
"2397","2398","23981","23989","2399","1400","1401","1403","1404","1405","1406","1408","1409"))
 then dx2 = 1;
  else dx2 = 0;
  
   if (DIAGNOSIS___3RD_MAIN_CODE in ("2390","2391","2392","2393","2394","2395","2396",
"2397","2398","23981","23989","2399","1400","1401","1403","1404","1405","1406","1408","1409"))
 then dx3 = 1;
  else dx3 = 0;

  
   if (DIAGNOSIS___4TH_MAIN_CODE in ("2390","2391","2392","2393","2394","2395","2396",
"2397","2398","23981","23989","2399","1400","1401","1403","1404","1405","1406","1408","1409"))
 then dx4 = 1;
  else dx4 = 0;

   if (DIAGNOSIS___5TH_MAIN_CODE in ("2390","2391","2392","2393","2394","2395","2396",
"2397","2398","23981","23989","2399","1400","1401","1403","1404","1405","1406","1408","1409"))
 then dx5 = 1;
  else dx5 = 0;
  
   if (DIAGNOSIS___6TH_MAIN_CODE in ("2390","2391","2392","2393","2394","2395","2396",
"2397","2398","23981","23989","2399","1400","1401","1403","1404","1405","1406","1408","1409"))
 then dx6 = 1;
  else dx6 = 0;
  
   if (DIAGNOSIS___7TH_MAIN_CODE in("2390","2391","2392","2393","2394","2395","2396",
"2397","2398","23981","23989","2399","1400","1401","1403","1404","1405","1406","1408","1409"))
 then dx7 = 1;
  else dx7 = 0;
  
   if (DIAGNOSIS___8TH_MAIN_CODE in ("2390","2391","2392","2393","2394","2395","2396",
"2397","2398","23981","23989","2399","1400","1401","1403","1404","1405","1406","1408","1409"))
 then dx8 = 1;
  else dx8 = 0;
  
   if (DIAGNOSIS___9TH_MAIN_CODE in ("2390","2391","2392","2393","2394","2395","2396",
"2397","2398","23981","23989","2399","1400","1401","1403","1404","1405","1406","1408","1409"))
 then dx9 = 1;
  else dx9 = 0;
  run; 

  proc sql;
  create table md_dx1hfyes_allrows_cancer1to9s as 
    select *, sum(dx1,dx2,dx3,dx4,dx5,dx6,dx7,dx8,dx9) as dx1to9cancerhistory
	from md_dx1hfyes_allrows_cancer1to9;
quit;

/*99.9% of the rows don't contain any cancer*/
/*proc freq data = md_dx1hfyes_allrows_cancer1to9s; 
  tables dx1to9cancerhistory/missing;
run;*/

/*Find out unique pid that has cancer history   -- n = 1730*/
proc sql;
  create table pid_w_cancer as
  select patient_id
  from md_dx1hfyes_allrows_cancer1to9s
  where dx1to9cancerhistory>0;
quit;

data pidu_w_cancer;
  set pid_w_cancer;
  by patient_id;
  if first.patient_id;
run;


/*merge md_dx1hfyes_allrows n=2811809*54 & pidu_w_cancer n = 1730*1 */
data md_dx1hfyes_allrows_nocancer; /*2780186 *54*/
  merge md_dx1hfyes_allrows(in = x) pidu_w_cancer(in = y);
  by patient_id;
  if x=1 and y=0;
run;

/*Check step: Eyeballing
md_dx1hfyes_allrows_nocancer vs Md_dx1hfyes_allrows, PASS
*/

/*save this data to hf_readm library*/
data hf_readm.alladm;  /*Should be 2780186 *54*/
  set md_dx1hfyes_allrows_nocancer;
run;


/************************************************************************/


/*We can directly work from here*/
/*subsets only the variables that we may need */
/*alladm_vars  n= 2780186*22*/
data alladm_vars;
  set hf_readm.alladm;
  keep rownum_in_mda patient_id adm_date birth_date death_date discharge_date1
       DIAGNOSIS___PRINCIPAL_MAIN DIAGNOSIS___2ND_MAIN_CODE DIAGNOSIS___3RD_MAIN_CODE
       DIAGNOSIS___4TH_MAIN_CODE DIAGNOSIS___5TH_MAIN_CODE DIAGNOSIS___6TH_MAIN_CODE
	   DIAGNOSIS___7TH_MAIN_CODE DIAGNOSIS___8TH_MAIN_CODE DIAGNOSIS___9TH_MAIN_CODE
       cause deathrnum status sex race prime dx1_hf;
run;

/*For each patient's record, we want to make several variables to help us proceed
  first_dx1hf_00to13
  second_adm
  second_dx1hfadm
*/

/*Noticing that the variable dx1_hf means any dx1_hf in any year, not only in 2000-2013 period */
data dx1hf_00to13;/*469155 which is <472952 of md_dx1hfyes_00to13 because we removed cancer */
  set alladm_vars; /*2780186*/
  where dx1_hf =1 AND adm_date between "01JAN2000"d and "12DEC2013"d;
run;

/*get the first rows of dx1hf_00to13, and the group is the patients that we need to make data on*/
/*dx1hf_00to13_1st is the data that for each patient's first HF caused admission in 2000-2013*/
data dx1hf_00to13_1st; /*236257*22*/
  set dx1hf_00to13;
  by patient_id;
  if first.patient_id;
run;

data dx1hf_00to13_1st_rownum;
  set dx1hf_00to13_1st;
  keep rownum_in_mda;
run;



/*alladm_vars_v1 is alladm_vars + dx1hf_firstadm(binary) indicator variable*/
/*dx1hf_firstadm means whether it's the first dx1 hf admission in our study period */
/*alladm_vars_v1 is a data that adds another variable named dx1hf_firstadm to alladm_vars*/
/*2780186 * 23 */
data alladm_vars_v1;
  merge alladm_vars  dx1hf_00to13_1st_rownum(in = indx1hf_00to13_1st_rownum);
  by rownum_in_mda;
  if (indx1hf_00to13_1st_rownum) then dx1hf_firstadm =1;
  else dx1hf_firstadm=0;
run;

/*Now we address the HF history variables first. we intend to add two variables
 1. dx1to9hfhistory  2. dx2to9hfhistory*/
/*In order to achieve so, we make d1 to d2 history window for each patient*/
/*NOTICE: in alladm_vars_v1_freq the rows within each patient is changed from alladm_vars_v1*/
Proc SQL ;
     Create table alladm_vars_v1_freq as
          select *, count (patient_id) as count
          From alladm_vars_v1
          Group by patient_id
     ;
Quit ;


data freq (keep= count);
  set alladm_vars_v1_freq;
  by patient_id;
  if first.patient_id;
run;

data d2( keep = adm_date);
  set Dx1hf_00to13_1st;
run;

data d2freq;
 set d2;
 set freq;
run;

data d2freq_repeat; /*n= 2780186*/

  set d2freq;
  do i=1 to count;
    output;
  end;
  drop i;
  rename adm_date = d2;
run;

data d1d2freq_repeat(drop = count);/*2780186*/
 set d2freq_repeat;
 d1 = intnx('year',d2,-5,"sameday");
 format d1 MMDDYY10.;
run;

/*we use alladm_vars_d1d2 to address the HF history variables*/
data alladm_vars_d1d2;
  set alladm_vars_v1;
  set d1d2freq_repeat;
run;

/*Subset alladm_vars_d1d2 using d1 to d2 time windows*/
proc sql;
  create table alladm_vars_d1d2subset as /*798885 * 25*/
  select *
  from alladm_vars_d1d2
  where adm_date >d1 and adm_date < d2;
quit;

/*we want two types of history 1st is hfhistory_dx1to9;
2nd is hfhistory_dx2to9*/

data alladm_vars_d1d2subset_his1; /* 798885*34 */
  set alladm_vars_d1d2subset;
  if (DIAGNOSIS___PRINCIPAL_MAIN in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then hfhistory_dx1 = 1;
  else hfhistory_dx1 = 0;

   if (DIAGNOSIS___2ND_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then hfhistory_dx2 = 1;
  else hfhistory_dx2 = 0;
  
   if (DIAGNOSIS___3RD_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then hfhistory_dx3 = 1;
  else hfhistory_dx3 = 0;

  
   if (DIAGNOSIS___4TH_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then hfhistory_dx4 = 1;
  else hfhistory_dx4 = 0;

   if (DIAGNOSIS___5TH_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then hfhistory_dx5 = 1;
  else hfhistory_dx5 = 0;
  
   if (DIAGNOSIS___6TH_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then hfhistory_dx6 = 1;
  else hfhistory_dx6 = 0;
  
   if (DIAGNOSIS___7TH_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then hfhistory_dx7 = 1;
  else hfhistory_dx7 = 0;
  
   if (DIAGNOSIS___8TH_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then hfhistory_dx8 = 1;
  else hfhistory_dx8 = 0;
  
   if (DIAGNOSIS___9TH_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then hfhistory_dx9 = 1;
  else hfhistory_dx9 = 0;

run; 

/*dx1to9 */
proc sql;
  create table alladm_vars_d1d2subset_his2 as /*798885*35*/
    select *, sum(hfhistory_dx1,hfhistory_dx2,hfhistory_dx3,hfhistory_dx4,hfhistory_dx5,
    hfhistory_dx6,hfhistory_dx7,hfhistory_dx8,hfhistory_dx9) 
    as hfhistory_dx1to9
	from alladm_vars_d1d2subset_his1;
quit;


proc sql;
  create table alladm_vars_d1d2subset_his3 as /*798885*36*/
    select *, sum(hfhistory_dx2,hfhistory_dx3,hfhistory_dx4,hfhistory_dx5,
    hfhistory_dx6,hfhistory_dx7,hfhistory_dx8,hfhistory_dx9) 
    as hfhistory_dx2to9
	from alladm_vars_d1d2subset_his2;
quit;

/*from alladm_vars_d1d2subset_his3, we get the pid that have hf history*/

/*first type of hf history dx1-9*/
proc sql;
  create table pid_with_hfhistory_dx1to9 as /*n= 227992*/
    select patient_id
	from alladm_vars_d1d2subset_his3
	where hfhistory_dx1to9 >0;
quit;

data hf_readm.pidu_with_hfhistory_dx1to9;/*99634 *//*SAVE*/
  set pid_with_hfhistory_dx1to9;
  by patient_id;
  if first.patient_id;
run;

/*second type of hf history dx2-9*/
proc sql;
  create table pid_with_hfhistory_dx2to9 as /*n= 201083*/
    select patient_id
	from alladm_vars_d1d2subset_his3
	where hfhistory_dx2to9 >0;
quit;

data hf_readm.pidu_with_hfhistory_dx2to9;/*n= 95989*//*SAVE*/
  set pid_with_hfhistory_dx2to9;
  by patient_id;
  if first.patient_id;
run;

/*Now merge pidu_with_hfhistory_dx1to9 & pid_with_hfhistory_dx2to9 into
 Alladm_vars_v1*/
data alladm_vars_v2;
  merge Alladm_vars_v1  hf_readm.pidu_with_hfhistory_dx1to9
        (in =inpidu_with_hfhistory_dx1to9);
  by patient_id;
  if ( inpidu_with_hfhistory_dx1to9 ) then hfhistory_dx1to9 =1;
  else hfhistory_dx1to9=0;
run;


data alladm_vars_v3;
  merge alladm_vars_v2  hf_readm.pidu_with_hfhistory_dx2to9
        (in =inpidu_with_hfhistory_dx2to9);
  by patient_id;
  if ( inpidu_with_hfhistory_dx2to9 ) then hfhistory_dx2to9 =1;
  else hfhistory_dx2to9=0;
run;


/*Here we add d2 inside the hf_readm.alladm_vars_v3, rename d2 = dx1hf_firstadm_date*/
data hf_readm.alladm_vars_v4;
  set alladm_vars_v3;
  set D2freq_repeat;
  drop count;
  rename d2 =dx1hf_firstadm_date;
run;





/*Now the dataset hf_readm.alladm_vars_v3 have all the information that we need*/

/*FIRST , WE DECIDE TO WORK ON PATIENTS THAT DON'T HAVE ANY DX1-9 HF HISTORY
  BEFORE THEIR FIRST DX1 HF ADMISSION IN 2000-2013
  THESE PATIENT ARE >18 YEARS OLD AND NEVER HAD CANCER IN MIDAS*/



/****************************************************/
/*Remember to consider history or not history later*/
/****************************************************/


/******OBJECTIVE ONE: MAKING THE ALL CAUSE READMISSION DATA****************************************************************************/
/*SUBSET TO KEEP ONLY THE ADMISSION FOR EACH PATIENT THAT IS ON OR AFTER 
dx1hf_firstadm_date */
data adms_onorafter_1stHF;  /*1556920*26*/
  set hf_readm.alladm_vars_v4;
  where adm_date >= dx1hf_firstadm_date;
run;

/** UNIQUE PATIENT NUMBER IS 236257**/
/*data survdata_allcause_draft1; 
  set adms_onorafter_1stHF;
  by patient_id;
  if first.patient_id;
run;*/

data pid_onceormultiple;
  set adms_onorafter_1stHF;
  keep patient_id;
run;

data pid_multiple;  /*1516031*/
  set pid_onceormultiple;
  by patient_id;
  if first.patient_id and last.patient_id then delete;
run;


data pid_multiple_unique;  /*195368*/
  set pid_multiple;
  by patient_id;
  if first.patient_id;
run;
/*0/n= 40889  ; 1/n=195368 */

/*we add one variable multipleadmi to adms_onorafter_1stHF */
data survdata_allcause_draft2; /*1556920*27*/
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


/*We seperately working on two type of patients
 1. survdata_allcause_once 40889*27
 2. survdata_allcause_multiple 1516031*27 */

/*IF there is only one row for a patient_id in survdata_allcause_draft2
  2-1/ IF the death_date is missing or it's after the end date, 
       THEN time_allcause_readmi <- end of study date - 1st admission date,
       we censored it on the end of study date Dec 31 2013
  2-2/ IF the death_date is before the end date, 
       THEN time_allcause_readmi <- death_date- 1st admission date, 
       we censored it on the death_date*/

data survdata_allcause_once2;/* 40889*29*/
 set survdata_allcause_once;
 censor_allcausereadmi = 1;
 IF(. <death_date< "31dec2013"d) 
   THEN time_allcausereadmi = DATDIF(adm_date, death_date,'act/act');
 ELSE time_allcausereadmi = DATDIF(adm_date,"31dec2013"d , 'act/act');
RUN;

data survdata_allcause_multiple_2;/* 195368*2*/
  set survdata_allcause_multiple;
  count +1;
  by patient_id adm_date;
  if FIRST.patient_id then count =1;
  if count =2 then output;
  keep patient_id adm_date;
  rename adm_date= second_admission_date;
run;

data survdata_allcause_multiple_3; /*195368*27*/
  set survdata_allcause_multiple;
  by patient_id;
  if first.patient_id;
run;

data survdata_allcause_multiple_4;
  merge survdata_allcause_multiple_3  survdata_allcause_multiple_2;
  by patient_id;
run;

/*IF there is more than one rows for a patient_id in survdata_allcause_draft2  
  1-1/ IF the death_date is missing or it's after the second admission
       THEN  time_allcausereadmi <- 2nd admition_date - 1st admission_date & censorship <- 0
  1-2/ IF the death_date is between the two admission date, then death_date must be before end of study date
       then we censored it on the death_date ( but I doubt this situation's exist or not?)*/

data survdata_allcause_multiple_5;
  set survdata_allcause_multiple_4;
  time_allcausereadmi = DATDIF(adm_date, second_admission_date, 'act/act');
  censor_allcausereadmi = 0;
run;

data survdata_allcause_multiple_6;/*195368*30*/
  set survdata_allcause_multiple_5;
  IF ( adm_date<death_date<second_admission_date) THEN DO;
   censor_allcausereadmi = 1;
   time_allcausereadmi= DATDIF(adm_date, death_date, 'act/act');
  END;
RUN;

data survdata_allcause_draft3; /*236257*30*/
     merge survdata_allcause_multiple_6   survdata_allcause_once2;
	 by patient_id;
run;

data survdata_allcause_draft4;
  set survdata_allcause_draft3;
  age = YRDIF(birth_date, adm_date, 'act/act');
  female = 0;
  IF (sex = 'F') THEN female =1;
run;

/*subset survdata_allcause_draft4 the non-hf history population*/
/*survdata_allcause_draft5 n =136623*32*/
data survdata_allcause_draft5;
  set survdata_allcause_draft4;
  where hfhistory_dx1to9 = 0;
run;

/*proc corr data = survdata_allcause_draft4 
plots(maxpoints=none)=matrix(histogram);
var  female   time_allcausereadmi  age  hfhistory_dx1to9 ;
run;*/


/*ods graphics on;
proc lifetest data=survdata_allcause_draft5 plots=survival(atrisk) ;
time time_allcausereadmi*censor_allcausereadmi(1);
strata sex;
run;
ods graphics off;
*/


/***Objective two: ALL CAUSE MORTALITY -TIME TO DEATH****************

/*bUILDING survdata_allcause_draft6 which adds 2 additional
 variables to survdata_allcause_draft5, 1st is time_allcausedeath
 2nd is censor_allcausedeath*/


/* Objective two- ALL CAUSE Mortality- Time to death*/
/* 
NO MATTER HOW MANY ROWS has for a patient_id in md6, we don't need censorship here, 
since we care about the death trend, end of study date is not important
  IF the newdtd is before the end of study date
       THEN time_all_death <- newdtd - 1st admission date, censor = 0
  IF the newdtd is after the end of study date 
       THEN time_all_death <- newdtd - 1st admission date, censor = 0

  IF the newdtd is missing
       THEN time_all_death <- 2014-12-31 - 1st admission date, censor =1
*/

data survdata_allcause_draft6;
  set survdata_allcause_draft5;
  time_allcausedeath = DATDIF(adm_date,"31dec2014"d, 'act/act');
  censor_allcausedeath = 1;
RUN;


data survdata_allcause_draft7;
  set survdata_allcause_draft6;
  IF (.< death_date )THEN DO ;
    censor_allcausedeath =0;
	time_allcausedeath = DATDIF(adm_date, death_date, 'act/act');
  END;
RUN;

/*RUN!
ods graphics on;
proc lifetest data=survdata_allcause_draft7 plots=survival(atrisk) ;
time time_allcausedeath*censor_allcausedeath(1);
strata sex;
run;
ods graphics off;
*/


/******OBJECTIVE THREE: ALL CAUSE READMISSION OR DEATH, TIME TO THE Earlier Event
  EITHER IT'S READMISSION OR DEATH*/

/*Dataset that I need to work on is survdata_allcause_draft7*/
/*Thoughts:
time_allcause_readmordeath 
censor_allcausereadmordeath

1.For the patients who had only single admission
if .<death_date < 31DEC2013
  then time_allcause_readmordeath = between adm_date and death_date
       censor_allcausereadmordeath = 0
if death_date > 31DEC2013 or missing,
   then time_allcause_readmordeath = between adm_date and 31DEC2013
        censor_allcausereadmordeath=1

2. For the patients who had multiple admissions
if the .<death_date <31DEC2013
   compare it with the second_admission_date, get the earlier_event_date
   time_allcause_readmordeath = between adm_date and earlier_event_date
       censor_allcausereadmordeath = 0
if the death_date >31DEC2013 or missing,
    time_allcause_readmordeath = between adm_date and second_admission_date
       censor_allcausereadmordeath = 0
*/

/* PLAN:
   We partition survdata_allcause_draft7 to two subsets survdata_allcause_draft8_single & survdata_allcause_draft8_multi
   we add two variables on each data then merge them by patient_id*/

data survdata_allcause_draft8_single  survdata_allcause_draft8_multi;
  set survdata_allcause_draft7;
  if (multipleadmi =0) then output survdata_allcause_draft8_single;
  else output survdata_allcause_draft8_multi;
run;

data survdata_allcause_draft9_single;
  set survdata_allcause_draft8_single;
  time_allcause_readmordeath = DATDIF(adm_date, "31dec2013"d, 'act/act');
  censor_allcausereadmordeath =1;
  if (.<death_date< "31dec2013"d) then do;
    time_allcause_readmordeath = DATDIF(adm_date, death_date, 'act/act');
    censor_allcausereadmordeath =0;
  end;
run;

/*earlier_date is the min among death_date and second_admission_date*/
data survdata_allcause_draft9_multi1;
  set survdata_allcause_draft8_multi;
  if (.<death_date< "31dec2013"d) then earlier_date = min ( death_date, second_admission_date) ;
  format earlier_date  MMDDYY10.;
run;



data survdata_allcause_draft9_multi2;
  set survdata_allcause_draft9_multi1;
  time_allcause_readmordeath = DATDIF(adm_date, second_admission_date, 'act/act');
  censor_allcausereadmordeath = 0;
  if (.<death_date< "31dec2013"d) then 
    time_allcause_readmordeath = DATDIF(adm_date, earlier_date, 'act/act');
run;

data survdata_allcause_draft10;
  merge  survdata_allcause_draft9_single  survdata_allcause_draft9_multi2;
  by patient_id;
run;


/*Now we can use survdata_allcause_draft10 to build the 
  all cause admission or death curve*/

/*
ods graphics on;
proc lifetest data=survdata_allcause_draft10 plots=survival(atrisk) ;
time time_allcause_readmordeath*censor_allcausereadmordeath(1);
strata sex;
run;
ods graphics off;
*/



