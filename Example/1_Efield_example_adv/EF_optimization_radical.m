function [] = EF_optimization_radical(freq, nbrEfields, modelType, goal_function)
%[P] = EF_OPTIMIZATION()
%   Calculates a optimization of E-fields to maximize power in tumor while
%   minimizing hotspots. The resulting power loss densities and antenna settings  will then be
%   saved to the results folder.
% goal_function is a string 'M1', 'M2' or 'HTQ'

% Ensure Yggdrasil is available
if strcmp(which('Yggdrasil.Octree'), '')
    error('Need addpath to the self-developed package ''Yggdrasil''.')
end

% Get root path
filename = which('EF_optimization_radical');
[rootpath,~,~] = fileparts(filename);
datapath = [rootpath filesep '..' filesep '1_Efield_example' filesep 'Data'];
scriptpath = [rootpath filesep 'Scripts'];
optpath = [rootpath filesep '..' filesep 'opt'];
addpath(scriptpath, optpath)
resultpath = [rootpath filesep '..' filesep '1_Efield_results_adv'];
if ~exist(resultpath,'dir')
    disp(['Creating result folder at ' resultpath]);
    [success,message,~] = mkdir(resultpath);
    if ~success
        error(message);
    end
end

% Initialize load_maestro to be able to load E_fields
Efilename = @(f,a)[datapath filesep 'Efield_' num2str(f) 'MHz_A' num2str(a) '_' modelType];
sigma     = @(f)[datapath filesep 'sigma_' modelType '_' num2str(f) 'MHz'];
rel_eps = 0.1; %0.05 för erik
Yggdrasil.Utils.Efield.load_maestro('init', Efilename, sigma, rel_eps);

% Convert sigma from .txt to a volumetric matrix
frequencies = freq;
n = nbrEfields; %Nmbr of Antennas
f_1 = frequencies(1);

% Convert sigma from .txt to a volumetric matrix
addpath([datapath filesep '..' filesep 'Scripts'])
for f = frequencies
    create_sigma_mat(f, modelType);
end
% Create Efield objects for two frequencies
e_f1 = cell(1,n);

for i = 1:n
    e_f1{i} = Yggdrasil.SF_Efield(f_1, i);
end

% Load information of where tumor is, and healthy tissue
tissue_mat = Yggdrasil.Utils.load([datapath filesep 'tissue_mat_' modelType '.mat']);
if startsWith(modelType, 'duke')==1
    water_ind = 81;
    ext_air_ind = 1;
    int_air_ind = 2;
    tumor_ind = 80;
elseif modelType == 'child'
    water_ind = 30;
    ext_air_ind = 1;
    int_air_ind = 5;
    tumor_ind = 9;
end
healthy_tissue_mat = tissue_mat~=water_ind & ...
    tissue_mat~=ext_air_ind & ...
    tissue_mat~=tumor_ind & ...
    tissue_mat~=int_air_ind;

tumor_oct = Yggdrasil.Octree(single(tissue_mat==tumor_ind));
healthy_tissue_oct = Yggdrasil.Octree(single(healthy_tissue_mat));
tumor_mat = tissue_mat==tumor_ind;

e_tot = e_f1{1};
for i = 2:length(e_f1)
    e_tot = e_tot + e_f1{i};
end

