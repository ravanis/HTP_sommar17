% MARATHON
% This file runs all runs! Make sure you enter the data below 
% first, and then run each section one by one. 

% Start in HTP_sommar17 folder

% ------------------------------------------------------
% ---- Enter data --------------------------------------
% ------------------------------------------------------
freq = 400; % MHz
nbrEfields = 16; 
modelType = 'duke_tongue'; % Current alternatives: 
%    duke_tongue/duke_nasal/duke_neck/child
goal_power_tumor = 0.5; % Goal power in tumor [W]
% ------------------------------------------------------
% ------------------------------------------------------

disp('Settings saved.')

%% Compile files

hyp_compile
hyp_init

disp('Done!')

%% run_1
run_1(freq, nbrEfields, modelType, goal_power_tumor)
disp('Done!')

%% run_1_adv
clc
freq_vec = [400, 600]; % vector with TWO frequencies

run_1_adv(freq_vec, nbrEfields, modelType)
disp('Done!')

%% run_1_summer
freq_vec = [600, 800]; % vector with TWO frequencies

run_1_summer(freq_vec, nbrEfields, modelType)
disp('Done!')

%% run_2
% Only needs to be run once for each model! Only P-matrix that changes.

run_2(modelType, freq)
disp('Done!')

%% run_3
disp('Run_3 should be done in FEniCS, you fool!')

%% run_4
run_4(modelType, freq);
disp('Done!')

%% OPTIONAL EVALUATION %%%%%%%%%%%%%%%%%%%%
%% myslicer PLD
scale = 200;

plot_myslice_PLD(scale, modelType, freq)

%% myslicer T
scale = 1000;

plot_myslice_temp(scale, modelType, freq)

%% Quality indicators
% Stå i HTP_sommar17

quality_indicators(modelType, freq)
