function [jointAngles] = anglesSEAtoU(snakeData,jointAngles)
%ANGLESSEATOU Changes SEAsnake joint angles as if it were a uSnake
%   Switches the signs of all joint angles and flips the module order to
%   be head to tail.
    for n = 1:length(jointAngles(:,1))
        jointAngles(n,:) = fliplr(jointAngles(n,:));
        jointAngles(n,:) = snakeData.reversals.*jointAngles(n,:);
    end
end