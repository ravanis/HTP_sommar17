function run_1_adv(freq_vec, nbrEfields, modelType)
%RUN_1_ADV
%   Run example 1
    olddir = pwd;
    [rootpath,~,~] = fileparts(mfilename('fullpath'));
    cd([rootpath filesep '..'])

    addpath([rootpath filesep '1_Efield_example_adv'])
    EF_optimization_adv(freq_vec, nbrEfields, modelType)
    
    addpath([rootpath filesep '1_Efield_example' filesep 'Scripts'])
    for i = freq_vec
        find_settings(modelType, i)
    end
    
    cd(olddir)
end