function [params] = PSASD_Training(record_num,varargin)
    
    %--------------------------------------------
    % INPUTS
    %--------------------------------------------
    % record_num = row number of batch file to read
    % Either specify second input as "batchargs" to use the inputs below stated in batchfile or directly entered into function 

    % Required:
    % "epochrange", [Starting Epoch:Ending Epoch]

    % Optional: 
    %    "gridsize",   Options: testing, partial, full. Default to full if unspecified. 
    %    "runcondition", Options: normal, normal-n2, leave-one-out. Default to normal if unspecified. 
    %    "runconditionmodifier", EpochNumToLeaveOut (Used for leave-one-out analysis, ignore otherwise)
    %    "threshold",  Options: Decimal number. Eg: :"0.01". For reference, 0.03 is used for PSG data and 0.01 for Dreem headset data. 

    % PUT EXAMPLES OF CODE HERE
    % Example 1: PSASD_Training(15,"batchargs") 
    % - Executes row 15 in the batchfile using the input arguments specified in the batchargs column
    
    % Example 2: PSASD_Training(73,"epochrange","[538:577]","gridsize","testing","runcondition","normal-n2","threshold",0.03)
    % - Executes row 73 in batchfile. Uses only epochs 538 to 577 using the "testing" gridsearch for debugging. Only N2 identified epochs are used.
    % - Threshold value of 0.03 is used since this is PSG data. 

        
    %Paths containing accessory functions
    addpath('./utility_code/');
    addpath('./accessory_code/');
    
    %Parallel Processing Diagnostic Function (useful when this is run on on the cluster)
    feature('numcores')

    %Determine if on cluster
    on_cluster = isunix;
    fprintf("Cluster status: %d\n",on_cluster);

    %% Batch File Handling
    mydir  = pwd;
    idcs   = strfind(mydir,'\');
    newdir = mydir(1:idcs(end)-1);

    Batchfile_Name = strcat(newdir, "\Batch Files\PSASD_BatchFile.xlsx");
    
%     opts = detectImportOptions(Batchfile_Name);
%     opts = setvaropts(opts,'Training_ArgsIn','QuoteRule','keep');
%     opts = setvaropts(opts,'Testing_ArgsIn','QuoteRule','keep');

%     PSASD_Training_Batchfile = readtable(Batchfile_Name,opts);
    PSASD_Training_Batchfile = readtable(Batchfile_Name);
    
    disp(strcat("Batchfile ",Batchfile_Name, " successfully read"));
    
    %Extract information from batch file
    Record_Label_List                = PSASD_Training_Batchfile.Record_Label;
    EEG_Filepath_List                = PSASD_Training_Batchfile.EEG_Filepath;

    AnnotatedSpindles_Filepath_List  = PSASD_Training_Batchfile.Annotated_Spindles_Filepath;

    Training_Channel_Name_List       = PSASD_Training_Batchfile.Channel_Names;
    
    Etc_Params_List                  = PSASD_Training_Batchfile.Etc_Params;

    % Get information for this record number   
    record_label                     = string(Record_Label_List(record_num)); 

    eeg_file_path                    = strcat(newdir, '\Data\', EEG_Filepath_List{record_num});
    annotated_spindles_file_path     = strcat(newdir, '\Spindle Logs - Manual Scored\', AnnotatedSpindles_Filepath_List{record_num});
    
    training_channels                = cellstr(Training_Channel_Name_List{record_num});
    etc_params                       = strcat(newdir, '\Data\', Etc_Params_List{record_num});
                    

    %% Filepath management

    %Convert filepaths from Windows format to Unix format if this program is being run on cluster
    eeg_file_path                = adjustForCluster(eeg_file_path);
    annotated_spindles_file_path = adjustForCluster(annotated_spindles_file_path);
    etc_params                   = adjustForCluster(etc_params);

    outfolder = "./training/";
    training_output_params_path = strcat(outfolder,record_label,".mat");
    if ~exist(outfolder, 'dir'); mkdir(outfolder); end

    %% Input Variable Handling

    %Input Variables

    EPOCHRANGE=[];
    GRIDSIZE="full";
    RUNCONDITION="normal";
    RUNCONDITION_MODIFIER = "";
    PSASD_THRESHOLD = 0.03;

%     % Use Training_Argsin if it exists
%     if strcmpi(varargin{1},"batchargs")
%         varargin=training_argsin;
%         varargin = extractBetween(varargin,'"','"');
%         varargin = cellfun(@(input) strtrim(input),varargin,'UniformOutput',false);
% 
% 
%     end
    
    %Extract name-value pairs from input
    if mod(length(varargin),2)==1
        error("Input parameter error. Your input parameters are either missing a comma or not all parameters are enclosed in double quotes.")

    else
        for i = 1:2:length(varargin)-1

            input_name  = varargin{i};
            input_value = varargin{i+1};
    
            input_name=lower(input_name);
    
            switch input_name
    
                case "epochrange"
                    
                    EPOCHRANGE=str2num(input_value);

                case "gridsize"

                    GRIDSIZE = lower(input_value);

                case "runcondition"

                    RUNCONDITION = lower(input_value);
            
                case "runconditionmodifier"

                    RUNCONDITION_MODIFIER = lower(input_value);

                case "threshold"

                    PSASD_THRESHOLD = str2num(input_value);
            end

        end

    end


    %% Data Importation
    disp(strcat("Attempting to read record: ",record_label));
 
    [EEG, header] = importEEGFile(eeg_file_path,training_channels,'filter');
    disp(strcat("Record successfully read"));
  
    header.record_label = record_label;
    header.outfolder = outfolder; 
    header.epoch_sec=30;
    params.input_EEG_samplingrate = header.samplingrate;

  
    %% Condition Selection
    
    selected_epochs=[]; 

    switch RUNCONDITION

        case "normal"
            
            selected_epochs = EPOCHRANGE; 

        case "normal-n2"

            selected_epochs = EPOCHRANGE; 

            hyno_opts = detectImportOptions(etc_params);

            hypnogram = readtable(etc_params,hyno_opts);
            

            n2_epochs = hypnogram.EpochNumber(strcmp(hypnogram.SleepStage,"S2"));

            selected_epochs = intersect(EPOCHRANGE,n2_epochs);
                      
                     
        case "leave-one-out"
            
            epoch_to_leave_out = str2double(RUNCONDITION_MODIFIER);
            start_epoch = EPOCHRANGE(1);
            end_epoch   = EPOCHRANGE(2);

            nEpochs = endEpoch - startEpoch + 1;
            selected_epochs = linspace(startEpoch,endEpoch,nEpochs);
            selected_epochs(selected_epochs==epoch_to_leave_out)=[];        
            
    end

    %% Import and subset data
    annotated_spindles = readtable(annotated_spindles_file_path);

    [EEG, annotated_spindles] =  data_epoch_selection(EEG, header, annotated_spindles, selected_epochs);

    expert_start_t = annotated_spindles.tstart;
    expert_end_t   = expert_start_t + annotated_spindles.duration;

    %Print out data characteristics for the user for diagnostic purposes
    fprintf("Data Length: %d points at %dHz\n",length(EEG),header.samplingrate); 
    fprintf("This is %d min of data being used for training\n",round(length(EEG)/header.samplingrate/60));
    disp(strcat("The following epochs have been selected for training: ",mat2str(selected_epochs)));
    disp(strcat("This is a total of ", num2str(length(selected_epochs))," epochs."));


    
    %% DETOKS Parameter Setup

    lam1=[]; lam2=[]; lam3=[];
    switch GRIDSIZE

        case "full"

           % Parameters from the DETOKS Parekh paper used for PSASD benchmarking 
            lam1 = 0.01: 0.1: 2;
            lam2 = 5: 0.2: 10;
            lam3 = 5.5: 0.2: 10.5;

        case "extended"
            
           % Parameters used for PSASD benchmarking but with smaller step size
            lam1 = 0.01: 0.1: 2;
            lam2 = 5: 0.1: 10;
            lam3 = 5.5: 0.1: 10.5;

        case "testing"

            % Limited set of parameters for testing purposes

            lam1 = 0.01: 0.5: 2;
            lam2 = 6: 0.25: 6.25;
            lam3 = 8.5: 0.25: 8.75; 
    end
                         
    lam_comb = combvec(lam1, lam2, lam3);
    ngrid = size(lam_comb, 2);
    
    params.deg       = 2;                     % degree of the low pass filter
    params.nit       = 50;                    % Number of iterations
    params.mu        = 0.5;                   % ADMM convergence parameter
    params.th        = PSASD_THRESHOLD;       % 0.03 for PSG data, 0.01 for Dreem headset data
    params.detoks_fs = 200;
    
    
    P    = nan(ngrid, 1);
    TP   = nan(ngrid, 1);
    FP   = nan(ngrid, 1);
    FN   = nan(ngrid, 1);
    
    t_TP = nan(ngrid, 1);
    t_FN = nan(ngrid, 1);
    t_FP = nan(ngrid, 1);
    t_TN = nan(ngrid, 1);

    Sensitivity = nan(ngrid, 1);
    Specificity = nan(ngrid, 1);
    F1   = nan(ngrid, 1);
           
   
    
    %% GRIDSEARCH
    fprintf("Starting grid search over %d gridpoints\n",ngrid);
    
    lam0 = lam_comb(1,:);
    lam1 = lam_comb(2,:);
    lam2 = lam_comb(3,:);

    tic
    parfor ii = 1: ngrid 
        tic

        lambdas = [];
        lambdas.lam0     = lam0(ii); %lam0
        lambdas.lam1     = lam1(ii); %lam1
        lambdas.lam2     = lam2(ii); %lam2

        [output]    = PSASD_Core(EEG,params,lambdas);
        [spin_start_t,spin_end_t]=spindle_bin_vec_time_extract(output.mc_detection,200);
        
        T_epsilon = 1;
        record_length_secs = length(EEG)/header.samplingrate;
        [P(ii), TP(ii), FP(ii), FN(ii), t_TP(ii), t_FN(ii), t_FP(ii), t_TN(ii), Sensitivity(ii), Specificity(ii), F1(ii)] = PSASD_event_comparison(expert_start_t, expert_end_t, spin_start_t, spin_end_t, T_epsilon,record_length_secs);
        
       
        tim = toc;

        if mod(ii,100)==1 

            fprintf('grid search, TP = %d FN = %d , FP = %d, iter %d out of %d in %.1f secs \n', TP(ii), FN(ii) , FP(ii), ii, ngrid, tim);

        end
    end
    tim = toc;
    fprintf("Time taken to execute grid search: %.1f seconds \n",tim);

    %% Gridsearch Parameter Optimization
    
    %Find gridsearch parameter producing highest sensitivity
    
    FN_min = min(FN);  % First minimize false negative then false positive
    FP_min = min(FP(FN == FN_min));
    idx = find((FN == FN_min) & (FP == FP_min));

    lam_norm =  sum(lam_comb.^2, 1);
    [~, idx_maxnorm_sensitivity] = max(lam_norm(idx));
    idx_opt = idx(idx_maxnorm_sensitivity);
        
    params.lam0_sensitivity = lam_comb(1, idx_opt);
    params.lam1_sensitivity = lam_comb(2, idx_opt);
    params.lam2_sensitivity = lam_comb(3, idx_opt);
    params.Sensitivity_max  = Sensitivity(idx_opt); 

    Sensitivity_max = params.Sensitivity_max; 

    % Find gridsearch parameter producing highest F1

    F1(isnan(F1))=0; %Convert NAN's to 0's
    
    F1_max = max(F1);
    idx_f1 = find(F1 == F1_max);
    
    [~, idx_maxnorm_f1] = max(lam_norm(idx_f1)); % Get lambda parameters for it
    idx_opt_f1 = idx_f1(idx_maxnorm_f1);

    params.lam0_f1 = lam_comb(1, idx_opt_f1);
    params.lam1_f1 = lam_comb(2, idx_opt_f1);
    params.lam2_f1 = lam_comb(3, idx_opt_f1); 
    params.F1_max  = F1_max;


    %% Optimized Parameter Output

    save(training_output_params_path, 'P', 'TP', 'FP', 'FN', 't_TP','t_FN', 't_FP','t_TN', ...
        'Sensitivity', 'Specificity','F1', 'Sensitivity_max', 'F1_max', 'params', 'lam_comb', ...
        'annotated_spindles');  
    disp(strcat("Output File Saved to: ",training_output_params_path));
      
end