disp('---PRE-OPTIMIZATION---')
% disp('ANTENNA - AMPLITUDE - PHASE')
% AntennaSettings = zeros(n,3);
% wave = e_tot.C.values;
% ant = e_tot.C.keys;
% for i=1:length(wave)
%     AntennaSettings(i,1) = abs(wave(i));
%     AntennaSettings(i,2) = 0; %It is 0 otherwise, but technically its 45
% end
% AntennaSettings = [ant' AntennaSettings(:,1) AntennaSettings(:,2)]
p_tot = abs_sq(e_tot);

disp(strcat('Pre-optimization, HTQ= ',num2str(HTQ_radical(p_tot,tumor_mat,healthy_tissue_mat))))
%disp(strcat('Pre-optimization, M1= ',num2str(M1_radical(p_tot,tumor_oct,healthy_tissue_oct))))

switch goal_function
    case 'M1'
        %----------------------- M1 -----------------------------
        %Optimization step.
        [X, E_opt] = OptimizeM1_radical(e_f1,tumor_oct,healthy_tissue_oct);
        
        %End of optimization, cancelling untouched
        e_tot_opt = E_opt{1};
        for i=2:length(E_opt)
            e_tot_opt = e_tot_opt + E_opt{i};
        end
        p_opt = abs_sq(e_tot_opt);
        
        disp('---POST-OPTIMIZATION--M1-')
        
        %disp(strcat('Post-optimization, M1= ',num2str(M1_radical(p_opt,tumor_oct,healthy_tissue_oct))))
        disp(strcat('Post-optimization, HTQ after M1 = ',num2str(HTQ_radical(p_opt,tumor_mat,healthy_tissue_mat))))
        mat_1 = p_opt.to_mat;
        [~,~,TC] = getHTQ(tissue_mat, mat_1, modelType);
        disp(['Post-optimization, TC25 after M1 = ' num2str(TC(1))])
        disp(['TC50 = ' num2str(TC(2))])
        disp(['TC75 = ' num2str(TC(3))])
        
        wave_opt = e_tot_opt.C.values;
        ant_opt = e_tot_opt.C.keys;
        
        for i=1:length(wave_opt)
            Amp(i) = abs(wave_opt(i));
            Pha(i) = rad2deg(phase(wave_opt(i)));
        end
        
        disp('ANTENNA SETTINGS')
        disp('ANTENNA - AMPLITUDE - PHASE')
        
        settings_1 = [ant_opt' Amp' Pha']; %For first frequency
        [values,order] = sort(settings_1(:,1));
        sortedsettings_1 = settings_1(order,:)
        settings_m1 = [sortedsettings_1(:,2), sortedsettings_1(:,3)];
        
        writeSettings(resultpath, settings_m1, 1, modelType, f_1);
        save([resultpath filesep 'P_M1_' modelType '_' num2str(freq) 'MHz.mat'], 'mat_1', '-v7.3');
        %save([resultpath filesep 'settings_' modelType '_' num2str(freq) 'MHz.mat'], 'settings_1', '-v7.3');
        
    case 'M2'
        %----------------------------- M2 ------------------------------
        disp('OPTIMIZATION - M2')
        
        [X, E_opt] = OptimizeM2_radical(e_f1,tumor_oct,healthy_tissue_oct);
        
        e_tot_opt_m2 = E_opt{1};
        for i=2:length(E_opt)
            e_tot_opt_m2 = e_tot_opt_m2 + E_opt{i};
        end
        
        p_opt_m2 = abs_sq(e_tot_opt_m2);
        
        %disp(strcat('Post-optimization, M2= ',num2str(M2_radical(p_opt_m2,tumor_oct))))
        disp(strcat('Post-optimization, HTQ after M2 = ',num2str(HTQ_radical(p_opt_m2,tumor_mat,healthy_tissue_mat))))
        mat_2 = p_opt_m2.to_mat;
        [~,~,TC] = getHTQ(tissue_mat, mat_2, modelType);
        disp(['Post-optimization, TC25 after M2 = ' num2str(TC(1))])
        disp(['TC50 = ' num2str(TC(2))])
        disp(['TC75 = ' num2str(TC(3))])
                
        wave_opt = e_tot_opt_m2.C.values;
        ant_opt = e_tot_opt_m2.C.keys;
        
        for i=1:length(wave_opt)
            Amp(i) = abs(wave_opt(i));
            Pha(i) = rad2deg(phase(wave_opt(i)));
        end
        
        disp('ANTENNA SETTINGS')
        disp('ANTENNA - AMPLITUDE - PHASE')
        
        settings_2 = [ant_opt' Amp' Pha']; %For first frequency
        [values,order] = sort(settings_2(:,1));
        sortedsettings_2 = settings_2(order,:)
        settings_m2 = [sortedsettings_2(:,2), sortedsettings_2(:,3)];
        
        writeSettings(resultpath, settings_m2, 1, modelType, f_1);
        save([resultpath filesep 'P_M2' modelType '_' num2str(freq) 'MHz.mat'], 'mat_2', '-v7.3');
        %save([resultpath filesep 'settings_' modelType '_' num2str(freq) 'MHz.mat'], 'settings_2', '-v7.3');
        
    case 'HTQ'
        % ------------------------------- HTQ -----------------------------
        
        disp('OPTIMIZATION - HTQ')
        
        [X, E_opt] = OptimizeHTQ_radical(e_f1,tumor_oct,healthy_tissue_oct);
        e_tot_opt_htq = E_opt{1};
        for i=2:length(E_opt)
            e_tot_opt_htq = e_tot_opt_htq + E_opt{i};
        end
        
        p_opt_htq = abs_sq(e_tot_opt_htq);
        
        disp(strcat('Post-optimization, HTQ= ',num2str(HTQ_radical(p_opt_htq,tumor_mat,healthy_tissue_mat))))
        mat_3 = p_opt_htq.to_mat;
        [~,~,TC] = getHTQ(tissue_mat, mat_3, modelType);
        disp(['Post-optimization, TC25 after HTQ = ' num2str(TC(1))])
        disp(['TC50 = ' num2str(TC(2))])
        disp(['TC75 = ' num2str(TC(3))])
        
        %Find antenna settings of active E-fields
        wave_opt = e_tot_opt_htq.C.values;
        ant_opt = e_tot_opt_htq.C.keys;
        
        for i=1:length(wave_opt)
            Amp(i) = abs(wave_opt(i));
            Pha(i) = rad2deg(phase(wave_opt(i)));
        end
        
        disp('ANTENNA SETTINGS')
        disp('ANTENNA - AMPLITUDE - PHASE')
        
        settings_3 = [ant_opt' Amp' Pha']; %For first frequency
        [values,order] = sort(settings_3(:,1));
        sortedsettings_3 = settings_3(order,:)
        settings_HTQ = [sortedsettings_3(:,2), sortedsettings_3(:,3)];
        
        writeSettings(resultpath, settings_htq, 1, modelType, f_1);
        save([resultpath filesep 'P_HTQ_' modelType '_' num2str(freq) 'MHz.mat'], 'mat_3', '-v7.3');
        %save([resultpath filesep 'settings_' modelType '_' num2str(freq) 'MHz.mat'], 'settings_3', '-v7.3');
        
end
%----------------------------------------------------------------------
close all
% Empty load_maestro
Yggdrasil.Utils.Efield.load_maestro('empty');
end