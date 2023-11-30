function [params] = PSASD_Testing(record_num,varargin)

    % Input:
    % record_num = row number of batch file to read
    % epochrange, [Starting Epoch:Ending Epoch]

    % Optional:
    %    "optimization", Options: "f1", "sensitivity". Defaults to sensitivity if unspecified
    %    "staging",      Options: "n2" to run training only n2 epochs identified from a hypnogram. Will require the "etc_params" column to be filled
    

    % Add paths
    addpath('./utility_code/');
    addpath('./accessory_code/');

    %Determine if on cluster
    on_cluster = isunix;
    fprintf("Cluster status: %d\n",on_cluster);

    %% Batch File Handling
    mydir  = pwd;
    idcs   = strfind(mydir,'\');
    newdir = mydir(1:idcs(end)-1);

    Batchfile_Name = strcat(newdir, "\Batch Files\PSASD_BatchFile.xlsx");
    
    PSASD_Testing_Batchfile = readtable(Batchfile_Name);
    
    Record_Label_List                = PSASD_Testing_Batchfile.Record_Label;
    EEG_Filepath_List                = PSASD_Testing_Batchfile.EEG_Filepath;

  
    Testing_Channel_Name_List        = PSASD_Testing_Batchfile.Channel_Names;
    
    Etc_Params_List                  = PSASD_Testing_Batchfile.Etc_Params;
    
    record_label                     = string(Record_Label_List(record_num)); 

    eeg_file_path                    = strcat(newdir, '\Data\', EEG_Filepath_List{record_num});

    training_output_params_path      = strcat("./training/",record_label,".mat");
    
    testing_channels                 = cellstr(Testing_Channel_Name_List{record_num});
    etc_params                       = strcat(newdir, '\Data\', Etc_Params_List{record_num});

    %% Filepath management

    eeg_file_path                = adjustForCluster(eeg_file_path);
    etc_params                   = adjustForCluster(etc_params);


    %% Input Variable Handling

    EPOCHRANGE  = [];
    OPTIMIZE_PARAM   = "sensitivity";
    STAGING     = "";
    THRESHOLD   = -1;
    

    %Extract name-value pairs from input
    if mod(length(varargin),2)==1
        error("Input parameter error")

    else

        for ii = 1:2:length(varargin)-1

            input_name  = varargin{ii};
            input_value = varargin{ii+1};
    
            input_name=lower(input_name);
    
            switch input_name
    
                case "optimization"

                    OPTIMIZE_PARAM  = lower(input_value);

                case "staging"

                    STAGING    = lower(input_value);

                case "epochrange"

                    EPOCHRANGE = str2num(input_value);

                case "threshold"

                    THRESHOLD = str2num(input_value);

            end

        end

    end

    %% Data Importataion Handling

    % Import EEG and get its parameters
    disp(strcat("Attempting to read record: ",record_label));
    [EEG, header] = importEEGFile(eeg_file_path,testing_channels,'filter');
    disp(strcat("Record successfully read"));

    header.record_label = record_label;
    % header.outfolder = outfolder; 
    header.epoch_sec = 30; % length of epoch in second
   

    % Import DETOKS Parameters
    params = []; lam0 = []; lam1=[]; lam2 = [];

%% Condition Selection

    % Selecting which optimization parameter to use
    switch OPTIMIZE_PARAM 

        case "f1"

            load_param = load(training_output_params_path,'params','FN','FP','lam_comb');

            params = load_param.params;
            loaded_FN = load_param.FN;
            loaded_FP = load_param.FP;
            loaded_lam_comb = load_param.lam_comb;

            if (THRESHOLD ~=-1)
                params.th=THRESHOLD;
            end
    
            lam0 = params.lam0_f1;
            lam1 = params.lam1_f1;
            lam2 = params.lam2_f1;

        case "sensitivity"

            load_param = load(training_output_params_path,'params','FN','FP','lam_comb');

            params = load_param.params;
            loaded_FN = load_param.FN;
            loaded_FP = load_param.FP;
            loaded_lam_comb = load_param.lam_comb;  

            if (THRESHOLD ~=-1)
                params.th=THRESHOLD;
            end
    
            lam0 = params.lam0_sensitivity;
            lam1 = params.lam1_sensitivity;
            lam2 = params.lam2_sensitivity;
    end

    % Epoch selection based on input parameters

    frame_nums = [];   
    selected_epochs = [];

    switch STAGING

        case "n2"
        
            hypnogram  = readtable(etc_params);
            n2_epochs = hypnogram.EpochNumber(strcmp(hypnogram.SleepStage,"S2"));
            selected_epochs = intersect(n2_epochs,EPOCHRANGE);

        case ""

            selected_epochs=EPOCHRANGE;
        case "detection_n2"
            hypnogram  = readtable(etc_params);
            n2_epochs = hypnogram.EpochNumber(strcmp(hypnogram.SleepStage,"S2"));
            selected_epochs = setdiff(n2_epochs,EPOCHRANGE);

    end


    EEG = subsetEEG(EEG,header,selected_epochs);
    lambda.lam0 = lam0;
    lambda.lam1 = lam1;
    lambda.lam2 = lam2;
    
    fprintf("Data Length: %d points at %dHz\n",length(EEG),header.samplingrate); 
    fprintf("This is %d min of data being used for inference\n",round(length(EEG)/header.samplingrate/60));
    disp(strcat("The following epochs have been selected for inference: ",mat2str(selected_epochs)));
    disp(strcat("This is a total of ", num2str(length(selected_epochs))," epochs."));

    params.input_EEG_samplingrate = header.samplingrate;
    output = PSASD_Core(EEG,params,lambda);

    [spin_start_t,spin_end_t]=spindle_bin_vec_time_extract(output.mc_detection,200);
    
    spin_start_idx = int32(spin_start_t*200);
    spin_end_idx   = int32(spin_end_t*200);

    time_map = [];

    for kk = 1:length(selected_epochs)
        
        epoch = selected_epochs(kk);
        temp                          = linspace((epoch-1)*30,epoch*30-(1/200),200*30);
        time_map = [time_map temp];

    end    

    spindle_abs_t_start           = time_map(spin_start_idx);
    spindle_duration              = spin_end_t-spin_start_t;
    spindle_epoch                 = arrayfun(@(start_time) ceil(start_time/30),spindle_abs_t_start);

    spindle_frame_num            = [];

    if STAGING == "n2" | STAGING == "detection_n2"
        for kk = 1:length(spindle_epoch)
        
            epoch_idx = find(n2_epochs==spindle_epoch(kk));
            spindle_frame_num = [spindle_frame_num epoch_idx];
        
        end

    else

        spindle_frame_num = spindle_epoch;
    end

    output_table.frames   = spindle_frame_num';
    output_table.tstart   = spindle_abs_t_start';
    output_table.duration = spindle_duration;
    output_table.y_n      = ones(length(spindle_frame_num),1);
    output_table.epoch    = spindle_epoch';

    otable = table(output_table.frames,output_table.tstart,output_table.duration,output_table.y_n,output_table.epoch);
    otable.Properties.VariableNames = {'frame','tstart','duration','y_n','epoch'};
    
    [~,filename,~] = fileparts(eeg_file_path);
    writetable(otable,strcat(newdir, "/Spindle Logs - Algorithm Scored/",filename,"_spindles_auto.csv"));


    function [Out_EEG] = subsetEEG(In_EEG,header,selected_epochs)

        fs = header.samplingrate;
        numPointsInEpoch = header.epoch_sec * fs;

        Out_EEG = [];
        
        startPoints = (selected_epochs-1).*numPointsInEpoch + 1;
        endPoints   = startPoints + (numPointsInEpoch-1);


        for ii = 1:length(selected_epochs)
            
            Out_EEG = horzcat(Out_EEG,In_EEG(:,startPoints(ii):endPoints(ii)));
            
        end
        
    end




end