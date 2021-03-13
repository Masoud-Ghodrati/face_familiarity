clc;
clear all;
close all


samples_sizes=[100,200,300,200]; % the number of time samples in each phase
% (time windows) of the time series
num_conditions=16; % RDM size
Num_unq_RDM_cells=(num_conditions*num_conditions-num_conditions)./2;

RDM_initial=nan*ones(Num_unq_RDM_cells,max(samples_sizes),2);

for time=1:max(samples_sizes)
    
    desired_RDM={'A','A','B','B','A','A','B','B','A','A','B','B','A','A','B','B',};
    X_task=nan*ones(num_conditions);
    
    for i=1:num_conditions
        for j=i+1:num_conditions
            if strcmp(desired_RDM{i},desired_RDM{j})==1
                X_task(i,j)=1;
            else
                X_task(i,j)=0;
            end
        end
    end
    Model_RDM_1=X_task(~isnan(X_task));
    Model_RDM_2=Model_RDM_1;
end
%% Imposing RDM dynamics
method=1;
Model_rdm=Model_RDM_1;
lags=300;
iterations=1;

noises_source=[100*ones(1,900) [100:-0.25:50] [50:0.25:100] 100*ones(1,1000)]./10000;
noises_destin=circshift(noises_source,lags);

% generating the RDM time series
for noise_level=lags+1:length(noises_source)
    for iteration=1:iterations
        noise_level_source=noises_source(noise_level);
        noise_level_destin=noises_destin(noise_level);
        
        inds_p=(Model_RDM_2==1);
        inds_z=(Model_RDM_2==0);
        Source_rdm(inds_p,noise_level,iteration)=Model_RDM_2(inds_p)-randi([0 100],[sum(inds_p==1) 1]).*noise_level_source;
        Source_rdm(inds_z,noise_level,iteration)=Model_RDM_2(inds_z)+randi([0 100],[sum(inds_z==1) 1]).*noise_level_source;
        
        inds_p=(Model_RDM_1==1);
        inds_z=(Model_RDM_1==0);
        Destin_rdm(inds_p,noise_level,iteration)=Model_RDM_1(inds_p)-randi([0 100],[sum(inds_p==1) 1]).*noise_level_destin;
        Destin_rdm(inds_z,noise_level,iteration)=Model_RDM_1(inds_z)+randi([0 100],[sum(inds_z==1) 1]).*noise_level_destin;
        
        Srce_model=corr(Model_rdm,Source_rdm(:,noise_level,iteration),'type','spearman');
        Destin_model=corr(Model_rdm,Destin_rdm(:,noise_level,iteration),'type','spearman');
        parCorrForw=partialcorr(Model_rdm,Destin_rdm(:,noise_level,iteration),Source_rdm(:,noise_level-lags,iteration),'type','spearman');
        parCorrBack=partialcorr(Model_rdm,Source_rdm(:,noise_level,iteration),Destin_rdm(:,noise_level-lags,iteration),'type','spearman');
                
        Results(noise_level,:,iteration)=[Srce_model Destin_model parCorrForw parCorrBack];
    end
end

%% Plots
xlow=600;
xhigh=length(noises_source);
smoothing=10;
subplot(411)
plot([1:xhigh],smooth(nanmean(Results(:,1,:),3),smoothing),'linewidth',1.5,'color','k')
xlim([xlow xhigh])
title({'Source Information Coding (correlation to model)'})
set(gca,'FontSize',10,'TickDir','out','LineWidth',1,'XTick',...
    [700:300:3300],'XTickLabel',{},'xcolor','k','xgrid','on');
box off;

subplot(412)
plot([1:xhigh],smooth(nanmean(Results(:,2,:),3),smoothing),'linewidth',1.5,'color','k')
xlim([xlow xhigh])
title({'Destination Information Coding (correlation to model)'})
set(gca,'FontSize',10,'TickDir','out','LineWidth',1,'XTick',...
    [700:300:3300],'XTickLabel',{},'xcolor','k','xgrid','on');
box off;

subplot(413)
plot([1:xhigh],smooth(nanmean(Results(:,2,:),3)-nanmean(Results(:,3,:),3),smoothing),'linewidth',1.5,'color',[0.8 0.3 0.2])
hold on;
plot([1:xhigh],smooth(nanmean(Results(:,1,:),3)-nanmean(Results(:,4,:),3),smoothing),'linewidth',1.5,'color',[0.2 0.3 0.8])
xlim([xlow xhigh])
title({'Information Flow (change in correlation)'})
legend('Forward','Backward','orientation','horizontal','location','southwest')
legend boxoff
ylim([-0.3 0.3])
set(gca,'FontSize',10,'TickDir','out','LineWidth',1,'XTick',...
    [700:300:3300],'XTickLabel',{},'xcolor','k','xgrid','on');
box off;

subplot(414)
plot([1:xhigh],smooth([nanmean(Results(:,2,:),3)-nanmean(Results(:,3,:),3)]-[nanmean(Results(:,1,:),3)-nanmean(Results(:,4,:),3)],smoothing),'linewidth',1.5,'color',[0.5 0.3 0.5])
xlim([xlow xhigh])
title({'Direction of Information Flow (forward-backward)'})
xlabel('Time sample')
ylim([-0.3 0.3])
box off;
set(gca,'FontSize',10,'TickDir','out','LineWidth',1,'XTick',...
    [700:300:3300],'XTickLabel',{num2str([[100:300:2700]]')},'xcolor','k','xgrid','on');

