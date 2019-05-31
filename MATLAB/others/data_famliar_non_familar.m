clear
close all
clc

load Subject_07_preprosessed.mat


aligment = 1;
group_catg = {[1], [2 3 4]};
group_chor = {0.22,0.3,0.45,0.55};

iSession = 1;
this_data1 = EEG_signals{aligment, iSession};
this_stim_ord1 = [Exp_data{1, iSession}.stim.stimTrain.imageCategory];
this_unq_stim_ord1  = unique(this_stim_ord1);
this_stim_chor1 = [Exp_data{1, iSession}.stim.stimTrain.imageNoise];
this_unq_stim_chor1  = unique(this_stim_chor1);

iSession = 2;
this_data2 = EEG_signals{aligment, iSession};
this_stim_ord2 = [Exp_data{1, iSession}.stim.stimTrain.imageCategory];
this_unq_stim_ord2  = unique(this_stim_ord2);
this_stim_chor2 = [Exp_data{1, iSession}.stim.stimTrain.imageNoise];
this_unq_stim_chor2  = unique(this_stim_chor2);


for iCatg = 1 : length(group_catg)
    
    for iChor = 1 : length(group_chor)
        
        indord1  = sum(this_stim_ord1 == group_catg{iCatg}', 1) >= 1;
        indchor1 = sum(this_stim_chor1 == group_chor{iChor}', 1) >= 1;
        indall1  = indord1 & indchor1;
        
        indord2  = sum(this_stim_ord2 == group_catg{iCatg}', 1) >= 1;
        indchor2 = sum(this_stim_chor2 == group_chor{iChor}', 1) >= 1;
        indall2  = indord2 & indchor2;
        
        
        for iChan = 1: 64
            these_trials = [double(squeeze(this_data1(iChan, :, indall1))');
                double(squeeze(this_data2(iChan, :, indall2))')];
            
            data(iChan, iChor, iCatg, :, :) = these_trials(:,1:5:end)';
            
        end
    end
end



