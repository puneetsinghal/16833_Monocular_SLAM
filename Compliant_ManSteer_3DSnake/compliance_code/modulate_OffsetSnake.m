function modulatedOffset = modulate_OffsetSnake(norm, snakeCompl, windows)
    
    % Get information from the structure
    slope           = 200; 
    offset_windows  = windows.offset;
    offset          = snakeCompl.offset;

%     disp('snake offset');
%     disp(offset);
    % Initialize the local variables
    len          = size(offset, 1);
%     disp('len');
%     disp(len);
    dummy_mod    = zeros(len, 1);
    
    % Scale the offsets to the sigmoid function
    for i = 1 : len    
%         
        sigmoidLeft      = exp(slope * (norm - offset_windows(i, 2)))/...
                             (1 + exp(slope * (norm - offset_windows(i, 2))));
        sigmoidRight     = exp(slope * (norm - offset_windows(i, 1)))/...
                             (1 + exp(slope * (norm - offset_windows(i, 1))));
                         
        dummy_mod(i, :)  = offset(i)/4 * (-sigmoidLeft + sigmoidRight);
    
    end
 
    modulatedOffset = sum(dummy_mod);
%         
end