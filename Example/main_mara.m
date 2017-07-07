% MAIN MARA

% Run all or run in sections

% ------------------------------------------------------------------
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------
InputData % flytta till HTP_sommar17

hyp_compile
hyp_init

olddir = pwd;
[rootpath,~,~] = fileparts(mfilename('fullpath'));
cd([rootpath filesep '..'])
addpath([rootpath filesep '1_Efield_example_adv'])

EF_optimization_radical(freq_vec, nbrEfields, modelType, 'HTQ')

%% Generate FEniCS Parameters
h = msgbox('Optimization finished! Generating FEniCS parameters. ','Success');

olddir = pwd;
[rootpath,~,~] = fileparts(mfilename('fullpath'));
cd(rootpath)

addpath ..
addpath ../Libs/iso2mesh
addpath 2_Prep_FEniCS_example

generate_fenics_parameters(modelType, freq, true) % Default: (modelType, freq, false, false)
cd(olddir)

%% FEniCS
k = msgbox('Time to move on to FEniCS! Remember to input the files you just generated.','Move on');
pause

%% Temperature
g = msgbox('Time for temperature calculations! Bring your FEniCS files.');

olddir = pwd;
[rootpath,~,~] = fileparts(mfilename('fullpath'));
cd(rootpath)
addpath ..
addpath 4_Temperature_example
evaluate_temp(modelType, freq, true);
cd(olddir)

t = msgbox('You have now finished the optimization and temperature transformation. You rock!', 'Rock on');
filename = which('new_mara');
[LocateLeo,~,~] = fileparts(filename);
GoodJob = [LocateLeo filesep 'Leonardo-DiCaprio-Clap.gif'];
gifplayer('C:\Users\Andrea\Documents\Kod\Leonardo-DiCaprio-Clap.gif',0.1);
