function run_2(modelType, freq, nbrEfields, PwrLimit)
%RUN_1_AND_2
%   Run example 2
    olddir = pwd;
    [rootpath,~,~] = fileparts(mfilename('fullpath'));
    cd(rootpath)

    addpath ..
    addpath ../Libs/iso2mesh
    addpath 2_Prep_FEniCS_example
    
    generate_fenics_parameters(modelType, freq, true) % Default: (modelType, freq, false, false)
    generate_amp_files(modelType, freq, nbrEfields, PwrLimit)
    cd(olddir)
end