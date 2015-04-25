#Merge the rotation dataset and the raw gaze dataset.  Only participant 1001.
require(zoo)
require(data.table)

#Import the raw file (raw.1001) and the rotation file (rot.1001)
raw.1001 <- read.table('D:/COMPLEXITY_MUELLER/IV_MAPPS_RawData/IVRaw_2015.01.26_
                      15.54.04_IV1001.txt', sep = '\t', skip=1, header=T)
rot.1001 <- read.csv('D:/COMPLEXITY_MUELLER/IV_Files/1001/Impala_1001_175207/Imp
                      ala_1001_175207_SmartEye.csv', header=T)

#Reduce these files down to only the important variables
raw.1001 <- subset(raw.1001, select=c("Set.Name","Elapsed.Time..seconds.",
                                      "GazeX","GazeY"))
rot.1001 <- subset(rot.1001, select=c("Time","HeadHeading", "HeadPitch",
                                      "HeadRoll", "HeadRotationQ"))

#rename cols in raw set.
names(raw.1001)[names(raw.1001)=="Elapsed.Time..seconds."] <- "ElapsedTime"

#Create index variable so you can go back in later and use it to keep only
#good points from the RAW set with the ROT data appended back to it; this 
#keeps you from having duplicate time stamps and duplicate gaze data from when
#rotation data changes between a raw data timestep.
raw.1001$ind <- seq(1:dim(raw.1001)[1])


#Adjust the rotation set "Time" so that it becomes elapsed time since 0.
#Step through this (not all at once) or else it won't work.
rot.1001$hour <- as.numeric(substr(rot.1001$Time, 12, 13))
rot.1001$min <- as.numeric(substr(rot.1001$Time, 15, 16))
rot.1001$sec <- as.numeric(substr(rot.1001$Time, 18, 23))
rot.1001$Time <- (rot.1001$hour*3600) + (rot.1001$min*60) + rot.1001$sec
rot.1001.min <- min(rot.1001$Time) #find minimum value of time
rot.1001$ElapsedTime <- rot.1001$Time - rot.1001.min #convert t(s) to elapsed.

#merge raw.1001 and rot.1001, backfill, and keep all NA values.
All.1001 <- NULL
All.1001 <- na.locf(merge(raw.1001, rot.1001, by="ElapsedTime", all=TRUE))

#Force the values into a numeric format instead of char from the merge (ID was
#string var, so it all went that way).
All.1001$ElapsedTime <- as.numeric(All.1001$ElapsedTime)
All.1001$ind <- as.numeric(All.1001$ind)
All.1001$GazeX <- as.numeric(All.1001$GazeX)
All.1001$GazeY <- as.numeric(All.1001$GazeY)
All.1001$HeadHeading <- as.numeric(All.1001$HeadHeading)
All.1001$HeadPitch <- as.numeric(All.1001$HeadPitch)
All.1001$HeadRoll <- as.numeric(All.1001$HeadRoll)
All.1001$HeadRotationQ <- as.numeric(All.1001$HeadRotationQ)


#Eliminate consecutive duplicates based on raw.1001$ind
All.1001 <- as.data.table(All.1001) #define as data table
All.1001[, lag.ind:=c(NA, ind[-.N])] #won't work until you redfine as data.table
All.1001$check <- All.1001$lag.ind - All.1001$ind #check = 0 for duplicated raw
Final.1001 <- subset(All.1001, check != 0 & HeadRotationQ == 1, 
                     select=c("ElapsedTime", "GazeX","GazeY", "HeadHeading", 
                     "HeadPitch","HeadRoll")) 
                    #HeadRotationQ == 1 corresponds to good data; 
                    #HeadRotationQ of 0.5 or 0 means not enough cameras were
                    #tracking subject's head during that observation.

#Output sample file for only participant 1001.  Work on applying to stacked set.
write.csv(Final.1001, file="RAW and ROT for 1001 only_Full.csv", row.names=FALSE)

#Create a reduced raw data set "data.red" systematically sampling that large set
Final.1001$index <- seq(1:dim(data)[1]) #create column from 1 to the end of the dataset
Final.1001$include <- ifelse(data$index %% 10 == 1, 1, 0) #Mark every 10th obs
Final.1001.red <- subset(Final.1001, include == 1, 
                    select=c("ElapsedTime", "GazeX","GazeY", "HeadHeading", 
                    "HeadPitch","HeadRoll"))

#Output sample file for only participant 1001.  Work on applying to stacked set.
write.csv(Final.1001.red, file="RAW and ROT for 1001 only_mod10.csv", row.names=FALSE)
