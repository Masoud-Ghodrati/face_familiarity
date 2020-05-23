clear
close all
clc

w_Values   = [0.5 0.45 0.4 0.35 0.3 0.25 0.2];  % signal level vector
image_File = '\\ad.monash.edu\home\User098\masoudg\Pictures\photo.JPG';  % image name
numSample = 1;  % how many sample for each level

figure(1)
% read image
img = imread(image_File);
if length(size(img)) > 1  % if it's  color image, convert it to gray
    img = rgb2gray(img);
end
img      = double(img)./255;  % we need to be double format
imshow(img)
title('Original Image')

figure(2)
SampleCnt = 1;  % just a counter for subplot
for iNoise = 1 : length(w_Values)
    
    phase_Scram_img = calculated_PhaseScrambleImage(image_File, w_Values(iNoise), numSample) ;
    
    for iSample = 1 :  numSample
        subplot(length(w_Values), numSample, SampleCnt)
        %         subplot(numSample, length(w_Values), SampleCnt)
        imshow(phase_Scram_img{iSample})
        SampleCnt = SampleCnt + 1;
    end
end