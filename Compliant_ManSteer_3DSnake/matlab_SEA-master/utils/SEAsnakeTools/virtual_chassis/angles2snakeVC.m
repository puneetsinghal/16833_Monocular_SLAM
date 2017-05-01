function [ kinematicInfo ] = angles2snakeVC( angles, snakeData, miscData )
%angles2snakeVC Takes in a set of joint angles and kinematic data about the
%snake and spits out the snake in the Virtual Chassis.
%
% [ kinematicInfo ] = angles2snakeVC( angles, snakeData, miscData )
%
%   Output:
%       kinematicInfo - a struct with the following fields:
%           .snakeShape - (4x4xnumModules) set of transforms that describe 
%               the pose of the snakes modules in the body frame
%           .T - the transform for the VC, used for VC algorithm
%           .S - magnitudes of the principal components in the VC
%
%   Input:  
%       angles - a struct with fields
%           .x_angle
%           .y_angle
%         NOTE: that these correspond to sc2logs format, so you can just
%         pass in the .feedback or .command struct and things should work
%         just fine.
%
%       snakeData - a struct with the following fields:
%           .x_ang_mask - degrees of freedom of x joints
%           .y_ang_mask - degrees of freedom of y joints
%           .moduleLen - length of a module (inches) 
%           
%       miscData - struct with anything else important:
%           .mexCode - true to use mexCode
%           .T_last - Transform from previous VC calculations


    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Check to run MEX Code %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % If not defined, run w/o MEX Code
    if isfield(miscData,'mexCode') && miscData.mexCode
        mexCode = true;
    else
        mexCode = false;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check for permutation matrix for the VC %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isfield(miscData,'axisPerm')
        axisPerm = eye(3);
    else
        axisPerm = miscData.axisPerm;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate the snake's forward kinematics %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if mexCode
        
        % MEX CODE (faster)%  
        gaitShapes = make_snake_fast( angles.x_angle', angles.y_angle', ...
                                      snakeData.x_ang_mask', snakeData.y_ang_mask', ...
                                      snakeData.moduleLen);
                                  
    else
        
        % MATLAB CODE %
        gaitShapes = make_snake( angles.x_angle, angles.y_angle, ...
                                 snakeData.x_ang_mask', snakeData.y_ang_mask', ...
                                 snakeData.moduleLen);
                             
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the virtual chassis %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if mexCode 
        
        % MEX CODE (faster)%  
        if ~isfield(miscData,'T_last')
            [T, S] = unifiedVC_fast( gaitShapes, axisPerm );
        else
            [T, S] = unifiedVC_fast( gaitShapes, axisPerm, miscData.T_last );
        end
        
    else
        
        % MATLAB CODE %
        if ~isfield(miscData,'T_last')
            [T, S] = unifiedVC( gaitShapes, axisPerm );
        else
            [T, S] = unifiedVC( gaitShapes, axisPerm, miscData.T_last );
        end
        
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Transform the snake to the virtual chassis %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if mexCode
        
        % MEX CODE (faster)%   
        snakeShape = transform_snake_fast( gaitShapes, T );
        
    else
        
        % MATLAB CODE %
        snakeShape = transform_snake( gaitShapes, T ); 
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Assemble into struct for return %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    kinematicInfo.snakeShape = snakeShape;
    kinematicInfo.T = T;
    kinematicInfo.S = S;
end

