function modulatedOffset      = modulate_OffsetWindows(norm, snakeCompl,...
                                                                   windows)
    offset_windows            = windows.offset;

    len                       = windows.numWindows;
    
    slope                     = snakeCompl.slope;
    
    modulatedOffset           = zeros(len, 1);
    
    for i = 1 : len
        
        sigmoidLeft           = exp(slope * (norm - offset_windows(i, 2)))/...
                          (1 + exp(slope * (norm - offset_windows(i, 2))));
        sigmoidRight          = exp(slope * (norm - offset_windows(i, 1)))/...
                          (1 + exp(slope * (norm - offset_windows(i, 1))));

        modulatedOffset(i, :) = -sigmoidLeft + sigmoidRight;
%         if norm < offset_windows(windows.steerIndex, 2)       
%             modulatedOffset(i, :) = -sigmoidLeft + sigmoidRight;
%         else
%             modulatedOffset(i, :) = 0;
%         end

        
    end
end