/*02222017 Properly index hf_readm.mda to hf_readm.mda2*/

/*Notice that in mda data, the var1 is incorrectedly formatted, so we make a new variable called var2 and add it to mda, called mda2*/

data hf_readm.mda2 (drop= var1);
  set hf_readm.mda;
  rownum_in_mda = _n_;
run;


