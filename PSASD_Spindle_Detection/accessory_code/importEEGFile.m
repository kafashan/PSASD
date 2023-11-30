function [data,header] = importEEGFile(filepath,channel_names,varargin) 

    [~,~,ext]=fileparts(filepath);

    if (ext==".edf")

        [data, header] = lab_read_edf(filepath);

        idxs = [];

        EEG_chans = "";

        %Get list of channels from header
        for i=1:size(header.channels,1)

            EEG_chans(i) = strtrim(header.channels(i,:));
        end

        disp(EEG_chans);

        if class(channel_names) == 'char'

            if lower(channel_names)=='default'
                channel_names=["Fpz-F7","Fpz-F8","F8-F7"];
            end

        else

            if lower(channel_names{1})=='default'
                channel_names=["Fpz-F7","Fpz-F8","F8-F7"];
            end

        end

        for i=1:length(channel_names)

            chn = channel_names{i};

            idxs(i) = find(strcmp(EEG_chans,chn));

        end

        fprintf("---------------------------\n");
        fprintf("Available EEG channels are: ");

        for j=1:length(EEG_chans)

            fprintf("%s ",EEG_chans(j));
        end

        
        fprintf("\nSelecting channels: ");
        


        selected_Channels = EEG_chans(idxs);
        for j=1:length(selected_Channels)

            fprintf("%s ",selected_Channels(j));

        end

        fprintf("\n");
        fprintf("Sampling rate of data is: %dHz\n",header.samplingrate);
        fprintf("---------------------------\n");

        data=data(idxs,:);

        
   

    elseif (ext==".h5")

        channelList = [];

        if class(channel_names) == 'char'

            if lower(channel_names)=='default'
                channelList=["Fpz-F7","Fpz-F8","F8-F7"];
            end

        else
        
            if lower(channel_names{1})=='default'
                channelList=["Fpz-F7","Fpz-F8","F8-F7"];
            end
        end
    
        info = h5info(filepath); 
        temp = {};

        for i=1:length(info.Attributes)

            temp{i} = info.Attributes(i).Name;

        end

        value = find(contains(temp,'description'));

        pattrn='{' + wildcardPattern + '}';
        chaninfo = extract(info.Attributes(value).Value,pattrn);

        chanidx = [];
        electrode_name=[];
        output_data=[];

        for i=1:length(channelList)
            
            electrodeIdx = find(contains(chaninfo,channelList(i)));
            rawIdx       = find(contains(chaninfo,'raw'));

            electrode_raw_idx = intersect(electrodeIdx,rawIdx);

            description = chaninfo{electrode_raw_idx};

            electrode_name{i}  = regexp(description,'eeg\d/raw','match');
            

            if isempty(electrode_name{i})

                electrode_name{i}  = regexp(description,'channel\d/raw','match');

            end
                output_data(i,:) = h5read(filepath,['/',electrode_name{i}{1}]);
        
        end

        data = output_data;

        header.samplingrate = 250;

        header.channelList = channelList;

    end

    if (length(varargin) > 0 && min(varargin{1}=='filter'))

        % minimum order zero-phase Bandstop filter [0.1,0.6] Hz to remove respiratory artifacts
        fprintf('Bandstop filtering with cutoffs [0.1 0.6] Hz to remove respiratory artifacts ... \n');
        numChans = size(data,1);
        for i = 1:numChans
        
            data(i,:) = bandstop(data(i,:)', [0.1, 0.6], header.samplingrate, 'ImpulseResponse','iir')'; 
        
        end
                         
    
        fprintf('Bandstop filtering completed! \n');
    
        % minimum order zero-hase Bandpass filter 1 to 50 Hz
        fprintf(sprintf('Bandpass filtering with cutoffs [1 50] Hz initiated ... \n'));
        
        for i = 1:numChans
    
            data(i,:) = bandpass(data(i,:)', [1, 50], header.samplingrate, 'ImpulseResponse','iir')';
    
        end 
    
        fprintf('Bandpass filtering completed! \n');

    end

end