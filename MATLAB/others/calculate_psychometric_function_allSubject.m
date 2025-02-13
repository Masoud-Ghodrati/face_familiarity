% This code uses Palamedes functions (http://www.palamedestoolbox.org/) to
% (1) fit a Psychometric Function to the data, obtained from human subjects
% in an orientation discrimination task, using a Maximum Likelihood criterion,
% (2) determine standard errors of free parameters using a bootstrap procedure
% and (3) determine the goodness-of-fit of the fit.

clear
close all
clc

num_Subjects  = [1 2 3 4 5];                                               % number of subject
file_Path     = 'C:\Users\masoudg\Dropbox\Project_Mirror Face';  % file path for subject recorded data
file_Name     = 'Face_Discrimination_Data_Subject_';             % file name for subject recorded data
session_Num   = [1 1 1 2 2];                                     % file/session number for each subject


each_Subject_Res = cell(1, length(num_Subjects));  % empty cell to store subject data
all_Subject_Res  = [];                    % empat array to store all subject data
for iSubject = 1 : length(num_Subjects)
    
    load([file_Path '\' file_Name num2str(num_Subjects(iSubject),'%0.2d') '_' num2str(session_Num(iSubject),'%0.4d') '.mat'])
    each_Subject_Res{iSubject} = stim.ResponseData.Values;
    all_Subject_Res = [all_Subject_Res stim.ResponseData.Values];
    
end


trial_Type_Index = unique( all_Subject_Res(end,:) );  % there are 4 types of trials
% 1) contro, 2) famous, 3) self, 4) failiar

for iTrial_Type_Ind = 1 : length(trial_Type_Index)
    
    % make a cell array consisting of information for every trial type
    this_Condition_Response_Array{iTrial_Type_Ind} = all_Subject_Res(:, all_Subject_Res(end, :) == trial_Type_Index(iTrial_Type_Ind));
    
end

unique_Noise_Coherence = stim.coherence_Values;
% calculte reaction time and accurcy for every condition
for iTrial_Type_Ind = 1 : length(trial_Type_Index)
    
    for iCoherence_Steps = 1 : length(unique_Noise_Coherence)
        
        % extract some information
        temp_RT_Array       = this_Condition_Response_Array{iTrial_Type_Ind}(1, this_Condition_Response_Array{iTrial_Type_Ind}(4,:) == unique_Noise_Coherence(iCoherence_Steps));
        temp_Accuracy_Array = this_Condition_Response_Array{iTrial_Type_Ind}(2, this_Condition_Response_Array{iTrial_Type_Ind}(4,:) == unique_Noise_Coherence(iCoherence_Steps));
        trails_Num          = length(temp_Accuracy_Array) ;
        
        % just take correct response RTs
        rt_Array(iTrial_Type_Ind, iCoherence_Steps)          = median( temp_RT_Array(temp_Accuracy_Array == 1));
        % calculte accuracy for each orientaion difference
        accuracy_Array(iTrial_Type_Ind, iCoherence_Steps, 1) = nansum(temp_Accuracy_Array) ;
        accuracy_Array(iTrial_Type_Ind, iCoherence_Steps, 2) = trails_Num;
        
    end
end

%% Fitting and visualization
accuracy_Array2(2,:,1) = sum(accuracy_Array(2:end,:,1));
accuracy_Array2(2,:,2) = sum(accuracy_Array(2:end,:,2));
accuracy_Array2(1,:,1) = accuracy_Array(1,:,1);
accuracy_Array2(1,:,2) = accuracy_Array(1,:,2);
% accuracy_Array = [];
accuracy_Array = accuracy_Array;

