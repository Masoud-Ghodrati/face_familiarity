clear
close all
clc

folder_Name1 = 'Control_Cropped_Equalize';
folder_Name2 = 'Famous_Cropped_Equalize';
myimgDir(1).Dir = ['C:\Users\masoudg\Dropbox\MirroFaceProject\Images\' folder_Name1];
myimgDir(2).Dir = ['C:\Users\masoudg\Dropbox\MirroFaceProject\Images\' folder_Name2];

all_Images(1).Info = dir(myimgDir(1).Dir );
all_Images(2).Info = dir(myimgDir(2).Dir );

c = ['r' 'b'];
for iFolder = 1 : length(all_Images)
    
    img_dir = all_Images(iFolder).Info;
    img_dir = img_dir(3:end);
    stat = [];
    for iImage = 1 : length(img_dir)
        
        img = double(imread([myimgDir(iFolder).Dir  '\' img_dir(iImage).name]))./255;
        
        lum = mean(img(:)) ;
        michelson_Cont = (max(img(:)) - min(img(:))) / (max(img(:)) + min(img(:)));
        rms_Cont = std(img(:));
        
        stat(:, iImage) = [lum michelson_Cont rms_Cont];
    end
    
    subplot(1,2,1)
    scatter(stat(1,:), stat(2,:), c(iFolder), 'filled'), hold on
    ylabel('Michelson Contrast')
    xlabel('Luminance')
    subplot(1,2,2)
    scatter(stat(1,:), stat(3,:), c(iFolder), 'filled'), hold on
    ylabel('RMS Contrast')
    xlabel('Luminance')
end

legend(folder_Name1, folder_Name2)


