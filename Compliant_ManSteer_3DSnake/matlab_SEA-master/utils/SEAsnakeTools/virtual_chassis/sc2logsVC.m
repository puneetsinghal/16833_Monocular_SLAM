function [ kinVC ] = sc2logsVC(field, p2, p3, p4, p5)
% Possible Calls -------------------------------------------------
% % Commanded with VC_Rot                                        |
% fnc(field, vc_rot)                               % 2 arguments |
% fnc(field, [length], vc_rot )                    % 3 arguments |
%                                                                |
% % Commanded with Accels                                        |
% fnc(field, accel x, accel y, accel z)            % 4 arguments |
% fnc(field, [length], accel x, accel y, accel z)  % 5 arguments |
%                                                                |
% % Feedback and Best Effort                                     |
% fnc(field) % checks for accels + standard length % 1 argument  |
% fnc(field, [length])                             % 2 arguments |
% ----------------------------------------------------------------
%
%
%   -----------------------------------------------------------------------
%   Return Value:
%   -----------------------------------------------------------------------
%   A cell array of 4x4xM kinematic chains, where M equals to the number of
%   modules.
%   
%   -----------------------------------------------------------------------
%   Parameters:
%   -----------------------------------------------------------------------
%   'field' is the sc2logs object that has the angles that should be
%   played.
%
%   'vc_rot' is the previous VC transformation matrix. It is used too
%   ensure that ambiguous axes do not get flipped.
%
%   'length' is the length of each module. It defaults to the standard
%   value in getSnakeGeometry().
%
%   'accel x/y/z' are accelerometer values that are used to initialize the
%   virtual chassis axes the right side up.
%
%   -----------------------------------------------------------------------   
%   Example Calls
%   -----------------------------------------------------------------------
%   Commanded angles with best effort
%   log.misc.vc = sc2logsVC(log.command)
%   
%   Commanded angles with old vc_rot
%   log.misc.vc = sc2logsVC(log.command, log.misc.vc{1})
%   
%   Commanded angles with accelerometers to initialize
%   log.misc.vc = sc2logsVC(log.command, log.feedback.x_accel, ...
%        log.feedback.y_accel, log.feedback.z_accel);
%
%   Feedback angles with best effort
%   log.misc.vc = sc2logsVC(log.feedback)
%
%   Feedback angles with old vc_rot (This ignores the accelerometer values)
%   log.misc.vc = sc2logsVC(log.feedback, log.misc.vc{1})
%
%   Feedback angles with accelerometers (Here the accelerometers are only
%   used for the initialization. Afterwards they are ignored. This is
%   identical to the commanded angle version)
%   log.misc.vc = sc2logsVC(log.feedback, log.feedback.x_accel, ...
%        log.feedback.y_accel, log.feedback.z_accel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check for Used Paths         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Common Folder
current = fileparts(mfilename('fullpath'));
commonMatlab = fullfile(current, '..');

% Virtual Chassis
if ~exist('unifiedVC','file')    
    addpath(fullfile(commonMatlab, 'virtual_chassis'));
end

% Kinematics & Geometry
if ~exist('make_snake','file') || ...
    ~exist('transform_snake','file') || ...
    ~exist('getSnakeGeometry','file')
    addpath(fullfile(commonMatlab, 'kinematics'));
end

% Sc2Logs Tools
if ~exist('sc2logs','file')
    addpath(fullfile(commonMatlab, 'logTools'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Unknown Parameters       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section handles 'overloading' of parameters and sets default values
% if nothing has been specified.

p.mode = nargin;
switch p.mode
    case 5 % Commanded Angles with Length and Accels
        p.length = p2;
        p.x_accel = p3;
        p.y_accel = p4;
        p.z_accel = p5;
        
    case 4 % Commanded Angles with Accels
        p.x_accel = p2;
        p.y_accel = p3;
        p.z_accel = p4;
        
    case 3 % Commanded Angles with Length and previous vc_rot
        p.length = p2;
        p.vc_rot = p3;
        
    case 2 % Commanded Angles with previous vc_rot or Feedback with Length
        if max(size(p2)) == 1
            p.length = p2;
        else
            p.vc_rot = p2;
        end
        
    case 1 % Any Angles with standard mode
        
    otherwise 
        error(['There is no method overload for ' num2str(p.mode) ...
            ' parameters.'], 'ParameterCheck:unsupportedParameter');
end

% If the entire old kinematics get passed in, just use the head module's
if isfield(p,'vc_rot')
    if size(p.vc_rot,3) > 1
        p.vc_rot = p.vc_rot(:,:,1);
    end
end

% Length
if ~isfield(p, 'length')
    snake = getSnakeGeometry();
    p.length = snake.module_len;
end

% TODO: find better solution instead of workaround
tmp = sc2logs(size(field.x_angle,2));
p.x_ang_mask = tmp.x_ang_mask;
p.y_ang_mask = tmp.y_ang_mask;
p.axisPerm = eye(3); % TODO: Implement axis perm for different gaits

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check for Parameter Validity %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fields
if ~isfield(field,'x_angle') || ~isfield(field,'y_angle')
    error(['The selected angles do not contain all necessary' ...
        ' subfields. (x_angle, y_angle)'], ...
        'ParameterCheck:fieldsNotFound');
end

% Previous vc_rot
if isfield(p,'vc_rot')
    if sum( size(p.vc_rot) ~= [4 4] )
        error(['The previous VC has wrong dimensions.' ...
            ' Expected 4x4xN Matrix.'], ...
            'ParameterCheck:unsupportedMode');
    end
end

% Length
if ~isa(p.length,'double') || p.length <= 0
    error(['The length parameter must be a positive double.' ''], ...
        'ParameterCheck:unsupportedParameter');
end

% Accelerometers (Length)
if ( p.mode == 4 ) && (...
        size(p.x_accel,1) > 1 || ...
        size(p.y_accel,1) > 1 || ...
        size(p.z_accel,1) > 1 )
    
    warning(['The length of the accelerometer data cannot be '...
        'greater than 1. Only the first ones will be used.'], ...
        'ParameterCheck:unsupportedParameter');
    
    p.x_accel = p.x_accel(1,:);
    p.y_accel = p.y_accel(1,:);
    p.z_accel = p.z_accel(1,:);
end

% Accelerometers
% Possibly check for NaNs ?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Kinematics in Head frame %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the VC kinematics for every set of angles.

kinCount = size(field.x_angle,1);
kinHead = cell(kinCount,1);

% calculate kinematics in head frame
for i = 1:kinCount
   
    %% Filter x_angle NaNs
    x_NaNs = isnan(field.x_angle(i,:));
    if sum(x_NaNs) ~= 0
        if i>1 && i<kinCount(end) % in the middle
            
            field.x_angle(i,x_NaNs) = ( field.x_angle(i-1,x_NaNs) + ...
                                        field.x_angle(i+1,x_NaNs) )/2;
            display(['X NaN at step ' num2str(i) ' changed to ' num2str(field.x_angle(i,x_NaNs))]);
            
        else % beginning or end
            display(['X NaN at step ' num2str(i) 'could not be changed.']);
        end
    end
    
    %% Filter y_angle NaNs
    y_NaNs = isnan(field.y_angle(i,:));
    if sum(y_NaNs) ~= 0
        if i>1 && i<kinCount(end) % in the middle
            
            field.y_angle(i,y_NaNs) = ( field.y_angle(i-1,y_NaNs) + ...
                                        field.y_angle(i+1,y_NaNs) )/2;
            display(['Y NaN at step ' num2str(i) ' changed to ' num2str(field.y_angle(i,y_NaNs))])
            
        else % at the end
            display(['Y NaN at step ' num2str(i) 'could not be changed.']);
        end
    end
    
    %% Filter NaNs at starting position and make sure that there aren't 2
    %  Nans in a row
     
    %% Calculate the kinematics
    kinHead{i} = make_snake( field.x_angle(i,:), ... 
                             field.y_angle(i,:), ... 
                             p.x_ang_mask, ...     %
                             p.y_ang_mask, ...     %
                             p.length);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the Best Virtual Chassis   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
kinVC = cell(kinCount,1);
flipMatrix = [  1  0  0  0 
                0 -1  0  0 
                0  0 -1  0 
                0  0  0  1];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use Accelerometers for first vc_rot     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if  isfield(p,'x_accel') && ...
        isfield(p,'y_accel') && ...
        isfield(p,'z_accel')
        
        % calculate ambiguous vc
        p.vc_rot = unifiedVC( kinHead{1}, p.axisPerm );
        
        % get average accelerometer readings in head frame
        [ avgAccel stdAccel ] = rotateAccelerometers(kinHead{1}, ...
            p.x_accel, p.y_accel, p.z_accel);
        
        % check the direction of "up" in temporary VC coordinates
        avgAccel = p.vc_rot(1:3,1:3)' * avgAccel;
        
        % flip if necessary
        if avgAccel(3) < 0
            p.vc_rot = p.vc_rot * flipMatrix;
            display(['VC flip at step ' num2str(i)]);
        end
        
        % TODO: display warnings when z direction is really low or standard
        % deviation of accel readings is really high ?
         
        % flip first step correctly
        kinVC{1} = transform_snake(kinHead{1}, p.vc_rot);
        
        % do the rest
        for i = 2:kinCount
            p.vc_rot = unifiedVC( kinHead{i}, p.axisPerm, p.vc_rot );
            kinVC{i} = transform_snake(kinHead{i}, p.vc_rot);
        end
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use previous vc_rot as a starting point %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isfield(p,'vc_rot')
        
        % do all
        for i=1:kinCount
            p.vc_rot = unifiedVC( kinHead{i}, p.axisPerm, p.vc_rot );
            kinVC{i} = transform_snake(kinHead{i}, p.vc_rot);
        end
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use Best Effort  => Accelerometers      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif  isfield(field,'x_accel') && ...
            isfield(field,'y_accel') && ...
            isfield(field,'z_accel')

        for i = 1:kinCount
            
            if i == 1 % calculate ambiguous first step
                p.vc_rot = unifiedVC( kinHead{i}, p.axisPerm);
            else
                p.vc_rot = unifiedVC( kinHead{i}, p.axisPerm, p.vc_rot );
            end
            
            % get average accelerometer readings in head frame
            [ avgAccel ~ ] = rotateAccelerometers(kinHead{i}, ...
               field.x_accel(i,:), field.y_accel(i,:), field.z_accel(i,:));
           
            % check the direction of "up" in temporary VC coordinates
            avgAccel = p.vc_rot(1:3,1:3)' * avgAccel;
            
            % TODO: display warnings when z direction is really low or standard
            % deviation of accel readings is really high ?
            
            % flip if necessary
            if avgAccel(3) < 0  % Maybe val < -0.05 to keep it more stable 
                p.vc_rot = p.vc_rot * flipMatrix;
                display(['VC flip at step ' num2str(i)]);
            end
            
            % transform kinematics into virtual chassis coordinates
            kinVC{i} = transform_snake(kinHead{i}, p.vc_rot);
        end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use Best Effort => No Info              %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        % init first vc_rot
        p.vc_rot = unifiedVC( kinHead{1}, p.axisPerm );
        kinVC{1} = transform_snake(kinHead{1}, p.vc_rot);
        
        % do the rest
        for i = 2:kinCount
            p.vc_rot = unifiedVC( kinHead{i}, p.axisPerm, p.vc_rot );
            kinVC{i} = transform_snake(kinHead{i}, p.vc_rot);
        end

    end

end

function [ avgAccel stdAccel ] = rotateAccelerometers( gait_pts, x, y, z )
%ROTATEACCELEROMETERS rotates all the accelerometers of different
% modules to the directions in their base frame
%   Detailed explanation goes here

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Accelerometer Matrices %
%%%%%%%%%%%%%%%%%%%%%%%%%%

modules = length(gait_pts)-1;
accelForce = zeros(3,modules+1);

for i = 1:modules
    
    inv_R = gait_pts(1:3,1:3,i+1);
    
    accelForce(1:3,i+1) = inv_R * [ x(i); y(i); z(i) ] ;               
end

% calculate normalized average force vector ( ~gravity )
avgAccel = mean(accelForce(:,2:end),2);
avgAccel = avgAccel / norm(avgAccel);
stdAccel = std(accelForce(:,2:end),0,2);

end


