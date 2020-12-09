clear
close all
clc

param.data_path = 'D:\Users\Masoud.Ghodrati\Documents\GitHub\face_familiarity\Data\Decoding_data\Temporal_decoding_data';
param.analysis_figures_dir = 'D:\Users\Masoud.Ghodrati\Documents\GitHub\face_familiarity';

param.region = 'whole';  % occipito, whole, fronto
% You should re
switch param.region
    case 'occipito'
        param.data_file_name_st = 'occipito_temporal_decoding_stim_resp_aligned_coh_levels_st';
        param.data_file_name_rp = 'occipito_temporal_decoding_stim_resp_aligned_coh_levels_rp';
    case 'fronto'
        param.data_file_name_st = 'fronto_parietal_decoding_stim_resp_aligned_coh_levels_st';
        param.data_file_name_rp = 'fronto_parietal_decoding_stim_resp_aligned_coh_levels_rp';
    case 'whole'
        param.data_file_name_st = 'whole_brain_decoding_stim_resp_aligned_coh_levels_st_v2';
        param.data_file_name_rp = 'whole_brain_decoding_stim_resp_aligned_coh_levels_rp_v2';
end
load([param.data_path '\' param.data_file_name_st])
decoding_data.st      = accuracy_coherences_st;
decoding_data.st_pval = Corrected_p_values_st;

load([param.data_path '\' param.data_file_name_rp])
decoding_data.rp      = accuracy_coherences_rp;
decoding_data.rp_pval = Corrected_p_values_rp;

group_catg            = {[1], [2], [3], [4]};
group_chor            = {0.22,0.3,0.45,0.55};


%% visualization
close all
clc

param.sr               = 1000; % sampling arte
param.window_stim      = [-100 600]; % window of presentation
param.window_dec       = [-500 100]; % window of presentation
param.window_gap       = 50;
param.coherence        = 4;
param.channel          = 22; %[20:24]; % 22 21 16 44 48   56 57 63 12 40
param.cond             = [6 5 4 2];
% 1: decoding of familiar from unfamiliar (averaged)
% 2: unfamiliar only
% 3: familiar only
% 4: famous
% 5: personally familiar
% 6: self
param.slidwind         = 10;
param.time_stim        = -500:param.slidwind :1500;
param.time_dec         = -1500:param.slidwind :500;
param.subj_name        = 'all';
param.error            = 'sem';
param.p_tresh          = 0.06;
% set plot properties
plot_linewidth         = 0.7;

% set axis properties
axis_ylim              = [0.4 0.7];%[-15 25];%[-10 15];
axis_ylim_spc          = 6;
axis_xlim_spc_st       = 7;
axis_xlim_spc_rp       = 6;
% axis_xlim              = param.window;
axis_tick_len          = 2;
axis_box_outline       = 'off';
axis_tick_style        = 'out';
axis_xlabel            = 'Time (s)';
axis_ylabel            = 'Decoding accuracy';
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
pdf_file_name          = ['Figure_4_decoding_' date];
pdf_paper_size         = [20 20];
pdf_print_resolution   = '-r300';

%
cl                     = colormap(hot(64));
cl                     = cl(1:10:end, :);


% extract the data
ic                     = [3 4 2 1];
for iCon = 1 : length(param.cond)
    
    this_data_stim = squeeze(decoding_data.st(param.coherence , :, param.cond(iCon), :));
    this_pval_stim = squeeze(decoding_data.st_pval(param.coherence , param.cond(iCon), :));
    
    this_data_dec  = squeeze(decoding_data.rp(param.coherence , :, param.cond(iCon), :));
    this_pval_dec  = squeeze(decoding_data.rp_pval(param.coherence , param.cond(iCon), :));
    
    mean_data_stim = nanmean(this_data_stim(:, param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2)), 1)';
    mean_data_stim = smooth(mean_data_stim);
    
    pval_stim                                 = this_pval_stim( param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2));
    pval_stim(~ (pval_stim <= param.p_tresh)) = NaN;
    pval_stim( pval_stim <= param.p_tresh)    = mean_data_stim(pval_stim <= param.p_tresh);
    
    mean_data_dec  = nanmean(this_data_dec(:, param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2)), 1)';
    mean_data_dec  = smooth(mean_data_dec);
    
    pval_dec                                = this_pval_dec(param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2));
    pval_dec(~ (pval_dec <= param.p_tresh)) = NaN;
    pval_dec( pval_dec <= param.p_tresh)    = mean_data_dec(pval_dec <= param.p_tresh);
    
    if strcmpi(param.error, 'std')
        error_data_stim = nanstd(this_data_stim(:, param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2)),1, 1);
        error_data_dec  = nanstd(this_data_dec(:, param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2)), 1, 1);
    elseif strcmpi(param.error, 'sem')
        error_data_stim = nanstd(this_data_stim(:, param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2)),1, 1)./sqrt(18);
        error_data_dec  = nanstd(this_data_dec(:, param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2)), 1, 1)./sqrt(18);
    end
    
    
    subplot(1, 2, 1)
    % plot the results
    %     h           = errorbar(param.window_stim(1) : param.slidwind : param.window_stim(2), mean_data_stim, error_data_stim, '.');
    %     h.LineWidth = plot_linewidth;
    %     h.Color     = cl(iCoh, :);
    %     h.CapSize   = 0;
    %     hold on
    h           = plot(param.window_stim(1) : param.slidwind : param.window_stim(2), mean_data_stim);
    h.LineWidth = plot_linewidth;
    h.Color     = cl(ic(iCon), :);
    hold on
    h           = plot(param.window_stim(1) : param.slidwind : param.window_stim(2), pval_stim);
    h.LineWidth = plot_linewidth + 1;
    h.Color     = cl(ic(iCon), :);
    
    
    subplot(1, 2, 2)
    %     h           = errorbar(param.window_dec(1) : param.slidwind : param.window_dec(2), mean_data_dec, error_data_dec, '.');
    %     h.LineWidth = plot_linewidth;
    %     h.Color     = cl(iCoh, :);
    %     h.CapSize   = 0;
    
    h           = plot(param.window_dec(1) : param.slidwind : param.window_dec(2), mean_data_dec);
    h.LineWidth = plot_linewidth;
    h.Color     = cl(ic(iCon), :);
    hold on
    h           = plot(param.window_dec(1) : param.slidwind : param.window_dec(2), pval_dec);
    h.LineWidth = plot_linewidth + 1;
    h.Color     = cl(ic(iCon), :);
    
    
end


subplot(1, 2, 1)
plot(param.window_stim, 0.5*[1 1], ':k')
plot([0 0], axis_ylim , ':k')
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
plot([0 0], axis_ylim , ':k')
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


% change legend properties
% h           = legend( 'Self', 'Self', 'Personally Familiar', 'Personally Familiar',...
%     'Famous', 'Famous', 'Control', 'Control');
% h.Location  = legend_box_loaction;
% h.Box       = legend_box_outline;
% h.FontAngle = legend_fontangel;
% h.FontSize  = legend_fontsize;
% %


% set the prining properties
fig                 = gcf;
fig.PaperUnits      = 'centimeters';
fig.Position        = [100 100 570 230];
fig.PaperSize       = pdf_paper_size;
print([ param.analysis_figures_dir '\' pdf_file_name '_sub_v2.pdf'], '-dpdf', pdf_print_resolution)