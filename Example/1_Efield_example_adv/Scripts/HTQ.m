function q = HTQ(P, tumor, per)

if isa(P, 'Yggdrasil.Octree')
    P = P.to_mat();
end
if isa(tumor, 'Yggdrasil.Octree')
    tumor = tumor.to_mat();
end

PLDtumor=P.*tumor;
[hasValues, ~]=find(PLDtumor);
PLDtumor_vec=reshape(tumorMatrix,size(P,1)*size(P,2)*size(P,3),1);
PLDtumor_vec=sort(PLDtumor_vec,'descend');
PLDtumor_vec=PLDtumor_vec(1:length(hasValues));
meanPLDtumor = mean(PLDtumor_vec);

PLDhealthy=P.*(~tumor);
[hasValues, ~]=find(PLDhealthy);
PLDhealthy_vec=reshape(tumorMatrix,size(P,1)*size(P,2)*size(P,3),1);
PLDhealthy_vec=sort(PLDhealthy_vec,'descend');
PLDhealthy_vec=PLDhealthy_vec(1:length(hasValues));
PLDv1=mean(PLDhealthy_vec(1:round(length(sortHealthyPLD_vec).*per)));

q=double(meanPLDtumor/PLDv1);

%--old version--
% 
% denom=Yggdrasil.Math.scalar_prod_integral(P,tumor);
% 
% if isa(P, 'Yggdrasil.Octree')
%     P = P.to_mat();
% end
% if isa(tumor, 'Yggdrasil.Octree')
%     tumor = tumor.to_mat();
% end
%
% vol = ceil(head_minus_tumor_vol*per);
% B = P(~tumor & P ~=0);
% while length(B)>=2*vol
%     medB = median(B);
%     B = B(B>medB);
%     if length(B)<vol
%         B = [B; medB*ones(vol-length(B),1)];
%     end
% end
% B = sort(B,'descend');
% nom = sum(B(1:vol));
% 
% q = double(nom/denom);
end