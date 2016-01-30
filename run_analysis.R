setwd("~/coursera/cleaning-data/coursera-cleaning-data")
#install.packages("data.table")
#install.packages("dplyr")
library(data.table)
library(dplyr)

dataDir <- "~/coursera/cleaning-data/coursera-cleaning-data/data"
if (!file.exists(dataDir)){
  dir.create(dataDir)
}

zipPath <- paste(dataDir, "/assigmentDataset.zip", sep="")
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", zipPath, method = "curl")
unzip(zipPath, exdir = dataDir)

dataSetDir <- paste(dataDir, "/UCI HAR Dataset", sep="")

testActivities <- read.table(paste(dataSetDir, "/test/y_test.txt", sep=""))
testSubjects <- read.table(paste(dataSetDir, "/test/subject_test.txt", sep=""))
testSet <- read.table(paste(dataSetDir, "/test/X_test.txt", sep=""))

trainActivities <- read.table(paste(dataSetDir, "/train/y_train.txt", sep=""))
trainSubjects <- read.table(paste(dataSetDir, "/train/subject_train.txt", sep=""))
trainSet <- read.table(paste(dataSetDir, "/train/X_train.txt", sep=""))

features <- read.table(paste(dataSetDir, "/features.txt", sep=""))
activityLabels <- read.table(paste(dataSetDir, "/activity_labels.txt", sep=""))

merged <- rbindlist(list(testSet, trainSet))
activities <- rbindlist(list(testActivities, trainActivities))
subjects <- rbindlist(list(testSubjects, trainSubjects))
setnames(subjects, c("subjectId"))

activity <- factor(activities$V1, levels = activityLabels$V1, labels = activityLabels$V2)

meanAndStdColumns <- filter(features, grepl(".*mean.*|.*std.*", V2)) %>% mutate(summaryDataName = gsub("()", "", V2, fixed = TRUE)) %>% mutate(summaryDataName = gsub("-", "_", summaryDataName, fixed = TRUE))
meanAndStdSet <- select(merged, meanAndStdColumns$V1)
setnames(meanAndStdSet, meanAndStdColumns$summaryDataName)
meanAndStdSet <- cbind(subjects, activity, meanAndStdSet)
meansBySubcjetIdAndActivity <- summarise_each(group_by(meanAndStdSet, subjectId, activity), funs(mean))

summaryFile <- paste(dataDir, "/../summary.csv", sep="")
write.csv(meansBySubcjetIdAndActivity, summaryFile, row.names = FALSE, quote = FALSE, sep = ",")

