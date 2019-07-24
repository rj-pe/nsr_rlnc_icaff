%% cobICA --- cob-aiNet[C] FOR ICA OVER GF(q) --- ARBITRARY SIZE FIELDS %%

%INPUT
%K: number of sources
%q, m: Galois Field order - GF(q^m)
%field: list of GF(q^m) elements
%prm: parameters struct
%funcfit: fitness function

%OUTPUT
%W: separating matrix
%minCost: best fitness records over the iterations
%meanCost: mean fitness records over the iterations
%AB: final population
%f: final fitness vector
%C: final concentration vector
%fitcount: total of fitness evaluations

%Daniel Guerreiro e Silva - 12/01/2015

function [W,minCost,meanCost,AB,v,C,fitcount] = cobicaEF(K,q,m,field,prm,funcfit)

global maxAB nCLmax nCLmin C0 sigmas beta_i beta_f LSit LSfreq maxEpoch P M FIELD fitc;


nCLmax = prm.nCLmax;                %max number of clones per antibody
nCLmin = prm.nCLmin;                %min number of clones per antibody
if(prm.C0<=1)
    C0 = prm.C0;                    %initial concentration
else
    error('Initial concentration is above the limit');
end

sigmas = prm.sigmas;            %supression threshold
maxEpoch = prm.maxEpoch;            %maximum number of epochs

%fixed parameters
nAB = 2;                  %initial number of antibodies
maxAB = 100;               %max number of antibodies
LSit = 1;                   %number of local search iterations
LSfreq = 1;                 %number of iterations between consecutive local searches
beta_i = .8*(K*K);              %initial mutation parameter
beta_f = .008*(K*K);            %final mutation parameter
P = q;
M = m;
FIELD = field;
fitc = 0;

%initial vector population
AB = gerapop(K,nAB);

%initializing
C = ones(nAB,1).*C0;
minCost = zeros(maxEpoch,1);
meanCost = zeros(maxEpoch,1);

v = feval(funcfit,AB);
fitc = fitc + length(v);
f = normfit(v);

epoch = 1;
while (epoch <= maxEpoch && nAB>1)
    
    nCL = round(C.*(nCLmax-nCLmin) + nCLmin); %number of clones
    beta = (beta_i - beta_f)/(1+exp(20/maxEpoch*(epoch-maxEpoch/2))) + beta_f;
    [AB,C,f,v,af] = clone_mut_sel(AB,nCL,f,C,beta,funcfit);
    
    %local search
    if (rem(epoch,LSfreq)==0)
        %local search routine
        v  = feval(funcfit,AB); %re-evaluate the fitness of all population
        fitc = fitc + length(v);
        for it=1:LSit            
            [AB,v] = localsearch(AB,v,funcfit);            
        end        
        f  = normfit(v);
        af = affinity(AB,f,C); %affinity update
        C  = updateConcentration(AB,af,f,C); %concentration update
    end
    
    %Supression    
    survivallist = (C>1e-6);
    sizelist = sum(survivallist);
    if(sizelist<size(AB,2)) %there will be supression when there are zeros
        if(sizelist==0) %always keep at least the best one            
            [~, elected] = sort(f,1,'descend');
            AB = AB(:,elected(1));
            C = C(elected(1));
            v = v(elected(1));
            f = normfit(v);
        else        
            AB = AB(:,survivallist); %maintain in population just individuals with non-null concentration
            C = C(survivallist);
            v = v(survivallist);
            f = normfit(v); %re-evaluate the fitness of all population
        end
    end
    nAB = size(AB,2);
    minCost(epoch) = min(v);
    meanCost(epoch) = mean(v);    
    
        
    %uncomment to show iteration progress
%     figure(1);hold on;title('Concentration');plot(epoch,mean(C),'b*',epoch,max(C),'r*',epoch,min(C),'g*');
     fprintf('Epoch: %d, Best fit: %.6f, Mean fit: %.6f, Pop size: %d\n',epoch,minCost(epoch),meanCost(epoch),nAB);
    
    epoch = epoch + 1;
end

%local search
v = feval(funcfit,AB); %re-evaluate the fitness of all population
fitc = fitc + length(v);
for it=1:LSit
    [AB,v] = localsearch(AB,v,funcfit);
end

%re-evaluate the fitness of all population
f = normfit(v);
af = affinity(AB,f,C);
%Antibodies' concentration update
C = updateConcentration(AB,af,f,C);

%%%%%%%%%%Supression
survivallist = (C>1e-6);
sizelist = sum(survivallist);
if(sizelist<size(AB,2)) %if # cells with non-null concentration are less than the total population -> there will be supression
    if(sizelist==0) %always keep at least the best one
        [~, elected] = sort(f,1,'descend');
        AB = AB(:,elected(1));
        C = C(elected(1));
        v = v(elected(1));
        f = normfit(v);
    else        
        AB = AB(:,survivallist); %maintain in population just individuals with non-null concentration
        C = C(survivallist);
        v = v(survivallist);
        f = normfit(v); %re-evaluate the fitness of all population
    end
end

W = buildMatrix(AB,f,K);
fitcount = fitc;

end

%procedure to select the best solution
function W = buildMatrix(AB,f,K)

[~, elected] = sort(f,1,'descend');

W = reshape(AB(:,elected(1)),K,K);

end

