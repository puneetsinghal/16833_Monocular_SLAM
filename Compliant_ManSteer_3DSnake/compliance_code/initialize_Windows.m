% 
% initialize_windows.m
%
% This function is called once when intializing the windows at the begin-
% ning of both of the two main functions. Windows are essentially an array 
% with cells containing parameters of the segment of the snake within that
% particular window. This allows sections of the snake to move independent-
% ly from the rest.
%
% Explanation of variables:
%         windowsOrigin - a value declared in the main function
%                         represents the position where the windows will
%                         originate. Important for updating and moving the
%                         originating position to different places, which 
%                         is needed for going backwards. 
%         numWindows    - a value declared in the main function
%                         represents the number of total number of windows
%         numWaves      - a value declared in the main function
%                         represents 
%         initialized_windows
%                       - the returned value.
%                         represents the initial state of the windows_array
%
%
% REQUIRES: 0 < numWindows
%           0 < windowsOrigin <= 3          This precondition will be 
%                                           hopefully improved
% ENSURES: initialized_windows(windowsOrigin, numWindows, numWaves) returns
%          a matrix of size 1-by-(numWindows + 1) with the value of at 
%          index windowsOrigin 0 and the value of initialized_windows(i) =
%          initialized_windows(i - 1) + 1/ (2 * numWaves) 
%          

function initialized_windows = initialize_Windows(snakeConst, windows)
    
%   Acquire necessary variables from structure
    posOrigin  = - pi / (2 * snakeConst.spFreq);
    origin     = windows.origin;
    numWindows = windows.numWindows;
    numWaves   = snakeConst.numWaves;
                
    % Initialize the matrix with the proper size
    initialized_windows = zeros(1, numWindows + 1);
    
    for i = 1 : (numWindows + 1)
        initialized_windows(i) = 1 / (2 * numWaves) * (i - origin) ...
                                                               + 4 * posOrigin;
    end
    
end
