function varargout = PreProcess(varargin)
% PREPROCESS MATLAB code for PreProcess.fig
%      PREPROCESS, by itself, creates a new PREPROCESS or raises the existing
%      singleton*.
%
%      H = PREPROCESS returns the handle to a new PREPROCESS or the handle to
%      the existing singleton*.
%
%      PREPROCESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREPROCESS.M with the given input arguments.
%
%      PREPROCESS('Property','Value',...) creates a new PREPROCESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PreProcess_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PreProcess_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PreProcess

% Last Modified by GUIDE v2.5 11-Jan-2018 12:44:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PreProcess_OpeningFcn, ...
    'gui_OutputFcn',  @PreProcess_OutputFcn, ...
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


% --- Executes just before PreProcess is made visible.
function PreProcess_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PreProcess (see VARARGIN)

% Choose default command line output for PreProcess
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
handles.vidStr = 'EditedVideoName';

guidata(hObject, handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PreProcess wait for user response (see UIRESUME)
% uiwait(handles.PreProcess);


% --- Outputs from this function are returned to the command line.
function varargout = PreProcess_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonLoadVideoWithScaling.
function pushbuttonLoadVideoWithScaling_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadVideoWithScaling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%load info from MovementScience main figure if possible

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
global frequency;
global vidTimes;

try
    %      try
    clear img;
    global img;
    handles.v = VideoReader(fullfile(handles.pathstr,handles.vidStr));
    handles.frames = handles.v.NumberOfFrames;
    frequency = 1 / handles.v.FrameRate;
    handles.v = VideoReader(fullfile(handles.pathstr,handles.vidStr));
    answer = inputdlg('Would you like to maintain the original audio? y or n');
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
        [audio,audioFrequency] = audioread(fullfile(handles.pathstr,handles.vidStr));
        first = str2num(get(handles.editFirstFrame,'String'));
        last = str2num(get(handles.editLastFrame,'String'));
        vr = handles.v.FrameRate;
        ar = audioFrequency;
        audio = audio(round(first*(ar/vr)):round(last*(ar/vr)),:);
    end
    
    
    ct=0;
    h2 = msgbox(['Load and resizing is ' num2str(1/length(img)) ' complete']);
    for i = 1:handles.frames
        if i >= str2num(get(handles.editFirstFrame,'String')) && i <= str2num(get(handles.editLastFrame,'String'))
            ct=ct+1;
            set(findobj(h2,'Tag','MessageBox'),'String',['Load and resizing is ' num2str(i/handles.frames) ' complete']);
            set(handles.editFrame,'String',num2str(i))
            img{ct} = imresize(readFrame(handles.v),str2num(get(handles.editScaleFactor,'String')));
            drawnow;
        end
    end
    
    for i = 1:length(img)
        if i == 1
            handles.vidTimes = 0;
        else
            handles.vidTimes = [handles.vidTimes i*(1/handles.v.FrameRate)];
        end
    end
    vidTimes = handles.vidTimes;
    
    PointSize = ceil(PointSize * str2num(get(handles.editScaleFactor,'String')));
    TrailingPointSize = ceil(TrailingPointSize  * str2num(get(handles.editScaleFactor,'String')));
    PointWeight = ceil(PointWeight * str2num(get(handles.editScaleFactor,'String')));
    TrailingPointWeight = ceil(TrailingPointWeight  * str2num(get(handles.editScaleFactor,'String')));
    LineWeight = ceil(LineWeight  * str2num(get(handles.editScaleFactor,'String')));
    TextSize = ceil(TextSize  * str2num(get(handles.editScaleFactor,'String')));
    SearchRadius = ceil(SearchRadius  * str2num(get(handles.editScaleFactor,'String')));
    TextWeight = ceil(TextWeight  * str2num(get(handles.editScaleFactor,'String')));
    
    % imgOrig = img;
    set(handles.sliderLoadedVideo,'Value',1);
    set(handles.sliderLoadedVideo,'min',1);
    set(handles.sliderLoadedVideo,'max',ct);
    set(handles.sliderLoadedVideo,'SliderStep',[1,1]/(ct-1));
    set(handles.editFrame,'String','1');
    drawnow();
    
    set(handles.sliderR,'Value',0);
    set(handles.sliderR,'min',0);
    set(handles.sliderR,'max',1);
    set(handles.sliderG,'Value',0);
    set(handles.sliderG,'min',0);
    set(handles.sliderG,'max',1);
    set(handles.sliderB,'Value',0);
    set(handles.sliderB,'min',0);
    set(handles.sliderB,'max',1);
    
    set(handles.sliderRHigh,'Value',1);
    set(handles.sliderRHigh,'min',0);
    set(handles.sliderRHigh,'max',1);
    set(handles.sliderGHigh,'Value',1);
    set(handles.sliderGHigh,'min',0);
    set(handles.sliderGHigh,'max',1);
    set(handles.sliderBHigh,'Value',1);
    set(handles.sliderBHigh,'min',0);
    set(handles.sliderBHigh,'max',1);
    
    set(handles.sliderBrightness,'Value',1);
    set(handles.sliderBrightness,'min',0);
    set(handles.sliderBrightness,'max',5);
    
    imshow(img{1},'Parent',handles.axesIMG);
    delete(h2);
    %     catch
    %         msgbox('You must select a video first');
    %     end
catch
    h = findobj('Tag','MovementScience');
    handles2 = guidata(h);
    if isfield(handles2,'audio')
        audFlag = 1;
    else
        audFlag = 0;
    end
    handles.frames = length(img);
    % imgOrig = img;
    set(handles.sliderLoadedVideo,'Value',1);
    set(handles.sliderLoadedVideo,'min',1);
    set(handles.sliderLoadedVideo,'max',length(img));
    set(handles.sliderLoadedVideo,'SliderStep',[1,1]/(length(img)-1));
    set(handles.editFrame,'String','1');
    drawnow();
    
    set(handles.sliderR,'Value',0);
    set(handles.sliderR,'min',0);
    set(handles.sliderR,'max',1);
    set(handles.sliderG,'Value',0);
    set(handles.sliderG,'min',0);
    set(handles.sliderG,'max',1);
    set(handles.sliderB,'Value',0);
    set(handles.sliderB,'min',0);
    set(handles.sliderB,'max',1);
    
    set(handles.sliderRHigh,'Value',1);
    set(handles.sliderRHigh,'min',0);
    set(handles.sliderRHigh,'max',1);
    set(handles.sliderGHigh,'Value',1);
    set(handles.sliderGHigh,'min',0);
    set(handles.sliderGHigh,'max',1);
    set(handles.sliderBHigh,'Value',1);
    set(handles.sliderBHigh,'min',0);
    set(handles.sliderBHigh,'max',1);
    
    set(handles.sliderBrightness,'Value',1);
    set(handles.sliderBrightness,'min',0);
    set(handles.sliderBrightness,'max',5);
    
    h2 = msgbox(['Load and resizing is ' num2str(1/length(img)) ' complete']);
    for i = 1:length(img)
        set(findobj(h2,'Tag','MessageBox'),'String',['Load and resizing is ' num2str(i/length(img)) ' complete']);
        drawnow();
        img{i} = imresize(img{i},str2num(get(handles.editScaleFactor,'String')));
    end
    
    PointSize = ceil(PointSize * str2num(get(handles.editScaleFactor,'String')));
    TrailingPointSize = ceil(TrailingPointSize  * str2num(get(handles.editScaleFactor,'String')));
    PointWeight = ceil(PointWeight * str2num(get(handles.editScaleFactor,'String')));
    TrailingPointWeight = ceil(TrailingPointWeight  * str2num(get(handles.editScaleFactor,'String')));
    LineWeight = ceil(LineWeight  * str2num(get(handles.editScaleFactor,'String')));
    TextSize = ceil(TextSize  * str2num(get(handles.editScaleFactor,'String')));
    SearchRadius = ceil(SearchRadius  * str2num(get(handles.editScaleFactor,'String')));
    TextWeight = ceil(TextWeight  * str2num(get(handles.editScaleFactor,'String')));
    
    imshow(img{1},'Parent',handles.axesIMG);
    delete(h2);
    
end
guidata(hObject, handles);



function editScaleFactor_Callback(hObject, eventdata, handles)
% hObject    handle to editScaleFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editScaleFactor as text
%        str2double(get(hObject,'String')) returns contents of editScaleFactor as a double


% --- Executes during object creation, after setting all properties.
function editScaleFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editScaleFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSelectVideo.
function pushbuttonSelectVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelectVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vidStr;
global pathstr;
[handles.vidStr handles.pathstr] = uigetfile(fullfile(pwd, '*.*'),'Please select the video file of interest');
vidStr = handles.vidStr;
pathstr = handles.pathstr;
set(handles.textVidPath,'String',fullfile(handles.pathstr,handles.vidStr));
v = VideoReader(fullfile(handles.pathstr,handles.vidStr));
set(handles.editLastFrame,'String',num2str(v.NumberOfFrames));

set(handles.sliderR,'Value',0);
set(handles.sliderR,'min',0);
set(handles.sliderR,'max',1);
set(handles.sliderG,'Value',0);
set(handles.sliderG,'min',0);
set(handles.sliderG,'max',1);
set(handles.sliderB,'Value',0);
set(handles.sliderB,'min',0);
set(handles.sliderB,'max',1);

set(handles.sliderRHigh,'Value',1);
set(handles.sliderRHigh,'min',0);
set(handles.sliderRHigh,'max',1);
set(handles.sliderGHigh,'Value',1);
set(handles.sliderGHigh,'min',0);
set(handles.sliderGHigh,'max',1);
set(handles.sliderBHigh,'Value',1);
set(handles.sliderBHigh,'min',0);
set(handles.sliderBHigh,'max',1);

set(handles.sliderBrightness,'Value',1);
set(handles.sliderBrightness,'min',0);
set(handles.sliderBrightness,'max',5);

handles.loadNew = 1;

guidata(hObject, handles);


% --- Executes on slider movement.
function sliderLoadedVideo_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLoadedVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global img;

set(handles.sliderLoadedVideo,'Value',round(get(handles.sliderLoadedVideo,'Value')));
set(handles.editFrame,'String',num2str(get(handles.sliderLoadedVideo,'Value')));
imshow(img{get(handles.sliderLoadedVideo,'Value')},'Parent',handles.axesIMG);
drawnow();
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



function editFrame_Callback(hObject, eventdata, handles)
% hObject    handle to editFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFrame as text
%        str2double(get(hObject,'String')) returns contents of editFrame as a double
global img;

imshow(img{str2num(get(handles.editFrame,'String'))},'Parent',handles.axesIMG);
set(handles.sliderLoadedVideo,'Value',str2num(get(handles.editFrame,'String')));
drawnow();
guidata(hObject, handles);


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


% --- Executes on button press in pushbuttonPreviewFrame.
function pushbuttonPreviewFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPreviewFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.vTmp = VideoReader(fullfile(handles.pathstr,handles.vidStr));
handles.frames = handles.vTmp.NumberOfFrames;
handles.vTmp = VideoReader(fullfile(handles.pathstr,handles.vidStr));

set(handles.sliderR,'Value',0);
set(handles.sliderR,'min',0);
set(handles.sliderR,'max',1);
set(handles.sliderG,'Value',0);
set(handles.sliderG,'min',0);
set(handles.sliderG,'max',1);
set(handles.sliderB,'Value',0);
set(handles.sliderB,'min',0);
set(handles.sliderB,'max',1);

set(handles.sliderRHigh,'Value',1);
set(handles.sliderRHigh,'min',0);
set(handles.sliderRHigh,'max',1);
set(handles.sliderGHigh,'Value',1);
set(handles.sliderGHigh,'min',0);
set(handles.sliderGHigh,'max',1);
set(handles.sliderBHigh,'Value',1);
set(handles.sliderBHigh,'min',0);
set(handles.sliderBHigh,'max',1);

set(handles.sliderBrightness,'Value',1);
set(handles.sliderBrightness,'min',0);
set(handles.sliderBrightness,'max',5);

guidata(hObject, handles);

for i = 1:handles.frames
    if i == str2num(get(handles.editFirstFrame,'String'))
        handles.vTmp.CurrentTime = i*(1/handles.vTmp.FrameRate);
        imshow(imresize( readFrame( handles.vTmp ),str2num( get( handles.editScaleFactor,'String' ) ) ),'Parent',handles.axesIMG );
        drawnow;
    end
end


% --- Executes on button press in pushbuttonSetFirstFrameToCurrentFrame.
function pushbuttonSetFirstFrameToCurrentFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetFirstFrameToCurrentFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
global audio;
global audioFrequency;
global frequency;
global vidTimes;

try
    img = img(str2num(get(handles.editFrame,'String')):end);
catch
    msgbox('You must load the video first!');
end
set(handles.sliderLoadedVideo,'Value',1);
set(handles.sliderLoadedVideo,'min',1);
set(handles.sliderLoadedVideo,'max',length(img));
set(handles.sliderLoadedVideo,'SliderStep',[1,1]/(length(img)-1));
set(handles.editFrame,'String','1');
set(handles.editFirstFrame,'String',num2str(get(handles.editFrame,'String')));
if ~isempty(audio)
    a = audioFrequency;
    b = str2num(get(handles.editFrame,'String'));
    frames = round(a * (b * frequency));
    audio = audio(1 + frames:end,:);
end
drawnow();
vidTimes = vidTimes(str2num(get(handles.editFrame,'String')):end);
vidTimes = vidTimes - vidTimes(1);

imshow(img{1},'Parent',handles.axesIMG);
guidata(hObject, handles);

% --- Executes on button press in pushbuttonSetLastFrameToCurrentFrame.
function pushbuttonSetLastFrameToCurrentFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetLastFrameToCurrentFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
global audio;
global audioFrequency;
global vidTimes;

try
    img = img(1:str2num(get(handles.editFrame,'String')));
catch
    msgbox('You must load the video first!');
end

set(handles.editFrame,'String',num2str(length(img)));
set(handles.sliderLoadedVideo,'Value',length(img));
set(handles.sliderLoadedVideo,'min',1);
set(handles.sliderLoadedVideo,'max',length(img));
set(handles.sliderLoadedVideo,'SliderStep',[1,1]/(length(img)-1));
set(handles.editFrame,'String',num2str(length(img)));
set(handles.editLastFrame,'String',num2str(length(img)));
if ~isempty(audio)
    a = audioFrequency;
    b = str2num(get(handles.editFrame,'String'));
    frames = round(a * (b * frequency));
    audio = audio(1:frames,:);
end
drawnow();
vidTimes = vidTimes(1:str2num(get(handles.editFrame,'String')));
vidTimes = vidTimes - vidTimes(1);

imshow(img{length(img)},'Parent',handles.axesIMG);
guidata(hObject, handles);



% --- Executes on button press in pushbuttonWriteCurrentVideo.
function pushbuttonWriteCurrentVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonWriteCurrentVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;
global audio;
global audioFrequency;
global frequency;

h = msgbox('Writing');
cmp = computer;
set(handles.pushbuttonWriteCurrentVideo,'BackgroundColor','c');
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
    if ~isempty(audio)
        audiowrite([pth '\myAudio.wav'],audio,audioFrequency);
    end
    sysLine= ['del ' fullfile(pth,'*.tif')];
    system(sysLine);
    zers = '00000000';
    ct=0;
    for i = 1:length(img)
        ct=ct+1;
        set(findobj(h,'Tag','MessageBox'),'String',['Writing frame ' num2str(i)]);
        imwrite(img{i},[pth '\' zers(1:end-length(num2str(ct))) num2str(ct) '.tif']);
        set(handles.editFrame,'String',num2str(i));
        drawnow();
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
        time = info.Duration;
    catch
    end
    %framerate
    framerate = 1/frequency;
    %ffmpeg build
    handles.vidStr = get(handles.editVideoName,'String');
    set(findobj(h,'Tag','MessageBox'),'String',"Encoding");
    if ~isempty(audio)
        sysLine = (['"c:\program files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg" -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -i "' pth '\myAudio.wav" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,handles.vidStr) '.avi"']]);
    else
        sysLine = (['"c:\program files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg" -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,handles.vidStr) '.avi"']]);
    end
    system(sysLine);
    set(findobj(h,'Tag','MessageBox'),'String','Cleaning temporary files');
    sysLine= ['del ' fullfile(pth,'*.tif')];
    system(sysLine);
    set(handles.pushbuttonWriteCurrentVideo,'BackgroundColor','g');
    delete(h);
end

if strcmp(cmp,'MACI64') == 1
    sysLine = 'killall ffmpeg';
    system(sysLine);
    user = getenv('USER');
    pth = ['/Users/' user  '/Documents'];
    sysLine = [' mkdir ' pth '/MovementScience'];
    system(sysLine);
    pth = [pth '/MovementScience'];
    sysLine = ['del ' fullfile(pth,'myAudio.wav')];
    system(sysLine);
    if ~isempty(audio)
        audiowrite([pth '/myAudio.wav'],audio,audioFrequency);
    end
    sysLine= ['rm ' fullfile(pth,'*.tif')];
    system(sysLine);
    zers = '00000000';
    ct=0;
    for i = 1:length(img)
        ct=ct+1;
        imwrite(img{i},[pth '/' zers(1:end-length(num2str(ct))) num2str(ct) '.tif']);
    end
    %get info from audio file
    try
        info = audioinfo(fullfile(pth,'myAudio.wav'));
        time = info.Duration;
    catch
    end
    %framerate
    framerate = 1/frequency;
    %ffmpeg build
    if ~isempty(audio)
        sysLine = (['"/Applications/MovementScience/application/Lion_Mountain_Lion_Mavericks_Yosemite_El-Captain_15.05.2017/ffmpeg" -framerate ' num2str(framerate) ' -i "' pth '/%08d.tif" -i "' pth '/myAudio.wav" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,handles.vidStr) '-Edited.avi"']]);
    else
        sysLine = (['"/Applications/MovementScience/application/Lion_Mountain_Lion_Mavericks_Yosemite_El-Captain_15.05.2017/ffmpeg" -framerate ' num2str(framerate) ' -i "' pth '/%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,handles.vidStr) '-Edited.avi"']]);
    end
    system(sysLine);
    sysLine= ['rm ' fullfile(pth,'*.tif')];
    system(sysLine);
    set(handles.pushbuttonWriteCurrentVideo,'BackgroundColor','g');
end
delete(h);




% --- Executes on button press in pushbuttonStabilizeVideo.
function pushbuttonStabilizeVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStabilizeVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;

val = get(handles.popupmenuStabilizationMethod,'Value');
[a b c] = size(img{1});

if val == 1
    try
        for i = 1:length(img)-1
            h = msgbox('''Stabilizing video frame 1 (may take a while if using Selection option)''');
            set(findobj(h,'Tag','MessageBox'),'String',['''Stabilizing video frame ' num2str(i) ' (may take a while if using Selection option)''']);
            set(handles.editFrame,'String',num2str(i));
            drawnow();
            
            if i < length(img)-1
                imgA = rgb2gray(img{i});
                imgB = rgb2gray(img{i+1});
                ptThresh = 0.2;
                
                pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);
                pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);
                
                [featuresA, pointsA] = extractFeatures(imgA, pointsA);
                [featuresB, pointsB] = extractFeatures(imgB, pointsB);
                
                indexPairs = matchFeatures(featuresA, featuresB);
                pointsA = pointsA(indexPairs(:, 1), :);
                pointsB = pointsB(indexPairs(:, 2), :);
                
                [tform, pointsBm, pointsAm] = estimateGeometricTransform(pointsB, pointsA, 'affine');
                imgBp = imwarp(img{i+1}, tform, 'OutputView', imref2d(size(img{i+1})));
                
                img{i+1} = imgBp;
            else
                imgA = rgb2gray(img{end-1});
                imgB = rgb2gray(img{end});
                ptThresh = 0.2;
                
                pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);
                pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);
                
                [featuresA, pointsA] = extractFeatures(imgA, pointsA);
                [featuresB, pointsB] = extractFeatures(imgB, pointsB);
                
                indexPairs = matchFeatures(featuresA, featuresB);
                pointsA = pointsA(indexPairs(:, 1), :);
                pointsB = pointsB(indexPairs(:, 2), :);
                
                [tform, pointsBm, pointsAm] = estimateGeometricTransform(pointsB, pointsA, 'projective');
                imgBp = imwarp(img{end}, tform, 'OutputView', imref2d(size(img{end})));
                
                img{end} = imgBp;
                
            end
        end
    catch
        msgbox(['Video quality too low to find points to stabilize at frame ' num2str(i) ' ; everything prior is stabilized']);
    end
end

if val == 2
    try
        hTM = vision.TemplateMatcher('ROIInputPort', true, ...
        'BestMatchNeighborhoodOutputPort', true);

        scale = 0.3;	
        for i = 1:length(img)
            im = img{i};
            im = imresize(im,scale);
            input = rgb2gray(im);
            if i==1
                [~,rect] = imcrop(input);
                rect = round(rect);
                [H W] = size(input);
                h = msgbox('''Stabilizing video frame 1 (may take a while if using Selection option)''');
%                 W = fileInfo.Width; % Width in pixels
%                 H = fileInfo.Height; % Height in pixels

                pos.template_orig = [rect(1) rect(2)]; % [x y] upper left corner
                pos.template_size = [rect(3) rect(4)];   % [width height]
                pos.search_border = [round(W/20) round(H/20)];   % max horizontal and vertical displacement
                pos.template_center = floor((pos.template_size-1)/2);
                pos.template_center_pos = (pos.template_orig + pos.template_center - 1);

                BorderCols = [1:pos.search_border(1)+4 W-pos.search_border(1)+4:W];
                BorderRows = [1:pos.search_border(2)+4 H-pos.search_border(2)+4:H];
                sz = [H W];
                TargetRowIndices = ...
                  pos.template_orig(2)-1:pos.template_orig(2)+pos.template_size(2)-2;
                TargetColIndices = ...
                  pos.template_orig(1)-1:pos.template_orig(1)+pos.template_size(1)-2;
                SearchRegion = pos.template_orig - pos.search_border - 1;
                Offset = [0 0];
                Target = zeros(W,H);
                firstTime = true;
            end
            set(findobj(h,'Tag','MessageBox'),'String',['''Stabilizing video frame ' num2str(i) ' (may take a while if using Selection option)''']);
            % Find location of Target in the input video frame
            if firstTime
              Idx = int32(pos.template_center_pos);
              MotionVector = [0 0];
              firstTime = false;
            else
              IdxPrev = Idx;

              ROI = [SearchRegion, pos.template_size+2*pos.search_border];
              Idx = step(hTM, input, Target, ROI);

              MotionVector = double(Idx-IdxPrev);
            end

            [Offset, SearchRegion] = updatesearch(sz, MotionVector, ...
                SearchRegion, Offset, pos);

            Offset
            % Translate video frame to offset the camera motion
            Stabilized = imtranslate(im,Offset,'linear');
            img{i} = imtranslate(img{i},Offset./scale,'linear');

            Target = Stabilized(TargetRowIndices, TargetColIndices);

            % Add black border for display
            Stabilized(:, BorderCols) = 0;
            Stabilized(BorderRows, :) = 0;

            %TargetRect = [pos.template_orig-Offset, pos.template_size];
            %SearchRegionRect = [SearchRegion, pos.template_size + 2*pos.search_border];

            % Draw rectangles on input to show target and search region
            %im = insertShape(im, 'Rectangle', [TargetRect; SearchRegionRect],...
%                                 'Color', 'white');
            % Display the offset (displacement) values on the input image
            %txt = sprintf('(%+05.1f,%+05.1f)', Offset);
            %im = insertText(im,[191 215],txt,'FontSize',16, ...
%                             'TextColor', 'white', 'BoxOpacity', 0);
            % Display video
            imshow(img{i},'Parent',handles.axesIMG);
            set(handles.editFrame,'String',num2str(i));
            drawnow();
        end
        
    catch
        msgbox(['Video quality too low to find points to stabilize at frame ' num2str(i) ' ; everything prior is stabilized']);
    end
    delete(h)
end

imshow(img{round(get(handles.sliderLoadedVideo,'Value'))},'Parent',handles.axesIMG);
set(handles.editFrame,'String',num2str(round(get(handles.sliderLoadedVideo,'Value'))));
guidata(hObject, handles);


% --- Executes on button press in pushbuttonSetAreaOfInterest.
function pushbuttonSetAreaOfInterest_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetAreaOfInterest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;

img2 = img{get(handles.sliderLoadedVideo,'Value')};
[~,rect] = imcrop(img2);

for i = 1:length(img)
    set(handles.editFrame,'String',num2str(i));
    drawnow();
    img{i} = imcrop(img{i},rect);
end
imshow(img{get(handles.sliderLoadedVideo,'Value')},'Parent',handles.axesIMG);
set(handles.editFrame,'String',num2str(get(handles.sliderLoadedVideo,'Value')));
guidata(hObject, handles);


% --- Executes on slider movement.
function sliderR_Callback(hObject, eventdata, handles)
% hObject    handle to sliderR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global img;

rValLow = get(handles.sliderR,'Value');
gValLow = get(handles.sliderG,'Value');
bValLow = get(handles.sliderB,'Value');

rValHigh = get(handles.sliderRHigh,'Value');
gValHigh = get(handles.sliderGHigh,'Value');
bValHigh = get(handles.sliderBHigh,'Value');

imTmp = imadjust(img{get(handles.sliderLoadedVideo,'Value')},[rValLow,gValLow,bValLow;rValHigh,gValHigh,bValHigh],[]);
imshow(imTmp,'Parent',handles.axesIMG);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderG_Callback(hObject, eventdata, handles)
% hObject    handle to sliderG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global img;

rValLow = get(handles.sliderR,'Value');
gValLow = get(handles.sliderG,'Value');
bValLow = get(handles.sliderB,'Value');

rValHigh = get(handles.sliderRHigh,'Value');
gValHigh = get(handles.sliderGHigh,'Value');
bValHigh = get(handles.sliderBHigh,'Value');

imTmp = imadjust(img{get(handles.sliderLoadedVideo,'Value')},[rValLow,gValLow,bValLow;rValHigh,gValHigh,bValHigh],[]);
imshow(imTmp,'Parent',handles.axesIMG);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderB_Callback(hObject, eventdata, handles)
% hObject    handle to sliderB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global img;

rValLow = get(handles.sliderR,'Value');
gValLow = get(handles.sliderG,'Value');
bValLow = get(handles.sliderB,'Value');

rValHigh = get(handles.sliderRHigh,'Value');
gValHigh = get(handles.sliderGHigh,'Value');
bValHigh = get(handles.sliderBHigh,'Value');

imTmp = imadjust(img{get(handles.sliderLoadedVideo,'Value')},[rValLow,gValLow,bValLow;rValHigh,gValHigh,bValHigh],[]);
imshow(imTmp,'Parent',handles.axesIMG);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sliderB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbuttonApplyColorsToVideo.
function pushbuttonApplyColorsToVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonApplyColorsToVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;

rValLow = get(handles.sliderR,'Value');
gValLow = get(handles.sliderG,'Value');
bValLow = get(handles.sliderB,'Value');

rValHigh = get(handles.sliderRHigh,'Value');
gValHigh = get(handles.sliderGHigh,'Value');
bValHigh = get(handles.sliderBHigh,'Value');

for i = 1:length(img)
    set(handles.editFrame,'String',num2str(i));
    drawnow();
    img{i} = imadjust(img{i},[rValLow,gValLow,bValLow;rValHigh,gValHigh,bValHigh],[]);
end
imshow(img{round(get(handles.sliderLoadedVideo,'Value'))},'Parent',handles.axesIMG);
guidata(hObject, handles);


% --- Executes on slider movement.
function sliderRHigh_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global img;

rValLow = get(handles.sliderR,'Value');
gValLow = get(handles.sliderG,'Value');
bValLow = get(handles.sliderB,'Value');

rValHigh = get(handles.sliderRHigh,'Value');
gValHigh = get(handles.sliderGHigh,'Value');
bValHigh = get(handles.sliderBHigh,'Value');

imTmp = imadjust(img{get(handles.sliderLoadedVideo,'Value')},[rValLow,gValLow,bValLow;rValHigh,gValHigh,bValHigh],[]);
imshow(imTmp,'Parent',handles.axesIMG);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderRHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderGHigh_Callback(hObject, eventdata, handles)
% hObject    handle to sliderGHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global img;

rValLow = get(handles.sliderR,'Value');
gValLow = get(handles.sliderG,'Value');
bValLow = get(handles.sliderB,'Value');

rValHigh = get(handles.sliderRHigh,'Value');
gValHigh = get(handles.sliderGHigh,'Value');
bValHigh = get(handles.sliderBHigh,'Value');

imTmp = imadjust(img{get(handles.sliderLoadedVideo,'Value')},[rValLow,gValLow,bValLow;rValHigh,gValHigh,bValHigh],[]);
imshow(imTmp,'Parent',handles.axesIMG);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderGHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderGHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderBHigh_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global img;

rValLow = get(handles.sliderR,'Value');
gValLow = get(handles.sliderG,'Value');
bValLow = get(handles.sliderB,'Value');

rValHigh = get(handles.sliderRHigh,'Value');
gValHigh = get(handles.sliderGHigh,'Value');
bValHigh = get(handles.sliderBHigh,'Value');

imTmp = imadjust(img{get(handles.sliderLoadedVideo,'Value')},[rValLow,gValLow,bValLow;rValHigh,gValHigh,bValHigh],[]);
imshow(imTmp,'Parent',handles.axesIMG);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderBHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderBrightness_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBrightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global img;

imTmp = img{round(get(handles.sliderLoadedVideo,'Value'))};
imTmp = imTmp .* get(handles.sliderBrightness,'Value');
imshow(imTmp,'Parent',handles.axesIMG);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderBrightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBrightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbuttonApplyBrightnessToVideo.
function pushbuttonApplyBrightnessToVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonApplyBrightnessToVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;

for i = 1:length(img)
    set(handles.editFrame,'String',num2str(i));
    drawnow();
    img{i} = img{i} .* get(handles.sliderBrightness,'Value');
end
imshow(img{round(get(handles.sliderLoadedVideo,'Value'))},'Parent',handles.axesIMG);
guidata(hObject, handles);


% --- Executes on button press in pushbuttonReset.
function pushbuttonReset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;

set(handles.sliderLoadedVideo,'Value',1);
set(handles.editFrame,'String','1');
imshow(img{round(get(handles.sliderLoadedVideo,'Value'))},'Parent',handles.axesIMG);
guidata(hObject, handles);


% --- Executes on button press in pushbuttonRotateVideo.
function pushbuttonRotateVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRotateVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;

deg = get(handles.editDegrees,'String');
try
    deg = str2num(deg);
catch
    deg = str2num(cell2mat(deg));
end
for i = 1:length(img)
    set(handles.editFrame,'String',num2str(i));
    drawnow();
    img{i} = imrotate(img{i},deg);
end
imshow(img{get(handles.sliderLoadedVideo,'Value')},'Parent',handles.axesIMG);
guidata(hObject, handles);


function editDegrees_Callback(hObject, eventdata, handles)
% hObject    handle to editDegrees (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDegrees as text
%        str2double(get(hObject,'String')) returns contents of editDegrees as a double


% --- Executes during object creation, after setting all properties.
function editDegrees_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDegrees (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFirstFrame_Callback(hObject, eventdata, handles)
% hObject    handle to editFirstFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFirstFrame as text
%        str2double(get(hObject,'String')) returns contents of editFirstFrame as a double


% --- Executes during object creation, after setting all properties.
function editFirstFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFirstFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLastFrame_Callback(hObject, eventdata, handles)
% hObject    handle to editLastFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLastFrame as text
%        str2double(get(hObject,'String')) returns contents of editLastFrame as a double


% --- Executes during object creation, after setting all properties.
function editLastFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLastFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonLoadVideoWithoutScaling.
function pushbuttonLoadVideoWithoutScaling_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadVideoWithoutScaling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%load info from MovementScience main figure if possible

global img;
global frequency;
global vidTimes;

try
    handles.v = VideoReader(fullfile(handles.pathstr,handles.vidStr));
    handles.frames = handles.v.NumberOfFrames;
    frequency = 1 / handles.v.FrameRate;
    handles.v = VideoReader(fullfile(handles.pathstr,handles.vidStr));
    answer = inputdlg('Would you like to maintain the original audio? y or n');
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
        [audio,audioFrequency] = audioread(fullfile(handles.pathstr,handles.vidStr));
        first = str2num(get(handles.editFirstFrame,'String'));
        last = str2num(get(handles.editLastFrame,'String'));
        vr = handles.v.FrameRate;
        ar = audioFrequency;
        audio = audio(round(first*(ar/vr)):round(last*(ar/vr)),:);
    end
    
    
    ct=0;
    clear img;
    global img;
    h2 = msgbox(['Load and resizing is ' num2str(1/handles.frames) ' complete']);
    for i = 1:handles.frames
        if i >= str2num(get(handles.editFirstFrame,'String')) && i <= str2num(get(handles.editLastFrame,'String'))
            ct=ct+1;
            set(findobj(h2,'Tag','MessageBox'),'String',['Load and resizing is ' num2str(i/handles.frames) ' complete']);
            set(handles.editFrame,'String',num2str(i))
            img{ct} = readFrame(handles.v);
            drawnow;
        end
    end
    
    for i = 1:length(img)
        if i == 1
            handles.vidTimes = 0;
        else
            handles.vidTimes = [handles.vidTimes i*(1/handles.v.FrameRate)];
        end
    end
    delete(h2);
    % imgOrig = img;
    set(handles.sliderLoadedVideo,'Value',1);
    set(handles.sliderLoadedVideo,'min',1);
    set(handles.sliderLoadedVideo,'max',ct);
    set(handles.sliderLoadedVideo,'SliderStep',[1,1]/(ct-1));
    set(handles.editFrame,'String','1');
    drawnow();
    
    set(handles.sliderR,'Value',0);
    set(handles.sliderR,'min',0);
    set(handles.sliderR,'max',1);
    set(handles.sliderG,'Value',0);
    set(handles.sliderG,'min',0);
    set(handles.sliderG,'max',1);
    set(handles.sliderB,'Value',0);
    set(handles.sliderB,'min',0);
    set(handles.sliderB,'max',1);
    
    set(handles.sliderRHigh,'Value',1);
    set(handles.sliderRHigh,'min',0);
    set(handles.sliderRHigh,'max',1);
    set(handles.sliderGHigh,'Value',1);
    set(handles.sliderGHigh,'min',0);
    set(handles.sliderGHigh,'max',1);
    set(handles.sliderBHigh,'Value',1);
    set(handles.sliderBHigh,'min',0);
    set(handles.sliderBHigh,'max',1);
    
    set(handles.sliderBrightness,'Value',1);
    set(handles.sliderBrightness,'min',0);
    set(handles.sliderBrightness,'max',5);
    
    imshow(img{1},'Parent',handles.axesIMG);
    
catch
    h = findobj('Tag','MovementScience');
    handles2 = guidata(h);
    if isfield(handles2,'audio')
        audFlag = 1;
    else
        audFlag = 0;
    end
    handles.frames = length(img);
    % imgOrig = img;
    set(handles.sliderLoadedVideo,'Value',1);
    set(handles.sliderLoadedVideo,'min',1);
    set(handles.sliderLoadedVideo,'max',length(img));
    set(handles.sliderLoadedVideo,'SliderStep',[1,1]/(length(img)-1));
    %     set(handles.editFrame,'String','1');
    drawnow();
    
    set(handles.sliderR,'Value',0);
    set(handles.sliderR,'min',0);
    set(handles.sliderR,'max',1);
    set(handles.sliderG,'Value',0);
    set(handles.sliderG,'min',0);
    set(handles.sliderG,'max',1);
    set(handles.sliderB,'Value',0);
    set(handles.sliderB,'min',0);
    set(handles.sliderB,'max',1);
    
    set(handles.sliderRHigh,'Value',1);
    set(handles.sliderRHigh,'min',0);
    set(handles.sliderRHigh,'max',1);
    set(handles.sliderGHigh,'Value',1);
    set(handles.sliderGHigh,'min',0);
    set(handles.sliderGHigh,'max',1);
    set(handles.sliderBHigh,'Value',1);
    set(handles.sliderBHigh,'min',0);
    set(handles.sliderBHigh,'max',1);
    
    set(handles.sliderBrightness,'Value',1);
    set(handles.sliderBrightness,'min',0);
    set(handles.sliderBrightness,'max',5);
    
    %     h2 = msgbox(['Load and resizing is ' num2str(1/length(img)) ' complete']);
    %     for i = 1:length(img)
    %         set(findobj(h2,'Tag','MessageBox'),'String',['Load and resizing is ' num2str(i/length(img)) ' complete']);
    %         img{i} = img{i});
    %     end
    imshow(img{1},'Parent',handles.axesIMG);
    %     delete(h2);
end
guidata(hObject, handles);



function editVideoName_Callback(hObject, eventdata, handles)
% hObject    handle to editVideoName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVideoName as text
%        str2double(get(hObject,'String')) returns contents of editVideoName as a double
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
handles.vidStr = get(handles.editVideoName,'String');

guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function editVideoName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVideoName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuStabilizationMethod.
function popupmenuStabilizationMethod_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuStabilizationMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuStabilizationMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuStabilizationMethod


% --- Executes during object creation, after setting all properties.
function popupmenuStabilizationMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuStabilizationMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [Offset, SearchRegion] = updatesearch(sz, MotionVector, SearchRegion, Offset, pos)
% Function to update Search Region for SAD and Offset for Translate

% check bounds
A_i = Offset - MotionVector;
AbsTemplate = pos.template_orig - A_i;
SearchTopLeft = AbsTemplate - pos.search_border;
SearchBottomRight = SearchTopLeft + (pos.template_size + 2*pos.search_border);

inbounds = all([(SearchTopLeft >= [1 1]) (SearchBottomRight <= fliplr(sz))]);

if inbounds
    Mv_out = MotionVector;
else
    Mv_out = [0 0];
end

Offset = Offset - Mv_out;
SearchRegion = SearchRegion + Mv_out;
