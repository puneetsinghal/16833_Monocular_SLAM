fig_one = figure(1);
fig_one.Position = [0 (990+150)/2 960 (990-150)/2];
plot_sfm_even = plot(0 ,0);
hold on;
plot_origin = scatter(0, 0, 'filled');
hold on;
xlim([-2 3]);
ylim([-3 3]);
hold on;

for window_ind = 1:numWindows
plot_windows(window_ind) = scatter(0, 0,'filled');
hold on;
end
 %only if window_amp is present
for window_ind = 1:numWindows
plot_windows_amp(window_ind) = scatter(0, 0);
hold on;
end