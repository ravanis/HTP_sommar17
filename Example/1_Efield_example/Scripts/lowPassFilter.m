function [ mat ] = lowPassFilter( mat, smoothVol )
%Does a "smooth" cut with a gauss distribution. Uses a 
%convulotion instead of working in the frequency plane.

%Converts the smoothing Volume to sigma (radius of the sphere)
sigma=(3*smoothVol/(4*pi))^(1/3);
%4*sigma covers all of the distibution
matSize=ceil([4*sigma, 4*sigma, 4*sigma]);

%The center of the Gauss distr. 
mu=findCenter(matSize);

%gets the Gauss distrib
G=getGauss(matSize, mu, sigma);

disp('lowPassFilter: convolutes...')
mat=convnfft(mat,G,'same',[],true);

end

