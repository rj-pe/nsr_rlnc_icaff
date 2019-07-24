% [outputVar] = functionName(inputVar)
% 
% Overview
%    Returns a matrix from a gf() object as defined in communications toolbox
%     
% Input
%    gf_obj: gf() object
%
% Output
%    M: matrix with elements in GF
function mat = gf2mat(gf_obj)
for rows_iter = 1 : size(gf_obj, 1)
	row = gf_obj(rows_iter, :);
	for cols_iter = 1 : size(gf_obj, 2)
		temp_var = row(cols_iter);
		mat(rows_iter, cols_iter) = double(temp_var.x);
	end % cols_iter
end % rows_iter

end %function