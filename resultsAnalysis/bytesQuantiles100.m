load('/home/rj/finalProject/AMERICA_maxkld_obs_2-003---0-934_100-pairs_27-Aug-2019_16:13:28/final.mat');
q = quantile(mutInfoObservations, 10);

pctBytesQuantile = zeros(11,2);
miSourcesMean = zeros(11,2);

for idx = 1 : 11
    if idx == 1
        pctBytesQuantile(idx, 1) = sum( pctBytes_mseMinimization( find( mutInfoObservations < q(idx)), :,:) == 100, 'all');
        miSourcesMean(idx, 1) = mean( mutInfoObservations( mutInfoObservations < q(idx)));
    elseif idx == 11
        pctBytesQuantile(idx, 1) = sum( pctBytes_mseMinimization( find( mutInfoObservations > q(idx-1)), :,:) == 100, 'all');
        miSourcesMean(idx, 1) = mean( mutInfoObservations( mutInfoObservations > q(idx-1)));
    else
        pctBytesQuantile(idx, 1) = sum( pctBytes_mseMinimization( find( mutInfoObservations >= q(idx-1) & mutInfoObservations < q(idx)),:,:) == 100, 'all');
        miSourcesMean(idx, 1) = mean( mutInfoObservations( find( mutInfoObservations >= q(idx-1) & mutInfoObservations < q(idx))));
    end
end

figure('Name', 'mse minimization algorithm')
plot(miSourcesMean(1:10,1), pctBytesQuantile(1:10,1))
ylabel('number of packet pairings which were 100 pct decoded')
xlabel('quantile mean MI for observed signals')
title('mse minimization algorithm')
print -depsc2 mseMin+MiObs.eps

for idx = 1 : 11
    if idx == 1
        pctBytesQuantile(idx, 2) = sum( pctBytes_repeatingOverlaps( find( mutInfoObservations < q(idx)), :,:) == 100, 'all');
        miSourcesMean(idx, 2) = mean( mutInfoObservations( mutInfoObservations < q(idx)));
    elseif idx == 11
        pctBytesQuantile(idx, 2) = sum( pctBytes_repeatingOverlaps( find( mutInfoObservations > q(idx-1)), :,:) == 100, 'all');
        miSourcesMean(idx, 2) = mean( mutInfoObservations( mutInfoObservations > q(idx-1)));
    else
        pctBytesQuantile(idx, 2) = sum( pctBytes_repeatingOverlaps( find( mutInfoObservations >= q(idx-1) & mutInfoObservations < q(idx)),:,:) == 100, 'all');
        miSourcesMean(idx, 2) = mean( mutInfoObservations( find( mutInfoObservations >= q(idx-1) & mutInfoObservations < q(idx))));
    end
end

figure('Name', 'ipv4 checksum algorithm')
plot(miSourcesMean(1:10,2), pctBytesQuantile(1:10,2) )
ylabel('number of packet pairings which were 100 pct decoded')
xlabel('quantile mean MI for observed signals')
title('ipv4 checksum algorithm')
print -depsc2 ipv4Check+MiObs.eps

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% kld %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars q pctBytesQuantile miSourcesMean
q = quantile(kldSources(:,3), 10);

pctBytesQuantile = zeros(11,2);
miSourcesMean = zeros(11,2);


for idx = 1 : 11
    if idx == 1
        pctBytesQuantile(idx, 1) = sum( pctBytes_mseMinimization( find( kldSources(:,3) < q(idx)), :,:) == 100, 'all');
        miSourcesMean(idx, 1) = mean( kldSources( kldSources(:,3) < q(idx),3));
    elseif idx == 11
        pctBytesQuantile(idx, 1) = sum( pctBytes_mseMinimization( find( kldSources(:,3) > q(idx-1)), :,:) == 100, 'all');
        miSourcesMean(idx, 1) = mean( kldSources( kldSources(:,3) > q(idx-1),3));
    else
        pctBytesQuantile(idx, 1) = sum( pctBytes_mseMinimization( find( kldSources(:,3) >= q(idx-1) & kldSources(:,3) < q(idx)),:,:) == 100, 'all');
        miSourcesMean(idx, 1) = mean( kldSources( find( kldSources(:,3) >= q(idx-1) & kldSources(:,3) < q(idx)),3));
    end
