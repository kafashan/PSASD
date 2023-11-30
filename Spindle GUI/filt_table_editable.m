function [ cell_data ] = filt_table_editable( MasterT, framenum,epochnum )

%Inputs: Spindle table, frame (epoch) number
%Outputs: Spindles in epoch

format short;
% 
% f = table2array(MasterT(:,1));
% indx = find(f == framenum);

SelectedFramesT = [MasterT(MasterT.FrameNum == framenum, "EpochNum") MasterT(MasterT.FrameNum == framenum, 2:4)];

DisplayT = [];
DisplayTLengthPad = 4;

%If there are spindles within this frame...
if ~isempty(SelectedFramesT)

    DisplayT = SelectedFramesT;

    FrameNum = ones(DisplayTLengthPad,1)*framenum;
    Select = false(DisplayTLengthPad,1);
    EpochNum = ones(DisplayTLengthPad,1)*epochnum;
    SpindleStart = zeros(DisplayTLengthPad,1);
    Duration = zeros(DisplayTLengthPad,1);
    
    % TempT = table(FrameNum,SpindleStart,Duration,Select,EpochNum);
    % Paul Kang - 10/20/23 - Removed FrameNum, rearranged table order
    TempT = table(EpochNum,SpindleStart,Duration,Select);
   
    outputT = [DisplayT;TempT];
    outputT.SpindleStart(1:end)=arrayfun(@(x) sprintf("%4.2f",x),outputT.SpindleStart(1:end));
    outputT.Duration(1:end)=arrayfun(@(x) sprintf("%4.2f",x),outputT.Duration(1:end));

    cell_data = table2cell(outputT);


%If there are no spindles within this frame...
else

    FrameNum = ones(DisplayTLengthPad,1)*framenum;
    Select = false(DisplayTLengthPad,1);
    EpochNum = ones(DisplayTLengthPad,1)*epochnum;
    SpindleStart = zeros(DisplayTLengthPad,1);
    Duration = zeros(DisplayTLengthPad,1);

    % Paul Kang - 10/20/23 - Same here
    DisplayT = table(EpochNum, SpindleStart,Duration,Select);
    %DisplayT.FrameNum(1:DisplayTLengthPad,1) = framenum;
    %DisplayT.Select = false(size(DisplayT,1),1);
    %DisplayT.EpochNum(1:DisplayTLengthPad,1) = epochnum;

    DisplayT.SpindleStart(1:end)=arrayfun(@(x) sprintf("%4.2f",x),DisplayT.SpindleStart(1:end));
    DisplayT.Duration(1:end)=arrayfun(@(x) sprintf("%4.2f",x),DisplayT.Duration(1:end));

    cell_data = table2cell(DisplayT);
    %cell_data = {};


end



% warning('off','all');
% if ~isempty(indx)
%     % Select only frames with the index specified by framenum
%     DisplayT = MasterT(indx,:);
%     % new_T.Var4 = true(size(new_T,1),1);
%     % Add additional rows
%     DisplayT.Var1(end+1:end+DisplayTLengthPad,1) = framenum;
%     DisplayT.Var4(end-DisplayTLengthPad+1:end,1) = false(DisplayTLengthPad,1);
%     
%     DisplayT.Var2(1:end)=arrayfun(@(x) sprintf("%4.1f",x),DisplayT.Var2(1:end));
%     DisplayT.Var3(1:end)=arrayfun(@(x) sprintf("%4.1f",x),DisplayT.Var3(1:end));
% 
%     % Return cell
%     cell_data = table2cell(DisplayT);
% else
%     DisplayT = table([],[],[],[],[]);
%     DisplayT.Var1(1:DisplayTLengthPad,1) = framenum;
%     DisplayT.Var4 = false(size(DisplayT,1),1);
%     cell_data = table2cell(DisplayT);
%     % cell_data = {};
% end

end

