function [ E_opt ] = optimize_M2( E, weight1, weight2 )
%OPTIMIZE_M1 Summary of this function goes here
%   Detailed explanation goes here
    narginchk(2,3);
    if ~isa(weight1,'Yggdrasil.Octree')
        weight1 = Yggdrasil.Octree(weight1);
    end

    if nargin ~= 2 && ~isa(weight2,'Yggdrasil.Octree')
        weight2 = Yggdrasil.Octree(weight2);
    end
    
    % Create the two square matrices for the gen. eigenvalue representation
    n = length(E);
    A = zeros(n,n,n,n);
    B = A;
    doneWith = A;

    % Calculate all integral values
    for i = 1:n % pick first Efield
        for j = 1:n % pick second Efield
            P1 = scalar_prod(E{i},E{j});
            denom_P1 = weight(P1,weight1);
            if nargin == 2
                nume_P1 = P1;
            else
                nume_P1 = weight(P_1,weight2);
            end    
            for l = 1:n % pick thrid Efield
                for k = 1:n % pick fourth Efield
                    if doneWith(k,l,i,j)
                        A(i,j,k,l) = A(k,l,i,j);
                        B(i,j,k,l) = B(k,l,i,j);
                    elseif doneWith(j,i,l,k)
                        A(i,j,k,l) = conj(A(j,i,l,k));
                        B(i,j,k,l) = conj(B(j,i,l,k));
                    elseif doneWith(l,k,j,i)
                        A(i,j,k,l) = conj(A(l,k,j,i));
                        B(i,j,k,l) = conj(B(l,k,j,i));
                    else
                        P2 = scalar_prod(E{k},E{l});
                        A(i,j,k,l) = integral(denom_P1,P2)/1e9;
                        B(i,j,k,l) = integral(nume_P1,P2)/1e9;
                    end
                    doneWith(i,j,k,l) = 1;
                end
            end
        end
    end
    
    P_nom = CPoly(0);
    P_den = CPoly(0);
    % Create the polynomials
    for i = 1:n % pick first Efield
        for j = 1:n % pick second Efield
            for k = 1:n % pick first Efield
                for l = 1:n % pick second Efield
                    P_nom = P_nom + CPoly(B(i,j,k,l),[-i;j;-k;l]);
                    P_den = P_den + CPoly(A(i,j,k,l),[-i;j;-k;l]);
                end
            end
        end
    end
    
    [reZ,imZ] = CPoly.optimize_ratio(P_nom,P_den);
    
    largest = 0;
    for i = 1:n
        largest = max([largest, abs(coeff(reZ,imZ,i))]);
    end
    
    KEYS = reZ.keys;
    for i = 1:length(KEYS)
        k = KEYS{i};
        reZ(k) = reZ(k)/largest;
    end
    KEYS = imZ.keys;
    for i = 1:length(KEYS)
        k = KEYS{i};
        imZ(k) = imZ(k)/largest;
    end
    E_opt = coeff(reZ,imZ,1)*E{1};
    for i = 2:length(E)
        E_opt = E_opt + coeff(reZ,imZ,i)*E{i};
    end
end

function [Z] = coeff(reZ,imZ,id)
    Z = 0;
    if isKey(reZ,id)
        Z = Z + reZ(id);
    end
    if isKey(imZ,id)
        Z = Z + 1i*imZ(id);
    end
end
