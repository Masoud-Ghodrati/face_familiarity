clear
close all
clc

param.data_path             = ['C:\MyFolder\Face_Familiarity\Data\RSA_feedback_feedforward_data\'];
param.analysis_figures_dir  = ['C:\MyFolder\Face_Familiarity\Git\face_familiarity\Figure_06\plots'];
param.region                = [3];
param.coherence             = [0.55];
param.file_names            = {'st_FF_FB_different_familiarity_models',...
    'rp_FF_FB_different_familiarity_models'};

% data overview:
%   1st dimension: Subject
%   2nd dimension: time
%   3rd dimension: {'unfamiliar','familiar','levels','famous','personally','self'}

for iFile = 1 : length(param.file_names )
    
    load([param.data_path param.file_names{iFile} '.mat'])
    param.aligned(iFile).data         = FF_FB_models;
    param.aligned(iFile).significance = significance;
    
end
