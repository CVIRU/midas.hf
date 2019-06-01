PROC IMPORT OUT= MYLIB.md8 
            DATAFILE= "C:\Users\Work\Dropbox\WRJ medical school Research
 projects\MIDAS\DATA\md8.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
