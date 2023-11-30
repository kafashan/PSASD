function [spinTableOutput] = findSpindleIntersections(spinTable)
    %Input: SpindleTable with columns: frame | tstart | duration | y_n | epoch    

%     %Sort by epoch number (Col 5)
%     spinTable = sortrows(spinTable,5);
%     
%     %Create a column vector of the tend of each spindle
%     tend_spindle = table2array(spinTable(:,2)) + table2array(spinTable (:,3));
%     
%     %Reshape enforces that tend_spindle is indeed a column vector
%     tend_spindle = reshape(tend_spindle,[length(tend_spindle),1]);
% 
%     %Create a temporary table with columns: tstart | tend for spindles
%     tempTable = [spinTable,array2table(tend_spindle)];
%     
%     %Create a placeholder for the output table 
%     outputTable = table('Size',[1 5],'VariableTypes',{'double','double','double','double', 'double'},'VariableNames',spinTable.Properties.VariableNames);
% 
%     %The way this works is that we're going to go through our temporary
%     %table of spindle start and end times. We're going to start with the
%     %first row in it and check it against every other row below it to check
%     %for overlaps...

    spinTable(spinTable.SpindleStart==0,:)=[];

          
    if height(spinTable)<=1

        spinTableOutput = spinTable;

    else
        spinTable = sortrows(spinTable,"SpindleStart");

        output_table=table();
        output_table=cell2table(cell(0,5),'VariableNames',spinTable.Properties.VariableNames);

        % Paul Kang 12/6: Avoids concatenating spindles that are marked N
        i = 1;
        while i<=height(spinTable) 
            if ~spinTable(i,:).Select 
                spinTable(i,:) = [];
            else
                i = i + 1;
            end
        end
        % End - PK

        i = 1;
        while i<=height(spinTable)            

            Fulcrum_Row = spinTable(i,:);
            Fulcrum_End_Time = Fulcrum_Row.SpindleStart + Fulcrum_Row.Duration;

            if (i+1)<=height(spinTable) 

                for j = (i+1):height(spinTable) 
       
                    next_row = spinTable(j,:);
                    flag_a = next_row.SpindleStart > Fulcrum_Row.SpindleStart; 
                    flag_b = next_row.SpindleStart < (Fulcrum_Row.SpindleStart + Fulcrum_Row.Duration); 
            
                    overlap_next = flag_a & flag_b; 

                    if overlap_next == 1
        
                        Next_End_Time = next_row.SpindleStart + next_row.Duration;
        
                        if Next_End_Time > Fulcrum_End_Time
        
                            New_Fulcrum_Duration = Next_End_Time - Fulcrum_Row.SpindleStart;
                            Fulcrum_Row.Duration = New_Fulcrum_Duration;
        
                        end

                        i = j + 1;
    
                    else
    
                        i = j;
                        break;
                            
                    end
                end

                output_table = [output_table;Fulcrum_Row];

            else

                output_table = [output_table;Fulcrum_Row];
                break;
                
            end

            

        end
    
         
        spinTableOutput = output_table;
        
    end
   


end
    
      

%% TODO
%     spinTable.SpindleEnd = spinTable.SpindleStart+ spinTable.Duration;
%     spinTable_sorted = sortrows(spinTable, "SpindleStart");
%     
%     ii = 1;
%     while ii < size(spinTable, 1)
%         flag_start = spinTable_sorted.SpindleStart(ii) < spinTable_sorted.SpindleEnd;
%         flag_end = spinTable_sorted.SpindleEnd(ii) > spinTable_sorted.SpindleStart;
%         flag_overlap = flag_start & flag_end; 
%         ii = ii+ 1+ sum(flag_overlap)
%     end

