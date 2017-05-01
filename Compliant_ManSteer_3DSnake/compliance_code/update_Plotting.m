    set(plot_sfm_even, 'xdata', ...
        (1:2:snakeConst.numModules)/snakeConst.numModules, 'ydata', ...
        commanded_angles(1:2:end)');
    hold on;
    plot(0, 0, 'b');
    for window_ind = 1:numWindows
        set(plot_windows(window_ind), 'xdata', windows.spFreq(window_ind,:),...
            'ydata', zeros(size(windows.spFreq(1,:))));
    end
    %------amp----------
    for window_ind = 1:numWindows
        set(plot_windows_amp(window_ind), 'xdata', windows.amp(window_ind,:),...
            'ydata', zeros(size(windows.amp(1,:))));
    end