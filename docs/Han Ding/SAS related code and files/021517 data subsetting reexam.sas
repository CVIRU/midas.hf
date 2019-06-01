proc contents data = mda;/*17855328*/
run;

data mda1;
 set hf_readm.mda;
 keep var1 patient_id ADMISSION_DATE PATIENT_BIRTH_DATE DIAGNOSIS___PRINCIPAL_MAIN DIAGNOSIS___2ND_MAIN_CODE DIAGNOSIS___3RD_MAIN_CODE
    DIAGNOSIS___4TH_MAIN_CODE DIAGNOSIS___5TH_MAIN_CODE DIAGNOSIS___6TH_MAIN_CODE DIAGNOSIS___7TH_MAIN_CODE DIAGNOSIS___8TH_MAIN_CODE
	DIAGNOSIS___9TH_MAIN_CODE;
run;
/*Change admission_date and PATIENT_BIRTH_DATE to num type */
data mda2;
  set mda1;
  new1 = input(ADMISSION_DATE,MMDDYY10.);
  format new1 MMDDYY10.;
  drop ADMISSION_DATE;
  rename new1 = ADMISSION_DATE;
  new2 = input(PATIENT_BIRTH_DATE,MMDDYY10.);
  format new2 MMDDYY10.;
  drop PATIENT_BIRTH_DATE;
  rename new2 = PATIENT_BIRTH_DATE;
run;

/*Sort it by patient id, admission date*/
proc sort data=mda2 out=mda3;
  by Patient_ID ADMISSION_DATE;
run;


/*Exclude age<18 population  we got mda_18 n=17438660 */ 
proc sql;
  CREATE TABLE work.mda_18 AS
  select *
  from work.mda3
  where PATIENT_BIRTH_DATE < '01Jan1982'd
  order by patient_id;
QUIT;

/*sort mda_18 by pid and admission date*/
proc sort data= work.mda_18;
  by patient_id admission_date;
run;

/*get the all of the patient id in md6 CALLED pidumd6 n= 238801*/
proc sql ;
  CREATE TABLE work.pidumd6 AS
    select DISTINCT patient_id
      from hf_readm.md6;
QUIT;

/*find all admissions in mda_18 that associated with pidumd6*/
/*mda18md6u n= 2820155 is all the admissions that we need to look at */

proc sql ;
  CREATE TABLE work.mda18md6u AS /*2820155*/
    select *
	  from work.mda_18, work.pidumd6
	where mda_18.patient_id = pidumd6.patient_id;
QUIT;

/*Among this mda18md6u n=2820155, we want to identify 
 all the admissions that were 
within 5 years date back of the  for each patient n=238801
Let's call it mda18md6u5ydb*/


/*get the standard md6, let's call it md6fmt*/
data md6fmt;
 set hf_readm.md6;
   format admission_date MMDDYY10.;
   format discharge_date MMDDYY10.;
   format patient_birth_date MMDDYY10.;
run;

/*Let's get the first obs of md6 call it md6fmt1st*/
data md6fmt1st;
  set md6fmt;
  by patient_id;
  if first.patient_id;
run;



/*Notice that this MIDAS is a indexed data, then it's easy to subset*/
/*match mda18md6u. VAR1 with md6fmt1st.VAR1, if it's, give 1, name the variable first_00_13*/

/*proc sql ;
  validate
  select *
    from  mda18md6u
  intersect
  select *
    from md6fmt1st;
quit;*//*Here we may need to adjust the column to be same*/

data md6fmt1st_var1;
  set md6fmt1st;
  keep var1;
run;

/*Sort var1 in mda18md6u & md6fmt1st_var1*/

proc sort data = mda18md6u;
  by var1;
run;
proc sort data = md6fmt1st_var1;
  by var1;
run;


data mda18md6u_indic;
  merge mda18md6u md6fmt1st_var1(in = inmd6fmt1st_var1);
  by var1;
  if (inmd6fmt1st_var1) then first_00_13 =1;
  else first_00_13= 0;
run;
/*something is wrong with this first_00_13 in the lower row, but it doesn't matter we don't use it*/

proc sort data =  mda18md6u_indic;
  by patient_id admission_date;
run;

/*For each patient_id's all admission mda18md6u_indic, we got to create a variable 
that is called d2 which is the first admission date in 2000-2013*/

/*Here never use proc freq on patient_id because it's too slow*/

Proc SQL ;
     Create table mda18md6u_indic_freq as
          select *, count (patient_id) as count
          From mda18md6u_indic
          Group by patient_id
     ;
Quit ;

  
data freq (keep= count);
  set mda18md6u_indic_freq;
  by patient_id;
  if first.patient_id;
run;

data d2 (keep = admission_date);
  set Md6fmt1st;
run;

/*method for combining two variable*/
data d2freq;
 set d2;
 set freq;
run;

/*method for repeating the elements in a variable specific times*/
data d2freq_repeat; /*n=2820155*/

  set d2freq;
  do i=1 to count;
    output;
  end;
  drop i;
  rename admission_date = d2;
run;

/* add a variable called d1*/
/* WRONG METHOD TO USE INCREMENT IN DATE data d1d2freq_repeat;
  set d2freq_repeat;
  d1 = d2- year(1);
  format d1 MMDDYY10.;
run; */

data d1d2freq_repeat(drop = count);/*2820155*/
 set d2freq_repeat;
 d1 = intnx('year',d2,-5,"sameday");
 format d1 MMDDYY10.;
