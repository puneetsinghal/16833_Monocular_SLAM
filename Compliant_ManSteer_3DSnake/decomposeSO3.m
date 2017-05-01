function [thetaX, thetaY, thetaZ] = decomposeSO3(rotationMatrix)

thetaX = atan2(rotationMatrix(3,2),rotationMatrix(3,3));
thetaY = atan2(-rotationMatrix(3,1),norm(rotationMatrix(3,2:3)));
thetaZ = atan2(rotationMatrix(2,1),rotationMatrix(1,1));
