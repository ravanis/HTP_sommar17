function [lin_htq_mat,lin_m1_mat,lin_m2_mat, quad_htq_mat,quad_m1_mat,quad_m2_mat] = EF_optimization_adv(freq_vec, nbrEfields, modelType)
%[P] = EF_OPTIMIZATION()
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

% Initialize load_maestro to be able to load E_fields
Efilename = @(f,a)[datapath filesep 'Efield_F' num2str(f) '_A' num2str(a)];
sigma     = @(f)[datapath filesep 'sigma_adv_' modelType '_' num2str(f) 'MHz'];
rel_eps = 0.4;
Yggdrasil.Utils.Efield.load_maestro('init', Efilename, sigma, rel_eps);

frequencies = freq_vec;
n = length(frequencies);

% Convert sigma from .txt to a volumetric matrix
for f = frequencies
    create_sigma_mat_adv(f);
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
    num_ant = 16;
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

for j = 1:n
    e_opt_main = optimize_M1(e_primary{j},tumor_oct);
    p_opt = abs_sq(e_opt_main);
    p_opt_mat = to_mat(abs_sq(e_opt_main));
    for jtilde = 1:n
        disp(['Optimizing M1 on (' num2str(j) ...
            ',' num2str(jtilde) ') out of ('...
            num2str(n) ',' num2str(n) ').'])
        e_opt_alt = optimize_M1(e_secondary{jtilde},tumor_oct,p_opt);
        
        p_opt_alt_mat = to_mat(abs_sq(e_opt_alt));
        %mix_p = real(to_mat(scalar_prod(e_opt_alt,e_opt_main)));
        
        perc = 0.01;
        f = @(x)(HTQ(x^2 * p_opt_mat + (1-x)^2 * p_opt_alt_mat...
            ,tumor_mat,head_minus_tumor_vol,perc));
        % Combine them
        x = fminsearch(f,1);
        e_opt = x*e_opt_main+(1-x)*e_opt_alt;
        p_opt = abs_sq(e_opt);
        lin_htq_mat(j,jtilde) = f(x)*tumor_vol/(head_minus_tumor_vol*perc);
        lin_m1_mat(j,jtilde) = M_1(p_opt, tumor_oct)*tumor_vol/head_vol;
        lin_m2_mat(j,jtilde) = M_2(p_opt, tumor_oct)*(tumor_vol^2)/head_vol;
    end
end

lin_htq_mat
lin_m1_mat
lin_m2_mat

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
        quad_htq_mat(j,jtilde) = HTQ(p_opt,tumor_oct,head_minus_tumor_vol,0.01)
        quad_m1_mat(j,jtilde) = M_1(p_opt, tumor_oct)*tumor_vol/head_vol
        quad_m2_mat(j,jtilde) = M_2(p_opt, tumor_oct)*(tumor_vol^2)/head_vol
    end
end



%
%     % Optimize
%     % A simple easy optimization used for testing purposes.
%     iter = 5;
%     goal_power_tumor = 0.18; % Goal power in tumor [W]
%     disp(['Optimizating E-fields, ' num2str(iter) ' iterations.'])
%     e_opt = Yggdrasil.Utils.Efield.optimize_Efield(e,tumor_oct);
%
%     % Calculate power loss density, and normalize to 1W in tumor
%     P = abs_sq(e_opt);
%     power_in_tumor = scalar_prod_integral(P, tumor_oct)/1E9;
%     P = P/power_in_tumor; % Normalize to 1W in tumor
%     e_opt = e_opt*(1/sqrt(power_in_tumor)); % Same with Efield
%     P_mean = P;
%
%     disp('Iteration 1 done.')
%
%     for i = 2:5
%         % Find the optimal combination of Efields using the mean from prev
%         % iterations
%         e_opt = Yggdrasil.Utils.Efield.optimize_Efield(e,tumor_oct,P_mean);
%
%         % Calculate power loss density
%         P = abs_sq(e_opt);
%         power_in_tumor = scalar_prod_integral(P, tumor_oct)/1E9;
%         P = P/power_in_tumor; % Normalize to 1W in tumor
%         e_opt = e_opt*(1/sqrt(power_in_tumor)); % Same with Efield
%         %P_mean = ((i-1)*P_mean + P)/(i); % Mean
%         P_mean = (P_mean + P)/2; % Exponential mean
%         disp(['Iteration ' num2str(i) ' done.'])
%     end
%
%     % Set goal power in tumor
%     P = P*goal_power_tumor;
%     e_opt = e_opt*sqrt(goal_power_tumor);
%
%     % Find amplitudes of active E-fields
%     amp = e_opt.C.values;
%     ant = e_opt.C.keys;
%     settings = [amp' ant'];
%
%     % Save power loss density
%     mat = P.to_mat;
%     resultpath = [rootpath filesep '..' filesep '1_Efield_results'];
%
%     if ~exist(resultpath,'dir')
%         disp(['Creating result folder at ' resultpath]);
%         [success,message,~] = mkdir(resultpath);
%         if ~success
%            error(message);
%         end
%     end
%     save([resultpath filesep 'P.mat'], 'mat', '-v7.3');
%     save([resultpath filesep 'settings.mat'], 'settings', '-v7.3');

% Empty load_maestro
Yggdrasil.Utils.Efield.load_maestro('empty');
end