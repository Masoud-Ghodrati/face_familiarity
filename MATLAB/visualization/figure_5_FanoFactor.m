clear
close all
clc

param.data_path       = 'C:\MyFolder\Face_Familiarity\Data\FanoFactor_data';  % EEG/decoding/FF data directory
analysis_figures_dir   = 'C:\MyFolder\Face_Familiarity\Git\face_familiarity\Figure_05\plots';
param.region          = 3;  % electrode region: occ = 1, parti = 2, wholehead = 3,
param.trial_type      = 1 : 3; % trial types: all = 3, cor = 2, incor = 1,
param.alignment       = 2;  % EEG/decoding/FF alignment: 1 : stimulus, 2 : response,
param.smoothing_win   = 3;  % length of smoothing window (data point)
param.separatedByCats = false;  % separate by face image category

for iTrial = param.trial_type  % loop over trial types
    
    switch iTrial
        case 1 % trial types: all = 3, cor = 2, incor = 1,
            if param.alignment == 1
                load([param.data_path '\st_ParametersV2_Incor_trials_region_', num2str(param.region),'.mat']);
            else
                load([param.data_path '\rp_ParametersV2_Incor_trials_region_', num2str(param.region),'.mat']);
            end
        case 2
            if param.alignment == 1
                load([param.data_path '\st_ParametersV2_Cor_trials_region_', num2str(param.region),'.mat']);
            else
                load([param.data_path '\rp_ParametersV2_Cor_trials_region_', num2str(param.region),'.mat']);
            end
        case 3
            if param.alignment == 1
                load([param.data_path '\st_ParametersV2_All_trials_region_', num2str(param.region),'.mat']);
            else
                load([param.data_path '\rp_ParametersV2_All_trials_region_', num2str(param.region),'.mat']);
            end
    end
    
    if param.alignment == 1
        for time = 1 : 195
            Means(:, : , time, :) = Means(:, :, time, :) - repmat( nanmean( nanmean( Means(:, :, 1:45, :), 3), 2), [1 4 1 1] );
        end
    end
    
    FanoFactor = Vars ./ abs(Means);  % calcualte the Fano Factor (Variability)
    for iChn = 1 : size(FanoFactor, 1)
        for iCond = 1 : size(FanoFactor, 2)
            for subj=[1:16 20 21]
                FanoFactor(iChn, iCond, isoutlier(FanoFactor(iChn, iCond, :, subj)), subj) = nan;
            end
        end
    end
    
    
    % store the results
    if param.separatedByCats
        for iCat = 1 : 4 % control faces, famous faces, familiar faces, self faces
            param.FF{iTrial}(iCat, :) = squeeze(smooth(nanmean(nanmean(nanmean(FanoFactor(:,:,:,:),2),1),4), param.smoothing_win));
        end
    else
        param.FF{iTrial} = squeeze(smooth(nanmean(nanmean(nanmean(FanoFactor(:,:,:,:),2),1),4), param.smoothing_win));
        
    end
    
end


%% visualization
close all
clc

param.sr               = 1000; % sampling arte
param.window_stim      = [-100 600]; % window of presentation
param.window_dec       = [-800 100]; % window of presentation
param.window_gap       = 50;
param.coherence        = 4;
param.channel          = 22; %[20:24]; % 22 21 16 44 48   56 57 63 12 40
param.cond             = 1 : 2;%[6 5 3 2];
% 1: decoding of familiar from unfamiliar (averaged)
% 2: unfamiliar only
% 3: familiar only
% 4: famous
% 5: personally familiar
% 6: self
param.slidwind         = 10;
param.time_stim        = [-500  : param.slidwind  : 1440] + 25;
param.time_dec         = [-1450 : param.slidwind  : 490  ] - 25;
param.subj_name        = 'all';
param.error            = 'sem';
param.p_tresh          = 0.06;
% set plot properties
plot_linewidth         = 1;

% set axis properties
axis_ylim              = [80 200];%[-15 25];%[-10 15];
axis_ylim_incor        = [50 100];
axis_ylim_spc          = 6;
axis_xlim_spc_st       = 7;
axis_xlim_spc_rp       = 6;
% axis_xlim              = param.window;
axis_tick_len          = 2;
axis_box_outline       = 'off';
axis_tick_style        = 'out';
axis_xlabel            = 'Time (s)';
axis_ylabel            = 'Fano factor [Var/Mean]';
axis_yxlabel_fontsize  = 10;
axis_yxlabel_fontangle = 'normal';
axis_yxtick_fontsize   = 8;
axis_yxtick_fontangle  = 'italic';
axis_title_fontangle   = 'normal';
axis_linewidth         = 1;

% set legend properties
legend_box_outline     = 'off';
legend_box_loaction    = 'southeast';
legend_fontangel       = 'normal';
legend_fontsize        = 8;

% set saveing/printing properties
pdf_file_name          = ['Figure_5_FF_Aligned_' num2str(param.alignment) '_' date];
pdf_paper_size         = [20 20];
pdf_print_resolution   = '-r300';

