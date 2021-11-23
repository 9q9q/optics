% ------------- this is script runs one session for one subject ---------
% READ THIS:
% - look at the sections with !!!! comments
% - if you need to exit at any point, the exit key will only work when
% there is no stimulus displayed
% - reponse key must be pressed when there is no stimulus displayed

%% setup
% !!!!!!!!!!!!! for dev on mac: comment out when running on windows !!!!!!
Screen('Preference','ConserveVRAM', 16384); % https://psychtoolbox.discourse.group/t/using-toolbox-with-big-sur-and-m1-macbook/3599
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','Verbosity', 3);
   
% Clear the workspace and the screen
sca;
close all;
clear;

prompt = 'Please enter subject ID and press enter: ';
SUBJECT_ID = input(prompt);
prompt = 'Please enter session # and press enter: ';
SESS_NUM = input(prompt);

PsychDefaultSetup(2);
rng('default'); % for random numbers

%% constants
SCREEN_WIDTH_PIX = 1920; % output of Screen('WindowSize', window)
SCREEN_HEIGHT_PIX = 1080;  % output of Screen('WindowSize', window)
PIX_PER_CM = 36.36363;
CM_PER_PIX = 1/PIX_PER_CM;
LINE_WIDTH = 4; % for fixation cross
CROSS_DIM = 20;

% !!!!!!!!! MAY NEED TO CHANGE !!!!!!!!!! --------------------------------
ADAPT_TIME = 1; % change this to 30 when actually running
PRES_TIME_SECS = 1; % Presentation Time for stim in seconds 

% these key mappings are for mac, may need to change for windows
ONE_KEY = 30; % KbName('1'); may work on windows
TWO_KEY = 31; % KbName('2'); may work on windows
THREE_KEY = 32; % KbName('3'); may work on windows

RECT_WIDTH = 3 * PIX_PER_CM;
GAP = .5 * PIX_PER_CM; % gap between color rects

% deg/frame calculated by: 
% 45deg/75ms -> 0.6deg/ms -> 600deg/s
% ifi = 0.0166943440000068s/frame
% deg per frame = 600deg/s * 0.0166943440000068s/frame
DEG_PER_FRAME = 10.0166; % determines speed
CROSS_POSX = SCREEN_WIDTH_PIX/2; 
STIM_POSX = (CROSS_POSX*CM_PER_PIX - 18) * PIX_PER_CM;
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --------------------------

RECT_HEIGHT = RECT_WIDTH*3 + GAP*2;
BASE_RECT = [0 0 RECT_WIDTH RECT_HEIGHT]; 


%% window setup stuff
% only one screen
screens = Screen('Screens');
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window); 
pos_y = screenYpixels / 2;

topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);
% text size
Screen('TextSize', window, 40);

%% MAKE COLOR STIM POOL AND RANDOMIZE -------------------------------------
load exp_colors % our struct containing experiment color data

base_green = exp_colors.base_green; % looks like [1 0 0]
base_red = exp_colors.base_red;
test_green = exp_colors.test_green; % looks like [r1 g1 b1; r2 g2 b2; r3 g3 b3]
test_red = exp_colors.test_red;
bases = [repmat(base_green, length(base_green), 1); repmat(base_red, length(base_red), 1)];
tests = [test_green; test_red];
NUM_HUE_PAIRS = length(test_green) + length(test_red); % before position permutations

% position permutations
bases = repmat(bases, 3, 1); % 3 positions
tests = repmat(tests, 3, 1);
odd_one_out_loc = [repmat(1, NUM_HUE_PAIRS, 1); repmat(2, NUM_HUE_PAIRS, 1); repmat(3, NUM_HUE_PAIRS, 1)];

% motion
bases = repmat(bases, 2, 1); % 2 motion conditions: moving and static
tests = repmat(tests, 2, 1);
motion = [repmat(1, length(odd_one_out_loc), 1); repmat(2, length(odd_one_out_loc), 1)];
odd_one_out_loc = repmat(odd_one_out_loc, 2, 1);

