clear
close all
clc

image_category_Name = 'Subject_20\Self';  % which image directory you want to crop
image_Path = ['C:\Users\masoudg\Dropbox\Project_Mirror Face\Images\' image_category_Name];  % image directory for selected category
image_Name = dir([image_Path '\']);  % extract image names and information
if image_Name(1).name == '.'
    image_Name = image_Name(3:end);
end
save_category_Name = [image_category_Name '_Cropped'];  % folder name for saving images
mkdir(['C:\Users\masoudg\Dropbox\Project_Mirror Face\Images\' save_category_Name]);  % image directory for saving images
save_image_Path = ['C:\Users\masoudg\Dropbox\Project_Mirror Face\Images\' save_category_Name];

defined_Rectangle_XSize = 400;  % output image X size (pixel)
defined_Rectangle_YSize = 400;  % output image X size (pixel)

for iImage = 1 : length(image_Name)  % loop over image
    
    close all
    figure('units','normalized','outerposition',[0 0 1 1]);
    
    this_original_img = imread([image_Path '\' image_Name(iImage).name]);  % load one image
    if length(size(this_original_img)) > 2  % convert it to gray if it is not
        this_original_img = rgb2gray(this_original_img);
    end
    
    %  croppong part
    happy = 'n';
    while ~strcmpi(happy, 'y')  % crop the images as many times as you think is enough
        
        subplot(121)
        imshow(this_original_img)
        [cropped_img, rect] = imcrop(this_original_img);  % crop the image using mouse
        title('original image')
        title(['original size, y: ' num2str(size(this_original_img, 1)),...
            ', x: ' num2str(size(this_original_img, 2))])
        
        subplot(122)
        imshow(cropped_img)
        title(['Cropped, y: ' num2str(size(cropped_img, 1)) ', x: ' num2str(size(cropped_img, 2)) ,...
            ', Press y if you are happy with the size, any key otherwise'])
        
        happy = input('Are you happy? press y:', 's');  % if you are not happy with the crop: press y, enter, do it again using mouse
        clf
        
    end
    
    % resize to selected size and save in the directory
    output_img = imresize(cropped_img, [defined_Rectangle_XSize defined_Rectangle_YSize]);
    imwrite(output_img, [save_image_Path '\' image_Name(iImage).name(1:find(image_Name(iImage).name=='.')-1) '.png'])
    
end