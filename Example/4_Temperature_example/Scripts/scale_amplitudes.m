function scale_amplitudes(freq, modelType, nbrEfields)
%freq is either one or two frequencies
% Skalar upp amplituder enligt skala från temperaturomvandling
% Skapa helt ny settings-fil med allt
% Ta bort gammal settings-fil

addpath Example\4_Temperature_example\Scripts

filename = which('scale_amplitudes');
[scriptpath,~,~] = fileparts(filename);
settingspath = [scriptpath filesep '..' filesep '..' filesep ...
    '1_Efield_results_adv' filesep];

scalepath = [scriptpath filesep '..' filesep '..' filesep '3_FEniCS_results' filesep 'scaleP.txt'];
scaleMat = fopen(scalepath);
resultpath = [scriptpath filesep '..' filesep '..' filesep '4_Temperature_results'];

if length(freq)==1
parampath = [settingspath 'settings_' modelType '_' num2str(freq) 'MHz.txt'];
%elseif length(freq)==2
% freq_comb = find_freq_comb(freq);
% parampath = [datapath 'settings_' modelType '_1_' num2str(freq_comb(1)) '_2_' ...
%     num2str(freq_comb(2)) 'MHz.txt'];
end

% Creates two columns containing index and sigma values
if length(freq)==1
paramMat = fopen(parampath);
for i=1:nbrEfields
    if i ==1
    for j =1:2
    fscanf(paramMat,'%s',1);
    end
    end
    amp{i} = fscanf(paramMat,'%s',1);
    fas{i} = fscanf(paramMat,'%s',1);
end
amp' = amp;
fas' = fas;

scale = fscanf(scaleMat,'%s',1);
scaled_amp = sqrt(2*amp);
settings=[scaled_amp, fas];

writeSettings(resultpath, settings, 1, modelType, freq)
end

if length(freq)>1
    %to-do
end

end