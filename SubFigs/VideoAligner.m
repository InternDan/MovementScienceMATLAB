function varargout = VideoAligner(varargin)
% VIDEOALIGNER MATLAB code for VideoAligner.fig
%      VIDEOALIGNER, by itself, creates a new VIDEOALIGNER or raises the existing
%      singleton*.
%
%      H = VIDEOALIGNER returns the handle to a new VIDEOALIGNER or the handle to
%      the existing singleton*.
%
%      VIDEOALIGNER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIDEOALIGNER.M with the given input arguments.
%
%      VIDEOALIGNER('Property','Value',...) creates a new VIDEOALIGNER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VideoAligner_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VideoAligner_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VideoAligner

% Last Modified by GUIDE v2.5 08-Jan-2018 15:59:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VideoAligner_OpeningFcn, ...
                   'gui_OutputFcn',  @VideoAligner_OutputFcn, ...
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


% --- Executes just before VideoAligner is made visible.
function VideoAligner_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VideoAligner (see VARARGIN)

% Choose default command line output for VideoAligner
handles.output = hObject;

handles.ispc = computer;

if strcmp(handles.ispc,'PCWIN64') == 1
    handles.pathstr = getenv('USERPROFILE');
    sysLine = ['md "' handles.pathstr '\Documents\MovementScience"'];
    system(sysLine);
    handles.pathstr = [handles.pathstr '\Documents\MovementScience'];
    sysLine = ['del /s "' handles.pathstr '\*.tif'];
    system(sysLine);
elseif strcmp(handles.ispc,'MACI64') == 1
    usr = getenv('USER');
    handles.pathstr = ['/Users/' usr '/Documents/MovementScience'];
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VideoAligner wait for user response (see UIRESUME)
% uiwait(handles.VideoAligner);


% --- Outputs from this function are returned to the command line.
function varargout = VideoAligner_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonLoadVideo1.
function pushbuttonLoadVideo1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadVideo1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.vidStr1 handles.pathstr1] = uigetfile(fullfile(handles.pathstr, '*.*'),'Please select the second video file');

h = msgbox(['Percent loaded ' num2str(0)]);
set(findobj(h,'style','pushbutton'),'Visible','off')

handles.v1 = VideoReader(fullfile(handles.pathstr1,handles.vidStr1));
handles.vidInfo1 = get(handles.v1);
clear handles.img1;

ct=0;
while hasFrame(handles.v1)
    ct=ct+1;
    handles.img1{ct} = readFrame(handles.v1);
    set(findobj(h,'Tag','MessageBox'),'String',['Percent loaded ' num2str(ct/(handles.vidInfo1.FrameRate*handles.vidInfo1.Duration))]);
    drawnow();
    drawnow();
end
for i = 1:ct
    if i == 1
        handles.vidTimes1(i) = 0;
    else
        handles.vidTimes1(i) = handles.vidTimes1(i-1) + (1/handles.vidInfo1.FrameRate);
    end
end
% set(findobj(h,'Tag','MessageBox'),'String','Loaded!');
set(handles.sliderVideo1,'Value',1);
set(handles.sliderVideo1,'min',1);
set(handles.sliderVideo1,'max',ct);
set(handles.sliderVideo1,'SliderStep',[1/(length(handles.img1)-1),0.1]);

imshow(handles.img1{1},'Parent',handles.axesVideo1);
delete(h);

guidata(hObject, handles);


% --- Executes on button press in pushbuttonLoadVideo2.
function pushbuttonLoadVideo2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadVideo2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.vidStr2 handles.pathstr2] = uigetfile(fullfile(handles.pathstr, '*.*'),'Please select the second video file');

handles.v2 = VideoReader(fullfile(handles.pathstr2,handles.vidStr2));
handles.vidInfo2 = get(handles.v2);

clear handles.img2;

h = msgbox(['Percent loaded ' num2str(0)]);
set(findobj(h,'style','pushbutton'),'Visible','off')

ct=0;
while hasFrame(handles.v2)
    ct=ct+1;
    handles.img2{ct} = readFrame(handles.v2);
    set(findobj(h,'Tag','MessageBox'),'String',['Percent loaded ' num2str(ct/(handles.vidInfo2.FrameRate*handles.vidInfo2.Duration))]);
    drawnow();
