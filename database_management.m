function varargout = database_management(varargin)
 %initialize componeent on gui
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @database_management_OpeningFcn, ...
    'gui_OutputFcn',  @database_management_OutputFcn, ...
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

function database_management_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for database_management
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = database_management_OutputFcn(hObject, eventdata, handles)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
%creat database if isn't exist 
A = exist('database.mat')
if A==0
    plate="";
    save database.mat plate
end
%otherwise load it
load database.mat plate
%display all entries in database line by line as string 
set(handles.database_output,'String',plate);

% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)
 
load database.mat plate

inputplates = get(handles.input_plate,'String');

if inputplates~=""
    status=0;
    numberplates=string(zeros(1,size(plate,2)+1));
    for i=1:size( plate,2)
        numberplates(1,i)= plate(1,i);
        if plate(1,i)== inputplates
            status = 1;
        end
    end
    if status==0
        numberplates(1,size(plate,2)+1)= inputplates;
        plate =numberplates;
        save 'database.mat' plate
    end
end


set(handles.database_output,'String',plate);
guidata(hObject, handles);
% --- Executes on button press in delete.
function delete_Callback(hObject, eventdata, handles)

load database.mat data
inputplates = get(handles.input_plate,'String');

load 'database.mat' plate

if  inputplates~=""
    for i=1:size(plate,2)
        if plate(1,i)== inputplates
            plate(1,i)="";
         end
    end
    plate(strcmp("",plate))=[];
    save 'database.mat' plate
end

set(handles.database_output,'String',plate);
guidata(hObject, handles);


function input_plate_Callback(hObject, eventdata, handles)
 
input=get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function input_plate_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
