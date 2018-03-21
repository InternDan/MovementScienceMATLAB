function varargout = MovementScience(varargin)
% MOVEMENTSCIENCE MATLAB code for MovementScience.fig
%      MOVEMENTSCIENCE, by itself, creates a new MOVEMENTSCIENCE or raises the existing
%      singleton*.
%
%      H = MOVEMENTSCIENCE returns the handle to a new MOVEMENTSCIENCE or the handle to
%      the existing singleton*.
%
%      MOVEMENTSCIENCE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVEMENTSCIENCE.M with the given input arguments.
%
%      MOVEMENTSCIENCE('Property','Value',...) creates a new MOVEMENTSCIENCE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MovementScience_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MovementScience_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MovementScience

% Last Modified by GUIDE v2.5 07-Feb-2018 15:17:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MovementScience_OpeningFcn, ...
    'gui_OutputFcn',  @MovementScience_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MovementScience is made visible.
function MovementScience_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MovementScience (see VARARGIN)

% Choose default command line output for MovementScience
handles.output = hObject;

ispc = computer;
if strcmp(ispc,'PCWIN64') == 1
    handles.pathstr = getenv('USERPROFILE');
    sysLine = ['md "' handles.pathstr '\Documents\MovementScience"'];
    system(sysLine);
    handles.pathstr = [handles.pathstr '\Documents\MovementScience'];
else%add for linux and osx
    user = getenv('USER');
    pth = ['/Users/' user  '/Documents'];
    sysLine = [' mkdir ' pth '/MovementScience'];
    system(sysLine);
    pth = [pth '/MovementScience'];
    handles.pathstr = pth;
end

handles.isStoredVid = 0;
handles.isStill = 0;
handles.plot = 0;
handles.continuing = 0;

handles.ct=1;
handles.pointTrackerisInitialized = 0;
handles.onOff = 0;
handles.recordOnOff = 0;

handles.numClicked = 0;
handles.realTimeClickIndicator = 0;

handles.currIMG = [];

handles.pointData = cell(0);
handles.PointSize = 15;
handles.TrailingPointSize = 5;
handles.PointWeight = 6;
handles.TrailingPointWeight = 6;
handles.LineWeight = 8;
handles.TextSize = 30;
handles.SearchRadius = 21;
handles.PointColor = 'r';
handles.TrailingPointColor = 'g';
handles.LineColor = 'c';
handles.TextColor = 'black';
handles.TextWeight = 6;
handles.TrailingPointNumber = 30;
handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);

handles.microphoneID = 0;
global audioFrequency;
global audio;

audio = [];
audioFrequency = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MovementScience wait for user response (see UIRESUME)
% uiwait(handles.MovementScience);


% --- Outputs from this function are returned to the command line.
function varargout = MovementScience_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonPopulateCameras.
function pushbuttonPopulateCameras_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPopulateCameras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.cameras = imaqhwinfo;
handles.webcameras = webcamlist;

if ~isempty(handles.webcameras) %add accounting for other cameras
    ct=0;
    for i = length(handles.webcameras)
        ct=ct+1;
        camList{i} = handles.webcameras{i};
    end
    %     for i = length(handles.cameras)
    %         ct=ct+1;
    %         obj = handles.cameras(i);
    %         info = imaqhwinfo(obj);
    %         camList{i} = DeviceName;
    %     end
else
    camList{1} = 'none connected';
end
set(handles.popupmenuCameras,'String',camList);
guidata(hObject, handles);


% --- Executes on button press in pushbuttonSetLocalCamera1.
function pushbuttonSetLocalCamera1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetLocalCamera1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear handles.cam handles.vidTimes;

str = get(handles.popupmenuCameras,'String');
val = get(handles.popupmenuCameras,'Value');
release(handles.pointTracker);
handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
handles.pointTrackerisInitialized = 0;
handles.isStill = 0;

camName = str{val};
handles.cam = webcam(camName);%need to add for not webcams
handles.isStoredVid = 0;

handles.resolutions = handles.cam.AvailableResolutions;
for i = 1:length(handles.resolutions)
    res{i} = handles.resolutions{i};
end
set(handles.popupmenuAvailableResolutions,'String',res);

% Save the handles structure.
guidata(hObject,handles)


% --- Executes on selection change in popupmenuCameras.
function popupmenuCameras_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuCameras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuCameras contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuCameras


% --- Executes on selection change in popupmenuTextColor.
function popupmenuTextColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTextColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTextColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTextColor


% --- Executes during object creation, after setting all properties.
function popupmenuTextColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTextColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuTextSize.
function popupmenuTextSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTextSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTextSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTextSize


% --- Executes during object creation, after setting all properties.
function popupmenuTextSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTextSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function popupmenuCameras_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuCameras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonIPCamera.
function pushbuttonIPCamera_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonIPCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
release(handles.pointTracker);
handles.cam = ipcam(get(handles.editIPAddress,'String'));
handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
preview(handles.cam);
guidata(hObject, handles);


