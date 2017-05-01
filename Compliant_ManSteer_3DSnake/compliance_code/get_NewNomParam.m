function [snakeCompl, snakeNom] = get_NewNomParam(snakeCompl, snakeNom, ...
                                     snakeConst, windows, tau_Applied, dt)

    len               = windows.numWindows;
                                                       
    MdPrime           = diag([1.5 * ones(1, len), ...
                              2 * ones(1, len)]);
    BdPrime           = diag([3 * ones(1, len), ...
                              1 * ones(1, len)]);
    KdPrime           = diag([4 * ones(1, len), ...
                              1 * ones(1, len)]);
    
    scale             = snakeNom.scale;
    steer             = snakeNom.steer;
    
    index             = windows.steerIndex;
    sigma_Nom         = snakeNom.sigma_Nom;
    sigma_D           = snakeNom.sigma_D;
    dsigmaD_dt        = snakeNom.dsigmaD_dt;    
    maxSteerAngle     =  pi/2;
    minSteerAngle     = -pi/2;

    if(index > 0)
            nom  = steer + sigma_Nom(index);
            des  = steer + sigma_D(index);
            if (nom > maxSteerAngle || des > maxSteerAngle)
                nom = maxSteerAngle;
                des = maxSteerAngle;
            elseif (nom < minSteerAngle || des < minSteerAngle)
                nom = minSteerAngle;
                des = minSteerAngle;    
            end
            
            sigma_D(index) = des;
            sigma_Nom(index) = nom;
    end
        
    sigma_Nom(end)    = sigma_Nom(end) + scale * snakeConst.tmFreq * dt;
    sigma_D(end)      =   sigma_D(end) + scale * snakeConst.tmFreq * dt;
    
    d2sigma_dt2       = MdPrime \ (tau_Applied - BdPrime * (dsigmaD_dt) ...
                                        - KdPrime * (sigma_D(len + 1:end - 1) - sigma_Nom(len + 1:end - 1)));
    dsigmaD_dt        = dsigmaD_dt + d2sigma_dt2 * dt;
    sigma_D(len + 1:end - 1) = sigma_D(len + 1:end - 1) + dsigmaD_dt  * dt;
    offset            = sigma_D(          1:     len);
    amp               = sigma_D(    len + 1: 2 * len);
    spFreq            = sigma_D(2 * len + 1: 3 * len);    
    tmFreq            = sigma_D(end);
    
    if any(spFreq <= 0.01)
        spFreq(spFreq <= 0.01) = 0.01;
    end
    
    snakeNom.sigma_Nom  = sigma_Nom;
    snakeNom.sigma_D    = sigma_D;
    snakeNom.dsigmaD_dt = dsigmaD_dt;
    
    snakeCompl.offset   = offset;
    snakeCompl.amp      = amp;
    snakeCompl.spFreq   = spFreq;
    snakeCompl.tmFreq   = tmFreq;

end