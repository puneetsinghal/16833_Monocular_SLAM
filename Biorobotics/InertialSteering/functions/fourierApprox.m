function fourierFit = fourierApprox(values)

dt = pi / 160;
t = 0:dt:(length(values)-1)*dt;

fourierFit = fit(t',values','fourier8');

plot(fourierFit,t,values)

% figure
% subplot(2,1,1)
% plot(t,values)
% legend('Original',...
%        'Location','SouthEast')
% subplot(2,1,2)
% plot(fourierFit)
% legend('Reconstructed', ...
%        'Location','SouthEast')
