function create_vol_matrices(overwriteOutput, tissue_mat, thermal_conductivity, perf_cap)
%CREATE_VOL_MATRICES(overwriteOutput, thermal_conductivity, perf_cap, tissue_mat)
%   Creates and saves volumetric (non-boundary) parameter matrices. 
%   Input: lists of material properties for each tissue index.

    if nargin ~= 4
            error('Needs three input arguments.')
    end

    if ~exist(get_path('stage2'), 'dir')
        disp('Creating new directory Stage2 for storage of the parameter matrices.');
        mkdir(get_path('stage2'));
    end

    if ~exist(get_path('thermal_cond_mat'),'var') || overwriteOutput
        thermal_conductivity_mat = thermal_conductivity(tissue_mat);
        save(get_path('thermal_cond_mat'), 'thermal_conductivity_mat', '-v7.3');
    end

    if ~exist(get_path('perfusion_heatcapacity_mat'),'var') || overwriteOutput
        perf_cap_mat = perf_cap(tissue_mat);
        save(get_path('perfusion_heatcapacity_mat'), 'perf_cap_mat', '-v7.3');
    end
end