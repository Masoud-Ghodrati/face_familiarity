% This code uses Palamedes functions (http://www.palamedestoolbox.org/) to
% (1) fit a Psychometric Function to the data, obtained from human subjects
% in an orientation discrimination task, using a Maximum Likelihood criterion,
% (2) determine standard errors of free parameters using a bootstrap procedure
% and (3) determine the goodness-of-fit of the fit.

clear
close all
clc

file_Path        = 'C:\Users\mq20185770\Desktop\face_familiarity-master\data\Behavioral_data';  % file path for subject recorded data
file_Name        = 'Face_Discrimination_Data_Subject_';             % file name for subject recorded data
save_path        = 'C:\Users\mq20185770\Desktop\face_familiarity-master\face_familiarity-master\Figure_01\plots';
num_Subjects     = [1: 16 20 21];

each_Subject_Res = cell(1, length(num_Subjects));  % empty cell to store subject data
all_Subject_Res  = [];                    % empat array to store all subject data

for isub = 1 : length(num_Subjects)
    
    subj_data_files = dir([file_Path '\' file_Name num2str(num_Subjects(isub), '%0.2d') '_*.mat']);
    this_subj_data  = [];
    
    for ifile = 1 : length(subj_data_files)
        
        % load the data
        load([file_Path '\' subj_data_files(ifile).name])
        all_Subject_Res = [ all_Subject_Res stim.ResponseData.Values];
        this_subj_data  = [ this_subj_data  stim.ResponseData.Values];
        
        
    end
    each_Subject_Res{isub} = this_subj_data;
end


trial_Type_Index = unique( all_Subject_Res(end,:) );  % there are 4 types of trials
unique_Noise_Coherence = stim.coherence_Values;
% 1) contol, 2) famous, 3) self, 4) familiar
% the above is the correct labels in the psychophysics data
for isub = 1 : length(num_Subjects)
    for iCoherence_Steps = 1 : length(unique_Noise_Coherence)
        
        % make a cell array consisting of information for every trial type
        this_Condition_Response_Array{isub}{iCoherence_Steps} = each_Subject_Res{isub}(:, each_Subject_Res{isub}(4,:) == unique_Noise_Coherence(iCoherence_Steps));
        
    end
end

nTrial_fam             = 60;
% calculte reaction time and accurcy for every condition
for isub = 1 : length(num_Subjects)
    
    for iCoherence_Steps = 1 : length(unique_Noise_Coherence)
        
        % extract some information
        temp_RT_Array       = this_Condition_Response_Array{isub}{iCoherence_Steps}(1, :);
        temp_Accuracy_Array = this_Condition_Response_Array{isub}{iCoherence_Steps}(2, :);
        
        
        % just take correct response RTs
        rt_Array(isub, iCoherence_Steps)       = nanmedian( temp_RT_Array(temp_Accuracy_Array == 1))/1000;
        
        % calculte accuracy for each orientaion difference
        accuracy_Array(isub, iCoherence_Steps) = nanmean(temp_Accuracy_Array);
        
    end
    
end

%%
close all
figure(1)
LINE_WIDTH             = 1;
MARKER_SIZE            = 4;
FONT_SIZE              = 10;
sEM_AS_ERRORBAR        = true;
all_Legends            = {'Control','','Famous','','Self','','Familiar',''};
AXIS_LINE_WIDTH        = 1;
TICK_LENGTH            = 2;
X_AXIS_LIM             = [min(unique_Noise_Coherence)-0.01 max(unique_Noise_Coherence)];
Y_AXIS_LIM_Perf        = [0.48 1];
Y_AXIS_LIM_RT          = [0.48 0.9];
Y_AXIS_1ST_TICK        = 0.5;
Y_AXIS_1ST_TICK_RT     = 0.5;
Y_AXIS_LABEL_NUM_STEPS = 3;
SAVE_PDF               = true;          % do you want to save PDF file of the paper
WANT_LEGEND            = false;         % do you want legend
FONT_SIZE              = 10;
FIGURE_DIMENSION       = [0 0 550 230;
    0 0 500 230]; % dimesion of the printed figure
PRINTED_FIGURE_SIZE    = [20, 20];      % the size of printed PDF file, cm
PDF_RESOLUTION         = '-r300';
cl                     = colormap(hot);
cl                     = cl(1:10:end, :);
% cl = 0.7*ones(2,3);
MARKER_COLOR           = cl;
MARKER_SIZE_Scale      = 0;
LINE_WIDTH_Scale       = -0.5;
MARKER_TYPE            = {'o','o','o','o'};
MARKER_IND             = 1;



HR = accuracy_Array;
RT = rt_Array;


subplot(121)

if sEM_AS_ERRORBAR == true
    h1 = errorbar(unique_Noise_Coherence, mean(HR), std(HR)./sqrt(length(num_Subjects)), '-o');
else
    h1 = errorbar(unique_Noise_Coherence, mean(HR), std(HR), '-o');
end
h1.Marker          = MARKER_TYPE{MARKER_IND};
h1.Color           = MARKER_COLOR(MARKER_IND, :);
h1.MarkerEdgeColor = MARKER_COLOR(MARKER_IND, :);
h1.MarkerFaceColor = MARKER_COLOR(MARKER_IND, :);
h1.MarkerSize      = MARKER_SIZE;
h1.CapSize         = 0;
h1.LineWidth       = LINE_WIDTH;
hold on

subplot(122)

if sEM_AS_ERRORBAR == true
    h1 = errorbar(unique_Noise_Coherence, nanmedian(RT), nanstd(RT)./sqrt(length(num_Subjects)), '-o');
else
    h1 = errorbar(unique_Noise_Coherence, nanmedian(RT), nanstd(RT), '-o');
end
h1.Marker          = MARKER_TYPE{MARKER_IND};
h1.Color           = MARKER_COLOR(MARKER_IND, :);
h1.MarkerEdgeColor = MARKER_COLOR(MARKER_IND, :);
h1.MarkerFaceColor = MARKER_COLOR(MARKER_IND, :);
h1.MarkerSize      = MARKER_SIZE;
h1.CapSize         = 0;
h1.LineWidth       = LINE_WIDTH;
hold on

MARKER_IND  = MARKER_IND +1;



% plot(unique_Noise_Coherence, 0.75*ones(size(unique_Noise_Coherence)), ':k')
% plot(unique_Noise_Coherence, 0.5*ones(size(unique_Noise_Coherence)), '--k')
% text(unique_Noise_Coherence(1),0.53, 'Chance')
subplot(121)
aX             = gca;
aX.Box         = 'off';
aX.TickDir     = 'out';
aX.TickLength  = TICK_LENGTH*aX.TickLength;
aX.YLim        = Y_AXIS_LIM_Perf;
aX.XLim        = X_AXIS_LIM;
aX.YTick       = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM_Perf(2), Y_AXIS_LABEL_NUM_STEPS);
aX.XTick       = unique_Noise_Coherence;
aX.XTickLabel  = 100*unique_Noise_Coherence;
aX.FontSize         = 8;
aX.FontAngle        = 'italic';
aX.XLabel.FontSize  = 10;
aX.XLabel.FontAngle = 'normal';
aX.YLabel.FontSize  = 10;
aX.YLabel.FontAngle = 'normal';
aX.LineWidth   = AXIS_LINE_WIDTH;
aX.XLabel.String = 'Coherence Level (%)';
aX.YLabel.String = 'Proportion Correct';

