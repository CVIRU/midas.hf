setwd("C:/Users/Work/Desktop/RWJ medical school Research projects/MIDAS/DATA")

we sort md1 by admission date and birthdate, we got md3 (17438660).
if we limit the admission date within 2000-2013, we got md4 (12547703)
plus, if we limit to all the observations that has HF in the DX1, 
     we got md5 (n=474674) 
plus, if sort by patient id and admission date, 
     we got md6 (n=474674)
plus, if we only keep the first observation(2000-2013 and DX1 HF positive) 
     for each patient, we got md7(n = 238801)

From md3 make md31 (n=17438660) which is the Patient_id (and admission date)ordered md3
from md31, we find all the observations that have the md7's patient id, 
           name it md32 (n= 2820155) 
          ####we need here md 32 to be patient id, admissiondate sorted.
from md32, we find all the observations that is within the ddb-dfa(from md7) time frame, 
           name it md33 (n= 810878). Notice that here, the date must be <dfa instead of =< dfa
from md33, we find all the observations that has at least one HF in DX1-9, 
           name it md34 (n=230682)
From md34, we extract the patient_id "pidmd34" (n= 230682) and "pidmd34u" (n = 100715) 
           and compare it with md6's patient_id (n=474674)
Subset md6, keep only the observations whose md6[,5] 
           is not included in pidmd34u #100715, we got md8 (n=249299) 
From md8, subset md9 (n= 138086) md9 is the first admission for each patient in md8.

In summary
So md8 is all the observation that 
1. Older than 18 years old when the study begins
2. Have at least one HF in DX1 during 2000-2013
3. Excluded any patients that have any HF in DX1-DX9 dating back 5 years from the 
   first admission date within 2000-2013 for him/herself.
4. Sorted by patient ID & Admission date

01212017 Subsetting Dictionary
md6 (n=474674) # All obs with One HF in 2000-2013
md7(n = 238801) #First obs of md6
md32 (n= 2820155) #all the observations that have the md7's patient id
md34 (n=230682) #all the observations that has at least one HF in DX1-9, within 5 years date back window
"pidmd34u" (n = 100715)  # unique patient id from md34
md8 (n=249299) #Subset md6, keep only the observations whose patient id is not included in pidmd34u #100715, we got md8 (n=249299) 
md9 (n= 138086) #md9 is the first observation for each patient in md8.
event1 <-  # the patient id showed more than once in md8
md10 (n= 48422) #md10 represents the md9(first obs) that event1 is true (multiple admissions)
md11 (n= 225375) #subset of md6 that keep only the obs whos patient id is included in pidmd34u, similar to md8
md12 (n = 100715) # First obs of md11, similar to md9
#md8 &md11 include all the information that we need.
