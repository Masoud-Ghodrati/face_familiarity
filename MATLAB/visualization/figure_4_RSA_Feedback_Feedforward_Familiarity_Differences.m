clear
close all
clc

param.data_path             = ['C:\MyFolder\Face_Familiarity\Data\RSA_feedback_feedforward_data\'];
param.analysis_figures_dir  = ['C:\MyFolder\Face_Familiarity\Git\face_familiarity\Figure_04\plots'];
param.region                = [3];
param.coherence             = [0.22 0.30 0.45 0.55];
param.file_names            = {'st_information_flow_analysis_coherence_',...
    'rp_information_flow_analysis_coherence_'};

for iCoh = 1 : length(param.coherence )
    
    for iFile = 1 : length(param.file_names )
        load([param.data_path param.file_names{iFile} num2str(param.coherence(iCoh)) '.mat'])
        
        param.aligned(iFile).data(iCoh, :, 1) = nanmean(difference_flow_to_Frnt_minus_to_Ocpt);
        param.aligned(iFile).data(iCoh, :, 2) = signif_difference_flow_to_Frnt_minus_to_Ocpt;
            
    end
end

%% visualization
close all
clc

param.sr               = 1000; % sampling arte
param.window_stim      = [-100 600]; % window of presentation
param.window_dec       = [-500 100]; % window of presentation
param.window_gap       = 50;
param.channel          = 22; %[20:24]; % 22 21 16 44 48   56 57 63 12 40
param.cond             = 1;
% 1: decoding of familiar from unfamiliar (averaged)
% 2: unfamiliar only
% 3: familiar only
% 4: famous
% 5: personally familiar
% 6: self
param.slidwind         = 10;
param.time_stim        = -100:param.slidwind :600;
param.time_dec         = -600:param.slidwind :100;
param.subj_name        = 'all';
param.error            = 'sem';
param.p_tresh          = 0.05;
param.linestyle        = {'-','-','-', '-','-'};
% set plot properties
plot_linewidth         = 0.7;

% set axis properties
axis_ylim              = [-0.005 0.015];
axis_ylim_diff         = [-0.005 0.015];
axis_ylim_spc          = 6;
axis_xlim_spc_st       = 7;
axis_xlim_spc_rp       = 6;
% axis_xlim              = param.window;
axis_tick_len          = 2;
axis_box_outline       = 'off';
axis_tick_style        = 'out';
axis_xlabel            = 'Time (s)';
axis_ylabel            = 'Direction of information flow (forward - backward)';
axis_ylabel_diff       = 'Direction of information flow (forward - backward)';
axis_yxlabel_fontsize  = 10;
axis_yxlabel_fontangle = 'normal';
axis_yxtick_fontsize   = 8;
axis_yxtick_fontangle  = 'italic';
axis_title_fontangle   = 'normal';
axis_linewidth         = 1;

% set legend properties
legend_box_outline     = 'off';
legend_box_loaction    = 'northwest';
legend_fontangel       = 'normal';
legend_fontsize        = 8;

% set saveing/printing properties
pdf_file_name          = ['rdm_feedback_familiarity_difference_' date];
pdf_paper_size         = [20 20];
pdf_print_resolution   = '-r300';

%
cl                     = colormap(cool);
cl                     = cl(1:15:end, :);
gray_scale             = 0.7;

% extract the data
for iCoh = [1 2 3 4]
    
    % for stim aligned 
    this_data_stim = param.aligned(1).data(iCoh, :, 1);
    this_pval_stim = param.aligned(1).data(iCoh, :, 2);
    
    mean_data_stim = this_data_stim(:, param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2));
    mean_data_stim = smooth(mean_data_stim);
    
    pval_stim                  = this_pval_stim( param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2));
    pval_stim( pval_stim == 1) = mean_data_stim(pval_stim == 1);
        
    % for decision aligned occipital
    this_data_dec  = param.aligned(2).data(iCoh, :, 1);
    this_pval_dec  = param.aligned(2).data(iCoh, :, 2);
    
    mean_data_dec  = this_data_dec(:, param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2));
    mean_data_dec  = smooth(mean_data_dec);
    
    pval_dec                 = this_pval_dec(param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2));
    pval_dec( pval_dec == 1) = mean_data_dec(pval_dec == 1);
    
    subplot(2, 2, 1)
    
    % plot ocip
    h           = plot(param.window_stim(1) : param.slidwind : param.window_stim(2), mean_data_stim);
    h.LineWidth = plot_linewidth;
    
    h.Color     = cl(iCoh, :);
    
    h.LineStyle = param.linestyle{iCoh};
    
    hold on
    h           = plot(param.window_stim(1) : param.slidwind : param.window_stim(2), pval_stim);
    h.LineWidth = plot_linewidth + 1;
    h.LineStyle = param.linestyle{iCoh};
    h.Color     = cl(iCoh, :);
    

    
    subplot(2, 2, 2)
    
    % plot ocip
    h           = plot(param.window_dec(1) : param.slidwind : param.window_dec(2), mean_data_dec);
    h.LineWidth = plot_linewidth;
    
    h.Color     = cl(iCoh, :);
    
    h.LineStyle = param.linestyle{iCoh};
    hold on
    h           = plot(param.window_dec(1) : param.slidwind : param.window_dec(2), pval_dec);
    h.LineWidth = plot_linewidth + 1;
    h.Color     = cl(iCoh, :);
    
    h.LineStyle = param.linestyle{iCoh};
    
    
end

subplot(2, 2, 1)
plot(param.window_stim, 0.5*[1 1], ':k')
plot([0 0], axis_ylim , ':k'), hold on
plot([param.window_stim(1), param.window_stim(end)], [0 0], ':k')
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
aX.XTick            = linspace(param.window_stim(1), param.window_stim(end), 8);
aX.XTickLabel       = linspace(param.window_stim(1), param.window_stim(end), 8)/1000;
aX.LineWidth        = axis_linewidth;
aX.XLim             = [param.window_stim(1), param.window_stim(end)];
% aX.XAxisLocation    = 'origin';
% aX.YAxisLocation    = 'origin';

% % change legend properties
h           = legend('XX', 'XX', 'XX', 'XX','','','','');
h.Location  = legend_box_loaction;
h.Box       = legend_box_outline;
h.FontAngle = legend_fontangel;
h.FontSize  = legend_fontsize;

subplot(2, 2, 2)
plot(param.window_dec, 0.5*[1 1], ':k')
plot([0 0], axis_ylim , ':k'), hold on
plot([param.window_dec(1), param.window_dec(end)], [0 0], ':k')
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
aX.XTick            = linspace(param.window_dec(1), param.window_dec(end), 7);
aX.XTickLabel       = linspace(param.window_dec(1), param.window_dec(end), 7)/1000;
aX.YAxis.Visible    = 'off';
aX.LineWidth        = axis_linewidth;
aX.XLim             = [param.window_dec(1), param.window_dec(end)];
% aX.XAxisLocation    = 'origin';
% aX.YAxisLocation    = 'origin';

% set the prining properties
fig                 = gcf;
fig.PaperUnits      = 'centimeters';
fig.Position        = [100 100 570 460];
fig.PaperSize       = pdf_paper_size;
print([ param.analysis_figures_dir '\' pdf_file_name '_Coh' num2str(param.coherence) '.pdf'], '-dpdf', pdf_print_resolution)


