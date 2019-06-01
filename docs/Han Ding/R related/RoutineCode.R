getwd()
setwd("C:/Users/Work/Dropbox/WRJ medical school Research projects/MIDAS/DATA")
getwd()

#libraries that I will need.
library(lubridate)
require(lubridate)

#Read in midas here

# correct the original data frame
md <- as.data.frame(midas) 
rm(midas) 


# Inport tarstr, which are the diagnosis list that we need to match in data and delete the patiens
getwd()
tarlist =read.table("TargetList.txt", header = FALSE)
tarstr <- tarlist[,1]; tarstr; rm(tarlist)
tarstr

# md1 is the patient birthday sorted observation list that is older than 18 years old on the year of 2000


md1 <- md
md$PATIENT.BIRTH.DATE <- mdy(md$PATIENT.BIRTH.DATE)
md1 <- md[md$PATIENT.BIRTH.DATE < ymd(19820101),]
md11 <- md1[order(md1$PATIENT.BIRTH.DATE),]


md2 <- md11
md2$DISCHARGE.DATE <- mdy(md2$DISCHARGE.DATE);str(md2$DISCHARGE.DATE)
md3 <- md2[order(md2$DISCHARGE.DATE),]   # SO the discharge date is from 1985-2014
hist(md3$DISCHARGE.DATE,20, freq= TRUE, main="Density Plot of Discharge date, n = 17438660", ylab ="Frequency")
attach(md3)
md4 <- subset(md3,DISCHARGE.DATE < ymd(20000101) & DISCHARGE.DATE >= ymd(19950101))
detach(md3)

diagmtrx <- md4[,17:25]
diagmtrx <- as.matrix(diagmtrx)
mxj <- matrix(NA, nrow = 2704654, ncol = 9); mxj
for (i in 1:9){
  mxj[,i] <- !is.na(match(diagmtrx[,i],tarstr))
}
vm1 <- apply(mxj, 1, any); table(vm1)


pidmd4 <- as.character(md4$Patient_ID) #character n=2704654
mdsub <- cbind(pidmd4,vm1);mdsub;

dfmdsub <- as.data.frame(mdsub)
dfmdsubt <- dfmdsub[which(dfmdsub$vm1=='TRUE'), ] # dfmdsubt's dim is 511363*2
lspiduni <- unique(dfmdsubt$pidmd4) # n = 246163; 
lspidunic <- as.character(lspiduni) # n = 246163;

md5<- subset(md3, !(Patient_ID %in% lspidunic))
dim(md5) #15613903       48
md6<- subset(md5, !(SEX %in% "U"))




#Summary plot of md6
# qplot(SEX, data = md6, main="Sex Distribution in target population")
# qplot(RACE, data = md6, main= "Race Frequency in target population")
# qplot(PRIME, data = md6, main= "Primary Insurance in target population")
# qplot(HISPAN, data = md6, main ="Hispanic Distribution in target population")
# qplot(DISCHARGE.DATE, data = md6, main ="Discharge date Distribution in target population md6")



rm(list=setdiff(ls(), "md6"))

#Read in md6 then run
library(lubridate);library(survival)
tarlist =read.table("TargetList.txt", header = FALSE)
tarstr <- tarlist[,1]; tarstr; rm(tarlist)

md61 <- subset(md6, (md6[,17] %in% tarstr))
md61$NEWDTD <- mdy(md61$NEWDTD)
md61$ADMISSION.DATE <- mdy(md61$ADMISSION.DATE)
md62<- subset(md61,DISCHARGE.DATE < ymd(20140101) & DISCHARGE.DATE >= ymd(20000101))
md62s <- md62[order(md62$Patient_ID),]
md62s$Patient_ID <- as.character(md62s$Patient_ID)
md7 <- md62s[order(md62s[,5],md62s[,6]),]
md7u <- md7[match(unique(md7$Patient_ID), md7$Patient_ID),]
md7u$SEX <- factor(md7u$SEX)
sex <- md7u$SEX
attach(md7u)
age <- round(((ADMISSION.DATE- PATIENT.BIRTH.DATE)/365),0)
detach(md7u)


#Summary plot of md7u which is the unique md7.
library(ggplot2)
age <- (md7u$DISCHARGE.DATE - md7u$PATIENT.BIRTH.DATE)/365.25
aveage <- mean(age);aveage 
qplot(SEX, data = md7u, main="Sex Distribution in target population")
qplot(RACE, data = md7u, main= "Race Frequency in target population")
qplot(PRIME, data = md7u, main= "Primary Insurance in target population")
qplot(HISPAN, data = md7u, main ="Hispanic Distribution in target population")
qplot(DISCHARGE.DATE, data = md7u, main ="Discharge date Distribution in target population md6", binwidth = 30)



