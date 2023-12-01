## Instructions to run Spindle GUI

1. Do not change any file names or locations within the folder 'Spindle GUI Package'; the code is dependent on specific file names.

2. To begin scoring spindles, ensure that the EEG data is in the correct format: EDF. For the GUI, the location of the data does not matter.

3. Open and run 'App_Dreem_mfile.m'. Load the desired EDF file. Since this is the first scoring of the data, it should open as "GUI in Annotation Mode".

4. Begin to score spindles by clicking the beginning and end of the spindle. Each frame shown in the GUI is a 30-second epoch at 250 Hz. In the case of an incorrectly marked spindle, simply uncheck the box in the bottom interface next to the corresponding timestamp of the incorrectly scored spindle. As long as the box is not checked, it will not appear in the final scoring.

5. Continue to score spindles until at least four epochs each have at least one spindle marked. Upon hitting "Save", the spindle data will automatically be saved to the folder: 'Spindle Logs - Manual Scored'.

6. In the case of re-editing a previous scoring, re-open the same EEG data file within the GUI and continue to edit. The same rater's initials *must* be used, otherwise, it will begin a new scoring.

7. If results from PSASD are to be reviewed, simply follow the same steps above, making sure that the algorithm scored file is in the correct folder: 'Spindle Logs - Algorithm Scored'.  The GUI should now read "GUI in Verification Mode".

**Note:** This pipeline has been tested and verified on **MATLAB R2023a** on Windows 10 Enterprise.