end
for i = 1:ct
    if i == 1
        handles.vidTimes2(i) = 0;
    else
        handles.vidTimes2(i) = handles.vidTimes2(i-1) + (1/handles.vidInfo2.FrameRate);
    end
end

set(handles.sliderVideo2,'Value',1);
set(handles.sliderVideo2,'min',1);
set(handles.sliderVideo2,'max',ct);
set(handles.sliderVideo2,'SliderStep',[1/(length(handles.img2)-1),0.1]);

imshow(handles.img2{1},'Parent',handles.axesVideo2);
delete(h);

guidata(hObject, handles);

% --- Executes on slider movement.
function sliderVideo1_Callback(hObject, eventdata, handles)
% hObject    handle to sliderVideo1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.ct1 = round(get(handles.sliderVideo1,'Value'));
imshow(handles.img1{handles.ct1},'Parent',handles.axesVideo1);
set(handles.editVideo1Frame,'String',num2str(handles.ct1));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sliderVideo1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderVideo1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderVideo2_Callback(hObject, eventdata, handles)
% hObject    handle to sliderVideo2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.ct2 = round(get(handles.sliderVideo2,'Value'));
imshow(handles.img2{handles.ct2},'Parent',handles.axesVideo2);
set(handles.editVideo2Frame,'String',num2str(handles.ct2));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderVideo2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderVideo2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editVideo1Frame_Callback(hObject, eventdata, handles)
% hObject    handle to editVideo1Frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVideo1Frame as text
%        str2double(get(hObject,'String')) returns contents of editVideo1Frame as a double
handles.ct1 = round(str2num(get(handles.editVideo1Frame,'String')));
imshow(handles.img1{handles.ct1},'Parent',handles.axesVideo1);
set(handles.sliderVideo1,'Value',handles.ct1);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editVideo1Frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVideo1Frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editVideo2Frame_Callback(hObject, eventdata, handles)
% hObject    handle to editVideo2Frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVideo2Frame as text
%        str2double(get(hObject,'String')) returns contents of editVideo2Frame as a double
handles.ct2 = round(str2num(get(handles.editVideo2Frame,'String')));
imshow(handles.img2{handles.ct2},'Parent',handles.axesVideo2);
set(handles.sliderVideo2,'Value',handles.ct2);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editVideo2Frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVideo2Frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSetFirstFrame1.
function pushbuttonSetFirstFrame1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetFirstFrame1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.img1 = handles.img1(handles.ct1:end);
handles.vidTimes1 = handles.vidTimes1(handles.ct1:end);
imshow(handles.img1{1},'Parent',handles.axesVideo1);
set(handles.editVideo1Frame,'String','1');
set(handles.sliderVideo1,'Value',1);
set(handles.sliderVideo1,'min',1);
set(handles.sliderVideo1,'max',length(handles.img1));
set(handles.sliderVideo1,'SliderStep',[1/(length(handles.img1)-1),0.1]);
handles.ct1=1;

guidata(hObject, handles);

% --- Executes on button press in pushbuttonSetLastFrame1.
function pushbuttonSetLastFrame1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetLastFrame1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.img1 = handles.img1(1:handles.ct1);
handles.vidTimes1 = handles.vidTimes1(1:handles.ct1);
imshow(handles.img1{length(handles.img1)},'Parent',handles.axesVideo1);
set(handles.editVideo1Frame,'String',num2str(length(handles.img1)));
set(handles.sliderVideo1,'min',1);
set(handles.sliderVideo1,'max',length(handles.img1));
set(handles.sliderVideo1,'Value',length(handles.img1));
set(handles.sliderVideo1,'SliderStep',[1/(length(handles.img1)-1),0.1]);
handles.ct1 = length(handles.img1);

guidata(hObject, handles);

% --- Executes on button press in pushbuttonSetFirstFrame2.
function pushbuttonSetFirstFrame2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetFirstFrame2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.img2 = handles.img2(handles.ct2:end);
handles.vidTimes2 = handles.vidTimes2(handles.ct2:end);
imshow(handles.img2{1},'Parent',handles.axesVideo2);
set(handles.editVideo2Frame,'String','1');
set(handles.sliderVideo2,'Value',1);
set(handles.sliderVideo2,'min',1);
set(handles.sliderVideo2,'max',length(handles.img2));
set(handles.sliderVideo2,'SliderStep',[1/(length(handles.img2)-1),0.1]);
handles.ct2 = 1;

guidata(hObject, handles);

