function [ snake ] = getSnakeGeometry(version)
%GET_SNAKE_GEOMETRY Summary of this function goes here
%   Detailed explanation goes here


if nargin < 1
   version = 'USnake'; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% Snake Geometry        %
%%%%%%%%%%%%%%%%%%%%%%%%%

switch version
    case 'USnake'
        % unit multiplier
        snake.multiplier = 2.54; % cm
        
        % dimensions
        snake.module_len = 2.01*snake.multiplier;  % inches
        snake.module_dia = 2.1275*snake.multiplier;  % inches

        % standard values for threshold and curvature
        snake.threshold = (1/2.54) * snake.multiplier; % was done in cm
        snake.curvature = 3;
        
        % number of actuated modules
        snake.num_modules = 16; 
        % (snake will be num_modules + 1 long including head)
        
        % X-axis aligned shape
        snake.axisPerm = [...
            1  0  0
            0  1  0
            0  0  1 ];
        
        % USnake module degrees of freedom (alternating on x and y axes)
        % MODULE 1 MOVES ON THE X-AXIS...
        for i=1:snake.num_modules
            snake.x_dofs(i) = mod(i,2)==1;
            snake.y_dofs(i) = mod(i+1,2)==1;
        end
        
    otherwise
        error(['No version called "' version '" was found.'], ...
        'ParameterCheck:unsupportedParameter');
end

end

