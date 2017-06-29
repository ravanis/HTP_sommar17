function run_1_new(freq, nbrEfields, modelType)

% Run 1
    olddir = pwd;
    [rootpath,~,~] = fileparts(mfilename('fullpath'));
    cd([rootpath filesep '..'])
    addpath([rootpath filesep '1_Efield_example'])
    best_Efields(freq, nbrEfields, modelType)
% 
    
end