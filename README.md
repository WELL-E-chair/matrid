
# Manual Tracking and Identification Software (MATRID)


MATRID allows both tracking and identification to be performed manually.
The script output is, for each video processed, the position of each cow for every frame of the video in the Social Network Analysis (SNA) experiment.  
This information can then be further processed to reconstruct the trajectories of cows on the paddock, and to analyze social network structure and interactions that are taking place. 

The tool extracts the trajectories of free-roaming cows in the paddock.
Cow position is represented by a single rectangular bounding box (BB) that encircles the parts of the cow that are visible at each instant.


<img width="1200" height="550" alt="" src="https://github.com/WELL-E-chair/matrid/blob/main/images/matrid1.png?raw=true" />

Figure shows augmented video with the information obtained through the tracking procedure. 
Each cow’s position is specified by a bounding box and a unique number.

Each cow is tracked individually by the user one-by-one, and its trajectory is saved in a file for later analysis (more instructions on this process and the GUI below).
The tool also allows the user to enter the name of cows as they are tracked. 
Alternatively, the user can also enter their name in an excel file during a second pass through the videos (instructions below).


The trajectory of an object (e.g. a cow) represents the position of the object in space as a function of time. In the case of experiments in animal science, there are two types of trajectories. The first type is the trajectory of the animal in the experimental space (i.e. the paddock in our case). 
This tool relied on video recordings of cows using a set of fixed cameras positioned at various locations on the paddock, as shown below: 

<img width="1200" height="550" alt="" src="https://github.com/WELL-E-chair/matrid/blob/main/images/matrid2.png?raw=true" />


Figure shows: (top, left) Aerial view of the McGill Farm; (center) Top-down view of the paddock, the corridor that leads to it from the barn, the paddock and of the 8 cameras used to record the experiment. There are four 180-degree cameras located along the north, south, east and west paddock fences, and four 90-degree cameras (labeled 1, 2, 3 and 4) located at the center of the paddock and oriented toward paddock corners.


<img width="400" height="260" alt="" src="https://github.com/WELL-E-chair/matrid/blob/main/images/matrid3.png?raw=true" />

Figure shows various definitions of a cow position: head position, center of mass position and bounding box.
For convenience, cow position is represented using a rectangular bounding box (BB), which gives information on the cow location in the camera field of view, its proximity to the camera, and its orientation in space and posture. 
It also facilitates its use by incoming computer vision approaches.


## Trajectories

Gold standard trajectories for a given video are the BB positions for each cow in all video frames,  where the BB is the smallest rectangular box that contains all cow body parts visible in a frame.
In the case of a manual tracking program, the position of the box is hand drawn using the computer mouse (see below for instructions).

Due to the slow movements and posture changes of cows (due to their size and the usually tranquil behaviors), we propose that it should be possible to approximate Gold Standard trajectories by sampling the animals’ positions at a lower temporal frequency (e.g. once every second).
The animal’s position between the sampled frames is then inferred using linear interpolation and low-pass filtering.
We call the resulting trajectory Silver Standard and make the assumption that it is close enough to the Gold Standard for our analysis of social networks and cow interactions.

<img width="1400" height="400" alt="" src="https://github.com/WELL-E-chair/matrid/blob/main/images/matrid6.png?raw=true" />

Figure shows trajectory of a cow (red curve) sampled every second (left), then linearly interpolated and low-pass filtered (right).



## Requirements

* MATLAB



## Instructions

### Arguments

| Argument          | Description                                                |
| ----------------- | ---------------------------------------------------------- |
| `vid_folder`      | folder containing the videos to be processed               |
| `my_file`         | name of the video                                          |
| `results_folder`  | folder where the files containing tracjetories are stored  |
| `delta_t`         | specifies time interval between consecutive frames         |


### Setting up the script for your video: 

The user first needs to set the variables shown above (following the same syntax, i.e. using strings between single quotes):
`vid_folder` = folder where the videos to be analyzed are stored.
`my_file` = name of the video analyzed.
`results_folder` = folder where the files containing the trajectories are stored.

Finally, variable `delta_t` specifies the time interval between consecutive sampled frames. The smaller it is, the more precise (and work and time-intensive) the tracking is. The default value is 1s, i.e. 30 frames.


### Graphic User Interface:
 
 <img width="1200" height="350" alt="" src="https://github.com/WELL-E-chair/matrid/blob/main/images/matrid8.png?raw=true" />

The GUI features two display screens which show the video that is being processed, as shown in the figure above. The user can zoom in/out using the mouse wheel and scroll the image vertically or horizontally using the mouse (left button click).

It is also possible to zoom and scroll using the small menu above each display, as shown in the figure below. Use the hand icon to scroll, and the magnifying glass to zoom in or out. 
Once these operations are finished, click again on the same icon to turn off this menu, to select the BB.

 <img width="300" height="140" alt="" src="https://github.com/WELL-E-chair/matrid/blob/main/images/matrid9.png?raw=true" />

