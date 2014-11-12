try
%% Get basic info, set filename.
clear all;
rng('shuffle');
% subject info and screen info

% ID = input('Participant ID? ', 's');
% diagnosis = input('Diagnosis? ');
scr_diagonal = 24;
scr_distance = 60;

% tstamp = clock;
% if ~isdir( fullfile(pwd, 'Results', mfilename, num2str(diagnosis)) )
%     mkdir( fullfile(pwd, 'Results', mfilename, num2str(diagnosis)) );
% end
% savefile = fullfile(pwd, 'Results', mfilename, num2str(diagnosis), [sprintf('crowding-%02d-%02d-%02d-%02d%02d-', tstamp(1), tstamp(2), tstamp(3), tstamp(4), tstamp(5)), ID, '.mat']);

%% Experiment Variables.
scr_background = 127.5;
scr_no = max(Screen('Screens'));
scr_dimensions = Screen('Rect', scr_no);
xcen = scr_dimensions(3)/2;
ycen = scr_dimensions(4)/2;

offset = 500;

% Frame Duration
frame_dur = 1/144;

% Frequencies
freq1 = 36;
freq2 = 28.8;
nframe1 = 144/freq1;
nframe2 = 144/freq2;

% Trialtime in seconds
trialdur = 5;

% this is percentage of maximum contrast
contr = 0.6;
% stimsize in degree
stimsize = 6;
% cycles per degree
cycpdegree = 2;

%% Set up Keyboard, Screen, Sound
% Keyboard
KbName('UnifyKeyNames');
u_key = KbName('UpArrow');
d_key = KbName('DownArrow');
esc_key = KbName('Escape');
ent_key = KbName('Return'); ent_key = ent_key(1);
keyList = zeros(1, 256);
keyList([u_key, d_key, esc_key, ent_key]) = 1;
KbQueueCreate([], keyList); clear keyList

% Sound
% InitializePsychSound;
% pa = PsychPortAudio('Open', [], [], [], [], [], 256);
% bp400 = PsychPortAudio('CreateBuffer', pa, [MakeBeep(400, 0.2); MakeBeep(400, 0.2)]);
% PsychPortAudio('FillBuffer', pa, bp400);

% Open Window
scr = Screen('OpenWindow', scr_no, scr_background);
HideCursor;
Screen('BlendFunction', scr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%% Prepare stimuli
% Stimsize
pxsize = visual_angle2pixel(6, scr_diagonal, scr_distance, scr_no);

% Make Stimuli
grating1 = make_grating(pxsize, cycpdegree*stimsize, contr, 0);
grating{1} = Screen('MakeTexture', scr, grating1);
grating2 = make_grating(pxsize, cycpdegree*stimsize, -contr, 0);
grating{2} = Screen('MakeTexture', scr, grating2);

% Stimulus Locations
stimrect{1} = [xcen-offset-pxsize/2, ycen-pxsize/2, xcen-offset+pxsize/2, ycen+pxsize/2];
stimrect{2} = [xcen+offset-pxsize/2, ycen-pxsize/2, xcen+offset+pxsize/2, ycen+pxsize/2];


% Fixation Cross
fixpoint{1} = [xcen-offset, ycen];
fixpoint{2} = [xcen+offset, ycen];
fixlines = [-pxsize/20 pxsize/20  0 0;
            0 0 -pxsize/20 pxsize/20];
fixwidth = 6;

%% Try Stimuli
WaitSecs(1);
timestamps = zeros(1, trialdur*144);
timestamps(1) = GetSecs;
for i = 2:trialdur*144
    
    Screen('DrawTexture', scr, grating{mod(floor(i/nframe1), 2) + 1}, [], stimrect{1});
    Screen('DrawLines', scr, fixlines, fixwidth, mod(floor(i/nframe1), 2)*255, fixpoint{1});
    Screen('DrawTexture', scr, grating{mod(floor(i/nframe2), 2) + 1}, [], stimrect{2});
    Screen('DrawLines', scr, fixlines, fixwidth, mod(floor(i/nframe2), 2)*255, fixpoint{2});
    timestamps(i) = Screen('Flip', scr, timestamps(i-1)+frame_dur, 1);
    
end

timediff = timestamps(2:end) - timestamps(1:end-1);
timediff = round(timediff*10000);
plot(timediff);

error('End');

catch err
%% Catch
    KbQueueStop;
    sca;
%     PsychPortAudio('Close');
%     savefile = [savefile(1:(size(savefile, 2)-4)), '-ERROR.mat'];
%     save(savefile);
%     if strcmp(input('Do you want to keep the data? y / n ', 's'), 'n')
%         delete(savefile);
%         disp('Data not saved.');
%     end
    Priority(0);
    rethrow(err);

end