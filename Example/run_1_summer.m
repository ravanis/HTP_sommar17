function run_1_summer(freq_vec, nbrEfields, modelType)
%RUN_1_SUMMER
%   Run example 1
    olddir = pwd;
    [rootpath,~,~] = fileparts(mfilename('fullpath'));
    cd([rootpath filesep '..'])

    addpath([rootpath filesep '1_Efield_example'])
    EF_optimization_summer(freq_vec, nbrEfields, modelType)
    
   %find_settings_adv(modelType, freq_vec(1), freq_vec(2))
    
    cd(olddir)
end