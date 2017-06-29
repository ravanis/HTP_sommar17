function best_Efields_M1(freq, nbrEfields, modelType)

addpath C:\Users\Andrea\Documents\Kod\HTP_sommar17\Example\1_Efield_example_adv\Scripts
% Ensure Yggdrasil is available
if strcmp(which('Yggdrasil.Octree'), '')
    error('Need addpath to the self-developed package ''Yggdrasil''.')
end

% Get root path
filename = which('EF_optimization');
[rootpath,~,~] = fileparts(filename);
datapath = [rootpath filesep 'Data'];
%scriptpath = [rootpath filesep 'Scripts'];
%addpath(scriptpath)
freq_vec = [freq freq];

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

E_opt = Yggdrasil.Utils.Efield.choose_Efields(e,tumor_oct);

%-----------------------------------------------------------------------------------------------
top = [];
% Checks HTQ before optimization with M2
e_tot = E_opt{1};
for i = 1:length(E_opt)
    for j = 1:length(e_tot)
     if ~(i==1) 
            e_tot = e_tot + E_opt{i};
        end
    end
end
p_bf = abs_sq(e_tot);
p= to_mat(p_bf);
HTQ_before = getHTQ(tissue_mat, p, modelType)
%-----------------------------------------------------------------------------------------------
e_primary=E_opt;
e_secondary=E_opt;
% starting values for finding best combination
bestHTQ = [100 0 0]; % starting value for HTQ and indeces
best_e_opt_main = optimize_M1(e_primary,tumor_oct);
best_p_opt_final = abs_sq(best_e_opt_main);
best_e_opt_alt = optimize_M1(e_secondary,tumor_oct,best_p_opt_final);
time_settings=zeros(2,1);

n=length(freq_vec);

% Optimize M1
for j = 1:n
    e_opt_main = optimize_M1(e_primary,tumor_oct);
    p_opt = abs_sq(e_opt_main);
    p_opt_mat = to_mat(abs_sq(e_opt_main));
    
    for jtilde = 1:n
        disp(['Optimizing M1 on (' num2str(j) ...
            ',' num2str(jtilde) ') out of ('...
            num2str(n) ',' num2str(n) ').'])
        e_opt_alt = optimize_M1(e_secondary,tumor_oct,p_opt);
        p_opt_alt_mat = to_mat(abs_sq(e_opt_alt));
        perc = 0.01;
        f = @(x)(HTQ(x^2 * p_opt_mat + (1-x)^2 * p_opt_alt_mat...
            ,tumor_mat,perc)); % old verion has head_minus_tumor_vol as input
        
        % Combine them
        x = fminsearch(f,1);
        z = sin(x).^2;
        x = z;
        
        e_opt = x*e_opt_main+(1-x)*e_opt_alt;
        p_opt_final = abs_sq(e_opt);
        lin_htq_mat(j,jtilde) = f(x); % for old version: *tumor_vol/(head_minus_tumor_vol*perc);
        lin_m1_mat(j,jtilde) = M_1(p_opt_final, tumor_oct)*tumor_vol/head_vol;
        lin_m2_mat(j,jtilde) = M_2(p_opt_final, tumor_oct)*(tumor_vol^2)/head_vol;
        
        if lin_htq_mat(j,jtilde) <= bestHTQ(1) %saves the best combination of frequencies
            bestHTQ(1) = lin_htq_mat(j,jtilde); % best HTQ-value
            bestHTQ(2) = j; %frequency 1 used for best HTQ
            bestHTQ(3) = jtilde; %frequency 2 used for best HTQ
            best_e_opt_main = e_opt_main; %used to calculate settings for freq 1
            best_e_opt_alt = e_opt_alt; %used to calculate settings for freq 2
            best_p_opt_final = p_opt_final; %p-matrix for best combination of freq
            time_settings = [x 1-x];
        end
    end
end
p = to_mat(best_p_opt_final);
getHTQ(tissue_mat, p, modelType)

% Empty load_maestro
Yggdrasil.Utils.Efield.load_maestro('empty');
end

