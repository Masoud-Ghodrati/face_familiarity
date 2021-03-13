clc;
clear all;
close all;
%% Settings
% cats=0; % categories=1 and coh=0
only_answered_trials=1; % all trials=0
only_correct_trials=1; % plus incorrect=0 you should also change the saving file names
only_incorrect_trials=0; % plus correct=0

only_answered_trials2=1; % all trials=0
only_correct_trials2=0; % plus incorrect=0 you should also change the saving file names
only_incorrect_trials2=1; % plus correct=0
% stim_resp=1; % for stim=1, for resp=2
baseline_correction=1;
steps=10;

%% ERPs
subject={'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21'};
sessions=[1 2];
accuracy=nan*ones(21,6,200);
test_on_errors=0;
for region=[1 2 3]
    for stim_resp=[1 2]
        for subj=[1:16 20 21]
            %% First dataset
            if stim_resp==1
                baseline_span=[1:500];
            else
                baseline_span=[300:800];
            end
            load(['Subject_',subject{subj},'_preprosessed.mat']);
            cc=0;
            for counte=[1 2 4 3]
                tmpt=[];
                cc=cc+1;
                if subj==13
                    sessions=1;
                else
                    sessions=[1 2];
                end
                for session=sessions
                    colors=[0 0.45 0.7 1];
                    indx{cc,session}=[Exp_data{1,session}.stim.stimTrain.imageCategory]==counte;
                    if only_answered_trials==1
                        tmp=indx{cc,session};
                        tmp(isnan(Exp_data{1,session}.stim.ResponseData.Values(2,:)))=0;
                        indx{cc,session}=tmp;
                        if only_correct_trials==1
                            tmp=indx{cc,session};
                            tmp(Exp_data{1,session}.stim.ResponseData.Values(2,:)==0)=0;
                            indx{cc,session}=tmp;
                        end
                        if only_incorrect_trials==1
                            tmp=indx{cc,session};
                            tmp(Exp_data{1,session}.stim.ResponseData.Values(2,:)==1)=0;
                            indx{cc,session}=tmp;
                        end
                    end
                    if subj==2 && session==2    % remove bad channels
                        EEG_signals{stim_resp,session}(31,:,:)=0;
                    elseif subj==10 && session==1
                        EEG_signals{stim_resp,session}(7,:,:)=0;
                    elseif subj==11 && session==1
                        EEG_signals{stim_resp,session}(41,:,:)=0;
                        EEG_signals{stim_resp,session}(63,:,:)=0;
                    end
                    tmpt=cat(3,tmpt,EEG_signals{stim_resp,session}(:,:,indx{cc,session}));
                end
                signals{cc}=tmpt;
            end
            
            if baseline_correction
                tt=nanmean([nanmean(nanmean(signals{1,1}(:,baseline_span,:),3),2) nanmean(nanmean(signals{1,2}(:,baseline_span,:),3),2) nanmean(nanmean(signals{1,3}(:,baseline_span,:),3),2) nanmean(nanmean(signals{1,4}(:,baseline_span,:),3),2)],2);
                for i=1:4
                    signals{1,i}=signals{1,i}-repmat(tt,[1 2000 size(signals{1,i},3)]);
                end
            end
            
            % EOG AND M1 are channels #32 and #13 plus non-region remove
            if region==1
                for i=1:4
                    signals{1,i}([1:12 13 14:23 25:27 32 33:49 51:52 58:61],:,:)=[];
                end
            elseif region==2
                for i=1:4
                    signals{1,i}([1:5 7:9 12 13 14:15 17:20 23:25 27:31 32 33:37 40:41 43:44 47:50 53:64],:,:)=[];
                end
            elseif region==3
                for i=1:4
                    signals{1,i}([13 32],:,:)=[];
                end
            end
            % Adding all familiar categories to cond #2
            sizes_signals=[size(signals{1,1},3) size(signals{1,2},3) size(signals{1,3},3) size(signals{1,4},3)];
            signals{1,2}(:,:,end+1:end+size(signals{1,3},3))=signals{1,3};
            signals{1,2}(:,:,end+1:end+size(signals{1,4},3))=signals{1,4};
            signals{1,3}=[];
            signals{1,4}=[];
            
            clearvars -except region test_on_errors sizes_signals accuracy Exp_data baseline_correction EEG_signals subject sessions steps baseline_span signals2 signals subj cats stim_resp only_answered_trials only_correct_trials only_incorrect_trials only_answered_trials2 only_correct_trials2 only_incorrect_trials2
            
            if test_on_errors==1
                %% Second dataset
                cc=0;
                for counte=[1 2 4 3]
                    tmpt=[];
                    cc=cc+1;
                    if subj==13
                        sessions=1;
                    else
                        sessions=[1 2];
                    end
                    for session=sessions
                        colors=[0 0.45 0.7 1];
                        indx{cc,session}=[Exp_data{1,session}.stim.stimTrain.imageCategory]==counte;
                        if only_answered_trials2==1
                            tmp=indx{cc,session};
                            tmp(isnan(Exp_data{1,session}.stim.ResponseData.Values(2,:)))=0;
                            indx{cc,session}=tmp;
                            if only_correct_trials2==1
                                tmp=indx{cc,session};
                                tmp(Exp_data{1,session}.stim.ResponseData.Values(2,:)==0)=0;
                                indx{cc,session}=tmp;
                            end
                            if only_incorrect_trials2==1
                                tmp=indx{cc,session};
                                tmp(Exp_data{1,session}.stim.ResponseData.Values(2,:)==1)=0;
                                indx{cc,session}=tmp;
                            end
                        end
                        if subj==2 && session==2    % remove bad channels
                            EEG_signals{stim_resp,session}(31,:,:)=0;
                        elseif subj==10 && session==1
                            EEG_signals{stim_resp,session}(7,:,:)=0;
                        elseif subj==11 && session==1
                            EEG_signals{stim_resp,session}(41,:,:)=0;
                            EEG_signals{stim_resp,session}(63,:,:)=0;
                        end
                        tmpt=cat(3,tmpt,EEG_signals{stim_resp,session}(:,:,indx{cc,session}));
                    end
                    signals2{cc}=tmpt;
                end
                
                if baseline_correction
                    tt=nanmean([nanmean(nanmean(signals2{1,1}(:,baseline_span,:),3),2) nanmean(nanmean(signals2{1,2}(:,baseline_span,:),3),2) nanmean(nanmean(signals2{1,3}(:,baseline_span,:),3),2) nanmean(nanmean(signals2{1,4}(:,baseline_span,:),3),2)],2);
                    for i=1:4
                        signals2{1,i}=signals2{1,i}-repmat(tt,[1 2000 size(signals2{1,i},3)]);
                    end
                end                
                
                % EOG AND M1 are channels #32 and #13 plus non-region remove
                if region==1
                    for i=1:4
                        signals2{1,i}([1:12 13 14:23 25:27 32 33:49 51:52 58:61],:,:)=[];
                    end
                elseif region==2
                    for i=1:4
                        signals2{1,i}([1:5 7:9 12 13 14:15 17:20 23:25 27:31 32 33:37 40:41 43:44 47:50 53:64],:,:)=[];
                    end
                elseif region==3
                    for i=1:4
                        signals2{1,i}([13 32],:,:)=[];
                    end
                end
                % Adding all familiar categories to cond #2
                sizes_signals=[size(signals2{1,1},3) size(signals2{1,2},3) size(signals2{1,3},3) size(signals2{1,4},3)];
                signals2{1,2}(:,:,end+1:end+size(signals2{1,3},3))=signals2{1,3};
                signals2{1,2}(:,:,end+1:end+size(signals2{1,4},3))=signals2{1,4};
                signals2{1,3}=[];
                signals2{1,4}=[];
                clearvars -except region test_on_errors sizes_signals accuracy subject sessions steps baseline_span baseline_correction signals signals2 subj cats stim_resp only_answered_trials only_correct_trials only_incorrect_trials only_answered_trials2 only_correct_trials2 only_incorrect_trials2
                %% SVM
                cond1=1;
                cond2=2;
                time=0;
                for tws=1:steps:2000-steps
                    tw=tws:tws+steps;
                    time=time+1;
                    [~,bigger_class_tr]=max([size(signals{1,cond1},3) size(signals{1,cond2},3)]);
                    [~,bigger_class_ts]=max([size(signals2{1,cond1},3) size(signals2{1,cond2},3)]);
                    for iter=1:10
                        if bigger_class_tr==2
                            t_inds_bigger_class=randsample([1:size(signals{1,cond2},3)],size(signals{1,cond1},3));
                            X1=[squeeze(mean(signals{1,cond1}(:,tw,:),2))';squeeze(mean(signals{1,cond2}(:,tw,t_inds_bigger_class),2))'];
                            y1=[ones(size(squeeze(signals{1,cond1}(:,tws,:))',1),1);zeros(size(squeeze(signals{1,cond1}(:,tws,:))',1),1)];
                        else
                            t_inds_bigger_class=randsample([1:size(signals{1,cond1},3)],size(signals{1,cond2},3));
                            X1=[squeeze(mean(signals{1,cond1}(:,tw,t_inds_bigger_class),2))';squeeze(mean(signals{1,cond2}(:,tw,:),2))'];
                            y1=[ones(size(squeeze(signals{1,cond2}(:,tws,:))',1),1);zeros(size(squeeze(signals{1,cond2}(:,tws,:))',1),1)];
                        end
                        
                        SVMModel = fitcsvm(X1,y1);
                        
                        X2=[squeeze(mean(signals2{1,cond1}(:,tw,:),2))';squeeze(mean(signals2{1,cond2}(:,tw,:),2))'];
                        y2=[ones(size(squeeze(signals2{1,cond1}(:,tws,:))',1),1);zeros(size(squeeze(signals2{1,cond2}(:,tws,:))',1),1)];

                        [label,~] = predict(SVMModel,X2);

                        % Unfamiliar vs Familiar
                        tmp(1,iter)=sum(label==y2)./length(label);
                        
                        % Unfamiliar and Familiar separately
                        tmp(2,iter)=sum(label(1:size(squeeze(signals2{1,cond1}(:,tws,:))',1))==y2(1:size(squeeze(signals2{1,cond1}(:,tws,:))',1)))./size(squeeze(signals2{1,cond1}(:,tws,:))',1);
                        tmp(3,iter)=sum(label(size(squeeze(signals2{1,cond1}(:,tws,:))',1)+1:end)==y2(size(squeeze(signals2{1,cond1}(:,tws,:))',1)+1:end))./size(squeeze(signals2{1,cond2}(:,tws,:))',1);
                        
                        % Familiar categories in order: Famous, Familiar, Self
                        tmp(4,iter)=sum(label(sizes_signals(1)+1:sizes_signals(1)+sizes_signals(2))==y2(sizes_signals(1)+1:sizes_signals(1)+sizes_signals(2)))./sizes_signals(2);
                        tmp(5,iter)=sum(label(sizes_signals(1)+sizes_signals(2)+1:sizes_signals(1)+sizes_signals(2)+sizes_signals(3))==y2(sizes_signals(1)+sizes_signals(2)+1:sizes_signals(1)+sizes_signals(2)+sizes_signals(3)))./sizes_signals(3);
                        tmp(6,iter)=sum(label(sizes_signals(1)+sizes_signals(2)+sizes_signals(3)+1:sizes_signals(1)+sizes_signals(2)+sizes_signals(3)+sizes_signals(4))==y2(sizes_signals(1)+sizes_signals(2)+sizes_signals(3)+1:sizes_signals(1)+sizes_signals(2)+sizes_signals(3)+sizes_signals(4)))./sizes_signals(4);
                        
                    end
                    [test_on_errors region stim_resp subj time]
                    accuracy(subj,:,time)=squeeze(nanmean(tmp,2));
                end
                if stim_resp==1
                    save(['st_Decoding_fam_unfam_tr_cor_ts_incor_baselined_windowed_region_',num2str(region),'_v5.mat'],'accuracy');
                else
                    save(['rp_Decoding_fam_unfam_tr_cor_ts_incor_baselined_windowed_region_',num2str(region),'_v5.mat'],'accuracy');
                end
            else
                %% SVM
                cond1=1;
                cond2=2;
                time=0;
                for tws=1:steps:2000-steps
                    tw=tws:tws+steps;
                    time=time+1;
                    
                    X=[squeeze(mean(signals{1,cond1}(:,tw,:),2))';squeeze(mean(signals{1,cond2}(:,tw,:),2))'];
                    y=[ones(size(squeeze(signals{1,cond1}(:,tws,:))',1),1);zeros(size(squeeze(signals{1,cond2}(:,tws,:))',1),1)];
                    for iter=1:10
                        tr_inds=randsample([1:size(X,1)],fix(size(X,1)*0.8));
                        ts_inds_bigger_class=[1:size(X,1)];
                        ts_inds_bigger_class(tr_inds)=[];
                        X1=X(tr_inds,:);
                        y1=y(tr_inds);
                        SVMModel = fitcsvm(X1,y1);
                        X2=X(ts_inds_bigger_class,:);
                        y2=y(ts_inds_bigger_class);
                        [label,~] = predict(SVMModel,X2);

                       
                        inds_tst1=ones(1,length(ts_inds_bigger_class));
                        inds_tst2=(ts_inds_bigger_class<sizes_signals(1)+1);
                        inds_tst3=(ts_inds_bigger_class>sizes_signals(1));
                        inds_tst4=(ts_inds_bigger_class>sizes_signals(1) & ts_inds_bigger_class<sizes_signals(1)+sizes_signals(2)+1);
                        inds_tst5=(ts_inds_bigger_class>sizes_signals(1)+sizes_signals(2) & ts_inds_bigger_class<sizes_signals(1)+sizes_signals(2)+sizes_signals(3)+1);
                        inds_tst6=(ts_inds_bigger_class>sizes_signals(1)+sizes_signals(2)+sizes_signals(3)+1 & ts_inds_bigger_class<sizes_signals(1)+sizes_signals(2)+sizes_signals(3)+sizes_signals(4)+1);
                        
                        % Unfamiliar vs Familiar
                        tmp(1,iter)=sum(label(inds_tst1)==y2(inds_tst1))./sum(inds_tst1);
                        
                        % Unfamiliar and Familiar separately
                        tmp(2,iter)=sum(label(inds_tst2)==y2(inds_tst2))./sum(inds_tst2);
                        tmp(3,iter)=sum(label(inds_tst3)==y2(inds_tst3))./sum(inds_tst3);
                        
                        % Familiar categories in order: Famous, Familiar, Self
                        tmp(4,iter)=sum(label(inds_tst4)==y2(inds_tst4))./sum(inds_tst4);
                        tmp(5,iter)=sum(label(inds_tst5)==y2(inds_tst5))./sum(inds_tst5);
                        tmp(6,iter)=sum(label(inds_tst6)==y2(inds_tst6))./sum(inds_tst6);
                        [test_on_errors region stim_resp subj time]
                    end
                    accuracy(subj,:,time)=squeeze(nanmean(tmp,2));
                end
                
                if stim_resp==1
                    save(['st_Decoding_fam_unfam_tr_cor_ts_cor_baselined_windowed_region_',num2str(region),'_v2.mat'],'accuracy');
                else
                    save(['rp_Decoding_fam_unfam_tr_cor_ts_cor_baselined_windowed_region_',num2str(region),'_v2.mat'],'accuracy');
                end
            end
        end
    end
end
