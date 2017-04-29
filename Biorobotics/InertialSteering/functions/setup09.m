lambdaS = 0.1;

% [snakeSignal1,propModules1,h1] = fftTorques2('s',1,0.9,lambdaS,[3 2]);
% [snakeSignal2,propModules2,h2] = fftTorques2('u',2,0.9,lambdaS,[1 4]);
% [snakeSignal3,propModules3,h3] = fftTorques2('s',3,0.9,lambdaS,[3 5]);
% [snakeSignal4,propModules4,h4] = fftTorques2('u',4,0.9,lambdaS,[1 6]);

[FFTmatrix1,~,h1] = fftTorques3('s',1,0.9,lambdaS,1);
[FFTmatrix2,~,h2] = fftTorques3('u',2,0.9,lambdaS,2);
[FFTmatrix3,~,h3] = fftTorques3('s',3,0.9,lambdaS,3);
[FFTmatrix4,~,h4] = fftTorques3('u',4,0.9,lambdaS,4);

Fs                          = 200;
temporalFreq                = 0.9;
lambdaFreq                  = 10;

windowLen                   = round(200 * 3 * 2 * pi / (100 * temporalFreq)) * 100;
peakFreq                    = temporalFreq / (2*pi); % 0.2865 for 1.8
frequencies                 = Fs * (0:windowLen/2)/windowLen;
freqMax                     = sum( frequencies <= lambdaFreq * peakFreq ); % empirically chosen
