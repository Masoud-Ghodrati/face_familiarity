clc;
% close all;
clear all;

for region=3 % 1=peri-occipital; 2=peri-frontal and 3=whole head
    for stim_resp=1:2 % stimulus(1)/response(2)-aligned 
        % region=2;
        % stim_resp=2;
        
        if stim_resp==1
            xplot=[-100:10:600];
            span=[40:110];
        else
            xplot=[-600:10:100];
            span=[90:160];
        end
        
        
        subject={'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','20','21'};
        noises=[0.22 0.3 0.45 0.55];
        
        c=0;
        corr_Dec_Beh_acc=nan*ones(21,71);
        corr_Dec_Beh_acc_upper=nan*ones(21,71);
        corr_Dec_Beh_acc_lower=nan*ones(21,71);
        corr_Dec_Beh_acc_random=nan*ones(21,71,10000);
        decoding_accuracies=nan*ones(21,16,71);
        Acc_cat=nan*ones(21,16);
        
        for subj=[1:16 20 21]
            c=c+1;
            load(['Subject_',subject{c},'_preprosessed.mat'],'Exp_data','chan_locations');
            t=0;
            for time=span
                t=t+1;
                for coh=1:4
                    if stim_resp==1
                        load(['st_Decoding_famCat_unfam_tr_cor_ts_cor_baselined_windowed_region_',num2str(region),'_Coh',num2str(noises(coh)),'.mat']);
                    else
                        load(['rp_Decoding_famCat_unfam_tr_cor_ts_cor_baselined_windowed_region_',num2str(region),'_Coh',num2str(noises(coh)),'.mat']);
                    end

                    decoding_accuracies(subj,(coh-1)*4+1:coh*4,t)=[nanmean(accuracy(subj,2,:,time),3);squeeze(accuracy(subj,1,:,time))]';
                    
                    for cat=1:4
                        if isempty(Exp_data{1,1})==0
                            ids1=([Exp_data{1,1}.stim.ResponseData.Values(5,:)==cat & Exp_data{1,1}.stim.ResponseData.Values(4,:)==noises(coh)]);
                        end
                        if isempty(Exp_data{1,2})==0 && ~isempty(Exp_data{1,2})
                            ids2=([Exp_data{1,2}.stim.ResponseData.Values(5,:)==cat & Exp_data{1,2}.stim.ResponseData.Values(4,:)==noises(coh)]);
                        end
                        if ~isempty(Exp_data{1,2})
                            Acc_cat(subj,(coh-1)*4+cat)=nanmean([Exp_data{1,1}.stim.ResponseData.Values(2,ids1) Exp_data{1,2}.stim.ResponseData.Values(2,ids2)]);
                        else
                            Acc_cat(subj,(coh-1)*4+cat)=nanmean([Exp_data{1,1}.stim.ResponseData.Values(2,ids1)]);
                        end
                    end
                end
                corr_Dec_Beh_acc(subj,t)=corr(decoding_accuracies(subj,:,t)',Acc_cat(subj,:)','type','spearman');
                %         corr_Dec_Beh_RT(subj,d)=corr(decoding_accuracies',nanmean(RT_cat,2));
                
                
                for randomization=1:10000
                    corr_Dec_Beh_acc_randoms(subj,t,randomization)=corr(decoding_accuracies(subj,:,t)',randsample(Acc_cat(subj,:),length(Acc_cat(subj,:)))','type','spearman');
                end
                [region stim_resp subj t]
            end
        end
        t=0;
        for time=span
            t=t+1;
            for subj=[1:16 20 21]
                inds_not_this=[1:16 20 21];
                inds_not_this(inds_not_this==subj)=[];
                corr_Dec_Beh_acc_upper(subj,t)=corr(decoding_accuracies(subj,:,t)',nanmean(Acc_cat)','type','spearman');
                corr_Dec_Beh_acc_lower(subj,t)=corr(decoding_accuracies(subj,:,t)',nanmean(Acc_cat(inds_not_this,:))','type','spearman');
            end
        end
        
        figure;
        plot(xplot,nanmean(corr_Dec_Beh_acc))
        hold on;
        plot(xplot,nanmean(corr_Dec_Beh_acc_upper))
        plot(xplot,nanmean(corr_Dec_Beh_acc_lower))
        
        significant=nan*ones(1,71);
        t=0;
        for time=1:size(corr_Dec_Beh_acc,2)
            t=t+1;
            if sum(nanmean(corr_Dec_Beh_acc(:,t))>nanmean(corr_Dec_Beh_acc_randoms(:,t,:)))>9500
                significant(t)=1;
            end
        end
        plot(xplot,significant*0.0001,'*')
        if stim_resp==1
            save(['st_aligned_Correlation_Betw_Decoding_Behaviour_v2_region_',num2str(region),'.mat'],'corr_Dec_Beh_acc','corr_Dec_Beh_acc_upper','corr_Dec_Beh_acc_lower','significant');
        else
            save(['rp_aligned_Correlation_Betw_Decoding_Behaviour_v2_region_',num2str(region),'.mat'],'corr_Dec_Beh_acc','corr_Dec_Beh_acc_upper','corr_Dec_Beh_acc_lower','significant');
        end
    end
end

%% 

for region=3
    for stim_resp=2
        
        if stim_resp==1
            xplot=[-100:10:600];
            span=[40:110];
        else
            xplot=[-600:10:100];
            span=[90:160];
        end
        if stim_resp==1
            load(['st_aligned_Correlation_Betw_Decoding_Behaviour_v2_region_',num2str(region),'.mat'],'corr_Dec_Beh_acc','corr_Dec_Beh_acc_upper','corr_Dec_Beh_acc_lower','significant');
        else
            load(['rp_aligned_Correlation_Betw_Decoding_Behaviour_v2_region_',num2str(region),'.mat'],'corr_Dec_Beh_acc','corr_Dec_Beh_acc_upper','corr_Dec_Beh_acc_lower','significant');
        end        
        
        figure;
        plot(xplot,nanmean(corr_Dec_Beh_acc))
        hold on;
        
        significant=nan*ones(1,71);
        t=0;
        for time=1:size(corr_Dec_Beh_acc,2)
            t=t+1;
            if sum(nanmean(corr_Dec_Beh_acc(:,t))>nanmean(corr_Dec_Beh_acc_randoms(:,t,:)))>9500
                significant(t)=1;
            end
        end
        plot(xplot,significant*0.0001,'*')

    end
end
