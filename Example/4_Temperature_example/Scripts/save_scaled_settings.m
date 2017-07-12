function save_scaled_settings(modelType,freq,nbrEfields)
% This function saves the new settings after the temperature loop in FEniCS
% has found a good scale. 

%find file paths
filename = which('save_scaled_settings');
[scriptpath,~,~] = fileparts(filename);
settingpath = [scriptpath filesep '..' filesep '..' filesep '1_Efield_results_adv' filesep];
savepath = [scriptpath filesep '..' filesep '..' filesep '4_Temperature_results'];
amppath = [scriptpath filesep '..' filesep '..' filesep '3_FEniCS_results' filesep 'scaledAmplitudes.txt'];

addpath(scriptpath)

% Find phase and amplitude from their respective files and create new
% settings vector 
if length(freq)==1
    settingsID = fopen([settingpath 'settings_' modelType '_' num2str(freq) 'MHz.txt']);
    ampID = fopen(amppath);
    for i = 1:nbrEfields
        if i==1
            for j=1:2
                fscanf(settingsID,'%s',1);
            end
        end
        fscanf(settingsID,'%s',1);
        amp_cell{i}=fscanf(ampID,'%s',1);
        fas_cell{i}=fscanf(settingsID,'%s',1);
    end
    fas = zeros(nbrEfields,1);
    amp = fas;
    for k = 1:nbrEfields
        fas(k) = str2num(fas_cell{k});
        amp(k) = str2num(amp_cell{k});
    end
end
settings = [amp fas];

%Use writeSettings to create new settings file 
writepath = [scriptpath filesep '..' filesep '..' filesep '1_Efield_example_adv' filesep 'Scripts'];
addpath(writepath)
writeSettings(savepath,settings,1,modelType,freq)
end