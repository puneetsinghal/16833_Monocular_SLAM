% fig_one = figure(1);
% fig_one.Position = [0 (990+150)/2 960 (990-150)/2];
% plot_sfm_even = plot(0 ,0);
% hold on;
% plot_origin = scatter(0, 0, 'filled');
% hold on;
% xlim([-2 3]);
% ylim([-3 3]);
% hold on;
% 
% for window_ind = 1:numWindows
% plot_windows(window_ind) = scatter(0, 0,'filled');
% hold on;
% end
%  %only if window_amp is present
% for window_ind = 1:numWindows
% plot_windows_amp(window_ind) = scatter(0, 0);
% hold on;
% end
t_record = 0;
heading_record = 0;
% mainAxes = 0;

fig_two = figure(3);
fig_two.Position = [0 40 960 (990-100)/2];
hold on;
plot_Heading = plot(0,0,'blue','LineWidth',2);
    % plot_MainAxes = plot(0,0,'red');
xlabel('Time [s]');
ylabel('Heading [rad]');
title('Snake''s Heading');
legend('Snake''s Heading', 'Location','SouthEast');
hold off;
