function [tstart_Spin, tend_Spin] = extract_splindle_info(T, iframe)
%Input: 
%   T - Table of spindles in column format
%   iframe - current frame 

%Output:
% - tstart_Spin: 
% - tend_Spin: 


% Function: Extract all spindles from the table of spindles that "Yes" is selected
% for 
T = T(T.Select == 1, :);

%If this table contains values...
if ~isempty(T)    
    %Extract all rows with that frame number
    ind = find(T.FrameNum(:,1) == iframe);
    nSpindle = length(ind);
    
    %Create placeholder vectors for spindle start and end values
    tstart_Spin = nan(nSpindle, 1);
    tend_Spin = nan(nSpindle, 1);
    
    %Go through each spindle and get its start and end times
    for ii = 1: nSpindle
        tstart_Spin(ii) = T.SpindleStart(ind(ii));
        tend_Spin(ii) = T.SpindleStart(ind(ii))+ T.Duration(ind(ii)); 
    end
else
    tstart_Spin = [];
    tend_Spin = [];
end