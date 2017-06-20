function find_settings_adv(modelType, freq1, freq2)
% Calculates settings for the current optimization using the
% settings_complex matrix obtained from run_1_adv.
% Needs two frequencies

% Find rootpath
filename = which('find_settings_adv');
[scriptpath,~,~] = fileparts(filename);
rootpath = [scriptpath filesep '..' filesep '..'];

% Load complex settings matrix
for i = [freq1 freq2]
    for j = [freq1 freq2]
        if exist([rootpath filesep '1_Efield_results_adv' filesep ...
                'settings_complex_' modelType '_1_' num2str(i) ...
                '_2_' num2str(j) 'MHz_(1).mat'], 'file')
            load_name_1 = [rootpath filesep '1_Efield_results_adv' filesep ...
                'settings_complex_' modelType '_1_' num2str(i) ...
                '_2_' num2str(j) 'MHz_(1).mat'];
            load_name_2 = [rootpath filesep '1_Efield_results_adv' filesep ...
                'settings_complex_' modelType '_1_' num2str(i) ...
                '_2_' num2str(j) 'MHz_(2).mat'];
        end
    end
end

if isempty(load_name_1) && isempty(load_name_2)
    error('Cannot find settings_complex file. Check name or number of frequencies in input.')
end

% Calculate phase and amplitude
for j = 1:(nargin-1)
    if j == 1
        settings_complex = Yggdrasil.Utils.load(load_name_1);
    elseif j == 2
        settings_complex = Yggdrasil.Utils.load(load_name_2);
    end
    N = size(settings_complex);
    fas = zeros(N(1),1);
    amp = zeros(N(1),1);
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
    freq = [freq1 freq2];
    settings = [amp/max(amp(:)), fas, (settings_complex(:,2))];
    save([rootpath filesep '1_Efield_results_adv' filesep 'settings_' modelType '_' num2str(freq(j)) 'MHz_(' num2str(j) ').mat'], 'settings');
    
    disp(['The settings for ' num2str(j) ' are:'])
    disp('  Amplitude   Phase    Antenna')
    disp([settings])
end
end