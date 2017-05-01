function estimateGravityLive()
% Estimates online the head and VC position of the SEASnake in a
% gravity-oriented frame
% THIS WILL NOT WORK UNLESS YOU CAN CONNECT TO THE SEA SNAKE

    g = HebiLookup.newConnectedGroupFromName('Spare','SA008');
    snakeData = setupSnakeData( 'SEA Snake', g.getInfo.numModules);
    
    CF = ComplementaryFilter(snakeData);

    while true

        CF.update(g.getNextFeedback());        
        T_head = CF.getInGravity ('head')
        T_VC = CF.getInGravity ('VC')
        T_head = CF.getInGravity ('tail')        

    end

end
