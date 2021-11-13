% for dev on mac: comment out when running on windows
Screen('Preference','ConserveVRAM', 16384); % https://psychtoolbox.discourse.group/t/using-toolbox-with-big-sur-and-m1-macbook/3599
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','Verbosity', 3);
   
% Clear the workspace and the screen
sca;
close all;
clear;

PsychDefaultSetup(2);

% constants
ROTATE = true;
SCREEN_WIDTH_PIX = 1920; % output of Screen('WindowSize', window)
SCREEN_HEIGHT_PIX = 1080;  % output of Screen('WindowSize', window)
PIX_PER_CM = 36.36363;
CM_PER_PIX = 1/PIX_PER_CM;
LINE_WIDTH = 4; % for fixation cross
CROSS_DIM = 20;
RECT_WIDTH = 3 * PIX_PER_CM;
GAP = .5 * PIX_PER_CM; % gap between color rects\
RECT_HEIGHT = RECT_WIDTH*3 + GAP*2;
BASE_RECT = [0 0 RECT_WIDTH RECT_HEIGHT]; 

% deg/frame calculated by: 
% 45deg/75ms -> 0.6deg/ms -> 600deg/s
% ifi = 0.0166943440000068s/frame
% deg per frame = 600deg/s * 0.0166943440000068s/frame
DEG_PER_FRAME = 10.0166;
CROSS_POSX = SCREEN_WIDTH_PIX/2; 
STIM_POSX = (CROSS_POSX*CM_PER_PIX - 18) * PIX_PER_CM;
COLORS = [0 177 0; 103 167 0; 0 177 0] / 256;

screens = Screen('Screens');
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Open gray background for adaptation
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
KbStrokeWait;

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window); 
pos_y = screenYpixels / 2;

topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% DRAW CROSS ------------------------------
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
% Here we set the size of the arms of our fixation cross
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-CROSS_DIM CROSS_DIM 0 0];
yCoords = [0 0 -CROSS_DIM CROSS_DIM];
allCoords = [xCoords; yCoords];   

% Sync us and get a time stamp
vbl = Screen('Flip', window);

% Animation loop
angle = 0; % starting angle of square
clockwise = true;
while ~KbCheck
    % draw cross TODO do we have to do this every time or can we keep it
    % constant somehow   
    % Draw the fixation cross in black, set it to the left of our screen (for right eye dominant) and
    % set good quality antialiasing
    Screen('DrawLines', window, allCoords, LINE_WIDTH, black, [CROSS_POSX yCenter], 2);

    % With this basic way of drawing we have to translate each square from
    % its screen position, to the coordinate [0 0], then rotate it, then
    % move it back to its screen position.
    % This is rather inefficient when drawing many rectangles at high
    % refresh rates. But will work just fine for simple drawing tasks.
    % For a much more efficient way of drawing rotated squares and rectangles
    % have a look at the texture tutorials
    % Get the current squares position and rotation angle
    % Translate, rotate, re-tranlate and then draw our square
    Screen('glPushMatrix', window)
    Screen('glTranslate', window, STIM_POSX, pos_y)
    Screen('glRotate', window, angle, 0, 0);
    Screen('glTranslate', window, -STIM_POSX, -pos_y) 
        
    % draw the colors
    Screen('FillRect', window, COLORS(1, :), CenterRectOnPoint(BASE_RECT, STIM_POSX - (RECT_WIDTH+GAP), pos_y));
    Screen('FillRect', window, COLORS(2, :), CenterRectOnPoint(BASE_RECT, STIM_POSX, pos_y));
    Screen('FillRect', window, COLORS(3, :), CenterRectOnPoint(BASE_RECT, STIM_POSX + (RECT_WIDTH+GAP), pos_y));

    Screen('glPopMatrix', window)

    % Flip to the screen
    vbl = Screen('Flip', window, vbl + ifi);

    % create rotations
    if ROTATE == true
        if angle >= 45
            clockwise = false;
            angle = angle - DEG_PER_FRAME;
        elseif angle <= -45
            clockwise = true;
            angle = angle + DEG_PER_FRAME;
        elseif clockwise == true
           angle = angle + DEG_PER_FRAME;
        else % clockwise = false
            angle = angle - DEG_PER_FRAME;
        end
    end


end

% Clear the screen
sca;
