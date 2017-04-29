function tau_Applied = get_AppliedForce2D(tau_Ext, ...
                                           snakeConst, snakeCompl, windows)
                                       
    J           = generate_Jacobian2D(snakeConst, snakeCompl, windows);
    tau_D       = snakeCompl.tau_D;
    
    tau_Applied = tau_D - J' * tau_Ext;
end
