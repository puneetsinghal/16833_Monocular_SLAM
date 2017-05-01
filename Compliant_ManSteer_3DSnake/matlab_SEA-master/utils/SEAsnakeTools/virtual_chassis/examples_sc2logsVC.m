%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Examples for kinematics VC %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file needs an already existing sc2logs file

% Possible Calls -------------------------------------------------
% % Commanded with VC_Rot                                        |
% fnc(field, vc_rot)                               % 2 arguments |
% fnc(field, [length], vc_rot )                    % 3 arguments |
%                                                                |
% % Commanded with Accels                                        |
% fnc(field, accel x, accel y, accel z)            % 4 arguments |
% fnc(field, [length], accel x, accel y, accel z)  % 5 arguments |
%                                                                |
% % Feedback                                                     |
% fnc(field) % checks for accels + standard length % 1 argument  |
% fnc(field, [length])                             % 2 arguments |
% ----------------------------------------------------------------

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check for Used Paths         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Common Folder
current = fileparts(mfilename('fullpath'));
commonMatlab = fullfile(current, '..');

% Virtual Chassis
if ~exist('sc2logsVC','file')    
    addpath(fullfile(commonMatlab, 'virtual_chassis'));
end

%% %%%%%%%%%%%%%%%%%
% Commanded Angles %
%%%%%%%%%%%%%%%%%%%%

%% commanded angles with best effort
% 2.8678 seconds calculated in 0.32 seconds ~ 8.9x realtime
tic
    log.misc.vc = sc2logsVC(log.command);
toc

%% commanded angles with old vc_rot
% 2.8678 seconds calculated in 0.32 seconds ~ 8.9x realtime
tic
    log.misc.vc = sc2logsVC(log.command, log.misc.vc{1});
toc

%% commanded angles with accelerometers
% 2.8678 seconds calculated in 0.33 seconds ~ 8.7x realtime
tic
    log.misc.vc = sc2logsVC(log.command, log.feedback.x_accel, ...
        log.feedback.y_accel, log.feedback.z_accel);
toc

%% %%%%%%%%%%%%%%%%%
% Feedback Angles  %
%%%%%%%%%%%%%%%%%%%%

%% feedback angles with best effort
% 2.8486 seconds calculated in 0.09 seconds  ~ 31.7x realtime
tic
    log.misc.vc = sc2logsVC(log.feedback);
toc

%% feedback angles with old vc_rot
% 2.8486 seconds calculated in 0.075 seconds ~ 38.0x realtime
tic
    log.misc.vc = sc2logsVC(log.feedback, log.misc.vc{1});
toc

%% feedback angles with accelerometers
% 2.8486 seconds calculated in 0.08 seconds ~ 35.6x realtime
tic
    log.misc.vc = sc2logsVC(log.feedback, log.feedback.x_accel, ...
        log.feedback.y_accel, log.feedback.z_accel);
toc


