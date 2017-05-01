function [IMU_U] = imuSEAtoU(IMU_SEA)
%IMUSEATOU Changes SEAsnake accelerometer or gyro readings of all of the
% individual modules into the first modules frame according to USnake
% convention

IMU_U = zeros(size(IMU_SEA));

IMU_SEA = fliplr(IMU_SEA);

% In the SEA snake the module frame rotate with respect to the following
% one of 90 degrees along z-axis
% Z does not change because all the modules are aligned along this axis
% rigidly

% Head frame of the SEA snake is rotated of 90degrees around z-axis with
% respect to USnake head
R_SEA_to_U = Rot_z(-pi/2);

for i = 1:size(IMU_SEA,2)
    
    IMU_U(:,i) = R_SEA_to_U * IMU_SEA(:,i);
    R_SEA_to_U = R_SEA_to_U*Rot_z(pi/2);
end

end

function R = Rot_z(angle)
    R = [cos(angle), -sin(angle), 0; ...
        sin(angle), cos(angle), 0; ...
        0, 0, 1];
end