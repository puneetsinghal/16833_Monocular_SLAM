    tau_Ext                = changeSEAtoUnified(snakeData,fbk.torque)'; 
    tau_Applied            = get_AppliedForceNoOffset(tau_Ext, ...
                                          snakeConst, snakeCompl, windows);
    [snakeCompl, snakeNom] = get_NewNomParam_AutopilotP(snakeCompl, snakeNom, ...
                                     snakeConst, windows, tau_Applied, dt);
        
%     windows                = update_Windows(snakeCompl, windows);
%     [snakeCompl, snakeNom, windows]...
%                            = update_StructuresP(snakeCompl, snakeConst, snakeNom, windows);
%     if isnan(mainAxis0)
%         [~,mainAxis0]      = get_NewAnglesNoOffsetP(snakeCompl, snakeConst, windows);
%     end
    [commanded_angles,mainAxis]...
                           = get_NewAnglesNoOffsetP(snakeCompl, snakeConst, windows);

    cmd.position           = changeUnifiedToSEA(snakeData,commanded_angles');