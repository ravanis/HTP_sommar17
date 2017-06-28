function find_settings_adv(modelType, freq, M)
% Calculates settings for the current optimization using the
% settings_complex matrix obtained from run_1_adv.
% Needs two frequencies
% M = M1 or M2 optimization methods

% Find rootpath
filename = which('find_settings_adv');
[scriptpath,~,~] = fileparts(filename);
rootpath = [scriptpath filesep '..' filesep '..'];
resultpath = [rootpath filesep '1_Efield_results_adv'];

% Load complex settings matrix
[freq_comb_filename1]= find_freq_comb(modelType, freq, 'settings_complex');
switch M
    case 'M1'
        load_name_1 = [resultpath filesep freq_comb_filename1 '_(1).mat'];
        load_name_2 = [resultpath filesep freq_comb_filename1 '_(2).mat'];
    case 'M2'
        load_name = [resultpath filesep freq_comb_filename1 '.mat'];
end
switch modelType
    case 'duke_tongue'
        used_freq = [freq_comb_filename1(32:34) freq_comb_filename1(38:40)];
    case 'duke_neck'
        used_freq = [freq_comb_filename1(30:32) freq_comb_filename1(36:38)];
    case 'duke_nasal'
        used_freq = [freq_comb_filename1(31:33) freq_comb_filename1(37:39)];
    case 'duke_cylinder'
        used_freq = [freq_comb_filename1(34:36) freq_comb_filename1(40:42)];
    case 'child'
        used_freq = [freq_comb_filename1(26:28) freq_comb_filename1(32:34)];
end

% loads the time quota for the treatment
switch M
    case 'M1'
        [freq_comb_filename2]= find_freq_comb(modelType, freq, 'time_settings');
        load_name_time = [resultpath filesep freq_comb_filename2];
        settings_time=Yggdrasil.Utils.load(load_name_time);
    case 'M2'
        settings_time = [0.5 0.5];
        disp(['The time settings are not optimized because the p-matrices ' ...
            'from freq1 and freq2 cannot be separated. This is a problem.'])
end
settings=[];

% Calculate phase and amplitude
for j = 1:length(freq)
    switch M
        case 'M1'
            if j == 1
                settings_complex = Yggdrasil.Utils.load(load_name_1);
            elseif j == 2
                settings_complex = Yggdrasil.Utils.load(load_name_2);
            end
        case 'M2'
            settings_complex = Yggdrasil.Utils.load(load_name);
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
    settings = [settings amp/max(amp(:)) fas];
end

freq = [str2num(used_freq(1:3)) str2num(used_freq(4:6))];

writeSettings(resultpath, settings, settings_time, modelType, freq);

if M == 'M1'
    delete([resultpath filesep freq_comb_filename2])
    delete([resultpath filesep freq_comb_filename1 '_(1).mat'])
    delete([resultpath filesep freq_comb_filename1 '_(2).mat'])
else
    delete([resultpath filesep freq_comb_filename1 '.mat'])
end
end