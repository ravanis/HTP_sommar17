% Calculate PLD from Efields in Example\1_Efield_example\Data

freq=[400 600 800]; % Enter frequency in MHz
folderPathEfields=[pwd,'\Example\1_Efield_example\Data\']; 
folderPathScripts = [pwd,'Example\1_Efield_example\Scripts\']; 
for j=freq

sigma_mat = Yggdrasil.Utils.load([folderPathEfields 'sigma_' num2str(j) '.mat']);

% Load Efields for each antenna and add them
e_tot = Yggdrasil.Utils.load([folderPathEfields, 'Efield_F', num2str(j), '_A', num2str(1), '.mat']);

for i=2:16
   e_tot=e_tot + Yggdrasil.Utils.load([folderPathEfields, 'Efield_F', num2str(j), '_A', num2str(i), '.mat']);
end

P = sum(abs(e_tot).^2,4).*sigma_mat/2;

end



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