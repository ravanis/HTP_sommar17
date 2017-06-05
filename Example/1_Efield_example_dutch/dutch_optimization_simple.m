function dutch_optimization_simple()
%function DUTCH_OPTIMIZATION_SIMPLE()
% This function follows an optimization report from a group from Holland. 
% The output is the power loss density, normalized to 0.52W in the tumor, 
% as given by the report. This script is completely stand alone, using only
% matrix calculations to minimize errors.

% Set all filepaths
filepath = which('dutch_optimization_simple');
[rootpath,~,~] = fileparts(filepath);
resultpath = [rootpath filesep '..' filesep '1_Efield_results'];
datapath = [rootpath filesep '..' ...
                     filesep '1_Efield_example' ... 
                     filesep 'Data'];
addpath(datapath);

if ~exist(resultpath,'dir')
    mkdir(resultpath);
end
    disp('Loading data')
    % load sigma_mat
    sigma_mat = Yggdrasil.Utils.load('sigma_600.mat');

    % load E-fields
    e6 = Yggdrasil.Utils.load('Efield_F600_A6.mat');
    e7 = Yggdrasil.Utils.load('Efield_F600_A7.mat');
    e13 = Yggdrasil.Utils.load('Efield_F600_A13.mat');
    e16 = Yggdrasil.Utils.load('Efield_F600_A16.mat');
    
    disp('Loading done')
    disp('Optimizing E-fields')
    
    % Normilize Efields, power = 1W
    P = sum(abs(e6).^2, 4).*sigma_mat/2;
    e6 = e6/sqrt(sum(P(:)));

    P = sum(abs(e7).^2, 4).*sigma_mat/2;
    e7 = e7/sqrt(sum(P(:)));

    P = sum(abs(e13).^2, 4).*sigma_mat/2;
    e13 = e13/sqrt(sum(P(:)));

    P = sum(abs(e16).^2, 4).*sigma_mat/2;
    e16 = e16/sqrt(sum(P(:)));

    % Apply amplitude
    e6  = e6*sqrt(16.2);
    e7  = e7*sqrt(11.3);
    e13 = e13*sqrt(20.2);
    e16 = e16*sqrt(11.6);

    % Apply phase
    u_phasor = @(D)exp(1i*(2*pi)/360*D); % D is degree
    e6  = e6 *u_phasor( 0);
    e7  = e7 *u_phasor(50.7);
    e13 = e13*u_phasor(16.7);
    e16 = e16*u_phasor( 9.0);

    % Sum
    e_tot = e6 + e7 + e13 + e16;

    % Power loss density
    P = sum(abs(e_tot).^2,4).*sigma_mat/2;

    disp('Total power, expected: 59.2W')
    P_tot = sum(P(:))
    tissue_mat = Yggdrasil.Utils.load('tissue_mat.mat');
    disp('Power in tumor, expected 0.52W')
    P_tum = sum(P(tissue_mat==80))
    disp('Setting power in tumor to 0.52W')
    P = 0.52*P/P_tum;

    % Conversion to SI units, mm^(-3) to m^(-3)
    P = P*1E9;
    disp(['Saving P: ' resultpath filesep 'P.mat'])
    save([resultpath filesep 'P.mat'], 'P', '-v7.3');

end