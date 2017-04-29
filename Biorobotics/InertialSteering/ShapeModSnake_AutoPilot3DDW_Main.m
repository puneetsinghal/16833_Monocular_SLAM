close all;

addpath(['functions/']);

plotQ = false;
headingQ = true;
saveQ = true;

%~~~~Initialize all parameters for the SEA SNAKE~~~~%

% Import all packages and files to connect to the snake
% import us.hebi.sdk.matlab.*;
% import org.biorobotics.math.*;
initializeSEASnake();


% Initialize all the gains
gains                           = snake.getGains();
ones_n                          = ones(1,snakeData.num_modules);
gains.controlStrategy           = ones_n*4;
gains.positionKp                = ones_n*4;
gains.positionKi                = ones_n*.01;
gains.positionKd                = ones_n*1;
gains.torqueKp                  = ones_n*1;
gains.torqueKi                  = ones_n*0;
gains.torqueKd                  = ones_n*.1;
gains.torqueMaxOutput           = ones_n*2.25;
gains.torqueMinOutput           = -gains.torqueMaxOutput;
gains.positionIClamp            = ones_n*1;
gains.velocityKp                = ones_n*1;
gains.positionMaxOutput         = ones_n*10;
gains.positionMinOutput         = ones_n*-10;
gains.torqueOutputLowpassGain   = ones_n*.5;
gains.torqueFF                  = ones_n*0.15;

snake.set('gains', gains);
snake.setCommandLifetime(0);

%~~~Initialize the command structure~~~%
cmd = CommandStruct(); 

%~~~Set feedback rate~~~%
fbkHz = 200;
snake.setFeedbackFrequency(fbkHz); 

% Initialize the joystick values here
% The on/off button for this program is button 2 on the controller.
joy                       = vrjoystick(1);  
onButton                  = 0;
%~~~~Initialize all parameters for the virtual SEA SNAKE~~~~%


snakeConst.numModules     = 16;
snakeConst.numWaves       = 1.5;
snakeConst.spFreq         = 2 * pi * snakeConst.numWaves;
snakeConst.tmFreq         = 1.8;
snakeConst.ampEvn         = pi / 4;
snakeConst.ampOdd         = 0;

%~~~~Initialize all parameters for the windows~~~~%

windows.numWindows        = 6;
windows.origin            = 1;                             
windows.steerIndex        = 3;

windows.array             = initialize_Windows(snakeConst, windows);
windows.amp               = initialize_AmpWindows(windows);
windows.spFreq            = initialize_SpFreqWindows(windows);     
windows.offset            = initialize_OffsetWindows(windows);
windows.torsion           = initialize_TorsionWindows(windows);

%~~~~Initialize all parameters for the compliant variables~~~~%

numWindows                = windows.numWindows;
snakeCompl.amp            = snakeConst.ampEvn * ones(1, numWindows); 
snakeCompl.spFreq         = snakeConst.spFreq * ones(1, numWindows);
snakeCompl.torsion        = zeros(1, numWindows);
snakeCompl.tmFreq         = 0;
snakeCompl.slope          = 200;
snakeCompl.phi            = 0;
snakeCompl.tau_D          = [3 * ones(numWindows, 1); 
                             0 * ones(numWindows, 1);
                             0 * ones(numWindows, 1)];

