function [newModuleFrames] = transform_snake(moduleFrames, T)
% TRANSFORM_SNAKE
% [new_module_frames] = transform_snake(module_frames, T)
%   
% Given a shape of the snake in the form of a set of homogeneous
% transforms, and a new homogeneous transform, the snake is transformed to
% a new body frame.
%
% For example: if T describes the pose of some module in module_frames,
% calling this function will transform the body frame of the snake to be
% aligned with the frame fixed at that module.
%
% Inputs: 
%   module_frames - a [4 x 4 x number of modules] array of homogeneous
%   transform matrices describing the shape of the the centers of each of
%   the modules in the snake.  The matrices need to be in some global
%   body frame, not relative to each other.
%
%   T - a homogeneous transfrom in the current body frame describing the
%   pose of the new body frame relative to the current one.
%
%
% Outputs:
%   new_module_frames - a [4 x 4 x number of modules] array of homogeneous
%   transform matrices describing the shape of the the centers of each of
%   the modules in the snake.
%
%   ALL UNITS ARE IN RADIANS / INCHES.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check if Mex is enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(getenv('BIOROBOTICS_ENABLE_MEX')))
    
    % call Mex method
    [newModuleFrames] = transform_snake_fast( moduleFrames, T );
    
    % Skip the rest
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Otherwise run MATLAB code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Initialize the output frames
    newModuleFrames = zeros(size(moduleFrames));

    % Step through the snake and transform each module to the new body
    % frame.  It's just that simple!
    for module=1:size(moduleFrames,3)
        newModuleFrames(:,:,module) = T \ moduleFrames(:,:,module);
    end

end
