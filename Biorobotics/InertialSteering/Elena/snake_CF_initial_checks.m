% This are the recommended checks to do before running the snake
% complementary filter in order to achieve best performance in the pose
% estimate

% HERE SET TO ZERO THE TRUSTABILITY OF THE ACCELEROMETERS AND THE GYROS
% WHICH LOOK CRAZY FROM THE CHECKSS
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Snake initalization   %   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Initialization..')

addpath('Elena');

HebiLookup;

g = HebiLookup.newConnectedGroupFromName('*','SA014');


numModules = g.getInfo.numModules;

accTrustability = ones(1,numModules);
accTrustability([4 14 15 16]) = 0;
gyrosTrustability = ones(1,numModules);
gyrosTrustability([8 10 11 12 16]) = 0;


% load('offsets.mat','accelOffsets');
% accelOffsets = zeros(3,numModules);
accelOffsets = retrieveAccelOffsets(g.getInfo().name);
% gyroOffsets = retrieveGyroOffsets(g.getInfo().name);
gyroOffsets = compute_gyro_offsets(g);

accelOffsets = accelOffsets(:,1:numModules);
gyrosTrustability = gyrosTrustability(1:numModules);
accTrustability = accTrustability(1:numModules);

close all;

cmd = CommandStruct;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Initial checks       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(' ')
disp('%%%%%%% START OF THE CHECKS %%%%%%%');

% ENCODERS
% Commanding the snake to be straight
disp('Please check the ENCODER')
cmd.position = zeros(1,numModules);
cmd.torque = zeros(1,numModules);
for i=1:5
    g.set(cmd);
    pause(.25);
end
disp('Is the snake straight?')
disp('Press any key to confirm')
pause();
disp('----');
disp('')

% ACCELEROMETERS
disp('Please check ACCELEROMETERS')
disp('You should look at the snakes in different poses and look at the gravity readings')
disp('(The blue/magenta readings are ignored)')
% Plotting the snake
plt = HebiPlotter('frame','gravity', 'accelOffsets', accelOffsets, ...
     'gyroOffsets', gyroOffsets(:,1:numModules), 'gyrosTrustability', gyrosTrustability, ...
     'accTrustability', accTrustability(1:numModules));
% Commanding the snake to be limp
cmd.position = NaN(1,numModules);
cmd.velocity = NaN(1,numModules);
cmd.torque = zeros(1,numModules);
for i=1:5
    g.set(cmd);
    pause(.25);
end
disp('Are they agreeing with each other?')
disp('Press any key to confirm')
disp('If not you should either ignore the bad ones (change variable accTrustability)');
disp('or recalibrate (slowly roll the modules in the three directions and then change function retrieveAccelOffsets)')
global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;
set(gcf, 'KeyPressFcn', @myKeyPressFcn)
 while(~KEY_IS_PRESSED)
    plt.plot(g.getNextFeedback);
 end
 close all
 disp('----');
 disp('')

 
% GYROS 
disp('Please leave the snake still on the floor, then press any key')
pause()
[mean_variation, deviations] = check_gyro_offsets(g,gyroOffsets, gyrosTrustability);
disp('Please check the GYROS')

if max(max(mean_variation)) > 15
    disp('!!!!!!!!!!! WARNING !!!!!!!!! apparently some gyro offsets have changed significantly');
    disp('You may wanna recalibrate (use fuction compute_gyro_offsets and then change function retrieveGyroOffsets)');
end
if max(max(deviations)) > 0.01
    disp('!!!!!!!!!!! WARNING !!!!!!!!! apparently some gyros reading which you are considering are very oscillating');
    disp('You may wanna ignore these values (change variable gyrosTrustability)');
end
disp('Press any key to confirm')

pause()
disp('----');
disp('')
% close all


disp('%%%%%%% END OF THE CHECKS %%%%%%%');

 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Complementary filter initalization %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% snakeData = setupSnakeData( 'SEA Snake', numModules);
% CF = ComplementaryFilter(snakeData, 'accelOffsets', accelOffsets, 'gyroOffsets', gyroOffsets, 'gyrosTrustability', gyrosTrustability);
% 
% fk_CF = CF.getInGravity ('wholeBody');
% VC_CF = CF.getInGravity ('VC');
% while  isempty(fk_CF)
%     CF.update(g.getNextFeedback());
%     fk_CF = CF.getInGravity ('wholeBody');
%     VC_CF = CF.getInGravity ('VC');
% end 


save('offsets.mat','gyroOffsets','accelOffsets','accTrustability','gyrosTrustability');
