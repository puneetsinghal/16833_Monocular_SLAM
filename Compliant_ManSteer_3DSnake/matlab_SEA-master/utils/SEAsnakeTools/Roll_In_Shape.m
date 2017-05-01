clearvars -except SEAsnake
close all

% Re-Import the Java Stuff
% import us.hebi.sdk.matlab.*;
% addpath('/Users/kywoodard/Documents/MATLAB/Biorobotics Lab/Snake/SVD')
% addpath(genpath('/Users/kywoodard/Documents/MATLAB/Biorobotics Lab/Matlab_Code/Matlab Snake Control'))
% addpath(genpath('/Users/kywoodard/Documents/MATLAB/Biorobotics Lab/Snake'))
% addpath('/Users/kywoodard/Documents/MATLAB/Biorobotics Lab/Snake/Pose Estimator')

%%%%%%%%%%%%%%%%%%%%
% Snake Parameters %
%%%%%%%%%%%%%%%%%%%%
command = false;
sim = true;
dummy = true;

% addpath('/Users/kywoodard/Documents/MATLAB/Biorobotics Lab/HEBI API')
% API_Setup_2_0;

if command
    %Setup File
    setupSVD;
    
    % Reget the handle to Matlab group
    SEAsnake = HebiApi.getGroup(1);
    
    %%%%%%%%%%%%%%%%%%%%
    % Snake Parameters %
    %%%%%%%%%%%%%%%%%%%%
    
    % SEA Snake
    snakeType = 'SEA Snake';
    numModules = SEAsnake.getInfo.num_modules;
    
    % Get the Snake Data Struct (info for kinematics, joint angle config, etc.)
    snakeData = setupSEAsnakeData(snakeType, numModules);
    
    %Set Feedback Frequency
    fbkHz = 500;
    SEAsnake.setFeedbackFrequencyHz(fbkHz);
    pause(0.5) %Delay to allow the feedback frequency to be set
    
    cmd = CommandStruct();
    cmd.position = nan*ones(1,numModules);
    cmd.velocity = nan*ones(1,numModules);
    cmd.torque = nan*ones(1,numModules);
end  
if sim    
    %%%%%%%%%%%%%%%%%%%%
    % Snake Parameters %
    %%%%%%%%%%%%%%%%%%%%
    if dummy
        % SEA Snake
        snakeType = 'SEA Snake';
        numModules = 18;
    end
    % Get the Snake Data Struct (info for kinematics, joint angle config, etc.)
    snakeData = setupSEAsnakeData(snakeType, numModules);
    
    cmd = CommandStruct();
    cmd.position = repmat([0,0],[1 numModules/2]);
    cmd.velocity = nan*ones(1,numModules);
    cmd.torque = nan*ones(1,numModules);
    
    if command
            SEAsnake.set(cmd)
            fbk = SEAsnake.getFeedback();
    end

    %Initializing setDummySnake
    flag = 1;
    V = 0;
    V1 = 0;
    animateStruct = struct();
    animateStruct1 = struct();
    [V,animateStruct] = setDummySEASnake(cmd,V,animateStruct,snakeData,flag);
    if command
        hold on
        [~,~,V1,animateStruct1] = SEASnakeVC(animateStruct1,snakeData,fbk,V1);
        hold off
    end
    flag = 0;
end

runtime = 100;

wS_l = 2*pi/(numModules/2);
wS_d = 1;
wT = 1;
A = 2;
Amp = 200;

mu = 0;
sig = 0.5;

s = (1:numModules); %Normalize length/(2*pi)
modules = (1:numModules)/numModules;

alpha = exp(-(s-mu).^2/(2*sig^2));
%gaus_c = Amp*(((s-mu).^2.*alpha)/sig^4-alpha/sig^2)/(sqrt(2*pi)*sig);
%figure(1)
%plot(s,gaus_c)

k_l = A*sin(wS_l*s);
k_d = zeros(1,numModules);

r = 0.5;

tic
tocNow = toc;

x = zeros(1,numModules+1);
y = zeros(1,numModules+1);
z = zeros(1,numModules+1);

while tocNow<runtime
   time=toc;
   
   k_l = A*sin(wS_l*s-time);
   k_d = zeros(1,numModules);
   
   mu = 0;
   sig = 4;

   s = (1:numModules); %Normalize length/(2*pi)
   modules = (1:numModules)/numModules;

   alpha = exp(-(s-mu).^2/(2*sig^2));
   %gaus_c = Amp*(((s-mu).^2.*alpha)/sig^4-alpha/sig^2)/(sqrt(2*pi)*sig);
   %figure(1)
   %plot(s,gaus_c)
   
   t = -pi/2+pi/8*cos(20*tocNow);
   latAngles = zeros(numModules)*cos(t);   %Lateral
   dorAngles = k_l;   %Dorsal
   
    
    for i=2:numModules+1
        if mod(i,2) %Odd Moules (Lateral)
            x(i) = x(i-1)+snakeData.moduleLen*sin(latAngles(i-2));
            z(i) = z(i-1)+snakeData.moduleLen*cos(latAngles(i-2));
            
        else % Even modules (Dorsal)
            y(i) = y(i-1)+snakeData.moduleLen*sin(dorAngles(i-1));
            z(i) = z(i-1)+snakeData.moduleLen*cos(dorAngles(i-1));
        end
        
    end
       
    latAngles_SEA = anglesUtoSEA(snakeData,latAngles);
    dorAngles_SEA = anglesUtoSEA(snakeData,dorAngles);
    
    
    for i=1:2:floor(numModules)
        cmd.position(i) = latAngles_SEA(i);
    end
    for i=2:2:floor(numModules)
        cmd.position(i) = dorAngles_SEA(i);
    end
    if command
        SEAsnake.set(cmd);
        fbk = SEAsnake.getFeedback();
    end
    if sim
                
        [V,animateStruct] = setDummySEASnake(cmd,V,animateStruct,snakeData,flag);
        if command
            hold on
            [~,~,V1,animateStruct1] = SEASnakeVC(animateStruct1,snakeData,fbk,V);
            hold off
        end
        xlim([-0.75,0.75])
        ylim([-0.25,0.25])
        zlim([-0.25,0.25])
        drawnow
        
    end
    
   
    tocNow = tocNow+toc-time;

    
end
