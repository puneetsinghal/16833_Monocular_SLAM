function estimateGravityLive()
% Estimates online the head and VC position of the SEASnake in a
% gravity-oriented frame
% THIS WILL NOT WORK UNLESS YOU CAN CONNECT TO THE SEA SNAKE

    g = HebiLookup.newConnectedGroupFromName('SEA-Snake','SA008');
    snakeData = setupSnakeData( 'SEA Snake', g.getInfo.numModules);
    
    CF = ComplementaryFilter(snakeData, ...
        'accelOffsets', accelOffsets(g.getInfo.name), ...
        'gyroOffsets', gyroOffsets(g.getInfo.name));
    
    while true
        CF.update(g.getNextFeedback());
        T_head = CF.getInGravity('body');
    end
end


function accelOffsets = accelOffsets(names)

    known_names =  ...   
    {   'SA002', 'SA017', 'SA006', 'SA004', ...
        'SA007', 'SA005', 'SA032', 'SA003', ...
        'SA013', 'SA010', 'SA008', 'SA031', ...
        'SA025', 'SA012', 'SA023', 'SA018', ...
        'SA011','SA015'};
    
    
    known_offsets = zeros(3,18);
    
    known_offsets(2,1) = (10.1-9.7)/2;
    known_offsets(2,2) = 0;
    known_offsets(2,3) = (8.6-11.2)/2;
    known_offsets(2,4) = (9.3-10.5)/2;
    known_offsets(2,5) = 0;
    known_offsets(2,6) = (9.2-10.6)/2;
    known_offsets(2,7) = (9.6-10.1)/2;
    known_offsets(2,8) = (10-9.7)/2;    
    known_offsets(2,9) = (10-9.7)/2;
    known_offsets(1,10) = (10-9.6)/2;    
    known_offsets(2,10) = (10.2-9.6)/2;
    known_offsets(2,11) = (9.5-10.3)/2;
    known_offsets(2,12) = (8.6-11.2)/2;
    known_offsets(2,13) = 0;
    known_offsets(2,14) = (10.2-9.5)/2;   
    known_offsets(2,15) = (9.4-10.4)/2;
    known_offsets(1,16) = (9.9-9.7)/2;
    known_offsets(1,17) = (8.6-11)/2;
    known_offsets(2,18) = 0;
    
    
    accelOffsets = zeros(3,length(names));
    for i=1:length(names)
        index = find(strcmp(known_names, names(i)));
        if strcmp('', names(i))
            accelOffsets(:,i) = [];
        elseif ~isempty(index)
            accelOffsets(:,i) = known_offsets(:,index);
        else
           disp(['WARNING, this acceleration offset of module ', num2str(i),' is unknown']);
           accelOffsets(:,i) = zeros(3,1);           
           pause();
        end

    end
end

function gyroOffsets = gyroOffsets(names)
    known_names =  ...   
    {   'SA002', 'SA017', 'SA006', 'SA004', ...
        'SA007', 'SA005', 'SA032', 'SA003', ...
        'SA013', 'SA010', 'SA008', 'SA031', ...
        'SA025', 'SA012', 'SA023', 'SA018', ...
        'SA011','SA015'};
    
    known_offsets = ...
    [ 0.0622   -0.1052    0.0255    0.0101    0.0359    0.0204    0.0245   -0.0048   -0.0138   -0.0033    0.0384    0.0399    0.0105    0.0319    0.0487    0.0387   -0.0298    0.0225;
   -0.0586   -0.0370   -0.0295   -0.0554   -0.0294   -0.0446   -0.0354   -0.0146   -0.0027   -0.0424   -0.0395    0.0013   -0.0317   -0.0567   -0.0431   -0.0741   -0.0348   -0.0447;
   -0.0546    0.0343   -0.0287   -0.0271   -0.0632   -0.0630    0.0081   -0.0358   -0.0680   -0.0386    0.0109   -0.0642   -0.0263   -0.0100   -0.0579   -0.0404   -0.1232   -0.0685];

    gyroOffsets = zeros(3,length(names));
    for i=1:length(names)
        index = find(strcmp(known_names, names(i)));
        if strcmp('', names(i))
            gyroOffsets(:,i) = [];
        elseif ~isempty(index)
            gyroOffsets(:,i) = known_offsets(:,index);
        else
           disp(['WARNING, this gyro offset of module ', num2str(i),' is unknown']);
           gyroOffsets(:,i) = zeros(3,1);
           pause();
        end

    end
    
    

end