function run_4(modelType, freq, nbrEfields)
%RUN_4
%   Run example 4
    olddir = pwd;
    [rootpath,~,~] = fileparts(mfilename('fullpath'));
    cd(rootpath)
	temperaturepath = ['4_Temperature_example'];
	scalepath = [temperaturepath filesep 'Scripts'];
	
	addpath(temperaturepath)
	addpath(scalepath) 
	   
    save_scaled_settings(modelType, freq, nbrEfields);
    cd(olddir)
    %addpath Extrapolation
    evaluate_temp(modelType, freq, true);
   
    cd(olddir)
end