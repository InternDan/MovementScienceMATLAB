function varargout = AdvancedSettingsForMovementScience(varargin)
% ADVANCEDSETTINGSFORMOVEMENTSCIENCE MATLAB code for AdvancedSettingsForMovementScience.fig
%      ADVANCEDSETTINGSFORMOVEMENTSCIENCE, by itself, creates a new ADVANCEDSETTINGSFORMOVEMENTSCIENCE or raises the existing
%      singleton*.
%
%      H = ADVANCEDSETTINGSFORMOVEMENTSCIENCE returns the handle to a new ADVANCEDSETTINGSFORMOVEMENTSCIENCE or the handle to
%      the existing singleton*.
%
%      ADVANCEDSETTINGSFORMOVEMENTSCIENCE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADVANCEDSETTINGSFORMOVEMENTSCIENCE.M with the given input arguments.
%
%      ADVANCEDSETTINGSFORMOVEMENTSCIENCE('Property','Value',...) creates a new ADVANCEDSETTINGSFORMOVEMENTSCIENCE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AdvancedSettingsForMovementScience_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AdvancedSettingsForMovementScience_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AdvancedSettingsForMovementScience

% Last Modified by GUIDE v2.5 12-Dec-2017 16:52:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AdvancedSettingsForMovementScience_OpeningFcn, ...
                   'gui_OutputFcn',  @AdvancedSettingsForMovementScience_OutputFcn, ...
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


% --- Executes just before AdvancedSettingsForMovementScience is made visible.
function AdvancedSettingsForMovementScience_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AdvancedSettingsForMovementScience (see VARARGIN)

% Choose default command line output for AdvancedSettingsForMovementScience
handles.output = hObject;

global img;
handles.im = img{round(length(img)/2)};
handles.imOrig = handles.im;
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

for i = 1:100
    str{i} = num2str(i);
end

set(handles.popupmenuPointWeight,'String',str);
set(handles.popupmenuPointWeight,'Value',PointWeight);
set(handles.popupmenuPointSize,'String',str);
set(handles.popupmenuPointSize,'Value',PointSize);
set(handles.popupmenuTrailingPointWeight,'String',str);
set(handles.popupmenuTrailingPointWeight,'Value',TrailingPointWeight);
set(handles.popupmenuTrailingPointSize,'String',str);
set(handles.popupmenuTrailingPointSize,'Value',TrailingPointSize);
set(handles.popupmenuLineWeight,'String',str);
set(handles.popupmenuLineWeight,'Value',LineWeight);
set(handles.popupmenuTextWeight,'String',str);
set(handles.popupmenuTextWeight,'Value',TextWeight);
set(handles.popupmenuTextSize,'String',str);
set(handles.popupmenuTextSize,'Value',TextSize);
%match to colors
if strcmp(TextColor,'black') == 1
    set(handles.popupmenuTextColor,'Value',6);
elseif strcmp(TextColor,'white') == 1
    set(handles.popupmenuTextColor,'Value',7);
elseif strcmp(TextColor,'yellow') == 1
    set(handles.popupmenuTextColor,'Value',5);
elseif strcmp(TextColor,'cyan') == 1
    set(handles.popupmenuTextColor,'Value',4);
elseif strcmp(TextColor,'blue') == 1
    set(handles.popupmenuTextColor,'Value',3);
elseif strcmp(TextColor,'green') == 1
    set(handles.popupmenuTextColor,'Value',2);
elseif strcmp(TextColor,'red') == 1
    set(handles.popupmenuTextColor,'Value',1);
end
if strcmp(PointColor,'k') == 1
    set(handles.popupmenuPointColor,'Value',6);
elseif strcmp(PointColor,'w') == 1
    set(handles.popupmenuPointColor,'Value',7);
elseif strcmp(PointColor,'y') == 1
    set(handles.popupmenuPointColor,'Value',5);
elseif strcmp(PointColor,'c') == 1
    set(handles.popupmenuPointColor,'Value',4);
elseif strcmp(PointColor,'b') == 1
    set(handles.popupmenuPointColor,'Value',3);
elseif strcmp(PointColor,'g') == 1
    set(handles.popupmenuPointColor,'Value',2);
elseif strcmp(PointColor,'r') == 1
    set(handles.popupmenuPointColor,'Value',1);
end
if strcmp(TrailingPointColor,'k') == 1
    set(handles.popupmenuTrailingPointColor,'Value',6);
