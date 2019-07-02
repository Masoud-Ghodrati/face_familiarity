clear
close all
clc

param.data_path             = ['C:\MyFolder\Face_Familiarity\Data\RSA_feedback_feedforward_data\'];
param.analysis_figures_dir  = ['C:\MyFolder\Face_Familiarity\Git\face_familiarity\Figure_04\plots'];
param.region                = [3];
param.coherence             = [0.55];
param.file_names            = {'st_information_flow_analysis_coherence_',...
    'rp_information_flow_analysis_coherence_'};


for iFile = 1 : length(param.file_names )
    load([param.data_path param.file_names{iFile} num2str(param.coherence) '.mat'])
    
    param.aligned(iFile).data_ocip(1, :, 1) = nanmean(ParCorr_ocpt_FamUnfam);
    param.aligned(iFile).data_ocip(1, :, 2) = signif_ocpt_FamUnfam;
    
    param.aligned(iFile).data_ocip(2, :, 1) = nanmean(ParCorr_ocpt_minus_frnt_FamUnfam);
    param.aligned(iFile).data_ocip(2, :, 2) = signif_ocpt_minus_frnt_FamUnfam;
    
    param.aligned(iFile).data_ocip(3, :, 1) = nanmean(ParCorr_ocpt_minus_frnt_and_ocpt_FamUnfam);
    param.aligned(iFile).data_ocip(3, :, 2) = signif_ocpt_minus_frnt_and_ocpt_FamUnfam;
    
    param.aligned(iFile).data_ocip(4, :, 1) = param.aligned(1).data_ocip(1, :, 1) - param.aligned(1).data_ocip(2, :, 1);
    param.aligned(iFile).data_ocip(4, :, 2) = signif_ocpt_1_3_FamUnfam(1, :);
    
    param.aligned(iFile).data_fron(1, :, 1) = nanmean(ParCorr_frnt_FamUnfam);
    param.aligned(iFile).data_fron(1, :, 2) = signif_frnt_FamUnfam;
    
    param.aligned(iFile).data_fron(2, :, 1) = nanmean(ParCorr_frnt_minus_ocpt_FamUnfam);
    param.aligned(iFile).data_fron(2, :, 2) = signif_frnt_minus_ocpt_FamUnfam;
    
    param.aligned(iFile).data_fron(3, :, 1) = nanmean(ParCorr_frnt_minus_ocpt_and_frnt_FamUnfam);
    param.aligned(iFile).data_fron(3, :, 2) = signif_frnt_minus_ocpt_and_frnt_FamUnfam;
    
    param.aligned(iFile).data_fron(4, :, 1) = param.aligned(1).data_fron(1, :, 1) - param.aligned(1).data_fron(2, :, 1);
    param.aligned(iFile).data_fron(4, :, 2) = signif_frnt_1_3_FamUnfam(1, :);
    
end

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
param.linestyle        = {'-','-.',':', '-'}; 
% set plot properties
plot_linewidth         = 1;

% set axis properties
axis_ylim              = [-0.01 0.045];
axis_ylim_diff         = [-2 8]*10^-3;
axis_ylim_spc          = 6;
axis_xlim_spc_st       = 7;
axis_xlim_spc_rp       = 6;
% axis_xlim              = param.window;
axis_tick_len          = 2;
axis_box_outline       = 'off';
axis_tick_style        = 'out';
axis_xlabel            = 'Time (s)';
axis_ylabel            = 'Correlation({\it r})';
axis_ylabel_diff       = '\Delta _{\it forward - backward} ';
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
pdf_file_name          = ['rdm_' date];
pdf_paper_size         = [20 20];
pdf_print_resolution   = '-r300';

%
cl                     = colormap(hot);
cl                     = cl(1:10:end, :);


% extract the data

for iCond = [1 2 4]
    
    % for stim aligned occipital
    this_data_ocip_stim = param.aligned(1).data_ocip(iCond, :, 1);
    this_pval_ocpi_stim = param.aligned(1).data_ocip(iCond, :, 2);
    
    mean_data_ocip_stim = this_data_ocip_stim(:, param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2));
    mean_data_ocip_stim = smooth(mean_data_ocip_stim);
    
    pval_ocip_stim                        = this_pval_ocpi_stim( param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2));
    pval_ocip_stim( pval_ocip_stim == 1)  = mean_data_ocip_stim(pval_ocip_stim == 1);
    
    shade_data{iCond, 1} = mean_data_ocip_stim;
    
    % for decision aligned occipital
    this_data_ocip_dec  = param.aligned(2).data_ocip(iCond, :, 1);
    this_pval_ocip_dec  = param.aligned(2).data_ocip(iCond, :, 2);
    
    mean_data_ocip_dec  = this_data_ocip_dec(:, param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2));
    mean_data_ocip_dec  = smooth(mean_data_ocip_dec);
    
    pval_ocip_dec                      = this_pval_ocip_dec(param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2));
    pval_ocip_dec( pval_ocip_dec == 1) = mean_data_ocip_dec(pval_ocip_dec == 1);
    
    shade_data{iCond, 2} = mean_data_ocip_dec;
    
        % for stim aligned frontal
    this_data_fron_stim = param.aligned(1).data_fron(iCond, :, 1);
    this_pval_fron_stim = param.aligned(1).data_fron(iCond, :, 2);
    
    mean_data_fron_stim = this_data_fron_stim(:, param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2));
    mean_data_fron_stim = smooth(mean_data_fron_stim);
    
    pval_fron_stim                        = this_pval_fron_stim( param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2));
    pval_fron_stim( pval_fron_stim == 1)  = mean_data_fron_stim(pval_fron_stim == 1);
 
    shade_data{iCond, 1} = mean_data_fron_stim;
    % for decision aligned frontal
    this_data_fron_dec  = param.aligned(2).data_fron(iCond, :, 1);
    this_pval_fron_dec  = param.aligned(2).data_fron(iCond, :, 2);
    
    mean_data_fron_dec  = this_data_fron_dec(:, param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2));
    mean_data_fron_dec  = smooth(mean_data_fron_dec);
    
    pval_fron_dec                      = this_pval_fron_dec(param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2));
    pval_fron_dec( pval_fron_dec == 1) = mean_data_fron_dec(pval_fron_dec == 1);
    shade_data{iCond, 2} = mean_data_fron_dec;
    
    if iCond <= 2
        subplot(2, 2, 1)
    elseif iCond >= 4      
        subplot(2, 2, 3)  
    end
    % plot ocip
    h           = plot(param.window_stim(1) : param.slidwind : param.window_stim(2), mean_data_ocip_stim);
    h.LineWidth = plot_linewidth;
    h.Color     = cl(1, :);
    h.LineStyle = param.linestyle{iCond};
    
    hold on
    h           = plot(param.window_stim(1) : param.slidwind : param.window_stim(2), pval_ocip_stim);
    h.LineWidth = plot_linewidth + 1;
    h.Color     = cl(1, :);
    
    % plot front
    h           = plot(param.window_stim(1) : param.slidwind : param.window_stim(2), mean_data_fron_stim);
    h.LineWidth = plot_linewidth;
    h.Color     = cl(2, :);
    h.LineStyle = param.linestyle{iCond};
    
    hold on
    h           = plot(param.window_stim(1) : param.slidwind : param.window_stim(2), pval_fron_stim);
    h.LineWidth = plot_linewidth + 1;
    h.Color     = cl(2, :);
    
    if iCond <= 2
        subplot(2, 2, 2)
    elseif iCond >= 4      
        subplot(2, 2, 4)  
    end
    % plot ocip
    h           = plot(param.window_dec(1) : param.slidwind : param.window_dec(2), mean_data_ocip_dec);
    h.LineWidth = plot_linewidth;
    h.Color     = cl(1, :);
    hold on
    h           = plot(param.window_dec(1) : param.slidwind : param.window_dec(2), pval_ocip_dec);
    h.LineWidth = plot_linewidth + 1;
    h.Color     = cl(1, :);
    h.LineStyle = param.linestyle{iCond};
    
    % plot front
    h           = plot(param.window_dec(1) : param.slidwind : param.window_dec(2), mean_data_fron_dec);
    h.LineWidth = plot_linewidth;
    h.Color     = cl(2, :);
    h.LineStyle = param.linestyle{iCond};
    
    hold on
    h           = plot(param.window_dec(1) : param.slidwind : param.window_dec(2), pval_fron_dec);
    h.LineWidth = plot_linewidth + 1;
    h.Color     = cl(2, :);
    

    
    
    
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


