function [output_path] =  adjustForCluster(input_path)

    windows_path_header = '\\storage1.ris.wustl.edu\';
    unix_path_header    = '/storage1/fs1/';
 
    if(isunix==1)

        output = strrep(input_path,windows_path_header,unix_path_header);
        output_path = strrep(output,'\','/');  

    else 

        output_path = input_path;

    end

end