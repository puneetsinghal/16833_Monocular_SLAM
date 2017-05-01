% Helper function to initialize the snake robot.  This should be the first
% thing called in most online scipts.
%
% This script was formed because all the code in the first 100 lines of all
% the various other scripts in matlabSnakeControl were basically the same.
%
% Dave Rollinson
% Oct 2013



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nuke the Matlab Workspace %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear *;
% clc;
% close all;
% Java stuff for talking to the snake
import org.biorobotics.matlab.*;

%%
%%%%%%%%%%%%%%%%%%%%%%%%
% Connect to SEA snake %
%%%%%%%%%%%%%%%%%%%%%%%%



fprintf(['Initializing SEA Snake\n']);

% currentFolder = pwd;
% cd('C:\Users\franc_fm0qowp\OneDrive\Documents\MATLAB\fruscell\Compliant_SEASnake\hebi');
     
     



if ~exist('snake', 'var')
    fprintf(['Creating new group\n']);
    snake = HebiLookup.newConnectedGroupFromName('*', 'SA072')
end
fprintf('Success!\n\n');
% Request feedback at 50 hz
snake.setFeedbackFrequency(50);

%%
%%%%%%%%%%%%%%%%%%%%
% Snake Parameters %
%%%%%%%%%%%%%%%%%%%%

% SEA Snake
snakeType = 'SEA Snake';
numModules = snake.getInfo.numModules;

% Get the Snake Data Struct
% (info for kinematics, joint angle config, etc.)
snakeData = setupSEAsnakeData( snakeType, numModules);

% cd(oldFolder);