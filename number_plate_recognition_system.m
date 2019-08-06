classdef number_plate_recognition_system < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        %defining all entity of projects.
        UIFigure             matlab.ui.Figure
        UIAxes               matlab.ui.control.UIAxes
        InitializeButton     matlab.ui.control.Button
        ADDButton            matlab.ui.control.Button
        DELETEButton         matlab.ui.control.Button
        NumberPlateLabel     matlab.ui.control.Label
        StatusLabel          matlab.ui.control.Label
        DatabaseButton       matlab.ui.control.Button
        ObjectDetectedLabel  matlab.ui.control.Label
        StartButton          matlab.ui.control.Button
        startupFcnButton     matlab.ui.control.Button
    end
 
    properties (Access = private)
        %defining global variables
        camera % Camera
        a      % Arduino
        lcd    % LCD
        s      % Servomotor
        str    % String Variable for display status at instance
        net1    % AI train bot on hand written charecters
        inputplate  % input plate number
        %dimension of plates in images
        plate_dimensions1 
        plate_dimensions2
    end
    %functions used by projects 
    methods (Access = private)
        %Algorthm for detecting and converted numplate image into
        %alphanumeric charecters
        function detectnumber=detection(app,car_image)
            cam=app.camera;
            charecter_recognition=app.net1;
            % rgb to gray scale conversion 
            car_image_gray=rgb2gray(car_image);
            
            %gray to binary conversion
            car_image_binary = imbinarize(car_image_gray,'adaptive', 'Sensitivity',0.6);
            
            %finding objects in binary scale image
            [labeledImage,numobjects] = bwlabel(car_image_binary,4);
            %finding boundries in labeled images
            region = regionprops(labeledImage, 'all');
            %stores bounding boxes of all objects present in binery image
            boundingboxes=zeros(numobjects,4);
            for i=1:numobjects
                boundingboxes(i,:)= region(i).BoundingBox ;
            end
            boundingboxes=round(boundingboxes);
 
            %take dimensions from initialize plate dimension for comperison
            %purpose with bounding boxes in labelled image
            min_height = app.plate_dimensions1(1);
            max_height= app.plate_dimensions1(2);
            min_width= app.plate_dimensions1(3);
            max_width = app.plate_dimensions1(4);
            val1=''; %store instantenus value of plate
            flag=0; %status checking
 
            for labels=1:numobjects
                %dimension from all objects
                min_row=boundingboxes(labels,1);
                min_col=boundingboxes(labels,2);
                region_width=boundingboxes(labels,3);
                region_height=boundingboxes(labels,4);
                max_row=min_row+region_width;
                max_col=min_col+region_height;
                
                %update image after every 10 iteration to look it smooth
                r=rem(labels,200);
                if r==0
                    frame=snapshot(cam);
                    axis(app.UIAxes,'image');
                    imshow(frame,'Parent',app.UIAxes);
                end
                % dimension of objects lies with in range 
                if region_height >= min_height && region_height <= max_height && region_width >= min_width && region_width <= max_width && region_width > region_height
                    app.str='Detecting';
                    printandactiion(app);
                    %crop plate from image
                    plateimg_gray=imcrop(car_image_gray,[min_row min_col max_row-min_row+1 max_col-min_col+1]);
                    
                    %binerize plate with high value of sensitivity for good
                    %looking purpose
                    plateimg_binary = imbinarize(plateimg_gray,'adaptive', 'Sensitivity',0.8);
                    
                    %not every bit in image for template and find each and
                    %every object in plate by binary label function name
                    %bwlabel
                    plateimg_binary=(plateimg_binary-1)*-1;
                    [labelled_plateimg,numofchar] = bwlabel(plateimg_binary,4);
                    %finding properties of label image
                    region_plateimg = regionprops(labelled_plateimg, 'all');
                    for j=1:numofchar
                        % checking the objects and finding if that lies in
                        % range of
                        if region_plateimg(j).Area >= 500 && region_plateimg(j).Area<=1600
                            app.str='Checking';
                            printandactiion(app);
                            %croping the charecter from grayscale image
                            bbox=region_plateimg(j).BoundingBox;
                            char_img_gray=imcrop(plateimg_gray,round(bbox));
                            %fitting the charecter image in center of
                            %128x128 size image
                            char_img_gray=imresize(char_img_gray,[60 60]);
                            char_img=255*ones(128,128);
                            for i=1:60
                                for j=1:60
                                    if char_img_gray(i,j)>160
                                        char_img(i+35,j+35)=255;
                                    else
                                        char_img(i+35,j+35)=0;
                                    end
                                end
                            end
                            
                            %converting grayscal image into RGB
                            char_img=uint8(char_img);
                            charecter=char_img; charecter(:,:,2)=char_img; charecter(:,:,3)=char_img;
                            % Charecter detection 
                            [valnet,scr]= classify(charecter_recognition,charecter);
                            
                            flag=1;
                            if scr<=0.8
                                %charecterize each charecters
                                char_img_binary=region_plateimg(j).Image;
                                char_img=imresize(char_img_binary,[42 24]);
                                char_img(1:2,:)=0; char_img(:,23:24)=0;
                                char_img(41:42,:)=0; char_img(:,1:2)=0;
                                % detect that charecters
                                valcorelation=Letter_detection(char_img);
                                if valnet~=valcorelation
                                    valnet=valcorelation;
                                end
                                if scr=<0.6
                                    valnet=valcorelation;
                                end
                            end
                            
                            val1=append(val1,valnet);
 
                        end
                    end
                end
            end
            %if plate is not found so flage is zeros than check for another
            %dimensions.
            %and the rest process is the same
            if flag==0
                
                min_height = app.plate_dimensions2(1);
                max_height = app.plate_dimensions2(2);
                min_width  = app.plate_dimensions2(3);
                max_width  = app.plate_dimensions2(4);
                val1='';
 
                for labels=1:numobjects
 
                    min_row=boundingboxes(labels,1);
                    min_col=boundingboxes(labels,2);
                    region_width=boundingboxes(labels,3);
                    region_height=boundingboxes(labels,4);
                    max_row=min_row+region_width;
                    max_col=min_col+region_height;
                    
