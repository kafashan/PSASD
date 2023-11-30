classdef App_Dreem_mfile < matlab.apps.AppBase
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        toEditField                  matlab.ui.control.NumericEditField
        toEditFieldLabel             matlab.ui.control.Label
        BandpassFilterHzEditField_2  matlab.ui.control.NumericEditField
        BandpassFilterHzEditField_2Label  matlab.ui.control.Label
        ScaleuvEditField_2           matlab.ui.control.NumericEditField
        ScaleuvEditField_2Label      matlab.ui.control.Label
        LoadDataButton               matlab.ui.control.Button
        SelectDatasetDropDown        matlab.ui.control.DropDown
        SelectDatasetDropDownLabel   matlab.ui.control.Label
        SaveButton                   matlab.ui.control.Button
        SleepSpindlesLabel_3         matlab.ui.control.Label
        UITable2                     matlab.ui.control.Table
        SelectEEGFileButton          matlab.ui.control.StateButton
        NextButton                   matlab.ui.control.StateButton
        BackButton                   matlab.ui.control.StateButton
        UIAxes_3                     matlab.ui.control.UIAxes
        UIAxes_2                     matlab.ui.control.UIAxes
        UIAxes                       matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

       
        % Code that executes after component creation
        function startupFcn(app)
            

            format shortG;

            app.UIFigure.Name = 'PSASD';

            % Plot Functions
            app.UIAxes.XMinorTick = 'on';
            app.UIAxes.XMinorGrid = 'on';
            app.UIAxes_2.XMinorTick = 'on';
            app.UIAxes_2.XMinorGrid = 'on';
            app.UIAxes_3.XMinorGrid = 'on';
            app.UIAxes_3.XMinorTick = 'on';
            
 
            app.UIAxes.Tag='Channel 1';
            app.UIAxes_2.Tag='Channel 2';
            app.UIAxes_3.Tag='Channel 3';

                      
                         
            
            %% Global variables
            global simdata;
            
            simdata.fs = 200; simdata.epoch = 30;
            simdata.start_time = [];

            
            simdata.st = 1; %Starting point = 1
            simdata.sp = simdata.epoch*simdata.fs; %sp = Number of points in epoch 


            %simdata.max_epochs = 20;
            simdata.max_amp = 75;
            
            simdata.data = [];

            %Variables for spindle click-to-mark function

            %Flag to enable this feature
            simdata.canClickToRegisterSpindle=1;

            %Other variables to make this functionality work
            simdata.startPointClicked=false;
            simdata.endPointClicked=false;
            simdata.XY_PointClicked = [];
            
            % super expert
            simdata.ex_spin = [];
            simdata.ex_spin_tab = [];
            
            simdata.spin_tab = [];
            
            simdata.fname = [];
            simdata.chn = [];
            simdata.start_epoch = [];
            simdata.frame_num = 0;

            simdata.mode="";
            
            % List directories in the root path
            rootpath = dir('./');
            isub = [rootpath(:).isdir];
            foldnames = [char(rootpath(isub).name)];
            foldnames = cellstr(foldnames(3:end,:));
            
            
            % Disable the 'Back' and 'Next' buttons
            app.NextButton.Enable = 'off';
            app.BackButton.Enable = 'off';
            
            
            %Executes MouseClickedFunction when the Axes is clicked
            %This is necessary for marking spindles by clicking on them
            app.UIAxes.ButtonDownFcn={@MouseClickedFunction,simdata};
            app.UIAxes_2.ButtonDownFcn={@MouseClickedFunction,simdata};
            app.UIAxes_3.ButtonDownFcn={@MouseClickedFunction,simdata};

            warning('off','MATLAB:declareGlobalBeforeUse');

            %Creates unique spindle record for each rater 
            prompt= 'Enter Rater Name ';
            simdata.rater_name=inputdlg(prompt);

            %cd("Code");
            
        end

        % Callback function
        function SelectDatasetDropDownValueChanged(app, event)
            
        end

        % Value changed function: SelectEEGFileButton
        function SelectEEGFileButtonValueChanged(app, event)
            
      
            global simdata;
            
            %[file, cache_folder_path] = uigetfile({'*.edf';'*.h5'},'Select data folder', 'MultiSelect', 'on');

            % [~,data_folder] = uigetfile({'*.edf';'*.h5'},'Select data folder', 'MultiSelect', 'on');
            % folder_info = struct2table(dir(data_folder));
            % 
            % filenames = folder_info.name;
            
            [~,data_folder] = uigetfile({'*.edf';'*.h5'},'Select data folder', 'MultiSelect', 'on');

            data_folder_edf = dir(fullfile(data_folder,'*.edf'));
            folder_info_edf = struct2table(data_folder_edf);
            filenames_edf = folder_info_edf.name;
            if ischar(filenames_edf)
                filenames_edf = {filenames_edf};
            end

            data_folder_h5 = dir(fullfile(data_folder,'*.h5'));
            folder_info_h5 = struct2table(data_folder_h5);
            filenames_h5 = folder_info_h5.name;
            if ischar(filenames_h5)
                filenames_h5 = {filenames_h5};
            end

            filenames = [filenames_edf; filenames_h5];
            % data_folder_h5 = fullfile(data_folder,'*.h5');
            
            % folder_info_h5 = struct2table(dir(data_folder_h5));
            % folder_info = [folder_info_edf; folder_info_h5];
            

            % i=1;
            % while i <= length(filenames)
            %     try 
            %         if strcmp(filenames{i}(end-3:end), '.edf') | strcmp(filenames{i}(end-2:end),'.h5')
            %             i = i + 1;
            %         else 
            %             filenames{i} = [];
            %         end
            %     catch ME
            %         if strcmp(ME.identifier, 'Array indices must be positive integers or logical values.')
            %             filenames{i} = [];
            %         end
            %     end
            % end
            % % filenames = filenames(arrayfun(@(x) ~strcmp(x.name(1),'.'),filenames));
            % display(filenames)


            simdata.folder = data_folder;
            app.SelectDatasetDropDown.Items = filenames;
            app.SelectDatasetDropDown.ItemsData = filenames;

            
