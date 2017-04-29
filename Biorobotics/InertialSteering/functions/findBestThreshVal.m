function bestVal = findBestThreshVal(vmin, vmax, dv, nExp, windowSize)

if nargin < 4
    nExp = 1;
end
if nargin < 5
    windowSize = 50;
end

vals = vmin:dv:vmax;

[~,Tshape] = plotResults(nExp, vmin, windowSize, false);
bestVal = [vmin mean(Tshape) std(Tshape) length(Tshape)];
values = [bestVal; zeros(length(vals)-1,4)];
bestRatio = mean(Tshape) / std(Tshape);
for i=2:length(vals)
    v = vals(i);
    [~,Tshape] = plotResults(nExp, v, windowSize, false);
    values(i,:) = [v mean(Tshape) std(Tshape) length(Tshape)];
    newRatio = mean(Tshape) / std(Tshape);
    if newRatio > bestRatio
        bestVal = [v mean(Tshape) std(Tshape) length(Tshape)];
        bestRatio = newRatio;
    end
end

figure
hold on
plot(vals, values(:,2) ./ values(:,3));
plot(vals, max(values(:,4)) - values(:,4), 'black');
hold off

display(bestVal)