elseif strcmp(TrailingPointColor,'w') == 1
    set(handles.popupmenuTrailingPointColor,'Value',7);
elseif strcmp(TrailingPointColor,'y') == 1
    set(handles.popupmenuTrailingPointColor,'Value',5);
elseif strcmp(TrailingPointColor,'c') == 1
    set(handles.popupmenuTrailingPointColor,'Value',4);
elseif strcmp(TrailingPointColor,'b') == 1
    set(handles.popupmenuTrailingPointColor,'Value',3);
elseif strcmp(TrailingPointColor,'g') == 1
    set(handles.popupmenuTrailingPointColor,'Value',2);
elseif strcmp(TrailingPointColor,'r') == 1
    set(handles.popupmenuTrailingPointColor,'Value',1);
end
if strcmp(LineColor,'k') == 1
    set(handles.popupmenuLineColor,'Value',6);
elseif strcmp(LineColor,'w') == 1
    set(handles.popupmenuLineColor,'Value',7);
elseif strcmp(LineColor,'y') == 1
    set(handles.popupmenuLineColor,'Value',5);
elseif strcmp(LineColor,'c') == 1
    set(handles.popupmenuLineColor,'Value',4);
elseif strcmp(LineColor,'b') == 1
    set(handles.popupmenuLineColor,'Value',3);
elseif strcmp(LineColor,'g') == 1
    set(handles.popupmenuLineColor,'Value',2);
elseif strcmp(LineColor,'r') == 1
    set(handles.popupmenuLineColor,'Value',1);
end

set(handles.editTrackingSearchRadius,'String',num2str(SearchRadius));
set(handles.editNumberOfTrailingPoints,'String',num2str(TrailingPointNumber));
    
imshow(handles.im,'Parent',handles.axesPreview);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AdvancedSettingsForMovementScience wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AdvancedSettingsForMovementScience_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenuPointColor.
function popupmenuPointColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPointColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuPointColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuPointColor
global PointColor
val = get(handles.popupmenuPointColor,'Value');
str = get(handles.popupmenuPointColor,'String');
PointColor = str{val};

% --- Executes during object creation, after setting all properties.
function popupmenuPointColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuPointColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuTrailingPointColor.
function popupmenuTrailingPointColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTrailingPointColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTrailingPointColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTrailingPointColor
global TrailingPointColor
val = get(handles.popupmenuTrailingPointColor,'Value');
str = get(handles.popupmenuTrailingPointColor,'String');
TrailingPointColor = str{val};

% --- Executes during object creation, after setting all properties.
function popupmenuTrailingPointColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTrailingPointColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuLineColor.
function popupmenuLineColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuLineColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuLineColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuLineColor
global LineColor
val = get(handles.popupmenuLineColor,'Value');
str = get(handles.popupmenuLineColor,'String');
LineColor = str{val};

% --- Executes during object creation, after setting all properties.
function popupmenuLineColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuLineColor (see GCBO)
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
global TextColor
val = get(handles.popupmenuTextColor,'Value');
str = get(handles.popupmenuTextColor,'String');
TextColor = str{val};

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


% --- Executes on selection change in popupmenuPointWeight.
function popupmenuPointWeight_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPointWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuPointWeight contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuPointWeight
global PointWeight
PointWeight = get(handles.popupmenuPointWeight,'Value');

% --- Executes during object creation, after setting all properties.
function popupmenuPointWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuPointWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuTrailingPointWeight.
function popupmenuTrailingPointWeight_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTrailingPointWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTrailingPointWeight contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTrailingPointWeight
global TrailingPointWeight
TrailingPointWeight = get(handles.popupmenuTrailingPointWeight,'Value');

% --- Executes during object creation, after setting all properties.
function popupmenuTrailingPointWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTrailingPointWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuLineWeight.
function popupmenuLineWeight_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuLineWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuLineWeight contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuLineWeight
global LineWeight
LineWeight = get(handles.popupmenuLineWeight,'Value');

% --- Executes during object creation, after setting all properties.
function popupmenuLineWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuLineWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuTextWeight.
function popupmenuTextWeight_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTextWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTextWeight contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTextWeight
global TextWeight
TextWeight = get(handles.popupmenuTextWeight,'Value');

% --- Executes during object creation, after setting all properties.
function popupmenuTextWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTextWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuPointSize.
function popupmenuPointSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPointSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuPointSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuPointSize
global PointSize
PointSize = get(handles.popupmenuPointSize,'Value');