end


figure('Name', 'mse minimization algorithm')
plot(miSourcesMean(1:10,1), pctBytesQuantile(1:10,1))
ylabel('number of packet pairings which were 100 pct decoded')
xlabel('quantile mean kld for observed signals')
title('mse minimization algorithm')
print -depsc2 mseMin+kldObs.eps

for idx = 1 : 11
    if idx == 1
        pctBytesQuantile(idx, 2) = sum( pctBytes_repeatingOverlaps( find( kldSources(:,3) < q(idx)), :,:) == 100, 'all');
        miSourcesMean(idx, 2) = mean( kldSources( kldSources(:,3) < q(idx),3));
    elseif idx == 11
        pctBytesQuantile(idx, 2) = sum( pctBytes_repeatingOverlaps( find( kldSources(:,3) > q(idx-1)), :,:) == 100, 'all');
        miSourcesMean(idx, 2) = mean( kldSources( kldSources(:,3) > q(idx-1),3));
    else
        pctBytesQuantile(idx, 2) = sum( pctBytes_repeatingOverlaps( find( kldSources(:,3) >= q(idx-1) & kldSources(:,3) < q(idx)),:,:) == 100, 'all');
        miSourcesMean(idx, 2) = mean( kldSources( find( kldSources(:,3) >= q(idx-1) & kldSources(:,3) < q(idx)),3));
    end
end

figure('Name', 'ipv4 checksum algorithm')
plot(miSourcesMean(1:10,2), pctBytesQuantile(1:10,2) )
ylabel('number of packet pairings which were 100 pct decoded')
xlabel('quantile mean kld for observed signals')
title('ipv4 checksum algorithm')
print -depsc2 ipv4Check+kldObs.eps


