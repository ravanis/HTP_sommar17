function [ tx_h ] = TXhealthy( X, temp_mat, tissue_mat, modelType, freq)
%   Finds the X percentile of temperature in healthy tissue. 
filename = which('TXhealthy');
[scriptpath,~,~] = fileparts(filename);
datapath = [scriptpath filesep '..' filesep '..' filesep '1_Efield_example/Data' filesep];

if startsWith(modelType, 'duke')
    tumor_ind=80;
    parampath = [datapath 'df_duke_neck_cst_' num2str(freq) 'MHz.txt'];
elseif modeltype == 'child'
    tumor_ind=9;
    parampath = [datapath 'df_chHead_cst_' num2str(freq) 'MHz.txt'];
else
    error('Modeltype not defined in TXhealthy.m.')
end

% Read the first file and save the wanted collums
paramMat = caseread(parampath);
paramMat(end-1:end,:)= []; % Removes the last two rows

[~, index, ~, ~, ~ , ~] = strread(paramMat', '%s %d %f %d %f %f',...
    'whitespace', '\t');

for i=1:length(index)
    if ~(index(i)==tumor_ind)
        indeces_of_interest(i)=index(i);
    end
end

tx_h=TX(X, temp_mat, tissue_mat, indeces_of_interest);
end