% --- Executes during object creation, after setting all properties.
function popupmenuPointSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuPointSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuTrailingPointSize.
function popupmenuTrailingPointSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTrailingPointSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTrailingPointSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTrailingPointSize
global TrailingPointSize
TrailingPointSize = get(handles.popupmenuTrailingPointSize,'Value');

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


% --- Executes on selection change in popupmenuTextSize.
function popupmenuTextSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTextSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTextSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTextSize
global TextSize;
TextSize = get(handles.popupmenuTextSize,'Value');

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



function editNumberOfTrailingPoints_Callback(hObject, eventdata, handles)
% hObject    handle to editNumberOfTrailingPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumberOfTrailingPoints as text
%        str2double(get(hObject,'String')) returns contents of editNumberOfTrailingPoints as a double
global TrailingPointNumber
x = get(handles.editNumberOfTrailingPoints,'String');
TrailingPointNumber = str2num(x);



% --- Executes during object creation, after setting all properties.
function editNumberOfTrailingPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumberOfTrailingPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTrackingSearchRadius_Callback(hObject, eventdata, handles)
% hObject    handle to editTrackingSearchRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTrackingSearchRadius as text
%        str2double(get(hObject,'String')) returns contents of editTrackingSearchRadius as a double
global SearchRadius;
str = get(handles.editTrackingSearchRadius,'String');
SearchRadius = str2num(str);

% --- Executes during object creation, after setting all properties.
function editTrackingSearchRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTrackingSearchRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonAddFeature.
function pushbuttonAddFeature_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddFeature (see GCBO)
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

imshow(handles.im,'Parent',handles.axesPreview);
drawnow();

str = get(handles.popupmenuFeatureList,'String');
val = get(handles.popupmenuFeatureList,'Value');
feat = str{val};
if strcmpi(feat,'Point') == 1
    [x y] = getpts(handles.axesPreview);
    ptsz = zeros(size(x));
    ptsz(:) = PointSize;
    handles.im = insertShape(handles.im,'circle',[x y ptsz],'LineWidth',PointWeight,'Color',PointColor);
    imshow(handles.im,'Parent',handles.axesPreview);
    drawnow();
    guidata(hObject, handles);
elseif strcmpi(feat,'PointWithTrailing') == 1
    [x y] = getpts(handles.axesPreview);
    ptsz = zeros(size(x));
    ptsz(:) = PointSize;
    ptsz2 = zeros(size(x));
    ptsz2(:) = TrailingPointSize;
    handles.im = insertShape(handles.im,'circle',[x y ptsz],'LineWidth',PointWeight,'Color',PointColor);
    handles.im = insertShape(handles.im,'circle',[x y ptsz2],'LineWidth',TrailingPointWeight,'Color',TrailingPointColor);
    imshow(handles.im,'Parent',handles.axesPreview);
    drawnow();
    guidata(hObject, handles);
elseif strcmpi(feat,'Line') == 1
    [x y] = getpts(handles.axesPreview);
    ptsz = zeros(size(x));
    ptsz(:) = PointSize;
    handles.im = insertShape(handles.im,'circle',[x y ptsz],'LineWidth',PointWeight,'Color',PointColor);
    handles.im = insertShape(handles.im,'line',[x(1) y(1) x(2) y(2)],'LineWidth',LineWeight,'Color',LineColor);
    imshow(handles.im,'Parent',handles.axesPreview);
    drawnow();
    guidata(hObject, handles);
elseif strcmpi(feat,'TextBox') == 1
    [x y] = getpts(handles.axesPreview);
    pt = [x y];
    text1 = inputdlg('Please enter the text you''d like in the textbox');
    boxColor = 'y';
    [aa bb cc] = size(getimage(handles.axesPreview));
    handles.im = getimage(handles.axesPreview);
    handles.im = insertText(handles.im,[pt(1),pt(2)],text1{1},'FontSize',TextSize,'TextColor',TextColor,'BoxOpacity',0.4,'BoxColor',boxColor);
    imshow(handles.im,'Parent',handles.axesPreview);
    drawnow();
    guidata(hObject, handles);
end
    
% --- Executes on selection change in popupmenuFeatureList.
function popupmenuFeatureList_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuFeatureList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuFeatureList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuFeatureList


% --- Executes during object creation, after setting all properties.
function popupmenuFeatureList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuFeatureList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonClearImage.
function pushbuttonClearImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.im = handles.imOrig;
imshow(handles.im,'Parent',handles.axesPreview);
guidata(hObject, handles);
