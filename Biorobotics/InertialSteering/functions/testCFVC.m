function testCFVC(calibrQ)

if nargin < 1
    calibrQ = true;
end

initializeSEASnake();
cmd = CommandStruct();
cmd.position = zeros(1,snakeData.num_modules);
cmd.torque = nan(1,snakeData.num_modules);
snake.set(cmd);
pause;

plt = HebiPlotter('frame', 'VC');

dt = pi/160;
% CF setup and calibration
load('offsets.mat');
CF = ComplementaryFilter(snakeData, 'accelOffsets', accelOffsets(:,1:numModules), 'gyroOffsets', gyroOffsets(:,1:numModules), 'gyrosTrustability', gyrosTrustability(1:numModules), 'accTrustability', accTrustability(1:numModules));
CF.update(snake.getNextFeedback());
pause(dt);
CF.update(snake.getNextFeedback());
pause(2);
disp('created CF object...');

if calibrQ
    nPoses = round(2 / dt);
    Zposes = zeros(1,nPoses);
    % TZs = zeros(1,numModules-1);
    for i=1:nPoses
        CF.update(snake.getNextFeedback());
        pose = CF.getInGravity('VC');
        [~,~,Zposes(i)] = decomposeSO3(pose(1:3,1:3));
        pause(dt);
    end
    TzOffset = mean(Zposes);
    disp('Calibrated initial pose...');
end

% Make it NUMB
cmd.position = nan(1,snakeData.num_modules);
cmd.torque = zeros(1,snakeData.num_modules);
snake.set(cmd);
pause(1);

% main code
figure(42)
clf
h = drawframe(pose);
display('Main Loop Running...');

while true
    tic;
    fbk = snake.getNextFeedback();
    while isempty(fbk)
        fbk = snake.getNextFeedback();
    end
    CF.update(fbk);
    
%     pose = rotz(TzOffset) * CF.getInGravity('VC');
    pose = CF.getInGravity('VC');
    
    hold on
    delete(h(1));
    delete(h(2));
    delete(h(3));
    delete(h(4));
    delete(h(5));
    delete(h(6));
    delete(h(7));
    h = drawframe(pose);
    plt.plot(fbk);
    hold off
    drawnow();
    
    currentTime = toc();
    pause(min(0,dt-currentTime));
end

