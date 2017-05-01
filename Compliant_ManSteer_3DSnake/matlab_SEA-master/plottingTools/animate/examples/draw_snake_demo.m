%%%%%%%%%%%%%%%%%%%%%
% draw_snake_demo.m %
%%%%%%%%%%%%%%%%%%%%%
%
% NOTE:
% This script assumes that you've either added everything in the
% common/matlab folder to your path, or you've run the SETUP_SCRIPT for a
% project folder, like matlabSnakeControl.
%
% SUMMARY:
% Basically, use some gait parameters to draw the snake in 3D.  This script
% initializes a snake info struct, initializes a gait info struct, and
% then calls the gait and animates the snake robot's shape based on the
% joint angles.
%
% This is a good starting point for familiarizing yourself with the
% Matlab snake and gait code.  Right click any function and open it, or
% type help [some_function] to get more info.
%
%
% Dave Rollinson
% Dec 2012

%%%%%%%%%%%%%%%%%%%%%%
% NUKE THE WORKSPACE %
%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;

% Make a structure with all the information for doing stuff with a Unified
% Snake robot.
snakeInfo = setupUSnake( 16 );

% Logical masks for the degrees-of-freedom (DOFs) in the snake robot.
xDOFs = snakeInfo.x_ang_mask;
yDOFs = snakeInfo.y_ang_mask;

moduleLen = snakeInfo.moduleLen;
moduleDia = snakeInfo.moduleDia;


%%
%%%%%%%%%%%%%%%%
% PICK A GAIT  %
%%%%%%%%%%%%%%%%

% Uncomment one of the functions below to use it as the commanded gait.

% % Helix
% gaitInfo = gaitHelix();

% % Rolling
% gaitInfo = gaitRolling();

% Sidewind
gaitInfo = gaitSidewind();

% % Slither 
% gaitInfo = gaitSlither();

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET JOINT ANGLES FROM THE GAIT FUNCTION %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the default parameters for the gait.
gaitParams = gaitInfo.defaultParams;

% Get the actual gait function from the info struct.  This is the function
% that will actually generate joint angles, given some set of gait
% parameters.
gaitFunc = gaitInfo.gaitFunction;

[x_angles, y_angles] = gaitFunc(gaitParams, snakeInfo);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO THE FORWARD KINEMATICS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function takes in joint angles, and returns a bunch of 4x4
% homogeneous transforms that describe the pose of each module.
[moduleFrames] = make_snake( x_angles, y_angles, ...
                              xDOFs, yDOFs, moduleLen );


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DRAW THE 3D SHAPE OF THE SNAKE IN A FIXED FRAME  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make an "animate struct" that tracks info about the plots.  The
% draw_snake function will use this to update things more quickly, and has
% handy helper variables for saving things to file, printing images at
% different resolutions, etc.
animStructFixed.fig = figure(101);

% Draw the snake
animStructFixed = draw_snake( animStructFixed, moduleFrames, ...
                                moduleLen, moduleDia);

% Label the axes!
title(['Snake Fixed-Frame Visualization: ', gaitInfo.gaitName]);
xlabel('x (inches)');
ylabel('y (inches)');
zlabel('z (inches)');


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DRAW THE 3D SHAPE OF THE SNAKE IN THE VIRTUAL CHASSIS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make an "animate struct" that tracks info about this new plot. 
animStructVC.fig = figure(102);

% Get the virtual chassis body frame for this shape.  Basically this is
% just a more intuitive 'averaged' frame in which to view the robot.
frameVC = unifiedVC( moduleFrames, eye(3) );

% Transform the robot from the fixed frame to the virtual chassis frame.
moduleFramesVC = transform_snake( moduleFrames, frameVC );

% Draw the snake again
animStructVC = draw_snake( animStructVC, moduleFramesVC, ...
                            moduleLen, moduleDia);

% Label the axes!
title(['Snake Virtual Chassis Visualization: ', gaitInfo.gaitName]);
xlabel('x (inches)');
ylabel('y (inches)');
zlabel('z (inches)');



