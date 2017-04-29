function maxFreq = get_maxFreq(filterLen, accelReading, dt)

    lambdaS = 0.1;
    frequencies = (1/dt) * (0 : filterLen/2)/filterLen;

    Z = fft(accelReading(1:filterLen , :));
    P2 = abs(Z/filterLen);
    P1 = P2(1:filterLen/2+1, :);
    P1(2:end-1, :) = 2 * P1(2:end-1, :);
    FFTmatrixB(:, 1) = mean(P1, 2);

    FFTmatrixAD = FFTmatrixB;
    FFTmatrixAD(FFTmatrixB <= ones(size(FFTmatrixB,1),1)*(mean(FFTmatrixB) + lambdaS * std(FFTmatrixB))) = 0;
    FFTmatrixAD             = diff(FFTmatrixAD);
%     clear('FFTmatrixB');

    Imin                    = (FFTmatrixAD >= 0);
    [~,locMin]              = max(Imin);
    ImaskB                  = generateMask(locMin, size(FFTmatrixAD));
    Imax                    = (ImaskB .* FFTmatrixAD < 0);
    clear('FFTmatrixAD');
    [minVals,argmaxA]       = max(Imax);
    argmaxA(minVals == 0)   = 1;
    
    maxFreq                 = frequencies(argmaxA);
%     if maxFreq > 2.5*peakFreq
%         maxFreq = 0; %low-pass filter, outlyers removal
%     end

end