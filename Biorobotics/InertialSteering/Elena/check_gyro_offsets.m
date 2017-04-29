%Check GyroOffsets
% HebiLookup;
function [mean_variation, deviations] = check_gyro_offsets(g,gyroOffsets, gyrosTrustability)


samples_for_calibration = 200;
g = HebiLookup.newConnectedGroupFromName('*','SA014');

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
        
gyro_x_comp = gyro_x - repmat(gyroOffsets(1,:), samples_for_calibration, 1);
gyro_y_comp = gyro_y - repmat(gyroOffsets(2,:), samples_for_calibration, 1);
gyro_z_comp = gyro_z - repmat(gyroOffsets(3,:), samples_for_calibration, 1);

bad_gyros = find(gyrosTrustability<1);
figure
plot(mean(gyro_x_comp),'*-', 'Color',  'r' ); hold on
plot(mean(gyro_y_comp),'*-', 'Color',  'g' ); hold on
plot(mean(gyro_z_comp),'*-', 'Color',  'b' ); hold on
plot(std(gyro_x_comp),'*-', 'Color',  [0.5430 0 0] ); hold on
plot(std(gyro_y_comp),'*-', 'Color',  [ 0 0.5430 0] ); hold on
plot(std(gyro_z_comp),'*-', 'Color',  [0 0 0.5430] ); hold on
plot(bad_gyros, mean(gyro_x_comp(:,bad_gyros)),'o', 'Color',  'r', 'MarkerSize', 20 ); hold on
plot(bad_gyros, mean(gyro_y_comp(:,bad_gyros)),'o', 'Color',  'g', 'MarkerSize', 20 ); hold on
plot(bad_gyros, mean(gyro_z_comp(:,bad_gyros)),'o', 'Color',  'b', 'MarkerSize', 20 ); hold on
plot(bad_gyros, std(gyro_x_comp(:,bad_gyros)),'o', 'Color',  [0.5430 0 0], 'MarkerSize', 20 ); hold on
plot(bad_gyros, std(gyro_y_comp(:,bad_gyros)),'o', 'Color',  [ 0 0.5430 0], 'MarkerSize', 20 ); hold on
plot(bad_gyros, std(gyro_z_comp(:,bad_gyros)),'o', 'Color',  [0 0 0.5430] , 'MarkerSize', 20); hold on
legend('x mean ', 'y mean ', 'z mean ', 'x std', 'y std', 'z std', 'o = ignored gyro');
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

newGyroOffset = [mean(gyro_x_comp); mean(gyro_y_comp); mean(gyro_z_comp)]+gyroOffsets;

% disp(['Offsets seems to be changed of these %:'])
mean_variation = abs(newGyroOffset-gyroOffsets)./max(max(gyroOffsets))*100;

figure
plot(mean_variation(1,:),'r*-'); hold on
plot(mean_variation(2,:),'g*-');
plot(mean_variation(3,:),'b*-');
plot(bad_gyros, mean_variation(1,bad_gyros),'ro', 'MarkerSize', 20); hold on
plot(bad_gyros, mean_variation(2,bad_gyros),'go', 'MarkerSize', 20);
plot(bad_gyros, mean_variation(3,bad_gyros),'bo', 'MarkerSize', 20);
legend('x', 'y', 'z');
ylabel('%')
xlabel('module #')
title('Variation of the offset from max previous offset')

deviations = [std(gyro_x_comp); std(gyro_y_comp); std(gyro_z_comp)];

%Ignore ignored gyros
good_gyros = setdiff(1:length(fbk.gyroX),bad_gyros);
deviations = deviations(:, good_gyros);
mean_variation = mean_variation(:, good_gyros);

end
