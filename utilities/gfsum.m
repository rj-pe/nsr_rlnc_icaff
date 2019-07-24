%auxiliary routine to perform sum over a list of GF(q^m) values
%INPUT
%a: list of elements to be summed
%field: list of GF(q^m) symbols

%OUTPUT
%y: result

%Daniel Guerreiro e Silva - 12/01/2015
function y = gfsum(a,field)

    y = a(1);

    for it=2:length(a)        
        y = gfadd(y,a(it),field);        
    end

end