Parametric_NonParametric_Bootstrap = 2;  % Parametric Bootstrap (1) or Non-Parametric Bootstrap? (2)
% Fitting function
PF = @PAL_CumulativeNormal;  % Alternatives:
% PAL_Gumbel, *
% PAL_Weibull,
% PAL_Quick,
% PAL_logQuick, *
% PAL_CumulativeNormal
% PAL_HyperbolicSecant *
options                = PAL_minimize('options'); % options structure containing default values
searchGrid.alpha       = -1:.01:1;                % structure defining grid to
searchGrid.beta        = 10.^[-1:.01:2];          % search for initial values
searchGrid.gamma       = 0:.01:.06;
searchGrid.lambda      = 0:.01:.06;
paramsFree             = [1 1 0 0];
WANT_ERRORBAR          = true;
WANT_SAVE              = true;
SIMULATON_NUM_ERRORBAR = 100;    % Number of simulations to perform to determine standard error
WANT_GOODNESS_OF_FIT   =  false;  % Number of simulations to perform to determine Goodness-of-Fit
SIMULATON_NUM_GOF      = 2000;


paramsValues_Array = [];
All_NumPos_Sim_Array =  [];
for iTrial_Type_Ind = 1 : size(accuracy_Array, 1)
    
    
    
    % Number of positive responses (e.g., 'yes' or 'correct' at each of the
    % entries of 'StimLevels'
    NumPos   = accuracy_Array(iTrial_Type_Ind, :, 1);
    % Number of trials at each entry of 'StimLevels'
    OutOfNum = accuracy_Array(iTrial_Type_Ind, :, 2);
    
    % Fit data:
    [paramsValues, LL, exitflag] = PAL_PFML_Fit(unique_Noise_Coherence, NumPos, OutOfNum, ...
        searchGrid, paramsFree, PF,'lapseLimits',[0 1],'guessLimits',...
        [0 1], 'searchOptions',options);
    
    disp('done:')
    message = sprintf('Threshold estimate: %6.4f', paramsValues(1));
    disp(message);
    message = sprintf('Slope estimate: %6.4f\r', paramsValues(2));
    disp(message);
    
    % Bootstrap for errorbar
    if WANT_ERRORBAR == true
        disp('Determining standard errors.....');
        
        if Parametric_NonParametric_Bootstrap == 1
            [SD, paramsSim, LLSim, converged] = PAL_PFML_BootstrapParametric(...
                unique_Noise_Coherence, OutOfNum, paramsValues, paramsFree, SIMULATON_NUM_ERRORBAR, PF, ...
                'searchGrid', searchGrid);
        else
            [SD, paramsSim, LLSim, converged, all_NumPos_Sim] = PAL_PFML_BootstrapNonParametric(...
                unique_Noise_Coherence, NumPos, OutOfNum, [], paramsFree, SIMULATON_NUM_ERRORBAR, PF,...
                'searchGrid', searchGrid);
        end
        
        disp('done:');
        message = sprintf('Standard error of Threshold: %6.4f', SD(1));
        disp(message);
        message = sprintf('Standard error of Slope: %6.4f\r', SD(2));
        disp(message);
        
        % Distribution of estimated slope parameters for simulations will be skewed
        % (type: hist(paramsSim(:,2),40) to see this). However, distribution of
        % log-transformed slope estimates will be approximately symmetric
        % [type: hist(log10(paramsSim(:,2),40)]. This might motivate using
        % log-scale for slope values (uncomment next three lines to put on screen):
        % SElog10slope = std(log10(paramsSim(:,2)));
        % message = ['Estimate for log10(slope): ' num2str(log10(paramsValues(2))) ' +/- ' num2str(SElog10slope)];
        % disp(message);
    end
    
    % calculate goodness of fit
    if WANT_GOODNESS_OF_FIT == true
        
        disp('Determining Goodness-of-fit.....');
        
        [Dev, pDev] = PAL_PFML_GoodnessOfFit(unique_Noise_Coherence, NumPos, OutOfNum, ...
            paramsValues, paramsFree, SIMULATON_NUM_GOF, PF, 'searchGrid', searchGrid);
        
        disp('done:');
        
        % Put summary of results on screen
        message = sprintf('Deviance: %6.4f', Dev);
        disp(message);
        message = sprintf('p-value: %6.4f', pDev);
        disp(message);
        
    end
    
    paramsValues_Array = [paramsValues_Array; paramsValues];
    All_NumPos_Sim_Array(iTrial_Type_Ind,:,:) = all_NumPos_Sim';
end

%%
close all
figure(1)
LINE_WIDTH             = 2;
MARKER_SIZE            = 6;
FONT_SIZE              = 10;
sEM_AS_ERRORBAR        = false;
all_Legends            = {'Control','','Famous','','Self','','Familiar',''};
AXIS_LINE_WIDTH        = 1;
TICK_LENGTH            = 3;
X_AXIS_LIM             = [0.24 0.5];
Y_AXIS_LIM             = [0.15 1];
Y_AXIS_1ST_TICK        = 0.2;
Y_AXIS_LABEL_NUM_STEPS = 3;
SAVE_PDF               = true;          % do you want to save PDF file of the paper
WANT_LEGEND            = true;         % do you want legend
FONT_SIZE              = 10;
FIGURE_DIMENSION       = [0 0 450 300;
                          0 0 300 300]; % dimesion of the printed figure
PRINTED_FIGURE_SIZE    = [20, 20];      % the size of printed PDF file, cm
PDF_RESOLUTION         = '-r300';
MARKER_COLOR           = [1 0 0;0 1 0;0 0 1;0 0 0];
MARKER_SIZE_Scale      = 0;
LINE_WIDTH_Scale       = -0.5;
MARKER_TYPE            = {'o','^','s','d'};
MARKER_IND             = 1;

for iTrial_Type_Ind = 1 : size(accuracy_Array, 1)
    
    
    paramsValues   = paramsValues_Array(iTrial_Type_Ind, :);
    all_NumPos_Sim = squeeze(All_NumPos_Sim_Array(iTrial_Type_Ind, :, :))';
    
    ProportionCorrectObserved = NumPos./OutOfNum;
    StimLevelsFineGrain       = [min(unique_Noise_Coherence):max(unique_Noise_Coherence)./1000:max(unique_Noise_Coherence)];
    ProportionCorrectModel    = PF(paramsValues,StimLevelsFineGrain);
    if sEM_AS_ERRORBAR == true
        h1 = errorbar(unique_Noise_Coherence, mean(all_NumPos_Sim), std(all_NumPos_Sim)./sqrt(SIMULATON_NUM_ERRORBAR), 'o');
    else
        h1 = errorbar(unique_Noise_Coherence, mean(all_NumPos_Sim), std(all_NumPos_Sim), 'o');
    end
    h1.Marker          = MARKER_TYPE{MARKER_IND};
    h1.Color           = 0.7*[1 1 1];
    h1.MarkerEdgeColor = MARKER_COLOR(MARKER_IND, :);
    h1.MarkerFaceColor = MARKER_COLOR(MARKER_IND, :);
    h1.MarkerSize      = MARKER_SIZE;
    h1.CapSize         = 0;
    h1.LineWidth       = 0.5;
    hold on
    plot(StimLevelsFineGrain, ProportionCorrectModel, '-', 'color',...
        MARKER_COLOR(MARKER_IND, :), 'linewidth', LINE_WIDTH)
    
    MARKER_IND  = MARKER_IND +1;
    
end

% plot(unique_Noise_Coherence, 0.75*ones(size(unique_Noise_Coherence)), ':k')
plot(unique_Noise_Coherence, 0.5*ones(size(unique_Noise_Coherence)), '--k')
text(unique_Noise_Coherence(1),0.53, 'Chance')
aX             = gca;
aX.Box         = 'off';
aX.TickDir     = 'out';
aX.TickLength  = TICK_LENGTH*aX.TickLength;
aX.YLim        = Y_AXIS_LIM;
aX.XLim        = X_AXIS_LIM;
aX.YTick       = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(2), Y_AXIS_LABEL_NUM_STEPS);
aX.XTick       = unique_Noise_Coherence;
aX.XTickLabel  = 100*unique_Noise_Coherence;
aX.FontSize    = FONT_SIZE;
aX.LineWidth   = AXIS_LINE_WIDTH;
aX.XLabel.String = 'Coherence Level (%)';
aX.YLabel.String = 'Proportion Correct';

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
        print('-dpdf', PDF_RESOLUTION, ['Psychometric_Function_Legend_' date '.pdf'])
        winopen(['Psychometric_Function_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, ['Psychometric_Function_' date '.pdf'])
        winopen(['Psychometric_Function_' date '.pdf'])
    end
end
