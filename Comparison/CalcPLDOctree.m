% NOTE: Put this file in the same folder as EF_optimization and use 
%run_1 to run this file, so that Yggdrasil comes automatically. 


freq = [400 600 800];
hold on 
for j=freq
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
    Efilename = @(f,a)[datapath filesep 'Efield_F' num2str(j) '_A' num2str(a)];
    sigma     = @(f)[datapath filesep 'sigma_' num2str(j)];
    rel_eps = 0.1;
    Yggdrasil.Utils.Efield.load_maestro('init', Efilename, sigma, rel_eps);
    
    % Convert sigma from .txt to a volumetric matrix
    create_sigma_mat(j);
    % Create Efield objects
    e = cell(16,1);
    for i = 1:16
        e{i}  = Yggdrasil.SF_Efield(j, i );
    end
    e_tot = e{1};
    for i =2:16
        e_tot = e{i} + e_tot; %Using addition with octrees is already defined, and '+' can be used
    end
    
    P = abs_sq(e_tot);
    P = P.to_mat;
    %save(strcat('P_oct',num2str(freq)),'P')
    
end