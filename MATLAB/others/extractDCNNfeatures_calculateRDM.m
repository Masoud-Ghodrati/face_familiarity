function [results_MDS, results_RDM, results_LumCont] = extractDCNNfeatures_calculateRDM(param)
image_Ind              = 1; % this is a counter for loader images
subplot_Ind            = 1;
% load images
for iCategory = 1 : length(param.Category)
    
    fprintf([param.Subject ', ' param.Category{iCategory} ' : '])
    if iCategory <= 2 % if we are loading familiar or self category
        image_Name = dir([param.MainImagePath '\' param.Subject '\' param.Category{iCategory}]);  % extract image names and information
        if image_Name(1).name == '.'
            image_Name = image_Name(3:end);
        end
        randomize_Image = randperm(length(image_Name)); % randomly select param.NumImages images
        image_Name      = image_Name(1:param.NumImages);
        for iImage = 1 : length(image_Name) % loop over selected images
            fprintf([num2str(iImage) ', '])
            param.allImage{image_Ind} = imresize(imread([param.MainImagePath '\' param.Subject '\' param.Category{iCategory} '\' image_Name(iImage).name ]), param.ImageSizeOriginal);
            image_Ind           = image_Ind  + 1;
            
        end
    else % if we are loading control or famous images
        image_Name = dir([param.MainImagePath '\' param.Category{iCategory}]);  % extract image names and information
        if image_Name(1).name == '.'
            image_Name = image_Name(3:end);
        end
        randomize_Image = randperm(length(image_Name));
        image_Name      = image_Name(1:param.NumImages);
        
        for iImage = 1 : length(image_Name)
            fprintf([num2str(iImage) ', '])
            param.allImage{image_Ind} = imresize(imread([param.MainImagePath '\' param.Category{iCategory} '\' image_Name(iImage).name ]), param.ImageSizeOriginal);
            image_Ind           = image_Ind  + 1;
            
        end
    end
    fprintf('\n')
end

% extract features
for iNoise = 1 : length(param.coherence_Values) % loop over coherence levels
    
    fprintf(['Coherence: ' num2str(param.coherence_Values(iNoise)) ':\n '])
    for iLayer = 1 : length(param.Layers)
        
        fprintf([param.Layers{iLayer}, ', Image: '])
        feature_Vector = [];
        image_Ind      = 1;
        for iImage = 1 : length(param.allImage)  % loop over image
            
            fprintf([ num2str(iImage), ', '])
            
            if  iLayer == 1
                this_phase_Scram_img   = calculated_PhaseScrambleImage_DCNN(param.allImage{image_Ind}, param.coherence_Values(iNoise), param.MeanFrequencyApm) ;
                phase_Scram_img{iImage} = imresize(this_phase_Scram_img, param.ImageSizeDNN);
                feature_Vector(image_Ind,:) = phase_Scram_img{iImage}(:)';
            else
                
                this_Image          = repmat(phase_Scram_img{iImage},1,1,3);
                featureLayer        = param.Layers{iLayer};
                this_Feature_Vector = double(activations(param.Net, this_Image, featureLayer, 'MiniBatchSize', 32, 'OutputAs', 'channels'));
                feature_Vector(image_Ind,:) = this_Feature_Vector(:);
            end
            
            results_LumCont.LumCont{iNoise, iLayer}(iImage,:) = [mean(phase_Scram_img{iImage}(:)) std(phase_Scram_img{iImage}(:))];
            
            image_Ind = image_Ind + 1;
            
        end
        
        % calculate RDM
        modelFeatures            = feature_Vector;
        results_RDM(subplot_Ind).RDM  = rsa.rdm.squareRDM(pdist(modelFeatures,'correlation'));
        results_RDM(subplot_Ind).name = ['C: ' num2str(100*param.coherence_Values(iNoise)) '%, L: ' param.Layers{iLayer}];
        % calculate MDS
        
        [Y e]                    = cmdscale(results_RDM(subplot_Ind).RDM);
        results_MDS.MDS_Y{iNoise, iLayer} = Y(:,1:2);
        results_MDS.MDS_e{iNoise, iLayer} = e;
        
        
        %         save([param.save_Path '\' param.Subject '_RSA_Res.mat' ], 'results_RSA')
        fprintf('\n')
        subplot_Ind = subplot_Ind + 1;
    end
    
end