run;


/*Making mda1md6u_dates concatenate this d1d2freq_repeat n=2820155
to Mda18md6u_indic_freq n=2820155*/

data mda1md6u_dates;
  set Mda18md6u_indic_freq;
  set d1d2freq_repeat;
run;

/*Making mda1md6u_d1tod2 by
subsetting mda1md6u_dates, select the rows that admission date is 
 between d1 and d2*/

proc sql ;
  create table mda1md6u_d1tod2 as /*811539 *17*/
  select * 
  from  mda1md6u_dates
  where admission_date < d2 AND admission_date > d1;
quit;

 
/*Among this mda1md6u_d1tod2, we need to find for each row 
 whether it HAS hftargetlist_chr or not in DX1-9*/

/*First we need to make hftargetlist_chr*/
data hftargetlist_chr;
  set hf_readm.hftargetlist;
  hfchr = put (var1, 8.);
  drop var1;
run;

/*mda1md6u_d1tod2 hftargetlist_chr
 Making a new data called mda1md6u_dx1to9_0or1*/
/*wrong method*/
/*data mda1md6u_dx1to9_0or1;
  set mda1md6u_d1tod2;
  if (DIAGNOSIS___PRINCIPAL_MAIN in hftargetlist_chr) 
    then dx1 = 1;
  else dx1 = 0;
  run; */

/*tried proc sql but failed

proc sql;
  select DIAGNOSIS___PRINCIPAL_MAIN
    from MDA1MD6U_D1TOD2
  intersect 
  select hfchr
    from HFTARGETLIST_CHR;
quit;
*/

data mda1md6u_dx1to9_0or1; /*811539*26*/
  set mda1md6u_d1tod2;
  if (DIAGNOSIS___PRINCIPAL_MAIN in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then dx1 = 1;
  else dx1 = 0;

   if (DIAGNOSIS___2ND_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then dx2 = 1;
  else dx2 = 0;
  
   if (DIAGNOSIS___3RD_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then dx3 = 1;
  else dx3 = 0;

  
   if (DIAGNOSIS___4TH_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then dx4 = 1;
  else dx4 = 0;

   if (DIAGNOSIS___5TH_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then dx5 = 1;
  else dx5 = 0;
  
   if (DIAGNOSIS___6TH_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then dx6 = 1;
  else dx6 = 0;
  
   if (DIAGNOSIS___7TH_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then dx7 = 1;
  else dx7 = 0;
  
   if (DIAGNOSIS___8TH_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then dx8 = 1;
  else dx8 = 0;
  
   if (DIAGNOSIS___9TH_MAIN_CODE in ("4280","4281","42820","42821","42822","42823","42830",
"42831","42832","42833","42840","42841","42842","42843","4289"))
 then dx9 = 1;
  else dx9 = 0;
  run; 


/*make Mda1md6u_dx1to9_0or1_sum1 FROM  Mda1md6u_dx1to9_0or1 to 
  help me understand which record had history*/

proc sql;
  create table Mda1md6u_dx1to9_0or1_sum1 as /*811539*27*/
    select *, sum(dx1,dx2,dx3,dx4,dx5,dx6,dx7,dx8,dx9) as dx1_9_history
	from Mda1md6u_dx1to9_0or1;
quit;

proc freq data= Mda1md6u_dx1to9_0or1_sum1;
  tables dx1_9_history/ MISSING;
RUN;

/*we wanna first find out the patient_id that are has history*/
/*using  Mda1md6u_dx1to9_0or1_sum1   dx1_9_history */
proc sql;
  create table pid_with_dx1to9history as /*n= 230939*/
    select patient_id
	from Mda1md6u_dx1to9_0or1_sum1
	where dx1_9_history >0;
quit;

data hf_readm.piduni_with_dx1to9history; /*100808*//*Save this data!*/
  set pid_with_dx1to9history;
  by patient_id;
  if first.patient_id;
run;

/*n of piduni_with_dx1to9history is 100808 is different from n= 100715 of pidmd34u, but they're similar*/


/*similar to history of DX1-9 , I wanna look for the history of DX1 and DX2-9*/
/*Let's prepare patient ID for them */
/*1. DX1 history 's patient ID n=14055*/
proc sql;
  create table pid_with_dx1history as /*27193*/
    select patient_id
	from Mda1md6u_dx1to9_0or1
	where dx1 > 0;
quit;

proc freq data = Mda1md6u_dx1to9_0or1;
  tables dx1/ missing;
run;

data hf_readm.piduni_with_dx1history;/*14055*//*SAVE*/
  set pid_with_dx1history;
  by patient_id;
  if first.patient_id;
run;

/*2. DX2-9 history's patient ID n=97140*/
proc sql;
  create table Mda1md6u_dx2to9_0or1_sum2 as /*811539*27*/
    select *, sum(dx2,dx3,dx4,dx5,dx6,dx7,dx8,dx9) as dx2_9_history
	from Mda1md6u_dx1to9_0or1;
quit;

proc freq data = Mda1md6u_dx2to9_0or1_sum2;
  tables dx2_9_history/ missing;
run;


proc sql;
  create table pid_with_dx2to9history as /*n= 203754*/
    select patient_id
	from Mda1md6u_dx2to9_0or1_sum2
	where dx2_9_history >0;
quit;

data hf_readm.piduni_with_dx2to9history;/* n= 97140*//*SAVE*/
  set pid_with_dx2to9history;
  by patient_id;
  if first.patient_id;
run;











