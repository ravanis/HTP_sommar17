% Returns the HTQ (hot spot SAR to tumor SAR quotient) and maximum SAR in
% tumor, and TC. 
% HTQ is defined as the mean in the top 1 percentile of healthy tissue
% divided by the mean in the tumor.
% TC is the tumor volume cover percentage of 25,50 and 75% of the maximum
% SAR value in healthy tissue.
% Created by JW 01-14

%tissue_filepath='F:\Models\Duke-tumorModels\tissue_files\test_duke_debye_600MHz.txt';

 function [HTQ, SARmaxTum, TC]=getHTQ(TissueMatrix, SARMatrix, tissue_filepath)
 
%----INPUT PARAMETERS----
% TissueMatrix - voxel data tissue matrix
% SARMatrix - Specific Absorption Rate matrix
% NOTE: The SARMatrix and TissueMatrix need to have the same size and
% resolution

[tissueData, tissue_names]=importTissueFile(tissue_filepath);
tumorIndex=find(strcmp('Tumor',tissue_names));
cystTumorIndex=find(strcmp('Cyst-Tumor',tissue_names));
tumorValue=tissueData(tumorIndex,1);
cystTumorValue=tissueData(cystTumorIndex,1);

airIndex=find(~cellfun('isempty',(strfind(lower(tissue_names),'air'))));
waterIndex=find(~cellfun('isempty',(strfind(lower(tissue_names),'water'))));
exteriorIndex=find(~cellfun('isempty',(strfind(lower(tissue_names),'exterior'))));
nonTissueIndeces=[airIndex;waterIndex;exteriorIndex];
nonTissueValues=tissueData(nonTissueIndeces,1);
        
A=SARMatrix;
B=TissueMatrix;
sizeA=size(A);

%Creating 0/1 tumor tissue matrix 

tumorTissue= B== tumorValue;
if ~isempty(cystTumorValue)
     tumorTissue= tumorTissue + (B==cystTumorValue);
end
 
%Creating tumor SAR matrix by multiplying SAR-matrix and tumor tissue matrix
tumorMatrix=tumorTissue.*A;


%Creating 0/1 healthy tissue matrix excluding Tumor and multiplying it with
%SAR matrix

onlyTissue=ones(size(A));
for i=1:length(nonTissueIndeces)
           onlyTissue=onlyTissue.*(TissueMatrix~=nonTissueValues(i)); 
end

healthySARmatrix=A.*onlyTissue.*(tumorMatrix==0);


% ----- Sort and get SARv1 value ------

% Number of elements in the healthy tissue
[rowHEALTHY, ~]=find(healthySARmatrix);

% Reshape healthy matrix to a vector to be able to sort
healthyVector=reshape(healthySARmatrix,sizeA(1).*sizeA(2).*sizeA(3),1);
sortHealthyVector=sort(healthyVector,'descend');
%Create correct length on healthy vector
sortHealthyVector=sortHealthyVector(1:size(rowHEALTHY));

sizeSort=size(sortHealthyVector);
% Calculate SARv1 value
SARv1=mean(sortHealthyVector(1:round(sizeSort(1).*0.01)));

% Sort and get SARtarget value

% Create sorted tumor vector
[rowTUM, ~]=find(tumorMatrix);
tumorVector=reshape(tumorMatrix,sizeA(1).*sizeA(2).*sizeA(3),1);
sortTumorVector=sort(tumorVector,'descend');
tumorVector=sortTumorVector(1:size(rowTUM));
sizeTum=size(tumorVector);
meanSARtarget=mean(tumorVector);

HTQ=SARv1/meanSARtarget;
SARmaxTum=tumorVector(1);

% Tumor coverage
TC(1)=sum(tumorVector>0.25*sortHealthyVector(1))/sizeTum(1); % TC25
TC(2)=sum(tumorVector>0.5*sortHealthyVector(1))/sizeTum(1);  % TC50
TC(3)=sum(tumorVector>0.75*sortHealthyVector(1))/sizeTum(1); % TC75

end
