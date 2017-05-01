function J_out = generate_Jacobian(snakeConst, snakeCompl, windows)

  numModules   = snakeConst.numModules;
  len          = windows.numWindows;
  phi          = snakeCompl.phi;
  J_out        = zeros(numModules, 2 * len);
  
  for i = (1 : numModules)
        
      norm     = i / numModules;  
      
      spFreqW  = modulate_SpFreqWindows(norm, snakeCompl, windows);
      ampW     = modulate_AmpWindows(norm, snakeCompl, windows);

      spFreqS  = modulate_SpFreqSnake(norm, snakeCompl, windows);
      ampS     = modulate_AmpSnake(norm, snakeCompl, windows);

%       if mod(i,2) 

          J_out(i,:) =  [    ampW *        sin(spFreqS + pi/2 - phi);...
                          spFreqW * ampS * cos(spFreqS + pi/2 - phi)]; 
%       else   
%           
%           J_out(i,:) =  0;
% 
%       end
  end            
end
