function generate_amp_files(modelType, freq, nbrEfields, PwrLimit)

filename = which('generate_amp_files');
[scriptpath,~,~] = fileparts(filename);
resultpath = [scriptpath filesep '..' filesep '..' filesep ...
    '2_Prep_FEniCS_results' filesep];
settingspath = [scriptpath filesep '..' filesep '..' filesep ...
    '1_Efield_results_adv' filesep];

fileID1=fopen([resultpath 'amplitudes.txt'],'w');

if length(freq)==1
parampath = [settingspath 'settings_' modelType '_' num2str(freq) 'MHz.txt'];
paramMat = fopen(parampath);
for i=1:nbrEfields
    if i ==1
    for j =1:2
    fscanf(paramMat,'%s',1);
    end
    end
    amp{i} = fscanf(paramMat,'%s',1);
    fscanf(paramMat,'%s',1);
    fprintf(fileID1,'%f\r\n',str2num(amp{i}));
end
end

%göra om pwrlim till amp och spara som txt

fileID2=fopen([resultpath 'ampLimit.txt'],'w');
ampLimit = sqrt(2*PwrLimit*150); % 150 W is the max power per antenna
fprintf(fileID2,'%f\r\n',ampLimit);

end