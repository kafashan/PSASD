function [s,d] = plotSpindlePoints(app,mousePosition,axesObject,simdata)
        
    global simdata;
    lineObject = [];

    if(simdata.canClickToRegisterSpindle==1)
    
        %If the object clicked is the axes, then extract the line object from it
        if (class(axesObject)=="matlab.ui.control.UIAxes")
            lineObject = axesObject.Children(end);

        %If the object clicked and registered is the line object, then use that instead
        else
            lineObject = axesObject;

        end

        %Get the x,y coordinates of the trace that is closest to the point that was clicked
        [x_closest,y_closest]=closestPoint(mousePosition,lineObject,simdata);

        %If we sucessfully found the closest x,y points... 
        if (x_closest ~= -1 && y_closest ~= -1)
            
            %If we're just starting and no points have been clicked
            if simdata.startPointClicked == false && simdata.endPointClicked == false

                %Register that the starting point has been clicked and save the x,y of it to the global variable simdata
                simdata.startPointClicked = true;
                simdata.XY_PointClicked=[x_closest,y_closest];

                %plotStartingPoint(app.Parent.Children(18))
                %plotStartingPoint(app.Parent.Children(17))
                %plotStartingPoint(app.Parent.Children(16))
                            
            %If a starting point was already clicked... 
            elseif simdata.startPointClicked == true && simdata.endPointClicked == false
                
                %simdata.endPointClicked = true;
                %simdata.XY_PointClicked=[x_closest,y_closest];

                %If the end point is at a later timepoint than the starting point...

                xStart = 0; xEnd = 0;

                if (x_closest > simdata.XY_PointClicked(1))
                    
                    xStart = simdata.XY_PointClicked(1); xEnd = x_closest;

                elseif (x_closest < simdata.XY_PointClicked(1))

                    xStart = x_closest; xEnd = simdata.XY_PointClicked(1);
                end
               

                %Lets append that to our table of spindles for this frame

                frameNum = simdata.frame_num;
                spindle_duration = xEnd-xStart;
                epochNum = simdata.ep_N2(frameNum);

                %Create a temporary table with the info of the spindle registered by clicking
                temp = {frameNum,xStart,spindle_duration,1,epochNum};

                %Append it to the table of spindles
                simdata.spin_tab = [simdata.spin_tab;temp];

                %Now lets plot out all of our spindles for this frame including the one we just registered...
                [tstart_Spin, tend_Spin] = extract_splindle_info(simdata.spin_tab, frameNum);

                % Update Fpz-F8 plot            
                updateSpindlePlots(app.Parent.Children(18), tstart_Spin, tend_Spin, simdata.max_amp, simdata.fs);
        
                % Update Fpz-F7 plot
                updateSpindlePlots(app.Parent.Children(17), tstart_Spin, tend_Spin, simdata.max_amp, simdata.fs);
                
                % Update F8-F7 plot
                updateSpindlePlots(app.Parent.Children(16), tstart_Spin, tend_Spin, simdata.max_amp, simdata.fs);  

                %Update displayed table
                app.Parent.Children(12).ColumnFormat={[],'char','char','logical',[]};
                app.Parent.Children(12).Data = filt_table_editable(simdata.spin_tab, simdata.frame_num, simdata.ep_N2(simdata.frame_num));

                %Reset these variables
                simdata.startPointClicked = false; simdata.endPointClicked = false;

            end





        end

    end

end



% 
%                 elseif (x_closest > simdata.spinClickStartPoint(1))
%                     
%                     simdata.spinClickEndPoint=[x_closest,y_closest];
% 
%                     T= simdata.spin_tab;
%                     frameNum = simdata.frame_num;
%                     epochNum = simdata.ep_N2(frameNum);
% 
%                     xStart = simdata.spinClickStartPoint(1);
%                     xEnd = x_closest;
% 
%                     simdata.spinClickStartPoint=[];
% 
%                     temp = {frameNum,xStart,xEnd-xStart,1,epochNum};
% 
%                     simdata.spin_tab = [T;temp];
% 
%                     [tstart_Spin, tend_Spin] = extract_splindle_info(simdata.spin_tab, frameNum);
%         
%                     epoch_spindles = [tstart_Spin, tend_Spin];
% 
%                     epoch = simdata.epoch; 
% 
%                     iframe = simdata.frame_num; 
%                     tstart  = (simdata.ep_N2(iframe) - 1) * epoch;
%                     tend    = simdata.ep_N2(iframe) * epoch; 
%                     N = simdata.fs*epoch;
%                     t = linspace(tstart, tend, N);
%                     fs = simdata.fs;
%                     
%                     % Fpz-F8            
%                     y = simdata.data(simdata.iChan(1), tstart* fs+ 1: tend* fs);
%                     channel_data = [t;y];
%                     updateSpindlePlots(app.Parent.Children(18),tstart_Spin, tend_Spin,simdata.max_amp,fs);
%             
%                     % Fpz-F7
%                     y = simdata.data(simdata.iChan(2), tstart* fs+ 1: tend* fs);
%                     channel_data = [t;y];
%                     updateSpindlePlots(app.Parent.Children(17),tstart_Spin, tend_Spin,simdata.max_amp,fs);
%                     
%                     % F8-F7
%                     y = simdata.data(simdata.iChan(3), tstart* fs+ 1: tend* fs);
%                     channel_data = [t;y];
%                     updateSpindlePlots(app.Parent.Children(16),tstart_Spin, tend_Spin,simdata.max_amp,fs);          
%            
%                     
%                     app.Parent.Children(12).ColumnFormat={[],'char','char','logical'};
%                     app.Parent.Children(12).Data = filt_table_editable(simdata.spin_tab, simdata.frame_num);
%                    
% 
%                 end

%             end

            %simdata.canClickToRegisterSpindle=0;
% 
%         end
% 
%     end

function [x,y] = closestPoint(mousePosition,axesObject,simdata)
    
    x = -1; y = -1;

    xp = mousePosition(1); yp = mousePosition(2);
    
    xd = axesObject.XData-xp;
    yd = axesObject.YData-yp;

    d = (xd.^2+yd.^2).^(1/2);
    [min_d,i_d]=min(d);
    
    

    %fprintf("Closest value is %d,%d\n",x,y);
    %disp(min_d);
    
    if min_d <= 2
        x = axesObject.XData(i_d);
        y=axesObject.YData(i_d);
        
        
    end



end