

#run_analisys.R Scrypt
require(plyr)
## getting the fullData, the automated way.
if(file.exists("./Data")){dir.create("./Data")}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

## check if the .fullData dir exists and more importante if the file exists, let's skip the download
download.file(fileUrl,destfile="./Data/Dataset.zip",method="curl")  


#inflate the zip file 
unzip(zipfile="./Data/Dataset.zip",exdir="./Data")

#deal with the path
localPath <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(localPath, recursive=TRUE)

#read pretty mutch everything 
activityDataTest  <- read.table(file.path(localPath, "test" , "Y_test.txt" ),header = FALSE)
activityDataTrain <- read.table(file.path(localPath, "train", "Y_train.txt"),header = FALSE)

subjectDataTrain <- read.table(file.path(localPath, "train", "subject_train.txt"),header = FALSE)
subjectDataTest  <- read.table(file.path(localPath, "test" , "subject_test.txt"),header = FALSE)

featuresDataTest  <- read.table(file.path(localPath, "test" , "X_test.txt" ),header = FALSE)
featuresDataTrain <- read.table(file.path(localPath, "train", "X_train.txt"),header = FALSE)

featuresDataNames <- read.table(file.path(localPath, "features.txt"),head=FALSE)
activityLabels <- read.table(file.path(localPath, "activity_labels.txt"),header = FALSE)

## concatenate all fullData tables by row.

subjectData <- rbind(subjectDataTrain, subjectDataTest)
activityData<- rbind(activityDataTrain, activityDataTest)
featuresData<- rbind(featuresDataTrain, featuresDataTest)


## add names to the valriables and observations
names(subjectData)<-c("subject")
names(activityData)<- c("activity")
names(featuresData)<- featuresDataNames$V2

## join all together
dataMerged <- cbind(subjectData, activityData)
fullData <- cbind(featuresData, dataMerged)

## get only required columns
subfullDataFeaturesNames<-featuresDataNames$V2[grep("mean\\(\\)|std\\(\\)", featuresDataNames$V2)]
selectedNames<-c(as.character(subfullDataFeaturesNames), "subject", "activity" )

## getting the activity labels from the raw fullData
selectedNames<-gsub("^t", "time",selectedNames)
selectedNames<-gsub("^f", "frequency", selectedNames)
selectedNames<-gsub("Acc", "Accelerometer", selectedNames)
selectedNames<-gsub("Gyro", "Gyroscope", selectedNames)
selectedNames<-gsub("Mag", "Magnitude", selectedNames)
selectedNames<-gsub("BodyBody", "Body", selectedNames)

fullData<- setNames(fullData,selectedNames)
fullData<-subset(fullData,select=selectedNames)


finalData<-aggregate(. ~subject + activity, fullData, mean)
finalData<- arrange(finalData, finalData$subject,finalData$activity)
write.table(finalData, file = "tidyData.txt",row.name=FALSE)
