PROC IMPORT OUT= HF_READM.pidmd34u 
            DATAFILE= "C:\Users\Work\Desktop\RWJ medical school Research
 projects\MIDAS\DATA\pidmd34u.txt" 
            DBMS=TAB REPLACE;
     GETNAMES=NO;
     DATAROW=1; 
RUN;
