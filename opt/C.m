function [y] = C(Q,P,tumor)

%Pointwise multiplication of octrees is not defined. We are forced to 
%convert from Octree to ordinary matrices, then pointwise multiplication
%and then integrate

if isa(P, 'Yggdrasil.Octree')
    P = P.to_mat();
end
if isa(tumor, 'Yggdrasil.Octree')
    tumor = tumor.to_mat();
end
if isa(Q, 'Yggdrasil.Octree')
    Q = Q.to_mat();
end

nom = (Q.*P);
nom = Yggdrasil-Octree(nom);
nom = abs_sq(nom);

denom = Yggdrasil.Math.scalar_prod_integral(P, tumor)*Yggdrasil.Math.scalar_prod_integral(Q, tumor);

y = nom/denom;


end

