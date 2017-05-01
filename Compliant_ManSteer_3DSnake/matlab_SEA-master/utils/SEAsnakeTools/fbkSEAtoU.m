function fbkUSnake = fbkSEAtoU(snakeData,fbkSEA)
%FBKSEATOU Changes SEAsnake feedback as if it were a USnake

% Convert angles to USnake head-tail order plus changes their sign
% according to USNake convention
fbkUSnake.position = anglesSEAtoU(snakeData,fbkSEA.position);

%Convert accelerations and gyros to USnake frame convention
accel_SEASnake= [fbkSEA.accelX; fbkSEA.accelY; fbkSEA.accelZ];
gyros_SEASnake= [fbkSEA.gyroX; fbkSEA.gyroY; fbkSEA.gyroZ];
accel_USnake = imuSEAtoU(accel_SEASnake);
gyros_USnake = imuSEAtoU(gyros_SEASnake);
fbkUSnake.gyroX = gyros_USnake(1,:);
fbkUSnake.gyroY = gyros_USnake(2,:);
fbkUSnake.gyroZ = gyros_USnake(3,:);
fbkUSnake.accelX = accel_USnake(1,:);
fbkUSnake.accelY = accel_USnake(2,:);
fbkUSnake.accelZ = accel_USnake(3,:);

% Copy time stamp
fbkUSnake.time = fbkSEA.time;

end