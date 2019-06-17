clear 
close all
clc

param.data_path             = [ cd '\refigure3\'];
param.analysis_figures_dir  = [cd];
param.region                = [3];

load([param.data_path  'st_aligned_Correlation_Betw_Decoding_Behaviour_region_' num2str(param.region) '.mat'])
param.data(1).Corr(1, :) = nanmean(corr_Dec_Beh_acc);
param.data(1).Corr(2, :) = significant;


load([param.data_path  'rp_aligned_Correlation_Betw_Decoding_Behaviour_region_' num2str(param.region) '.mat'])
param.data(2).Corr(1, :) = nanmean(corr_Dec_Beh_acc);
param.data(2).Corr(2, :) = significant;

%% visualization
close all
clc

param.sr               = 1000; % sampling arte
param.window_stim      = [-100 600]; % window of presentation
param.window_dec       = [-500 100]; % window of presentation
param.window_gap       = 50;
param.coherence        = 4;
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
% set plot properties
plot_linewidth         = 1;

% set axis properties
axis_ylim              = [-0.1 0.3];
axis_ylim_spc          = 6;
axis_xlim_spc_st       = 7;
axis_xlim_spc_rp       = 6;
% axis_xlim              = param.window;
axis_tick_len          = 2;
axis_box_outline       = 'off';
axis_tick_style        = 'out';
axis_xlabel            = 'Time (s)';
axis_ylabel            = 'r^2';
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
pdf_file_name          = ['corr_' date];
pdf_paper_size         = [20 20];
pdf_print_resolution   = '-r300';

%
cl                     = colormap(hot);
cl                     = cl(1:10:end, :);


% extract the data

iCoh = 1;

this_data_stim = param.data(1).Corr(1, :);
this_pval_stim = param.data(1).Corr(2, :);

this_data_dec  = param.data(2).Corr(1, :);
this_pval_dec  = param.data(2).Corr(2, :);

mean_data_stim = this_data_stim(:, param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2));
mean_data_stim = smooth(mean_data_stim);

pval_stim                   = this_pval_stim( param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2));
pval_stim( pval_stim == 1)  = mean_data_stim(pval_stim == 1);

mean_data_dec  = this_data_dec(:, param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2));
mean_data_dec  = smooth(mean_data_dec);

pval_dec                 = this_pval_dec(param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2));
pval_dec( pval_dec == 1) = mean_data_dec(pval_dec == 1);



subplot(1, 2, 1)
h           = plot(param.window_stim(1) : param.slidwind : param.window_stim(2), mean_data_stim);
h.LineWidth = plot_linewidth;
h.Color     = cl(iCoh, :);
hold on
h           = plot(param.window_stim(1) : param.slidwind : param.window_stim(2), pval_stim);
h.LineWidth = plot_linewidth + 2;
h.Color     = cl(iCoh, :);


subplot(1, 2, 2)

h           = plot(param.window_dec(1) : param.slidwind : param.window_dec(2), mean_data_dec);
h.LineWidth = plot_linewidth;
h.Color     = cl(iCoh, :);
hold on
h           = plot(param.window_dec(1) : param.slidwind : param.window_dec(2), pval_dec);
h.LineWidth = plot_linewidth + 2;
h.Color     = cl(iCoh, :);



subplot(1, 2, 1)
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

subplot(1, 2, 2)
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


% % change legend properties
% h           = legend('Control', 'Famous', 'Familiar', 'Self');
% h.Location  = legend_box_loaction;
% h.Box       = legend_box_outline;
% h.FontAngle = legend_fontangel;
% h.FontSize  = legend_fontsize;
%


% set the prining properties
fig                 = gcf;
fig.PaperUnits      = 'centimeters';
fig.Position        = [100 100 570 230];
fig.PaperSize       = pdf_paper_size;
print([ param.analysis_figures_dir '\' pdf_file_name '.pdf'], '-dpdf', pdf_print_resolution)

