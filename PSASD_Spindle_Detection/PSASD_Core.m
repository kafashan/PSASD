function [output] = PSASD_Core(EEG,params,lambda)
    
    %% PSASD Parameter Initialization
    psasd.eeg_fs_original   = params.input_EEG_samplingrate;
    psasd.epoch_duration    = 30; % length of epoch in second
    psasd.e_samples         = 30* psasd.eeg_fs_original;
    psasd.nepochs           = ceil(length(EEG)/ psasd.e_samples);
    psasd.nchannels         = size(EEG,1);
    psasd.T_overlap         = 1; % in seconds
    psasd.T_overlap_multich = 0.2;  % overlap time between spindle from different channel not to include the same spindle multiple time
    psasd.artifact_thr      = 100; % artifact threshold to exclude those detected spindles
  
    %% DETOKS parameters
    detoks_fs       = 200;   %   DETOKS works with fs=200 so need resampling if different 
    lam0            = lambda.lam0;
    lam1            = lambda.lam1;
    lam2            = lambda.lam2;
    deg             = params.deg;
    nit             = params.nit;
    mu              = params.mu;
    th              = params.th;
    
    % Cut-off frequency for low-pass filter 
    HZ              = 1;     
    lowpass_fc      = HZ/(detoks_fs/2);
    
    % Resampling Parameters
    [Pfilt,Qfilt]     = rat(detoks_fs/psasd.eeg_fs_original);
    resampled_npoints = detoks_fs * psasd.epoch_duration * psasd.nepochs; 
    
    
    output.x         = zeros(psasd.nchannels,resampled_npoints);
    output.f         = zeros(psasd.nchannels,resampled_npoints);
    output.s         = zeros(psasd.nchannels,resampled_npoints);
    output.tk        = zeros(psasd.nchannels,resampled_npoints);
    output.sc_detection = zeros(psasd.nchannels,resampled_npoints);
    output.mc_detection = zeros(1,resampled_npoints);


    %% Apply PSASD algorithm
    
    for currentEpoch = 1:psasd.nepochs

        %disp(currentEpoch);

        %Start and stop data point numbers of each epoch 
        x_start = (currentEpoch-1) * (30 * psasd.eeg_fs_original) + 1;
        x_end   =  currentEpoch    * (30 * psasd.eeg_fs_original);
    
        %Start and stop times of each epoch 
        t_start_sec = (currentEpoch-1)* 30;
        t_end_sec = currentEpoch* 30;
       
      
        %Subset the data for DETOKS
        y_raw    = EEG(:, x_start: x_end);
        y_in     = resample(y_raw', Pfilt, Qfilt)';
        y_length = size(y_in,2);

        y_start_prime = (currentEpoch-1) * (30 * detoks_fs) + 1;
        y_end_prime   =  currentEpoch    * (30 * detoks_fs);

        %DETOKS Variable Initializations
        x_detoks = zeros(y_length,psasd.nchannels);
        s_detoks = zeros(y_length,psasd.nchannels);
        f_detoks = zeros(y_length,psasd.nchannels);
        tk_detoks = zeros(y_length,psasd.nchannels);
        output_detoks = zeros(y_length,psasd.nchannels);
    
       
        %Detoks output for each channel
        for ch = 1: psasd.nchannels
            
            [x_detoks(:, ch),s_detoks(:, ch),f_detoks(:, ch),~] =  DETOKS(y_in(ch, :),detoks_fs,deg,lowpass_fc,lam0,lam1,lam2,nit,mu);
            tk_detoks(:, ch) = teager_operator(s_detoks(:, ch));
    
            [~,~,output_detoks(:, ch)] = detect_roi( tk_detoks(:, ch), detoks_fs, th, 'spindle', 'detoks');
        
        end  
                               
        [output_psasd, ~, ~, ~] = spindle_start_extract_multich(output_detoks, y_in, detoks_fs, psasd.artifact_thr, psasd.T_overlap_multich);
       
        output.x(:,y_start_prime:y_end_prime)               =   x_detoks';
        output.f(:,y_start_prime:y_end_prime)               =   s_detoks';
        output.s(:,y_start_prime:y_end_prime)               =   f_detoks';
        output.tk(:,y_start_prime:y_end_prime)              =   tk_detoks';
        output.sc_detection(:,y_start_prime:y_end_prime)    =   output_detoks';
        output.mc_detection(:,y_start_prime:y_end_prime)    =   output_psasd;


    end


end



function [out_psasd, t_s, t_e, ch_indx] = spindle_start_extract_multich(sc_detected_spindles, y, fs, artifact_thr, T_overlap_multich)
    
    nCh         = size(y, 1);
    out_psasd   = [];
    t_s         = [];
    t_e         = [];
    ch_indx     = [];

    for ch = 1: nCh

        %Get the start and end times of each spindle in this channel
        [chan_spind_s, chan_spind_e] = spindle_bin_vec_time_extract(sc_detected_spindles(:, ch), fs);

        for ii = 1:length(chan_spind_s)

            %Only consider those spindles under the artifact threshold

            if max(abs(y(ch, floor(chan_spind_s(ii)* fs) + 1: floor(chan_spind_e(ii)* fs)))) < artifact_thr

                %Union of spindles across all channels. Intersection is defined as a spindle with a ...
                %... start time under the "T_overlap_multich" overlap threshold time

                if isempty(t_s) || (min(abs(t_s - chan_spind_s(ii))) > T_overlap_multich)
                    t_s = [t_s;  chan_spind_s(ii)];
                    t_e = [t_e;  chan_spind_e(ii)];   
                    ch_indx = [ch_indx; ch];
                end

            end
        end
    end

    numpointsinepoch = fs * 30;
    out_psasd = zeros(1,numpointsinepoch);

    for i = 1:length(t_s)

        startpoint = int32(t_s(i) * fs)+1;
        endpoint   = int32(t_e(i) * fs); 

        out_psasd(startpoint:endpoint) = 1;
    end

    out_psasd=out_psasd(1:numpointsinepoch);
    
end

%Given a spindle binary vector, get the start and end times of each spindle
function [start_indx, end_indx] = spindle_bin_vec_time_extract(binVec, fs)
        
    binVec = binVec(:);
    bin_diff = diff(binVec);

    start_indx = [];
    if binVec(1) == 1
        start_indx = [start_indx; 0];
    end
    start_indx = [start_indx; (find(bin_diff == 1))/fs]; 
    
    end_indx = [];
    end_indx = [end_indx; (find(bin_diff == -1))/fs]; 
    if binVec(end) == 1
        end_indx = [end_indx; length(binVec)/fs];
    end

end






