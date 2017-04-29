function snakeSignal = fftTorques(runType, runNb, windowLen, plotQ)
    
    if nargin < 3
        windowLen = 4200;
    end
    if nargin < 4
        plotQ = true;
    end
    
    tic
    
    accX = 0; accY = 0; accZ = 0; gyroX = 0; gyroY = 0; gyroZ = 0; tau = 0; time = 0;
    if strcmpi(runType, 'U')
        expFile = sprintf('Experiments/logfileUnstuck%d.mat', runNb);
    else
        expFile = sprintf('Experiments/logfileStuck%d.mat', runNb);
    end
    
    load(expFile);
    
    temporalFreq        = 1.8;
    peakFreq            = temporalFreq / (2*pi); % 0.2865
    [dataLen,nModules]  = size(tau);
    Fs                  = 200;
    frequencies         = Fs * (0:windowLen/2)/windowLen;
    
    allValues           = zeros(2, dataLen, nModules);
    allValues(1,:,:)    = accX(:,:);
    allValues(2,:,:)    = accY(:,:);

    
    maxFreq = zeros(dataLen - windowLen + 1, nModules);
    if plotQ
        wb = waitbar(0,'Computing...');
        nIter = (dataLen - windowLen + 1) * nModules;
        it = 0;
    end
    for i = 1:nModules
        currData(:) = allValues(2 - mod(i,2), :, i);
        count    = 1;

        while (count <= dataLen - windowLen + 1)
            currVect             = currData(count : count + windowLen-1);

            % matlab's example fft stuffs
            Y                    = fft(currVect);
            P2                   = abs(Y/windowLen);
            P1                   = P2(1:windowLen/2+1);
            P1(2:end-1)          = 2*P1(2:end-1);

            % Angela's Magic
            P1(P1 <= mean(P1(2:end)) + 0.5*std(P1)) = 0;
            locMin = find(diff(P1) < 0 == 0,1);
            locMax = find(diff(P1(locMin:end)) >= 0 == 0,1);
            if isempty(locMax)
                maxFreq(count, i) = NaN;
            else
                argmax = locMin + locMax;
                maxFreq(count, i) = frequencies(argmax);
            end

            maxFreq(count, i) = frequencies(argmax);
            count              = count + 1;
            if plotQ
                it = it + 1;
                waitbar(it/nIter);
            end
        end
    end
    
    maxFreq(maxFreq > 2.5*peakFreq) = NaN; %low-pass filter, outlyers removal
    
    toc
    if plotQ
        close(wb);
        
        figure(1)
        clf
        title('Accelerometers X/Y');
        hold on
        for i=1:16
            subplot(4,4,i)
            title(sprintf('Module %d', i));
            xlabel('time [s]');
            ylabel('FFT Peak [Hz]');
            plot(time(windowLen:dataLen),maxFreq(:,i));
        end
        hold off
        if strcmpi(runType, 'U')
            saveas(gca, sprintf('Experiments/Unstuck%d_AccelerometersSTD.png', runNb));
        else
            saveas(gca, sprintf('Experiments/Stuck%d_AccelerometersSTD.png', runNb));
        end
        
        snakeSignal = nanmean(maxFreq, 2);
        snakeSignal = medfilter(snakeSignal,400);
        propModules = sum(isnan(maxFreq),2) / nModules;
        figure(2)
        clf
        title('Average Snake Signal from accerometers X/Y (medfilter400,2s)');
        hold on
        xlabel('time [s]');
        ylabel('FFT Peak [Hz]');
        plot(time(windowLen:dataLen), snakeSignal);
        plot(time(windowLen:dataLen), propModules, 'red');
        hold off
        if strcmpi(runType, 'U')
            saveas(gca, sprintf('Experiments/Unstuck%d_SnakeSignalNaN.png', runNb));
        else
            saveas(gca, sprintf('Experiments/Stuck%d_SnakeSignalNaN.png', runNb));
        end
    end
end
