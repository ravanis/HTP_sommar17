function [] = EF_optimizationRadical()
%[P] = EF_OPTIMIZATION()
%   Calculates a optimization of E-fields to maximize power in tumor while
%   minimizing hotspots. The resulting power loss densities and antenna settings  will then be
%   saved to the results folder.

%This version do not use select_best, increasing the time (immensely) to execute this
close all
clear all
clc

% Ensure Yggdrasil is available
if strcmp(which('Yggdrasil.Octree'), '')
    error('Need addpath to the self-developed package ''Yggdrasil''.')
end

% Get root path
filename = which('EF_optimization');
[rootpath,~,~] = fileparts(filename);
datapath = [rootpath filesep 'Data'];
scriptpath = [rootpath filesep 'Scripts'];
addpath(scriptpath)

% Initialize load_maestro to be able to load E_fields
Efilename = @(f,a)[datapath filesep 'Efield_F' num2str(f) '_A' num2str(a)];
sigma     = @(f)[datapath filesep 'sigma_' num2str(f)];
rel_eps = 0.05;
Yggdrasil.Utils.Efield.load_maestro('init', Efilename, sigma, rel_eps);

% Convert sigma from .txt to a volumetric matrix
frequencies = [450 800];
n = 10; %Nmbr of Antennas
f_1 = frequencies(1);

% Convert sigma from .txt to a volumetric matrix
for f = frequencies
    create_sigma_mat(f);
end
% Create Efield objects for two frequencies
e_f1 = cell(1,n);

for i = 1:n
    e_f1{i} = Yggdrasil.SF_Efield(f_1, i);
end

% Load information of where tumor is, and healthy tissue

tissue_mat = Yggdrasil.Utils.load([rootpath filesep 'Data' filesep 'tissue_mat.mat']);
water_ind = 81;
ext_air_ind = 1;
int_air_ind = 2;
healthy_tissue_mat = tissue_mat~=water_ind & ...
    tissue_mat~=ext_air_ind & ...
    tissue_mat~=80 & ...
    tissue_mat~=int_air_ind;

tumor_oct = Yggdrasil.Octree(single(tissue_mat==80));
healthy_tissue_oct = Yggdrasil.Octree(single(healthy_tissue_mat));
tumor_mat = tissue_mat==80;


e_tot = e_f1{1};
for i = 2:length(e_f1)
    e_tot = e_tot + e_f1{i};
end


disp('---PRE-OPTIMIZATION---')
disp('AMPLITUDE - PHASE - ANTENNA')
AntennaSettings = zeros(n,3);
wave = e_tot.C.values;
ant = e_tot.C.keys;

for i=1:length(wave)
    AntennaSettings(i,1) = abs(wave(i));
    AntennaSettings(i,2) = 45; %It is 0 otherwise, but technically its 45
end

AntennaSettings = [AntennaSettings(:,1) AntennaSettings(:,2) ant']
p_tot = abs_sq(e_tot);

disp(strcat('Pre-optimization, HTQ= ',num2str(HTQ(p_tot,tumor_mat,healthy_tissue_mat))))
disp(strcat('Pre-optimization, M1= ',num2str(M1(p_tot,tumor_oct,healthy_tissue_oct))))

%Optimization step.

[X, E_opt] = OptimizeM1(e_f1,tumor_oct,healthy_tissue_oct);


%End of optimization, cancelling untouched
e_tot_opt = E_opt{1};
for i=2:length(E_opt)
    e_tot_opt = e_tot_opt + E_opt{i};
end

p_opt = abs_sq(e_tot_opt);

disp('---POST-OPTIMIZATION--M1-')

disp(strcat('Post-optimization, M1= ',num2str(M1(p_opt,tumor_oct,healthy_tissue_oct))))
wave_opt = e_tot_opt.C.values;
ant_opt = e_tot_opt.C.keys;

for i=1:length(wave_opt)
    Amp(i) = abs(wave_opt(i));
    Pha(i) = rad2deg(phase(wave_opt(i)));
end

disp('ANTENNA SETTINGS')
disp('AMPLITUDE - PHASE - ANTENNA')

settings_1 = [Amp' Pha' ant_opt']; %For first frequency
settings_1 = sort(settings_1,1);

disp('OPTIMIZATION - M2')

[X, E_opt] = OptimizeM1(e_f1,tumor_oct,healthy_tissue_oct);

e_tot_opt_m2 = E_opt{1};
for i=2:length(E_opt)
    e_tot_opt_m2 = e_tot_opt_m2 + E_opt{i};
end

p_opt_m2 = abs_sq(e_tot_opt_m2);

wave_opt = e_tot_opt_m2.C.values;
ant_opt = e_tot_opt_m2.C.keys;

for i=1:length(wave_opt)
    Amp(i) = abs(wave_opt(i));
    Pha(i) = rad2deg(phase(wave_opt(i)));
end

disp('ANTENNA SETTINGS')
disp('AMPLITUDE - PHASE - ANTENNA')

settings_2 = [Amp' Pha' ant_opt']; %For first frequency
settings_2 = sort(settings_1,1);

disp(strcat('Post-optimization, M2= ',num2str(M2(p_opt_m2,tumor_oct))))


disp('OPTIMIZATION - HTQ')

[X, E_opt] = OptimizeHTQ(e_f1,tumor_oct,healthy_tissue_oct);
e_tot_opt_htq = E_opt{1};
for i=2:length(E_opt)
    e_tot_opt_htq = e_tot_opt_htq + E_opt{i};
end

p_opt_htq = abs_sq(e_tot_opt_htq);

disp(strcat('Post-optimization, HTQ= ',num2str(HTQ(p_opt_htq,tumor_mat,healthy_tissue_mat))))
%Find antenna settings of active E-fields
wave_opt = e_tot_opt_htq.C.values;
ant_opt = e_tot_opt_htq.C.keys;

for i=1:length(wave_opt)
    Amp(i) = abs(wave_opt(i));
    Pha(i) = rad2deg(phase(wave_opt(i)));
end

disp('ANTENNA SETTINGS')
disp('AMPLITUDE - PHASE - ANTENNA')

settings_3 = [Amp' Pha' ant_opt'] %For first frequency
settings_3 = sort(settings_3,1);

mat_1 = p_opt.to_mat;
mat_2 = p_opt_htq.to_mat;
mat_3 = p_opt_m2.to_mat;


resultpath = [rootpath filesep '..' filesep '1_Efield_results_radical'];

if ~exist(resultpath,'dir')
    disp(['Creating result folder at ' resultpath]);
    [success,message,~] = mkdir(resultpath);
    if ~success
        error(message);
    end
end

writeSettings(resultpath,settings_1,1,'cylinder',f_1);
writeSettings(resultpath,settings_2,1,'cylinder',f_1);
writeSettings(resultpath,settings_3,1,'cylinder',f_1);


save([resultpath filesep 'P_m1.mat'], 'mat_1', '-v7.3');
save([resultpath filesep 'settings_1.mat'], 'settings_1', '-v7.3');

save([resultpath filesep 'P_m2.mat'], 'mat_2', '-v7.3');
save([resultpath filesep 'settings_1.mat'], 'settings_1', '-v7.3');

save([resultpath filesep 'P_htq.mat'], 'mat_3', '-v7.3');
save([resultpath filesep 'settings_1.mat'], 'settings_1', '-v7.3');

% Empty load_maestro
Yggdrasil.Utils.Efield.load_maestro('empty');
end