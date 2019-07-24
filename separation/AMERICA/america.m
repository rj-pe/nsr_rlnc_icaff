function B = america(PPx, P, K, PK, Lex, r)
%The Ascending Minimization of EntRopies for ICA
%(AMERICA) algorithm
%input: PPx - the (estimated) probabilities tensor
%output: B - the estimated separating matrix

eqeps = 1e-9; %a threshold for deciding
              %equal entropies


%K-D fft for obtaining the characteristic tensor
% reshape the prob'ilities matrix into a K-dim object
fPPyn = fftn(reshape(PPx,P*ones(1,K)));

% collect x'formed K-dim into single column vector
% fPPy is the characteristic tensor
fPPy = fPPyn(:);
        
%obtain the characteristic vectors of 
%the linear combinations
qf = ones(P,PK);
% the second row is the x'frmed characteristic tensor
qf(2,:) = fPPy;

if P > 2
    % the Pth row is the conjugate of the second row
    qf(P,:) = conj(fPPy);
    for m = 2:P/2
        % each mLex is a shifted version of Lex
        mLex = mod(m*Lex,P);
        % each row in `qf` is a different ordering of `fPPy`
        % fill `qf` from the start (row 1)
        % for example figures see fPPy_rowN.fig
        qf(m+1,:) = fPPy(r*mLex+1);
        % a quick way to get yet another ordering
        % take the conjugate of the previous ordering
        % fill `qf` from the end (row `P`)
        qf(P+1-m,:) = conj( qf(m+1,:) );
    end
end

% translate characteristic vectors into probabilities vectors
ffq = ifft(qf);
% infinitesimal values in ffq replaced with the standard value given by eps
ffq = max(ffq,eps);
% and then into entropies
% each entry of h corresponds to a ffq's row entropy
h = -sum(ffq .* log2(ffq+eps), 1);
%mark irrelevant entropies (such as the one related
%to the all-zeros (trivial) combination, and subsequent
%"used" entropies - with a NaN
h(1) = NaN;

B = [];
k = 1;
%sorted entropies (ascending order)
% sorted_entropies: ascending sorted entropies
% presort_indx: index of the sorted value
[sorted_entropies, presort_indx] = sort(h);
inh = 1;
while k <= K
    %% sort entropies and choose the one with the lowest value
    % start with the lowest entropy in the list
    vh = sorted_entropies(inh);
    % the pre-sort index of the lowest entropy value
    mix = presort_indx(inh);
    % find the next entropy value that is at least a little larger than the
    % current entropy under consideration.
    for itry = inh + 1 : PK
        if abs( sorted_entropies(itry) - vh) > eqeps, break; end
    end

    %% randomized selection when multiple l.c.'s produce an equivalent entropy
    neq = itry - inh;
    if neq > 1
        % if more than one combin. produced an entropy equal to current entropy
        % randomly pick an index between the current entropy's index and the
        % index of the last row with an equivalent entropy
        ipick = floor(rand * neq);
        % adjust pick for the current index
        pinh = inh + ipick;
        
        % swap the current entropy with the randomly chosen one  
        tmph = sorted_entropies(inh);
        tmpi = presort_indx(inh);
        
        sorted_entropies(inh) = sorted_entropies(pinh);
        presort_indx(inh) = presort_indx(pinh);
        
        sorted_entropies(pinh) = tmph;
        presort_indx(pinh) = tmpi;
    end
    %% test if the selected is not a linear combination of ???
    % record the selected entropy's index again in case shuffling changed which
    % l.c. the entropy represents.
    mix = presort_indx(inh);
    % retrieve the coefficients which correspond to the selected entropy
    b = Lex(:,mix);
    % append them to the current list of lowest entropy producing coefficients
    Bb = [B b];
    % select only a k based subset of the coeffiecients we have already
    % tested in the while loop ????
    TLex = Lex(1:k,2:P^k);
    % ???
    test0 = mod(Bb*TLex,P);
    % if any of the vectors in the test were l.d. then they would be
    % additive inverses in GF and fail this test.
    if ~any(sum(test0,1) == 0) 
        % not a linear combination, we can add the current row to the
        % estimated mixing matrix.
        B = Bb;   
        k = k+1;
    end
    inh = inh+1;
end

B = B';