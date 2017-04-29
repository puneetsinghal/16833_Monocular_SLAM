function [angles_array,mainAxis,currSerpPos,shapeRegularity] = get_NewAngles2D(snakeCompl, snakeConst, windows)
    
    FUDGEFACTOR = 0.8471; % Something about the snake doing a cos (sin(pi/2 + ...))
                          % but the initial mainAxis is not zero and blabla
                          % something weird...
    
    numModules        = snakeConst.numModules;
    angles_array      = zeros(numModules, 1);
    angles_array0      = zeros(numModules, 1);
    phi               = snakeCompl.phi;
    

    for i = 1 : numModules
        
        norm             = i / numModules;
        
        ampNew      = modulate_AmpSnake(norm, snakeCompl, windows);
        spFreqNew   = modulate_SpFreqSnake(norm, snakeCompl, windows);
        offsetNew   = modulate_OffsetSnake(norm, snakeCompl, windows);
%         torsionNew  = modulate_torsionSnake(norm, snakeCompl, windows);
        angle       = offsetNew + ampNew * sin(spFreqNew - phi + pi/2);
%         angle0      = ampNew * sin(spFreqNew - phi + pi/2);

        if mod(i, 2)
%             angle = angle * cos(torsionNew);
%             angle0 = angle0 * cos(torsionNew);
            
            if i == 1
                % defining the head's heading -> used to get main Axis
                mainAxis = ampNew * cos(spFreqNew - phi + pi/2 - FUDGEFACTOR);
                currSerpPos = spFreqNew - phi + pi/2;
            end
        else
            angle = 0;
%             angle0 = angle0 * sin(torsionNew);
        end
        
        angles_array(i) = min(pi/2, max(-pi/2, angle));
%         angles_array0(i) = min(pi/2, max(-pi/2, angle0));
    end
    angles_array(end) = pi / 2;
    angles_array0(end) = pi / 2;
    
    shapeRegularity = sum( (angles_array - angles_array0).^2 );
end