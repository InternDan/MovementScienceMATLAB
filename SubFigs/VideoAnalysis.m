function varargout = VideoAnalysis(varargin)
% VIDEOANALYSIS MATLAB code for VideoAnalysis.fig
%      VIDEOANALYSIS, by itself, creates a new VIDEOANALYSIS or raises the existing
%      singleton*.
%
%      H = VIDEOANALYSIS returns the handle to a new VIDEOANALYSIS or the handle to
%      the existing singleton*.
%
%      VIDEOANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIDEOANALYSIS.M with the given input arguments.
%
%      VIDEOANALYSIS('Property','Value',...) creates a new VIDEOANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VideoAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VideoAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VideoAnalysis

% Last Modified by GUIDE v2.5 26-Oct-2017 15:09:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @VideoAnalysis_OpeningFcn, ...
    'gui_OutputFcn',  @VideoAnalysis_OutputFcn, ...
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


% --- Executes just before VideoAnalysis is made visible.
function VideoAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VideoAnalysis (see VARARGIN)

% Choose default command line output for VideoAnalysis
handles.output = hObject;

handles.pathstr = getenv('USERPROFILE');
handles.pathstr = [handles.pathstr '\desktop'];
handles.isStoredVid = 0;
handles.isStill = 0;
handles.plot = 0;

handles.ct=1;
handles.ptType = cell(0);
handles.trackPoints = [];
handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 5,'BlockSize',[11 11],'MaxIterations',50,'NumPyramidLevels',4);
handles.pointTrackerisInitialized = 0;
handles.trailPoints = cell(0);
handles.onOff = 0;
handles.recordOnOff = 0;
handles.angles = cell(0);

handles.numClicked = 0;
handles.realTimeClickIndicator = 0;

handles.time = [];
handles.imgCurr = [];
handles.position = [];
handles.velocity = [];
handles.acceleration = [];
handles.angularVelocity = [];
handles.angularAcceleration = [];

for i = 1:100
    str{i} = num2str(i);
end
set(handles.popupmenuSetPointWeight,'String',str);
set(handles.popupmenuSetTrailingPointWeight,'String',str);
set(handles.popupmenuSetLineWeight,'String',str);
set(handles.popupmenuSetPointSize,'String',str);
set(handles.popupmenuSetTrailingPointSize,'String',str);

set(handles.popupmenuSetPointWeight,'Value',12);
set(handles.popupmenuSetTrailingPointWeight,'Value',5);
set(handles.popupmenuSetLineWeight,'Value',10);
set(handles.popupmenuSetPointSize,'Value',20);
set(handles.popupmenuSetTrailingPointSize,'Value',5);

set(handles.popupmenuSetPointColor,'Value',1);
set(handles.popupmenuSetTrailingPointColor,'Value',2);
set(handles.popupmenuSetLineColor,'Value',4);

set(handles.popupmenuTextColor,'Value',6);
set(handles.popupmenuTextSize,'String',str);
set(handles.popupmenuTextSize,'Value',50);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VideoAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VideoAnalysis_OutputFcn(hObject, eventdata, handles)
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
preview(handles.cam);
guidata(hObject, handles);


