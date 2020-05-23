equalization_Methodclear
close all
clc

image_category_Name = 'Famous_Cropped';  % which image directory you want to equalize
image_Path = ['C:\Users\masoudg\Dropbox\MirroFaceProject\Images\' image_category_Name];  % image directory for selected category
image_Name = dir(image_Path);  % extract image names and information
image_Name = image_Name(3:end);

save_category_Name = 'Famous_Cropped_Equalize';  % folder name for saving images
save_image_Path = ['C:\Users\masoudg\Dropbox\MirroFaceProject\Images\' save_category_Name];  % image directory for saving images


for iImage = 1 : length(image_Name)  % loop over image
    
    
    this_original_img = imread([image_Path '\' image_Name(iImage).name]);  % load one image
    if size(this_original_img, 3) > 1  % convert it to gray if it is not
        this_original_img = rgb2gray(this_original_img);
    end
    
    if iImage == 1
        all_img_Matrix = zeros(size(this_original_img));
    end
    this_original_img = im2double(this_original_img);
    this_original_img = imadjust(this_original_img, [min(this_original_img(:)) max(this_original_img(:))], [0 1]);
    all_img_Matrix(:,:,iImage) = imadjust(this_original_img);
    
%   all_img_Matrix(:,:,iImage) = double(imadjust(this_original_img));
    
end

mean_all_img = im2uint8(imadjust(mean(all_img_Matrix, 3)));

close all
figure('units','normalized','outerposition',[0 0 1 1]);
for iImage = 1 : length(image_Name)  % loop over image
    
    
    this_original_img = imread([image_Path '\' image_Name(iImage).name]);  % load one image
    if size(this_original_img, 3) > 1  % convert it to gray if it is not
        this_original_img = rgb2gray(this_original_img);
    end
    
    equalized_img = histeq(this_original_img);
    equalized_img = imhistmatch(this_original_img, mean_all_img);
    subplot(231)
    imshow(this_original_img)
    subplot(232)
    imshow(equalized_img)
    subplot(233)
    imshow(mean_all_img)
    
    subplot(234)
    imhist(this_original_img)
    subplot(235)
    imhist(equalized_img)
    subplot(236)
    imhist(mean_all_img)
    % resize to selected size and save in the directory
%     output_img = imresize(cropped_img, [defined_Rectangle_XSize defined_Rectangle_YSize]);
%     imwrite(output_img, [save_image_Path '\' image_Name(iImage).name(1:find(image_Name(iImage).name=='.')-1) '.png'])
    pause()
end