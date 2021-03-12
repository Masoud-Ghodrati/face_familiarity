clc;
close all;
clear all;
%% Settings
cats=1; % categories=1 and noise_levels=0
only_answered_trials=1; % all trials=0
only_correct_trials=1; % plus incorrect=0
stim_resp=2; % for stim=1, for resp=2
baseline_correction=1; % 1=on; 0=off
if stim_resp==1
    epoch_span=[-500 1499]; %for stimulus aligned
    baseline_span=[1:500];
    xlimits=[-500 1000];
else
    epoch_span=[-1499 500]; %for response aligned
    baseline_span=[300:800];
    xlimits=[-1000 500];
end

%% ERPs
subject={'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21'};
subjs=[1:16 20 21];      % subj #
sessions=1:2;
cc=0;
coherence_level=0.55;
if cats==1
    for counte=[1 2 4 3]
        colors=[0 0.45 0.7 1];
        cc=cc+1;
        signals=nan.*ones(length(subject),64,2000);
        tt=nan.*ones(2,64,2000);
        for subj=subjs
            if subj==3
                sessions=1;
            end
            for session=sessions
                load(['Subject_',subject{subj},'_preprosessed.mat']);
                if isempty(Exp_data{1,session})==0
                    indx{cc,session}=([[Exp_data{1,session}.stim.stimTrain.imageCategory]==counte & [Exp_data{1, session}.stim.stimTrain.imageNoise]==coherence_level]);
                    if only_answered_trials==1
                        tmp=indx{cc,session};
                        tmp(isnan(Exp_data{1,session}.stim.ResponseData.Values(2,:)))=0;
                        indx{cc,session}=tmp;
                        if only_correct_trials==1
                            tmp=indx{cc,session};
                            tmp(Exp_data{1,session}.stim.ResponseData.Values(2,:)==0)=0;
                            indx{cc,session}=tmp;
                        end
                    end
                    if subj==2 && session==2
                        EEG_signals{stim_resp,session}(31,:,:)=nan;
                    elseif subj==10 && session==1
                        EEG_signals{stim_resp,session}(7,:,:)=nan;
                    elseif subj==11 && session==1
                        EEG_signals{stim_resp,session}(41,:,:)=nan;
                        EEG_signals{stim_resp,session}(63,:,:)=nan;
                    end
                    tt(session,1:64,:)=squeeze(nanmean(EEG_signals{stim_resp,session}(:,:,indx{cc,session}),3));
                end
            end
            signals(subj,1:64,:)=nanmean(tt);
            if baseline_correction
                signals(subj,1:64,:)=squeeze(signals(subj,1:64,:))-repmat(squeeze(mean(signals(subj,:,baseline_span),3))',[1 2000]);
            end
        end
        ff(:,:,:,cc)=signals;
        clearvars signals
    end
    X_difference=squeeze(nanmean(ff(:,:,:,1),1))-squeeze(nanmean(nanmean(ff(:,:,:,2:4),1),4));
    X_difference([13 34],:)=[];
    save('X.mat','X_difference');
    eeglab
    ccc
    for ch=0:8:56
        figure;
        c=0;
        for chf=ch+1:ch+8
            c=c+1;
            for cc=1:4
                subplot(2,4,c);
                plot([epoch_span(1):epoch_span(2)],smooth(squeeze(nanmean(ff(:,chf,:,cc))),20),'Color',[0.8 0.2 1]*colors(cc),'LineWidth',1.5);
                hold on;
            end
            line([epoch_span(1) epoch_span(2)],[0 0]);
            line([0 0],[-5 5]);
            xlim([xlimits(1) xlimits(2)]);
            %         ylim([-20 20]);
            xlabel('Time [ms]');
            ylabel('Amplitude [uv]');
            title(chan_locations{1,1}{chf,1})
        end
    end
else
    for counte=[0.22 0.3 0.45 0.55]
        colors=[0 0.45 0.7 1];
        cc=cc+1;
        signals=nan.*ones(length(subject),64,2000);
        tt=nan.*ones(2,64,2000);
        for subj=subjs
            if subj==3
                sessions=1;
            end
            for session=sessions
                load(['Subject_',subject{subj},'_preprosessed.mat']);
                if isempty(Exp_data{1,session})==0
                    indx{cc,session}=[Exp_data{1,session}.stim.stimTrain.imageNoise]==counte;
                    if only_answered_trials==1
                        tmp=indx{cc,session};
                        tmp(isnan(Exp_data{1,session}.stim.ResponseData.Values(2,:)))=0;
                        indx{cc,session}=tmp;
                        if only_correct_trials==1
                            tmp=indx{cc,session};
                            tmp(Exp_data{1,session}.stim.ResponseData.Values(2,:)==0)=0;
                            indx{cc,session}=tmp;
                        end
                    end
                    if subj==2 && session==2
                        EEG_signals{stim_resp,session}(31,:,:)=nan;
                    elseif subj==10 && session==1
                        EEG_signals{stim_resp,session}(7,:,:)=nan;
                    elseif subj==11 && session==1
                        EEG_signals{stim_resp,session}(41,:,:)=nan;
                        EEG_signals{stim_resp,session}(63,:,:)=nan;
                    end
                    tt(session,1:64,:)=squeeze(nanmean(EEG_signals{stim_resp,session}(:,:,indx{cc,session}),3));
                end
            end
            signals(subj,1:64,:)=nanmean(tt);
            if baseline_correction
                signals(subj,1:64,:)=squeeze(signals(subj,1:64,:))-repmat(squeeze(mean(signals(subj,:,baseline_span),3))',[1 2000]);
            end
        end
        ff(:,:,:,cc)=signals;
        clearvars signals
    end
    for ch=0:8:56
        figure;
        c=0;
        for chf=ch+1:ch+8
            c=c+1;
            for cc=1:4
                subplot(2,4,c);
                plot([epoch_span(1):epoch_span(2)],smooth(squeeze(nanmean(ff(:,chf,:,cc))),20),'Color',[1 0.2 0.8]*colors(cc),'LineWidth',1.5);
                hold on;
            end
            line([epoch_span(1) epoch_span(2)],[0 0]);
            line([0 0],[-5 5]);
            xlim([xlimits(1) xlimits(2)]);
            %         ylim([-20 20]);
            xlabel('Time [ms]');
            ylabel('Amplitude [uv]');
            title(chan_locations{1,1}{chf,1})
        end
    end
end

if cats==1
    legend ('Control','Famous','Familiar','Self','Location','southeast');
else
    legend ('Coherence = 0.22','Coherence = 0.33','Coherence = 0.45','Coherence = 0.55','Location','southeast');
end
