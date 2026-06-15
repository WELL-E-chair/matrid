clear;

% *************************************************************************
% main script: 
% requires folder where videos are, the name of the video to be tracked,
% and the name of the folder where results will be stored.
%
% call gui.m:
% takes as input video = pointer to video, new_cow_gs = structure array
% containing datasets for each cow (frames, BB before after linear
% interpolation, and after low-pass filtering), and results_folder.
% 
% gui.m builds a gui with two plots: left = tracking for first frame of
% tracking, ie shows snapshot of cow that is being currently tracked, and
% right = tracking for all subsequent frames). Right plot shows zoom on the 
% cow of interest together with previous BB (in green) and another (in red
% that the user can modify to track the current frame, and presses ENTER to
% confirm the new selection).
%
% The gui also contains:
% - cow number field: number of trajectory constructed by the user.
% It is incremented automatically by 1 each time a trajectory is completed.
% - start time (minute and seconds fields): the starting time (in minutes 
% and seconds) for tracking an animal is specified by the user (it can 
% differs for each cow). Tracking starts at that point.
% - cow name field: name of the cow typed in by the user (using hoof trimming
% snapshots).
% - a "Track Cow" button: when pressed, launches the tracking which will go
% on until the end of the video at which point it will save the trajectory
% in both a position file and a new_cow_gs file.
%
% 99% of what the script does is performed through callback function 
% trackcow_callback_dt that is triggered by pressing on the "Track Cow"
% button. trackcow_callback does the following:
% 1) reads and disables the cow number and start time fields.
% 2) performs the tracking by calling function track_cow(video,new_cow_gs,start)
% which returns the "position" array (containing on each line the frame,
% the BB and the correlation between BB for the previous frame tracked and
% the present one). This function features various tricks to accelerate the
% tracking, and once it reaches the end of the video, it saves position in
% a file, performs linear interpolation and low-pass filtering, and finally
% saves the resulting cow dataset in new_cow_gs(.mat). 3) Once done, the
% cow number is incremented by one, and the user is free to track the next
% cow.
% Note: added the time resolution for the manual tracking (default value:
% 1s between tracking points).
% <<<<<<< : need to add button to cut short trajectory if cow leaves the
% field of view.


% *************************************************************************

% location of videos
vid_folder = 'path\to\video_folder';

% name of the video
my_file = 'video_name.mp4';

% location of the files for the analysis
results_folder = 'path\to\results_folder';

% time resolution for the manual tracking (in seconds)
delta_t = 1;

% ============ DON'T CHANGE ANYTHING BEYOND THIS POINT ====================
% =========================================================================

vfile= [vid_folder '\' my_file];
video = VideoReader(vfile);

% =========================================================================
% load new_cow_gs if it has already beed saved.
file_saved = dir([results_folder '\new_cow_gs.mat']);

if isempty(file_saved)
    new_cow_gs = [];
else
    load([results_folder '\new_cow_gs.mat'],'new_cow_gs')
end

% tracking is done here using new_cow_gs if it already exists.
gui(video,new_cow_gs,results_folder,delta_t);

% =========================================================================









