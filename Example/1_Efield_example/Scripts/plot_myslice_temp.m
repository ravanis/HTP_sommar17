function plot_myslice_temp(scale, modelType, freq)

% Get temp_path
filename = which('marathon');
[rootpath,~,~] = fileparts(filename);
temp_path = ([rootpath filesep '4_Temperature_results' filesep 'temp_' modelType '_' num2str(freq) 'MHz.mat']);

% Load temp_mat
temp_mat = Extrapolation.load(temp_path);

% Plot
myslicer(scale*temp_mat/(max(temp_mat(:))))
end