% --- Executes on button press in togglebuttonStream.
function togglebuttonStream_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonStream (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonStream

global img;

if handles.isStoredVid == 0
    img = [];
    handles.time = [];
    handles.cp = [];
    try
        rmfield(handles,'audio');
    catch
    end
    tic
end

handles.onOff = get(handles.togglebuttonStream,'Value');
if handles.onOff == 1
    set(handles.togglebuttonStream,'BackgroundColor','r');
    set(handles.togglebuttonStream,'String','Playing');
    guidata(hObject, handles);
    drawnow();
else
    set(handles.togglebuttonStream,'BackgroundColor','g');
    set(handles.togglebuttonStream,'String','Stream/Play');
    guidata(hObject, handles);
    drawnow();
end

handles.timeFrames2= [];
tic;
while handles.onOff == 1
    if handles.isStoredVid == 0%for streaming
        %time stamps
        if isempty(handles.time)
            handles.time = toc;
        else
            handles.time = [handles.time toc];
        end
        %grab a frame
        
        
        %check if the user wants to click a point to track
        if handles.realTimeClickIndicator == 1
            handles.currIMG = snapshot(handles.cam);
            str = get(handles.popupmenuFeature,'String');
            val = get(handles.popupmenuFeature,'Value');
            feat = str{val};
            switch feat
                case 'Point'
                    imshow(handles.currIMG,'Parent',handles.axesCamera1);
                    [x y] = getpts(handles.axesCamera1);
                    if isempty(handles.ptType)
                        handles.ptType(1:length(x)) = {'p'};
                    elseif ~isempty(handles.ptType)
                        handles.ptType(end+1:end+1+length(x)-1) = {'p'};
                    end
                    if ~isempty(handles.trackPoints)
                        handles.trackPoints = [handles.trackPoints; [x y]];
                    else
                        handles.trackPoints = [x y];
                    end
                    clear handles.trailPoints handles.position;
                    handles.trailPoints{1} = handles.trackPoints;
                    handles.position{1} = handles.trackPoints;
                    release(handles.pointTracker);
                    handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
                    initialize(handles.pointTracker,handles.trackPoints,handles.currIMG);
                    %                     str = get(handles.popupmenuSetPointColor,'String');
                    %                     val = get(handles.popupmenuSetPointColor,'Value');
                    %                     color = str(val);
                    for i = 1:length(x)
                        handles.currIMG = insertShape(handles.currIMG,'circle',[handles.trackPoints(i,1) handles.trackPoints(i,2) handles.PointSize],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                    end
                    imshow(handles.currIMG,'Parent',handles.axesCamera1);
                    handles.pointTrackerisInitialized = 1;
                    guidata(hObject, handles);
                    
                case '2-Point Line'
                    [x y] = getpts(handles.axesCamera1,2);
                    if isempty(handles.ptType)
                        handles.ptType(1:length(x)) = {'l'};
                    elseif ~isempty(handles.ptType)
                        handles.ptType(end+1:end+1+length(x)-1) = {'l'};
                    end
                    if ~isempty(handles.trackPoints)
                        handles.trackPoints = [handles.trackPoints; [x y]];
                    else
                        handles.trackPoints = [x y];
                    end
                    release(handles.pointTracker);
                    handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
                    initialize(handles.pointTracker,handles.trackPoints,handles.currIMG);
                    %                     str = get(handles.popupmenuSetPointColor,'String');
                    %                     val = get(handles.popupmenuSetPointColor,'Value');
                    %                     color = str(val);
                    for i = 1:length(x)
                        handles.currIMG = insertShape(handles.currIMG,'circle',[handles.trackPoints(i,1) handles.trackPoints(i,2) handles.PointSize],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                    end
                    %                     str = get(handles.popupmenuSetLineColor,'String');
                    %                     val = get(handles.popupmenuSetLineColor,'Value');
                    %                     color = str(val);
                    handles.currIMG = insertShape(handles.currIMG,'line',[handles.trackPoints(1,1) handles.trackPoints(1,2) handles.trackPoints(2,1) handles.trackPoints(2,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                    imshow(handles.currIMG,'Parent',handles.axesCamera1);
                    handles.pointTrackerisInitialized = 1;
                    guidata(hObject, handles);
                case '2-Point Angle'
                    %get 2 points explicitly
                    [x y] = getpts(handles.axesCamera1,2);
                    
                    %fill label vector for which kind of points are being added
                    if isempty(handles.ptType)
                        handles.ptType(1:length(x)) = {'2a'};
                    elseif ~isempty(handles.ptType)
                        handles.ptType(end+1:end+1+length(x)-1) = {'2a'};
                    end
                    
                    %append coordinates for points
                    if ~isempty(handles.trackPoints)
                        handles.trackPoints = [handles.trackPoints; [x y]];
                    else
                        handles.trackPoints = [x y];
                    end
                    
                    %re-initialize tracker due to added points
                    release(handles.pointTracker);
                    handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
                    try
                        initialize(handles.pointTracker,handles.trackPoints,img{handles.ct});
                    catch
                        initialize(handles.pointTracker,handles.trackPoints,handles.currIMG);
                    end
                    
                    %plot points and line
                    if handles.isStoredVid == 0 || handles.isStill == 1
                        for i = 1:length(x)
                            handles.currIMG = insertShape(handles.currIMG,'circle',[x(i) y(i) handles.PointSize],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                        end
                    else
                        for i = 1:length(x)
                            img{handles.ct} = insertShape(img{handles.ct},'circle',[x(i) y(i) handles.PointSize],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                        end
                    end
                    if handles.isStoredVid == 0 || handles.isStill == 1
                        handles.currIMG = insertShape(handles.currIMG,'line',[x(1) y(1) x(2) y(2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                        imshow(handles.currIMG,'Parent',handles.axesCamera1);
                        
                    else
                        img{handles.ct} = insertShape(img{handles.ct},'line',[x(1) y(1) x(2) y(2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                        imshow(img{handles.ct},'Parent',handles.axesCamera1);
                        
                    end
                    
                    %calculate angle
                    angle = atan((y(2)-y(1))/(x(2)-x(1)));
                    if angle < 0
                        angle = angle + pi;
                    end
                    angle = rad2deg(angle);
                    if isempty(handles.angles)
                        handles.angles{1} = angle;
                    else
                        handles.angles{length(handles.angles)+1} = angle;
                    end
                    
                    if handles.isStoredVid == 0 || handles.isStill == 1
                        %             str = get(handles.popupmenuTextSize,'String');
                        %             val = get(handles.popupmenuTextSize,'Value');
                        %             sz = str{val};
                        %             str = get(handles.popupmenuTextColor,'String');
                        %             val = get(handles.popupmenuTextColor,'Value');
                        %             color = str{val};
                        handles.currIMG = insertText(handles.currIMG,[x(1)+10,y(1)+10],num2str(angle),'FontSize',handles.TextSize,...
                            'TextColor',handles.TextColor);
                        imshow(handles.currIMG,'Parent',handles.axesCamera1);
                        
                    else
                        %             str = get(handles.popupmenuTextSize,'String');
                        %             val = get(handles.popupmenuTextSize,'Value');
                        %             sz = str{val};
                        %             str = get(handles.popupmenuTextColor,'String');
                        %             val = get(handles.popupmenuTextColor,'Value');
                        %             color = str{val};
                        %             str = get(handles.popupmenuTextSize,'String');
                        %             val = get(handles.popupmenuTextSize,'Value');
                        img{handles.ct} = insertText(img{handles.ct},[x(1)+10,y(1)+10],num2str(angle),...
                            'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                        imshow(img{handles.ct},'Parent',handles.axesCamera1);
                        
                    end
                    
                    handles.pointTrackerisInitialized = 1;
                    guidata(hObject, handles);
                    
                case '3-Point Angle'
                    %get 2 points explicitly
                    [x y] = getpts(handles.axesCamera1,3);
                    
                    %fill label vector for which kind of points are being added
                    if isempty(handles.ptType)
                        handles.ptType(1:length(x)) = {'3a'};
                    elseif ~isempty(handles.ptType)
                        handles.ptType(end+1:end+1+length(x)-1) = {'3a'};
                    end
                    
                    %append coordinates for points
                    if ~isempty(handles.trackPoints)
                        handles.trackPoints = [handles.trackPoints; [x y]];
                    else
                        handles.trackPoints = [x y];
                    end
                    
                    %re-initialize tracker due to added points
                    release(handles.pointTracker);
                    handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
                    try
                        initialize(handles.pointTracker,handles.trackPoints,img{handles.ct});
                    catch
                        initialize(handles.pointTracker,handles.trackPoints,handles.currIMG);
                    end
                    
                    %plot points and line
                    %         str = get(handles.popupmenuSetPointColor,'String');
                    %         val = get(handles.popupmenuSetPointColor,'Value');
                    %         color = str(val);
                    if handles.isStoredVid == 0 || handles.isStill == 1
                        for i = 1:length(x)
                            handles.currIMG = insertShape(handles.currIMG,'circle',[x(i) y(i) handles.PointSize],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                        end
                    else
                        for i = 1:length(x)
                            img{handles.ct} = insertShape(img{handles.ct},'circle',[x(i) y(i) handles.PointSize],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                        end
                    end
                    %         str = get(handles.popupmenuSetLineColor,'String');
                    %         val = get(handles.popupmenuSetLineColor,'Value');
                    %         color = str(val);
                    
                    %calculate angle
                    P0 = [x(1) y(1)];
                    P1 = [x(2) y(2)];
                    P2 = [x(3) y(3)];
                    angle = atan2(abs(det([P2-P0;P1-P0])),dot(P2-P0,P1-P0));
                    if angle < 0
                        angle = angle + pi;
                    end
                    angle = rad2deg(angle);
                    if isempty(handles.angles)
                        handles.angles{1} = angle;
                    else
                        handles.angles{length(handles.angles)+1} = angle;
                    end
                    
                    
                    if handles.isStoredVid == 0 || handles.isStill == 1
                        handles.currIMG = insertShape(handles.currIMG,'line',[x(1) y(1) x(2) y(2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                        handles.currIMG = insertShape(handles.currIMG,'line',[x(1) y(1) x(3) y(3)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                    else
                        img{handles.ct} = insertShape(img{handles.ct},'line',[x(1) y(1) x(2) y(2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                        img{handles.ct} = insertShape(img{handles.ct},'line',[x(1) y(1) x(3) y(3)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                    end
                    
                    if handles.isStoredVid == 0 || handles.isStill == 1
                        %             str = get(handles.popupmenuTextSize,'String');
                        %             val = get(handles.popupmenuTextSize,'Value');
                        %             sz = str{val};
                        %             str = get(handles.popupmenuTextColor,'String');
                        %             val = get(handles.popupmenuTextColor,'Value');
                        %             color = str{val};
                        handles.currIMG = insertText(handles.currIMG,[x(1)+10,y(1)+10],num2str(angle),...
                            'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                        imshow(handles.currIMG,'Parent',handles.axesCamera1);
                        
                    else
                        %             str = get(handles.popupmenuTextSize,'String');
                        %             val = get(handles.popupmenuTextSize,'Value');
                        %             sz = str{val};
                        %             str = get(handles.popupmenuTextColor,'String');
                        %             val = get(handles.popupmenuTextColor,'Value');
                        %             color = str{val};
                        img{handles.ct} = insertText(img{handles.ct},[x(1)+10,y(1)+10],num2str(angle),...
                            'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                        imshow(img{handles.ct},'Parent',handles.axesCamera1);
                        
                    end
                    
                    handles.pointTrackerisInitialized = 1;
                    guidata(hObject, handles);
                    
                case '4-Point Angle'
                    [x y] = getpts(handles.axesCamera1);
                    [a b c] = size(img{round(handles.ct)});
                    y = y;%correct for top/bottom flip
                    for i = 1:length(x)
                        if length(handles.pointData) == 0
                            handles.pointData{1,1} = handles.ct;
                            handles.pointData{1,2} = handles.ct/handles.vidInfo.FrameRate;
                            handles.pointData{1,3} = '4a';
                            handles.pointData{1,4} = [x(i) y(i)];
                            handles.pointData{1,5} = [NaN NaN];
                            handles.pointData{1,6} = [NaN NaN];
                            handles.pointData{1,7} = [x(i) y(i)];
                            handles.pointData{1,8} = 0;
                            handles.pointData{1,9} = 0;
                            handles.pointData{1,10} = 0;
                        else
                            row = length(handles.pointData(:,1));
                            handles.pointData{row+1,1} = handles.ct;%frame added
                            handles.pointData{row+1,2} = handles.ct/handles.vidInfo.FrameRate;%time added
                            handles.pointData{row+1,3} = '4a';%point type
                            handles.pointData{row+1,4} = [x(i) y(i)];%point position
                            handles.pointData{row+1,5} = [NaN NaN];%point velocity
                            handles.pointData{row+1,6} = [NaN NaN];%point acceleration
                            handles.pointData{row+1,7} = [x(i) y(i)];%initial trail point
                            handles.pointData{row+1,8} = 0;%angle
                            handles.pointData{row+1,9} = 0;%angular velocity
                            handles.pointData{row+1,10} = 0;%angular acceleration
                        end
                    end
                    
                    %re-initialize tracker due to added points
                    release(handles.pointTracker);
                    handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
                    try
                        %create handles.trackPoints with last position of each
                        %point
                        for i = 1:length(handles.pointData(:,1))
                            handles.trackPoints(i,:) = handles.pointData{i,4}(end,:);
                        end
                        initialize(handles.pointTracker,handles.trackPoints,img{handles.ct});
                    catch
                        for i = 1:length(handles.pointData(:,1))
                            handles.trackPoints(i,:) = handles.pointData{i,4}(end,:);
                        end
                        initialize(handles.pointTracker,handles.trackPoints,handles.currIMG);
                    end
                    
                    %re-initialize tracker due to added points
                    release(handles.pointTracker);
                    handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
                    try
                        initialize(handles.pointTracker,handles.trackPoints,img{handles.ct});
                    catch
                        initialize(handles.pointTracker,handles.trackPoints,handles.currIMG);
                    end
                    
                    %plot points
                    if handles.isStoredVid == 0 || handles.isStill == 1
                        ct=0;
                        clear x y;
                        for i = 1:length(trackPoints)
                            if strcmp(handles.pointData{i,3},'4a') == 1
                                ct=ct+1;
                                x(ct) = handles.trackPoints(i,1);
                                y(ct) = handles.trackPoints(i,2);
                                sz(ct) = handles.PointSize;
                            end
                        end
                        handles.currIMG = insertShape(handles.currIMG,'circle',[x' y' sz'],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                        imshow(handles.currIMG,'Parent',handles.axesCamera1);
                    else
                        ct=0;
                        clear x y;
                        for i = 1:length(handles.trackPoints)
                            if strcmp(handles.pointData{i,3},'p') == 1
                                ct=ct+1;
                                x(ct) = handles.trackPoints(i,1);
                                y(ct) = handles.trackPoints(i,2);
                                sz(ct) = handles.PointSize;
                            end
                        end
                        img{handles.ct} = insertShape(img{handles.ct},'circle',[x' y' sz'],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                        imshow(img{handles.ct},'Parent',handles.axesCamera1);
                    end
                    %plot lines
                    x = x(end-3,end);
                    y = y(end-3,end);
                    if handles.isStoredVid == 0 || handles.isStill == 1
                        handles.currIMG = insertShape(handles.currIMG,'line',[x(1) y(1) x(2) y(2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                        handles.currIMG = insertShape(handles.currIMG,'line',[x(3) y(3) x(4) y(4)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                    else
                        img{handles.ct} = insertShape(img{handles.ct},'line',[x(1) y(1) x(2) y(2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                        img{handles.ct} = insertShape(img{handles.ct},'line',[x(3) y(3) x(4) y(4)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                    end
                    
                    %calculate angle
                    P0 = [x(1) y(1)];
                    P1 = [x(2) y(2)];
                    P2 = [x(3) y(3)];
                    P3 = [x(4) y(4)];
                    v1 = P1 - P0;
                    v2 = P3 - P2;
                    a1 = mod(atan2( det([v1;v2;]) , dot(v1,v2) ), 2*pi );
                    angle = (a1>pi/2)*pi-a1;
                    if angle < 0
                        angle = angle + pi;
                    end
                    angle = rad2deg(angle);
                    if isempty(handles.angles)
                        handles.angles{1} = angle;
                    else
                        handles.angles{length(handles.angles)+1} = angle;
                    end
                    if handles.isStoredVid == 0 || handles.isStill == 1
                        handles.currIMG = insertText(handles.currIMG,[x(1)+10,y(1)+10],num2str(angle),...
                            'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                        imshow(handles.currIMG,'Parent',handles.axesCamera1);
                    else
                        img{handles.ct} = insertText(img{handles.ct},[x(1)+10,y(1)+10],num2str(angle),...
                            'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                        imshow(img{handles.ct},'Parent',handles.axesCamera1);
                    end
                    
                    handles.pointTrackerisInitialized = 1;
                    guidata(hObject, handles);
                    
                    
            end
            drawnow();
            
            handles.realTimeClickIndicator = 0;
        else
            handles.currIMG = snapshot(handles.cam);
            if handles.pointTrackerisInitialized == 1
                handles = realTimeProcess(handles,eventdata,hObject);
            end
            imshow(handles.currIMG,'Parent',handles.axesCamera1);
            drawnow();
        end
        
        %store frame if record is pressed
        if get(handles.togglebuttonRecordVideo,'Value') == 1
            set(handles.togglebuttonRecordVideo,'BackgroundColor','r');
            if isempty(img)
                img{1} = handles.currIMG;
            else
                img{length(img)+1} = handles.currIMG;
            end
        else
            set(handles.togglebuttonRecordVideo,'BackgroundColor','g');
        end
        drawnow();
        handles.onOff = get(handles.togglebuttonStream,'Value');
        guidata(hObject, handles);
    else%for loaded videos
        ispc = computer;
        if strcmp(ispc,'PCWIN64') == 1
            pth = getenv('USERPROFILE');
            pth = [pth '\Documents'];
            pth = [pth '\MovementScience'];
            zers = '00000000';
            if get(handles.togglebuttonRecordAudioOverMovie,'Value') == 1 && get(handles.togglebuttonStream,'Value') == 1
                handles.ct2 = round(get(handles.sliderLoadedVideo,'Value'));
                if handles.ct2 < length(img)
                    handles.ct = handles.ct+1;
                    %                     if ~isempty(handles.trackPoints)
                    %                         handles = processFrame(handles,eventdata,hObject);
                    %                     end
                    imshow(img{handles.ct2},'Parent',handles.axesCamera1);
                    drawnow();
                    im = getimage(handles.axesCamera1);
                    %                 h2 = figure;
                    %                 imshow(im);
                    imwrite(im,[pth '\towrite' zers(1:end-length(num2str(handles.ct))) num2str(handles.ct) '.tif']);
                    fprintf(handles.fid,'%s\t',[pth '\towrite' zers(1:end-length(num2str(handles.ct))) num2str(handles.ct) '.tif']);
                    fprintf(handles.fid,'%s\t',num2str(1));
                    fprintf(handles.fid,'%s\n',num2str(toc(handles.tic)));
                    guidata(hObject, handles);
                    handles.ct2 = handles.ct2+1;
                    set(handles.sliderLoadedVideo,'Value',handles.ct2);
                    set(handles.editFrame,'String',num2str(handles.ct2));
                end
                guidata(hObject, handles);
                drawnow();
            elseif get(handles.togglebuttonRecordAudioOverMovie,'Value') == 1 && get(handles.togglebuttonStream,'Value') == 0
                handles.continuing = 1;
                guidata(hObject, handles);
                togglebuttonRecordAudioOverMovie_Callback(hObject, eventdata, handles)
            else
                handles.ct = get(handles.sliderLoadedVideo,'Value');
                guidata(hObject, handles);
                handles = processFrame(handles,eventdata,hObject);
                imshow(img{handles.ct},'Parent',handles.axesCamera1);
                handles.ct = handles.ct + 1;
                if handles.ct <= length(img)
                    set(handles.sliderLoadedVideo,'Value',handles.ct);
                    set(handles.editFrame,'String',num2str(handles.ct));
                end
                drawnow();
                if handles.ct > length(img) || handles.ct == length(img)
                    handles.onOff = 0;
                    set(handles.togglebuttonStream,'BackgroundColor','g');
                    set(handles.togglebuttonStream,'String','Track/Stream/Play');
                else
                    handles.onOff = get(handles.togglebuttonStream,'Value');
                end
            end
        end
        
        if strcmp(ispc,'MACI64') == 1
            pth = getenv('USER');
            pth = ['/Users/' pth '/Documents'];
            sysLine = [' mkdir ' pth '/MovementScience'];
            system(sysLine);
            pth = [pth '/MovementScience'];
            zers = '00000000';
            if get(handles.togglebuttonRecordAudioOverMovie,'Value') == 1 && get(handles.togglebuttonStream,'Value') == 1
                handles.ct2 = round(get(handles.sliderLoadedVideo,'Value'));
                if handles.ct2 < length(img)
                    handles.ct = handles.ct+1;
                    %                     if ~isempty(handles.trackPoints)
                    %                         handles = processFrame(handles,eventdata,hObject);
                    %                     end
                    imshow(img{handles.ct2},'Parent',handles.axesCamera1);
                    drawnow();
                    im = getimage(handles.axesCamera1);
                    %                 h2 = figure;
                    %                 imshow(im);
                    imwrite(im,[pth '\towrite' zers(1:end-length(num2str(handles.ct))) num2str(handles.ct) '.tif']);
                    fprintf(handles.fid,'%s\t',[pth '\towrite' zers(1:end-length(num2str(handles.ct))) num2str(handles.ct) '.tif']);
                    fprintf(handles.fid,'%s\t',num2str(1));
                    fprintf(handles.fid,'%s\n',num2str(toc(handles.tic)));
                    guidata(hObject, handles);
                    handles.ct2 = handles.ct2+1;
                    set(handles.sliderLoadedVideo,'Value',handles.ct2);
                    set(handles.editFrame,'String',num2str(handles.ct2));
                end
                guidata(hObject, handles);
                drawnow();
            elseif get(handles.togglebuttonRecordAudioOverMovie,'Value') == 1 && get(handles.togglebuttonStream,'Value') == 0
                handles.continuing = 1;
                guidata(hObject, handles);
                togglebuttonRecordAudioOverMovie_Callback(hObject, eventdata, handles)
            else
                handles.ct = get(handles.sliderLoadedVideo,'Value');
                guidata(hObject, handles);
                handles = processFrame(handles,eventdata,hObject);
                imshow(img{handles.ct},'Parent',handles.axesCamera1);
                handles.ct = handles.ct + 1;
                if handles.ct <= length(img)
                    set(handles.sliderLoadedVideo,'Value',handles.ct);
                    set(handles.editFrame,'String',num2str(handles.ct));
                end
                drawnow();
                if handles.ct > length(img)
                    handles.onOff = 0;
                else
                    handles.onOff = get(handles.togglebuttonStream,'Value');
                end
            end
        end
        
        guidata(hObject, handles);
    end
end

guidata(hObject, handles);

function [handles] = realTimeProcess(handles,eventdata,hObject)

global img;

imgNext = snapshot(handles.cam);
handles.trackPoints = step(handles.pointTracker,imgNext);
handles.trailPoints{length(handles.trailPoints)+1} = handles.trackPoints;

pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'p'))),:);
if ~isempty(pt)
    %     str = get(handles.popupmenuSetPointColor,'String');
    %     val = get(handles.popupmenuSetPointColor,'Value');
    %     color = str(val);
    clear ptPlot;
    for j = 1:length(pt(:,1))
        ptPlot(j,:) = [pt(j,:) handles.PointSize];
    end
    imgNext = insertShape(imgNext,'circle',ptPlot,'LineWidth',handles.PointWeight,'Color',handles.PointColor);
    %     str = get(handles.popupmenuSetTrailingPointColor,'String');
    %     val = get(handles.popupmenuSetTrailingPointColor,'Value');
    %     color = str(val);
    clear ptTrailPlot;
    c = 0;
    %     numTrailPts = str2num(get(handles.editTrailingPoints,'String'));
    if length(handles.trailPoints) <= handles.TrailingPointNumber && length(handles.trailPoints) > 0
        for j = 1:length(handles.trailPoints)
            for k = 1:length(handles.trailPoints{j}(:,1))
                c=c+1;
                ptTrailPlot(c,:) = [handles.trailPoints{j}(k,:) handles.TrailingPointSize];
            end
        end
    elseif length(handles.trailPoints) > handles.TrailingPointNumber
        c=0;
        for j = length(handles.trailPoints) - handles.TrailingPointNumber:length(handles.trailPoints)
            for k = 1:length(handles.trailPoints{j}(:,1))
                c=c+1;
                ptTrailPlot(c,:) = [handles.trailPoints{j}(k,:) handles.TrailingPointSize];
            end
        end
    end
    imgNext = insertShape(imgNext,'circle',ptTrailPlot,'LineWidth',handles.TrailingPointWeight,'Color',handles.TrailingPointColor);
    guidata(hObject, handles);
end

pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'l'))),:);
if ~isempty(pt)
    %     str = get(handles.popupmenuSetPointColor,'String');
    %     val = get(handles.popupmenuSetPointColor,'Value');
    %     color = str(val);
    clear ptPlot;
    for j = 1:length(pt(:,1))
        ptPlot(j,:) = [pt(j,:) handles.PointSize];
    end
    imgNext = insertShape(imgNext,'circle',ptPlot,'LineWidth',handles.PointWeight,'Color',handles.PointColor);
    %     str = get(handles.popupmenuSetLineColor,'String');
    %     val = get(handles.popupmenuSetLineColor,'Value');
    %     color = str(val);
    for i = 1:2:length(pt)
        imgNext = insertShape(imgNext,'line',[pt(1,1) pt(1,2) pt(2,1) pt(2,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
    end
    guidata(hObject, handles);
end

%2 point angles
pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'2a'))),:);
if ~isempty(pt)
    %     str = get(handles.popupmenuSetPointColor,'String');
    %     val = get(handles.popupmenuSetPointColor,'Value');
    %     color = str(val);
    clear ptPlot;
    for j = 1:length(pt(:,1))
        ptPlot(j,:) = [pt(j,:) handles.PointSize];
    end
    imgNext = insertShape(imgNext,'circle',ptPlot,'LineWidth',handles.PointWeight,'Color',handles.PointColor);
    %     str = get(handles.popupmenuSetLineColor,'String');
    %     val = get(handles.popupmenuSetLineColor,'Value');
    %     color = str(val);
    for i = 1:2:length(pt)
        imgNext = insertShape(imgNext,'line',[pt(i,1) pt(i,2) pt(i+1,1) pt(i+1,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
        %calculate angle
        angle = atan((pt(i+1,2)-pt(i,2))/(pt(i+1,1)-pt(i,1)));
        if angle < 0
            angle = angle + pi;
        end
        angle = rad2deg(angle);
        handles.angles{length(handles.angles)+1} = angle;
        %         str = get(handles.popupmenuTextSize,'String');
        %         val = get(handles.popupmenuTextSize,'Value');
        %         sz = str{val};
        %         str = get(handles.popupmenuTextColor,'String');
        %         val = get(handles.popupmenuTextColor,'Value');
        %         color = str{val};
        imgNext = insertText(imgNext,[pt(i,1)+10,pt(i,2)+10],num2str(angle),'FontSize',handles.TextSize,'TextColor',handles.TextColor);
        
    end
    guidata(hObject, handles);
end

%3 point angles
pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'3a'))),:);
if ~isempty(pt)
    %     str = get(handles.popupmenuSetPointColor,'String');
    %     val = get(handles.popupmenuSetPointColor,'Value');
    %     color = str(val);
    clear ptPlot;
    for j = 1:length(pt(:,1))
        ptPlot(j,:) = [pt(j,:) handles.PointSize];
    end
    imgNext = insertShape(imgNext,'circle',ptPlot,'LineWidth',handles.PointWeight,'Color',handles.PointColor);
    %     str = get(handles.popupmenuSetLineColor,'String');
    %     val = get(handles.popupmenuSetLineColor,'Value');
    %     color = str(val);
    for i = 1:3:length(pt)
        imgNext = insertShape(imgNext,'line',[pt(i,1) pt(i,2) pt(i+1,1) pt(i+1,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
        imgNext = insertShape(imgNext,'line',[pt(i,1) pt(i,2) pt(i+2,1) pt(i+2,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
        %calculate angle
        P0 = pt(i,:);
        P1 = pt(i+1,:);
        P2 = pt(i+2,:);
        angle = atan2(abs(det([P2-P0;P1-P0])),dot(P2-P0,P1-P0));
        if angle < 0
            angle = angle + pi;
        end
        angle = rad2deg(angle);
        if isempty(handles.angles)
            handles.angles{1} = angle;
        else
            handles.angles{length(handles.angles)+1} = angle;
        end
        %         str = get(handles.popupmenuTextSize,'String');
        %         val = get(handles.popupmenuTextSize,'Value');
        %         sz = str{val};
        %         str = get(handles.popupmenuTextColor,'String');
        %         val = get(handles.popupmenuTextColor,'Value');
        %         color = str{val};
        imgNext = insertText(imgNext,[pt(i,1)+10,pt(i,2)+10],num2str(angle),'FontSize',handles.TextSize,'TextColor',handles.TextColor);
        guidata(hObject, handles);
    end
end

pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'4a'))),:);
if ~isempty(pt)
    %     str = get(handles.popupmenuSetPointColor,'String');
    %     val = get(handles.popupmenuSetPointColor,'Value');
    %     color = str(val);
    clear ptPlot;
    for j = 1:length(pt(:,1))
        ptPlot(j,:) = [pt(j,:) handles.PointSize];
    end
    imgNext = insertShape(imgNext,'circle',ptPlot,'LineWidth',handles.PointWeight,'Color',handles.PointColor);
    %     str = get(handles.popupmenuSetLineColor,'String');
    %     val = get(handles.popupmenuSetLineColor,'Value');
    %     color = str(val);
    for i = 1:4:length(pt)
        imgNext = insertShape(imgNext,'line',[pt(i,1) pt(i,2) pt(i+1,1) pt(i+1,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
        imgNext = insertShape(imgNext,'line',[pt(i+2,1) pt(i+2,2) pt(i+3,1) pt(i+3,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
        %calculate angle
        P0 = pt(i,:);
        P1 = pt(i+1,:);
        P2 = pt(i+2,:);
        P3 = pt(i+3,:);
        v1 = P1 - P0;
        v2 = P3 - P2;
        
        a1 = mod(atan2( det([v1;v2;]) , dot(v1,v2) ), 2*pi );
        angle = (a1>pi/2)*pi-a1;
        if angle < 0
            angle = angle + pi;
        end
        angle = rad2deg(angle);
        if isempty(handles.angles)
            handles.angles{1} = angle;
        else
            handles.angles{length(handles.angles)+1} = angle;
        end
        %         str = get(handles.popupmenuTextSize,'String');
        %         val = get(handles.popupmenuTextSize,'Value');
        %         sz = str{val};
        %         str = get(handles.popupmenuTextColor,'String');
        %         val = get(handles.popupmenuTextColor,'Value');
        %         color = str{val};
        imgNext = insertText(imgNext,[pt(i,1)+10,pt(i,2)+10],num2str(angle),'FontSize',handles.TextSize,'TextColor',handles.TextColor);
        guidata(hObject, handles);
    end
end
handles.currIMG = imgNext;
guidata(hObject, handles);


% --- Executes on button press in togglebuttonRecordVideo.
function togglebuttonRecordVideo_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonRecordVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonRecordVideo


function editMovieName_Callback(hObject, eventdata, handles)
% hObject    handle to editMovieName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMovieName as text
%        str2double(get(hObject,'String')) returns contents of editMovieName as a double


% --- Executes during object creation, after setting all properties.
function editMovieName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMovieName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonAddFeatureToTrack.
function pushbuttonAddFeatureToTrack_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddFeatureToTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;


if handles.isStoredVid == 0
    handles.numClicked = 0;
    handles.realTimeClickIndicator = 1;
    guidata(hObject, handles);
    togglebuttonStream_Callback(hObject,eventdata,handles);
end


if handles.onOff == 1
    handles.onOff = 0;
    guidata(hObject, handles);
    set(handles.togglebuttonStream,'BackgroundColor','c');
    drawnow();
end

str = get(handles.popupmenuFeature,'String');
val = get(handles.popupmenuFeature,'Value');

feat = str{val};

handles.currIMG = getimage(handles.axesCamera1);
handles.ct = round(get(handles.sliderLoadedVideo,'Value'));%just added
guidata(hObject, handles);

if handles.realTimeClickIndicator == 0
    switch feat
        case 'Point'
            %get clicked points
            [x y] = getpts(handles.axesCamera1);
            [a b c] = size(img{round(handles.ct)});
            y = y;%correct for top/bottom flip
            for i = 1:length(x)
                if length(handles.pointData) == 0
                    handles.pointData{1,1} = handles.ct;
                    handles.pointData{1,2} = handles.ct/handles.vidInfo.FrameRate;
                    handles.pointData{1,3} = 'p';
                    handles.pointData{1,4} = [x(i) y(i)];
                    handles.pointData{1,5} = [0 0];
                    handles.pointData{1,6} = [0 0];
                    handles.pointData{1,7} = [x(i) y(i)];
                    handles.pointData{1,8} = NaN;
                    handles.pointData{1,9} = NaN;
                    handles.pointData{1,10} = NaN;
                else
                    row = length(handles.pointData(:,1));
                    handles.pointData{row+1,1} = handles.ct;%frame added
                    handles.pointData{row+1,2} = handles.ct/handles.vidInfo.FrameRate;%time added
                    handles.pointData{row+1,3} = 'p';%point type
                    handles.pointData{row+1,4} = [x(i) y(i)];%point position
                    handles.pointData{row+1,5} = [0 0];%point velocity
                    handles.pointData{row+1,6} = [0 0];%point acceleration
                    handles.pointData{row+1,7} = [x(i) y(i)];%initial trail point
                    handles.pointData{row+1,8} = NaN;%angle
                    handles.pointData{row+1,9} = NaN;%angular velocity
                    handles.pointData{row+1,10} = NaN;%angular acceleration
                end
            end
            
            %re-initialize tracker due to added points
            release(handles.pointTracker);
            handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
            try
                %create handles.trackPoints with last position of each
                %point
                for i = 1:length(handles.pointData(:,1))
                    handles.trackPoints(i,:) = handles.pointData{i,4}(end,:);
                end
                initialize(handles.pointTracker,handles.trackPoints,img{handles.ct});
            catch
                initialize(handles.pointTracker,handles.trackPoints,handles.currIMG);
            end
            
            if handles.isStoredVid == 0 || handles.isStill == 1
                ct=0;
                clear x y;
                for i = 1:length(trackPoints(:,1))
                    if strcmp(handles.pointData{i,3},'p') == 1
                        ct=ct+1;
                        x(ct) = handles.trackPoints(i,1);
                        y(ct) = handles.trackPoints(i,2);
                        sz(ct) = handles.PointSize;
                    end
                end
                handles.currIMG = insertShape(handles.currIMG,'circle',[x' y' sz'],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                imshow(handles.currIMG,'Parent',handles.axesCamera1);
                
            else
                ct=0;
                clear x y;
                for i = 1:length(handles.trackPoints(:,1))
                    if strcmp(handles.pointData{i,3},'p') == 1
                        ct=ct+1;
                        x(ct) = handles.trackPoints(i,1);
                        y(ct) = handles.trackPoints(i,2);
                        sz(ct) = handles.PointSize;
                    end
                end
                img{handles.ct} = insertShape(img{handles.ct},'circle',[x' y' sz'],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                imshow(img{handles.ct},'Parent',handles.axesCamera1);
                
            end
            handles.pointTrackerisInitialized = 1;
            guidata(hObject, handles);
            
        case '2-Point Line'
            [x y] = getpts(handles.axesCamera1);
            if length(x) ~= 2
                msgbox('Pick two points for the two point line!');
                return
            end
            [a b c] = size(img{round(handles.ct)});
            y = y;%correct for top/bottom flip
            for i = 1:length(x)
                if length(handles.pointData) == 0
                    handles.pointData{1,1} = handles.ct;
                    handles.pointData{1,2} = handles.ct/handles.vidInfo.FrameRate;
                    handles.pointData{1,3} = 'l';
                    handles.pointData{1,4} = [x(i) y(i)];
                    handles.pointData{1,5} = [NaN NaN];
                    handles.pointData{1,6} = [NaN NaN];
                    handles.pointData{1,7} = [NaN NaN];
                    handles.pointData{1,8} = NaN;
                    handles.pointData{1,9} = NaN;
                    handles.pointData{1,10} = NaN;
                else
                    row = length(handles.pointData(:,1));
                    handles.pointData{row+1,1} = handles.ct;%frame added
                    handles.pointData{row+1,2} = handles.ct/handles.vidInfo.FrameRate;%time added
                    handles.pointData{row+1,3} = 'l';%point type
                    handles.pointData{row+1,4} = [x(i) y(i)];%point position
                    handles.pointData{row+1,5} = [NaN NaN];%point velocity
                    handles.pointData{row+1,6} = [NaN NaN];%point acceleration
                    handles.pointData{row+1,7} = [NaN NaN];%initial trail point
                    handles.pointData{row+1,8} = NaN;%angle
                    handles.pointData{row+1,9} = NaN;%angular velocity
                    handles.pointData{row+1,10} = NaN;%angular acceleration
                end
            end
            
            %re-initialize tracker due to added points
            release(handles.pointTracker);
            handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
            try
                %create handles.trackPoints with last position of each
                %point
                for i = 1:length(handles.pointData(:,1))
                    handles.trackPoints(i,:) = handles.pointData{i,4}(end,:);
                end
                initialize(handles.pointTracker,handles.trackPoints,img{handles.ct});
            catch
                for i = 1:length(handles.pointData(:,1))
                    handles.trackPoints(i,:) = handles.pointData{i,4}(end,:);
                end
                initialize(handles.pointTracker,handles.trackPoints,handles.currIMG);
            end
            
            %plot points
            if handles.isStoredVid == 0 || handles.isStill == 1
                ct=0;
                clear x y;
                for i = 1:length(handles.trackPoints(:,1))
                    if strcmp(handles.pointData{i,3},'l') == 1
                        ct=ct+1;
                        x(ct) = handles.trackPoints(i,1);
                        y(ct) = handles.trackPoints(i,2);
                        sz(ct) = handles.PointSize;
                    end
                end
                handles.currIMG = insertShape(handles.currIMG,'circle',[x' y' sz'],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                imshow(handles.currIMG,'Parent',handles.axesCamera1);
            else
                ct=0;
                clear x y;
                for i = 1:length(handles.trackPoints(:,1))
                    if strcmp(handles.pointData{i,3},'l') == 1
                        ct=ct+1;
                        x(ct) = handles.trackPoints(i,1);
                        y(ct) = handles.trackPoints(i,2);
                        sz(ct) = handles.PointSize;
                    end
                end
                img{handles.ct} = insertShape(img{handles.ct},'circle',[x' y' sz'],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                imshow(img{handles.ct},'Parent',handles.axesCamera1);
            end
            %plot lines
            for i = 1:2:length(x)
                if handles.isStoredVid == 0 || handles.isStill == 1
                    handles.currIMG = insertShape(handles.currIMG,'line',[x(i) y(i) x(i+1) y(i+1)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                    imshow(handles.currIMG,'Parent',handles.axesCamera1);
                else
                    img{handles.ct} = insertShape(img{handles.ct},'line',[x(i) y(i) x(i+1) y(i+1)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                    imshow(img{handles.ct},'Parent',handles.axesCamera1);
                end
            end
            
            handles.pointTrackerisInitialized = 1;
            guidata(hObject, handles);
            
        case '2-Point Angle'
            [x y] = getpts(handles.axesCamera1);
            [a b c] = size(img{round(handles.ct)});
            y = y;%correct for top/bottom flip
            for i = 1:length(x)
                if length(handles.pointData) == 0
                    handles.pointData{1,1} = handles.ct;
                    handles.pointData{1,2} = handles.ct/handles.vidInfo.FrameRate;
                    handles.pointData{1,3} = '2a';
                    handles.pointData{1,4} = [x(i) y(i)];
                    handles.pointData{1,5} = [NaN NaN];
                    handles.pointData{1,6} = [NaN NaN];
                    handles.pointData{1,7} = [NaN NaN];
                    handles.pointData{1,8} = 0;
                    handles.pointData{1,9} = 0;
                    handles.pointData{1,10} = 0;
                else
                    row = length(handles.pointData(:,1));
                    handles.pointData{row+1,1} = handles.ct;%frame added
                    handles.pointData{row+1,2} = handles.ct/handles.vidInfo.FrameRate;%time added
                    handles.pointData{row+1,3} = '2a';%point type
                    handles.pointData{row+1,4} = [x(i) y(i)];%point position
                    handles.pointData{row+1,5} = [NaN NaN];%point velocity
                    handles.pointData{row+1,6} = [NaN NaN];%point acceleration
                    handles.pointData{row+1,7} = [NaN NaN];%initial trail point
                    handles.pointData{row+1,8} = 0;%angle
                    handles.pointData{row+1,9} = 0;%angular velocity
                    handles.pointData{row+1,10} = 0;%angular acceleration
                end
            end
            
            %re-initialize tracker due to added points
            %re-initialize tracker due to added points
            release(handles.pointTracker);
            handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
            try
                %create handles.trackPoints with last position of each
                %point
                for i = 1:length(handles.pointData(:,1))
                    handles.trackPoints(i,:) = handles.pointData{i,4}(end,:);
                end
                initialize(handles.pointTracker,handles.trackPoints,img{handles.ct});
            catch
                for i = 1:length(handles.pointData(:,1))
                    handles.trackPoints(i,:) = handles.pointData{i,4}(end,:);
                end
                initialize(handles.pointTracker,handles.trackPoints,handles.currIMG);
            end
            
            %plot points
            if handles.isStoredVid == 0 || handles.isStill == 1
                ct=0;
                clear x y;
                for i = 1:length(handles.trackPoints(:,1))
                    if strcmp(handles.pointData{i,3},'2a') == 1
                        ct=ct+1;
                        x(ct) = handles.trackPoints(i,1);
                        y(ct) = handles.trackPoints(i,2);
                        sz(ct) = handles.PointSize;
                    end
                end
                handles.currIMG = insertShape(handles.currIMG,'circle',[x' y' sz'],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                imshow(handles.currIMG,'Parent',handles.axesCamera1);
            else
                ct=0;
                clear x y;
                for i = 1:length(handles.trackPoints(:,1))
                    if strcmp(handles.pointData{i,3},'2a') == 1
                        ct=ct+1;
                        x(ct) = handles.trackPoints(i,1);
                        y(ct) = handles.trackPoints(i,2);
                        sz(ct) = handles.PointSize;
                    end
                end
                img{handles.ct} = insertShape(img{handles.ct},'circle',[x' y' sz'],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                imshow(img{handles.ct},'Parent',handles.axesCamera1);
            end
            %plot lines
            for i = 1:2:length(x)
                if handles.isStoredVid == 0 || handles.isStill == 1
                    handles.currIMG = insertShape(handles.currIMG,'line',[x(i) y(i) x(i+1) y(i+1)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                    imshow(handles.currIMG,'Parent',handles.axesCamera1);
                else
                    img{handles.ct} = insertShape(img{handles.ct},'line',[x(i) y(i) x(i+1) y(i+1)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                    imshow(img{handles.ct},'Parent',handles.axesCamera1);
                end
            end
            
            %calculate angle
            x = x(end-1:end);
            y = y(end-1:end);
            angle = atan((y(2)-y(1))/(x(2)-x(1)));
            if angle < 0
                angle = angle + pi;
            end
            angle = rad2deg(angle);
            %assign angle and initialize angular velocity
            handles.pointData{end-1,8} = angle;
            handles.pointData{end-1,9} = 0;
            handles.pointData{end-1,10} = 0;
            handles.pointData{end,8} = angle;
            handles.pointData{end,9} = 0;
            handles.pointData{end,10} = 0;
            
            if handles.isStoredVid == 0 || handles.isStill == 1
                handles.currIMG = insertText(handles.currIMG,[x(1)+10,y(1)+10],num2str(angle),'FontSize',handles.TextSize,...
                    'TextColor',handles.TextColor);
                imshow(handles.currIMG,'Parent',handles.axesCamera1);
            else
                img{handles.ct} = insertText(img{handles.ct},[x(1)+10,y(1)+10],num2str(angle),...
                    'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                imshow(img{handles.ct},'Parent',handles.axesCamera1);
            end
            handles.pointTrackerisInitialized = 1;
            guidata(hObject, handles);
            
        case '3-Point Angle'
            [x y] = getpts(handles.axesCamera1);
            if length(x) ~= 3
                msgbox('Pick 3 points for a 3 point angle!');
                return
            end
            [a b c] = size(img{round(handles.ct)});
            y = y;%correct for top/bottom flip
            for i = 1:length(x)
                if length(handles.pointData) == 0
                    handles.pointData{1,1} = handles.ct;
                    handles.pointData{1,2} = handles.ct/handles.vidInfo.FrameRate;
                    handles.pointData{1,3} = '3a';
                    handles.pointData{1,4} = [x(i) y(i)];
                    handles.pointData{1,5} = [NaN NaN];
                    handles.pointData{1,6} = [NaN NaN];
                    handles.pointData{1,7} = [x(i) y(i)];
                    handles.pointData{1,8} = 0;
                    handles.pointData{1,9} = 0;
                    handles.pointData{1,10} = 0;
                else
                    row = length(handles.pointData(:,1));
                    handles.pointData{row+1,1} = handles.ct;%frame added
                    handles.pointData{row+1,2} = handles.ct/handles.vidInfo.FrameRate;%time added
                    handles.pointData{row+1,3} = '3a';%point type
                    handles.pointData{row+1,4} = [x(i) y(i)];%point position
                    handles.pointData{row+1,5} = [NaN NaN];%point velocity
                    handles.pointData{row+1,6} = [NaN NaN];%point acceleration
                    handles.pointData{row+1,7} = [x(i) y(i)];%initial trail point
                    handles.pointData{row+1,8} = 0;%angle
                    handles.pointData{row+1,9} = 0;%angular velocity
                    handles.pointData{row+1,10} = 0;%angular acceleration
                end
            end
            
            %re-initialize tracker due to added points
            release(handles.pointTracker);
            handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
            try
                %create handles.trackPoints with last position of each
                %point
                for i = 1:length(handles.pointData(:,1))
                    handles.trackPoints(i,:) = handles.pointData{i,4}(end,:);
                end
                initialize(handles.pointTracker,handles.trackPoints,img{handles.ct});
            catch
                for i = 1:length(handles.pointData(:,1))
                    handles.trackPoints(i,:) = handles.pointData{i,4}(end,:);
                end
                initialize(handles.pointTracker,handles.trackPoints,handles.currIMG);
            end
            
            %plot points
            if handles.isStoredVid == 0 || handles.isStill == 1
                ct=0;
                clear x y;
                for i = 1:length(handles.trackPoints(:,1))
                    if strcmp(handles.pointData{i,3},'3a') == 1
                        ct=ct+1;
                        x(ct) = handles.trackPoints(i,1);
                        y(ct) = handles.trackPoints(i,2);
                        sz(ct) = handles.PointSize;
                    end
                end
                handles.currIMG = insertShape(handles.currIMG,'circle',[x' y' sz'],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                imshow(handles.currIMG,'Parent',handles.axesCamera1);
            else
                ct=0;
                clear x y;
                for i = 1:length(handles.trackPoints(:,1))
                    if strcmp(handles.pointData{i,3},'3a') == 1
                        ct=ct+1;
                        x(ct) = handles.trackPoints(i,1);
                        y(ct) = handles.trackPoints(i,2);
                        sz(ct) = handles.PointSize;
                    end
                end
                img{handles.ct} = insertShape(img{handles.ct},'circle',[x' y' sz'],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                imshow(img{handles.ct},'Parent',handles.axesCamera1);
            end
            x = x(end-2:end);
            y = y(end-2:end);
            %plot lines
            if handles.isStoredVid == 0 || handles.isStill == 1
                handles.currIMG = insertShape(handles.currIMG,'line',[x(1) y(1) x(1+1) y(1+1)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                handles.currIMG = insertShape(handles.currIMG,'line',[x(1) y(1) x(1+2) y(1+2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                imshow(handles.currIMG,'Parent',handles.axesCamera1);
            else
                img{handles.ct} = insertShape(img{handles.ct},'line',[x(1) y(1) x(1+1) y(1+1)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                img{handles.ct} = insertShape(img{handles.ct},'line',[x(1) y(1) x(1+2) y(1+2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                imshow(img{handles.ct},'Parent',handles.axesCamera1);
            end
            
            %calculate angle
            P0 = [x(1) y(1)];
            P1 = [x(2) y(2)];
            P2 = [x(3) y(3)];
            angle = atan2(abs(det([P2-P0;P1-P0])),dot(P2-P0,P1-P0));
            if angle < 0
                angle = angle + pi;
            end
            angle = rad2deg(angle);
            handles.pointData{end-2,8} = angle;
            handles.pointData{end-1,8} = angle;
            handles.pointData{end,8} = angle;
            handles.pointData{end-2,9} = 0;
            handles.pointData{end-1,9} = 0;
            handles.pointData{end,9} = 0;
            handles.pointData{end-2,10} = 0;
            handles.pointData{end-1,10} = 0;
            handles.pointData{end,10} = 0;
            
            if handles.isStoredVid == 0 || handles.isStill == 1
                handles.currIMG = insertText(handles.currIMG,[x(1)+10,y(1)+10],num2str(angle),...
                    'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                imshow(handles.currIMG,'Parent',handles.axesCamera1);
            else
                img{handles.ct} = insertText(img{handles.ct},[x(1)+10,y(1)+10],num2str(angle),...
                    'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                imshow(img{handles.ct},'Parent',handles.axesCamera1);
            end
            
            handles.pointTrackerisInitialized = 1;
            guidata(hObject, handles);
            
        case '4-Point Angle'
            [x y] = getpts(handles.axesCamera1);
            [a b c] = size(img{round(handles.ct)});
            y = y;%correct for top/bottom flip
            for i = 1:length(x)
                if length(handles.pointData) == 0
                    handles.pointData{1,1} = handles.ct;
                    handles.pointData{1,2} = handles.ct/handles.vidInfo.FrameRate;
                    handles.pointData{1,3} = '4a';
                    handles.pointData{1,4} = [x(i) y(i)];
                    handles.pointData{1,5} = [NaN NaN];
                    handles.pointData{1,6} = [NaN NaN];
                    handles.pointData{1,7} = [x(i) y(i)];
                    handles.pointData{1,8} = 0;
                    handles.pointData{1,9} = 0;
                    handles.pointData{1,10} = 0;
                else
                    row = length(handles.pointData(:,1));
                    handles.pointData{row+1,1} = handles.ct;%frame added
                    handles.pointData{row+1,2} = handles.ct/handles.vidInfo.FrameRate;%time added
                    handles.pointData{row+1,3} = '4a';%point type
                    handles.pointData{row+1,4} = [x(i) y(i)];%point position
                    handles.pointData{row+1,5} = [NaN NaN];%point velocity
                    handles.pointData{row+1,6} = [NaN NaN];%point acceleration
                    handles.pointData{row+1,7} = [x(i) y(i)];%initial trail point
                    handles.pointData{row+1,8} = 0;%angle
                    handles.pointData{row+1,9} = 0;%angular velocity
                    handles.pointData{row+1,10} = 0;%angular acceleration
                end
            end
            
            %re-initialize tracker due to added points
            release(handles.pointTracker);
            handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
            try
                %create handles.trackPoints with last position of each
                %point
                for i = 1:length(handles.pointData(:,1))
                    handles.trackPoints(i,:) = handles.pointData{i,4}(end,:);
                end
                initialize(handles.pointTracker,handles.trackPoints,img{handles.ct});
            catch
				for i = 1:length(handles.pointData(:,1))
                    handles.trackPoints(i,:) = handles.pointData{i,4}(end,:);
                end
                initialize(handles.pointTracker,handles.trackPoints,handles.currIMG);
            end
            
            %plot points and line
            %         str = get(handles.popupmenuSetPointColor,'String');
            %         val = get(handles.popupmenuSetPointColor,'Value');
            %         color = str(val);
            if handles.isStoredVid == 0 || handles.isStill == 1
                for i = 1:length(x)
                    handles.currIMG = insertShape(handles.currIMG,'circle',[x(i) y(i) handles.PointSize],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                end
            else
                for i = 1:length(x)
                    img{handles.ct} = insertShape(img{handles.ct},'circle',[x(i) y(i) handles.PointSize],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                end
            end
            %         str = get(handles.popupmenuSetLineColor,'String');
            %         val = get(handles.popupmenuSetLineColor,'Value');
            %         color = str(val);
            if handles.isStoredVid == 0 || handles.isStill == 1
                handles.currIMG = insertShape(handles.currIMG,'line',[x(1) y(1) x(2) y(2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                handles.currIMG = insertShape(handles.currIMG,'line',[x(3) y(3) x(4) y(4)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
            else
                img{handles.ct} = insertShape(img{handles.ct},'line',[x(1) y(1) x(2) y(2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                img{handles.ct} = insertShape(img{handles.ct},'line',[x(3) y(3) x(4) y(4)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
            end
            
            %calculate angle
            P0 = [x(1) y(1)];
            P1 = [x(2) y(2)];
            P2 = [x(3) y(3)];
            P3 = [x(4) y(4)];
            v1 = P1 - P0;
            v2 = P3 - P2;
            a1 = mod(atan2( det([v1;v2;]) , dot(v1,v2) ), 2*pi );
            angle = (a1>pi/2)*pi-a1;
            if angle < 0
                angle = angle + pi;
            end
            angle = rad2deg(angle);
            handles.pointData{end-3,8} = angle;
            handles.pointData{end-3,9} = 0;
            handles.pointData{end-3,10} = 0;
            handles.pointData{end-2,8} = angle;
            handles.pointData{end-2,9} = 0;
            handles.pointData{end-2,10} = 0;
            handles.pointData{end-1,8} = angle;
            handles.pointData{end-1,9} = 0;
            handles.pointData{end-1,10} = 0;
            handles.pointData{end,8} = angle;
            handles.pointData{end,9} = 0;
            handles.pointData{end,10} = 0;
            
            if handles.isStoredVid == 0 || handles.isStill == 1
                handles.currIMG = insertText(handles.currIMG,[x(1)+10,y(1)+10],num2str(angle),...
                    'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                imshow(handles.currIMG,'Parent',handles.axesCamera1);
            else
                img{handles.ct} = insertText(img{handles.ct},[x(1)+10,y(1)+10],num2str(angle),...
                    'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                imshow(img{handles.ct},'Parent',handles.axesCamera1);
            end
            
            handles.pointTrackerisInitialized = 1;
            guidata(hObject, handles);
            
    end
end

% --- Executes on selection change in popupmenuFeature.
function popupmenuFeature_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuFeature contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuFeature


% --- Executes during object creation, after setting all properties.
function popupmenuFeature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editTrailingPoints_Callback(hObject, eventdata, handles)
% hObject    handle to editTrailingPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTrailingPoints as text
%        str2double(get(hObject,'String')) returns contents of editTrailingPoints as a double


% --- Executes during object creation, after setting all properties.
function editTrailingPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTrailingPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSetPointAttr.
function pushbuttonSetPointAttr_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetPointAttr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenuSetPointColor.
function popupmenuSetPointColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSetPointColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSetPointColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSetPointColor


% --- Executes during object creation, after setting all properties.
function popupmenuSetPointColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSetPointColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbuttonSetLineAttr.
function pushbuttonSetLineAttr_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetLineAttr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenuSetLineColor.
function popupmenuSetLineColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSetLineColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSetLineColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSetLineColor

function editIPAddress_Callback(hObject, eventdata, handles)
% hObject    handle to editIPAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIPAddress as text
%        str2double(get(hObject,'String')) returns contents of editIPAddress as a double


% --- Executes during object creation, after setting all properties.
function editIPAddress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIPAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function popupmenuSetLineColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSetLineColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSetTrailingPointAttr.
function pushbuttonSetTrailingPointAttr_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetTrailingPointAttr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenuSetTrailingPointColor.
function popupmenuSetTrailingPointColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSetTrailingPointColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSetTrailingPointColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSetTrailingPointColor


% --- Executes during object creation, after setting all properties.
function popupmenuSetTrailingPointColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSetTrailingPointColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonLoadVideo.
function pushbuttonLoadVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;
global audio;
global audioFrequency;
global frequency;
img = cell(0);
clear handles.vidTimes;

[handles.vidStr handles.pathstr] = uigetfile(fullfile(handles.pathstr, '*.*'),'Please select the video file of interest');
set(handles.textMovieFolder,'String',fullfile(handles.pathstr,handles.vidStr));


release(handles.pointTracker);
handles.trackPoints = [];
handles.v = VideoReader(fullfile(handles.pathstr,handles.vidStr));
handles.vidInfo = get(handles.v);
handles.isStill = 0;

try
    [audio,audioFrequency] = audioread(fullfile(handles.pathstr,handles.vidStr));
    answer = inputdlg('Would you like to maintain the original audio? y or n');
catch
    %     msgbox('Unable to load audio; no audio or format unrecognized');
    answer{1} = 'n';%inputdlg('Would you like to maintain the original audio? y or n');
end

if strcmpi(answer{1},'y') == 1
    audFlag = 1;
elseif strcmpi(answer{1},'n') == 1
    audFlag = 0;
else
    answer = inputdlg('Type y or n! Would you like to maintain the original audio? y or n');
    if strcmpi(answer{1},'y') == 1
        audFlag = 1;
    elseif strcmpi(answer{1},'n') == 1
        audFlag = 0;
    end
end
if audFlag == 1
    try
        [audio,audioFrequency] = audioread(fullfile(handles.pathstr,handles.vidStr));
    catch
        msgbox('Unable to load audio; no audio or format unrecognized');
    end
end

handles.pointTrackerisInitialized = 0;
ct=0;
clear handles.vidTimes;
% img = cell(0);
set(handles.togglebuttonStream,'BackgroundColor','g');
set(handles.togglebuttonStream,'Value',0);
set(handles.togglebuttonRecordAudioOverMovie,'BackgroundColor','g');
set(handles.togglebuttonRecordAudioOverMovie,'Value',0);
frequency = 1/handles.v.FrameRate;
while hasFrame(handles.v)
    ct=ct+1;
    img{ct} = readFrame(handles.v,'native');
    set(handles.editFrame,'String',num2str(ct));
    drawnow();
end
for i = 1:ct
    if i == 1
        handles.vidTimes(i) = 0;
    else
        handles.vidTimes(i) = handles.vidTimes(i-1) + (1/handles.vidInfo.FrameRate);
    end
end

%set point sizes and weights and things to be reasonable with video
%dimensions

[a b c] = size(img{1});
ptRatio = ceil(a * 0.01);
tptRatio = ceil(a * 0.003);
ptwtRatio = ceil(a * 0.006);
tptwtRatio = ceil(a * 0.003);
lnRatio = ceil(a * 0.005);
txtRatio = ceil(a * 0.02);

handles.PointSize = ptRatio;
handles.TrailingPointSize = tptRatio;
handles.PointWeight = ptwtRatio;
handles.TrailingPointWeight = tptwtRatio;
handles.LineWeight = lnRatio;
handles.TextSize = txtRatio;
handles.SearchRadius = ceil(a/85);
if mod(handles.SearchRadius,2) == 0
    handles.SearchRadius = handles.SearchRadius + 1;
end
handles.PointColor = 'r';
handles.TrailingPointColor = 'g';
handles.LineColor = 'c';
handles.TextColor = 'black';
handles.TextWeight = 6;
handles.TrailingPointNumber = 30;

set(handles.sliderLoadedVideo,'Value',1);
set(handles.sliderLoadedVideo,'min',1);
set(handles.sliderLoadedVideo,'max',ct);
set(handles.sliderLoadedVideo,'SliderStep',[1/(length(img)-1),0.1]);
set(handles.editFrame,'String','1');
drawnow();
imshow(img{1},'Parent',handles.axesCamera1);

handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);

handles.isStoredVid = 1;
guidata(hObject, handles);


% --- Executes on slider movement.
function sliderLoadedVideo_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLoadedVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global img;

handles.ct = round(get(handles.sliderLoadedVideo,'Value'));
set(handles.editFrame,'String',num2str(handles.ct));
imshow(img{handles.ct},'Parent',handles.axesCamera1);

% if ~isempty(get(handles.axesGraph,'Children'))
%     ax = handles.axesGraph;
%     yLim = ax.YLim;
%     hold('on',handles.axesGraph);
%     set(handles.hLine,'XData',[handles.vidTimes(handles.ct) handles.vidTimes(handles.ct)],'YData',yLim,'Color','r');
%     hold('off',handles.axesGraph);
%     drawnow();
% end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderLoadedVideo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLoadedVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function editRotateDegrees_Callback(hObject, eventdata, handles)
% hObject    handle to editRotateDegrees (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRotateDegrees as text
%        str2double(get(hObject,'String')) returns contents of editRotateDegrees as a double


% --- Executes during object creation, after setting all properties.
function editRotateDegrees_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRotateDegrees (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in popupmenuAvailableResolutions.
function popupmenuAvailableResolutions_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuAvailableResolutions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuAvailableResolutions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuAvailableResolutions


% --- Executes during object creation, after setting all properties.
function popupmenuAvailableResolutions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuAvailableResolutions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSetResolution.
function pushbuttonSetResolution_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetResolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(handles.popupmenuAvailableResolutions,'String');
val = get(handles.popupmenuAvailableResolutions,'Value');
handles.cam.Resolution = str{val};
guidata(hObject, handles);


% --- Executes on button press in pushbuttonClearAll.
function pushbuttonClearAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;

handles.trackPoints = [];
handles.pointData = cell(0);

if handles.isStoredVid == 1
    handles.v = VideoReader(fullfile(handles.pathstr,handles.vidStr));
    handles.vidInfo = get(handles.v);
    img = cell(0);
    ct=0;
    while hasFrame(handles.v)
        ct=ct+1;
        img{ct} = readFrame(handles.v);
        set(handles.editFrame,'String',num2str(ct));
        drawnow();
    end
elseif handles.isStoredVid == 0
    handles.realTimeClickIndicator = 0;
    set(handles.togglebuttonStream,'String','Paused');
    guidata(hObject, handles);
    set(handles.togglebuttonStream,'Value',0);
    set(handles.togglebuttonStream,'Value',0);
    set(handles.togglebuttonStream,'Value',0);
end

handles.pointTrackerisInitialized = 0;
clear handles.vidTimes;

set(handles.togglebuttonStream,'BackgroundColor','g');
set(handles.togglebuttonStream,'Value',0);

try
    for i = 1:length(img)
        if i == 1
            handles.vidTimes(i) = 0;
        else
            handles.vidTimes(i) = handles.vidTimes(i-1) + (1/handles.vidInfo.FrameRate);
        end
    end
catch
end
release(handles.pointTracker);
handles.pointTrackerisInitialized = 0;
handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
try
    if handles.isStoredVid == 0
        imshow(snapshot(handles.cam));
    else
        handles.time = [];
        handles.ct = 1;
        set(handles.sliderLoadedVideo,'Value',1);
        set(handles.sliderLoadedVideo,'min',1);
        set(handles.sliderLoadedVideo,'max',length(img));
        set(handles.sliderLoadedVideo,'SliderStep',[1/(length(img)-1),0.1]);
        set(handles.editFrame,'String','1');
        drawnow();
        imshow(img{get(handles.sliderLoadedVideo,'Value')},'Parent',handles.axesCamera1);
    end
catch
    try
        handles.currIMG = handles.currIMGOrig;
    catch
    end
    imshow(handles.currIMG,'Parent',handles.axesCamera1);
    
end
guidata(hObject, handles);

function [handles] = processFrame(handles,eventdata,hObject)
%%contains logic for processing and drawing on image

global img;
global PointSize;
global TrailingPointSize;
global PointWeight;
global TrailingPointWeight;
global LineWeight;
global TextSize;
global SearchRadius;
global PointColor;
global TrailingPointColor;
global LineColor;
global TextColor;
global TextWeight;
global TrailingPointNumber;
if handles.ct < length(img) && ~isempty(handles.trackPoints)
    
    [handles.trackPoints validity scores] = step(handles.pointTracker,img{handles.ct+1});
    for i = 1:length(validity)
        if validity(i) == 1
            str{i} = ['Point ' num2str(i) ' is valid'];
        elseif validity(i) == 0
            str{i} = ['Point ' num2str(i) ' is not valid'];
        end
    end
    if isfield(handles,'hValidBox')
        if isvalid(handles.hValidBox)
            set(findobj(handles.hValidBox,'Tag','MessageBox'),'String',str);
        else
            handles.hValidBox = msgbox(str,'Name','hValidBox');
        end
    else
        handles.hValidBox = msgbox(str,'Name','hValidBox');
    end
    [a b c] = size(img{handles.ct+1});
    i=1;
    while i <= length(handles.trackPoints(:,1))
        if strcmp(handles.pointData{i,3},'p') == 1
            handles.pointData{i,4}(end+1,:) = handles.trackPoints(i,:);
            handles.pointData{i,7}(end+1,:) = handles.trackPoints(i,:);
            if length(handles.pointData{i,4}(:,1)) > 1
                handles.pointData{i,5}(end,:) = handles.pointData{i,4}(end,:) - handles.pointData{i,4}(end-1,:);
                if length(handles.pointData{i,5}(:,1)) > 2
                    handles.pointData{i,6}(end,:) = handles.pointData{i,5}(end,:) - handles.pointData{i,5}(end-1,:);
                end
            end
            img{handles.ct+1} = insertShape(img{handles.ct+1},'circle',[handles.pointData{i,4}(end,:) handles.PointSize],'LineWidth',handles.PointWeight,'Color',handles.PointColor);
            trailLen = length(handles.pointData{i,7}(:,1));
            for j = 1:trailLen-1
                if j < handles.TrailingPointNumber
                    ptPlot = zeros(j,3);
                    if j == 1
                        ptPlot = [handles.pointData{i,7}(end-j,:) handles.TrailingPointSize];
                    else
                        ptPlot = [ptPlot;[handles.pointData{i,7}(end-j,:) handles.TrailingPointSize]];
                    end
                end
                img{handles.ct+1} = insertShape(img{handles.ct+1},'circle',ptPlot,'LineWidth',handles.TrailingPointWeight,'Color',handles.TrailingPointColor);
            end
            i = i+1;
        end
        if i <= length(handles.trackPoints(:,1))
            if strcmp(handles.pointData{i,3},'l') == 1  
                handles.pointData{i,4}(end+1,:) = handles.trackPoints(i,:);
                handles.pointData{i+1,4}(end+1,:) = handles.trackPoints(i+1,:);
                ptPlot = [[handles.pointData{i,4}(end,:); handles.pointData{i+1,4}(end,:)] [handles.PointSize handles.PointSize]'];
                img{handles.ct+1} = insertShape(img{handles.ct+1},'circle',ptPlot,'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                img{handles.ct+1} = insertShape(img{handles.ct+1},'line',[ptPlot(1,1) ptPlot(1,2) ptPlot(2,1) ptPlot(2,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                imshow(img{handles.ct},'Parent',handles.axesCamera1);
                i = i+2;
            end
        end
        if i <= length(handles.trackPoints(:,1))
            if strcmp(handles.pointData{i,3},'2a') == 1 
                handles.pointData{i,4}(end+1,:) = handles.trackPoints(i,:);
                handles.pointData{i+1,4}(end+1,:) = handles.trackPoints(i+1,:);
                ptPlot = [[handles.pointData{i,4}(end,:); handles.pointData{i+1,4}(end,:)] [handles.PointSize handles.PointSize]'];
                img{handles.ct+1} = insertShape(img{handles.ct+1},'circle',ptPlot,'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                img{handles.ct+1} = insertShape(img{handles.ct+1},'line',[ptPlot(1,1) ptPlot(1,2) ptPlot(2,1) ptPlot(2,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                angle = atan((ptPlot(2,2)-ptPlot(1,2))/(ptPlot(2,1)-ptPlot(1,1)));
                if angle < 0
                    angle = angle + pi;
                end
                angle = rad2deg(angle);
                handles.pointData{i,8}(end+1) = angle;
                handles.pointData{i+1,8}(end+1) = angle;
                if length(handles.pointData{i,8}) > 1
                    handles.pointData{i,9}(end+1) = handles.pointData{i,8}(end) - handles.pointData{i,8}(end-1);
                    handles.pointData{i+1,9}(end+1) = handles.pointData{i,8}(end) - handles.pointData{i,8}(end-1);
                    if length(handles.pointData{i,9}) > 1
                        handles.pointData{i,10}(end+1) = handles.pointData{i,9}(end) - handles.pointData{i,9}(end-1);
                        handles.pointData{i+1,10}(end+1) = handles.pointData{i,9}(end) - handles.pointData{i,9}(end-1);
                    end
                end
                img{handles.ct+1} = insertText(img{handles.ct+1},[ptPlot(1,1)+10,ptPlot(1,2)+10],num2str(angle),'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                imshow(img{handles.ct+1},'Parent',handles.axesCamera1);
                i = i+2;
            end
        end
        if i <= length(handles.trackPoints(:,1))
            if strcmp(handles.pointData{i,3},'3a') == 1 
                handles.pointData{i,4}(end+1,:) = handles.trackPoints(i,:);
                handles.pointData{i+1,4}(end+1,:) = handles.trackPoints(i+1,:);
                handles.pointData{i+2,4}(end+1,:) = handles.trackPoints(i+2,:);
                ptPlot = [[handles.pointData{i,4}(end,:); handles.pointData{i+1,4}(end,:); handles.pointData{i+2,4}(end,:)] [handles.PointSize handles.PointSize handles.PointSize]'];
                img{handles.ct+1} = insertShape(img{handles.ct+1},'circle',ptPlot,'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                img{handles.ct+1} = insertShape(img{handles.ct+1},'line',[ptPlot(1,1) ptPlot(1,2) ptPlot(2,1) ptPlot(2,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                img{handles.ct+1} = insertShape(img{handles.ct+1},'line',[ptPlot(1,1) ptPlot(1,2) ptPlot(3,1) ptPlot(3,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                P0 = [ptPlot(1,1) ptPlot(1,2)];
                P1 = [ptPlot(2,1) ptPlot(2,2)];
                P2 = [ptPlot(3,1) ptPlot(3,2)];
                angle = atan2(abs(det([P2-P0;P1-P0])),dot(P2-P0,P1-P0));
                if angle < 0
                    angle = angle + pi;
                end
                angle = rad2deg(angle);
                handles.pointData{i,8}(end+1) = angle;
                handles.pointData{i+1,8}(end+1) = angle;
                handles.pointData{i+2,8}(end+1) = angle;
                if length(handles.pointData{i,8}) > 1
                    handles.pointData{i,9}(end+1) = handles.pointData{i,8}(end) - handles.pointData{i,8}(end-1);
                    handles.pointData{i+1,9}(end+1) = handles.pointData{i,8}(end) - handles.pointData{i,8}(end-1);
                    handles.pointData{i+2,9}(end+1) = handles.pointData{i,8}(end) - handles.pointData{i,8}(end-1);
                    if length(handles.pointData{i,9}) > 1
                        handles.pointData{i,10}(end+1) = handles.pointData{i,9}(end) - handles.pointData{i,9}(end-1);
                        handles.pointData{i+1,10}(end+1) = handles.pointData{i,9}(end) - handles.pointData{i,9}(end-1);
                        handles.pointData{i+2,10}(end+1) = handles.pointData{i,9}(end) - handles.pointData{i,9}(end-1);
                    end
                end
                img{handles.ct+1} = insertText(img{handles.ct+1},[ptPlot(1,1)+10,ptPlot(1,2)+10],num2str(angle),'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                imshow(img{handles.ct+1},'Parent',handles.axesCamera1);
                i = i+3;
            end
        end
        if i <= length(handles.trackPoints(:,1))
            if strcmp(handles.pointData{i,3},'4a') == 1 
                handles.pointData{i,4}(end+1,:) = handles.trackPoints(i,:);
                handles.pointData{i+1,4}(end+1,:) = handles.trackPoints(i+1,:);
                handles.pointData{i+2,4}(end+1,:) = handles.trackPoints(i+2,:);
                handles.pointData{i+3,4}(end+1,:) = handles.trackPoints(i+3,:);
                ptPlot = [[handles.pointData{i,4}(end,:); handles.pointData{i+1,4}(end,:); handles.pointData{i+2,4}(end,:); handles.pointData{i+3,4}(end,:)] [handles.PointSize handles.PointSize handles.PointSize handles.PointSize]'];
                img{handles.ct+1} = insertShape(img{handles.ct+1},'circle',ptPlot,'LineWidth',handles.PointWeight,'Color',handles.PointColor);
                img{handles.ct+1} = insertShape(img{handles.ct+1},'line',[ptPlot(1,1) ptPlot(1,2) ptPlot(2,1) ptPlot(2,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                img{handles.ct+1} = insertShape(img{handles.ct+1},'line',[ptPlot(3,1) ptPlot(3,2) ptPlot(4,1) ptPlot(4,2)],'LineWidth',handles.LineWeight,'Color',handles.LineColor);
                P0 = [ptPlot(1,1) ptPlot(1,2)];
                P1 = [ptPlot(2,1) ptPlot(2,2)];
                P2 = [ptPlot(3,1) ptPlot(3,2)];
                P3 = [ptPlot(4,1) ptPlot(4,2)];
                v1 = P1 - P0;
                v2 = P3 - P2;
                a1 = mod(atan2( det([v1;v2;]) , dot(v1,v2) ), 2*pi );
                angle = (a1>pi/2)*pi-a1;
                if angle < 0
                    angle = angle + pi;
                end
                angle = rad2deg(angle);
                handles.pointData{i,8}(end+1) = angle;
                handles.pointData{i+1,8}(end+1) = angle;
                handles.pointData{i+2,8}(end+1) = angle;
                handles.pointData{i+3,8}(end+1) = angle;
                if length(handles.pointData{i,8}) > 1
                    handles.pointData{i,9}(end+1) = handles.pointData{i,8}(end) - handles.pointData{i,8}(end-1);
                    handles.pointData{i+1,9}(end+1) = handles.pointData{i,8}(end) - handles.pointData{i,8}(end-1);
                    handles.pointData{i+2,9}(end+1) = handles.pointData{i,8}(end) - handles.pointData{i,8}(end-1);
                    handles.pointData{i+3,9}(end+1) = handles.pointData{i,8}(end) - handles.pointData{i,8}(end-1);
                    if length(handles.pointData{i,9}) > 1
                        handles.pointData{i,10}(end+1) = handles.pointData{i,9}(end) - handles.pointData{i,9}(end-1);
                        handles.pointData{i+1,10}(end+1) = handles.pointData{i,9}(end) - handles.pointData{i,9}(end-1);
                        handles.pointData{i+2,10}(end+1) = handles.pointData{i,9}(end) - handles.pointData{i,9}(end-1);
                        handles.pointData{i+3,10}(end+1) = handles.pointData{i,9}(end) - handles.pointData{i,9}(end-1);
                    end
                end
                img{handles.ct+1} = insertText(img{handles.ct+1},[ptPlot(1,1)+10,ptPlot(1,2)+10],num2str(angle),'FontSize',handles.TextSize,'TextColor',handles.TextColor);
                imshow(img{handles.ct+1},'Parent',handles.axesCamera1);
                i = i+4;
            end
        end
        
    end
    
end

guidata(hObject, handles);

% --- Executes on button press in pushbuttonGrabKeyFrame.
function pushbuttonGrabKeyFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonGrabKeyFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currIMG = getimage(handles.axesCamera1);
handles.isStill = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbuttonSaveKeyFrame.
function pushbuttonSaveKeyFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveKeyFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currIMG = getimage(handles.axesCamera1);
ispc = computer;
if strcmp(ispc,'PCWIN64') == 1
    pth = getenv('USERPROFILE');
    pth = [pth '\Documents'];
    sysLine = [' md ' pth '\MovementScience'];
    system(sysLine);
    pth = [pth '\MovementScience'];
end
if strcmp(ispc,'MACI64')
    pth = getenv('USER');
    pth = ['/Users/' pth '/Documents'];
    sysLine = ['mkdir ' pth '/MovementScience'];
    system(sysLine);
    pth = [pth '/MovementScience'];
end

fName = fullfile(pth,[get(handles.editImageName,'String') '.png']);
if exist(fName,'file') == 2
    fName = [datestr(now) fName];
end
imwrite(handles.currIMG,fName);


function editImageName_Callback(hObject, eventdata, handles)
% hObject    handle to editImageName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editImageName as text
%        str2double(get(hObject,'String')) returns contents of editImageName as a double


% --- Executes during object creation, after setting all properties.
function editImageName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editImageName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenuAnnotations.
function popupmenuAnnotations_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuAnnotations contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuAnnotations


% --- Executes during object creation, after setting all properties.
function popupmenuAnnotations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonDrawScribble.
function pushbuttonDrawScribble_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDrawScribble (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;

val = get(handles.togglebuttonIMGOrVid,'Value');
if val == 1
    [handles.currIMG] = drawScribbleGUI(handles.axesCamera1,handles,eventdata,hObject);
    imshow(handles.currIMG,'Parent',handles.axesCamera1);
    drawnow();
else
    [handles.currIMG] = drawScribbleGUI(handles.axesCamera1,handles,eventdata,hObject);
    imshow(handles.currIMG,'Parent',handles.axesCamera1);
    drawnow();
    img{handles.ct} = handles.currIMG;
end

guidata(hObject, handles);


% --- Executes on button press in pushbuttonAddAnnotation.
function pushbuttonAddAnnotation_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddAnnotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;

str = get(handles.popupmenuAnnotations,'String');
val = get(handles.popupmenuAnnotations,'Value');

ann = str{val};

switch ann
    case 'TextBox'
        pt = getTextBoxLocation(hObject, eventdata, handles);
        text1 = inputdlg('Please enter the text you''d like in the textbox');
        %         val = get(handles.popupmenuTextSize,'Value');
        %         str = get(handles.popupmenuTextSize,'String');
        %         sz = str2num(str{val});
        %         val = get(handles.popupmenuTextColor,'Value');
        %         str = get(handles.popupmenuTextColor,'String');
        %         color = str{val};
        val = get(handles.popupmenuSetObjectColor,'Value');
        str = get(handles.popupmenuSetObjectColor,'String');
        boxColor = str{val};
        [aa bb cc] = size(getimage(handles.axesCamera1));
        img = getimage(handles.axesCamera1);
        img = insertText(img,[pt(1),pt(2)],text1{1},'FontSize',handles.TextSize,'TextColor',handles.TextColor,'BoxOpacity',0.4,'BoxColor',boxColor);
        handles.currIMG = img;
        imshow(handles.currIMG,'Parent',handles.axesCamera1);
        
        drawnow();
        
        guidata(hObject, handles);
        
    case 'Arrow'
        str = get(handles.popupmenuSetObjectColor,'String');
        val = get(handles.popupmenuSetObjectColor,'Value');
        color = str{val};
        %         str = get(handles.popupmenuSetLineWeight,'String');
        %         val = get(handles.popupmenuSetLineWeight,'Value');
        %         wt = str2num(str{val});
        
        [x y] = getpts(handles.axesCamera1,2);
        img = getimage(handles.axesCamera1);
        [a b c] = size(img);
        %draw main body
        p1 = [x(1) y(1)];
        p2 = [x(2) y(2)];
        dp = p2-p1;
        hold(handles.axesCamera1,'on');
        quiver(handles.axesCamera1,p1(1),p1(2),dp(1),dp(2),0,'MaxHeadSize',0.5,'color',color);
        hold(handles.axesCamera1,'off');
        
    case 'Circle'
        [handles.currIMG] = drawCircleGUI(handles.axesCamera1,handles,eventdata,hObject);
        imshow(handles.currIMG,'Parent',handles.axesCamera1);
        
        drawnow();
        
        guidata(hObject, handles);
        
    case 'Rectangle'
        [handles.currIMG] = drawRectGUI(handles.axesCamera1,handles,eventdata,hObject);
        imshow(handles.currIMG,'Parent',handles.axesCamera1);
        
        drawnow();
        
        guidata(hObject, handles);
        
        
        
        
end

function pt = getTextBoxLocation(hObject, eventdata, handles)
h = msgbox('Please click the upper left corner of where you''d like your textbox');
[x y] = getpts(handles.axesCamera1,1);
pt = [x y];
close(h);


% --- Executes on selection change in popupmenuSetObjectColor.
function popupmenuSetObjectColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSetObjectColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSetObjectColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSetObjectColor


% --- Executes during object creation, after setting all properties.
function popupmenuSetObjectColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSetObjectColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonLoadImage.
function pushbuttonLoadImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.file handles.pathstr] = uigetfile(fullfile(handles.pathstr,'*.*'),'Please select an image to load');
handles.currIMG = imread(fullfile(handles.pathstr,handles.file));
imshow(handles.currIMG,'Parent',handles.axesCamera1);

handles.currIMGOrig = handles.currIMG;
guidata(hObject, handles);


% --- Executes on selection change in popupmenuXAxis.
function popupmenuXAxis_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuXAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuXAxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuXAxis


% --- Executes during object creation, after setting all properties.
function popupmenuXAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuXAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuYAxis.
function popupmenuYAxis_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuYAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuYAxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuYAxis


% --- Executes during object creation, after setting all properties.
function popupmenuYAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuYAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonCreatePlot.
function pushbuttonCreatePlot_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCreatePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(handles.popupmenuXAxis,'String');
val = get(handles.popupmenuXAxis,'Value');
xItem = str{val};

switch val
    case 1
        plotX = handles.vidTimes;
    case 2
        numPoints = length(handles.trackPoints(:,1));
        answer = inputdlg(['Please choose the point whos position you wish to plot on the x-axis (' num2str(1) ' - ' num2str(numPoints) ')']);
        pointNum = str2num(answer{1});
        answer = inputdlg(['X or Y coordinate?']);
        if strcmpi(answer{1},'x') == 1
            ptPart = 1;
        elseif strcmpi(answer{1},'y') == 1
            ptPart = 2;
        else
            msgbox('You must enter X or Y!');
        end
        for i = 1:length(handles.trailPoints)
            plotX(i) = handles.trailPoints{i}(pointNum,ptPart);
        end
    case 3
        numPoints = length(handles.trackPoints(:,1));
        answer = inputdlg(['Please choose the point whos velocity you wish to plot  on the x-axis (' num2str(1) ' - ' num2str(numPoints) ')']);
        pointNum = str2num(answer{1});
        answer = inputdlg(['X or Y coordinate?']);
        if strcmpi(answer{1},'x') == 1
            ptPart = 1;
        elseif strcmpi(answer{1},'y') == 1
            ptPart = 2;
        else
            msgbox('You must enter X or Y!');
        end
        for i = 1:length(handles.trailPoints)
            if isempty(handles.velocity{i})
                plotX(i) = 0;
            else
                plotX(i) = handles.velocity{i}(pointNum,ptPart);
            end
        end
    case 4
        numPoints = length(handles.trackPoints(:,1));
        answer = inputdlg(['Please choose the point whos acceleration you wish to plot  on the x-axis (' num2str(1) ' - ' num2str(numPoints) ')']);
        pointNum = str2num(answer{1});
        answer = inputdlg('X or Y coordinate?');
        if strcmpi(answer{1},'x') == 1
            ptPart = 1;
        elseif strcmpi(answer{1},'y') == 1
            ptPart = 2;
        else
            msgbox('You must enter X or Y!');
        end
        for i = 1:length(handles.trailPoints)
            if isempty(handles.acceleration{i})
                plotX(i) = 0;
            else
                plotX(i) = handles.acceleration{i}(pointNum,ptPart);
            end
        end
    case 5
        numAngs = length(handles.angles)/length(handles.vidTimes);
        answer = inputdlg(['Please choose the angle you wish to plot  on the x-axis (' num2str(1) ' - ' num2str(numAngs) ')']);
        angNum = str2num(answer{1});
        ct=0;
        for i = angNum:numAngs:length(handles.angles)
            ct=ct+1;
            if isempty(handles.angles{i})
                plotX(ct) = 0;
            else
                plotX(ct) = handles.angles{i};
            end
        end
    case 6
        numAngs = length(handles.angles)/length(handles.vidTimes);
        answer = inputdlg(['Please choose the angle whos velocity you wish to plot  on the x-axis (' num2str(1) ' - ' num2str(numAngs) ')']);
        angNum = str2num(answer{1});
        ct=0;
        for i = angNum:numAng:length(handles.angles)
            ct=ct+1;
            ang(ct) = handles.angles{i};
        end
        for i = 2:length(ang)
            vel(i) = (ang(i) - ang(i-1)) / (handles.vidTimes(i) - handles.vidTimes(i-1));
        end
        for i = 3:length(ang)
            acc(i) = (vel(i) - vel(i-1)) / (handles.vidTimes(i) - handles.vidTimes(i-1));
        end
        plotX = vel;
    case 7
        numAngs = length(handles.angles)/length(handles.vidTimes);
        answer = inputdlg(['Please choose the angle whos Acceleration you wish to plot  on the x-axis (' num2str(1) ' - ' num2str(numAngs) ')']);
        angNum = str2num(answer{1});
        ct=0;
        for i = angNum:numAng:length(handles.angles)
            ct=ct+1;
            ang(ct) = handles.angles{i};
        end
        for i = 2:length(ang)
            vel(i) = (ang(i) - ang(i-1)) / (handles.vidTimes(i) - handles.vidTimes(i-1));
        end
        for i = 3:length(ang)
            acc(i) = (vel(i) - vel(i-1)) / (handles.vidTimes(i) - handles.vidTimes(i-1));
        end
        plotX = acc;
end

str = get(handles.popupmenuYAxis,'String');
val = get(handles.popupmenuYAxis,'Value');
yItem = str{val};

switch val
    case 1
        plotY = handles.vidTimes;
    case 2
        if ~isempty(handles.position)
            numPoints = length(handles.position{1}(:,1));
            answer = inputdlg(['Please choose the point whos position you wish to plot on the y-axis (' num2str(1) ' - ' num2str(numPoints) ')']);
            pointNum = str2num(answer{1});
            answer = inputdlg(['X or Y coordinate?']);
            if strcmpi(answer{1},'x') == 1
                ptPart = 1;
            elseif strcmpi(answer{1},'y') == 1
                ptPart = 2;
            else
                msgbox('You must enter X or Y!');
            end
            for i = 1:length(handles.trailPoints)
                plotY(i) = handles.trailPoints{i}(pointNum,ptPart);
            end
        else
            msgbox('There are no standalone points tracked!');
        end
    case 3
        if ~isempty(handles.position)
            numPoints = length(handles.position{1}(:,1));
            answer = inputdlg(['Please choose the point whos velocity you wish to plot  on the y-axis (' num2str(1) ' - ' num2str(numPoints) ')']);
            pointNum = str2num(answer{1});
            answer = inputdlg(['X or Y coordinate?']);
            if strcmpi(answer{1},'x') == 1
                ptPart = 1;
            elseif strcmpi(answer{1},'y') == 1
                ptPart = 2;
            else
                msgbox('You must enter X or Y!');
            end
            for i = 1:length(handles.trailPoints)
                if handles.velocity{i} == 0
                    plotY(i) = 0;
                else
                    plotY(i) = handles.velocity{i}(pointNum,ptPart);
                end
            end
        else
            msgbox('There are no standalone points tracked!');
        end
    case 4
        if ~isempty(handles.position)
            numPoints = length(handles.position{1}(:,1));
            answer = inputdlg(['Please choose the point whos acceleration you wish to plot  on the y-axis (' num2str(1) ' - ' num2str(numPoints) ')']);
            pointNum = str2num(answer{1});
            answer = inputdlg('X or Y coordinate?');
            if strcmpi(answer{1},'x') == 1
                ptPart = 1;
            elseif strcmpi(answer{1},'y') == 1
                ptPart = 2;
            else
                msgbox('You must enter X or Y!');
            end
            for i = 1:length(handles.trailPoints)
                if handles.acceleration{i} == 0
                    plotY(i) = 0;
                else
                    plotY(i) = handles.acceleration{i}(pointNum,ptPart);
                end
            end
        else
            msgbox('There are no standalone points tracked!');
        end
    case 5
        numAngs = round(length(handles.angles)/length(handles.vidTimes));
        answer = inputdlg(['Please choose the angle you wish to plot  on the y-axis (' num2str(1) ' - ' num2str(numAngs) ')']);
        angNum = str2num(answer{1});
        ct=0;
        for i = angNum:numAngs:length(handles.angles)
            ct=ct+1;
            if isempty(handles.angles{i})
                plotY(ct) = 0;
            else
                plotY(ct) = handles.angles{i};
            end
        end
        plotY = plotY(1:length(img));
    case 6
        numAngs = length(handles.angles)/length(handles.vidTimes);
        answer = inputdlg(['Please choose the angle whos velocity you wish to plot  on the y-axis (' num2str(1) ' - ' num2str(numAngs) ')']);
        angNum = str2num(answer{1});
        ct=0;
        for i = angNum:numAngs:length(handles.angles)
            ct=ct+1;
            ang(ct) = handles.angles{round(i)};
        end
        for i = 2:length(ang)
            vel(i) = (ang(i) - ang(i-1)) / (handles.vidTimes(i) - handles.vidTimes(i-1));
        end
        for i = 3:length(ang)
            acc(i) = (vel(i) - vel(i-1)) / (handles.vidTimes(i) - handles.vidTimes(i-1));
        end
        plotY = vel;
    case 7
        numAngs = length(handles.angles)/length(handles.vidTimes);
        answer = inputdlg(['Please choose the angle whos Acceleration you wish to plot  on the y-axis (' num2str(1) ' - ' num2str(numAngs) ')']);
        angNum = str2num(answer{1});
        ct=0;
        for i = angNum:numAngs:length(handles.angles)
            ct=ct+1;
            ang(ct) = handles.angles{round(i)};
        end
        for i = 2:length(ang)
            vel(i) = (ang(i) - ang(i-1)) / (handles.vidTimes(i) - handles.vidTimes(i-1));
        end
        for i = 3:length(ang)
            acc(i) = (vel(i) - vel(i-1)) / (handles.vidTimes(i) - handles.vidTimes(i-1));
        end
        plotY = acc;
end

plot(handles.axesGraph,plotX,plotY,'LineWidth',6);
ax = handles.axesGraph;
set(handles.axesGraph,'color','k');
yLim = ax.YLim;
handles.hLine = line(handles.axesGraph,[handles.vidTimes(end) handles.vidTimes(end)],yLim,'Color','r','LineWidth',6);
set(handles.textGraphTitle,'String',[yItem '-' xItem]);
handles.plot = 1;
drawnow();
guidata(hObject, handles);


% --- Executes on button press in pushbuttonWriteTrackedVideo.
function pushbuttonWriteTrackedVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonWriteTrackedVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;
global audio;
global audioFrequency;

h = msgbox('Writing');
cmp = computer;
set(handles.pushbuttonWriteTrackedVideo,'BackgroundColor','c');
drawnow();
if strcmp(cmp,'PCWIN64') == 1
    sysLine = 'Taskkill /IM ffmpeg.exe /F';
    system(sysLine);
    sysLine = 'Taskkill /IM cmd.exe /F';
    system(sysLine);
    pth = getenv('USERPROFILE');
    pth = [pth '\Documents'];
    sysLine = [' md ' pth '\MovementScience'];
    system(sysLine);
    pth = [pth '\MovementScience'];
    sysLine = ['del "' fullfile(pth,'\myAudio.wav"')];
    system(sysLine);
    if ~isempty(audio)%isfield(handles,'audio')
        audiowrite([pth '\myAudio.wav'],audio,audioFrequency);
    end
    sysLine= ['del ' fullfile(pth,'*.tif')];
    system(sysLine);
    
    zers = '00000000';
    ct=0;
    for i = 1:length(img)
        ct=ct+1;
        set(handles.editFrame,'String',num2str(ct));
        drawnow();
        imwrite(img{i},[pth '\' zers(1:end-length(num2str(ct))) num2str(ct) '.tif']);
    end
    pth = getenv('USERPROFILE');
    pth = [pth '\Documents'];
    pth = [pth '\MovementScience'];
    sysLine = 'Taskkill /IM ffmpeg.exe /F';
    system(sysLine);
    sysLine = 'Taskkill /IM cmd.exe /F';
    system(sysLine);
    %get info from audio file
    try
        info = audioinfo(fullfile(pth,'\myAudio.wav'));
    catch
    end
    %framerate
    if handles.isStoredVid == 1
        try
            framerate = handles.v.FrameRate;
        catch
            framerate = handles.framerate;
        end
    else
        framerate = round(1/mean(diff(handles.time)));
    end
    %ffmpeg build
    fName = get(handles.editMovieName,'String');
    if isfield(handles,'audio')
        sysLine = (['"c:\program files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -i "' pth '\myAudio.wav" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '.avi" &']]);
    else
        sysLine = (['"c:\program files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '.avi" &']]);
    end
    system(sysLine);
    set(handles.pushbuttonWriteTrackedVideo,'BackgroundColor','g');
end

if strcmp(cmp,'MACI64') == 1
    sysLine = 'killall ffmpeg';
    system(sysLine);
    user = getenv('USER');
    pth = ['/Users/' user  '/Documents'];
    sysLine = [' mkdir ' pth '/MovementScience'];
    system(sysLine);
    pth = [pth '/MovementScience'];
    sysLine = ['rm ' fullfile(pth,'myAudio.wav')];
    system(sysLine);
    if ~isempty(audio)%isfield(handles,'audio')
        audiowrite([pth '/myAudio.wav'],audio,audioFrequency);
    end
    sysLine= ['rm ' fullfile(pth,'*.tif')];
    system(sysLine);
    
    zers = '00000000';
    ct=0;
    for i = 1:length(img)
        ct=ct+1;
        set(handles.editFrame,'String',num2str(ct));
        drawnow();
        imwrite(img{i},[pth '/' zers(1:end-length(num2str(ct))) num2str(ct) '.tif']);
    end
    %get info from audio file
    try
        info = audioinfo(fullfile(pth,'/myAudio.wav'));
    catch
    end
    %framerate
    if handles.isStoredVid == 1
        framerate = handles.v.FrameRate;
    else
        framerate = round(1/mean(diff(handles.time)));
    end
    %ffmpeg build
    fName = get(handles.editMovieName,'String');
    if isfield(handles,'audio')
        sysLine = (['"/Applications/MovementScience/application/OSXFFMPEG/ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '/%08d.tif" -i "' pth '/myAudio.wav" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '.avi" &']]);
    else
        sysLine = (['"/Applications/MovementScience/application/OSXFFMPEG/ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '/%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '.avi" &']]);
    end
    system(sysLine);
    %     sysLine= ['rm ' fullfile(pth,'*.tif')];
    %     system(sysLine);
    set(handles.pushbuttonWriteTrackedVideo,'BackgroundColor','g');
end
delete(h);


% --- Executes on button press in pushbuttonExportTrackedValues.
function pushbuttonExportTrackedValues_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExportTrackedValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

header = {'Movie Name','Frame Number','Time'};
ispc = computer;
if strcmp(ispc,'PCWIN64') == 1
    pth = getenv('USERPROFILE');
    pth = [pth '\Documents'];
    sysLine = [' md ' pth '\MovementScience'];
    system(sysLine);
    pth = [pth '\MovementScience'];
end
if strcmp(ispc,'MACI64') == 1
    pth = getenv('USER');
    pth = ['/Users/' pth '/Documents'];
    sysLine = ['mkdir ' pth '/MovementScience'];
    system(sysLine);
    pth = [pth '/MovementScience'];
end
%account for point values
pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'p'))),:);
a = length(header);
[aa bb] = size(pt);
ct=1;
ptCt = 1;
if ~isempty(pt)
    for i = 1:2:aa*bb
        header{a+ct} = ['Point ' num2str(ptCt) ' X Position'];
        header{a+ct+1} = ['Point ' num2str(ptCt) ' Y Position'];
        ptCt = ptCt + 1;
        ct=ct+2;
    end
end
pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'p'))),:);
a = length(header);
[aa bb] = size(pt);
ct=1;
ptCt = 1;
if ~isempty(pt)
    for i = 1:2:aa*bb
        header{a+ct} = ['Point ' num2str(ptCt) ' X Velocity'];
        header{a+ct+1} = ['Point ' num2str(ptCt) ' Y Velocity'];
        ptCt = ptCt + 1;
        ct=ct+2;
    end
end

pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'p'))),:);
a = length(header);
[aa bb] = size(pt);
ct=1;
ptCt = 1;
if ~isempty(pt)
    for i = 1:2:aa*bb
        header{a+ct} = ['Point ' num2str(ptCt) ' X Acceleration'];
        header{a+ct+1} = ['Point ' num2str(ptCt) ' Y Acceleration'];
        ptCt = ptCt + 1;
        ct=ct+2;
    end
end

numAngles = floor(length(handles.angles) / length(handles.vidTimes));
a = length(header);
ct=0;
if numAngles > 0
    for i = 1:numAngles
        ct=ct+1;
        header{a+ct} = ['Angle ' num2str(ct) ' Position'];
    end
end
numAngles = floor(length(handles.angles) / length(handles.vidTimes));
a = length(header);
ct=0;
if numAngles > 0
    for i = 1:numAngles
        ct=ct+1;
        header{a+ct} = ['Angle ' num2str(ct) ' Velocity'];
    end
end
numAngles = floor(length(handles.angles) / length(handles.vidTimes));
a = length(header);
ct=0;
if numAngles > 0
    for i = 1:numAngles
        ct=ct+1;
        header{a+ct} = ['Angle ' num2str(ct) ' Acceleration'];
    end
end

% %info for 2 point angles
% pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'2a'))),:);
% a = length(header);
% ct=0;
% if ~isempty(pt)
%     for i = 1:2:length(pt(:,1))
%         ct=ct+1;
%         header{a+ct} = ['2 Point Angle ' num2str(ct) ' Position'];
%     end
% end
% %info for 2 point angles
% pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'2a'))),:);
% a = length(header);
% ct=0;
% if ~isempty(pt)
%     for i = 1:2:length(pt(:,1))
%         ct=ct+1;
%         header{a+ct} = ['2 Point Angle ' num2str(ct) ' Velocity'];
%     end
% end
% %info for 2 point angles
% pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'2a'))),:);
% a = length(header);
% ct=0;
% if ~isempty(pt)
%     for i = 1:2:length(pt(:,1))
%         ct=ct+1;
%         header{a+ct} = ['2 Point Angle ' num2str(ct) ' Acceleration'];
%     end
% end
%
% %info for 3 point angles
% pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'3a'))),:);
% a = length(header);
% ct=0;
% if ~isempty(pt)
%     for i = 1:3:length(pt(:,1))
%         ct=ct+1;
%         header{a+ct} = ['3 Point Angle ' num2str(ct) ' Position'];
%     end
% end
% pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'3a'))),:);
% a = length(header);
% ct=0;
% if ~isempty(pt)
%     for i = 1:3:length(pt(:,1))
%         ct=ct+1;
%         header{a+ct} = ['3 Point Angle ' num2str(ct) ' Velocity'];
%     end
% end
% pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'3a'))),:);
% a = length(header);
% ct=0;
% if ~isempty(pt)
%     for i = 1:3:length(pt(:,1))
%         ct=ct+1;
%         header{a+ct} = ['3 Point Angle ' num2str(ct) ' Acceleration'];
%     end
% end
%
% %info for 4 point angles
% pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'4a'))),:);
% a = length(header);
% ct=0;
% if ~isempty(pt)
%     for i = 1:4:length(pt(:,1))
%         ct=ct+1;
%         header{a+ct} = ['4 Point Angle ' num2str(ct) ' Position'];
%     end
% end
% pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'4a'))),:);
% a = length(header);
% ct=0;
% if ~isempty(pt)
%     for i = 1:4:length(pt(:,1))
%         ct=ct+1;
%         header{a+ct} = ['4 Point Angle ' num2str(ct) ' Velocity'];
%     end
% end
% pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'4a'))),:);
% a = length(header);
% ct=0;
% if ~isempty(pt)
%     for i = 1:4:length(pt(:,1))
%         ct=ct+1;
%         header{a+ct} = ['4 Point Angle ' num2str(ct) ' Acceleration'];
%     end
% end

%open file
textOutName = fullfile(pth,[handles.vidStr(1:end-4) '-' get(handles.editExportFileName,'String') '.txt']);
fid = fopen(textOutName,'w');
%print header
for i = 1:length(header)
    if i ~=length(header)
        fprintf(fid,'%s\t',header{i});
    else
        fprintf(fid,'%s\n',header{i});
    end
end
%grab easy parts of first line
outLine{1} = handles.vidStr;
outLine{2} = num2str(1);
outLine{3} = num2str(handles.vidTimes(1));
%print out point positions
pos = handles.position{1};
ptPos = pos(find(~cellfun(@isempty,strfind(handles.ptType,'p'))),:);
for i = 1:length(ptPos(:,1))
    a = length(outLine);
    outLine{a+1} = num2str(ptPos(i,1));
    outLine{a+2} = num2str(ptPos(i,2));
end
numPoints = length(ptPos(:,1));
%print out point velocities
vel = zeros(numPoints,2);%zero for first frame
% ptVel = vel(find(~cellfun(@isempty,strfind(handles.ptType,'p'))),:);
for i = 1:length(vel(:,1))
    a = length(outLine);
    outLine{a+1} = num2str(vel(i,1));
    outLine{a+2} = num2str(vel(i,2));
end
%print out point accelerations (zero, same as velocities for first frame)
vel = zeros(numPoints,2);
% ptVel = vel(find(~cellfun(@isempty,strfind(handles.ptType,'p'))),:);
for i = 1:length(vel(:,1))
    a = length(outLine);
    outLine{a+1} = num2str(vel(i,1));
    outLine{a+2} = num2str(vel(i,2));
end
%print out angular positions
numAngles = floor(length(handles.angles) / length(handles.vidTimes));
handles.angles = handles.angles(1:end-numAngles);
for i = 1:numAngles
    ct=1;
    a = length(outLine);
    outLine{a+ct} = num2str(handles.angles{i});
end
%print out velocities as zero for first frame
for i = 1:numAngles
    ct=1;
    a = length(outLine);
    outLine{a+ct} = num2str(0);
end
%print out accelerations as zero for first frame
for i = 1:numAngles
    ct=1;
    a = length(outLine);
    outLine{a+ct} = num2str(0);
end
for i = 1:length(outLine)
    if i < length(outLine)
        fprintf(fid,'%s\t',outLine{i});
    else
        fprintf(fid,'%s\n',outLine{i});
    end
end

%calculate angular velocity and acceleration
start = 1+numAngles * 2;
ct = 2;
diffs = diff(handles.vidTimes);
diffs = [diffs(1) diffs];
for i = start:length(handles.angles)
    handles.angularVelocity(i) = (handles.angles{i} - handles.angles{i-numAngles}) / mean(diffs);
    ct=ct+1;
end
start = 1+numAngles * 3;
ct = 2;
diffs = diff(handles.vidTimes);
diffs = [diffs(1) diffs];
for i = start:length(handles.angles)
    handles.angularAcceleration(i) = (handles.angularVelocity(i) - handles.angularVelocity(i-numAngles)) / mean(diffs);
    ct=ct+1;
end

%print out the rest
ang = 1;
for i = 2:length(handles.vidTimes)
    %leave name column empty rest of the way
    fprintf(fid,'%s\t','');
    %frame
    fprintf(fid,'%s\t',num2str(i));
    fprintf(fid,'%s\t',num2str(handles.vidTimes(i)));
    pos = handles.position{i};
    ptPos = pos(find(~cellfun(@isempty,strfind(handles.ptType,'p'))),:);
    for j = 1:length(ptPos(:,1))
        fprintf(fid,'%s\t',num2str(ptPos(j,1)));
        fprintf(fid,'%s\t',num2str(ptPos(j,2)));
    end
    vel = handles.velocity{i};
    for j = 1:length(vel(:,1))
        fprintf(fid,'%s\t',num2str(vel(j,1)));
        fprintf(fid,'%s\t',num2str(vel(j,2)));
    end
    acc = handles.acceleration{i};
    if i > 2
        for j = 1:numPoints
            fprintf(fid,'%s\t',num2str(acc(j,1)));
            fprintf(fid,'%s\t',num2str(acc(j,2)));
        end
    else
        for j = 1:numPoints
            fprintf(fid,'%s\t',num2str(0));
            fprintf(fid,'%s\t',num2str(0));
        end
    end
    
    for j = ang:ang+numAngles-1
        fprintf(fid,'%s\t',num2str(handles.angles{j}));
    end
    for j = ang:ang+numAngles-1
        fprintf(fid,'%s\t',num2str(handles.angularVelocity(j)));
    end
    if i > 2
        for j = ang:ang+numAngles-1
            fprintf(fid,'%s\t',num2str(handles.angularAcceleration(j)));
        end
    else
        for j = ang:ang+numAngles-1
            fprintf(fid,'%s\t',num2str(0));
        end
    end
    fprintf(fid,'%s\n','');
    ang = ang + numAngles;
end


function editExportFileName_Callback(hObject, eventdata, handles)
% hObject    handle to editExportFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editExportFileName as text
%        str2double(get(hObject,'String')) returns contents of editExportFileName as a double


% --- Executes during object creation, after setting all properties.
function editExportFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editExportFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonPlayVideo.
function pushbuttonPlayVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlayVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;

pc = computer;
if strcmp(pc,'MACI64') == 1
    try
        pth = getenv('USER');
        pth = ['/Users/' pth '/Documents'];
        sysLine = ['mkdir ' pth '/MovementScience'];
        pth = [pth '/MovementScience'];
        system(sysLine);
        w = VideoWriter([pth '/tmp'],'Uncompressed AVI');
        w.FrameRate = handles.v.FrameRate;
        zers = '00000000';
        h = msgbox('Writing temporary video');
        for i = 1:length(img)
            set(handles.editFrame,'String',num2str(i));
            drawnow();
            imwrite(img{i},fullfile(pth,[zers(1:end-length(num2str(i))) num2str(i) '.tif']));
        end
        %       try
        if exist(fullfile(pth,'myAudio.avi')) == 2
            sysLine = (['"/Applications/MovementScience/application/OSXFFMPEG/ffmpeg" -framerate ' num2str(handles.v.FrameRate) ' -i "' pth '/%08d.tif" -i "' pth '/myAudio.wav" -codec copy -y -c:v mjpeg -qscale:v 0  "' [pth '/tmp.avi"']]);
            system(sysLine);
        else
            sysLine = (['"/Applications/MovementScience/application/OSXFFMPEG/ffmpeg" -framerate ' num2str(handles.v.FrameRate) ' -i "' pth '/%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [pth '/tmp.avi"']]);
            system(sysLine);
        end
        sysLine = (['rm "' pth '/*.tif"']);
        system(sysLine);
        sysLine = ['open "' pth '/tmp.avi"'];
        system(sysLine)
    catch
        msgbox('Unable to launch video player');
    end
    delete(h);
end

if strcmp(pc,'PCWIN64') == 1
    try
        pth = getenv('USERPROFILE');
        pth = [pth '\Documents'];
        sysLine = ['md ' pth '\MovementScience'];
        pth = [pth '\MovementScience'];
        system(sysLine);
        sysLine = ['del /s ' pth '\*.tif'];
        system(sysLine);
        w = VideoWriter([pth '\tmp'],'Uncompressed AVI');
        w.FrameRate = handles.v.FrameRate;
        zers = '00000000';
        h = msgbox('Writing temporary video');
        for i = 1:length(img)
            set(handles.editFrame,'String',num2str(i));
            drawnow();
            imwrite(img{i},fullfile(pth,[zers(1:end-length(num2str(i))) num2str(i) '.tif']));
        end
        %       try
        if exist(fullfile(pth,'myAudio.avi')) == 2
            sysLine = (['"C:\Program Files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg.exe" -framerate ' num2str(handles.v.FrameRate) ' -i "' pth '\%08d.tif" -i "' pth '\myAudio.wav" -codec copy -y -c:v mjpeg -qscale:v 0  "' [pth '\tmp.avi"']]);
            system(sysLine);
        else
            sysLine = (['"C:\Program Files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg.exe" -framerate ' num2str(handles.v.FrameRate) ' -i "' pth '\%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [pth '\tmp.avi"']]);
            system(sysLine);
        end
        sysLine = (['del "' pth '\*.tif"']);
        system(sysLine);
        sysLine = ['"C:\Program Files\windows media player\wmplayer.exe" "' pth '\tmp.avi" &'];
        system(sysLine)
    catch
        msgbox('Unable to launch video player');
    end
    delete(h);
end
%use ffmpeg on Mac prolly


% --- Executes on button press in pushbuttonPopulateMicrophones.
function pushbuttonPopulateMicrophones_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPopulateMicrophones (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
info = audiodevinfo();
for i = 1:length(info.input)
    str{i} = info.input(i).Name;
end
set(handles.popupmenuMicrophones,'String',str);
guidata(hObject, handles);


% --- Executes on selection change in popupmenuMicrophones.
function popupmenuMicrophones_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMicrophones (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMicrophones contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMicrophones


% --- Executes during object creation, after setting all properties.
function popupmenuMicrophones_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMicrophones (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSetMicrophone.
function pushbuttonSetMicrophone_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetMicrophone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(handles.popupmenuMicrophones,'String');
val = get(handles.popupmenuMicrophones,'Value');
handles.microphoneID = val-1;
handles.recorder = audiorecorder(9600,8,1,handles.microphoneID);
guidata(hObject, handles);


% --- Executes on button press in togglebuttonRecordAudioOverMovie.
function togglebuttonRecordAudioOverMovie_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonRecordAudioOverMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonRecordAudioOverMovie

global img;
global audio;
global audioFrequency;

val = get(handles.togglebuttonRecordAudioOverMovie,'Value');
cmp = computer;
release(handles.pointTracker);
handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);
handles.pointTrackerisInitialized = 0;
handles.trackPoints = [];
guidata(hObject, handles);
if strcmp(cmp,'PCWIN64') == 1
    pth = getenv('USERPROFILE');
    pth = [pth '\Documents'];
    sysLine = [' md ' pth '\MovementScience'];
    pth = [pth '\MovementScience'];
    system(sysLine);
    if handles.continuing == 0
        sysLine = 'Taskkill /IM ffmpeg.exe /F';
        system(sysLine);
    end
    if val == 1
        if handles.continuing == 0
            sysLine = ['del ' '"' pth '\myAudio.wav"'];
            system(sysLine);
            sysLine= ['del ' fullfile(pth,'*.tif')];
            system(sysLine);
            handles.fid = fopen(fullfile(pth,'frameTimes.txt'),'w');
            guidata(hObject, handles);
        end
        set(handles.togglebuttonRecordAudioOverMovie,'BackgroundColor','r');
        if handles.continuing == 0
            try
                str = get(handles.popupmenuMicrophones,'String');
                val2 = get(handles.popupmenuMicrophones,'Value');
                mic = str{val2};
                mic = mic(1:end-22);
                sysLine = (['"C:\Program Files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg" -f dshow -i audio="' mic '" "' pth '\myAudio.wav &']);
                system(sysLine);
                %                 sysLine = (['"c:\program files\MovementScience\application\fmedia\fmedia" --dev-capture=' num2str(handles.microphoneID) ' --record --out=' pth '\myAudio.wav',' --rate=48000 &']);
            catch
                msgbox('No microphone selected');
            end
            
        end
        zers = '00000000';
        if handles.continuing == 0
            handles.ct=0;
            handles.tic = tic;
        end
        handles.timeFrames = [];
        while val == 1 && get(handles.togglebuttonStream,'Value') == 0
            handles.ct=handles.ct+1;
            imwrite(getimage(handles.axesCamera1),[pth '\towrite' zers(1:end-length(num2str(handles.ct))) num2str(handles.ct) '.tif']);
            drawnow();
            fprintf(handles.fid,'%s\t',[pth '\towrite' zers(1:end-length(num2str(handles.ct))) num2str(handles.ct) '.tif']);
            fprintf(handles.fid,'%s\t',num2str(0));
            fprintf(handles.fid,'%s\n',num2str(toc(handles.tic)));
            val = get(handles.togglebuttonRecordAudioOverMovie,'Value');
            guidata(hObject, handles);
        end
    elseif val == 0
        handles.continuing = 0;
        h = msgbox('Writing video with recorded audio');
        pth = getenv('USERPROFILE');
        pth = [pth '\Documents'];
        pth = [pth '\MovementScience'];
        %kill fmedia task
        %             sysLine = 'Taskkill /IM fmedia.exe /F';
        %             system(sysLine);
        sysLine = 'Taskkill /IM ffmpeg.exe /F';
        system(sysLine);
        sysLine = 'Taskkill /IM cmd.exe /F';
        system(sysLine);
        sysLine = ['del ' fullfile(pth,'myMovieWithAudio.avi')];
        system(sysLine);
        %get info from audio file
        info = audioinfo(fullfile(pth,'\myAudio.wav'));
        timeAudio = info.Duration;
        timeFrames = importdata(fullfile(pth,'frameTimes.txt'),'\t');
        playFlags = find(timeFrames.data(:,1));
        if isempty(playFlags)
            timeFrames = timeFrames.data(:,2);
            playTimes = timeFrames;
        else
            timeFrames = timeFrames.data(:,2);
            playTimes = timeFrames(playFlags);
        end
        fr = 1/median(diff(timeFrames(1:4)));%framerate for first 4 frames, probably not playing here is why these 4 are chosen
        frSTD = diff(timeFrames(1:8));
        frSTD = std(frSTD);
        timeFrames = [0;timeFrames];
        wav = audioread(fullfile(pth,'\myAudio.wav'));
        wavOut = wav;%(1:info.SampleRate*max(times),:);
        audiowrite(fullfile(pth,'\myAudio.wav'),wavOut,info.SampleRate);
        ims = dir([pth '\towrite*.tif']);
        zers = '0000000000';
        ct=1;
        imwrite(imread(fullfile(pth,ims(1).name)),fullfile(pth,[zers(1:end-length(num2str(ct))) num2str(ct) '.tif']));
        timeDiffs = diff(timeFrames);
        clear toInterpolate;
        count = 0;
        toInterpolate = cell(0);
        for i = 1:length(timeDiffs)
            if timeDiffs(i) > median(timeDiffs(1:8)) * 2
                count = count+1;
                timeMeasured(count) = timeFrames(i+1);
                toInterpolate{count} = imread(fullfile(pth,ims(i+1).name));
            end
            if timeDiffs(i) <= mean(timeDiffs(1:8)) + 5*(frSTD)
                if length(toInterpolate) > 1
                    timeDesired = min(timeMeasured):1/fr:max(timeMeasured);
                    ct = interpolateAndWriteColorFrames(toInterpolate,timeMeasured,timeDesired,ct,zers,pth);
                    toInterpolate = cell(0);
                    count = 0;
                    clear timeDesired timeMeasured;
                else
                    ct=ct+1;
                    imwrite(imread(fullfile(pth,ims(i+1).name)),fullfile(pth,[zers(1:end-length(num2str(ct))) num2str(ct) '.tif']));
                end
            end
        end
        
        sysLine= ['del ' fullfile(pth,'towrite*.tif')];
        system(sysLine);
        
        %ffmpeg build
        fr = length(dir(fullfile(pth,'*.tif')))/timeAudio;
        sysLine = (['"c:\program files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg" -framerate ' num2str(fr) ' -i "' pth '\%10d.tif" -i "' pth '\myAudio.wav" -codec copy -y -c:v mjpeg -qscale:v 0  "' pth '\' get(handles.editMovieName,'String') '-WithAudio.avi" &']);
        system(sysLine);
        delete(h);
        set(handles.togglebuttonRecordAudioOverMovie,'Value',0);
        set(handles.togglebuttonRecordAudioOverMovie,'BackgroundColor','g');
        set(handles.togglebuttonStream,'Value',0);
        set(handles.togglebuttonStream,'BackgroundColor','g');
        fclose(handles.fid);
        guidata(hObject, handles);
    end
    set(handles.togglebuttonRecordAudioOverMovie,'BackgroundColor','g');
    return
end
% if strcmp(cmp,'GLNXA64') == 1
%     if val == 1
%         set(handles.togglebuttonRecordAudioOverMovie,'BackgroundColor','r');
%         sysLine = 'which MovementScience';
%         prgPth = system(sysLine);
%         pth = getenv('USERPROFILE');

if strcmp(cmp,'MACI64') == 1
    usr = getenv('USER');
    pth = ['/Users/' usr '/Documents/MovementScience'];
    sysLine = ['rm ' pth '/*.tif'];
    system(sysLine);
    sysLine = ['rm ' pth '/*.aac'];
    system(sysLine);
    if val == 1
        set(handles.togglebuttonRecordAudioOverMovie,'BackgroundColor','r');
        %start recording video independent of MATLAB
        currDir = pwd;
        sysLine = ['"/Applications/MovementScience/application/OSXFFMPEG/ffmpeg" -f avfoundation -ac 2 -i :0 -c:a aac -ab 96k "' pth '/myVoice.aac" &'];
        system(sysLine);
        cd(currDir);
        system(sysLine);
        zers = '00000000';
        ct=0;
        tic;
        while val == 1
            ct=ct+1;
            imwrite(getimage(handles.axesCamera1),[pth '/' zers(1:end-length(num2str(ct))) num2str(ct) '.tif']);
            drawnow();
            toc;
            handles.timeFrames = toc;
            val = get(handles.togglebuttonRecordAudioOverMovie,'Value');
            guidata(hObject, handles);
        end
    elseif val == 0
        sysLine = 'killall ffmpeg';
        system(sysLine);
        info = audioinfo(fullfile(pth,'/myVoice.aac'));
        time = info.Duration;
        %cut beginning of audio to match video
        dif = time - handles.timeFrames;
        frames = dif * info.SampleRate;
        aac = audioread(fullfile(pth,'/myVoice.aac'));
        aacOut = aac((dif*info.SampleRate):end,:);
        audiowrite(fullfile(pth,'/myVoice.aac'),aacOut,info.SampleRate);
        %framerate
        framerate = length(dir([pth '/*.tif'])) / handles.timeFrames;
        %ffmpeg build
        currDir = pwd;
        sysLine = (['"/Applications/MovementScience/application/OSXFFMPEG/ffmpeg" -framerate ' num2str(framerate) ' -i ' pth '/%08d.tif -i ' pth '/myVoice.aac" -codec copy -y -c:v mjpeg -qscale:v 0  "' pth '/' get(handles.editMovieName,'String') 'WithAudio.avi"']);
        system(sysLine);
        cd(currDir);
        sysLine= ['rm ' pth '/*.tif'];
        system(sysLine);
    end
end



% --- Executes on button press in pushbuttonResizeAndCrop.
function pushbuttonResizeAndCrop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonResizeAndCrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
global audio;
global audioFrequency;
global PointSize;
global TrailingPointSize;
global PointWeight;
global TrailingPointWeight;
global LineWeight;
global TextSize;
global SearchRadius;
global TextWeight;
global vidStr;
global pathstr;
global vidTimes;
if isfield(handles,'vidTimes')
    vidTimes = handles.vidTimes;
end

h = PreProcess;
waitfor(h);
release(handles.pointTracker);
handles.trackPoints = [];
handles.pointTrackerisInitialized = 0;
set(handles.togglebuttonStream,'BackgroundColor','g');
set(handles.togglebuttonStream,'Value',0);
set(handles.togglebuttonRecordAudioOverMovie,'BackgroundColor','g');
set(handles.togglebuttonRecordAudioOverMovie,'Value',0);
[a b c] = size(img{1});
ptRatio = ceil(a * 0.01);
tptRatio = ceil(a * 0.003);
ptwtRatio = ceil(a * 0.006);
tptwtRatio = ceil(a * 0.003);
lnRatio = ceil(a * 0.005);
txtRatio = ceil(a * 0.02);

PointSize = PointSize * ptRatio;
TrailingPointSize = TrailingPointSize * tptRatio;
PointWeight = PointWeight * ptwtRatio;
TrailingPointWeight = TrailingPointWeight * tptwtRatio;
LineWeight = LineWeight * lnRatio;
TextSize = TextSize * txtRatio;
SearchRadius = SearchRadius * ptRatio;
TextWeight = TextWeight * txtRatio;
handles.vidTimes = vidTimes;

if ~isempty(pathstr)
    handles.pathstr = pathstr;
    clear pathstr;
    handles.vidStr = vidStr;
    clear vidStr;
end

% set(handles.popupmenuSetPointSize,'Value',ptRatio);
% set(handles.popupmenuTrailingPointSize,'Value',tptRatio);
% set(handles.popupmenuSetPointWeight,'Value',ptwtRatio);
% set(handles.popupmenuSetTrailingPointWeight,'Value',tptwtRatio);
% set(handles.popupmenuSetLineWeight,'Value',lnRatio);
% set(handles.popupmenuTextSize,'Value',txtRatio);
% set(handles.editSearchRadius,'String',num2str(ceil(a/100)));
set(handles.sliderLoadedVideo,'Value',1);
set(handles.sliderLoadedVideo,'min',1);
set(handles.sliderLoadedVideo,'max',length(img));
set(handles.sliderLoadedVideo,'SliderStep',[1/(length(img)-1),0.1]);
set(handles.editFrame,'String','1');
imshow(img{1},'Parent',handles.axesCamera1);
drawnow();


handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);

handles.isStoredVid = 1;
guidata(hObject, handles);


% --- Executes on selection change in popupmenuTrailingPointSize.
function popupmenuTrailingPointSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTrailingPointSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTrailingPointSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTrailingPointSize


% --- Executes during object creation, after setting all properties.
function popupmenuTrailingPointSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTrailingPointSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSearchRadius_Callback(hObject, eventdata, handles)
% hObject    handle to editSearchRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSearchRadius as text
%        str2double(get(hObject,'String')) returns contents of editSearchRadius as a double
% str = get(handles.editSearchRadius,'String');
% val = str2num(str);
% sz = str2num(str{val});
handles.pointTracker = vision.PointTracker('BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxBidirectionalError',5,'MaxIterations',50,'NumPyramidLevels',4);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editSearchRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSearchRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebuttonRecordAudioOnly.
function togglebuttonRecordAudioOnly_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonRecordAudioOnly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonRecordAudioOnly
val = get(handles.togglebuttonRecordAudioOnly,'Value');

try
    if val == 1
        if ~isfield(handles,'r')
            str = get(handles.popupmenuMicrophones,'String');
            val2 = get(handles.popupmenuMicrophones,'Value');
            dev = str{val2};
            info = audiodevinfo(1,dev);
            handles.r = audiorecorder(44100,16,1,info);
            guidata(hObject, handles);
        end
        set(handles.togglebuttonRecordAudioOnly,'BackgroundColor','c');
        drawnow()
        record(handles.r);
        guidata(hObject, handles);
    elseif val == 0
        stop(handles.r);
        y = getaudiodata(handles.r);
        fName = get(handles.editAudioFileName,'String');
        ispc = computer;
        if strcmp(ispc,'PCWIN64') == 1
            pth = getenv('USERPROFILE');
            pth = [pth '\Documents'];
            sysLine = [' md ' pth '\MovementScience'];
            system(sysLine);
            pth = [pth '\MovementScience'];
        end
        if strcmp(ispc,'MACI64') == 1
            pth = getenv('USER');
            pth = ['/Users/' pth '/Documents'];
            sysLine = ['mkdir ' pth '/MovementScience'];
            system(sysLine);
            pth = [pth '/MovementScience'];
        end
        
        fName = fullfile(pth,fName);
        audiowrite([fName '.wav'],y,44100);
        guidata(hObject, handles);
        set(handles.togglebuttonRecordAudioOnly,'BackgroundColor','g');
        drawnow()
    end
catch
    msgbox('Microphone has not been set');
end



function editAudioFileName_Callback(hObject, eventdata, handles)
% hObject    handle to editAudioFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAudioFileName as text
%        str2double(get(hObject,'String')) returns contents of editAudioFileName as a double


% --- Executes during object creation, after setting all properties.
function editAudioFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAudioFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function togglebuttonStream_CreateFcn(hObject, eventdata, handles)
% hObject    handle to togglebuttonStream (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbuttonOverlayGraphOnImages.
function pushbuttonOverlayGraphOnImages_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOverlayGraphOnImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;

ispc = computer;

if strcmp(ispc,'PCWIN64') == 1
    pth = getenv('USERPROFILE');
    pth = [pth '\Documents'];
    sysLine = [' md ' pth '\MovementScience'];
    pth = [pth '\MovementScience'];
    system(sysLine);
    loc = get(handles.sliderLoadedVideo,'Value');
    for i = 1:length(img)
        set(handles.sliderLoadedVideo,'Value',i);
        imshow(img{i},'Parent',handles.axesCamera1);
        im = getimage(handles.axesCamera1);
        [a b c] = size(im);
        sliderLoadedVideo_Callback(hObject, eventdata, handles);
        set(handles.axesGraph,'color','k');
        imGraph = getframe(handles.axesGraph);
        %         set(handles.axesGraph,'color','w');
        imGraph = imGraph.cdata;
        [ag bg cg] = size(imGraph);
        gText = get(handles.textGraphTitle,'String');
        sz = get(handles.popupmenuTextSize,'Value');
        clS = get(handles.popupmenuTextColor,'String');
        v = get(handles.popupmenuTextColor,'Value');
        imGraph = imresize(imGraph,[round((ag*(b/bg))) b]);
        [ag bg cg] = size(imGraph);
        vertPad = a - ag;
        topPad = vertPad / 2;
        fg = mod(topPad,1);
        if fg ~= 0
            topPad = floor(topPad);
            botPad = topPad + 1;
        else
            botPad = topPad;
        end
        tP = zeros(topPad,b,3);
        bP = zeros(botPad,b,3);
        imGraph = [tP;imGraph;bP];
        C = imfuse(im,imGraph,'blend');
        C = imadjust(C,[0 .5],[0 1]);
        C = insertText(C,[10,10],gText,'FontSize',sz,'TextColor',clS(v),'BoxColor','white','BoxOpacity',0.1);
        img{i} = C;
        %         imshow(img{i},'Parent',handles.axesCamera1);
        %         set(handles.sliderLoadedVideo,'Value',i);
        %         set(handles.editFrame,'String',num2str(i));
        %         handles.ct=i;
        guidata(hObject, handles);
    end
    set(handles.sliderLoadedVideo,'Value',loc);
    imshow(img{get(handles.sliderLoadedVideo,'Value')},'Parent',handles.axesCamera1);
    drawnow();
end

if strcmp(ispc,'MACI64') == 1
    pth = getenv('USER');
    pth = ['/Users/' pth '/Documents'];
    sysLine = ['mkdir ' pth '/MovementScience'];
    pth = [pth '/MovementScience'];
    system(sysLine);
    loc = get(handles.sliderLoadedVideo,'Value');
    for i = 1:length(img)
        set(handles.sliderLoadedVideo,'Value',i);
        imshow(img{i},'Parent',handles.axesCamera1);
        im = getimage(handles.axesCamera1);
        [a b c] = size(im);
        sliderLoadedVideo_Callback(hObject, eventdata, handles);
        set(handles.axesGraph,'color','k');
        imGraph = getframe(handles.axesGraph);
        %         set(handles.axesGraph,'color','w');
        imGraph = imGraph.cdata;
        [ag bg cg] = size(imGraph);
        gText = get(handles.textGraphTitle,'String');
        sz = get(handles.popupmenuTextSize,'Value');
        clS = get(handles.popupmenuTextColor,'String');
        v = get(handles.popupmenuTextColor,'Value');
        imGraph = imresize(imGraph,[round((ag*(b/bg))) b]);
        [ag bg cg] = size(imGraph);
        vertPad = a - ag;
        topPad = vertPad / 2;
        fg = mod(topPad,1);
        if fg ~= 0
            topPad = floor(topPad);
            botPad = topPad + 1;
        else
            botPad = topPad;
        end
        tP = zeros(topPad,b,3);
        bP = zeros(botPad,b,3);
        imGraph = [tP;imGraph;bP];
        C = imfuse(im,imGraph,'blend');
        C = imadjust(C,[0 .5],[0 1]);
        C = insertText(C,[10,10],gText,'FontSize',sz,'TextColor',clS(v),'BoxColor','white','BoxOpacity',0.1);
        img{i} = C;
        %         imshow(img{i},'Parent',handles.axesCamera1);
        %         set(handles.sliderLoadedVideo,'Value',i);
        %         set(handles.editFrame,'String',num2str(i));
        %         handles.ct=i;
        guidata(hObject, handles);
    end
    set(handles.sliderLoadedVideo,'Value',loc);
    imshow(img{get(handles.sliderLoadedVideo,'Value')},'Parent',handles.axesCamera1);
    drawnow();
end



% --- Executes on button press in pushbuttonMergeVideos.
function pushbuttonMergeVideos_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMergeVideos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
global audio;
global audioFrequency;
global PointSize;
global TrailingPointSize;
global PointWeight;
global TrailingPointWeight;
global LineWeight;
global TextSize;
global SearchRadius;
global TextWeight;
global vidStr;
global pathstr;
global framerate;
h = VideoAligner();
waitfor(h);
release(handles.pointTracker);
handles.trackPoints = [];
handles.pointTrackerisInitialized = 0;
set(handles.togglebuttonStream,'BackgroundColor','g');
set(handles.togglebuttonStream,'Value',0);
set(handles.togglebuttonRecordAudioOverMovie,'BackgroundColor','g');
set(handles.togglebuttonRecordAudioOverMovie,'Value',0);
[a b c] = size(img{1});
ptRatio = ceil(a * 0.01);
tptRatio = ceil(a * 0.003);
ptwtRatio = ceil(a * 0.006);
tptwtRatio = ceil(a * 0.003);
lnRatio = ceil(a * 0.005);
txtRatio = ceil(a * 0.02);

PointSize = PointSize * ptRatio;
TrailingPointSize = TrailingPointSize * tptRatio;
PointWeight = PointWeight * ptwtRatio;
TrailingPointWeight = TrailingPointWeight * tptwtRatio;
LineWeight = LineWeight * lnRatio;
TextSize = TextSize * txtRatio;
SearchRadius = SearchRadius * ptRatio;
TextWeight = TextWeight * txtRatio;
set(handles.sliderLoadedVideo,'Value',1);
set(handles.sliderLoadedVideo,'min',1);
set(handles.sliderLoadedVideo,'max',length(img));
set(handles.sliderLoadedVideo,'SliderStep',[1/(length(img)-1),0.1]);
set(handles.editFrame,'String','1');
imshow(img{1},'Parent',handles.axesCamera1);
drawnow();
handles.isStoredVid = 1;
handles.framerate = framerate;
guidata(hObject, handles);

try
    if ~isempty(pathstr)
        handles.pathstr = pathstr;
        handles.vidStr = vidStr;
    end
catch
end

handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[handles.SearchRadius handles.SearchRadius],'MaxIterations',50,'NumPyramidLevels',4);

guidata(hObject, handles);

% --- Executes on button press in pushbuttonCleanFolder.
function pushbuttonCleanFolder_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCleanFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pc = computer;
if strcmp(pc,'PCWIN64') == 1
    pth = getenv('USERPROFILE');
    pth = [pth '\Documents'];
    pth = [pth '\MovementScience'];
    sysLine = ['del /s "' pth '\*.tif"'];
    system(sysLine);
end
if strcmp(pc,'MACI64') == 1
    pth = getenv('USER');
    pth = ['/Users/' pth '/Documents/MovementScience'];
    sysLine = ['rm "' pth '/*.tif"'];
    system(sysLine);
end


% --- Executes on button press in pushbuttonCreateGraph.
function pushbuttonCreateGraph_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCreateGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
global PointData;
global FrameRate;
PointData = handles.pointData;
FrameRate = handles.vidInfo.FrameRate;

h = MovementScienceGraphing();
waitfor(h);
imshow(img{round(get(handles.sliderLoadedVideo,'Value'))},'Parent',handles.axesCamera1);
try
    release(handles.pointTracker);
catch
end
handles.trackPoints = [];
handles.pointData = cell(0);
handles.pointTrackerisInitialized = 0;
drawnow();
guidata(hObject, handles);


function editFrame_Callback(hObject, eventdata, handles)
% hObject    handle to editFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFrame as text
%        str2double(get(hObject,'String')) returns contents of editFrame as a double


% --- Executes during object creation, after setting all properties.
function editFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonAdvancedSettings.
function pushbuttonAdvancedSettings_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAdvancedSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PointSize;
global TrailingPointSize;
global PointWeight;
global TrailingPointWeight;
global LineWeight;
global TextSize;
global SearchRadius;
global PointColor;
global TrailingPointColor;
global LineColor;
global TextColor;
global TextWeight;
global TrailingPointNumber;

PointSize = handles.PointSize;
TrailingPointSize = handles.TrailingPointSize;
PointWeight = handles.PointWeight;
TrailingPointWeight = handles.TrailingPointWeight;
LineWeight = handles.LineWeight;
TextSize = handles.TextSize;
SearchRadius = handles.SearchRadius;
PointColor = handles.PointColor;
TrailingPointColor = handles.TrailingPointColor;
LineColor = handles.LineColor;
TextColor = handles.TextColor;
TextWeight = handles.TextWeight;
TrailingPointNumber = handles.TrailingPointNumber;

AdvancedSettingsForMovementScience();
uiwait();

handles.PointSize = PointSize;
handles.TrailingPointSize = TrailingPointSize;
handles.PointWeight = PointWeight;
handles.TrailingPointWeight = TrailingPointWeight;
handles.LineWeight = LineWeight;
handles.TextSize = TextSize;
handles.SearchRadius = SearchRadius;
if mod(handles.SearchRadius,2) == 0
    handles.SearchRadius = handles.SearchRadius + 1;
end
handles.PointColor = PointColor;
handles.TrailingPointColor = TrailingPointColor;
handles.LineColor = LineColor;
handles.TextColor = TextColor;
handles.TextWeight = TextWeight;
handles.TrailingPointNumber = TrailingPointNumber;

guidata(hObject, handles);


% --- Executes on button press in pushbuttonAddWatermark.
function pushbuttonAddWatermark_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddWatermark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;

[f p] = uigetfile(fullfile(handles.pathstr,'*.*'),'Please select the image file to use as a watermark');
f = fullfile(p,f);
try
    wm = imread(f);
    h = vision.AlphaBlender;
    str = get(handles.popupmenuWatermarkLocation,'String');
    val = get(handles.popupmenuWatermarkLocation,'Value');
    str = str{val};
    [a b c] = size(img{1});
    
    [a2 b2 c2] = size(wm);
    if a2 < round(a/8) && b2 < round(b/5)
    else
        [a2 b2 c2] = size(wm);
        aRat = a2 / a;
        bRat = b2 / b;
        
        x = bRat / (1/5);
        b2 = b2 * (1/x);
        a2 = a2 * (1/x);
        
        wm = imresize(wm,[round(a2) round(b2)]);
        
    end
    
    
    if strcmp(str,'Top Left')
    elseif strcmp(str,'Top Right')
        h.Location = [(b - b2) 1];
    elseif strcmp(str,'Bottom Right')
        h.Location = [(b - b2) (a - a2)];
    elseif strcmp(str,'Bottom Left')
        h.Location = [1 (a - a2)];
    end
    
    h.Opacity = 0.5;
    for i = 1:length(img)
        C = step(h,img{i},wm);
        %         C = imadjust(C,[0 ],[0 1]);
        img{i} = C;
        imshow(img{i},'Parent',handles.axesCamera1);
        set(handles.editFrame,'String',num2str(i));
        set(handles.sliderLoadedVideo,'Value',i);
        drawnow();
    end
catch
    msgbox('Invalid image file for watermark');
end
imshow(img{1},'Parent',handles.axesCamera1);


% --- Executes on selection change in popupmenuWatermarkLocation.
function popupmenuWatermarkLocation_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuWatermarkLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuWatermarkLocation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuWatermarkLocation


% --- Executes during object creation, after setting all properties.
function popupmenuWatermarkLocation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuWatermarkLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebuttonIMGOrVid.
function togglebuttonIMGOrVid_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonIMGOrVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonIMGOrVid
val = get(handles.togglebuttonIMGOrVid,'Value');
if val == 1
    set(handles.togglebuttonIMGOrVid,'Background','g');
    set(handles.togglebuttonIMGOrVid,'String','IMG');
else
    set(handles.togglebuttonIMGOrVid,'Background','y');
    set(handles.togglebuttonIMGOrVid,'String','VidFrame');
end
