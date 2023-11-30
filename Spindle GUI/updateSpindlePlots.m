function updateSpindlePlots(Axes, spindles_tstart, spindles_tend, max_amp, fs, channel_data)

    epoch_spindles=[spindles_tstart,spindles_tend];
    t_vals=[];
    y_vals=[];

    if nargin ==6 

    %Plot raw trace
        t_vals = channel_data(1,:);
        y_vals = channel_data(2,:);

    elseif nargin == 5

        t_vals = Axes.Children(end).XData;
        y_vals = Axes.Children(end).YData;

    end
    
    hold(Axes,'off');
    plot(Axes, t_vals, y_vals, 'k'); hold(Axes, 'on'); 
    lineObject = Axes.Children(end);
    Axes.Children(1).HitTest='off';

    Axes.XLim = ([t_vals(1),t_vals(end)]);
    Axes.YLim = ([-max_amp,+max_amp]);
    
    %Plot spindles
    numSpindles = size(epoch_spindles,1);


    if numSpindles >= 1

        t_trace_start=t_vals(1);
    
    
        for i = 1: numSpindles
    
            spindle_tstart = epoch_spindles(i,1);
            spindle_tend = epoch_spindles(i,2);

            [~,spindle_tstart_idx] = min(abs(t_vals-spindle_tstart));
            [~,spindle_tend_idx] = min(abs(t_vals-spindle_tend));


            tspin = t_vals(spindle_tstart_idx : spindle_tend_idx);
            yspin = y_vals(spindle_tstart_idx : spindle_tend_idx);
    
                             
            plot(Axes, tspin, yspin, 'r'); hold(Axes, 'on');
            Axes.Children(1).HitTest='off';
    
        end

    end

    hold(Axes,'off');
      
end