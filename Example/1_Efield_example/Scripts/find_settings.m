function find_settings(modelType, freq1, freq2)
% Calculates settings for the current optimization using the
% settings_complex matrix obtained from run_1.
% Can handle one or two frequencies

% Find rootpath
filename = which('find_settings');
[scriptpath,~,~] = fileparts(filename);
rootpath = [scriptpath filesep '..' filesep '..'];

% Load complex settings matrix
if nargin == 2
    load_name = [rootpath filesep '1_Efield_results' filesep ...
        'settings_complex_' modelType '_' num2str(freq) 'MHz.mat'];
elseif nargin == 3
    if exist([rootpath filesep '1_Efield_results' filesep ...
            'settings_complex_' modelType '_1_' num2str(freq1) ...
            '_2_' num2str(freq2) 'MHz.mat'], 'file')
        load_name = [rootpath filesep '1_Efield_results' filesep ...
            'settings_complex_' modelType '_1_' num2str(freq1) ...
            '_2_' num2str(freq2) 'MHz.mat'];
    elseif exist([rootpath filesep '1_Efield_results' filesep ...
            'settings_complex_' modelType '_1_' num2str(freq2) ...
            '_2_' num2str(freq1) 'MHz.mat'], 'file')
        load_name = [rootpath filesep '1_Efield_results' filesep ...
            'settings_complex_' modelType '_1_' num2str(freq2) ...
            '_2_' num2str(freq1) 'MHz.mat'];
    else
        error('Cannot find settings_complex file')
    end
else
    error('Too many frequencies!')
end
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