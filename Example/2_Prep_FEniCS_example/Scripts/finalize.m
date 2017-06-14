function finalize(keyword, nearest_points, modelType, freq)
%FINALIZE(keyword, nearest_points)
%   Last step of data preparation. The mesh used by FEniCS can differ in size 
%   w.r.t. the body described in the index matrix. To make sure sampling of mesh 
%   points is ok, the data matrices are extrapolated outside the body 
%   (nearest neighbor in 3d).

if nargin == 4
    mat = Extrapolation.load(get_path(keyword, modelType, freq));
    mat = extrapolate_data(mat, nearest_points);
    save(get_path(['xtrpol_' keyword], modelType, freq), 'mat', '-v7.3');
else
    mat = Extrapolation.load(get_path(keyword));
    mat = extrapolate_data(mat, nearest_points);
    save(get_path(['xtrpol_' keyword]), 'mat', '-v7.3');
end
end