%                     r=rem(labels,50);
%                     if r==0
%                         frame=snapshot(cam);
%                         axis(app.UIAxes,'image');
%                         imshow(frame,'Parent',app.UIAxes);
%                     end
                    if region_height >= min_height && region_height <= max_height && region_width >= min_width && region_width <= max_width && region_width > region_height
                        app.str='Detecting';
                        printandactiion(app);
                        
                        plateimg_gray=imcrop(car_image_gray,[min_row min_col max_row-min_row+1 max_col-min_col+1]);
                        
                        plateimg_binary = imbinarize(plateimg_gray,'adaptive', 'Sensitivity',0.8);
                        
                        plateimg_binary=(plateimg_binary-1)*-1;
                        [labelled_plateimg,numofchar] = bwlabel(plateimg_binary,4);
                        
                        
                        region_plateimg = regionprops(labelled_plateimg, 'all');
                        for j=1:numofchar
                            % checking the objects and finding if that lies in
                            % range of
                            if region_plateimg(j).Area >= 700 && region_plateimg(j).Area<=1800
                                app.str='Checking';
                                printandactiion(app);
                                
                                bbox=region_plateimg(j).BoundingBox;
                                char_img_gray=imcrop(plateimg_gray,round(bbox));
                                
                                char_img_gray=imresize(char_img_gray,[60 60]);
                                char_img=255*ones(128,128);
                                for i=1:60
                                    for j=1:60
                                        if char_img_gray(i,j)>160
                                            char_img(i+35,j+35)=255;
                                        else
                                            char_img(i+35,j+35)=0;
                                        end
                                    end
                                end
                                
                                
                                char_img=uint8(char_img);
                                charecter=char_img; charecter(:,:,2)=char_img; charecter(:,:,3)=char_img;
                                %            charecter=a6;
                                [valnet,scr]= classify(charecter_recognition,charecter);
                                
                                flag=1;
                                if scr<=0.8
                                    %charecterize each charecters
                                    char_img1=region_plateimg(j).Image;
                                    char_img=imresize(char_img1,[42 24]);
                                    char_img(1:2,:)=0; char_img(:,23:24)=0;
                                    char_img(41:42,:)=0; char_img(:,1:2)=0;
                                    % detect that charecters
                                    valcorelation=Letter_detection(char_img);
                                    if valnet~=valcorelation
                                        valnet=valcorelation;
                                    end
                                    if scr<=0.6
                                        valnet=valcorelation;
                                    end
                                end
                                
                                val1=append(val1,valnet);
                                
                            end
                        end
                    end
                end
            end
            % return charecters on plate as a string of alphanumeric
            % values
            detectnumber=val1;
        end
        
        % Checking the status of plate(finding that vehicle is allow or not
        function [ ] = statuscheck(app )
            %check database if not exist create it.
            A=exist('database.mat','file');
            if A==0
                plate="";
                save database.mat plate
            end
            %load database
            load database.mat plate
            status=0;
            input=app.inputplate;
            if input~=""
                %check inputplate with each entry in database 
                for i=1:size(plate,2)
                    %if found Allowed Car
                    if plate(1,i)==input
                        app.StatusLabel.Text="Allowed ";
                        app.str='Allowed';
                        printandactiion(app);
                        status=1;
                        %and return funcion
                        break;
                    end
                    %after checking all entries if not found then vehicle
                    %is not allowed
                    if i==size(plate,2) && status==0
                        app.StatusLabel.Text="Not Allowed ";
                        app.str='Not Allowed';
                        printandactiion(app);
                    end
                end
            end
        end
        
        % Main function of program snapshoot is taken by camera and send to
        % detectionnumber function where number is received and then check
        % that plate in statuscheck funcion.
        function [ ] = start(app)
            cam=app.camera;
            % take snapshot display it check it in infinite loop
            while 1
                %take snapshoot
                frame=snapshot(cam);
                %display snapshoot
                axis(app.UIAxes,'image');
                imshow(frame,'Parent',app.UIAxes);
                
                %check picture
                input=detection(app,frame);
                app.inputplate=input;
                app.NumberPlateLabel.Text=input;
                
                %clear entries
                if input~=""
                    statuscheck(app);
                end
                
                %wait for another call backs
                drawnow
                %repeate
            end
        end
        
        %print and action function function where different action and
        %messages 
        %is taken by required situation
        function [ ]=printandactiion(app )
            %check the status of string variable and do that action 
            Lcd=app.lcd;
            servomotor=app.s;
            Str=app.str;
            
            app.ObjectDetectedLabel.Text=Str;
            
            switch(Str)
                case 'Welcome'
                    clearLCD(Lcd);
                    printLCD(Lcd,'    Welcome    ');
                    pause(0.5);
                    writePosition(servomotor, 0.62);
                    pause(0.5);
                    writePosition(servomotor, 0);
                case 'Adding'
                    clearLCD(Lcd);
                    printLCD(Lcd,'     Adding     ');
                    pause(0.5);
                case 'Deleting'
                    clearLCD(Lcd);
                    printLCD(Lcd,'    Deleting    ');
                    pause(0.5);
                case 'Allowed'
                    clearLCD(Lcd);
                    printLCD(Lcd,'    Allowed    ');
                    pause(0.5);
                    writePosition(servomotor, 0.62);
                    pause(3);
                    writePosition(servomotor, 0);
                case 'Not Allowed'
                    clearLCD(Lcd);
                    printLCD(Lcd,'      Not      ');
                    pause(0.5);
                    printLCD(Lcd,'    Allowed    ');
                    pause(0.5);
                case 'Detecting'
                    clearLCD(Lcd);
                    printLCD(Lcd,'    Detecting   ');
                    pause(0.5);
                case 'Checking'
                    clearLCD(Lcd);
                    printLCD(Lcd,'    Checking    ');
                    pause(0.5);
                otherwise
                    clearLCD(Lcd);
                    pause(0.5);
            end
        end
        
    end
    
    % Callbacks that handle component events
    methods (Access = private)
        %initializer initializing variables
        function startupFcn(app,event )
            %Initialize each hardware
            app.a= arduino; %arduino initializing
            ard=app.a; 
            %Lcd initializing
            app.lcd = addon(ard,'ExampleLCD/LCDAddon');
            %servo motor initializing
            app.s = servo(ard, 'A0', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
            
            %camera initializing
            app.camera=webcam;
            cam=app.camera;
                        
            frame=snapshot(cam);
            
            %plate dimension initializing
            plate_dimensions  = [0.18*size(frame,1), 0.3*size(frame,1), 0.45*size(frame,2), 0.73*size(frame,2)];
            app.plate_dimensions1  = round(plate_dimensions);
            plate_dimensions  = [0.25*size(frame,1), 0.45*size(frame,1), 0.6*size(frame,2), 0.8*size(frame,2)];
            app.plate_dimensions2  = round(plate_dimensions);
            
            %database checking if not exist create new one
            A=exist('database.mat','file');
            if A==0
                plate="";
                save database.mat plate
            end
            load charecter.mat net
            app.net1=net;
            
            app.NumberPlateLabel.Text=" ";
            app.inputplate ="";
            
            %clear LCD
            Lcd=app.lcd;
            writePWMVoltage(ard, 'D11',  2);
            initializeLCD(Lcd);
            clearLCD(Lcd);
            %printing welcome on LCD Status label in program
            app.str='Welcome';
            printandactiion(app );
            app.StatusLabel.Text=app.str;

        end

        %Start checking by calling start function
        % Button pushed function: StartButton
        function STARTButtonPushed(app, event)
            % goto start funcion
            start(app);
        end
        
        %delet the plate present in database 
        % Button pushed function: DELETEButton
        function DELETEButtonPushed(app, event)
            %check the database if not present creat it
            A=exist('database.mat','file');
            if A==0
                plate="";
                save database.mat plate
            end
            %and load database
            load database.mat plate
            
            %checking if vehicles scan exist mean inputplate have some
            %plate number
            if app.inputplate~=""
                for i=1:size(plate,2)
                    %iterate all entry in database and check if the plate
                    %exist in database make it null
                    if plate(1,i)==app.inputplate
                        plate(1,i)="";
                        app.str='Deleting';
                        printandactiion(app);
                    end
                end
                %remove the null entries in database and save the rest
                plate(strcmp("",plate))=[];
                save 'database.mat' plate
            end
            %continue the program as before
            start(app);
        end
        
        % add the plate if 
        % Button pushed function: ADDButton
        function ADDButtonPushed(app, event)
            % checking the database if not exist creat it
            A=exist('database.mat','file');
            if A==0
                plate="";
                save database.mat plate
            end
            %and load it.
            load database.mat plate
            
            input =app.inputplate;
            %check if input have plate number
            if input ~=""
                status=0;
                numberplates=string(zeros(1,size(plate,2)+1));
                %iterate all entry in database check for input plate
                for i=1:size( plate,2)
                    numberplates(1,i)= plate(1,i);
                    if plate(1,i)==app.inputplate
                        status = 1;
                    end
                end
                %if plate is not exist
                if status==0
                    app.str='Adding';
                    printandactiion(app);
                    %add at the end of table
                    numberplates(1,size(plate,2)+1)=input ;
                    
                    plate =numberplates;
                    %and save the updated database
                    save 'database.mat' plate
                end
            end
            %continue the program as runing before
            app.inputplate=input ;
            start(app);
        end
        
        % checking database which dsiplay all licence plate present in
        % database and also new number plate can be added or present one
        % can be deleted
        % Button pushed function: DatabaseButton
        function DatabaseButtonPushed(app, event)
            %run this programm which is only for database management
            run('database_management.m')
            % and continue the application as before
            start(app);
        end
    end
    
    % Component initialization
    methods (Access = private)
        % initializing componenet and defining its callbacks, labels its
        % properties and its positions
        % Create UIFigure and components
        function createComponents(app)
            
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';
            
            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.Position = [255 168 356 264];
            
            
            % Create startupFcn
            app.startupFcnButton = uibutton(app.UIFigure, 'push');
            app.startupFcnButton.ButtonPushedFcn = createCallbackFcn(app, @startupFcn, true);
            app.startupFcnButton.FontSize = 16;
            app.startupFcnButton.FontWeight = 'bold';
            app.startupFcnButton.Position = [74 468 145 58];
            app.startupFcnButton.Text = 'Initialize';
            
            % Create ADDButton
            app.ADDButton = uibutton(app.UIFigure, 'push');
            app.ADDButton.ButtonPushedFcn = createCallbackFcn(app, @ADDButtonPushed, true);
            app.ADDButton.FontSize = 16;
            app.ADDButton.FontWeight = 'bold';
            app.ADDButton.Position = [73 268 146 58];
            app.ADDButton.Text = 'ADD';
            
            % Create DELETEButton
            app.DELETEButton = uibutton(app.UIFigure, 'push');
            app.DELETEButton.ButtonPushedFcn = createCallbackFcn(app, @DELETEButtonPushed, true);
            app.DELETEButton.FontSize = 16;
            app.DELETEButton.FontWeight = 'bold';
            app.DELETEButton.Position = [73 168 146 58];
            app.DELETEButton.Text = 'DELETE';
            
            % Create NumberPlateLabel
            app.NumberPlateLabel = uilabel(app.UIFigure);
            app.NumberPlateLabel.HorizontalAlignment = 'center';
            app.NumberPlateLabel.FontWeight = 'bold';
            app.NumberPlateLabel.Position = [255 109 348 60];
            app.NumberPlateLabel.Text = 'Number Plate';
            
            % Create StatusLabel
            app.StatusLabel = uilabel(app.UIFigure);
            app.StatusLabel.HorizontalAlignment = 'center';
            app.StatusLabel.FontWeight = 'bold';
            app.StatusLabel.Position = [255 37 348 73];
            app.StatusLabel.Text = 'Status';
            
            % Create DatabaseButton
            app.DatabaseButton = uibutton(app.UIFigure, 'push');
            app.DatabaseButton.ButtonPushedFcn = createCallbackFcn(app, @DatabaseButtonPushed, true);
            app.DatabaseButton.FontSize = 16;
            app.DatabaseButton.FontWeight = 'bold';
            app.DatabaseButton.Position = [73 68 146 58];
            app.DatabaseButton.Text = 'Database';
            
            % Create ObjectDetectedLabel
            app.ObjectDetectedLabel = uilabel(app.UIFigure);
            app.ObjectDetectedLabel.HorizontalAlignment = 'center';
            app.ObjectDetectedLabel.FontSize = 11;
            app.ObjectDetectedLabel.Position = [255 431 356 36];
            app.ObjectDetectedLabel.Text = 'Object Detected';
            
            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @STARTButtonPushed, true);
            app.StartButton.FontSize = 20;
            app.StartButton.FontWeight = 'bold';
            app.StartButton.Position = [74 368 145 58];
            app.StartButton.Text = 'Start';
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        % Construct app
        function app = number_plate_recognition_system
            
            % Create UIFigure and components
            createComponents(app)
            
            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end