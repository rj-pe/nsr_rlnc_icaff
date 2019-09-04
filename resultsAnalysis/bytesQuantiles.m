load('AMERICA_mi_obs_0-054---1-046_100-pairs_13-Aug-2019_18:14:49/final.mat');
q = quantile(mutInfoTestSources, 10);

pctBytesQuantile = zeros(11,2);
miSourcesMean = zeros(11,2);


pctBytesQuantile(1,1) = mean(pctBytes_mseMinimization(find(mutInfoTestSources < q(1)),:,:), 'all');
miSourcesMean(1,1) = mean(mutInfoTestSources(find(mutInfoTestSources < q(1))));
pctBytesQuantile(2,1) = mean( pctBytes_mseMinimization( find( mutInfoTestSources >= q(1) & mutInfoTestSources < q(2)),:,:), 'all');
miSourcesMean(2,1) = mean(mutInfoTestSources(find( mutInfoTestSources >= q(1) & mutInfoTestSources < q(2))));
pctBytesQuantile(3,1) = mean(pctBytes_mseMinimization(find(mutInfoTestSources >= q(2) & mutInfoTestSources < q(3)),:,:), 'all');
miSourcesMean(3,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(2) & mutInfoTestSources < q(3))));
pctBytesQuantile(4,1) = mean(pctBytes_mseMinimization(find(mutInfoTestSources >= q(3) & mutInfoTestSources < q(4)),:,:), 'all');
miSourcesMean(4,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(3) & mutInfoTestSources < q(4))));
pctBytesQuantile(5,1) = mean(pctBytes_mseMinimization(find(mutInfoTestSources >= q(4) & mutInfoTestSources < q(5)),:,:), 'all');
miSourcesMean(5,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(4) & mutInfoTestSources < q(5))));
pctBytesQuantile(6,1) = mean(pctBytes_mseMinimization(find(mutInfoTestSources >= q(5) & mutInfoTestSources < q(6)),:,:), 'all');
miSourcesMean(6,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(5) & mutInfoTestSources < q(6))));
pctBytesQuantile(7,1) = mean(pctBytes_mseMinimization(find(mutInfoTestSources >= q(6) & mutInfoTestSources < q(7)),:,:), 'all');
miSourcesMean(7,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(6) & mutInfoTestSources < q(7))));
pctBytesQuantile(8,1) = mean(pctBytes_mseMinimization(find(mutInfoTestSources >= q(7) & mutInfoTestSources < q(8)),:,:), 'all');
miSourcesMean(8,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(7) & mutInfoTestSources < q(8))));
pctBytesQuantile(9,1) = mean(pctBytes_mseMinimization(find(mutInfoTestSources >= q(8) & mutInfoTestSources < q(9)),:,:), 'all');
miSourcesMean(9,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(8) & mutInfoTestSources < q(9))));
pctBytesQuantile(10,1) = mean(pctBytes_mseMinimization(find(mutInfoTestSources >= q(9) & mutInfoTestSources < q(10)),:,:), 'all');
miSourcesMean(10,1) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(9) & mutInfoTestSources < q(10))), 'all');
pctBytesQuantile(11,1) = mean(pctBytes_mseMinimization(find(mutInfoTestSources > q(10)),:,:), 'all');
miSourcesMean(11,1) = mean(mutInfoTestSources(find(mutInfoTestSources > q(10))));

figure('Name', 'mse minimization')
scatter(miSourcesMean(:,1), pctBytesQuantile(:,1))
ylabel('mean pct bytes decoded')
xlabel('quantile mean MI')
title('mse minimization')

pctBytesQuantile(1,2) = mean(pctBytes_repeatingOverlaps(find(mutInfoTestSources < q(1)),:,:), 'all');
miSourcesMean(1,2) = mean(mutInfoTestSources(find(mutInfoTestSources < q(1))));
pctBytesQuantile(2,2) = mean( pctBytes_repeatingOverlaps( find( mutInfoTestSources >= q(1) & mutInfoTestSources < q(2)),:,:), 'all');
miSourcesMean(2,2) = mean(mutInfoTestSources(find( mutInfoTestSources >= q(1) & mutInfoTestSources < q(2))));
pctBytesQuantile(3,2) = mean(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(2) & mutInfoTestSources < q(3)),:,:), 'all');
miSourcesMean(3,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(2) & mutInfoTestSources < q(3))));
pctBytesQuantile(4,2) = mean(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(3) & mutInfoTestSources < q(4)),:,:), 'all');
miSourcesMean(4,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(3) & mutInfoTestSources < q(4))));
pctBytesQuantile(5,2) = mean(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(4) & mutInfoTestSources < q(5)),:,:), 'all');
miSourcesMean(5,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(4) & mutInfoTestSources < q(5))));
pctBytesQuantile(6,2) = mean(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(5) & mutInfoTestSources < q(6)),:,:), 'all');
miSourcesMean(6,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(5) & mutInfoTestSources < q(6))));
pctBytesQuantile(7,2) = mean(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(6) & mutInfoTestSources < q(7)),:,:), 'all');
miSourcesMean(7,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(6) & mutInfoTestSources < q(7))));
pctBytesQuantile(8,2) = mean(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(7) & mutInfoTestSources < q(8)),:,:), 'all');
miSourcesMean(8,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(7) & mutInfoTestSources < q(8))));
pctBytesQuantile(9,2) = mean(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(8) & mutInfoTestSources < q(9)),:,:), 'all');
miSourcesMean(9,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(8) & mutInfoTestSources < q(9))));
pctBytesQuantile(10,2) = mean(pctBytes_repeatingOverlaps(find(mutInfoTestSources >= q(9) & mutInfoTestSources < q(10)),:,:), 'all');
miSourcesMean(10,2) = mean(mutInfoTestSources(find(mutInfoTestSources >= q(9) & mutInfoTestSources < q(10))));
pctBytesQuantile(11,2) = mean(pctBytes_repeatingOverlaps(find(mutInfoTestSources > q(10)),:,:), 'all');
miSourcesMean(11,2) = mean(mutInfoTestSources(find(mutInfoTestSources > q(10))));


figure('Name', 'ipv4 checksum')
scatter(miSourcesMean(:,2), pctBytesQuantile(:,2) )
ylabel('mean pct bytes decoded')
xlabel('quantile mean MI')
title('ipv4 checksum')