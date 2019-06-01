/*05052017 Puting five curves in on graph 2 and modification*/
/*In the program that I wrote in 04262017 Puting five curves in one graph,
I actually used all the population instead of the people without heart failure 
history subgroup, I'm modifiying this mistake in this program and 
and producing the new and correct five curves in one graph and analysis file*/

data Survdata_5curvesin1_nohfhis; /*131690*46*/
  set hf_readm.Survdata_allandhfcause_draft3;
  where hfhistory_dx1to9 =0;
run;

*time_allcausereadmi time_allcausedeath time_allcause_readmordeath time_hfcausereadmi time_hfcause_readmordeath;
*censor_allcausereadmi censor_allcausedeath  censor_allcausereadmordeath censor_hfcausereadmi  censor_hfcausereadmordeath;

/*First, let's make a consise datatable*/
data building;
  set Survdata_5curvesin1_nohfhis;
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

DATA eventall; /*658450*/
  length eventtype $32;
  SET event1 event2 event3 event4 event5;
RUN;  


data eventall_in_year;
  set eventall;
  timetoevent_in_year = timetoevent/365.25;
run; 


ODS _ALL_ CLOSE;
ods pdf file="C:\Users\Work\Desktop\RWJ medical school Research projects\
              Heart_Failure_Readmission\Heart_Failure_Readmission\SAS_Library_HF\Results\surv2.pdf";
proc lifetest data= eventall;
  time timetoevent*censorship(0);
  strata eventtype;
run;
ods pdf close;


*ERROR: Physical file does not exist, C:\Users\Work\Desktop\RWJ medical school Research projects\

       Heart_Failure_Readmission\Heart_Failure_Readmission\SAS_Library_HF\Results\surv2.pdf.
;


/********************Run this, this works**********************************/
ods output homtests=homeT;
proc lifetest data=eventall_in_year outsurv= LTEstimates_nohfhis; 
 time timetoevent_in_year*censorship(0);
 strata eventtype;
run;

/*****Save the LTEstimates_nohfhis to hf_readm)**/

ods html;
goptions reset=all;
proc gplot data = LTEstimates_nohfhis;
  plot survival *timetoevent_in_year = eventtype;
run;
quit;


goption reset=all ftext=simplex;
symbol1 line=1 color=red i=stepj;
symbol2 line=1 color=orange i=stepj;
symbol3 line=1 color=green i=stepj;
symbol4 line=1 color=blue i=stepj;
symbol5 line=1 color=purple i=stepj;
axis1 label=(angle=90 'Survival Probability') ;
axis2 label=('Time to Event (Years)');
proc gplot data= LTEstimates_nohfhis;
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
proc gplot data= LTEstimates_nohfhis;
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
proc gplot data= LTEstimates_nohfhis;
 plot survival * timetoevent_in_year = eventtype / vaxis=axis1 haxis=axis2;
run;
quit;


/*Make a the line thicker*/
/*05062017*/
*Let's work on the 13.5 years range 5 curves in 1 graph first;


*Y-axis is changed to probability;
*Legend has been put inside the graph;
*Adjust the width of the line;
*Make the font and lable bigger;
*Adjust the ticks;


ODS HTML;
goption reset=all ftext=Ariel  ;
symbol1 line=1 color=red i=stepj mode=include width=4;
symbol2 line=1 color=orange i=stepj  mode=include width=3;
symbol3 line=1 color=green i=stepj mode=include width=3;
symbol4 line=1 color=blue i=stepj mode=include width=4;
symbol5 line=1 color=purple i=stepj mode=include width=4;
axis1 label=(height=2 angle=90 'Survival Probability') 
      major = (height =2 width =1.5) value = (height=2);
axis2 label=(height=2 'Time to Event (Years)' ) 
       order=(0 to 13.5 by 1) major = (height =1.5 width =1.5)
       value = (height=2);
legend1 label=(height = 1.25 position =top justify = center 'Event Types')
        value=(height =1.5 'All Cause Death' 'All Cause Readmission'  'All Cause Readmission or Death'
               'HF Cause Readmission'  'HF Cause Readmission or Death')  
        mode=protect position=(top right inside) offset=(-8 -4) across=1
        frame 
; 
proc gplot data= LTEstimates_nohfhis;
 plot survival * timetoevent_in_year = eventtype / vaxis=axis1 haxis=axis2 legend=legend1;
 format survival percent12.0;
run;
quit;


*test;
ODS HTML;
goption reset=all ftext=Ariel  ;
symbol1 line=1 color=red i=stepj mode=include width=4;
symbol2 line=1 color=orange i=stepj  mode=include width=3;
symbol3 line=1 color=green i=stepj mode=include width=3;
symbol4 line=1 color=blue i=stepj mode=include width=4;
symbol5 line=1 color=purple i=stepj mode=include width=4;
axis1 label=(height=2 angle=90 'Survival Probability') 
      major = (height =2 width =1.5) value = (height=2);
axis2 label=(height=2 'Time to Event (Years)' ) 
       order=(0 to 13.5 by 1) major = (height =1.5 width =1.5)
       value = (height=2);
legend1 label=(height = 2 position =top justify = center 'Event Types')
        value=(height =2 'All-Cause Death' 'All-Cause Readmission'  'All-Cause Readmission or Death'
               'HF Cause Readmission'  'HF Cause Readmission or Death')  
        mode=protect position=(top right inside) offset=(-6 -2) across=1
        frame 
; 
proc gplot data= LTEstimates_nohfhis;
 plot survival * timetoevent_in_year = eventtype / vaxis=axis1 haxis=axis2 legend=legend1;
 format survival percent12.0;
run;
quit;


