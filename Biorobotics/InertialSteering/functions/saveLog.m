function saveLog(log)

time = log.time;
vel  = log.velocity;
pos  = log.position;
tau  = log.torque;
accX = log.accelX;
accY = log.accelY;
accZ = log.accelZ;
gyroX = log.gyroX;
gyroY = log.gyroY;
gyroZ = log.gyroZ;

<<<<<<< HEAD
save('logfileUnstuck2.mat', 'time', 'vel', 'pos', 'tau', 'accX', 'accY', 'accZ', 'gyroX', 'gyroY', 'gyroZ');
=======
save('test1.mat', 'time', 'vel', 'pos', 'tau', 'accX', 'accY', 'accZ', 'gyroX', 'gyroY', 'gyroZ');
>>>>>>> f108d1c876c0b7660b81a41e25bcccc7b425fc1f
