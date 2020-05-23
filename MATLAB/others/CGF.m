clear
close all
clc

% simulate some data
unique_Noise_Coherence = linspace(0, 0.6, 100);  % nois/coherence levels
noise_Threshold        = [0.40 0.45 0.2 0.25 ];  % threshold of psychometric functions
Slop                   = [  15   15   40   30]'; % slop of psychometric functions
accuracy_Matrix        = 1./(1+exp(-Slop.*(repmat(unique_Noise_Coherence, 4, 1) - noise_Threshold')));

% ploting setting
LINE_WIDTH             = 2;
FONT_SIZE              = 10;
all_Legends            = {'Control','Famous','Self','Familiar',''};
AXIS_LINE_WIDTH        = 1;
TICK_LENGTH            = 3;
X_AXIS_LIM             = [0 0.6];
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
Line_Color           = [1 0 0;0 1 0;0 0 1;0 0 0];

% plot
h = rectangle('Position', [0.25 Y_AXIS_1ST_TICK 0.25 6]);
h.EdgeColor = 'none';
h.FaceColor = 0.8*[1 1 1];
hold on
for i = 1 : 4
    if i == 2
        plot(unique_Noise_Coherence, (0.7*accuracy_Matrix(i,:))+0.25, 'linewidth', 2, 'color', Line_Color(i, :))
    else
        plot(unique_Noise_Coherence, (0.5*accuracy_Matrix(i,:))+0.5, 'linewidth', 2, 'color', Line_Color(i, :))
        
    end
end
plot(unique_Noise_Coherence, 0.5*ones(size(unique_Noise_Coherence)), '--k')
text(0.25,0.53, 'Chance')
aX = gca;
aX.Box         = 'off';
aX.TickDir     = 'out';
aX.TickLength  = TICK_LENGTH*aX.TickLength;
aX.YLim        = Y_AXIS_LIM;
aX.XLim        = X_AXIS_LIM;
aX.YTick       = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(2), Y_AXIS_LABEL_NUM_STEPS);
aX.XTick       = linspace(unique_Noise_Coherence(1), unique_Noise_Coherence(end), 7) ;
aX.XTickLabel  = 100*aX.XTick;
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
        print('-dpdf', PDF_RESOLUTION, ['Sim_Psychometric_Function_Legend_' date '.pdf'])
        winopen(['Sim_Psychometric_Function_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, ['Sim_Psychometric_Function_' date '.pdf'])
        winopen(['Sim_Psychometric_Function_' date '.pdf'])
    end
end