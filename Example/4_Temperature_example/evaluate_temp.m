function [temp_mat, tx] = evaluate_temp(modelType, freq, overwriteOutput)
%function [temp_mat] = EVALUATE_TEMP(overwriteOutput)
%   Reads the output from example 3(FEniCS temp. simulations)
%   and transforms it into a .mat file. It also ends with some evaluation
%   of the temperature, such as T90, T70, T50.
    
    if nargin < 3
        overwriteOutput = false;
    end

    % Get all paths
    filename = which('evaluate_temp');
    [rootpath,~,~] = fileparts(filename); 
    datapath = [rootpath filesep 'Data'];
    scriptpath = [rootpath filesep 'Scripts'];
    resultpath = [rootpath filesep '..' filesep '4_Temperature_results'];
    temppath = [rootpath filesep '..' filesep '3_FEniCS_results' filesep...
                'temperature.h5'];
    addpath(scriptpath)
    
    % Ensure Extrapolation package is available
    % It is needed to load .mat-files
    if strcmp(which('Extrapolation.load'), '')
        error('Need addpath to the self-developed package ''Extrapolation''.')
    end
    
    % Load all tissues
    tissue_mat = Extrapolation.load([datapath filesep 'tissue_mat_' modelType '.mat']);
    [a,b,c] = size(tissue_mat);
    
    % Skip transforming the temperature if .mat already exists
    if ~exist([resultpath filesep 'temp.mat'], 'file') || overwriteOutput
        % Transform FEniCS-format to .mat
        disp('Transforming temperature format, will take some time.')
        temp_mat = read_temperature(temppath,1,1,1,a,b,c);

        % Save temperature
        mat = temp_mat;
        resultpath = [rootpath filesep '..' filesep '4_Temperature_results'];
        if ~exist(resultpath,'dir')
            disp(['Creating result folder at ' resultpath]);
            [success,message,~] = mkdir(resultpath);
            if ~success
               error(message); 
            end
        end
        save([resultpath filesep 'temp_' modelType '_' num2str(freq) 'MHz.mat'], 'mat', '-v7.3');
    else % If the .mat file already exists
        disp('Using previously calcuated temperature .mat file.')
        temp_mat = Extrapolation.load([resultpath filesep 'temp_' modelType '_' num2str(freq) 'MHz.mat']);
    end
    
    % Evaluate tumor temp
    [tx] = tumor_temp(temp_mat, modelType);
end