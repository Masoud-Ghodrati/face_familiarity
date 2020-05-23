clear all
close all
clc

% PathData = [cd '\sys6_synth_15_6_KrizhevskyCNN'];
% load class_v3s6.mat
Dir = dir([PathData '\*.mat']);

Run = 5;
Layer = 8;
DownSamp = [3 2 1 1 1 1 1 1];
Category = 8;
NumImg = 250;
NumImgPerCat = 20;

for Lay = 1 : Layer
    % sample data to know the length of feature vector
    load([PathData '\' Dir(1).name])
    
    Data = zeros(Category*NumImg,length(Features{Lay}(1:DownSamp(Lay):end)));
    clear Features
    % data structure
    fprintf('We are loading images, be patient...\n')
    q = 1;
    for cat = 1 : Category
        
        Catind = find(classid==cat,1,'first');
        fprintf([num2str(Catind,'%0.4d') ' Cat# ' num2str(cat) ' : '])
        for imgn = 1 : NumImg
            
            fprintf([num2str(imgn+Catind-1,'%0.4d') ', '])
            load([PathData '\' Dir(imgn+Catind-1).name])
            Data(q,:) = double(Features{Lay}(1:DownSamp(Lay):end));
            q = q + 1;
            
        end
        fprintf('\n')
    end
    clc
    fprintf('\nloading is done! \n')
    fprintf('RDM started... \n')
    
    for NumRun = 1 : Run
        
        XTrain = [];
        for sel_cat = 1 : Category
            
            D = Data((sel_cat-1)*NumImg+1:(sel_cat-1)*NumImg+NumImg,:);
            Rnd= randperm(NumImg);
            XTrain = [XTrain; D(Rnd(1:NumImgPerCat),:)];
        end
        resps3 = XTrain;
        modelFeatures = resps3;
        modelRDM.RDM(:,:,NumRun) = squareRDM(pdist(modelFeatures,'correlation'));
        modelRDM.name = [];
        modelRDM.color = [0 0 0];
        
    end
    RDM{Lay} = modelRDM;
    % visualize the RDM
    modelRDM.RDM = mean(modelRDM.RDM,3);
    showRDMs(modelRDM)
    pause(2)
    close all
    fprintf('\n')
    clear Data
end

save Caffe_RDM.mat RDM
