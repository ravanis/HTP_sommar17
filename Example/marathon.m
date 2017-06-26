% MARATHON
% This file runs all runs! Make sure you enter the data below 
% first, and then run each section one by one. 

% Start in HTP_sommar17 folder

% ------------------------------------------------------
% ---- Enter data --------------------------------------
% ------------------------------------------------------
freq = 450; % MHz, IF SIMPLE USE ONE FREQUENCY
%freq_vec = [400, 400]; % MHz, IF ADVANCED USE TWO

nbrEfields = 16; 
modelType = 'duke_tongue'; % Current alternatives: 
%    duke_tongue/duke_nasal/duke_neck/child
goal_power_tumor = 0.5; % Goal power in tumor [W]
% ------------------------------------------------------
% ------------------------------------------------------

disp('Settings saved.')

%% Compile files
hyp_compile;
hyp_init;

disp('Done!')

%% run_1
clc
run_1(freq, nbrEfields,  modelType, goal_power_tumor)
disp('Done!')

%% run_1_adv
run_1_adv(freq_vec, nbrEfields, modelType)
disp('Done!')

%% run_1_summer
run_1_summer(freq_vec, nbrEfields, modelType)
disp('Done!')

%% run_2
% Only needs to be run once for each model! Only P-matrix that changes.
run_2(modelType, freq) % IF SIMPLE USE FREQ, IF ADVANCED USE FREQ_VEC
disp('Done!')

%% run_3
disp('Run_3 should be done in FEniCS, you fool!')

%% run_4
run_4(modelType, freq_vec); % IF SIMPLE USE FREQ, IF ADVANCED USE FREQ_VEC
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

quality_indicators(modelType, freq)%, goal_power_tumor) % Kan köras med freq eller freq_vec
