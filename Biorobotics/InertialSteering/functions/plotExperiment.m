function plotExperiment(nExp,videoQ)

if nargin < 1
    nExp = 1;
end
if nargin < 2
    videoQ = false;
end

if exist(sprintf('experiment%d.mat',nExp),'file') == 2
    load(sprintf('experiment%d.mat',nExp));
else
    load(sprintf('ExperimentsMat/experiment%d.mat',nExp));
end

nIter = length(headings);
X = -pi:0.1:pi;
qsr_beta1 = -pi/2; qsr_beta2 = 0; qsr_beta3 = pi/2;
landscape = @(X) 1/12.*X.*(-12.*qsr_beta1.*qsr_beta2.*qsr_beta3 + 6.*(qsr_beta2.*qsr_beta3 + qsr_beta1.*(qsr_beta2 + qsr_beta3)).*X - 4.*(qsr_beta1 + qsr_beta2 + qsr_beta3).*X.^2 + 3.*X.^3);
LX = landscape(X);

if videoQ
% 	v = VideoWriter(sprintf('Videos/Data%d.mp4',nExp),'MPEG-4');
	v = VideoWriter(sprintf('Videos/Data%d.avi',nExp),'Uncompressed AVI');
    v.FrameRate = 50;
	open(v);
    wb = waitbar(0, 'Video Creation...');
else
    figure(1)
    hold on
    plot(0:dt:dt*nIter, [0 qs_betas], 'red');
    plot(0:dt:dt*nIter, [0 headings], 'blue');
    hold off
end

% steering = 0;
% alphaC = 1.; Kh = 3.; 

figure(2)
pause
for i=1:nIter
    clf
    hold on
    axis([-0.7*pi 0.7*pi -2 2]);
    title('Heading/Steering Offset in the Potential Field');
    xlabel('Phase/Steering Offset [rad]');
    ylabel('Potential Field [rad^2]');
    plot(X,LX, 'black', 'LineWidth', 2);
    plot(headings(i), landscape(headings(i)), '.k', 'color', 'blue', 'MarkerSize', 30);
    plot(steerings(i), landscape(steerings(i)), '.k', 'color', 'red', 'MarkerSize', 30);
%     plot(steering, landscape(steering), '.k', 'color', 'red', 'MarkerSize', 30);
    legend('Potential Field', 'Heading', 'Steering Offset');
    set(gca, 'FontSize', 20);
    hold off
    if videoQ
        frame = getframe(gcf);
        writeVideo(v,frame);
%         saveas(gca, sprintf('frames%d/frame%03d.png', nExp, i));
%         display(sprintf('%d/%d', i, nIter));
        waitbar(i/nIter);
    else
        drawnow();
        pause(dt);
    end
    
%     steering = steering + dt * (- alphaC * (steering - qsr_beta1).*(steering - qsr_beta2).*(steering - qsr_beta3) + Kh * (-headings(i)/2 - steering));
end

if videoQ
	close(v);
    close(wb);
end

