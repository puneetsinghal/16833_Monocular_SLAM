function [FFTmatrixA,FFTmatrixG,snakeSignal,h] = fftTorques3(runType, runNb, temporalFreq, lambdaS, figureNum, windowLen, plotQ)
    
    if nargin < 4
        lambdaS = 0.1; % cutoff: mu + lambdaS * sigma, for now, 1.8/P12 or 0.1/P1 seem good (P1 better), P1 is usually better (line 63/64)
    end
    if nargin < 5
        figureNum = 1;
    end
    if nargin < 6
        % 2 periods @ 200Hz, rounded to the nearest hundred
        windowLen = round(2 * 200 * 2 * pi / (100 * temporalFreq)) * 100;
        disp(windowLen);
    end
    if nargin < 7
        plotQ = true;
    end
    
    accX = 0; accY = 0;% gyroX = 0; gyroY = 0;
    if strcmpi(runType, 'U')
        expFile = sprintf('Experiments/tmFreq_%.1f/logfileUnstuck%d.mat', temporalFreq, runNb);
    else
        expFile = sprintf('Experiments/tmFreq_%.1f/logfileStuck%d.mat', temporalFreq, runNb);
    end
    
    load(expFile);
    peakFreq                    = temporalFreq / (2*pi); % 0.2865 for 1.8
    [dataLen,nModules]          = size(tau);
%     display(dataLen);
    Fs                          = 200;
    frequencies                 = Fs * (0:windowLen/2)/windowLen;
    freqMax                     = sum( frequencies <= 10 * peakFreq ); % lambdaFreq = 10, empirically chosen
    accValues                   = zeros(dataLen, nModules);
    accValues(:,1:2:nModules)   = accX(:,1:2:nModules);
    accValues(:,2:2:nModules)   = accY(:,2:2:nModules);
%     gyroValues                  = zeros(dataLen, nModules);
%     gyroValues(:,1:2:nModules)  = gyroX(:,1:2:nModules);
%     gyroValues(:,2:2:nModules)  = gyroY(:,2:2:nModules);
    
    medFilterWL                 = windowLen; % length of the maj/med filters' windows (400 = 2s)
    
    %%
    disp('    Computing fft''s...');
    
    FFTmatrixA = zeros(windowLen/2+1,dataLen-windowLen+1);
%     FFTmatrixG = zeros(windowLen/2+1,dataLen-windowLen+1);
    
    if plotQ
        wb = waitbar(0, 'computing fft''s...');
    end
    for t = 1:dataLen-windowLen+1
%         fprintf('%d/%d\n',t,dataLen-windowLen);
        
        % Accelerometers
        Y                       = fft(accValues(t:t+windowLen-1,:));
        P2                      = abs(Y/windowLen);
        P1                      = P2(1:windowLen/2+1,:);
        P1(2:end-1,:)           = 2*P1(2:end-1,:);
        FFTmatrixA(:,t)         = mean(P1,2);
        
%         % Gyros
%         Y                       = fft(gyroValues(t:t+windowLen-1,:));
%         P2                      = abs(Y/windowLen);
%         P1                      = P2(1:windowLen/2+1,:);
%         P1(2:end-1,:)           = 2*P1(2:end-1,:);
%         FFTmatrixG(:,t)         = mean(P1,2);
        
        if plotQ
            waitbar(t/(dataLen-windowLen+1), wb);
        end
    end
    if plotQ
        close(wb);
    end
    
    %%
    disp('    fft done... Analyzing now...');
    
    % Angela's Magic - Accelerometers
    FFTmatrixAD = FFTmatrixA;
    FFTmatrixAD(FFTmatrixA <= ones(size(FFTmatrixA,1),1)*(mean(FFTmatrixA) + lambdaS * std(FFTmatrixA))) = 0;
    FFTmatrixAD             = diff(FFTmatrixAD);
%     clear('FFTmatrixA');
    
    Imin                    = (FFTmatrixAD >= 0);
    [~,locMin]              = max(Imin);
    Imask                   = generateMask(locMin, size(FFTmatrixAD));
    Imax                    = (Imask .* FFTmatrixAD < 0);
    clear('FFTmatrixAD');
    [minVals,argmaxA]       = max(Imax);
    argmaxA(minVals == 0)   = 1;
    maxFreqA                = frequencies(argmaxA);
    stdA                    = std(FFTmatrixA(1:freqMax,:));
    maxValA                 = FFTmatrixA(argmaxA + 0:size(FFTmatrixA,1):length(FFTmatrixA(:)-1));
    
%     % Angela's Magic - Gyros
%     FFTmatrixGD = FFTmatrixG;
%     FFTmatrixGD(FFTmatrixG <= ones(size(FFTmatrixG,1),1)*(mean(FFTmatrixG) + lambdaS * std(FFTmatrixG))) = 0;
%     FFTmatrixGD              = diff(FFTmatrixGD);
% %     clear('FFTmatrixG');
%     
%     Imin                    = (FFTmatrixGD >= 0);
%     [~,locMin]              = max(Imin);
%     Imask                   = generateMask(locMin, size(FFTmatrixGD));
%     Imax                    = (Imask .* FFTmatrixGD < 0);
%     clear('FFTmatrixGD');
%     [minVals,argmaxG]       = max(Imax);
%     argmaxG(minVals == 0)   = 1;
%     maxFreqG                = frequencies(argmaxG);
%     stdG                    = std(FFTmatrixG(1:freqMax,:));
%     maxValG                 = FFTmatrixG(argmaxG + 0:size(FFTmatrixG,1):length(FFTmatrixG(:)-1));
    
    maxFreqA(maxFreqA > 2.5*peakFreq) = 0; %low-pass filter, outlyers removal
%     maxFreqG(maxFreqG > 2.5*peakFreq) = 0; %low-pass filter, outlyers removal
    
    disp('    Analysis done.');
    
    %%
    disp('Plotting now...');
    if plotQ
        snakeSignalA = medfilter(maxFreqA, medFilterWL);
%         snakeSignalG = medfilter(maxFreqG, medFilterWL);
        
        figure(figureNum)
        clf
        title('Average Snake Signal from accerometers X/Y (medfilter400,2s)');
        hold on
        xlabel('time [s]');
        ylabel('FFT Peak [Hz]');
        plot(time(windowLen:dataLen), snakeSignalA, 'blue');
        plot(time(windowLen:dataLen), maxFreqA, 'black');
%         plot(time(windowLen:dataLen), maxValA, 'black');
%         h = plot(time(windowLen:dataLen), stdA, 'red');
%         plot(time(windowLen:dataLen), snakeSignalG, '--', 'color', 'blue');
%         plot(time(windowLen:dataLen), maxValG, '--', 'color', 'black');
%         h = plot(time(windowLen:dataLen), stdG, '--', 'color', 'red');
        hold off
        drawnow();
%         if strcmpi(runType, 'U')
%             saveas(gca, sprintf('Experiments/Unstuck%d_snakeSignalNaN.png', runNb));
%         else
%             saveas(gca, sprintf('Experiments/Stuck%d_snakeSignalNaN.png', runNb));
%         end
    end
end
