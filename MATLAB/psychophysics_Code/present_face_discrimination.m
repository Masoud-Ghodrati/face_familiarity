function stim = present_face_discrimination(stim)

try
    
    AssertOpenGL;   % We use PTB-3
    
    [scr, stim] = initialize_Parameters(stim);   % initial stimulus and monitor parameters
    [scr, stim] = save_StimulusFile(scr, stim);  % save stimulus file in a predefined directory
    
    % present some text information to the subject
    MyText = ['Hello! Thanks for your help! \n\n',...
        'Just some information about your task:\n\n',...
        'Estimated Time: '   num2str(stim.EstimatedTime) ' (mins)\n',...
        'Number of Trials: ' num2str(stim.nTrials) '\n',...
        'Number of Blocks: ' num2str(stim.numBlock) '\n\n',...
        'Press "' stim.familiar_Key '" for familiar, and "' stim.unfamiliar_Key '" for unfamiliar\n\n',...;
        'Be a good subject :) and\n\nPress Any Key To Begin!' ];
    
    Screen('TextSize', scr.win,30);
    Screen('TextStyle',scr.win,2);
    DrawFormattedText(scr.win, MyText, 'center', 'center', scr.white*[1 1 1]/2);
    Screen('Flip', scr.win);
    
    KbStrokeWait;
    
    stim = show_Images(scr,stim);  % show images
    save(stim.fullFile, 'stim','-append')
    
    
catch me
    
    me
    keyboard
    
end

ShowCursor;
ListenChar(0); % restore keyboard input echo
Screen('CloseAll'); % close all windows


function [scr,stim] = initialize_Parameters(stim)

% Set the Toolbox preferences
Screen('Preference', 'SkipSyncTests', 1)
Screen('Preference', 'VisualDebugLevel', 0);
KbName('UnifyKeyNames');

screenNumber = max(Screen('Screens'));

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','FloatingPoint32Bit');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'ClampOnly');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
current_VER        = Screen('Preference','Verbosity',1);
[scr.win,scr.rect] = PsychImaging('OpenWindow', screenNumber, 0 , []);
Screen('Preference', 'Verbosity', current_VER);

% Define monitor parameters
scr.width    = stim.ScrWidth;     % (mm) width
scr.viewDist = stim.ScrViewDist;  % (mm) distance

Screen('Flip', scr.win, 0, 0);
[oldmaximumvalue oldclampcolors] = Screen('ColorRange', scr.win, 255);

[scr.center(1), scr.center(2)] = RectCenter(scr.rect);
% Obtain screen parameters
% default colour indices
scr.black = BlackIndex(scr.win);
scr.white = WhiteIndex(scr.win);

scr.ifi  = Screen('GetFlipInterval', scr.win);
scr.fps  = 1/scr.ifi;  % frame per second
scr.ppd  = ((scr.rect(3)-scr.rect(1))/scr.width) / ((180/pi) * atan(1/scr.viewDist)); % pixel per digree
scr.cent = floor((scr.rect(3:4)-scr.rect(1:2)) / 2);

GetSecs; % preload this function
HideCursor;	% Hide the mouse cursor
Priority(MaxPriority(scr.win));

% convert to pixels / frames etc.
stim.diamPix = ceil(stim.diamDeg * scr.ppd);
if length(stim.diamPix) == 1
    stim.diamPix = stim.diamPix*[1 1];
end

stim.centPix        = [1 -1].*ceil(stim.centDeg * scr.ppd);
stim.centPixFix     = [1 -1].*ceil(stim.FixationCentre * scr.ppd);
stim.sizePixFix     = ceil(stim.fixation_Size*scr.ppd);

% convert stimulus to screen units (pixels and frames) and randomize the
% stimuli
stim.fixation_Frame             = floor(stim.fixation_Duration * scr.fps);     % number of frames for fixation duration/presentation
stim.stimulus_Frame             = floor(stim.stimulus_Duration * scr.fps);     % number of frames for stimulus duration/presentation
stim.inter_Trial_Interval_Frame = floor(stim.inter_Trial_Interval * scr.fps);  % number of frames for ITI duration/presentation

