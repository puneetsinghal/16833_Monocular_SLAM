function [V,animateStruct] = setDummySEASnake(cmd,V,animateStruct,snakeData)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Ideal Snake Based On Position Command %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(cmd.position)
    if cmd.position(i) > pi/2
        cmd.position(i) = pi/2;
    elseif cmd.position(i) < -pi/2
        cmd.position(i) = -pi/2;
    end
end
    
[TF,MF,V,animateStruct] = SEASnakeVC(animateStruct,snakeData,cmd,V);

end