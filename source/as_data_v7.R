# |----------------------------------------------------------------------------------|
# | Project: Ankylosing Spondylitis                                                  |
# | Script: Make the data set for the analysis                                       |
# | Author: Davit Sargsyan, Lyudvig Petrosyan                                        |
# | Principal Investigator: John B. Kostis                                           | 
# | Coordinator: Nora Cosgrove                                                       |
# | Created: 05/26/2017                                                              |
# | Modified: 04/21/2018 (DS):  using package 'icd'. Used 'shiny.icd' app to get     |
# |                             diagnoses lists                                      |
# |           06/23/2018 (DS): created analysis data set (V5 of data source code)    |
# |           11/12/2018 (DS): added stroke and TIA                                  |
# |           11/17/2018 (DS): removed other sponylities; consolidated cancers       |
# |           12/21/2018 (DS): save demographics for matching; discard comorbidities |
# |           12/22/2018 (DS): rerun and save data + log                             |
# |----------------------------------------------------------------------------------|
sink(file = "tmp/log_as_data_v7.txt")
date()

# Header----
options(scipen = 999)

# Load packages
require(data.table)
require(knitr)
require(icd)

# PART I----
# Load MIDAS----
# NOTE: data was preprocessed. See project 
# 'midas' R script 'export_midas_from_csv_to_rdata_v4.R'
system.time(load("E:/MIDAS/midas15_clean.RData"))
midas15

# Remove unused variables----
midas15[, ZIP := NULL]
midas15[, TOTBIL := NULL]
midas15[, DIV := NULL]
midas15[, STATUS := NULL]
gc()

# Number of patients
length(unique(midas15$Patient_ID))
# 18,057,028 records of 4,446,438 patients

# Exclude Emergency/Other Outpatient---- 
# 1 = inpatient
# 2 = ER outpatient
# 3 = same day surgery (SDS) outpatient
# 4 = other outpatient (non-ER and non-SDS)
# 5 = non-ER outpatient (3 or 4)
t1 <- table(midas15$YEAR,
            midas15$ADM_TYPE)
kable(format(t1, big.mark = ","))
# |     |1       |2       |3       |4      |5       |
# |:----|:-------|:-------|:-------|:------|:-------|
# |1995 |445,427 |0       |0       |0      |51,019  |
# |1996 |462,937 |0       |0       |0      |60,475  |
# |1997 |469,139 |0       |0       |0      |73,844  |
# |1998 |480,809 |0       |0       |0      |83,075  |
# |1999 |487,342 |0       |0       |0      |86,042  |
# |2000 |506,849 |0       |0       |0      |90,692  |
# |2001 |512,121 |0       |0       |0      |94,236  |
# |2002 |538,553 |0       |0       |0      |99,614  |
# |2003 |567,841 |0       |0       |0      |104,101 |
# |2004 |565,937 |0       |0       |0      |124,838 |
# |2005 |577,161 |0       |0       |0      |127,869 |
# |2006 |588,474 |0       |0       |0      |126,024 |
# |2007 |588,841 |71      |0       |7      |129,072 |
# |2008 |605,433 |367,436 |78,367  |79,698 |0       |
# |2009 |605,830 |418,646 |95,288  |78,484 |0       |
# |2010 |599,233 |456,183 |102,948 |83,270 |0       |
# |2011 |574,068 |478,511 |105,419 |78,619 |0       |
# |2012 |568,398 |532,918 |98,152  |84,347 |0       |
# |2013 |550,449 |540,387 |97,425  |87,278 |0       |
# |2014 |541,051 |562,339 |102,041 |92,963 |0       |
# |2015 |530,759 |614,445 |106,091 |98,142 |0       |

# Exclude emergency records (missing before 2008)----
midas15 <- droplevels(subset(midas15,
                             ADM_TYPE != 3))
table(midas15$ADM_TYPE)
midas15[, ADM_TYPE := NULL]
gc()
# 17,271,297 records left

length(unique(midas15$Patient_ID))
# 4,310,486 patients

unique(midas15$HOSP)
length(unique(midas15$HOSP))
# 115 hospitals

range(midas15$ADMDAT)
# "1995-01-01" "2015-12-31"

# Separate diagnostic codes (DX1:DX9)
dx <- data.table(Record_ID = 1:nrow(midas15),
                 Patient_ID = midas15$Patient_ID,
                 midas15[, DX1:DX9])
dx

# Load ICD-9/Comorbidity mapping----
l1 <- fread("data/icd9_comorb_map.csv",
            colClasses = c("character"))

# Ankylosing spondylitis and other inflammatory spondylopathies----
l2 <- l1[l1$comorb %in% c("as",
                          "spond"), ]
