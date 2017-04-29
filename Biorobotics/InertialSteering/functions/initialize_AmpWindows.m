% 
% initialize_SpFreqWindows.m
%
% This function is called once when intializing the spFreq_windows array at
% the beginning of the main function. 
%
% Explanation of variables:
%         windows       - the structure that contains all the information
%                         surrounding windows.
%         amp_windows   - the returned value.
%                         represents the initial state of the
%                         amp_windows array
%
%
% REQUIRES : windows structure is defined for numWindows and windows_array
% ENSURES : returns a matrix of size numWindows-by-2 array such that the
%           first element 
% 
% 
function amp_windows = initialize_AmpWindows(windows) 

    numWindows          =  windows.numWindows;
    array               =  windows.array;
    
    amp_windows         =  zeros(numWindows, 2);
    amp_windows(1, :)   = [array(1) - (array(2) - array(1))/2, ...
                           array(1) + (array(2) - array(1))/2];
    for i = 2 : numWindows
        amp_windows(i,:) = [array(i) - (array(i)   - array(i-1))/2, ...
                            array(i) + (array(i+1) - array(i))  /2];
    end


end