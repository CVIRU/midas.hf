getwd()
setwd("C:/Users/Work/Dropbox/WRJ medical school Research projects/MIDAS/DATA")
load("md8.Rda")
#md9 is the first admission for each patient in md8 
md9 <- md8[match(unique(md8[,5]), md8[,5]),] # n=138086
library(lubridate)
require(lubridate)

# Make some basic statistics about the target population
library(ggplot2)
age <- (md9$ADMISSION.DATE - md9$PATIENT.BIRTH.DATE)/365.25
age <- unclass(age) #trick to transform from difftime to numeric
aveage <- mean(age);aveage 
qplot(SEX, data = md9, main="Sex Distribution in target population")  #adjusted for age
qplot(RACE, data = md9, main= "Race Frequency in target population")  #0, 1, 2  and others
qplot(PRIME, data = md9, main= "Primary Insurance in target population") #Medicaid/selfpaid, medicare, commercial
qplot(ADMISSION.DATE, data = md9, main ="Admission Date Distribution in target population md6", binwidth = 30) #done general

# First, we adjust md9 with age.
# See the histogram of age firsst
hist(as.numeric(age), main = "Histogram of age for md9",xlab = "years old")
# average age when first admissioned is 74.69 years old

summary(age)
names(md9)
pos1834 <- which(age <35)
pos3554 <- which(age >= 35 & age <55)
pos5564 <- which(age >= 55 & age <65)
pos6574 <- which(age >= 65 & age <75)
pos7584 <- which(age >= 75 & age <85)
pos8594 <- which(age >= 85 & age <95)
pos95up <- which(age >= 95)

md9_1834 <- md9[pos1834,]
md9_3554 <- md9[pos3554,]
md9_5564 <- md9[pos5564,]
md9_6574 <- md9[pos6574,]
md9_7584 <- md9[pos7584,]
md9_8594 <- md9[pos8594,]
md9_95up <- md9[pos95up,]


####Sex Distribution in target population adjusted by age group ####
data1<- c(md9_1834[,12],md9_3554[,12])
qplot(SEX, data = md9, main="Sex Distribution in target population")  
tt<- table(md9[,12])
as.vector(tt)
rt <- tt[1]/(tt[1]+tt[2])
unname(rt)
as.vector(table(md9[,12]))[1]

# get all the female sex ratio from multiple data
# we need package qpcR to build the Matrix(NA) in using vectors with different length.
library(MASS)
library(minpack.lm)
library(rgl)
library(robustbase)
library(Matrix)
library(qpcR)

dta <- qpcR:::cbind.na(md9_1834[,12],md9_3554[,12],md9_5564[,12],
        md9_6574[,12],md9_7584[,12],md9_8594[,12],md9_95up[,12])
head(dta)
tail(dta)
table(md9[,12])
table(md9_1834[,12])
table(md9_3554[,12])
table(md9_5564[,12])
table(dta[,1])



ftbr <- numeric(7)
for (i in 1:7) {
  ftbr[i] <- (as.vector(table(dta[,i]))[1])/
    ((as.vector(table(dta[,i]))[1])+(as.vector(table(dta[,i]))[2]))
}

round(ftbr,3)
ct <- c(985,13836,17747,27085,42650,32155,3628)
ctrt <- round(ct/138086,3)
ctrt


#### race distribution####
names(md9)
race <- md9[,13]
table(race)
as.vector(race)
table(race)
unname(race)
levels(race) <- c(4,1,2,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4)
race
qplot(race,  main= "Race Frequency in target population")  #0, 1, 2  and others = 4


#### Insurance distribution####
insur <- md9[,48]
table(insur)
unname(insur)
levels(insur) <- c(rep("Commercials",9),"Mediaid/Self Paid", "Medicare", "Mediaid/Self Paid" )
table(insur)
qplot(insur, main= "Primary Insurance in target population",xlab="Insurance") #Medicaid/selfpaid, medicare, commercial

