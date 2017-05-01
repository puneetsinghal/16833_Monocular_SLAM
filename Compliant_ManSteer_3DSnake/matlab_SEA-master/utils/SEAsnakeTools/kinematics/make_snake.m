function [module_frame] = make_snake( x_angles, y_angles, ...
                                      x_dofs, y_dofs, module_len )
% MAKE_SNAKE
% [module_frames] = make_snake( x_angles, y_angles, 
%                              x_dofs, y_dofs, module_len)
%   
% Given vectors of angles (module angles), this function returns 
% a set of 4x4 transformations to move points from the frame of the first 
% module to the rest (all the modules are in a single frame from module 1).
%
% Modules are chained in the -z direction, like on the real snake (i.e.
% module 1 is the head, and if the snake were straight, module 2 would be
% behind it along the z-axis.
%
% Inputs: 
%   x_angles / y_angles - Angles (in radians) between each module around
%   the x- and y-axes of the snake as defined by the torsion-free frame
%   convention.  This is usually a full set of angles returned by a
%   gait equations.
%
%   x_dof / y_dofs - Logical masks to elimate degrees of freedom so
%   that the kinematics reflect the configuration of a Unified Snake.  You
%   can get these by calling the setupUSnake() function.
%
%   module_len - The distance between modules joints.  For the unified
%   snake this number is 2.01 inches.  This value is also returned in the
%   struct from the setupUSnake() function.
%
% Outputs:
%   module_frame - a [4 x 4 x number of modules] array of homogeneous
%   transform matrices describing the shape of the the centers of each of
%   the modules in the snake.  There will be 1 more module than angles,
%   since the angles represent joints between modules.
%
%   The shape will returned in a coordinate frame aligned with the position
%   and orientation of the head module.
%
%   ALL UNITS ARE IN RADIANS / INCHES.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check if Mex is enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(getenv('BIOROBOTICS_ENABLE_MEX')))
    
    % call Mex method
    [module_frame] = make_snake_fast( x_angles', y_angles, ...
                                      x_dofs, y_dofs, module_len );
    
    % Skip the rest
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check if Java is enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(getenv('BIOROBOTICS_ENABLE_JAVA')))
    
    % call java method
    import biorobotics.Kinematics;
    [module_frame] = Kinematics.makeSnake( ...
        x_angles, y_angles, x_dofs, y_dofs, module_len );
    
    % Skip the Matlab part
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Otherwise run MATLAB code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % For reference:
    
    % Rx         Ry         Rz
    % 1  0  0    c  0  s    c -s  0
    % 0  c -s    0  1  0    s  c  0
    % 0  s  c   -s  0  c    0  0  1

    % ensure angles are given as row vectors
    if size(x_angles,1) > 1
        x_angles = x_angles';
    end

    if size(y_angles,1) > 1
        y_angles = y_angles';
    end

    % Form the overall angle transformations based on module_dofs
    x_angles(~x_dofs) = 0;
    y_angles(~y_dofs) = 0;
    
    num_joints = size(x_angles,2);
    
    T_1 = zeros(4,4,num_joints);
    T_2 = zeros(4,4,num_joints);
    T = zeros(4,4,num_joints);

    % For each module in the snake, these are the transformations to the
    % next module
    for i = 1:num_joints
        % Shift the module in the -z-direction of the current frame
        T_1(:,:,i) = eye(4);
        T_2(:,:,i) = eye(4);
        
        T_1(1:3,4,i) = [0; 0; -module_len/2];
        
        % Rotate around the x- and y-axes of the current frame
        R_x = [ 1        0                   0;
                0  cos(x_angles(i))  -sin(x_angles(i)); 
                0  sin(x_angles(i))   cos(x_angles(i)) ];

        R_y = [ cos(y_angles(i))  0  sin(y_angles(i));
                        0         1         0;
               -sin(y_angles(i))  0  cos(y_angles(i)) ];

        T_2(1:3,1:3,i) = R_y' * R_x';   

        % Shift the module in the -z-direction of the current frame
        T_2(1:3,4,i) = [0; 0; -module_len/2];
        
        T(:,:,i) = T_2(:,:,i) * T_1(:,:,i);
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % We have now built all of our transformations.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Make the first module located at [0 0 0] pointed up (+ Z axis).  
    % This is the head module.
    module_frame = zeros(4,4,num_joints+1);
    module_frame(:,:,1) = eye(4);

    for i = 1:num_joints

        % Rotate move the module to the next location based on the
        % relative transformations from above.  Each local transformation 
        % gets chained resulting in a world frame from head to tail.
        module_frame(:,:,i+1) = module_frame(:,:,i) * T(:,:,i);

    end

end
