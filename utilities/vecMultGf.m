% elementwise multiplication of a signal by a coefficient in GF

function scaledVector = vecMultGf(coeff, vector, field, icaAlgo)
    scaledVector = zeros(1, size(vector, 2));
	if strcmp(icaAlgo, 'cobICA')
		for iterElem = 1 : size(vector, 2)
				scaledVector(1, iterElem) = ...
				  gfmul((coeff - 1), vector(iterElem), field);
	    end % end for
	    % some products of the above multiplication will result in -Inf
	    % replace -Inf with -1
	    scaledVector(scaledVector == -Inf) = -1;
	elseif strcmp(icaAlgo, 'AMERICA')
		scaledVectorGf = coeff * gf(vector, 4);
		scaledVector = gf2mat(scaledVectorGf);
	end

end % function vectMultGf