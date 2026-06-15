function gui(video,cow_gs,results_folder,delta_t)

% video frame rate
fps = video.FrameRate;

% set of cow data (gs = gold standard)
new_cow_gs = cow_gs;

% frame increment between tracking points
delta_frame = round(fps*delta_t);

% --------------------------- main variables ------------------------------

% start frame
% minutes
mins = 0;
% seconds
secs = 0;
% start frame
start = (mins*60+secs)*fps+1;

% cow parameters
% number in the tracking process (starts where things were left off: adds
% to cow_gs).
cow_number = length(cow_gs)+1;

% name assigned by the user
cow_name = '';

% set to 1 when user wants to stop traj tracking - global is a bad practice
% I know, but that is the only way I can see of stopping the loop in
% track_cow_dt.
global stop_tracking;
stop_tracking = 0;

% ------------------------ gui setup --------------------------------------
fig = figure('Position',[343 261 1567 730]);

clf

% left plot
ax1 = subplot(1,2,1);
box on
set(ax1,'XTick',[]);
set(ax1,'YTick',[]);

% right plot
ax2 = subplot(1,2,2);
box on
set(ax2,'XTick',[]);
set(ax2,'YTick',[]);

% Gui commands
x = 50;
y = 80;
h = -40;

% number of cow tracked ------------------------------
% "cow"
txt_cow = uicontrol('Style','Text','String','Trajectory:');
txt_cow.Position = [5+x 400+y 100 30];
txt_cow.FontSize = 15;
txt_cow.Units = 'Normalized';

% cow number
edit_cownum = uicontrol('Style','Edit','String',num2str(cow_number),'Callback',@setcownumber_callback);
edit_cownum.Position = [5+x 400+y+h 50 30];
edit_cownum.FontSize = 15;
edit_cownum.Units = 'Normalized';

% start time for viewing video (for cow of interest) ------------
% "Start:"
txt_name = uicontrol('Style','Text','String','Start:');
txt_name.Position = [5+x 300+y 50 20];
txt_name.FontSize = 15;
txt_name.Units = 'Normalized';

% minutes
edit_min = uicontrol('Style','Edit','String',num2str(mins),'Callback',@setminutes_callback);
edit_min.Position = [5+x 300+y+h 50 30];
edit_min.FontSize = 15;
edit_min.Units = 'Normalized';

% ":"
txt_colon = uicontrol('Style','Text','String',':');
txt_colon.Position = [60+x 300+y+h 5 30];
txt_colon.FontSize = 15;
txt_colon.Units = 'Normalized';

% seconds
edit_sec = uicontrol('Style','Edit','String',num2str(secs),'Callback',@setseconds_callback);
edit_sec.Position = [75+x 300+y+h 50 30];
edit_sec.FontSize = 15;
edit_sec.Units = 'Normalized';

% cow name given by user ----------------------------------
% "Name:"
txt_name = uicontrol('Style','Text','String','Name:');
txt_name.Position = [5+x 200+y 60 20];
txt_name.FontSize = 15;
txt_name.Units = 'Normalized';

% cow name
edit_cowname = uicontrol('Style','Edit','String',cow_name,'Callback',@setcowname_callback);
edit_cowname.Position = [5+x 200+y+h 130 30];
edit_cowname.FontSize = 15;
edit_cowname.Units = 'Normalized';

% button to launch tracking -----------------------------------
but_track = uicontrol('Style','PushButton','Value',0,'String','Track Cow','Callback',@trackcow_callback);
but_track.Position = [5+x 100+y+h 130 30];
but_track.FontSize = 15;
but_track.Units = 'Normalized';

% button to stop cow tracking -----------------------------------
but_stop = uicontrol('Style','PushButton','Value',0,'String','Done','Callback',@stoptrack_callback);
but_stop.Position = [5+x 50+y+h 130 30];
but_stop.FontSize = 15;
but_stop.Units = 'Normalized';

% -------------------------------------------------------------------------

% ----------------------------- functions ---------------------------------
% 2 functions to read minutes and seconds specifying the start time for tracking
% process.
    function setminutes_callback(~,~)
        % read minutes for start frame in the text box
        mins = str2num(edit_min.String);
        % compute start frames
        start = (mins*60+secs)*fps+1;
        % display it
        subplot(1,2,2)
        xlabel(['Frame: ' num2str(start)]);
    end

    function setseconds_callback(~,~)
        % read seconds for start frame in the text box
        secs = str2num(edit_sec.String);
        % compute start frames
        start = (mins*60+secs)*fps+1;
        % display it
        subplot(1,2,2)
        xlabel(['Frame: ' num2str(start)]);
    end

