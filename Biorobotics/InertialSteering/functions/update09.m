freqMax = sum( frequencies <= lambdaFreq * peakFreq );

% Plot 1
std1 = std(FFTmatrix1(1:freqMax,:));
% std1 = mean(FFTmatrix1(1:freqMax,:));
set(h1, 'YData', std1);

% Plot 2
std2 = std(FFTmatrix2(1:freqMax,:));
% std2 = mean(FFTmatrix2(1:freqMax,:));
set(h2, 'YData', std2);

% Plot 3
std3 = std(FFTmatrix3(1:freqMax,:));
% std3 = mean(FFTmatrix3(1:freqMax,:));
set(h3, 'YData', std3);

% Plot 4
std4 = std(FFTmatrix4(1:freqMax,:));
% std4 = mean(FFTmatrix4(1:freqMax,:));
set(h4, 'YData', std4);

% system(sprintf('scrshot testsP1_tFreq=0.9_lambdaS=%.2f_medFilterWL=400_majFilterWL=%d_threshold=%.2f',lambdaS, majFilterWL, threshold/majFilterWL));
% system('ls testsP* | while read line; do convert "$line" -crop 1080x1920+3840+0 "CROP_$line"; done');
