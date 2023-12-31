## PSASD
A Personalized Semi-Automatic Sleep Spindle Detection (PSASD) Framework

## Data Download
You'll first need to download sample data from [here](https://wustl.box.com/s/nhhv77e79l3iudv3396o7ejl0092e4vp).
Please ensure the `Data` folder is a subfolder of the `PSASD` (parent) folder. 

## Directory Guide

- To access the GUI, click on the `Spindle GUI` folder.
- To access the PSASD algorithm, click on `PSASD_Spindle_Detection` folder.

**All other folders:**

`Batch Files`: houses the CSV files used by PSASD to run multiple data files at once.

`Data`: Contains EDF file and manual sleep staging used by PSASD for training.

`Spindle Logs - Algorithm Scored`: files that PSASD has finished scoring will be saved here.

`Spindle Logs - Manual Scored`: files that have been manually scored by the GUI will be saved here.

`Spindle Logs - Verified`: files that have been scored by the algorithm and then manually reviewed will be saved here.

**Note:** This pipeline has been tested and verified on **MATLAB R2023a** on Windows 10 Enterprise.