subplot(122)
aX             = gca;
aX.Box         = 'off';
aX.TickDir     = 'out';
aX.TickLength  = TICK_LENGTH*aX.TickLength;
aX.YLim        = Y_AXIS_LIM_RT;
aX.XLim        = X_AXIS_LIM;
aX.YTick       = linspace(Y_AXIS_1ST_TICK_RT, Y_AXIS_LIM_RT(2), Y_AXIS_LABEL_NUM_STEPS);
aX.XTick       = unique_Noise_Coherence;
aX.XTickLabel  = 100*unique_Noise_Coherence;
aX.FontSize         = 8;
aX.FontAngle        = 'italic';
aX.XLabel.FontSize  = 10;
aX.XLabel.FontAngle = 'normal';
aX.YLabel.FontSize  = 10;
aX.YLabel.FontAngle = 'normal';
aX.LineWidth   = AXIS_LINE_WIDTH;
aX.XLabel.String = 'Coherence Level (%)';
aX.YLabel.String = 'Reaction Time (sec)';

if WANT_LEGEND == true
    hL     = legend(aX, all_Legends, 'location', 'EastOutside');
    hL.Box = 'off';
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
elseif WANT_LEGEND == false
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
end



set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION)
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    
    if WANT_LEGEND == true
        
        print('-dpdf', PDF_RESOLUTION, [save_path '\Psychometric_Function_Legend_' date '.pdf'])
        winopen([save_path '\Psychometric_Function_Legend_' date '.pdf'])
        
    elseif WANT_LEGEND == false
        
        print('-dpdf', PDF_RESOLUTION, [save_path '\Psychometric_Function_' date '.pdf'])
        winopen([save_path '\Psychometric_Function_' date '.pdf'])
        
    end
    
end
