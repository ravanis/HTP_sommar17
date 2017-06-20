function run_1(freq, nbrEfields, modelType, goal_power_tumor)
%RUN_1
%   Run example 1
    olddir = pwd;
    [rootpath,~,~] = fileparts(mfilename('fullpath'));
    cd([rootpath filesep '..'])

    addpath([rootpath filesep '1_Efield_example'])
    EF_optimization(freq, nbrEfields, modelType, goal_power_tumor)
    find_settings(modelType, goal_power_tumor, freq)
    
    cd(olddir)
end