# Merge-Asynchronous-Data
Merge gaze location (x,y) from MAPPS output with head triaxial rotation from SmartEye

Gaze location dataset:
  ParticipantID Time GazeX GazeY
  ParticipantID: anonymous participant identifier ("P1001")
  Time: elapsed time from onset of data collection, in seconds
  GazeX: x-position of raw gaze position on forward view
  GazeY: y-position of raw gaze position on forward view.
  
Rotation dataset:
  RidiculousTimeStamp HeadHeading HeadPitch HeadRoll HeadRotationQ
  RidiculousTimeStamp: format DD-MM-YYYY'T'HH:MM:SS.SSS
  HeadHeading: reflects the "no" head movement from a neutral axis
  HeadPitch: reflects "yes" head movement  from a neutral axis
  HeadRoll: reflects.. tilted head--the "maybe" head movement from neutral axis
  HeadRotationQ: Value of 0 means no cameras are trained on subject head; 
    0.5 means only 1 camera is trained on subject head; 
    1 means 2-5 cameras are on head and quality is sufficient for analysis.

This program imports each file from each participant.
The wacky timestamp is converted to a format that is equivalent to elapsed time in seconds.
Files are merged on elapsed time.  Gaze location is most important here, so the gaze 
rotation is backfilled and the output file is the gaze location set with the corresponding
(backfilled where duplicates are necessary) rotation column bound to the set.
