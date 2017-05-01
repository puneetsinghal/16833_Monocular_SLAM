close all;

%~~~~Initialize all parameters for the SEA SNAKE~~~~%

% Import all packages and files to connect to the snake
import us.hebi.sdk.matlab.*;

import org.biorobotics.math.*;
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
joy           = vrjoystick(1);  
joyError      = 0.05;           
onButton                  = 0;
steer = 0;
slowFactor = 3;
%~~~~Initialize all parameters for the virtual SEA SNAKE~~~~%

snakeConst.numModules     = 9;
snakeConst.numWaves       = 1.5;
snakeConst.spFreq         = 2 * pi * snakeConst.numWaves;
snakeConst.tmFreq         = 1.8;
snakeConst.ampEvn         = pi / 6;
snakeConst.ampOdd         = 0;

%~~~~Initialize all parameters for the windows~~~~%

windows.numWindows        = 6;
windows.origin            = 1;                             
windows.steerIndex        = 3;

windows.array             = initialize_Windows(snakeConst, windows);
windows.amp               = initialize_AmpWindows(windows);
windows.spFreq            = initialize_SpFreqWindows(windows);     
windows.offset            = initialize_OffsetWindows(windows);
%~~~~Initialize all parameters for the compliant variables~~~~%

numWindows                = windows.numWindows;
snakeCompl.amp            = snakeConst.ampEvn * ones(1, numWindows); 
snakeCompl.spFreq         = snakeConst.spFreq * ones(1, numWindows);
snakeCompl.tmFreq         = 0;
snakeCompl.slope          = 200;
snakeCompl.phi            = 0;
snakeCompl.tau_D          = [1 * ones(numWindows, 1); 
                             0 * ones(numWindows, 1)];

snakeNom.sigma_Nom        = [    zeros(numWindows, 1);
                                 snakeCompl.amp';
                                 snakeCompl.spFreq';
                                 snakeCompl.tmFreq'];  
                             
snakeNom.sigma_D          = [    zeros(numWindows, 1);
                             2 * snakeCompl.amp';
                                 snakeCompl.spFreq';
                                 snakeCompl.tmFreq']; 

snakeNom.dsigmaD_dt       = zeros(2 * numWindows, 1);
snakeNom.direction        = 0;

initialize_Plotting;

t                         = 0;
dt                        = pi / 80;
tic;

while (onButton ~= 1)
    
    onButton               = button(joy, 2);
    [axes, buttons, povs]  = read( joy );

    xCoor = axes(3);
    yCoor = axes(2);

    forward = -yCoor;
    steer   = -xCoor * pi / 2 * dt * slowFactor;

    if (abs(forward) < joyError)
        forward = 0;
    end
    
    if (abs(xCoor) < joyError)
        steer = 0;
    else
        index = 2; % Hard-coded because I know it's always the 3rd window
        windows.steerIndex     = index;
    end
    
    phase                  = snakeCompl.tmFreq;
    snakeNom.direction     = mod(phase, pi) - pi/2;

    snakeNom.scale         = forward;
    snakeNom.steer         = steer;
    
    t                      = t + dt;
    
    fbk                    = snake.getNextFeedback(); 
    if (isempty(fbk))
        disp('Feedback Empty');
        fbk                = snake.getNextFeedback(); 

    end

    tau_Ext                = changeSEAtoUnified(snakeData,fbk.torque)'; 
    tau_Applied            = get_AppliedForce(tau_Ext, ...
                                          snakeConst, snakeCompl, windows);
   [snakeCompl, snakeNom]  = get_NewNomParam(snakeCompl, snakeNom, ...
                                     snakeConst, windows, tau_Applied, dt);
        
    windows                = update_Windows(snakeCompl, windows);
    [snakeCompl, snakeNom, windows]...
                           = update_Structures(snakeCompl, snakeConst, snakeNom, windows);
   
    commanded_angles       = get_NewAngles(snakeCompl, snakeConst, snakeNom, windows);

    cmd.position           = changeUnifiedToSEA(snakeData,commanded_angles');
    snake.set(cmd);
    
    update_Plotting;
    pause(.05);

end

cmd.position = nan(1,numModules);
cmd.velocity = nan(1,numModules); 
cmd.torque = nan(1,numModules);
snake.set(cmd);



