
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET FIGURE RENDERER STUFF   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rendererType = 'OPENGL';

fprintf(['Setting Renderer to ' rendererType ' ...']);

set(0,'DefaultFigureRenderer',rendererType);

fprintf('Done!\n'); 


%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD STUFF TO THE PATH %
%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Adding Paths...');

% This folder
addpath( pwd );
addpath( [pwd 'poseEstimation'] );

% Save this folder
matlabSC_folder = pwd;

% Common folders 
% (gaits, helper functions, log tools, etc.)
% addpath( [pwd '/common'], ...
%          [pwd '/common/java'], ...
%          [pwd '/common/matlab/']);

    addpath( [pwd '/ShapeModulation_Ruscelli'],...
[pwd '/simulation_snake_wTorque'],...
[pwd '/simulation_snake'],...
[pwd '/hebi']); %'/snakeGaitTEST/TraversWindows_new/compliant_Julian_original
% [pwd '/TraversWindows_new/compliant_Julian'],...
%   [pwd '/TraversWindows_new/ShapeSigmoid_Periodic'],...
% oldFolder = pwd;
% cd('hebi');        
fprintf('Done!\n');   

