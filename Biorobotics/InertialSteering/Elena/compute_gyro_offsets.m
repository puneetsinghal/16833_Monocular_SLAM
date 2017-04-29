%Compute GyroOffsets
% HebiLookup;
function newGyroOffset = compute_gyro_offsets(g)


samples_for_calibration = 1200;
% g = HebiLookup.newConnectedGroupFromName('Spare','SA008');

gyro_x = [];
gyro_y = [];
gyro_z = [];

tic
for i=1:samples_for_calibration
    fbk = g.getNextFeedback();
    gyro_x(end+1,:) = fbk.gyroX;
    gyro_y(end+1,:) = fbk.gyroY;
    gyro_z(end+1,:) = fbk.gyroZ;
end
toc
        
gyro_x_comp = gyro_x; 
gyro_y_comp = gyro_y;
gyro_z_comp = gyro_z;

figure
plot(mean(gyro_x_comp),'*-', 'Color',  'r' ); hold on
plot(mean(gyro_y_comp),'*-', 'Color',  'g' ); hold on
plot(mean(gyro_z_comp),'*-', 'Color',  'b' ); hold on
plot(std(gyro_x_comp),'*-', 'Color',  [0.5430 0 0] ); hold on
plot(std(gyro_y_comp),'*-', 'Color',  [ 0 0.5430 0] ); hold on
plot(std(gyro_z_comp),'*-', 'Color',  [0 0 0.5430] ); hold on
legend('x mean ', 'y mean ', 'z mean ', 'x std', 'y std', 'z std');
ylabel(' [rad/sec]')
xlabel('module #')
title('std of the gyro')



minimum = min(min([gyro_x_comp; gyro_y_comp; gyro_z_comp]));
maximum = max(max([gyro_x_comp; gyro_y_comp; gyro_z_comp]));
limit = max(maximum, -maximum);

figure
subplot(1,3,1);
plot(gyro_x_comp); hold on
legend('1', '2', '3', '4', '5', '6', '7', '8', '9',...
    '10', '11', '12', '13', '14', '15', '16', '17', '18');
xlabel('gyro x');
xlim([1, length(gyro_x)]);
ylim([-limit, limit]);
subplot(1,3,2);
plot(gyro_y_comp); hold on
legend('1', '2', '3', '4', '5', '6', '7', '8', '9',...
    '10', '11', '12', '13', '14', '15', '16', '17', '18');
xlabel('gyro y');
xlim([1, length(gyro_x)]);
ylim([-limit, limit]);
subplot(1,3,3);
plot(gyro_z_comp); hold on
legend('1', '2', '3', '4', '5', '6', '7', '8', '9',...
    '10', '11', '12', '13', '14', '15', '16', '17', '18');                
xlabel('gyro z');
xlim([1, length(gyro_x)]);   
ylim([-limit, limit]);

newGyroOffset = [mean(gyro_x_comp); mean(gyro_y_comp); mean(gyro_z_comp)];




end
