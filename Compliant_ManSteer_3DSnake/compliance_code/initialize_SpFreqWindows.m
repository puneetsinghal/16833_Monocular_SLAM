% 
% initialize_SpFreqWindows.m
%
% This function is called once when intializing the spFreq_windows array at
% the beginning of the main function. 
%
% Explanation of variables:
%         windows       - the structure that contains all the information
%                         surrounding windows.
%         spFreq_windows
%                       - the returned value.
%                         represents the initial state of the
%                         spFreq_windows array
%
%
% REQUIRES : windows structure is defined for numWindows and windows_array
% ENSURES : returns a matrix of size numWindows-by-2 array such that the
%           first element in the ith row is the coordinate where the window
%           begins and the second element is the coordinate where the 
%           window ends. 

function spFreq_windows = initialize_SpFreqWindows(windows) 

    numWindows     = windows.numWindows;
    windows_array  = windows.array;
    
    spFreq_windows = zeros(numWindows, 2);
    
    for i = 1 : numWindows
        spFreq_windows(i, :) = [windows_array(i), windows_array(i + 1)];
    end

end