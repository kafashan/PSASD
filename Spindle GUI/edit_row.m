function [ T ] = edit_row( T, loc, fnum, ndata )
%Spindle table

%If the table doesn't exist...
if isempty(T)
    ell = 4;
    new_T = table([],[],[],[],[]);
    new_T.FrameNum(1:ell,1) = fnum;
    new_T.Select = false(size(new_T,1),1);
    T = new_T;
end

frame_rows = find(T.FrameNum(:,1) == fnum);
row_idx = [];
if ~isempty(frame_rows)
%     loc(1) = min(ind) + loc(1) - 1;
%     loc(2) = loc(2);
      row_idx = frame_rows(loc(1));

% 
% else
%     frame_rows = find(T.FrameNum(:,1) < fnum);
%     if ~isempty(frame_rows)
%         loc(1) = max(frame_rows) + loc(1) + 1;
%         loc(2) = loc(2);
%     else
%         loc(1) = loc(1);
%         loc(2) = loc(2);
%     end
% end

T.FrameNum(row_idx) = fnum;
T(row_idx,loc(2)) = {ndata};

end