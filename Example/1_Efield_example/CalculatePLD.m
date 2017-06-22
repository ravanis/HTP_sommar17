% Calcualte PLD from Efields in Data Folder and plot.
% NOTE: Use run_1 to run this file, so that Yggdrasil comes automatically.
% Alternative: run addpath(genpath('HTP_sommar17')) from folder over HTP

freq=[400]; % Enter frequencies in MHz
whichCase='duke_tongue';

filename=which('CalculatePLD');
[scriptpath,~,~] = fileparts(filename);
folderPathEfields=[scriptpath,'\Data\'];

PLD_Matlab=cell(1,length(freq));
count=0;

for j=freq
    sigma_mat = Yggdrasil.Utils.load([folderPathEfields 'sigma_' num2str(j) '.mat']);
    count=count+1;
    % Load Efields for each antenna and add them
    e_tot = Yggdrasil.Utils.load([folderPathEfields, 'Efield_', num2str(j), ...
        'MHz_A', num2str(1), '_', whichCase,'.mat']);
    for i=2:16
        e_tot=e_tot + Yggdrasil.Utils.load([folderPathEfields, 'Efield_', num2str(j), ...
            'MHz_A', num2str(i), '_', whichCase,'.mat']);
    end
    PLD_Matlab{count}=sum(abs(e_tot).^2,4).*sigma_mat/2;
end

clear folderPath* PLD e_tot i mat  scriptpath filename j dim