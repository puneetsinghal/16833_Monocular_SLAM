%% Loading the Hebi API
addpath('/Users/kywoodard/Documents/MATLAB/Biorobotics Lab/HEBI API')
API_Setup_2_0;


%% Create a group

% Time to wait when trying to build a group
timeout_ms = 1000;

%%%%%%%%%%%%%%%%%%%%%%%
% ONE GREAT BIG GROUP %
%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('SEAsnake')
    firstMac = {'00:1E:C0:8D:54:D6'};     % test

    groupName = 'SEASnake';

    SEAsnake = HebiApi.newConnectedGroupFromMac(firstMac);

    addpath('/Users/kywoodard/Documents/MATLAB/Biorobotics Lab/ModuleTest/gains');
    addpath('/Users/kywoodard/Documents/MATLAB/Biorobotics Lab/Snake')

    fprintf('Success!\n\n');
end
