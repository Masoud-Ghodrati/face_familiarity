% the refRDM has to be changed for other comparisons =>..
function [pvalue, bootstrapStats] = calcBootstrap(brainRDM,modelRDM)



modelRDMs_cell = {modelRDM};
refRDM = brainRDM;


userOptions.RDMcorrelationType='Kendall_taua';
userOptions.nBootstrap = 10000;
userOptions.candRDMdifferencesTest = 'conditionRFXbootstrap';
userOptions.candRDMdifferencesMultipleTesting = 'FDR';
userOptions.candRDMdifferencesThreshold = 0.05;

%% create refRDM_stack and meanCandRDMs

candRDMs = modelRDMs_cell;

refRDM_stack = stripNsquareRDMs(refRDM);
[nCond,nCond,nRefRDMinstances]=size(refRDM_stack);

if isstruct(refRDM)
    if isfield(refRDM,'name')
        refRDMName = refRDM.name;
    end
end
refRDMmask = ~any(isnan(refRDM_stack),3)|logical(eye(nCond)); % valid dissimilarities in the reference RDM
if any(~refRDMmask(:))
    nNaN_ref = numel(find(refRDMmask == 0));
    fprintf('Found %d NaNs in the reference RDM input. \n',nNaN_ref)
    fprintf('...excluding the entries from the analysis \n')
end
% collect the RDM labels in one cell array. also give names to unnamed
% RDMs.
unnamedI=1;
for candI = 1:numel(candRDMs)
    if isstruct(candRDMs{candI})
        try
            thisCand=candRDMs{candI};
            candidateNames{candI} = thisCand.name;
        catch
            candidateNames{candI} = ['unnamed RDM',num2str(unnamedI)];
            unnamedI = unnamedI + 1;
        end
    else
        candidateNames{candI} = ['unnamed RDM',num2str(unnamedI)];
        unnamedI = unnamedI + 1;
    end
    candRDM_stack{candI} = double(stripNsquareRDMs(candRDMs{candI}));
    meanCandRDMs(:,:,candI)= mean(candRDM_stack{candI},3);
    nsCandRDMinstances(candI)=size(candRDM_stack{candI},3);
end

candRDMmask = ~any(isnan(meanCandRDMs),3)|logical(eye(nCond));  % valid dissimilarities in all candidate RDMs

RDMmask = refRDMmask & candRDMmask; % valid dissimilarities in all RDMs
nValidDissimilarities=sum(RDMmask(:));

% find the indices for the non-NaN entries
% validConds = any(~(RDMmask&logical(eye(nCond))),1);%~any(~(RDMmask|logical(eye(nCond))),1));
validConds1 = zeros(1,nCond);
for i = 1: nCond
    if ~(sum(RDMmask(i,:)) -1 == 0) % minuse one is becuase of the diagonal which is always one irregardless of ...
        validConds1(i) =  i;
    end
end
counter = 1;
for i =1:nCond
    if validConds1(i) ~= 0
        validConds(counter) = validConds1(i);
        counter = counter +1;
    end
end

% reduce the condition set in both reference and candidate RDM stacks to
% locations where there are no NaNs only
refRDM_stack = refRDM_stack(validConds,validConds,:);

meanRefRDM = mean(refRDM_stack,3);

clear meanCandRDMs
for candI = 1:numel(candRDM_stack)
    temp=candRDM_stack{candI};
    candRDM_stack{candI}= temp(validConds,validConds,:);
    meanCandRDMs(:,:,candI) = mean(candRDM_stack{candI},3);
end

%%
fprintf('Performing condition bootstrap test comparing candidate RDMs.\n');
userOptions.resampleSubjects=0;userOptions.resampleConditions=1;
[realRs bootstrapEs pairwisePs bootstrapRs] = bootstrapRDMs(refRDM_stack, meanCandRDMs, userOptions);

% bootstrapStats.realRS = realRs;
bootstrapStats.bootstrapEs=bootstrapEs;
% bootstrapStats.pairwisePs=pairwisePs;
bootstrapStats.bootstrapRs = bootstrapRs;

pvalue = 1 - sum(bootstrapRs > 0)/length(bootstrapRs);

end