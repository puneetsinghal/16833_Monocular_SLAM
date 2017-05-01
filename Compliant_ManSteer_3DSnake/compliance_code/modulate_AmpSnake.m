function modulatedAmp = modulate_AmpSnake(norm, snakeCompl, windows)

    amp_snake           = snakeCompl.amp;
    amp_windows         = windows.amp;
    len                 = windows.numWindows;
    
    slope               = snakeCompl.slope;
    
    dummy_mod           = zeros(len, 1);
    
    for i = 1 : len
        
        sigmoidLeft      = exp(slope * (norm - amp_windows(i, 2)))/...
                             (1 + exp(slope * (norm - amp_windows(i, 2))));
        sigmoidRight     = exp(slope * (norm - amp_windows(i, 1)))/...
                             (1 + exp(slope * (norm - amp_windows(i, 1))));
                         

%         sigmoidLeft        = 1/(1 + exp(-slope * (norm - amp_windows(i, 1))));
%         sigmoidRight       = 1/(1 + exp( slope * (norm - amp_windows(i, 2))));
        
        dummy_mod(i, :)  = amp_snake(i) * (-sigmoidLeft + sigmoidRight);
    end
    
    modulatedAmp         = sum(dummy_mod);

end