Cows that were already tracked are indicated by color BB to help the user focus on animals not yet tracked. The left-hand display is only interacted with when selecting a cow’s first frame. The remaining time, it is only used as a visual reference while tracking is performed using the right-hand display. The right-hand display is where the user tracks the cow of interest’s position with the mouse and the keyboard.

The GUI also features several buttons and editable text fields on its left-hand side:

* `Cow` text box: it contains the number of the trajectory that is being tracked, and it is automatically indexed by one unit each time a new trajectory is started.

* `Start Time` text boxes: in many cases, cows are only visible for part of the video (they are un-trackable when outside of the field of view, or when they are too far from the camera to be clearly distinguished from the background or other cows). To take this into account and save time, the user can enter the time where tracking should start: simply type in the number of minutes and seconds from the start of the video (e.g. 2:38) to start tracking at this time point.

* `Cow name` text box: aside from numbering trajectories, the user can also label them using the name of the cow they are tracking. This identification is performed using shots gathered during the cows’ hoof-trimming sessions (see Figure 8).

* `Track Cow` and `Done` buttons: pressing the Track Cow button launches the tracking procedure. This process, during which the user traces out BBs, keeps going until the Done button is pressed (e.g. for when the cow leaves the field of view) or automatically at the end of the video. In either case, the trajectory is then linearly interpolated over and low-pass filtered before being saved in a file.


## Steps:

### Step 1:

Open the script matrid-[latest version].m in matlab and set the variables for the video and results folder, the video name and (if necessary) the sampling rate of the tracking.

### Step 2:

Press the `run` button to launch the script and display the GUI.

### Step 3: 

Open the video in a video reader (e.g. quicktime or VLC), and scroll forward until the cow of interest enters the video’s field of view or the experimental space. 
Write the corresponding video time (e.g. 2:28) into MATRID’s Start Time text boxes, and press Track` Cow` to launch the tracking process. 
This displays the video at the start time in the left-hand display.

### Step 4:

Using the mouse draw a box around the cow while keeping the left-click button pressed (if necessary, first zoom in on the cow of interest before tracing the BB).


 <img width="1200" height="400" alt="" src="https://github.com/WELL-E-chair/matrid/blob/main/images/matrid11.png?raw=true" />
 
Release the button to create the BB. 

Once the button is released, the right-hand screen automatically displays the video 30 frames later (since in our case we set the sampling increment to 1s which is equal to 30 frames for the current video):

 <img width="1200" height="400" alt="" src="https://github.com/WELL-E-chair/matrid/blob/main/images/matrid12.png?raw=true" />
 
 The script is now waiting for the user to draw a bounding box for the new frame (e.g. at frame 4471). To speed up the process as much as possible, the script has already drawn the BB from the previous frame (thick green line) and over it a red box of the same dimensions that the user can edit.
If the BB is correct, i.e. it is the smallest box possible that contains the entirety of the cow of interest for that frame, the user can press any key (e.g. RETURN) to accept the BB and move on to the next frame.
If the box is incorrect, the user can edit it with the mouse (BB corners and edges can be moved using the mouse) to make the necessary corrections:

 <img width="1200" height="400" alt="" src="https://github.com/WELL-E-chair/matrid/blob/main/images/matrid13.png?raw=true" />
 
 To accept this BB, press any key.
 The script then automatically moves on to the next frame (e.g frame 4501).
 
  <img width="1200" height="400" alt="" src="https://github.com/WELL-E-chair/matrid/blob/main/images/matrid14.png?raw=true" />


### Step 5:

The script will keep solicitating the user for BB until the trajectory comes to an end, which happens either when the video comes to an end, or when the cow disappears from the field of view. 
In the former case, a dialog window opens to request confirmation from the user to save the current trajectory in a file:

  <img width="1200" height="450" alt="" src="https://github.com/WELL-E-chair/matrid/blob/main/images/matrid15.png?raw=true" />
  
Press Save to write the trajectory to the disk and complete it with linear interpolation and low-pass filtering. Press `Cancel` to skip the saving step.
In the latter case where the cow has left the field of view, simply press the `Done button and then press any key. This will close the trajectory and again generate the above dialog box.
  

### Step 6

Once the trajectory is closed, the GUI resets itself to its initial state and waits for the user to start tracking the next trajectory: the trajectory number is incremented by one, the `Start Time` sets itself to 0, and both video display windows are blanked out. 
To continue processing the video, simply repeat Steps 3 to 5 until all cows are tracked.

  
### Step 7

Once all cows have been tracked, simply close the GUI window to end the program.
At the end of each trajectory, the main window displays a summary of the tracking:
  
<img width="600" height="350" alt="" src="https://github.com/WELL-E-chair/matrid/blob/main/images/matrid16.png?raw=true" />

These are used to help estimate the performance of the tracking algorithm and find ways to improve it.

