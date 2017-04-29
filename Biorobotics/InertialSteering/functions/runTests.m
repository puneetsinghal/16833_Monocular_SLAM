lambdaS = 0.1;
medFilterWL = 400; % length of the maj/med filters' windows (400 = 2s)
majFilterWL = 2000; % don't forget to change this in the code...
threshold   = 6/nModules * majFilterWL; % empirically determined

tic;

fftTorques2('s',1,0.9,lambdaS,[1 2]); % figure 2 / 27650
fftTorques2('u',2,0.9,lambdaS,[3 4]); % figure 4 / 28201
fftTorques2('s',3,0.9,lambdaS,[1 5]); % figure 5 / 27180
fftTorques2('u',4,0.9,lambdaS,[3 6]); % figure 6 / 7965
drawnow();
system(sprintf('scrshot testsP1_tFreq=0.9_lambdaS=%.2f_medFilterWL=%d_majFilterWL=%d_threshold=%.2f',lambdaS, medFilterWL, majFilterWL, threshold/majFilterWL));

threshold   = 6/nModules * majFilterWL; % empirically determined

fftTorques2('s',1,0.5,lambdaS,[1 2]); % figure 2 / 27440
fftTorques2('u',2,0.5,lambdaS,[3 4]); % figure 4 / 40926
fftTorques2('u',3,0.5,lambdaS,[1 5]); % figure 5 / 39036
fftTorques2('u',4,0.5,lambdaS,[3 6]); % figure 6 / 35367
drawnow();
system(sprintf('scrshot testsP1_tFreq=0.5_lambdaS=%.2f_medFilterWL=%d_majFilterWL=%d_threshold=%.2f',lambdaS, medFilterWL, majFilterWL, threshold/majFilterWL));

fftTorques2('s',1,1.8,lambdaS,[1 2]); % figure 2 / 45651
fftTorques2('s',2,1.8,lambdaS,[3 4]); % figure 4 / 
fftTorques2('s',3,1.8,lambdaS,[1 5]); % figure 5 / 
drawnow();
system(sprintf('scrshot testsP1_tFreq=1.8_lambdaS=%.2f_medFilterWL=%d_majFilterWL=%d_threshold=%.2f',lambdaS, medFilterWL, majFilterWL, threshold/majFilterWL));
toc

system('ls testsP* | while read line; do convert "$line" -crop 1080x1920+3840+0 "CROP_$line"; done');
