function [snakeCompl, snakeNom, windows] = ...
                           update_Structures2D(snakeCompl, snakeConst, snakeNom, windows)
    
    windows_array     = windows.array;
    len               = windows.numWindows;
    
    offset_snake      = snakeCompl.offset;
    amp_snake         = snakeCompl.amp;
    spFreq_snake      = snakeCompl.spFreq;
%     torsion_snake      = snakeCompl.torsion;
    tauD              = snakeCompl.tau_D;
    
    sigma_Nom         = snakeNom.sigma_Nom;
    sigma_D           = snakeNom.sigma_D;
    dsigmaD_dt        = snakeNom.dsigmaD_dt;
    
    if (windows.spFreq(1) > -0.333333333)
        windows_array = [(windows_array(1) - abs(windows_array(1) - ...
            windows_array(2))), windows_array(1:end-1)]; 
        
        amp_snake      =  [    amp_snake(1);         amp_snake(1 : end-1)];
        spFreq_snake   =  [ spFreq_snake(1);      spFreq_snake(1 : end-1)];
%         torsion_snake   =  [ torsion_snake(1);      torsion_snake(1 : end-1)];
        tauD           =  [          tauD(1);        tauD(1 :  len-1); ...
                                 tauD(len+1);        tauD(len+1 : 2*len-1)];
%                                  tauD(2*len+1);      tauD(2*len+1 : 3*len-1)];
        
        sigma_Nom      =  [ sigma_Nom(1); sigma_Nom(1 :   len - 1); ...
                            sigma_Nom(len+1);   sigma_Nom(len+1 : 2*len-1); ...
                            sigma_Nom(2 * len+1);   sigma_Nom(2 * len+1 : 3*len-1); ...
%                             sigma_Nom(3 * len+1);   sigma_Nom(3 * len+1 : 4*len-1); ...
                                                           sigma_Nom(end)];
        sigma_D        = [     sigma_D(1); sigma_D(1 :   len-1); ...
                              sigma_D(len+1);     sigma_D(len+1 : 2*len - 1); ...
                              sigma_D(2 * len+1);     sigma_D(2 * len+1 : 3*len - 1); ...
%                               sigma_D(3 * len+1);     sigma_D(3 * len+1 : 4*len - 1); ...
                                                             sigma_D(end)];    
        dsigmaD_dt     = [    dsigmaD_dt(1);       dsigmaD_dt(1 :   len-1); ...
                          dsigmaD_dt(len+1);   dsigmaD_dt( len+1: 2*len - 1)];
%                           dsigmaD_dt(2*len+1);   dsigmaD_dt( 2*len+1: 3*len - 1)];
        
        snakeCompl.phi = snakeCompl.tmFreq;

    end
    windows.array       = windows_array;   
    
    windows.offset      = update_OffsetWindows(windows);
    windows.spFreq      = update_SpFreqWindows(snakeCompl, snakeConst, windows);
    windows.amp         = update_AmpWindows(snakeCompl, snakeConst, windows);
    
    snakeCompl.offset   = offset_snake;
    snakeCompl.amp      = amp_snake;
    snakeCompl.spFreq   = spFreq_snake;
%     snakeCompl.torsion  = torsion_snake;
    snakeCompl.tau_D    = tauD;

    snakeNom.sigma_Nom  = sigma_Nom;
    snakeNom.sigma_D    = sigma_D;
    snakeNom.dsigmaD_dt = dsigmaD_dt;

end