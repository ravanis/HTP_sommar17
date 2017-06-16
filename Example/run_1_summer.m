function run_1_summer(freq_vec, nbrEfields, modelType)
%RUN_1_SUMMER
%   Run example 1
    olddir = pwd;
    [rootpath,~,~] = fileparts(mfilename('fullpath'));
    cd([rootpath filesep '..'])

    addpath([rootpath filesep '1_Efield_example'])
    EF_optimization_summer(freq_vec, nbrEfields, modelType)
    
    for i = freq_vec
        find_settings(modelType, i)
    end
    
    cd(olddir)
end