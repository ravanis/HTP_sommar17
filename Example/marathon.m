% MARATHON
% This file runs all runs! Make sure you enter the data below 
% first, and then run each section one by one. 

% ------------------------------------------------------
% ---- Enter data --------------------------------------
% ------------------------------------------------------
freq = 800; % MHz
nbrEfields = 16; 
modelType = 'duke'; % Current alternatives: duke/child
% ------------------------------------------------------
% ------------------------------------------------------

hyp_compile
hyp_init

disp('Done!')

%% run_1
run_1(freq, nbrEfields, modelType)
disp('Done')

%% run_2
run_2(modelType)
disp('Done')

%% run_3
disp('This should be done in FEniCS, you fool!')

%% run_4
run_4(modelType);
disp('Done')



