#Merge the rotation dataset and the raw gaze dataset.  Only participant 1001.
  
require(zoo)
require(data.table)

#you can probably just use a default for some of these since you only care about first 4 and last 4.
csvnames <- read.csv('C:/Users/jessica.mueller/Google Drive/NSF - Eye Tracking Clustering/Merge-Asynchronous-Data/FilePathsforMerge.csv', header=T)
csvnames$rawname <- as.character(csvnames$rawname)
csvnames$rawpath <- as.character(csvnames$rawpath)
csvnames$rotname <- as.character(csvnames$rotname)
csvnames$rotationpath <- as.character(csvnames$rotationpath)
csvnames$mergedname <- as.character(csvnames$mergedname)
csvnames$finalname <- as.character(csvnames$finalname)
csvnames$finalcsv <- as.character(csvnames$finalcsv)
csvnames$redfinalname <- as.character(csvnames$redfinalname)
csvnames$redfinalcsv <- as.character(csvnames$redfinalcsv)


mergefile <- function(rawname, rawpath, rotname, rotationpath, mergedname, finalname, finalcsv, redfinalname, redfinalcsv){

#Import the raw file (raw.1001) and the rotation file (rot.1001)
raw <- read.table(rawpath, sep = '\t', skip=1)
setnames(raw, old=c("V1","V3","V6","V7"), new=c("Set.Name","Elapsed.Time..seconds.","GazeX","GazeY"))
rot <- read.csv(rotationpath, header=T)

#Reduce these files down to only the important variables
raw <- subset(raw, select=c("Set.Name","Elapsed.Time..seconds.","GazeX","GazeY"))
rot <- subset(rot, select=c("Time","HeadHeading", "HeadPitch","HeadRoll", "HeadRotationQ"))

#rename cols in raw set.
names(raw)[names(raw)=="Elapsed.Time..seconds."] <- "ElapsedTime"

#Create index variable so you can go back in later and use it to keep only
#good points from the RAW set with the ROT data appended back to it; this 
#keeps you from having duplicate time stamps and duplicate gaze data from when
#rotation data changes between a raw data timestep.
raw$ind <- seq(1:dim(raw)[1])


#Adjust the rotation set "Time" so that it becomes elapsed seconds since 0.
#If you have to add an offset component to the rot timestamp to make up for a 
#delay, do that here (time <- time + delaylength).
rot$TimeX <- as.numeric(substr(rot$Time, 12, 13))
rot$TimeY <- as.numeric(substr(rot$Time, 15, 16))
rot$TimeZ <- as.numeric(substr(rot$Time, 18, 23))
rot$TimeSec <- (rot$TimeX*3600 + rot$TimeY*60 + rot$TimeZ)
minrot <- min(rot$TimeSec) #find minimum value of time
rot$ElapsedTime <- rot$TimeSec - minrot #convert t(s) to elapsed.

#merge raw.1001 and rot.1001, backfill, and keep all NA values.
mergedset <- NULL
mergedset <- na.locf(merge(raw, rot, by="ElapsedTime", all=TRUE))

#Force the values into a numeric format instead of char from the merge (ID was
#string var, so it all went that way).
mergedset$ElapsedTime <- as.numeric(mergedset$ElapsedTime)
mergedset$ind <- as.numeric(mergedset$ind)
mergedset$GazeX <- as.numeric(mergedset$GazeX)
mergedset$GazeY <- as.numeric(mergedset$GazeY)
mergedset$HeadHeading <- as.numeric(mergedset$HeadHeading)
mergedset$HeadPitch <- as.numeric(mergedset$HeadPitch)
mergedset$HeadRoll <- as.numeric(mergedset$HeadRoll)
mergedset$HeadRotationQ <- as.numeric(mergedset$HeadRotationQ)


#Eliminate consecutive duplicates based on raw.1001$ind
mergedset <- as.data.table(mergedset) #define as data table
mergedset[, lag.ind:=c(NA, ind[-.N])] #won't work until you redfine as data.table
mergedset$check <- mergedset$lag.ind - mergedset$ind #check = 0 for duplicated raw
finalsetname <- subset(mergedset, check != 0 & HeadRotationQ == 1, 
                     select=c("ElapsedTime", "GazeX","GazeY", "HeadHeading", 
                     "HeadPitch","HeadRoll")) 
                    #HeadRotationQ == 1 corresponds to good data; 
                    #HeadRotationQ of 0.5 or 0 means not enough cameras were
                    #tracking subject's head during that observation.

#Output file 
write.csv(finalsetname, file=finalcsv, row.names=FALSE)

#Create a reduced raw data set "data.red" systematically sampling that large set
finalsetname$index <- seq(1:dim(finalsetname)[1]) #create column from 1 to the end of the dataset
finalsetname$include <- ifelse(finalsetname$index %% 10 == 1, 1, 0) #Mark every 10th obs
redset <- subset(finalsetname, include == 1, 
                    select=c("ElapsedTime", "GazeX","GazeY", "HeadHeading", 
                    "HeadPitch","HeadRoll"))

#Output reduced file 
write.csv(redset, file=redfinalcsv, row.names=FALSE)
return(finalname)
}



#import a dataset (csvnames) with all those function terms
#for (i in 1:dim(data)[2]) {

for (i in 6:23) {
  rawname <- csvnames[i,1]
  rawpath <- csvnames[i,2]
  rotname <- csvnames[i,3]
  rotationpath <- csvnames[i,4]
  mergedname <- csvnames[i,5]
  finalname <- csvnames[i,6]
  finalcsv <- csvnames[i,7]
  redfinalname <- csvnames[i,8]
  redfinalcsv <- csvnames[i,9]
  partid <- csvnames[i,10]

  mergefile(rawname, rawpath, rotname, rotationpath, mergedname, finalname, finalcsv, redfinalname, redfinalcsv)
}

#theoretically this will export VERY MANY of the merged files
#and VERY MANY of the reduced merged files.  Throw those in Gdrive to figure out the
#clustering code.



##############
#Once that works
#Try to import all the reduced merged files and stack them.
