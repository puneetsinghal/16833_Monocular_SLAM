function generateTorquePlots()
    load('log.mat');
    windowLen = 400;
    dataLen = size(log.torque, 1);
    dataEnd = 400;
    
    for i = 1 : 16
%         data = log.torque(:, i);
        [f, power] = plotFFT(i);
        maxX = zeros(1, dataLen - windowLen);
        maxY = zeros(1, dataLen - windowLen);
        while (dataEnd ~= dataLen)
            [maxY(dataEnd - windowLen), maxX(dataEnd - windowLen)] = max(power(dataEnd - windowLen, dataEnd));
            dataEnd = dataEnd + 1;
        end
        figure(i)
        subplot(2, 1, 1)
        plot(1 : 1 : dataLen - windowLen, maxX);
        
        subplot(2, 1, 2)
        plot(1 : 1 : dataLen - windowLen, maxY);
        
       
    end
end
