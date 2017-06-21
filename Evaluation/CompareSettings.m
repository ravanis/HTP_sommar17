% Compares settings derived from optimization to those from time reversal

%------- INPUT PARAM -------

modelType='duke_tongue';

freq=450; % Frequency in MHz

isSingle=1; % Boolean that states if there is only one frequency

% Path to result location
resultPath=['D:' filesep 'KandFFT' filesep 'Results' filesep num2str(freq) 'MHz' filesep];

numAnts=16; % Number of antennas

% Absolute path to optimization settings ends with .txt
settingPath1='';

% Absolute path to time reversal settings ends with .txt
settingPath2=['D:' fileSep 'KandFFT' filesep 'Results' 'KandFFT' filesep...
    'Results' filesep 'TimeReversal' filesep ];

%---------------------------

% reads settings

[settings1, timeShare1] = readSettings( settingPath1, isSingle );

[settings2, timeShare2] = readSettings( settingPath2, isSingle );

% loads tissue matrix

tissue_mat = Yggdrasil.Utils.load([datapath filesep 'tissue_mat_' modelType '.mat']);

% loads sigma matrix

SigmaMat=cell(length(freq),1);

for i=1:length(freq)
    
    sigmaPath=['..' filesep 'Example' filesep '1_Efield_example' filesep ...
        'Data' filesep 'sigma_' modelType '_' num2str(freq(i)) 'MHz.mat'];
    SigmaMat{i}=importdata(sigmaPath);
    
end

% loads and applies settings to fields fields

E1=cell(length(freq),1);
E2=cell(length(freq),1);

for i=1:length(freq)
    
    fileName=['Efield_' num2str(freq(i)) 'MHz_A' num2str(1) '_duke_tongue.mat'];
    
    E=importdata([resultPath fileName]);
    
    E1{i}=sum(E,4)*settings1(1,1)*exp(-1i*settings1(1,2));
    
    E2{i}=sum(E,4)*settings2(1,1)*exp(-1i*settings2(1,2));
    
    for j=2:numAnts
        
        fileName=['Efield_' num2str(freq(i)) 'MHz_A' num2str(j) '_duke_tongue.mat'];
        
        E=importdata([resultPath fileName]);
                
        E1{i}=E1{i}+sum(E,4)*settings1(1,2*i-1)*exp(-1i*settings1(1,2*i));
        
        E2{i}=E2{i}+sum(E,4)*settings2(1,2*i-1)*exp(-1i*settings2(1,2*i));
        
    end
    
end

% calculates PLD

if isSingle
    
    PLD1=abs(E1{1}).^2.*SigmaMat{1};
    PLD2=abs(E2{1}).^2.*SigmaMat{1};
    
else
    
    PLD1=abs(E1{1}*timeShare1(1).*sqrt(SigmaMat{1})+E1{2}*timeShare1(2).*sqrt(SigmaMat{1})).^2;
    PLD2=abs(E2{1}*timeShare2(1).*sqrt(SigmaMat{1})+E2{2}*timeShare2(2).*sqrt(SigmaMat{1})).^2;
    
end

% creates tissue_filepath for getHTQ

if startsWith(modelType, 'duke') == 1
    tissue_filepath = ([datapath filesep 'df_duke_neck_cst_' num2str(freq) 'MHz.txt']);
    elseif strcmp(modelType,'child')
        tissue_filepath = ([datapath filesep 'df_chHead_cst_' num2str(freq) 'MHz.txt']);
    else
        error('Model not available. Add to quality_indicators.')
end

% calculates quality indicators

addpath Evaluation\quality_indicators 
[HTQ1, PLDmaxTum1, TC1]=getHTQ(tissue_mat, PLD1, tissue_filepath);

[HTQ2, PLDmaxTum2, TC2]=getHTQ(tissue_mat, PLD2, tissue_filepath);

disp(['HTQ for setting 1 is ' num2str(HTQ1)])
disp(['TC25 for setting 1 is ' num2str(TC1(1))])
disp(['Maximum PLD in tumor for setting 1 is ' num2str(PLDmaxTum1) ' W'])

disp(['HTQ for setting 2 is ' num2str(HTQ2)])
disp(['TC25 for setting 2 is ' num2str(TC2(1))])
disp(['Maximum PLD in tumor for setting 2 is ' num2str(PLDmaxTum2) ' W'])

disp(['HTQ difference is ' num2str(abs(HTQ1-HTQ2))])
disp(['TC25 difference is ' num2str(abs(TC1(1)-TC2(1)))])
disp(['Difference in Maximum PLD in tumor is ' num2str(abs(PLDmaxTum1-PLDmaxTum2)) ' W'])

figure(1)
myslicer(1000*PLD1/(max(PLD1(:))))
title('PLD distribution for settings 1')
figure(2)
myslicer(1000*PLD2/(max(PLD2(:))))
title('PLD distribution for settings 2')


