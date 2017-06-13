function run_1(freq, nbrEfields)
%RUN_1
%   Run example 1
    olddir = pwd;
    [rootpath,~,~] = fileparts(mfilename('fullpath'));
    cd([rootpath filesep '..'])

    addpath([rootpath filesep '1_Efield_example'])
    EF_optimization(freq, nbrEfields)
    
    % Use the following to the advanced optimization
    %addpath([rootpath filesep '1_Efield_example_advanced'])
    %[a,b,c] = EF_optimization
    
    cd(olddir)
end