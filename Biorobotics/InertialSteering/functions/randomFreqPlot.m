function randomFreqPlot(runType, runNb, windowLen, plotQ)
    
    if nargin < 3
        windowLen = 4188;
    end
    if nargin < 4
        plotQ = true;
    end
    
    accX = 0; accY = 0; accZ = 0; gyroX = 0; gyroY = 0; gyroZ = 0; tau = 0; time = 0;
    if strcmpi(runType, 'U')
        expFile = sprintf('Experiments/logfileUnstuck%d.mat', runNb);
    else
        expFile = sprintf('Experiments/logfileStuck%d.mat', runNb);
    end
    
    load(expFile);
    
    [dataLen,nModules]  = size(tau);
    Fs                  = 200;
    freqs               = Fs * (0:windowLen/2)/windowLen;
    
    allValues           = zeros(7, dataLen, nModules);
    allValues(1,:,:) = accX(:,:);
    allValues(2,:,:) = accY(:,:);
    allValues(3,:,:) = accZ(:,:);
    allValues(4,:,:) = gyroX(:,:);
    allValues(5,:,:) = gyroY(:,:);
    allValues(6,:,:) = gyroZ(:,:);
    allValues(7,:,:) = tau(:,:);
    vals = {'accX', 'accY', 'accZ', 'gyroX', 'gyroY', 'gyroZ', 'tau'};
    nVals = 1:length(vals);
    nVals = [1];
    
    maxFreq = zeros(length(vals), dataLen - windowLen + 1, nModules);
%     if plotQ
%         wb = waitbar(0,'Computing...');
%         nIter = length(nVals) * (dataLen - windowLen + 1) * nModules;
%         it = 0;
%     end
    randomStartTime = randi(dataLen - windowLen - 1);
    randomModule    = randi(16);
    display(randomStartTime);
    for j = nVals
%         for i = 1:nModules
            currData(:) = allValues(2-mod(randomModule,2), :, randomModule);
%             count    = 1;
            
%             while (count <= dataLen - windowLen + 1)
                currVect             = currData(randomStartTime : randomStartTime + windowLen-1);
                
                % matlab's example fft stuffs
                Y                    = fft(currVect);
                P2                   = abs(Y/windowLen);
                P1                   = P2(1:windowLen/2+1);
                P1(2:end-1)          = 2*P1(2:end-1);
                
%                 P1(1:20)
                
                % find max peak
                [~, argmax]          = max(P1(2:end));
%                 display(freqs(argmax+1));
%                 maxFreq(j, count, i) = freqs(argmax);
                
%                 count                = count + 1;
%                 if plotQ
%                     it = it + 1;
%                     waitbar(it/nIter);
%                 end
%             end
%         end
    end
    
    P1(P1 <= mean(P1(2:end)) + std(P1)) = 0;
    locMin = 1;
    while P1(locMin) > P1(locMin + 1)
        locMin = locMin + 1;
    end
    clf;
    hold on;
    plot(freqs(1:20), P1(1:20), 'b');
    plot(freqs(locMin:locMin+20), P1(locMin:locMin+20), 'r');

    locMax = 1;
    while locMin+locMax < length(P1) && P1(locMin + locMax) <= P1(locMin + locMax + 1)
        locMax = locMax + 1;
    end
    argmax = locMin + locMax;
    display(freqs(argmax));
%     
%     if plotQ
%         close(wb);
%         
%         for j=nVals
%             figure(1)
%             clf
%             title(vals{j});
%             hold on
%             for i=1:16
%                 subplot(4,4,i)
%                 title(sprintf('Module %d', i));
%                 xlabel('time [s]');
%                 ylabel('FFT Peak [Hz]');
%                 plot(time(windowLen:dataLen),maxFreq(j,:,i));
%             end
%             hold off
%             if strcmpi(runType, 'U')
%                 saveas(gca, sprintf('Experiments/Unstuck%d_%s.png', runNb, vals{j}));
%             else
%                 saveas(gca, sprintf('Experiments/Stuck%d_%s.png', runNb, vals{j}));
%             end
%         end
%     end
end
