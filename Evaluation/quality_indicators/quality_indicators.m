function quality_indicators(modelType, freq, goal_power_tumor)
% Returns quality indicators HTQ, TC25, SARmaxTum

addpath Example\1_Efield_example\Scripts\       
addpath Example\2_Prep_FEniCS_example\Scripts\  

% Get paths
filename = which('quality_indicators');
[evalpath,~,~] = fileparts(filename);
rootpath = [evalpath filesep '..' filesep '..' filesep 'Example'];
datapath = [rootpath filesep '1_Efield_example' filesep 'Data'];

% Load matrices
PLD = Yggdrasil.Utils.load([rootpath filesep '1_Efield_results' filesep 'P_' modelType '_' num2str(freq) ...
    'MHz_GP' num2str(goal_power_tumor) '.mat']);
tissue_mat = Yggdrasil.Utils.load([datapath filesep 'tissue_mat_' modelType '.mat']);

% Get Q.I.
addpath Evaluation\quality_indicators
[HTQ, PLDmaxTum, TC]=getHTQ(tissue_mat, PLD, modelType);

disp(['HTQ is ' num2str(HTQ)])
disp(['TC25 is ' num2str(TC(1))])
disp(['Maximum PLD in tumor is ' num2str(PLDmaxTum) ' W'])
end