%
cl                     = my_color_map;
cl_step                = 10;

% extract the data

for iTrial = param.trial_type  % loop over trial types
    
    if iTrial == 3 || iTrial  == 2
        subplot(2, 1, 1)
         hold on
        plot([0 0], axis_ylim , ':k')
    else
        subplot(2, 1, 2)
         hold on
        plot([0 0], axis_ylim_incor , ':k')
    end
    
    if param.alignment == 1
        h           = plot(param.time_stim(param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2)),...
            param.FF{iTrial}(param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2)));
        h.LineWidth = plot_linewidth;
        h.Color     = cl{iTrial}(cl_step, :);

    else
        h           = plot(param.time_dec(param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2)),...
            param.FF{iTrial}(param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2)));
        h.LineWidth = plot_linewidth;
        h.Color     = cl{iTrial}(cl_step, :);

    end
    
end


subplot(2, 1, 1)
% change the axis properties
aX                  = gca;
aX.Box              = axis_box_outline;
aX.TickDir          = axis_tick_style;
aX.TickLength       = axis_tick_len * aX.TickLength;
aX.FontSize         = axis_yxtick_fontsize;
aX.FontAngle        = axis_yxtick_fontangle;
aX.XLabel.String    = axis_xlabel;
aX.XLabel.FontSize  = axis_yxlabel_fontsize;
aX.XLabel.FontAngle = axis_yxlabel_fontangle;
aX.YLabel.String    = axis_ylabel;
aX.YLabel.FontSize  = axis_yxlabel_fontsize;
aX.YLabel.FontAngle = axis_yxlabel_fontangle;
aX.YLim             = axis_ylim;
aX.YTick            = linspace(axis_ylim(1), axis_ylim(2), axis_ylim_spc);
if param.alignment == 1
    aX.XTick            = linspace(param.window_stim(1), param.window_stim(end), 8);
    aX.XTickLabel       = linspace(param.window_stim(1), param.window_stim(end), 8)/1000;
    aX.XLim             = [param.window_stim(1), param.window_stim(end)];
else
    aX.XTick            = linspace(param.window_dec(1), param.window_dec(end), 7);
    aX.XTickLabel       = linspace(param.window_dec(1), param.window_dec(end), 7)/1000;
    aX.XLim             = [param.window_dec(1), param.window_dec(end)];
end
aX.LineWidth        = axis_linewidth;

% aX.XAxisLocation    = 'origin';
% aX.YAxisLocation    = 'origin';
% change legend properties
h           = legend('','All trials', '','Correct trials');
h.Location  = legend_box_loaction;
h.Box       = legend_box_outline;
h.FontAngle = legend_fontangel;
h.FontSize  = legend_fontsize;
subplot(2, 1, 2)

% change the axis properties
aX                  = gca;
aX.Box              = axis_box_outline;
aX.TickDir          = axis_tick_style;
aX.TickLength       = axis_tick_len * aX.TickLength;
aX.FontSize         = axis_yxtick_fontsize;
aX.FontAngle        = axis_yxtick_fontangle;
aX.XLabel.String    = axis_xlabel;
aX.XLabel.FontSize  = axis_yxlabel_fontsize;
aX.XLabel.FontAngle = axis_yxlabel_fontangle;
aX.YLabel.String    = axis_ylabel;
aX.YLabel.FontSize  = axis_yxlabel_fontsize;
aX.YLabel.FontAngle = axis_yxlabel_fontangle;
aX.YLim             = axis_ylim_incor;
aX.YTick            = linspace(axis_ylim_incor(1), axis_ylim_incor(2), axis_ylim_spc);
if param.alignment == 1
    aX.XTick            = linspace(param.window_stim(1), param.window_stim(end), 8);
    aX.XTickLabel       = linspace(param.window_stim(1), param.window_stim(end), 8)/1000;
    aX.XLim             = [param.window_stim(1), param.window_stim(end)];
else
    aX.XTick            = linspace(param.window_dec(1), param.window_dec(end), 7);
    aX.XTickLabel       = linspace(param.window_dec(1), param.window_dec(end), 7)/1000;
    aX.XLim             = [param.window_dec(1), param.window_dec(end)];
end
% aX.YAxis.Visible    = 'off';
aX.LineWidth        = axis_linewidth;

% aX.XAxisLocation    = 'origin';
% aX.YAxisLocation    = 'origin';


% change legend properties
h           = legend( '', 'Incorrect trials');
h.Location  = legend_box_loaction;
h.Box       = legend_box_outline;
h.FontAngle = legend_fontangel;
h.FontSize  = legend_fontsize;
%


% set the prining properties
fig                 = gcf;
fig.PaperUnits      = 'centimeters';
fig.Position        = [100 100 266 510];
fig.PaperSize       = pdf_paper_size;
print([ analysis_figures_dir '\' pdf_file_name '_sub.pdf'], '-dpdf', pdf_print_resolution)

