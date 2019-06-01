DATA mylib.sexbyagemd10; 
   INPUT agegroup $ ratioofmd10 ratiobyage ; 
   DATALINES;
  18to34 0.008 0.379 
  35to54 0.105  0.352 
  55to64 0.134  0.400 
  65to74 0.208 0.456 
  75to84 0.320 0.532 
  85to94 0.209 0.638 
  95up   0.017 0.756
  all    1     0.504
;
run;

/*First graph*/
/* Define the title and footnote */                                                                                                     
title1 'In md10, female population percentage adjusted by agegroup';                                                                                               
footnote1 ' ';                                                                                                                          
                                                                                                                                        
/* Define symbol characteristics */                                                                                                     
symbol1 interpol=join color=vibg value=dot;                                                                                             
symbol2 interpol=join color=mob font=marker value=C height=0.7;  

/* Define legend options */                                                                                                             
legend1 position=(top center inside)                                                                                                    
        label=none                                                                                                                      
        mode=share; 

/* Create the overlay plot */                                                                                                           
proc gplot data=mylib.sexbyagemd10;                                                                                                                 
   plot ratiobyage*agegroup ratioofmd10*agegroup / overlay                                                                                                    
                             legend=legend1                                                                                             
                             haxis=axis1                                                                                                
                             vaxis=axis2                                                                                                
                             vref=0 to 1 by 0.1                                                                                 
                             lvref=2;                                                                                                                                                                                                                   
run;                                                                                                                                    
quit;
