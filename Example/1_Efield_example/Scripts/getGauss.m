function [ G ] = getGauss( matSize, mu, sigma )
%Creates a 3 dimensional matrix of a nomalized Gaussian distribution
%in the first octant(only non-negative x, y and z values).

%Create the x y z values
xvekt=1:matSize(1);
yvekt=1:matSize(2);
zvekt=1:matSize(3);

%Meshgrid
[X,Y,Z]=meshgrid(xvekt,yvekt,zvekt);

%Calculate the Gaussian distribution
G=exp(-(((mu(1)-X).^2+(mu(2)-Y).^2+(mu(3)-Z).^2)/2)/sigma^2);
%Normilize the Guassian matrix
G=G/sum(sum(sum(G)));
end

