PROC IMPORT OUT= HF_READM.HFtargetlist 
            DATAFILE= "C:\Users\Work\Desktop\RWJ medical school Research
 projects\MIDAS\DATA\TargetList.txt" 
            DBMS=TAB REPLACE;
     GETNAMES=NO;
     DATAROW=1; 
RUN;
