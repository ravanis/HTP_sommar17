% Returns the HTQ (hot spot PLD to tumor PLD quotient) and maximum PLD in
% tumor, and TC. 
% HTQ is defined as the mean in the top 1 percentile of healthy tissue
% divided by the mean in the tumor.
% TC is the tumor volume cover percentage of 25,50 and 75% of the maximum
% PLD value in healthy tissue.
% To find PLDmaxTum from PLDmaxTum, divide with rho

% Created by JW 01-14

 function [HTQ, PLDmaxTum, TC]=getHTQ(TissueMatrix, PLD, modelType)
 
%----INPUT PARAMETERS----
% TissueMatrix - voxel data tissue matrix
% PLD - Power Loss Density matrix, it is also possible to use a PLD matrix
% NOTE: The PLD and TissueMatrix need to have the same size and
% resolution

filename = which('find_settings');
[scriptpath,~,~] = fileparts(filename);
datapath = [scriptpath filesep '..' filesep 'Data' filesep];

if startsWith(lower(modelType), 'duke') == 1
    tissue_filepath = ([datapath 'df_duke_neck_cst_400MHz.txt']);
elseif strcmpi(modelType,'child')
    tissue_filepath = ([datapath 'df_chHead_cst_400MHz.txt']);
else
    error('Assumed to retrieve indices for frequency 400 MHz (no matter which frequency you use), the tissuefile for this frequency is missing.')
end

[tissueData, tissue_names]=importTissueFile(tissue_filepath);

nonTissueValues=[];
tumorValue=[];
cystTumorValue=[];

for i=1:length(tissue_names)
    
    tissue_name=tissue_names{i};
    tissue_name=tissue_name(~isspace(tissue_name));
    
    if strcmpi('Tumor',tissue_name)
        tumorValue=tissueData(i,1);
    elseif strcmpi('Cyst-Tumor',tissue_name)
        cystTumorValue=tissueData(i,1);
    elseif contains(lower(tissue_name),'air')
        nonTissueValues=[nonTissueValues tissueData(i,1)];
    elseif contains(lower(tissue_name),'water')
        nonTissueValues=[nonTissueValues tissueData(i,1)];
    end
    
end        

A=PLD;
B=TissueMatrix;
sizeA=size(A);

%Creating 0/1 tumor tissue matrix 

tumorTissue= B == tumorValue;
if ~isempty(cystTumorValue)
     tumorTissue= tumorTissue + (B==cystTumorValue);
end
 
%Creating tumor PLD matrix by multiplying PLD-matrix and tumor tissue matrix
tumorMatrix=tumorTissue.*A;


%Creating 0/1 healthy tissue matrix excluding Tumor and multiplying it with
%PLD matrix

onlyTissue=ones(size(A));
for i=1:length(nonTissueValues)
           onlyTissue=onlyTissue.*(TissueMatrix~=nonTissueValues(i)); 
end

healthyPLD=A.*onlyTissue.*(tumorMatrix==0);


% ----- Sort and get PLDv1 value ------

% Number of elements in the tissue
[rowTissue, ~]=find(PLD);

% Reshape PLD matrix to a vector to be able to sort
PLD_vec=reshape(PLD,sizeA(1).*sizeA(2).*sizeA(3),1);
sortPLD_vec=sort(PLD_vec,'descend');
%Create correct length on healthy vector
sortPLD_vec=sortPLD_vec(1:size(rowTissue));

% Number of elements in the healthy tissue
[rowHealthyTissue, ~]=find(healthyPLD);

% Reshape healthy PLD matrix to a vector to be able to sort
healthyPLD_vec=reshape(healthyPLD,sizeA(1).*sizeA(2).*sizeA(3),1);
sortHealthyPLD_vec=sort(healthyPLD_vec,'descend');
%Create correct length on healthy vector
sortHealthyPLD_vec=sortHealthyPLD_vec(1:size(rowHealthyTissue));

% Calculate PLDv1 value
PLDv1=mean(sortHealthyPLD_vec(1:round(length(sortHealthyPLD_vec).*0.01)));

% Create sorted tumor vector
[rowTUM, ~]=find(tumorMatrix);
tumorVector=reshape(tumorMatrix,sizeA(1).*sizeA(2).*sizeA(3),1);
sortTumorVector=sort(tumorVector,'descend');
tumorVector=sortTumorVector(1:length(rowTUM));
meanPLDtarget=mean(tumorVector);

HTQ=PLDv1/meanPLDtarget;
PLDmaxTum=tumorVector(1);

% Tumor coverage
TC(1)=sum(tumorVector>0.25*sortPLD_vec(1))/length(tumorVector); % TC25
TC(2)=sum(tumorVector>0.5*sortPLD_vec(1))/length(tumorVector);  % TC50
TC(3)=sum(tumorVector>0.75*sortPLD_vec(1))/length(tumorVector); % TC75

end
