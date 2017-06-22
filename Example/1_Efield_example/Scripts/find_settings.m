function find_settings(modelType, goal_power_tumor, freq)
% Calculates settings for the current optimization using the
% settings_complex matrix obtained from run_1.
% Only handles one frequency

% Find rootpath
filename = which('find_settings');
[scriptpath,~,~] = fileparts(filename);
rootpath = [scriptpath filesep '..' filesep '..'];
resultpath = [rootpath filesep '1_Efield_results'];

% Load complex settings matrix
if exist([rootpath filesep '1_Efield_results' filesep ...
        'settings_complex_' modelType '_' num2str(freq) 'MHz_GP' num2str(goal_power_tumor) '.mat'], 'file')
load_name = [rootpath filesep '1_Efield_results' filesep ...
        'settings_complex_' modelType '_' num2str(freq) 'MHz_GP' num2str(goal_power_tumor) '.mat'];
else
    error('Cannot find settings_complex file. Check name or number of frequencies in input.')
end
settings_complex = Yggdrasil.Utils.load(load_name);

% Load time settings matrix if there are more than 2 frequencies
% if(length(freq)>1)
% if exist([rootpath filesep '1_Efield_results' filesep ...
%         'settings_' modelType '_' num2str(freq) 'MHz.mat'], 'file')
% load_name = [rootpath filesep '1_Efield_results' filesep ...
%         'settings_complex_' modelType '_' num2str(freq) 'MHz.mat'];
% else
%     error('Cannot find settings_complex file. Check name or number of frequencies in input.')
% end
% settings_complex = Yggdrasil.Utils.load(load_name);
delete(load_name);

% Calculate phase and amplitude
N = length(settings_complex);
fas = zeros(N,1);
amp = zeros(N,1);
V = settings_complex;

for i = 1:length(fas)
    amp(i,1) = sqrt((real(V(i,1)))^2+(real(V(i,1)))^2);
    if real(V(i,1))>0
        fas(i,1) = (atan(imag(V(i,1))/real(V(i,1)))*180/pi);
    elseif real(V(i,1))<0 && imag(V(i,1))>=0
        fas(i,1) = atan(imag(V(i,1))/real(V(i,1)))*180/pi+180;
    elseif real(V(i,1))<0 && imag(V(i,1))<0
        fas(i,1) = atan(imag(V(i,1))/real(V(i,1)))*180/pi-180;
    end
end

% Save settings
settings = [amp/max(amp(:)), fas];
settings_time=1;

writeSettings( resultpath, settings, settings_time, modelType, freq, goal_power_tumor);

disp('The settings are:')
disp('  Amplitude   Phase    Antenna')
disp([settings])

end