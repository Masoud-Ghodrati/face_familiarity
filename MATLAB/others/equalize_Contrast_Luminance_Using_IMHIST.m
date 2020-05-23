clear
close all
clc

image_category_Name = 'Subject_16\Familiar_Cropped';  % which image directory you want to crop
image_Path = ['C:\Users\masoudg\Dropbox\Project_Mirror Face\Images\' image_category_Name];  % image directory for selected category
image_Name = dir([image_Path '\']);  % extract image names and information
if image_Name(1).name == '.'
    image_Name = image_Name(3:end);
end
save_category_Name = [image_category_Name '_Equalize'];  % folder name for saving images
mkdir(['C:\Users\masoudg\Dropbox\Project_Mirror Face\Images\' save_category_Name]);  % image directory for saving images
save_image_Path = ['C:\Users\masoudg\Dropbox\Project_Mirror Face\Images\' save_category_Name];

close all
figure('units','normalized','outerposition',[0 0 1 1]);
for iImage = 1 : length(image_Name)  % loop over image
    

    this_original_img = imread([image_Path '\' image_Name(iImage).name]);  % load one image
    if size(this_original_img, 3) > 1  % convert it to gray if it is not
        this_original_img = rgb2gray(this_original_img);
    end
    
    equalized_img = histeq(this_original_img);
    
    subplot(221)
    imshow(this_original_img)
    subplot(222)
    imshow(equalized_img)
    
    subplot(223)
    imhist(this_original_img)
    subplot(224)
    imhist(equalized_img)

    % save imgae in the directory
    imwrite(equalized_img, [save_image_Path '\' image_Name(iImage).name(1:find(image_Name(iImage).name=='.')-1) '.png'])
    
%     pause(0.2)
end