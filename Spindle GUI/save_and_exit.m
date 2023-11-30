function save_and_exit( T, fpath, fname,fext)

%Inputs: 
% T - Table of Spindle values
% fpath - file path
% fname - file name 
% epochs - which epocs to save out to

%Remove blank values from output table
ind = find(T.Select(:,1) == 0);
if ~isempty(ind)
    T(ind,:) = [];
end

T = sortrows(T,2);
T.Properties.VariableNames = {'frame' 'tstart' 'duration' 'y_n' 'epoch'};

fullpath = strcat(fpath,filesep,fname,fext);


if exist(fullpath)
    delete(fullpath);
end

try
    writetable(T, fullpath);
catch
    fprintf('Please confirm that the file is saved in the appropriate folder ... \n');
end

% Paul Kang 12/9: Removed saving .mat file
% try
%     save(strcat(fpath,fname,'.mat'), 'T');
% catch
%     fprintf('Process completed ... \n');
% end
% End - PK

end
