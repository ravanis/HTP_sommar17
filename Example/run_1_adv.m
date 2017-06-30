function run_1_adv(freq_vec, nbrEfields, modelType, M, goal_function)
%RUN_1_ADV
%   Run example 1

olddir = pwd;
[rootpath,~,~] = fileparts(mfilename('fullpath'));
cd([rootpath filesep '..'])

addpath([rootpath filesep '1_Efield_example_adv'])

if nargin == 4
    switch M
        case 'M1'
            EF_optimization_adv(freq_vec, nbrEfields, modelType)
            addpath([rootpath filesep '1_Efield_example' filesep 'Scripts'])
        case 'M2'
            EF_optimization_M2_2freq(freq_vec, nbrEfields, modelType)
    end
    find_settings_adv(modelType, freq_vec, M)
elseif nargin == 5
    EF_optimization_radical(freq_vec, nbrEfields, modelType, goal_function)
end

addpath([rootpath filesep '2_Prep_FEniCS_example' filesep 'Scripts'])
cd(olddir)
end