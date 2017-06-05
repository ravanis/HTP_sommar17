function [thermal_conductivity, perf_cap, modified_perf_cap, heat_trans, temp_out] =...
          get_parameter_vectors(keyword)
% [thermal_conductivity, perf_cap, modified_perf_cap, heat_trans, temp_out] = GET_PARAMETER_VECTORS(path_name)
% Loads the data from a file specific type of file created by
% reload_parameters.m and outputs the four collums as arrays.

%% Load data from .m files

% Gets the boundrary conditions
heat_trans = boundary_condition();

% Sets the values for the temperatures in the same order as heat_trans
temp_out = temperature();

%% Load data from .txt file
% Reads the file with material properties
% In the read data the values for the tumor is incorrect
path = get_path(keyword);
paramMat = caseread(path);
paramMat(end,:)= []; % Removes the last two rows
[name, ~, heat_cap, thermal_conductivity, perf, modified_perf, dens] =...
strread(paramMat', '%s %d %f %f %f %f %f', 'whitespace', '\t');

% Finds the index of blood
index_blood = strfind(name, 'BloodA');
index_blood = find(not(cellfun('isempty', index_blood)));

% Multiplies the heat capacity and density of blood with the perfusion and
% density of other materials
perf_cap = heat_cap(index_blood) .* perf .* dens .* dens(index_blood);
modified_perf_cap = heat_cap(index_blood) .* modified_perf .* dens .* dens(index_blood);
end