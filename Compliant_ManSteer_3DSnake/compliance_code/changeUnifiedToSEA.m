function  SEA_angles= changeUnifiedToSEA(snakeData, unified_angles)
%changeUnifiedToSEA changes output from inified snake simple style to SEA
% module style. 
%   flips the module order to
%   be head to tail, and Switches the signs of all joint angles  
  for n = 1:length(unified_angles(:,1))
      unified_angles(n,:) = fliplr(unified_angles(n,:));  
      unified_angles(n,:) = snakeData.reversals.*unified_angles(n,:);
      
  end
 SEA_angles=  unified_angles;
end