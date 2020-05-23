clear
close all
clc

%% initial settings:

% Define stimulus, monitor, and subject parameters
stim.centDeg        = [0 0];    % (deg) x-y position of stimulus center
stim.diamDeg        =  6.5;     % (deg) specifies circular aperture; two values define a rectangle
stim.fixation_Color = [0 0 0];  % fixation color for all stages but test 1 and 2 stims
stim.fixation_Size  =  0.3;     % fixation size
stim.FixationCentre = [0 0];    % (deg) x-y position of fixation center, [0 0] center of the monitor
stim.lineWidthPix   =  2;

% Define stimulus timing and related parameters
stim.fixation_Duration    = [0.3 0.6];                % time (sec) of first test stim
stim.stimulus_Duration    = 1.2;                % time (sec) of second test stim
stim.inter_Trial_Interval = [0.04 0.06];          % time (sec) of ISI
stim.coherence_Values     = [0.25 0.3 0.35 0.4 0.5];    % min: 0.15 there should be 5 noise levels, 0 indicates full noise or 0% phase coherence, 1 means full signal
stim.repetition_PerLevel  = 10;
stim.blockSize            = 36;                 % how many trials within eacg block

% Define Respose key 
stim.familiar_Key   = 'LeftArrow';   % if test 1 stim is rotated anti-clockwise relative to test 2 stim
stim.unfamiliar_Key = 'RightArrow';  % if test 1 stim is rotated clockwise relative to test 2 stim
stim.giveFeedback   = 0;             % 1: give sound feedback to subjects, 0) no feedback

% Define screen parameters
stim.ScrWidth    = 320;  % (mm) width
stim.ScrViewDist = 600;  % (mm)
stim.backgroundLuminance = 0.5;  % backgroudn lumince scaling factor
% Define path for reading images and saving subject data/result
stim.image_Folder        = 'C:\Users\masoudg\Dropbox\Project_Mirror Face\Images\';          % this is the main folder for images
stim.control_FolderName  = 'Control_Cropped_Equalize';   % the folder name for control images
stim.famous_FolderName   = 'Famous_Cropped_Equalize';    % the folder name for famous images
stim.self_FolderName     = 'Self_Cropped_Equalize';      % the folder name for self images
stim.familiar_FolderName = 'Familiar_Cropped_Equalize';  % the folder name for familiar images

% tag and comments communications
stim.send_Tags           = false;  % true will send tags, false will not
stim.read_Tags           = false;  % true will read the written tags from the port, this is just to check 
stim.EEG_SamplingRate    = 1000;  % (Hz) the sampling rate of the 
stim.TTLBandWidth        = 3;     % (samples) the bandwithd of TTL puls 

stim.fixation_TagValue   = 2;     % the tag/number that is sent for start of fixation
stim.stimulus_TagValue   = 4;     % the tag/number that is sent for start of stimulus/image
stim.decision_TagValue   = 6;     % the tag/number that is sent for decision time
stim.aborted_TagValue    = 8;     % the tag/number that is sent for aborted trials


% Define subjects infomration
stim.subject_Name = 'Subject_01';  % this must be the same as folder name for the subject

load('C:\Users\masoudg\Dropbox\Project_Mirror Face\code_repo\mean_FFT_Amplitude.mat');  % a .mat file that contains the average frequency amplitude of all images
stim.MeanFrequencyApm    = mean_FFT_Amplitude;

stim.save_Folder         = 'C:\Users\masoudg\Dropbox\Project_Mirror Face\Images\';                                         % the folder name for saving the record/data
stim.fName               = ['Face_Discrimination_Data_' stim.subject_Name];  % file name for the data 

tic
stim = present_face_discrimination(stim);  % this is the main subject for stimulus presentation
toc