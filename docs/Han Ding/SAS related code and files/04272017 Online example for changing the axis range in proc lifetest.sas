

/********************/
/* LIFETEST example */
/********************/
data myeloma;
   input time vstatus logbun hgb platelet age logwbc frac
         logpbm protein scalc;
   datalines;
        1.25  1  2.2175   9.4  1  67  3.6628  1  1.9542  12  10
        1.25  1  1.9395  12.0  1  38  3.9868  1  1.9542  20  18
        2.00  1  1.5185   9.8  1  81  3.8751  1  2.0000   2  15
        2.00  1  1.7482  11.3  0  75  3.8062  1  1.2553   0  12
        2.00  1  1.3010   5.1  0  57  3.7243  1  2.0000   3   9
        3.00  1  1.5441   6.7  1  46  4.4757  0  1.9345  12  10
        5.00  1  2.2355  10.1  1  50  4.9542  1  1.6628   4   9
        5.00  1  1.6812   6.5  1  74  3.7324  0  1.7324   5   9
       13.00  0  1.6628   4.9  0  71  3.6435  0  1.7924   0   9
       16.00  0  1.1461  13.0  1  55  3.8573  0  0.9031   0   9
       19.00  0  1.3222  13.0  1  59  3.7709  1  2.0000   1  10
       19.00  0  1.3222  10.8  1  69  3.8808  1  1.5185   0  10
       28.00  0  1.2304   7.3  1  82  3.7482  1  1.6721   0   9
       41.00  0  1.7559  12.8  1  72  3.7243  1  1.4472   1   9
       53.00  0  1.1139  12.0  1  66  3.6128  1  2.0000   1  11
       57.00  0  1.2553  12.5  1  66  3.9685  0  1.9542   0  11
       77.00  0  1.0792  14.0  1  60  3.6812  0  0.9542   0  12
       ;
       run;

ods graphics / reset noborder width=600px height=400px;
ods listing close;
ods html file='lifetest.html' path='.' style=listing;
ods select SurvivalPlot;

proc lifetest data=myeloma plots=survival;      
   strata frac;
   time time*vstatus(0);
run;
quit;

ods html close;
ods listing;
ods graphics off;

/* Delete the custom template in order to use the original */
/* template the next time PROC LIFETEST is run. */
proc template;
   delete Stat.Lifetest.Graphics.ProductLimitSurvival;
run;
quit;


*************************START FROM HERE*************************


*******NAN LIU Article  using proc gplot*************************;

ods output homtests=homeT;
proc lifetest data=hmohiv outsurv= LTEstimates;
 time time*censor(0);
 strata drug;
run;



goptions reset=all;

proc gplot data = LTEstimates;
  plot survival *time = drug;
run;
quit;


data LTEstimates_1;
 set LTEstimates;
 output;
 if stratum= 2 and time= 15 then do;
 do i = 16 to 55;
 time= i;
 survival= 0.0582;
 output;
 end;
 end;
run;

goptions reset=all;
proc gplot data = LTEstimates_1;
  plot survival *time = drug;
run;
quit;


goption reset=all;
symbol1 line=1 color=blue i=stepj;
symbol2 line=2 color=red i=stepj;
proc gplot data= LTEstimates;
 plot survival * time = drug;
run;
quit;


goption reset=all ftext=simplex;
symbol1 line=1 color=blue i=stepj;
symbol2 line=2 color=red i=stepj;
axis1 label=(angle=90 'Survival Probability');
axis2 label=('Time to Event (months)') ;
proc gplot data= LTEstimates;
 plot survival * time = drug / vaxis=axis1 haxis=axis2;
run;
quit;
