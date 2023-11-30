function [P, TP, FP, FN, t_TP, t_FN, t_FP, t_TN, Sensitivity, Specificity, F1] = PSASD_event_comparison(start_exp, end_exp, start_input_spind, end_input_spind, T_epsilon,recording_length_secs)
    
    start_input = start_input_spind;
    end_input   = end_input_spind;

    P = length(start_exp); 
    TP_vector = zeros(length(start_exp),1);
    FP_vector = ones(length(start_input_spind),1);

    FN = 0;    
    t_TP = 0;
    t_FN = 0;
    t_FP = 0;
    t_TN = recording_length_secs; 
    
    %For each detected spindle
    for i = 1 : length(start_input)
        
        %Compare it to all the expert identified spindles and find the closest

            [delta_s, minIndx_s] = min(abs(start_exp - start_input(i)));
            [delta_e, minIndx_e] = min(abs(end_exp - end_input(i)));
      

            if ~isempty(delta_s) %If we have expert detected spindles in this epoch...
            
                %TP = Input spindles with start or end times within T_epsilon secs of those of the expert spindles
                if (delta_s < delta_e && delta_s < T_epsilon) || (delta_s >= delta_e && delta_e < T_epsilon)
                    TP_vector(minIndx_s)=1; 
                    FP_vector(i)=0;
                    t_TP = t_TP + (end_input(i) - start_input(i)); 

                end
                                             
            end

    end

    for k = 1 : length (TP_vector)
        if TP_vector(k)==0
            t_FN = t_FN + end_exp(k) - start_exp(k);
        end
    end

    for k = 1 : length(FP_vector)
        if FP_vector(k)==1
            t_FP = t_FP + end_input(k) - start_input(k);
        end
    end

    t_TN = t_TN - t_FP;
   
    TP = sum(TP_vector);
    FP = sum(FP_vector);
    FN = length(start_exp)-TP;

    Sensitivity = TP/(TP+FN);
    Specificity = t_TN/(t_TN + t_FP);

    Precision = TP/(TP+FP);
    Recall = TP/(TP+FN);
    F1 = (2*Precision*Recall)/(Precision+Recall);
    
   
end