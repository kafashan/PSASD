# PSASD
A Personalized Semi-Automatic Sleep Spindle Detection (PSASD) Framework

# Data Download
You need to first download sample data from [here](https://wustl.box.com/s/nhhv77e79l3iudv3396o7ejl0092e4vp).
Please ensure the "Data" folder is a subfolder of the PSASD (parent) folder. 

# Directory Guide

*To access the GUI, click on the 'Spindle GUI' folder. 
*To access the PSASD algorithm, click on 'PSASD_Spindle_Detection'.

All other folders:

Batch Files: houses the CSV files used by PSASD to run multiple data files at once.

Data: houses .edf files used by PSASD for training.

Spindle Logs - Algorithm Scored: files that PSASD has finished scoring will be saved here.

Spindle Logs - Manual Scored: files that have been manually scored by the GUI will be saved here.

Spindle Logs - Verified: files that have been scored by the algorithm and then manually reviewed will be saved here.