% randomize order in the same way (same seed)
rng(SUBJECT_ID)
bases_shuff = bases(randperm(length(bases)), :);
rng(SUBJECT_ID) 
tests_shuff = tests(randperm(length(tests)), :);
rng(SUBJECT_ID) 
odd_one_out_loc_shuff = odd_one_out_loc(randperm(length(odd_one_out_loc)), :);
rng(SUBJECT_ID) 
motion_shuff = motion(randperm(length(motion)), :);

% with 5 hue distances per color, length(stim_mtx) = 60
stim_mtx = zeros(length(bases_shuff), 3, 3); % 3 colors (3 rectangles), 3 color values (rgb)
for i = 1:length(stim_mtx)
    odd_one_out = odd_one_out_loc_shuff(i);
    stim_mtx(i, :, :) = repmat(bases_shuff(i, :), 1, 1, 3);
    stim_mtx(i, :, odd_one_out) = tests_shuff(i, :);
end

% save info
% TODO need to get hue distances (in CIE space, so have to do some
% conversions) and color (red vs green), but can do this post process also
data = struct;
data.motion = motion_shuff;
data.base_colors = bases_shuff;
data.test_colors = tests_shuff; 
data.odd_one_out = odd_one_out_loc_shuff;

%% keyboard information
escapeKey = KbName('ESCAPE');
oneKey = ONE_KEY;
twoKey = TWO_KEY;
threeKey = THREE_KEY;

%% timing info
presTimeFrames = round(PRES_TIME_SECS / ifi);

%% DEFINE CROSS ------------------------------
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
 
%% experimental loop for one subject and one session
responses = zeros(length(stim_mtx), 1);
for trial = 1:length(stim_mtx)

    if trial == 1
        DrawFormattedText(window, 'Press any key to begin', 'center', 'center', black);
        Screen('Flip', window);
        KbStrokeWait;

        % adapt 30 sec
        Screen('FillRect', window, grey);
        vbl = Screen('Flip', window);
        WaitSecs('UntilTime', vbl + ADAPT_TIME);
    end

    % draw cross
    Screen('DrawLines', window, allCoords, LINE_WIDTH, black, [CROSS_POSX yCenter], 2);
    vbl = Screen('Flip', window);

    % now draw stimulus
    angle = 0; % starting angle of square
    clockwise = true;
    for frame = 1:presTimeFrames
        Screen('glPushMatrix', window)
        Screen('glTranslate', window, STIM_POSX, pos_y)
        Screen('glRotate', window, angle, 0, 0);
        Screen('glTranslate', window, -STIM_POSX, -pos_y) 
        % draw the colors
        Screen('FillRect', window, stim_mtx(trial, :, 1), CenterRectOnPoint(BASE_RECT, STIM_POSX - (RECT_WIDTH+GAP), pos_y));
        Screen('FillRect', window, stim_mtx(trial, :, 2), CenterRectOnPoint(BASE_RECT, STIM_POSX, pos_y));
        Screen('FillRect', window, stim_mtx(trial, :, 3), CenterRectOnPoint(BASE_RECT, STIM_POSX + (RECT_WIDTH+GAP), pos_y));
        Screen('glPopMatrix', window)
%         vbl = Screen('Flip', window, vbl + ifi);

        if motion_shuff(trial) == 2 % 1 is static, 2 is moving
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

        % Draw the fixation point
        Screen('DrawLines', window, allCoords, LINE_WIDTH, black, [CROSS_POSX yCenter], 2);

        % Flip to the screen
        vbl = Screen('Flip', window, vbl);
    end
    Screen('FillRect', window, grey);
    Screen('Flip', window);

    respToBeMade = true;
    while respToBeMade
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(oneKey)
            response = 1;
            respToBeMade = false;
        elseif keyCode(twoKey)
            response = 2;
            respToBeMade = false;
        elseif keyCode(threeKey)
            response = 3;
            respToBeMade = false;
        end
    end

    % Record the response
    responses(trial) = response;
end

% for all fields in the struct, each row is a trial and corresponds to the
% same row number in all other fields
data.responses = responses;
save(['sub_' num2str(SUBJECT_ID,'%d') '_sess_' num2str(SESS_NUM,'%d') '_data.mat'], "data")

% Clear the screen
sca;
