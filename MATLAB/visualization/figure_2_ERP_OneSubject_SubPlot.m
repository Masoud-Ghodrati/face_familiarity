clear
close all
clc

param.data_path     = '\\ad.monash.edu\home\User098\masoudg\Desktop\EEG_Psycho_Data\Data\ERP_data';
analysis_figures_dir = '\\ad.monash.edu\home\User098\masoudg\Desktop\EEG_Psycho_Data\Figure 1\plots';

load([param.data_path '\Subject_07_preprosessed.mat'])

group_catg = {[1], [2], [3], [4]};
group_chor = {0.22,0.3,0.45,0.55};

for aligment = 1 : 2
    iSession             = 1;
    this_data1           = EEG_signals{aligment, iSession};
    this_stim_ord1       = [Exp_data{1, iSession}.stim.stimTrain.imageCategory];
    this_unq_stim_ord1   = unique(this_stim_ord1);
    this_stim_chor1      = [Exp_data{1, iSession}.stim.stimTrain.imageNoise];
    this_unq_stim_chor1  = unique(this_stim_chor1);
    
    iSession             = 2;
    this_data2           = EEG_signals{aligment, iSession};
    this_stim_ord2       = [Exp_data{1, iSession}.stim.stimTrain.imageCategory];
    this_unq_stim_ord2   = unique(this_stim_ord2);
    this_stim_chor2      = [Exp_data{1, iSession}.stim.stimTrain.imageNoise];
    this_unq_stim_chor2  = unique(this_stim_chor2);
    
    
    for iCatg = 1 : length(group_catg)
        
        for iChor = 1 : length(group_chor)
            
            indord1  = sum(this_stim_ord1 == group_catg{iCatg}', 1) >= 1;
            indchor1 = sum(this_stim_chor1 == group_chor{iChor}', 1) >= 1;
            indall1  = indord1 & indchor1;
            
            indord2  = sum(this_stim_ord2 == group_catg{iCatg}', 1) >= 1;
            indchor2 = sum(this_stim_chor2 == group_chor{iChor}', 1) >= 1;
            indall2  = indord2 & indchor2;
            
            
            for iChan = 1: 64
                these_trials = [double(squeeze(this_data1(iChan, :, indall1))');
                    double(squeeze(this_data2(iChan, :, indall2))')];
                if aligment == 1
                    data_eeg_stim(iChan).chn(iCatg).cat(iChor).cho = these_trials(:,1:1:end);
                elseif aligment == 2
                    data_eeg_dec(iChan).chn(iCatg).cat(iChor).cho = these_trials(:,1:1:end);
                end
                
            end
        end
    end
end

%% visualization
close all
clc

analysis_figures_dir = cd;

param.sr               = 1000; % sampling arte
param.window_stim      = [-100 700]; % window of presentation
param.window_dec       = [-1400 100]; % window of presentation
param.coherence        = 4;
param.channel          = 57;%56 57 63 12 40
param.time_stim        = -500:1500;
param.time_dec         = -1500:500;
param.time_gap         = 50;


% set plot properties
plot_linewidth = 1.5;

% set axis properties
axis_ylim              = [-15 20];
axis_ylim_spc          = 6;
axis_xlim_spc          = 5;
% axis_xlim              = param.window;
axis_tick_len          = 2;
axis_box_outline       = 'off';
axis_tick_style        = 'out';
axis_xlabel            = 'Time (ms)';
axis_ylabel            = 'Amplitude (a.u.)';
axis_yxlabel_fontsize  = 12;
axis_yxlabel_fontangle = 'normal';
axis_yxtick_fontsize   = 10;
axis_yxtick_fontangle  = 'italic';
axis_title_fontangle   = 'normal';
axis_linewidth         = 0.5;

% set legend properties
legend_box_outline     = 'off';
legend_box_loaction    = 'northeast';
legend_fontangel       = 'normal';
legend_fontsize        = 8;

% set saveing/printing properties
pdf_file_name          = 'x';
pdf_paper_size         = [20 20];
pdf_print_resolution   = '-r300';

% 
cl                     = colormap(hot);
cl                     = cl(1:10:end, :);
for iCatg = 1 : length(group_catg)
     
    this_data_stim = data_eeg_stim(param.channel).chn(iCatg).cat(param.coherence).cho;
    this_data_dec  = data_eeg_dec(param.channel).chn(iCatg).cat(param.coherence).cho;
    
    mean_data_stim = mean(this_data_stim(:, param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2)));
    mean_data_dec  = mean(this_data_dec(:, param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2)));
    
    subplot(1, 2, 1)
    % plot the results
    h           = plot(param.window_stim(1) : param.window_stim(2), mean_data_stim);
    h.LineWidth = plot_linewidth;
    h.Color     = cl(iCatg, :);
    hold on
    subplot(1, 2, 2)
    h           = plot(param.window_dec(1) : param.window_dec(2), mean_data_dec);
    h.LineWidth = plot_linewidth;
    h.Color     = cl(iCatg, :);
    hold on
    
end
subplot(1, 2, 1)
% plot([0 0], param.window_stim, ':k')
% plot(param.window_stim, [0 0], ':k')
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
% aX.YLim             = axis_ylim;
% aX.YTick            = linspace(axis_ylim(1), axis_ylim(2), axis_ylim_spc);
% aX.XTick            = linspace(param.window_stim(1), param.window_stim(end), axis_xlim_spc);
aX.LineWidth        = axis_linewidth;
aX.XLim             = param.window_stim ;
% aX.XAxisLocation    = 'origin';
% aX.YAxisLocation    = 'origin';

subplot(1, 2, 2)
% plot([0 0], param.window_dec, ':k')
% plot(param.window_dec, [0 0], ':k')
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
% aX.YLabel.String    = axis_ylabel;
aX.YLabel.FontSize  = axis_yxlabel_fontsize;
aX.YLabel.FontAngle = axis_yxlabel_fontangle;
% aX.YLim             = axis_ylim;
% aX.YTick            = [];%linspace(axis_ylim(1), axis_ylim(2), axis_ylim_spc);
aX.YAxis.Visible    = 'off';
aX.LineWidth        = axis_linewidth;
aX.XLim             = param.window_dec ;
% aX.XAxisLocation    = 'origin';
% aX.YAxisLocation    = 'origin';

% change legend properties
h           = legend('Control', 'Famous', 'Self', 'Familiar');
h.Location  = legend_box_loaction;
h.Box       = legend_box_outline;
h.FontAngle = legend_fontangel;
h.FontSize  = legend_fontsize;
%
% set the prining properties
fig                 = gcf;
fig.PaperUnits      = 'centimeters';
fig.Position        = [100 100 750 300];
fig.PaperSize       = pdf_paper_size;
print([ analysis_figures_dir '\' pdf_file_name], '-dpdf', pdf_print_resolution)
%



