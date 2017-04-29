function ampNew = update_AmpWindows(snakeCompl, snakeConst, windows)

    numWindows      = windows.numWindows;
    array           = windows.array;
    phi             = snakeCompl.tmFreq;
    spFreq          = snakeConst.spFreq;
    
    ampNew(1, :) = [array(1) - pi/(2 * spFreq),...
                          array(1) + ((array(2)-array(1))/2)] + phi/spFreq;
    
    for i = 1:numWindows-1
        ampNew(i+1,:) = [array(i)   + ((array(i+1)-array(i))  /2),...
                         array(i+1) + ((array(i+2)-array(i+1))/2)]...
                                                              + phi/spFreq;
    end
    

end