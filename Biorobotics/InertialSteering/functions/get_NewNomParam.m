function [snakeCompl, snakeNom] = get_NewNomParam(snakeCompl, snakeNom, ...
                                     snakeConst, windows, tau_Applied, dt)
    
    compliantQ = true;
    steerQ = true;
    
    len               = windows.numWindows;
    
    MdPrime           = snakeNom.MdPrime;
    BdPrime           = snakeNom.BdPrime;
    KdPrime           = snakeNom.KdPrime;
    
    index             = windows.steerIndex;
    sigma_Nom         = snakeNom.sigma_Nom;
    sigma_D           = snakeNom.sigma_D;
    dsigmaD_dt        = snakeNom.dsigmaD_dt;
    
    if steerQ
        steer1 = -pi/2; steer2 = 0; steer3 = pi/2;

        if(index > 0)
            alphaC = 1.; Kh = 3.;
            sigma_D(index)   = sigma_D(index) + dt * (- alphaC * (sigma_D(index) - steer1).*(sigma_D(index) - steer2).*(sigma_D(index) - steer3) + Kh * (-snakeNom.h/2 - sigma_D(index)));
            sigma_Nom(index) = sigma_Nom(index) + dt * (- alphaC * (sigma_Nom(index) - steer1).*(sigma_Nom(index) - steer2).*(sigma_Nom(index) - steer3) + Kh * (-snakeNom.h/2 - sigma_Nom(index)));
            snakeNom.steeringOffset = sigma_Nom(index);
        end
    end
    
    if compliantQ
        d2sigma_dt2       = MdPrime \ (tau_Applied - BdPrime * dsigmaD_dt ...
                                            - KdPrime * (sigma_D(len + 1:end - 1) - sigma_Nom(len + 1:end - 1)));
        dsigmaD_dt         = dsigmaD_dt + d2sigma_dt2 * dt;
        sigma_D(len + 1:end - 1) = sigma_D(len + 1:end - 1) + dsigmaD_dt  * dt;
        snakeNom.dsigmaD_dt = dsigmaD_dt;

    end
    
    offset            = sigma_D(          1:     len);
    amp               = sigma_D(    len + 1: 2 * len);    
    spFreq            = sigma_D(2 * len + 1: 3 * len);
    torsion           = sigma_D(3 * len + 1: 4 * len);
    tmFreq            = snakeCompl.tmFreq + snakeConst.tmFreq * dt;
    if any(spFreq <= 0.01)
        spFreq(spFreq <= 0.01) = 0.01;
    end

    snakeCompl.offset   = offset;
    snakeCompl.amp      = amp;
    snakeCompl.spFreq   = spFreq;
    snakeCompl.torsion  = torsion;
    snakeCompl.tmFreq   = tmFreq;
    
    snakeNom.sigma_Nom  = sigma_Nom;
    snakeNom.sigma_D    = sigma_D;
end