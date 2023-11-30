function [start_indx, end_indx] = spindle_bin_vec_time_extract(binVec, fs)
            
        binVec = binVec(:);
        bin_diff = diff(binVec);
    
        start_indx = [];
        if binVec(1) == 1
            start_indx = 0;
        end
        start_indx = [start_indx; (find(bin_diff == 1))/fs]; 
        
        end_indx = [];
        end_indx = [end_indx; (find(bin_diff == -1))/fs]; 
        if binVec(end) == 1
            end_indx = [end_indx; length(binVec)/fs];
        end
    
end