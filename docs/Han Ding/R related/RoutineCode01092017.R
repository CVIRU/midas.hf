memory.size(100000)
memory.limit()
getwd()
setwd("C:/Users/Work/Desktop/RWJ medical school Research projects/MIDAS/DATA")
#Read in midas.RData
md <- as.data.frame(midas) 
rm(midas)


tarlist =read.table("TargetList.txt", header = FALSE)
tarstr <- tarlist[,1]
rm(tarlist)


#Change the date dataform in md to mdy in package lubridate using the mdy function in lubridate 
library(lubridate)
require(lubridate)
# Including 5,6,7,8th column

#test 
mdtest <- md[1:100,]
mdtest[,5] <- as.character(mdtest[,5])
mdtest[,6] <- mdy(mdtest[,6])
rm(mdtest)
#test end

#
md[,5] <- as.character(md[,5])#Patient ID
md[,6] <- mdy(md[,6]) #Admission_date
md[,7] <- mdy(md[,7]) #Discharge date
md[,8] <- mdy(md[,8]) #Birthdate
str(md[,5:8])


md1 <- md[md[,8] < ymd(19820101),]
md2 <- md1[order(md1[,8]),] #17438660 sort by birthdate, not necessary 


#md3 is md2, admission date sorted
#test [,6] is the admission date
md2t <- md2[1:100,]
md3t <- md2t[order(md2t[,6]),]
#testend
md3 <- md2[order(md2[,6]),] #17438660
head(md3[,c(6,8)],100)

#md4 is the 2000-2013 admisioned md2, admission date sorted
#test
md3t <- md3[1:10000,]
md4t <- subset(md3t,  md3t[,6] >= ymd(20000101) & md3t[,6] <= ymd(20131231)) 
head(md3t[,6],10000)
#testend
md4 <- subset(md3,  md3[,6] >= ymd(20000101) & md3[,6] <= ymd(20131231)) #12547703

#md5 is the md4 that has at least one HF in thier primary diagnosis.
#test
md4t <- md4[1:10000,]
md5t <- subset(md4t, (md4t[,17] %in% tarstr))
#testend
md5 <- subset(md4, (md4[,17] %in% tarstr)) #474674

#md6 is made by sorting md5 by PATIENTID-5 and ADMISSIONDATE-6
#test
md5t <- md5[1:10000,]
md6t <- md5t[order(md5t[,5],md5t[,6]),]
head(md6t[,5:6],100)
#testend
md6 <- md5[order(md5[,5],md5[,6]),] #n=474674
head(md6[,5:6],100)

#Cleaning
rm(md1t,md2t,md3t,md4t,md5t,md6t)

#md7 is the first observations of md6
#test
md7t <- md6[1:1000,][match(unique(md6[1:1000,][,5]), md6[1:1000,][,5]),]
#testend
md7 <- md6[match(unique(md6[,5]), md6[,5]),] # n=238801
head(md7[,5:6])


#  The first admission date in md7 -dfa n= 238801
dfa <- md7[,6]
head(dfa,50)
tail(dfa,50)

#  five years dateback endpoint for each patient in md7 -ddb n=238801
dbd <- md7[,6] - years(5)
str(md7[,6])
str(dbd)

#test

# patient id in md7 
pidmd7 <- md7[,5] #n = 238801

#Algorithm 
# For each patient ID in md7, if you can find a HF in the ddb-dfa time period in md3,
# gives the indicator value of 1, otherwise, gives the indicator value of 0.

# Method 1: looping, not good
# For each row in md7[,5]
# for (i in 1:10){
#  if we find a HF in the ddb-dfa time period in md3
#   idkt[i] <- TRUE

# Method2: Subsetting step by step
# From md3 make md31 which is the Patient_id ordered md3
# from md31, we find all the observations that have the md7's patient id, name it md32
# from md32, we find all the observations that is within the ddb-dfa time frame, name it md33
# from md33, we find all the observations that has at least one HF in DX1-9, name it md34
# From md34, we extract the patient_id and compare it with md6 & md7's patient_id,
# If there is some duplications, delete these patients from md6 and md7



dim(md3)
#test
md3t <- md3[1:10000,]
md31t <- md3t[order(md3t[,5]),]
#testend
md31 <- md3[order(md3[,5]),] #17438660

#test
md7t <- md7[1:10000,]
md32t <- subset(md31t, (md31t[,5] %in% md7t[,5]))
head(md7t[,5],25);head(md32t[,5],25)
(a <- c(1:10))
(b <- c(1,1,2,3,4,5,11,12,13,18,20))
(c<- subset(b, b %in% a))
#testend
md32 <- subset(md31, (md31[,5] %in% md7[,5])) # n=2820155

