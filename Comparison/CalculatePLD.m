% NOTE: Put this file in the same folder as EF_optimization and use 
%run_1 to run this file, so that Yggdrasil comes automatically. 

freq=[400 600 800]; % Enter frequency in MHz
addpath D:\HTP_sommar17\+Yggdrasil
folderPathEfields=[pwd,'\Example\1_Efield_example\Data\']; 
folderPathScripts = [pwd,'Example\1_Efield_example\Scripts\']; 
create_sigma_mat(freq(1));
create_sigma_mat(freq(2));
create_sigma_mat(freq(3));
load([folderPathEfields 'sigma_' num2str(freq(1)) '.mat']);
load([folderPathEfields 'sigma_' num2str(freq(2)) '.mat']);
load([folderPathEfields 'sigma_' num2str(freq(3)) '.mat']);
e_tot=zeros((size(sigma_mat)));

% Load Efields for each antenna and add them
for i=1:16
    load([folderPathEfields, 'Efield_F', num2str(freq(1)),'_A',num2str(i),'.mat'])
    e=sum(mat,4);
    e_tot=e_tot+e;
end

dim = size(e); 
e_tot_tilde=zeros((size(sigma_mat)));
for i=1:16
    load([folderPathEfields, 'Efield_F', num2str(freq(2)),'_A',num2str(i),'.mat'])
    e_t=sum(mat,4);
    e_tot_tilde=e_tot_tilde+e_t;
end

e_tot_tilde_t=zeros((size(sigma_mat)));
for i=1:16
    load([folderPathEfields, 'Efield_F', num2str(freq(3)),'_A',num2str(i),'.mat'])
    e_t_t=sum(mat,4);
    e_tot_tilde_t=e_tot_tilde_t+e_t_t;
end

% Calculate (total) Power loss density


load('D:\HTP_sommar17\Example\1_Efield_example\Data\sigma_400.mat');
P_1 = sum(abs(e_tot).^2,4).*sigma_mat/2;
load('D:\HTP_sommar17\Example\1_Efield_example\Data\sigma_600.mat');
P_2 = sum(abs(e_tot_tilde).^2,4).*sigma_mat/2;
load('D:\HTP_sommar17\Example\1_Efield_example\Data\sigma_800.mat');
P_3 = sum(abs(e_tot_tilde_t).^2,4).*sigma_mat/2;

hold on 
figure
title('400Mhz')
mesh(P_1(:,:,195))
figure
title('600Mhz')
mesh(P_2(:,:,195))
figure
title('800Mhz')
mesh(P_3(:,:,195))

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