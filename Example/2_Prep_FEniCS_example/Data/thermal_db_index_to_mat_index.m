function [index_map] = thermal_db_index_to_mat_index()

% A map for the indexes between the first and the second file in this case
% the tumor, which didnt have a value was assigned that of blood
index_map = [4 7 9 13 14 19 20 21 23 24 25 32 19 78 30 33 34 35 38 44 ...
            45 46 47 53 55 60 10 61 63 64 65 66 70 71 73 76 78 9 81 91 ...
            85 87 89 90 94 7 101 4 102 2 2 2 2];

end