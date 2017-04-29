function snakeSinal = fftTorquesGPUp(runType, runNb, temporalFreq, windowLen, plotQ)
    
    if nargin < 3
        temporalFreq = 0.9;
    end
    if nargin < 4
        windowLen = 4200;
    end
    if nargin < 5
        plotQ = true;
    end
    
    tic
    
    accX = 0; accY = 0;% accZ = 0; gyroX = 0; gyroY = 0; gyroZ = 0; tau = 0; time = 0;
    if strcmpi(runType, 'U')
        expFile = sprintf('Experiments/tmFreq_%.1f/logfileUnstuck%d.mat', temporalFreq, runNb);
    else
        expFile = sprintf('Experiments/tmFreq_%.1f/logfileStuck%d.mat', temporalFreq, runNb);
    end
    
    load(expFile);
    peakFreq                    = temporalFreq / (2*pi); % 0.2865
    [dataLen,nModules]          = size(tau);
    Fs                          = 200;
    frequencies                 = [Fs * (0:windowLen/2)/windowLen nan];
    accValues                   = zeros(dataLen, nModules);
    accValues(:,1:2:nModules)   = accX(:,1:2:nModules);
    accValues(:,2:2:nModules)   = accY(:,2:2:nModules);
    
    % Main result
    maxFreq                     = zeros(dataLen - windowLen + 1, nModules);
    
    tmp                         = ones(dataLen,dataLen-windowLen+1);
    I                           = (tril(tmp,0) - tril(tmp,-windowLen)) > 0;
    
    parfor i = 1:nModules
        display(sprintf('Module %d',i));
        % Building huge mtrix for one-time fft computation
        modValues               = accValues(:,i) * ones(1,dataLen-windowLen+1);
        fftMatrixG              = gpuArray( reshape(modValues(I),windowLen,dataLen-windowLen+1) );
        
        display('    Computing fft...');
        % matlab's example fft stuffs
%         Y                       = gather(fft(fftMatrixG));
        Y                       = fft(fftMatrixG);
        P2                      = abs(Y/windowLen);
        P1                      = P2(1:windowLen/2+1,:);
        P1(2:end-1,:)           = 2*P1(2:end-1,:);
        
        display('    fft done... Analyzing now...');
        % Angela's Magic
        P1(P1 <= ones(size(P1,1),1)*(mean(P1(2:end,:)) ...
        + 0.5*std(P1)))         = 0;
        P1d                     = diff(P1);
        
        Imin                    = (P1d >= 0);
        [~,locMin]              = max(Imin);
        Imask                   = gpuArray( generateMask(locMin, size(P1d)) );
        Imax                    = (Imask .* P1d < 0);
        [minVals,argmax]        = max(Imax);
        argmax(minVals == 0)    = length(frequencies);
        
        maxFreqs                            = frequencies(argmax);
        maxFreqs(maxFreqs > 2.5*peakFreq,i) = NaN; %low-pass filter, outliers removal
        maxFreq(:,i)                        = maxFreqs;
        
        display('    Analysis done.');
    end
    
    display('Plotting now...');
    toc
    if plotQ
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
%         if strcmpi(runType, 'U')
%             saveas(gca, sprintf('Experiments/Unstuck%d_AccelerometersSTD.png', runNb));
%         else
%             saveas(gca, sprintf('Experiments/Stuck%d_AccelerometersSTD.png', runNb));
%         end
        
        snakeSinal = nanmean(maxFreq, 2);
        snakeSinal = medfilter(snakeSinal,400);
        propModules = sum(isnan(maxFreq),2) / nModules;
        figure(2)
        clf
        title('Average Snake Sinal from accerometers X/Y (medfilter400,2s)');
        hold on
        xlabel('time [s]');
        ylabel('FFT Peak [Hz]');
        plot(time(windowLen:dataLen), snakeSinal);
        plot(time(windowLen:dataLen), propModules, 'red');
        hold off
%         if strcmpi(runType, 'U')
%             saveas(gca, sprintf('Experiments/Unstuck%d_SnakeSinalNaN.png', runNb));
%         else
%             saveas(gca, sprintf('Experiments/Stuck%d_SnakeSinalNaN.png', runNb));
%         end
    end
end