function MouseClickedFunction(app,event,simdata)

    global simdata;

    %Get the X and Y values of the point that was clicked
    pointClicked = event.Source.CurrentPoint;
    x_cursor = pointClicked(1,1);
    y_cursor = pointClicked(1,2);

    %Rewrite this in the future to ID the axes by tag rather than position
    %axesList = {app.Children(18),app.Children(17),app.Children(16)};
    %[axesNum,axesObject] = whichAxes(clickPoint,axesList);

    %fprintf("Axes Number: %d\n",axesNum);
    %fprintf("X position: %d  Y position: %d\n",x_cursor,y_cursor); 

    mousePosition = [x_cursor, y_cursor];
    plotSpindlePoints(app,mousePosition,app,simdata);
    
 
end