## Instructions to run PSASD pipline in training and testing (inference) modes:

1. Add all data into the 'Data' folder. This should include EEG and sleep stage data. 2 data files are provided as examples.

2. In the batchfile, `PSASD_BatchFile.xlsx`, edit the Excel file with each row representing either training or testing for one data record. An example of testing and training are provided. For file paths, there is no need to specify the directory as it automatically assumes the file is present in the `Data` folder. Note that the epochs listed when in Training will be the epochs used to train the model. However, in Testing, the model will score all epochs except those provided.

3. Open and run `run_PSASD.m`. This will run all rows of the batch file. Note: do not change the name of the batch file, or any folder names; the code is dependent on specific file names. Curently for the first row in the batchfile, `PSASD_BatchFile.xlsx`, `Analysis_Type` is set to `training` which means the pipline will go into training mode. The grid size has been set to `testing` for a quick execution of the scripts. For the full grid search, it should be set to `full`. For the second row in the batchfile will `Analysis_Type` is set to `testing` which means the pipline will go into inference mode.

4. The `training` folder stores the PSASD model to be used for scoring the rest of the epochs. After Testing, the model scored spindles should be located in 'Spindle Logs - Algorithm Scored'.

**Note:** This pipeline has been tested and verified on **MATLAB R2023a** on Windows 10 Enterprise.
