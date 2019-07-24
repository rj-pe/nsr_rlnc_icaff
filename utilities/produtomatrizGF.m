%auxiliary routine to perform matrix multiplication over GF(q^m)
%INPUT
%A, B: input matrices, defined over GF(q^m)
%field: list of GF(q^m) elements

%OUTPUT
%C: product matrix

%Daniel Guerreiro e Silva - 12/01/2015
function [C] = produtomatrizGF(A,B,q,m,field)

if(m==1)%prime field
    C = rem(A*B,q);
else %non-prime field
    lines = size(A,1);
    columns = size(B,2);
    C = zeros(lines,columns);   
    for j=1:columns
        for i=1:lines        
            list = gfmul(A(i,:),B(:,j)',field);
            C(i,j) = gfsum(list,field);
        end
    end                        
    C(C==-Inf) = -1;
end

end