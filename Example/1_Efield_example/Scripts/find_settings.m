function find_settings(modelType, freq)
% Calculates settings for the current optimization using the
% settings_complex matrix obtained from run_1.

% Find rootpath
filename = which('find_settings');
[scriptpath,~,~] = fileparts(filename);
rootpath = [scriptpath filesep '..' filesep '..'];

% Load complex settings matrix
load_name = [rootpath filesep '1_Efield_results' filesep ...
    'settings_complex_' modelType '_' num2str(freq) 'MHz.mat'];
settings_complex = Yggdrasil.Utils.load(load_name);

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
settings = [amp/max(amp(:)), fas, (settings_complex(:,2))];
save([rootpath filesep '1_Efield_example' filesep 'Scripts' filesep 'settings_' modelType '_' freq 'MHz.mat'], 'settings');

disp('The settings are:')
disp('  Amplitude   Phase    Antenna')
disp([settings])

end