#Admission date
qplot(ADMISSION.DATE, data = md9, main ="Admission date distribution in target population", binwidth = 20) 


# Usual suspect subsetting
# md8 249299 #md9 138086
names(md8) #patient id is [,5], admission date is [,6]
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


##################################
##################################graphs for md10
age10 <- (md10$ADMISSION.DATE - md10$PATIENT.BIRTH.DATE)/365.25
age10 <- unclass(age10) #trick to transform from difftime to numeric
aveage <- mean(age10);aveage  #73.84 years old

pos1834 <- which(age10 <35)
pos3554 <- which(age10 >= 35 & age10 <55)
pos5564 <- which(age10 >= 55 & age10 <65)
pos6574 <- which(age10 >= 65 & age10 <75)
pos7584 <- which(age10 >= 75 & age10 <85)
pos8594 <- which(age10 >= 85 & age10 <95)
pos95up <- which(age10 >= 95)

md10_1834 <- md10[pos1834,]
md10_3554 <- md10[pos3554,]
md10_5564 <- md10[pos5564,]
md10_6574 <- md10[pos6574,]
md10_7584 <- md10[pos7584,]
md10_8594 <- md10[pos8594,]
md10_95up <- md10[pos95up,]

####Sex Distribution in target population adjusted by age group ####
qplot(SEX, data = md10, main="Sex Distribution in md10")  
tt<- table(md10[,12])
as.vector(tt)
rt <- tt[1]/(tt[1]+tt[2])
unname(rt)
as.vector(table(md9[,12]))[1]

# get all the female sex ratio from multiple data
# we need package qpcR to build the Matrix(NA) in using vectors with different length.
library(MASS)
library(minpack.lm)
library(rgl)
library(robustbase)
library(Matrix)
library(qpcR)

dta <- qpcR:::cbind.na(md10_1834[,12],md10_3554[,12],md10_5564[,12],
                       md10_6574[,12],md10_7584[,12],md10_8594[,12],md10_95up[,12])
head(dta)
tail(dta)
table(md10[,12])
table(md10_1834[,12])
table(md10_3554[,12])
table(md10_5564[,12])
table(dta[,1])



ftbr <- numeric(7)
for (i in 1:7) {
  ftbr[i] <- (as.vector(table(dta[,i]))[1])/
    ((as.vector(table(dta[,i]))[1])+(as.vector(table(dta[,i]))[2]))
}

round(ftbr,3)
ct <- c(393,5079,6470,10062,15477,10127,814)
ctrt <- round(ct/48422,3)
ctrt
round(ftbr,3)

#### race distribution####
names(md10)
race <- md10[,13]
table(race)
as.vector(race)
table(race)
unname(race)
levels(race) <- c(4,1,2,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4)
race
qplot(race,  main= "Race Frequency in md10")  #0, 1, 2  and others = 4


#### Insurance distribution####
insur <- md10[,48]
table(insur)
unname(insur)
levels(insur) <- c(rep("Commercials",9),"Mediaid/Self Paid", "Medicare", "Mediaid/Self Paid" )
table(insur)
qplot(insur, main= "Primary Insurance in md10",xlab="Insurance") #Medicaid/selfpaid, medicare, commercial

#Admission date
qplot(ADMISSION.DATE, data = md10, main ="Admission date distribution in md10", binwidth = 20) 





#md11 represents the md9 that event2 is true
#event 2 is defined as the patient id shows more than once in md8 and the first two admission
# date is > 3 days

event2 <- event1
# FALSE IS STILL FALSE, TRUE in event1 can be False in event2
# If it is false, keep it as false, if it's true, we need to check the Patient_ID's first and second
# admission date in md8, if it's > 3 days, then it's TURE, otherwise, it's false

head(md8$Patient_ID,25)
head(md8$CAUSE,25)
head(md8$STATUS,25)
head(md8$DeathRNUM,25)
head(md8$NEWDTD,25)
names(md8)