%local search heuristic
function [AB,v] = localsearch(AB,v,funcfit)
    
    global P M FIELD fitc;
        
    [KK,nAB] = size(AB);
    K = sqrt(KK);
           
    for it=1:nAB
        W = reshape(AB(:,it),K,K);
        parar = 0;
        for i=1:K
            for j=[1:i-1 i+1:K]                
                T = eye(K);
                T(i,j) = randi(P-1);                                    
                if(M>1)
                    T = T - 1;                    
                end                                    
                Wnew = produtomatrizGF(T,W,P,M,FIELD);
                abnew = reshape(Wnew,KK,1);
                vnew = feval(funcfit,abnew);
                fitc = fitc + length(vnew);
                if(vnew<v(it)) %there was an improvement
                    AB(:,it) = abnew;
                    v(it) = vnew;
                    parar = 1;
                    break;
                end
            end
            if(parar) 
                break;
            end
        end
    end
                
        
       
end

%concentration update routine
function C = updateConcentration(AB,af,f,C)
    nAB = size(AB,2);
    for it=1:nAB
        if (af(it)>0)
            alpha = 0.7; %concentration decay
        else
            alpha = 1 + 0.1*f(it); %zero affinity -> up to 10% increment in concentration            
        end
        increment = alpha.*C(it) - af(it);
        if (increment>=0)
            C(it) = min([increment 1]);
        else
            C(it) = 0;
        end
    end
end

%cloning, mutation, selection and automatic insertion routine
function [AB,C,f,v,af] = clone_mut_sel(AB,nCL,f,C,beta,funcfit)

    global sigmas maxAB C0 fitc;
     
    nAB = size(AB,2);
    ABnew = [];
    
    nABold = nAB;
    
    for it=1:nAB
        cln = repmat(AB(:,it),1,nCL(it)+1); %clones population and its parent
        n_mut = max(round(beta*exp(-f(it)*C(it))),1); %number of mutation iterations
%         p_mut = exp(-f(it));%alternative
        p_mut = 1;
        for it2=2:nCL(it)+1
            for it3=1:n_mut

                cln(:,it2) = mutate(cln(:,it2),p_mut);

            end

        end
        
        vclones = feval(funcfit,cln);
        fitc = fitc + length(vclones);
        fclones = normfit(vclones);
        [~,bestcl] = max(fclones);
        ABnew = [];                
        
        if(bestcl>1) %if best individual is not the parent
            if(nAB<maxAB)
                dist = pdist2(cln(:,bestcl)',cln(:,1)','hamming'); %distance between parent and clone
                if(dist>sigmas) %insertion with parent
                    ABnew = [ABnew cln(:,bestcl)]; %clone is included in possible incorporation list
                else
                    AB(:,it) = cln(:,bestcl); %clone replaces its parent
                end
            else
                AB(:,it) = cln(:,bestcl); %clone replaces its parent
            end
        end
        
    end
    
    it=1;
    listnewcells=[];
    %new cells insertion if the maximum population size and distance is
    %respected
    while(it<=size(ABnew,2) && (length(listnewcells)+size(AB,2))<maxAB)
        mindist = min(pdist2(ABnew(:,it)',AB','hamming'));
        if(mindist>sigmas)
            listnewcells = [listnewcells;it];
        end
        it = it + 1;
    end
    
    %insertion
    if(~isempty(listnewcells))
        AB = [AB ABnew(:,listnewcells)];
        C = [C; C0.*ones(length(listnewcells),1)];
    end        
    
    v = feval(funcfit,AB); %fitness update
    fitc = fitc + length(v);
    f = normfit(v);
    af = affinity(AB,f,C); %affinity update
    C(1:nABold) = updateConcentration(AB(:,1:nABold),af(1:nABold),f(1:nABold),C(1:nABold)); %concentration update of the old cells        

end


%mutation operators routine
function [abn] = mutate(ab,p)

    global P M FIELD;

    k = sqrt(length(ab));
    abn = reshape(ab,k,k);
    
    if(rand()<p)
        
        line1 = randi(k);
        line2 = randi(k);
        while(line2==line1)
            line2 = randi(k);
        end
        
        if(M>1)%non-prime field
            cte = (randi(P^M-1)-1)*ones(1,k);        
            abn(line1,:) = gfadd(abn(line1,:),gfmul(cte,abn(line2,:),FIELD),FIELD);
        else
            cte = randi(P-1);        
            abn(line1,:) = rem(abn(line1,:) + rem(cte*abn(line2,:),P),P);
        end            
    end
    abn(abn==-Inf) = -1;
    abn = reshape(abn,k*k,1);      
        
end

%affinity function among antibodies
function [af] = affinity(AB,f,C)

global sigmas;

nAB = size(AB,2);
af = zeros(nAB,1);
denom = zeros(nAB,1);

matNormL1 = pdist2(AB',AB','hamming'); %hamming dist. among all antibodies

for it1=1:nAB
    matMask = matNormL1(it1,:) <= sigmas; %mask
    matMask(it1) = 0;
    fitMask = (f>=f(it1))';
    fitMask = and(fitMask, matMask);    
    if(sum(fitMask)>0)      
        af(it1) = af(it1) + sum(C(fitMask).*(sigmas - matNormL1(it1,fitMask)'));
        denom(it1) = denom(it1) + sum(C(fitMask));
    end
    if(denom(it1)>0)
        af(it1) = af(it1)/denom(it1);
    end
end

end

%function to normalize fitness
function [vnorm] = normfit(v)
nAB = length(v);
mn = min(v);
mx = max(v);

if(mn==mx)
    vnorm = 0.5.*ones(nAB,1);
else
    vnorm = 1 - (v-mn)./(mx-mn); %normalized fitness to be maximized
end

end

%population generation
function [POP] = gerapop(K,nAB)

global P M FIELD;
POP = zeros(K*K,nAB);

for it=1:nAB
    %random generation of a separating matrix    
    POP(:,it) = reshape(geramatrizmistura(P,M,FIELD,K),K*K,1);
end

end

