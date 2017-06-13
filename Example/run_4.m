function run_4(modelType)
%RUN_4
%   Run example 4
    olddir = pwd;
    [rootpath,~,~] = fileparts(mfilename('fullpath'));
    cd(rootpath)

    addpath ..
    addpath 4_Temperature_example
    evaluate_temp(modelType, true);

    cd(olddir)
end