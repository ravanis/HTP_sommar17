% MARATHON
% This file runs all runs! Make sure you enter the data below 
% first, and then run each section one by one. 

% Start in HTP_sommar17 folder

% ------------------------------------------------------
% ---- Enter data --------------------------------------
% ------------------------------------------------------
freq = 450; % MHz, IF SIMPLE USE ONE FREQUENCY
freq_vec = [450, 450]; % MHz, IF ADVANCED USE TWO

nbrEfields = 10; 
modelType = 'duke_cylinder'; % Current alternatives: 
%    duke_tongue/duke_nasal/duke_neck/duke_cylinder/child
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
run_1(freq, nbrEfields, modelType, goal_power_tumor)
disp('Done!')

%% run_1_adv
clc
M = 'radical'; % which optimization method to use for run_1_adv
goal_function = 'M1'; % Only for radical: M1/M2/HTQ

run_1_adv(freq, nbrEfields, modelType, M, goal_function)
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
scale = 50;
plot_myslice_PLD(scale, modelType, freq_vec)%, goal_power_tumor)

%% myslicer T
scale = 1000;

plot_myslice_temp(scale, modelType, freq)

%% Quality indicators
% St� i HTP_sommar17
quality_indicators(modelType, freq, goal_power_tumor)%, goal_power_tumor) % Kan k�ras med freq eller freq_vec
