function windows = update_Windows(snakeCompl, windows)

    numWindows      = windows.numWindows;
    array_windows   = windows.array;
    spFreq_snake    = snakeCompl.spFreq;
    
    for i = 1 : numWindows
        array_windows(i + 1) = array_windows(i) +  pi / spFreq_snake(i);
    end
    
    windows.array  = array_windows;
end