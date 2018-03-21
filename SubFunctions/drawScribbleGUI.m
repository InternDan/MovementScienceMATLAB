function [im] = drawScribbleGUI(axes,handles,eventdata,hObject)
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

  set(gcf,'windowbuttondownfcn',@ondown);
  set(gcf,'keypressfcn',        @onkeypress);
  % living variables
  P = [];
  p = [];

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
    if isempty(p)
      % init plot
      hold(handles.axesCamera1,'on');
      color = handles.LineColor;
      wt = handles.LineWeight;
      plot(handles.axesCamera1,P(:,1),P(:,2),'Color',color,'LineWidth',wt);
    else
      % update plot
      color = handles.LineColor;
      wt = handles.LineWeight;
      plot(handles.axesCamera1,P(:,1),P(:,2),'Color',color,'LineWidth',wt);
    end
  end

  function finish()
    done = true;
    hold off;
    set(gcf,'windowbuttonmotionfcn','');
    set(gcf,'windowbuttonupfcn','');
    set(gcf,'windowbuttondownfcn','');
    set(gcf,'keypressfcn','');
    color = handles.LineColor;
    wt = handles.LineWeight;
    im = getimage(handles.axesCamera1);
    c=0;
    for i = 1:length(P)-1
        c=c+1;
        P2(c,1) = P(i,1);
        P2(c,2) = P(i,2);
        P2(c,3) = P(i+1,1);
        P2(c,4) = P(i+1,2);
    end
    im = insertShape(im,'Line',P2,'Color',color,'LineWidth',wt);
  end

end