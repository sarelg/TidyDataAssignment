# setwd('./gcdataass/')

library(mgsub)
library(dplyr)

# load features

features <- read.table('features.txt')

# load the data and assign the col names from the features

x_test <- read.table('./test/X_test.txt', col.names = as.vector(features$V2))
y_test <- read.table('./test/Y_test.txt')
x_train <- read.table('./train/X_train.txt', col.names = as.vector(features$V2))
y_train <- read.table('./train/Y_train.txt')

# rename the y vectors to be the activities and add as a column in each x df

names <- c('walking', 'walking_upstairs', 'walking_downstairs', 'sitting', 'standing', 'laying')
nums <- c('1', '2', '3', '4', '5', '6')

y_test <- mgsub(y_test, nums, names)
y_train <- mgsub(y_train, nums, names)

x_test$activity <- y_test$V1
x_train$activity <- y_train$V1

# add a column for the train and test dfs to indicate which is which

x_test$train_test <- rep('test', times = length(x_test$tBodyAcc.mean...X))
x_train$train_test <- rep('train', times = length(x_train$tBodyAcc.mean...X))

# combine the dataframe into one

total <- rbind(x_train, x_test)

# only keep the columns with mean, std, activity and train_test - this is the total

total <- total[,grep('mean\\.|std\\.|activity|train_test', colnames(total))]

# get the subjects and add them to the total

subjtrain <- read.table('./train/subject_train.txt')
subjtest <- read.table('./test/subject_test.txt')
subj <- rbind(subjtrain, subjtest)
total$subject <- subj$V1

# make the colnames more readable

colnames(total) <- tolower(colnames(total))
colnames(total) <- gsub('\\.', '', colnames(total))
colnames(total) <- gsub('mean', '_mean_', colnames(total))
colnames(total) <- gsub('std', '_std_', colnames(total))

# group subjects and activities using dplyr and create a new data frame with the mean for each subject and activity

all_group <- group_by_at(total, vars(subject, activity))
sub_act_total <- summarize_if(all_group, is.numeric, mean) %>% arrange(subject)

write.table(sub_act_total, 'final_data.txt', row.name = FALSE)