stim               = randomize_Trials(stim);  % read and randomizes image information
% get an estimate of the time that it takes to load and make
% images (just a sample image from the selected data base), this time is dependent on the PC config
tic
this_ImageFolder   = stim.stimTrain(1).imageFolder;
this_imageName     = stim.stimTrain(1).imageName;
this_imageNoise    = stim.stimTrain(1).imageNoise;
this_Image = imread([this_ImageFolder '\' this_imageName]);
phase_Scram_img = zeros(size(this_Image, 1), size(this_Image, 2), stim.stimulus_Frame);
for iSample = 1 : stim.stimulus_Frame
    
    phase_Scram_img(:, :, iSample) = calculated_PhaseScrambleImage(this_Image, this_imageNoise, stim.MeanFrequencyApm);  % generate phase scrambled image
    
end
stim.image_Generation_Elapsed_Time = toc;
stim.EstimatedTime = ceil((stim.nTrials * (max(stim.fixation_Duration) + stim.stimulus_Duration + max(stim.inter_Trial_Interval) + stim.image_Generation_Elapsed_Time + 2))/60);

% Make sure keyboard mapping is the same on all supported operating systems
% Apple MacOS/X, MS-Windows and GNU/Linux:
KbName('UnifyKeyNames');
% Init keyboard responses (caps doesn't matter)
% Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
% they are loaded and ready when we need them - without delays
% in the wrong moment:
KbCheck;
WaitSecs(0.1);
GetSecs;
stim.familiar_KeyCode   = KbName(stim.familiar_Key);
stim.unfamiliar_KeyCode = KbName(stim.unfamiliar_Key);


function [scr, stim] = save_StimulusFile(scr, stim)
% save parameter listing
% find the next available file
fileNames = dir([stim.save_Folder  stim.fName '*.mat']);
Temp      = struct2cell(fileNames);
F         = char(Temp(1,:));

if isempty(F)  % no files already exist
    fNum = '0000';
else
    %  find numbers in files - ignore Saving.Base and .mat
    G    = str2num(F(:, length(stim.fName)+2:end-4));
    fNum = num2str(max(G) + 1,'%0.4d');  % increment file number & make it 4 chars
end

stim.fullFile = [stim.save_Folder stim.fName '_' fNum '.mat'];

%save the parameters
save(stim.fullFile, 'scr','stim');
disp(['Saved to ' stim.fullFile]);

function stim = send_Communication(stim, tag_Value)
%%
if stim.send_Tags == true
    % create an instance of the io64 object
    io64(stim.IO.ioObj ,  stim.IO.address, tag_Value);   % output command
    
    WaitSecs(stim.TTLBandWidth/stim.EEG_SamplingRate)
    % now, let's read that value back into MATLAB
    tag_Value = 0;
    io64(stim.IO.ioObj ,  stim.IO.address, tag_Value);   % output command  
    
end

function  stim = show_Images(scr,stim)

stim.ResponseData.Values = nan(5, stim.nTrials);  % an empty matrix for storing the results
stim.ResponseData.Names  = cell(1, stim.nTrials); % an empty cell to store presentated image name

destRect = repmat(scr.center + stim.centPix   - 0.5 * stim.diamPix,   1, 2) + [0 0 stim.diamPix];

Screen('FillRect',scr.win, stim.backgroundLuminance * scr.white*[1 1 1]);
[~, TimFre] = Screen('Flip', scr.win, 0, 0); % wait for end of frame and show stimulus
stim.elapsed_Time     = cell(4, stim.nTrials);

xCoords    = [-stim.sizePixFix stim.sizePixFix 0 0];
yCoords    = [0 0 -stim.sizePixFix stim.sizePixFix];
allCoords  = [xCoords; yCoords];


this_blockResults = zeros(1, stim.blockSize);
iThis_Block       = 1;
iBlock            = 1;

if stim.send_Tags == true
    % create an instance of the io64 object
    stim.IO.ioObj   = io64;
    % initialize the interface to the inpoutx64 system driver
    stim.IO.status  = io64(stim.IO.ioObj);
    
    % if status = 0, you are now ready to write and read to a hardware port
    % let's try sending the value=1 to the parallel printer's output port (LPT1)
    if stim.IO.status ~= 0
        error('inp/outp installation failed');
    end
    stim.IO.address = hex2dec('c100'); % standard LPT1 output port address
end

% Loop through all trials
for iTrial = 1 : stim.nTrials
    
    % choose the stimulus
    this_ImageFolder   = stim.stimTrain(iTrial).imageFolder;
    this_imageName     = stim.stimTrain(iTrial).imageName;
    this_imageNoise    = stim.stimTrain(iTrial).imageNoise;
    this_imageCategory = stim.stimTrain(iTrial).imageCategory;
    
    % load images and pre-make all noise images
    tic
    this_Image = imread([this_ImageFolder '\' this_imageName]);
    phase_Scram_img = zeros(size(this_Image, 1), size(this_Image, 2), stim.stimulus_Frame);
    for iSample = 1 : stim.stimulus_Frame
        
        phase_Scram_img(:, :, iSample) = calculated_PhaseScrambleImage(this_Image, this_imageNoise, stim.MeanFrequencyApm);  % generate phase scrambled image
        
    end
    stim.elapsed_Time{1,iTrial} = toc;
    % show the fixation cross
    % Inter trial interval
    if length(stim.fixation_Frame) > 1
        numFrameFixation = randi([stim.fixation_Frame]);
    else
        numFrameFixation = randi([stim.fixation_Frame(1) stim.fixation_Frame(1)]);
    end
    for fr = 1 : numFrameFixation
        Screen('DrawLines', scr.win, allCoords, stim.lineWidthPix, scr.white*stim.fixation_Color, [scr.center(1)+stim.centPixFix(1), scr.center(2)+stim.centPixFix(2)], []);
        [~, TimFre] = Screen('Flip', scr.win, 0, 0);  % wait for end of frame and show stimulus
        
        % ###############   sent the trigger ################
        if fr == 1 % only sent one trigger (for example number 2) at the start of frist frame
            % send the trigger
            stim = send_Communication(stim, stim.fixation_TagValue);
        end
        % ###################################################
        stim.elapsed_Time{2,iTrial}(fr) = 1000 * TimFre;
    end
    
    % Sync us and get a time stamp
    Screen('Flip', scr.win, 0, 0)
    keyIsDown = []; secs = []; keyCode = [];
    for fr = 1 : stim.stimulus_Frame
        
        image_Texture   = Screen('MakeTexture', scr.win, im2uint8(phase_Scram_img(:, :, fr)));
        Screen('FillRect', scr.win, scr.white*stim.backgroundLuminance*[1 1 1])
        %         Screen('DrawTexture', scr.win, image_Texture, [], destRect, [], 0);
        Screen('DrawTexture', scr.win, image_Texture, [], [], 0);
        %         DrawFormattedText(scr.win, num2str(this_imageNoise), 10, 10, scr.white*stim.backgroundLuminance*[1 0 0])
        if fr == 1
            [~, startrt]  = Screen('Flip', scr.win, 0, 0); % wait for end of frame and show stimulus
            stim.elapsed_Time{3, iTrial}(fr) = 1000*startrt;
            
            % ###############   sent the trigger ################
            % only sent one trigger (for example number 3) at the start of frist frame
            % send the trigger
            stim = send_Communication(stim, stim.stimulus_TagValue);
            % ###################################################
            
        else
            [~, TimFre] = Screen('Flip', scr.win, 0, 0); % wait for end of frame and show stimulus
            stim.elapsed_Time{3, iTrial}(fr) = 1000*TimFre;
        end
        %         [keyIsDown, secs, keyCode] = PsychHID('KbCheck');
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyCode(stim.familiar_KeyCode) == 1 || keyCode(stim.unfamiliar_KeyCode) == 1
            
            % ###############   sent the trigger ################
            % only sent one trigger (for example number 4) at the start of frist frame
            % send the trigger
            stim = send_Communication(stim, stim.decision_TagValue);
            % ###################################################
            
            break;
        end
        
    end
    
    
    if keyCode(stim.familiar_KeyCode) == 0 && keyCode(stim.unfamiliar_KeyCode) == 0
        
        % ###############   sent the trigger ################
        % only sent one trigger (for example number 4) at the start of frist frame
        % send the trigger
        stim = send_Communication(stim, stim.aborted_TagValue);
        % ###################################################
        
        
        % abort the trial in no key was pressed
        Screen('FillRect', scr.win, scr.white*stim.backgroundLuminance*[1 1 1])
        MyText = 'You missed the trial\n\nTOO late, be faster';
        DrawFormattedText(scr.win, MyText, 'center', 'center', scr.white*[1 0 0]);
        
        [~, TimFre] = Screen('Flip', scr.win, 0, 0);
        subject_ReactionTime = NaN;
        subject_Response     = NaN;
        stim.ResponseData.Values(:, iTrial) = [subject_ReactionTime subject_Response NaN this_imageNoise this_imageCategory];
        stim.ResponseData.Names{iTrial}    = this_imageName;
        WaitSecs(2);
    else
        
        
        
        subject_ReactionTime = 1000 * (secs - startrt);
        subject_Response     = 0;
        if (this_imageCategory == 1 && keyCode(stim.unfamiliar_KeyCode) == 1) || (this_imageCategory ~= 1 && keyCode(stim.familiar_KeyCode) == 1)
            subject_Response = 1;
        end
        
        % if the subject select two key at the same time
        if length(find(keyCode)) > 1
            temp_Key = find(keyCode);
            
            if ~isempty(temp_Key(temp_Key == stim.familiar_KeyCode))
                stim.ResponseData.Values(:, iTrial) = [subject_ReactionTime subject_Response stim.familiar_KeyCode   this_imageNoise this_imageCategory];
                stim.ResponseData.Names{iTrial}     = this_imageName;
            elseif ~isempty(temp_Key(temp_Key == stim.unfamiliar_KeyCode))
                stim.ResponseData.Values(:, iTrial) = [subject_ReactionTime subject_Response stim.unfamiliar_KeyCode this_imageNoise this_imageCategory];
                stim.ResponseData.Names{iTrial}     = this_imageName;
            else
                stim.ResponseData.Values(:, iTrial) = [subject_ReactionTime subject_Response NaN                     this_imageNoise this_imageCategory];
                stim.ResponseData.Names{iTrial}     = this_imageName;
            end
            
        else
            stim.ResponseData.Values(:, iTrial) = [subject_ReactionTime subject_Response find(keyCode) this_imageNoise this_imageCategory];
            stim.ResponseData.Names{iTrial}     = this_imageName;
        end
        
        if stim.giveFeedback
            if subject_Response == 1
                [wavedata freq ] = audioread([cd '\' 'correct.wav']); % load sound file (make sure that it is in the same folder as this script
                Snd('Play',wavedata',freq');
                Screen('Flip', scr.win);
                
                WaitSecs(2) %waits 2 seconds for sound to play,if this wait is too short then sounds will be cutoff
            else
                [wavedata freq ] = audioread([cd '\' 'wrong.wav']); % load sound file (make sure that it is in the same folder as this script
                Snd('Play',wavedata',freq');
                Screen('Flip', scr.win);
                % *********** need an intertrail intervale
                WaitSecs(2) %waits 2 seconds for sound to play,if this wait is too short then sounds will be cutoff
            end
            
        end
        save(stim.fullFile, 'stim','-append')
    end
    
    % Inter trial interval
    if length(stim.inter_Trial_Interval_Frame) > 1
        numFrameITI = randi([stim.inter_Trial_Interval_Frame]);
    else
        numFrameITI = randi([stim.inter_Trial_Interval_Frame(1) stim.inter_Trial_Interval_Frame(1)]);
    end
    for fr = 1 : numFrameITI
        
        Screen('FillRect', scr.win, scr.white*stim.backgroundLuminance*[1 1 1])
        [~, TimFre] = Screen('Flip', scr.win, 0, 0);  % wait for end of frame and show stimulus
        stim.elapsed_Time{4, iTrial}(fr) = 1000*TimFre;
        
    end
    
    this_blockResults(iThis_Block) = subject_Response;
    iThis_Block                    = iThis_Block +1;
    if iTrial > 1 && mod(iTrial, stim.blockSize) == 1
        
        this_BlockAccuracy = round(100*(nansum(this_blockResults)./stim.blockSize));
        overall_Accuracy   = round(100*(nansum(stim.ResponseData.Values(2, 1:iTrial))/iTrial));
        
        if this_BlockAccuracy < 65
            
            MyText = ['Opps ' stim.subject_Name ' !\n\n You have just finished block  ' num2str(iBlock),...
                '  out of  ' num2str(stim.numBlock) '  blocks' '\n\n Your performance in this block is: ' num2str(this_BlockAccuracy),...
                '\n Your overal performance is: ' num2str(overall_Accuracy) '\n\n You can do better\n\n Take a rest! Press Any Key To Begin When Ready'];
            
        elseif this_BlockAccuracy>=65 && this_BlockAccuracy<90
            MyText = ['Welldone ' stim.subject_Name ' !\n\n You have just finished block  ' num2str(iBlock),...
                '  out of  ' num2str(stim.numBlock) '  blocks' '\n\n Your performance in this block is: ' num2str(this_BlockAccuracy),...
                '\n Your overal performance is: ' num2str(overall_Accuracy) '\n\n Keep doing well!\n\n Take a rest! Press Any Key To Begin When Ready'];
        elseif this_BlockAccuracy>=90 && this_BlockAccuracy<=99
            MyText = ['Fantastic job ' stim.subject_Name ' !\n\n You have just finished block  ' num2str(iBlock),...
                '  out of  ' num2str(stim.numBlock) '  blocks' '\n\n Your performance in this block is: ' num2str(this_BlockAccuracy),...
                '\n Your overal performance is: ' num2str(overall_Accuracy) '\n\n Why not higher!?\n\n Take a rest! Press Any Key To Begin When Ready'];
        elseif this_BlockAccuracy==100
            MyText = ['You are a legend ' stim.subject_Name ' !\n\n You have just finished block  ' num2str(iBlock),...
                '  out of  ' num2str(stim.numBlock) '  blocks' '\n\n Your performance in this block is: ' num2str(this_BlockAccuracy),...
                '\n Your overal performance is: ' num2str(overall_Accuracy) ' \n\n Take a rest! Press Any Key To Begin When Ready'];
        else
            MyText = ['Come on ' stim.subject_Name '!!! You can do much better than this !'];
        end
        
        DrawFormattedText(scr.win, MyText, 'center', 'center', scr.white*[0 0 0]);
        [VBLTimestamp, TimFre1] = Screen('Flip', scr.win, 0, 0);
        KbStrokeWait;
        Screen('Flip', scr.win, 0, 0);
        iBlock            = iBlock +1;
        this_blockResults = zeros(1, stim.blockSize);
        iThis_Block       = 1;
    end
    
    [~, ~, this_keyCode] = KbCheck(-1);  % check for key-press
    if find(this_keyCode) == KbName('ESCAPE'), break; end  % check for ESC press
    
end

function stim = randomize_Trials(stim)
% generates a random train of trials
nFamiliarCategoy = 3;  % number of familiar categories, this is just to equalize the number of images in the ctegorization task
nTrialsControl   = nFamiliarCategoy * length(stim.coherence_Values) * stim.repetition_PerLevel;  % number of trials/images for control category
nTrialsOthers    =                    length(stim.coherence_Values) * stim.repetition_PerLevel;  % number of trials/images for other three categories (famous, self, familiar)

% control images
dir_Control = dir([stim.image_Folder stim.control_FolderName '\']);
if dir_Control(1).name == '.'
    dir_Control = dir_Control(3:end);
end
if length(dir_Control) < nTrialsControl
    shortage_Trials        = nTrialsControl - length(dir_Control);
    select_these_Trials    = randi([1 length(dir_Control)], [1 shortage_Trials]);
    dir_Control            = [dir_Control(randperm(length(dir_Control))); dir_Control(select_these_Trials)];
else
    temp_Rnd               = randperm(length(dir_Control));
    dir_Control            = dir_Control(temp_Rnd(1:nTrialsControl));
end
if length(dir_Control) ~= nTrialsControl
    error('nTrialsControl should be equal to length(dir_Control)')
end

% make a train of images for control category
image_Counter  = 1;
trial_Counter = 1;
for iNoise = 1 : length(stim.coherence_Values)
    for iRepetition = 1 : (nFamiliarCategoy * stim.repetition_PerLevel)
        stim.stimTrain(trial_Counter).imageFolder   = [stim.image_Folder stim.control_FolderName];
        stim.stimTrain(trial_Counter).imageName     = dir_Control(image_Counter).name;
        stim.stimTrain(trial_Counter).imageNoise    = stim.coherence_Values(iNoise);
        stim.stimTrain(trial_Counter).imageCategory = 1;
        image_Counter = image_Counter  + 1;
        trial_Counter = trial_Counter  + 1;
    end
end

% famous images
dir_Famous = dir([stim.image_Folder stim.famous_FolderName '\']);
if dir_Famous(1).name == '.'
    dir_Famous = dir_Famous(3:end);
end
if length(dir_Famous) < nTrialsOthers
    shortage_Trials     = nTrialsOthers - length(dir_Famous);
    select_these_Trials = randi([1 length(dir_Famous)], [1 shortage_Trials]);
    dir_Famous          = [dir_Famous(randperm(length(dir_Famous))); dir_Famous(select_these_Trials)];
else
    temp_Rnd            = randperm(length(dir_Famous));
    dir_Famous          = dir_Famous(temp_Rnd(1:nTrialsOthers));
end
if length(dir_Famous) ~= nTrialsOthers
    error('nTrialsOthers should be equal to length(dir_Famous)')
end

image_Counter  = 1;
for iNoise = 1 : length(stim.coherence_Values)
    for iRepetition = 1 : stim.repetition_PerLevel
        stim.stimTrain(trial_Counter).imageFolder   = [stim.image_Folder stim.famous_FolderName];
        stim.stimTrain(trial_Counter).imageName     = dir_Famous(image_Counter).name;
        stim.stimTrain(trial_Counter).imageNoise    = stim.coherence_Values(iNoise);
        stim.stimTrain(trial_Counter).imageCategory = 2;
        image_Counter = image_Counter + 1;
        trial_Counter = trial_Counter + 1;
    end
end

% self images
dir_Self = dir([stim.image_Folder stim.subject_Name '\' stim.self_FolderName '\']);
if dir_Self(1).name == '.'
    dir_Self = dir_Self(3:end);
end
if length(dir_Self) < nTrialsOthers
    shortage_Trials     = nTrialsOthers - length(dir_Self);
    select_these_Trials = randi([1 length(dir_Self)], [1 shortage_Trials]);
    dir_Self            = [dir_Self(randperm(length(dir_Self))); dir_Self(select_these_Trials)];
else
    temp_Rnd            = randperm(length(dir_Self));
    dir_Self            = dir_Self(temp_Rnd(1:nTrialsOthers));
end
if length(dir_Self) ~= nTrialsOthers
    error('nTrialsOthers should be equal to length(dir_Self)')
end

image_Counter = 1;
for iNoise = 1 : length(stim.coherence_Values)
    for iRepetition = 1 : stim.repetition_PerLevel
        stim.stimTrain(trial_Counter).imageFolder   = [stim.image_Folder stim.subject_Name '\' stim.self_FolderName];
        stim.stimTrain(trial_Counter).imageName     = dir_Self(image_Counter).name;
        stim.stimTrain(trial_Counter).imageNoise    = stim.coherence_Values(iNoise);
        stim.stimTrain(trial_Counter).imageCategory = 3;
        image_Counter = image_Counter + 1;
        trial_Counter = trial_Counter + 1;
    end
end


% familiar images
dir_Familiar = dir([stim.image_Folder stim.subject_Name '\' stim.familiar_FolderName '\']);
if dir_Familiar(1).name == '.'
    dir_Familiar = dir_Familiar(3:end);
end
if length(dir_Familiar) < nTrialsOthers
    shortage_Trials     = nTrialsOthers - length(dir_Familiar);
    select_these_Trials = randi([1 length(dir_Familiar)], [1 shortage_Trials]);
    dir_Familiar        = [dir_Familiar(randperm(length(dir_Familiar))); dir_Familiar(select_these_Trials)];
else
    temp_Rnd            = randperm(length(dir_Familiar));
    dir_Familiar        = dir_Familiar(temp_Rnd(1:nTrialsOthers));
end
if length(dir_Familiar) ~= nTrialsOthers
    error('nTrialsOthers should be equal to length(dir_Familiar)')
end

image_Counter = 1;
for iNoise = 1 : length(stim.coherence_Values)
    for iRepetition = 1 : stim.repetition_PerLevel
        stim.stimTrain(trial_Counter).imageFolder   = [stim.image_Folder stim.subject_Name '\' stim.familiar_FolderName];
        stim.stimTrain(trial_Counter).imageName     = dir_Familiar(image_Counter).name;
        stim.stimTrain(trial_Counter).imageNoise    = stim.coherence_Values(iNoise);
        stim.stimTrain(trial_Counter).imageCategory = 4;
        image_Counter = image_Counter + 1;
        trial_Counter = trial_Counter + 1;
    end
end

% randomize the stimulus train
stim.stimTrain = stim.stimTrain(randperm(length(stim.stimTrain)));
stim.nTrials    = length(stim.stimTrain);
stim.numBlock   = round(stim.nTrials/stim.blockSize);