snakeNom.steer            = 0;
snakeNom.sigma_Nom        = [    zeros(numWindows, 1);
                                 snakeCompl.amp';
                                 snakeCompl.spFreq';
                                 snakeCompl.torsion';
                                 snakeCompl.tmFreq'];  

snakeNom.sigma_D          = [    zeros(numWindows, 1);
                             2 * snakeCompl.amp';
                                 snakeCompl.spFreq'
                                 snakeCompl.torsion';
                                 snakeCompl.tmFreq']; 

snakeNom.MdPrime           = diag([1.5 * ones(1, windows.numWindows), ...
                          2 * ones(1, windows.numWindows), ...
                          1.5 * ones(1, windows.numWindows)]);
snakeNom.BdPrime           = diag([3 * ones(1, windows.numWindows), ...
                          1 * ones(1, windows.numWindows), ...
                          3 * ones(1, windows.numWindows)]);
snakeNom.KdPrime           = diag([4 * ones(1, windows.numWindows), ...
                          1 * ones(1, windows.numWindows), ...
                          1.5 * ones(1, windows.numWindows)]);

snakeNom.dsigmaD_dt       = zeros(3 * numWindows, 1);

if plotQ
    initialize_Plotting;
end

t                         = 0;
dt                        = pi / 160;

% Initial Shape of the snake (for use while calibrating the complementary filter)
snakeCompl.offset      = zeros(numWindows, 1);

[commanded_angles]...
                       = get_NewAngles(snakeCompl, snakeConst, windows);
cmd.position           = changeUnifiedToSEA(snakeData,1.7*commanded_angles');
TzOffset = commanded_angles(1) / 2;
snake.set(cmd);

disp('press any key to initialize');
pause
if headingQ
    % CF setup and calibration
    load('offsets.mat');
    CF = ComplementaryFilter(snakeData, 'accelOffsets', accelOffsets(:,1:numModules), 'gyroOffsets', gyroOffsets(:,1:numModules), 'gyrosTrustability', gyrosTrustability(1:numModules), 'accTrustability', accTrustability(1:numModules));
    fbk = snake.getNextFeedback();
    CF.update(fbk);
    pause(dt);
    fbk = snake.getNextFeedback();
    CF.update(fbk);
    pause(2);
    disp('created CF object...');
    nPoses = round(2 / dt);
    pose0 = zeros(4,4);
    for i=1:nPoses
        fbk = snake.getNextFeedback(); 
        CF.update(fbk);
        pose0 = pose0 + CF.getInGravity('head');
        pause(dt);
    end
    pose0 = pose0 / nPoses;
    % nPosesH = 1;
    nPosesH = round(0.2 * 2*pi / (snakeConst.tmFreq * dt));
    CFHposes = zeros(1,nPosesH); Ih = 1;
    disp('Calibrated initial pose...');
    headingOffsets = [pi/2 pi -pi/2 0];
    headingOffset = 0;
    snakeNom.h = 0;
    mainAxis = 0;
    currSerpPos0 = 1.1; % tied to the location at which we start the motion in the period signal fourier8Fit
    currSerpPos = pi/2;
    % Hobo style solution
    if numModules == 16
        load('fourier8Fit.mat','fourier8Fit');
    end
end
mainAxis0 = NaN;

% Storing values
if saveQ
    steeringValues = 0;
    headingValues = 0;
    headingOffsetValues = 0;
    shapeRegularity = 0;
    anglesMatrix = zeros(snakeConst.numModules, 1);
    rotationMatrix = zeros(3, 3);
    accel = zeros(3, 1);
end

if plotQ
    heading_record = 0;
    head_record = 0;
end
while (onButton ~= 1)
    tic();
    
    onButton               = button(joy, 5);
    [axes, buttons, povs]  = read( joy );
    
    snakeCompl.buttonArray = [button(joy, 1), button(joy, 2), button(joy, 3), button(joy, 4)];
    if sum(snakeCompl.buttonArray) == 1
        headingOffset = headingOffsets(snakeCompl.buttonArray);
    end
    
    forward = 1;
    
    index = 1;
    while(windows.offset(index, 2) < 0)
       index = index + 1;
    end
    windows.steerIndex     = index;
    
    fbk = snake.getNextFeedback();
    while isempty(fbk)
        display('No Feedback... :-(');
        fbk = snake.getNextFeedback();
    end
    
    % Guillaume's crap
    if headingQ
        % Update CF
        CF.update(fbk);
        % get Head pose
        pose = CF.getInGravity('head');

        % Get head's heading
        Tz = - decomposeSO3(pose0 \ pose);
%         if numModules == 16
%             CFHposes(Ih) = (Tz-TzOffset) - mainAxis - fourier8Fit(currSerpPos);
%         else
            CFHposes(Ih) = (Tz-TzOffset) - mainAxis;
%         end
        Ih = mod(Ih,nPosesH) + 1;
        Hh = angleMean(CFHposes,snakeNom.h);

        % Update snake's heading
        snakeNom.h = mod( Hh - headingOffset + pi, 2*pi) - pi;
%         display(snakeNom.h);
    else
        snakeNom.h = 0;
    end
    
    %=================================== Beta ===================================
    
    snakeNom.scale         = forward;
    t                      = t + dt;
    
    tau_Ext                = changeSEAtoUnified(snakeData,fbk.torque)'; 
    tau_Applied            = get_AppliedForce(tau_Ext, ...
                                          snakeConst, snakeCompl, windows);
    [snakeCompl, snakeNom] = get_NewNomParam(snakeCompl, snakeNom, ...
                                     snakeConst, windows, tau_Applied, dt);
    windows                = update_Windows(snakeCompl, windows);
    [snakeCompl, snakeNom, windows]...
                           = update_Structures(snakeCompl, snakeConst, snakeNom, windows);
    if isnan(mainAxis0)
        [~,mainAxis0]      = get_NewAngles(snakeCompl, snakeConst, windows);
    end
    [commanded_angles,mainAxis,currSerpPos,shapeReg]...
                           = get_NewAnglesDW(snakeCompl, snakeConst, windows, t);

    cmd.position           = changeUnifiedToSEA(snakeData,commanded_angles');
    snake.set(cmd);
    
    if headingQ
        mainAxis = mainAxis - mainAxis0;
        currSerpPos = currSerpPos - currSerpPos0;
    end

    if plotQ
        update_Plotting;
    end
    
    current_time = toc();
    pause(max(0,dt-current_time));
    
    % Storing things
    if saveQ
        steeringValues = [steeringValues; snakeNom.sigma_D(windows.steerIndex)];
        headingValues = [headingValues; snakeNom.h];
        headingOffsetValues = [headingOffsetValues; headingOffset];
        shapeRegularity = [shapeRegularity; shapeReg];
        anglesMatrix = cat(2, anglesMatrix, commanded_angles);
        rotationMatrix = cat(3, rotationMatrix, pose(1:3, 1:3));
        accel = cat(2, accel, CF.accelerationAvg);
    end
end

cmd.position = nan(1,numModules);
cmd.velocity = nan(1,numModules); 
cmd.torque = zeros(1,numModules);
snake.set(cmd);

if saveQ
	runNb = 1;
	FileName = sprintf('Experiments/PaperExperiments/experiment%d.mat', runNb);
	while exist(FileName,'file') == 2   % if the chosen name is taken, add a number to the end
	    runNb = runNb + 1;              % increase the number until it is no longer taken
	    FileName = sprintf('Experiments/PaperExperiments/experiment%d.mat', runNb);
	end
	save(FileName, 'steeringValues', 'headingValues', 'headingOffsetValues', 'shapeRegularity', ...
        'currSerpPos0', 'mainAxis0', 'headingOffsets', 'snakeConst', 'snakeCompl', 'snakeNom', ...
        'windows', 't', 'dt', 'anglesMatrix', 'rotationMatrix', 'accel');
end
