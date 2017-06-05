% Calculate PLD from Efields in Example\1_Efield_example\Data

freq=600; % Enter frequency in MHz

folderPathEfields=[pwd,'\Example\1_Efield_example\Data\']; 
create_sigma_mat(freq);
load([folderPathEfields 'sigma_' num2str(freq) '.mat']);
e_tot=zeros((size(sigma_mat)));

% Load Efields for each antenna and add them
for i=1:16
    load([folderPathEfields, 'Efield_F', num2str(freq),'_A',num2str(i),'.mat'])
    e=sum(mat,4);
    e_tot=e_tot+e;
end

% Calculate Power loss density
P = sum(abs(e_tot).^2,4).*sigma_mat/2;

clear folderPath e e_tot i mat 