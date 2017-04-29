function [Thead,Tshape] = plotResults2(nExp, shapeThresh, windowSize, plotQ)

if nargin < 2
    shapeThresh = 0.8;
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

Tcell = {find(and(abs(diff(headingOffsetValues))<=3,diff(headingOffsetValues)>0))+1, find(abs(diff(headingOffsetValues))>3)+1};
Tshape = cell(1,length(Tcell));
Thead = cell(1,length(Tcell));
TchangesH = cell(1,length(Tcell));
TchangesS = cell(1,length(Tcell));

for j=1:length(Tcell)
    Tchanges = Tcell{j};
    Thead{j} = zeros(1,length(Tchanges));
    Tshape{j} = zeros(1,length(Tchanges));
    for i=1:length(Tchanges)
        % Heading error bump length
        if headingsFiltered(Tchanges(i)) >= 0
            find(diff(headingsFiltered(Tchanges(i):end) <= headingsFiltered(Tchanges(i)-1)) ~= 0,1)
            Thead{j}(i) = find(diff(headingsFiltered(Tchanges(i):end) <= headingsFiltered(Tchanges(i)-1)) ~= 0,1);
        else
            Thead{j}(i) = find(diff(headingsFiltered(Tchanges(i):end) >= headingsFiltered(Tchanges(i)-1)) ~= 0,1);
        end

%         % Shape Regularity bump length
%         tmp = find(diff(shapeRegFiltered(Tchanges(i):end)>shapeThresh) ~= 0, 1+(shapeRegFiltered(Tchanges(i))<=shapeThresh));
%         Tshape{j}(i) = tmp(end);
        % Shape Regularity bump length
        tmp = find(diff(shapeSTD(Tchanges(i):end) <= shapeThresh)~=0, 1+(shapeSTD(Tchanges(i))<=shapeThresh));
        if isempty(tmp)
            Tshape{j}(i) = nan;
        else
            Tshape{j}(i) = tmp(end);
        end
    end
    
    Tshape{j} = Tshape{j} * dt;
    Thead{j} = Thead{j} * dt;
    
    I = abs(Thead{j} - mean(Thead{j})) <= 2*std(Thead{j});
    Thead{j} = Thead{j}(I);
    TchangesH{j} = Tchanges(I);

    I = abs(Tshape{j} - mean(Tshape{j})) <= 3*std(Tshape{j});
    Tshape{j} = Tshape{j}(I);
    TchangesS{j} = Tchanges(I);
end

if plotQ
    for j=1:length(Tcell)
        display([mean(Thead{j}) mean(Tshape{j}); std(Thead{j}) std(Tshape{j})]);
    end

    figure(1)
    clf
    subplot(length(Tcell)+1,1,1)
    hold on
    plot(times, headingsFiltered(1:length(times)));
    plot(times, shapeRegFiltered(1:length(times)), 'red');
    plot(times, headingOffsetValues(1:length(times)), 'black');
    axis([0 50*ceil(t/50) -pi pi]);
    hold off
    for j=1:length(Tcell)
        subplot(length(Tcell)+1,1,j+1)
        hold on
        plot(TchangesH{j}*dt, Thead{j});
        plot(TchangesS{j}*dt, Tshape{j}, 'red');
        axis([0 50*ceil(t/50) 0 max([Thead{j} Tshape{j}])+1]);
        hold off
    end
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
