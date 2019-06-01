/*06022017 Frequency of different types of hf in the patients who had a first time HF*/

/*Based on the code files below*/
*06012017 Applying basic Cox model Changing the target population to the ones that have zero HF history;
* produce the data survdata_histable4 first from that code file;

proc freq data = survdata_histable4;
  
