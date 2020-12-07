clear
close all
clc


param.data_path     = 'D:\Users\Masoud.Ghodrati\Documents\GitHub\face_familiarity\Data\ERP_data';
analysis_figures_dir = 'D:\Users\Masoud.Ghodrati\Documents\GitHub\face_familiarity';


load([param.data_path '\St_aligned_ERPs_categories_coh_0.22.mat'])
erp_data(1).coh.st = ff;

load([param.data_path '\St_aligned_ERPs_categories_coh_0.30.mat'])
erp_data(2).coh.st = ff;

load([param.data_path '\St_aligned_ERPs_categories_coh_0.45.mat'])
erp_data(3).coh.st = ff;

load([param.data_path '\St_aligned_ERPs_categories_coh_0.55.mat'])
erp_data(4).coh.st = ff;

load([param.data_path '\Rp_aligned_ERPs_categories_coh_0.22.mat'])
erp_data(1).coh.rp = ff;

load([param.data_path '\Rp_aligned_ERPs_categories_coh_0.30.mat'])
erp_data(2).coh.rp = ff;

load([param.data_path '\Rp_aligned_ERPs_categories_coh_0.45.mat'])
erp_data(3).coh.rp = ff;

load([param.data_path '\Rp_aligned_ERPs_categories_coh_0.55.mat'])
erp_data(4).coh.rp = ff;

group_catg = {[1], [2], [3], [4]};
group_chor = {0.22,0.3,0.45,0.55};


%% visualization
close all
clc

param.sr               = 1000; % sampling arte
param.window_stim      = [-100 650]; % window of presentation
param.window_dec       = [-500 100]; % window of presentation
param.window_gap       = 50;
param.coherence        = 1;
param.channel          = 22;%[20:24]; % 22 21 16 44 48   56 57 63 12 40
param.time_stim        = -500:1500;
param.time_dec         = -1500:500;
param.subj_name        = 'all';


% set plot properties
plot_linewidth         = 1;

% set axis properties
axis_ylim              = [-10 15];%[-15 25];%[-10 15];
axis_ylim_spc          = 6;
axis_xlim_spc          = 15;
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
axis_linewidth         = 1;

% set legend properties
legend_box_outline     = 'off';
legend_box_loaction    = 'southeast';
legend_fontangel       = 'normal';
legend_fontsize        = 8;

% set saveing/printing properties
pdf_file_name          = [param.subj_name '_' num2str(group_chor{param.coherence}) '_' chan_locations{1}{param.channel} '_' date];
pdf_paper_size         = [20 20];
pdf_print_resolution   = '-r300';

%
cl                     = colormap(hot(64));
cl                     = cl(1:10:end, :);


% extract the data
if strcmpi(param.subj_name, 'all')
    
    this_st = squeeze( erp_data(param.coherence).coh.st(:, param.channel, :, :) );
    this_rp = squeeze( erp_data(param.coherence).coh.rp(:, param.channel, :, :) );
    
elseif length(param.channel) > 1
    
    this_st = squeeze( erp_data(param.coherence).coh.st(str2num(param.subj_name), param.channel, :, :) );
    this_rp = squeeze( erp_data(param.coherence).coh.rp(str2num(param.subj_name), param.channel, :, :) );
    
else
    
    this_st(1:length(str2num(param.subj_name)), :, :) = squeeze( erp_data(param.coherence).coh.st(str2num(param.subj_name), param.channel, :, :) );
    this_rp(1:length(str2num(param.subj_name)), :, :) = squeeze( erp_data(param.coherence).coh.rp(str2num(param.subj_name), param.channel, :, :) );
    
end
ic = 1;
for iCatg = [1 2 4 3] 
    
    this_data_stim = this_st(:, :, iCatg);
    this_data_dec  = this_rp(:, :, iCatg);
    
    mean_data_stim = nanmean(this_data_stim(:, param.time_stim >= param.window_stim(1) & param.time_stim <= param.window_stim(2)), 1);
    mean_data_dec  = nanmean(this_data_dec(:, param.time_dec >= param.window_dec(1) & param.time_dec <= param.window_dec(2)), 1);
    
    time_vec    = sum(abs(param.window_stim)) + sum(abs(param.window_dec)) + abs(param.window_gap);
    h           = plot([mean_data_stim NaN * ones(1, param.window_gap) mean_data_dec]);
    h.LineWidth = plot_linewidth;
    h.Color     = cl(ic, :);
    hold on
    ic = 1 + ic;
end

time_vec
chan_locations{1}{param.channel}

plot([1 1] * abs(param.window_stim(1)), axis_ylim , ':k')
plot([0 time_vec], [0 0], ':k')
plot([1 1] * time_vec - abs(param.window_dec(2)), axis_ylim , ':k')
plot([sum(abs(param.window_stim)) sum(abs(param.window_stim))+param.window_gap], [0 0], 'w')
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
aX.XTick            = linspace(0, time_vec, axis_xlim_spc);
TickDiff            = aX.XTick(2) - aX.XTick(1);
st_TickSpc          = round(sum(abs(param.window_stim))/TickDiff);
rp_TickSpc          = round(sum(abs(param.window_dec))/TickDiff);
aX.XTickLabel       = [linspace(param.window_stim(1), param.window_stim(end)-param.window_gap, st_TickSpc) linspace(param.window_dec(1), param.window_dec(end), rp_TickSpc+1)];
aX.LineWidth        = axis_linewidth;
aX.XLim             = [0 time_vec];
% aX.XAxisLocation    = 'origin';
% aX.YAxisLocation    = 'origin';

% change legend properties
% there are 4 types of trials
% 1) contol, 2) famous, 3) self, 4) familiar
% the above is the correct labels in the psychophysics data
h           = legend('Control', 'Famous',  'Self', 'Familiar');
h.Location  = legend_box_loaction;
h.Box       = legend_box_outline;
h.FontAngle = legend_fontangel;
h.FontSize  = legend_fontsize;
%
% set the prining properties
fig                 = gcf;
fig.PaperUnits      = 'centimeters';
fig.Position        = [100 100 600 300];
fig.PaperSize       = pdf_paper_size;
print([ analysis_figures_dir '\' pdf_file_name '.pdf'], '-dpdf', pdf_print_resolution)

