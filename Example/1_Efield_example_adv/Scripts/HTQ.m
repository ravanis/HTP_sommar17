function q = HTQ(P, tumor, head_minus_tumor_vol, per)

denom = Yggdrasil.Math.scalar_prod_integral(P, tumor);

if isa(P, 'Yggdrasil.Octree')
    P = P.to_mat();
end
if isa(tumor, 'Yggdrasil.Octree')
    tumor = tumor.to_mat();
end


vol = ceil(head_minus_tumor_vol*per);
B = P(~tumor & P ~=0);
while length(B)>=2*vol
    medB = median(B);
    B = B(B>medB);
    if length(B)<vol
        B = [B; medB*ones(vol-length(B),1)];
    end
end
B = sort(B,'descend');
nom = sum(B(1:vol));

q = double(nom/denom);
end