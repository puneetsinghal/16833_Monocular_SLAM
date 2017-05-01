function [snakeCompl, snakeNom, windows] = ...
                           update_Structures(snakeCompl, snakeConst, snakeNom, windows)
    
    windows_array     = windows.array;
    len               = windows.numWindows;
    
    amp_snake         = snakeCompl.amp;
    spFreq_snake      = snakeCompl.spFreq;
    tauD              = snakeCompl.tau_D;
    
    sigma_Nom         = snakeNom.sigma_Nom;
    sigma_D           = snakeNom.sigma_D;
    dsigmaD_dt        = snakeNom.dsigmaD_dt;
    
    if (windows.spFreq(1) > -0.333333333)
%         disp('refresh');
      
        windows_array = [(windows_array(1) - abs(windows_array(1) - ...
            windows_array(2))), windows_array(1:end-1)]; 
        
        amp_snake      =  [    amp_snake(1);         amp_snake(1 : end-1)];
        spFreq_snake   =  [ spFreq_snake(1);      spFreq_snake(1 : end-1)];
        tauD           =  [          tauD(1);            tauD(1 :  len-1); ...
                                 tauD(len+1);        tauD(len+1 : 2*len-1)];
        
        sigma_Nom      =  [ sigma_Nom(1); sigma_Nom(1 :   len - 1); ...
                            sigma_Nom(len+1);   sigma_Nom(len+1 : 2*len-1); ...
                            sigma_Nom(2 * len+1);   sigma_Nom(2 * len+1 : 3*len-1); ...
                                                           sigma_Nom(end)];
        sigma_D        = [    sigma_D(1); sigma_D(1 :   len - 1); ...
                              sigma_D(len+1);     sigma_D(len+1 : 2*len - 1); ...
                              sigma_D(2 * len+1);     sigma_D(2 * len+1 : 3*len - 1); ...
                                                             sigma_D(end)];    
        dsigmaD_dt     = [    dsigmaD_dt(1);       dsigmaD_dt(1 :   len-1); ...
                          dsigmaD_dt(len+1);   dsigmaD_dt( len+1: 2*len - 1)]; 
        
        snakeCompl.phi = snakeCompl.tmFreq;

    % Snake is moving backward, windows must refresh forward
%     elseif (windows.spFreq(1) < 0)
%      
%         disp('back');
%         windows_array = [windows_array(2:end), ...
%         windows_array(end) + abs(windows_array(end) - windows_array(end - 1))];
% 
%         
% %      offset_snake   =  [  offset_snake(2 : end),     offset_snake(end)];
%         amp_snake      =  [     amp_snake(2 : end);        amp_snake(end)];
%         spFreq_snake   =  [  spFreq_snake(2 : end);     spFreq_snake(end)];
%         tauD           =  [        tauD(2 :   len);             tauD(len); ...
%                                tauD(len+2 : 2*len);           tauD(2*len); ...
%                              tauD(2*len+2 : 3*len);           tauD(3*len); ...
%                                                              tauD(end)];
%         sigma_Nom      = [    sigma_Nom(2 :   len);        0; ...
%                           sigma_Nom(len+2 : 2*len);      sigma_Nom(2*len); ...
%                         sigma_Nom(2*len+2 : 3*len);      sigma_Nom(3*len); ...
%                                                        sigma_Nom(end)];
%         sigma_D        = [      sigma_D(2 :   len);          0; ...
%                             sigma_D(len+2 : 2*len);        sigma_D(2*len); ...
%                           sigma_D(2*len+2 : 3*len);        sigma_D(3*len); ...
%                                                           sigma_D(end)]; 
%         dsigmaD_dt      = [  dsigmaD_dt(2 :   len);       dsigmaD_dt(len); ...
%                          dsigmaD_dt(len+2 : 2*len);     dsigmaD_dt(2*len); ...
%                        dsigmaD_dt(2*len+2 : 3*len);     dsigmaD_dt(3*len); ...
%                                                           dsigmaD_dt(end)]; 
%         
%         snakeCompl.phi = snakeCompl.tmFreq;
%                                                    
    end
    windows.array       = windows_array;    
    
    windows.offset      = update_OffsetWindows(windows);
    windows.spFreq      = update_SpFreqWindows(snakeCompl, snakeConst, windows);
    windows.amp         = update_AmpWindows(snakeCompl, snakeConst, windows);
    
    snakeCompl.amp      = amp_snake;
    snakeCompl.spFreq   = spFreq_snake;
    snakeCompl.tau_D    = tauD;

    snakeNom.sigma_Nom  = sigma_Nom;
    snakeNom.sigma_D    = sigma_D;
    snakeNom.dsigmaD_dt = dsigmaD_dt;

end