subplot(2, 2, 3)
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
aX.YLabel.String    = axis_ylabel_diff;
aX.YLabel.FontSize  = axis_yxlabel_fontsize;
aX.YLabel.FontAngle = axis_yxlabel_fontangle;
aX.YLim             = axis_ylim_diff;
aX.YTick            = linspace(axis_ylim_diff(1), axis_ylim_diff(2), axis_ylim_spc);
aX.XTick            = linspace(param.window_stim(1), param.window_stim(end), 8);
aX.XTickLabel       = linspace(param.window_stim(1), param.window_stim(end), 8)/1000;
aX.LineWidth        = axis_linewidth;
aX.XLim             = [param.window_stim(1), param.window_stim(end)];
% aX.XAxisLocation    = 'origin';
% aX.YAxisLocation    = 'origin';


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


subplot(2, 2, 4)
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
aX.YLabel.String    = axis_ylabel_diff;
aX.YLabel.FontSize  = axis_yxlabel_fontsize;
aX.YLabel.FontAngle = axis_yxlabel_fontangle;
aX.YLim             = axis_ylim_diff;
aX.YTick            = linspace(axis_ylim_diff(1), axis_ylim_diff(2), axis_ylim_spc);
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
fig.Position        = [100 100 570 460];
fig.PaperSize       = pdf_paper_size;
print([ param.analysis_figures_dir '\' pdf_file_name '.pdf'], '-dpdf', pdf_print_resolution)

% 
% % plot model RDMS
% figure(2)
% c = colormap(hot);
% c = c(end:-1:1,:);
% c = c(10:30, :);
% subplot(121)
% imagesc(Familiar_Unfamiliar_Model_RDM)
% colormap(c);
% axis off
% subplot(122)
% imagesc(Familiarity_levels_Model_RDM)
% axis off
% 
% 
% fig                 = gcf;
% fig.PaperUnits      = 'centimeters';
% fig.Position        = [100 100 200 80];
% fig.PaperSize       = pdf_paper_size;
% set(0, 'DefaultFigureRenderer', 'OpenGL');
% print('-painters', '-dpng', [ param.analysis_figures_dir '\' pdf_file_name '_MODELRDM.png'],'-r600')
% 
% 
% 
