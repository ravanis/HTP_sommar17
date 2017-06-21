function [P_adv_filename]= find_P_adv(modelType, freq_vec)
% This script is used to find the best combination of frequencies that was 
% saved by EF_optimization_adv. Useful for finding correct file. 

% freq_vec is a vector of two frequencies

% Find rootpath
filename = which('find_P_adv');
[scriptpath,~,~] = fileparts(filename);
rootpath = [scriptpath filesep '..' filesep '..'];

% Find P_adv file name
for i = freq_vec
    for j = freq_vec
        if exist([rootpath filesep '1_Efield_results_adv' filesep ...
                'P_' modelType '_1_' num2str(i) '_2_' num2str(j) 'MHz.mat'], 'file')
            P_adv_filename = ['P_' modelType '_1_' num2str(i) ...
                '_2_' num2str(j) 'MHz.mat'];
        end
    end
end
end