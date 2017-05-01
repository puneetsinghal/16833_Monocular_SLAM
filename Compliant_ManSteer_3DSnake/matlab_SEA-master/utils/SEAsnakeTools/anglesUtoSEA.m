function [jointAngles] = anglesUtoSEA(snakeData,jointAngles)
%ANGLESUTOSEA Sets U snake joint angles as if it were a SEASnake
%   Switches the signs of all joint angles and flips the module order to
%   be head to tail.
    for n = 1:length(jointAngles(:,1))
        jointAngles(n,:) = snakeData.reversals.*jointAngles(n,:);
        jointAngles(n,:) = fliplr(jointAngles(n,:));
    end
end