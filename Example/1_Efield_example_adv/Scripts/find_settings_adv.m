function find_settings_adv(modelType, freq)
% Calculates settings for the current optimization using the
% settings_complex matrix obtained from run_1_adv.
% Needs two frequencies

% Find rootpath
filename = which('find_settings_adv');
[scriptpath,~,~] = fileparts(filename);
rootpath = [scriptpath filesep '..' filesep '..'];
resultpath = [rootpath filesep '1_Efield_results_adv'];

% Load complex settings matrix
[freq_comb_filename1]= find_freq_comb(modelType, freq, 'settings_complex');
load_name_1 = [resultpath filesep freq_comb_filename1 '_(1).mat'];
load_name_2 = [resultpath filesep freq_comb_filename1 '_(2).mat'];
used_freq = [freq_comb_filename1(32:34) freq_comb_filename1(38:40)];

% loads the time quota for the treatment
[freq_comb_filename2]= find_freq_comb(modelType, freq, 'time_settings');
load_name_time = [resultpath filesep freq_comb_filename2];
settings_time=Yggdrasil.Utils.load(load_name_time);
settings=[];

% Calculate phase and amplitude
for j = 1:length(freq)
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
    settings = [settings amp/max(amp(:)) fas];
end

freq = [str2num(used_freq(1:3)) str2num(used_freq(4:6))];
fileID=fopen([resultpath filesep 'settings_' modelType '_1_' used_freq(1:3) '_2_' used_freq(4:6) 'MHz.txt'],'w');
fprintf(fileID,'%s %.2f %.2f\r\n','time quota:',settings_time);
fprintf(fileID,'%s %d %d\r\n','frequencies:', freq);
for i=1:length(settings)
    fprintf(fileID,'%.2f %.2f %.2f %.2f\r\n',settings(i,:));
end
fprintf(fileID,'%s','\\Amp \\Phase \\Amp \\Phase');
fclose(fileID);

delete([resultpath filesep freq_comb_filename2])
end