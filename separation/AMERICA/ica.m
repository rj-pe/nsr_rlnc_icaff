function [icaEstimate] = ica( ...
    observations, ...
    testMixingMatrix, ...
    testSourceLength, ...
    base, ...
    degree, ...
    binICA)
% perform separation on the combined signals
% parameters: 
% returns the estimated source signals

% working parameters
% Number of sources
K = 2;

if binICA
    % convert source to binary and perform AMERICA in gf(2)
    % Galois order
    P = base;
    %Observation length
    T = testSourceLength * 4;
    % convert mixing matrix to binary
    A(1, :) = source2bin(testMixingMatrix(1, :));
    A(2, :) = source2bin(testMixingMatrix(2, :));
    % convert observations to binary
    X(1, :) = source2bin(observations(1, :));
    X(2, :) = source2bin(observations(2, :));
else
    P = base^degree;
    gf_exp = log2(P);
    T = testSourceLength;
    A = gf(testMixingMatrix, 4);
    X = gf(observations, 4);
end

PK=P^K;

%Now prepare for separation

%construct a "Lexicon": Lex(:,n) is the (n-1)-th
%index vector: n-1=Lex(1,n)+P*Lex(2,n)+P^2*Lex(3,n)+
%...+P^(K-1)*Lex(K,n)
Lex=zeros(K,PK);

if ~binICA
    Lex = gf(Lex, gf_exp);
end

nvec=[0:PK-1];

for k=1:K-1
    Lex(k,:)=mod(nvec,P);
    nvec=floor(nvec/P);
end

Lex(K,:)=nvec;
%construct an "index-vector translation" vector:
r=P.^[0:K-1]; 

%estimate the probabilities "tensor"
%(the P^K tensor is stored in a 1xP^K vector PPx:
%PPx(n) represents the probability of occurrence
%of x, such that n=r*x;

PPx=zeros(1,PK);

if binICA
    ixt=r*X;
else
    ixt = r * double(X.x);
end

for t=1:T
    PPx(ixt(t)+1)=PPx(ixt(t)+1)+1;
end

PPx=PPx/T;

if binICA
    Ba=america(PPx, P, K, PK, Lex, r);
else
    Ba = america_gf2n(PPx, P, K, PK, Lex, r, gf_exp);
end

if binICA
    Da=mod(Ba*A,P); % 
    Danz=(Da>0); % the non-zero elements of Da
else
    Da = Ba * A
    Danz = (Da.x > 0);
end

sca=sum(sum(Danz,2)==1);
if sca==K
    disp('AMERICA: succeeded')
else
    disp('AMERICA: failed')
end

if binICA
    binIcaEstimate = mod(Ba * X, P);
    icaEstimate(1, :) = bin2source(binIcaEstimate(1, :));
    icaEstimate(2, :) = bin2source(binIcaEstimate(2, :));
else
    icaEstimateGf = Ba * X;
    icaEstimate = gf2mat(icaEstimateGf);
end
