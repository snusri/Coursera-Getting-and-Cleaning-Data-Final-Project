library(dplyr)
library(memisc)
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileURL, destfile = "./dataset.zip")
              
##Storing the extracted files in folder "files"
unzip("dataset.zip", exdir = "./files")

##Setting the new working directory to be UCI HAR Dataset folder
setwd("./files/UCI HAR Dataset")

##Reading the data files that xon
feature <- read.table("features.txt")
activity_label <- read.table("activity_labels.txt")

## The following set of commands brings all the test data set in the Global Env:
##subject_test.txt
##X_test.txt
##y_test.txt
setwd("./files/UCI HAR Dataset/test")
temp <- list.files(pattern = "*.txt")
list2env(lapply(setNames(temp, make.names(gsub("*.txt$", "", temp))), read.table), envir = .GlobalEnv)


## Similarly, the following set of commands brings all the test data set in the global env:
##subject_train.txt
##X_train.txt
##y_train.txt
setwd("./files/UCI HAR Dataset/train")
temp2 <- list.files(pattern = "*.txt")
list2env(lapply(setNames(temp2, make.names(gsub("*.txt$", "", temp2))), read.table), envir = .GlobalEnv)

##Setting back the working directory to UCI HAR Dataset folder
setwd("./files/UCI HAR Dataset")
                                                    
##Naming all the variables of the dataset brought into the global env
colnames(y_test) <- "ActivityLabel"
colnames(y_train) <- "ActivityLabels"
colnames(subject_test) <- "SubjectIdentfier"
colnames(subject_train) <- "SubjectIdentfier"
colname(X_test) <- feature[,2]
colname(X_train) <- feature[,2]

##Merging all dataframes of the test and train
merge_test <- cbind(subject_test, y_test, X_test)
merge_train <- cbind(subject_train, y_train, X_train)

## Merging test and train dataset                                                    
dat <- rbind(merge_test, merge_train)

##Naming the activity_label names with appropriate activities in the data set
dat$Activity <- activity_label$Activity[match(dat$ActivityLable, activity_label$ActivityLable)]
                                                    
##Bringing the "Activity" column at the beginning
col_idx <- grep("Activity", names(dat))
dat <- dat[, c(col_idx, (1:ncol(dat))[-col_idx])]

dat$SubjectIdentifier <- as.factor(dat$SubjectIdentifier)
dat$ActivityLable <- as.factor(dat$ActivityLable)

##Appropriately labeling the data set with descriptive variable names.                                                
colnames(dat) <- gsub("mean", "Mean Value", names(dat))
colnames(dat) <- gsub("\\(|\\)", "", names(dat2))
colnames(dat) <- gsub("std", "Standard Deviation", names(dat))
colnames(dat) <- gsub("^t", "Time Domain Signals-", names(dat))
colnames(dat) <- gsub("^f", "Frequency Domain Signals-", names(dat))
                                                    
## Creating an independent data set with the average of each variable for each activity and each subject   
mean_values <- aggregate(dat[4:ncol(dat)], list(dat$Activity, dat$SubjectIdentifier), mean)

##Tidying this dataset
mean_values <- rename(mean_values, Acitvity = Group.1)
mean_values <- rename(mean_values, SubjectIdentifier = Group.2)
mean_values <- mean_values[, c(2,1,3:81)]

##Writing the tidy text under tidy.txt
write.table(mean_values, file="tidy.txt", row.names = FALSE)

##Creating a codebook
x <- codebook(mean_values)
Write(x, file = "codebook.txt")
                                                    