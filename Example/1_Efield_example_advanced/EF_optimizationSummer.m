function [] = EF_optimizationSummer()
%[P] = EF_OPTIMIZATION()
%   Calculates a optimization of E-fields to maximize power in tumor while
%   minimizing hotspots. The resulting power loss densities and antenna settings  will then be
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
    Efilename = @(f,a)[datapath filesep 'Efield_F' num2str(f) '_A' num2str(a)];
    sigma     = @(f)[datapath filesep 'sigma_' num2str(f)];
    rel_eps = 0.1;
    Yggdrasil.Utils.Efield.load_maestro('init', Efilename, sigma, rel_eps);
    
    % Convert sigma from .txt to a volumetric matrix
    frequencies = [450 800];
    n = length(frequencies);
    f_1 = frequencies(1);
    f_2 = frequencies(2);
    % Convert sigma from .txt to a volumetric matrix
    for f = frequencies
        create_sigma_mat(f);
    end
    % Create Efield objects for two frequencies
    e_f1 = cell(1,16);
    e_f2 = cell(1,16);
    for i = 1:16
        e_f1{i} = Yggdrasil.SF_Efield(f_1, i);
        e_f2{i} = Yggdrasil.SF_Efield(f_2, i);
    end
    
     
    % Load information of where tumor is, and healthy tissue
    tissue_mat = Yggdrasil.Utils.load([rootpath filesep 'Data' filesep 'tissue_mat.mat']);
    tumor_oct = Yggdrasil.Octree(single(tissue_mat==80));
    tumor_mat = to_mat(tumor_oct);
    
    water_ind = 81;
    ext_air_ind = 1;
    int_air_ind = 2;
    head_mat = tissue_mat~=water_ind & ...
               tissue_mat~=ext_air_ind & ...
               tissue_mat~=int_air_ind;
    head_vol = sum(head_mat(:));
    tumor_vol = tumor_oct.integral();
    head_minus_tumor_vol = head_vol - tumor_vol;
    
    %Optimization 
    
    %FIRST FREQUENCY
    
    e_opt_1 = optimize_M1(e_f1,tumor_oct);
    p_opt_1 = abs_sq(e_opt_1);
    
    
    %SECOND FREQUENCY
    %This is where it gets tricky. We want to represent the function C(Q).
    %The easiest way to do this is to use the function optimize_M1, however
    %then we need to have a special change in optimize_ratio.
    %Every point in the octree(technically)represents a second degree polynomial
    %We want to multiply every single point of the healthy tissue with old 2nd degree
    %polynomials from e_opt_1, and then optimize with regards to the "new"
    %2nd degree polynomials from our E-field with the second frequency. 
    %We have "weighted" the octree with an old P-matrix, technically
    %speaking, and the function (@f) in optimize_ratio need to see that. 

    e_opt_2 = optimize_M1_w(e_f2,tumor_oct,p_opt_1);
    p_opt_2 = abs_sq(e_opt_2);

    %HTQ Convex Combination
    f = @(x)(HTQ(x^2 * p_opt_1 + (1-x)^2 * p_opt_2...
            ,tumor_mat,head_minus_tumor_vol,perc));
        
    x = fminsearch(f,1);
   
    p_opt = (x^2)*p_opt_1 + ((1-x)^2)*p_opt_2;
    
    disp(strcat('Time distribution is: ' ,num2str(sqrt(x)),'for first frequency'))
    disp(strcat('Time distribution is: ' ,num2str(1-sqrt(x)),'for second frequency'))
    
    %Find antenna settings of active E-fields
    amp = e_opt_1.C.values;
    ant = e_opt_1.C.keys;    
    settings_1 = [amp' ant']; %For first frequency
    
    amp = e_opt_2.C.values;
    ant = e_opt_2.C.keys;
    settings_2 = [amp' ant']; %For second frequency
    
    % Save all the power loss densities. The third one shall go into FEniCS
    mat_1 = p_opt_1.to_mat;
    mat_2 = p_opt_2.to_mat;
    mat = p_opt.to_mat;
    
    resultpath = [rootpath filesep '..' filesep '1_Efield_results'];
    
    if ~exist(resultpath,'dir')
        disp(['Creating result folder at ' resultpath]);
        [success,message,~] = mkdir(resultpath);
        if ~success
           error(message); 
        end
    end
    
    save([resultpath filesep 'P_1.mat'], 'mat_1', '-v7.3');
    save([resultpath filesep 'settings_1.mat'], 'settings', '-v7.3');
    save([resultpath filesep 'p_opt.mat'], 'mat', '-v7.3');
    save([resultpath filesep 'P_2.mat'], 'mat_2', '-v7.3');
    save([resultpath filesep 'settings_2.mat'], 'settings', '-v7.3');
    
    % Empty load_maestro
    Yggdrasil.Utils.Efield.load_maestro('empty');
end