% this function fits a probability distribution object to a given source
function pmf = fitPmf2Source(source)

if min(source, [], 2) < 0
	source = source + 1;
end % end if

pmf = hist(source, 16)' ./ numel(source);

pmf(pmf == 0) = 0.000001;

end %function
