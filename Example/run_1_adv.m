function run_1_adv(freq_vec, nbrEfields, modelType)
%RUN_1_ADV
%   Run example 1
olddir = pwd;
[rootpath,~,~] = fileparts(mfilename('fullpath'));
cd([rootpath filesep '..'])

addpath([rootpath filesep '1_Efield_example_adv'])
% EF_optimization_adv(freq_vec, nbrEfields, modelType)
EF_optimization_M2_2freq(freq_vec, nbrEfields, modelType)
addpath([rootpath filesep '1_Efield_example' filesep 'Scripts'])
find_settings_adv(modelType, freq_vec)
cd(olddir)
end