function [path] = get_path(str, modelType, freq)
%function [path] = get_path(str)
%   Returns the absolute path of a file given by a keyword. This is used to
%   simplify file loading/saving.

% Relative filepaths
% input for databases and PLD
tissuepath = ['Data' filesep];
sourcepath = ['..' filesep '1_Efield_results' filesep];
% temporary files
stage1path = ['tmp' filesep 'Stage1' filesep];
stage2path = ['tmp' filesep 'Stage2' filesep];
% output
resultpath = ['..' filesep '2_Prep_FEniCS_results' filesep];

if nargin < 2
    switch(lower(str))
        case 'tissue_data'
            path = tissuepath;
        case 'scripts'
            path = 'Scripts';
        case 'mesh_scripts'
            path = ['Scripts' filesep 'Mesh_generation'];
        case 'boundary_condition'
            path = [tissuepath 'boundrary_condition.m'];
        case 'temperature'
            path = [tissuepath 'temperature.m'];
        case 'map_index'
            path = [tissuepath 'thermal_db_index_to_mat_index.m'];
        case 'thermal_db'
            path = [tissuepath 'Thermal_dielectric_acoustic_MR_'...
                'properties_database_V3.0%28Excel%29.xlsx'];
        case 'stage1'
            path = [stage1path(1:end-1)];
        case 'stage2'
            path = [stage2path(1:end-1)];
        case 'stage1_thermal_compilation'
            path = [stage1path 'thermal_compilation.txt'];
        case 'premade_thermal_compilation'
            path = [tissuepath 'thermal_compilation.txt'];
        case 'thermal_cond_mat'
            path = [stage2path 'thermal_cond.mat'];
        case 'perfusion_heatcapacity_mat'
            path = [stage2path 'perfusion_heatcapacity.mat'];
            
            % Final data, ready to be used by FEniCS
        case 'bnd_heat_transfer_mat'
            path = [resultpath 'bnd_heat_transfer.mat'];
        case 'bnd_temp_mat'
            path = [resultpath 'bnd_temp.mat'];
        case 'bnd_temp_times_ht_mat'
            path = [resultpath 'bnd_temp_times_ht.mat'];
        case 'xtrpol_thermal_cond_mat'
            path = [resultpath 'thermal_cond.mat'];
        case 'xtrpol_perfusion_heatcapacity_mat'
            path = [resultpath 'perfusion_heatcapacity.mat'];
        case 'mesh'
            path = [resultpath 'mesh.xml'];
        case 'tumor_mesh'
            path = [resultpath 'tumor_mesh.obj'];
    end
elseif nargin==2
    switch(lower(str))
        case 'mat_index'
            path = [tissuepath 'tissue_mat_' modelType '.mat'];
        case 'rho'
            path = [tissuepath 'rho_' modelType '.mat'];
        otherwise
            error(['Unknown path to file: ''' str '''.'])
    end
else
    switch(lower(str))
        case 'pld'
            path = [sourcepath 'P_' modelType '_' num2str(freq) 'MHz.mat'];
        case 'xtrpol_pld'
            path = [resultpath 'P_' modelType '_' num2str(freq) 'MHz.mat'];
        case 'sigma'
            path = [tissuepath 'sigma_' modelType '_' num2str(freq) 'MHz.mat'];
        case 'sigma_adv'
            path = [tissuepath 'sigma_adv' modelType '_' num2str(freq) 'MHz.mat'];
        case 'cst_data'
            if startsWith(modelType, 'duke')==1
                path = [tissuepath 'df_duke_neck_cst_' num2str(freq) 'MHz.txt'];
            elseif modelType == 'child'
                path = [tissuepath 'df_chHead_cst_' num2str(freq) 'MHz.txt'];
            else
                error('Model type not available. Enter the full name of your model tissue_file in create_sigma_mat.')
            end
    end
end

% Get root path
filename = which('get_path');
[scriptpath,~,~] = fileparts(filename);
rootpath = [scriptpath filesep '..'];

% Make relative path into a absolute path
path = [rootpath filesep path];

end