clear
close all
clc

% set some parameters
param.MainImagePath    = 'C:\Users\masoudg\Dropbox\Project_Mirror Face\Images'; % main path for images
param.save_Path        = 'C:\Users\masoudg\Dropbox\Project_Mirror Face\code_repo\Modeling analysis'; % path for saving the results
param.MeanFFT_Path     = 'C:\Users\masoudg\Dropbox\Project_Mirror Face\code_repo\mean_FFT_Amplitude.mat';
param.Subject          = 'Subject_'; % subject index/number
param.Category{1}      = 'Familiar_Cropped_Equalize'; % subject's familar category
param.Category{2}      = 'Self_Cropped_Equalize'; % subject's self category
param.Category{3}      = 'Control_Cropped_Equalize'; % control category
param.Category{4}      = 'Famous_Cropped_Equalize'; % famous category
param.NumImages        = 30; % number of images selected from each category
param.ImageSizeOriginal= [400 400]; % this is the size we presented to subjects
param.ImageSizeDNN     = [277 277];% image size (this might change depending on the deep neural network)
param.coherence_Values = [22, 30, 45, 55]./100;  % signal level vector
param.Net              = alexnet; % we use alexnet
param.Layers           = {'pixel' 'conv1' 'conv2' 'conv3' 'conv4' 'conv5' 'fc6' 'fc7' 'fc8'}; % which layers we want features from
load(param.MeanFFT_Path);  % a .mat file that contains the average frequency amplitude of all images
param.MeanFrequencyApm    = mean_FFT_Amplitude;
param.FIGURE_DIMENSION = [1400 600];
param.PRINTED_FIGURE_SIZE = [30 20];
param.SAVE_PDF         = true;
param.PDF_RESOLUTION   = '-r300';
param.SubjectInd       = [1:16];

for iSubject = 1 : length(param.SubjectInd)
    
    param.Subject = ['Subject_' num2str(param.SubjectInd(iSubject), '%0.2d')];
    [results_MDS, results_RDM, results_LumCont] = extractDCNNfeatures_calculateRDM(param);
    for iRDM = 1 : 36
        results_allRDM(iRDM).RDM(:,:,iSubject) = results_RDM(iRDM).RDM;
        results_allRDM(iRDM).name = results_RDM(iRDM).name;
    end
    
    for iNoise = 1 : length(param.coherence_Values) % loop over coherence levels
        for iLayer = 1 : length(param.Layers)
            results_allMDS.MDS_Y{iNoise, iLayer}(:,:,iSubject) = results_MDS.MDS_Y{iNoise, iLayer};
            
        end
    end
    clc
    fprintf(['Subject: ' num2str(iSubject) '\n'])
end

%%
for iRDM = 1 : 36
    results_AveallRDM(iRDM).RDM = mean(results_allRDM(iRDM).RDM, 3);
    results_AveallRDM(iRDM).name = results_RDM(iRDM).name;
end
subplot_Ind = 1;
for iNoise = 1 : length(param.coherence_Values) % loop over coherence levels
    for iLayer = 1 : length(param.Layers)
        [Y e]                    = cmdscale(results_AveallRDM(subplot_Ind).RDM);
        results_AveMDS.MDS_Y{iNoise, iLayer} = Y(:,1:2);
        results_AveMDS.MDS_e{iNoise, iLayer} = e;
        subplot_Ind = subplot_Ind + 1;
    end
end


close all
%% visualization RDM
fig_1       = figure(1);
rsa.fig.showRDMs(results_AveallRDM, fig_1, 1, [], 0, 8/4)

set(fig_1,'color','w')
set(fig_1, 'Position', [0 0 param.FIGURE_DIMENSION])
set(fig_1, 'PaperUnits','centimeters')
set(fig_1, 'PaperSize',param.PRINTED_FIGURE_SIZE)
set(fig_1, 'PaperPositionMode','auto')
if param.SAVE_PDF == true
    
    print('-dpdf', param.PDF_RESOLUTION, [param.save_Path '\Average_RDM_AlexNet' date '.pdf'])
    winopen([param.save_Path '\Average_RDM_AlexNet' date '.pdf'])
    
end
%% visualization MDS
fig_2       = figure(2);
subplot_Ind = 1;
color_Vec   = [1 0 0;
    0 1 0;
    0 0 1;
    0 0 0];

for iNoise = 1 : length(param.coherence_Values) % loop over coherence levels
    
    for iLayer = 1 : length(param.Layers)
        
        figure(fig_2)
        subplot(length(param.coherence_Values), length(param.Layers), subplot_Ind)
        category_Ind = 1;
        for iCategory = 1 : length(param.Category)
            
            h = plot(results_AveMDS.MDS_Y{iNoise, iLayer}(category_Ind : category_Ind + param.NumImages - 1,1), results_AveMDS.MDS_Y{iNoise, iLayer}(category_Ind : category_Ind + param.NumImages - 1, 2), 'o');
            
            h.MarkerFaceColor = color_Vec(iCategory, :);
            h.Marker = 'o';
            h.MarkerEdgeColor = color_Vec(iCategory, :);
            h.MarkerSize = 3;
            category_Ind = category_Ind + param.NumImages;
            hold on
            axis off
        end
        subplot_Ind = subplot_Ind + 1;
    end
    

end
legend('Famil','Self','Contr','Famo', 'Location','eastoutside')
legend boxoff
set(fig_2,'color','w')
set(fig_2, 'Position', [0 0 param.FIGURE_DIMENSION])
set(fig_2, 'PaperUnits','centimeters')
set(fig_2, 'PaperSize',param.PRINTED_FIGURE_SIZE)
set(fig_2, 'PaperPositionMode','auto')
if param.SAVE_PDF == true
    
    print('-dpdf', param.PDF_RESOLUTION, [param.save_Path '\Average_MDS_AlexNet' date '.pdf'])
    winopen([param.save_Path '\Average_MDS_AlexNet' date '.pdf'])
    
end
%% visualization contrast
fig_3       = figure(3);
subplot_Ind = 1;

for iNoise = 1 : length(param.coherence_Values) % loop over coherence levels
    
    for iLayer = 1 : length(param.Layers)
        
        figure(fig_3)
        subplot(length(param.coherence_Values), length(param.Layers), subplot_Ind)
        category_Ind = 1;
        for iCategory = 1 : length(param.Category)
            
            x_Data = mean(results_allMDS.MDS_Y{iNoise, iLayer}(category_Ind : category_Ind + param.NumImages - 1,1,:));
            y_Data = mean(results_allMDS.MDS_Y{iNoise, iLayer}(category_Ind : category_Ind + param.NumImages - 1,2,:));
            h = plot(squeeze(x_Data), squeeze(y_Data), 'o');
            
            h.MarkerFaceColor = color_Vec(iCategory, :);
            h.Marker = 'o';
            h.MarkerEdgeColor = color_Vec(iCategory, :);
            h.MarkerSize = 3;
            category_Ind = category_Ind + param.NumImages;
            hold on
                            axis off
        end
        subplot_Ind = subplot_Ind + 1;
    end
    
end

set(fig_3,'color','w')
set(fig_3, 'Position', [0 0 param.FIGURE_DIMENSION])
set(fig_3, 'PaperUnits','centimeters')
set(fig_3, 'PaperSize',param.PRINTED_FIGURE_SIZE)
set(fig_3, 'PaperPositionMode','auto')
if param.SAVE_PDF == true
    
    print('-dpdf', param.PDF_RESOLUTION, [param.save_Path '\AveMDSSubject' date '.pdf'])
    winopen([param.save_Path '\AveMDSSubject' date '.pdf'])
    
end
