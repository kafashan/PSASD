function [ T ] = add_new_row( T, fnum )

if isempty(T)
    T = {fnum, 0, 0, 0, 0};
else    
    ind = find(T.FrameNum(:,1) <= fnum);
    if ~isempty(ind)
        old_T = T(1:ind(end),:);
        new_T = {fnum, 0, 0, 0, 0};
        rem_T = T(ind(end)+1:end,:);
        T = [old_T; new_T; rem_T];
    else
        new_T = {fnum, 0, 0, 0,0};
        T = [new_T; T];
    end
end

end