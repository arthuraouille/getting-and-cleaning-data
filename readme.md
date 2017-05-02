# Getting and Cleaning Data Course Project

This repo is mainly an R script that can create 2 separate tidy datasets from a [set of files](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) which contains data collected from the accelerometers of a smartphone during a [study about Human Activity Recognition](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

#### Assignment

You should create one R script called *run_analysis.R* that does the following :

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#### Description of the provided solution

1. Load necessary libraries

```R
library(tidyr)
library(stringr)
library(dplyr)
```


2. Create *features* dataframe from `features.txt`

```R
features <- read.table("UCI HAR Dataset/features.txt", header=F, sep=" ", stringsAsFactors = F)
```


3. Create *trainSet* dataframe from `X_train.txt`, `subject_train.txt` and `y_train.txt`

Here, the data in `X_train.txt` was so "dirty" (whitespace everywhere) that I had to perform additional operations to remove the leading space, after having tested several unsuccessful methods.

The subject and y dataframes were cleaner, I just had to give them names and them combine them together with my *xTrainSet* to have a clean, full *trainSet*. 
```R
trainFeatures <- rbind(c(" ", " "), features)
xTrainSet <- read.table("UCI HAR Dataset/train/X_train.txt", header=F, sep=";", stringsAsFactors = F)
xTrainSet <- separate(xTrainSet, V1, trainFeatures[,2], sep = " +", remove = T)
xTrainSet <- xTrainSet[, 2:ncol(xTrainSet)]

yTrainSet <- read.table("UCI HAR Dataset/train/y_train.txt", header=F, sep="", stringsAsFactors = F)
names(yTrainSet) = "activity"
subjTrainSet <- read.table("UCI HAR Dataset/train/subject_train.txt", header=F, sep="", stringsAsFactors = F)
names(subjTrainSet) = "subject"

trainSet <- cbind(subjTrainSet, xTrainSet, yTrainSet)
```


4. Create *testSet* dataframe from `X_test.txt`, `subject_test.txt` and `y_test.txt`

The same operations were used to generate a clean, full *testSet*. 
```R
testFeatures <- rbind(c(" ", " "), features)
xTestSet <- read.table("UCI HAR Dataset/test/X_test.txt", header=F, sep=";", stringsAsFactors = F)
xTestSet <- separate(xTestSet, V1, testFeatures[,2], sep = " +", remove = T)
xTestSet <- xTestSet[, 2:ncol(xTestSet)]

yTestSet <- read.table("UCI HAR Dataset/test/y_test.txt", header=F, sep="", stringsAsFactors = F)
names(yTestSet) = "activity"
subjTestSet <- read.table("UCI HAR Dataset/test/subject_test.txt", header=F, sep="", stringsAsFactors = F)
names(subjTestSet) = "subject"

testSet <- cbind(subjTestSet, xTestSet, yTestSet)
```


5. Create *firstSet* dataframe

We combine (rbind) *trainSet* and *testSet* together and make sure the numeric columns are transformed into numeric. Also, remove useless dataframes.
```R
firstSet <- rbind(trainSet, testSet)
firstSet[,2:562] <- as.numeric(as.matrix(firstSet[,2:562]))

rm("features", "subjTestSet", "subjTrainSet", "xTestSet", "xTrainSet", "yTestSet", "yTrainSet", "testFeatures", "trainFeatures", "testSet", "trainSet")
```


6. Extract only measurements on the mean and std from the *firstSet* dataframe

Select only columns whose name contains "mean()" or "std()" + first column (subject) and last column (activity).
```R
firstSet <- firstSet[, c(1, grep("(mean|std)\\(\\)", names(firstSet)), 563)]
```


7. Uses descriptive activity names to name the activities in the data set

Create an *activities* dataframe containing activities and their id. Reformat the text values in this dataframe. Replace "activity_id" in *firstSet* by "activity_name" from the *activities* dataframe.
```R
activities <- read.table("UCI HAR Dataset/activity_labels.txt", header=F, sep=" ", stringsAsFactors = F)
activities$V2 <- gsub("_", " ", activities$V2)
activities$V2 <- gsub("(^|[[:space:]])([[:alpha:]])", "\\1\\U\\2", tolower(activities$V2), perl=TRUE)

firstSet$activity <- activities[firstSet$activity, 2]
```


8. Appropriately label *firstSet* with descriptive variable names.

Perform several renaming operations (full name instead of abbreviations, moving the function (mean/std) at the end of the name, etc.) on the names of *firstSet*.

```R
names(firstSet) <- gsub("^t", "time", names(firstSet))
names(firstSet) <- gsub("^f", "frequency", names(firstSet))
names(firstSet) <- gsub("Acc", "Acceleration", names(firstSet))
names(firstSet) <- gsub("Gyro", "Gyroscope", names(firstSet))
names(firstSet) <- gsub("Mag", "Magnitude", names(firstSet))
names(firstSet) <- gsub("-(mean|std)\\(\\)-([XYZ])", "\\2\\1", names(firstSet))
names(firstSet) <- gsub("-(m|s)(ean|td)\\(\\)", "\\U\\1\\L\\2", names(firstSet), perl = TRUE)
```


9. Finally, write the first tidy dataset to your working directory

```R
write.table(firstSet, "tidyDataset1.txt", row.names = F)
```


10. Create *secondSet* datafram from *firstSet* and apply the mean...

Aggregate (=group by) all columns by activity and subject, and use the *mean* function to regroup the data.
```R
secondSet <- firstSet
secondSet <- aggregate(. ~ activity + subject, secondSet, mean)
```


11. Prefix *secondSet* names with "avg_"

```R
names(secondSet)[3:length(names(secondSet))] <- gsub("(.*)", "avg_\\1", names(secondSet)[3:length(names(secondSet))])
```


12. Finally, write the second tidy dataset to your working directory
```R
write.table(secondSet, "tidyDataset2.txt", row.names = F)
```