function spFreqNew = update_SpFreqWindows(snakeCompl, snakeConst, windows)

    numWindows     = windows.numWindows;
    windows_array  = windows.array;
    phi            = snakeCompl.tmFreq;
    spFreq         = snakeConst.spFreq;
    
    spFreqNew      = zeros(numWindows, 2);
    
    for i = 1 : numWindows
        spFreqNew(i, :) = [windows_array(i), windows_array(i + 1)]...
                                                            + phi / spFreq;
    end

end