% function to read the cow number
    function setcownumber_callback(~,~)
        cow_number = str2num(edit_cownum.String);
    end

% function to read the cow name
    function setcowname_callback(~,~)
        cow_name = str2num(edit_cowname.String);
    end

% function to launch the tracking
    function trackcow_callback(~,~)

        % reset variables that stops tracking (see track_cow_dt).
        stop_tracking = 0;

        % deactivate the cow number and start parameters (so the user
        % cannot change them during the tracking)
        edit_cownum.Enable = 'Off';
        edit_min.Enable = 'Off';
        edit_sec.Enable = 'Off';
        % as well as the track button until the trajectory is done
        but_track.Enable = 'Off';

        % write info on the main window
        disp(' ')
        disp(['Cow ' num2str(cow_number)]);
        disp(['Video start time ' num2str(mins) ':' num2str(secs)]);
        start_time = datetime;
        disp(['Tracking started at ' num2str(start_time.Hour) ':' num2str(start_time.Minute) ':' num2str(round(start_time.Second))]); 

        % launch the tracking
        position = track_cow_dt(video,new_cow_gs,start,delta_frame);

        % display some statistics on the acceleration from autocropped frames and frames where user
        % kept same BB.
        p1=length(find(position(:,6)>=0.9))/height(position);
        p2=length(find(isnan(position(:,6))))/height(position);

        end_time = datetime;
        disp(['Tracking finished at ' ...
            num2str(end_time.Hour) ':' num2str(end_time.Minute) ':' num2str(round(end_time.Second))]);
        
        disp(['Percentage of frames auto-tracked: ' num2str(100*p1) '%']);
        disp(['Percentage of frames already framed: ' num2str(100*p2) '%']);
        disp(['Total percentage of frames manually tracked: ' num2str(100-100*p1+p2) '%']);

        % disable cow name
        edit_cowname.Enable = 'Off';

        track_duration = end_time-start_time;
        disp(['Total tracking duration: ' char(track_duration)]);

        % Compute the average time taken to track each frame
        dframe = position(end,1)-position(1,1);
        disp(['Tracked ' num2str(dframe) ' frames.']);
        dtime = seconds(track_duration);
        avframe = dtime/dframe;

        disp(['Average time track time per frame: ' num2str(avframe) 's']);

        % once done, ask if user wants to save the trajectory (also checks
        % if file with same cow already saved)
        file = ['position_cow_' num2str(cow_number) '.mat'];
        full_file = [results_folder '\' file];

        [file,path,indx] = uiputfile(full_file,['Save file for the position of cow ' num2str(cow_number) '?']);
        if indx~=0
            % position was saved
            save(full_file,'position');
            disp(['Position was saved in file ' file]);
        else
            % position not saved
            disp('Position was not saved and was discarded.')
        end

        % convert position into a cow dataset:
        disp('Interpolating and low-pass filtering the cow tracking...');
        cow_dataset = convert_position(video,position);
        disp('Done')

        % adding the name of the cow if one was submitted by the user
        if not(isempty(edit_cowname.String))
            cow_dataset.name = edit_cowname.String;
            disp(['Added cow name: ' cow_dataset.name]);
        end


        % add it to the set of datasets for the video
        disp('Appending data from the current cow to the dataset.')
        new_cow_gs(cow_number).frames = cow_dataset.frames;
        new_cow_gs(cow_number).all_frames = cow_dataset.all_frames;
        new_cow_gs(cow_number).BBl = cow_dataset.BBl;
        new_cow_gs(cow_number).BBf = cow_dataset.BBf;
        if not(isempty(edit_cowname.String))
            new_cow_gs(cow_number).name = cow_dataset.name;
        end

        % save the total dataset collected
        save([results_folder '\new_cow_gs.mat'],'new_cow_gs');

        disp('-------------')
        disp(' ');

        % rest the display to the user can track the next cow:
        % enable the track button
        but_track.Enable = 'On';
        % the cow number: increase it by one unit
        cow_number = cow_number + 1;
        edit_cownum.String = num2str(cow_number);
        edit_cownum.Enable = 'On';
        % start time
        edit_min.Enable = 'On';
        edit_sec.Enable = 'On';
        % erase the cow name and enable it
        edit_cowname.String = '';
        edit_cowname.Enable = 'On';

        % reset subplots
        subplot(1,2,1)
        cla
        xlabel('')
        subplot(1,2,2)
        cla
        xlabel('')

    end

% function called when user presses button to stop tracking for the current
% cow
    function stoptrack_callback(~,~)
        stop_tracking = 1;
    end

end