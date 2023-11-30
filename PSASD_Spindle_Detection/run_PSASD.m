function run_PSASD()
    
    % initialize local directories

    % provide the location of the batch file
    mydir  = pwd;
    idcs   = strfind(mydir,'\');
    newdir = mydir(1:idcs(end)-1);

    filename = strcat(newdir,'\Batch Files\PSASD_BatchFile.xlsx');
    input_data = readtable(filename);

    %% initializations
    
    % Iterate through each row and call PSASD_Training function
    for row_idx = 1:size(input_data, 1)
        % Get input arguments for the current row
        record_label = input_data.Record_Label(row_idx);
        eeg_filepath_str = input_data.EEG_Filepath{row_idx};
        annotated_spindles_filepath_str = input_data.Annotated_Spindles_Filepath{row_idx};
        epochrange_str = input_data.epochrange{row_idx};
        gridsize_str = input_data.gridsize{row_idx};
        runcondition_str = input_data.runcondition{row_idx};
        mode_str = input_data.Analysis_Type{row_idx};   
        optimization_str = input_data.optimization{row_idx};   
        staging_str = input_data.staging{row_idx};
        % Check the "mode" value and call the appropriate function
        if strcmpi(mode_str, 'training')
            % Call the PSASD_Training function with the current row's arguments
            PSASD_Training(row_idx, "epochrange", epochrange_str, "gridsize", gridsize_str, ...
                "runcondition", runcondition_str);
    
            % Display a message indicating the function call for the current row
            fprintf('PSASD_Training called with Record_Label: %d, EEG_Filepath: %s, mode: %s\n', ...
                record_label, eeg_filepath_str, mode_str);
        elseif strcmpi(mode_str, 'testing')
            % Call the PSAD_testing function with the current row's arguments
            PSASD_Testing(row_idx, 'epochrange', epochrange_str,  ...
                'optimization', optimization_str, 'staging', staging_str);

           % Display a message indicating the function call for the current row
            fprintf('PSASD_Testing called with Record_Label: %d, EEG_Filepath: %s, mode: %s\n', ...
                record_label, eeg_filepath_str, mode_str);
        else
            fprintf('Invalid "mode" value for row %d. Skipping...\n', row_idx);
        end
    end
end
