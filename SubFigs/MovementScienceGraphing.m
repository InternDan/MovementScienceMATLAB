function varargout = MovementScienceGraphing(varargin)
% MOVEMENTSCIENCEGRAPHING MATLAB code for MovementScienceGraphing.fig
%      MOVEMENTSCIENCEGRAPHING, by itself, creates a new MOVEMENTSCIENCEGRAPHING or raises the existing
%      singleton*.
%
%      H = MOVEMENTSCIENCEGRAPHING returns the handle to a new MOVEMENTSCIENCEGRAPHING or the handle to
%      the existing singleton*.
%
%      MOVEMENTSCIENCEGRAPHING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVEMENTSCIENCEGRAPHING.M with the given input arguments.
%
%      MOVEMENTSCIENCEGRAPHING('Property','Value',...) creates a new MOVEMENTSCIENCEGRAPHING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MovementScienceGraphing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MovementScienceGraphing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MovementScienceGraphing

% Last Modified by GUIDE v2.5 13-Feb-2018 11:08:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MovementScienceGraphing_OpeningFcn, ...
    'gui_OutputFcn',  @MovementScienceGraphing_OutputFcn, ...
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


% --- Executes just before MovementScienceGraphing is made visible.
function MovementScienceGraphing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MovementScienceGraphing (see VARARGIN)

% Choose default command line output for MovementScienceGraphing
handles.output = hObject;

h = findobj('Tag','MovementScience');
handles.handles2 = guidata(h);
guidata(hObject, handles);
initializeContents(hObject,eventdata,handles);

for i = 1:100
    str{i} = num2str(i);
end
set(handles.popupmenuDataLineWeight,'String',str);
set(handles.popupmenuVerticalLineWeight,'String',str);
set(handles.popupmenuTextSize,'String',str);

set(handles.popupmenuDataLineWeight,'Value',8);
set(handles.popupmenuVerticalLineWeight,'Value',3);
set(handles.popupmenuTextSize,'Value',11);
set(handles.popupmenuDataLineColor,'Value',1);
set(handles.popupmenuBackgroundColor,'Value',5);
set(handles.popupmenuVerticalLineColor,'Value',3);
set(handles.popupmenuTextColor,'Value',5);

set(handles.sliderBrightness,'Value',0.5);
set(handles.sliderBrightness,'min',0);
set(handles.sliderBrightness,'max',1);
set(handles.sliderBrightness,'SliderStep',[0.05/1,0.05]);

set(handles.sliderOpacity,'Value',0.5);
set(handles.sliderOpacity,'min',0);
set(handles.sliderOpacity,'max',1);
set(handles.sliderOpacity,'SliderStep',[0.05/1,0.05]);

handles.rescaled = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MovementScienceGraphing wait for user response (see UIRESUME)
% uiwait(handles.MovementScienceGraphing);


