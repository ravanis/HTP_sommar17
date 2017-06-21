function plot_myslice_PLD(scale, modelType, freq)

% Get pld_path
filename = which('marathon');
[rootpath,~,~] = fileparts(filename);
pld_path = ([rootpath filesep '1_Efield_results' filesep 'P_' modelType '_' num2str(freq) 'MHz.mat']);

% Load temp_mat
pld_mat = Extrapolation.load(pld_path);

% Plot
myslicer(scale*pld_mat/(max(pld_mat(:))))
end