%             [~,~,file_ext]=fileparts(file);
%             if file               
%                 
%                 if file_ext == ".edf"                
%                                
%                     rootpath = dir(fullfile(cache_folder_path, '*.edf'));  
% 
%                 elseif file_ext == ".h5"
% 
%                     rootpath = dir(fullfile(cache_folder_path, '*.h5'));
%                 
%                 end
% 
%                 isub = ~[rootpath(:).isdir];
%                 filenames = [char(rootpath(isub).name)];
%                 filenames = cellstr(filenames);
%                 % Add the list of folders as dropdown
%                 simdata.folder = cache_folder_path;
%                 app.SelectDatasetDropDown.Items = filenames;
%                 app.SelectDatasetDropDown.ItemsData = filenames;
% 
%             end      


        end

        % Button pushed function: LoadDataButton
        function LoadDataButtonPushed(app, event)
            
            % Global variables
            global simdata;
            format short;
            
            %Start from the beginning of the EEG 
            simdata.frame_num = 0;
            
            %User input values for max amplitude and BP filter cutoffs
            simdata.max_amp = app.ScaleuvEditField_2.Value;
            simdata.flo = app.BandpassFilterHzEditField_2.Value; 
            simdata.fhi = app.toEditField.Value;
            
            %Get filename and path from the dropdown menu 
            filename = app.SelectDatasetDropDown.Value; 
            filepath = [simdata.folder app.SelectDatasetDropDown.Value]; 
            
            %Import EEG
            [EEG, header] = GUI_importEEGFile(filepath);
            simdata.fs = header.samplingrate;
            
            % minimum order zero-hase Bandstop filter [0.1,0.6] Hz to remove respiratory artifacts
            fprintf('Bandstop filtering with cutoffs [0.1 0.6] Hz to remove respiratory artifacts ... \n');
            ff = msgbox('Bandstop filtering with cutoffs [0.1 0.6] Hz to remove respiratory artifacts ...');
            
            numChans = size(EEG,1);

            for i = 1:numChans
            
                EEG(i,:) = bandstop(EEG(i,:)', [0.1,0.6],  simdata.fs, 'ImpulseResponse','iir')'; 
            
            end
                     
            fprintf('Bandstop filtering completed! \n');

            % minimum order zero-hase Bandpass filter [flo, fhi] Hz
            fprintf(sprintf('Bandpass filtering with cutoffs [%0.1f %0.1f] Hz initiated ... \n', simdata.flo, simdata.fhi));
            close(ff); 
            
            ff = msgbox(sprintf('Bandpass filtering with cutoffs [%0.1f %0.1f] Hz initiated ... \n', simdata.flo, simdata.fhi));

            for i = 1:numChans

                EEG(i,:) = bandpass(EEG(i,:)', [simdata.flo, simdata.fhi],  simdata.fs, 'ImpulseResponse','iir')';

            end 

            fprintf('Bandpass filtering completed! \n');
            close(ff); 


            %% Load manual sleep staging data
            dir_struct = dir( fullfile(simdata.folder,'*.csv') );

            %If sleep staging data exists...
            if numel(dir_struct) > 0
                
                sleep_staging = true;                           
                staging_filename = dir_struct(1).name;
                fprintf('Manual sleep scoring was found and used for detection of relevant epochs \n');

                staging_data = readtable([simdata.folder filesep staging_filename]);
                staging_data.Properties.VariableNames={'Epoch_Number','StartTime','SleepStage'};

                idx_N2 = strcmp(staging_data.SleepStage, 'S2');
                idx_N2N3  = (strcmp(staging_data.SleepStage, 'S2')) | (strcmp(staging_data.SleepStage, 'S3'));
                idx_NREM  = (strcmp(staging_data.SleepStage, 'S1')) | (strcmp(staging_data.SleepStage, 'S2')) | (strcmp(staging_data.SleepStage, 'S3'));          
          
            %If no sleep staging data exists
            else
                
                sleep_staging = false;
                disp('There is no csv file containing manual sleep scoring alongside the EEG file.')

                %Manually point to sleep staging file 
                fig_scoring = uifigure;
                msg = 'Is there a csv file with sleep scoring for this EEG record?';
                title = 'Sleep Scoring?';
                selection = uiconfirm(fig_scoring, msg, title, 'Options', {'Yes','No'}, 'DefaultOption', 1);
                close(fig_scoring);

                epochs = []; stageNames = []; staging_data = []; idx_N2 = []; idx_N2N3 = []; idx_NREM = [];

                if (selection == 'Yes')

                    [slp_file,slp_path] = uigetfile('*.csv','Specify Sleep Scoring File');

                    staging_data = readtable(strcat(slp_path,filesep,slp_file));
                    staging_data.Properties.VariableNames={'Epoch_Number','StartTime','SleepStage'};
                    
                    fprintf("Successfully found manual sleep scoring file \n");

                    idx_N2 = strcmp(staging_data.Sleep_Stage,'S2');
                    idx_N2N3 = strcmp(staging_data.Sleep_Stage,'S2') | strcmp(staging_data.Sleep_Stage,'S3');
                    idx_NREM = strcmp(staging_data.Sleep_Stage,'S1') | strcmp(staging_data.Sleep_Stage,'S2') | strcmp(staging_data.Sleep_Stage,'S3');


                %If no sleep staging data exists, treat the entire dataset as S2
                else

                    epochs = (1:1:ceil(size(EEG,2)/(simdata.fs*30)))';
                    stageNames = repmat("S2",epochs(end),1);
                    staging_data = table(epochs,stageNames,'VariableNames',{'EpochNumber','Stages'});
                    idx_N2 = epochs;
                    idx_N2N3=[];
                    idx_NREM=[];

                end
                
            end                  
                       
            params          = {};
            
            stage_N2_epochs        = staging_data.Epoch_Number(idx_N2, 1);
            stage_N2N3_epochs      = staging_data.Epoch_Number(idx_N2N3, 1);
            stage_NREM_epochs      = staging_data.Epoch_Number(idx_NREM, 1);

            params.staging_data = staging_data;
            params.stage_N2_epochs = stage_N2_epochs;
            params.stage_N2N3_epochs = stage_N2N3_epochs;
            params.stage_NREM_epochs = stage_NREM_epochs;
            

            % Assign filename

            [~,fnametemp,~]=fileparts(filename);
            simdata.fname   = fnametemp;
            simdata.data    = EEG; 
            
            simdata.iChan = [find(contains( lower(cellstr(header.channels)), 'fpz-f8')), ...
                find(contains( lower(cellstr(header.channels)), 'fpz-f7')), ...
                find(contains( lower(cellstr(header.channels)), 'f8-f7'))];
            
            % Read attributes
            simdata.fs = header.samplingrate;
            simdata.ep_num = 1;
            simdata.ep_N2 = params.stage_N2_epochs;
            simdata.ep_N2_len = size(simdata.ep_N2,1);
            %% loading spindle table
            %------------------------------------------------
            %               TABLE FORMAT
            %------------------------------------------------
            %Columns: frame | tstart | duration | y_n | epoch
            %------------------------------------------------
            
            %Get absolute path for directory one level above 
            mydir  = pwd;
            idcs   = strfind(mydir,'\');
            newdir = mydir(1:idcs(end)-1);

            %Use that absolute path to access the folders containing manual
            %and algorithm scored data

            manual_fpath = strcat(newdir,'\Spindle Logs - Manual Scored\',  simdata.fname,'_',simdata.rater_name{1},'_spindles_manual','.csv'); 

            auto_fpath = strcat(newdir,'\Spindle Logs - Algorithm Scored\', simdata.fname,'_spindles_auto','.csv');

            %If the file for algorithm scored values exists...
            if exist(auto_fpath)

                %Read in spindle tables for the manually and automatically scored data
                                
                manual_spin_T = [];
                autoscored_spin_T = readtable(auto_fpath);
        
                if exist(manual_fpath)
                    manual_spin_T = readtable(manual_fpath);
                end
                
                %Vertically concatenate the manual and algorithm scored
                %tables

                combinedTable = [manual_spin_T; autoscored_spin_T];
% 
%                 if size(combinedTable,2)==4
%                     combinedTable = [table(combinedTable.epoch) combinedTable];
%                 end
                
                combinedTable.Properties.VariableNames = {'FrameNum','SpindleStart','Duration','Select','EpochNum'};
                
                %Eliminate overlapping spindles and order the table by
                %frame number (Col 1)
                combinedTable = findSpindleIntersections(combinedTable);
            

                simdata.spin_tab = combinedTable;
                fprintf('GUI in Verification Mode \n');
                ff = msgbox('GUI in Verification Mode');
                simdata.mode="verification";                                  
            
            % If there is previous manual scored data, load it to allow saving and continuing work on one file
            elseif exist(manual_fpath)
                manual_spin_T = readtable(manual_fpath);
                manual_spin_T.Properties.VariableNames = {'FrameNum','SpindleStart','Duration','Select','EpochNum'};
                simdata.spin_tab = manual_spin_T;

                fprintf('Loaded previously saved data \n')
                simdata.mode="manual";


            %If there is no file for algorithm scored data... Hence in
            % manual scoring mode...
            else
                

                varTypes = {'int16','double','double','logical','int16'};

                simdata.spin_tab = table('Size',[0 5],'VariableTypes',varTypes);
                simdata.spin_tab.Properties.VariableNames = {'FrameNum','SpindleStart','Duration','Select','EpochNum'};
                simdata.spin_tab.FrameNum = zeros(0);
                simdata.spin_tab.SpindleStart = zeros(0);
                simdata.spin_tab.Duration = zeros(0);  
                simdata.spin_tab.Select = zeros(0);
                simdata.spin_tab.EpochNum = zeros(0);
                fprintf('GUI in Annotation Mode \n');
                ff = msgbox('GUI in Annotation Mode');
                simdata.mode="manual";

            end
 
            %Start with the first frame 
            simdata.frame_num = 1;
            
            %Get start and end times of the first frame
            frame_tstart  = (simdata.ep_N2(simdata.frame_num) - 1) * simdata.epoch;
            frame_tend    = simdata.ep_N2(simdata.frame_num) * simdata.epoch; 
            
            %Get number of points in epoch and use those to create a time vector
            N = simdata.fs*simdata.epoch;
            t = linspace(frame_tstart, frame_tend, N);

            %Extract all spindles from the table of spindles that "Yes" is selected
            [spindles_tstart, spindles_tend] = extract_splindle_info(simdata.spin_tab, simdata.frame_num);
                        
            % Plot Fpz-F8            
            y = simdata.data(simdata.iChan(1), frame_tstart* simdata.fs+ 1: frame_tend* simdata.fs);
            channel_data = [t;y];
            updateSpindlePlots(app.UIAxes,spindles_tstart,spindles_tend,simdata.max_amp,simdata.fs,channel_data);
    
            % Plot Fpz-F7
            y = simdata.data(simdata.iChan(2), frame_tstart* simdata.fs+ 1: frame_tend* simdata.fs);
            channel_data = [t;y];
            updateSpindlePlots(app.UIAxes_2,spindles_tstart,spindles_tend,simdata.max_amp,simdata.fs,channel_data);
            
            % Plot F8-F7
            y = simdata.data(simdata.iChan(3), frame_tstart* simdata.fs+ 1: frame_tend* simdata.fs);
            channel_data = [t;y];
            updateSpindlePlots(app.UIAxes_3,spindles_tstart,spindles_tend,simdata.max_amp,simdata.fs,channel_data);          
           
            % Update Displayed Table 
            app.UITable2.ColumnFormat={[], 'char','char','logical'};
            app.UITable2.Data = filt_table_editable(simdata.spin_tab, simdata.frame_num, simdata.ep_N2(simdata.frame_num)); % ***
            
            % Enable the 'Next' buttons
            app.NextButton.Enable = 'on';
            app.BackButton.Enable = 'off';
         
        end

        % Value changed function: NextButton
        function NextButtonValueChanged(app, event)
            pause(0.100);
            
            % Global variables
            global simdata;
            simdata.max_amp = app.ScaleuvEditField_2.Value;
            % Update the pointers
            fs = simdata.fs; epoch = simdata.epoch; N = fs*epoch;
            st = simdata.sp+1; sp = simdata.sp+N;
            
            current_frame = simdata.frame_num + 1;

            if current_frame <= length(simdata.ep_N2)
    
                tstart  = (simdata.ep_N2(current_frame) - 1)* epoch;
                tend = simdata.ep_N2(current_frame) * epoch; 
                N = fs * epoch;
                t = linspace(tstart, tend, N);                

                if (tend * fs) > size(simdata.data,2)

                    tend = size(simdata.data,2)/fs;
                    
                    N_Start = (simdata.ep_N2(current_frame) - 1)* epoch * fs;
                    N = size(simdata.data,2) - N_Start;
                    t = linspace(tstart, tend, N);

                end
          
                [tstart_Spin, tend_Spin] = extract_splindle_info(simdata.spin_tab, current_frame);
                %epoch_spindles = [tstart_Spin, tend_Spin];
        
                
                %% Fpz-F8            
                y = simdata.data(simdata.iChan(1), tstart* fs+ 1: tend* fs);
                channel_data = [t;y];
                updateSpindlePlots(app.UIAxes,tstart_Spin, tend_Spin,simdata.max_amp,fs,channel_data);
        
                %% Fpz-F7
                y = simdata.data(simdata.iChan(2), tstart* fs+ 1: tend* fs);
                channel_data = [t;y];
                updateSpindlePlots(app.UIAxes_2,tstart_Spin, tend_Spin,simdata.max_amp,fs,channel_data);
                
                %% F8-F7
                y = simdata.data(simdata.iChan(3), tstart* fs+ 1: tend* fs);
                channel_data = [t;y];
                updateSpindlePlots(app.UIAxes_3,tstart_Spin, tend_Spin,simdata.max_amp,fs,channel_data);
                
                %% Update spindle table
                simdata.frame_num = current_frame;     
                app.UITable2.ColumnFormat={[],'char','char','logical'};
                app.UITable2.Data = filt_table_editable(simdata.spin_tab, simdata.frame_num,simdata.ep_N2(simdata.frame_num)); % ***
                
                
                % Update globa pointers
                
                simdata.st = st; simdata.sp = sp;
            
            else

                disp("End of Record Reached");
            
            end
            
            % Enable/Disable the 'Back' buttons
            if simdata.st == 1
                app.BackButton.Enable = 'off';
            else
                app.BackButton.Enable = 'on';
            end
            
            % Enable/Disable the 'Next' buttons

            %If we've reached the end of the record, disable the "Next" button
            if current_frame == length(simdata.ep_N2)
                app.NextButton.Enable = 'off';
            else
                app.NextButton.Enable = 'on';
            end
            
        end

        % Value changed function: BackButton
        function BackButtonValueChanged(app, event)
            
            pause(0.100);

            % Global variables
            global simdata;
            simdata.max_amp = app.ScaleuvEditField_2.Value;
            % Update the pointers
            fs = simdata.fs; epoch = simdata.epoch; N = fs*epoch;
            sp = simdata.sp-N; st = sp-N+1;
            
            current_frame = simdata.frame_num- 1;

            if current_frame >= 1

                tstart  = (simdata.ep_N2(current_frame)- 1)* epoch;
                tend    = simdata.ep_N2(current_frame)* epoch; 
                N = fs * epoch;
                t = linspace(tstart, tend, N);
            
                [tstart_Spin, tend_Spin] = extract_splindle_info(simdata.spin_tab, current_frame);
               
                %% Fpz-F8            
                y = simdata.data(simdata.iChan(1), tstart* fs+ 1: tend* fs);
                channel_data = [t;y];
                updateSpindlePlots(app.UIAxes,tstart_Spin, tend_Spin,simdata.max_amp,fs,channel_data);
        
                %% Fpz-F7
                y = simdata.data(simdata.iChan(2), tstart* fs+ 1: tend* fs);
                channel_data = [t;y];
                updateSpindlePlots(app.UIAxes_2,tstart_Spin, tend_Spin,simdata.max_amp,fs,channel_data);
                
                %% F8-F7
                y = simdata.data(simdata.iChan(3), tstart* fs+ 1: tend* fs);
                channel_data = [t;y];
                updateSpindlePlots(app.UIAxes_3,tstart_Spin, tend_Spin,simdata.max_amp,fs,channel_data);
            
                %% Update spindle table
                simdata.frame_num = current_frame;     
                app.UITable2.ColumnFormat={[],'char','char','logical'};
                app.UITable2.Data = filt_table_editable(simdata.spin_tab, simdata.frame_num,simdata.ep_N2(simdata.frame_num));
                
                
                % Update globa pointers
                
                simdata.st = st; simdata.sp = sp;                       
            
            
            end                                    
%             
%             %% Fpz-F8            
%             t = linspace(tstart, tend, N);
%             plot(app.UIAxes, t, simdata.data(simdata.iChan(1), tstart* fs+ 1: tend* fs), 'k'); hold(app.UIAxes, 'on'); 
%             for ii = 1: length(tstart_Spin)
%                 tspin_start = tstart_Spin(ii);
%                 tspin_end = tend_Spin(ii);   
%                 tspin = [tspin_start* fs+ 1: tspin_end* fs]/fs;
%                 plot(app.UIAxes, tspin, simdata.data(simdata.iChan(1), tspin_start* fs+ 1: tspin_end* fs), 'r'); hold(app.UIAxes, 'on'); 
%             end 
%             app.UIAxes.YLim = ([-simdata.max_amp,+simdata.max_amp]);
%             app.UIAxes.XLim = ([tstart,tend]);
%             hold(app.UIAxes, 'off'); 
%             %% Fpz-F7
%             plot(app.UIAxes_2, t, simdata.data(simdata.iChan(2), tstart* fs+ 1: tend* fs), 'k'); hold(app.UIAxes_2, 'on'); 
%             for ii = 1: length(tstart_Spin)
%                 tspin_start = tstart_Spin(ii);
%                 tspin_end = tend_Spin(ii);   
%                 tspin = [tspin_start* fs+ 1: tspin_end* fs]/fs;
%                 plot(app.UIAxes_2, tspin, simdata.data(simdata.iChan(2), tspin_start* fs+ 1: tspin_end* fs), 'r'); hold(app.UIAxes_2, 'on'); 
%             end    
%             app.UIAxes_2.YLim = ([-simdata.max_amp,+simdata.max_amp]);
%             app.UIAxes_2.XLim = ([tstart,tend]);
%             hold(app.UIAxes_2, 'off'); 
%             %% F8-F7
%             plot(app.UIAxes_3, t, simdata.data(simdata.iChan(3), tstart* fs+ 1: tend* fs), 'k'); hold(app.UIAxes_3, 'on'); 
%             for ii = 1: length(tstart_Spin)
%                 tspin_start = tstart_Spin(ii);
%                 tspin_end = tend_Spin(ii);   
%                 tspin = [tspin_start* fs+ 1: tspin_end* fs]/fs;
%                 plot(app.UIAxes_3, tspin, simdata.data(simdata.iChan(3), tspin_start* fs+ 1: tspin_end* fs), 'r'); hold(app.UIAxes_3, 'on'); 
%             end      
%             app.UIAxes_3.YLim = ([-simdata.max_amp,+simdata.max_amp]);
%             app.UIAxes_3.XLim = ([tstart,tend]);           
%             hold(app.UIAxes_3, 'off'); 
%             
%             simdata.frame_num = simdata.frame_num - 1;
%             app.UITable2.ColumnFormat={[],'char','char','logical'};
%             app.UITable2.Data = filt_table_editable(simdata.spin_tab, simdata.frame_num, simdata.ep_N2(current_frame));
%             
% 
%             % Update global pointers
%             simdata.st = st; simdata.sp = sp;
            
            % Enable/Disable the 'Back' buttons
            if simdata.frame_num == 1
                app.BackButton.Enable = 'off';
            else
                app.BackButton.Enable = 'on';
            end
            
            % Enable/Disable the 'Next' buttons
%             if simdata.sp == simdata.epoch*simdata.fs*simdata.max_epochs
            if simdata.frame_num == simdata.ep_N2_len    
                app.NextButton.Enable = 'off';
            else
                app.NextButton.Enable = 'on';
            end
            
        end

        % Cell edit callback: UITable2
        function UITable2CellEdit(app, event)
            global simdata;
            i1 = event.Indices(1,1);
            i2 = event.Indices(1,2);

            %If the checkbox is clicked and was previously empty... adds
            %another row
            if (i2 == 4) && (event.PreviousData == 0) && (event.NewData ~= 0)
                simdata.spin_tab = add_new_row(simdata.spin_tab,simdata.frame_num);
                simdata.spin_tab = edit_row(simdata.spin_tab,[i1,i2],simdata.frame_num,event.NewData);
                simdata.spin_tab (uint8(i1),uint8(i2)) = {event.NewData};
                        
            %Edit row but don't add a new row since the checkbox is not clicked
            elseif (event.PreviousData ~= event.NewData) 
                simdata.spin_tab = edit_row(simdata.spin_tab,[i1,i2],simdata.frame_num,event.NewData);

            end

%             elseif (event.PreviousData ~= 0) && (event.PreviousData ~= event.NewData) 
%                 simdata.spin_tab = edit_row(simdata.spin_tab,[i1,i2],simdata.frame_num,event.NewData);
% 
%             %If add a new value and the previous value was empty
%             elseif (event.PreviousData == 0) && (event.PreviousData ~= event.NewData) 
%                 simdata.spin_tab = edit_row(simdata.spin_tab,[i1,i2],simdata.frame_num,event.NewData);
% 
%             end

            
            simdata.max_amp = app.ScaleuvEditField_2.Value;
        
            fs = simdata.fs; epoch = simdata.epoch; iframe = simdata.frame_num; 
 
            [tstart_Spin, tend_Spin] = extract_splindle_info(simdata.spin_tab, iframe);
        
            %epochSpindles = [tstart_Spin, tend_Spin];
         
            updateSpindlePlots(app.UIAxes,tstart_Spin, tend_Spin,simdata.max_amp,fs);
            updateSpindlePlots(app.UIAxes_2,tstart_Spin, tend_Spin,simdata.max_amp,fs);
            updateSpindlePlots(app.UIAxes_3,tstart_Spin, tend_Spin,simdata.max_amp,fs);
            

        end

       
        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            
            global simdata;

            % simdata.spin_tab = findSpindleIntersections(simdata.spin_tab);

            % Prevents the user from saving if spindles do not exist in 4 or more epochs
            temp_spin_table = findSpindleIntersections(simdata.spin_tab);

            if height(temp_spin_table) < 4
                fprintf('Could not save. Please mark spindles in 4 or more epochs. \n'); 
                msgbox('Could not save. Please mark spindles in 4 or more epochs.','Error','error');
                return;
            end

            uniqueEpochs = [temp_spin_table(1,:).EpochNum];
            for i = 2:height(temp_spin_table)
                currentEpoch = uniqueEpochs(size(uniqueEpochs)); 
                if currentEpoch ~= temp_spin_table(i,:).EpochNum
                    uniqueEpochs(size(uniqueEpochs)+1) = temp_spin_table(i,:).EpochNum;
                end
            end

            if size(uniqueEpochs) < 4
                fprintf('Could not save. Please mark spindles in 4 or more epochs. \n'); 
                msgbox('Could not save. Please mark spindles in 4 or more epochs.','Error','error');
                return;
            end

            simdata.spin_tab = temp_spin_table;
            
            app.UITable2.ColumnFormat={[],'char','char','logical'};
            app.UITable2.Data = filt_table_editable(simdata.spin_tab, simdata.frame_num,simdata.ep_N2(simdata.frame_num));
            
            fpath = "";
            
            %Prompts user with where to save to 
            mydir  = pwd;
            idcs   = strfind(mydir,'\');
            newdir = mydir(1:idcs(end)-1);

           
            if simdata.mode == "manual"   
                        
                %fpath = uigetdir(newdir,"Select which folder to save manually scored data to");
                fpath = strcat(newdir, "\Spindle Logs - Manual Scored");
                fpath_full = strcat(fpath,'\', simdata.fname,'_', strcat(simdata.rater_name),'_spindles_manual','.csv');            
                       
            elseif simdata.mode == "verification"
                    
                %fpath = uigetdir(newdir,"Select which folder to save manually scored data to");
                fpath = strcat(newdir, "\Spindle Logs - Verified");
                fpath_full = strcat(fpath,'\', simdata.fname,'_', strcat(simdata.rater_name),'_spindles_verified','.csv'); 
                    
            end

            [outfilepath,outfilename,outfileext] = fileparts(fpath_full);

            msgbox(sprintf('Saving %s to %s \n', outfilename, fpath));

            save_and_exit(simdata.spin_tab,outfilepath,outfilename,outfileext);
            
            
            %delete(app);
        end    
       


    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            format short; 
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 794 634];
            app.UIFigure.Name = 'UI Figure';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Fpz-F8')
            ylabel(app.UIAxes, 'Amplitude (uV)')
            app.UIAxes.PlotBoxAspectRatio = [8.78494623655914 1 1];
            app.UIAxes.XColor = [0.15 0.15 0.15];
            app.UIAxes.YColor = [0.15 0.15 0.15];
            app.UIAxes.ZColor = [0.15 0.15 0.15];
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.FontSize = 9;
            app.UIAxes.GridColor = [0.15 0.15 0.15];
            app.UIAxes.MinorGridColor = [0.1 0.1 0.1];
            app.UIAxes.GridAlpha = 0.15;
            app.UIAxes.MinorGridAlpha = 0.25;
%             app.UIAxes.HandleVisibility = 'off';
            app.UIAxes.Box = 'on';
            app.UIAxes.Position = [1 462 794 129];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, 'Fpz-F7')
            ylabel(app.UIAxes_2, 'Amplitude (uV)')
            app.UIAxes_2.PlotBoxAspectRatio = [8.78494623655914 1 1];
            app.UIAxes_2.XColor = [0.15 0.15 0.15];
            app.UIAxes_2.YColor = [0.15 0.15 0.15];
            app.UIAxes_2.ZColor = [0.15 0.15 0.15];
            app.UIAxes_2.XGrid = 'on';
            app.UIAxes_2.YGrid = 'on';
            app.UIAxes_2.FontSize = 9;
            app.UIAxes_2.GridColor = [0.15 0.15 0.15];
            app.UIAxes_2.MinorGridColor = [0.1 0.1 0.1];
            app.UIAxes_2.GridAlpha = 0.15;
            app.UIAxes_2.MinorGridAlpha = 0.25;
%             app.UIAxes_2.HandleVisibility = 'off';
            app.UIAxes_2.Box = 'on';
            app.UIAxes_2.Position = [1 331 794 129];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.UIFigure);
            title(app.UIAxes_3, 'F8-F7')
            ylabel(app.UIAxes_3, 'Amplitude (uV)')
            app.UIAxes_3.PlotBoxAspectRatio = [8.78494623655914 1 1];
            app.UIAxes_3.XColor = [0.15 0.15 0.15];
            app.UIAxes_3.YColor = [0.15 0.15 0.15];
            app.UIAxes_3.ZColor = [0.15 0.15 0.15];
            app.UIAxes_3.XGrid = 'on';
            app.UIAxes_3.YGrid = 'on';
            app.UIAxes_3.FontSize = 9;
            app.UIAxes_3.GridColor = [0.15 0.15 0.15];
            app.UIAxes_3.MinorGridColor = [0.1 0.1 0.1];
            app.UIAxes_3.GridAlpha = 0.15;
            app.UIAxes_3.MinorGridAlpha = 0.25;
%           app.UIAxes_3.HandleVisibility = 'off';
            app.UIAxes_3.Box = 'on';
            app.UIAxes_3.Position = [1 199 794 129];

            % Create BackButton
            app.BackButton = uibutton(app.UIFigure, 'state');
            app.BackButton.ValueChangedFcn = createCallbackFcn(app, @BackButtonValueChanged, true);
            app.BackButton.Text = 'Back';
            app.BackButton.FontWeight = 'bold';
            app.BackButton.Position = [123 12 100 22];

            % Create NextButton
            app.NextButton = uibutton(app.UIFigure, 'state');
            app.NextButton.ValueChangedFcn = createCallbackFcn(app, @NextButtonValueChanged, true);
            app.NextButton.Text = 'Next';
            app.NextButton.FontWeight = 'bold';
            app.NextButton.Position = [551 12 100 22];

            % Create SelectEEGFileButton
            app.SelectEEGFileButton = uibutton(app.UIFigure, 'state');
            app.SelectEEGFileButton.ValueChangedFcn = createCallbackFcn(app, @SelectEEGFileButtonValueChanged, true);
            app.SelectEEGFileButton.Text = 'Select EEG File';
            app.SelectEEGFileButton.FontWeight = 'bold';
            app.SelectEEGFileButton.Position = [57 589 104 22];

            % Create UITable2
            app.UITable2 = uitable(app.UIFigure);
            app.UITable2.ColumnName = {'epoch';'start'; 'duration'; 'yes/no'};
            app.UITable2.RowName = {};
            app.UITable2.ColumnEditable = [true true true true];
            app.UITable2.CellEditCallback = createCallbackFcn(app, @UITable2CellEdit, true);
            app.UITable2.Position = [210 47 453 125];

            % Create SleepSpindlesLabel_3
            app.SleepSpindlesLabel_3 = uilabel(app.UIFigure);
            app.SleepSpindlesLabel_3.VerticalAlignment = 'top';
            app.SleepSpindlesLabel_3.FontWeight = 'bold';
            app.SleepSpindlesLabel_3.Position = [364 185 89 15];
            app.SleepSpindlesLabel_3.Text = 'Sleep Spindles';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.FontWeight = 'bold';
            app.SaveButton.Position = [350 12 100 22];
            app.SaveButton.Text = 'Save';

            % Create SelectDatasetDropDownLabel
            app.SelectDatasetDropDownLabel = uilabel(app.UIFigure);
            app.SelectDatasetDropDownLabel.HorizontalAlignment = 'right';
            app.SelectDatasetDropDownLabel.VerticalAlignment = 'top';
            app.SelectDatasetDropDownLabel.FontWeight = 'bold';
            app.SelectDatasetDropDownLabel.Position = [245 618 89 15];
            app.SelectDatasetDropDownLabel.Text = 'Select Dataset';

            % Create SelectDatasetDropDown
            app.SelectDatasetDropDown = uidropdown(app.UIFigure);
            app.SelectDatasetDropDown.Position = [210 590 166 22];

            % Create LoadDataButton
            app.LoadDataButton = uibutton(app.UIFigure, 'push');
            app.LoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @LoadDataButtonPushed, true);
            app.LoadDataButton.FontWeight = 'bold';
            app.LoadDataButton.Position = [422 589 100 22];
            app.LoadDataButton.Text = 'Load Data';

            % Create ScaleuvEditField_2Label
            app.ScaleuvEditField_2Label = uilabel(app.UIFigure);
            app.ScaleuvEditField_2Label.HorizontalAlignment = 'right';
            app.ScaleuvEditField_2Label.Position = [716 612 60 22];
            app.ScaleuvEditField_2Label.Text = 'Scale (uv)';

            % Create ScaleuvEditField_2
            app.ScaleuvEditField_2 = uieditfield(app.UIFigure, 'numeric');
            app.ScaleuvEditField_2.Position = [728 590 44 22];
            app.ScaleuvEditField_2.Value = 75;

            % Create BandpassFilterHzEditField_2Label
            app.BandpassFilterHzEditField_2Label = uilabel(app.UIFigure);
            app.BandpassFilterHzEditField_2Label.HorizontalAlignment = 'right';
            app.BandpassFilterHzEditField_2Label.Position = [551 610 115 22];
            app.BandpassFilterHzEditField_2Label.Text = 'Bandpass Filter (Hz)';

            % Create BandpassFilterHzEditField_2
            app.BandpassFilterHzEditField_2 = uieditfield(app.UIFigure, 'numeric');
            app.BandpassFilterHzEditField_2.Position = [563 587 33 22];
            app.BandpassFilterHzEditField_2.Value = 1;

            % Create toEditFieldLabel
            app.toEditFieldLabel = uilabel(app.UIFigure);
            app.toEditFieldLabel.HorizontalAlignment = 'right';
            app.toEditFieldLabel.Position = [589 589 25 22];
            app.toEditFieldLabel.Text = 'to';

            % Create toEditField
            app.toEditField = uieditfield(app.UIFigure, 'numeric');
            app.toEditField.Position = [621 588 32 22];
            app.toEditField.Value = 50;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = App_Dreem_mfile

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end