% --- Outputs from this function are returned to the command line.
function varargout = MovementScienceGraphing_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenuObjectToGraphX.
function popupmenuObjectToGraphX_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuObjectToGraphX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuObjectToGraphX contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuObjectToGraphX
updateGraph(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function popupmenuObjectToGraphX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuObjectToGraphX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuComponentToGraphX.
function popupmenuComponentToGraphX_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuComponentToGraphX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuComponentToGraphX contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuComponentToGraphX


% --- Executes during object creation, after setting all properties.
function popupmenuComponentToGraphX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuComponentToGraphX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuObjectToGraphY.
function popupmenuObjectToGraphY_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuObjectToGraphY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuObjectToGraphY contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuObjectToGraphY
updateGraph(hObject,eventdata,handles);




% --- Executes during object creation, after setting all properties.
function popupmenuObjectToGraphY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuObjectToGraphY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuComponentToGraphY.
function popupmenuComponentToGraphY_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuComponentToGraphY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuComponentToGraphY contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuComponentToGraphY


% --- Executes during object creation, after setting all properties.
function popupmenuComponentToGraphY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuComponentToGraphY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuDataLineColor.
function popupmenuDataLineColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuDataLineColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuDataLineColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuDataLineColor
updateGraph(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function popupmenuDataLineColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuDataLineColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuVerticalLineColor.
function popupmenuVerticalLineColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuVerticalLineColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuVerticalLineColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuVerticalLineColor
updateGraph(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function popupmenuVerticalLineColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuVerticalLineColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuDataLineWeight.
function popupmenuDataLineWeight_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuDataLineWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuDataLineWeight contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuDataLineWeight
updateGraph(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function popupmenuDataLineWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuDataLineWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuVerticalLineWeight.
function popupmenuVerticalLineWeight_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuVerticalLineWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuVerticalLineWeight contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuVerticalLineWeight
updateGraph(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function popupmenuVerticalLineWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuVerticalLineWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderGraphPerFrame_Callback(hObject, eventdata, handles)
% hObject    handle to sliderGraphPerFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = round(get(handles.sliderGraphPerFrame,'Value'));
set(handles.editFrameNumber,'String',num2str(val));
updateGraph(hObject,eventdata,handles);



% --- Executes during object creation, after setting all properties.
function sliderGraphPerFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderGraphPerFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in pushbuttonSaveCurrentGraphImage.
function pushbuttonSaveCurrentGraphImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveCurrentGraphImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = getimage(handles.axesGraph);
outstr = get(handles.editGraphImage,'String');
ispc = computer;
if strcmp(ispc,'PCWIN64') == 1
    pathstr = getenv('USERPROFILE');
    sysLine = ['md "' pathstr '\Documents\MovementScience"'];
    system(sysLine);
    pathstr = [pathstr '\Documents\MovementScience'];
else%add for linux and osx
    user = getenv('USER');
    pth = ['/Users/' user  '/Documents'];
    sysLine = [' mkdir ' pth '/MovementScience'];
    system(sysLine);
    pth = [pth '/MovementScience'];
    pathstr = pth;
end
try
    imwrite(im,fullfile(pathstr,[outstr '.png']));
catch
    im = export_fig(handles.axesGraph);
    imwrite(im,fullfile(pathstr,[outstr '.png']));
end


function editGraphImage_Callback(hObject, eventdata, handles)
% hObject    handle to editGraphImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGraphImage as text
%        str2double(get(hObject,'String')) returns contents of editGraphImage as a double
set(handles.sliderGraphPerFrame,'Value',num2str(get(handles.editGraphImage,'String')));
guidata(hObject,handles);
updateGraph(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function editGraphImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGraphImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenuBackgroundColor.
function popupmenuBackgroundColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuBackgroundColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuBackgroundColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuBackgroundColor
updateGraph(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function popupmenuBackgroundColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuBackgroundColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuTextColor.
function popupmenuTextColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTextColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTextColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTextColor
updateGraph(hObject,eventdata,handles);

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
updateGraph(hObject,eventdata,handles);

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


% --- Executes on selection change in popupmenuGraphBothAgainstTime.
function popupmenuGraphBothAgainstTime_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuGraphBothAgainstTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuGraphBothAgainstTime contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuGraphBothAgainstTime
updateGraph(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function popupmenuGraphBothAgainstTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuGraphBothAgainstTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonPreviewGraphOverlay.
function pushbuttonPreviewGraphOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPreviewGraphOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;

imshow(img{round(get(handles.sliderGraphPerFrame,'Value'))},'Parent',handles.axesGraph);
im = getimage(handles.axesGraph);
[a b c] = size(im);
updateGraph(hObject,eventdata,handles);
imGraph = getframe(handles.axesGraph);
imGraph = imGraph.cdata;
[ag bg cg] = size(imGraph);
gText = handles.handles2.title;
sz = get(handles.popupmenuTextSize,'Value');
clS = get(handles.popupmenuTextColor,'String');
v = get(handles.popupmenuTextColor,'Value');
clS = clS{v};
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
h = vision.AlphaBlender;
h.Opacity = get(handles.sliderOpacity,'Value');
C = step(h,im,imGraph);
brightness = get(handles.sliderBrightness,'Value');
C = imadjust(C,[0 brightness],[0 1]);
if strcmp(clS,'r') == 1
    clS = 'red';
elseif strcmp(clS,'g') == 1
    clS = 'green';
elseif strcmp(clS,'b') == 1
    clS = 'blue';
elseif strcmp(clS,'k') == 1
    clS = 'black';
elseif strcmp(clS,'y') == 1
    clS = 'yellow';
elseif strcmp(clS,'c') == 1
    clS = 'cyan';
elseif strcmp(clS,'w') == 1
    clS = 'white';
end
    
C = insertText(C,[10,10],gText,'FontSize',sz,'TextColor',clS,'BoxColor','white','BoxOpacity',0.1);
imshow(C,'Parent',handles.axesGraph);
drawnow();


% --- Executes on button press in pushbuttonOverlayGraphOnVideo.
function pushbuttonOverlayGraphOnVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOverlayGraphOnVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
global audio;
global audioFrequency;

% fName = get(handles.editOverlaidVideoName,'String');

cmp = computer;
set(handles.pushbuttonOverlayGraphOnVideo,'BackgroundColor','c');
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
        set(handles.sliderGraphPerFrame,'Value',i);
        set(handles.editFrameNumber,'String',num2str(i));
        imshow(img{i},'Parent',handles.axesGraph);
        im = getimage(handles.axesGraph);
        [a b c] = size(im);
        updateGraph(hObject,eventdata,handles);
        clear imGraph;
        imGraph = getframe(handles.axesGraph);
        imGraph = imGraph.cdata;
        [ag bg cg] = size(imGraph);
        gText = handles.handles2.title;
        sz = get(handles.popupmenuTextSize,'Value');
        clS = get(handles.popupmenuTextColor,'String');
        v = get(handles.popupmenuTextColor,'Value');
        clS = clS{v};
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
        h = vision.AlphaBlender;
        h.Opacity = get(handles.sliderOpacity,'Value');
        C = step(h,im,imGraph);
        brightness = get(handles.sliderBrightness,'Value');
        C = imadjust(C,[0 brightness],[0 1]);
        if strcmp(clS,'r') == 1
            clS = 'red';
        elseif strcmp(clS,'g') == 1
            clS = 'green';
        elseif strcmp(clS,'b') == 1
            clS = 'blue';
        elseif strcmp(clS,'k') == 1
            clS = 'black';
        elseif strcmp(clS,'y') == 1
            clS = 'yellow';
        elseif strcmp(clS,'c') == 1
            clS = 'cyan';
        elseif strcmp(clS,'w') == 1
            clS = 'white';
        end
        C = insertText(C,[10,10],gText,'FontSize',sz,'TextColor',clS,'BoxColor','white','BoxOpacity',0.1);
        zers = '00000000';
        imshow(C,'Parent',handles.axesGraph);
%         drawnow();
%         f = [zers(1:end-length(num2str(i))) num2str(i) '.tif'];
%         imwrite(C,fullfile(pth,f));
        img{i} = C;
    end
%     pth = getenv('USERPROFILE');
%     pth = [pth '\Documents'];
%     pth = [pth '\MovementScience'];
%     sysLine = 'Taskkill /IM ffmpeg.exe /F';
%     system(sysLine);
%     sysLine = 'Taskkill /IM cmd.exe /F';
%     system(sysLine);
%     %get info from audio file
%     try
%         info = audioinfo(fullfile(pth,'\myAudio.wav'));
%     catch
%     end
%     %framerate
%     try
%         framerate = handles.handles2.v.FrameRate;
%     catch
%         framerate = round(1/mean(diff(handles.handles2.time)));
%     end
%     %ffmpeg build
% %     fName = get(handles.editMovieName,'String');
%     if isfield(handles,'audio')
%         sysLine = (['"c:\program files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -i "' pth '\myAudio.wav" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '-Overlaid.avi" &']]);
%     else
%         sysLine = (['"c:\program files\MovementScience\application\WIN64FFMPEG\bin\ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '\%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '-Overlaid.avi" &']]);
%     end
%     system(sysLine);
    set(handles.pushbuttonOverlayGraphOnVideo,'BackgroundColor','g');
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
        set(handles.sliderGraphPerFrame,'Value',i);
        set(handles.editFrameNumber,'String',num2str(i));
        imshow(img{i},'Parent',handles.axesGraph);
        im = getimage(handles.axesGraph);
        [a b c] = size(im);
        updateGraph(hObject,eventdata,handles);
        clear imGraph;
        imGraph = getframe(handles.axesGraph);
        imGraph = imGraph.cdata;
        [ag bg cg] = size(imGraph);
        gText = handles.handles2.title;
        sz = get(handles.popupmenuTextSize,'Value');
        clS = get(handles.popupmenuTextColor,'String');
        v = get(handles.popupmenuTextColor,'Value');
        clS = clS{v};
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
        h = vision.AlphaBlender;
        h.Opacity = get(handles.sliderOpacity,'Value');
        C = step(h,im,imGraph);
        C = imadjust(C,[0 .3],[0 1]);
        if strcmp(clS,'r') == 1
            clS = 'red';
        elseif strcmp(clS,'g') == 1
            clS = 'green';
        elseif strcmp(clS,'b') == 1
            clS = 'blue';
        elseif strcmp(clS,'k') == 1
            clS = 'black';
        elseif strcmp(clS,'y') == 1
            clS = 'yellow';
        elseif strcmp(clS,'c') == 1
            clS = 'cyan';
        elseif strcmp(clS,'w') == 1
            clS = 'white';
        end
        C = insertText(C,[10,10],gText,'FontSize',sz,'TextColor',clS,'BoxColor','white','BoxOpacity',0.1);
        zers = '00000000';
        imshow(C,'Parent',handles.axesGraph);
%         drawnow();
        f = [zers(1:end-length(num2str(i))) num2str(i) '.tif'];
        imwrite(C,fullfile(pth,f));
    end
    %get info from audio file
    try
        info = audioinfo(fullfile(pth,'/myAudio.wav'));
    catch
    end
    %framerate
    try
        framerate = handles.handles2.v.FrameRate;
    catch
        framerate = round(1/mean(diff(handles.handles2.time)));
    end
    %ffmpeg build
%     fName = get(handles.editMovieName,'String');
    if isfield(handles,'audio')
        sysLine = (['"/Applications/MovementScience/application/OSXFFMPEG/ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '/%08d.tif" -i "' pth '/myAudio.wav" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '-Overlaid.avi" &']]);
    else
        sysLine = (['"/Applications/MovementScience/application/OSXFFMPEG/ffmpeg" -vsync 2 -framerate ' num2str(framerate) ' -i "' pth '/%08d.tif" -codec copy -y -c:v mjpeg -qscale:v 0  "' [fullfile(pth,fName) '-Overlaid.avi" &']]);
    end
    system(sysLine);
%     sysLine= ['rm ' fullfile(pth,'*.tif')];
%     system(sysLine);
    set(handles.pushbuttonOverlayGraphOnVideo,'BackgroundColor','g');
end


function editFrameNumber_Callback(hObject, eventdata, handles)
% hObject    handle to editFrameNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFrameNumber as text
%        str2double(get(hObject,'String')) returns contents of editFrameNumber as a double
set(handles.sliderGraphPerFrame,'Value',str2num(get(handles.editFrameNumber,'String')));
guidata(hObject,handles);
updateGraph(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function editFrameNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFrameNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function initializeContents(hObject,eventdata,handles)

global PointData;
global FrameRate;
global img;
 
numPointPositions = 0;
numAngles = 0;

[a b c] = size(img{1});

h = figure;
hi = imshow(img{1});
set(hi,'alphadata',0.5);

ct=0;
ct=ct+1;
%time first
str{ct} = 'Time';
%positions
numPointPositions = length(find(contains(PointData(:,3),'p')));
if numPointPositions > 0
    for i = 1:numPointPositions
        ct=ct+1;
        str{ct} = ['Point Position ' num2str(i) ' Horizontal'];
        ct=ct+1;
        str{ct} = ['Point Position ' num2str(i) ' Vertical'];
        ct=ct+1;
        str{ct} = ['Point Velocity ' num2str(i) ' Horizontal'];
        ct=ct+1;
        str{ct} = ['Point Velocity ' num2str(i) ' Vertical'];
        ct=ct+1;
        str{ct} = ['Point Acceleration ' num2str(i) ' Horizontal'];
        ct=ct+1;
        str{ct} = ['Point Acceleration ' num2str(i) ' Vertical'];
    end
end
%if there are positions, there's velocities and accelerations
%filter position data and calc velocity and acceleration
if numPointPositions > 0
    for i = 1:length(PointData(:,1))
        if strcmp(PointData{i,3},'p') == 1
            PointData{i,5} = bw_filter(PointData{i,4},round(FrameRate),2,'low',2);
            PointData{i,5} = [diff(PointData{i,5}(:,1)) diff(PointData{i,5}(:,2))];
            
            PointData{i,6} = bw_filter(PointData{i,5},round(FrameRate),2,'low',2);
            PointData{i,6} = [diff(PointData{i,6}(:,1)) diff(PointData{i,6}(:,2))];
            
            PointData{i,5} = [[0,0];PointData{i,5}] .* (FrameRate);
            PointData{i,6} = [[0,0];[0,0];PointData{i,6}] .* (FrameRate)^2;
        end
    end
end
        
%add angles to list        
numAngles = numAngles + length(find(contains(PointData(:,3),'2a')))/2;
if length(find(contains(PointData(:,3),'2a'))) > 0
    for i = 1:numAngles
        ct=ct+1;
        str{ct} = ['Angular Position ' num2str(i)];
        ct=ct+1;
        str{ct} = ['Angular Velocity ' num2str(i)];
        ct=ct+1;
        str{ct} = ['Angular Acceleration ' num2str(i)];
    end
end
numAngles = numAngles + length(find(contains(PointData(:,3),'3a')))/3;
if length(find(contains(PointData(:,3),'3a'))) > 0
    for i = 1:numAngles
        ct=ct+1;
        str{ct} = ['Angular Position ' num2str(i)];
        ct=ct+1;
        str{ct} = ['Angular Velocity ' num2str(i)];
        ct=ct+1;
        str{ct} = ['Angular Acceleration ' num2str(i)];
    end
end
numAngles = numAngles + length(find(contains(PointData(:,3),'4a')))/4;
if length(find(contains(PointData(:,3),'4a'))) > 0
    for i = 1:numAngles
        ct=ct+1;
        str{ct} = ['Angular Position ' num2str(i)];
        ct=ct+1;
        str{ct} = ['Angular Velocity ' num2str(i)];
        ct=ct+1;
        str{ct} = ['Angular Acceleration ' num2str(i)];
    end
end

set(handles.popupmenuObjectToGraphX,'String',str);
set(handles.popupmenuObjectToGraphY,'String',str);

guidata(hObject, handles);


function updateGraph(hObject,eventdata,handles)

global PointData;
global img;

if get(handles.sliderGraphPerFrame,'Value') == 0
    set(handles.sliderGraphPerFrame,'Value',1);
    set(handles.sliderGraphPerFrame,'min',1);
    set(handles.sliderGraphPerFrame,'max',length(img));
    set(handles.sliderGraphPerFrame,'SliderStep',[1/(length(img)-1),0.1]);
    set(handles.editGraphImage,'String','1');
end


str = get(handles.popupmenuObjectToGraphX,'String');
val = get(handles.popupmenuObjectToGraphX,'Value');
xStr = str{val};
xC = strsplit(xStr,' ');

str = get(handles.popupmenuObjectToGraphY,'String');
val = get(handles.popupmenuObjectToGraphY,'Value');
yStr = str{val};
yC = strsplit(yStr,' ');

%%split point data from angle data
c1=0;
c2=0;
for i = 1:length(PointData(:,1))
    if strcmp(PointData{i,3},'p') == 1
        c1 = c1+1;
        points(c1,:) = PointData(i,:);
    else
        c2 = c2+1;
        angles(c2,:) = PointData(i,:);
    end
end

%get y data
if strcmp(yC,'Time') == 1
    msgbox('Time is not supported as an outcome variable');
else
    if strcmp(yC{1},'Point') == 1
        if strcmp(yC{2},'Position') == 1
            if strcmp(yC{4},'Horizontal') == 1
                yData = points{str2num(yC{3}),4}(:,1);
                yStart = points{str2num(yC{3}),1};
            elseif strcmp(yC{4},'Vertical') == 1
                 yData = points{str2num(yC{3}),4}(:,2);
                 yStart = points{str2num(yC{3}),1};
            end
        elseif strcmp(yC{2},'Velocity') == 1
            if strcmp(yC{4},'Horizontal') == 1
                yData = points{str2num(yC{3}),5}(:,1);
                yStart = points{str2num(yC{3}),1};
            elseif strcmp(yC{4},'Vertical') == 1
                 yData = points{str2num(yC{3}),5}(:,2);
                 yStart = points{str2num(yC{3}),1};
            end
        elseif strcmp(yC{2},'Acceleration') == 1
            if strcmp(yC{4},'Horizontal') == 1
                yData = points{str2num(yC{3}),6}(:,1);
                yStart = points{str2num(yC{3}),1};
            elseif strcmp(yC{4},'Vertical') == 1
                 yData = points{str2num(yC{3}),6}(:,2);
                 yStart = points{str2num(yC{3}),1};
            end
        end
    elseif strcmp(yC{1},'Angular') == 1
        if strcmp(yC{2},'Position') == 1
            yData = angles{str2num(yC{3}),8};
            yStart = angles{str2num(yC{3}),1};
        elseif strcmp(yC{2},'Velocity') == 1
            yData = angles{str2num(yC{3}),9};
            yStart = angles{str2num(yC{3}),1};
        elseif strcmp(yC{2},'Acceleration') == 1
            yData = angles{str2num(yC{3}),10};
            yStart = angles{str2num(yC{3}),1};
        end
    end
end


% get x data
if strcmp(xC,'Time') == 1
    xData = handles.handles2.vidTimes;
    xStart = 1;
else
    if strcmp(xC{1},'Point') == 1
        if strcmp(xC{2},'Position') == 1
            if strcmp(xC{4},'Horizontal') == 1
                xData = PointData{str2num(xC{3}),4}(:,1);
                xStart = PointData{str2num(xC{3}),1};
            elseif strcmp(xC{4},'Vertical') == 1
                 xData = PointData{str2num(xC{3}),4}(:,2);
                 xStart = PointData{str2num(xC{3}),1};
            end
        elseif strcmp(xC{2},'Velocity') == 1
            if strcmp(xC{4},'Horizontal') == 1
                xData = PointData{str2num(xC{3}),5}(:,1);
                xStart = PointData{str2num(xC{3}),1};
            elseif strcmp(xC{4},'Vertical') == 1
                 xData = PointData{str2num(xC{3}),5}(:,2);
                 xStart = PointData{str2num(xC{3}),1};
            end
        elseif strcmp(xC{2},'Acceleration') == 1
            if strcmp(xC{4},'Horizontal') == 1
                xData = PointData{str2num(xC{3}),6}(:,1);
                xStart = PointData{str2num(xC{3}),1};
            elseif strcmp(xC{4},'Vertical') == 1
                 xData = PointData{str2num(xC{3}),6}(:,2);
                 xStart = PointData{str2num(xC{3}),1};
            end
        end
    elseif strcmp(xC{1},'Angular') == 1
        if strcmp(xC{2},'Position') == 1
            xData = PointData{str2num(xC{3}),8};
            xStart = PointData{str2num(xC{3}),1};
        elseif strcmp(xC{2},'Velocity') == 1
            xData = PointData{str2num(xC{3}),9};
            xStart = PointData{str2num(xC{3}),1};
        elseif strcmp(xC{2},'Acceleration') == 1
            xData = PointData{str2num(xC{3}),10};
            xStart = PointData{str2num(xC{3}),1};
        end
    end
end
    


str = get(handles.popupmenuDataLineColor,'String');
val = get(handles.popupmenuDataLineColor,'Value');
dataColor = str{val};

str = get(handles.popupmenuVerticalLineColor,'String');
val = get(handles.popupmenuVerticalLineColor,'Value');
verticalColor = str{val};

val = get(handles.popupmenuDataLineWeight,'Value');
dataWeight = val;

val = get(handles.popupmenuVerticalLineWeight,'Value');
verticalWeight = val;

v = get(handles.popupmenuGraphBothAgainstTime,'Value');

diff = yStart - xStart;
if diff == 0
elseif diff > 0
    xData= xData((yStart - xStart + 1):end);
else
    yData= yData((xStart - yStart + 1):end);
end

if length(xData) > length(yData)
    handles.xData = xData(1:length(yData));
    xData = handles.xData;
elseif length(xData) < length(yData)
    handlesyData = yData(1:length(xData));
    yData = handles.yData;
else
    handles.xData = xData;
    handles.yData = yData;
end
    


if v == 1
    plot(handles.axesGraph,xData,yData,'LineWidth',dataWeight,'Color',dataColor);

    bgColor = get(handles.popupmenuBackgroundColor,'String');
    v = get(handles.popupmenuBackgroundColor,'Value');
    bgColor = bgColor{v};

    ax = handles.axesGraph;
    set(handles.axesGraph,'color',bgColor);
    yLim = ax.YLim;
    frame = ceil(get(handles.sliderGraphPerFrame,'Value'));
    handles.hLine = line(handles.axesGraph,[handles.handles2.vidTimes(frame) handles.handles2.vidTimes(frame)],yLim,'Color',verticalColor,'LineWidth',verticalWeight);
    handles.handles2.title = [yStr '-' xStr];
    str = get(handles.popupmenuTextSize,'String');
    v = get(handles.popupmenuTextSize,'Value');
    clr = get(handles.popupmenuTextColor,'String');
    v2 = get(handles.popupmenuTextColor,'Value');
    title(handles.handles2.title,'FontSize',v,'Color',clr{v2});
    if handles.rescaled == 1
        set(handles.axesGraph,'xlim',[min(handles.xData) max(handles.xData)]);
        set(handles.axesGraph,'ylim',[min(handles.yData) max(handles.yData)]);
        drawnow();
    end
    guidata(hObject, handles);
else
    v = get(handles.popupmenuDataLineWeight,'Value');
    clr = get(handles.popupmenuDataLineColor,'String');
    v2 = get(handles.popupmenuDataLineColor,'Value');
    clr = clr{v2};
    frame = round(get(handles.sliderGraphPerFrame,'Value'));
    if frame == 0
        frame = 1;
    end
    for i = 1:length(xData)
        if i ~= frame
            if strcmp(clr,'r') == 1
                c(i,:) = [1 0 0];
            elseif strcmp(clr,'g') == 1
                c(i,:) = [0 1 0];
            elseif strcmp(clr,'b') == 1
                c(i,:) = [0 0 1];
            elseif strcmp(clr,'c') == 1
                c(i,:) = [0 1 1];
            elseif strcmp(clr,'k') == 1
                c(i,:) = [0 0 0];
            elseif strcmp(clr,'y') == 1
                c(i,:) = [1 1 0];
            elseif strcmp(clr,'w') == 1
                c(i,:) = [1 1 1];
            end
        else
            c(i,:) = [1 0 1];
        end
    end
    scatter(xData,yData,v,c,'filled');
    bgColor = get(handles.popupmenuBackgroundColor,'String');
    v = get(handles.popupmenuBackgroundColor,'Value');
    bgColor = bgColor{v};
    handles.handles2.title = [yStr '-' xStr];
    str = get(handles.popupmenuTextSize,'String');
    v = get(handles.popupmenuTextSize,'Value');
    clr = get(handles.popupmenuTextColor,'String');
    v2 = get(handles.popupmenuTextColor,'Value');
    set(handles.axesGraph,'color',bgColor);
    title(handles.handles2.title,'FontSize',v,'Color',clr{v2});
    if handles.rescaled == 1
        set(handles.axesGraph,'xlim',[min(handles.xData) max(handles.xData)]);
        set(handles.axesGraph,'ylim',[min(handles.yData) max(handles.yData)]);
        drawnow();
    end
    guidata(hObject, handles);
end
    
    
    



function editOverlaidVideoName_Callback(hObject, eventdata, handles)
% hObject    handle to editOverlaidVideoName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOverlaidVideoName as text
%        str2double(get(hObject,'String')) returns contents of editOverlaidVideoName as a double


% --- Executes during object creation, after setting all properties.
function editOverlaidVideoName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOverlaidVideoName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderTransparency_Callback(hObject, eventdata, handles)
% hObject    handle to sliderTransparency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderTransparency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderTransparency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderOpacity_Callback(hObject, eventdata, handles)
% hObject    handle to sliderOpacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global img;

imshow(img{round(get(handles.sliderGraphPerFrame,'Value'))},'Parent',handles.axesGraph);
im = getimage(handles.axesGraph);
[a b c] = size(im);
handles.handles2.updatePause = 1;
updateGraph(hObject,eventdata,handles);
imGraph = getframe(handles.axesGraph);
imGraph = imGraph.cdata;
[ag bg cg] = size(imGraph);
gText = handles.handles2.title;
sz = get(handles.popupmenuTextSize,'Value');
clS = get(handles.popupmenuTextColor,'String');
v = get(handles.popupmenuTextColor,'Value');
clS = clS{v};
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
h = vision.AlphaBlender;
h.Opacity = get(handles.sliderOpacity,'Value');
C = step(h,im,imGraph);
C = imadjust(C,[0 .3],[0 1]);
if strcmp(clS,'r') == 1
    clS = 'red';
elseif strcmp(clS,'g') == 1
    clS = 'green';
elseif strcmp(clS,'b') == 1
    clS = 'blue';
elseif strcmp(clS,'k') == 1
    clS = 'black';
elseif strcmp(clS,'y') == 1
    clS = 'yellow';
elseif strcmp(clS,'c') == 1
    clS = 'cyan';
elseif strcmp(clS,'w') == 1
    clS = 'white';
end
    
C = insertText(C,[10,10],gText,'FontSize',sz,'TextColor',clS,'BoxColor','white','BoxOpacity',0.1);
imshow(C,'Parent',handles.axesGraph);
drawnow();

% --- Executes during object creation, after setting all properties.
function sliderOpacity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderOpacity (see GCBO)
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

imshow(img{round(get(handles.sliderGraphPerFrame,'Value'))},'Parent',handles.axesGraph);
im = getimage(handles.axesGraph);
[a b c] = size(im);
handles.handles2.updatePause = 1;
updateGraph(hObject,eventdata,handles);
imGraph = getframe(handles.axesGraph);
imGraph = imGraph.cdata;
[ag bg cg] = size(imGraph);
gText = handles.handles2.title;
sz = get(handles.popupmenuTextSize,'Value');
clS = get(handles.popupmenuTextColor,'String');
v = get(handles.popupmenuTextColor,'Value');
clS = clS{v};
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
h = vision.AlphaBlender;
h.Opacity = get(handles.sliderOpacity,'Value');
C = step(h,im,imGraph);
brightness = get(handles.sliderBrightness,'Value');
C = imadjust(C,[0 brightness],[0 1]);
if strcmp(clS,'r') == 1
    clS = 'red';
elseif strcmp(clS,'g') == 1
    clS = 'green';
elseif strcmp(clS,'b') == 1
    clS = 'blue';
elseif strcmp(clS,'k') == 1
    clS = 'black';
elseif strcmp(clS,'y') == 1
    clS = 'yellow';
elseif strcmp(clS,'c') == 1
    clS = 'cyan';
elseif strcmp(clS,'w') == 1
    clS = 'white';
end
    
C = insertText(C,[10,10],gText,'FontSize',sz,'TextColor',clS,'BoxColor','white','BoxOpacity',0.1);
imshow(C,'Parent',handles.axesGraph);

% --- Executes during object creation, after setting all properties.
function sliderBrightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBrightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in togglebuttonRescaleAxes.
function togglebuttonRescaleAxes_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonRescaleAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.togglebuttonRescaleAxes,'Value');
if val == 1
    set(handles.togglebuttonRescaleAxes,'BackgroundColor','g');
    set(handles.axesGraph,'xlim',[min(handles.xData) max(handles.xData)]);
    set(handles.axesGraph,'ylim',[min(handles.yData) max(handles.yData)]);
    handles.rescaled = 1;
    drawnow();
    guidata(hObject, handles);
else
    set(handles.togglebuttonRescaleAxes,'BackgroundColor','r');
    drawnow();
    handles.rescaled = 0;
    guidata(hObject, handles);
    updateGraph(hObject,eventdata,handles);
end
