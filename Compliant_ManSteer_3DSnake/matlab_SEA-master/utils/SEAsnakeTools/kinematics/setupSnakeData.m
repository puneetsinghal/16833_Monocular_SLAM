  function [ snakeData ] = setupSnakeData( snakeType, numModules )
%SETUPSNAKEDATA Initializes the data needed to run the matlab control code
%on one of our snakes.
%
%   The hope is that using this function will allow us to design code that
%   can be used on future snakes with different configurations, with a
%   minimal amount of re-work.
%
%   [snakeData] = setupSnakeData( snakeType, numModules )
%       Returns a struct based on the type of snake and the number of 
%       modules specified.  The snake data strcut contains:
%           .snakeType
%
%           .modules
%           .numModules
%
%           .moduleLen
%           .moduleDia
%
%           .x_ang_mask
%           .y_ang_mask
%
%           .axisPerm
%
% Dave Rollinson
% Oct 2013

    % String Describing Snake Type
    snakeData.snakeType = snakeType;

    % Number of modules
    snakeData.modules = 1:numModules;
    snakeData.num_modules = numModules;

    %%%%%%%%%%%%%%%%%%
    % KINEMATIC INFO %
    %%%%%%%%%%%%%%%%%%
    if strcmp(snakeType,'Unified Snake')
        
        % Length of modules
        snakeData.moduleLen = .0511;    % meters

        % Diameter of modules 
        % (for animation only, does not effect kinematics)
        % (may come into play for motion models)
        snakeData.moduleDia = .0540;    % meters (w/ silicone skins)
        
    elseif strcmp(snakeType,'SEA Snake')
        
        % Length of modules
        snakeData.moduleLen = .0639;    % meters
        % Diameter of modules 
        % (for animation only, does not effect kinematics)
        % (may come into play for motion models)
        snakeData.moduleDia = .0508;    % meters (no skin)
        
    elseif strcmp(snakeType, 'Sim Snake')
        
        % Length of modules
        snakeData.moduleLen = .026*2+0.003;    % meters
        % Diameter of modules 
        % (for animation only, does not effect kinematics)
        % (may come into play for motion models)
        snakeData.moduleDia = .026*2;    % meters
        
    else
        error('Not a recognized snake type.');
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % USnake module degrees of freedom %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (alternating on x and y axes)
    % MODULE 1 MOVES ON THE X-AXIS...
    snakeData.x_ang_mask = mod(1:numModules,2)==1;
    snakeData.y_ang_mask = ~snakeData.x_ang_mask;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Permutation Axis for Virtual Chassis %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Defaults to X-Y-Z being 1st-2nd-3rd Principal Moments
    snakeData.axisPerm = [ 1  0  0
                           0  1  0
                           0  0  1 ];

end

