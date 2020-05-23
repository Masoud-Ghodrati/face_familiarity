function phase_Scram_img = calculated_PhaseScrambleImage_DCNN(image_File, w, MeanAmplitude)


% read image
if ischar(image_File)
    img = imread(image_File);
else
    img = image_File;
    if length(size(img)) > 2  % if it's  color image, convert it to gray
        img = rgb2gray(img);
    end
end
img      = double(img)./255;  % we need to be double format
img_Size = size (img);

% we need to correct for luminance
% ...

% we need to correct for contrast
% ...

% calculate the image FFT
img_FFT         = fft2(img);
% img_FFTmag      = abs(img_FFT);    % magnitude of FFT, we don't need it
img_FFTphi      = angle(img_FFT);  % phase of FFT

% noise FFT
n_img        = rand(img_Size);    % make a random image
n_img_FFT    = fft2(n_img);       % calculate the fft of random image
% n_img_FFTmag = abs(n_img_FFT);    % magnitude of FFT
n_img_FFTphi = angle(n_img_FFT);  % phase of FFT

% phase scrambeling, read these papers:
% Philiastides, M. G., & Sajda, P. (2005). Cerebral cortex, 16(4), 509-518.
% Dakin, S. C., Hess, R. F., Ledgeway, T., & Achtman, R. L. (2002). Current Biology, 12(14), R476-R477.
S = w * sin(img_FFTphi) + (1 - w) * sin(n_img_FFTphi);
C = w * cos(img_FFTphi) + (1 - w) * cos(n_img_FFTphi);

ind_Finalphi_1 = C > 0;
ind_Finalphi_2 = C < 0 & S > 0;
ind_Finalphi_3 = C < 0 & S < 0;

final_phi(:, :, 1) = ind_Finalphi_1 .*  atan(S./C);
final_phi(:, :, 2) = ind_Finalphi_2 .* (atan(S./C) + pi);
final_phi(:, :, 3) = ind_Finalphi_3 .* (atan(S./C) - pi);
final_phi          = sum(final_phi, 3);

% inverse FFT
scrambled_FFT   = MeanAmplitude.*exp(1i*final_phi);
phase_Scram_img = abs(ifft2(scrambled_FFT));

