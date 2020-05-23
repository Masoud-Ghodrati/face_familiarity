clear
close all
clc

image_Path     = 'C:\Users\masoudg\Dropbox\Project_Mirror Face\Images';  % image path, all images from all categories and subjects should be on one path
subject_Num    = 9;                                % number of subject that you hvae
category1_Name = 'Control_Cropped_Equalize';       % folder name of control images
category2_Name = 'Famous_Cropped_Equalize';        % folder name of famous images
category3_Name = 'Familiar_Cropped_Equalize';      % folder name of familiar images
category4_Name = 'Self_Cropped_Equalize';          % folder name of self images

image_Size         = [400 400]; % this should be the same size of images
mean_FFT_Amplitude = zeros(image_Size(1), image_Size(2));
image_Counter      = 0; % images counter

% control
image_Names = dir([image_Path '\' category1_Name '\']);
if image_Names(1).name == '.'
    image_Names = image_Names(3:end);
end
for iImage = 1 : length(image_Names)  % loop over the images
    
    img = double(imread([ image_Path '\' category1_Name '\' image_Names(iImage).name]))./255;  % load the image
    
    img_FFT            = fft2(img);       % calculate the FFT
    img_FFTmag         = abs(img_FFT);    % magnitude of FFT
    img_FFTphi         = angle(img_FFT);  % phase of FFT
    mean_FFT_Amplitude = mean_FFT_Amplitude + img_FFTmag;  % sum all the amps to finally take the mean
    image_Counter = image_Counter + 1;
end

% famous
image_Names = dir([image_Path '\' category2_Name '\']);
if image_Names(1).name == '.'
    image_Names = image_Names(3:end);
end
for iImage = 1 : length(image_Names)  % loop over the images
    
    img = double(imread([ image_Path '\' category2_Name '\' image_Names(iImage).name]))./255;  % load the image
    
    img_FFT            = fft2(img);       % calculate the FFT
    img_FFTmag         = abs(img_FFT);    % magnitude of FFT
    img_FFTphi         = angle(img_FFT);  % phase of FFT
    mean_FFT_Amplitude = mean_FFT_Amplitude + img_FFTmag;  % sum all the amps to finally take the mean
    image_Counter = image_Counter + 1;
end


% familair
for iSubject = 1 : subject_Num
    
    image_Names = dir([image_Path '\Subject_' num2str(iSubject, '%0.2d') '\' category3_Name '\']);
    if image_Names(1).name == '.'
        image_Names = image_Names(3:end);
    end
    for iImage = 1 : length(image_Names)  % loop over the images
        
        img = double(imread([image_Path '\Subject_' num2str(iSubject, '%0.2d') '\' category3_Name '\' image_Names(iImage).name]))./255;  % load the image
        
        img_FFT            = fft2(img);       % calculate the FFT
        img_FFTmag         = abs(img_FFT);    % magnitude of FFT
        img_FFTphi         = angle(img_FFT);  % phase of FFT
        mean_FFT_Amplitude = mean_FFT_Amplitude + img_FFTmag;  % sum all the amps to finally take the mean
        image_Counter = image_Counter + 1;
    end
    
end


% self
for iSubject = 1 : subject_Num
    
    image_Names = dir([image_Path '\Subject_' num2str(iSubject, '%0.2d') '\' category4_Name '\']);
    if image_Names(1).name == '.'
        image_Names = image_Names(3:end);
    end
    for iImage = 1 : length(image_Names)  % loop over the images
        
        img = double(imread([image_Path '\Subject_' num2str(iSubject, '%0.2d') '\' category4_Name '\' image_Names(iImage).name]))./255;  % load the image
        
        img_FFT            = fft2(img);       % calculate the FFT
        img_FFTmag         = abs(img_FFT);    % magnitude of FFT
        img_FFTphi         = angle(img_FFT);  % phase of FFT
        mean_FFT_Amplitude = mean_FFT_Amplitude + img_FFTmag;  % sum all the amps to finally take the mean
        image_Counter = image_Counter + 1;
    end
    
end

mean_FFT_Amplitude = mean_FFT_Amplitude./image_Counter;  % mean amp

save('mean_FFT_Amplitude', 'mean_FFT_Amplitude')
