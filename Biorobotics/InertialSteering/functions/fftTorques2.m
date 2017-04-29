function [snakeSignal,propModules,h] = fftTorques2(runType, runNb, temporalFreq, lambdaS, figureNums, windowLen, plotQ)
    
    if nargin < 4
        lambdaS = 0.1; % cutoff: mu + lambdaS * sigma, for now, 1.8/P12 or 0.1/P1 seem good (P1 better), P1 is usually better (line 63/64)
    end
    if nargin < 5
        figureNums = [1 2];
    end
    if nargin < 6
        windowLen = 4200;
    end
    if nargin < 7
        plotQ = true;
    end
    
    accX = 0; accY = 0;% accZ = 0; gyroX = 0; gyroY = 0; gyroZ = 0; tau = 0; time = 0;
    if strcmpi(runType, 'U')
        expFile = sprintf('Experiments/tmFreq_%.1f/logfileUnstuck%d.mat', temporalFreq, runNb);
    else
        expFile = sprintf('Experiments/tmFreq_%.1f/logfileStuck%d.mat', temporalFreq, runNb);
    end
    
    load(expFile);
    peakFreq                    = temporalFreq / (2*pi); % 0.2865
    [dataLen,nModules]          = size(tau);
    display(dataLen);
    Fs                          = 200;
    frequencies                 = [Fs * (0:windowLen/2)/windowLen nan];
    accValues                   = zeros(dataLen, nModules);
    accValues(:,1:2:nModules)   = accX(:,1:2:nModules);
    accValues(:,2:2:nModules)   = accY(:,2:2:nModules);
    
    % Main result
    medFilterWL                 = 400; % length of the maj/med filters' windows (400 = 2s)
    majFilterWL                 = 2000; % empirically determined, 1.5s
    threshold                   = 2/nModules; % empirically determined
    maxFreq                     = zeros(dataLen - windowLen + 1, nModules);
    
    I = zeros(1,windowLen*(dataLen-windowLen+1));
    for i=1:dataLen-windowLen+1
        I((i-1)*windowLen+1:i*windowLen) = i:i+windowLen-1;
    end
    
    for i = 1:nModules
        fprintf('Module %d',i);
        % Building huge matrix for one-time fft computation
        modValues               = accValues(:,i) * ones(1,dataLen-windowLen+1);
        fftMatrix               = reshape(modValues(I),windowLen,dataLen-windowLen+1);
        clear('modValues');
        
        disp('    Computing fft...');
        % matlab's example fft stuffs
        Y                       = fft(fftMatrix);
        clear('fftMatrix');
        P2                      = abs(Y/windowLen);
        clear('Y');
        P1                      = P2(1:windowLen/2+1,:);
        clear('P2');
        P1(2:end-1,:)           = 2*P1(2:end-1,:);
        
        disp('    fft done... Analyzing now...');
        % Angela's Magic
        P1(P1 <= ones(size(P1,1),1)*(mean(P1(2:end,:)) + lambdaS * std(P1))) = 0;
        P1d                     = diff(P1);
        clear('P1');
        
        Imin                    = (P1d >= 0);
        [~,locMin]              = max(Imin);
        Imask                   = generateMask(locMin, size(P1d));
        Imax                    = (Imask .* P1d < 0);
        clear('P1d');
        [minVals,argmax]        = max(Imax);
        argmax(minVals == 0)    = length(frequencies);
        
        maxFreq(:,i)            = frequencies(argmax);
        
        disp('    Analysis done.');
    end
    
    maxFreq(maxFreq > 2.5*peakFreq) = NaN; %low-pass filter, outlyers removal
    
    disp('Plotting now...');
    if plotQ
        figure(figureNums(1))
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
        drawnow();
%         if strcmpi(runType, 'U')
%             saveas(gca, sprintf('Experiments/Unstuck%d_AccelerometersSTD.png', runNb));
%         else
%             saveas(gca, sprintf('Experiments/Stuck%d_AccelerometersSTD.png', runNb));
%         end
        
        snakeSignal = nanmean(maxFreq, 2);
        snakeSignal = medfilter(snakeSignal, medFilterWL);
        propModules = sum(isnan(maxFreq),2) / nModules; % proportion of stuck modules
        stuckGuess  = majfilter(propModules, majFilterWL, threshold);
        
        figure(figureNums(2))
        clf
        title('Average Snake Sinal from accerometers X/Y (medfilter400,2s)');
        hold on
        xlabel('time [s]');
        ylabel('FFT Peak [Hz]');
        plot(time(windowLen:dataLen), snakeSignal);
        plot(time(windowLen:dataLen), propModules, 'red');
        h = plot(time(windowLen:dataLen), stuckGuess, 'black', 'linewidth', 2);
        hold off
        drawnow();
%         if strcmpi(runType, 'U')
%             saveas(gca, sprintf('Experiments/Unstuck%d_snakeSignalNaN.png', runNb));
%         else
%             saveas(gca, sprintf('Experiments/Stuck%d_snakeSignalNaN.png', runNb));
%         end
    end
end