l2 <- as.comorbidity_map(split(x = l2$code,
                               f = l2$long_desc))
l2

  # Number of patients with each condition----
  dtt <- list()
  for(i in 1:9){
    dtt[[i]] <- icd9_comorbid(x = dx,
                              map = l2,
                              visit_name = "Patient_ID",
                              icd_name = names(dx)[i + 2])
  }
  
  # Patients with these admissons (DX1)----
  as.dx1 <- data.table(dtt[[1]])
  as.dx1
  kable(format(data.frame(N_Patients = colSums(as.dx1)),
               big.mark = ","))
  # |                                                              |N_Patients |
  # |:-------------------------------------------------------------|:----------|
  # |Ankylosing spondylitis                                        |142        |
  # |Inflammatory spondylopathies in diseases classified elsewhere |0          |
  # |Other inflammatory spondylopathies                            |10         |
  # |Sacroiliitis, not elsewhere classified                        |847        |
  # |Spinal enthesopathy                                           |15         |
  # |Unspecified inflammatory spondylopathy                        |52         |
  
  # Patients with these diagnoses (DX1-9)----
  dt2 <- data.table(apply(Reduce("+", dtt),
                          MARGIN = 2,
                          function(a){
                            a > 0
                          }))
  dt2$Patient_ID <- rownames(dtt[[1]])
  kable(format(data.frame(N_Patients = colSums(dt2[, 1:6])),
               big.mark = ","))
# |                                                              |N_Patients |
# |:-------------------------------------------------------------|:----------|
# |Ankylosing spondylitis                                        |1,858      |
# |Inflammatory spondylopathies in diseases classified elsewhere |48         |
# |Other inflammatory spondylopathies                            |37         |
# |Sacroiliitis, not elsewhere classified                        |1,800      |
# |Spinal enthesopathy                                           |46         |
# |Unspecified inflammatory spondylopathy                        |365        |

l3 <- as.comorbidity_map(split(x = l1$code,
                               f = l1$comorb))
l3

# Cancer----
source("source/icd9_dx_get_data_v1.R")
dt.icd <- icd9cm_merge_version_dx(32)
l.cancer <- dt.icd[dt.icd$major_code %in% c(140:209,
                                            235:239), ]
# NOTE: excludes binign neoplasms, ICD9 210-229
l.cancer <- as.comorbidity_map(split(x = l.cancer$code,
                                     f = l.cancer$sub_chapter))
l.cancer
l3 <- c(l3, 
        l.cancer)

# Convert ICD to comorbidities----
dtt <- list()
for(i in 1:9){
  dtt[[i]] <- icd9_comorbid(x = dx,
                            map = l3,
                            visit_name = "Patient_ID",
                            icd_name = names(dx)[i + 2])
}

# Patients with these diagnoses (DX1-9)----
dt3 <- data.table(apply(Reduce("+", dtt),
                        MARGIN = 2,
                        function(a){
                          a > 0
                        }))
dt3 <- data.table(Patient_ID = rownames(dtt[[1]]),
                  dt3)

# Tables of comobidity counts----
t1 <- data.table(Comorb = colnames(dt3)[-1],
                 AS = colSums(dt3[dt3$as, 2:ncol(dt3)]),
                 No_AS = colSums(dt3[!dt3$as, 2:ncol(dt3)]),
                 Combined = colSums(dt3[, 2:ncol(dt3)]))
kable(t1,
      digits = 1) 
# Number of patients:
# |Comorb                                                          |   AS|   No_AS| Combined|
# |:---------------------------------------------------------------|----:|-------:|--------:|
# |akf                                                             |  414|  564520|   564934|
# |ami                                                             |  281|  416938|   417219|
# |as                                                              | 1858|       0|     1858|
# |chf.acute                                                       |  564|  846655|   847219|
# |chf.chron                                                       |   94|  103769|   103863|
# |ckd                                                             |  229|  307919|   308148|
# |cld                                                             |   75|  110799|   110874|
# |copd                                                            |  651|  983600|   984251|
# |diab                                                            |  533| 1084534|  1085067|
# |hyp                                                             | 1563| 3203839|  3205402|
# |lipid                                                           |  875| 1518979|  1519854|
# |spond                                                           |   39|    2247|     2286|
# |stroke                                                          |  129|  254153|   254282|
# |tia                                                             |  112|  184795|   184907|
# |Malignant Neoplasm Of Bone, Connective Tissue, Skin, And Breast |   20|   76880|    76900|
# |Malignant Neoplasm Of Digestive Organs And Peritoneum           |   49|  128764|   128813|
# |Malignant Neoplasm Of Genitourinary Organs                      |  110|  168434|   168544|
# |Malignant Neoplasm Of Lip, Oral Cavity, And Pharynx             |    3|    9586|     9589|
# |Malignant Neoplasm Of Lymphatic And Hematopoietic Tissue        |   37|   76358|    76395|
# |Malignant Neoplasm Of Other And Unspecified Sites               |   68|  252163|   252231|
# |Malignant Neoplasm Of Respiratory And Intrathoracic Organs      |   38|  105373|   105411|
# |Neoplasms Of Uncertain Behavior                                 |   28|   41384|    41412|
# |Neoplasms Of Unspecified Nature                                 |   10|   14769|    14779|
# |Neuroendocrine Tumors                                           |    4|    2886|     2890|