% --- Executes on button press in pushbuttonSetLastFrame2.
function pushbuttonSetLastFrame2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetLastFrame2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.img2 = handles.img2(1:handles.ct2);
handles.vidTimes2 = handles.vidTimes2(1:handles.ct2);
imshow(handles.img2{length(handles.img2)},'Parent',handles.axesVideo2);
set(handles.editVideo2Frame,'String',num2str(length(handles.img2)));
set(handles.sliderVideo2,'min',1);
set(handles.sliderVideo2,'max',length(handles.img2));
set(handles.sliderVideo2,'Value',length(handles.img2));
set(handles.sliderVideo2,'SliderStep',[1/(length(handles.img2)-1),0.1]);
handles.ct2 = length(handles.img2);

guidata(hObject, handles);


% --- Executes on button press in pushbuttonSynchronizeVideos.
function pushbuttonSynchronizeVideos_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSynchronizeVideos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global framerate;

[a1 b1 c1] = size(handles.img1{1});
[a2 b2 c2] = size(handles.img2{1});

ratA = a1/a2;
ratB = b1/b2;

str = get(handles.popupmenuSyncFrameSizeOption,'String');
val = get(handles.popupmenuSyncFrameSizeOption,'Value');

frames1 = length(handles.img1);
frames2 = length(handles.img2);

% %%do interpolation for both operations
fr1 = handles.vidInfo1.FrameRate;
fr2 = handles.vidInfo2.FrameRate;
ratio = fr2/fr1;

str = get(handles.popupmenuSyncFramerateOption,'String');
val = get(handles.popupmenuSyncFramerateOption,'Value');

