function modulatedHead = modulate_HeadSnake(norm, spFreqNew, phi)
    
    mu            = 1/6;
    sigma         = 1/16;
    
    modulatedHead = sin(spFreqNew - phi + pi/2)/...
                                   (1 + exp(-(norm - mu)/(2 * (sigma)^2)));    
end