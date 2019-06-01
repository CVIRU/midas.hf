/*04192017 Correction of data*/
proc corr data = Survdata_allandhfcause_draft2 
plots(maxpoints=none)=matrix(histogram);
var  time_allcausereadmi time_allcausedeath time_hfcausereadmi 
     length_index_adm hfhistory_dx1 hfhistory_dx2to9 ;
run;

*time_allcausereadmi includes negative value
time_allcausedeath includes negative value
time_hfcausereadmi includes negative value;


* We extract three pid out of the Survdata_allandhfcause_draft2 and made a union of this pid list and then delete them from
 Survdata_allandhfcause_draft2 to make Survdata_allandhfcause_draft3;

data pid_time_allcausereadmi_nega;
  set hf_readm.Survdata_allandhfcause_draft2;
  keep patient_id;
  if time_allcausereadmi < 0 or time_allcausedeath<0 or time_hfcausereadmi<0 
     or time_allcause_readmordeath<0 or time_hfcause_readmordeath<0 ;
run;

/*Exclude the pid_time_allcausereadmi_nega from Survdata_allandhfcause_draft2 to 
make Survdata_allandhfcause_draft3 */

data hf_readm.Survdata_allandhfcause_draft3; /*SAVE 226185*46*/
  merge Survdata_allandhfcause_draft2(in =x) pid_time_allcausereadmi_nega(in=y);
  by patient_id;
  if x=1 and y=0;
run;


proc corr data = hf_readm.Survdata_allandhfcause_draft3 
plots(maxpoints=none)=matrix(histogram);
var  time_allcausereadmi time_allcausedeath time_hfcausereadmi 
     length_index_adm hfhistory_dx1 hfhistory_dx2to9 ;
run;
/*done*/

*** Prepare data for the cox model;
*Cox model Sex age race prime admission_year length_index_adm
LOOK BACK FIVE YEARS FROM THE INDEX ADM_DATE 
usual susbpect: diabetes, hypertension, CKD, COPD,
(CHD which I don't have it now);

*First we look at the data;
proc freq data = Survdata_allandhfcause_draft3;
 table race prime;
run;

/*Define a format for prime variable called primefmt*/

proc format library = hf_readm;
  value $primefmt '008' = 'Commercial'
                      'BLUE CROSS P' = 'Commercial'
					  'HMO' = 'Commercial'
					  'COMMERCIAL' = 'Commercial'
					  'medicaid' = 'Medicaid'
                      'self pay'  = 'Self Pay'
					  'medicare' = 'Medicare' ;
run;
   


                      
    

    
