function [ virtualChassis, chassisMags ] = ...
                            unifiedVC( robotFrames, axisPerm, lastVC )
%UNIFIEDVC 
%   [ virtualChassis, chassisMags ] = 
%            unifiedVC( robotFrames, axisPerm, lastVC )
%
%   Uses SVD to find the virtual chassis of the snake for any gait.  
%   The function finds the principal moments of inertia of the robot's 
%   shape and uses them to define the axes of the virtual chassis, with the
%   origin at the center of mass (each transform is treated as a point mass
%   of equal weight).
%
%   This code is intended for use with the Modsnake robots, but it should
%   theoretically be general enough to work on any system with a bunch of
%   points described by transformation matrices in a common frame.
%
%   Inputs:
%       robotFrames - a [4 x 4 x number of modules] array of homogeneous
%       transform matrices describing the poses of the the centers of 
%       the modules in the robot.  The matrices need to be in some common
%       body frame, not relative to each other.
%
%       axisPerm - a [3 x 3] permutation matrix that allows the user to
%       re-align the virtual chassis however they want.  By default the 
%   	1st, 2nd, and 3rd principal moments of inertia are aligned
%       respectively with the Z, Y, and X axes of the virtual chassis.
%
%       lastVC - this is optional and is used to correct for sign flipping
%       that can occur due to the SVD algorithm.  If lastVC is passed in,
%       then the virtual chassis will not flip signs with respect to this
%       frame.  We assume that a similar initial frame was used to generate
%       the virtual chassis at both this configuration and lastVC.  By 
%       default the principal axis of the virtual chassis will point toward
%       the module specified by the first transform in robotFrames.  
%
%   Outputs:
%       virtualChassis - [4 x 4] transformation matrix that describes the
%       pose of the virtual chassis body frame, described in the frame of
%       the input transformation matrices.
%
%       chassisMags - [3 x 1] vector, diag(S) from SVD, for reporting
%       the magnitudes of the principle components of the robot's shape.
%
%   July 2011

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check if Mex is enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(getenv('BIOROBOTICS_ENABLE_MEX')))
    
    if (nargin < 3) || (isempty(lastVC))
        [ virtualChassis, chassisMags ] = ...
            unifiedVC_fast( robotFrames, axisPerm );
    else
        
        % call Mex method
        [ virtualChassis, chassisMags ] = ...
            unifiedVC_fast( robotFrames, axisPerm, lastVC );
    end
    
    % Skip the rest
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check if Java is enabled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(getenv('BIOROBOTICS_ENABLE_JAVA')))
%     import biorobotics.VirtualChassis;
    
    % If no lastVC has been passed in
    if (nargin < 3) || (isempty(lastVC))
        
        % call java method
        obj = struct(VirtualChassis.unifiedVC(...
            robotFrames, axisPerm ));
        
        % extract return values
        virtualChassis = obj.virtualChassis; % extract 4x4
        chassisMags = obj.chassisMags; % extract 1x3
        
    
    else % If lastVC exists   
         
        % call java method
        obj = struct(VirtualChassis.unifiedVC(...
            robotFrames, axisPerm, lastVC ));
        
        % extract return values
        virtualChassis = obj.virtualChassis; % extract 4x4
        chassisMags = obj.chassisMags; % extract 1x3
        
    end
    
    % Skip the Matlab part
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Otherwise run MATLAB code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Get the XYZ points from the input frames
    xyz_pts = squeeze( robotFrames(1:3,4,:) )';
    
    % Find and shift to the center of mass.
    CoM = mean(xyz_pts);
    xyz_pts = xyz_pts - repmat(CoM,size(xyz_pts,1),1);
    
    % Take the SVD of the zero-meaned positions
    [U S V] = svd( xyz_pts );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % If there's no previous frame %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (nargin < 3) || (isempty(lastVC))
    
        % Account for possible sign flips in SVD.
        % Point the 1st principal moment toward the head module
        if dot( V(:,1), xyz_pts(1,:) ) < 0
            V(:,1) = -V(:,1);
        end
        
        % Y-axis is what it is (no good hueristic for all gaits / shapes).
        % :-(
        
        % Use the cross product of the first 2 axes to define the 3rd.
        % Ensures right-handed coordinates.
        V(:,3) = cross(V(:,1), V(:,2));
        
        % Permute the axes and eigenvalues accordingly.
        virtualChassis_R = V * axisPerm;
        chassisMags = (diag(S(1:3,1:3))' * axisPerm)';
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % If there is a previous frame provided %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        
        % Get the rotation matrix from the previous VC
        lastVC_R = lastVC(1:3,1:3);
        
        % Apply the axis permutaions
        virtualChassis_R = V * axisPerm;
        chassisMags = (diag(S(1:3,1:3))' * axisPerm)';
        
        % Make sure the X-axis isn't flipped
        if dot( virtualChassis_R(:,1), lastVC_R(:,1) ) < 0
            virtualChassis_R(:,1) = -virtualChassis_R(:,1);
        end
        
        % Make sure the Y-axis isn't flipped
        if dot( virtualChassis_R(:,2), lastVC_R(:,2) ) < 0
            virtualChassis_R(:,2) = -virtualChassis_R(:,2);
        end
        
        % Use the cross product of the first 2 axes to define the 3rd.
        % Ensures right-handed coordinates.
        virtualChassis_R(:,3) = cross( virtualChassis_R(:,1), ...
                                     virtualChassis_R(:,2) );
    end
    
    % Make the full Virtual Chassis transformation matrix
    virtualChassis = eye(4);
    virtualChassis(1:3,1:3) = virtualChassis_R;
    virtualChassis(1:3,4) = CoM';

end

