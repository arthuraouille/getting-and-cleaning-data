# Merge training and test sets
library(tidyr)
library(stringr)
library(dplyr)

features <- read.table("UCI HAR Dataset/features.txt", header=F, sep=" ", stringsAsFactors = F)

# Train set
trainFeatures <- rbind(c(" ", " "), features)
xTrainSet <- read.table("UCI HAR Dataset/train/X_train.txt", header=F, sep=";", stringsAsFactors = F)
xTrainSet <- separate(xTrainSet, V1, trainFeatures[,2], sep = " +", remove = T)
xTrainSet <- xTrainSet[, 2:ncol(xTrainSet)]

yTrainSet <- read.table("UCI HAR Dataset/train/y_train.txt", header=F, sep="", stringsAsFactors = F)
names(yTrainSet) = "activity"
subjTrainSet <- read.table("UCI HAR Dataset/train/subject_train.txt", header=F, sep="", stringsAsFactors = F)
names(subjTrainSet) = "subject"

trainSet <- cbind(subjTrainSet, xTrainSet, yTrainSet)

# Test set
testFeatures <- rbind(c(" ", " "), features)
xTestSet <- read.table("UCI HAR Dataset/test/X_test.txt", header=F, sep=";", stringsAsFactors = F)
xTestSet <- separate(xTestSet, V1, testFeatures[,2], sep = " +", remove = T)
xTestSet <- xTestSet[, 2:ncol(xTestSet)]

yTestSet <- read.table("UCI HAR Dataset/test/y_test.txt", header=F, sep="", stringsAsFactors = F)
names(yTestSet) = "activity"
subjTestSet <- read.table("UCI HAR Dataset/test/subject_test.txt", header=F, sep="", stringsAsFactors = F)
names(subjTestSet) = "subject"

testSet <- cbind(subjTestSet, xTestSet, yTestSet)

firstSet <- rbind(trainSet, testSet)
firstSet[,2:562] <- as.numeric(as.matrix(firstSet[,2:562]))

rm("features", "subjTestSet", "subjTrainSet", "xTestSet", "xTrainSet", "yTestSet", "yTrainSet", "testFeatures", "trainFeatures", "testSet", "trainSet")



# Extract only measurements on the mean and standard deviation for each measurement.

firstSet <- firstSet[, c(1, grep("(mean|std)\\(\\)", names(firstSet)), 563)]



# Uses descriptive activity names to name the activities in the data set

activities <- read.table("UCI HAR Dataset/activity_labels.txt", header=F, sep=" ", stringsAsFactors = F)
activities$V2 <- gsub("_", " ", activities$V2)
activities$V2 <- gsub("(^|[[:space:]])([[:alpha:]])", "\\1\\U\\2", tolower(activities$V2), perl=TRUE)

firstSet$activity <- activities[firstSet$activity, 2]



# Appropriately labels the data set with descriptive variable names.

names(firstSet) <- gsub("^t", "time", names(firstSet))
names(firstSet) <- gsub("^f", "frequency", names(firstSet))
names(firstSet) <- gsub("Acc", "Acceleration", names(firstSet))
names(firstSet) <- gsub("Gyro", "Gyroscope", names(firstSet))
names(firstSet) <- gsub("Mag", "Magnitude", names(firstSet))
names(firstSet) <- gsub("-(mean|std)\\(\\)-([XYZ])", "\\2\\1", names(firstSet))
names(firstSet) <- gsub("-(m|s)(ean|td)\\(\\)", "\\U\\1\\L\\2", names(firstSet), perl = TRUE)


write.table(firstSet, "tidyDataset1.txt", row.names = F)



# From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
secondSet <- firstSet

secondSet <- aggregate(. ~ activity + subject, secondSet, mean)
names(secondSet)[3:length(names(secondSet))] <- gsub("(.*)", "avg_\\1", names(secondSet)[3:length(names(secondSet))])

write.table(secondSet, "tidyDataset2.txt", row.names = F)