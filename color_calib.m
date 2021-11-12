% for dev on mac: comment out when actually running
Screen('Preference','ConserveVRAM', 16384); % https://psychtoolbox.discourse.group/t/using-toolbox-with-big-sur-and-m1-macbook/3599
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','Verbosity', 3);
   
% Clear the workspace and the screen
sca;
close all;
clear;
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);

COLORS = [];

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Open gray background for adaptation
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
KbStrokeWait;

[screenXpixels, screenYpixels] = Screen('WindowSize', window);  
rect = [0 0 screenXpixels screenYpixels];

red = 1:256;
green = 1:256;

% red = [1 256];
% green = [1 256];

seen = zeros(256, 256);
colors = 0;
for r = red
    for g = green
        rgb = [(r-1)/256 (g-1)/256 0];
        lab = rgb2lab(rgb);
        if lab(1) <= 53.5 && lab(1) >= 53.2
            colors = colors + 1;
            Screen('FillRect', window, rgb, rect)
            Screen('Flip', window);
            pause(.1)
    
               % this doesn't work
    %         [keyIsDown, secs, keyCode] = KbCheck(-1);
    %         unique(keyCode)
    %         if keyCode(KbName('space')) == 1
    %             sca;
    %             disp('*** terminated ***');
    %             break
    %         end
%                 KbStrokeWait;
        else
           % do nothing
        end
    end
end
colors


% Clear the screen
sca;