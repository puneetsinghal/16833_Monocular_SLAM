function modulatedTorsion = modulate_torsionSnake(norm, snakeCompl, windows)
    
    % Get information from the structure
    slope           = 200; 
    torsion_windows  = windows.torsion;
    torsion          = snakeCompl.torsion;

%     disp('snake torsion');
%     disp(torsion);
    % Initialize the local variables
    len          = size(torsion, 1);
%     disp('len');
%     disp(len);
    dummy_mod    = zeros(len, 1);
    
    % Scale the torsions to the sigmoid function
    for i = 1 : len    
        sigmoidLeft      = exp(slope * (norm - torsion_windows(i, 2)))/...
                             (1 + exp(slope * (norm - torsion_windows(i, 2))));
        sigmoidRight     = exp(slope * (norm - torsion_windows(i, 1)))/...
                             (1 + exp(slope * (norm - torsion_windows(i, 1))));
                         
        dummy_mod(i, :)  = torsion(i) * (-sigmoidLeft + sigmoidRight);
    end
 
    modulatedTorsion = sum(dummy_mod);
%         
end