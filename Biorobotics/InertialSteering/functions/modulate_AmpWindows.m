function modulatedAmp = modulate_AmpWindows(norm, snakeCompl, windows)

    amp_windows         = windows.amp;
    len                 = windows.numWindows;
    
    slope               = snakeCompl.slope;
    
    modulatedAmp        = zeros(len, 1);
    
    for i = 1 : len
        
        sigmoidLeft         = exp(slope * (norm - amp_windows(i, 2)))/...
                             (1 + exp(slope * (norm - amp_windows(i, 2))));
        sigmoidRight        = exp(slope * (norm - amp_windows(i, 1)))/...
                             (1 + exp(slope * (norm - amp_windows(i, 1))));
                         
        modulatedAmp(i, :)  = -sigmoidLeft + sigmoidRight;
        
    end

end