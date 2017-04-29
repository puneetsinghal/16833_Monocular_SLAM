function accelOffsets = retrieveAccelOffsets(names)
    
    known_names =  ...   
    {   'SA002'
        'SA017'
        'SA006'
        'SA004'
        'SA007'
        'SA005'
        'SA032'
        'SA003'
        'SA013'
        'SA010'
        'SA008'
        'SA031'
        'SA025'
        'SA012'
        'SA023'
        'SA018'
        'SA011'
        'SA015'};
    
    
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
           pause();
        end

    end
    
    

end