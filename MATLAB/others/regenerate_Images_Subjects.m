clear
close all
clc

psy_data_path   = ['C:\MyFolder\Face_Familiarity\Data\Behavioral_data\'];  % the path for behavioral data
image_data_path = ['C:\Users\masoudg\Dropbox\Project_Mirror Face\Images\'];  % the path for image data
save_image_path = ['C:\MyFolder\Face_Familiarity\Data\Images\'];  % the path for save generated images
cohereneces     = [0.22 0.30 0.45 0.55];  % coherences
num_subjects    = 16;  % number of subject

face_cat_names  = {'Control_Cropped_Equalize',...
    'Famous_Cropped_Equalize',...
    'Self_Cropped_Equalize',...
    'Familiar_Cropped_Equalize'};

psy_file_name   = 'Face_Discrimination_Data_Subject_';  % general fike name of the  behavioral data

for iSub = 1 : num_subjects  % loop over subjects
    
    this_psy_data_dir = dir([psy_data_path psy_file_name num2str(iSub, '%0.2d') '_*.mat']);
    
    for iPsy_dir = 1 : length(this_psy_data_dir)  % loop over data files for evey subject
        
        load([this_psy_data_dir(iPsy_dir).folder '\' this_psy_data_dir(iPsy_dir).name])
        
        for iTrial = 1 : length(stim.stimTrain)  % loop over trials
            
            this_img_cat = stim.stimTrain(iTrial).imageCategory;
            if this_img_cat == 1 || this_img_cat == 2
                this_img_dir = [image_data_path                                       face_cat_names{this_img_cat} '\' stim.stimTrain(iTrial).imageName];
            else
                this_img_dir = [image_data_path 'Subject_' num2str(iSub, '%0.2d') '\' face_cat_names{this_img_cat} '\' stim.stimTrain(iTrial).imageName];
            end
            
            disp(this_img_dir)
            
            % read the image and add noise
            num_samples = floor(stim.ResponseData.Values(1, iTrial)/ 16.7);
            if isnan(num_samples)
                num_samples = 50;
            end
            phase_Scram_img = calculated_PhaseScrambleImage(this_img_dir, stim.stimTrain(iTrial).imageNoise, num_samples);
            phase_Scram_img = mean(reshape(cell2mat(phase_Scram_img), size(phase_Scram_img{1}, 1), size(phase_Scram_img{1}, 2), []), 3);
            % save the image
            this_sourse_dir  = [save_image_path 'Subject_' num2str(iSub, '%0.2d') '\coherence_' num2str(100*stim.stimTrain(iTrial).imageNoise)];
            if ~exist(this_sourse_dir, 'dir')
                mkdir(this_sourse_dir)
            end
            
            imwrite(phase_Scram_img, [this_sourse_dir '\' stim.stimTrain(iTrial).imageName])
            
        end
        
        
    end
    
end

