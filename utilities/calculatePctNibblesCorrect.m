function percentage = calculatePctNibblesCorrect(estimate, original)

packetLength = size(original, 2);


percentage = round(100 * (sum(estimate == original) / packetLength));

end