h = msgbox(['Adding frames']);
if strcmp(str{val},'OriginalFramerates') == 1
    if frames1 > frames2
        for i = frames2+1:frames1
            set(findobj(h,'Tag','MessageBox'),'String',['Adding frame ' num2str(i) ' to video 2']);
            drawnow();
            handles.img2{i} = handles.img2{end};
        end
    elseif frames2 > frames1
        for i = frames1+1:frames2
            set(findobj(h,'Tag','MessageBox'),'String',['Adding frame ' num2str(i) ' to video 1']);
            handles.img1{i} = zeros(size(handles.img1{1}),class(handles.img1{1}));
            drawnow();
        end
    else
    end
    h = msgbox(['Resizing frame ' num2str(1)]);
    if strcmp(str{val},'MatchFrameSizeToLarger') == 1
        if a1 > a2
            for i = 1:length(handles.img2)
                set(findobj(h,'Tag','MessageBox'),'String',['Resizing frame ' num2str(i) ' in video 2']);
                handles.img2{i} = imresize(handles.img2{i},[a2*ratA,round(b2*ratA)]);
                drawnow();
            end
        elseif a2 > a1
            for i = 1:length(handles.img1)
                set(findobj(h,'Tag','MessageBox'),'String',['Resizing frame ' num2str(i) ' in video 1']);
                handles.img1{i} = imresize(handles.img1{i},[a1*ratA,round(b1*ratA)]);
                drawnow();
            end
        end
    else
        if a1 < a2
            ratA = a1/a2;
            for i = 1:length(handles.img2)
                set(findobj(h,'Tag','MessageBox'),'String',['Resizing frame ' num2str(i) ' in video 2']);
                handles.img2{i} = imresize(handles.img2{i},[a2*ratA,round(b2*ratA)]);
                drawnow();
            end
        elseif a2 < a1
            ratA = a2/a1;
            for i = 1:length(handles.img1)
                set(findobj(h,'Tag','MessageBox'),'String',['Resizing frame ' num2str(i) ' in video 1']);
                handles.img1{i} = imresize(handles.img1{i},[a1*ratA,round(b1*ratA)]);
                drawnow();
            end
        end
    end
    delete(h);
    h = msgbox('Merging frames');
    zers = '00000000';
    cmp = computer;
    if strcmp(cmp,'PCWIN64') == 1
        sysLine = ['del "' handles.pathstr '\*.tif'];
        system(sysLine);
    end
    for i = 1:length(handles.img1)
        img = [handles.img1{i} handles.img2{i}];
        fName = [zers(1:end-length(num2str(i))) num2str(i) '.tif'];
        imwrite(img,fullfile(handles.pathstr,fName));
        set(findobj(h,'Tag','MessageBox'),'String',['Merging frame ' num2str(i)]);
        drawnow();
    end
    delete(h);
    delete(h);
    cmp = computer;
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
        fName = get(handles.editMergedMovieName,'String');
        framerate = (fr2+fr1)/2;
        sysLine = (['"c:\program files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg" -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -codec copy -y -c:v mjpeg  "' [fullfile(pth,fName) '.avi"']]);
        system(sysLine);
        sysLine = ['"C:\Program Files\windows media player\wmplayer.exe" "' fullfile(pth,fName) '.avi"'];
        system(sysLine)
    end
    if strcmp(cmp,'MACI64') == 1
        sysLine = (['rm "' pth '/*.tif"']);
        system(sysLine);
        sysLine = 'killall ffmpeg';
        system(sysLine);
        pth = getenv('USER');
        pth = ['/Users/' pth '/Documents'];
        pth = [pth '/MovementScience'];
        fName = get(handles.editMergedMovieName,'String');
        framerate = (fr2+fr1)/2;
        sysLine = (['"/Applications/MovementScience/application/OSXFFMPEG/ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '.avi"']]);
        system(sysLine);
        sysLine = ['open "' fullfile(pth,fName) '.avi"'];
        system(sysLine)
    end
end
delete(h);
if strcmp(str{val},'MatchDuration') == 1
    h = msgbox(['Resizing frame ' num2str(1)]);
    if strcmp(str{val},'MatchFrameSizeToLarger') == 1
        if a1 > a2
            for i = 1:length(handles.img2)
                set(findobj(h,'Tag','MessageBox'),'String',['Resizing frame ' num2str(i) ' in video 2']);
                handles.img2{i} = imresize(handles.img2{i},[a2*ratA,round(b2*ratA)]);
                drawnow();
            end
        elseif a2 > a1
            for i = 1:length(handles.img1)
                set(findobj(h,'Tag','MessageBox'),'String',['Resizing frame ' num2str(i) ' in video 1']);
                handles.img1{i} = imresize(handles.img1{i},[a1*ratA,round(b1*ratA)]);
                drawnow();
            end
        end
    else
        if a1 < a2
            ratA = a1/a2;
            for i = 1:length(handles.img2)
                set(findobj(h,'Tag','MessageBox'),'String',['Resizing frame ' num2str(i) ' in video 2']);
                handles.img2{i} = imresize(handles.img2{i},[a2*ratA,round(b2*ratA)]);
                drawnow();
            end
        elseif a2 < a1
            ratA = a2/a1;
            for i = 1:length(handles.img1)
                set(findobj(h,'Tag','MessageBox'),'String',['Resizing frame ' num2str(i) ' in video 1']);
                handles.img1{i} = imresize(handles.img1{i},[a1*ratA,round(b1*ratA)]);
                drawnow();
            end
        end
    end
    delete(h);
    %interpolate frames
    if frames1 > frames2
        h = msgbox('Interpolating frames, this may take a minute');
        clear tmp;
        t1 = 0:max(handles.vidTimes1)/frames1:max(handles.vidTimes1);
        t2 = 0:max(handles.vidTimes1)/frames2:max(handles.vidTimes1);
        t1 = t1(1:end-1);
        t2 = t2(1:end-1);
        for i = 1:frames2
            tmp(:,:,i) = handles.img2{i}(:,:,1);
        end
        tmp = permute(tmp,[3 1 2]);
        tmp1 = interp1(t2,double(tmp),t1);
        clear tmp;
        for i = 1:frames2
            tmp(:,:,i) = handles.img2{i}(:,:,2);
        end
        tmp = permute(tmp,[3 1 2]);
        tmp2 = interp1(t2,double(tmp),t1);
        clear tmp;
        for i = 1:frames2
            tmp(:,:,i) = handles.img2{i}(:,:,3);
        end
        tmp = permute(tmp,[3 1 2]);
        %make false times
        tmp3 = interp1(t2,double(tmp),t1);
        tmp1 = permute(tmp1,[2 3 1]);
        tmp2 = permute(tmp2,[2 3 1]);
        tmp3 = permute(tmp3,[2 3 1]);
        [a b c] = size(tmp1);
        clear handles.img2;
        for i = 1:c
            handles.img2{i}(:,:,1) = tmp1(:,:,i);
            handles.img2{i}(:,:,2) = tmp2(:,:,i);
            handles.img2{i}(:,:,3) = tmp3(:,:,i);
        end
        delete(h)
    elseif frames2 > frames1
        clear tmp;
        h = msgbox('Interpolating frames, this may take a minute');
        t1 = 0:max(handles.vidTimes1)/frames1:max(handles.vidTimes1);
        t2 = 0:max(handles.vidTimes1)/frames2:max(handles.vidTimes1);
        t1 = t1(1:end-1);
        t2 = t2(1:end-1);
        for i = 1:frames1
            tmp(:,:,i) = handles.img1{i}(:,:,1);
        end
        tmp = permute(tmp,[3 1 2]);
        tmp1 = interp1(t1,double(tmp),t2);
        clear tmp;
        for i = 1:frames1
            tmp(:,:,i) = handles.img1{i}(:,:,2);
        end
        tmp = permute(tmp,[3 1 2]);
        tmp2 = interp1(t1,double(tmp),t2);
        clear tmp;
        for i = 1:frames1
            tmp(:,:,i) = handles.img1{i}(:,:,3);
        end
        tmp = permute(tmp,[3 1 2]);
        %make false times
        tmp3 = interp1(t1,double(tmp),t2);
        tmp1 = permute(tmp1,[2 3 1]);
        tmp2 = permute(tmp2,[2 3 1]);
        tmp3 = permute(tmp3,[2 3 1]);
        [a b c] = size(tmp1);
        clear handles.img1;
        for i = 1:c
            handles.img1{i}(:,:,1) = tmp1(:,:,i);
            handles.img1{i}(:,:,2) = tmp2(:,:,i);
            handles.img1{i}(:,:,3) = tmp3(:,:,i);
        end
        delete(h);
    end
    h = msgbox('Merging frames');
    zers = '00000000';
    cmp = computer;
    if strcmp(cmp,'PCWIN64') == 1
        sysLine = ['del "' handles.pathstr '\*.tif'];
        system(sysLine);
    end
    for i = 1:length(handles.img1)
        img = [handles.img1{i} handles.img2{i}];
        fName = [zers(1:end-length(num2str(i))) num2str(i) '.tif'];
        imwrite(img,fullfile(handles.pathstr,fName));
        set(findobj(h,'Tag','MessageBox'),'String',['Merging frame ' num2str(i)]);
        drawnow();
    end
    delete(h);
    cmp = computer;
    if strcmp(cmp,'PCWIN64') == 1
        sysLine = ['del ' pth '\*.tif'];
        system(sysLine);
        sysLine = 'Taskkill /IM ffmpeg.exe /F';
        system(sysLine);
        sysLine = 'Taskkill /IM cmd.exe /F';
        system(sysLine);
        pth = getenv('USERPROFILE');
        pth = [pth '\Documents'];
        sysLine = [' md ' pth '\MovementScience'];
        system(sysLine);
        pth = [pth '\MovementScience'];
        fName = get(handles.editMergedMovieName,'String');
        framerate = handles.vidInfo1.FrameRate;
        sysLine = (['"c:\program files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '.avi"']]);
        system(sysLine);
        sysLine = ['"C:\Program Files\windows media player\wmplayer.exe" "' fullfile(pth,fName) '.avi" &'];
        system(sysLine)
    end
    if strcmp(cmp,'MACI64') == 1
        sysLine = (['rm "' pth '/*.tif"']);
        system(sysLine);
        sysLine = 'killall ffmpeg';
        system(sysLine);
        pth = getenv('USER');
        pth = ['/Users/' pth '/Documents'];
        pth = [pth '/MovementScience'];
        fName = get(handles.editMergedMovieName,'String');
        framerate = handles.vidInfo1.FrameRate;
        sysLine = (['"/Applications/MovementScience/application/OSXFFMPEG/ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '.avi"']]);
        system(sysLine);
        sysLine = ['open "' fullfile(pth,fName) '.avi" &'];
        system(sysLine)
    end
%     if strcmp(cmp,'MACI64') == 1
%         sysLine = (['rm "' pth '/*.tif"']);
%         system(sysLine);
%         sysLine = 'killall ffmpeg';
%         system(sysLine);
%         pth = getenv('USER');
%         pth = ['/Users/' pth '/Documents'];
%         pth = [pth '/MovementScience'];
%         fName = get(handles.editMergedMovieName,'String');
%         framerate = (fr2+fr1)/2;
%         sysLine = (['"/Applications/MovementScience/application/OSXFFMPEG/ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '.avi" &']]);
%         system(sysLine);
%         sysLine = ['del "' handles.pathstr '\*.tif'];
%         system(sysLine);
%     end
end
delete(h);

handles.v = VideoReader([fullfile(pth,fName) '.avi']);
vidStr = [fName '.avi'];
pathstr = pth;
handles.vidInfo = get(handles.v);
global img;
img = cell(0);
ct=0;
while hasFrame(handles.v)
    ct=ct+1;
    img{ct} = readFrame(handles.v);
end




%make all frames same size
%make individual videos
%merge videos with ffmpeg
%ffmpeg -i input1.mp4 -i input2.mp4 -filter_complex \
%'[0:v]pad=iw*2:ih[int];[int][1:v]overlay=W/2:0[vid]' \
%-map [vid] -c:v libx264 -crf 23 -preset veryfast output.mp4

% --- Executes on selection change in popupmenuSyncFramerateOption.
function popupmenuSyncFramerateOption_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSyncFramerateOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSyncFramerateOption contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSyncFramerateOption


% --- Executes during object creation, after setting all properties.
function popupmenuSyncFramerateOption_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSyncFramerateOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuSyncFrameSizeOption.
function popupmenuSyncFrameSizeOption_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSyncFrameSizeOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSyncFrameSizeOption contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSyncFrameSizeOption


% --- Executes during object creation, after setting all properties.
function popupmenuSyncFrameSizeOption_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSyncFrameSizeOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMergedMovieName_Callback(hObject, eventdata, handles)
% hObject    handle to editMergedMovieName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMergedMovieName as text
%        str2double(get(hObject,'String')) returns contents of editMergedMovieName as a double


% --- Executes during object creation, after setting all properties.
function editMergedMovieName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMergedMovieName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonClearTiff.
function pushbuttonClearTiff_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearTiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pc = computer;
if strcmp(pc,'PCWIN64')
    sysLine = ['del /s "' handles.pathstr '\*.tif"'];
    system(sysLine);
end
if strcmp(pc,'MACI64')
    sysLine = ['rm "' handles.pathstr '/*.tif"'];
    system(sysLine);
end


% --- Executes on button press in pushbuttonAppendVideos.
function pushbuttonAppendVideos_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAppendVideos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
global pathtstr;
global vidStr;

pth = getenv('USERPROFILE');
pth = [pth '\Documents'];
sysLine = [' md ' pth '\MovementScience'];
system(sysLine);
pth = [pth '\MovementScience'];

pathstr = pth;
vidStr = get(handles.editMergedMovieName,'String');

[a1 b1 c1] = size(handles.img1{1});
[a2 b2 c2] = size(handles.img2{1});

if a1 == a2 && b1 == b2 && c1 == c2 %same size video, like from same camera
    img = [handles.img1 handles.img2];
else
    [a1 b1 c1] = size(handles.img1{1});
    [a2 b2 c3] = size(handles.img2{1});
    ratA = a1/a2;
    ratB = b1/b2;
    str = get(handles.popupmenuSyncFrameSizeOption,'String');
    val = get(handles.popupmenuSyncFrameSizeOption,'Value');
    frames1 = length(handles.img1);
    frames2 = length(handles.img2);
    fr1 = handles.vidInfo1.FrameRate;
    fr2 = handles.vidInfo2.FrameRate;
    h = msgbox(['Resizing frame ' num2str(1)]);
    if strcmp(str{val},'MatchFrameSizeToLarger') == 1%matches in vertical direction
        if a1 > a2
            for i = 1:length(handles.img2)
                set(findobj(h,'Tag','MessageBox'),'String',['Resizing frame ' num2str(i) ' in video 2']);
                if ratA > 1 || ratA == 1
                    handles.img2{i} = imresize(handles.img2{i},[a2*ratA,round(b2*ratA)]);
                else
                    handles.img2{i} = imresize(handles.img2{i},[a2/ratA,round(b2/ratA)]);
                end
                drawnow();
            end
        elseif a2 > a1
            for i = 1:length(handles.img1)
                set(findobj(h,'Tag','MessageBox'),'String',['Resizing frame ' num2str(i) ' in video 1']);
                if ratA > 1 || ratA == 1
                    handles.img1{i} = imresize(handles.img1{i},[a1*ratA,round(b1*ratA)]);
                else
                    handles.img1{i} = imresize(handles.img1{i},[a1/ratA,round(b1/ratA)]);
                end
                drawnow();
            end
        end
    else
        if a1 < a2
            ratA = a1/a2;
            for i = 1:length(handles.img2)
                set(findobj(h,'Tag','MessageBox'),'String',['Resizing frame ' num2str(i) ' in video 2']);
                if ratA > 1 || ratA == 1
                    handles.img2{i} = imresize(handles.img2{i},[a2/ratA,round(b2/ratA)]);
                else
                    handles.img2{i} = imresize(handles.img2{i},[a2*ratA,round(b2*ratA)]);
                end
                drawnow();
            end
        elseif a2 < a1
            ratA = a2/a1;
            for i = 1:length(handles.img1)
                set(findobj(h,'Tag','MessageBox'),'String',['Resizing frame ' num2str(i) ' in video 1']);
                if ratA > 1 || ratA == 1
                    handles.img1{i} = imresize(handles.img1{i},[a1/ratA,round(b1/ratA)]);
                else
                    handles.img1{i} = imresize(handles.img1{i},[a1*ratA,round(b1*ratA)]);
                end
                drawnow();
            end
        end
    end
    delete(h);
    %now pad smaller frame horizontally
    [a1 b1 c1] = size(handles.img1{1});
    [a2 b2 c2] = size(handles.img2{1});
    h = msgbox(['Padding frames']);
    if b1 > b2
        bDiff = b1-b2;
        if mod(bDiff,2) == 0
            left = zeros(a1,bDiff/2,3);
            right = left;
        else
            left = zeros(a1,floor(bDiff/2),3);
            right = zeros(a1,ceil(bDiff/2),3);
        end
        for i = 1:length(handles.img2)
            set(findobj(h,'Tag','MessageBox'),'String',['Padding frames ' num2str(i/length(handles.img2))]);
            drawnow();
            handles.img2{i} = [left handles.img2{i}];
            handles.img2{i} = [handles.img2{i} right];
        end
    elseif b2 > b1
        bDiff = b1-b2;
        if mod(bDiff,2) == 0
            left = zeros(a1,abs(bDiff/2),3);
            right = left;
        else
            left = zeros(a1,abs(floor(bDiff/2)),3);
            right = zeros(a1,abs(ceil(bDiff/2)),3);
        end
        for i = 1:length(handles.img1)
            set(findobj(h,'Tag','MessageBox'),'String',['Padding frames ' num2str(i/length(handles.img1))]);
            drawnow();
            handles.img1{i} = [left handles.img1{i}];
            handles.img1{i} = [handles.img1{i} right];
        end
    end
    %equalize framerates
    img = [handles.img1 handles.img2]; 
    delete(h);
end
    
    
    
zers = '00000000';
h = msgbox('Generating Video');
set(findobj(h,'Tag','MessageBox'),'String',['Generating Video ' num2str(1/length(img))]);
drawnow();
sysLine = ['del ' pth '\*.tif'];
system(sysLine);
for i = 1:length(img)
    fName = [zers(1:end-length(num2str(i))) num2str(i) '.tif'];
    imwrite(img{i},fullfile(pathstr,fName));
    set(findobj(h,'Tag','MessageBox'),'String',['Generating Video ' num2str(i/length(img))]);
    drawnow();
end

cmp = computer;
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
    fName = get(handles.editMergedMovieName,'String');
    framerate = handles.vidInfo1.FrameRate;
    sysLine = (['"c:\program files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '.avi"']]);
    system(sysLine);
    sysLine = ['"C:\Program Files\windows media player\wmplayer.exe" "' fullfile(pth,fName) '.avi" &'];
    system(sysLine)
end
if strcmp(cmp,'MACI64') == 1
%     sysLine = (['rm "' pth '/*.tif"']);
%     system(sysLine);
    sysLine = 'killall ffmpeg';
    system(sysLine);
    pth = getenv('USER');
    pth = ['/Users/' pth '/Documents'];
    pth = [pth '/MovementScience'];
    fName = get(handles.editMergedMovieName,'String');
    framerate = handles.vidInfo1.FrameRate;
    sysLine = (['"/Applications/MovementScience/application/OSXFFMPEG/ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '.avi"']]);
    system(sysLine);
    sysLine = ['open "' fullfile(pth,fName) '.avi" &'];
    system(sysLine)
end

delete(h);
delete(h);
