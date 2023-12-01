## Instructions to edit the batchfile to run the analysis in training and testing (inference) modes for different EEG records:

In the batchfile, `PSASD_BatchFile.xlsx`, edit the Excel file with each row representing either training or testing for one data record. An example of testing and training are provided. For file paths, there is no need to specify the directory as it automatically assumes the file is present in the `Data` folder. Note that the epochs listed when in Training will be the epochs used to train the model. However, in Testing, the model will score all epochs except those provided.

- Curently for the first row in the batchfile, `Analysis_Type` is set to `training` which means the pipline will go into training mode. The grid size has been set to `testing` for a quick execution of the scripts. For the full grid search, it should be set to `full`. For the second row in the batchfile will `Analysis_Type` is set to `testing` which means the pipline will go into inference mode.

**Note:** This pipeline has been tested and verified on **MATLAB R2023a** on Windows 10 Enterprise.
