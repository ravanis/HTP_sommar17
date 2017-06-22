function writeSettings( resultpath,settings, settings_time, modelType, freq, goal_power_tumor)
%writeSettings: writes txt-file out of settings that can be used in LabView
%   INPUT:
%   resultpath - path to where results are to be stored, not ending with
%                filesep
%   settings - matrix of with amplitude and phase as columns ordered
%              according to the frequencies in the freq-vector. ammplitude 
%              first, then phase.
%   settings_time - percentage of time each frequency shall be held 
%                   correspoding to freq-vector, 1 if there is only 1 
%                   frequency.
%   modelType - string of type of model
%   freq - frequency vector correstponding to order settings and
%           time_settings
%   goal_power_tumor - goal power of tumor used in optimization, set to 0
%                      if time reversal is used instead on opt.

if ~goal_power_tumor
    fileID=fopen([resultpath filesep 'settings_' modelType '_' freq 'MHz_TR.txt'],'w');
    fprintf(fileID,'%s %d\r\n','frequency:',freq);
else 
    if length(freq)==1
        fileID=fopen([resultpath filesep 'settings_' modelType '_' freq 'MHz_GP' goal_power_tumor '.txt'],'w');
        fprintf(fileID,'%s %d\r\n','frequency:',freq);
    else
        fileID=fopen([resultpath filesep 'settings_' modelType '_1_' used_freq(1:3) '_2_' used_freq(4:6) 'MHz.txt'],'w');
        fprintf(fileID,'%s %.2f %.2f\r\n','time quota:',settings_time);
        fprintf(fileID,'%s %d %d\r\n','frequencies:', freq);
    end
end

if length(freq)==1
    for i=1:length(settings)
        fprintf(fileID,'%.2f %.2f\r\n',settings(i,:));
    end
    fprintf(fileID,'%s','\\Amp \\Phase');
else
    for i=1:length(settings)
        fprintf(fileID,'%.2f %.2f %.2f %.2f\r\n',settings(i,:));
    end
    fprintf(fileID,'%s','\\Amp \\Phase \\Amp \\Phase');
end

fclose(fileID);

end

