function [data_out, spindles_out] =  data_epoch_selection(data_in,header, spindles_in,selected_epochs)

    fs = header.samplingrate;
    numPointsInEpoch = header.epoch_sec * fs;

    nEpochs = ceil(size(data_in,2)/ numPointsInEpoch);

    data_out = [];
    spindles_out = [];

    startPoints = (linspace(1,nEpochs,nEpochs)-1) .* numPointsInEpoch + 1;
        

    for iter = 1:length(selected_epochs)

        epoch_selected = selected_epochs(iter);
        xStart = startPoints(epoch_selected);

        if epoch_selected == nEpochs

            data_out=horzcat(data_out, data_in(:,xStart:end));

        else

            xEnd = xStart + numPointsInEpoch - 1; 
            data_out=horzcat(data_out, data_in(:,xStart:xEnd));
            
        end

        spindles_out = [spindles_out; spindles_in(spindles_in.epoch == epoch_selected,:)];

    end


    temp_spindles = spindles_out;
    
    for iter = 1:length(selected_epochs)
       
        if (selected_epochs(iter)~=1)

            currentEpoch = selected_epochs(iter);

            delta_epochs = currentEpoch-iter;

            spindles_out.tstart(spindles_out.epoch==currentEpoch)=spindles_out.tstart(spindles_out.epoch==currentEpoch) - delta_epochs * header.epoch_sec;
            spindles_out.epoch(spindles_out.epoch==currentEpoch)=spindles_out.epoch(spindles_out.epoch==currentEpoch)-delta_epochs;


        end


    end


end