t1 <- addmargins(table(dt3$as,
                       dt3$spond))
kable(format(t1,
             big.mark = ","))
# |      |FALSE     |TRUE  |Sum       |
# |:-----|:---------|:-----|:---------|
# |FALSE |4,306,381 |2,247 |4,308,628 |
# |TRUE  |1,819     |39    |1,858     |
# |Sum   |4,308,200 |2,286 |4,310,486 |
# Out of 1,858 AS patients, 39 also had another spondylitis 

# Exclude all patients with other inflammatory spondylopathies----
id.rm <- unique(dt3$Patient_ID[dt3$spond])
dt3 <- dt3[!(Patient_ID %in% id.rm), ]
dt3$spond <- NULL

# Combine cancers----
dt3[, cancer := (`Malignant Neoplasm Of Bone, Connective Tissue, Skin, And Breast` |
                   `Malignant Neoplasm Of Digestive Organs And Peritoneum` |
                   `Malignant Neoplasm Of Genitourinary Organs` |
                   `Malignant Neoplasm Of Lip, Oral Cavity, And Pharynx` |
                   `Malignant Neoplasm Of Lymphatic And Hematopoietic Tissue` |
                   `Malignant Neoplasm Of Other And Unspecified Sites` |
                   `Malignant Neoplasm Of Respiratory And Intrathoracic Organs` |
                   `Neoplasms Of Uncertain Behavior` |
                   `Neoplasms Of Unspecified Nature` |
                   `Neuroendocrine Tumors`)] 

# Remove different types of cancer----
dt3$`Malignant Neoplasm Of Bone, Connective Tissue, Skin, And Breast` <- NULL
dt3$`Malignant Neoplasm Of Digestive Organs And Peritoneum` <- NULL
dt3$`Malignant Neoplasm Of Genitourinary Organs` <- NULL
dt3$`Malignant Neoplasm Of Lip, Oral Cavity, And Pharynx` <- NULL
dt3$`Malignant Neoplasm Of Lymphatic And Hematopoietic Tissue` <- NULL
dt3$`Malignant Neoplasm Of Other And Unspecified Sites` <- NULL
dt3$`Malignant Neoplasm Of Respiratory And Intrathoracic Organs` <- NULL
dt3$`Neoplasms Of Uncertain Behavior` <- NULL
dt3$`Neoplasms Of Unspecified Nature` <- NULL
dt3$`Neuroendocrine Tumors` <- NULL
dt3
gc()

# Combine acute and chronic HF-----
dt3$hf <- dt3$chf.acute |
  dt3$chf.chron
dt3$chf.acute <- NULL
dt3$chf.chron <- NULL

# Combine AKD and AKF----
dt3$kf <- dt3$akf |
  dt3$ckd
dt3$akf <- NULL
dt3$ckd <- NULL

# Redo Table1----
t1 <- data.table(Comorb = colnames(dt3)[-1],
                 AS = colSums(dt3[dt3$as, 2:ncol(dt3)]),
                 No_AS = colSums(dt3[!dt3$as, 2:ncol(dt3)]),
                 Combined = colSums(dt3[, 2:ncol(dt3)]))
kable(format(t1,
             big.mark = ","))
  # |Comorb |AS    |No_AS     |Combined  |
  # |:------|:-----|:---------|:---------|
  # |ami    |271   |416,643   |416,914   |
  # |as     |1,819 |0         |1,819     |
  # |cld    |73    |110,684   |110,757   |
  # |copd   |635   |982,701   |983,336   |
  # |diab   |524   |1,083,697 |1,084,221 |
  # |hyp    |1,527 |3,201,770 |3,203,297 |
  # |lipid  |855   |1,517,664 |1,518,519 |
  # |stroke |127   |253,974   |254,101   |
  # |tia    |111   |184,602   |184,713   |
  # |cancer |271   |611,703   |611,974   |
  # |hf     |556   |851,899   |852,455   |
  # |kf     |472   |660,925   |661,397   |

