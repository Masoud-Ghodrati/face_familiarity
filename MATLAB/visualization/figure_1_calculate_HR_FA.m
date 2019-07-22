% This code uses Palamedes functions (http://www.palamedestoolbox.org/) to
% (1) fit a Psychometric Function to the data, obtained from human subjects
% in an orientation discrimination task, using a Maximum Likelihood criterion,
% (2) determine standard errors of free parameters using a bootstrap procedure
% and (3) determine the goodness-of-fit of the fit.

clear
close all
clc

file_Path        = 'C:\MyFolder\Face_Familiarity\Data\Behavioral_data';  % file path for subject recorded data
file_Name        = 'Hit_rates_False_alarms_and_Correct_reaction_times';             % file name for subject recorded data
save_path        = 'C:\MyFolder\Face_Familiarity\Git\face_familiarity\Figure_01\plots';

% load the data
load([file_Path '\' file_Name '.mat'])
num_subj         = 18;
trial_Type_Index = 1 : 4;  % there are 4 types of trials
% 1) contol, 2) famous, 3) self, 4) familiar
% the above is the correct labels in the psychophysics data
unique_Noise_Coherence = [0.22 0.33 0.45 0.55];
% calculte reaction time and accurcy for every condition


%%
close all
figure(1)
LINE_WIDTH             = 1;
MARKER_SIZE            = 4;
FONT_SIZE              = 10;
sEM_AS_ERRORBAR        = true;
all_Legends            = {'Control','','Familiar','','','','',''};
AXIS_LINE_WIDTH        = 1;
TICK_LENGTH            = 2;
X_AXIS_LIM             = [min(unique_Noise_Coherence)-0.01 max(unique_Noise_Coherence)];
Y_AXIS_LIM_Perf        = [-0.05 1];
Y_AXIS_LIM_RT          = [0.48 0.9];
Y_AXIS_1ST_TICK        = 0;
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

for iTrial_Type_Ind = [1 2]
    
    subplot(121)
    this_TPR = [squeeze(TPR(:, iTrial_Type_Ind, :, 1));
        squeeze(TPR(:, iTrial_Type_Ind, :, 2))];
    
    this_FPR = [squeeze(FPR(:, iTrial_Type_Ind, :, 1));
        squeeze(FPR(:, iTrial_Type_Ind, :, 2))];
    
    if sEM_AS_ERRORBAR == true
        h1 = errorbar(unique_Noise_Coherence, nanmean(this_TPR), nanstd(this_TPR)./sqrt(num_subj), '-o');
    else
        h1 = errorbar(unique_Noise_Coherence, nanmean(this_TPR), nanstd(this_TPR), '-o');
    end
    h1.Marker          = MARKER_TYPE{MARKER_IND};
    h1.Color           = MARKER_COLOR(MARKER_IND, :);
    h1.MarkerEdgeColor = MARKER_COLOR(MARKER_IND, :);
    h1.MarkerFaceColor = MARKER_COLOR(MARKER_IND, :);
    h1.MarkerSize      = MARKER_SIZE;
    h1.CapSize         = 0;
    h1.LineWidth       = LINE_WIDTH;
    hold on
    
    if sEM_AS_ERRORBAR == true
        h1 = errorbar(unique_Noise_Coherence, nanmean(this_FPR), nanstd(this_FPR)./sqrt(num_subj), '--o');
    else
        h1 = errorbar(unique_Noise_Coherence, nanmean(this_FPR), nanstd(this_FPR), '--o');
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
    this_RT = [squeeze(RT_correct(:, iTrial_Type_Ind, :, 1));
        squeeze(RT_correct(:, iTrial_Type_Ind, :, 2))]./1000;
    if sEM_AS_ERRORBAR == true
        h1 = errorbar(unique_Noise_Coherence, nanmedian(this_RT), nanstd(this_RT)./sqrt(num_subj), '-o');
    else
        h1 = errorbar(unique_Noise_Coherence, nanmedian(this_RT), nanstd(this_RT), '-o');
    end
    h1.Marker          = MARKER_TYPE{MARKER_IND};
    h1.Color           = MARKER_COLOR(MARKER_IND, :);
    h1.MarkerEdgeColor = MARKER_COLOR(MARKER_IND, :);
    h1.MarkerFaceColor = MARKER_COLOR(MARKER_IND, :);
    h1.MarkerSize      = MARKER_SIZE;
    h1.CapSize         = 0;
    h1.LineWidth       = LINE_WIDTH;
    hold on
    
    MARKER_IND  = MARKER_IND + 2;
    
end

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
aX.YLabel.String = 'Hit Rate / False Alarm Aate';

if WANT_LEGEND == true
    hL     = legend(aX, all_Legends, 'location', 'EastOutside');
    hL.Box = 'off';
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
elseif WANT_LEGEND == false
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
end

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

set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION)
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    
    if WANT_LEGEND == true
        
        print('-dpdf', PDF_RESOLUTION, [save_path '\HR_FAR_Function_Legend_' date '.pdf'])
        winopen([save_path '\HR_FAR_Function_Legend_' date '.pdf'])
        
    elseif WANT_LEGEND == false
        
        print('-dpdf', PDF_RESOLUTION, [save_path '\HR_FAR_Function_' date '.pdf'])
        winopen([save_path '\HR_FAR_Function_' date '.pdf'])
        
    end
    
end
