function [path] = get_path(str, modelType)
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
        case 'cst_data'
            path = [tissuepath 'df_duke_neck_cst_800MHz.txt'];
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
        case 'pld'
            path = [sourcepath 'P.mat'];
            
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
        case 'xtrpol_pld'
            path = [resultpath 'P.mat'];
        case 'mesh'
            path = [resultpath 'mesh.xml'];
        case 'tumor_mesh'
            path = [resultpath 'tumor_mesh.obj'];
    end
else
    switch(lower(str))
        case 'mat_index'
            path = [tissuepath 'tissue_mat_' modelType '.mat'];
        otherwise
            error(['Unknown path to file: ''' str '''.'])
    end
end

% Get root path
filename = which('get_path');
[scriptpath,~,~] = fileparts(filename);
rootpath = [scriptpath filesep '..'];

% Make relative path into a absolute path
path = [rootpath filesep path];

end