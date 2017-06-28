function plot_myslice_PLD(scale, modelType, freq, goal_power_tumor)

% Get pld_path
filename = which('marathon');
[rootpath,~,~] = fileparts(filename);
if length(freq)==1
pld_path = ([rootpath filesep '1_Efield_results' filesep 'P_' modelType '_' num2str(freq) 'MHz_GP' num2str(goal_power_tumor) '.mat']);
elseif length(freq)>1
pld_path = ([rootpath filesep '1_Efield_results_adv' filesep 'P_' modelType '_1_' num2str(freq(1)) '_2_' num2str(freq(2)) 'MHz.mat']);
end

% Load temp_mat
pld_mat = Extrapolation.load(pld_path);

% Plot
myslicer(scale*pld_mat/(max(pld_mat(:))))
end