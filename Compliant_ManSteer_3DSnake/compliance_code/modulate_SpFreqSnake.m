function modulatedSpFreq = modulate_SpFreqSnake(norm, snakeCompl, windows)

    spFreq_snake        = snakeCompl.spFreq;
    spFreq_windows      = windows.spFreq;
    len                 = size(spFreq_windows, 1);
    
    slope               = snakeCompl.slope;
    
    dummy_mod           = zeros(len, 1);
    
    for i = 1 : len
        
        sigmoidLeft      = exp(slope * (norm - spFreq_windows(i, 2)));
        
        sigmoidRight     = exp(slope * (norm - spFreq_windows(i, 1))); 
 
        dummy_mod(i,:)   = spFreq_snake(i) / slope * ... 
                           (-log(sigmoidLeft + 1) + log(sigmoidRight + 1));
                
    end

    modulatedSpFreq      = sum(dummy_mod);

end