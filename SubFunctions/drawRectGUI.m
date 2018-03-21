function [img] = drawRectGUI(axes,handles,eventdata,hObject)
  % GET_PENCIL_CURVE Get a curve (sequence of points) from the user by dragging
  % on the current plot window
  %
  % P = get_pencil_curve()
  % P = get_pencil_curve(f)
  % 
  % Inputs:
  %   f  figure id
  % Outputs:
  %   P  #P by 2 list of point positions
  %
  %

  % Get the input figure or get current one (creates new one if none exist)
%   f = figure;
%   img = getimage(handles.axesCamera1);
%   imshow(img);

  % get axes of current figure (creates on if doesn't exist)
  a = gca;

  % set equal axis 
%   axis equal;
  % freeze axis
%   axis manual;
  % set view to XY plane
%   view(2);

  set(gcf,'windowbuttondownfcn',@ondown);
  set(gcf,'keypressfcn',        @onkeypress);
  % living variables
  P = [];
  p = [];
  rectCent = [];
  xDist = [];
  yDist = [];
  imgOrig = [];
  
  % loop until mouse up or ESC is pressed
  done = false;
  while(~done)
    drawnow;
  end

  % We've been also gathering Z coordinate, drop it
  P = P(:,1:2);

  % Callback for mouse press
  function ondown(src,ev)
    % Tell window that we'll handle drag and up events
    set(gcf,'windowbuttonmotionfcn', @ondrag);
    set(gcf,'windowbuttonupfcn',     @onup);
    append_current_point();
  end

  % Callback for mouse drag
  function ondrag(src,ev)
    append_current_point();
  end

  % Callback for mouse release
  function onup(src,ev)
    % Tell window to handle down, drag and up events itself
    finish();
  end

  function onkeypress(src,ev)
    % escape character id
    ESC = char(27);
    switch ev.Character
    case ESC
      finish();
    otherwise
      error(['Unknown key: ' ev.Character]);
    end
  end

  function append_current_point()
    % get current mouse position
    cp = get(gca,'currentpoint');
    % append to running list
    P = [P;cp(1,:)];
%     cp(1,:)
    if isempty(p)
      % init plot
      p=1;
      hold(handles.axesCamera1,'on');
      str = get(handles.popupmenuSetObjectColor,'String');
      val = get(handles.popupmenuSetObjectColor,'Value');
      color = str{val};
      rectCent = [P(1,1) P(1,2)];
      img = getimage(handles.axesCamera1);
      imgOrig = img;
      img = insertShape(img,'FilledRectangle',[rectCent 1 1],'Color',color,'Opacity',0.3);
      imshow(img,'Parent',handles.axesCamera1);
      drawnow();
    else
      % update plot
      str = get(handles.popupmenuSetObjectColor,'String');
      val = get(handles.popupmenuSetObjectColor,'Value');
      color = str{val};
      circBord = cp;
      xDist = cp(1,1) - rectCent(1,1);
      yDist = cp(1,2) - rectCent(1,2);
      img = getimage(handles.axesCamera1);
      img = insertShape(img,'FilledRectangle',[rectCent xDist yDist],'Color',color,'Opacity',0.3);
      imshow(img,'Parent',handles.axesCamera1);
      drawnow();
    end
  end

  function finish()
    done = true;
    hold off;
    set(gcf,'windowbuttonmotionfcn','');
    set(gcf,'windowbuttonupfcn','');
    set(gcf,'windowbuttondownfcn','');
    set(gcf,'keypressfcn','');
    str = get(handles.popupmenuSetObjectColor,'String');
    val = get(handles.popupmenuSetObjectColor,'Value');
    color = str{val};
    img = getimage(handles.axesCamera1);
    img = insertShape(img,'FilledRectangle',[rectCent xDist yDist],'Color',color,'Opacity',0.3);
  end

end