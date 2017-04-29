function [Thead,Tshape] = plotResults(nExp, shapeThresh, windowSize, plotQ)

if nargin < 2
    shapeThresh = 0.762;
end
if nargin < 3
    windowSize = 50;
end
if nargin < 4
    plotQ = true;
end


shapeRegularity = []; headingValues = [];
load(sprintf('Experiments/PaperExperiments/experiment%d.mat', nExp));
[shapeRegFiltered,shapeSTD] = medfilter(shapeRegularity, windowSize);
headingsFiltered = medfilter(headingValues, round(windowSize/5));
times = 0:dt:t;

Tchanges = find(diff(headingOffsetValues)~=0);
Tshape = zeros(1,length(Tchanges));
Thead = zeros(1,length(Tchanges));

for i=1:length(Tchanges)
    % Heading error bump length
    if headingsFiltered(Tchanges(i)) >= 0
        find(diff(headingsFiltered(Tchanges(i):end) <= headingsFiltered(Tchanges(i)-1)) ~= 0,1);
        tmp = find(diff(headingsFiltered(Tchanges(i):end) <= headingsFiltered(Tchanges(i)-1)) ~= 0,1);
    else
        tmp = find(diff(headingsFiltered(Tchanges(i):end) >= headingsFiltered(Tchanges(i)-1)) ~= 0,1);
    end
    if isempty(tmp)
        Thead(i) = nan;
    else
        Thead(i) = tmp(end);
    end

%     % Shape Regularity bump length
%     tmp = find(diff(shapeRegFiltered(Tchanges(i):end)>shapeThresh) ~= 0, 1+(shapeRegFiltered(Tchanges(i))<=shapeThresh));
%     Tshape(i) = tmp(end);
    % Shape Regularity bump length
    tmp = find(diff(shapeSTD(Tchanges(i):end) <= shapeThresh)~=0, 1+(shapeSTD(Tchanges(i))<=shapeThresh));
    if isempty(tmp)
        Tshape(i) = nan;
    else
        Tshape(i) = tmp(end);
    end
end
    
Tshape = Tshape * dt;
Thead = Thead * dt;

Ih = abs(Thead - nanmean(Thead)) <= 2*nanstd(Thead);
Is = abs(Tshape - nanmean(Tshape)) <= 2*nanstd(Tshape);
I = and(Ih,Is);
Thead = Thead(I);
Tshape = Tshape(I);

if plotQ
    display([nanmean(Thead) nanmean(Tshape); nanstd(Thead) nanstd(Tshape)]);

    figure(1)
    clf
    subplot(2,1,1)
    hold on
    plot(times, headingsFiltered(1:length(times)));
    plot(times, shapeRegFiltered(1:length(times)), 'red');
    plot(times, headingOffsetValues(1:length(times)), 'black');
    axis([0 50*ceil(t/50) -pi pi]);
    hold off
    subplot(2,1,2)
    hold on
%     plot(TchangesH*dt, Thead);
%     plot(TchangesS*dt, Tshape, 'red');
    plot(Thead);
    plot(Tshape, 'red');
    axis([0 50*ceil(t/50) 0 max([Thead Tshape])+1]);
    hold off
    
    figure(2)
    clf
    hold on
    plot(Thead, 'linewidth', 2);
    plot(Tshape, 'red', 'linewidth', 2);
    axis([0 max(length(Thead),length(Tshape)) 0 max([Thead Tshape])+1]);
    legend('head', 'whole body');
    title('Time needed to perform steering');
    xlabel('Steering maneuver [#]');
    ylabel('Steering time [s]');
    set(gca, 'FontSize', 24, 'linewidth', 1.5);
    hold off
end



% Method 1
%
%     % Heading error bump length
%     tmp = find(diff(abs(headingsFiltered(Tchanges(i):end))>headThresh) ~= 0, 1+(abs(headingsFiltered(Tchanges(i)))<=headThresh));
%     Thead(i) = tmp(end);
%     % Shape Regularity bump length
%     tmp = find(diff(shapeRegFiltered(Tchanges(i):end)>shapeThresh) ~= 0, 1+(shapeRegFiltered(Tchanges(i))<=shapeThresh));
%     Tshape(i) = tmp(end);
%     % Shape Regularity bump length
%     Tshape(i) = find(diff(shapeRegFiltered(Tchanges(i):end) <= shapeRegFiltered(Tchanges(i)-1)) ~= 0,1);
