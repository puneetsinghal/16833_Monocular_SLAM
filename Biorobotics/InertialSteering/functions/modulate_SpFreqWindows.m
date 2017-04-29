function modulatedSpFreq = modulate_SpFreqWindows(norm, snakeCompl, windows)
    
    spFreq_windows      = windows.spFreq;
    len                 = windows.numWindows;
    
    slope               = snakeCompl.slope;
    
    modulatedSpFreq     = zeros(len, 1);
    
    for i = 1 : len
        
        sigmoidLeft     = exp(slope * (norm - spFreq_windows(i, 2)))/...
                          (1 + exp(slope * (norm - spFreq_windows(i, 2))));
        sigmoidRight    = exp(slope * (norm - spFreq_windows(i, 1)))/...
                          (1 + exp(slope * (norm - spFreq_windows(i, 1))));

        modulatedSpFreq(i, :)  = -sigmoidLeft + sigmoidRight;
        
    end

end