## ------------------------------------------------------------------------
library(dplyr)
library(data.table)
library(tidyr)
library(reshape2)

## ------------------------------------------------------------------------
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file <- "DataSets.zip"
path <- getwd()
fPath <- file.path(path, file)
if(!file.exists(fPath)){
  download.file(url, fPath)
  unzip(fPath)
}
dPath <- file.path(path, "UCI HAR Dataset")

xtrain <- tbl_df(data.table(read.table(file.path(dPath, "train", "X_train.txt"))))
xtest <- tbl_df(data.table(read.table(file.path(dPath, "test", "X_test.txt"))))

ytrain <- tbl_df(data.table(read.table(file.path(dPath, "train", "y_train.txt"))))
ytest <- tbl_df(data.table(read.table(file.path(dPath, "test", "y_test.txt"))))

strain <- tbl_df(data.table(read.table(file.path(dPath, "train", "subject_train.txt"))))
stest <- tbl_df(data.table(read.table(file.path(dPath, "test", "subject_test.txt"))))

dim(xtrain)
dim(xtest)
dim(ytrain)
dim(ytest)
dim(strain)
dim(stest)

features <- tbl_df(data.table(read.table(file.path(dPath, "features.txt"))))
dim(features)

labels <- tbl_df(data.table(read.table(file.path(dPath, "activity_labels.txt"))))
dim(labels)


## ------------------------------------------------------------------------
ytrain <- rename(ytrain, activityNum = V1)
ytest <- rename(ytest, activityNum = V1)

stest <- rename(stest, subject = V1)
strain <- rename(strain, subject = V1)

features <- rename(features, featureNum = V1, featureName = V2)
labels <- rename(labels, activityNum = V1, activityName = V2)


## ------------------------------------------------------------------------
x <- rbind(xtrain, xtest)
y <- rbind(ytrain, ytest)
s <- rbind(strain, stest)
colnames(x) <- features$featureName

fulldata <- cbind(s,y,x)
dim(fulldata)


## ------------------------------------------------------------------------
meanstd_features <- grep("mean\\(\\)|std\\(\\)", features$featureName,value=TRUE)
length(meanstd_features)
meanstd_features <- union(c("subject","activityNum"), meanstd_features)
fulldata <- subset(fulldata, select=meanstd_features)
dim(fulldata)


## ------------------------------------------------------------------------
fulldata <- merge(labels, fulldata, by="activityNum", all.x = TRUE)
fulldata$activityName <- as.character(fulldata$activityName)
dataAggr<- aggregate(. ~ subject - activityName, data = fulldata, mean) 

fulldata <- tbl_df(arrange(dataAggr,subject,activityName))

## ------------------------------------------------------------------------
head(str(fulldata),2)
names(fulldata)<-gsub("std()", "SD", names(fulldata))
names(fulldata)<-gsub("mean()", "MEAN", names(fulldata))
names(fulldata)<-gsub("^t", "time", names(fulldata))
names(fulldata)<-gsub("^f", "frequency", names(fulldata))
names(fulldata)<-gsub("Acc", "Accelerometer", names(fulldata))
names(fulldata)<-gsub("Gyro", "Gyroscope", names(fulldata))
names(fulldata)<-gsub("Mag", "Magnitude", names(fulldata))
names(fulldata)<-gsub("BodyBody", "Body", names(fulldata))

head(str(fulldata),6)


## ------------------------------------------------------------------------
write.table(fulldata, "TidyData.txt", row.name=FALSE)


