function [P] = EF_optimization(freq, nbrEfields, modelType, goal_power_tumor)
%[P] = EF_OPTIMIZATION()
%   Calculates a optimization of E-fields to maximize power in tumor while
%   minimizing hotspots. The resulting power loss density will then be
%   saved to the results folder.

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
Efilename = @(f,a)[datapath filesep 'Efield_' num2str(f) 'MHz_A' num2str(a) '_' modelType];
sigma     = @(f)[datapath filesep 'sigma_' modelType '_' num2str(f) 'MHz'];
rel_eps = 0.1;
Yggdrasil.Utils.Efield.load_maestro('init', Efilename, sigma, rel_eps);

% Convert sigma from .txt to a volumetric matrix
create_sigma_mat(freq, modelType);
% Create Efield objects
e = cell(nbrEfields,1);
for i = 1:nbrEfields
    e{i}  = Yggdrasil.SF_Efield(freq, i );
end

% Load information of where tumor is
tissue_mat = Yggdrasil.Utils.load([rootpath filesep 'Data' filesep 'tissue_mat_' modelType '.mat']);
if startsWith(modelType, 'duke') == 1
    tumor_ind = 80;
elseif modelType == 'child'
    tumor_ind = 9;
else
    error('Model type not available. Enter your model indices in EF_optimization')
end
tumor_oct = Yggdrasil.Octree(single(tissue_mat==tumor_ind));

% Optimize
% A simple easy optimization used for testing purposes.
iter = 5;
disp(['Optimizating E-fields, ' num2str(iter) ' iterations.'])
e_opt = Yggdrasil.Utils.Efield.optimize_Efield(e,tumor_oct);

% Calculate power loss density, and normalize to 1W in tumor
P = abs_sq(e_opt);
power_in_tumor = scalar_prod_integral(P, tumor_oct)/1E9;
P = P/power_in_tumor; % Normalize to 1W in tumor
e_opt = e_opt*(1/sqrt(power_in_tumor)); % Same with Efield
P_mean = P;

disp('Iteration 1 done.')

for i = 2:5
    % Find the optimal combination of Efields using the mean from prev
    % iterations
    e_opt = Yggdrasil.Utils.Efield.optimize_Efield(e,tumor_oct,P_mean);
    
    % Calculate power loss density
    P = abs_sq(e_opt);
    power_in_tumor = scalar_prod_integral(P, tumor_oct)/1E9;
    P = P/power_in_tumor; % Normalize to 1W in tumor
    e_opt = e_opt*(1/sqrt(power_in_tumor)); % Same with Efield
    %P_mean = ((i-1)*P_mean + P)/(i); % Mean
    P_mean = (P_mean + P)/2; % Exponential mean
    disp(['Iteration ' num2str(i) ' done.'])
end

% Set goal power in tumor
P = P*goal_power_tumor;
e_opt = e_opt*sqrt(goal_power_tumor);

% Find amplitudes of active E-fields
amp = e_opt.C.values;
ant = e_opt.C.keys;
settings_complex = [amp' ant'];

% Save power loss density
mat = P.to_mat;
resultpath = [rootpath filesep '..' filesep '1_Efield_results'];

if ~exist(resultpath,'dir')
    disp(['Creating result folder at ' resultpath]);
    [success,message,~] = mkdir(resultpath);
    if ~success
        error(message);
    end
end

save([resultpath filesep 'P_' modelType '_' num2str(freq) 'MHz.mat'], 'mat', '-v7.3');
save([resultpath filesep 'settings_complex_' modelType '_' num2str(freq) 'MHz.mat'], 'settings_complex', '-v7.3');

% Empty load_maestro
Yggdrasil.Utils.Efield.load_maestro('empty');
end