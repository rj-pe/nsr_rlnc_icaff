%cobICA fitness function - sum of maximum-likelihood marginal entropies
%INPUT
%AB: KK x nAB population matrix
%field: list of GF(q^m) elements
%X: mixtures

%OUTPUT
%v: fitness vector

%Daniel Guerreiro e Silva - 12/01/2015
function [v] = fitness_sum_mlh(AB,X,q,m,field)

P = q^m;

lg_cte = log(P); %correction factor to calculate always logP entropies
[KK, nAB] = size(AB);
Nobs = size(X,2);
crc = ((P-1)/(2*Nobs));
v = zeros(nAB,1);
K = sqrt(KK);
for iter=1:nAB

    W = reshape(AB(:,iter),K,K); %rearrangement of individuals into extraction vectors  
    Y = produtomatrizGF(W,X,q,m,field);
    if(m>1)%non-prime field
        Py = histc(Y,-1:P-2,2)./Nobs; %pmf estimation for all q symbols
    else
        Py = histc(Y,0:P-1,2)./Nobs; %pmf estimation for all q symbols
    end
    lgPy = log(Py)./lg_cte;
    Pzero = (Py==0);
    PlgP = Py.*lgPy;
    PlgP(Pzero) = 0;
    v(iter) = sum(crc-sum(PlgP,2))./K;
end

end