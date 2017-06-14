function q= create_rho_mat(modelType, freq)
% creates a matrix of the density at each position

filename = which('create_rho_mat');
[scriptpath,~,~] = fileparts(filename);
datapath = [scriptpath filesep '..' filesep 'Data' filesep];
if startsWith(modelType, 'duke') == 1
    parampath = [datapath 'df_duke_neck_cst_' num2str(freq) 'MHz.txt'];
elseif modelType == 'child'
    parampath = [datapath 'df_chHead_cst_' num2str(freq) 'MHz.txt'];
else
    error('Model not available. Add to create_rho_mat.')
end
tissue_mat = Yggdrasil.Utils.load([datapath 'tissue_mat_' modelType '.mat']);

% Read the first file and save the wanted columns
paramMat = caseread(parampath);
paramMat(end-1:end,:)= []; % Removes the last two rows

% Creates two columns containing index and rho values
[~, index, ~, ~, ~,rho] = strread(paramMat', '%s %d %f %d %f %f',...
    'whitespace', '\t');

% Convert rho to rho_mat, corresponding to tissue_mat
index_to_row = zeros(max(index),1);
index_to_row(index) = 1:length(index);
rho_mat = rho(index_to_row(tissue_mat));

save([datapath 'rho_' modelType '.mat'], 'rho_mat');

end