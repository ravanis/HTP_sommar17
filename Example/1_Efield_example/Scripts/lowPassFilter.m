function [ mat ] = lowPassFilter( mat, smoothVol )
%Cuts away the highest frequencies in a frequency. Does a "smooth" cut with
%a gauss distribution. Uses a convulotion instead of working in the
%frequency plane.

%Converts the pasFreq to a proper variance sigma (INTE KLAR, needs math)
sigma=(3*smoothVol/(4*pi))^(1/3);
matSize=ceil([4*sigma, 4*sigma, 4*sigma]);

%The center of the Gauss distr. 
mu=findCenter(matSize);

%gets the Gauss distrib
G=getGauss(matSize, mu, sigma);

disp('lowPassFilter: convolutes...')
mat=convnfft(mat,G,'same',[],true);

end

