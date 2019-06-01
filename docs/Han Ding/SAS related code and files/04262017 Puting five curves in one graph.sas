/*04262017 Puting five curves in one graph*/
*data is hf_readm.Survdata_allandhfcause_draft3;
proc contents data = hf_readm.Survdata_allandhfcause_draft3;
run;

*time_allcausereadmi time_allcausedeath time_allcause_readmordeath time_hfcausereadmi time_hfcause_readmordeath;
*censor_allcausereadmi censor_allcausedeath  censor_allcausereadmordeath censor_hfcausereadmi  censor_hfcausereadmordeath;

/*First, let's make a consise datatable*/
data building;
  set hf_readm.Survdata_allandhfcause_draft3;
  keep time_allcausereadmi time_allcausedeath time_allcause_readmordeath time_hfcausereadmi time_hfcause_readmordeath
       censor_allcausereadmi censor_allcausedeath  censor_allcausereadmordeath censor_hfcausereadmi  censor_hfcausereadmordeath;
run;

/*We break this data building into event1-event5*/
data event1(rename=(time_allcausereadmi=timetoevent censor_allcausereadmi=censorship));
 
  set building (keep = time_allcausereadmi censor_allcausereadmi);
  eventtype = "All Cause Readmission";
  
run;
  
data event2(rename=(time_allcausedeath=timetoevent censor_allcausedeath=censorship));
  set building (keep = time_allcausedeath censor_allcausedeath);
  eventtype = "All Cause Death";
run;

data event3(rename=(time_allcause_readmordeath=timetoevent censor_allcausereadmordeath=censorship));
  set building (keep = time_allcause_readmordeath censor_allcausereadmordeath);
  eventtype = "All Cause Readmission or Death";
run;

data event4(rename=(time_hfcausereadmi=timetoevent censor_hfcausereadmi=censorship));
  set building (keep = time_hfcausereadmi censor_hfcausereadmi);
  eventtype = "HF Cause Readmission";
run;

data event5(rename=(time_hfcause_readmordeath=timetoevent censor_hfcausereadmordeath=censorship));
  set building (keep = time_hfcause_readmordeath censor_hfcausereadmordeath);
  eventtype = "HF Cause Readmission or Death";
run;

*done;

*Now concatenating the event1-5;

/*Notice here we must specify the length of variable first 
so that it won't be defined as the lenght of first value of the variable*/

DATA eventall; 
  length eventtype $32;
  SET event1 event2 event3 event4 event5;
RUN;  


data eventall_in_year;
  set eventall;
  timetoevent_in_year = timetoevent/365.25;
run; 

*Try the general survival curves;


/*ods graphics on;
ods select survivalplot(persist) failureplot(persist);*/

ODS _ALL_ CLOSE;
ods pdf file="C:\Users\Work\Desktop\RWJ medical school Research projects\
              Heart_Failure_Readmission\Heart_Failure_Readmission\SAS_Library_HF\Results\surv.pdf" ;
contents = yes pdftoc = 2;
proc lifetest data= eventall;
  time timetoevent*censorship(0);
  strata eventtype;
run;
ods pdf close;




ods graphics on;
ods select survivalplot(persist) failureplot(persist);
proc lifetest data= eventall plots = survival(atrisk(outside(0.15)) nocensor) ;
  time timetoevent*censorship(0);
  strata eventtype;
run;


proc lifetest data= eventall plots = survival( nocensor) ;
  time timetoevent*censorship(0);
  strata eventtype;
run;


proc lifetest data= eventall plots = survival(atrisk(atrisktick maxlen= 13 
                                     outside(0.20)) =0 500 5000 nocensor) ;
  time timetoevent*censorship(0);
  strata eventtype;
run;



*Draw a time to event in year graph;

ods html;
ods graphics on;
ods select survivalplot(persist) failureplot(persist);
proc lifetest data= eventall_in_year plots = survival(atrisk(atrisktick maxlen= 13 
                                     outside(0.20)) =0 1.37 13.69 nocensor) ;
  time timetoevent_in_year*censorship(0);
  strata eventtype;
run;


*No at risk graph;
ods graphics on;
ods select survivalplot(persist) failureplot(persist);
proc lifetest data= eventall_in_year plots = survival(nocensor) ;
  time timetoevent_in_year*censorship(0);
  strata eventtype;
run;



*******NAN LIU Article  using proc gplot*************************;
ods output homtests=homeT;
proc lifetest data=eventall_in_year outsurv= LTEstimates;
 time timetoevent_in_year*censorship(0);
 strata eventtype;
run;

goptions reset=all;
proc gplot data = LTEstimates;
  plot survival *timetoevent_in_year = eventtype;
run;
quit;


goption reset=all;
symbol1 line=1 color=red i=stepj;
symbol2 line=1 color=orange i=stepj;
symbol3 line=1 color=green i=stepj;
symbol4 line=1 color=blue i=stepj;
symbol5 line=1 color=purple i=stepj;
proc gplot data= LTEstimates;
 plot survival * timetoevent_in_year = eventtype;
run;
quit;


*CHANGING THE RANGE OF THE AXIS;

goption reset=all ftext=simplex;
symbol1 line=1 color=red i=stepj;
symbol2 line=1 color=orange i=stepj;
symbol3 line=1 color=green i=stepj;
symbol4 line=1 color=blue i=stepj;
symbol5 line=1 color=purple i=stepj;
axis1 label=(angle=90 'Survival Probability') ;
axis2 label=('Time to Event (Years)') order=(0 to 13.5 by 1);
proc gplot data= LTEstimates;
 plot survival * timetoevent_in_year = eventtype / vaxis=axis1 haxis=axis2;
run;
quit;




*Get a 1.37 years = 500days cut of the x axis;
goption reset=all ftext=simplex;
symbol1 line=1 color=red i=stepj;
symbol2 line=1 color=orange i=stepj;
symbol3 line=1 color=green i=stepj;
symbol4 line=1 color=blue i=stepj;
symbol5 line=1 color=purple i=stepj;
axis1 label=(angle=90 'Survival Probability') ;
axis2 label=('Time to Event (Years)') order=(0 to 1.37 by 0.1);
proc gplot data= LTEstimates;
 plot survival * timetoevent_in_year = eventtype / vaxis=axis1 haxis=axis2;
run;
quit;
