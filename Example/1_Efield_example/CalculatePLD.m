% Calcualte PLD from Efields in Data Folder and plot.
% NOTE: Use run_1 to run this file, so that Yggdrasil comes automatically.
% Alternative: run addpath(genpath('HTP_sommar17')) from folder over HTP 

freq=[400]; % Enter frequencies in MHz

filename=which('CalculatePLD');
[scriptpath,~,~] = fileparts(filename);
folderPathEfields=[scriptpath,'\Data\']; 

for i=1:length(freq)
create_sigma_mat(freq(i));
end

% Load Efields for each antenna and add them
e_tot_400=zeros((size(sigma_mat)));
for i=1:16
    load([folderPathEfields, 'Efield_F', num2str(freq(1)),'_A',num2str(i),'.mat'])
    e=sum(mat,4);
    e_tot_400=e_tot_400+e;
end
 
e_tot_600=zeros((size(sigma_mat)));
for i=1:16
    load([folderPathEfields, 'Efield_F', num2str(freq(2)),'_A',num2str(i),'.mat'])
    e=sum(mat,4);
    e_tot_600=e_tot_600+e;
end

e_tot_800=zeros((size(sigma_mat)));
for i=1:16
    load([folderPathEfields, 'Efield_F', num2str(freq(3)),'_A',num2str(i),'.mat'])
    e=sum(mat,4);
    e_tot_800=e_tot_800+e;
end

% Calculate (total) Power loss density

load([folderPathEfields 'sigma_' num2str(freq(1)) '.mat']);
P_400 = abs(e_tot_400).^2.*sigma_mat/2;
load([folderPathEfields 'sigma_' num2str(freq(2)) '.mat']);
P_600 = abs(e_tot_600).^2.*sigma_mat/2;
load([folderPathEfields 'sigma_' num2str(freq(3)) '.mat']);
P_800 = abs(e_tot_800).^2.*sigma_mat/2;

hold on 
figure
title('400Mhz')
mesh(P_400(:,:,195))
figure
title('600Mhz')
mesh(P_600(:,:,195))
figure
title('800Mhz')
mesh(P_800(:,:,195))

% dim = size(e);
% for i=1:dim(3)
%     P_diff_2(i) = norm(P(:,:,i),2);
%     P_diff_1(i) = norm(P(:,:,i),1);
%    
% end
% figure
% hist(P_diff_2)
% xlabel('Z-value')
% ylabel('L2 norm of the difference of power difference')
% figure
% hist(P_diff_1)
% xlabel('Z-value')
% ylabel('L1 norm of the difference of power difference')



%results = [norm(P,1),norm(P,2),norm(P,inf)];

%Calculate the difference in power loss density for every xy - plane
% P = zeros(dim(1),2);
% 
% 
% for i=1:dim(1)
%     P(i) = sum(abs(e_tot(:,:,i)).^2,4).*sigma_mat/2 - sum(abs(e_tot_tilde(:,:,i)).^2,4).*sigma_mat/2;
% end

%Subtract every element in the vectorfield componentwise and then plot it
% hold on
% 
% %Real part of the Efield
% e = e_tot_tilde-e_tot;
% e_r = real(e);
% 
% for i_1=1:dim(1)
%     for i_2=1:dim(2)
%         for i_3=1:dim(3)
%             quiver3(e_r(i_1,i_2,i_3,1),e_r(i_1,i_2,i_3,2),e_r(i_1,i_2,i_3,3),i_1,i_2,i_3)
%         end
%     end
% end
% 
% %Imaginary part of the Efield
% e_i = imag(e);
% 
% for i_1=1:dim(1)
%     for i_2=1:dim(2)
%         for i_3=1:dim(3)
%             quiver3(e_i(i_1,i_2,i_3,1),e_i(i_1,i_2,i_3,2),e_i(i_1,i_2,i_3,3),i_1,i_2,i_3)
%         end
%     end
% end        


clear folderPath e e_tot i mat 