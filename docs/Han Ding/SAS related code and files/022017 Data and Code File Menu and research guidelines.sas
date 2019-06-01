/*Data and Code File Menu and research guidelines*/
/*Objective all caused readmission
Graph1 all caused readmission
Graph2 all caused death
Graph3 all caused readmission or death*/

/*Objective HF caused readmission
Graph1 HF caused readmission
Graph2 HF caused death
Graph3 HF caused readmission or death*/


 /*all caused readmission

The "Objective one_ALL CAUSE Readmission_Time to readmission.sas" it's wrong
becaused it is basically the HF Caused readmission*/



/******OBJECTIVE ONE: ALL CAUSE READMISSION - Time to Readmission **

 1. survdata_allcause_once 40889*27
 2. survdata_allcause_multiple 1516031*27 */

/*IF there is more than one rows for a patient_id in survdata_allcause_draft2  
  1-1/ IF the death_date is missing or it's after the second admission
       THEN  time_allcausereadmi <- 2nd admition_date - 1st admission_date & censorship <- 0
  1-2/ IF the death_date is between the two admission date, then death_date must be before end of study date
       then we censored it on the death_date ( but I doubt this situation's exist or not?)*/
/*IF there is only one row for a patient_id in survdata_allcause_draft2
  2-1/ IF the death_date is missing or it's after the end date, 
       THEN time_allcause_readmi <- end of study date - 1st admission date,
       we censored it on the end of study date Dec 31 2013
  2-2/ IF the death_date is before the end date, 
       THEN time_allcause_readmi <- death_date- 1st admission date, 
       we censored it on the death_date*/

/* Objective two- ALL CAUSE Mortality- Time to Death*/
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
