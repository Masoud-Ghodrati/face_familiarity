clear
close all
clc

file_Path    = 'C:\Users\masoudg\Dropbox\Project_Mirror Face\EEG_Psycho_Data';  % file path for subject recorded data
file_Name    = 'Face_Discrimination_Data_Subject_05_0000';             % file name for subject recorded data
load([file_Path '\' file_Name])                                        % load the data

unique_Categories      = unique(stim.ResponseData.Values(5, ~isnan(stim.ResponseData.Values(5, :))));  % unique categories: control, famous, familar, self
unique_Coherence_Level = unique(stim.ResponseData.Values(4, ~isnan(stim.ResponseData.Values(4, :))));  % unique coherence levels

% calculate the psychometic function
for iCategory = 1 : length(unique_Categories)
    
    for iCoherence = 1 : length(unique_Coherence_Level)
        
        selected_Traial                         = (stim.ResponseData.Values(5,:) == unique_Categories(iCategory)) & (stim.ResponseData.Values(4,:) == unique_Coherence_Level(iCoherence));
        find(selected_Traial)
        accuracy_Matrix(iCategory, iCoherence ) = nanmean(stim.ResponseData.Values(2, selected_Traial));
        rt_Matrix(iCategory, iCoherence )       = nanmedian(stim.ResponseData.Values(1, selected_Traial));
        
    end
    
end
sum(isnan(stim.ResponseData.Values(2,:)))
figure(1)
subplot(221)
plot(stim.coherence_Values, accuracy_Matrix')
xlabel('Coherence level (%)')
ylabel('accuracy')
legend('control','famous','self','familiar', 'location', 'best')
legend boxoff
box off
subplot(222)
plot(stim.coherence_Values, rt_Matrix')
xlabel('Coherence level (%)')
ylabel('reaction time (ms)')
legend('control','famous','self','familiar', 'location', 'best')
legend boxoff
box off
subplot(223)
plot(stim.coherence_Values, accuracy_Matrix(1,:))
hold on
plot(stim.coherence_Values, mean(accuracy_Matrix(2:end,:)))
xlabel('Coherence level (%)')
ylabel('accuracy')
legend('unfamiliar','familiar', 'location', 'best')
legend boxoff
box off
subplot(224)
plot(stim.coherence_Values, rt_Matrix(1,:))
hold on
plot(stim.coherence_Values, mean(rt_Matrix(2:end,:)))
xlabel('Coherence level (%)')
ylabel('reaction time (ms)')
legend('unfamiliar','familiar', 'location', 'best')
legend boxoff
box off
figure(2)

for iFrame = 1 : size(stim.elapsed_Time, 1)
    subplot(2,2,iFrame)
    if iFrame == 1
        hist([stim.elapsed_Time{iFrame,:}],0:0.1:10)
        xlabel('image generation time (sec)')
        ylabel('Frequency')
    else
        this_Time_Data = [];
        for iTrial = 1 : size(stim.elapsed_Time, 2)
            this_Time_Data(iTrial) = sum(diff(stim.elapsed_Time{iFrame,iTrial}));
        end
        hist(this_Time_Data,0:50:5500)
        switch iFrame
            case 2
                xlabel('fixation time (ms)')
            case 3
                xlabel('stimulus presentation time or RT (ms)')
            case 4
                xlabel('inter trial interval time (ms)')
        end
        
        ylabel('Frequency')
        
    end
end