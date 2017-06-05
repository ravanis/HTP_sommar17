function  create_sigma_mat(freq)
%CREATE_SIGMA_MAT(freq)

    filename = which('create_sigma_mat');
    [scriptpath,~,~] = fileparts(filename);
    
    datapath = [scriptpath filesep '..' filesep ...
        '..' filesep '1_Efield_example' filesep 'Data' filesep];
    parampath = [datapath ...
                'df_duke_neck_cst_' num2str(freq) 'MHz.txt'];
    tissue_mat = Yggdrasil.Utils.load([datapath...
                'tissue_mat.mat']);
            
    % Read the first file and save the wanted collums
    paramMat = caseread(parampath);
    paramMat(end-1:end,:)= []; % Removes the last two rows

    % Creates two columns containing index and sigma values
    [~, index, ~, ~, sigma, ~] = strread(paramMat', '%s %d %f %d %f %f',...
                                               'whitespace', '\t');
    % Convert sigma to sigma_mat, corresponding to tissue_mat
    index_to_row = zeros(max(index),1);
    index_to_row(index) = 1:length(index);
    sigma_mat = sigma(index_to_row(tissue_mat));
    
    % Remove conductivity of non-biological data
    water_ind = 81;
    ext_air_ind = 1;
    int_air_ind = 2;
    
    sigma_mat(water_ind) = 0;
    sigma_mat(ext_air_ind) = 0;
    sigma_mat(int_air_ind) = 0;
    
    save([datapath 'sigma_' num2str(freq) '.mat'], 'sigma_mat', '-v7.3');
end