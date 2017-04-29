function varyLambdaS(values)

for lambdaS = values
    tic;
    fftTorques2('u',4,0.9,lambdaS,[1 2]); % figure 2 / 7965
    fftTorques2('s',3,0.9,lambdaS,[3 4]); % figure 4 / 27180
    fftTorques2('u',2,0.9,lambdaS,[1 5]); % figure 5 / 28201
    fftTorques2('s',1,0.9,lambdaS,[3 6]); % figure 6 / 27650
    
    drawnow();
    system(sprintf('scrshot testsP1_tFreq=0.9_lambdaS=%.2f',lambdaS));
%     system(sprintf('scrshot testsP12_tFreq=0.9_lambdaS=%.2f',lambdaS)); % worse... P1 seems better
end
