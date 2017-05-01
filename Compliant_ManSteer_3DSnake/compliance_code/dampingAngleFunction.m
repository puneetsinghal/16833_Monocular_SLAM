function angleNew = dampingAngleFunction(angle)
    
    a = -2/pi;
    b = -a * pi;
    c = 3 * pi/8 - a * (pi/2) ^ 2 - b * (pi/2);
    x0 = 1/(2 * a) + pi/2;
    
    aNeg = 2/pi;
    bNeg = aNeg * pi;
    cNeg = -3 * pi/8 - aNeg * (pi/2) ^ 2 + bNeg * (pi/2);
    x0Neg = 1/(2 * aNeg) - pi/2;
    
    if angle > pi/2
       angle = pi/2;
    elseif angle < -pi/2
       angle = -pi/2;
    end

    if (angle < x0 && angle > x0Neg)
        angleNew  = angle;
    else
        if(angle > x0)
            output  = a * angle^2 + b * angle + c;
        else
            output  = aNeg * angle^2 + bNeg * angle + cNeg;
        end
        angleNew  = output;
    end
    

end



% 
% function [angleFirstNew, angleSecondNew] = dampingAngleFunction(angleSecond, angleFirst)
%     
%     a = -2/pi;
%     b = -2 * a * pi;
%     c = 7 * pi/8 - a * (pi) ^ 2 - b * (pi);
%     x0 = 1/(2 * a) + pi;
%     
%     aNeg = 2/pi;
%     bNeg = 2 * aNeg * pi;
%     cNeg = -7 * pi/8 - aNeg * (pi) ^ 2 + bNeg * (pi);
%     x0Neg = 1/(2 * aNeg) - pi;
%     
%     if angleSecond > pi/2
%        angleSecond = pi/2;
%     elseif angleSecond < -pi/2
%        angleSecond = -pi/2;
%     end
%     
%     if angleFirst > pi/2
%        angleFirst = pi/2;
%     elseif angleFirst < -pi/2
%        angleFirst = -pi/2;
%     end
%     
%     angleSum = angleSecond + angleFirst;
%     if (angleSum < x0 && angleSum > x0Neg)
%         angleFirstNew  = angleFirst;
%         angleSecondNew = angleSecond;
%     else
%         if(angleSecond + angleFirst > x0)
%             outputSum  = a * angleSum^2 + b * angleSum + c;
%         else
%             outputSum  = aNeg * angleSum^2 + bNeg * angleSum + cNeg;
%         end
%         angleSecondNew = outputSum / (angleFirst/angleSecond + 1);
%         angleFirstNew  = outputSum - angleSecondNew;
%     end
%     
% 
% end
