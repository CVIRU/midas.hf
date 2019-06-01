ods graphics on;

proc freq data=sashelp.cars;
tables Origin / plots=FreqPlot(scale=Percent) out=Freq1Out; /* save Percent variable */
run;

title "Plot of sex distribution adjusted by age group";
/* agegroup is the x axis, ratioofmd9 and ratiobyage are two bar for each x */
proc gchart data = mylib.sexbyage2;
   vbar count/ discrete type = percent;
   run;
quit;

proc freq data= mylib.sexbyage2;
tables count /out= Test
run;
quit;

proc sgplot data=mylib.sexbyage2;
vbar type /group=Origin groupdisplay=cluster response=Percent;
run;
quit;

TITLE 'Scatterplot - adjusted by age group';
PROC GPLOT DATA=mylib.sexbyage;
     PLOT ratioofmd9 * agegroup  ;
RUN; 
quit;
