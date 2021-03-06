# Many notes

getwd()
setwd("C:/Users/Work/Dropbox/WRJ medical school Research projects/MIDAS/DATA")
getwd()

# Tried open file to open the midas.RData.  SUCCESSFUL!!!
# Other methods that I tried but failed.
library(data.table) # not working
mydata<-fread("midas.RData") #not working
###########################
filename="midas.RData"  # not working
require(data.table)  # not working
tyr <- fread(filename, h=F, sep=";", nrows=81, skip=168, verbose=T) # not working
###########################
# Tried to click import dataset on the environment tab, can't stop



###########################
# Check what this data is and making it a correct dataframe
head(midas)
names(midas)
names(midas)[17:25]
midas[1:10,17:25]  #something weird about this midas data
midas[1,]
midas[1,1]
midas[1,1:3]
midas[1:2,1:3]
midas[1:2,1]
dim(midas) # Its dim seems alright, but we need to make a working data frame
as.data.frame(midas[1:1000,])
as.data.frame(midas[1:1000,]) -> md
md[1,]
md[1:2,1]
md
as.data.frame(midas) -> md
is.data.frame(md)
rm(midas) 
md[,1]
###############################

###############################
# We wanna label the primary 
pridig=md[,17:25]


table(md[,17])
table(as.character(md[,17])
      
############################
nchar(pridig[,1])[1:3]
nchar(as.character(pridig[,1])[1:3]
))
nchar(as.character(pridig[,1]))[1:3]
5-nchar(as.character(pridig[,1]))[1:3]
paste(rep("0",))
j =5-nchar(as.character(pridig[,1]))[1:3]
paste(rep("0",j))
j
paste(rep("0",j[1:2]))
paste(rep("0",j[1]))
ff= function(x) paste(rep("0",x),sep="")
ff(3)
ff= function(x) paste(rep("0",x),collapse ="")
ff(3)
st1 = as.character(pridig[,1])
sapply(st1,ff)[1:20]
ff= function(x) if(x>0) paste(rep("0",x),collapse ="") else ""
sapply(st1,ff)[1:20]
st1
gg = function(x) { k = 5-nchar(x); paste(ff(k,x),sep="")}
gg(st1[1])
st1[1]
gg = function(x) { k = 5-nchar(x); paste(ff(k),x,sep="")}
gg(st1[1])
st2 = sapply(st1,gg)

##########################################################
#######This part is about matching
#101416 DO some matching to subset the data
str1 = c("42841","42842","42843","4289")
jj <-!is.na(match(pridgns5d,str1))
match(pridgns5d,str1) [1:10]
table(is.na(match(pridgns5d,str1) ))



#################Cabrera's suggestion
i <- md1$PATIENT.BIRTH.DATE > as.Date("1982-01-01")
i[is.na(i)] = F
i
md5 <- md1[i,]
table(i) # see that? my i is wrong

# How to detach package from R
detach("package:ff", unload=TRUE)


# remove object from globle environment except a few
rm(list=setdiff(ls(), "md"))


# How to compare to vector
a= as.numeric(tail(j0,1000))
b= as.numeric(tail(j1,1000))
a-b

# Save and load data frame
save(md6,file="md6.Rda")
load("md6.Rda")


#Surv 
Surv(days2event,event)
plot(Surv(days2event,event))


# Using fake memory, don't use this anymore
memory.limit()
memory.size(200000)
memory.limit()
library(bigmemory.sri)
library(bigmemory)

# Storing rdata as csv


load("md8.Rda")
ls() #returns a list of all the objects you just loaded (and anything else in your environment)
write.csv(md8,
          file="md8.csv")

#Matching 
(x <- c(1,1,2,2,3,3,3,3,4,5))
x <- c(1,1,2,2,3,3,3,3,4,5)
unique(x)
match(unique(x),x)
x[match(unique(x),x)]

# ggplot2 from david
library(data.table)
library(ggplot2)
require(data.table)
require(ggplot2)
# Dummy data
n.animal <- 7
n.trt <- 5
n.read <- 2

d1 <- data.table(read = factor(paste("Reading",
                                     rep(1:n.read, 
                                         each = n.animal*n.trt),
                                     sep = "")),
                 trt = factor(rep(rep(LETTERS[1:n.trt],
                                      each = n.animal),
                                  n.read)),
                 id = factor(rep(1:n.animal, n.read*n.trt)),
                 readout = rnorm(n.animal*n.trt*n.read))

# Plot
ggplot(data = d1) +
  scale_x_discrete("Treatment") + 
  scale_y_continuous("Readout") + 
  ggtitle("Title") +
  facet_wrap(~ read,
             ncol = 1) +
  geom_boxplot(aes(x = trt,
                   y = readout,
                   outlier.shape = NA)) +
  geom_point(aes(x = trt,
                 y = readout,
                 group = id,
                 colour = id),
             size = 3,
             alpha = 0.6,
             position = position_dodge(0.3)) + 
  geom_line(aes(x = trt,
                y = readout,
                group = id,
                colour = id),
            size = 2,
            alpha = 0.6,
            position = position_dodge(0.3)) + 
  guides(colour = guide_legend(title = "ID",
                               title.position="top",
                               nrow = 1)) +
  theme(legend.position = "top",
        axis.text.x = element_text(angle = 45,
                                   hjust = 1))

      