#md31(n= 17438660) is the id, admission, birthday ordered observations 
#md32(n= 2820155) is the md31 subset that has the patiend id of md7 (n= 238801)    
#check
head(md32[,5:8],50)
head(md7[,5:8],50) 
# For each admissions in md32
# if the admission was within the time period of md7, gives it a value 1, which means keeps it
# if not, gives it a value 0, which means delete it.
# In this way, md33 is made.

idkt <- logical(length = 2820155)


# dfa is the admission date for the patient between 2000-2013
# dbd is the 5 years date backed date for the patient between 2000-2013
# md32dfa is the patient id repeated version of dfa
# md32dbd is the patient id repeated version of dbd

#first postion fst_pst
#test
fst_pst <- match(md7[1:10000,5],md32[1:10000,5])
#testend
fst_pst <- match(md7[,5],md32[,5])
head(fst_pst,50)
tail(fst_pst,50)
# First patient id should be repeated 31-1=30 times, 
# the last which is the 238801 th patient id should be repeated 2820155-2820151 +1 = 5 times
rep_times1 <- fst_pst[2:238801]  
rep_times2 <- c(rep_times1, 2820156) #2820155+1
head(rep_times2)
tail(rep_times2)
rep_times3 <- rep_times2- fst_pst #238801
head(rep_times3)
tail(rep_times3)

#check if the rep_times3 is correct
head(md32[,5],50)
tail(md32[,5],50)

md32dfa <- rep(dfa,rep_times3 )
head(md32dfa,50)
tail(md32dfa,50)

str(md32dfa)
md32dbd <- md32dfa - years(5) 
head(md32dbd,50)

# from md32, we find all the observations that is within the ddb-dfa time frame, 
# name it md33 
#test
md32t2<- md32[1:1000,]
md33t <- subset(md32t2, (md32t2[,6] < md32dfa[1:1000] & md32t2[,6] >= md32dbd[1:1000]))
head(md32[,5:8],50)
head(md7[,5:8],50) 
head(md33t[,5:8],50)
#testend
md33 <- subset(md32, (md32[,6] < md32dfa & md32[,6] >= md32dbd))   #correct n= 810878
head(md32[,5:8],50)
head(md7[,5:8],50) 
head(md33[,5:8],50)


# from md33, we find all the observations that has at least one HF in DX1-9, name it md34
mxdxmd33 <- as.matrix(md33[,17:25]) #810878       9
head(mxdxmd33)
mxdxmd33[,1]
mx <- matrix(NA, nrow = nrow(md33), ncol = 9) #810878       9

for (i in 1:9){
  mx[,i] <- !is.na(match(mxdxmd33[,i],tarstr))
}
vm1 <- apply(mx, 1, any) # n= 810878
head(vm1,100)
head(md33[,5:8],100)
table(vm1) #FALSE 580196  TRUE 230682 (the size of md34) 

md34 <- md33[vm1,] #230682
head(md34[,5:8],25)
head(md34[,17:25],25)


# From md34, we extract the patient_id and compare it with md6 & md7's patient_id,
names(md34)
pidmd34 <- md34[,5] #230682
head(md3[,c(5:8)],50)
head(md34[,c(5,6,17:18)],50)
head(md6[,c(5,6,17:18)],50)
head(md31[,c(5,6,17:18)],100)
head(md32[,c(5,6,17:18)],100)
head(md33[,c(5,6,17:18)],100)

head(md32[,5:6],200)
head(md7[,5:6],200)
tail(md32[,5:6],200)
tail(md7[,5:6],200)

# Compare pidmd34 with md6[,5] #474674, if duplicate, then delete these patients to make md8 and md9(first observation)
pidmd34u <- unique(pidmd34) # 100715

#double check
head(table(md6[,5]))
head(table(pidmd34u))
head(pidmd34u,200)
head(md6[,5],200)
tail(pidmd34u,200)
tail(md6[,5],200)

# Just subset, keep all the observations whose md6[,5] #474674 is not included in pidmd34u #230682
#test
length(which(md6[,5] %in% pidmd34u)) #225375
which(md6[,5] %in% pidmd34u)
#testend

md8 <- md6[-which(md6[,5] %in% pidmd34u),]  #md8 = 249299 which is equal to 474674-225375

head(table(pidmd34u),25)
head(table(md6[,5]),25)
head(table(md8[,5]),25)

#md8 is the adjusted md6
head(md8[,5:7],50)

#save data md8
# save(md8,file="md8.Rda")

#md9 is the first admission for each patient in md8 
md9 <- md8[match(unique(md8[,5]), md8[,5]),] # n=138086

#md11 is all the admissions that with HF history within the 5 years dateback windows.
#Basically, md8 and md11 made up all the observations that we need
#md9 and md12, which are all the unique observations that we need to make the tabel
md11 <- md6[which(md6[,5] %in% pidmd34u),]; dim(md11) #225375
md12 <- md11[match(unique(md11[,5]), md11[,5]),]; dim(md12) #100715
head(md11[,5])
head(md8[,5])

