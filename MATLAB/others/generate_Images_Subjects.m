clear
close all
clc

coherence_Values  = [60]./100;  % signal level vector

image_category_Name = 'Subject_01\Self_Cropped_Equalize';  % which image directory you want to crop
image_Path = ['C:\Users\masoudg\Dropbox\Project_Mirror Face\Images\' image_category_Name];  % image directory for selected category
image_Name = dir([image_Path '\']);  % extract image names and information
if image_Name(1).name == '.'
    image_Name = image_Name(3:end);
end

save_category_Name = [image_category_Name '_imageset'];  % folder name for saving images
mkdir(['\\ad.monash.edu\home\User098\masoudg\Desktop\faces\images\' save_category_Name]);  % image directory for saving images
save_image_Path = ['\\ad.monash.edu\home\User098\masoudg\Desktop\faces\images\' save_category_Name];

numSample = 1;  % how many sample for each level

for iNoise = 1 : length(coherence_Values) % loop over coherence levels
    
    mkdir([save_image_Path '\Coherence_' num2str(100*coherence_Values(iNoise))])
    
    for iImage = 1 : length(image_Name)  % loop over image
        
        this_original_img_file = [image_Path '\' image_Name(iImage).name];  % load one image
        
        phase_Scram_img = calculated_PhaseScrambleImage(this_original_img_file, coherence_Values(iNoise), numSample) ;
        imwrite(phase_Scram_img{1}, [save_image_Path '\Coherence_' num2str(100*coherence_Values(iNoise)),...
            '\' image_Name(iImage).name(1:find(image_Name(iImage).name=='.')-1) '_Noise_' num2str(100*coherence_Values(iNoise)) '.png'])
        
    end
    
end