clear
close all
clc

file_Path        = 'C:\MyFolder\Face_Familiarity\Data\Behavioral_data';  % file path for subject recorded data
file_Name        = 'Hit_rates_False_alarms_and_Correct_reaction_times';             % file name for subject recorded data
save_path        = 'C:\MyFolder\Face_Familiarity\Data\Behavioral_data\Tabel_ANOVA';

% load the data
load([file_Path '\' file_Name '.mat'])
% categories 1:5 are in order Control, Familiar, Famous, Personally familiar and Self

%% make HR for familar and unfamilar
cat_name = {'F', 'U'};
sub_HR   = [];
coh_lev  = [];
cat_nam  = [];

for iFamiliarity = [1 2] % 1: control 2: familiar
    
    
    for iCoh = 1 : 4 % coherence levels
        
        this_HR           = [TPR(:, iFamiliarity, iCoh, 1);
            TPR(:, iFamiliarity, iCoh, 2)];
        this_HR           = this_HR(~isnan(this_HR));
        this_coh_label    = iCoh*ones(size(this_HR));
        this_cat_label    = cell(size(this_HR));
        this_cat_label(:) = {cat_name{iFamiliarity}};
        
        sub_HR  = [sub_HR; this_HR];
        coh_lev = [coh_lev; this_coh_label];
        cat_nam = [cat_nam ; this_cat_label];
        
    end
      
end

T_TPR = table(cat_nam, coh_lev, sub_HR);
writetable(T_TPR, [save_path '\TPR_Familiar_Unfamiliar.xlsx' ]);
%% make FPR for familar and unfamilar
cat_name = {'F', 'U'};
sub_FPR   = [];
coh_lev  = [];
cat_nam  = [];

for iFamiliarity = [1 2] % 1: control 2: familiar
    
    
    for iCoh = 1 : 4 % coherence levels
        
        this_FPR           = [FPR(:, iFamiliarity, iCoh, 1);
            FPR(:, iFamiliarity, iCoh, 2)];
        this_FPR           = this_FPR(~isnan(this_FPR));
        this_coh_label    = iCoh*ones(size(this_FPR));
        this_cat_label    = cell(size(this_FPR));
        this_cat_label(:) = {cat_name{iFamiliarity}};
        
        sub_FPR  = [sub_FPR; this_FPR];
        coh_lev = [coh_lev; this_coh_label];
        cat_nam = [cat_nam ; this_cat_label];
        
    end
      
end

T_FPR = table(cat_nam, coh_lev, sub_FPR);
writetable(T_FPR, [save_path '\FPR_Familiar_Unfamiliar.xlsx' ]);
%% make RT for familar and unfamilar
cat_name = {'F', 'U'};
sub_RT   = [];
coh_lev  = [];
cat_nam  = [];

for iFamiliarity = [1 2] % 1: control 2: familiar
    
    
    for iCoh = 1 : 4 % coherence levels
        
        this_RT           = [RT_correct(:, iFamiliarity, iCoh, 1);
            RT_correct(:, iFamiliarity, iCoh, 2)];
        this_RT           = this_RT(~isnan(this_RT));
        this_coh_label    = iCoh*ones(size(this_RT));
        this_cat_label    = cell(size(this_RT));
        this_cat_label(:) = {cat_name{iFamiliarity}};
        
        sub_RT  = [sub_RT; this_RT];
        coh_lev = [coh_lev; this_coh_label];
        cat_nam = [cat_nam ; this_cat_label];
        
    end
      
end

T_RT = table(cat_nam, coh_lev, sub_RT);
writetable(T_RT, [save_path '\RT_Familiar_Unfamiliar.xlsx' ]);
%% make HR for familar subcategories
cat_name = {'F','U','F', 'P', 'S'};
sub_HR   = [];
coh_lev  = [];
cat_nam  = [];

for iFamiliarity = [3 4 5] % 1: control 2: familiar
    
    
    for iCoh = 1 : 4 % coherence levels
        
        this_TP           = [TPR(:, iFamiliarity, iCoh, 1);
            TPR(:, iFamiliarity, iCoh, 2)];
        this_TP           = this_TP(~isnan(this_TP));
        this_coh_label    = iCoh*ones(size(this_TP));
        this_cat_label    = cell(size(this_TP));
        this_cat_label(:) = {cat_name{iFamiliarity}};
        
        sub_HR  = [sub_HR; this_TP];
        coh_lev = [coh_lev; this_coh_label];
        cat_nam = [cat_nam ; this_cat_label];
        
    end
      
end

T_TP_sub = table(cat_nam, coh_lev, sub_HR);
writetable(T_TP_sub, [save_path '\TPR_Familiar_Sub.xlsx' ]);
%% make HR for familar subcategories
cat_name = {'F','U','F', 'P', 'S'};
sub_RT   = [];
coh_lev  = [];
cat_nam  = [];

for iFamiliarity = [3 4 5] % 1: control 2: familiar
    
    
    for iCoh = 1 : 4 % coherence levels
        
        this_RT           = [RT_correct(:, iFamiliarity, iCoh, 1);
            RT_correct(:, iFamiliarity, iCoh, 2)];
        this_RT           = this_RT(~isnan(this_RT));
        this_coh_label    = iCoh*ones(size(this_RT));
        this_cat_label    = cell(size(this_RT));
        this_cat_label(:) = {cat_name{iFamiliarity}};
        
        sub_RT  = [sub_RT; this_RT];
        coh_lev = [coh_lev; this_coh_label];
        cat_nam = [cat_nam ; this_cat_label];
        
    end
      
end

T_RT_sub = table(cat_nam, coh_lev, sub_RT);
writetable(T_RT_sub, [save_path '\RT_Familiar_Sub.xlsx' ]);



