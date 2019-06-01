# Target population description is in the RoutineCode01172017 subsetting explaination.R


getwd()
setwd("C:/Users/Work/Desktop/RWJ medical school Research projects/MIDAS/DATA")
getwd()
load("md8.Rda")
load("md11.Rda")
#md9 is the first admission for each patient in md8 
md9 <- md8[match(unique(md8[,5]), md8[,5]),] # n=138086
md12 <- md11[match(unique(md11[,5]), md11[,5]),]; dim(md12) #100715
library(lubridate)
require(lubridate)

pidmd8 <- md8[,5];pidmd8
pididx <- order(pidmd8)[!duplicated(pidmd8)]; pididx #it's the first admission position n= 138086
# Define event1 <-  the patient id showed more than once in md8
event1 <- logical(138086)
for (i in 1:length(event1)){
  if (pididx[i+1] -pididx[i] != 1){
    event1[i] <- TRUE
  }
}
event1[length(event1)] <- TRUE
head(event1)
tail(event1)
head(pidmd8)
tail(pidmd8)# check done

#md10 represents the md9 (unique patient id) that event1 is true (multiple admissions)
event1 #F 89664  T 48422 
md10 <- md9[event1=="TRUE",] # 48422
head(md10[,5]) 

#md9 (n=138086) is part of what we need to make the Davit table

#If we subset md6 in a different way, we can get md11 
# so md8&md11 are all we need
# Again md8 249299; md11 225375
#       md9 138086; md12 100715 
head(md9[,5])
head(md11[,5:8])
head(md12[,5:8])

# Find if md12's pid shows more than once in md11 or not
pidmd11 <- md11[,5];pidmd11
pididx11 <- order(pidmd11)[!duplicated(pidmd11)]; pididx11 #it's the first admission position n= 100715
# Define event2 <-  the md12 patient id showed more than once in md11
event2 <- logical(100715);event2
for (i in 1:length(event2)){
  if (pididx11[i+1] -pididx11[i] != 1){
    event2[i] <- TRUE
  }
}
event2 #F 54743 T 45972
event2[length(event2)] <- TRUE
head(event2)
tail(event2)
head(pidmd11)
tail(pidmd11)# check done

#md10 represents the md9 (unique patient id) that event1 is true (multiple admissions)
event1 #F 89664  T 48422 
md10 <- md9[event1=="TRUE",] # 48422
head(md10[,5]) 

library(data.table)
# d1 <- data.table(patientid,history,admi_date1,readmi, admi_date2, death, deathdate)
patientid <- c(md9[,5],md12[,5]) #238801
history <- c(rep(0,138086),rep(1,100715)); summary(history)
admi_date1 <- c(md9[,6],md12[,6])  
# readmi 
# For md9, we know that if the patient id is in md10, it's readmitted, so ->1
# Same goes with md12
readmi <- as.numeric(c(event1,event2));readmi #DONE

# admi_date2

# for md8,the length should be length(md9)
# we find those pid is in md10, and use the second admission date - the first admission date
# for md11, the length should be length(md12)

#1 Get md13 which is similar to md10
event2 #F 54743 T 45972
md13 <- md12[event2=="TRUE",] # 45972
head(md13[,5]) 
head(md12[,5])

#2 First part of : md8,9,10, so each obs in md9 should receive a time if he's in md10 or it should receive a NULL
pidmd10 <- md10[,5]
admi_date2_nohistory <- numeric(length(event1)) #138086
pidmd8 <- md8[,5];pidmd8
pididx <- order(pidmd8)[!duplicated(pidmd8)]; pididx #it's the first admission position n= 138086
event1 #F 89664  T 48422
# If event1 is true 
# then the second observation's admission date - the first observation's admission date
# If event1 is FALSE
# then NULL
# for (i in 1:length(event1)){
#   if event1[i] <- TRUE {
#     admi_date2_nohistory[i] <- md8[i+1,6] -md8[i,6]
#   }
# }


# Approach II: In md8, get the position of the first observation of each readmitted patient
# step 1, in md8, get the position of all obs of each readmitted patient ,this is position_md8_md10
length(pidmd10) #48422
position_md8_md10 <- which(md8[,5] %in% pidmd10) #159635  (range is from 1 to 249299)
head(position_md8_md10,25);tail(position_md8_md10,25)
head(md8[,5],25)
head(pidmd10,25)
position_md8_md10

#
test <- numeric(159635)
for (i in 1:length(position_md8_md10)){
  if (position_md8_md10[i+1]- position_md8_md10[i] == 1){
    test[i] <-1
  }
}


head(test,25)
tail(test,25)
head(position_md8_md10,25)
tail(position_md8_md10,25)

# Approach III, best one: diff(position_md8_md10)


#subsetting by genders
