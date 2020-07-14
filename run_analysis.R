library(dplyr)

#load data
readme <- readLines("UCI HAR Dataset/README.txt", skipNul = TRUE)
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
x_test<- read.table("UCI HAR Dataset/test/X_test.txt")
features <- read.table("UCI HAR Dataset/features.txt")
activity <- read.table("UCI HAR Dataset/activity_labels.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
activity_train <-  read.table("UCI HAR Dataset/train/y_train.txt")
activity_test <-  read.table("UCI HAR Dataset/test/y_test.txt")


#merge data
x_train$subject <- subject_train$V1
x_test$subject <- subject_test$V1
x_train$activity <- activity_train$V1
x_test$activity <- activity_test$V1
x_all <- rbind(x_train, x_test)
x_all$test_train <- c(rep("train", times = 7352), rep("test", times = 2947))
names(x_all) <- c(as.character(features$V2), "subject", "activity", "test_train")

#extract mean and sd
#this is marked with "std()" or "mean()" at the end of each names of the feature

extract_names <- grep("mean|std", names(x_all), value = TRUE)
extract_names <- c(extract_names, "subject", "activity", "test_train")
x_all <- x_all[,extract_names]

merged <- merge(x_all, activity, by.x = "activity", by.y = "V1")
merged$activity <- NULL

merged <-rename(merged, activity = V2)

#descriptive names transformation
names <- (names(merged))[1:79]
names <- gsub("^t", "TimeDomainSignals", names)
names <- gsub("^f", "FrequencyDomainSignalsFromFourierTransformation", names)
names <- gsub("Gyro", "FromGyroscope", names)
names <- gsub("Acc", "FromAccelerometer", names)
names <- gsub("Mag", "MagnitudeAccordingToEuclideanNorm", names)
names <- gsub("Freq", "Frequency", names)
names <- gsub("Body", "OfBody", names)
names <- gsub("Gravity", "OfGravity", names)
names <- gsub("Jerk", "InJerkSignals", names)
names <- gsub("std", "StandardDeviation", names)
names <- gsub("X", "X-direction", names)
names <- gsub("Y", "Y-direction", names)
names <- gsub("Z", "Z-direction", names)
names <- c(names, "subject", "test_train", "activity")

names(merged) <- names
merged$activity <- as.character(merged$activity)
clean_data <- merged

#step 5
by_clean_data <- group_by(clean_data[c(1:80, 82)], activity, subject)
by_clean_data <- summarise_all(by_clean_data, mean)
write.table(by_clean_data, file = "clean_data.txt", row.names = FALSE)

