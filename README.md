# Peer-graded Assignment: Getting and Cleaning Data Course Project

####load the required libraries:

```{r}
library(dplyr)
library(data.table)
library(tidyr)
library(reshape2)
```


## Download the files and load data files.
Following code checks if the zip file is already present. If the file is not present, zip file is
downloaded and then extracted using unzip.

Subsequently the code loads all the data files.

```{r}
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

```

### Rename the columns:

Following code renames the column names for activity, subject, features and labels data frame.

```{r}
ytrain <- rename(ytrain, activityNum = V1)
ytest <- rename(ytest, activityNum = V1)

stest <- rename(stest, subject = V1)
strain <- rename(strain, subject = V1)

features <- rename(features, featureNum = V1, featureName = V2)
labels <- rename(labels, activityNum = V1, activityName = V2)

```


##1. Merges the training and the test sets to create one data set.

Following code performs the rbind to merge the training and test data set.
And then the code performs the cbind all data sets.

```{r}
x <- rbind(xtrain, xtest)
y <- rbind(ytrain, ytest)
s <- rbind(strain, stest)
colnames(x) <- features$featureName

fulldata <- cbind(s,y,x)
dim(fulldata)

```



##2. Extracts only the measurements on the mean and standard deviation for each measurement.

Following code greps only the mean and std. deviation features to create new vector.
And then only the columns [mean, std. deviation, subject, activityNum] from the fulldata.

```{r}
meanstd_features <- grep("mean\\(\\)|std\\(\\)", features$featureName,value=TRUE)
length(meanstd_features)
meanstd_features <- union(c("subject","activityNum"), meanstd_features)
fulldata <- subset(fulldata, select=meanstd_features)
dim(fulldata)

```



##3. Uses descriptive activity names to name the activities in the data set

Following code merges the activity labels/names with activities in the full data set. 

```{r}
fulldata <- merge(labels, fulldata, by="activityNum", all.x = TRUE)
fulldata$activityName <- as.character(fulldata$activityName)
dataAggr<- aggregate(. ~ subject - activityName, data = fulldata, mean) 

fulldata <- tbl_df(arrange(dataAggr,subject,activityName))

```


##4. Appropriately labels the data set with descriptive variable names.

Following code greps and replaces the activity names with descriptive names. 

```{r}
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

```



##5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Following code writes the tidy data into TidyData.txt.

```{r}
write.table(fulldata, "TidyData.txt", row.name=FALSE)

```


