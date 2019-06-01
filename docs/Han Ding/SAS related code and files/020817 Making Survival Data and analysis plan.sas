/* Objective one- ALL CAUSE READMISSION*/
/* 238801 each row for one patient
Patient_ID   time_all_admi  censorship  sex(subset later) age  prime  race  history*/


/*IF there are more than one rows for a patient_id in md6  
  1-1/ IF the newdtd is missing or it's after the second admission
       THEN  time_all_admi <- 2nd admition_date - 1st admission_date & censorship <- 0
  1-2/ IF the newdtd is between the two admission date, then newdtd must be before end of study date
       then we censored it on the newdtd ( but I doubt this situation's exist or not?YES! 27 RARE WEIRD CASES)

IF there is only one row for a patient_id in md6
  2-1/ IF the newdtd is missing or it's after the end date, 
       THEN time_all_admi <- end of study date - 1st admission date, we censored it on the end of study date Dec 31 2013
  2-2/ IF the newdtd is before the end date, 
       THEN time_all_admi <- newdtd- 1st admission date we censored it on the newdtd



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





