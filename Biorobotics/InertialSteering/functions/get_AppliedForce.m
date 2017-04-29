function tau_Applied = get_AppliedForce(tau_Ext, ...
                                           snakeConst, snakeCompl, windows)
                                       
    J           = generate_Jacobian(snakeConst, snakeCompl, windows);
    tau_D       = snakeCompl.tau_D;
    
    tau_Applied = tau_D - J' * tau_Ext;
end
