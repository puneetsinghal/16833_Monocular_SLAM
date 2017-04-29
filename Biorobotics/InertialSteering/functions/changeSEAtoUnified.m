function unified_angles = changeSEAtoUnified(snakeData, SEA_angles)
%changeSEAtoUnified changes output from SEA modules to a simpler unified
%style. 
%   Switches the signs of all joint angles and flips the module order to
%   be head to tail.
  for n = 1:length(SEA_angles(:,1))
        SEA_angles(n,:) = snakeData.reversals.*SEA_angles(n,:);
        SEA_angles(n,:) = fliplr(SEA_angles(n,:));
  end
  unified_angles = SEA_angles;
end