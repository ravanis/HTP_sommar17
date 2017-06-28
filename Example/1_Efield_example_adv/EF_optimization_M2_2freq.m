function EF_optimization_M2_2freq(freq_vec, nbrEfields, modelType)
%   Calculates a optimization of E-fields to maximize power in tumor while
%   minimizing hotspots. The resulting power loss density will then be
%   saved to the results folder.
% freq_vec is a vector with TWO frequencies

% force top value according to warning
top = [];
%top = 5;

% Ensure Yggdrasil is available
if strcmp(which('Yggdrasil.Octree'), '')
    error('Need addpath to the self-developed package ''Yggdrasil''.')
end

% Get root path
filename = which('EF_optimization_M2_2freq');
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
n = length(freq_vec);
e_primary = cell(n,1);
e_secondary = cell(n,1);
for j = 1:n
    % Create Efield objects
    e_j = cell(nbrEfields,1);
    for i = 1:nbrEfields
        e_j{i}  = Yggdrasil.SF_Efield(freq_vec(j), i);
    end
    % Calculates the recommended top(number of active antennas) value and
    % set to 3 if no other value is given (3 takes not too long time).
    if j == 1
        recommendedTop = chkQuality(e_j, tumor_oct);
        if recommendedTop <= 3
            top = recommendedTop;
        elseif isempty(top)
            top = 3;
            disp(['Recommended value for top is ' num2str(recommendedTop) '. ' ...
                'Set value is 3 due to time demand.'])
            disp(['For higher accuracy and better results manually set top in EF_optimization_M2_2freq.'])
        else
            disp(['Top is set to ' num2str(top) ', calculations will take a long time.'])
        end
    end
    disp(['Loading E-field at frequency ' num2str(freq_vec(j)) '.'])
    e_primary{j} = select_best(e_j,top,tumor_oct);
    e_j = cell(nbrEfields,1);
    for i = 1:nbrEfields
        e_j{i}  = Yggdrasil.SF_Efield(freq_vec(j), i);%, 2); Fungerar ej om arrangement �r 2 d� M1 och M2 l�gger ihop e p� olika s�tt
    end
    e_secondary{j} = select_best(e_j,top,tumor_oct);
end

% starting values for finding best combination
bestHTQ = [100 0 0];
time_settings = zeros(2,1);

% optimize M2
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
        e;
        e_opt = optimize_M2(e,tumor_oct);
        p_opt = abs_sq(e_opt);
        p_opt_mat = to_mat(p_opt);
        HTQ = getHTQ(tissue_mat, p_opt_mat, modelType);
        if HTQ <= bestHTQ(1)
            a=0;
            bestHTQ(1)= HTQ;
            bestHTQ(2)= freq_vec(j);
            bestHTQ(3)= freq_vec(jtilde);
            p_opt_best = p_opt;
            e_opt_best = e_opt;
        end
        %         quad_htq_mat(j,jtilde) = HTQ(p_opt_mat,tumor_oct,0.01) % old version has head_minus_tumor_vol as input and is multiplied with *tumor_vol/(head_minus_tumor_vol*perc);
        %         quad_m1_mat(j,jtilde) = M_1(p_opt, tumor_oct)*tumor_vol/head_vol
        %         quad_m2_mat(j,jtilde) = M_2(p_opt, tumor_oct)*(tumor_vol^2)/head_vol
    end
end

% optimize M2 prov
% for j = 1:n
%     %     e_opt_main = optimize_M1(e_primary{j},tumor_oct);
%     %     p_opt = abs_sq(e_opt_main);
%     %     p_opt_mat = to_mat(abs_sq(e_opt_main));
%     N = length(e_primary{j});
%     for i = 1:N
%         e{i} = e_primary{j}{i};
%     end
%     for jtilde = j:n
%         disp(['Optimizing M2 on (' num2str(j) ...
%             ',' num2str(jtilde) ') out of ('...
%             num2str(n) ',' num2str(n) ').'])
%         M = length(e_secondary{jtilde});
%         e = cell(N+M,1);
%         for i = 1:M
%             e{i+N} = e_secondary{jtilde}{i};
%         end
%         e_opt = optimize_M2(e,tumor_oct);
%         p_opt = abs_sq(e_opt);
%         p_opt_mat = to_mat(p_opt);
%         HTQ = getHTQ(tissue_mat, p_opt_mat, modelType);
%         if HTQ <= bestHTQ(1)
%             a=0;
%             bestHTQ(1)= HTQ;
%             bestHTQ(2)= freq_vec(j);
%             bestHTQ(3)= freq_vec(jtilde);
%             p_opt_best = p_opt;
%             e_opt_best = e_opt;
%         end
%         quad_htq_mat(j,jtilde) = HTQ(p_opt_mat,tumor_oct,0.01) % old version has head_minus_tumor_vol as input and is multiplied with *tumor_vol/(head_minus_tumor_vol*perc);
%         quad_m1_mat(j,jtilde) = M_1(p_opt, tumor_oct)*tumor_vol/head_vol
%         quad_m2_mat(j,jtilde) = M_2(p_opt, tumor_oct)*(tumor_vol^2)/head_vol
%     end
% end

% save best p_opt
if exist('a')~=0
    p_best=to_mat(p_opt_best);
else
    p_best = to_mat(p_opt);
end
save([resultpath filesep 'P_M2_' modelType '_1_' num2str(bestHTQ(2)) ...
    '_2_' num2str(bestHTQ(3)) 'MHz.mat'], 'p_best')

disp(['Best HTQ is ' num2str(bestHTQ(1)) ' and is obtained by combining frequencies '...
    num2str(bestHTQ(2)) ' and ' num2str(bestHTQ(3)) '.'])

% save settings_complex
if exist('a')~=0
    e_best=e_opt_best;
else
    e_best = e_opt;
end
amp = e_best.C.values;
ant = e_best.C.keys;

settings_complex=zeros(nbrEfields,1);
settings_complex(ant) = amp;

% saves complex antenna settings and time settings
%save([resultpath filesep 'time_settings_' modelType '_1_' num2str(frequencies(bestHTQ(2))) ...
%    '_2_' num2str(frequencies(bestHTQ(3))) 'MHz.mat'], 'time_settings', '-v7.3');
save([resultpath filesep 'settings_complex_' modelType '_1_' num2str(bestHTQ(2)) ...
    '_2_' num2str(bestHTQ(3)) 'MHz.mat'], 'settings_complex', '-v7.3');
%save([resultpath filesep 'settings_complex_' modelType '_1_' num2str(bestHTQ(2)) ...
%   '_2_' num2str(bestHTQ(3)) 'MHz_(2).mat'], 'settings_complex2', '-v7.3');

% Empty load_maestro
Yggdrasil.Utils.Efield.load_maestro('empty');
end