function [freq_comb_filename]= find_freq_comb(modelType, freq_vec, fileType)
% This script is used to find the best combination of frequencies that was
% saved by EF_optimization_adv. Useful for finding correct file.

% freq_vec is a vector of two frequencies
% fileType, eg. 'P', 'temp', 'settings_complex', 'time_settings'

% Find rootpath
filename = which('find_freq_comb');
[scriptpath,~,~] = fileparts(filename);
rootpath = [scriptpath filesep '..' filesep '..'];

% Find file names
switch fileType
    case 'P'
        for i = freq_vec
            for j = freq_vec
                if exist([rootpath filesep '1_Efield_results_adv' filesep ...
                        'P_' modelType '_1_' num2str(i) '_2_' num2str(j) 'MHz.mat'], 'file')
                    freq_comb_filename = ['P_' modelType '_1_' num2str(i) ...
                        '_2_' num2str(j) 'MHz.mat'];
                end
            end
        end
    case 'temp'
        for i = freq_vec
            for j = freq_vec
                if exist([rootpath filesep '4_Temperature_results' filesep ...
                        'temp_' modelType '_1_' num2str(i) '_2_' num2str(j) 'MHz.mat'], 'file')
                    freq_comb_filename = ['temp_' modelType '_1_' num2str(i) ...
                        '_2_' num2str(j) 'MHz.mat'];
                end
            end
        end
    case 'settings_complex'
        for i = freq_vec
            for j = freq_vec
                if exist([rootpath filesep '1_Efield_results_adv' filesep ...
                        'settings_complex_' modelType '_1_' num2str(i) '_2_' num2str(j) 'MHz'], 'file')
                    freq_comb_filename = ['settings_complex_' modelType '_1_' num2str(i) ...
                        '_2_' num2str(j) 'MHz'];
                end
            end
        end
    case 'time_settings'
        for i = freq_vec
            for j = freq_vec
                if exist([rootpath filesep '1_Efield_results_adv' filesep ...
                        'time_settings_' modelType '_1_' num2str(i) '_2_' num2str(j) 'MHz.mat'], 'file')
                    freq_comb_filename = ['time_settings_' modelType '_1_' num2str(i) ...
                        '_2_' num2str(j) 'MHz.mat'];
                end
            end
        end
end