%  
%  pctBytesQuantile(1,1) = sum(pctBytes_mseMinimization(find(mutInfoTestSources < q(1)),:,:) == 100 , 'all');
%  miSourcesMean(1,1) =         mean(mutInfoTestSources(find(mutInfoTestSources < q(1))));
%  pctBytesQuantile(2,1) = sum( pctBytes_mseMinimization( find( mutInfoTestSources >= q(1) & mutInfoTestSources < q(2)),:,:) == 100, 'all');
%  miSourcesMean(2,1) = mean(mutInfoTestSources(find( mutInfoTestSources >= q(1) & mutInfoTestSources < q(2))));
%  pctBytesQuantile(3,1) = sum(pctBytes_mseMinimization(find(mutInfoTestSources >= q(2) & mutInfoTestSources < q(3)),:,:) == 100, 'all');
%  miSourcesMean(3,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(2) & mutInfoTestSources < q(3))));
%  pctBytesQuantile(4,1) = sum(pctBytes_mseMinimization(find(mutInfoTestSources >= q(3) & mutInfoTestSources < q(4)),:,:) == 100, 'all');
%  miSourcesMean(4,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(3) & mutInfoTestSources < q(4))));
%  pctBytesQuantile(5,1) = sum(pctBytes_mseMinimization(find(mutInfoTestSources >= q(4) & mutInfoTestSources < q(5)),:,:) == 100, 'all');
%  miSourcesMean(5,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(4) & mutInfoTestSources < q(5))));
%  pctBytesQuantile(6,1) = sum(pctBytes_mseMinimization(find(mutInfoTestSources >= q(5) & mutInfoTestSources < q(6)),:,:) == 100,  'all');
%  miSourcesMean(6,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(5) & mutInfoTestSources < q(6))));
%  pctBytesQuantile(7,1) = sum(pctBytes_mseMinimization(find(mutInfoTestSources >= q(6) & mutInfoTestSources < q(7)),:,:) == 100, 'all');
%  miSourcesMean(7,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(6) & mutInfoTestSources < q(7))));
%  pctBytesQuantile(8,1) = sum(pctBytes_mseMinimization(find(mutInfoTestSources >= q(7) & mutInfoTestSources < q(8)),:,:) == 100, 'all');
%  miSourcesMean(8,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(7) & mutInfoTestSources < q(8))));
%  pctBytesQuantile(9,1) = sum(pctBytes_mseMinimization(find(mutInfoTestSources >= q(8) & mutInfoTestSources < q(9)),:,:) == 100, 'all');
%  miSourcesMean(9,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(8) & mutInfoTestSources < q(9))));
%  pctBytesQuantile(10,1) = sum(pctBytes_mseMinimization(find(mutInfoTestSources >= q(9) & mutInfoTestSources < q(10)),:,:) == 100, 'all');
%  miSourcesMean(10,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(9) & mutInfoTestSources < q(10))));
%  pctBytesQuantile(11,1) = sum(pctBytes_mseMinimization(find(mutInfoTestSources > q(10)),:,:) == 100, 'all' );
%  miSourcesMean(11,1) = mean(mutInfoTestSources(find(mutInfoTestSources > q(10))));
%  
%  figure('Name', 'mse minimization')
%  scatter(miSourcesMean(1:10,1), pctBytesQuantile(1:10,1))
%  ylabel('100 pct decoded')
%  xlabel('quantile mean MI')
%  title('mse minimization')
%  
%  pctBytesQuantile(1,2) = sum(pctBytes_repeatingOverlaps(find(mutInfoTestSources < q(1)),:,:) == 100 , 'all');
%  miSourcesMean(1,2) = mean(mutInfoTestSources(find(mutInfoTestSources < q(1))));
%  pctBytesQuantile(2,2) = sum( pctBytes_repeatingOverlaps( find( mutInfoTestSources >= q(1) & mutInfoTestSources < q(2)),:,:) == 100, 'all');
%  miSourcesMean(2,2) = mean(mutInfoTestSources(find( mutInfoTestSources >= q(1) & mutInfoTestSources < q(2))));
%  pctBytesQuantile(3,2) = sum(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(2) & mutInfoTestSources < q(3)),:,:) == 100, 'all');
%  miSourcesMean(3,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(2) & mutInfoTestSources < q(3))));
%  pctBytesQuantile(4,2) = sum(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(3) & mutInfoTestSources < q(4)),:,:) == 100, 'all');
%  miSourcesMean(4,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(3) & mutInfoTestSources < q(4))));
%  pctBytesQuantile(5,2) = sum(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(4) & mutInfoTestSources < q(5)),:,:) == 100, 'all');
%  miSourcesMean(5,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(4) & mutInfoTestSources < q(5))));
%  pctBytesQuantile(6,2) = sum(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(5) & mutInfoTestSources < q(6)),:,:) == 100,  'all');
%  miSourcesMean(6,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(5) & mutInfoTestSources < q(6))));
%  pctBytesQuantile(7,2) = sum(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(6) & mutInfoTestSources < q(7)),:,:) == 100, 'all');
%  miSourcesMean(7,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(6) & mutInfoTestSources < q(7))));
%  pctBytesQuantile(8,2) = sum(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(7) & mutInfoTestSources < q(8)),:,:) == 100, 'all');
%  miSourcesMean(8,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(7) & mutInfoTestSources < q(8))));
%  pctBytesQuantile(9,2) = sum(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(8) & mutInfoTestSources < q(9)),:,:) == 100, 'all');
%  miSourcesMean(9,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(8) & mutInfoTestSources < q(9))));
%  pctBytesQuantile(10,2) = sum(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(9) & mutInfoTestSources < q(10)),:,:) == 100, 'all');
%  miSourcesMean(10,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(9) & mutInfoTestSources < q(10))));
%  pctBytesQuantile(11,2) = sum(pctBytes_repeatingOverlaps(find(mutInfoTestSources > q(10)),:,:) == 100, 'all' );
%  miSourcesMean(11,2) = mean(mutInfoTestSources(find(mutInfoTestSources > q(10))));
%  
%  figure('Name', 'ipv4 checksum')
%  scatter(miSourcesMean(1:10,2), pctBytesQuantile(1:10,2) )
%  ylabel('100 pct decoded')
%  xlabel('quantile mean MI')
%  title('ipv4 checksum')