# Tables of comobidity permills----
t2 <- data.table(Comorb = colnames(dt3)[-1],
                 AS = round(10^2*colSums(dt3[dt3$as, 
                                             2:ncol(dt3)])/sum(dt3$as),
                            2),
                 No_AS = round(10^2*colSums(dt3[!dt3$as, 
                                                2:ncol(dt3)])/sum(!dt3$as),
                               2),
                 Combined = round(10^2*colSums(dt3[, 2:ncol(dt3)])/nrow(dt3),
                                  2))
kable(format(t2,
             big.mark = ","))
# Percent patients:
  # |Comorb |AS     |No_AS |Combined |
  # |:------|:------|:-----|:--------|
  # |ami    |14.90  |9.68  |9.68     |
  # |as     |100.00 |0.00  |0.04     |
  # |cld    |4.01   |2.57  |2.57     |
  # |copd   |34.91  |22.82 |22.82    |
  # |diab   |28.81  |25.16 |25.17    |
  # |hyp    |83.95  |74.35 |74.35    |
  # |lipid  |47.00  |35.24 |35.25    |
  # |stroke |6.98   |5.90  |5.90     |
  # |tia    |6.10   |4.29  |4.29     |
  # |cancer |14.90  |14.20 |14.20    |
  # |hf     |30.57  |19.78 |19.79    |
  # |kf     |25.95  |15.35 |15.35    |
# Number of patients in each group
length(unique(dt3$Patient_ID))
# 4,308,200, same as the number of rows
length(unique(dt3$Patient_ID[dt3$as]))
# 1,819
length(unique(dt3$Patient_ID[!dt3$as]))
# 4,306,381
write.csv(t2,
          file = "tmp/t2.csv")

# Demographic data of the selected patients (both, cases and controls)----
demog <- unique(data.table(midas15[Patient_ID %in% dt3$Patient_ID,
                                   c("Patient_ID",
                                     "patbdte",
                                     "NEWDTD",
                                     "CAUSE",
                                     "SEX",
                                     "RACE",
                                     "HISPAN")]))
demog
# 5,160,568 records, i.e. some patients have contradicting demograpic parameters
# Take them as recorded for the first time
demog <- demog[order(demog$Patient_ID), ]
demog[, N := 1:.N,
      by = Patient_ID]
demog <- demog[N == 1, ]
demog
# 4,308,200 rows, same as number of unique patients

# Birth year----
demog$birthyear <- as.numeric(substr(demog$patbdte, 1, 4))

# Age at death----
demog$ageatdeath <- round(as.numeric(difftime(demog$NEWDTD,
                                        demog$patbdte,
                                        units = "days"))/365.25, 
                          1)
hist(demog$ageatdeath, 100)

# Cause of death (cv or cancer only)----
# Source: http://www.health.state.ok.us/stats/Vital_Statistics/Death/039_causes.shtml
demog$cvdeath <- (substr(demog$CAUSE, 1, 1) == "I")
table(dead = !is.na(demog$NEWDTD),
      cvdeath = demog$cvdeath)
#              cvdeath
# dead      FALSE    TRUE
# FALSE   3154538       2
# TRUE     792184  361476

# Two patients had cause of death but not date. Reset to no death:
demog$cvdeath[demog$cvdeath & is.na(demog$NEWDTD)] <- FALSE
table(dead = !is.na(demog$NEWDTD),
      cvdeath = demog$cvdeath)
#              cvdeath
# dead      FALSE    TRUE
# FALSE   3154540       0
# TRUE     792184  361476

demog$cancerdeath  <- (substr(demog$CAUSE, 1, 1) == "C")
table(dead = !is.na(demog$NEWDTD),
      cancerdeath = demog$cancerdeath)
#            cancerdeath
# dead      FALSE    TRUE
# FALSE   3154539       1
# TRUE     924421  229239

# One patient had cause of death but not date. Reset to no death:
demog$cancerdeath[demog$cancerdeath & is.na(demog$NEWDTD)] <- FALSE
table(dead = !is.na(demog$NEWDTD),
      cancerdeath = demog$cancerdeath)
#            cancerdeath
# dead      FALSE    TRUE
# FALSE   3154540       0
# TRUE     924421  229239

# Clenup
demog$N <- NULL
demog$CAUSE <- NULL
demog$patbdte <- NULL
demog$NEWDTD <- NULL
demog
gc()

# Merge with AS----
demog <- merge(dt3[, c("Patient_ID",
                       "as")],
               demog,
               by = "Patient_ID",
               all = FALSE)
demog

# Save data and upload to server (continue here on the server)----
attr(demog, "created") <- date()
attr(demog, c("description")) <- "Source: 'as_data_v7.R'."
attributes(demog)
save(demog,
     file = "data/demog.RData")

# NOTE: this data set should be copied to our RStudio server,
# folder "shared/ankylosing.spondylitis"

sessionInfo()
sink()