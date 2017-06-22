function EF_optimization_M2_2freq(freq_vec, nbrEfields, modelType)

%   Calculates a optimization of E-fields to maximize power in tumor while
%   minimizing hotspots. The resulting power loss density will then be
%   saved to the results folder.

% freq_vec is a vector with TWO frequencies

% Ensure Yggdrasil is available
if strcmp(which('Yggdrasil.Octree'), '')
    error('Need addpath to the self-developed package ''Yggdrasil''.')
end

% Get root path
filename = which('EF_optimization_adv');
[rootpath,~,~] = fileparts(filename);
resultpath = [rootpath filesep '..' filesep '1_Efield_results_adv'];
datapath = [rootpath filesep '..' ...
    filesep '1_Efield_example' ...
    filesep 'Data'];
scriptpath = [rootpath filesep 'Scripts'];
addpath(scriptpath)

% Create results folder
if ~exist(resultpath,'dir')
    disp(['Creating result folder at ' resultpath]);
    [success,message,~] = mkdir(resultpath);
    if ~success
        error(message);
    end
end

% Initialize load_maestro to be able to load E_fields
Efilename = @(f,a)[datapath filesep 'Efield_' num2str(f) 'MHz_A' num2str(a) '_' modelType];
sigma     = @(f)[datapath filesep 'sigma_adv_' modelType '_' num2str(f) 'MHz'];
rel_eps = 0.1;
Yggdrasil.Utils.Efield.load_maestro('init', Efilename, sigma, rel_eps);

frequencies = freq_vec;
n = length(frequencies);

% Convert sigma from .txt to a volumetric matrix
for f = frequencies
    create_sigma_mat_adv(f, modelType);
end
htq_mat = zeros(n);
m1_mat = zeros(n);
m2_mat = zeros(n);

% Load information of where tumor is
tissue_mat = Yggdrasil.Utils.load([datapath filesep 'tissue_mat_' modelType '.mat']);

if startsWith(modelType, 'duke') == 1
    tumor_oct = Yggdrasil.Octree(single(tissue_mat==80));
    water_ind = 81;
    ext_air_ind = 1;
    int_air_ind = 2;
elseif modelType == 'child'
    tumor_oct = Yggdrasil.Octree(single(tissue_mat==9));
    water_ind = 30;
    ext_air_ind = 1;
    int_air_ind = 5;
else
    error('Model type not available. Enter your model indices in EF_optimization_adv')
end

tumor_mat = to_mat(tumor_oct);
head_mat = tissue_mat~=water_ind & ...
    tissue_mat~=ext_air_ind & ...
    tissue_mat~=int_air_ind;
head_vol = sum(head_mat(:));
tumor_vol = tumor_oct.integral();
head_minus_tumor_vol = head_vol - tumor_vol;

% Create the E-fields used during optimization
e_primary = cell(n,1);
e_secondary = cell(n,1);
for j = 1:n
    % Create Efield objects
    num_ant = nbrEfields;
    e_j = cell(num_ant,1);
    for i = 1:num_ant
        e_j{i}  = Yggdrasil.SF_Efield(frequencies(j), i);
    end
    disp(['Loading E-field at frequency ' num2str(frequencies(j)) '.'])
    e_primary{j} = select_best(e_j,3,tumor_oct);
    e_j = cell(num_ant,1);
    for i = 1:num_ant
        e_j{i}  = Yggdrasil.SF_Efield(frequencies(j), i, 2);
    end
    e_secondary{j} = select_best(e_j,3,tumor_oct);
end

optimize M2
for j = 1:n
    for jtilde = j:n
        disp(['Optimizing M2 on (' num2str(j) ...
            ',' num2str(jtilde) ') out of ('...
            num2str(n) ',' num2str(n) ').'])
        N = length(e_primary{j});
        M = length(e_secondary{jtilde});

        e = cell(N+M,1);
        for i = 1:N
            e{i} = e_primary{j}{i};
        end
        for i = 1:M
            e{i+N} = e_secondary{jtilde}{i};
        end
        e_opt = optimize_M2(e,tumor_oct);
        p_opt = abs_sq(e_opt);

        quad_htq_mat(j,jtilde) = HTQ(p_opt_mat,tumor_oct,head_minus_tumor_vol,0.01)
        quad_m1_mat(j,jtilde) = M_1(p_opt, tumor_oct)*tumor_vol/head_vol
        quad_m2_mat(j,jtilde) = M_2(p_opt, tumor_oct)*(tumor_vol^2)/head_vol
    end
end

% % starting values for finding best combination
% bestHTQ = [100 0 0]; % starting value for HTQ and indeces
% best_e_opt_main = optimize_M1(e_primary{1},tumor_oct);
% best_p_opt_final = abs_sq(best_e_opt_main);
% best_e_opt_alt = optimize_M1(e_secondary{1},tumor_oct,best_p_opt_final);
% time_settings=zeros(2,1);

% % save best p_opt
% save([resultpath filesep 'P_' modelType '_1_' num2str(frequencies(bestHTQ(2))) ...
%     '_2_' num2str(frequencies(bestHTQ(3))) 'MHz.mat'], 'best_p_opt_final')

% % save settings_complex
% amp1 = best_e_opt_main.C.values;
% amp2 = best_e_opt_alt.C.values;
% ant1 = best_e_opt_main.C.keys;
% ant2 = best_e_opt_alt.C.keys;
% 
% settings_complex1=zeros(nbrEfields,1);
% settings_complex2=zeros(nbrEfields,1);
% settings_complex1(ant1) = amp1;
% settings_complex2(ant2) = amp2;
% 
% % saves complex antenna settings and time settings
% save([resultpath filesep 'time_settings_' modelType '_1_' num2str(frequencies(bestHTQ(2))) ...
%     '_2_' num2str(frequencies(bestHTQ(3))) 'MHz.mat'], 'time_settings', '-v7.3');
% save([resultpath filesep 'settings_complex_' modelType '_1_' num2str(frequencies(bestHTQ(2))) ...
%     '_2_' num2str(frequencies(bestHTQ(3))) 'MHz_(1).mat'], 'settings_complex1', '-v7.3');
% save([resultpath filesep 'settings_complex_' modelType '_1_' num2str(frequencies(bestHTQ(2))) ...
%     '_2_' num2str(frequencies(bestHTQ(3))) 'MHz_(2).mat'], 'settings_complex2', '-v7.3');

% Empty load_maestro
Yggdrasil.Utils.Efield.load_maestro('empty');
end