function J_out = generate_Jacobian(snakeConst, snakeCompl, windows)

%     disp('torsion');
  numModules   = snakeConst.numModules;
  len          = windows.numWindows;
  phi          = snakeCompl.phi;
  J_out        = zeros(numModules, 3 * len);
  
  for i = (1 : numModules)
        
      norm     = i / numModules;  
      
      spFreqW  = modulate_SpFreqWindows(norm, snakeCompl, windows);
      ampW     = modulate_AmpWindows(norm, snakeCompl, windows);

      spFreqS  = modulate_SpFreqSnake(norm, snakeCompl, windows);
      ampS     = modulate_AmpSnake(norm, snakeCompl, windows);
      torS     = modulate_torsionSnake(norm, snakeCompl, windows);
      
      if mod(i,2)
          J_out(i,:) =  [          ampW * sin(spFreqS + pi/2 - phi);...
                         spFreqW * ampS * cos(spFreqS + pi/2 - phi);...
                         ampS * -sin(torS) * sin(spFreqS + pi/2 - phi) * ones(len,1)];
      else
          J_out(i,:) =  [zeros(len,1); ...
                         zeros(len,1); ...
                         ampS * cos(torS) * sin(spFreqS + pi/2 - phi) * ones(len,1)];
      end
  end

end
