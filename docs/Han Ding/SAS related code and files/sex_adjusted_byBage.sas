DATA mylib.sexbyage; 
   INPUT agegroup $ count ratioofmd9 ratiobyage ; 
   DATALINES;
   
18to34 985   0.007 0.401 
35to54 17747 0.100 0.372 
55to64 13836 0.129 0.408 
65to74 27085 0.196 0.463 
75to84 42650 0.309 0.540 
85to94 32155 0.233 0.642 
95up 3628  0.026 0.765
all  138086 1    0.520
;
run;

DATA mylib.sexbyage2; 
   INPUT agegroup $ count ratioofmd9 ratiobyage ; 
   DATALINES;
   
18to34 985   0.007 0.401 
35to54 17747 0.100 0.372 
55to64 13836 0.129 0.408 
65to74 27085 0.196 0.463 
75to84 42650 0.309 0.540 
85to94 32155 0.233 0.642 
95up 3628  0.026 0.765
;
run;
/*First graph*/
/* Define the title and footnote */                                                                                                     
title1 'In md9, female population percentage adjusted by agegroup';                                                                                               
footnote1 ' ';                                                                                                                          
                                                                                                                                        
/* Define symbol characteristics */                                                                                                     
symbol1 interpol=join color=vibg value=dot;                                                                                             
symbol2 interpol=join color=mob font=marker value=C height=0.7;  

/* Define legend options */                                                                                                             
legend1 position=(top center inside)                                                                                                    
        label=none                                                                                                                      
        mode=share; 

/* Create the overlay plot */                                                                                                           
proc gplot data=mylib.sexbyage;                                                                                                                 
   plot ratiobyage*agegroup ratioofmd9*agegroup / overlay                                                                                                    
                             legend=legend1                                                                                             
                             haxis=axis1                                                                                                
                             vaxis=axis2                                                                                                
                             vref=0 to 1 by 0.1                                                                                 
                             lvref=2;                                                                                                                                                                                                                   
run;                                                                                                                                    
quit;
