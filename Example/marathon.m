% MARATHON
% This file runs all runs! Make sure you enter the data below 
% first, and then run each section one by one. 

% Start in HTP_sommar17 folder

% ------------------------------------------------------
% ---- Enter data --------------------------------------
% ------------------------------------------------------
freq = 800; % MHz
nbrEfields = 16; 
modelType = 'duke_tongue'; % Current alternatives: 
%    duke_tongue/duke_nasal/duke_neck/child
goal_power_tumor = 0.18; % Goal power in tumor [W]
% ------------------------------------------------------
% ------------------------------------------------------

hyp_compile
hyp_init

disp('Done!')

%% run_1
run_1(freq, nbrEfields, modelType, goal_power_tumor)
disp('Done')

%% run_2
clc
run_2(modelType, freq)
disp('Done')

%% run_3
disp('Run_3 should be done in FEniCS, you fool!')

%% run_4
run_4(modelType);
disp('Done')



