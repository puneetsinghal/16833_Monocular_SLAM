function [ q_out ] = quat_rotate( Xr, Yr, Zr, q_bottom, dt )
%QUAT_ROTATE Rotate a quaternion by a velocity and timestep.
    
    % Switch to scalar top, because that's what this code was written for
    q = zeros(4,1);
    q(1) =  q_bottom(4);   % w  -x
    q(2) = -q_bottom(1);   % x  -y  
    q(3) = -q_bottom(2);   % y  -z  
    q(4) = -q_bottom(3);   % z   w
    
    
    % Make the velocity vector
    q_vel = zeros(4,1);
    q_vel(2) = Xr;
    q_vel(3) = Yr;
    q_vel(4) = Zr;
    
    % Update using some quaternion calculus.
    q_new = q + dt * .5 * quat_mult( q , q_vel );
    
    % Normalize
    q_new = q_new / ...
       sqrt(q_new(1)^2 + q_new(2)^2 + q_new(3)^2 + q_new(4)^2);
   
   
    % Switch back to using scalar bottom to spit out
    q_out = zeros(4,1);
    q_out(1) = -q_new(2);    % x  w
    q_out(2) = -q_new(3);    % y -x
    q_out(3) = -q_new(4);    % z -y
    q_out(4) =  q_new(1);    % w -z
    

end

