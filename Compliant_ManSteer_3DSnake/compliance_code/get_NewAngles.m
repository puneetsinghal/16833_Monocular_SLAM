function angles_array = get_NewAngles(snakeCompl, snakeConst, snakeNom, windows)

    numModules        = snakeConst.numModules;
    angles_array      = zeros(numModules, 1);
    phi               = snakeCompl.phi;

    for i = 1 : numModules
        
        norm             = i / numModules;
        
%         if mod(i, 2)

            ampNew      = modulate_AmpSnake(norm, snakeCompl, windows);
            spFreqNew   = modulate_SpFreqSnake(norm, snakeCompl, windows);
            offsetNew   = modulate_OffsetSnake(norm, snakeCompl, windows);
            angle       = offsetNew + ampNew * sin(spFreqNew - phi + pi/2);
  
%             angles_array(i, :) = min(pi/2, max(-pi/2, angle));
            angles_array(i, :) = dampingAngleFunction(angle);
%         else
%             
%             angles_array(i, :) = 0; 
%         
%         end
    end
    angles_array(end) = pi / 2;
    
    
end