lambdaS = 0.1;
medFilterWL = 400; % length of the maj/med filters' windows (400 = 2s)
nPeriods = 2; % experimentally determined

temporalFreq = 0.9;
windowlen = round(nPeriods * 200 * 2 * pi / (100 * temporalFreq)) * 100;

fftTorques3('u',4,0.9,lambdaS,4,windowlen); % figure 4 / 7965
fftTorques3('s',1,0.9,lambdaS,1,windowlen); % figure 1 / 27650
fftTorques3('u',2,0.9,lambdaS,2,windowlen); % figure 2 / 28201
fftTorques3('s',3,0.9,lambdaS,3,windowlen); % figure 3 / 27180
drawnow();
system(sprintf('scrshot testsP1_tFreq=0.9_lambdaS=%.2f_medFilterWL=%d_windowlen=%d',lambdaS, medFilterWL, windowlen));

temporalFreq = 0.5;
windowlen = round(nPeriods * 200 * 2 * pi / (100 * temporalFreq)) * 100;

fftTorques3('s',1,0.5,lambdaS,1,windowlen); % figure 1 / 27440
fftTorques3('u',2,0.5,lambdaS,2,windowlen); % figure 2 / 40926
fftTorques3('u',3,0.5,lambdaS,3,windowlen); % figure 3 / 39036
fftTorques3('u',4,0.5,lambdaS,4,windowlen); % figure 4 / 35367
drawnow();
system(sprintf('scrshot testsP1_tFreq=0.5_lambdaS=%.2f_medFilterWL=%d_windowlen=%d',lambdaS, medFilterWL, windowlen));

temporalFreq = 1.8;
windowlen = round(nPeriods * 200 * 2 * pi / (100 * temporalFreq)) * 100;

fftTorques3('s',1,1.8,lambdaS,1,windowlen); % figure 1 / 45651
fftTorques3('s',2,1.8,lambdaS,2,windowlen); % figure 2 / 38839
fftTorques3('s',3,1.8,lambdaS,3,windowlen); % figure 3 / 28467
figure(4); clf
drawnow();
system(sprintf('scrshot testsP1_tFreq=1.8_lambdaS=%.2f_medFilterWL=%d_windowlen=%d',lambdaS, medFilterWL, windowlen));

system('ls testsP* | while read line; do convert "$line" -crop 1920x1080+0+0 "CROP_$line"; done; rm testsP* -f');
% system('ls testsP* | while read line; do convert "$line" -crop 1080x1920+3840+0 "CROP_$line"; done',windowlen); % 3 screens home setup
