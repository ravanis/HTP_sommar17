function [data, tissueNames] = WeightedTissuefile(tissue_filepath, x)
%Finds data from tissue files of two frequencies and weighs it using the x calculated in
%EF_opt_adv. 
% Returns tissue data and tissue name vector from a specified tissue file

[data1, tissueNames] = importTissueFile(tissue_filepath(1));
[data2, ~] = importTissueFile(tissue_filepath(2));

% Weigh data
data = data1*x + data2*(1-x);

end