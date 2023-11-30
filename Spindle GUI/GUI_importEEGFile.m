function [data,header] = GUI_importEEGFile(filepath) 

    [~,~,ext]=fileparts(filepath);

    if (ext==".edf")

        [data, header] = lab_read_edf(filepath);

    elseif (ext==".h5")
    
        info = h5info(filepath); 
        
        record_info = info.Attributes(10).Value;
        temp_vals = strsplit(record_info,{'{','},'},'CollapseDelimiters',true);
    
        channelList=["Fpz-F8","Fpz-F7","F8-F7"];

        for i = 1:3

            chan = channelList(i);

            channel_attribute_indices = intersect(find(cellfun(@(s) contains(s,chan),temp_vals)),find(cellfun(@(s) contains(s,"filtered"),temp_vals)));
            temp_chn_data = strsplit(temp_vals{channel_attribute_indices},", ");
        
            samp_freq_idx=find(cellfun(@(s) contains(s,"fs"),temp_chn_data));
            samp_freq_cellarr = strsplit(temp_chn_data{samp_freq_idx}," ");
            fs = str2double(samp_freq_cellarr{2});
            
            h5_group_idx=find(cellfun(@(s) contains(s,"path"),temp_chn_data));
            h5_group_cellarr = strsplit(temp_chn_data{h5_group_idx}," ");
            h5_group = strcat("/",h5_group_cellarr{2}(2:end-1));
            
            data(i,:) = h5read(filepath,h5_group);
        end
        
        data=double(data);

        header.samplingrate=fs;

    end

end