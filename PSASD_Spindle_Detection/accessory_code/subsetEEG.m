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