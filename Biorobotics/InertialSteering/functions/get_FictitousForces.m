% 
% getFictitousForces.m
%
% This function is called at the beginning of every iteration of the main
% loop. Define here the fictitious forces that would be taken to account in
% the simulation.
%
% Explanation of variables:
%         t         - a value declared in the main function
%                     represents the current time
%         tau_Ext   - a matrix representing the forces that are applied to 
%                     the snake by the evironment.
%
%
% REQUIRES: NONE
% ENSURES: returns the external forces acting on the snake at the given
%          time, t
%   
function tau_Ext = get_FictitousForces(t, snakeConst)

    numModules         = snakeConst.numModules;
    if (t > 2.1)
           tauExt_even = [0 0 0 0 0 0 0 0 0]; 
           tauExt_odd  = [0 0 0 0 0 0 0 0 0];
           tau_Ext     = [tauExt_even; tauExt_odd];
           tau_Ext     = tau_Ext(:);
    elseif (t > 0.7)
           tauExt_even = [0 0 0 0 0 0 0 0 0]; 
           tauExt_odd  = [0 0 0 0 0 0 0 0 0];
           tau_Ext     = [tauExt_even; tauExt_odd];
           tau_Ext     = tau_Ext(:); 
    else
           tau_Ext     = zeros(numModules, 1);
    end

end