% --- Executes on button press in togglebuttonStream.
function togglebuttonStream_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonStream (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonStream

if handles.isStoredVid == 0
    handles.img = [];
    handles.time = [];
    handles.cp = [];
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

while handles.onOff == 1
    if handles.isStoredVid == 0%for streaming
        %time stamps
        if isempty(handles.time)
            handles.time = now;
        else
            handles.time = [handles.time now];
        end
        %grab a frame
        handles.imgCurr = snapshot(handles.cam);
       
        %check if the user wants to click a point to track
		if handles.realTimeClickIndicator == 1
			
            str = get(handles.popupmenuFeature,'String');
            val = get(handles.popupmenuFeature,'Value');
            feat = str{val};
			switch feat
				case 'Point'
        			imshow(handles.imgCurr,'Parent',handles.axesCamera1);
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
                    initialize(handles.pointTracker,handles.trackPoints,handles.imgCurr);
                    str = get(handles.popupmenuSetPointColor,'String');
                    val = get(handles.popupmenuSetPointColor,'Value');
                    color = str(val);
                    for i = 1:length(x)
                        handles.imgCurr = insertShape(handles.imgCurr,'circle',[handles.trackPoints(i,1) handles.trackPoints(i,2) get(handles.popupmenuSetPointSize,'Value')],'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
                    end
                    imshow(handles.imgCurr,'Parent',handles.axesCamera1);
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
                    initialize(handles.pointTracker,handles.trackPoints,handles.imgCurr);
                    str = get(handles.popupmenuSetPointColor,'String');
                    val = get(handles.popupmenuSetPointColor,'Value');
                    color = str(val);
                    for i = 1:length(x)
                        handles.imgCurr = insertShape(handles.imgCurr,'circle',[handles.trackPoints(i,1) handles.trackPoints(i,2) get(handles.popupmenuSetPointSize,'Value')],'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
                    end
                    str = get(handles.popupmenuSetLineColor,'String');
                    val = get(handles.popupmenuSetLineColor,'Value');
                    color = str(val);
                    handles.imgCurr = insertShape(handles.imgCurr,'line',[handles.trackPoints(1,1) handles.trackPoints(1,2) handles.trackPoints(2,1) handles.trackPoints(2,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color{1});
                    imshow(handles.imgCurr,'Parent',handles.axesCamera1);
                    handles.pointTrackerisInitialized = 1;
                    guidata(hObject, handles);
                    
            end
            
		handles.realTimeClickIndicator = 0;
        else
            if handles.pointTrackerisInitialized == 1
                handles = realTimeProcess(handles,eventdata,hObject);
            end
            imshow(handles.imgCurr,'Parent',handles.axesCamera1);
        end
        
        %store frame if record is pressed
        if get(handles.togglebuttonRecordVideo,'Value') == 1
            set(handles.togglebuttonRecordVideo,'BackgroundColor','r');
            if isempty(handles.img)
                handles.img{1} = handles.imgCurr;
            else
                handles.img{length(handles.img)+1} = handles.imgCurr;
            end
        else
            set(handles.togglebuttonRecordVideo,'BackgroundColor','g');
        end
        drawnow();
        handles.onOff = get(handles.togglebuttonStream,'Value');
        guidata(hObject, handles);
    else%for loaded videos
        handles.ct = get(handles.sliderLoadedVideo,'Value');
        guidata(hObject, handles);
        handles = processFrame(handles,eventdata,hObject);
        imshow(handles.img{handles.ct},'Parent',handles.axesCamera1);
        
        handles.ct = handles.ct + 1;
        if handles.ct <= length(handles.img)
            set(handles.sliderLoadedVideo,'Value',handles.ct);
            set(handles.textFrameNumber,'String',num2str(handles.ct));
        end
        drawnow();
        if handles.ct > length(handles.img)
            handles.onOff = 0;
        else
            handles.onOff = get(handles.togglebuttonStream,'Value');
        end
        
        guidata(hObject, handles);
    end
end

guidata(hObject, handles);

function [handles] = realTimeProcess(handles,eventdata,hObject)
handles.imgNext = snapshot(handles.cam);
handles.trackPoints = step(handles.pointTracker,handles.imgNext);
handles.trailPoints{length(handles.trailPoints)+1} = handles.trackPoints;

pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'p'))),:);
if ~isempty(pt)
    str = get(handles.popupmenuSetPointColor,'String');
    val = get(handles.popupmenuSetPointColor,'Value');
    color = str(val);
    clear ptPlot;
    for j = 1:length(pt(:,1))
        ptPlot(j,:) = [pt(j,:) get(handles.popupmenuSetPointSize,'Value')];
    end
    handles.imgNext = insertShape(handles.imgNext,'circle',ptPlot,'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
    str = get(handles.popupmenuSetTrailingPointColor,'String');
    val = get(handles.popupmenuSetTrailingPointColor,'Value');
    color = str(val);
    clear ptTrailPlot;
    c = 0;
    numTrailPts = str2num(get(handles.editTrailingPoints,'String'));
    if length(handles.trailPoints) <= numTrailPts && length(handles.trailPoints) > 0
        for j = 1:length(handles.trailPoints)
            for k = 1:length(handles.trailPoints{j}(:,1))
                c=c+1;
                ptTrailPlot(c,:) = [handles.trailPoints{j}(k,:) get(handles.popupmenuSetTrailingPointSize,'Value')];
            end
        end
    elseif length(handles.trailPoints) > numTrailPts
        c=0;
        for j = length(handles.trailPoints) - numTrailPts:length(handles.trailPoints)
            for k = 1:length(handles.trailPoints{j}(:,1))
                c=c+1;
                ptTrailPlot(c,:) = [handles.trailPoints{j}(k,:) get(handles.popupmenuSetTrailingPointSize,'Value')];
            end
        end
    end
    handles.imgNext = insertShape(handles.imgNext,'circle',ptTrailPlot,'LineWidth',get(handles.popupmenuSetTrailingPointSize,'Value'),'Color',color{1});
    guidata(hObject, handles);
end

pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'l'))),:);
if ~isempty(pt)
    str = get(handles.popupmenuSetPointColor,'String');
    val = get(handles.popupmenuSetPointColor,'Value');
    color = str(val);
    clear ptPlot;
    for j = 1:length(pt(:,1))
        ptPlot(j,:) = [pt(j,:) get(handles.popupmenuSetPointSize,'Value')];
    end
    handles.imgNext = insertShape(handles.imgNext,'circle',ptPlot,'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
    str = get(handles.popupmenuSetLineColor,'String');
    val = get(handles.popupmenuSetLineColor,'Value');
    color = str(val);
    for i = 1:2:length(pt)
        handles.imgNext = insertShape(handles.imgNext,'line',[pt(1,1) pt(1,2) pt(2,1) pt(2,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
    end
    guidata(hObject, handles);
end

%2 point angles
pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'2a'))),:);
if ~isempty(pt)
    str = get(handles.popupmenuSetPointColor,'String');
    val = get(handles.popupmenuSetPointColor,'Value');
    color = str(val);
    clear ptPlot;
    for j = 1:length(pt(:,1))
        ptPlot(j,:) = [pt(j,:) get(handles.popupmenuSetPointSize,'Value')];
    end
    handles.imgNext = insertShape(handles.imgNext,'circle',ptPlot,'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
    str = get(handles.popupmenuSetLineColor,'String');
    val = get(handles.popupmenuSetLineColor,'Value');
    color = str(val);
    for i = 1:2:length(pt)
        handles.imgNext = insertShape(handles.imgNext,'line',[pt(i,1) pt(i,2) pt(i+1,1) pt(i+1,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
        %calculate angle
        angle = atan((pt(i+1,2)-pt(i,2))/(pt(i+1,1)-pt(i,1)));
        if angle < 0
            angle = angle + pi;
        end
        angle = rad2deg(angle);
        handles.angles{length(handles.angles)+1} = angle;
        str = get(handles.popupmenuTextSize,'String');
        val = get(handles.popupmenuTextSize,'Value');
        sz = str{val};
        str = get(handles.popupmenuTextColor,'String');
        val = get(handles.popupmenuTextColor,'Value');
        color = str{val};
        handles.imgNext = insertText(handles.imgNext,[pt(i,1)+10,pt(i,2)+10],num2str(angle),'FontSize',str2num(sz),'TextColor',color);

    end
    guidata(hObject, handles);
end

%3 point angles
pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'3a'))),:);
if ~isempty(pt)
    str = get(handles.popupmenuSetPointColor,'String');
    val = get(handles.popupmenuSetPointColor,'Value');
    color = str(val);
    clear ptPlot;
    for j = 1:length(pt(:,1))
        ptPlot(j,:) = [pt(j,:) get(handles.popupmenuSetPointSize,'Value')];
    end
    handles.imgNext = insertShape(handles.imgNext,'circle',ptPlot,'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
    str = get(handles.popupmenuSetLineColor,'String');
    val = get(handles.popupmenuSetLineColor,'Value');
    color = str(val);
    for i = 1:3:length(pt)
        handles.imgNext = insertShape(handles.img{handles.ct},'line',[pt(i,1) pt(i,2) pt(i+1,1) pt(i+1,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
        handles.imgNext = insertShape(handles.img{handles.ct},'line',[pt(i,1) pt(i,2) pt(i+2,1) pt(i+2,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
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
        str = get(handles.popupmenuTextSize,'String');
        val = get(handles.popupmenuTextSize,'Value');
        sz = str{val};
        str = get(handles.popupmenuTextColor,'String');
        val = get(handles.popupmenuTextColor,'Value');
        color = str{val};
        handles.imgNext = insertText(handles.imgNext,[pt(i,1)+10,pt(i,2)+10],num2str(angle),'FontSize',str2num(sz),'TextColor',color);
        guidata(hObject, handles);
    end
end

pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'4a'))),:);
if ~isempty(pt)
    str = get(handles.popupmenuSetPointColor,'String');
    val = get(handles.popupmenuSetPointColor,'Value');
    color = str(val);
    clear ptPlot;
    for j = 1:length(pt(:,1))
        ptPlot(j,:) = [pt(j,:) get(handles.popupmenuSetPointSize,'Value')];
    end
    handles.imgNext = insertShape(handles.imgNext,'circle',ptPlot,'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
    str = get(handles.popupmenuSetLineColor,'String');
    val = get(handles.popupmenuSetLineColor,'Value');
    color = str(val);
    for i = 1:4:length(pt)
        handles.imgNext = insertShape(handles.img{handles.ct},'line',[pt(i,1) pt(i,2) pt(i+1,1) pt(i+1,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
        handles.imgNext = insertShape(handles.img{handles.ct},'line',[pt(i+2,1) pt(i+2,2) pt(i+3,1) pt(i+3,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
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
        str = get(handles.popupmenuTextSize,'String');
        val = get(handles.popupmenuTextSize,'Value');
        sz = str{val};
        str = get(handles.popupmenuTextColor,'String');
        val = get(handles.popupmenuTextColor,'Value');
        color = str{val};
        handles.imgNext = insertText(handles.imgNext,[pt(i,1)+10,pt(i,2)+10],num2str(angle),'FontSize',str2num(sz),'TextColor',color);
        guidata(hObject, handles);
    end
end
handles.imgCurr = handles.imgNext;
guidata(hObject, handles);
    

% --- Executes on button press in togglebuttonRecordVideo.
function togglebuttonRecordVideo_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonRecordVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonRecordVideo


% --- Executes on button press in pushbuttonSetFolder.
function pushbuttonSetFolder_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pathstr = uigetdir(pwd,'Please select the folder you wish to store videos in');
set(handles.textMovieFolder,'String',handles.pathstr);

guidata(hObject, handles);



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



switch feat
    case 'Point'
        %get clicked points
        [x y] = getpts(handles.axesCamera1);
        handles.position{1} = [x y];
        %fill label vector for which kind of points are being added
        if isempty(handles.ptType)
            handles.ptType(1:length(x)) = {'p'};
        elseif ~isempty(handles.ptType)
            handles.ptType(end+1:end+1+length(x)-1) = {'p'};
        end
        
        %append coordinates for points
        if ~isempty(handles.trackPoints)
            handles.trackPoints = [handles.trackPoints; [x y]];
        else
            handles.trackPoints = [x y];
        end
        [a b c] = size(handles.img{handles.ct});
        handles.trailPoints{1} = handles.trackPoints;
        handles.trailPoints{1}(:,2) = a - handles.trailPoints{1}(:,2);
        handles.position{1} = handles.trackPoints;
        handles.position{1}(:,2) = a - handles.position{1}(:,2);
        handles.velocity{1} = 0;
        handles.acceleration{1} = 0;
        handles.acceleration{2} = 0;
        
        %re-initialize tracker due to added points
        release(handles.pointTracker);
        try
            initialize(handles.pointTracker,handles.trackPoints,handles.img{handles.ct});
        catch
            initialize(handles.pointTracker,handles.trackPoints,handles.imgCurr);
        end
        str = get(handles.popupmenuSetPointColor,'String');
        val = get(handles.popupmenuSetPointColor,'Value');
        color = str(val);
        if handles.isStoredVid == 0 || handles.isStill == 1
            for i = 1:length(x)
                handles.imgCurr = insertShape(handles.imgCurr,'circle',[x(i) y(i) get(handles.popupmenuSetPointSize,'Value')],'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
            end
            imshow(handles.imgCurr,'Parent',handles.axesCamera1);
            
        else
            for i = 1:length(x)
                handles.img{handles.ct} = insertShape(handles.img{handles.ct},'circle',[x(i) y(i) get(handles.popupmenuSetPointSize,'Value')],'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
            end
            imshow(handles.img{handles.ct},'Parent',handles.axesCamera1);
            
        end
        handles.pointTrackerisInitialized = 1;
        guidata(hObject, handles);
        
    case '2-Point Line'
        %get 2 points explicitly
        [x y] = getpts(handles.axesCamera1,2);
        
        %fill label vector for which kind of points are being added
        if isempty(handles.ptType)
            handles.ptType(1:length(x)) = {'l'};
        elseif ~isempty(handles.ptType)
            handles.ptType(end+1:end+1+length(x)-1) = {'l'};
        end
        
        %append coordinates for points
        if ~isempty(handles.trackPoints)
            handles.trackPoints = [handles.trackPoints; [x y]];
        else
            handles.trackPoints = [x y];
        end
        
        %re-initialize tracker due to added points
        release(handles.pointTracker);
        try
            initialize(handles.pointTracker,handles.trackPoints,handles.img{handles.ct});
        catch
            initialize(handles.pointTracker,handles.trackPoints,handles.imgCurr);
        end
        
        str = get(handles.popupmenuSetPointColor,'String');
        val = get(handles.popupmenuSetPointColor,'Value');
        color = str(val);
        if handles.isStoredVid == 0 || handles.isStill == 1
            for i = 1:length(x)
                handles.imgCurr = insertShape(handles.imgCurr,'circle',[x(i) y(i) get(handles.popupmenuSetPointSize,'Value')],'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
            end
        else
            for i = 1:length(x)
                handles.img{handles.ct} = insertShape(handles.img{handles.ct},'circle',[x(i) y(i) get(handles.popupmenuSetPointSize,'Value')],'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
            end
        end
        str = get(handles.popupmenuSetLineColor,'String');
        val = get(handles.popupmenuSetLineColor,'Value');
        color = str(val);
        
        if handles.isStoredVid == 0 || handles.isStill == 1
            handles.imgCurr = insertShape(handles.imgCurr,'line',[x(1) y(1) x(2) y(2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color{1});
            imshow(handles.imgCurr,'Parent',handles.axesCamera1);
            
        else
            handles.img{handles.ct} = insertShape(handles.img{handles.ct},'line',[x(1) y(1) x(2) y(2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color{1});
            imshow(handles.img{handles.ct},'Parent',handles.axesCamera1);
            
        end
        
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
        try
            initialize(handles.pointTracker,handles.trackPoints,handles.img{handles.ct});
        catch
            initialize(handles.pointTracker,handles.trackPoints,handles.imgCurr);
        end
        
        %plot points and line
        str = get(handles.popupmenuSetPointColor,'String');
        val = get(handles.popupmenuSetPointColor,'Value');
        color = str(val);
        if handles.isStoredVid == 0 || handles.isStill == 1
            for i = 1:length(x)
                handles.imgCurr = insertShape(handles.imgCurr,'circle',[x(i) y(i) get(handles.popupmenuSetPointSize,'Value')],'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
            end
        else
            for i = 1:length(x)
                handles.img{handles.ct} = insertShape(handles.img{handles.ct},'circle',[x(i) y(i) get(handles.popupmenuSetPointSize,'Value')],'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
            end
        end
        str = get(handles.popupmenuSetLineColor,'String');
        val = get(handles.popupmenuSetLineColor,'Value');
        color = str(val);
        if handles.isStoredVid == 0 || handles.isStill == 1
            handles.imgCurr = insertShape(handles.imgCurr,'line',[x(1) y(1) x(2) y(2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
            imshow(handles.imgCurr,'Parent',handles.axesCamera1);
            
        else
            handles.img{handles.ct} = insertShape(handles.img{handles.ct},'line',[x(1) y(1) x(2) y(2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
            imshow(handles.img{handles.ct},'Parent',handles.axesCamera1);
            
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
            str = get(handles.popupmenuTextSize,'String');
            val = get(handles.popupmenuTextSize,'Value');
            sz = str{val};
            str = get(handles.popupmenuTextColor,'String');
            val = get(handles.popupmenuTextColor,'Value');
            color = str{val};
            handles.imgCurr = insertText(handles.imgCurr,[x(1)+10,y(1)+10],num2str(angle),'FontSize',str2num(sz),...
                'TextColor',color);
            imshow(handles.imgCurr,'Parent',handles.axesCamera1);
            
        else
            str = get(handles.popupmenuTextSize,'String');
            val = get(handles.popupmenuTextSize,'Value');
            sz = str{val};
            str = get(handles.popupmenuTextColor,'String');
            val = get(handles.popupmenuTextColor,'Value');
            color = str{val};
            str = get(handles.popupmenuTextSize,'String');
            val = get(handles.popupmenuTextSize,'Value');
            handles.img{handles.ct} = insertText(handles.img{handles.ct},[x(1)+10,y(1)+10],num2str(angle),...
                'FontSize',str2num(sz),'TextColor',color);
            imshow(handles.img{handles.ct},'Parent',handles.axesCamera1);
            
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
        try
            initialize(handles.pointTracker,handles.trackPoints,handles.img{handles.ct});
        catch
            initialize(handles.pointTracker,handles.trackPoints,handles.imgCurr);
        end
        
        %plot points and line
        str = get(handles.popupmenuSetPointColor,'String');
        val = get(handles.popupmenuSetPointColor,'Value');
        color = str(val);
        if handles.isStoredVid == 0 || handles.isStill == 1
            for i = 1:length(x)
                handles.imgCurr = insertShape(handles.imgCurr,'circle',[x(i) y(i) get(handles.popupmenuSetPointSize,'Value')],'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
            end
        else
            for i = 1:length(x)
                handles.img{handles.ct} = insertShape(handles.img{handles.ct},'circle',[x(i) y(i) get(handles.popupmenuSetPointSize,'Value')],'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
            end
        end
        str = get(handles.popupmenuSetLineColor,'String');
        val = get(handles.popupmenuSetLineColor,'Value');
        color = str(val);
        
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
            handles.imgCurr = insertShape(handles.imgCurr,'line',[x(1) y(1) x(2) y(2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
            handles.imgCurr = insertShape(handles.imgCurr,'line',[x(1) y(1) x(3) y(3)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
        else
            handles.img{handles.ct} = insertShape(handles.img{handles.ct},'line',[x(1) y(1) x(2) y(2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
            handles.img{handles.ct} = insertShape(handles.img{handles.ct},'line',[x(1) y(1) x(3) y(3)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
        end
        
        if handles.isStoredVid == 0 || handles.isStill == 1
            str = get(handles.popupmenuTextSize,'String');
            val = get(handles.popupmenuTextSize,'Value');
            sz = str{val};
            str = get(handles.popupmenuTextColor,'String');
            val = get(handles.popupmenuTextColor,'Value');
            color = str{val};
            handles.imgCurr = insertText(handles.imgCurr,[x(1)+10,y(1)+10],num2str(angle),...
                'FontSize',str2num(sz),'TextColor',color);
            imshow(handles.imgCurr,'Parent',handles.axesCamera1);
            
        else
            str = get(handles.popupmenuTextSize,'String');
            val = get(handles.popupmenuTextSize,'Value');
            sz = str{val};
            str = get(handles.popupmenuTextColor,'String');
            val = get(handles.popupmenuTextColor,'Value');
            color = str{val};
            handles.img{handles.ct} = insertText(handles.img{handles.ct},[x(1)+10,y(1)+10],num2str(angle),...
                'FontSize',str2num(sz),'TextColor',color);
            imshow(handles.img{handles.ct},'Parent',handles.axesCamera1);
            
        end
        
        handles.pointTrackerisInitialized = 1;
        guidata(hObject, handles);
        
    case '4-Point Angle'
        %get 4 points explicitly
        [x y] = getpts(handles.axesCamera1,4);
        
        %fill label vector for which kind of points are being added
        if isempty(handles.ptType)
            handles.ptType(1:length(x)) = {'4a'};
        elseif ~isempty(handles.ptType)
            handles.ptType(end+1:end+1+length(x)-1) = {'4a'};
        end
        
        %append coordinates for points
        if ~isempty(handles.trackPoints)
            handles.trackPoints = [handles.trackPoints; [x y]];
        else
            handles.trackPoints = [x y];
        end
        
        %re-initialize tracker due to added points
        release(handles.pointTracker);
        try
            initialize(handles.pointTracker,handles.trackPoints,handles.img{handles.ct});
        catch
            initialize(handles.pointTracker,handles.trackPoints,handles.imgCurr);
        end
        
        %plot points and line
        str = get(handles.popupmenuSetPointColor,'String');
        val = get(handles.popupmenuSetPointColor,'Value');
        color = str(val);
        if handles.isStoredVid == 0 || handles.isStill == 1
            for i = 1:length(x)
                handles.imgCurr = insertShape(handles.imgCurr,'circle',[x(i) y(i) get(handles.popupmenuSetPointSize,'Value')],'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
            end
        else
            for i = 1:length(x)
                handles.img{handles.ct} = insertShape(handles.img{handles.ct},'circle',[x(i) y(i) get(handles.popupmenuSetPointSize,'Value')],'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
            end
        end
        str = get(handles.popupmenuSetLineColor,'String');
        val = get(handles.popupmenuSetLineColor,'Value');
        color = str(val);
        if handles.isStoredVid == 0 || handles.isStill == 1
            handles.imgCurr = insertShape(handles.imgCurr,'line',[x(1) y(1) x(2) y(2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
            handles.imgCurr = insertShape(handles.imgCurr,'line',[x(3) y(3) x(4) y(4)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
        else
            handles.img{handles.ct} = insertShape(handles.img{handles.ct},'line',[x(1) y(1) x(2) y(2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
            handles.img{handles.ct} = insertShape(handles.img{handles.ct},'line',[x(3) y(3) x(4) y(4)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
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
            str = get(handles.popupmenuTextSize,'String');
            val = get(handles.popupmenuTextSize,'Value');
            sz = str{val};
            str = get(handles.popupmenuTextColor,'String');
            val = get(handles.popupmenuTextColor,'Value');
            color = str{val};
            handles.imgCurr = insertText(handles.imgCurr,[x(1)+10,y(1)+10],num2str(angle),...
                'FontSize',str2num(sz),'TextColor',color);
            imshow(handles.imgCurr,'Parent',handles.axesCamera1);
            
        else
            str = get(handles.popupmenuTextSize,'String');
            val = get(handles.popupmenuTextSize,'Value');
            sz = str{val};
            str = get(handles.popupmenuTextColor,'String');
            val = get(handles.popupmenuTextColor,'Value');
            color = str{val};
            handles.img{handles.ct} = insertText(handles.img{handles.ct},[x(1)+10,y(1)+10],num2str(angle),...
                'FontSize',str2num(sz),'TextColor',color);
            imshow(handles.img{handles.ct},'Parent',handles.axesCamera1);
            
        end
        
        handles.pointTrackerisInitialized = 1;
        guidata(hObject, handles);
       
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
[handles.vidStr handles.pathstr] = uigetfile(fullfile(handles.pathstr, '*.*'),'Please select the video file of interest');
release(handles.pointTracker);
handles.v = VideoReader(fullfile(handles.pathstr,handles.vidStr));
handles.vidInfo = get(handles.v);
handles.isStill = 0;

handles.pointTrackerisInitialized = 0;
ct=0;
clear handles.img handles.vidTimes;
% handles.img = cell(0);
set(handles.togglebuttonStream,'BackgroundColor','g');
set(handles.togglebuttonStream,'Value',0);
while hasFrame(handles.v)
    ct=ct+1;
    handles.img{ct} = readFrame(handles.v);
    set(handles.textFrameNumber,'String',num2str(ct));
    drawnow();
end
for i = 1:ct
    if i == 1
        handles.vidTimes(i) = 0;
    else
        handles.vidTimes(i) = handles.vidTimes(i-1) + (1/handles.vidInfo.FrameRate);
    end
end

% handles.imgOrig = handles.img;
set(handles.sliderLoadedVideo,'Value',1);
set(handles.sliderLoadedVideo,'min',1);
set(handles.sliderLoadedVideo,'max',ct);
set(handles.sliderLoadedVideo,'SliderStep',[1,1]/(ct-1));
set(handles.textFrameNumber,'String','1');
drawnow();
imshow(handles.img{1},'Parent',handles.axesCamera1);

handles.isStoredVid = 1;
guidata(hObject, handles);


% --- Executes on slider movement.
function sliderLoadedVideo_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLoadedVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.ct = round(get(handles.sliderLoadedVideo,'Value'));
set(handles.textFrameNumber,'String',num2str(handles.ct));
imshow(handles.img{handles.ct},'Parent',handles.axesCamera1);

if ~isempty(get(handles.axesGraph,'Children'))
    ax = handles.axesGraph;
    yLim = ax.YLim;
    hold('on',handles.axesGraph);
    set(handles.hLine,'XData',[handles.vidTimes(handles.ct) handles.vidTimes(handles.ct)],'YData',yLim,'Color','r'); 
    hold('off',handles.axesGraph);
    drawnow();
end
    
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


% --- Executes on button press in pushbuttonSetAsFirstFrame.
function pushbuttonSetAsFirstFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetAsFirstFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.img = handles.img(round(get(handles.sliderLoadedVideo,'Value')):end);
handles.vidTimes = handles.vidTimes(round(get(handles.sliderLoadedVideo,'Value')):end);
imshow(handles.img{1},'Parent',handles.axesCamera1);

set(handles.sliderLoadedVideo,'Value',1);
set(handles.sliderLoadedVideo,'min',1);
set(handles.sliderLoadedVideo,'max',length(handles.img));
set(handles.sliderLoadedVideo,'SliderStep',[1,1]/(length(handles.img)-1));
set(handles.textFrameNumber,'String','1');
guidata(hObject, handles);

% --- Executes on button press in pushbuttonSetAsLastFrame.
function pushbuttonSetAsLastFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetAsLastFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.img = handles.img(1:round(get(handles.sliderLoadedVideo,'Value')));
handles.vidTimes = handles.vidTimes(1:round(get(handles.sliderLoadedVideo,'Value')));
imshow(handles.img{end},'Parent',handles.axesCamera1);

set(handles.sliderLoadedVideo,'Value',length(handles.img));
set(handles.sliderLoadedVideo,'min',1);
set(handles.sliderLoadedVideo,'max',length(handles.img));
set(handles.sliderLoadedVideo,'SliderStep',[1,1]/(length(handles.img)-1));
set(handles.textFrameNumber,'String',num2str(length(handles.img)));
guidata(hObject, handles);

% --- Executes on selection change in popupmenuSetPointWeight.
function popupmenuSetPointWeight_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSetPointWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSetPointWeight contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSetPointWeight


% --- Executes during object creation, after setting all properties.
function popupmenuSetPointWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSetPointWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuSetTrailingPointWeight.
function popupmenuSetTrailingPointWeight_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSetTrailingPointWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSetTrailingPointWeight contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSetTrailingPointWeight


% --- Executes during object creation, after setting all properties.
function popupmenuSetTrailingPointWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSetTrailingPointWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuSetLineWeight.
function popupmenuSetLineWeight_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSetLineWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSetLineWeight contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSetLineWeight


% --- Executes during object creation, after setting all properties.
function popupmenuSetLineWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSetLineWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTextSize_Callback(hObject, eventdata, handles)
% hObject    handle to editTextSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTextSize as text
%        str2double(get(hObject,'String')) returns contents of editTextSize as a double


% --- Executes during object creation, after setting all properties.
function editTextSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTextSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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


% --- Executes on selection change in popupmenuSetPointSize.
function popupmenuSetPointSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSetPointSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSetPointSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSetPointSize

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





% --- Executes during object creation, after setting all properties.
function popupmenuSetPointSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSetPointSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuSetTrailingPointSize.
function popupmenuSetTrailingPointSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSetTrailingPointSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSetTrailingPointSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSetTrailingPointSize


% --- Executes during object creation, after setting all properties.
function popupmenuSetTrailingPointSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSetTrailingPointSize (see GCBO)
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
handles.trackPoints = [];
handles.trailPoints = [];
handles.ptType = cell(0);
handles.position = [];
handles.velocity = [];
handles.acceleration = [];
handles.angles = [];
handles.angularVelocity = [];
handles.angularAcceleration = [];
handles.v = VideoReader(fullfile(handles.pathstr,handles.vidStr));
handles.vidInfo = get(handles.v);
handles.pointTrackerisInitialized = 0;
ct=0;
clear handles.img handles.vidTimes;
% handles.img = cell(0);
set(handles.togglebuttonStream,'BackgroundColor','g');
set(handles.togglebuttonStream,'Value',0);
while hasFrame(handles.v)
    ct=ct+1;
    handles.img{ct} = readFrame(handles.v);
    set(handles.textFrameNumber,'String',num2str(ct));
    drawnow();
end
try
    for i = 1:length(handles.img)
        if i == 1
            handles.vidTimes(i) = 0;
        else
            handles.vidTimes(i) = handles.vidTimes(i-1) + (1/handles.vidInfo.FrameRate);
        end
    end
catch
end
handles.plot = 0;
cla(handles.axesGraph);
release(handles.pointTracker);
handles.pointTrackerisInitialized = 0;
try
    if handles.isStoredVid == 0
        imshow(snapshot(handles.cam));
    end
%     handles.img = handles.imgOrig;
    handles.time = [];
    handles.ct = 1;
    set(handles.sliderLoadedVideo,'Value',1);
    set(handles.sliderLoadedVideo,'min',1);
    set(handles.sliderLoadedVideo,'max',length(handles.img));
    set(handles.sliderLoadedVideo,'SliderStep',[1,1]/(length(handles.img)-1));
    set(handles.textFrameNumber,'String','1');
    drawnow();
    imshow(handles.img{get(handles.sliderLoadedVideo,'Value')},'Parent',handles.axesCamera1);
catch
    try
        handles.imgCurr = handles.imgCurrOrig;
    catch
    end
    imshow(handles.imgCurr,'Parent',handles.axesCamera1);
    
end
guidata(hObject, handles);

% --- Executes on button press in pushbuttonRotateVideo.
function pushbuttonRotateVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRotateVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i = 1:length(handles.img)
    handles.img{i} = imrotate(handles.img{i},str2num(get(handles.editRotateDegrees,'String')));
    set(handles.textFrameNumber,'String',num2str(i));
    drawnow();
end
imshow(handles.img{handles.ct},'Parent',handles.axesCamera1);

set(handles.textFrameNumber,'String',num2str(handles.ct));

guidata(hObject, handles);





% --- Executes on button press in pushbuttonCrop.
function pushbuttonCrop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[j rect] = imcrop(handles.img{1});
for i = 1:length(handles.img)
    handles.img{i} = imcrop(handles.img{i},rect);
    set(handles.textFrameNumber,'String',num2str(i));
    drawnow();
end
imshow(handles.img{handles.ct},'Parent',handles.axesCamera1);

set(handles.textFrameNumber,'String',num2str(handles.ct));

guidata(hObject, handles);

function [handles] = processFrame(handles,eventdata,hObject)
%%contains logic for processing and drawing on image
if handles.ct < length(handles.img) && ~isempty(handles.trackPoints)
    handles.trackPoints = step(handles.pointTracker,handles.img{handles.ct+1});
    [a b c] = size(handles.img{handles.ct+1});
    handles.trackPoints(:,2) = a - handles.trackPoints(:,2);
    handles.trailPoints{length(handles.trailPoints)+1} = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'p'))),:);
end

%check to see if anything needs to be drawn
if ~isempty(handles.trackPoints)
    
    %plot current just points
    pt = [];
    pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'p'))),:);
    [a b c] = size(handles.img{handles.ct});
    if ~isempty(pt)
        pt(:,2) = a - pt(:,2); 
        str = get(handles.popupmenuSetPointColor,'String');
        val = get(handles.popupmenuSetPointColor,'Value');
        color = str(val);
        clear ptPlot;
        for j = 1:length(pt(:,1))
            ptPlot(j,:) = [pt(j,:) get(handles.popupmenuSetPointSize,'Value')];
        end
        handles.img{handles.ct} = insertShape(handles.img{handles.ct},'circle',ptPlot,'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
        %plot trailing points
        str = get(handles.popupmenuSetTrailingPointColor,'String');
        val = get(handles.popupmenuSetTrailingPointColor,'Value');
        color = str(val);
        clear ptTrailPlot;
        c = 0;
        numTrailPts = str2num(get(handles.editTrailingPoints,'String'));
        if length(handles.trailPoints) <= numTrailPts && length(handles.trailPoints) > 0
            for j = 1:length(handles.trailPoints)
                for k = 1:length(handles.trailPoints{j}(:,1))
                    c=c+1;
                    ptTrailPlot(c,:) = [handles.trailPoints{j}(k,:) get(handles.popupmenuSetTrailingPointSize,'Value')];
                    ptTrailPlot(c,2) = a - ptTrailPlot(c,2); 
                end
            end
        elseif length(handles.trailPoints) > numTrailPts
            c=0;
            for j = length(handles.trailPoints) - numTrailPts:length(handles.trailPoints)
                for k = 1:length(handles.trailPoints{j}(:,1))
                    c=c+1;
                    ptTrailPlot(c,:) = [handles.trailPoints{j}(k,:) get(handles.popupmenuSetTrailingPointSize,'Value')];
                    ptTrailPlot(c,2) = a - ptTrailPlot(c,2);
                end
            end
        end
        handles.img{handles.ct} = insertShape(handles.img{handles.ct},'circle',ptTrailPlot,'LineWidth',get(handles.popupmenuSetTrailingPointSize,'Value'),'Color',color{1});
        %calculate position, velocity, and acceleration
        
        if handles.ct == 1
            handles.position{1} = handles.trailPoints{1};
        else
            handles.position{handles.ct} = handles.trackPoints;
        end
        handles.ct
        if handles.ct > 1
            for i = 1:length(pt(:,1))
                handles.velocity{handles.ct}(i,1) = (handles.position{handles.ct}(i,1) - handles.position{handles.ct-1}(i,1)) / (handles.vidTimes(handles.ct) - handles.vidTimes(handles.ct-1));
                handles.velocity{handles.ct}(i,2) = (handles.position{handles.ct}(i,2) - handles.position{handles.ct-1}(i,2)) / (handles.vidTimes(handles.ct) - handles.vidTimes(handles.ct-1));
                if handles.ct > 2
                    handles.acceleration{handles.ct}(i,1) = (handles.velocity{handles.ct}(i,1) - handles.velocity{handles.ct-1}(i,1)) / (handles.vidTimes(handles.ct) - handles.vidTimes(handles.ct-1));
                    handles.acceleration{handles.ct}(i,2) = (handles.velocity{handles.ct}(i,2) - handles.velocity{handles.ct-1}(i,2)) / (handles.vidTimes(handles.ct) - handles.vidTimes(handles.ct-1));
                end
            end
        end
        %
        guidata(hObject, handles);
    end
    
    pt = [];
    %2 point lines
    pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'l'))),:);
    if ~isempty(pt)
        pt(:,2) = a - pt(:,2);
        str = get(handles.popupmenuSetPointColor,'String');
        val = get(handles.popupmenuSetPointColor,'Value');
        color = str(val);
        clear ptPlot;
        for j = 1:length(pt(:,1))
            ptPlot(j,:) = [pt(j,:) get(handles.popupmenuSetPointSize,'Value')];
        end
        handles.img{handles.ct} = insertShape(handles.img{handles.ct},'circle',ptPlot,'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
        str = get(handles.popupmenuSetLineColor,'String');
        val = get(handles.popupmenuSetLineColor,'Value');
        color = str(val);
        for i = 1:2:length(pt)
            handles.img{handles.ct} = insertShape(handles.img{handles.ct},'line',[pt(1,1) pt(1,2) pt(2,1) pt(2,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
        end
    end
    
    
    %2 point angles
    pt = [];
    pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'2a'))),:);
    if ~isempty(pt)
        pt(:,2) = a - pt(:,2);
        str = get(handles.popupmenuSetPointColor,'String');
        val = get(handles.popupmenuSetPointColor,'Value');
        color = str(val);
        clear ptPlot;
        for j = 1:length(pt(:,1))
            ptPlot(j,:) = [pt(j,:) get(handles.popupmenuSetPointSize,'Value')];
        end
        handles.img{handles.ct} = insertShape(handles.img{handles.ct},'circle',ptPlot,'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
        str = get(handles.popupmenuSetLineColor,'String');
        val = get(handles.popupmenuSetLineColor,'Value');
        color = str(val);
        for i = 1:2:length(pt)
            handles.img{handles.ct} = insertShape(handles.img{handles.ct},'line',[pt(i,1) pt(i,2) pt(i+1,1) pt(i+1,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
            %calculate angle
            angle = atan((pt(i+1,2)-pt(i,2))/(pt(i+1,1)-pt(i,1)));
            if angle < 0
                angle = angle + pi;
            end
            angle = rad2deg(angle);
            handles.angles{length(handles.angles)+1} = angle;
            str = get(handles.popupmenuTextSize,'String');
            val = get(handles.popupmenuTextSize,'Value');
            sz = str{val};
            str = get(handles.popupmenuTextColor,'String');
            val = get(handles.popupmenuTextColor,'Value');
            color = str{val};
            handles.img{handles.ct} = insertText(handles.img{handles.ct},[pt(i,1)+10,pt(i,2)+10],num2str(angle),'FontSize',str2num(sz),'TextColor',color);
            
        end
        
    end
    
    
    %3 point angles
    pt=[];
    pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'3a'))),:);
    if ~isempty(pt)
        pt(:,2) = a - pt(:,2);
        str = get(handles.popupmenuSetPointColor,'String');
        val = get(handles.popupmenuSetPointColor,'Value');
        color = str(val);
        clear ptPlot;
        for j = 1:length(pt(:,1))
            ptPlot(j,:) = [pt(j,:) get(handles.popupmenuSetPointSize,'Value')];
        end
        handles.img{handles.ct} = insertShape(handles.img{handles.ct},'circle',ptPlot,'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
        str = get(handles.popupmenuSetLineColor,'String');
        val = get(handles.popupmenuSetLineColor,'Value');
        color = str(val);
        for i = 1:3:length(pt)
            handles.img{handles.ct} = insertShape(handles.img{handles.ct},'line',[pt(i,1) pt(i,2) pt(i+1,1) pt(i+1,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
            handles.img{handles.ct} = insertShape(handles.img{handles.ct},'line',[pt(i,1) pt(i,2) pt(i+2,1) pt(i+2,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
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
            str = get(handles.popupmenuTextSize,'String');
            val = get(handles.popupmenuTextSize,'Value');
            sz = str{val};
            str = get(handles.popupmenuTextColor,'String');
            val = get(handles.popupmenuTextColor,'Value');
            color = str{val};
            handles.img{handles.ct} = insertText(handles.img{handles.ct},[pt(i,1)+10,pt(i,2)+10],num2str(angle),'FontSize',str2num(sz),'TextColor',color);
        end
    end
    
    %4 point angles
    pt = [];
    pt = handles.trackPoints(find(~cellfun(@isempty,strfind(handles.ptType,'4a'))),:);
    if ~isempty(pt)
        pt(:,2) = a - pt(:,2);
        str = get(handles.popupmenuSetPointColor,'String');
        val = get(handles.popupmenuSetPointColor,'Value');
        color = str(val);
        clear ptPlot;
        for j = 1:length(pt(:,1))
            ptPlot(j,:) = [pt(j,:) get(handles.popupmenuSetPointSize,'Value')];
        end
        handles.img{handles.ct} = insertShape(handles.img{handles.ct},'circle',ptPlot,'LineWidth',get(handles.popupmenuSetPointWeight,'Value'),'Color',color);
        str = get(handles.popupmenuSetLineColor,'String');
        val = get(handles.popupmenuSetLineColor,'Value');
        color = str(val);
        for i = 1:4:length(pt)
            handles.img{handles.ct} = insertShape(handles.img{handles.ct},'line',[pt(i,1) pt(i,2) pt(i+1,1) pt(i+1,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
            handles.img{handles.ct} = insertShape(handles.img{handles.ct},'line',[pt(i+2,1) pt(i+2,2) pt(i+3,1) pt(i+3,2)],'LineWidth',get(handles.popupmenuSetLineWeight,'Value'),'Color',color);
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
            str = get(handles.popupmenuTextSize,'String');
            val = get(handles.popupmenuTextSize,'Value');
            sz = str{val};
            str = get(handles.popupmenuTextColor,'String');
            val = get(handles.popupmenuTextColor,'Value');
            color = str{val};
            handles.img{handles.ct} = insertText(handles.img{handles.ct},[pt(i,1)+10,pt(i,2)+10],num2str(angle),'FontSize',str2num(sz),'TextColor',color);
        end
    end
    
    
end
guidata(hObject, handles);

% --- Executes on button press in pushbuttonGrabKeyFrame.
function pushbuttonGrabKeyFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonGrabKeyFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imgCurr = getimage(handles.axesCamera1);
handles.isStill = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbuttonSaveKeyFrame.
function pushbuttonSaveKeyFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveKeyFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imgCurr = getimage(handles.axesCamera1);
fName = fullfile(handles.pathstr,[get(handles.editImageName,'String') '.png']);
if exist(fName,'file') == 2
    fName = [datestr(now) fName];
end
imwrite(handles.imgCurr,fName);


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
[handles.imgCurr] = drawScribbleGUI(handles.axesCamera1,handles,eventdata,hObject);
imshow(handles.imgCurr,'Parent',handles.axesCamera1);
drawnow();

guidata(hObject, handles);


% --- Executes on button press in pushbuttonAddAnnotation.
function pushbuttonAddAnnotation_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddAnnotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(handles.popupmenuAnnotations,'String');
val = get(handles.popupmenuAnnotations,'Value');

ann = str{val};

switch ann
    case 'TextBox'
        pt = getTextBoxLocation(hObject, eventdata, handles);
        text1 = inputdlg('Please enter the text you''d like in the textbox');
        val = get(handles.popupmenuTextSize,'Value');
        str = get(handles.popupmenuTextSize,'String');
        sz = str2num(str{val});
        val = get(handles.popupmenuTextColor,'Value');
        str = get(handles.popupmenuTextColor,'String');
        color = str{val};
        val = get(handles.popupmenuSetObjectColor,'Value');
        str = get(handles.popupmenuSetObjectColor,'String');
        boxColor = str{val};
        [aa bb cc] = size(getimage(handles.axesCamera1));
        img = getimage(handles.axesCamera1);
        img = insertText(img,[pt(1),pt(2)],text1{1},'FontSize',sz,'TextColor',color,'BoxOpacity',0.3,'BoxColor',boxColor);
        handles.imgCurr = img;
        imshow(handles.imgCurr,'Parent',handles.axesCamera1);
        
        drawnow();
        
        guidata(hObject, handles);
        
    case 'Arrow'
        str = get(handles.popupmenuSetObjectColor,'String');
        val = get(handles.popupmenuSetObjectColor,'Value');
        color = str{val};
        str = get(handles.popupmenuSetLineWeight,'String');
        val = get(handles.popupmenuSetLineWeight,'Value');
        wt = str2num(str{val});
        
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
        [handles.imgCurr] = drawCircleGUI(handles.axesCamera1,handles,eventdata,hObject);
        imshow(handles.imgCurr,'Parent',handles.axesCamera1);
        
        drawnow();
        
        guidata(hObject, handles);
        
    case 'Rectangle'
        [handles.imgCurr] = drawRectGUI(handles.axesCamera1,handles,eventdata,hObject);
        imshow(handles.imgCurr,'Parent',handles.axesCamera1);
        
        drawnow();
        
        guidata(hObject, handles);
        
        
        
        
end

function pt = getTextBoxLocation(hObject, eventdata, handles)
h = msgbox('Please click where you''d like your textbox');
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
[handles.file handles.pathstr] = uigetfile('*.*','Please select an image to load');
handles.imgCurr = imread(fullfile(handles.pathstr,handles.file));
imshow(handles.imgCurr,'Parent',handles.axesCamera1);

handles.imgCurrOrig = handles.imgCurr;
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
        plotY = plotY(1:length(handles.img));
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

plot(handles.axesGraph,plotX,plotY);
ax = handles.axesGraph;
yLim = ax.YLim;
handles.hLine = line(handles.axesGraph,[handles.vidTimes(end) handles.vidTimes(end)],yLim,'Color','r');
set(handles.textGraphTitle,'String',[xItem '-' yItem]);
handles.plot = 1;
drawnow();
guidata(hObject, handles);


% --- Executes on button press in pushbuttonWriteTrackedVideo.
function pushbuttonWriteTrackedVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonWriteTrackedVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.vidStr = get(handles.editMovieName,'String');
if exist(fullfile(handles.pathstr,[handles.vidStr '.mp4']),'file') == 2
    handles.vidStr = [handles.vidStr '-next'];
end
handles.aviObj = VideoWriter([fullfile(handles.pathstr,handles.vidStr)],'MPEG-4');
open(handles.aviObj);
for i = 1:length(handles.img)
    writeVideo(handles.aviObj,im2frame(handles.img{i}));
end
close(handles.aviObj);


% --- Executes on button press in pushbuttonExportTrackedValues.
function pushbuttonExportTrackedValues_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExportTrackedValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
header = {'Movie Name','Frame Number','Time'};
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
textOutName = fullfile(handles.pathstr,[handles.vidStr(1:end-4) '-' get(handles.editExportFileName,'String') '.txt']);
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

        


% --- Executes on button press in pushbuttonSetTrackingSearchRadius.
function pushbuttonSetTrackingSearchRadius_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetTrackingSearchRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(handles.popupmenuTrackingSearchRadius,'String');
val = get(handles.popupmenuTrackingSearchRadius,'Value');
sz = str2num(str{val});
handles.pointTracker = vision.PointTracker('BlockSize',[sz sz],'MaxBidirectionalError',5,'MaxIterations',50,'NumPyramidLevels',4);
guidata(hObject, handles);

% --- Executes on selection change in popupmenuTrackingSearchRadius.
function popupmenuTrackingSearchRadius_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTrackingSearchRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTrackingSearchRadius contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTrackingSearchRadius


% --- Executes during object creation, after setting all properties.
function popupmenuTrackingSearchRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTrackingSearchRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonPlayVideo.
function pushbuttonPlayVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlayVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pc = computer;
if strcmp(pc,'PCWIN64') == 1
    try
        pth = getenv('USERPROFILE');
        pth = [pth '\Documents'];
        sysLine = [' md ' pth '\MovementScience'];
        pth = [pth '\MovementScience'];
        system(sysLine);
        w = VideoWriter([pth '\tmp'],'Uncompressed AVI');
        w.FrameRate = handles.v.FrameRate;
        open(w);
        h = msgbox('Writing temporary video');
        for i = 1:length(handles.img)
            set(handles.textFrameNumber,'String',num2str(i));
            drawnow();
            writeVideo(w,handles.img{i});
        end
        close(w);
        delete(h);
        sysLine = ['"c:\program files\MovementScience\application\vlc-2.2.6-win32\vlc-2.2.6\vlc" "' pth '\tmp.avi"'];
        system(sysLine)
    catch
        msgbox('Unable to launch VLC');
    end
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
handles.recorder = audiorecorder(8000,8,1,handles.microphoneID);
guidata(hObject, handles);


% --- Executes on button press in togglebuttonRecordAudioOverMovie.
function togglebuttonRecordAudioOverMovie_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonRecordAudioOverMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonRecordAudioOverMovie
val = get(handles.togglebuttonRecordAudioOverMovie,'Value');
cmp = computer;
if strcmp(cmp,'PCWIN64') == 1
    pth = getenv('USERPROFILE');
    pth = [pth '\Documents'];
    sysLine = [' md ' pth '\MovementScience'];
    pth = [pth '\MovementScience'];
    system(sysLine);
    sysLine = 'Taskkill /IM fmedia.exe /F';
    system(sysLine);
    if val == 1
        sysLine = ['del ' '"' pth '\myAudio.wav"'];
        system(sysLine);
        sysLine= ['del ' fullfile(pth,'*.tif')];
        system(sysLine);
        set(handles.togglebuttonRecordAudioOverMovie,'BackgroundColor','r');
        sysLine = (['"c:\program files\MovementScience\application\fmedia\fmedia" --record --out=' pth '\myAudio.wav',' --rate=48000 &']);
        system(sysLine);
        zers = '00000000';
        ct=0;
        tic;
        while val == 1
            ct=ct+1;
            imwrite(getimage(handles.axesCamera1),[pth '\' zers(1:end-length(num2str(ct))) num2str(ct) '.tif']);
            drawnow();
            toc;
            handles.timeFrames = toc;
            val = get(handles.togglebuttonRecordAudioOverMovie,'Value');
            guidata(hObject, handles);
        end
    elseif val == 0
            pth = getenv('USERPROFILE');
            pth = [pth '\Documents'];
            pth = [pth '\MovementScience'];
            %kill fmedia task
            sysLine = 'Taskkill /IM fmedia.exe /F';
            system(sysLine);
            sysLine = 'Taskkill /IM ffmpeg.exe /F';
            system(sysLine);
            sysLine = 'Taskkill /IM cmd.exe /F';
            system(sysLine);
            sysLine = ['del ' fullfile(pth,'myMovieWithAudio.avi')];
            system(sysLine);
            %get info from audio file
            info = audioinfo(fullfile(pth,'\myAudio.wav'));
            time = info.Duration;
            %cut beginning of audio to match video
            dif = time - handles.timeFrames;
            frames = dif * info.SampleRate;
            wav = audioread(fullfile(pth,'\myAudio.wav'));
            wavOut = wav((dif*info.SampleRate):end,:);
            audiowrite(fullfile(pth,'\myAudio.wav'),wavOut,info.SampleRate);
            %framerate
            framerate = length(dir([pth '\*.tif'])) / handles.timeFrames;
            %ffmpeg build
            sysLine = (['"c:\program files\MovementScience\application\ffmpeg-20170921-183fd30-win64-static\bin\ffmpeg" -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -i "' pth '\myAudio.wav" -codec copy -y -c:v mjpeg -qscale:v 0  "' handles.pathstr '\' get(handles.editMovieName,'String') 'WithAudio.avi"']);
            system(sysLine);
            sysLine= ['del ' fullfile(pth,'*.tif')];
            system(sysLine);
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

if strcmp(cmp,'maci64') == 1
    usr = getenv('USER');
    pth = ['Users/' usr '/Applications/MovementScience'];
    mkdir([pth '/TIF']);
    mkdir([pth '/AUDIO']);
    sysLine = ['rm ' pth '/TIF/*.tif'];
    system(sysLine);
    sysLine = ['rm ' pth '/AUDIO/*.*'];
    system(sysLine);
    if val == 1
        set(handles.togglebuttonRecordAudioOverMovie,'BackgroundColor','r');
        %start recording video independent of MATLAB
        sysLine = ['/Users/' usr '/Applications/MovementScience/ffmpeg -f avfoundation -ac 2 -i :0 -c:a aac -ab 96k ' pth '/AUDIO/myVoice.aac'];
        system(sysLine);
        zers = '00000000';
        ct=0;
        tic;
        while val == 1
            ct=ct+1;
            imwrite(getimage(handles.axesCamera1),[pth '/TIF/' zers(1:end-length(num2str(ct))) num2str(ct) '.tif']);
            drawnow();
            toc;
            handles.timeFrames = toc;
            val = get(handles.togglebuttonRecordAudioOverMovie,'Value');
            guidata(hObject, handles);
        end
    elseif val == 0
        sysLine = 'killall ffmpeg';
        system(sysLine);
        info = audioinfo(fullfile(pth,'/AUDIO/myVoice.aac'));
        time = info.Duration;
        %cut beginning of audio to match video
        dif = time - handles.timeFrames;
        frames = dif * info.SampleRate;
        aac = audioread(fullfile(pth,'/AUDIO/myVoice.wav'));
        aacOut = aac((dif*info.SampleRate):end,:);
        audiowrite(fullfile(pth,'/AUDIO/myVoice.aac'),aacOut,info.SampleRate);
        %framerate
        framerate = length(dir([pth '/TIF/*.tif'])) / handles.timeFrames;
        %ffmpeg build
        sysLine = (['Users/' usr '/Applications/MovementScience/ffmpeg -framerate ' num2str(framerate) ' -i ' pth '/TIF/%08d.tif -i ' pth '/AUDIO/myVoice.aac" -codec copy -y -c:v mjpeg -qscale:v 0  ' handles.pathstr '/' get(handles.editMovieName,'String') 'WithAudio.avi']);
        system(sysLine);
        sysLine= ['rm ' pth '/TIF/*.tif'];
        system(sysLine);
    end
end
    


% --- Executes on button press in pushbuttonResizeAndCrop.
function pushbuttonResizeAndCrop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonResizeAndCrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resizeAndCropVideo();
